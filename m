Received: from m5.gw.fujitsu.co.jp ([10.0.50.75]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7OCaaJB023957 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 21:36:36 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp by m5.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7OCaZmZ011564 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 21:36:35 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail502.fjmail.jp.fujitsu.com (fjmail502-0.fjmail.jp.fujitsu.com [10.59.80.98]) by s6.gw.fujitsu.co.jp (8.12.11)
	id i7OCaYme009814 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 21:36:34 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail502.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2Y002E4B0XOM@fjmail502.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Tue, 24 Aug 2004 21:36:34 +0900 (JST)
Date: Tue, 24 Aug 2004 21:41:41 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC/PATCH] free_area[] bitmap elimination [3/3]
Message-id: <412B3785.30300@jp.fujitsu.com>
MIME-version: 1.0
Content-type: multipart/mixed; boundary="------------060006090608070807060308"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave Hansen <haveblue@us.ibm.com>, Hirokazu Takahashi <taka@valinux.co.jp>, ncunningham@linuxmail.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060006090608070807060308
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

This is the last(4th) part.
a patch for free_pages()

there are many changes but an algorithm itself is unchanged.
If this patch is complex, please see an example I added.

--Kame

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--------------060006090608070807060308
Content-Type: text/x-patch;
 name="eliminate-bitmap-free.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="eliminate-bitmap-free.patch"


This patch removes bitmap operation from free_pages()

Instead of using bitmap, this patch records page's order in 
page struct itself, page->private field.

As a side effect of removing a bitmap, we must test whether a buddy of a page 
is existing or not. This is done by zone->aligned_order and bad_range(page,zone).

zone->aligned_order guarantees "a page of an order below zone->aligned_order has
its buddy in the zone".This is calculated in the zone initialization time.

If order > zone->aligned_order, we must call bad_range(zone, page) and 
this is enough when zone doesn't contain memory-hole.

But....
In IA64 case, additionally, there can be memory holes in a zone and size of a hole 
is smaller than 1 << MAX_ORDER. So pfn_valid() is inserted.
But pfn_valid() looks a bit heavy in ia64 and replacing this with faster one
is desirable.

I think some of memory-hotplug codes will be good for fix this in the future.
There will be light-weight pfn_valid() for detecting memory-hole.



example) a series of free_pages()

consider these 8 pages

	page  0  1  2  3  4  5  6   7
	     [A][F][F][-][F][A][A2][-]
        page[0] is allocated , order=0
	page[1] is free,       order=0
	page[2-3] is free,     order=1
	page[4] is free,       order=0
	page[5] is allocated , order=0
	page[6-7] is allocated, order=1

0) status
   free_area[3] ->
   free_area[2] -> 
   free_area[1] -> page[2-3]
   free_area[0] -> page[1], page[4]
   allocated    -> page[0], page[5], page[6-7]

1) free_pages (page[6],order=1)
1-1) loop 1st
   free_area[3] ->
   free_area[2] -> 
   free_area[1] -> page[2-3], page[6-7]
   free_area[0] -> page[1], page[4]
   allocated    -> page[0], page[5]

   buddy of page 6 in order 1 is page[4].
   page[4] is free,but its order is 0
   stop here.

2) free_pages(page[5], order=0)
2-1) loop 1st
   free_area[3] ->
   free_area[2] -> 
   free_area[1] -> page[2-3], page[6-7]
   free_area[0] -> page[1], page[4], page[5]
   allocated    -> page[0]
   
   buddy of page[5] in order 0 is page[4].
   page[4] is free and its order is 0.
   do coalesce page[4] & page[5].
 
2-2) loop 2nd
   free_area[3] ->
   free_area[2] -> 
   free_area[1] -> page[2-3], page[6-7],page[4-5]
   free_area[0] -> page[1]
   allocated    -> page[0]
   
   buddy of page[4] in order 1 is page[6]
   page[6] is free and its order is 1
   coalesce page[4-5] and page[6-7]   

2-3) loop 3rd
   free_area[3] ->
   free_area[2] -> page[4-7] 
   free_area[1] -> page[2-3],
   free_area[0] -> page[1]
   allocated    -> page[0]
  
   buddy of page[4] in order 2 is page[0]
   page[0] is not free.
   stop here.

3) free_pages(page[0],order=0)
3-1) 1st loop
   free_area[3] ->
   free_area[2] -> page[4-7] 
   free_area[1] -> page[2-3],
   free_area[0] -> page[1],page[0] -> coalesce
   allocated    ->

3-2) 2nd loop
   free_area[3] ->
   free_area[2] -> page[4-7] 
   free_area[1] -> page[0-1],page[2-3] -> coalesce
   free_area[0] -> 
   allocated    ->

3-3) 3rd
   free_area[3] ->
   free_area[2] -> page[4-7] , page[0-3] -> coalesce
   free_area[1] -> 
   free_area[0] -> 
   allocated    ->

3-4) 4th
   free_area[3] -> page[0-7]
   free_area[2] -> 
   free_area[1] -> 
   free_area[0] -> 
   allocated    ->


---

 linux-2.6.8.1-mm4-kame-kamezawa/mm/page_alloc.c |   82 ++++++++++++++++++------
 1 files changed, 63 insertions(+), 19 deletions(-)

diff -puN mm/page_alloc.c~eliminate-bitmap-free mm/page_alloc.c
--- linux-2.6.8.1-mm4-kame/mm/page_alloc.c~eliminate-bitmap-free	2004-08-24 20:03:48.000000000 +0900
+++ linux-2.6.8.1-mm4-kame-kamezawa/mm/page_alloc.c	2004-08-24 20:03:48.000000000 +0900
@@ -157,6 +157,37 @@ static void destroy_compound_page(struct
 #endif		/* CONFIG_HUGETLB_PAGE */
 
 /*
+ * This function checks whether a page is free && is the buddy
+ * we can do coalesce if
+ * (a) the buddy is free and
+ * (b) the buddy is on the buddy system
+ * (c) the buddy has the same order.
+ * for recording page's order, we use private field and PG_private.
+ */
+static inline int page_is_buddy(struct page *page, int order)
+{
+	if (page_count(page) == 0 &&
+	    PagePrivate(page) &&
+	    !PageReserved(page) &&
+            page_order(page) == order) {
+		/* check, check... see free_pages_check() */
+		if (page_mapped(page) ||
+		    page->mapping != NULL ||
+		    (page->flags & (
+			    1 << PG_lru	|
+			    1 << PG_locked	|
+			    1 << PG_active	|
+			    1 << PG_reclaim	|
+			    1 << PG_slab	|
+			    1 << PG_swapcache |
+			    1 << PG_writeback )))
+			bad_page(__FUNCTION__, page);
+		return 1;
+	}
+	return 0;
+}
+
+/*
  * Freeing function for a buddy system allocator.
  *
  * The concept of a buddy system is to maintain direct-mapped table
@@ -168,9 +199,12 @@ static void destroy_compound_page(struct
  * at the bottom level available, and propagating the changes upward
  * as necessary, plus some accounting needed to play nicely with other
  * parts of the VM system.
- * At each level, we keep one bit for each pair of blocks, which
- * is set to 1 iff only one of the pair is allocated.  So when we
- * are allocating or freeing one, we can derive the state of the
+ *
+ * At each level, we keep a list of pages, which are head of chunk of
+ * pages at the level. A page, which is a head of chunks, has its order
+ * in page structure itself and PG_private flag is set. we can get an 
+ * order of a page by calling  page_order().
+ * So we are allocating or freeing one, we can derive the state of the
  * other.  That is, if we allocate a small block, and both were   
  * free, the remainder of the region must be split into blocks.   
  * If a block is freed, and its buddy is also free, then this
@@ -178,43 +212,53 @@ static void destroy_compound_page(struct
  *
  * -- wli
  */
-
 static inline void __free_pages_bulk (struct page *page, struct page *base,
 		struct zone *zone, struct free_area *area, unsigned int order)
 {
-	unsigned long page_idx, index, mask;
-
+	unsigned long page_idx, mask;
 	if (order)
 		destroy_compound_page(page, order);
 	mask = (~0UL) << order;
 	page_idx = page - base;
 	if (page_idx & ~mask)
 		BUG();
-	index = page_idx >> (1 + order);
-
 	zone->free_pages += 1 << order;
-	while (order < MAX_ORDER-1) {
-		struct page *buddy1, *buddy2;
+	BUG_ON(bad_range(zone,page));
 
+	while (order < MAX_ORDER-1) {
+		struct page *buddy1;
 		BUG_ON(area >= zone->free_area + MAX_ORDER);
-		if (!__test_and_change_bit(index, area->map))
+		buddy1 = base + (page_idx ^ (1 << order));
+		if (order >= zone->aligned_order) {
+			/* we need range check */
+#ifdef CONFIG_VIRTUAL_MEM_MAP  
+			/* This check is necessary when
+			   1. there may be holes in zone.
+			   2. a hole is not aligned in this order.
+			   currently, VIRTUAL_MEM_MAP case, is only case.
+			   Is there better call than pfn_valid ?
+			*/
+			if (!pfn_valid(zone->zone_start_pfn + (page_idx ^ (1 << order))))
+				break;
+#endif		
+			/* this order in this zone is not aligned. */
+			if (bad_range(zone, buddy1))
+				break;
+		}
+		if (!page_is_buddy(buddy1, order))
 			/*
-			 * the buddy page is still allocated.
+			 *  the buddy page is still allocated.
 			 */
 			break;
-
-		/* Move the buddy up one level. */
-		buddy1 = base + (page_idx ^ (1 << order));
-		buddy2 = base + page_idx;
-		BUG_ON(bad_range(zone, buddy1));
-		BUG_ON(bad_range(zone, buddy2));
 		list_del(&buddy1->lru);
+		invalidate_page_order(buddy1);
 		mask <<= 1;
 		order++;
 		area++;
-		index >>= 1;
 		page_idx &= mask;
 	}
+	/* record the final order of the page */
+	set_page_order((base + page_idx), order);
 	list_add(&(base + page_idx)->lru, &area->free_list);
 }
 

_

--------------060006090608070807060308--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
