Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 940C96B004D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 10:08:48 -0500 (EST)
Date: Mon, 2 Nov 2009 00:08:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCHv2 1/5] vmscan: separate sc.swap_cluster_max and sc.nr_max_reclaim
Message-Id: <20091101234614.F401.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Currently, sc.scap_cluster_max has double meanings.

 1) reclaim batch size as isolate_lru_pages()'s argument
 2) reclaim baling out thresolds

The two meanings pretty unrelated. Thus, Let's separate it.
this patch doesn't change any behavior.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f805958..6a3eb9f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -55,6 +55,9 @@ struct scan_control {
 	/* Number of pages freed so far during a call to shrink_zones() */
 	unsigned long nr_reclaimed;
 
+	/* How many pages shrink_list() should reclaim */
+	unsigned long nr_to_reclaim;
+
 	/* This context's GFP mask */
 	gfp_t gfp_mask;
 
@@ -1585,6 +1588,7 @@ static void shrink_zone(int priority, struct zone *zone,
 	enum lru_list l;
 	unsigned long nr_reclaimed = sc->nr_reclaimed;
 	unsigned long swap_cluster_max = sc->swap_cluster_max;
+	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	int noswap = 0;
 
@@ -1634,8 +1638,7 @@ static void shrink_zone(int priority, struct zone *zone,
 		 * with multiple processes reclaiming pages, the total
 		 * freeing target can get unreasonably large.
 		 */
-		if (nr_reclaimed > swap_cluster_max &&
-			priority < DEF_PRIORITY && !current_is_kswapd())
+		if (nr_reclaimed > nr_to_reclaim && priority < DEF_PRIORITY)
 			break;
 	}
 
@@ -1733,6 +1736,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	struct zoneref *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
+	unsigned long writeback_threshold;
 
 	delayacct_freepages_start();
 
@@ -1768,7 +1772,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 			}
 		}
 		total_scanned += sc->nr_scanned;
-		if (sc->nr_reclaimed >= sc->swap_cluster_max) {
+		if (sc->nr_reclaimed >= sc->nr_to_reclaim) {
 			ret = sc->nr_reclaimed;
 			goto out;
 		}
@@ -1780,8 +1784,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		 * that's undesirable in laptop mode, where we *want* lumpy
 		 * writeout.  So in laptop mode, write out the whole world.
 		 */
-		if (total_scanned > sc->swap_cluster_max +
-					sc->swap_cluster_max / 2) {
+		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
+		if (total_scanned > writeback_threshold) {
 			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned);
 			sc->may_writepage = 1;
 		}
@@ -1827,6 +1831,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.gfp_mask = gfp_mask,
 		.may_writepage = !laptop_mode,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
+		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.may_unmap = 1,
 		.may_swap = 1,
 		.swappiness = vm_swappiness,
@@ -1885,6 +1890,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 		.may_unmap = 1,
 		.may_swap = !noswap,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
+		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.swappiness = swappiness,
 		.order = 0,
 		.mem_cgroup = mem_cont,
@@ -1932,6 +1938,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 		.may_unmap = 1,
 		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
+		.nr_to_reclaim = ULONG_MAX,
 		.swappiness = vm_swappiness,
 		.order = order,
 		.mem_cgroup = NULL,
@@ -2549,7 +2556,9 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.may_swap = 1,
 		.swap_cluster_max = max_t(unsigned long, nr_pages,
-					SWAP_CLUSTER_MAX),
+				       SWAP_CLUSTER_MAX),
+		.nr_to_reclaim = max_t(unsigned long, nr_pages,
+				       SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,
 		.swappiness = vm_swappiness,
 		.order = order,
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
