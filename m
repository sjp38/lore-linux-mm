Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EA4F46B48F3
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:20:41 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id l9so23427550plt.7
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:20:41 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id y10si3926463plt.406.2018.11.27.08.20.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 08:20:40 -0800 (PST)
From: Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2 3/5] mm, memory_hotplug: Move zone/pages handling to offline stage
Date: Tue, 27 Nov 2018 17:20:03 +0100
Message-Id: <20181127162005.15833-4-osalvador@suse.de>
In-Reply-To: <20181127162005.15833-1-osalvador@suse.de>
References: <20181127162005.15833-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.com>

The current implementation accesses pages during hot-remove
stage in order to get the zone linked to this memory-range.
We use that zone for a) check if the zone is ZONE_DEVICE and
b) to shrink the zone's spanned pages.

Accessing pages during this stage is problematic, as we might be
accessing pages that were not initialized if we did not get to
online the memory before removing it.

The only reason to check for ZONE_DEVICE in __remove_pages
is to bypass the call to release_mem_region_adjustable(),
since these regions are removed with devm_release_mem_region.

With patch#2, this is no longer a problem so we can safely
call release_mem_region_adjustable().
release_mem_region_adjustable() will spot that the region
we are trying to remove was acquired by means of
devm_request_mem_region, and will back off safely.

This allows us to remove all zone-related operations from
hot-remove stage.

Because of this, zone's spanned pages are shrinked during
the offlining stage in shrink_zone_pgdat().
It would have been great to decrease also the spanned page
for the node there, but we need them in try_offline_node().
So we still decrease spanned pages for the node in the hot-remove
stage.

The only particularity is that now
find_smallest_section_pfn/find_biggest_section_pfn, when called from
shrink_zone_span, will now check for online sections and not
valid sections instead.
To make this work with devm/HMM code, we need to call offline_mem_sections
and online_mem_sections in that code path when we are adding memory.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 arch/powerpc/mm/mem.c          | 11 +----
 arch/sh/mm/init.c              |  4 +-
 arch/x86/mm/init_32.c          |  3 +-
 arch/x86/mm/init_64.c          |  8 +---
 include/linux/memory_hotplug.h |  8 ++--
 kernel/memremap.c              | 14 +++++--
 mm/memory_hotplug.c            | 95 ++++++++++++++++++++++++------------------
 mm/sparse.c                    |  4 +-
 8 files changed, 76 insertions(+), 71 deletions(-)

diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 40feb262080e..b3c9ee5c4f78 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -144,18 +144,9 @@ int __meminit arch_remove_memory(int nid, u64 start, u64 size,
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
-	struct page *page;
 	int ret;
 
-	/*
-	 * If we have an altmap then we need to skip over any reserved PFNs
-	 * when querying the zone.
-	 */
-	page = pfn_to_page(start_pfn);
-	if (altmap)
-		page += vmem_altmap_offset(altmap);
-
-	ret = __remove_pages(page_zone(page), start_pfn, nr_pages, altmap);
+	ret = remove_sections(nid, start_pfn, nr_pages, altmap);
 	if (ret)
 		return ret;
 
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index a8e5c0e00fca..1a483a008872 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -447,11 +447,9 @@ int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
-	struct zone *zone;
 	int ret;
 
-	zone = page_zone(pfn_to_page(start_pfn));
-	ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
+	ret = remove_sections(nid, start_pfn, nr_pages, altmap);
 	if (unlikely(ret))
 		pr_warn("%s: Failed, __remove_pages() == %d\n", __func__,
 			ret);
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 85c94f9a87f8..0b8c7b0033d2 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -866,8 +866,7 @@ int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 
-	zone = page_zone(pfn_to_page(start_pfn));
-	return __remove_pages(zone, start_pfn, nr_pages, altmap);
+	return remove_sections(nid, start_pfn, nr_pages, altmap);
 }
 #endif
 #endif
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 449958da97a4..f80d98381a97 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1152,15 +1152,9 @@ int __ref arch_remove_memory(int nid, u64 start, u64 size,
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
-	struct page *page = pfn_to_page(start_pfn);
-	struct zone *zone;
 	int ret;
 
-	/* With altmap the first mapped page is offset from @start */
-	if (altmap)
-		page += vmem_altmap_offset(altmap);
-	zone = page_zone(page);
-	ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
+	ret = remove_sections(nid, start_pfn, nr_pages, altmap);
 	WARN_ON_ONCE(ret);
 	kernel_physical_mapping_remove(start, start + size);
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 3aedcd7929cd..0a882d8e32c6 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -109,8 +109,10 @@ static inline bool movable_node_is_enabled(void)
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern int arch_remove_memory(int nid, u64 start, u64 size,
 				struct vmem_altmap *altmap);
-extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
-	unsigned long nr_pages, struct vmem_altmap *altmap);
+extern int remove_sections(int nid, unsigned long start_pfn,
+			unsigned long nr_pages, struct vmem_altmap *altmap);
+extern void shrink_zone(struct zone *zone, unsigned long start_pfn,
+			unsigned long end_pfn, unsigned long offlined_pages);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /* reasonably generic interface to expand the physical pages */
@@ -335,7 +337,7 @@ extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern int sparse_add_one_section(struct pglist_data *pgdat,
 		unsigned long start_pfn, struct vmem_altmap *altmap);
-extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
+extern void sparse_remove_one_section(int nid, struct mem_section *ms,
 		unsigned long map_offset, struct vmem_altmap *altmap);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 0d5603d76c37..66cbf334203b 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -87,6 +87,7 @@ static void devm_memremap_pages_release(void *data)
 	struct resource *res = &pgmap->res;
 	resource_size_t align_start, align_size;
 	unsigned long pfn;
+	unsigned long nr_pages;
 	int nid;
 
 	pgmap->kill(pgmap->ref);
@@ -101,10 +102,14 @@ static void devm_memremap_pages_release(void *data)
 	nid = page_to_nid(pfn_to_page(align_start >> PAGE_SHIFT));
 
 	mem_hotplug_begin();
+
+	pfn = align_start >> PAGE_SHIFT;
+	nr_pages = align_size >> PAGE_SHIFT;
+	offline_mem_sections(pfn, pfn + nr_pages);
+	shrink_zone(page_zone(pfn_to_page(pfn)), pfn, pfn + nr_pages, nr_pages);
+
 	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
-		pfn = align_start >> PAGE_SHIFT;
-		__remove_pages(page_zone(pfn_to_page(pfn)), pfn,
-				align_size >> PAGE_SHIFT, NULL);
+		remove_sections(nid, pfn, nr_pages, NULL);
 	} else {
 		arch_remove_memory(nid, align_start, align_size,
 				pgmap->altmap_valid ? &pgmap->altmap : NULL);
@@ -224,7 +229,10 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 
 	if (!error) {
 		struct zone *zone;
+		unsigned long pfn = align_start >> PAGE_SHIFT;
+		unsigned long nr_pages = align_size >> PAGE_SHIFT;
 
+		online_mem_sections(pfn, pfn + nr_pages);
 		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
 		move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
 				align_size >> PAGE_SHIFT, altmap);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 849bcc55c5f1..4fe42ccb0be4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -314,6 +314,17 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
+static bool is_section_ok(struct mem_section *ms, bool zone)
+{
+	/*
+	 * We cannot shrink pgdat's spanned because we use them
+	 * in try_offline_node to check if all sections were removed.
+	 */
+	if (zone)
+		return online_section(ms);
+	else
+		return valid_section(ms);
+}
 /* find the smallest valid pfn in the range [start_pfn, end_pfn) */
 static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
 				     unsigned long start_pfn,
@@ -324,7 +335,7 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
 	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
 		ms = __pfn_to_section(start_pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (!is_section_ok(ms, !!zone))
 			continue;
 
 		if (unlikely(pfn_to_nid(start_pfn) != nid))
@@ -352,7 +363,7 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
 	for (; pfn >= start_pfn; pfn -= PAGES_PER_SECTION) {
 		ms = __pfn_to_section(pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (!is_section_ok(ms, !!zone))
 			continue;
 
 		if (unlikely(pfn_to_nid(pfn) != nid))
@@ -414,7 +425,7 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
 		ms = __pfn_to_section(pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (unlikely(!online_section(ms)))
 			continue;
 
 		if (page_zone(pfn_to_page(pfn)) != zone)
@@ -501,23 +512,33 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	pgdat->node_spanned_pages = 0;
 }
 
-static void __remove_zone(struct zone *zone, unsigned long start_pfn)
+void shrink_zone(struct zone *zone, unsigned long start_pfn,
+		unsigned long end_pfn, unsigned long offlined_pages)
 {
-	struct pglist_data *pgdat = zone->zone_pgdat;
 	int nr_pages = PAGES_PER_SECTION;
+	unsigned long pfn;
+
+	clear_zone_contiguous(zone);
+	for (pfn = start_pfn; pfn < end_pfn; pfn += nr_pages)
+		shrink_zone_span(zone, pfn, pfn + nr_pages);
+	set_zone_contiguous(zone);
+}
+
+static void shrink_pgdat(int nid, unsigned long sect_nr)
+{
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	int nr_pages = PAGES_PER_SECTION;
+	unsigned long pfn = section_nr_to_pfn((unsigned long)sect_nr);
 	unsigned long flags;
 
-	pgdat_resize_lock(zone->zone_pgdat, &flags);
-	shrink_zone_span(zone, start_pfn, start_pfn + nr_pages);
-	shrink_pgdat_span(pgdat, start_pfn, start_pfn + nr_pages);
-	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+	pgdat_resize_lock(pgdat, &flags);
+	shrink_pgdat_span(pgdat, pfn, pfn + nr_pages);
+	pgdat_resize_unlock(pgdat, &flags);
 }
 
-static int __remove_section(struct zone *zone, struct mem_section *ms,
+static int __remove_section(int nid, struct mem_section *ms,
 		unsigned long map_offset, struct vmem_altmap *altmap)
 {
-	unsigned long start_pfn;
-	int scn_nr;
 	int ret = -EINVAL;
 
 	if (!valid_section(ms))
@@ -527,17 +548,15 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
 	if (ret)
 		return ret;
 
-	scn_nr = __section_nr(ms);
-	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
-	__remove_zone(zone, start_pfn);
+	shrink_pgdat(nid, __section_nr(ms));
 
-	sparse_remove_one_section(zone, ms, map_offset, altmap);
+	sparse_remove_one_section(nid, ms, map_offset, altmap);
 	return 0;
 }
 
 /**
- * __remove_pages() - remove sections of pages from a zone
- * @zone: zone from which pages need to be removed
+ * __remove_pages() - remove sections of pages from a nid
+ * @nid: nid from which pages belong to
  * @phys_start_pfn: starting pageframe (must be aligned to start of a section)
  * @nr_pages: number of pages to remove (must be multiple of section size)
  * @altmap: alternative device page map or %NULL if default memmap is used
@@ -547,35 +566,28 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
  * sure that pages are marked reserved and zones are adjust properly by
  * calling offline_pages().
  */
-int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
+int remove_sections(int nid, unsigned long phys_start_pfn,
 		 unsigned long nr_pages, struct vmem_altmap *altmap)
 {
 	unsigned long i;
 	unsigned long map_offset = 0;
 	int sections_to_remove, ret = 0;
+	resource_size_t start, size;
 
-	/* In the ZONE_DEVICE case device driver owns the memory region */
-	if (is_dev_zone(zone)) {
-		if (altmap)
-			map_offset = vmem_altmap_offset(altmap);
-	} else {
-		resource_size_t start, size;
-
-		start = phys_start_pfn << PAGE_SHIFT;
-		size = nr_pages * PAGE_SIZE;
+	start = phys_start_pfn << PAGE_SHIFT;
+	size = nr_pages * PAGE_SIZE;
 
-		ret = release_mem_region_adjustable(&iomem_resource, start,
-					size);
-		if (ret) {
-			resource_size_t endres = start + size - 1;
+	if (altmap)
+		map_offset = vmem_altmap_offset(altmap);
 
-			pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
-					&start, &endres, ret);
-		}
+	ret = release_mem_region_adjustable(&iomem_resource, start,
+								size);
+	if (ret) {
+		resource_size_t endres = start + size - 1;
+		pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
+						&start, &endres, ret);
 	}
 
-	clear_zone_contiguous(zone);
-
 	/*
 	 * We can only remove entire sections
 	 */
@@ -587,15 +599,13 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
 
 		cond_resched();
-		ret = __remove_section(zone, __pfn_to_section(pfn), map_offset,
-				altmap);
+		ret = __remove_section(nid, __pfn_to_section(pfn), map_offset,
+									altmap);
 		map_offset = 0;
 		if (ret)
 			break;
 	}
 
-	set_zone_contiguous(zone);
-
 	return ret;
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
@@ -1652,11 +1662,14 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	/* reset pagetype flags and makes migrate type to be MOVABLE */
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
 	/* removal success */
+
+	/* Shrink zone's managed,spanned and zone/pgdat's present pages */
 	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
 	zone->present_pages -= offlined_pages;
 
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
 	zone->zone_pgdat->node_present_pages -= offlined_pages;
+	shrink_zone(zone, valid_start, valid_end, offlined_pages);
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 
 	init_per_zone_wmark_min();
diff --git a/mm/sparse.c b/mm/sparse.c
index 691544a2814c..01aa42102f8b 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -790,12 +790,12 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
 		free_map_bootmem(memmap);
 }
 
-void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
+void sparse_remove_one_section(int nid, struct mem_section *ms,
 		unsigned long map_offset, struct vmem_altmap *altmap)
 {
 	struct page *memmap = NULL;
 	unsigned long *usemap = NULL, flags;
-	struct pglist_data *pgdat = zone->zone_pgdat;
+	struct pglist_data *pgdat = NODE_DATA(nid);
 
 	pgdat_resize_lock(pgdat, &flags);
 	if (ms->section_mem_map) {
-- 
2.13.6
