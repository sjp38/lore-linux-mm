Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 6AD1E6B0044
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 05:58:57 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v4 0/7] acpi,memory-hotplug : implement framework for hot removing memory
Date: Thu, 8 Nov 2012 19:04:46 +0800
Message-Id: <1352372693-32411-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Toshi Kani <toshi.kani@hp.com>, Wen Congyang <wency@cn.fujitsu.com>

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
https://lkml.org/lkml/2012/10/26/175

Note: patch1-2 are in pm tree now. And there is a bug in patch1, so I resend
them. The commit in pm tree is:
patch1: 85fcb3758c10e063a2a30dfad75017097999deed
patch2: d0fbb400b6f3a6191bdc5024f8733b2e2b86338f

Changes from v3 to v4:
1. patch1: unlock list_lock when removing memory fails.
2. patch2: just rebase them
3. patch3-7: these patches are in -mm tree, and they conflict with this
   patchset, so Adrew Morton drop them from -mm tree. I rebase and merge
   them into this patchset.

Wen Congyang (6):
  acpi,memory-hotplug: introduce a mutex lock to protect the list in
    acpi_memory_device
  acpi_memhotplug.c: fix memory leak when memory device is unbound from
    the module acpi_memhotplug
  acpi_memhotplug.c: free memory device if acpi_memory_enable_device()
    failed
  acpi_memhotplug.c: don't allow to eject the memory device if it is
    being used
  acpi_memhotplug.c: bind the memory device when the driver is being
    loaded
  acpi_memhotplug.c: auto bind the memory device which is hotplugged
    before the driver is loaded

Yasuaki Ishimatsu (1):
  acpi,memory-hotplug : add memory offline code to
    acpi_memory_device_remove()

 drivers/acpi/acpi_memhotplug.c | 168 ++++++++++++++++++++++++++++++++---------
 1 file changed, 133 insertions(+), 35 deletions(-)

-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
