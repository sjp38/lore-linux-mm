Received: from m1.gw.fujitsu.co.jp ([10.0.50.71]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7OCMxJB017947 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 21:22:59 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7OCMwPV028126 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 21:22:58 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail505.fjmail.jp.fujitsu.com (fjmail505-0.fjmail.jp.fujitsu.com [10.59.80.104]) by s7.gw.fujitsu.co.jp (8.12.11)
	id i7OCMwX7032744 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 21:22:58 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail505.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2Y00GV2AE94S@fjmail505.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Tue, 24 Aug 2004 21:22:58 +0900 (JST)
Date: Tue, 24 Aug 2004 21:28:05 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC/PATCH] free_area[] bitmap elimination[1/3]
Message-id: <412B3455.1000604@jp.fujitsu.com>
MIME-version: 1.0
Content-type: multipart/mixed; boundary="------------040104080105010000000000"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Hirokazu Takahashi <taka@valinux.co.jp>, ncunningham@linuxmail.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040104080105010000000000
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

this is 2nd part.
code for intialization .

calculation of zone->alinged_order is newly added.

-- Kame
==

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--------------040104080105010000000000
Content-Type: text/x-patch;
 name="eliminate-bitmap-init.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="eliminate-bitmap-init.patch"


This patch removes bitmap allocation in zone_init_free_lists() and
page_to_bitmap_size();

And new added member zone->aligned_order is initialized.

zone->alined_order guarantees "zone is aligned to (1 << zone->aligned_order) 
contiguous pages"

If zone->alined_order == MAX_ORDER, zone is completely aligned, and
every page is guaranteed to have its buddy page in any order.

zone->aligned_order is used in free_pages_bulk() to skip range checking.
By using this, if order < zone->aligned_order,
we do not have to worry about "a page can have its buddy in an order or not?"

This would work well in several architectures.

But my ia64 box shows zone->aligned_order=0 .....this aligned_order would not 
be helpful in some environment.

-- Kame


---

 linux-2.6.8.1-mm4-kame-kamezawa/mm/page_alloc.c |   72 +++++++++---------------
 1 files changed, 28 insertions(+), 44 deletions(-)

diff -puN mm/page_alloc.c~eliminate-bitmap-init mm/page_alloc.c
--- linux-2.6.8.1-mm4-kame/mm/page_alloc.c~eliminate-bitmap-init	2004-08-24 18:25:14.000000000 +0900
+++ linux-2.6.8.1-mm4-kame-kamezawa/mm/page_alloc.c	2004-08-24 20:32:14.640312608 +0900
@@ -301,7 +301,7 @@ void __free_pages_ok(struct page *page, 
  * subsystem according to empirical testing, and this is also justified
  * by considering the behavior of a buddy system containing a single
  * large block of memory acted on by a series of small allocations.
- * This behavior is a critical factor in sglist merging's success.
+ * This behavior is a critical factor in s merging's success.
  *
  * -- wli
  */
@@ -1499,6 +1499,25 @@ static void __init calculate_zone_totalp
 	printk(KERN_DEBUG "On node %d totalpages: %lu\n", pgdat->node_id, realtotalpages);
 }
 
+/*   
+ *    calculate_aligned_order()
+ *    this function calculates an upper bound order of alignment of buddy pages.
+ *    if order < zone->aligned_order, every page are guaranteed to have its buddy.
+ */
+void __init calculate_aligned_order(int nid, int zone, unsigned long start_pfn, 
+				    unsigned long size)
+{
+	int order;
+	unsigned long mask;
+	struct zone *zonep = zone_table[NODEZONE(nid, zone)];
+	for (order = 0 ; order < MAX_ORDER; order++) {
+		mask = (unsigned long)1 << order;
+		if ((start_pfn & mask) || (size & mask))
+			break;
+	}
+	if (order < zonep->aligned_order)
+		zonep->aligned_order = order;
+}
 
 /*
  * Initially all pages are reserved - free ones are freed
@@ -1510,7 +1529,7 @@ void __init memmap_init_zone(unsigned lo
 {
 	struct page *start = pfn_to_page(start_pfn);
 	struct page *page;
-
+	unsigned long saved_start_pfn = start_pfn;
 	for (page = start; page < (start + size); page++) {
 		set_page_zone(page, NODEZONE(nid, zone));
 		set_page_count(page, 0);
@@ -1524,51 +1543,18 @@ void __init memmap_init_zone(unsigned lo
 #endif
 		start_pfn++;
 	}
-}
-
-/*
- * Page buddy system uses "index >> (i+1)", where "index" is
- * at most "size-1".
- *
- * The extra "+3" is to round down to byte size (8 bits per byte
- * assumption). Thus we get "(size-1) >> (i+4)" as the last byte
- * we can access.
- *
- * The "+1" is because we want to round the byte allocation up
- * rather than down. So we should have had a "+7" before we shifted
- * down by three. Also, we have to add one as we actually _use_ the
- * last bit (it's [0,n] inclusive, not [0,n[).
- *
- * So we actually had +7+1 before we shift down by 3. But
- * (n+8) >> 3 == (n >> 3) + 1 (modulo overflows, which we do not have).
- *
- * Finally, we LONG_ALIGN because all bitmap operations are on longs.
- */
-unsigned long pages_to_bitmap_size(unsigned long order, unsigned long nr_pages)
-{
-	unsigned long bitmap_size;
-
-	bitmap_size = (nr_pages-1) >> (order+4);
-	bitmap_size = LONG_ALIGN(bitmap_size+1);
-
-	return bitmap_size;
+	/* Because memmap_init_zone() is called in suitable way 
+	 * even if zone has memory hole,
+	 * calling calculate_aligned_order(zone) here is reasonable 
+	 */
+	calculate_aligned_order(nid, zone, saved_start_pfn, size);
 }
 
 void zone_init_free_lists(struct pglist_data *pgdat, struct zone *zone, unsigned long size)
 {
 	int order;
-	for (order = 0; ; order++) {
-		unsigned long bitmap_size;
-
+	for (order = 0 ; order < MAX_ORDER ; order++) {
 		INIT_LIST_HEAD(&zone->free_area[order].free_list);
-		if (order == MAX_ORDER-1) {
-			zone->free_area[order].map = NULL;
-			break;
-		}
-
-		bitmap_size = pages_to_bitmap_size(order, size);
-		zone->free_area[order].map =
-		  (unsigned long *) alloc_bootmem_node(pgdat, bitmap_size);
 	}
 }
 
@@ -1681,11 +1667,9 @@ static void __init free_area_init_core(s
 
 		if ((zone_start_pfn) & (zone_required_alignment-1))
 			printk("BUG: wrong zone alignment, it will crash\n");
-
+		zone->aligned_order = MAX_ORDER;
 		memmap_init(size, nid, j, zone_start_pfn);
-
 		zone_start_pfn += size;
-
 		zone_init_free_lists(pgdat, zone, zone->spanned_pages);
 	}
 }

_

--------------040104080105010000000000--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
