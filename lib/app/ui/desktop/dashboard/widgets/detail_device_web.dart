import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phuonghai/app/controllers/home_controller.dart';
import 'package:phuonghai/app/ui/common/widgets/device_card.dart';
import 'package:phuonghai/app/ui/common/widgets/divider_with_text.dart';
import 'package:phuonghai/app/ui/common/widgets/history_widget.dart';
import 'package:phuonghai/app/ui/common/widgets/iaq_card.dart';
import 'package:phuonghai/app/ui/common/widgets/refri_item_widget.dart';
import 'package:phuonghai/app/ui/mobile/device/device_info.dart';

import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:flutter_vlc_player/src/vlc_player_controller.dart';
import 'package:url_launcher/url_launcher.dart';



class DetailDeviceWeb extends GetWidget<HomeController> {
  const DetailDeviceWeb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      color: Colors.white,
      child: Container(
        width: 460,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          border: Border(
            left: BorderSide(
              color: Colors.black54,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 56,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Colors.green.shade400,
                    Colors.indigo.shade400,
                  ],
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      controller.detailDevice[0].friendlyName,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.visible.value = false;
                      controller.detailDevice[0].isSelected.value = false;
                    },
                    splashRadius: 22,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                children: [
                  Obx(
                    () => DividerWithText(
                      text:
                          "${"lastUpdated".tr}: ${controller.detailDevice[0].getSyncDateObs}",
                    ),
                  ),
                  if (controller.detailDevice[0].type == 'Refrigerator')
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: RefriItemWidget(
                        sensor: controller.detailDevice[0].sensor,
                        isSetting: true,
                      ),
                    )
                  else if (controller.detailDevice[0].type == 'Air Node')
                    IaqWidget(model: controller.detailDevice[0])
                  else if (controller.detailDevice[0].type ==
                      'Environmental Chamber')
                    StatusEnvironList(model: controller.detailDevice[0]),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 8,
                      top: 5,
                      right: 8,
                      bottom: 20,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (co, i) {
                        if (controller.detailDevice[0].sensors[i].name ==
                            ' FTP') {
                          return FTPConnection(
                              sensor: controller.detailDevice[0].sensors[i]);
                        }
                        return SmartpHSensor(
                          sensor: controller.detailDevice[0].sensors[i],
                          isSetting: true,
                        );
                      },
                      itemCount: controller.detailDevice[0].sensors.length,
                    ),
                  ),
                  DividerWithText(text: "Security Camera"),

                //  //As web browser does not support vlc so provide a clickable link
                GestureDetector(
                onTap: () async {
                    //const url = "rtsp://admin:1234abcd@222.252.98.34:554/Streaming/Channels/101";
                    var url = controller.detailDevice[0].camUrl1;
                    final Uri _url = Uri.parse(url);
                    await launchUrl(_url);
                },
                child: Image.asset('images/camera.png'),
                ),
                    
                //ExampleVideo(camUrl1: "rtsp://admin:1234abcd@14.241.170.107:554/Streaming/Channels/101"),
                //TestWidget(title:"rtsp://admin:1234abcd@14.241.170.107:554/Streaming/Channels/101"),
                  
                  DividerWithText(text: 'dataHistory'.tr),

                  if (controller.detailDevice[0].type == 'Refrigerator')
                    HistoryWidget(sensors: [
                      controller.detailDevice[0].sensor.temp,
                      controller.detailDevice[0].sensor.pin,
                    ])
                  else
                    HistoryWidget(
                        sensors: controller.detailDevice[0].sensors
                            .skipWhile((value) => value.name == ' FTP')
                            .toList()),
                  const SizedBox(height: 15),
                  DeviceInfo(model: controller.detailDevice[0]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusEnvironList extends StatelessWidget {
  const StatusEnvironList({
    Key? key,
    this.model,
  }) : super(key: key);

  final dynamic model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ListTile(
                  leading: const SizedBox(
                      height: double.infinity,
                      child: Icon(Icons.monitor_heart)),
                  subtitle: Obx(() => Text(
                        model.operation.value.toString().tr,
                        style: TextStyle(
                          color: model.operation.value == 'stop'
                              ? null
                              : Colors.orange,
                        ),
                      )),
                  title: Text('deviceInfo'.tr),
                ),
              ),
              const SizedBox(height: 35, child: VerticalDivider()),
              Expanded(
                child: ListTile(
                  leading: const Icon(Icons.timelapse),
                  title: Obx(() => Text(
                      '${(Duration(seconds: model.countTimer.value))}'
                          .substring(0, 4)
                          .padLeft(5, '0'))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => Icon(
                        Icons.waves,
                        color: model.heater.value == 1 ? Colors.orange : null,
                      )),
                  const SizedBox(height: 2),
                  Obx(() => Text(
                        'heater'.tr,
                        style: TextStyle(
                          color: model.heater.value == 1 ? Colors.orange : null,
                        ),
                      ))
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => Icon(
                        Icons.ac_unit,
                        color: model.cooler.value == 1 ? Colors.orange : null,
                      )),
                  const SizedBox(height: 2),
                  Obx(() => Text(
                        'cooler'.tr,
                        style: TextStyle(
                          color: model.cooler.value == 1 ? Colors.orange : null,
                        ),
                      ))
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => Icon(
                        Icons.invert_colors_off,
                        color: model.humidity.value == 1 ? Colors.orange : null,
                      )),
                  const SizedBox(height: 2),
                  Obx(() => Text(
                        'humiditier'.tr,
                        style: TextStyle(
                          color:
                              model.humidity.value == 1 ? Colors.orange : null,
                        ),
                      ))
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => Icon(
                        Icons.invert_colors,
                        color: model.moise.value == 1 ? Colors.orange : null,
                      )),
                  const SizedBox(height: 2),
                  Obx(() => Text(
                        'moiser'.tr,
                        style: TextStyle(
                          color: model.moise.value == 1 ? Colors.orange : null,
                        ),
                      ))
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}


class TestWidget extends StatelessWidget {
  const TestWidget({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(title);
  }
}


//cameraa 
// String url =  'rtsp://admin:1234abcd@14.241.170.107:554/Streaming/Channels/101';

class ExampleVideo extends StatefulWidget {
  const ExampleVideo({Key? key, required this.camUrl1}) : super(key: key);
  final String camUrl1;

  @override
  _ExampleVideoState createState() => _ExampleVideoState(camUrl1);
}

class _ExampleVideoState extends State<ExampleVideo> {

   String _camUrl1 = "";

  _ExampleVideoState(String camUrl1) {
    this._camUrl1 = camUrl1;
  }

  //  VlcPlayerController _vlcViewController = new VlcPlayerController.network(
  //  "",
  //   autoPlay: true,
  // );


  @override
  Widget build(BuildContext context) {
   
    return Column(
     
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new VlcPlayer(
              controller: new VlcPlayerController.network(
                this._camUrl1,
                autoPlay: true,
              ),
              aspectRatio: 16 / 9,
              placeholder: Text("Hello World"),
            ),
          ],
      );
  }
}