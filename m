Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id AE1ED6B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 23:39:45 -0500 (EST)
Received: by iacb35 with SMTP id b35so27622506iac.14
        for <linux-mm@kvack.org>; Wed, 28 Dec 2011 20:39:45 -0800 (PST)
Date: Wed, 28 Dec 2011 20:39:36 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3/3] mm: take pagevecs off reclaim stack
In-Reply-To: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112282037000.1362@eggly.anvils>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org

Replace pagevecs in putback_lru_pages() and move_active_pages_to_lru()
by lists of pages_to_free: then apply Konstantin Khlebnikov's
free_hot_cold_page_list() to them instead of pagevec_release().

Which simplifies the flow (no need to drop and retake lock whenever
pagevec fills up) and reduces stale addresses in stack backtraces
(which often showed through the pagevecs); but more importantly,
removes another 120 bytes from the deepest stacks in page reclaim.
Although I've not recently seen an actual stack overflow here with
a vanilla kernel, move_active_pages_to_lru() has often featured in
deep backtraces.

However, free_hot_cold_page_list() does not handle compound pages
(nor need it: a Transparent HugePage would have been split by the
time it reaches the call in shrink_page_list()), but it is possible
for putback_lru_pages() or move_active_pages_to_lru() to be left
holding the last reference on a THP, so must exclude the unlikely
compound case before putting on pages_to_free.

Remove pagevec_strip(), its work now done in move_active_pages_to_lru().
The pagevec in scan_mapping_unevictable_pages() remains in mm/vmscan.c,
but that is never on the reclaim path, and cannot be replaced by a list.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/pagevec.h |    2 -
 mm/swap.c               |   19 ------------
 mm/vmscan.c             |   58 ++++++++++++++++++++++++++------------
 3 files changed, 40 insertions(+), 39 deletions(-)

--- mmotm.orig/include/linux/pagevec.h	2011-12-22 02:53:31.000000000 -0800
+++ mmotm/include/linux/pagevec.h	2011-12-28 17:33:21.855263356 -0800
@@ -22,7 +22,6 @@ struct pagevec {
 
 void __pagevec_release(struct pagevec *pvec);
 void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
-void pagevec_strip(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
 unsigned pagevec_lookup_tag(struct pagevec *pvec,
@@ -59,7 +58,6 @@ static inline unsigned pagevec_add(struc
 	return pagevec_space(pvec);
 }
 
-
 static inline void pagevec_release(struct pagevec *pvec)
 {
 	if (pagevec_count(pvec))
--- mmotm.orig/mm/swap.c	2011-12-28 12:53:23.000000000 -0800
+++ mmotm/mm/swap.c	2011-12-28 17:37:21.071268545 -0800
@@ -23,7 +23,6 @@
 #include <linux/init.h>
 #include <linux/export.h>
 #include <linux/mm_inline.h>
-#include <linux/buffer_head.h>	/* for try_to_release_page() */
 #include <linux/percpu_counter.h>
 #include <linux/percpu.h>
 #include <linux/cpu.h>
@@ -730,24 +729,6 @@ void ____pagevec_lru_add(struct pagevec
 
 EXPORT_SYMBOL(____pagevec_lru_add);
 
-/*
- * Try to drop buffers from the pages in a pagevec
- */
-void pagevec_strip(struct pagevec *pvec)
-{
-	int i;
-
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-
-		if (page_has_private(page) && trylock_page(page)) {
-			if (page_has_private(page))
-				try_to_release_page(page, 0);
-			unlock_page(page);
-		}
-	}
-}
-
 /**
  * pagevec_lookup - gang pagecache lookup
  * @pvec:	Where the resulting pages are placed
--- mmotm.orig/mm/vmscan.c	2011-12-28 17:03:07.000000000 -0800
+++ mmotm/mm/vmscan.c	2011-12-28 17:59:24.811300757 -0800
@@ -1398,12 +1398,10 @@ putback_lru_pages(struct mem_cgroup_zone
 		  struct list_head *page_list)
 {
 	struct page *page;
-	struct pagevec pvec;
+	LIST_HEAD(pages_to_free);
 	struct zone *zone = mz->zone;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
 
-	pagevec_init(&pvec, 1);
-
 	/*
 	 * Put back any unfreeable pages.
 	 */
@@ -1427,17 +1425,24 @@ putback_lru_pages(struct mem_cgroup_zone
 			int numpages = hpage_nr_pages(page);
 			reclaim_stat->recent_rotated[file] += numpages;
 		}
-		if (!pagevec_add(&pvec, page)) {
-			spin_unlock_irq(&zone->lru_lock);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
+		if (put_page_testzero(page)) {
+			__ClearPageLRU(page);
+			__ClearPageActive(page);
+			del_page_from_lru_list(zone, page, lru);
+
+			if (unlikely(PageCompound(page))) {
+				spin_unlock_irq(&zone->lru_lock);
+				(*get_compound_page_dtor(page))(page);
+				spin_lock_irq(&zone->lru_lock);
+			} else
+				list_add(&page->lru, &pages_to_free);
 		}
 	}
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
 
 	spin_unlock_irq(&zone->lru_lock);
-	pagevec_release(&pvec);
+	free_hot_cold_page_list(&pages_to_free, 1);
 }
 
 static noinline_for_stack void
@@ -1647,13 +1652,23 @@ shrink_inactive_list(unsigned long nr_to
 
 static void move_active_pages_to_lru(struct zone *zone,
 				     struct list_head *list,
+				     struct list_head *pages_to_free,
 				     enum lru_list lru)
 {
 	unsigned long pgmoved = 0;
-	struct pagevec pvec;
 	struct page *page;
 
-	pagevec_init(&pvec, 1);
+	if (buffer_heads_over_limit) {
+		spin_unlock_irq(&zone->lru_lock);
+		list_for_each_entry(page, list, lru) {
+			if (page_has_private(page) && trylock_page(page)) {
+				if (page_has_private(page))
+					try_to_release_page(page, 0);
+				unlock_page(page);
+			}
+		}
+		spin_lock_irq(&zone->lru_lock);
+	}
 
 	while (!list_empty(list)) {
 		struct lruvec *lruvec;
@@ -1667,12 +1682,17 @@ static void move_active_pages_to_lru(str
 		list_move(&page->lru, &lruvec->lists[lru]);
 		pgmoved += hpage_nr_pages(page);
 
-		if (!pagevec_add(&pvec, page) || list_empty(list)) {
-			spin_unlock_irq(&zone->lru_lock);
-			if (buffer_heads_over_limit)
-				pagevec_strip(&pvec);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
+		if (put_page_testzero(page)) {
+			__ClearPageLRU(page);
+			__ClearPageActive(page);
+			del_page_from_lru_list(zone, page, lru);
+
+			if (unlikely(PageCompound(page))) {
+				spin_unlock_irq(&zone->lru_lock);
+				(*get_compound_page_dtor(page))(page);
+				spin_lock_irq(&zone->lru_lock);
+			} else
+				list_add(&page->lru, pages_to_free);
 		}
 	}
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
@@ -1766,12 +1786,14 @@ static void shrink_active_list(unsigned
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	move_active_pages_to_lru(zone, &l_active,
+	move_active_pages_to_lru(zone, &l_active, &l_hold,
 						LRU_ACTIVE + file * LRU_FILE);
-	move_active_pages_to_lru(zone, &l_inactive,
+	move_active_pages_to_lru(zone, &l_inactive, &l_hold,
 						LRU_BASE   + file * LRU_FILE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&zone->lru_lock);
+
+	free_hot_cold_page_list(&l_hold, 1);
 }
 
 #ifdef CONFIG_SWAP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
