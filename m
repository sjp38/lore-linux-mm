Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9C6A56B007B
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 10:12:06 -0500 (EST)
Date: Mon, 2 Nov 2009 00:12:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCHv2 4/5] vmscan: Kill sc.swap_cluster_max
In-Reply-To: <20091101234614.F401.A69D9226@jp.fujitsu.com>
References: <20091101234614.F401.A69D9226@jp.fujitsu.com>
Message-Id: <20091102001110.F40A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Now, all caller is settng to swap_cluster_max = SWAP_CLUSTER_MAX.
Then, we can remove it perfectly.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   26 ++++++--------------------
 1 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e463d48..7bdf4f0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -71,12 +71,6 @@ struct scan_control {
 	/* Can pages be swapped as part of reclaim? */
 	int may_swap;
 
-	/* This context's SWAP_CLUSTER_MAX. If freeing memory for
-	 * suspend, we effectively ignore SWAP_CLUSTER_MAX.
-	 * In this context, it doesn't matter that we scan the
-	 * whole list at once. */
-	int swap_cluster_max;
-
 	int swappiness;
 
 	int all_unreclaimable;
@@ -1127,7 +1121,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		unsigned long nr_anon;
 		unsigned long nr_file;
 
-		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
+		nr_taken = sc->isolate_pages(SWAP_CLUSTER_MAX,
 			     &page_list, &nr_scan, sc->order, mode,
 				zone, sc->mem_cgroup, 0, file);
 
@@ -1562,15 +1556,14 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
  * until we collected @swap_cluster_max pages to scan.
  */
 static unsigned long nr_scan_try_batch(unsigned long nr_to_scan,
-				       unsigned long *nr_saved_scan,
-				       unsigned long swap_cluster_max)
+				       unsigned long *nr_saved_scan)
 {
 	unsigned long nr;
 
 	*nr_saved_scan += nr_to_scan;
 	nr = *nr_saved_scan;
 
-	if (nr >= swap_cluster_max)
+	if (nr >= SWAP_CLUSTER_MAX)
 		*nr_saved_scan = 0;
 	else
 		nr = 0;
@@ -1589,7 +1582,6 @@ static void shrink_zone(int priority, struct zone *zone,
 	unsigned long percent[2];	/* anon @ 0; file @ 1 */
 	enum lru_list l;
 	unsigned long nr_reclaimed = sc->nr_reclaimed;
-	unsigned long swap_cluster_max = sc->swap_cluster_max;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	int noswap = 0;
@@ -1612,8 +1604,7 @@ static void shrink_zone(int priority, struct zone *zone,
 			scan = (scan * percent[file]) / 100;
 		}
 		nr[l] = nr_scan_try_batch(scan,
-					  &reclaim_stat->nr_saved_scan[l],
-					  swap_cluster_max);
+					  &reclaim_stat->nr_saved_scan[l]);
 	}
 
 	trace_printk("sz p=%d %d:%s %lu:%lu [%lu %lu %lu %lu] \n",
@@ -1625,7 +1616,8 @@ static void shrink_zone(int priority, struct zone *zone,
 					nr[LRU_INACTIVE_FILE]) {
 		for_each_evictable_lru(l) {
 			if (nr[l]) {
-				nr_to_scan = min(nr[l], swap_cluster_max);
+				nr_to_scan = min_t(unsigned long,
+						   nr[l], SWAP_CLUSTER_MAX);
 				nr[l] -= nr_to_scan;
 
 				nr_reclaimed += shrink_list(l, nr_to_scan,
@@ -1834,7 +1826,6 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
 		.may_writepage = !laptop_mode,
-		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.may_unmap = 1,
 		.may_swap = 1,
@@ -1859,7 +1850,6 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = !noswap,
-		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = swappiness,
 		.order = 0,
 		.mem_cgroup = mem,
@@ -1893,7 +1883,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = !noswap,
-		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.swappiness = swappiness,
 		.order = 0,
@@ -1941,7 +1930,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 1,
 		.may_swap = 1,
-		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.nr_to_reclaim = ULONG_MAX,
 		.swappiness = vm_swappiness,
 		.order = order,
@@ -2281,7 +2269,6 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 		.may_swap = 1,
 		.may_unmap = 1,
 		.may_writepage = 1,
-		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.nr_to_reclaim = nr_to_reclaim,
 		.hibernation_mode = 1,
 		.swappiness = vm_swappiness,
@@ -2455,7 +2442,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.may_swap = 1,
-		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.nr_to_reclaim = max_t(unsigned long, nr_pages,
 				       SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
