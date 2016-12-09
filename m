Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAB466B0260
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 21:45:15 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 17so5593797pfy.2
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 18:45:15 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 18si31297225pgg.168.2016.12.08.18.45.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 18:45:14 -0800 (PST)
Subject: [PATCH v2 02/11] mm: introduce struct mem_section_usage to track
 partial population of a section
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 08 Dec 2016 18:41:05 -0800
Message-ID: <148125126509.13512.13486269099518435729.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148125125407.13512.1253904589564772668.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148125125407.13512.1253904589564772668.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: toshi.kani@hpe.com, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, Stephen Bates <stephen.bates@microsemi.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Logan Gunthorpe <logang@deltatee.com>, Vlastimil Babka <vbabka@suse.cz>

'struct mem_section_usage' combines the existing 'pageblock_flags' bitmap
with a new 'map_active' bitmap.  The new bitmap enables the memory
hot{plug,remove} implementation to act on incremental sub-divisions of
a section. The primary impetus for this functionality is to support
platforms that mix "System RAM" and "Persistent Memory" within a single
section.  We want to be able to hotplug "Persistent Memory" to extend a
partially populated section and share that section between ZONE_DEVICE and
ZONE_NORMAL/MOVABLE memory.

This introduces a pointer to the new 'map_active' bitmap through struct
mem_section, but otherwise should not change any behavior.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Stephen Bates <stephen.bates@microsemi.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |   21 +++++++++-
 mm/memory_hotplug.c    |    4 +-
 mm/page_alloc.c        |    2 -
 mm/sparse.c            |   98 ++++++++++++++++++++++++++----------------------
 4 files changed, 75 insertions(+), 50 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0f088f3a2fed..b13b490321a5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1068,6 +1068,19 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 #define SECTION_ALIGN_UP(pfn)	(((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
 #define SECTION_ALIGN_DOWN(pfn)	((pfn) & PAGE_SECTION_MASK)
 
+#define SECTION_ACTIVE_SIZE ((1UL << SECTION_SIZE_BITS) / BITS_PER_LONG)
+#define SECTION_ACTIVE_MASK (~(SECTION_ACTIVE_SIZE - 1))
+
+struct mem_section_usage {
+	/*
+	 * SECTION_ACTIVE_SIZE portions of the section that are populated in
+	 * the memmap
+	 */
+	unsigned long map_active;
+	/* See declaration of similar field in struct zone */
+	unsigned long pageblock_flags[0];
+};
+
 struct page;
 struct page_ext;
 struct mem_section {
@@ -1085,8 +1098,7 @@ struct mem_section {
 	 */
 	unsigned long section_mem_map;
 
-	/* See declaration of similar field in struct zone */
-	unsigned long *pageblock_flags;
+	struct mem_section_usage *usage;
 #ifdef CONFIG_PAGE_EXTENSION
 	/*
 	 * If SPARSEMEM, pgdat doesn't have page_ext pointer. We use
@@ -1117,6 +1129,11 @@ extern struct mem_section *mem_section[NR_SECTION_ROOTS];
 extern struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT];
 #endif
 
+static inline unsigned long *section_to_usemap(struct mem_section *ms)
+{
+	return ms->usage->pageblock_flags;
+}
+
 static inline struct mem_section *__nr_to_section(unsigned long nr)
 {
 	if (!mem_section[SECTION_NR_TO_ROOT(nr)])
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index cad4b9125695..c7b3b2308ac3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -227,7 +227,7 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
 	for (i = 0; i < mapsize; i++, page++)
 		get_page_bootmem(section_nr, page, SECTION_INFO);
 
-	usemap = __nr_to_section(section_nr)->pageblock_flags;
+	usemap = section_to_usemap(__nr_to_section(section_nr));
 	page = virt_to_page(usemap);
 
 	mapsize = PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
@@ -253,7 +253,7 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
 
 	register_page_bootmem_memmap(section_nr, memmap, PAGES_PER_SECTION);
 
-	usemap = __nr_to_section(section_nr)->pageblock_flags;
+	usemap = section_to_usemap(__nr_to_section(section_nr));
 	page = virt_to_page(usemap);
 
 	mapsize = PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8fd42aa7c4bd..8a509e382f55 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -352,7 +352,7 @@ static inline unsigned long *get_pageblock_bitmap(struct page *page,
 							unsigned long pfn)
 {
 #ifdef CONFIG_SPARSEMEM
-	return __pfn_to_section(pfn)->pageblock_flags;
+	return section_to_usemap(__pfn_to_section(pfn));
 #else
 	return page_zone(page)->pageblock_flags;
 #endif /* CONFIG_SPARSEMEM */
diff --git a/mm/sparse.c b/mm/sparse.c
index 1e168bf2779a..91e1908db23d 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -233,15 +233,15 @@ struct page *sparse_decode_mem_map(unsigned long coded_mem_map, unsigned long pn
 
 static int __meminit sparse_init_one_section(struct mem_section *ms,
 		unsigned long pnum, struct page *mem_map,
-		unsigned long *pageblock_bitmap)
+		struct mem_section_usage *usage)
 {
 	if (!present_section(ms))
 		return -EINVAL;
 
 	ms->section_mem_map &= ~SECTION_MAP_MASK;
 	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum) |
-							SECTION_HAS_MEM_MAP;
- 	ms->pageblock_flags = pageblock_bitmap;
+		SECTION_HAS_MEM_MAP;
+	ms->usage = usage;
 
 	return 1;
 }
@@ -255,9 +255,13 @@ unsigned long usemap_size(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-static unsigned long *__kmalloc_section_usemap(void)
+static struct mem_section_usage *__alloc_section_usage(void)
 {
-	return kmalloc(usemap_size(), GFP_KERNEL);
+	struct mem_section_usage *usage;
+
+	usage = kzalloc(sizeof(*usage) + usemap_size(), GFP_KERNEL);
+	/* TODO: allocate the map_active bitmap */
+	return usage;
 }
 #endif /* CONFIG_MEMORY_HOTPLUG */
 
@@ -293,7 +297,8 @@ sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 	return p;
 }
 
-static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
+static void __init check_usemap_section_nr(int nid,
+		struct mem_section_usage *usage)
 {
 	unsigned long usemap_snr, pgdat_snr;
 	static unsigned long old_usemap_snr = NR_MEM_SECTIONS;
@@ -301,7 +306,7 @@ static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
 	struct pglist_data *pgdat = NODE_DATA(nid);
 	int usemap_nid;
 
-	usemap_snr = pfn_to_section_nr(__pa(usemap) >> PAGE_SHIFT);
+	usemap_snr = pfn_to_section_nr(__pa(usage) >> PAGE_SHIFT);
 	pgdat_snr = pfn_to_section_nr(__pa(pgdat) >> PAGE_SHIFT);
 	if (usemap_snr == pgdat_snr)
 		return;
@@ -336,7 +341,8 @@ sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 	return memblock_virt_alloc_node_nopanic(size, pgdat->node_id);
 }
 
-static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
+static void __init check_usemap_section_nr(int nid,
+		struct mem_section_usage *usage)
 {
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
@@ -344,26 +350,27 @@ static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
 static void __init sparse_early_usemaps_alloc_node(void *data,
 				 unsigned long pnum_begin,
 				 unsigned long pnum_end,
-				 unsigned long usemap_count, int nodeid)
+				 unsigned long usage_count, int nodeid)
 {
-	void *usemap;
+	void *usage;
 	unsigned long pnum;
-	unsigned long **usemap_map = (unsigned long **)data;
-	int size = usemap_size();
+	struct mem_section_usage **usage_map = data;
+	int size = sizeof(struct mem_section_usage) + usemap_size();
 
-	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
-							  size * usemap_count);
-	if (!usemap) {
+	usage = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
+							  size * usage_count);
+	if (!usage) {
 		pr_warn("%s: allocation failed\n", __func__);
 		return;
 	}
 
+	memset(usage, 0, size * usage_count);
 	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 		if (!present_section_nr(pnum))
 			continue;
-		usemap_map[pnum] = usemap;
-		usemap += size;
-		check_usemap_section_nr(nodeid, usemap_map[pnum]);
+		usage_map[pnum] = usage;
+		usage += size;
+		check_usemap_section_nr(nodeid, usage_map[pnum]);
 	}
 }
 
@@ -468,7 +475,7 @@ void __weak __meminit vmemmap_populate_print_last(void)
 
 /**
  *  alloc_usemap_and_memmap - memory alloction for pageblock flags and vmemmap
- *  @map: usemap_map for pageblock flags or mmap_map for vmemmap
+ *  @map: usage_map for mem_section_usage or mmap_map for vmemmap
  */
 static void __init alloc_usemap_and_memmap(void (*alloc_func)
 					(void *, unsigned long, unsigned long,
@@ -521,10 +528,9 @@ static void __init alloc_usemap_and_memmap(void (*alloc_func)
  */
 void __init sparse_init(void)
 {
+	struct mem_section_usage *usage, **usage_map;
 	unsigned long pnum;
 	struct page *map;
-	unsigned long *usemap;
-	unsigned long **usemap_map;
 	int size;
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	int size2;
@@ -539,21 +545,21 @@ void __init sparse_init(void)
 
 	/*
 	 * map is using big page (aka 2M in x86 64 bit)
-	 * usemap is less one page (aka 24 bytes)
+	 * usage is less one page (aka 24 bytes)
 	 * so alloc 2M (with 2M align) and 24 bytes in turn will
 	 * make next 2M slip to one more 2M later.
 	 * then in big system, the memory will have a lot of holes...
 	 * here try to allocate 2M pages continuously.
 	 *
 	 * powerpc need to call sparse_init_one_section right after each
-	 * sparse_early_mem_map_alloc, so allocate usemap_map at first.
+	 * sparse_early_mem_map_alloc, so allocate usage_map at first.
 	 */
-	size = sizeof(unsigned long *) * NR_MEM_SECTIONS;
-	usemap_map = memblock_virt_alloc(size, 0);
-	if (!usemap_map)
-		panic("can not allocate usemap_map\n");
+	size = sizeof(struct mem_section_usage *) * NR_MEM_SECTIONS;
+	usage_map = memblock_virt_alloc(size, 0);
+	if (!usage_map)
+		panic("can not allocate usage_map\n");
 	alloc_usemap_and_memmap(sparse_early_usemaps_alloc_node,
-							(void *)usemap_map);
+							(void *)usage_map);
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
@@ -568,8 +574,8 @@ void __init sparse_init(void)
 		if (!present_section_nr(pnum))
 			continue;
 
-		usemap = usemap_map[pnum];
-		if (!usemap)
+		usage = usage_map[pnum];
+		if (!usage)
 			continue;
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
@@ -581,7 +587,7 @@ void __init sparse_init(void)
 			continue;
 
 		sparse_init_one_section(__nr_to_section(pnum), pnum, map,
-								usemap);
+								usage);
 	}
 
 	vmemmap_populate_print_last();
@@ -589,7 +595,7 @@ void __init sparse_init(void)
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	memblock_free_early(__pa(map_map), size2);
 #endif
-	memblock_free_early(__pa(usemap_map), size);
+	memblock_free_early(__pa(usage_map), size);
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
@@ -693,9 +699,9 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
 	struct pglist_data *pgdat = zone->zone_pgdat;
+	static struct mem_section_usage *usage;
 	struct mem_section *ms;
 	struct page *memmap;
-	unsigned long *usemap;
 	unsigned long flags;
 	int ret;
 
@@ -709,8 +715,8 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
 	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id);
 	if (!memmap)
 		return -ENOMEM;
-	usemap = __kmalloc_section_usemap();
-	if (!usemap) {
+	usage = __alloc_section_usage();
+	if (!usage) {
 		__kfree_section_memmap(memmap);
 		return -ENOMEM;
 	}
@@ -727,12 +733,12 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
 
 	ms->section_mem_map |= SECTION_MARKED_PRESENT;
 
-	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
+	ret = sparse_init_one_section(ms, section_nr, memmap, usage);
 
 out:
 	pgdat_resize_unlock(pgdat, &flags);
 	if (ret <= 0) {
-		kfree(usemap);
+		kfree(usage);
 		__kfree_section_memmap(memmap);
 	}
 	return ret;
@@ -760,19 +766,20 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 }
 #endif
 
-static void free_section_usemap(struct page *memmap, unsigned long *usemap)
+static void free_section_usage(struct page *memmap,
+		struct mem_section_usage *usage)
 {
 	struct page *usemap_page;
 
-	if (!usemap)
+	if (!usage)
 		return;
 
-	usemap_page = virt_to_page(usemap);
+	usemap_page = virt_to_page(usage->pageblock_flags);
 	/*
 	 * Check to see if allocation came from hot-plug-add
 	 */
 	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
-		kfree(usemap);
+		kfree(usage);
 		if (memmap)
 			__kfree_section_memmap(memmap);
 		return;
@@ -790,23 +797,24 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
 void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
 		unsigned long map_offset)
 {
+	unsigned long flags;
 	struct page *memmap = NULL;
-	unsigned long *usemap = NULL, flags;
+	struct mem_section_usage *usage = NULL;
 	struct pglist_data *pgdat = zone->zone_pgdat;
 
 	pgdat_resize_lock(pgdat, &flags);
 	if (ms->section_mem_map) {
-		usemap = ms->pageblock_flags;
+		usage = ms->usage;
 		memmap = sparse_decode_mem_map(ms->section_mem_map,
 						__section_nr(ms));
 		ms->section_mem_map = 0;
-		ms->pageblock_flags = NULL;
+		ms->usage = NULL;
 	}
 	pgdat_resize_unlock(pgdat, &flags);
 
 	clear_hwpoisoned_pages(memmap + map_offset,
 			PAGES_PER_SECTION - map_offset);
-	free_section_usemap(memmap, usemap);
+	free_section_usage(memmap, usage);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_MEMORY_HOTPLUG */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
