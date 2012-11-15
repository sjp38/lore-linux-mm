Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 4D3726B00BC
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 05:22:59 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so705843bkc.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 02:22:57 -0800 (PST)
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: [RFC PATCH v2 0/3] acpi: Introduce prepare_remove device operation
Date: Thu, 15 Nov 2012 11:22:47 +0100
Message-Id: <1352974970-6643-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com
Cc: rjw@sisk.pl, lenb@kernel.org, toshi.kani@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>

As discussed in https://patchwork.kernel.org/patch/1581581/
the driver core remove function needs to always succeed. This means we need
to know that the device can be successfully removed before acpi_bus_trim / 
acpi_bus_hot_remove_device are called. This can cause panics when OSPM-initiated
eject or driver unbind of memory devices fails e.g with:

echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/unbind

since the ACPI core goes ahead and ejects the device regardless of whether the
the memory is still in use or not.

For this reason a new acpi_device operation called prepare_remove is introduced.
This operation should be registered for acpi devices whose removal (from kernel
perspective) can fail.  Memory devices fall in this category.
A similar operation is introduced in bus_type to safely handle driver unbind
from the device driver core.

acpi_bus_hot_remove_device and driver_unbind are changed to handle removal in 2
steps:
- preparation for removal i.e. perform part of removal that can fail. Should
  succeed for device and all its children.
- if above step was successfull, proceed to actual device removal

With this patchset, only acpi memory devices use the new prepare_remove
device operation. The actual memory removal (VM-related offline and other memory
cleanups) is moved to prepare_remove. The old remove operation just cleans up
the acpi structures. Directly ejecting PNP0C80 memory devices works safely. I
haven't tested yet with an ACPI container which contains memory devices.

v1->v2:
- new patch to introduce bus_type prepare_remove callback. Needed to prepare
removal on driver unbinding from device-driver core.
- v1 patches 1 and 2 simplified and merged in one. acpi_bus_trim does not require
argument changes.

Comments welcome.

Vasilis Liaskovitis (3):
  driver core: Introduce prepare_remove in bus_type
  acpi: Introduce prepare_remove operation in acpi_device_ops
  acpi_memhotplug: Add prepare_remove operation

 drivers/acpi/acpi_memhotplug.c |   22 ++++++++++++++++++++--
 drivers/acpi/scan.c            |   21 ++++++++++++++++++++-
 drivers/base/bus.c             |   36 ++++++++++++++++++++++++++++++++++++
 include/acpi/acpi_bus.h        |    2 ++
 include/linux/device.h         |    2 ++
 5 files changed, 80 insertions(+), 3 deletions(-)

-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
