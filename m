Message-ID: <447054BA.7080303@yahoo.com.au>
Date: Sun, 21 May 2006 21:53:30 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2/2] mm: handle unaligned zones
References: <4470232B.7040802@yahoo.com.au>	<44702358.1090801@yahoo.com.au> <20060521021905.0f73e01a.akpm@osdl.org> <4470417F.2000605@yahoo.com.au>
In-Reply-To: <4470417F.2000605@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------030909030003000205030504"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: apw@shadowen.org, mel@csn.ul.ie, stable@kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030909030003000205030504
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:

> It is possible we can avoid the zone seqlock checks simply by always
> testing whether the pfn is valid (this way the test would be more
> unified with the holes in zone case).

New patch 2/2.

-- 
SUSE Labs, Novell Inc.

--------------030909030003000205030504
Content-Type: text/plain;
 name="mm-unaligned-zones.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-unaligned-zones.patch"

Allow unaligned zones, and make this an opt-in CONFIG_ option because
some architectures appear to be relying on unaligned zones being handled
correctly.

- Also, the bad_range checks are removed, they are checked at meminit time
  since the last patch.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2006-05-21 17:53:36.000000000 +1000
+++ linux-2.6/mm/page_alloc.c	2006-05-21 20:52:55.000000000 +1000
@@ -85,55 +85,6 @@ int min_free_kbytes = 1024;
 unsigned long __initdata nr_kernel_pages;
 unsigned long __initdata nr_all_pages;
 
-#ifdef CONFIG_DEBUG_VM
-static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
-{
-	int ret = 0;
-	unsigned seq;
-	unsigned long pfn = page_to_pfn(page);
-
-	do {
-		seq = zone_span_seqbegin(zone);
-		if (pfn >= zone->zone_start_pfn + zone->spanned_pages)
-			ret = 1;
-		else if (pfn < zone->zone_start_pfn)
-			ret = 1;
-	} while (zone_span_seqretry(zone, seq));
-
-	return ret;
-}
-
-static int page_is_consistent(struct zone *zone, struct page *page)
-{
-#ifdef CONFIG_HOLES_IN_ZONE
-	if (!pfn_valid(page_to_pfn(page)))
-		return 0;
-#endif
-	if (zone != page_zone(page))
-		return 0;
-
-	return 1;
-}
-/*
- * Temporary debugging check for pages not lying within a given zone.
- */
-static int bad_range(struct zone *zone, struct page *page)
-{
-	if (page_outside_zone_boundaries(zone, page))
-		return 1;
-	if (!page_is_consistent(zone, page))
-		return 1;
-
-	return 0;
-}
-
-#else
-static inline int bad_range(struct zone *zone, struct page *page)
-{
-	return 0;
-}
-#endif
-
 static void bad_page(struct page *page)
 {
 	printk(KERN_EMERG "Bad page state in process '%s'\n"
@@ -281,9 +232,42 @@ __find_combined_index(unsigned long page
 }
 
 /*
- * This function checks whether a page is free && is the buddy
- * we can do coalesce a page and its buddy if
- * (a) the buddy is not in a hole &&
+ * If the mem_map may have holes (invalid pfns) in it, which are not on
+ * MAX_ORDER<<1 aligned boundaries, CONFIG_HOLES_IN_ZONE must be set by the
+ * architecture, because the buddy allocator will otherwise attempt to access
+ * their underlying struct page when finding a buddy to merge.
+ *
+ * If the the zone's mem_map is not 1<<MAX_ORDER aligned, CONFIG_ALIGNED_ZONE
+ * must *not* be set by the architecture, because the buddy allocator will run
+ * into "buddies" which are outside mem_map. It is not enough for the node's
+ * mem_map to be aligned, because unaligned zone boundaries can cause a buddies
+ * to be in different zones.
+ */
+static inline int buddy_outside_zone(struct page *page, struct page *buddy)
+{
+#if defined(CONFIG_HOLES_IN_ZONE) || !defined(CONFIG_ALIGNED_ZONE)
+	if (!pfn_valid(page_to_pfn(buddy)))
+		return 1;
+#endif
+
+#if !defined(CONFIG_ALIGNED_ZONE)
+	/*
+	 * page_zone_idx accesses page->flags, so this test must go after
+	 * the above, which ensures that buddy is valid (and can have its
+	 * zone_idx tested).
+	 */
+	if (page_zone_idx(page) != page_zone_idx(buddy))
+		return 1;
+
+#endif
+
+	return 0;
+}
+
+/*
+ * This function checks whether a buddy is free and is the buddy of page.
+ * We can coalesce a page and its buddy if
+ * (a) the buddy is not "outside" the zone &&
  * (b) the buddy is in the buddy system &&
  * (c) a page and its buddy have the same order.
  *
@@ -292,15 +276,17 @@ __find_combined_index(unsigned long page
  *
  * For recording page's order, we use page_private(page).
  */
-static inline int page_is_buddy(struct page *page, int order)
+static inline int page_is_buddy(struct page *page, struct page *buddy, int order)
 {
-#ifdef CONFIG_HOLES_IN_ZONE
-	if (!pfn_valid(page_to_pfn(page)))
+	/*
+	 * In some memory configurations, buddy pages may be found
+	 * which are outside the zone. Check for those here.
+	 */
+	if (buddy_outside_zone(page, buddy))
 		return 0;
-#endif
 
-	if (PageBuddy(page) && page_order(page) == order) {
-		BUG_ON(page_count(page) != 0);
+	if (PageBuddy(buddy) && page_order(buddy) == order) {
+		BUG_ON(page_count(buddy) != 0);
 		return 1;
 	}
 	return 0;
@@ -342,7 +328,6 @@ static inline void __free_one_page(struc
 	page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
 
 	BUG_ON(page_idx & (order_size - 1));
-	BUG_ON(bad_range(zone, page));
 
 	zone->free_pages += order_size;
 	while (order < MAX_ORDER-1) {
@@ -351,7 +336,7 @@ static inline void __free_one_page(struc
 		struct page *buddy;
 
 		buddy = __page_find_buddy(page, page_idx, order);
-		if (!page_is_buddy(buddy, order))
+		if (!page_is_buddy(page, buddy, order))
 			break;		/* Move the buddy up one level. */
 
 		list_del(&buddy->lru);
@@ -506,7 +491,6 @@ static inline void expand(struct zone *z
 		area--;
 		high--;
 		size >>= 1;
-		BUG_ON(bad_range(zone, &page[size]));
 		list_add(&page[size].lru, &area->free_list);
 		area->nr_free++;
 		set_page_order(&page[size], high);
@@ -824,7 +808,6 @@ again:
 	local_irq_restore(flags);
 	put_cpu();
 
-	BUG_ON(bad_range(zone, page));
 	if (prep_new_page(page, order, gfp_flags))
 		goto again;
 	return page;
@@ -2048,11 +2031,13 @@ static __meminit void zone_debug_checks(
 	unsigned long end = start + zone->spanned_pages;
 	const unsigned long mask = ((1<<MAX_ORDER)-1);
 	
+#ifdef CONFIG_ALIGNED_ZONE
 	if (start & mask)
 		panic("zone start pfn (%lx) not MAX_ORDER aligned\n", start);
 
 	if (end & mask)
 		panic("zone end pfn (%lx) not MAX_ORDER aligned\n", end);
+#endif
 
 	for (pfn = start; pfn < end; pfn++) {
 		struct page *page;
@@ -2068,16 +2053,29 @@ static __meminit void zone_debug_checks(
 			panic("zone page (pfn %lx) in wrong zone\n", pfn);
 
 		for (order = 0; order < MAX_ORDER-1; order++) {
+			unsigned long buddy_pfn;
 			struct page *buddy;
 			buddy = __page_find_buddy(page, pfn & mask, order);
+			buddy_pfn = page_to_pfn(buddy);
 
-#ifndef CONFIG_HOLES_IN_ZONE
-			if (!pfn_valid(page_to_pfn(buddy)))
+#if !defined(CONFIG_HOLES_IN_ZONE) && defined(CONFIG_ALIGNED_ZONE)
+			if (!pfn_valid(buddy_pfn))
 				panic("pfn (%lx) buddy (order %d) not valid\n", pfn, order);
 #endif
 
-			if (page_zone(buddy) != zone)
-				panic("pfn (%lx) buddy (order %d) in wrong zone\n", pfn, order);
+#ifdef CONFIG_ALIGNED_ZONE
+			if (buddy_pfn < start || buddy_pfn >= end)
+				panic("pfn (%lx) buddy (%lx) (order %d) outside zone\n", pfn, buddy_pfn, order);
+
+			if (zone != page_zone(buddy))
+				panic("pfn (%lx) buddy (%lx) (order %d) in different zone\n", pfn, buddy_pfn, order);
+#else
+
+			if (buddy_pfn < start || buddy_pfn >= end) {
+				if (pfn_valid(buddy_pfn) && zone == page_zone(buddy))
+					panic("pfn (%lx) buddy (%lx) (order %d) is outside the zone but page_zone would cause it to be merged\n", pfn, buddy_pfn, order);
+			}
+#endif
 		}
 	}
 }
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2006-05-19 12:48:01.000000000 +1000
+++ linux-2.6/include/linux/mm.h	2006-05-21 18:10:23.000000000 +1000
@@ -466,10 +466,14 @@ static inline unsigned long page_zonenum
 struct zone;
 extern struct zone *zone_table[];
 
+static inline unsigned long page_zone_idx(struct page *page)
+{
+	return (page->flags >> ZONETABLE_PGSHIFT) & ZONETABLE_MASK;
+}
+
 static inline struct zone *page_zone(struct page *page)
 {
-	return zone_table[(page->flags >> ZONETABLE_PGSHIFT) &
-			ZONETABLE_MASK];
+	return zone_table[page_zone_idx(page)];
 }
 
 static inline unsigned long page_to_nid(struct page *page)

--------------030909030003000205030504--
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
