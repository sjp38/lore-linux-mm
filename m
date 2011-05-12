Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4F50F90010F
	for <linux-mm@kvack.org>; Thu, 12 May 2011 14:47:55 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH 3/4] Implementation of soft_limit reclaim in round-robin.
Date: Thu, 12 May 2011 11:47:11 -0700
Message-Id: <1305226032-21448-4-git-send-email-yinghan@google.com>
In-Reply-To: <1305226032-21448-1-git-send-email-yinghan@google.com>
References: <1305226032-21448-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This patch re-implement the soft_limit reclaim function which it
picks up next memcg to reclaim from in a round-robin fashion.

For each memcg, we do hierarchical reclaim and checks the zone_wmark_ok()
after each iteration. There is a rate limit per each memcg on how many
pages to scan based on how much it exceeds the soft_limit.

This patch is a first step approach to switch from RB-tree based reclaim
to link-list based reclaim, and improvement on per-memcg soft_limit reclaim
algorithm is needed next.

Some test result:
Test 1:
Here I have three memcgs each doing a read on 20g file on a 32g system(no swap).
Meantime I have a program pinned a 18g anon pages under root. The hard_limit and
soft_limit is listed as container(hard_limit, soft_limit)

root: 18g anon pages w/o swap

A (20g, 2g):
soft_kswapd_steal 4265600
soft_kswapd_scan 4265600

B (20g, 2g):
soft_kswapd_steal 4265600
soft_kswapd_scan 4265600

C: (20g, 2g)
soft_kswapd_steal 4083904
soft_kswapd_scan 4083904

vmstat:
kswapd_steal 12617255

99.9% steal

This two stats shows the zone_wmark_ok is fullfilled after soft_limit
reclaim vs per-zone reclaim.

kwapd_zone_wmark_ok 1974
kswapd_soft_limit_zone_wmark_ok 1969


Test2:
Here the same memcgs but each is doing a 20g file write.

root: 18g anon pages w/o swap

A (20g, 2g):
soft_kswapd_steal 4718336
soft_kswapd_scan 4718336

B (20g, 2g):
soft_kswapd_steal 4710304
soft_kswapd_scan 4710304

C (20g, 3g);
soft_kswapd_steal 2933406
soft_kswapd_scan 5797460

kswapd_steal 15958486
77%

kswapd_zone_wmark_ok 2517
kswapd_soft_limit_zone_wmark_ok 2405

TODO:
1. We would like to do better on targeting reclaim by calculating the target
nr_to_scan per-memcg, especially combining the current heuristics with
soft_limit exceeds. How much weight we would like to put for the soft_limit
exceed, or do we want to make it configurable?

2. As decided in LSF, we need a second list of memcgs under their soft_limit
per-zone as well. This is needed to do zone balancing w/o global LRU. We
shouldn't scan the second list unless the first list exhausted.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |    3 +-
 mm/memcontrol.c            |  119 ++++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                |   25 +++++-----
 3 files changed, 131 insertions(+), 16 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6a0cffd..c7fcb26 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -145,7 +145,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 }
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-						gfp_t gfp_mask,
+						gfp_t gfp_mask, int end_zone,
+						unsigned long balance_gap,
 						unsigned long *total_scanned);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1360de6..b87ccc8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1093,6 +1093,19 @@ unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 	return MEM_CGROUP_ZSTAT(mz, lru);
 }
 
+unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup_per_zone *mz)
+{
+	unsigned long total = 0;
+
+	if (nr_swap_pages) {
+		total += MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
+		total += MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON);
+	}
+	total +=  MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_FILE);
+	total +=  MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE);
+	return total;
+}
+
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone)
 {
@@ -1528,7 +1541,14 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 			return ret;
 		total += ret;
 		if (check_soft) {
-			if (!res_counter_soft_limit_excess(&root_mem->res))
+			/*
+			 * We want to be fair for each memcg soft_limit reclaim
+			 * based on the excess.excess >> 2 is not to excessive
+			 * so as to reclaim too much, nor too less that we keep
+			 * coming back to reclaim from tis cgroup.
+			 */
+			if (!res_counter_soft_limit_excess(&root_mem->res) ||
+			    total >= (excess >> 2))
 				return total;
 		} else if (mem_cgroup_margin(root_mem))
 			return 1 + total;
@@ -3314,11 +3334,104 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 	return ret;
 }
 
+static struct mem_cgroup_per_zone *
+__mem_cgroup_next_soft_limit_node(struct mem_cgroup_list_per_zone *mclz)
+{
+	struct mem_cgroup_per_zone *mz;
+
+retry:
+	mz = NULL;
+	if (list_empty(&mclz->list))
+		goto done;
+
+	mz = list_entry(mclz->list.prev, struct mem_cgroup_per_zone,
+			soft_limit_list);
+
+	__mem_cgroup_remove_exceeded(mz->mem, mz, mclz);
+	if (!res_counter_soft_limit_excess(&mz->mem->res) ||
+		!mem_cgroup_zone_reclaimable_pages(mz) ||
+		!css_tryget(&mz->mem->css))
+		goto retry;
+done:
+	return mz;
+}
+
+static struct mem_cgroup_per_zone *
+mem_cgroup_next_soft_limit_node(struct mem_cgroup_list_per_zone *mclz)
+{
+	struct mem_cgroup_per_zone *mz;
+
+	spin_lock(&mclz->lock);
+	mz = __mem_cgroup_next_soft_limit_node(mclz);
+	spin_unlock(&mclz->lock);
+	return mz;
+}
+
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-					    gfp_t gfp_mask,
+					    gfp_t gfp_mask, int end_zone,
+					    unsigned long balance_gap,
 					    unsigned long *total_scanned)
 {
-	return 0;
+	unsigned long nr_reclaimed = 0;
+	unsigned long reclaimed;
+	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup_list_per_zone *mclz;
+	unsigned long long excess;
+	unsigned long nr_scanned;
+	int loop = 0;
+
+	/*
+	 * memcg reclaim doesn't support lumpy.
+	 */
+	if (order > 0)
+		return 0;
+
+	mclz = soft_limit_list_node_zone(zone_to_nid(zone), zone_idx(zone));
+	/*
+	 * Start from the head of list.
+	 */
+	while (!list_empty(&mclz->list)) {
+		mz = mem_cgroup_next_soft_limit_node(mclz);
+		if (!mz)
+			break;
+
+		nr_scanned = 0;
+		reclaimed = mem_cgroup_hierarchical_reclaim(mz->mem, zone,
+							gfp_mask,
+							MEM_CGROUP_RECLAIM_SOFT,
+							&nr_scanned);
+		nr_reclaimed += reclaimed;
+		*total_scanned += nr_scanned;
+
+		spin_lock(&mclz->lock);
+
+		__mem_cgroup_remove_exceeded(mz->mem, mz, mclz);
+		/*
+		 * Add it back to the list even the reclaimed equals
+		 * to zero as long as the memcg is still above its
+		 * soft_limit. It could be possible lots of pages becomes
+		 * reclaimable suddently.
+		 */
+		excess = res_counter_soft_limit_excess(&mz->mem->res);
+		__mem_cgroup_insert_exceeded(mz->mem, mz, mclz, excess);
+
+		spin_unlock(&mclz->lock);
+		css_put(&mz->mem->css);
+		loop++;
+
+		if (zone_watermark_ok_safe(zone, order,
+				high_wmark_pages(zone) + balance_gap,
+				end_zone, 0)) {
+			break;
+		}
+
+		if (loop > MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS ||
+			*total_scanned > nr_reclaimed + nr_reclaimed / 2)
+			break;
+
+	}
+
+	return nr_reclaimed;
 }
 
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 96789e0..9d79070 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2421,18 +2421,6 @@ loop_again:
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;
 
-			sc.nr_scanned = 0;
-
-			nr_soft_scanned = 0;
-			/*
-			 * Call soft limit reclaim before calling shrink_zone.
-			 */
-			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
-							order, sc.gfp_mask,
-							&nr_soft_scanned);
-			sc.nr_reclaimed += nr_soft_reclaimed;
-			total_scanned += nr_soft_scanned;
-
 			/*
 			 * We put equal pressure on every zone, unless
 			 * one zone has way too many pages free
@@ -2445,6 +2433,19 @@ loop_again:
 				(zone->present_pages +
 					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
 				KSWAPD_ZONE_BALANCE_GAP_RATIO);
+			sc.nr_scanned = 0;
+
+			nr_soft_scanned = 0;
+			/*
+			 * Call soft limit reclaim before calling shrink_zone.
+			 */
+			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
+							order, sc.gfp_mask,
+							end_zone, balance_gap,
+							&nr_soft_scanned);
+			sc.nr_reclaimed += nr_soft_reclaimed;
+			total_scanned += nr_soft_scanned;
+
 			if (!zone_watermark_ok_safe(zone, order,
 					high_wmark_pages(zone) + balance_gap,
 					end_zone, 0))
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
