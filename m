Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 329DB6B0062
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 13:29:43 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jm1so1587948bkc.14
        for <linux-mm@kvack.org>; Thu, 08 Nov 2012 10:29:42 -0800 (PST)
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: [RFC PATCH 3/3] acpi_memhotplug: Add prepare_remove operation
Date: Thu,  8 Nov 2012 19:29:31 +0100
Message-Id: <1352399371-8015-4-git-send-email-vasilis.liaskovitis@profitbricks.com>
In-Reply-To: <1352399371-8015-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
References: <1352399371-8015-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com
Cc: rjw@sisk.pl, wency@cn.fujitsu.com, lenb@kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>

Offlining and removal of memory is now done in the prepare_remove callback,
not in the remove callback.

Signed-off-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
---
 drivers/acpi/acpi_memhotplug.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 7fcc844..9b734a5 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -54,6 +54,7 @@ MODULE_LICENSE("GPL");
 
 static int acpi_memory_device_add(struct acpi_device *device);
 static int acpi_memory_device_remove(struct acpi_device *device, int type);
+static int acpi_memory_device_prepare_remove(struct acpi_device *device);
 
 static const struct acpi_device_id memory_device_ids[] = {
 	{ACPI_MEMORY_DEVICE_HID, 0},
@@ -68,6 +69,7 @@ static struct acpi_driver acpi_memory_device_driver = {
 	.ops = {
 		.add = acpi_memory_device_add,
 		.remove = acpi_memory_device_remove,
+		.prepare_remove = acpi_memory_device_prepare_remove,
 		},
 };
 
@@ -499,6 +501,20 @@ static int acpi_memory_device_add(struct acpi_device *device)
 static int acpi_memory_device_remove(struct acpi_device *device, int type)
 {
 	struct acpi_memory_device *mem_device = NULL;
+
+	if (!device || !acpi_driver_data(device))
+		return -EINVAL;
+
+	mem_device = acpi_driver_data(device);
+
+	kfree(mem_device);
+
+	return 0;
+}
+
+static int acpi_memory_device_prepare_remove(struct acpi_device *device)
+{
+	struct acpi_memory_device *mem_device = NULL;
 	int result;
 
 	if (!device || !acpi_driver_data(device))
@@ -506,12 +522,14 @@ static int acpi_memory_device_remove(struct acpi_device *device, int type)
 
 	mem_device = acpi_driver_data(device);
 
+	/*
+	 * offline and remove memory only when the memory device is
+	 * ejected.
+	 */
 	result = acpi_memory_remove_memory(mem_device);
 	if (result)
 		return result;
 
-	kfree(mem_device);
-
 	return 0;
 }
 
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
