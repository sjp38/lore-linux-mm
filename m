Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id AAD156B0070
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 01:53:41 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v5 3/7] acpi_memhotplug.c: fix memory leak when memory device is unbound from the module acpi_memhotplug
Date: Thu, 15 Nov 2012 14:59:33 +0800
Message-Id: <1352962777-24407-4-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com>
References: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Toshi Kani <toshi.kani@hp.com>, Wen Congyang <wency@cn.fujitsu.com>, Jiang Liu <liuj97@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>

We allocate memory to store acpi_memory_info, so we should free it before
freeing mem_device.

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
 drivers/acpi/acpi_memhotplug.c | 27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 6e12042..c5e7b6d 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -125,12 +125,20 @@ acpi_memory_get_resource(struct acpi_resource *resource, void *context)
 	return AE_OK;
 }
 
+static void
+acpi_memory_free_device_resources(struct acpi_memory_device *mem_device)
+{
+	struct acpi_memory_info *info, *n;
+
+	list_for_each_entry_safe(info, n, &mem_device->res_list, list)
+		kfree(info);
+	INIT_LIST_HEAD(&mem_device->res_list);
+}
+
 static int
 acpi_memory_get_device_resources(struct acpi_memory_device *mem_device)
 {
 	acpi_status status;
-	struct acpi_memory_info *info, *n;
-
 
 	if (!list_empty(&mem_device->res_list))
 		return 0;
@@ -138,9 +146,7 @@ acpi_memory_get_device_resources(struct acpi_memory_device *mem_device)
 	status = acpi_walk_resources(mem_device->device->handle, METHOD_NAME__CRS,
 				     acpi_memory_get_resource, mem_device);
 	if (ACPI_FAILURE(status)) {
-		list_for_each_entry_safe(info, n, &mem_device->res_list, list)
-			kfree(info);
-		INIT_LIST_HEAD(&mem_device->res_list);
+		acpi_memory_free_device_resources(mem_device);
 		return -EINVAL;
 	}
 
@@ -363,6 +369,15 @@ static void acpi_memory_device_notify(acpi_handle handle, u32 event, void *data)
 	return;
 }
 
+static void acpi_memory_device_free(struct acpi_memory_device *mem_device)
+{
+	if (!mem_device)
+		return;
+
+	acpi_memory_free_device_resources(mem_device);
+	kfree(mem_device);
+}
+
 static int acpi_memory_device_add(struct acpi_device *device)
 {
 	int result;
@@ -427,7 +442,7 @@ static int acpi_memory_device_remove(struct acpi_device *device, int type)
 	if (result)
 		return result;
 
-	kfree(mem_device);
+	acpi_memory_device_free(mem_device);
 
 	return 0;
 }
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
