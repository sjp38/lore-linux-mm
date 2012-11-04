Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 431156B004D
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 07:50:29 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3667633pad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 04:50:28 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part2 00/13] introduce ACPI based system device hotplug driver
Date: Sun,  4 Nov 2012 20:50:02 +0800
Message-Id: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

This is the second part of the new ACPI based system device hotplug
framework, which implements the ACPI based system device hotplug
driver (acpihp_drv). For an introduction of the new framework,
please refer to:
https://lkml.org/lkml/2012/11/3/143
https://github.com/downloads/jiangliu/linux/ACPI%20Based%20System%20Device%20Dynamic%20Reconfiguration.pdf

And you may pull from:
https://github.com/jiangliu/linux.git acpihp_drv

The hotplug driver provides following features:
1) Configure/unconfigure affected system devices in optimal order
2) Provide sysfs interfaces for user to trigger hotplug operations
3) Provide interface to cancel ongoing hotplug opertions
4) Resolve dependencies among hotplug slots
5) Better error handling and recovery

This patch set implements the core of the new ACPI hotplug framework,
a state machine for ACPI hotplug slots. The state machine is:

       (plug in)     (power on)    (connect)      (configure)
 [ABSENT] <-> [PRESENT] <-> [POWERED] <-> [CONNECTED] <-> [CONFIGURED]
       (plug out)   (power off)   (disconnect)   (unconfigure)

[...]: state
(...): action
(connect): create ACPI devices and bind ACPI device drivers
(disconnect): unbind ACPI device drivers and destroy ACPI devices
(configure): allocate resources and put system devices into working
(unconfigure): stop system devices from working and free resources

It depends on the ACPI hotplug slot enumeration driver to control each
slot in platform specific ways, and also depends on ACPI device drivers
for processor, memory, PCI host bridge and container to configure/
unconfigure each system device.

For example, Intel Emerald Ridge/Quantum S4R platform has
1) 4 hotpluggable physical processors
2) 8 hotpluggable memory boards (each processor has two memory boards)
3) 1 hotpluggable IOH and 1 non-hotpluggable legacy IOH
Following command sequence shows how to hot-remove and then hot-add
a physical processor with two memory boards attached to it.

Intel-server:~ # cd /sys/devices/LNXSYSTM\:00/acpihp/CPU03/
Intel-server:/sys/devices/LNXSYSTM:00/acpihp/CPU03 # lscpu
......
CPU socket(s):         4
NUMA node(s):          4
......
NUMA node0 CPU(s):     0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76
NUMA node1 CPU(s):     2,6,10,14,18,22,26,30,34,38,42,46,50,54,58,62,66,70,74,78
NUMA node2 CPU(s):     1,5,9,13,17,21,25,29,33,37,41,45,49,53,57,61,65,69,73,77
NUMA node3 CPU(s):     3,7,11,15,19,23,27,31,35,39,43,47,51,55,59,63,67,71,75,79
Intel-server:/sys/devices/LNXSYSTM:00/acpihp/CPU03 # free
             total       used       free     shared    buffers     cached
Mem:      57507896     506988   57000908          0       7520     151604
-/+ buffers/cache:     347864   57160032
Swap:      2096124          0    2096124
Intel-server:/sys/devices/LNXSYSTM:00/acpihp/CPU03 # echo disconnect > control
Intel-server:/sys/devices/LNXSYSTM:00/acpihp/CPU03 # lscpu
......
CPU socket(s):         3
NUMA node(s):          3
......
NUMA node0 CPU(s):     0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76
NUMA node1 CPU(s):     2,6,10,14,18,22,26,30,34,38,42,46,50,54,58,62,66,70,74,78
NUMA node2 CPU(s):     1,5,9,13,17,21,25,29,33,37,41,45,49,53,57,61,65,69,73,77
Intel-server:/sys/devices/LNXSYSTM:00/acpihp/CPU03 # free
             total       used       free     shared    buffers     cached
Mem:      40730680     419024   40311656          0       7648     144020
-/+ buffers/cache:     267356   40463324
Swap:      2096124          0    2096124
Intel-server:/sys/devices/LNXSYSTM:00/acpihp/CPU03 # echo configure > control
Intel-server:/sys/devices/LNXSYSTM:00/acpihp/CPU03 # lscpu
......
CPU socket(s):         4
NUMA node(s):          4
Vendor ID:             GenuineIntel
......
NUMA node0 CPU(s):     0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76
NUMA node1 CPU(s):     2,6,10,14,18,22,26,30,34,38,42,46,50,54,58,62,66,70,74,78
NUMA node2 CPU(s):     1,5,9,13,17,21,25,29,33,37,41,45,49,53,57,61,65,69,73,77
NUMA node3 CPU(s):     3,7,11,15,19,23,27,31,35,39,43,47,51,55,59,63,67,71,75,79

And following patch sets will enhance ACPI container, processor, memory
and PCI host bridge drivers to support the new hotplug framework.

Jiang Liu (13):
  ACPIHP: introduce interfaces to scan and walk ACPI devices attached
    to a slot
  ACPIHP: use klist to manage ACPI devices attached to a slot
  ACPIHP: add callbacks into acpi_device_ops to support new hotplug
    framework
  ACPIHP: provide interfaces to manage driver data associated with
    hotplug slots
  ACPIHP: implement utility interfaces to support system device hotplug
  ACPIHP: implement ACPI system device hotplug driver skeleton
  ACPIHP: analyse dependencies among ACPI hotplug slots
  ACPIHP: provide interface to cancel inprogress hotplug operations
  ACPIHP: configure/unconfigure system devices attached to a hotplug
    slot
  ACPIHP: implement the core state machine to manage hotplug slots
  ACPIHP: block ACPI device driver from unloading when doing hotplug
  ACPIHP: implement sysfs interfaces for system device hotplug
  ACPIHP: handle ACPI device hotplug events

 drivers/acpi/Kconfig                 |   15 +
 drivers/acpi/hotplug/Makefile        |   11 +-
 drivers/acpi/hotplug/acpihp.h        |    1 +
 drivers/acpi/hotplug/acpihp_drv.h    |  100 ++++++
 drivers/acpi/hotplug/cancel.c        |  174 +++++++++
 drivers/acpi/hotplug/configure.c     |  355 +++++++++++++++++++
 drivers/acpi/hotplug/core.c          |  281 +++++++++++++++
 drivers/acpi/hotplug/dependency.c    |  245 +++++++++++++
 drivers/acpi/hotplug/device.c        |  208 +++++++++++
 drivers/acpi/hotplug/drv_main.c      |  343 ++++++++++++++++++
 drivers/acpi/hotplug/event.c         |  163 +++++++++
 drivers/acpi/hotplug/state_machine.c |  639 ++++++++++++++++++++++++++++++++++
 drivers/acpi/hotplug/sysfs.c         |  181 ++++++++++
 drivers/acpi/internal.h              |    3 +
 drivers/acpi/scan.c                  |   12 +-
 include/acpi/acpi_bus.h              |    5 +
 include/acpi/acpi_hotplug.h          |  121 +++++++
 17 files changed, 2854 insertions(+), 3 deletions(-)
 create mode 100644 drivers/acpi/hotplug/acpihp_drv.h
 create mode 100644 drivers/acpi/hotplug/cancel.c
 create mode 100644 drivers/acpi/hotplug/configure.c
 create mode 100644 drivers/acpi/hotplug/dependency.c
 create mode 100644 drivers/acpi/hotplug/device.c
 create mode 100644 drivers/acpi/hotplug/drv_main.c
 create mode 100644 drivers/acpi/hotplug/event.c
 create mode 100644 drivers/acpi/hotplug/state_machine.c
 create mode 100644 drivers/acpi/hotplug/sysfs.c

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
