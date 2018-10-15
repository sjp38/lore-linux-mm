Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EBB46B0006
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 11:30:56 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id c16-v6so15959968wrr.8
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 08:30:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g4-v6sor6191617wru.17.2018.10.15.08.30.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 08:30:54 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH 1/5] mm/memory_hotplug: Add nid parameter to arch_remove_memory
Date: Mon, 15 Oct 2018 17:30:30 +0200
Message-Id: <20181015153034.32203-2-osalvador@techadventures.net>
In-Reply-To: <20181015153034.32203-1-osalvador@techadventures.net>
References: <20181015153034.32203-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, dave.jiang@intel.com, linux-mm@kvack.org, alexander.h.duyck@linux.intel.com, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This patch is only a preparation for the following-up patches.
The idea of passing the nid is that will allow us to get rid
of the zone parameter in the patches that follow

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: David Hildenbrand <david@redhat.com>
---
 arch/ia64/mm/init.c            | 2 +-
 arch/powerpc/mm/mem.c          | 3 ++-
 arch/s390/mm/init.c            | 2 +-
 arch/sh/mm/init.c              | 2 +-
 arch/x86/mm/init_32.c          | 2 +-
 arch/x86/mm/init_64.c          | 3 ++-
 include/linux/memory_hotplug.h | 2 +-
 kernel/memremap.c              | 4 +++-
 mm/hmm.c                       | 4 +++-
 mm/memory_hotplug.c            | 2 +-
 10 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index d5e12ff1d73c..904fe55e10fc 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -661,7 +661,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
+int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 5551f5870dcc..6db8f527babb 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -139,7 +139,8 @@ int __meminit arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int __meminit arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
+int __meminit arch_remove_memory(int nid, u64 start, u64 size,
+					struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 76d0708438e9..b7503f8b7725 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -242,7 +242,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
+int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	/*
 	 * There is no hardware or firmware interface which could trigger a
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index c8c13c777162..a8e5c0e00fca 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -443,7 +443,7 @@ EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
 #endif
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
+int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 49ecf5ecf6d3..85c94f9a87f8 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -860,7 +860,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
+int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 5fab264948c2..449958da97a4 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1147,7 +1147,8 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 	remove_pagetable(start, end, true, NULL);
 }
 
-int __ref arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
+int __ref arch_remove_memory(int nid, u64 start, u64 size,
+				struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 84e9ae205930..786cdfc9a974 100644
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
index 9eced2cc9f94..c95df6ed2d4a 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -87,6 +87,7 @@ static void devm_memremap_pages_release(void *data)
 	struct resource *res = &pgmap->res;
 	resource_size_t align_start, align_size;
 	unsigned long pfn;
+	int nid;
 
 	for_each_device_pfn(pfn, pgmap)
 		put_page(pfn_to_page(pfn));
@@ -100,9 +101,10 @@ static void devm_memremap_pages_release(void *data)
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
index 774d684fa2b4..42d79bcc8aab 100644
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
index dbbb94547ad0..33d448314b3f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1875,7 +1875,7 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 	memblock_free(start, size);
 	memblock_remove(start, size);
 
-	arch_remove_memory(start, size, NULL);
+	arch_remove_memory(nid, start, size, NULL);
 
 	try_offline_node(nid);
 
-- 
2.13.6
