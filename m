From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070910112051.3097.67091.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
References: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/13] Add a bitmap that is used to track flags affecting a block of pages
Date: Mon, 10 Sep 2007 12:20:51 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Subject: Add a bitmap that is used to track flags affecting a block of pages
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The grouping pages by mobility patchset needs to track if pages within a block
can be moved or reclaimed so that pages are freed to the appropriate list.
This patch adds a bitmap for flags affecting a whole a pageblock_nr_pages
block of pages.

In non-SPARSEMEM configurations, the bitmap is stored in the struct zone
and allocated during initialisation.  SPARSEMEM dynamically allocates the
bitmap in a struct mem_section as required.

Additional credit to Andy Whitcroft who reviewed up an earlier implementation
of the mechanism an suggested how to make it a *lot* cleaner.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Cc: Andy Whitcroft <apw@shadowen.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mmzone.h          |   13 +++
 include/linux/pageblock-flags.h |   74 ++++++++++++++++++
 mm/page_alloc.c                 |  137 +++++++++++++++++++++++++++++++++++
 3 files changed, 224 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-001-ia64-parse-kernel-parameter-hugepagesz=-in-early-boot/include/linux/mmzone.h linux-2.6.23-rc5-002-add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages/include/linux/mmzone.h
--- linux-2.6.23-rc5-001-ia64-parse-kernel-parameter-hugepagesz=-in-early-boot/include/linux/mmzone.h	2007-09-02 16:18:27.000000000 +0100
+++ linux-2.6.23-rc5-002-add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages/include/linux/mmzone.h	2007-09-02 16:19:05.000000000 +0100
@@ -13,6 +13,7 @@
 #include <linux/init.h>
 #include <linux/seqlock.h>
 #include <linux/nodemask.h>
+#include <linux/pageblock-flags.h>
 #include <asm/atomic.h>
 #include <asm/page.h>
 
@@ -222,6 +223,14 @@ struct zone {
 #endif
 	struct free_area	free_area[MAX_ORDER];
 
+#ifndef CONFIG_SPARSEMEM
+	/*
+	 * Flags for a pageblock_nr_pages block. See pageblock-flags.h.
+	 * In SPARSEMEM, this map is stored in struct mem_section
+	 */
+	unsigned long		*pageblock_flags;
+#endif /* CONFIG_SPARSEMEM */
+
 
 	ZONE_PADDING(_pad1_)
 
@@ -708,6 +717,9 @@ extern struct zone *next_zone(struct zon
 #define PAGES_PER_SECTION       (1UL << PFN_SECTION_SHIFT)
 #define PAGE_SECTION_MASK	(~(PAGES_PER_SECTION-1))
 
+#define SECTION_BLOCKFLAGS_BITS \
+	((1UL << (PFN_SECTION_SHIFT - pageblock_order)) * NR_PAGEBLOCK_BITS)
+
 #if (MAX_ORDER - 1 + PAGE_SHIFT) > SECTION_SIZE_BITS
 #error Allocator MAX_ORDER exceeds SECTION_SIZE
 #endif
@@ -727,6 +739,7 @@ struct mem_section {
 	 * before using it wrong.
 	 */
 	unsigned long section_mem_map;
+	DECLARE_BITMAP(pageblock_flags, SECTION_BLOCKFLAGS_BITS);
 };
 
 #ifdef CONFIG_SPARSEMEM_EXTREME
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-001-ia64-parse-kernel-parameter-hugepagesz=-in-early-boot/include/linux/pageblock-flags.h linux-2.6.23-rc5-002-add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages/include/linux/pageblock-flags.h
--- linux-2.6.23-rc5-001-ia64-parse-kernel-parameter-hugepagesz=-in-early-boot/include/linux/pageblock-flags.h	2007-09-02 16:18:27.000000000 +0100
+++ linux-2.6.23-rc5-002-add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages/include/linux/pageblock-flags.h	2007-09-02 16:19:05.000000000 +0100
@@ -0,0 +1,74 @@
+/*
+ * Macros for manipulating and testing flags related to a
+ * pageblock_nr_pages number of pages.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation version 2 of the License
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *
+ * Copyright (C) IBM Corporation, 2006
+ *
+ * Original author, Mel Gorman
+ * Major cleanups and reduction of bit operations, Andy Whitcroft
+ */
+#ifndef PAGEBLOCK_FLAGS_H
+#define PAGEBLOCK_FLAGS_H
+
+#include <linux/types.h>
+
+/* Macro to aid the definition of ranges of bits */
+#define PB_range(name, required_bits) \
+	name, name ## _end = (name + required_bits) - 1
+
+/* Bit indices that affect a whole block of pages */
+enum pageblock_bits {
+	NR_PAGEBLOCK_BITS
+};
+
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
+/* Forward declaration */
+struct page;
+
+/* Declarations for getting and setting flags. See mm/page_alloc.c */
+unsigned long get_pageblock_flags_group(struct page *page,
+					int start_bitidx, int end_bitidx);
+void set_pageblock_flags_group(struct page *page, unsigned long flags,
+					int start_bitidx, int end_bitidx);
+
+#define get_pageblock_flags(page) \
+			get_pageblock_flags_group(page, 0, NR_PAGEBLOCK_BITS-1)
+#define set_pageblock_flags(page) \
+			set_pageblock_flags_group(page, 0, NR_PAGEBLOCK_BITS-1)
+
+#endif	/* PAGEBLOCK_FLAGS_H */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-001-ia64-parse-kernel-parameter-hugepagesz=-in-early-boot/mm/page_alloc.c linux-2.6.23-rc5-002-add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages/mm/page_alloc.c
--- linux-2.6.23-rc5-001-ia64-parse-kernel-parameter-hugepagesz=-in-early-boot/mm/page_alloc.c	2007-09-02 16:18:31.000000000 +0100
+++ linux-2.6.23-rc5-002-add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages/mm/page_alloc.c	2007-09-02 16:19:05.000000000 +0100
@@ -59,6 +59,10 @@ unsigned long totalreserve_pages __read_
 long nr_swap_pages;
 int percpu_pagelist_fraction;
 
+#ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
+int pageblock_order __read_mostly;
+#endif
+
 static void __free_pages_ok(struct page *page, unsigned int order);
 
 /*
@@ -2901,6 +2905,62 @@ static void __meminit calculate_node_tot
 							realtotalpages);
 }
 
+#ifndef CONFIG_SPARSEMEM
+/*
+ * Calculate the size of the zone->blockflags rounded to an unsigned long
+ * Start by making sure zonesize is a multiple of pageblock_order by rounding
+ * up. Then use 1 NR_PAGEBLOCK_BITS worth of bits per pageblock, finally
+ * round what is now in bits to nearest long in bits, then return it in
+ * bytes.
+ */
+static unsigned long __init usemap_size(unsigned long zonesize)
+{
+	unsigned long usemapsize;
+
+	usemapsize = roundup(zonesize, pageblock_nr_pages);
+	usemapsize = usemapsize >> pageblock_order;
+	usemapsize *= NR_PAGEBLOCK_BITS;
+	usemapsize = roundup(usemapsize, 8 * sizeof(unsigned long));
+
+	return usemapsize / 8;
+}
+
+static void __init setup_usemap(struct pglist_data *pgdat,
+				struct zone *zone, unsigned long zonesize)
+{
+	unsigned long usemapsize = usemap_size(zonesize);
+	zone->pageblock_flags = NULL;
+	if (usemapsize) {
+		zone->pageblock_flags = alloc_bootmem_node(pgdat, usemapsize);
+		memset(zone->pageblock_flags, 0, usemapsize);
+	}
+}
+#else
+static void inline setup_usemap(struct pglist_data *pgdat,
+				struct zone *zone, unsigned long zonesize) {}
+#endif /* CONFIG_SPARSEMEM */
+
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
@@ -2981,6 +3041,8 @@ static void __meminit free_area_init_cor
 		if (!size)
 			continue;
 
+		set_pageblock_order(HUGETLB_PAGE_ORDER);
+		setup_usemap(pgdat, zone, size);
 		ret = init_currently_empty_zone(zone, zone_start_pfn,
 						size, MEMMAP_EARLY);
 		BUG_ON(ret);
@@ -3934,4 +3996,79 @@ EXPORT_SYMBOL(pfn_to_page);
 EXPORT_SYMBOL(page_to_pfn);
 #endif /* CONFIG_OUT_OF_LINE_PFN_TO_PAGE */
 
+/* Return a pointer to the bitmap storing bits affecting a block of pages */
+static inline unsigned long *get_pageblock_bitmap(struct zone *zone,
+							unsigned long pfn)
+{
+#ifdef CONFIG_SPARSEMEM
+	return __pfn_to_section(pfn)->pageblock_flags;
+#else
+	return zone->pageblock_flags;
+#endif /* CONFIG_SPARSEMEM */
+}
 
+static inline int pfn_to_bitidx(struct zone *zone, unsigned long pfn)
+{
+#ifdef CONFIG_SPARSEMEM
+	pfn &= (PAGES_PER_SECTION-1);
+	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
+#else
+	pfn = pfn - zone->zone_start_pfn;
+	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
+#endif /* CONFIG_SPARSEMEM */
+}
+
+/**
+ * get_pageblock_flags_group - Return the requested group of flags for the pageblock_nr_pages block of pages
+ * @page: The page within the block of interest
+ * @start_bitidx: The first bit of interest to retrieve
+ * @end_bitidx: The last bit of interest
+ * returns pageblock_bits flags
+ */
+unsigned long get_pageblock_flags_group(struct page *page,
+					int start_bitidx, int end_bitidx)
+{
+	struct zone *zone;
+	unsigned long *bitmap;
+	unsigned long pfn, bitidx;
+	unsigned long flags = 0;
+	unsigned long value = 1;
+
+	zone = page_zone(page);
+	pfn = page_to_pfn(page);
+	bitmap = get_pageblock_bitmap(zone, pfn);
+	bitidx = pfn_to_bitidx(zone, pfn);
+
+	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
+		if (test_bit(bitidx + start_bitidx, bitmap))
+			flags |= value;
+
+	return flags;
+}
+
+/**
+ * set_pageblock_flags_group - Set the requested group of flags for a pageblock_nr_pages block of pages
+ * @page: The page within the block of interest
+ * @start_bitidx: The first bit of interest
+ * @end_bitidx: The last bit of interest
+ * @flags: The flags to set
+ */
+void set_pageblock_flags_group(struct page *page, unsigned long flags,
+					int start_bitidx, int end_bitidx)
+{
+	struct zone *zone;
+	unsigned long *bitmap;
+	unsigned long pfn, bitidx;
+	unsigned long value = 1;
+
+	zone = page_zone(page);
+	pfn = page_to_pfn(page);
+	bitmap = get_pageblock_bitmap(zone, pfn);
+	bitidx = pfn_to_bitidx(zone, pfn);
+
+	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
+		if (flags & value)
+			__set_bit(bitidx + start_bitidx, bitmap);
+		else
+			__clear_bit(bitidx + start_bitidx, bitmap);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
