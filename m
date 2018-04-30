Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4591F6B000E
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 05:43:02 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d5-v6so6300597qtg.17
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 02:43:02 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g12-v6si6790789qtj.142.2018.04.30.02.43.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 02:43:01 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RCFv2 7/7] mm/memory_hotplug: allow online/offline memory by a kernel module
Date: Mon, 30 Apr 2018 11:42:36 +0200
Message-Id: <20180430094236.29056-8-david@redhat.com>
In-Reply-To: <20180430094236.29056-1-david@redhat.com>
References: <20180430094236.29056-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Thomas Gleixner <tglx@linutronix.de>

Kernel modules that want to control how/when memory is onlined/offlined
need a proper interface to these functions. Also, for adding memory
properly, memory_block_size_bytes is required.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c          |  1 +
 include/linux/memory_hotplug.h |  2 ++
 mm/memory_hotplug.c            | 27 +++++++++++++++++++++++++--
 3 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index c785e4c01b23..0a7c79cfaaf8 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -88,6 +88,7 @@ unsigned long __weak memory_block_size_bytes(void)
 {
 	return MIN_MEMORY_BLOCK_SIZE;
 }
+EXPORT_SYMBOL(memory_block_size_bytes);
 
 static unsigned long get_memory_block_size(void)
 {
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index ae53017b54df..0e3e48410415 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -97,6 +97,8 @@ extern void __online_page_increment_counters(struct page *page);
 extern void __online_page_free(struct page *page);
 
 extern int try_online_node(int nid);
+extern int online_memory_blocks(uint64_t start, uint64_t size);
+extern int offline_memory_blocks(uint64_t start, uint64_t size);
 
 extern bool memhp_auto_online;
 /* If movable_node boot option specified */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c47cc68341fc..849bf0543fb1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -89,12 +89,14 @@ void mem_hotplug_begin(void)
 	cpus_read_lock();
 	percpu_down_write(&mem_hotplug_lock);
 }
+EXPORT_SYMBOL(mem_hotplug_begin);
 
 void mem_hotplug_done(void)
 {
 	percpu_up_write(&mem_hotplug_lock);
 	cpus_read_unlock();
 }
+EXPORT_SYMBOL(mem_hotplug_done);
 
 /* add this memory to iomem resource */
 static struct resource *register_memory_resource(u64 start, u64 size)
@@ -980,6 +982,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	memory_notify(MEM_CANCEL_ONLINE, &arg);
 	return ret;
 }
+EXPORT_SYMBOL(online_pages);
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
 static void reset_node_present_pages(pg_data_t *pgdat)
@@ -1109,6 +1112,25 @@ static int online_memory_block(struct memory_block *mem, void *arg)
 	return device_online(&mem->dev);
 }
 
+static int offline_memory_block(struct memory_block *mem, void *arg)
+{
+	return device_offline(&mem->dev);
+}
+
+int online_memory_blocks(uint64_t start, uint64_t size)
+{
+	return walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1),
+				 NULL, online_memory_block);
+}
+EXPORT_SYMBOL(online_memory_blocks);
+
+int offline_memory_blocks(uint64_t start, uint64_t size)
+{
+	return walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1),
+				 NULL, offline_memory_block);
+}
+EXPORT_SYMBOL(offline_memory_blocks);
+
 static int mark_memory_block_driver_managed(struct memory_block *mem, void *arg)
 {
 	mem->driver_managed = true;
@@ -1197,8 +1219,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online,
 
 	/* online pages if requested */
 	if (online)
-		walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1),
-				  NULL, online_memory_block);
+		online_memory_blocks(start, size);
 	else if (driver_managed)
 		walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1),
 				  NULL, mark_memory_block_driver_managed);
@@ -1297,6 +1318,7 @@ bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 	/* All pageblocks in the memory block are likely to be hot-removable */
 	return true;
 }
+EXPORT_SYMBOL(is_mem_section_removable);
 
 /*
  * Confirm all pages in a range [start, end) belong to the same zone.
@@ -1759,6 +1781,7 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages,
 {
 	return __offline_pages(start_pfn, start_pfn + nr_pages, retry_forever);
 }
+EXPORT_SYMBOL(offline_pages);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /**
-- 
2.14.3
