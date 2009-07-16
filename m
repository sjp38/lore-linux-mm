Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7D70B6B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 04:40:58 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G8etME032393
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Jul 2009 17:40:58 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B8F8145DE64
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:40:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FB6445DE5D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:40:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 024431DB803A
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:40:55 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9070DE38004
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:40:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 5/5] move PGDEACTIVATE modification to shrink_active_list()
In-Reply-To: <20090716173449.9D4B.A69D9226@jp.fujitsu.com>
References: <20090716173449.9D4B.A69D9226@jp.fujitsu.com>
Message-Id: <20090716174018.9D57.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Jul 2009 17:40:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Subject: move PGDEACTIVATE modification to shrink_active_list()

Pgmoved accounting in move_active_pages_to_lru() doesn't make any sense.
it can be calculated in irq enabled area.

This patch move #-of-deactivating-pages calcution to shrink_active_list().

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1217,7 +1217,6 @@ static void move_active_pages_to_lru(str
 				     struct list_head *list,
 				     enum lru_list lru)
 {
-	unsigned long pgmoved = 0;
 	struct pagevec pvec;
 	struct page *page;
 
@@ -1231,7 +1230,6 @@ static void move_active_pages_to_lru(str
 		SetPageLRU(page);
 
 		add_page_to_lru_list(zone, page, lru);
-		pgmoved++;
 
 		if (!pagevec_add(&pvec, page) || list_empty(list)) {
 			spin_unlock_irq(&zone->lru_lock);
@@ -1241,8 +1239,6 @@ static void move_active_pages_to_lru(str
 			spin_lock_irq(&zone->lru_lock);
 		}
 	}
-	if (!is_active_lru(lru))
-		__count_vm_events(PGDEACTIVATE, pgmoved);
 }
 
 static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
@@ -1257,6 +1253,7 @@ static void shrink_active_list(unsigned 
 	struct page *page;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	unsigned long nr_rotated = 0;
+	unsigned long nr_deactivate = 0;
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
@@ -1311,6 +1308,7 @@ static void shrink_active_list(unsigned 
 
 		ClearPageActive(page);	/* we are de-activating */
 		list_add(&page->lru, &l_inactive);
+		nr_deactivate++;
 	}
 
 	/*
@@ -1324,6 +1322,7 @@ static void shrink_active_list(unsigned 
 	 * get_scan_ratio.
 	 */
 	reclaim_stat->recent_rotated[!!file] += nr_rotated;
+	__count_vm_events(PGDEACTIVATE, nr_deactivate);
 
 	move_active_pages_to_lru(zone, &l_active,
 						LRU_ACTIVE + file * LRU_FILE);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
