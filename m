Received: from m5.gw.fujitsu.co.jp ([10.0.50.75]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7L2WxJB013780 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 11:32:59 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp by m5.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7L2WwmZ009693 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 11:32:58 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail503.fjmail.jp.fujitsu.com (fjmail503-0.fjmail.jp.fujitsu.com [10.59.80.100]) by s7.gw.fujitsu.co.jp (8.12.11)
	id i7L2WwtO011164 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 11:32:58 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail503.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2R00IMDZ2X1Z@fjmail503.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Sat, 21 Aug 2004 11:32:57 +0900 (JST)
Date: Sat, 21 Aug 2004 11:38:05 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] free_area[] bitmap elimination [2/3]
Message-id: <4126B58D.8080004@jp.fujitsu.com>
MIME-version: 1.0
Content-type: multipart/mixed; boundary="------------050905000303020205080200"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: LHMS <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050905000303020205080200
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

This part is for alloc_pages()



-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--------------050905000303020205080200
Content-Type: text/x-patch;
 name="eliminate-bitmap-p03.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="eliminate-bitmap-p03.patch"


removing bitmap operation in page allocation.


---

 linux-2.6.8.1-kame-kamezawa/mm/page_alloc.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff -puN mm/page_alloc.c~eliminate-bitmap-p03 mm/page_alloc.c
--- linux-2.6.8.1-kame/mm/page_alloc.c~eliminate-bitmap-p03	2004-08-21 08:54:43.285765800 +0900
+++ linux-2.6.8.1-kame-kamezawa/mm/page_alloc.c	2004-08-21 08:54:43.292764736 +0900
@@ -287,8 +287,6 @@ void __free_pages_ok(struct page *page, 
 	free_pages_bulk(page_zone(page), 1, &list, order);
 }
 
-#define MARK_USED(index, order, area) \
-	__change_bit((index) >> (1+(order)), (area)->map)
 
 /*
  * The order of subdivision here is critical for the IO subsystem.
@@ -315,9 +313,10 @@ expand(struct zone *zone, struct page *p
 		high--;
 		size >>= 1;
 		BUG_ON(bad_range(zone, &page[size]));
+		set_page_order(&page[size],high);
 		list_add(&page[size].lru, &area->free_list);
-		MARK_USED(index + size, high, area);
 	}
+	invalidate_page_order(page);
 	return page;
 }
 
@@ -378,12 +377,9 @@ static struct page *__rmqueue(struct zon
 		area = zone->free_area + current_order;
 		if (list_empty(&area->free_list))
 			continue;
-
 		page = list_entry(area->free_list.next, struct page, lru);
 		list_del(&page->lru);
 		index = page - zone->zone_mem_map;
-		if (current_order != MAX_ORDER-1)
-			MARK_USED(index, current_order, area);
 		zone->free_pages -= 1UL << order;
 		return expand(zone, page, index, order, current_order, area);
 	}

_

--------------050905000303020205080200--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
