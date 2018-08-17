Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE18D6B08EE
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 11:41:39 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s25-v6so1341403wmh.1
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 08:41:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 66-v6sor967157wms.91.2018.08.17.08.41.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Aug 2018 08:41:36 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [RFC v2 1/2] mm/memory_hotplug: Add nid parameter to arch_remove_memory
Date: Fri, 17 Aug 2018 17:41:26 +0200
Message-Id: <20180817154127.28602-2-osalvador@techadventures.net>
In-Reply-To: <20180817154127.28602-1-osalvador@techadventures.net>
References: <20180817154127.28602-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, david@redhat.com, jonathan.cameron@huawei.com, Pavel.Tatashin@microsoft.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This patch is only a preparation for the following-up patches.
The idea of passing the nid is that will allow us to get rid
of the zone parameter in the patches that follow.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 arch/ia64/mm/init.c            | 2 +-
 arch/powerpc/mm/mem.c          | 2 +-
 arch/s390/mm/init.c            | 2 +-
 arch/sh/mm/init.c              | 2 +-
 arch/x86/mm/init_32.c          | 2 +-
 arch/x86/mm/init_64.c          | 2 +-
 include/linux/memory_hotplug.h | 2 +-
 kernel/memremap.c              | 4 +++-
 mm/hmm.c                       | 4 +++-
 mm/memory_hotplug.c            | 2 +-
 10 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 3b85c3ecac38..b54d0ee74b53 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -662,7 +662,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
+int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 5c8530d0c611..9e17d57a9948 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -139,7 +139,7 @@ int __meminit arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int __meminit arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
+int __meminit arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 3fa3e5323612..bc49b560625e 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -240,7 +240,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
+int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	/*
 	 * There is no hardware or firmware interface which could trigger a
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 7713c084d040..5c91bb6abc35 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -444,7 +444,7 @@ EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
 #endif
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
+int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 979e0a02cbe1..9fa503f2f56c 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -861,7 +861,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
+int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index dd519f372169..f90fa077b0c4 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1148,7 +1148,7 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 	remove_pagetable(start, end, true, NULL);
 }
 
-int __ref arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
+int __ref arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 34a28227068d..c68b03fd87bd 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -107,7 +107,7 @@ static inline bool movable_node_is_enabled(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-extern int arch_remove_memory(u64 start, u64 size,
+extern int arch_remove_memory(int nid, u64 start, u64 size,
 		struct vmem_altmap *altmap);
 extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages, struct vmem_altmap *altmap);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 5b8600d39931..7a832b844f24 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -121,6 +121,7 @@ static void devm_memremap_pages_release(void *data)
 	struct resource *res = &pgmap->res;
 	resource_size_t align_start, align_size;
 	unsigned long pfn;
+	int nid;
 
 	for_each_device_pfn(pfn, pgmap)
 		put_page(pfn_to_page(pfn));
@@ -134,9 +135,10 @@ static void devm_memremap_pages_release(void *data)
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
 		- align_start;
+	nid = dev_to_node(dev);
 
 	mem_hotplug_begin();
-	arch_remove_memory(align_start, align_size, pgmap->altmap_valid ?
+	arch_remove_memory(nid, align_start, align_size, pgmap->altmap_valid ?
 			&pgmap->altmap : NULL);
 	kasan_remove_zero_shadow(__va(align_start), align_size);
 	mem_hotplug_done();
diff --git a/mm/hmm.c b/mm/hmm.c
index c968e49f7a0c..21787e480b4a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -995,6 +995,7 @@ static void hmm_devmem_release(struct device *dev, void *data)
 	unsigned long start_pfn, npages;
 	struct zone *zone;
 	struct page *page;
+	int nid;
 
 	if (percpu_ref_tryget_live(&devmem->ref)) {
 		dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
@@ -1007,12 +1008,13 @@ static void hmm_devmem_release(struct device *dev, void *data)
 
 	page = pfn_to_page(start_pfn);
 	zone = page_zone(page);
+	nid = zone->zone_pgdat->node_id;
 
 	mem_hotplug_begin();
 	if (resource->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY)
 		__remove_pages(zone, start_pfn, npages, NULL);
 	else
-		arch_remove_memory(start_pfn << PAGE_SHIFT,
+		arch_remove_memory(nid, start_pfn << PAGE_SHIFT,
 				   npages << PAGE_SHIFT, NULL);
 	mem_hotplug_done();
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9eea6e809a4e..9bd629944c91 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1895,7 +1895,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 	memblock_free(start, size);
 	memblock_remove(start, size);
 
-	arch_remove_memory(start, size, NULL);
+	arch_remove_memory(nid, start, size, NULL);
 
 	try_offline_node(nid);
 
-- 
2.13.6
