From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060119192141.11913.9056.sendpatchset@linux.site>
In-Reply-To: <20060119192131.11913.27564.sendpatchset@linux.site>
References: <20060119192131.11913.27564.sendpatchset@linux.site>
Subject: [patch 1/6] mm: never ClearPageLRU released pages
Date: Thu, 19 Jan 2006 20:22:51 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

If vmscan finds a zero refcount page on the lru list, never ClearPageLRU it.
This means the release code need not hold ->lru_lock to stabalise PageLRU,
so that lock may be skipped entirely when releasing !PageLRU pages (because
we know PageLRU won't have been temporarily cleared by vmscan, which
was previously guaranteed by holding the lock to synchroise against vmscan).

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -823,21 +823,25 @@ static int isolate_lru_pages(int nr_to_s
 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
 
-		if (!TestClearPageLRU(page))
-			BUG();
 		list_del(&page->lru);
-		if (get_page_testone(page)) {
+		if (unlikely(get_page_testone(page))) {
 			/*
 			 * It is being freed elsewhere
 			 */
 			__put_page(page);
-			SetPageLRU(page);
 			list_add(&page->lru, src);
 			continue;
-		} else {
-			list_add(&page->lru, dst);
-			nr_taken++;
 		}
+
+		/*
+		 * Be careful not to clear PageLRU until after we're sure
+		 * the page is not being freed elsewhere -- the page release
+		 * code relies on it.
+		 */
+		if (!TestClearPageLRU(page))
+			BUG();
+		list_add(&page->lru, dst);
+		nr_taken++;
 	}
 
 	*scanned = scan;
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c
+++ linux-2.6/mm/swap.c
@@ -206,17 +206,18 @@ int lru_add_drain_all(void)
  */
 void fastcall __page_cache_release(struct page *page)
 {
-	unsigned long flags;
-	struct zone *zone = page_zone(page);
+	if (PageLRU(page)) {
+		unsigned long flags;
 
-	spin_lock_irqsave(&zone->lru_lock, flags);
-	if (TestClearPageLRU(page))
+		struct zone *zone = page_zone(page);
+		spin_lock_irqsave(&zone->lru_lock, flags);
+		if (!TestClearPageLRU(page))
+			BUG();
 		del_page_from_lru(zone, page);
-	if (page_count(page) != 0)
-		page = NULL;
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
-	if (page)
-		free_hot_page(page);
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	}
+
+	free_hot_page(page);
 }
 
 EXPORT_SYMBOL(__page_cache_release);
@@ -242,27 +243,30 @@ void release_pages(struct page **pages, 
 	pagevec_init(&pages_to_free, cold);
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
-		struct zone *pagezone;
 
 		if (!put_page_testzero(page))
 			continue;
 
-		pagezone = page_zone(page);
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irq(&zone->lru_lock);
-			zone = pagezone;
-			spin_lock_irq(&zone->lru_lock);
-		}
-		if (TestClearPageLRU(page))
+		if (PageLRU(page)) {
+			struct zone *pagezone = page_zone(page);
+			if (pagezone != zone) {
+				if (zone)
+					spin_unlock_irq(&zone->lru_lock);
+				zone = pagezone;
+				spin_lock_irq(&zone->lru_lock);
+			}
+			if (!TestClearPageLRU(page))
+				BUG();
 			del_page_from_lru(zone, page);
-		if (page_count(page) == 0) {
-			if (!pagevec_add(&pages_to_free, page)) {
+		}
+
+		if (!pagevec_add(&pages_to_free, page)) {
+			if (zone) {
 				spin_unlock_irq(&zone->lru_lock);
-				__pagevec_free(&pages_to_free);
-				pagevec_reinit(&pages_to_free);
-				zone = NULL;	/* No lock is held */
+				zone = NULL;
 			}
+			__pagevec_free(&pages_to_free);
+			pagevec_reinit(&pages_to_free);
 		}
 	}
 	if (zone)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
