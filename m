From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070601163031.24933.66621.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070601163010.24933.87242.sendpatchset@skynet.skynet.ie>
References: <20070601163010.24933.87242.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/3] Do not depend on MAX_ORDER when grouping pages by mobility
Date: Fri,  1 Jun 2007 17:30:31 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently mobility grouping works at the MAX_ORDER_NR_PAGES level.
This makes sense for the majority of users where this is also the huge page
size. However, on platforms like ia64 where the huge page size is runtime
configurable it is desirable to group at a lower order.  On x86_64 and
occasionally on x86, the hugepage size may not always be MAX_ORDER_NR_PAGES.

This patch groups pages together based on the value of HUGETLB_PAGE_ORDER. It
uses a compile-time constant if possible and a variable where the huge page
size is runtime configurable.

It is assumed that grouping should be done at the lowest sensible order
and that the user would not want to override this.  If this is not true,
page_block order could be forced to a variable initialised via a boot-time
kernel parameter.

One potential issue with this patch is that IA64 now parses hugepagesz
with early_param() instead of __setup(). __setup() is called after the
memory allocator has been initialised and the pageblock bitmaps already
setup. In tests on one IA64 there did not seem to be any problem with using
early_param() and in fact may be more correct as it guarantees the parameter
is handled before the parsing of hugepages=.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Christoph Lameter <clameter@sgi.com>
---

 arch/ia64/Kconfig               |    5 ++
 arch/ia64/mm/hugetlbpage.c      |    4 +-
 include/linux/mmzone.h          |    4 +-
 include/linux/pageblock-flags.h |   25 ++++++++++++-
 mm/page_alloc.c                 |   67 ++++++++++++++++++++++++-----------
 5 files changed, 80 insertions(+), 25 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc3-mm1-clean/arch/ia64/Kconfig linux-2.6.22-rc3-mm1-004_group_arbitrary/arch/ia64/Kconfig
--- linux-2.6.22-rc3-mm1-clean/arch/ia64/Kconfig	2007-06-01 09:24:34.000000000 +0100
+++ linux-2.6.22-rc3-mm1-004_group_arbitrary/arch/ia64/Kconfig	2007-06-01 10:16:26.000000000 +0100
@@ -54,6 +54,11 @@ config ARCH_HAS_ILOG2_U64
 	bool
 	default n
 
+config HUGETLB_PAGE_SIZE_VARIABLE
+	bool
+	depends on HUGETLB_PAGE
+	default y
+
 config GENERIC_FIND_NEXT_BIT
 	bool
 	default y
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc3-mm1-clean/arch/ia64/mm/hugetlbpage.c linux-2.6.22-rc3-mm1-004_group_arbitrary/arch/ia64/mm/hugetlbpage.c
--- linux-2.6.22-rc3-mm1-clean/arch/ia64/mm/hugetlbpage.c	2007-05-26 03:55:14.000000000 +0100
+++ linux-2.6.22-rc3-mm1-004_group_arbitrary/arch/ia64/mm/hugetlbpage.c	2007-06-01 10:16:26.000000000 +0100
@@ -195,6 +195,6 @@ static int __init hugetlb_setup_sz(char 
 	 * override here with new page shift.
 	 */
 	ia64_set_rr(HPAGE_REGION_BASE, hpage_shift << 2);
-	return 1;
+	return 0;
 }
-__setup("hugepagesz=", hugetlb_setup_sz);
+early_param("hugepagesz", hugetlb_setup_sz);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc3-mm1-clean/include/linux/mmzone.h linux-2.6.22-rc3-mm1-004_group_arbitrary/include/linux/mmzone.h
--- linux-2.6.22-rc3-mm1-clean/include/linux/mmzone.h	2007-06-01 09:24:41.000000000 +0100
+++ linux-2.6.22-rc3-mm1-004_group_arbitrary/include/linux/mmzone.h	2007-06-01 10:16:26.000000000 +0100
@@ -238,7 +238,7 @@ struct zone {
 
 #ifndef CONFIG_SPARSEMEM
 	/*
-	 * Flags for a MAX_ORDER_NR_PAGES block. See pageblock-flags.h.
+	 * Flags for a pageblock_nr_pages block. See pageblock-flags.h.
 	 * In SPARSEMEM, this map is stored in struct mem_section
 	 */
 	unsigned long		*pageblock_flags;
@@ -713,7 +713,7 @@ extern struct zone *next_zone(struct zon
 #define PAGE_SECTION_MASK	(~(PAGES_PER_SECTION-1))
 
 #define SECTION_BLOCKFLAGS_BITS \
-		((1 << (PFN_SECTION_SHIFT - (MAX_ORDER-1))) * NR_PAGEBLOCK_BITS)
+	((1UL << (PFN_SECTION_SHIFT - pageblock_order)) * NR_PAGEBLOCK_BITS)
 
 #if (MAX_ORDER - 1 + PAGE_SHIFT) > SECTION_SIZE_BITS
 #error Allocator MAX_ORDER exceeds SECTION_SIZE
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc3-mm1-clean/include/linux/pageblock-flags.h linux-2.6.22-rc3-mm1-004_group_arbitrary/include/linux/pageblock-flags.h
--- linux-2.6.22-rc3-mm1-clean/include/linux/pageblock-flags.h	2007-06-01 09:24:41.000000000 +0100
+++ linux-2.6.22-rc3-mm1-004_group_arbitrary/include/linux/pageblock-flags.h	2007-06-01 10:24:53.000000000 +0100
@@ -1,6 +1,6 @@
 /*
  * Macros for manipulating and testing flags related to a
- * MAX_ORDER_NR_PAGES block of pages.
+ * pageblock_nr_pages number of pages.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -35,6 +35,29 @@ enum pageblock_bits {
 	NR_PAGEBLOCK_BITS
 };
 
+#ifdef CONFIG_HUGETLB_PAGE
+
+#ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
+
+/* Huge page sizes are variable */
+extern int pageblock_order;
+
+#else /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
+
+/* Huge pages are a constant size */
+#define pageblock_order		HUGETLB_PAGE_ORDER
+
+#endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
+
+#else /* CONFIG_HUGETLB_PAGE */
+
+/* If huge pages are not used, group by MAX_ORDER_NR_PAGES */
+#define pageblock_order		(MAX_ORDER-1)
+
+#endif /* CONFIG_HUGETLB_PAGE */
+
+#define pageblock_nr_pages	(1UL << pageblock_order)
+
 /* Forward declaration */
 struct page;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc3-mm1-clean/mm/page_alloc.c linux-2.6.22-rc3-mm1-004_group_arbitrary/mm/page_alloc.c
--- linux-2.6.22-rc3-mm1-clean/mm/page_alloc.c	2007-06-01 09:24:41.000000000 +0100
+++ linux-2.6.22-rc3-mm1-004_group_arbitrary/mm/page_alloc.c	2007-06-01 10:31:18.000000000 +0100
@@ -59,6 +59,10 @@ unsigned long totalreserve_pages __read_
 long nr_swap_pages;
 int percpu_pagelist_fraction;
 
+#ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
+int pageblock_order __read_mostly;
+#endif
+
 static void __free_pages_ok(struct page *page, unsigned int order);
 
 /*
@@ -708,7 +712,7 @@ static int fallbacks[MIGRATE_TYPES][MIGR
 
 /*
  * Move the free pages in a range to the free lists of the requested type.
- * Note that start_page and end_pages are not aligned in a MAX_ORDER_NR_PAGES
+ * Note that start_page and end_pages are not aligned on a pageblock
  * boundary. If alignment is required, use move_freepages_block()
  */
 int move_freepages(struct zone *zone,
@@ -758,10 +762,10 @@ int move_freepages_block(struct zone *zo
 	struct page *start_page, *end_page;
 
 	start_pfn = page_to_pfn(page);
-	start_pfn = start_pfn & ~(MAX_ORDER_NR_PAGES-1);
+	start_pfn = start_pfn & ~(pageblock_nr_pages-1);
 	start_page = pfn_to_page(start_pfn);
-	end_page = start_page + MAX_ORDER_NR_PAGES - 1;
-	end_pfn = start_pfn + MAX_ORDER_NR_PAGES - 1;
+	end_page = start_page + pageblock_nr_pages - 1;
+	end_pfn = start_pfn + pageblock_nr_pages - 1;
 
 	/* Do not cross zone boundaries */
 	if (start_pfn < zone->zone_start_pfn)
@@ -825,14 +829,14 @@ static struct page *__rmqueue_fallback(s
 			 * back for a reclaimable kernel allocation, be more
 			 * agressive about taking ownership of free pages
 			 */
-			if (unlikely(current_order >= MAX_ORDER / 2) ||
+			if (unlikely(current_order >= (pageblock_order >> 1)) ||
 					start_migratetype == MIGRATE_RECLAIMABLE) {
 				unsigned long pages;
 				pages = move_freepages_block(zone, page,
 								start_migratetype);
 
 				/* Claim the whole block if over half of it is free */
-				if (pages >= (1 << (MAX_ORDER-2)))
+				if (pages >= (1 << (pageblock_order-1)))
 					set_pageblock_migratetype(page,
 								start_migratetype);
 
@@ -845,7 +849,7 @@ static struct page *__rmqueue_fallback(s
 			__mod_zone_page_state(zone, NR_FREE_PAGES,
 							-(1UL << order));
 
-			if (current_order == MAX_ORDER - 1)
+			if (current_order == pageblock_order)
 				set_pageblock_migratetype(page,
 							start_migratetype);
 
@@ -2422,7 +2426,7 @@ void build_all_zonelists(void)
 	 * made on memory-hotadd so a system can start with mobility
 	 * disabled and enable it later
 	 */
-	if (vm_total_pages < (MAX_ORDER_NR_PAGES * MIGRATE_TYPES))
+	if (vm_total_pages < (pageblock_nr_pages * MIGRATE_TYPES))
 		page_group_by_mobility_disabled = 1;
 	else
 		page_group_by_mobility_disabled = 0;
@@ -2507,7 +2511,7 @@ static inline unsigned long wait_table_b
 #define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
 
 /*
- * Mark a number of MAX_ORDER_NR_PAGES blocks as MIGRATE_RESERVE. The number
+ * Mark a number of pageblocks as MIGRATE_RESERVE. The number
  * of blocks reserved is based on zone->pages_min. The memory within the
  * reserve will tend to store contiguous free pages. Setting min_free_kbytes
  * higher will lead to a bigger reserve which will get freed as contiguous
@@ -2522,9 +2526,10 @@ static void setup_zone_migrate_reserve(s
 	/* Get the start pfn, end pfn and the number of blocks to reserve */
 	start_pfn = zone->zone_start_pfn;
 	end_pfn = start_pfn + zone->spanned_pages;
-	reserve = roundup(zone->pages_min, MAX_ORDER_NR_PAGES) >> (MAX_ORDER-1);
+	reserve = roundup(zone->pages_min, pageblock_nr_pages) >>
+							pageblock_order;
 
-	for (pfn = start_pfn; pfn < end_pfn; pfn += MAX_ORDER_NR_PAGES) {
+	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
 		if (!pfn_valid(pfn))
 			continue;
 		page = pfn_to_page(pfn);
@@ -2599,7 +2604,7 @@ void __meminit memmap_init_zone(unsigned
 		 * the start are marked MIGRATE_RESERVE by
 		 * setup_zone_migrate_reserve()
 		 */
-		if ((pfn & (MAX_ORDER_NR_PAGES-1)))
+		if ((pfn & (pageblock_nr_pages-1)))
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 
 		INIT_LIST_HEAD(&page->lru);
@@ -3303,8 +3308,8 @@ static void __meminit calculate_node_tot
 #ifndef CONFIG_SPARSEMEM
 /*
  * Calculate the size of the zone->blockflags rounded to an unsigned long
- * Start by making sure zonesize is a multiple of MAX_ORDER-1 by rounding up
- * Then figure 1 NR_PAGEBLOCK_BITS worth of bits per MAX_ORDER-1, finally
+ * Start by making sure zonesize is a multiple of pageblock_order by rounding
+ * up. Then use 1 NR_PAGEBLOCK_BITS worth of bits per pageblock, finally
  * round what is now in bits to nearest long in bits, then return it in
  * bytes.
  */
@@ -3312,8 +3317,8 @@ static unsigned long __init usemap_size(
 {
 	unsigned long usemapsize;
 
-	usemapsize = roundup(zonesize, MAX_ORDER_NR_PAGES);
-	usemapsize = usemapsize >> (MAX_ORDER-1);
+	usemapsize = roundup(zonesize, pageblock_nr_pages);
+	usemapsize = usemapsize >> pageblock_order;
 	usemapsize *= NR_PAGEBLOCK_BITS;
 	usemapsize = roundup(usemapsize, 8 * sizeof(unsigned long));
 
@@ -3335,6 +3340,27 @@ static void inline setup_usemap(struct p
 				struct zone *zone, unsigned long zonesize) {}
 #endif /* CONFIG_SPARSEMEM */
 
+#ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
+/* Initialise the number of pages represented by NR_PAGEBLOCK_BITS */
+static inline void __init set_pageblock_order(unsigned int order)
+{
+	/* Check that pageblock_nr_pages has not already been setup */
+	if (pageblock_order)
+		return;
+
+	/*
+	 * Assume the largest contiguous order of interest is a huge page.
+	 * This value may be variable depending on boot parameters on IA64
+	 */
+	pageblock_order = order;
+}
+#else /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
+
+/* Defined this way to avoid accidently referencing HUGETLB_PAGE_ORDER */
+#define set_pageblock_order(x)	do {} while (0)
+
+#endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
+
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -3415,6 +3440,7 @@ static void __meminit free_area_init_cor
 		if (!size)
 			continue;
 
+		set_pageblock_order(HUGETLB_PAGE_ORDER);
 		setup_usemap(pgdat, zone, size);
 		ret = init_currently_empty_zone(zone, zone_start_pfn,
 						size, MEMMAP_EARLY);
@@ -4341,15 +4367,15 @@ static inline int pfn_to_bitidx(struct z
 {
 #ifdef CONFIG_SPARSEMEM
 	pfn &= (PAGES_PER_SECTION-1);
-	return (pfn >> (MAX_ORDER-1)) * NR_PAGEBLOCK_BITS;
+	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
 #else
 	pfn = pfn - zone->zone_start_pfn;
-	return (pfn >> (MAX_ORDER-1)) * NR_PAGEBLOCK_BITS;
+	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
 #endif /* CONFIG_SPARSEMEM */
 }
 
 /**
- * get_pageblock_flags_group - Return the requested group of flags for the MAX_ORDER_NR_PAGES block of pages
+ * get_pageblock_flags_group - Return the requested group of flags for the pageblock_nr_pages block of pages
  * @page: The page within the block of interest
  * @start_bitidx: The first bit of interest to retrieve
  * @end_bitidx: The last bit of interest
@@ -4377,7 +4403,7 @@ unsigned long get_pageblock_flags_group(
 }
 
 /**
- * set_pageblock_flags_group - Set the requested group of flags for a MAX_ORDER_NR_PAGES block of pages
+ * set_pageblock_flags_group - Set the requested group of flags for a pageblock_nr_pages block of pages
  * @page: The page within the block of interest
  * @start_bitidx: The first bit of interest
  * @end_bitidx: The last bit of interest

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
