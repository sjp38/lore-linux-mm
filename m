Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E368260037F
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:57:03 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 48 of 67] remove lumpy_reclaim
Message-Id: <bc5a8994fd7ceb60052c.1270691491@v2.random>
In-Reply-To: <patchbomb.1270691443@v2.random>
References: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:51:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Even with memory compaction enabled, without this patch, after:

	echo always >/sys/kernel/mm/transparent_hugepage/defrag

the system becomes unusable and swaps despite gigabytes of clean cache
available in the inactive list. Any frequent high order allocation (despite
being done with noretry/nomemalloc/nowarn) grinds the system to unusable state.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1130,7 +1130,6 @@ static unsigned long shrink_inactive_lis
 	unsigned long nr_scanned = 0;
 	unsigned long nr_reclaimed = 0;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
-	int lumpy_reclaim = 0;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1140,18 +1139,6 @@ static unsigned long shrink_inactive_lis
 			return SWAP_CLUSTER_MAX;
 	}
 
-	/*
-	 * If we need a large contiguous chunk of memory, or have
-	 * trouble getting a small set of contiguous pages, we
-	 * will reclaim both active and inactive pages.
-	 *
-	 * We use the same threshold as pageout congestion_wait below.
-	 */
-	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
-		lumpy_reclaim = 1;
-	else if (sc->order && priority < DEF_PRIORITY - 2)
-		lumpy_reclaim = 1;
-
 	pagevec_init(&pvec, 1);
 
 	lru_add_drain();
@@ -1163,12 +1150,11 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_freed;
 		unsigned long nr_active;
 		unsigned int count[NR_LRU_LISTS] = { 0, };
-		int mode = lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
 		unsigned long nr_anon;
 		unsigned long nr_file;
 
 		nr_taken = sc->isolate_pages(SWAP_CLUSTER_MAX,
-			     &page_list, &nr_scan, sc->order, mode,
+			     &page_list, &nr_scan, sc->order, ISOLATE_INACTIVE,
 				zone, sc->mem_cgroup, 0, file);
 
 		if (scanning_global_lru(sc)) {
@@ -1209,27 +1195,6 @@ static unsigned long shrink_inactive_lis
 		nr_scanned += nr_scan;
 		nr_freed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
 
-		/*
-		 * If we are direct reclaiming for contiguous pages and we do
-		 * not reclaim everything in the list, try again and wait
-		 * for IO to complete. This will stall high-order allocations
-		 * but that should be acceptable to the caller
-		 */
-		if (nr_freed < nr_taken && !current_is_kswapd() &&
-		    lumpy_reclaim) {
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
-
-			/*
-			 * The attempt at page out may have made some
-			 * of the pages active, mark them inactive again.
-			 */
-			nr_active = clear_active_flags(&page_list, count);
-			count_vm_events(PGDEACTIVATE, nr_active);
-
-			nr_freed += shrink_page_list(&page_list, sc,
-							PAGEOUT_IO_SYNC);
-		}
-
 		nr_reclaimed += nr_freed;
 
 		local_irq_disable();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
