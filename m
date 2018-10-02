Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id D00C56B000D
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 11:00:54 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id y203-v6so1825096wmg.9
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 08:00:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 192-v6sor1464146wmw.0.2018.10.02.08.00.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Oct 2018 08:00:51 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [RFC PATCH v3 4/5] mm/memory_hotplug: Move zone/pages handling to offline stage
Date: Tue,  2 Oct 2018 17:00:28 +0200
Message-Id: <20181002150029.23461-5-osalvador@techadventures.net>
In-Reply-To: <20181002150029.23461-1-osalvador@techadventures.net>
References: <20181002150029.23461-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, dave.jiang@intel.com, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Currently, we decrement zone/node spanned_pages during the
hot-remove path.

The picture we have now is:

- hot-add memory:
  a) Allocate a new resouce based on the hot-added memory
  b) Add memory sections for the hot-added memory

- online memory:
  c) Re-adjust zone/pgdat nr of pages (managed, spanned, present)
  d) Initialize the pages from the new memory-range
  e) Online memory sections

- offline memory:
  f) Offline memory sections
  g) Re-adjust zone/pgdat nr of managed/present pages

- hot-remove memory:
  i) Re-adjust zone/pgdat nr of spanned pages
  j) Remove memory sections
  k) Release resource

This, besides of not being consistent with the current code,
implies that we can access steal pages if we never get to online
that memory.
So we should move i) to the offline stage.

Hot-remove path should only care about memory sections and memory
blocks.

There is a particularity and that is HMM/devm.
When the memory is being handled by HMM/devm, this memory is moved to
ZONE_DEVICE by means of move_pfn_range_to_zone, but since this memory
does not get "online", the sections do not get online either.
This is a problem because shrink_zone_pgdat_pages will now look for
online sections, so we need to explicitly offline the sections
before calling in.
add_device_memory takes care of online them, and del_device_memory offlines
them.

Finally, shrink_zone_pgdat_pages() is moved to offline_pages(), so now,
all pages/zone handling is being taken care in online/offline_pages stage.

So now we will have:

- hot-add memory:
  a) Allocate a new resource based on the hot-added memory
  b) Add memory sections for the hot-added memory

- online memory:
  c) Re-adjust zone/pgdat nr of pages (managed, spanned, present)
  d) Initialize the pages from the new memory-range
  e) Online memory sections

- offline memory:
  f) Offline memory sections
  g) Re-adjust zone/pgdat nr of managed/present/spanned pages

- hot-remove memory:
  i) Remove memory sections
  j) Release resource

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 arch/ia64/mm/init.c            |   4 +-
 arch/powerpc/mm/mem.c          |  11 +----
 arch/sh/mm/init.c              |   4 +-
 arch/x86/mm/init_32.c          |   4 +-
 arch/x86/mm/init_64.c          |   8 +---
 include/linux/memory_hotplug.h |   8 ++--
 mm/memory_hotplug.c            | 100 +++++++++++++++++++----------------------
 mm/sparse.c                    |   4 +-
 8 files changed, 57 insertions(+), 86 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 904fe55e10fc..a6b5f351620c 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -665,11 +665,9 @@ int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
-	struct zone *zone;
 	int ret;
 
-	zone = page_zone(pfn_to_page(start_pfn));
-	ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
+	ret = __remove_pages(nid, start_pfn, nr_pages, altmap);
 	if (ret)
 		pr_warn("%s: Problem encountered in __remove_pages() as"
 			" ret=%d\n", __func__,  ret);
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 445fce705f91..6d02171b2d0f 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -142,18 +142,9 @@ int __meminit arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altma
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
+	ret = __remove_pages(nid, start_pfn, nr_pages, altmap);
 	if (ret)
 		return ret;
 
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index a8e5c0e00fca..6e80a7a50f8b 100644
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
+	ret = __remove_pages(nid, start_pfn, nr_pages, altmap);
 	if (unlikely(ret))
 		pr_warn("%s: Failed, __remove_pages() == %d\n", __func__,
 			ret);
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index b2a698d87a0e..72f403816053 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -864,10 +864,8 @@ int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
-	struct zone *zone;
 
-	zone = page_zone(pfn_to_page(start_pfn));
-	return __remove_pages(zone, start_pfn, nr_pages, altmap);
+	return __remove_pages(nid, start_pfn, nr_pages, altmap);
 }
 #endif
 #endif
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index c754d9543ae1..9872307d9c88 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1151,15 +1151,9 @@ int __ref arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *a
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
+	ret = __remove_pages(nid, start_pfn, nr_pages, altmap);
 	WARN_ON_ONCE(ret);
 	kernel_physical_mapping_remove(start, start + size);
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 2f7b8eb4cddb..90c97a843094 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -109,8 +109,8 @@ static inline bool movable_node_is_enabled(void)
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern int arch_remove_memory(int nid, u64 start, u64 size,
 		struct vmem_altmap *altmap);
-extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
-	unsigned long nr_pages, struct vmem_altmap *altmap);
+extern int __remove_pages(int nid, unsigned long start_pfn,
+			unsigned long nr_pages, struct vmem_altmap *altmap);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /* reasonably generic interface to expand the physical pages */
@@ -342,8 +342,8 @@ extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern int sparse_add_one_section(struct pglist_data *pgdat,
 		unsigned long start_pfn, struct vmem_altmap *altmap);
-extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
-		unsigned long map_offset, struct vmem_altmap *altmap);
+extern void sparse_remove_one_section(int nid, struct mem_section *ms,
+			unsigned long map_offset, struct vmem_altmap *altmap);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
 extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 72928808c5e9..1f71aebd598b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -319,12 +319,10 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
 				     unsigned long start_pfn,
 				     unsigned long end_pfn)
 {
-	struct mem_section *ms;
-
 	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
-		ms = __pfn_to_section(start_pfn);
+		struct mem_section *ms = __pfn_to_section(start_pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (unlikely(!online_section(ms)))
 			continue;
 
 		if (unlikely(pfn_to_nid(start_pfn) != nid))
@@ -344,15 +342,14 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
 				    unsigned long start_pfn,
 				    unsigned long end_pfn)
 {
-	struct mem_section *ms;
 	unsigned long pfn;
 
 	/* pfn is the end pfn of a memory section. */
 	pfn = end_pfn - 1;
 	for (; pfn >= start_pfn; pfn -= PAGES_PER_SECTION) {
-		ms = __pfn_to_section(pfn);
+		struct mem_section *ms = __pfn_to_section(pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (unlikely(!online_section(ms)))
 			continue;
 
 		if (unlikely(pfn_to_nid(pfn) != nid))
@@ -414,7 +411,7 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
 		ms = __pfn_to_section(pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (unlikely(!online_section(ms)))
 			continue;
 
 		if (page_zone(pfn_to_page(pfn)) != zone)
@@ -482,7 +479,7 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SECTION) {
 		ms = __pfn_to_section(pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (unlikely(!online_section(ms)))
 			continue;
 
 		if (pfn_to_nid(pfn) != nid)
@@ -501,23 +498,31 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	pgdat->node_spanned_pages = 0;
 }
 
-static void __remove_zone(struct zone *zone, unsigned long start_pfn)
+static void shrink_zone_pgdat_pages(struct zone *zone, unsigned long start_pfn,
+			unsigned long end_pfn, unsigned long offlined_pages)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	int nr_pages = PAGES_PER_SECTION;
 	unsigned long flags;
+	unsigned long pfn;
 
-	pgdat_resize_lock(zone->zone_pgdat, &flags);
-	shrink_zone_span(zone, start_pfn, start_pfn + nr_pages);
-	shrink_pgdat_span(pgdat, start_pfn, start_pfn + nr_pages);
-	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+	zone->present_pages -= offlined_pages;
+	clear_zone_contiguous(zone);
+
+	pgdat_resize_lock(pgdat, &flags);
+	pgdat->node_present_pages -= offlined_pages;
+	for (pfn = start_pfn; pfn < end_pfn; pfn += nr_pages) {
+		shrink_zone_span(zone, pfn, pfn + nr_pages);
+		shrink_pgdat_span(pgdat, pfn, pfn + nr_pages);
+	}
+	pgdat_resize_unlock(pgdat, &flags);
+
+	set_zone_contiguous(zone);
 }
 
-static int __remove_section(struct zone *zone, struct mem_section *ms,
+static int __remove_section(int nid, struct mem_section *ms,
 		unsigned long map_offset, struct vmem_altmap *altmap)
 {
-	unsigned long start_pfn;
-	int scn_nr;
 	int ret = -EINVAL;
 
 	if (!valid_section(ms))
@@ -527,17 +532,13 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
 	if (ret)
 		return ret;
 
-	scn_nr = __section_nr(ms);
-	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
-	__remove_zone(zone, start_pfn);
-
-	sparse_remove_one_section(zone, ms, map_offset, altmap);
+	sparse_remove_one_section(nid, ms, map_offset, altmap);
 	return 0;
 }
 
 /**
  * __remove_pages() - remove sections of pages from a zone
- * @zone: zone from which pages need to be removed
+ * @nid: nid from which pages belong to
  * @phys_start_pfn: starting pageframe (must be aligned to start of a section)
  * @nr_pages: number of pages to remove (must be multiple of section size)
  * @altmap: alternative device page map or %NULL if default memmap is used
@@ -547,35 +548,27 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
  * sure that pages are marked reserved and zones are adjust properly by
  * calling offline_pages().
  */
-int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
-		 unsigned long nr_pages, struct vmem_altmap *altmap)
+int __remove_pages(int nid, unsigned long phys_start_pfn,
+			 unsigned long nr_pages, struct vmem_altmap *altmap)
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
+	ret = release_mem_region_adjustable(&iomem_resource, start, size);
+	if (ret) {
+		resource_size_t endres = start + size - 1;
+		pr_warn("Unable to release resource <%pa-%pa> (%d)\n", &start,
+								&endres, ret);
 	}
 
-	clear_zone_contiguous(zone);
-
 	/*
 	 * We can only remove entire sections
 	 */
@@ -586,15 +579,13 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	for (i = 0; i < sections_to_remove; i++) {
 		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
 
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
@@ -1580,7 +1571,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	unsigned long pfn, nr_pages;
 	long offlined_pages;
 	int ret, node;
-	unsigned long flags;
 	unsigned long valid_start, valid_end;
 	struct zone *zone;
 	struct memory_notify arg;
@@ -1658,11 +1648,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
 	/* removal success */
 	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
-	zone->present_pages -= offlined_pages;
 
-	pgdat_resize_lock(zone->zone_pgdat, &flags);
-	zone->zone_pgdat->node_present_pages -= offlined_pages;
-	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+	/* Here we will shrink zone/node's spanned/present_pages */
+	shrink_zone_pgdat_pages(zone, valid_start, valid_end, offlined_pages);
 
 	init_per_zone_wmark_min();
 
@@ -1911,12 +1899,15 @@ int del_device_memory(int nid, unsigned long start, unsigned long size,
 	int ret;
 	unsigned long start_pfn = PHYS_PFN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
-	struct zone *zone = page_zone(pfn_to_page(pfn));
+	struct zone *zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
 
 	mem_hotplug_begin();
 
+	offline_mem_sections(start_pfn, start_pfn + nr_pages);
+	shrink_zone_pgdat_pages(zone, start_pfn, start_pfn + nr_pages, 0);
+
 	if (private_mem)
-		ret = __remove_pages(zone, start_pfn, nr_pages, NULL);
+		ret = __remove_pages(nid, start_pfn, nr_pages, NULL);
 	else
 		ret = arch_remove_memory(nid, start, size, altmap);
 
@@ -1946,6 +1937,7 @@ int add_device_memory(int nid, unsigned long start, unsigned long size,
 
 	if (!ret) {
 		struct zone *zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
+		online_mem_sections(start_pfn, start_pfn + nr_pages);
 		move_pfn_range_to_zone(zone, start_pfn, nr_pages, altmap);
 	}
 
diff --git a/mm/sparse.c b/mm/sparse.c
index c0788e3d8513..21d5f6ad0d14 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -766,12 +766,12 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
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
