Message-Id: <20070814153501.766137366@sgi.com>
References: <20070814153021.446917377@sgi.com>
Date: Tue, 14 Aug 2007 08:30:25 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 4/9] Atomic reclaim: Save irq flags in vmscan.c
Content-Disposition: inline; filename=vmscan_irqsave
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Reclaim can be called with interrupts disabled in atomic reclaim.
vmscan.c is currently using spinlock_irq(). Switch to spin_lock_irqsave().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/vmscan.c |   36 +++++++++++++++++++-----------------
 1 file changed, 19 insertions(+), 17 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-08-14 07:34:25.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-08-14 07:34:55.000000000 -0700
@@ -775,11 +775,12 @@ static unsigned long shrink_inactive_lis
 	struct pagevec pvec;
 	unsigned long nr_scanned = 0;
 	unsigned long nr_reclaimed = 0;
+	unsigned long flags;
 
 	pagevec_init(&pvec, 1);
 
 	lru_add_drain();
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irqsave(&zone->lru_lock, flags);
 	do {
 		struct page *page;
 		unsigned long nr_taken;
@@ -798,12 +799,12 @@ static unsigned long shrink_inactive_lis
 		__mod_zone_page_state(zone, NR_INACTIVE,
 						-(nr_taken - nr_active));
 		zone->pages_scanned += nr_scan;
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
 		nr_scanned += nr_scan;
 		nr_freed = shrink_page_list(&page_list, sc);
 		nr_reclaimed += nr_freed;
-		local_irq_disable();
+		local_irq_save(flags);
 		if (current_is_kswapd()) {
 			__count_zone_vm_events(PGSCAN_KSWAPD, zone, nr_scan);
 			__count_vm_events(KSWAPD_STEAL, nr_freed);
@@ -828,15 +829,15 @@ static unsigned long shrink_inactive_lis
 			else
 				add_page_to_inactive_list(zone, page);
 			if (!pagevec_add(&pvec, page)) {
-				spin_unlock_irq(&zone->lru_lock);
+				spin_unlock_irqrestore(&zone->lru_lock, flags);
 				__pagevec_release(&pvec);
-				spin_lock_irq(&zone->lru_lock);
+				spin_lock_irqsave(&zone->lru_lock, flags);
 			}
 		}
   	} while (nr_scanned < max_scan);
-	spin_unlock(&zone->lru_lock);
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
 done:
-	local_irq_enable();
+	local_irq_restore(flags);
 	pagevec_release(&pvec);
 	return nr_reclaimed;
 }
@@ -890,6 +891,7 @@ static void shrink_active_list(unsigned 
 	struct page *page;
 	struct pagevec pvec;
 	int reclaim_mapped = 0;
+	unsigned long flags;
 
 	if (sc->may_swap) {
 		long mapped_ratio;
@@ -939,12 +941,12 @@ force_reclaim_mapped:
 	}
 
 	lru_add_drain();
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irqsave(&zone->lru_lock, flags);
 	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
 			    &l_hold, &pgscanned, sc->order, ISOLATE_ACTIVE);
 	zone->pages_scanned += pgscanned;
 	__mod_zone_page_state(zone, NR_ACTIVE, -pgmoved);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
 
 	while (!list_empty(&l_hold)) {
 		reclaim_resched(sc);
@@ -963,7 +965,7 @@ force_reclaim_mapped:
 
 	pagevec_init(&pvec, 1);
 	pgmoved = 0;
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irqsave(&zone->lru_lock, flags);
 	while (!list_empty(&l_inactive)) {
 		page = lru_to_page(&l_inactive);
 		prefetchw_prev_lru_page(page, &l_inactive, flags);
@@ -976,21 +978,21 @@ force_reclaim_mapped:
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
-			spin_unlock_irq(&zone->lru_lock);
+			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			pgdeactivate += pgmoved;
 			pgmoved = 0;
 			if (buffer_heads_over_limit)
 				pagevec_strip(&pvec);
 			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
+			spin_lock_irqsave(&zone->lru_lock, flags);
 		}
 	}
 	__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
 	pgdeactivate += pgmoved;
 	if (buffer_heads_over_limit) {
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
 		pagevec_strip(&pvec);
-		spin_lock_irq(&zone->lru_lock);
+		spin_lock_irqsave(&zone->lru_lock, flags);
 	}
 
 	pgmoved = 0;
@@ -1005,16 +1007,16 @@ force_reclaim_mapped:
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
 			pgmoved = 0;
-			spin_unlock_irq(&zone->lru_lock);
+			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
+			spin_lock_irqsave(&zone->lru_lock, flags);
 		}
 	}
 	__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	__count_vm_events(PGDEACTIVATE, pgdeactivate);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
 
 	pagevec_release(&pvec);
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
