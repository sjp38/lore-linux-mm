Received: from m2.gw.fujitsu.co.jp ([10.0.50.72]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i827wstx006619 for <linux-mm@kvack.org>; Thu, 2 Sep 2004 16:58:54 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp by m2.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i827wrti001891 for <linux-mm@kvack.org>; Thu, 2 Sep 2004 16:58:53 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail506.fjmail.jp.fujitsu.com (fjmail506-0.fjmail.jp.fujitsu.com [10.59.80.106]) by s3.gw.fujitsu.co.jp (8.12.10)
	id i827wrkO030054 for <linux-mm@kvack.org>; Thu, 2 Sep 2004 16:58:53 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120]) by
 fjmail506.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3E00F2VM64LY@fjmail506.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Thu,  2 Sep 2004 16:58:52 +0900 (JST)
Date: Thu, 02 Sep 2004 17:04:06 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] buddy allocator without bitmap [2/3]
Message-id: <4136D3F6.7010304@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

This part is unchanged from previous version.

I'm sorry to forget to say that these patches are against 2.6.9-rc1-mm2.

--Kame
====

This is 3rd.
This patch removes bitmap operation from alloc_pages().

Instead of using MARK_USED() bitmap operation,
this patch records page's order in page struct itself, page->private field.



---

 test-kernel-kamezawa/mm/page_alloc.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff -puN mm/page_alloc.c~eliminate-bitmap-alloc mm/page_alloc.c
--- test-kernel/mm/page_alloc.c~eliminate-bitmap-alloc	2004-09-02 15:46:01.135746384 +0900
+++ test-kernel-kamezawa/mm/page_alloc.c	2004-09-02 15:46:01.140745624 +0900
@@ -288,9 +288,6 @@ void __free_pages_ok(struct page *page,
 	free_pages_bulk(page_zone(page), 1, &list, order);
 }

-#define MARK_USED(index, order, area) \
-	__change_bit((index) >> (1+(order)), (area)->map)
-
 /*
  * The order of subdivision here is critical for the IO subsystem.
  * Please do not alter this order without good reasons and regression
@@ -307,7 +304,7 @@ void __free_pages_ok(struct page *page,
  */
 static inline struct page *
 expand(struct zone *zone, struct page *page,
-	 unsigned long index, int low, int high, struct free_area *area)
+       int low, int high, struct free_area *area)
 {
 	unsigned long size = 1 << high;

@@ -317,7 +314,9 @@ expand(struct zone *zone, struct page *p
 		size >>= 1;
 		BUG_ON(bad_range(zone, &page[size]));
 		list_add(&page[size].lru, &area->free_list);
-		MARK_USED(index + size, high, area);
+		/* Note: already have lock, we don't need to use atomic ops */
+		set_page_order(&page[size], high);
+		SetPagePrivate(&page[size]);
 	}
 	return page;
 }
@@ -371,7 +370,6 @@ static struct page *__rmqueue(struct zon
 	struct free_area * area;
 	unsigned int current_order;
 	struct page *page;
-	unsigned int index;

 	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
 		area = zone->free_area + current_order;
@@ -380,11 +378,10 @@ static struct page *__rmqueue(struct zon

 		page = list_entry(area->free_list.next, struct page, lru);
 		list_del(&page->lru);
-		index = page - zone->zone_mem_map;
-		if (current_order != MAX_ORDER-1)
-			MARK_USED(index, current_order, area);
+		/* Note: already have lock, we don't need to use atomic ops */
+		ClearPagePrivate(page);
 		zone->free_pages -= 1UL << order;
-		return expand(zone, page, index, order, current_order, area);
+		return expand(zone, page, order, current_order, area);
 	}

 	return NULL;

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
