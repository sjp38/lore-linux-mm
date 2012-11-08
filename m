Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 85BEA6B002B
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 13:29:39 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jm1so1587948bkc.14
        for <linux-mm@kvack.org>; Thu, 08 Nov 2012 10:29:37 -0800 (PST)
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: [RFC PATCH 0/3] acpi: Introduce prepare_remove device operation
Date: Thu,  8 Nov 2012 19:29:28 +0100
Message-Id: <1352399371-8015-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com
Cc: rjw@sisk.pl, wency@cn.fujitsu.com, lenb@kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>

As discussed in
https://patchwork.kernel.org/patch/1581581/
the driver core remove function needs to always succeed. This means we need
to know that the device can be successfully removed before acpi_bus_trim / 
acpi_bus_hot_remove_device are called. This can cause panics when OSPM-initiated
eject (echo 1 > /sys/bus/acpi/devices/PNP/eject) of memory devices fails, since
the ACPI core goes ahead and ejects the device regardless of whether the memory
is still in use or not.

For this reason a new acpi_device operation called prepare_remove is introduced.
This operation should be registered for acpi devices whose removal (from kernel
perspective) can fail.  Memory devices fall in this category.

acpi_bus_hot_remove_device is changed to handle removal in 2 steps:
- preparation for removal i.e. perform part of removal that can fail outside of
  ACPI core. Should succeed for device and all its children.
- if above step was successfull, proceed to actual ACPI removal

acpi_bus_trim is changed accordingly to handle preparation for removal and
actual removal.

With this patchset, only acpi memory devices use the new prepare_remove
device operation. The actual memory removal (VM-related offline and other memory
cleanups) is moved to prepare_remove. The old remove operation just cleans up
the acpi structures. Directly ejecting PNP0C80 memory devices works safely. I
haven't tested yet with an ACPI container which contains memory devices.

Other ACPI devices (e.g. CPU) do not register prepare_remove callbacks, and
their OSPM-side eject should not be affected.

I am not happy with the name prepare_remove. Comments welcome. Let me know if I
should work more in this direction (I think Yasuaki might also look into this
and might have a simpler idea)

Patches are on top of Rafael's linux-pm/linux-next

Vasilis Liaskovitis (3):
  acpi: Introduce prepare_remove operation in acpi_device_ops
  acpi: Make acpi_bus_trim handle device removal preparation
  acpi_memhotplug: Add prepare_remove operation

 drivers/acpi/acpi_memhotplug.c     |   24 +++++++++++++++++++++---
 drivers/acpi/dock.c                |    2 +-
 drivers/acpi/scan.c                |   32 +++++++++++++++++++++++++++++---
 drivers/pci/hotplug/acpiphp_glue.c |    4 ++--
 drivers/pci/hotplug/sgi_hotplug.c  |    2 +-
 include/acpi/acpi_bus.h            |    4 +++-
 6 files changed, 57 insertions(+), 11 deletions(-)

-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
