Date: Fri, 27 Aug 2004 21:55:50 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [PATCH] Avoid unecessary zone spinlocking on refill_inactive_zone() 
Message-ID: <20040828005550.GC4482@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Hi, 

As I've noticed in previous to the list that refill_inactive_zone does 
unecessary spinlocking by calling __release_pages() twice (while processing
l_active and later on l_inactive).

The waste happens:

1) It drops the zone lock, calls __release_pages(), which in turn call release_page(), which 
locks the same lock again. 
2) It unlocks the zone lock at the end of the function even if there is no page to be freed (which
needs to be pagevec_free'd).

Atomic operations which lock the bus are expensive, and we can avoid those.

The following patch implements a release_pages_nolock/release_pages_nl pair
of function (not the best names in the world) to take that into account 
and avoid these unecessary atomic operations. 

This is a fast path on pagecache intensive workloads (as the comment on top
of the function says), so I believe such optimization is worth.

Its important to benchmark it carefully (it survives my stress tests on multiprocessor box).

On a side note, the current accounting of inactive/active pages is broken 
in refill_inactive_zone (due to pages being freed in __release_pages). 
I plan to fix that tomorrow - should be easy as returning the number of pages
freed in __release_pages and take that into account.

Comments are appreciated.

This is against 2.6.8.1. 

diff -Nur --exclude='*.cmd' linux-2.6.7/mm/swap.c linux-2.6.7-vmscan/mm/swap.c
--- linux-2.6.8/mm/swap.c	2004-08-27 23:32:47.708904528 -0300
+++ linux-2.6.8-vmscan/mm/swap.c	2004-08-27 23:35:34.152601240 -0300
@@ -192,6 +192,49 @@
 
 EXPORT_SYMBOL(__page_cache_release);
 
+
+void release_pages_nolock(struct page **pages, int nr, struct zone *zone)
+{
+	int i;
+	struct pagevec pages_to_free;
+	int to_free = 0;
+
+
+	pagevec_init(&pages_to_free, 1);
+	for (i = 0; i < nr; i++) {
+		struct page *page = pages[i];
+
+		if (PageReserved(page) || !put_page_testzero(page))
+			continue;
+
+		if (TestClearPageLRU(page))
+			del_page_from_lru(zone, page);
+
+		if (page_count(page) == 0) {
+			if (!pagevec_add(&pages_to_free, page)) {
+				spin_unlock_irq(&zone->lru_lock);
+				to_free = 0;
+				__pagevec_free(&pages_to_free);
+				pagevec_reinit(&pages_to_free);
+				spin_lock_irq(&zone->lru_lock);
+			}
+			to_free = 1;
+		}
+			
+	}
+
+	if (to_free) {
+		spin_unlock_irq(&zone->lru_lock);
+		pagevec_free(&pages_to_free);
+		spin_lock_irq(&zone->lru_lock);
+	}
+}
+
+void release_pages_nl(struct pagevec *pvec, struct zone *zone) {
+	release_pages_nolock(pvec->pages, pagevec_count(pvec), zone);
+	pagevec_reinit(pvec);
+}
+
 /*
  * Batched page_cache_release().  Decrement the reference count on all the
  * passed pages.  If it fell to zero then remove the page from the LRU and
diff -Nur --exclude='*.cmd' linux-2.6.7/mm/vmscan.c linux-2.6.7-vmscan/mm/vmscan.c
--- linux-2.6.8/mm/vmscan.c	2004-08-27 23:32:47.714903616 -0300
+++ linux-2.6.8-vmscan/mm/vmscan.c	2004-08-27 23:31:16.410783952 -0300
@@ -74,6 +74,8 @@
 	int may_writepage;
 };
 
+void release_pages_nl(struct pagevec *, struct zone *zone);
+
 /*
  * The list of shrinker callbacks used by to apply pressure to
  * ageable caches.
@@ -753,13 +755,14 @@
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			zone->nr_inactive += pgmoved;
-			spin_unlock_irq(&zone->lru_lock);
 			pgdeactivate += pgmoved;
 			pgmoved = 0;
-			if (buffer_heads_over_limit)
+			if (buffer_heads_over_limit) {
+				spin_unlock_irq(&zone->lock);
 				pagevec_strip(&pvec);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
+				spin_lock_irq(&zone->lock);
+			}
+			release_pages_nl(&pvec, zone);
 		}
 	}
 	zone->nr_inactive += pgmoved;
@@ -782,9 +785,7 @@
 		if (!pagevec_add(&pvec, page)) {
 			zone->nr_active += pgmoved;
 			pgmoved = 0;
-			spin_unlock_irq(&zone->lru_lock);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
+			release_pages_nl(&pvec, zone);
 		}
 	}
 	zone->nr_active += pgmoved;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
