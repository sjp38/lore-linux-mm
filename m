Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id CE3926B0109
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:23:53 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:23:53 -0800 (PST)
Subject: [PATCH v2 20/22] mm: optimize putback for 0-order reclaim
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:23:50 +0400
Message-ID: <20120220172350.22196.24003.stgit@zurg>
In-Reply-To: <20120220171138.22196.65847.stgit@zurg>
References: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

At 0-order reclaim all pages are isolated from one lruvec,
thus we don't need to recheck and relock page_lruvec on putback.

Maybe it would be better to collect lumpy-isolated pages into
separate list and handle them independently.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 39b4525..b9bd6c7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1342,6 +1342,7 @@ static int too_many_isolated(struct zone *zone, int file,
  */
 static noinline_for_stack struct lruvec *
 putback_inactive_pages(struct lruvec *lruvec,
+		       struct scan_control *sc,
 		       struct list_head *page_list)
 {
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
@@ -1364,8 +1365,10 @@ putback_inactive_pages(struct lruvec *lruvec,
 		}
 
 		/* can differ only on lumpy reclaim */
-		lruvec = __relock_page_lruvec(lruvec, page);
-		reclaim_stat = &lruvec->reclaim_stat;
+		if (sc->order) {
+			lruvec = __relock_page_lruvec(lruvec, page);
+			reclaim_stat = &lruvec->reclaim_stat;
+		}
 
 		SetPageLRU(page);
 		lru = page_lru(page);
@@ -1565,7 +1568,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
 	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
-	lruvec = putback_inactive_pages(lruvec, &page_list);
+	lruvec = putback_inactive_pages(lruvec, sc, &page_list);
 
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
@@ -1630,6 +1633,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 static struct lruvec *
 move_active_pages_to_lru(struct lruvec *lruvec,
+			 struct scan_control *sc,
 			 struct list_head *list,
 			 struct list_head *pages_to_free,
 			 enum lru_list lru)
@@ -1655,7 +1659,8 @@ move_active_pages_to_lru(struct lruvec *lruvec,
 		page = lru_to_page(list);
 
 		/* can differ only on lumpy reclaim */
-		lruvec = __relock_page_lruvec(lruvec, page);
+		if (sc->order)
+			lruvec = __relock_page_lruvec(lruvec, page);
 
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
@@ -1771,9 +1776,9 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	lruvec = move_active_pages_to_lru(lruvec, &l_active, &l_hold,
+	lruvec = move_active_pages_to_lru(lruvec, sc, &l_active, &l_hold,
 						LRU_ACTIVE + file * LRU_FILE);
-	lruvec = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold,
+	lruvec = move_active_pages_to_lru(lruvec, sc, &l_inactive, &l_hold,
 						LRU_BASE   + file * LRU_FILE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	unlock_lruvec_irq(lruvec);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
