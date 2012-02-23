Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 187516B00FA
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:52:55 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1365307bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 05:52:55 -0800 (PST)
Subject: [PATCH v3 15/21] mm: handle lruvec relocks on lumpy reclaim
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 23 Feb 2012 17:52:52 +0400
Message-ID: <20120223135252.12988.50017.stgit@zurg>
In-Reply-To: <20120223133728.12988.5432.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>

Prepare for lock splitting in lumly reclaim logic.
Now move_active_pages_to_lru() and putback_inactive_pages()
can put pages into different lruvecs.

* relock book before SetPageLRU()
* update reclaim_stat pointer after relocks
* return currently locked lruvec

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |   45 +++++++++++++++++++++++++++++++++------------
 1 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a3941d1..6eeeb4b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1114,6 +1114,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		unsigned long *nr_scanned, struct scan_control *sc,
 		isolate_mode_t mode, int active, int file)
 {
+	struct lruvec *cursor_lruvec = lruvec;
 	struct list_head *src;
 	unsigned long nr_taken = 0;
 	unsigned long nr_lumpy_taken = 0;
@@ -1197,14 +1198,17 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			    !PageSwapCache(cursor_page))
 				break;
 
+			/* Switch cursor_lruvec lock for lumpy isolate */
+			if (!__lock_page_lruvec_irq(&cursor_lruvec,
+						    cursor_page))
+				continue;
+
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
 				unsigned int isolated_pages;
-				struct lruvec *cursor_lruvec;
 				int cursor_lru = page_lru(cursor_page);
 
 				list_move(&cursor_page->lru, dst);
 				isolated_pages = hpage_nr_pages(cursor_page);
-				cursor_lruvec = page_lruvec(cursor_page);
 				cursor_lruvec->pages_count[cursor_lru] -=
 								isolated_pages;
 				VM_BUG_ON((long)cursor_lruvec->
@@ -1235,6 +1239,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			}
 		}
 
+		/* Restore original lruvec lock */
+		cursor_lruvec = __relock_page_lruvec(cursor_lruvec, page);
+
 		/* If we break out of the loop above, lumpy reclaim failed */
 		if (pfn < end_pfn)
 			nr_lumpy_failed++;
@@ -1325,7 +1332,10 @@ static int too_many_isolated(struct zone *zone, int file,
 	return isolated > inactive;
 }
 
-static noinline_for_stack void
+/*
+ * Returns currently locked lruvec
+ */
+static noinline_for_stack struct lruvec *
 putback_inactive_pages(struct lruvec *lruvec,
 		       struct list_head *page_list)
 {
@@ -1347,10 +1357,13 @@ putback_inactive_pages(struct lruvec *lruvec,
 			lock_lruvec_irq(lruvec);
 			continue;
 		}
+
+		lruvec = __relock_page_lruvec(lruvec, page);
+		reclaim_stat = &lruvec->reclaim_stat;
+
 		SetPageLRU(page);
 		lru = page_lru(page);
 
-		lruvec = page_lruvec(page);
 		add_page_to_lru_list(lruvec, page, lru);
 		if (is_active_lru(lru)) {
 			int file = is_file_lru(lru);
@@ -1375,6 +1388,8 @@ putback_inactive_pages(struct lruvec *lruvec,
 	 * To save our caller's stack, now use input list for pages to free.
 	 */
 	list_splice(&pages_to_free, page_list);
+
+	return lruvec;
 }
 
 static noinline_for_stack void
@@ -1544,7 +1559,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
 	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
-	putback_inactive_pages(lruvec, &page_list);
+	lruvec = putback_inactive_pages(lruvec, &page_list);
 
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
@@ -1603,12 +1618,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
  *
  * The downside is that we have to touch page->_count against each page.
  * But we had to alter page->flags anyway.
+ *
+ * Returns currently locked lruvec
  */
 
-static void move_active_pages_to_lru(struct lruvec *lruvec,
-				     struct list_head *list,
-				     struct list_head *pages_to_free,
-				     enum lru_list lru)
+static struct lruvec *
+move_active_pages_to_lru(struct lruvec *lruvec,
+			 struct list_head *list,
+			 struct list_head *pages_to_free,
+			 enum lru_list lru)
 {
 	unsigned long pgmoved = 0;
 	struct page *page;
@@ -1630,10 +1648,11 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 
 		page = lru_to_page(list);
 
+		lruvec = __relock_page_lruvec(lruvec, page);
+
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
-		lruvec = page_lruvec(page);
 		list_move(&page->lru, &lruvec->pages_lru[lru]);
 		numpages = hpage_nr_pages(page);
 		lruvec->pages_count[lru] += numpages;
@@ -1655,6 +1674,8 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, pgmoved);
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
+
+	return lruvec;
 }
 
 static void shrink_active_list(unsigned long nr_to_scan,
@@ -1744,9 +1765,9 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	move_active_pages_to_lru(lruvec, &l_active, &l_hold,
+	lruvec = move_active_pages_to_lru(lruvec, &l_active, &l_hold,
 						LRU_ACTIVE + file * LRU_FILE);
-	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold,
+	lruvec = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold,
 						LRU_BASE   + file * LRU_FILE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	unlock_lruvec_irq(lruvec);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
