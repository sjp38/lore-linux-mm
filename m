Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 32003900151
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 18:42:18 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH 1/5] Revert soft_limit reclaim changes under global pressure.
Date: Tue, 21 Jun 2011 15:41:26 -0700
Message-Id: <1308696090-31569-2-git-send-email-yinghan@google.com>
In-Reply-To: <1308696090-31569-1-git-send-email-yinghan@google.com>
References: <1308696090-31569-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

Two commits are reverted in this patch.

memcg: count the soft_limit reclaim in global background reclaim
memcg: add the soft_limit reclaim in global direct reclaim.

The two patches are the changes on top of existing global soft_limit
reclaim which will also be reverted in the following patch.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |    6 ++----
 include/linux/swap.h       |    3 +--
 mm/memcontrol.c            |   16 ++++------------
 mm/vmscan.c                |   31 +++++--------------------------
 4 files changed, 12 insertions(+), 44 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6a49d00..7c1450c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -147,8 +147,7 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 }
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-						gfp_t gfp_mask,
-						unsigned long *total_scanned);
+						gfp_t gfp_mask);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
 
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
@@ -361,8 +360,7 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 
 static inline
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-					    gfp_t gfp_mask,
-					    unsigned long *total_scanned)
+					    gfp_t gfp_mask);
 {
 	return 0;
 }
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 384eb5f..a5c6da5 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -257,8 +257,7 @@ extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						unsigned int swappiness,
-						struct zone *zone,
-						unsigned long *nr_scanned);
+						struct zone *zone);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6b6e65b..c98ad1b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1664,8 +1664,7 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
 
 static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_mem,
 					struct zone *zone,
-					gfp_t gfp_mask,
-					unsigned long *total_scanned)
+					gfp_t gfp_mask)
 {
 	struct mem_cgroup *victim;
 	int ret, total = 0;
@@ -1673,7 +1672,6 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_mem,
 	bool noswap = false;
 	bool is_kswapd = false;
 	unsigned long excess;
-	unsigned long nr_scanned;
 
 	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
 
@@ -1720,8 +1718,7 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_mem,
 		}
 		/* we use swappiness of local cgroup */
 		ret = mem_cgroup_shrink_node_zone(victim, gfp_mask, noswap,
-						  get_swappiness(victim), zone,
-						  &nr_scanned);
+						  get_swappiness(victim), zone);
 		css_put(&victim->css);
 		total += ret;
 		if (!res_counter_soft_limit_excess(&root_mem->res))
@@ -3527,8 +3524,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 }
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-					    gfp_t gfp_mask,
-					    unsigned long *total_scanned)
+					    gfp_t gfp_mask)
 {
 	unsigned long nr_reclaimed = 0;
 	struct mem_cgroup_per_zone *mz, *next_mz = NULL;
@@ -3536,7 +3532,6 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 	int loop = 0;
 	struct mem_cgroup_tree_per_zone *mctz;
 	unsigned long long excess;
-	unsigned long nr_scanned;
 
 	if (order > 0)
 		return 0;
@@ -3555,11 +3550,8 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 		if (!mz)
 			break;
 
-		nr_scanned = 0;
-		reclaimed = mem_cgroup_soft_reclaim(mz->mem, zone, gfp_mask,
-						&nr_scanned);
+		reclaimed = mem_cgroup_soft_reclaim(mz->mem, zone, gfp_mask);
 		nr_reclaimed += reclaimed;
-		*total_scanned += nr_scanned;
 
 		spin_lock(&mctz->lock);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 09ebf0c..7c9ed8e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2026,14 +2026,11 @@ static void shrink_zone(int priority, struct zone *zone,
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  */
-static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
+static void shrink_zones(int priority, struct zonelist *zonelist,
 					struct scan_control *sc)
 {
 	struct zoneref *z;
 	struct zone *zone;
-	unsigned long nr_soft_reclaimed;
-	unsigned long nr_soft_scanned;
-	unsigned long total_scanned = 0;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
@@ -2050,17 +2047,8 @@ static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
 				continue;	/* Let kswapd poll it */
 		}
 
-		nr_soft_scanned = 0;
-		nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
-							sc->order, sc->gfp_mask,
-							&nr_soft_scanned);
-		sc->nr_reclaimed += nr_soft_reclaimed;
-		total_scanned += nr_soft_scanned;
-
 		shrink_zone(priority, zone, sc);
 	}
-
-	return total_scanned;
 }
 
 static bool zone_reclaimable(struct zone *zone)
@@ -2125,7 +2113,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		sc->nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
-		total_scanned += shrink_zones(priority, zonelist, sc);
+		shrink_zones(priority, zonelist, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
@@ -2233,11 +2221,9 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						unsigned int swappiness,
-						struct zone *zone,
-						unsigned long *nr_scanned)
+						struct zone *zone)
 {
 	struct scan_control sc = {
-		.nr_scanned = 0,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
@@ -2266,7 +2252,6 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
-	*nr_scanned = sc.nr_scanned;
 	return sc.nr_reclaimed;
 }
 
@@ -2422,8 +2407,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long total_scanned;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
-	unsigned long nr_soft_reclaimed;
-	unsigned long nr_soft_scanned;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 1,
@@ -2516,15 +2499,11 @@ loop_again:
 
 			sc.nr_scanned = 0;
 
-			nr_soft_scanned = 0;
 			/*
 			 * Call soft limit reclaim before calling shrink_zone.
 			 */
-			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
-							order, sc.gfp_mask,
-							&nr_soft_scanned);
-			sc.nr_reclaimed += nr_soft_reclaimed;
-			total_scanned += nr_soft_scanned;
+			mem_cgroup_soft_limit_reclaim(zone, order,
+					sc.gfp_mask);
 
 			/*
 			 * We put equal pressure on every zone, unless
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
