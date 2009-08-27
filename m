Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 347D26B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 00:39:02 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7R4d3qY030354
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 27 Aug 2009 13:39:03 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C32F745DE51
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 13:39:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 94EB845DE4F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 13:39:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8059D1DB803E
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 13:39:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D72C1DB803A
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 13:39:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] vmscan: move PGDEACTIVATE modification to shrink_active_list()
Message-Id: <20090827133727.398B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 27 Aug 2009 13:39:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Pgmoved accounting in move_active_pages_to_lru() doesn't make any sense.
it can be calculated in irq enabled area.

This patch move #-of-deactivating-pages calcution to shrink_active_list().
Fortunatelly, it also kill one branch.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 848689a..9618170 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1270,7 +1270,6 @@ static void move_active_pages_to_lru(struct zone *zone,
 				     struct list_head *list,
 				     enum lru_list lru)
 {
-	unsigned long pgmoved = 0;
 	struct pagevec pvec;
 	struct page *page;
 
@@ -1284,7 +1283,6 @@ static void move_active_pages_to_lru(struct zone *zone,
 
 		list_move(&page->lru, &zone->lru[lru].list);
 		mem_cgroup_add_lru_list(page, lru);
-		pgmoved++;
 
 		if (!pagevec_add(&pvec, page) || list_empty(list)) {
 			spin_unlock_irq(&zone->lru_lock);
@@ -1294,9 +1292,6 @@ static void move_active_pages_to_lru(struct zone *zone,
 			spin_lock_irq(&zone->lru_lock);
 		}
 	}
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
-	if (!is_active_lru(lru))
-		__count_vm_events(PGDEACTIVATE, pgmoved);
 }
 
 static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
@@ -1311,6 +1306,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	struct page *page;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	unsigned long nr_rotated = 0;
+	unsigned long nr_deactivated = 0;
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
@@ -1365,12 +1361,18 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 
 		ClearPageActive(page);	/* we are de-activating */
 		list_add(&page->lru, &l_inactive);
+		nr_deactivated++;
 	}
 
 	/*
 	 * Move pages back to the lru list.
 	 */
 	spin_lock_irq(&zone->lru_lock);
+	move_active_pages_to_lru(zone, &l_active,
+						LRU_ACTIVE + file * LRU_FILE);
+	move_active_pages_to_lru(zone, &l_inactive,
+						LRU_BASE   + file * LRU_FILE);
+
 	/*
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
@@ -1378,12 +1380,10 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	 * get_scan_ratio.
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
-
-	move_active_pages_to_lru(zone, &l_active,
-						LRU_ACTIVE + file * LRU_FILE);
-	move_active_pages_to_lru(zone, &l_inactive,
-						LRU_BASE   + file * LRU_FILE);
+	__count_vm_events(PGDEACTIVATE, nr_deactivated);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
+	__mod_zone_page_state(zone, LRU_ACTIVE + file * LRU_FILE, nr_rotated);
+	__mod_zone_page_state(zone, LRU_BASE + file * LRU_FILE, nr_deactivated);
 	spin_unlock_irq(&zone->lru_lock);
 }
 
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
