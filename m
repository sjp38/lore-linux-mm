Received: from m4.gw.fujitsu.co.jp ([10.0.50.74]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7L2YbJB014241 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 11:34:37 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7L2YaTM026170 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 11:34:36 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail503.fjmail.jp.fujitsu.com (fjmail503-0.fjmail.jp.fujitsu.com [10.59.80.100]) by s0.gw.fujitsu.co.jp (8.12.10)
	id i7L2YaKw022550 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 11:34:36 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail503.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2R00LK6Z5N9O@fjmail503.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Sat, 21 Aug 2004 11:34:35 +0900 (JST)
Date: Sat, 21 Aug 2004 11:39:43 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] free_area[] bitmap elimination [3/3]
Message-id: <4126B5EF.2090701@jp.fujitsu.com>
MIME-version: 1.0
Content-type: multipart/mixed; boundary="------------010600060001020409080805"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: LHMS <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010600060001020409080805
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

This part is for free_pages().





-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--------------010600060001020409080805
Content-Type: text/x-patch;
 name="eliminate-bitmap-p04.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="eliminate-bitmap-p04.patch"


remove bitmap operation from free_pages()


---

 linux-2.6.8.1-kame-kamezawa/mm/page_alloc.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff -puN mm/page_alloc.c~eliminate-bitmap-p04 mm/page_alloc.c
--- linux-2.6.8.1-kame/mm/page_alloc.c~eliminate-bitmap-p04	2004-08-21 08:55:16.712684136 +0900
+++ linux-2.6.8.1-kame-kamezawa/mm/page_alloc.c	2004-08-21 09:03:32.859258392 +0900
@@ -181,7 +181,7 @@ static void destroy_compound_page(struct
 static inline void __free_pages_bulk (struct page *page, struct page *base,
 		struct zone *zone, struct free_area *area, unsigned int order)
 {
-	unsigned long page_idx, index, mask;
+	unsigned long page_idx, mask;
 
 	if (order)
 		destroy_compound_page(page, order);
@@ -189,21 +189,21 @@ static inline void __free_pages_bulk (st
 	page_idx = page - base;
 	if (page_idx & ~mask)
 		BUG();
-	index = page_idx >> (1 + order);
-
+	set_page_order(page,order);
 	zone->free_pages += 1 << order;
 	while (order < MAX_ORDER-1) {
 		struct page *buddy1, *buddy2;
 
 		BUG_ON(area >= zone->free_area + MAX_ORDER);
-		if (!__test_and_change_bit(index, area->map))
-			/*
-			 * the buddy page is still allocated.
-			 */
-			break;
-
 		/* Move the buddy up one level. */
 		buddy1 = base + (page_idx ^ (1 << order));
+		BUG_ON(bad_range(zone, buddy1));
+		if ((page_count(buddy1) != 0) ||
+		    (page_order(buddy1) != order) )
+		    /*
+		     *		the buddy is still allocated
+		     */
+		    break;
 		buddy2 = base + page_idx;
 		BUG_ON(bad_range(zone, buddy1));
 		BUG_ON(bad_range(zone, buddy2));
@@ -211,9 +211,9 @@ static inline void __free_pages_bulk (st
 		mask <<= 1;
 		order++;
 		area++;
-		index >>= 1;
 		page_idx &= mask;
 	}
+	set_page_order((base + page_idx), order);
 	list_add(&(base + page_idx)->lru, &area->free_list);
 }
 
@@ -236,6 +236,7 @@ static inline void free_pages_check(cons
 		bad_page(function, page);
 	if (PageDirty(page))
 		ClearPageDirty(page);
+	invalidate_page_order(page);
 }
 
 /*

_

--------------010600060001020409080805--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
