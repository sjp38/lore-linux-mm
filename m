Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 681606B006C
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 05:59:02 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v4 6/7] acpi_memhotplug.c: bind the memory device when the driver is being loaded
Date: Thu, 8 Nov 2012 19:04:52 +0800
Message-Id: <1352372693-32411-7-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1352372693-32411-1-git-send-email-wency@cn.fujitsu.com>
References: <1352372693-32411-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Toshi Kani <toshi.kani@hp.com>, Wen Congyang <wency@cn.fujitsu.com>, Jiang Liu <liuj97@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>

We had introduced acpi_hotmem_initialized to avoid strange add_memory fail
message.  But the memory device may not be used by the kernel, and the
device should be bound when the driver is being loaded.  Remove
acpi_hotmem_initialized to allow that the device can be bound when the
driver is being loaded.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
CC: Rafael J. Wysocki <rjw@sisk.pl>
CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 drivers/acpi/acpi_memhotplug.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 1fb1342..8a8716f 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -88,8 +88,6 @@ struct acpi_memory_device {
 	struct list_head res_list;	/* protected by list_lock */
 };
 
-static int acpi_hotmem_initialized;
-
 static acpi_status
 acpi_memory_get_resource(struct acpi_resource *resource, void *context)
 {
@@ -520,15 +518,6 @@ static int acpi_memory_device_add(struct acpi_device *device)
 
 	printk(KERN_DEBUG "%s \n", acpi_device_name(device));
 
-	/*
-	 * Early boot code has recognized memory area by EFI/E820.
-	 * If DSDT shows these memory devices on boot, hotplug is not necessary
-	 * for them. So, it just returns until completion of this driver's
-	 * start up.
-	 */
-	if (!acpi_hotmem_initialized)
-		return 0;
-
 	if (!acpi_memory_check_device(mem_device)) {
 		/* call add_memory func */
 		result = acpi_memory_enable_device(mem_device);
@@ -644,7 +633,6 @@ static int __init acpi_memory_device_init(void)
 		return -ENODEV;
 	}
 
-	acpi_hotmem_initialized = 1;
 	return 0;
 }
 
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
