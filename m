Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id E8B106B007B
	for <linux-mm@kvack.org>; Tue, 21 May 2013 17:34:06 -0400 (EDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH] mm: Change normal message to use pr_debug
Date: Tue, 21 May 2013 15:33:54 -0600
Message-Id: <1369172034-17267-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, Toshi Kani <toshi.kani@hp.com>

During early boot-up, iomem_resource is set up from the boot
descriptor table, such as EFI Memory Table and e820.  Later,
acpi_memory_device_add() calls add_memory() for each ACPI
memory device object as it enumerates ACPI namespace.  This
add_memory() call is expected to fail in register_memory_resource()
at boot since iomem_resource has been set up from EFI/e820.
As a result, add_memory() returns -EEXIST, which
acpi_memory_device_add() handles as the normal case.

This scheme works fine, but the following error message is
logged for every ACPI memory device object during boot-up.

  "System RAM resource %pR cannot be added\n"

This patch changes register_memory_resource() to use pr_debug()
for the message as it shows up under the normal case.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 mm/memory_hotplug.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 5ea1287..90ebc91 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -75,7 +75,7 @@ static struct resource *register_memory_resource(u64 start, u64 size)
 	res->end = start + size - 1;
 	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
 	if (request_resource(&iomem_resource, res) < 0) {
-		printk("System RAM resource %pR cannot be added\n", res);
+		pr_debug("System RAM resource %pR cannot be added\n", res);
 		kfree(res);
 		res = NULL;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
