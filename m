Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 968966B006E
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 05:59:00 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v4 4/7] acpi_memhotplug.c: free memory device if acpi_memory_enable_device() failed
Date: Thu, 8 Nov 2012 19:04:50 +0800
Message-Id: <1352372693-32411-5-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1352372693-32411-1-git-send-email-wency@cn.fujitsu.com>
References: <1352372693-32411-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Toshi Kani <toshi.kani@hp.com>, Wen Congyang <wency@cn.fujitsu.com>, Jiang Liu <liuj97@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>

If acpi_memory_enable_device() fails, acpi_memory_enable_device() will
return a non-zero value, which means we fail to bind the memory device to
this driver.  So we should free memory device before
acpi_memory_device_add() returns.

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
 drivers/acpi/acpi_memhotplug.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 5e5ac80..8914399 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -506,9 +506,11 @@ static int acpi_memory_device_add(struct acpi_device *device)
 	if (!acpi_memory_check_device(mem_device)) {
 		/* call add_memory func */
 		result = acpi_memory_enable_device(mem_device);
-		if (result)
+		if (result) {
 			printk(KERN_ERR PREFIX
 				"Error in acpi_memory_enable_device\n");
+			acpi_memory_device_free(mem_device);
+		}
 	}
 	return result;
 }
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
