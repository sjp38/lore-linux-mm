Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id B5BEA6B004D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 12:50:47 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so4656089bkc.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2012 09:50:46 -0800 (PST)
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: [RFC PATCH v3 0/3] acpi: Introduce prepare_remove device operation
Date: Fri, 23 Nov 2012 18:50:34 +0100
Message-Id: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com
Cc: rjw@sisk.pl, lenb@kernel.org, toshi.kani@hp.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>

As discussed in https://patchwork.kernel.org/patch/1581581/
the driver core remove function needs to always succeed. This means we need
to know that the device can be successfully removed before acpi_bus_trim / 
acpi_bus_hot_remove_device are called. This can cause panics when OSPM-initiated
or SCI-initiated eject of memory devices fail e.g with:
echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject

since the ACPI core goes ahead and ejects the device regardless of whether the
the memory is still in use or not.

For this reason a new acpi_device operation called prepare_remove is introduced.
This operation should be registered for acpi devices whose removal (from kernel
perspective) can fail.  Memory devices fall in this category.

acpi_bus_remove() is changed to handle removal in 2 steps:
- preparation for removal i.e. perform part of removal that can fail. Should
  succeed for device and all its children.
- if above step was successfull, proceed to actual device removal

With this patchset, only acpi memory devices use the new prepare_remove
device operation. The actual memory removal (VM-related offline and other memory
cleanups) is moved to prepare_remove. The old remove operation just cleans up
the acpi structures. Directly ejecting PNP0C80 memory devices works safely. I
haven't tested yet with an ACPI container which contains memory devices.

Note that unbinding the acpi driver from a memory device with:
echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/unbind

will no longer try to remove the memory. This is in compliance with normal
unbind driver core semantics, see the discussion in v2 of this patchset:
https://lkml.org/lkml/2012/11/16/649

After a successful unbind of the driver:
- OSPM ejects of the memory device cannot proceed, as acpi_eject_store will
return -ENODEV on missing driver.
- SCI ejects of the memory device also cannot proceed, as they will also get
a "driver data is NULL" error.
So the memory can continue to be used safely after unbind.

Patchset based on Rafael's linux-pm/linux-next (commit 78c38651).
Comments welcome.

v2->v3:
- remove driver core changes. Only acpi core changes needed. Unbind semantics
follow driver core rules. Unbind does not remove memory.
- new patch to set enable bit in order to proceed with ejects on driver
re-binding scenario.

v1->v2:
- new patch to introduce bus_type prepare_remove callback. Needed to prepare
removal on driver unbinding from device-driver core.
- v1 patches 1 and 2 simplified and merged in one. acpi_bus_trim does not require
argument changes.

Vasilis Liaskovitis (3):
  acpi: Introduce prepare_remove operation in acpi_device_ops
  acpi_memhotplug: Add prepare_remove operation
  acpi_memhotplug: Allow eject to proceed on rebind scenario

 drivers/acpi/acpi_memhotplug.c |   21 +++++++++++++++++----
 drivers/acpi/scan.c            |    9 ++++++++-
 include/acpi/acpi_bus.h        |    2 ++
 3 files changed, 27 insertions(+), 5 deletions(-)

-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
