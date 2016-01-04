Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 778936B0007
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 11:17:45 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id q21so158753826iod.0
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 08:17:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id tg1si62035241igb.83.2016.01.04.08.17.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 08:17:45 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH v2 2/2] memory-hotplug: keep the request_resource() error code
Date: Mon,  4 Jan 2016 17:17:31 +0100
Message-Id: <1451924251-4189-3-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1451924251-4189-1-git-send-email-vkuznets@redhat.com>
References: <1451924251-4189-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Dan Williams <dan.j.williams@intel.com>, David Vrabel <david.vrabel@citrix.com>, Igor Mammedov <imammedo@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>

Don't overwrite the request_resource() return value with -EEXIST in
register_memory_resource(), just propagate the return value. As we return
-EBUSY instead of -EEXIST when the desired resource is already occupied
now we need to adapt acpi_memory_enable_device(). -EBUSY is currently the
only possible error returned by request_resource() so this is just a
cleanup, no functional changes intended.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Igor Mammedov <imammedo@redhat.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/acpi/acpi_memhotplug.c | 4 ++--
 mm/memory_hotplug.c            | 6 ++++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 6b0d3ef..e367e4b 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -232,10 +232,10 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 
 		/*
 		 * If the memory block has been used by the kernel, add_memory()
-		 * returns -EEXIST. If add_memory() returns the other error, it
+		 * returns -EBUSY. If add_memory() returns the other error, it
 		 * means that this memory block is not used by the kernel.
 		 */
-		if (result && result != -EEXIST)
+		if (result && result != -EBUSY)
 			continue;
 
 		result = acpi_bind_memory_blocks(info, mem_device->device);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 92f9595..07eab2c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -130,6 +130,7 @@ void mem_hotplug_done(void)
 static struct resource *register_memory_resource(u64 start, u64 size)
 {
 	struct resource *res;
+	int ret;
 	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
 	if (!res)
 		return ERR_PTR(-ENOMEM);
@@ -138,10 +139,11 @@ static struct resource *register_memory_resource(u64 start, u64 size)
 	res->start = start;
 	res->end = start + size - 1;
 	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
-	if (request_resource(&iomem_resource, res) < 0) {
+	ret = request_resource(&iomem_resource, res);
+	if (ret < 0) {
 		pr_debug("System RAM resource %pR cannot be added\n", res);
 		kfree(res);
-		return ERR_PTR(-EEXIST);
+		return ERR_PTR(ret);
 	}
 	return res;
 }
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
