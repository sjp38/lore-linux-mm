Message-Id: <20070814153501.545101191@sgi.com>
References: <20070814153021.446917377@sgi.com>
Date: Tue, 14 Aug 2007 08:30:24 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 3/9] Make cond_rescheds conditional on __GFP_WAIT
Content-Disposition: inline; filename=vmscan_reclaim_resched
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

We cannot reschedule if we are in atomic reclaim. So make
the calls to cond_resched depending on the __GFP_WAIT flag.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/vmscan.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-08-14 07:34:18.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-08-14 07:34:25.000000000 -0700
@@ -258,6 +258,15 @@ static int may_write_to_queue(struct bac
 }
 
 /*
+ * Reschedule if we are not in atomic mode
+ */
+static void reclaim_resched(struct scan_control *sc)
+{
+	if (sc->gfp_mask & __GFP_WAIT)
+		cond_resched();
+}
+
+/*
  * We detected a synchronous write error writing a page out.  Probably
  * -ENOSPC.  We need to propagate that into the address_space for a subsequent
  * fsync(), msync() or close().
@@ -437,7 +446,7 @@ static unsigned long shrink_page_list(st
 	int pgactivate = 0;
 	unsigned long nr_reclaimed = 0;
 
-	cond_resched();
+	reclaim_resched(sc);
 
 	pagevec_init(&freed_pvec, 1);
 	while (!list_empty(page_list)) {
@@ -446,7 +455,7 @@ static unsigned long shrink_page_list(st
 		int may_enter_fs;
 		int referenced;
 
-		cond_resched();
+		reclaim_resched(sc);
 
 		page = lru_to_page(page_list);
 		list_del(&page->lru);
@@ -938,7 +947,7 @@ force_reclaim_mapped:
 	spin_unlock_irq(&zone->lru_lock);
 
 	while (!list_empty(&l_hold)) {
-		cond_resched();
+		reclaim_resched(sc);
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
 		if (page_mapped(page)) {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
