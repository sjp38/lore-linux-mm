Received: from m4.gw.fujitsu.co.jp ([10.0.50.74]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i88BkVtx019911 for <linux-mm@kvack.org>; Wed, 8 Sep 2004 20:46:31 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i88BkVI6029820 for <linux-mm@kvack.org>; Wed, 8 Sep 2004 20:46:31 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp (localhost [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 53751153635
	for <linux-mm@kvack.org>; Wed,  8 Sep 2004 20:46:31 +0900 (JST)
Received: from fjmail501.fjmail.jp.fujitsu.com (fjmail501-0.fjmail.jp.fujitsu.com [10.59.80.96])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D6C0815362F
	for <linux-mm@kvack.org>; Wed,  8 Sep 2004 20:46:30 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120]) by
 fjmail501.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3Q00J1Y0PHIV@fjmail501.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed,  8 Sep 2004 20:46:30 +0900 (JST)
Date: Wed, 08 Sep 2004 20:51:46 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] no bitmap buddy allocator : modifies expand() (2/4)
Message-id: <413EF252.8040808@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>, Andrew Morton <akpm@osdl.org>, William Lee Irwin III <wli@holomorphy.com>, Dave Hansen <haveblue@us.ibm.com>, Hirokazu Takahashi <taka@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This is part (2/4) and modifies expand().

This patch removes bitmap operation from alloc_pages().

Instead of using MARK_USED() bitmap operation,
this patch records page's order in page struct itself, page->private field.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---

  test-kernel-kamezawa/mm/page_alloc.c |   17 +++++++----------
  1 files changed, 7 insertions(+), 10 deletions(-)

diff -puN mm/page_alloc.c~eliminate-bitmap-alloc mm/page_alloc.c
--- test-kernel/mm/page_alloc.c~eliminate-bitmap-alloc	2004-09-08 18:48:40.667294640 +0900
+++ test-kernel-kamezawa/mm/page_alloc.c	2004-09-08 19:04:05.398714096 +0900
@@ -296,9 +296,6 @@ void __free_pages_ok(struct page *page,
  	free_pages_bulk(page_zone(page), 1, &list, order);
  }

-#define MARK_USED(index, order, area) \
-	__change_bit((index) >> (1+(order)), (area)->map)
-
  /*
   * The order of subdivision here is critical for the IO subsystem.
   * Please do not alter this order without good reasons and regression
@@ -315,7 +312,7 @@ void __free_pages_ok(struct page *page,
   */
  static inline struct page *
  expand(struct zone *zone, struct page *page,
-	 unsigned long index, int low, int high, struct free_area *area)
+       int low, int high, struct free_area *area)
  {
  	unsigned long size = 1 << high;

@@ -325,7 +322,9 @@ expand(struct zone *zone, struct page *p
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
@@ -379,7 +378,6 @@ static struct page *__rmqueue(struct zon
  	struct free_area * area;
  	unsigned int current_order;
  	struct page *page;
-	unsigned int index;

  	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
  		area = zone->free_area + current_order;
@@ -388,11 +386,10 @@ static struct page *__rmqueue(struct zon

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
