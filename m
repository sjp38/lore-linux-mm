Date: Wed, 27 Apr 2005 11:09:10 -0400
From: Martin Hicks <mort@sgi.com>
Subject: [PATCH/RFC 1/4] VM: merge_lru_pages
Message-ID: <20050427150910.GS8018@localhost>
References: <20050427145734.GL8018@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050427145734.GL8018@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Linux-MM <linux-mm@kvack.org>
Cc: Ray Bryant <raybry@sgi.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>


Just a refactoring patch that sticks a list of pages back onto
the appropriate LRU lists.  This is used to return pages to the
LRU lists after processing them outside the LRU lock.

Signed-off-by:  Martin Hicks <mort@sgi.com>
---

 vmscan.c |   62 ++++++++++++++++++++++++++++++++++++++------------------------
 1 files changed, 38 insertions(+), 24 deletions(-)

Index: linux-2.6.12-rc2.wk/mm/vmscan.c
===================================================================
--- linux-2.6.12-rc2.wk.orig/mm/vmscan.c	2005-04-20 09:00:04.000000000 -0700
+++ linux-2.6.12-rc2.wk/mm/vmscan.c	2005-04-27 06:56:48.000000000 -0700
@@ -610,20 +610,50 @@ static int isolate_lru_pages(int nr_to_s
 }
 
 /*
+ * This is the opposite of isolate_lru_pages().  It puts the
+ * pages in @list back onto the lru lists in @zone.
+ */
+void merge_lru_pages(struct zone *zone, struct list_head *list)
+{
+	struct page *page;
+	struct pagevec pvec;
+
+	BUG_ON(zone == NULL);
+	BUG_ON(list == NULL);
+
+	pagevec_init(&pvec, 1);
+
+	while (!list_empty(list)) {
+		page = lru_to_page(list);
+		if (TestSetPageLRU(page))
+			BUG();
+		list_del(&page->lru);
+		if (PageActive(page))
+			add_page_to_active_list(zone, page);
+		else
+			add_page_to_inactive_list(zone, page);
+		if (!pagevec_add(&pvec, page)) {
+			spin_unlock_irq(&zone->lru_lock);
+			__pagevec_release(&pvec);
+			spin_lock_irq(&zone->lru_lock);
+		}
+	}
+	spin_unlock_irq(&zone->lru_lock);
+	pagevec_release(&pvec);
+	spin_lock_irq(&zone->lru_lock);
+}
+
+/*
  * shrink_cache() adds the number of pages reclaimed to sc->nr_reclaimed
  */
 static void shrink_cache(struct zone *zone, struct scan_control *sc)
 {
 	LIST_HEAD(page_list);
-	struct pagevec pvec;
 	int max_scan = sc->nr_to_scan;
 
-	pagevec_init(&pvec, 1);
-
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	while (max_scan > 0) {
-		struct page *page;
 		int nr_taken;
 		int nr_scan;
 		int nr_freed;
@@ -636,7 +666,7 @@ static void shrink_cache(struct zone *zo
 		spin_unlock_irq(&zone->lru_lock);
 
 		if (nr_taken == 0)
-			goto done;
+			return;
 
 		max_scan -= nr_scan;
 		if (current_is_kswapd())
@@ -649,29 +679,13 @@ static void shrink_cache(struct zone *zo
 		mod_page_state_zone(zone, pgsteal, nr_freed);
 		sc->nr_to_reclaim -= nr_freed;
 
-		spin_lock_irq(&zone->lru_lock);
 		/*
 		 * Put back any unfreeable pages.
 		 */
-		while (!list_empty(&page_list)) {
-			page = lru_to_page(&page_list);
-			if (TestSetPageLRU(page))
-				BUG();
-			list_del(&page->lru);
-			if (PageActive(page))
-				add_page_to_active_list(zone, page);
-			else
-				add_page_to_inactive_list(zone, page);
-			if (!pagevec_add(&pvec, page)) {
-				spin_unlock_irq(&zone->lru_lock);
-				__pagevec_release(&pvec);
-				spin_lock_irq(&zone->lru_lock);
-			}
-		}
-  	}
+		spin_lock_irq(&zone->lru_lock);
+		merge_lru_pages(zone, &page_list);
+	}
 	spin_unlock_irq(&zone->lru_lock);
-done:
-	pagevec_release(&pvec);
 }
 
 /*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
