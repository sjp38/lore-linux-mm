Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D21996B0062
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 01:25:29 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5A5QFEI016176
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 10 Jun 2009 14:26:15 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CC8F45DE53
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 14:26:15 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 081BF45DE51
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 14:26:15 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DD7861DB8042
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 14:26:14 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C4471DB803E
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 14:26:14 +0900 (JST)
Date: Wed, 10 Jun 2009 14:24:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/2] lumpy reclaim: clean up and write lumpy reclaim
Message-Id: <20090610142443.9370aff8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, apw@canonical.com, riel@redhat.com, minchan.kim@gmail.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

I think lumpy reclaim should be updated to meet to current split-lru.
This patch includes bugfix and cleanup. How do you think ?

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

In lumpty reclaim, "cursor_page" is found just by pfn. Then, we don't know
where "cursor" page came from. Then, putback it to "src" list is BUG.
And as pointed out, current lumpy reclaim doens't seem to
work as originally designed and a bit complicated. This patch adds a
function try_lumpy_reclaim() and rewrite the logic.

The major changes from current lumpy reclaim is
  - check migratetype before aggressive retry at failure.
  - check PG_unevictable at failure.
  - scan is done in buddy system order. This is a help for creating
    a lump around targeted page. We'll create a continuous pages for buddy
    allocator as far as we can _around_ reclaim target page.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |  120 +++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 71 insertions(+), 49 deletions(-)

Index: mmotm-2.6.30-Jun10/mm/vmscan.c
===================================================================
--- mmotm-2.6.30-Jun10.orig/mm/vmscan.c
+++ mmotm-2.6.30-Jun10/mm/vmscan.c
@@ -850,6 +850,69 @@ int __isolate_lru_page(struct page *page
 	return ret;
 }
 
+static int
+try_lumpy_reclaim(struct page *page, struct list_head *dst, int request_order)
+{
+	unsigned long buddy_base, buddy_idx, buddy_start_pfn, buddy_end_pfn;
+	unsigned long pfn, page_pfn, page_idx;
+	int zone_id, order, type;
+	int do_aggressive = 0;
+	int nr = 0;
+	/*
+	 * Lumpy reqraim. Try to take near pages in requested order to
+	 * create free continous pages. This algorithm tries to start
+	 * from order 0 and scan buddy pages up to request_order.
+	 * If you are unsure about buddy position calclation, please see
+	 * mm/page_alloc.c
+	 */
+	zone_id = page_zone_id(page);
+	page_pfn = page_to_pfn(page);
+	buddy_base = page_pfn & ~((1 << MAX_ORDER) - 1);
+
+	/* Can we expect succesful reclaim ? */
+	type = get_pageblock_migratetype(page);
+	if ((type == MIGRATE_MOVABLE) || (type == MIGRATE_RECLAIMABLE))
+		do_aggressive = 1;
+
+	for (order = 0; order < request_order; ++order) {
+		/* offset in this buddy region */
+		page_idx = page_pfn & ~buddy_base;
+		/* offset of buddy can be calculated by xor */
+		buddy_idx = page_idx ^ (1 << order);
+		buddy_start_pfn = buddy_base + buddy_idx;
+		buddy_end_pfn = buddy_start_pfn + (1 << order);
+
+		/* scan range [buddy_start_pfn...buddy_end_pfn) */
+		for (pfn = buddy_start_pfn; pfn < buddy_end_pfn; ++pfn) {
+			/* Avoid holes within the zone. */
+			if (unlikely(!pfn_valid_within(pfn)))
+				break;
+			page = pfn_to_page(pfn);
+			/*
+			 * Check that we have not crossed a zone boundary.
+			 * Some arch have zones not aligned to MAX_ORDER.
+			 */
+			if (unlikely(page_zone_id(page) != zone_id))
+				break;
+
+			/* we are always under ISOLATE_BOTH */
+			if (__isolate_lru_page(page, ISOLATE_BOTH, 0) == 0) {
+				list_move(&page->lru, dst);
+				nr++;
+			} else if (do_aggressive && !PageUnevictable(page))
+					continue;
+			else
+				break;
+		}
+		/* we can't refill this order */
+		if (pfn != buddy_end_pfn)
+			break;
+		if (buddy_start_pfn < page_pfn)
+			page_pfn = buddy_start_pfn;
+	}
+	return nr;
+}
+
 /*
  * zone->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
@@ -875,14 +938,10 @@ static unsigned long isolate_lru_pages(u
 		unsigned long *scanned, int order, int mode, int file)
 {
 	unsigned long nr_taken = 0;
-	unsigned long scan;
+	unsigned long scan, nr;
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		struct page *page;
-		unsigned long pfn;
-		unsigned long end_pfn;
-		unsigned long page_pfn;
-		int zone_id;
 
 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
@@ -903,52 +962,15 @@ static unsigned long isolate_lru_pages(u
 		default:
 			BUG();
 		}
-
-		if (!order)
-			continue;
-
 		/*
-		 * Attempt to take all pages in the order aligned region
-		 * surrounding the tag page.  Only take those pages of
-		 * the same active state as that tag page.  We may safely
-		 * round the target page pfn down to the requested order
-		 * as the mem_map is guarenteed valid out to MAX_ORDER,
-		 * where that page is in a different zone we will detect
-		 * it from its zone id and abort this block scan.
+		 * Lumpy reclaim tries to free nearby pages regardless of
+		 * their lru attributes(file, active, etc..)
 		 */
-		zone_id = page_zone_id(page);
-		page_pfn = page_to_pfn(page);
-		pfn = page_pfn & ~((1 << order) - 1);
-		end_pfn = pfn + (1 << order);
-		for (; pfn < end_pfn; pfn++) {
-			struct page *cursor_page;
-
-			/* The target page is in the block, ignore it. */
-			if (unlikely(pfn == page_pfn))
-				continue;
-
-			/* Avoid holes within the zone. */
-			if (unlikely(!pfn_valid_within(pfn)))
-				break;
-
-			cursor_page = pfn_to_page(pfn);
-
-			/* Check that we have not crossed a zone boundary. */
-			if (unlikely(page_zone_id(cursor_page) != zone_id))
-				continue;
-			switch (__isolate_lru_page(cursor_page, mode, file)) {
-			case 0:
-				list_move(&cursor_page->lru, dst);
-				nr_taken++;
-				scan++;
-				break;
-
-			case -EBUSY:
-				/* else it is being freed elsewhere */
-				list_move(&cursor_page->lru, src);
-			default:
-				break;	/* ! on LRU or wrong list */
-			}
+		if (order && mode == ISOLATE_BOTH) {
+			/* try to reclaim pages nearby this */
+			nr = try_lumpy_reclaim(page, dst, order);
+			nr_taken += nr;
+			scan += nr;
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
