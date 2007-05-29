From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070529173629.1570.71378.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
References: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/7] Roll-up patch of what has been sent already
Date: Tue, 29 May 2007 18:36:29 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This contains some bug fixes including one to PAGE_OWNER, grouping by
arbitrary order, statistics work. The patches have been sent piecemeal
to linux-mm already so the are not broken-out here. At time of sending
the patches have not been merged to -mm so I am including them here for
convenience.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 Documentation/page_owner.c      |    3 
 arch/ia64/Kconfig               |    5 
 arch/ia64/mm/hugetlbpage.c      |    4 
 fs/proc/proc_misc.c             |   50 ++++
 include/linux/gfp.h             |   12 +
 include/linux/mmzone.h          |   14 +
 include/linux/pageblock-flags.h |   24 ++
 mm/internal.h                   |   10 
 mm/page_alloc.c                 |  108 ++++------
 mm/vmstat.c                     |  377 +++++++++++++++++++++++++++--------
 10 files changed, 465 insertions(+), 142 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-clean/arch/ia64/Kconfig linux-2.6.22-rc2-mm1-001_lameter-v4r4/arch/ia64/Kconfig
--- linux-2.6.22-rc2-mm1-clean/arch/ia64/Kconfig	2007-05-24 10:13:32.000000000 +0100
+++ linux-2.6.22-rc2-mm1-001_lameter-v4r4/arch/ia64/Kconfig	2007-05-28 14:09:40.000000000 +0100
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
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-clean/arch/ia64/mm/hugetlbpage.c linux-2.6.22-rc2-mm1-001_lameter-v4r4/arch/ia64/mm/hugetlbpage.c
--- linux-2.6.22-rc2-mm1-clean/arch/ia64/mm/hugetlbpage.c	2007-05-19 05:06:17.000000000 +0100
+++ linux-2.6.22-rc2-mm1-001_lameter-v4r4/arch/ia64/mm/hugetlbpage.c	2007-05-28 14:09:40.000000000 +0100
@@ -195,6 +195,6 @@ static int __init hugetlb_setup_sz(char 
 	 * override here with new page shift.
 	 */
 	ia64_set_rr(HPAGE_REGION_BASE, hpage_shift << 2);
-	return 1;
+	return 0;
 }
-__setup("hugepagesz=", hugetlb_setup_sz);
+early_param("hugepagesz", hugetlb_setup_sz);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-clean/Documentation/page_owner.c linux-2.6.22-rc2-mm1-001_lameter-v4r4/Documentation/page_owner.c
--- linux-2.6.22-rc2-mm1-clean/Documentation/page_owner.c	2007-05-24 10:13:32.000000000 +0100
+++ linux-2.6.22-rc2-mm1-001_lameter-v4r4/Documentation/page_owner.c	2007-05-28 14:09:40.000000000 +0100
@@ -2,7 +2,8 @@
  * User-space helper to sort the output of /proc/page_owner
  *
  * Example use:
- * cat /proc/page_owner > page_owner.txt
+ * cat /proc/page_owner > page_owner_full.txt
+ * grep -v ^PFN page_owner_full.txt > page_owner.txt
  * ./sort page_owner.txt sorted_page_owner.txt
 */
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-clean/fs/proc/proc_misc.c linux-2.6.22-rc2-mm1-001_lameter-v4r4/fs/proc/proc_misc.c
--- linux-2.6.22-rc2-mm1-clean/fs/proc/proc_misc.c	2007-05-24 10:13:33.000000000 +0100
+++ linux-2.6.22-rc2-mm1-001_lameter-v4r4/fs/proc/proc_misc.c	2007-05-28 14:09:40.000000000 +0100
@@ -232,6 +232,19 @@ static const struct file_operations frag
 	.release	= seq_release,
 };
 
+extern struct seq_operations pagetypeinfo_op;
+static int pagetypeinfo_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &pagetypeinfo_op);
+}
+
+static const struct file_operations pagetypeinfo_file_ops = {
+	.open		= pagetypeinfo_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 extern struct seq_operations zoneinfo_op;
 static int zoneinfo_open(struct inode *inode, struct file *file)
 {
@@ -748,6 +761,7 @@ read_page_owner(struct file *file, char 
 	unsigned long offset = 0, symsize;
 	int i;
 	ssize_t num_written = 0;
+	int blocktype = 0, pagetype = 0;
 
 	pfn = min_low_pfn + *ppos;
 	page = pfn_to_page(pfn);
@@ -755,8 +769,16 @@ read_page_owner(struct file *file, char 
 		if (!pfn_valid(pfn))
 			continue;
 		page = pfn_to_page(pfn);
+
+		/* Catch situations where free pages have a bad ->order  */
+		if (page->order >= 0 && PageBuddy(page))
+			printk(KERN_WARNING
+				"PageOwner info inaccurate for PFN %lu\n",
+				pfn);
+
 		if (page->order >= 0)
 			break;
+
 		next_idx++;
 	}
 
@@ -776,6 +798,33 @@ read_page_owner(struct file *file, char 
 		goto out;
 	}
 
+	/* Print information relevant to grouping pages by mobility */
+	blocktype = get_pageblock_migratetype(page);
+	pagetype  = allocflags_to_migratetype(page->gfp_mask);
+	ret += snprintf(kbuf+ret, count-ret,
+			"PFN %lu Block %lu type %d %s "
+			"Flags %s%s%s%s%s%s%s%s%s%s%s%s\n",
+			pfn,
+			pfn >> pageblock_order,
+			blocktype,
+			blocktype != pagetype ? "Fallback" : "        ",
+			PageLocked(page)	? "K" : " ",
+			PageError(page)		? "E" : " ",
+			PageReferenced(page)	? "R" : " ",
+			PageUptodate(page)	? "U" : " ",
+			PageDirty(page)		? "D" : " ",
+			PageLRU(page)		? "L" : " ",
+			PageActive(page)	? "A" : " ",
+			PageSlab(page)		? "S" : " ",
+			PageWriteback(page)	? "W" : " ",
+			PageCompound(page)	? "C" : " ",
+			PageSwapCache(page)	? "B" : " ",
+			PageMappedToDisk(page)	? "M" : " ");
+	if (ret >= count) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
 	num_written = ret;
 
 	for (i = 0; i < 8; i++) {
@@ -874,6 +923,7 @@ void __init proc_misc_init(void)
 #endif
 #endif
 	create_seq_entry("buddyinfo",S_IRUGO, &fragmentation_file_operations);
+	create_seq_entry("pagetypeinfo", S_IRUGO, &pagetypeinfo_file_ops);
 	create_seq_entry("vmstat",S_IRUGO, &proc_vmstat_file_operations);
 	create_seq_entry("zoneinfo",S_IRUGO, &proc_zoneinfo_file_operations);
 #ifdef CONFIG_BLOCK
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-clean/include/linux/gfp.h linux-2.6.22-rc2-mm1-001_lameter-v4r4/include/linux/gfp.h
--- linux-2.6.22-rc2-mm1-clean/include/linux/gfp.h	2007-05-24 10:13:34.000000000 +0100
+++ linux-2.6.22-rc2-mm1-001_lameter-v4r4/include/linux/gfp.h	2007-05-28 14:09:40.000000000 +0100
@@ -101,6 +101,18 @@ struct vm_area_struct;
 /* 4GB DMA on some platforms */
 #define GFP_DMA32	__GFP_DMA32
 
+/* Convert GFP flags to their corresponding migrate type */
+static inline int allocflags_to_migratetype(gfp_t gfp_flags)
+{
+	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
+
+	if (unlikely(page_group_by_mobility_disabled))
+		return MIGRATE_UNMOVABLE;
+
+	/* Group based on mobility */
+	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
+		((gfp_flags & __GFP_RECLAIMABLE) != 0);
+}
 
 static inline enum zone_type gfp_zone(gfp_t flags)
 {
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-clean/include/linux/mmzone.h linux-2.6.22-rc2-mm1-001_lameter-v4r4/include/linux/mmzone.h
--- linux-2.6.22-rc2-mm1-clean/include/linux/mmzone.h	2007-05-24 10:13:34.000000000 +0100
+++ linux-2.6.22-rc2-mm1-001_lameter-v4r4/include/linux/mmzone.h	2007-05-28 14:09:40.000000000 +0100
@@ -45,6 +45,16 @@ extern int page_group_by_mobility_disabl
 	for (order = 0; order < MAX_ORDER; order++) \
 		for (type = 0; type < MIGRATE_TYPES; type++)
 
+extern int page_group_by_mobility_disabled;
+
+static inline int get_pageblock_migratetype(struct page *page)
+{
+	if (unlikely(page_group_by_mobility_disabled))
+		return MIGRATE_UNMOVABLE;
+
+	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
+}
+
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free;
@@ -238,7 +248,7 @@ struct zone {
 
 #ifndef CONFIG_SPARSEMEM
 	/*
-	 * Flags for a MAX_ORDER_NR_PAGES block. See pageblock-flags.h.
+	 * Flags for a pageblock_nr_pages block. See pageblock-flags.h.
 	 * In SPARSEMEM, this map is stored in struct mem_section
 	 */
 	unsigned long		*pageblock_flags;
@@ -713,7 +723,7 @@ extern struct zone *next_zone(struct zon
 #define PAGE_SECTION_MASK	(~(PAGES_PER_SECTION-1))
 
 #define SECTION_BLOCKFLAGS_BITS \
-		((1 << (PFN_SECTION_SHIFT - (MAX_ORDER-1))) * NR_PAGEBLOCK_BITS)
+	((1UL << (PFN_SECTION_SHIFT - pageblock_order)) * NR_PAGEBLOCK_BITS)
 
 #if (MAX_ORDER - 1 + PAGE_SHIFT) > SECTION_SIZE_BITS
 #error Allocator MAX_ORDER exceeds SECTION_SIZE
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-clean/include/linux/pageblock-flags.h linux-2.6.22-rc2-mm1-001_lameter-v4r4/include/linux/pageblock-flags.h
--- linux-2.6.22-rc2-mm1-clean/include/linux/pageblock-flags.h	2007-05-24 10:13:34.000000000 +0100
+++ linux-2.6.22-rc2-mm1-001_lameter-v4r4/include/linux/pageblock-flags.h	2007-05-28 14:09:40.000000000 +0100
@@ -1,6 +1,6 @@
 /*
  * Macros for manipulating and testing flags related to a
- * MAX_ORDER_NR_PAGES block of pages.
+ * pageblock_nr_pages number of pages.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -35,6 +35,28 @@ enum pageblock_bits {
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
+#endif /* CONFIG_HUGETLB_PAGE */
+
+#define pageblock_nr_pages	(1UL << pageblock_order)
+
 /* Forward declaration */
 struct page;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-clean/mm/internal.h linux-2.6.22-rc2-mm1-001_lameter-v4r4/mm/internal.h
--- linux-2.6.22-rc2-mm1-clean/mm/internal.h	2007-05-19 05:06:17.000000000 +0100
+++ linux-2.6.22-rc2-mm1-001_lameter-v4r4/mm/internal.h	2007-05-28 14:09:40.000000000 +0100
@@ -37,4 +37,14 @@ static inline void __put_page(struct pag
 extern void fastcall __init __free_pages_bootmem(struct page *page,
 						unsigned int order);
 
+/*
+ * function for dealing with page's order in buddy system.
+ * zone->lock is already acquired when we use these.
+ * So, we don't need atomic page->flags operations here.
+ */
+static inline unsigned long page_order(struct page *page)
+{
+	VM_BUG_ON(!PageBuddy(page));
+	return page_private(page);
+}
 #endif
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-clean/mm/page_alloc.c linux-2.6.22-rc2-mm1-001_lameter-v4r4/mm/page_alloc.c
--- linux-2.6.22-rc2-mm1-clean/mm/page_alloc.c	2007-05-24 10:13:34.000000000 +0100
+++ linux-2.6.22-rc2-mm1-001_lameter-v4r4/mm/page_alloc.c	2007-05-28 14:09:40.000000000 +0100
@@ -59,6 +59,10 @@ unsigned long totalreserve_pages __read_
 long nr_swap_pages;
 int percpu_pagelist_fraction;
 
+#ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
+int pageblock_order __read_mostly;
+#endif
+
 static void __free_pages_ok(struct page *page, unsigned int order);
 
 /*
@@ -151,32 +155,12 @@ EXPORT_SYMBOL(nr_node_ids);
 
 int page_group_by_mobility_disabled __read_mostly;
 
-static inline int get_pageblock_migratetype(struct page *page)
-{
-	if (unlikely(page_group_by_mobility_disabled))
-		return MIGRATE_UNMOVABLE;
-
-	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
-}
-
 static void set_pageblock_migratetype(struct page *page, int migratetype)
 {
 	set_pageblock_flags_group(page, (unsigned long)migratetype,
 					PB_migrate, PB_migrate_end);
 }
 
-static inline int allocflags_to_migratetype(gfp_t gfp_flags)
-{
-	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
-
-	if (unlikely(page_group_by_mobility_disabled))
-		return MIGRATE_UNMOVABLE;
-
-	/* Cluster based on mobility */
-	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
-		((gfp_flags & __GFP_RECLAIMABLE) != 0);
-}
-
 #ifdef CONFIG_DEBUG_VM
 static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 {
@@ -336,20 +320,13 @@ static inline void prep_zero_page(struct
 		clear_highpage(page + i);
 }
 
-/*
- * function for dealing with page's order in buddy system.
- * zone->lock is already acquired when we use these.
- * So, we don't need atomic page->flags operations here.
- */
-static inline unsigned long page_order(struct page *page)
-{
-	return page_private(page);
-}
-
 static inline void set_page_order(struct page *page, int order)
 {
 	set_page_private(page, order);
 	__SetPageBuddy(page);
+#ifdef CONFIG_PAGE_OWNER
+		page->order = -1;
+#endif
 }
 
 static inline void rmv_page_order(struct page *page)
@@ -719,7 +696,7 @@ static int fallbacks[MIGRATE_TYPES][MIGR
 
 /*
  * Move the free pages in a range to the free lists of the requested type.
- * Note that start_page and end_pages are not aligned in a MAX_ORDER_NR_PAGES
+ * Note that start_page and end_pages are not aligned on a pageblock
  * boundary. If alignment is required, use move_freepages_block()
  */
 int move_freepages(struct zone *zone,
@@ -728,7 +705,7 @@ int move_freepages(struct zone *zone,
 {
 	struct page *page;
 	unsigned long order;
-	int blocks_moved = 0;
+	int pages_moved = 0;
 
 #ifndef CONFIG_HOLES_IN_ZONE
 	/*
@@ -757,10 +734,10 @@ int move_freepages(struct zone *zone,
 		list_add(&page->lru,
 			&zone->free_area[order].free_list[migratetype]);
 		page += 1 << order;
-		blocks_moved++;
+		pages_moved += 1 << order;
 	}
 
-	return blocks_moved;
+	return pages_moved;
 }
 
 int move_freepages_block(struct zone *zone, struct page *page, int migratetype)
@@ -769,10 +746,10 @@ int move_freepages_block(struct zone *zo
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
@@ -836,14 +813,14 @@ static struct page *__rmqueue_fallback(s
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
-				if ((pages << current_order) >= (1 << (MAX_ORDER-2)))
+				if (pages >= (1 << (pageblock_order-1)))
 					set_pageblock_migratetype(page,
 								start_migratetype);
 
@@ -856,7 +833,7 @@ static struct page *__rmqueue_fallback(s
 			__mod_zone_page_state(zone, NR_FREE_PAGES,
 							-(1UL << order));
 
-			if (current_order == MAX_ORDER - 1)
+			if (current_order == pageblock_order)
 				set_pageblock_migratetype(page,
 							start_migratetype);
 
@@ -1771,9 +1748,6 @@ fastcall void __free_pages(struct page *
 			free_hot_page(page);
 		else
 			__free_pages_ok(page, order);
-#ifdef CONFIG_PAGE_OWNER
-		page->order = -1;
-#endif
 	}
 }
 
@@ -2426,7 +2400,7 @@ void build_all_zonelists(void)
 	 * made on memory-hotadd so a system can start with mobility
 	 * disabled and enable it later
 	 */
-	if (vm_total_pages < (MAX_ORDER_NR_PAGES * MIGRATE_TYPES))
+	if (vm_total_pages < (pageblock_nr_pages * MIGRATE_TYPES))
 		page_group_by_mobility_disabled = 1;
 	else
 		page_group_by_mobility_disabled = 0;
@@ -2511,7 +2485,7 @@ static inline unsigned long wait_table_b
 #define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
 
 /*
- * Mark a number of MAX_ORDER_NR_PAGES blocks as MIGRATE_RESERVE. The number
+ * Mark a number of pageblocks as MIGRATE_RESERVE. The number
  * of blocks reserved is based on zone->pages_min. The memory within the
  * reserve will tend to store contiguous free pages. Setting min_free_kbytes
  * higher will lead to a bigger reserve which will get freed as contiguous
@@ -2526,9 +2500,10 @@ static void setup_zone_migrate_reserve(s
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
@@ -2603,7 +2578,7 @@ void __meminit memmap_init_zone(unsigned
 		 * the start are marked MIGRATE_RESERVE by
 		 * setup_zone_migrate_reserve()
 		 */
-		if ((pfn & (MAX_ORDER_NR_PAGES-1)))
+		if ((pfn & (pageblock_nr_pages-1)))
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 
 		INIT_LIST_HEAD(&page->lru);
@@ -3307,8 +3282,8 @@ static void __meminit calculate_node_tot
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
@@ -3316,8 +3291,8 @@ static unsigned long __init usemap_size(
 {
 	unsigned long usemapsize;
 
-	usemapsize = roundup(zonesize, MAX_ORDER_NR_PAGES);
-	usemapsize = usemapsize >> (MAX_ORDER-1);
+	usemapsize = roundup(zonesize, pageblock_nr_pages);
+	usemapsize = usemapsize >> pageblock_order;
 	usemapsize *= NR_PAGEBLOCK_BITS;
 	usemapsize = roundup(usemapsize, 8 * sizeof(unsigned long));
 
@@ -3339,6 +3314,26 @@ static void inline setup_usemap(struct p
 				struct zone *zone, unsigned long zonesize) {}
 #endif /* CONFIG_SPARSEMEM */
 
+#ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
+/* Initialise the number of pages represented by NR_PAGEBLOCK_BITS */
+void __init set_pageblock_order(unsigned int order)
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
+void __init set_pageblock_order(unsigned int order)
+{
+}
+#endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
+
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -3419,6 +3414,7 @@ static void __meminit free_area_init_cor
 		if (!size)
 			continue;
 
+		set_pageblock_order(HUGETLB_PAGE_ORDER);
 		setup_usemap(pgdat, zone, size);
 		ret = init_currently_empty_zone(zone, zone_start_pfn,
 						size, MEMMAP_EARLY);
@@ -4345,15 +4341,15 @@ static inline int pfn_to_bitidx(struct z
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
@@ -4381,7 +4377,7 @@ unsigned long get_pageblock_flags_group(
 }
 
 /**
- * set_pageblock_flags_group - Set the requested group of flags for a MAX_ORDER_NR_PAGES block of pages
+ * set_pageblock_flags_group - Set the requested group of flags for a pageblock_nr_pages block of pages
  * @page: The page within the block of interest
  * @start_bitidx: The first bit of interest
  * @end_bitidx: The last bit of interest
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-clean/mm/vmstat.c linux-2.6.22-rc2-mm1-001_lameter-v4r4/mm/vmstat.c
--- linux-2.6.22-rc2-mm1-clean/mm/vmstat.c	2007-05-24 10:13:34.000000000 +0100
+++ linux-2.6.22-rc2-mm1-001_lameter-v4r4/mm/vmstat.c	2007-05-28 14:09:40.000000000 +0100
@@ -13,6 +13,7 @@
 #include <linux/module.h>
 #include <linux/cpu.h>
 #include <linux/sched.h>
+#include "internal.h"
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
@@ -397,6 +398,13 @@ void zone_statistics(struct zonelist *zo
 
 #include <linux/seq_file.h>
 
+static char * const migratetype_names[MIGRATE_TYPES] = {
+	"Unmovable",
+	"Reclaimable",
+	"Movable",
+	"Reserve",
+};
+
 static void *frag_start(struct seq_file *m, loff_t *pos)
 {
 	pg_data_t *pgdat;
@@ -421,28 +429,236 @@ static void frag_stop(struct seq_file *m
 {
 }
 
-/*
- * This walks the free areas for each zone.
- */
-static int frag_show(struct seq_file *m, void *arg)
+/* Walk all the zones in a node and print using a callback */
+static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
+		void (*print)(struct seq_file *m, pg_data_t *, struct zone *))
 {
-	pg_data_t *pgdat = (pg_data_t *)arg;
 	struct zone *zone;
 	struct zone *node_zones = pgdat->node_zones;
 	unsigned long flags;
-	int order;
 
 	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
 		if (!populated_zone(zone))
 			continue;
 
 		spin_lock_irqsave(&zone->lock, flags);
-		seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
-		for (order = 0; order < MAX_ORDER; ++order)
-			seq_printf(m, "%6lu ", zone->free_area[order].nr_free);
+		print(m, pgdat, zone);
 		spin_unlock_irqrestore(&zone->lock, flags);
+	}
+}
+
+static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
+						struct zone *zone)
+{
+	int order;
+
+	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+	for (order = 0; order < MAX_ORDER; ++order)
+		seq_printf(m, "%6lu ", zone->free_area[order].nr_free);
+	seq_putc(m, '\n');
+}
+
+/*
+ * This walks the free areas for each zone.
+ */
+static int frag_show(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+	walk_zones_in_node(m, pgdat, frag_show_print);
+	return 0;
+}
+
+static void pagetypeinfo_showfree_print(struct seq_file *m,
+					pg_data_t *pgdat, struct zone *zone)
+{
+	int order, mtype;
+
+	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++) {
+		seq_printf(m, "Node %4d, zone %8s, type %12s ",
+					pgdat->node_id,
+					zone->name,
+					migratetype_names[mtype]);
+		for (order = 0; order < MAX_ORDER; ++order) {
+			unsigned long freecount = 0;
+			struct free_area *area;
+			struct list_head *curr;
+
+			area = &(zone->free_area[order]);
+
+			list_for_each(curr, &area->free_list[mtype])
+				freecount++;
+			seq_printf(m, "%6lu ", freecount);
+		}
 		seq_putc(m, '\n');
 	}
+}
+
+/* Print out the free pages at each order for each migatetype */
+static int pagetypeinfo_showfree(struct seq_file *m, void *arg)
+{
+	int order;
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	/* Print header */
+	seq_printf(m, "%-43s ", "Free pages count per migrate type at order");
+	for (order = 0; order < MAX_ORDER; ++order)
+		seq_printf(m, "%6d ", order);
+	seq_putc(m, '\n');
+
+	walk_zones_in_node(m, pgdat, pagetypeinfo_showfree_print);
+
+	return 0;
+}
+
+static void pagetypeinfo_showblockcount_print(struct seq_file *m,
+					pg_data_t *pgdat, struct zone *zone)
+{
+	int mtype;
+	unsigned long pfn;
+	unsigned long start_pfn = zone->zone_start_pfn;
+	unsigned long end_pfn = start_pfn + zone->spanned_pages;
+	unsigned long count[MIGRATE_TYPES] = { 0, };
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
+		struct page *page;
+
+		if (!pfn_valid(pfn))
+			continue;
+
+		page = pfn_to_page(pfn);
+		mtype = get_pageblock_migratetype(page);
+
+		count[mtype]++;
+	}
+
+	/* Print counts */
+	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
+		seq_printf(m, "%12lu ", count[mtype]);
+	seq_putc(m, '\n');
+}
+
+/* Print out the free pages at each order for each migratetype */
+static int pagetypeinfo_showblockcount(struct seq_file *m, void *arg)
+{
+	int mtype;
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	seq_printf(m, "\n%-23s", "Number of blocks type ");
+	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
+		seq_printf(m, "%12s ", migratetype_names[mtype]);
+	seq_putc(m, '\n');
+	walk_zones_in_node(m, pgdat, pagetypeinfo_showblockcount_print);
+
+	return 0;
+}
+
+#ifdef CONFIG_PAGE_OWNER
+static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
+							pg_data_t *pgdat,
+							struct zone *zone)
+{
+	int mtype, pagetype;
+	unsigned long pfn;
+	unsigned long start_pfn = zone->zone_start_pfn;
+	unsigned long end_pfn = start_pfn + zone->spanned_pages;
+	unsigned long count[MIGRATE_TYPES] = { 0, };
+
+	/* Align PFNs to pageblock_nr_pages boundary */
+	pfn = start_pfn & ~(pageblock_nr_pages-1);
+
+	/*
+	 * Walk the zone in pageblock_nr_pages steps. If a page block spans
+	 * a zone boundary, it will be double counted between zones. This does
+	 * not matter as the mixed block count will still be correct
+	 */
+	for (; pfn < end_pfn; pfn += pageblock_nr_pages) {
+		struct page *page;
+		unsigned long offset = 0;
+
+		/* Do not read before the zone start, use a valid page */
+		if (pfn < start_pfn)
+			offset = start_pfn - pfn;
+
+		if (!pfn_valid(pfn + offset))
+			continue;
+
+		page = pfn_to_page(pfn + offset);
+		mtype = get_pageblock_migratetype(page);
+
+		/* Check the block for bad migrate types */
+		for (; offset < pageblock_nr_pages; offset++) {
+			/* Do not past the end of the zone */
+			if (pfn + offset >= end_pfn)
+				break;
+
+			if (!pfn_valid_within(pfn + offset))
+				continue;
+
+			page = pfn_to_page(pfn + offset);
+
+			/* Skip free pages */
+			if (PageBuddy(page)) {
+				offset += (1UL << page_order(page)) - 1UL;
+				continue;
+			}
+			if (page->order < 0)
+				continue;
+
+			pagetype = allocflags_to_migratetype(page->gfp_mask);
+			if (pagetype != mtype) {
+				count[mtype]++;
+				break;
+			}
+
+			/* Move to end of this allocation */
+			offset += (1 << page->order) - 1;
+		}
+	}
+
+	/* Print counts */
+	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
+		seq_printf(m, "%12lu ", count[mtype]);
+	seq_putc(m, '\n');
+}
+#endif /* CONFIG_PAGE_OWNER */
+
+/*
+ * Print out the number of pageblocks for each migratetype that contain pages
+ * of other types. This gives an indication of how well fallbacks are being
+ * contained by rmqueue_fallback(). It requires information from PAGE_OWNER
+ * to determine what is going on
+ */
+static void pagetypeinfo_showmixedcount(struct seq_file *m, pg_data_t *pgdat)
+{
+#ifdef CONFIG_PAGE_OWNER
+	int mtype;
+
+	seq_printf(m, "\n%-23s", "Number of mixed blocks ");
+	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
+		seq_printf(m, "%12s ", migratetype_names[mtype]);
+	seq_putc(m, '\n');
+
+	walk_zones_in_node(m, pgdat, pagetypeinfo_showmixedcount_print);
+#endif /* CONFIG_PAGE_OWNER */
+}
+
+/*
+ * This prints out statistics in relation to grouping pages by mobility.
+ * It is expensive to collect so do not constantly read the file.
+ */
+static int pagetypeinfo_show(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	seq_printf(m, "Page block order: %d\n", pageblock_order);
+	seq_printf(m, "Pages per block:  %lu\n", pageblock_nr_pages);
+	seq_putc(m, '\n');
+	pagetypeinfo_showfree(m, pgdat);
+	pagetypeinfo_showblockcount(m, pgdat);
+	pagetypeinfo_showmixedcount(m, pgdat);
+
 	return 0;
 }
 
@@ -453,6 +669,13 @@ const struct seq_operations fragmentatio
 	.show	= frag_show,
 };
 
+const struct seq_operations pagetypeinfo_op = {
+	.start	= frag_start,
+	.next	= frag_next,
+	.stop	= frag_stop,
+	.show	= pagetypeinfo_show,
+};
+
 #ifdef CONFIG_ZONE_DMA
 #define TEXT_FOR_DMA(xx) xx "_dma",
 #else
@@ -531,84 +754,78 @@ static const char * const vmstat_text[] 
 #endif
 };
 
-/*
- * Output information about zones in @pgdat.
- */
-static int zoneinfo_show(struct seq_file *m, void *arg)
+static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
+							struct zone *zone)
 {
-	pg_data_t *pgdat = arg;
-	struct zone *zone;
-	struct zone *node_zones = pgdat->node_zones;
-	unsigned long flags;
-
-	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; zone++) {
-		int i;
-
-		if (!populated_zone(zone))
-			continue;
-
-		spin_lock_irqsave(&zone->lock, flags);
-		seq_printf(m, "Node %d, zone %8s", pgdat->node_id, zone->name);
-		seq_printf(m,
-			   "\n  pages free     %lu"
-			   "\n        min      %lu"
-			   "\n        low      %lu"
-			   "\n        high     %lu"
-			   "\n        scanned  %lu (a: %lu i: %lu)"
-			   "\n        spanned  %lu"
-			   "\n        present  %lu",
-			   zone_page_state(zone, NR_FREE_PAGES),
-			   zone->pages_min,
-			   zone->pages_low,
-			   zone->pages_high,
-			   zone->pages_scanned,
-			   zone->nr_scan_active, zone->nr_scan_inactive,
-			   zone->spanned_pages,
-			   zone->present_pages);
+	int i;
+	seq_printf(m, "Node %d, zone %8s", pgdat->node_id, zone->name);
+	seq_printf(m,
+		   "\n  pages free     %lu"
+		   "\n        min      %lu"
+		   "\n        low      %lu"
+		   "\n        high     %lu"
+		   "\n        scanned  %lu (a: %lu i: %lu)"
+		   "\n        spanned  %lu"
+		   "\n        present  %lu",
+		   zone_page_state(zone, NR_FREE_PAGES),
+		   zone->pages_min,
+		   zone->pages_low,
+		   zone->pages_high,
+		   zone->pages_scanned,
+		   zone->nr_scan_active, zone->nr_scan_inactive,
+		   zone->spanned_pages,
+		   zone->present_pages);
 
-		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-			seq_printf(m, "\n    %-12s %lu", vmstat_text[i],
-					zone_page_state(zone, i));
+	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
+		seq_printf(m, "\n    %-12s %lu", vmstat_text[i],
+				zone_page_state(zone, i));
 
-		seq_printf(m,
-			   "\n        protection: (%lu",
-			   zone->lowmem_reserve[0]);
-		for (i = 1; i < ARRAY_SIZE(zone->lowmem_reserve); i++)
-			seq_printf(m, ", %lu", zone->lowmem_reserve[i]);
-		seq_printf(m,
-			   ")"
-			   "\n  pagesets");
-		for_each_online_cpu(i) {
-			struct per_cpu_pageset *pageset;
-			int j;
-
-			pageset = zone_pcp(zone, i);
-			for (j = 0; j < ARRAY_SIZE(pageset->pcp); j++) {
-				seq_printf(m,
-					   "\n    cpu: %i pcp: %i"
-					   "\n              count: %i"
-					   "\n              high:  %i"
-					   "\n              batch: %i",
-					   i, j,
-					   pageset->pcp[j].count,
-					   pageset->pcp[j].high,
-					   pageset->pcp[j].batch);
+	seq_printf(m,
+		   "\n        protection: (%lu",
+		   zone->lowmem_reserve[0]);
+	for (i = 1; i < ARRAY_SIZE(zone->lowmem_reserve); i++)
+		seq_printf(m, ", %lu", zone->lowmem_reserve[i]);
+	seq_printf(m,
+		   ")"
+		   "\n  pagesets");
+	for_each_online_cpu(i) {
+		struct per_cpu_pageset *pageset;
+		int j;
+
+		pageset = zone_pcp(zone, i);
+		for (j = 0; j < ARRAY_SIZE(pageset->pcp); j++) {
+			seq_printf(m,
+				   "\n    cpu: %i pcp: %i"
+				   "\n              count: %i"
+				   "\n              high:  %i"
+				   "\n              batch: %i",
+				   i, j,
+				   pageset->pcp[j].count,
+				   pageset->pcp[j].high,
+				   pageset->pcp[j].batch);
 			}
 #ifdef CONFIG_SMP
-			seq_printf(m, "\n  vm stats threshold: %d",
-					pageset->stat_threshold);
+		seq_printf(m, "\n  vm stats threshold: %d",
+				pageset->stat_threshold);
 #endif
-		}
-		seq_printf(m,
-			   "\n  all_unreclaimable: %u"
-			   "\n  prev_priority:     %i"
-			   "\n  start_pfn:         %lu",
-			   zone->all_unreclaimable,
-			   zone->prev_priority,
-			   zone->zone_start_pfn);
-		spin_unlock_irqrestore(&zone->lock, flags);
-		seq_putc(m, '\n');
 	}
+	seq_printf(m,
+		   "\n  all_unreclaimable: %u"
+		   "\n  prev_priority:     %i"
+		   "\n  start_pfn:         %lu",
+		   zone->all_unreclaimable,
+		   zone->prev_priority,
+		   zone->zone_start_pfn);
+	seq_putc(m, '\n');
+}
+
+/*
+ * Output information about zones in @pgdat.
+ */
+static int zoneinfo_show(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+	walk_zones_in_node(m, pgdat, zoneinfo_show_print);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
