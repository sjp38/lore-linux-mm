Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id B12EC6B0044
	for <linux-mm@kvack.org>; Sat,  3 Nov 2012 12:08:01 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3365062pad.14
        for <linux-mm@kvack.org>; Sat, 03 Nov 2012 09:08:01 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part1 0/4] introduce a framework for ACPI based system device hotplug
Date: Sun,  4 Nov 2012 00:07:41 +0800
Message-Id: <1351958865-24394-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

Modern high-end servers may support advanced RAS features, such as
system device dynamic reconfiguration. On x86 and IA64 platforms,
system device means processor(CPU), memory device, PCI host bridge
and even computer node.

The ACPI specifications have provided standard interfaces between
firmware and OS to support device dynamic reconfiguraiton at runtime.
This patch series introduces a new framework for system device
dynamic reconfiguration based on ACPI specification, which will
replace current existing system device hotplug logic embedded in
ACPI processor/memory/container device drivers.

The new ACPI based hotplug framework is modelled after the PCI hotplug
architecture and target to achieve following goals:
1) Optimize device configuration order to achieve best performance for
   hot-added system devices. For best perforamnce, system device should
   be configured in order of memory -> CPU -> IOAPIC/IOMMU -> PCI HB.
2) Resolve dependencies among hotplug slots. You need first to remove
   the memory device before removing a physical processor if a
   hotpluggable memory device is connected to a hotpluggable physical
   processor.
3) Provide interface to cancel ongoing hotplug operations. It may take
   a very long time to remove a memory device, so provide interface to
   cancel the inprogress hotplug operations.
4) Support new advanced RAS features, such as socket/memory migration.
5) Provide better user interfaces to access the hotplug functionalities.
6) Provide a mechanism to detect hotplug slots by checking existence
   of ACPI _EJ0 method or by other hardware platform specific methods.
7) Unify the way to enumerate ACPI based hotplug slots. All hotplug
   slots will be enumerated by the enumeration driver (acpihp_slot),
   instead of by individual ACPI device drivers.
8) Unify the way to handle ACPI hotplug events. All ACPI hotplug events
   for system devices will be handled by a generic ACPI hotplug driver
   (acpihp_drv) instead of by individual ACPI device drivers.
9) Provide better error handling and error recovery.
10) Trigger hotplug events/operations by software. This feature is useful
   for hardware fault management and/or power saving.

The new framework is composed up of three major components:
1) A system device hotplug slot enumerator driver, which enumerates
   hotplug slots in the system and provides platform specific methods
   to control those slots.
2) A system device hotplug driver, which is a platform independent
   driver to manage all hotplug slots created by the slot enumerator.
   The hotplug driver implements a state machine for hotplug slots and
   provides user interfaces to manage hotplug slots.
3) Several ACPI device drivers to configure/unconfigure system devices
   at runtime.

And the whole patchset will be split into 7 parts:
1) the hotplug slot enumeration driver (acpihp_slot)
2) the system device hotplug driver (acpihp_drv)
3) enhance ACPI container driver to support new framework
4) enhance ACPI processor driver to support new framework
5) enhance ACPI memory driver to support new framework
6) enhance ACPI host bridge driver to support new framework
7) enhancments and cleanups to the ACPI core

This is the first part of hotplug slot enumeration driver (acpihp_slot).
And you may pull from:
https://github.com/jiangliu/linux.git acpihp_slot

On loading, it will scan ACPI hotplug slots for system device hotplug.
For example, Intel Emerald Ridge/Quantum S4R platform has
1) 4 hotpluggable physical processors
2) 8 hotpluggable memory boards (each processor has two memory boards)
3) 1 hotpluggable IOH and 1 non-hotpluggable legacy IOH

#modprobe acpihp_slot
#cd /sys/bus/acpi/slots
#ls -l
total 0
lrwxrwxrwx  CPU00 -> ../../../devices/LNXSYSTM:00/acpihp/CPU00
lrwxrwxrwx  CPU01 -> ../../../devices/LNXSYSTM:00/acpihp/CPU01
lrwxrwxrwx  CPU02 -> ../../../devices/LNXSYSTM:00/acpihp/CPU02
lrwxrwxrwx  CPU03 -> ../../../devices/LNXSYSTM:00/acpihp/CPU03
lrwxrwxrwx  IOX01 -> ../../../devices/LNXSYSTM:00/acpihp/IOX01
lrwxrwxrwx  MEM00 -> ../../../devices/LNXSYSTM:00/acpihp/CPU00/MEM00
lrwxrwxrwx  MEM01 -> ../../../devices/LNXSYSTM:00/acpihp/CPU00/MEM01
lrwxrwxrwx  MEM02 -> ../../../devices/LNXSYSTM:00/acpihp/CPU01/MEM02
lrwxrwxrwx  MEM03 -> ../../../devices/LNXSYSTM:00/acpihp/CPU01/MEM03
lrwxrwxrwx  MEM04 -> ../../../devices/LNXSYSTM:00/acpihp/CPU02/MEM04
lrwxrwxrwx  MEM05 -> ../../../devices/LNXSYSTM:00/acpihp/CPU02/MEM05
lrwxrwxrwx  MEM06 -> ../../../devices/LNXSYSTM:00/acpihp/CPU03/MEM06
lrwxrwxrwx  MEM07 -> ../../../devices/LNXSYSTM:00/acpihp/CPU03/MEM07

For each hotplug slots, it provides following sysfs interfaces:
# cd CPU00/
# ls			; MEM00, MEM01 are child hotplug slots
MEM00  MEM01  capabilities  device  object  power  state  status  subsystem  uevent
# cat capabilities	; show slot RAS capabilities
online,offline,poweroff,hotplug
# cat object		; show ACPI object corresponding to this slot
\_SB_.SCK0
# cat state		; show slot state machine state
configured
# cat status		; show devie health status
ok

Jiang Liu (4):
  ACPIHP: introduce a framework for ACPI based system device hotplug
  ACPIHP: introduce acpihp_slot driver to enumerate hotplug slots
  ACPIHP: detect ACPI hotplug slots by checking ACPI _EJ0 method
  ACPIHP: implement a fake ACPI system device hotplug slot enumerator

 drivers/acpi/Kconfig             |   42 +++
 drivers/acpi/Makefile            |    2 +
 drivers/acpi/hotplug/Makefile    |   11 +
 drivers/acpi/hotplug/acpihp.h    |   36 +++
 drivers/acpi/hotplug/core.c      |  543 ++++++++++++++++++++++++++++++++++++++
 drivers/acpi/hotplug/slot.c      |  421 +++++++++++++++++++++++++++++
 drivers/acpi/hotplug/slot_ej0.c  |  143 ++++++++++
 drivers/acpi/hotplug/slot_fake.c |  180 +++++++++++++
 include/acpi/acpi_hotplug.h      |  208 +++++++++++++++
 9 files changed, 1586 insertions(+)
 create mode 100644 drivers/acpi/hotplug/Makefile
 create mode 100644 drivers/acpi/hotplug/acpihp.h
 create mode 100644 drivers/acpi/hotplug/core.c
 create mode 100644 drivers/acpi/hotplug/slot.c
 create mode 100644 drivers/acpi/hotplug/slot_ej0.c
 create mode 100644 drivers/acpi/hotplug/slot_fake.c
 create mode 100644 include/acpi/acpi_hotplug.h

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
