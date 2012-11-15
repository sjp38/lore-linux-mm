Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 491A36B0075
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 01:53:45 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v5 7/7] acpi_memhotplug.c: auto bind the memory device which is hotplugged before the driver is loaded
Date: Thu, 15 Nov 2012 14:59:37 +0800
Message-Id: <1352962777-24407-8-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com>
References: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Toshi Kani <toshi.kani@hp.com>, Wen Congyang <wency@cn.fujitsu.com>, Jiang Liu <liuj97@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>

If the memory device is hotplugged before the driver is loaded, the user
cannot see this device under the directory /sys/bus/acpi/devices/, and the
user cannot bind it by hand after the driver is loaded.  This patch
introduces a new feature to bind such device when the driver is being
loaded.

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
 drivers/acpi/acpi_memhotplug.c | 37 ++++++++++++++++++++++++++++++++++++-
 1 file changed, 36 insertions(+), 1 deletion(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index e0f7425..9f1d107 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -52,6 +52,9 @@ MODULE_LICENSE("GPL");
 #define MEMORY_POWER_ON_STATE	1
 #define MEMORY_POWER_OFF_STATE	2
 
+static bool auto_probe;
+module_param(auto_probe, bool, S_IRUGO | S_IWUSR);
+
 static int acpi_memory_device_add(struct acpi_device *device);
 static int acpi_memory_device_remove(struct acpi_device *device, int type);
 
@@ -494,12 +497,44 @@ acpi_memory_register_notify_handler(acpi_handle handle,
 				    u32 level, void *ctxt, void **retv)
 {
 	acpi_status status;
-
+	struct acpi_memory_device *mem_device = NULL;
+	unsigned long long current_status;
 
 	status = is_memory_device(handle);
 	if (ACPI_FAILURE(status))
 		return AE_OK;	/* continue */
 
+	if (auto_probe) {
+		/* Get device present/absent information from the _STA */
+		status = acpi_evaluate_integer(handle, "_STA", NULL,
+					       &current_status);
+		if (ACPI_FAILURE(status))
+			goto install;
+
+		/*
+		 * Check for device status. Device should be
+		 * present/enabled/functioning.
+		 */
+		if (!(current_status &
+		      (ACPI_STA_DEVICE_PRESENT | ACPI_STA_DEVICE_ENABLED |
+		       ACPI_STA_DEVICE_FUNCTIONING)))
+			goto install;
+
+		if (acpi_memory_get_device(handle, &mem_device))
+			goto install;
+
+		/* We have bound this device while we register the driver */
+		if (mem_device->state == MEMORY_POWER_ON_STATE)
+			goto install;
+
+		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
+				  "\nauto probe memory device\n"));
+
+		if (acpi_memory_enable_device(mem_device))
+			pr_err(PREFIX "Cannot enable memory device\n");
+	}
+
+install:
 	status = acpi_install_notify_handler(handle, ACPI_SYSTEM_NOTIFY,
 					     acpi_memory_device_notify, NULL);
 	/* continue */
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
