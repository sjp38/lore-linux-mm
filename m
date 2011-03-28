Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7D63A8D0048
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 19:51:45 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V2 1/2] count the soft_limit reclaim in global background reclaim
Date: Mon, 28 Mar 2011 16:51:09 -0700
Message-Id: <1301356270-26859-2-git-send-email-yinghan@google.com>
In-Reply-To: <1301356270-26859-1-git-send-email-yinghan@google.com>
References: <1301356270-26859-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

In the global background reclaim, we do soft reclaim before scanning the
per-zone LRU. However, the return value is ignored.

We would like to skip shrink_zone() if soft_limit reclaim does enough work.
Also, we need to make the memory pressure balanced across per-memcg zones,
like the logic vm-core. This patch is the first step where we start with
counting the nr_scanned and nr_reclaimed from soft_limit reclaim into the
global scan_control.

Change log v2...v1:
1. Not skipping the shrink_zone() but instead count the nr_scanned and
nr_reclaimed in the global scan_control.
2. Removed the stats into the next patch.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |    6 ++++--
 include/linux/swap.h       |    3 ++-
 mm/memcontrol.c            |   29 ++++++++++++++++++++---------
 mm/vmscan.c                |   16 +++++++++++++---
 4 files changed, 39 insertions(+), 15 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5a5ce70..01281ac 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -144,7 +144,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 }
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-						gfp_t gfp_mask);
+						gfp_t gfp_mask,
+						unsigned long *total_scanned);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -338,7 +339,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 
 static inline
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-					    gfp_t gfp_mask)
+					    gfp_t gfp_mask,
+					    unsigned long *total_scanned)
 {
 	return 0;
 }
diff --git a/include/linux/swap.h b/include/linux/swap.h
index ed6ebe6..3c6a9cd 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -257,7 +257,8 @@ extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						unsigned int swappiness,
-						struct zone *zone);
+						struct zone *zone,
+						unsigned long *nr_scanned);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4407dd0..67fff28 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1433,7 +1433,8 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
 static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 						struct zone *zone,
 						gfp_t gfp_mask,
-						unsigned long reclaim_options)
+						unsigned long reclaim_options,
+						unsigned long *total_scanned)
 {
 	struct mem_cgroup *victim;
 	int ret, total = 0;
@@ -1442,6 +1443,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
 	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
 	unsigned long excess;
+	unsigned long nr_scanned;
 
 	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
 
@@ -1484,10 +1486,12 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 			continue;
 		}
 		/* we use swappiness of local cgroup */
-		if (check_soft)
+		if (check_soft) {
 			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
-				noswap, get_swappiness(victim), zone);
-		else
+				noswap, get_swappiness(victim), zone,
+				&nr_scanned);
+			*total_scanned += nr_scanned;
+		} else
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
 						noswap, get_swappiness(victim));
 		css_put(&victim->css);
@@ -1928,7 +1932,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 		return CHARGE_WOULDBLOCK;
 
 	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
-					      gfp_mask, flags);
+					      gfp_mask, flags, NULL);
 	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
 		return CHARGE_RETRY;
 	/*
@@ -3211,7 +3215,8 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 			break;
 
 		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
-						MEM_CGROUP_RECLAIM_SHRINK);
+						MEM_CGROUP_RECLAIM_SHRINK,
+						NULL);
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 		/* Usage is reduced ? */
   		if (curusage >= oldusage)
@@ -3271,7 +3276,8 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 
 		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
 						MEM_CGROUP_RECLAIM_NOSWAP |
-						MEM_CGROUP_RECLAIM_SHRINK);
+						MEM_CGROUP_RECLAIM_SHRINK,
+						NULL);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
@@ -3285,7 +3291,8 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 }
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-					    gfp_t gfp_mask)
+					    gfp_t gfp_mask,
+					    unsigned long *total_scanned)
 {
 	unsigned long nr_reclaimed = 0;
 	struct mem_cgroup_per_zone *mz, *next_mz = NULL;
@@ -3293,6 +3300,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 	int loop = 0;
 	struct mem_cgroup_tree_per_zone *mctz;
 	unsigned long long excess;
+	unsigned long nr_scanned;
 
 	if (order > 0)
 		return 0;
@@ -3311,10 +3319,13 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 		if (!mz)
 			break;
 
+		nr_scanned = 0;
 		reclaimed = mem_cgroup_hierarchical_reclaim(mz->mem, zone,
 						gfp_mask,
-						MEM_CGROUP_RECLAIM_SOFT);
+						MEM_CGROUP_RECLAIM_SOFT,
+						&nr_scanned);
 		nr_reclaimed += reclaimed;
+		*total_scanned += nr_scanned;
 		spin_lock(&mctz->lock);
 
 		/*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 060e4c1..3755ad5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2147,9 +2147,11 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						unsigned int swappiness,
-						struct zone *zone)
+						struct zone *zone,
+						unsigned long *nr_scanned)
 {
 	struct scan_control sc = {
+		.nr_scanned = 0,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
@@ -2158,6 +2160,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 		.order = 0,
 		.mem_cgroup = mem,
 	};
+
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 
@@ -2176,6 +2179,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
+	*nr_scanned = sc.nr_scanned;
 	return sc.nr_reclaimed;
 }
 
@@ -2320,6 +2324,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long total_scanned;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
+	unsigned long nr_soft_reclaimed;
+	unsigned long nr_soft_scanned;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 1,
@@ -2409,11 +2415,15 @@ loop_again:
 
 			sc.nr_scanned = 0;
 
+			nr_soft_scanned = 0;
 			/*
 			 * Call soft limit reclaim before calling shrink_zone.
-			 * For now we ignore the return value
 			 */
-			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask);
+			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
+							order, sc.gfp_mask,
+							&nr_soft_scanned);
+			sc.nr_reclaimed += nr_soft_reclaimed;
+			total_scanned += nr_soft_scanned;
 
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
