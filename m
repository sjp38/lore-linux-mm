From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Message-Id: <20060322223258.12658.22203.sendpatchset@twins.localnet>
In-Reply-To: <20060322223107.12658.14997.sendpatchset@twins.localnet>
References: <20060322223107.12658.14997.sendpatchset@twins.localnet>
Subject: [PATCH 11/34] mm: page-replace-should_reclaim_mapped.patch
Date: Wed, 22 Mar 2006 23:33:30 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Bob Picco <bob.picco@hp.com>, Andrew Morton <akpm@osdl.org>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Move the reclaim_mapped code over to its own function so that other
reclaim policies can make use of it.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

---

 mm/vmscan.c |   86 ++++++++++++++++++++++++++++++++----------------------------
 1 file changed, 46 insertions(+), 40 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2006-03-13 20:37:32.000000000 +0100
+++ linux-2.6/mm/vmscan.c	2006-03-13 20:37:33.000000000 +0100
@@ -978,6 +978,50 @@ done:
 	pagevec_release(&pvec);
 }
 
+int should_reclaim_mapped(struct zone *zone, struct scan_control *sc)
+{
+	long mapped_ratio;
+	long distress;
+	long swap_tendency;
+
+	/*
+	 * `distress' is a measure of how much trouble we're having
+	 * reclaiming pages.  0 -> no problems.  100 -> great trouble.
+	 */
+	distress = 100 >> zone->prev_priority;
+
+	/*
+	 * The point of this algorithm is to decide when to start
+	 * reclaiming mapped memory instead of just pagecache.  Work out
+	 * how much memory
+	 * is mapped.
+	 */
+	mapped_ratio = (sc->nr_mapped * 100) / total_memory;
+
+	/*
+	 * Now decide how much we really want to unmap some pages.  The
+	 * mapped ratio is downgraded - just because there's a lot of
+	 * mapped memory doesn't necessarily mean that page reclaim
+	 * isn't succeeding.
+	 *
+	 * The distress ratio is important - we don't want to start
+	 * going oom.
+	 *
+	 * A 100% value of vm_swappiness overrides this algorithm
+	 * altogether.
+	 */
+	swap_tendency = mapped_ratio / 2 + distress + vm_swappiness;
+
+	/*
+	 * Now use this metric to decide whether to start moving mapped
+	 * memory onto the inactive list.
+	 */
+	if (swap_tendency >= 100)
+		return 1;
+
+	return 0;
+}
+
 /*
  * This moves pages from the active list to the inactive list.
  *
@@ -1009,46 +1053,8 @@ refill_inactive_zone(struct zone *zone, 
 	struct pagevec pvec;
 	int reclaim_mapped = 0;
 
-	if (unlikely(sc->may_swap)) {
-		long mapped_ratio;
-		long distress;
-		long swap_tendency;
-
-		/*
-		 * `distress' is a measure of how much trouble we're having
-		 * reclaiming pages.  0 -> no problems.  100 -> great trouble.
-		 */
-		distress = 100 >> zone->prev_priority;
-
-		/*
-		 * The point of this algorithm is to decide when to start
-		 * reclaiming mapped memory instead of just pagecache.  Work out
-		 * how much memory
-		 * is mapped.
-		 */
-		mapped_ratio = (sc->nr_mapped * 100) / total_memory;
-
-		/*
-		 * Now decide how much we really want to unmap some pages.  The
-		 * mapped ratio is downgraded - just because there's a lot of
-		 * mapped memory doesn't necessarily mean that page reclaim
-		 * isn't succeeding.
-		 *
-		 * The distress ratio is important - we don't want to start
-		 * going oom.
-		 *
-		 * A 100% value of vm_swappiness overrides this algorithm
-		 * altogether.
-		 */
-		swap_tendency = mapped_ratio / 2 + distress + vm_swappiness;
-
-		/*
-		 * Now use this metric to decide whether to start moving mapped
-		 * memory onto the inactive list.
-		 */
-		if (swap_tendency >= 100)
-			reclaim_mapped = 1;
-	}
+	if (unlikely(sc->may_swap))
+		reclaim_mapped = should_reclaim_mapped(zone, sc);
 
 	page_replace_add_drain();
 	spin_lock_irq(&zone->lru_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
