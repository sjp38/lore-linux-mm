Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 780E76B0078
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:50:54 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH v2 05/12] mm: Add memory hotplug handlers
Date: Thu, 10 Jan 2013 16:40:23 -0700
Message-Id: <1357861230-29549-6-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Toshi Kani <toshi.kani@hp.com>

Added memory hotplug handlers.  mm_add_execute() onlines requested
memory ranges for hot-add & online operations, and mm_del_execute()
offlines them for hot-delete & offline operations.  They are also
used for rollback as well.

mm_del_validate() fails a hot-delete request if a requested memory
range is non-movable when del_movable_only is set.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 mm/memory_hotplug.c |  101 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 101 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d04ed87..ed3d829 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -29,6 +29,8 @@
 #include <linux/suspend.h>
 #include <linux/mm_inline.h>
 #include <linux/firmware-map.h>
+#include <linux/module.h>
+#include <linux/sys_hotplug.h>
 
 #include <asm/tlbflush.h>
 
@@ -45,6 +47,13 @@ static void generic_online_page(struct page *page);
 
 static online_page_callback_t online_page_callback = generic_online_page;
 
+static int mm_add_execute(struct shp_request *req, int rollback);
+static int mm_del_execute(struct shp_request *req, int rollback);
+
+static int del_movable_only = 0;
+module_param(del_movable_only, int, 0644);
+MODULE_PARM_DESC(del_movable_only, "Restrict hot-remove to movable memory only");
+
 DEFINE_MUTEX(mem_hotplug_mutex);
 
 void lock_memory_hotplug(void)
@@ -1431,3 +1440,95 @@ int remove_memory(u64 start, u64 size)
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 EXPORT_SYMBOL_GPL(remove_memory);
+
+static int mm_add_execute(struct shp_request *req, int rollback)
+{
+	struct shp_device *shp_dev;
+	struct shp_memory *shp_mem;
+	int ret;
+
+	if (rollback)
+		return mm_del_execute(req, 0);
+
+	list_for_each_entry(shp_dev, &req->dev_list, list) {
+		if (shp_dev->class != SHP_CLS_MEMORY)
+			continue;
+
+		shp_mem = &shp_dev->info.mem;
+
+		ret = add_memory(shp_mem->node,
+				shp_mem->start_addr, shp_mem->length);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int mm_del_validate(struct shp_request *req, int rollback)
+{
+	struct shp_device *shp_dev;
+	struct shp_memory *shp_mem;
+	unsigned long start_pfn, nr_pages;
+
+	if (rollback || !del_movable_only)
+		return 0;
+
+	list_for_each_entry(shp_dev, &req->dev_list, list) {
+		if (shp_dev->class != SHP_CLS_MEMORY)
+			continue;
+
+		shp_mem = &shp_dev->info.mem;
+		start_pfn = shp_mem->start_addr >> PAGE_SHIFT;
+		nr_pages = PAGE_ALIGN(shp_mem->length) >> PAGE_SHIFT;
+
+		/*
+		 * Check if this memory range is removable.  This check is
+		 * enabled when del_movable_only is set.
+		 */
+		if (is_mem_section_removable(start_pfn, nr_pages)) {
+			pr_info("Memory [%#010llx-%#010llx] not removable\n",
+				shp_mem->start_addr,
+				shp_mem->start_addr + shp_mem->length-1);
+			return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
+static int mm_del_execute(struct shp_request *req, int rollback)
+{
+	struct shp_device *shp_dev;
+	struct shp_memory *shp_mem;
+	int ret;
+
+	if (rollback)
+		return mm_add_execute(req, 0);
+
+	list_for_each_entry(shp_dev, &req->dev_list, list) {
+		if (shp_dev->class != SHP_CLS_MEMORY)
+			continue;
+
+		shp_mem = &shp_dev->info.mem;
+
+		ret = remove_memory(shp_mem->start_addr, shp_mem->length);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int __init mm_shp_init(void)
+{
+	shp_register_handler(SHP_ADD_EXECUTE, mm_add_execute,
+				SHP_MEM_ADD_EXECUTE_ORDER);
+	shp_register_handler(SHP_DEL_VALIDATE, mm_del_validate,
+				SHP_MEM_DEL_VALIDATE_ORDER);
+	shp_register_handler(SHP_DEL_EXECUTE, mm_del_execute,
+				SHP_MEM_DEL_EXECUTE_ORDER);
+
+	return 0;
+}
+module_init(mm_shp_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
