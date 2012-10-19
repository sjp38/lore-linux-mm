Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id E74C26B005D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 05:58:25 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [PATCH v2 0/3] acpi,memory-hotplug : implement framework for hot removing memory
Date: Fri, 19 Oct 2012 18:03:57 +0800
Message-Id: <1350641040-19434-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org
Cc: liuj97@gmail.com, len.brown@intel.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, muneda.takahiro@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Wen Congyang <wency@cn.fujitsu.com>

The patch-set implements a framework for hot removing memory.

The memory device can be removed by 2 ways:
1. send eject request by SCI
2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject

In the 1st case, acpi_memory_disable_device() will be called.
In the 2nd case, acpi_memory_device_remove() will be called.
acpi_memory_device_remove() will also be called when we unbind the
memory device from the driver acpi_memhotplug or a driver initialization
fails.

acpi_memory_disable_device() has already implemented a code which
offlines memory and releases acpi_memory_info struct . But
acpi_memory_device_remove() has not implemented it yet.

So the patch prepares the framework for hot removing memory and
adds the framework into acpi_memory_device_remove().

The last version of this patchset is here:
https://lkml.org/lkml/2012/10/3/126

Changelos from v1 to v2:
  Patch1: use acpi_bus_trim() instead of acpi_bus_remove()
  Patch2: new patch, introduce a lock to protect the list
  Patch3: remove memory too when type is ACPI_BUS_REMOVAL_NORMAL
  Note: I don't send [Patch2-4 v1] in this series because they
  are no logical changes in these 3 patches.

Wen Congyang (2):
  acpi,memory-hotplug: call acpi_bus_trim() to remove memory device
  acpi,memory-hotplug: introduce a mutex lock to protect the list in
    acpi_memory_device

Yasuaki Ishimatsu (1):
  acpi,memory-hotplug : add memory offline code to
    acpi_memory_device_remove()

 drivers/acpi/acpi_memhotplug.c |   51 ++++++++++++++++++++++++++++++++--------
 1 files changed, 41 insertions(+), 10 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
