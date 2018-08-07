Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0476B000E
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 09:38:25 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s18-v6so11571617wmh.0
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 06:38:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q201-v6sor461369wmg.15.2018.08.07.06.38.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 06:38:23 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and move it to offline_pages
Date: Tue,  7 Aug 2018 15:37:56 +0200
Message-Id: <20180807133757.18352-3-osalvador@techadventures.net>
In-Reply-To: <20180807133757.18352-1-osalvador@techadventures.net>
References: <20180807133757.18352-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@oracle.com, jglisse@redhat.com, david@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Currently, we decrement zone/node spanned_pages when we
__remove__ the memory.
This is not really great.

Incrementing of spanned pages is done in online_pages() path,
decrementing spanned pages should be moved to offline_pages().

This, besides making the core more consistent, helps in fixing
the bug explained in the cover letter, since from now on,
we will not touch any pages in remove_memory path.

This does all the work to accomplish this.
It removes __remove_zone() and creates __shrink_pages(), which does pretty much the same.

It also changes find_smallest/biggest_section_pfn to check for:

!online_section(ms)

instead of

!valid_section(ms)

as we offline the section in:

__offline_pages
 offline_isolated_pages
  offline_isolated_pages_cb
   __offline_isolated_pages
    offline_mem_sections

right before shrinking the pages.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 arch/ia64/mm/init.c            |  4 +--
 arch/powerpc/mm/mem.c          | 11 +------
 arch/sh/mm/init.c              |  4 +--
 arch/x86/mm/init_32.c          |  4 +--
 arch/x86/mm/init_64.c          |  8 +-----
 include/linux/memory_hotplug.h |  6 ++--
 kernel/memremap.c              |  5 ++++
 mm/hmm.c                       |  2 +-
 mm/memory_hotplug.c            | 65 +++++++++++++++++++++---------------------
 mm/sparse.c                    |  4 +--
 10 files changed, 50 insertions(+), 63 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index bc5e15045cee..0029c4d3f574 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -664,11 +664,9 @@ int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
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
index 9e17d57a9948..12879191bc6b 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -143,18 +143,9 @@ int __meminit arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altma
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
index 55c740ab861b..4f183857b522 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -458,11 +458,9 @@ int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
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
index 9fa503f2f56c..88909e88c873 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -865,10 +865,8 @@ int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
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
index 26728df07072..1aad5ea2e274 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1152,15 +1152,9 @@ int __ref arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *a
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
index c68b03fd87bd..eff460ba3ab1 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -109,8 +109,10 @@ static inline bool movable_node_is_enabled(void)
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern int arch_remove_memory(int nid, u64 start, u64 size,
 		struct vmem_altmap *altmap);
-extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
+extern int __remove_pages(int nid, unsigned long start_pfn,
 	unsigned long nr_pages, struct vmem_altmap *altmap);
+extern void shrink_pages(struct zone *zone, unsigned long start_pfn,
+					unsigned long nr_pages);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /* reasonably generic interface to expand the physical pages */
@@ -333,7 +335,7 @@ extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
 extern int sparse_add_one_section(struct pglist_data *pgdat,
 		unsigned long start_pfn, struct vmem_altmap *altmap);
-extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
+extern void sparse_remove_one_section(int nid, struct mem_section *ms,
 		unsigned long map_offset, struct vmem_altmap *altmap);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 7a832b844f24..2057af5c1c4f 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -121,6 +121,7 @@ static void devm_memremap_pages_release(void *data)
 	struct resource *res = &pgmap->res;
 	resource_size_t align_start, align_size;
 	unsigned long pfn;
+	struct page *page;
 	int nid;
 
 	for_each_device_pfn(pfn, pgmap)
@@ -138,6 +139,10 @@ static void devm_memremap_pages_release(void *data)
 	nid = dev_to_node(dev);
 
 	mem_hotplug_begin();
+	page = pfn_to_page(pfn);
+	if (pgmap->altmap_valid)
+		page += vmem_altmap_offset(&pgmap->altmap);
+	shrink_pages(page_zone(page), pfn, align_size >> PAGE_SHIFT);
 	arch_remove_memory(nid, align_start, align_size, pgmap->altmap_valid ?
 			&pgmap->altmap : NULL);
 	kasan_remove_zero_shadow(__va(align_start), align_size);
diff --git a/mm/hmm.c b/mm/hmm.c
index 21787e480b4a..b2f2dcadb5fb 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1012,7 +1012,7 @@ static void hmm_devmem_release(struct device *dev, void *data)
 
 	mem_hotplug_begin();
 	if (resource->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY)
-		__remove_pages(zone, start_pfn, npages, NULL);
+		__remove_pages(nid, start_pfn, npages, NULL);
 	else
 		arch_remove_memory(nid, start_pfn << PAGE_SHIFT,
 				   npages << PAGE_SHIFT, NULL);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9bd629944c91..e33555651e46 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -320,12 +320,10 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
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
@@ -345,15 +343,14 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
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
@@ -415,7 +412,7 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
 		ms = __pfn_to_section(pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (unlikely(!online_section(ms)))
 			continue;
 
 		if (page_zone(pfn_to_page(pfn)) != zone)
@@ -483,7 +480,7 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SECTION) {
 		ms = __pfn_to_section(pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (unlikely(!online_section(ms)))
 			continue;
 
 		if (pfn_to_nid(pfn) != nid)
@@ -502,19 +499,32 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	pgdat->node_spanned_pages = 0;
 }
 
-static void __remove_zone(struct zone *zone, unsigned long start_pfn)
+static void __shrink_pages(struct zone *zone, unsigned long start_pfn,
+						unsigned long end_pfn,
+						unsigned long offlined_pages)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	int nr_pages = PAGES_PER_SECTION;
 	unsigned long flags;
+	unsigned long pfn;
 
-	pgdat_resize_lock(zone->zone_pgdat, &flags);
-	shrink_zone_span(zone, start_pfn, start_pfn + nr_pages);
-	shrink_pgdat_span(pgdat, start_pfn, start_pfn + nr_pages);
-	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+	clear_zone_contiguous(zone);
+	pgdat_resize_lock(pgdat, &flags);
+	for(pfn = start_pfn; pfn < end_pfn; pfn += nr_pages) {
+		shrink_zone_span(zone, pfn, pfn + nr_pages);
+		shrink_pgdat_span(pgdat, pfn, pfn + nr_pages);
+	}
+	pgdat->node_present_pages -= offlined_pages;
+	pgdat_resize_unlock(pgdat, &flags);
+	set_zone_contiguous(zone);
 }
 
-static int __remove_section(struct zone *zone, struct mem_section *ms,
+void shrink_pages(struct zone *zone, unsigned long start_pfn, unsigned long nr_pages)
+{
+	__shrink_pages(zone, start_pfn, start_pfn + nr_pages, nr_pages);
+}
+
+static int __remove_section(int nid, struct mem_section *ms,
 		unsigned long map_offset, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn;
@@ -530,15 +540,14 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
 
 	scn_nr = __section_nr(ms);
 	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
-	__remove_zone(zone, start_pfn);
 
-	sparse_remove_one_section(zone, ms, map_offset, altmap);
+	sparse_remove_one_section(nid, ms, map_offset, altmap);
 	return 0;
 }
 
 /**
  * __remove_pages() - remove sections of pages from a zone
- * @zone: zone from which pages need to be removed
+ * @nid: node which pages belong to
  * @phys_start_pfn: starting pageframe (must be aligned to start of a section)
  * @nr_pages: number of pages to remove (must be multiple of section size)
  * @altmap: alternative device page map or %NULL if default memmap is used
@@ -548,7 +557,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
  * sure that pages are marked reserved and zones are adjust properly by
  * calling offline_pages().
  */
-int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
+int __remove_pages(int nid, unsigned long phys_start_pfn,
 		 unsigned long nr_pages, struct vmem_altmap *altmap)
 {
 	unsigned long i;
@@ -556,10 +565,9 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	int sections_to_remove, ret = 0;
 
 	/* In the ZONE_DEVICE case device driver owns the memory region */
-	if (is_dev_zone(zone)) {
-		if (altmap)
-			map_offset = vmem_altmap_offset(altmap);
-	} else {
+	if (altmap)
+		map_offset = vmem_altmap_offset(altmap);
+	else {
 		resource_size_t start, size;
 
 		start = phys_start_pfn << PAGE_SHIFT;
@@ -575,8 +583,6 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 		}
 	}
 
-	clear_zone_contiguous(zone);
-
 	/*
 	 * We can only remove entire sections
 	 */
@@ -587,15 +593,13 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	for (i = 0; i < sections_to_remove; i++) {
 		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
 
-		ret = __remove_section(zone, __pfn_to_section(pfn), map_offset,
+		ret = __remove_section(nid, __pfn_to_section(pfn), map_offset,
 				altmap);
 		map_offset = 0;
 		if (ret)
 			break;
 	}
 
-	set_zone_contiguous(zone);
-
 	return ret;
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
@@ -1595,7 +1599,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	unsigned long pfn, nr_pages;
 	long offlined_pages;
 	int ret, node;
-	unsigned long flags;
 	unsigned long valid_start, valid_end;
 	struct zone *zone;
 	struct memory_notify arg;
@@ -1667,9 +1670,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
 	zone->present_pages -= offlined_pages;
 
-	pgdat_resize_lock(zone->zone_pgdat, &flags);
-	zone->zone_pgdat->node_present_pages -= offlined_pages;
-	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+	__shrink_pages(zone, valid_start, valid_end, offlined_pages);
 
 	init_per_zone_wmark_min();
 
diff --git a/mm/sparse.c b/mm/sparse.c
index 10b07eea9a6e..016020bd20b5 100644
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
