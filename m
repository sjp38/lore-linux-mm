Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 93ECE6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 21:03:41 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAB23dZS023692
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Nov 2009 11:03:39 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C29E445DE4F
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:03:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BAAC45DE51
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:03:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 674FE1DB803C
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:03:38 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 09AA2E1800B
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:03:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 4/5] vmscan: Kill sc.swap_cluster_max
In-Reply-To: <20091111104744.FD3B.A69D9226@jp.fujitsu.com>
References: <20091111104744.FD3B.A69D9226@jp.fujitsu.com>
Message-Id: <20091111110217.FD47.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Nov 2009 11:03:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>

Now, All caller of reclaim use swap_cluster_max as SWAP_CLUSTER_MAX.
Then, we can remove it perfectly.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmscan.c |   26 ++++++--------------------
 1 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d0422a8..d53a934 100644
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
@@ -1833,7 +1825,6 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
 		.may_writepage = !laptop_mode,
-		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.may_unmap = 1,
 		.may_swap = 1,
@@ -1858,7 +1849,6 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = !noswap,
-		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = swappiness,
 		.order = 0,
 		.mem_cgroup = mem,
@@ -1892,7 +1882,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = !noswap,
-		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.swappiness = swappiness,
 		.order = 0,
@@ -1940,7 +1929,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 1,
 		.may_swap = 1,
-		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		/*
 		 * kswapd doesn't want to be bailed out while reclaim. because
 		 * we want to put equal scanning pressure on each zone.
@@ -2284,7 +2272,6 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 		.may_swap = 1,
 		.may_unmap = 1,
 		.may_writepage = 1,
-		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.nr_to_reclaim = nr_to_reclaim,
 		.hibernation_mode = 1,
 		.swappiness = vm_swappiness,
@@ -2458,7 +2445,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
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
