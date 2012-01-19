Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 1A07C6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 10:43:50 -0500 (EST)
Received: by werl4 with SMTP id l4so67003wer.14
        for <linux-mm@kvack.org>; Thu, 19 Jan 2012 07:43:48 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 19 Jan 2012 23:43:48 +0800
Message-ID: <CAJd=RBDpvVmSmCuvrO92pW-yX0Q_uq1-WFrcKTF+_ffcTBLJVQ@mail.gmail.com>
Subject: [RFC] mm: memcg: balance soft limit reclaim
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

In soft limit reclaim, mem cgroups sorted on RB tree are selected, beginning
with the largest excessor, to be reclaimed one after another. For a selected
memcg, reclaiming is terminated when it is no longer a excessor.

After all excessors on RB tree are scaned and reclaimed, global mem pressure
is reduced to certain extent, together with performance regressions of the
reclaimees due to pages are recycled more than needed.

A balanced reclaim is proposed in this work, in which for given mem pressure,
the number of pages to be reclaimed is shared _evenly_ by all excessors. For
a selected excessor, no more than the exceeding pages are reclaimed, but only
a fixed amount, SWAP_CLUSTER_MAX, of pages is reclaimed each time, so no more
pages are reclaimed than needed for individual memcg.

But how to achieve reclaim that is no more and no less, for given global mem
pressure? The answer is to inform soft limit reclaim how many pages required
to be recycled. With that info, excessors are reclaimed in round robin, with
reclaim budget set carefully for individuals. Once the global reclaim request
is met(no less), or no more exceeding pages availble(no more), the soft limit
reclaim stops, and in both cases global request is evenly shared.

Since it is really hard to gauge global mem pressure, though available methods
used, RFC is delivered for collecting comments and thoughts.

Thanks
Hillf
---

--- a/mm/memcontrol.c	Tue Jan 17 20:41:36 2012
+++ b/mm/memcontrol.c	Thu Jan 19 21:28:58 2012
@@ -1612,7 +1612,8 @@ bool mem_cgroup_reclaimable(struct mem_c
 static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
 				   struct zone *zone,
 				   gfp_t gfp_mask,
-				   unsigned long *total_scanned)
+				   unsigned long *total_scanned,
+				   unsigned long budget)
 {
 	struct mem_cgroup *victim = NULL;
 	int total = 0;
@@ -1626,7 +1627,9 @@ static int mem_cgroup_soft_reclaim(struc

 	excess = res_counter_soft_limit_excess(&root_memcg->res) >> PAGE_SHIFT;

-	while (1) {
+	while (total < budget) {
+		unsigned long nr_to_reclaim;
+
 		victim = mem_cgroup_iter(root_memcg, victim, &reclaim);
 		if (!victim) {
 			loop++;
@@ -1652,8 +1655,19 @@ static int mem_cgroup_soft_reclaim(struc
 		}
 		if (!mem_cgroup_reclaimable(victim, false))
 			continue;
+
+		nr_to_reclaim = res_counter_soft_limit_excess(&victim->res)
+								>> PAGE_SHIFT;
+		if (!nr_to_reclaim)
+			continue;
+		if (nr_to_reclaim > budget)
+			nr_to_reclaim = budget;
+		if (nr_to_reclaim > SWAP_CLUSTER_MAX)
+			nr_to_reclaim = SWAP_CLUSTER_MAX;
+
 		total += mem_cgroup_shrink_node_zone(victim, gfp_mask, false,
-						     zone, &nr_scanned);
+						     zone, &nr_scanned,
+						     nr_to_reclaim);
 		*total_scanned += nr_scanned;
 		if (!res_counter_soft_limit_excess(&root_memcg->res))
 			break;
@@ -3502,7 +3516,8 @@ static int mem_cgroup_resize_memsw_limit

 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 					    gfp_t gfp_mask,
-					    unsigned long *total_scanned)
+					    unsigned long *total_scanned,
+					    unsigned long nr_required)
 {
 	unsigned long nr_reclaimed = 0;
 	struct mem_cgroup_per_zone *mz, *next_mz = NULL;
@@ -3521,7 +3536,9 @@ unsigned long mem_cgroup_soft_limit_recl
 	 * keep exceeding their soft limit and putting the system under
 	 * pressure
 	 */
-	do {
+	while (nr_reclaimed < nr_required) {
+		unsigned long budget;
+
 		if (next_mz)
 			mz = next_mz;
 		else
@@ -3529,19 +3546,47 @@ unsigned long mem_cgroup_soft_limit_recl
 		if (!mz)
 			break;

+		budget = res_counter_soft_limit_excess(&mz->mem->res) >> PAGE_SHIFT;
+		if (!budget) {
+			spin_lock(&mctz->lock);
+			__mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
+			excess = res_counter_soft_limit_excess(&mz->mem->res);
+			__mem_cgroup_insert_exceeded(mz->mem, mz, mctz, excess);
+			spin_unlock(&mctz->lock);
+			css_put(&mz->mem->css);
+
+			if (mz != next_mz) {
+				/*
+				 * The current RB tree, as a whole, is no longer
+				 * noticeable in terms of excess.
+				 */
+				break;
+			}
+			/* Check for sure, no larger excessor on RB tree */
+			next_mz = NULL;
+			continue;
+		}
+		/* Setup reclaim budget for selected memcg */
+		if (budget > nr_required)
+			budget = nr_required;
+		if (budget > (SWAP_CLUSTER_MAX * 2))
+			budget = (SWAP_CLUSTER_MAX * 2);
+
 		nr_scanned = 0;
 		reclaimed = mem_cgroup_soft_reclaim(mz->mem, zone,
-						    gfp_mask, &nr_scanned);
+						    gfp_mask, &nr_scanned,
+						    budget);
 		nr_reclaimed += reclaimed;
 		*total_scanned += nr_scanned;
 		spin_lock(&mctz->lock);

 		/*
-		 * If we failed to reclaim anything from this memory cgroup
-		 * it is time to move on to the next cgroup
+		 * Beginning with the largest excessor, mem cgroups are
+		 * reclaimed one after another in round robin, and the request
+		 * from global reclaimers is evenly shared by all excessors as
+		 * reclaim budget is set for each group.
 		 */
 		next_mz = NULL;
-		if (!reclaimed) {
 			do {
 				/*
 				 * Loop until we find yet another one.
@@ -3561,7 +3606,7 @@ unsigned long mem_cgroup_soft_limit_recl
 				else /* next_mz == NULL or other memcg */
 					break;
 			} while (1);
-		}
+
 		__mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
 		excess = res_counter_soft_limit_excess(&mz->mem->res);
 		/*
@@ -3586,7 +3631,7 @@ unsigned long mem_cgroup_soft_limit_recl
 			(next_mz == NULL ||
 			loop > MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS))
 			break;
-	} while (!nr_reclaimed);
+	}
 	if (next_mz)
 		css_put(&next_mz->mem->css);
 	return nr_reclaimed;
--- a/mm/vmscan.c	Sat Jan 14 14:02:20 2012
+++ b/mm/vmscan.c	Thu Jan 19 22:07:00 2012
@@ -2245,6 +2245,8 @@ static bool shrink_zones(int priority, s
 		 * to global LRU.
 		 */
 		if (global_reclaim(sc)) {
+			unsigned long balance_gap, free;
+
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
@@ -2269,11 +2271,25 @@ static bool shrink_zones(int priority, s
 			 * and returns the number of reclaimed pages and
 			 * scanned pages. This works for global memory pressure
 			 * and balancing, not for a memcg's limit.
+			 *
+			 * And soft limit reclaim is informed with the number of
+			 * pages to be reclaimed.
 			 */
+			balance_gap = min(low_wmark_pages(zone),
+					(zone->present_pages +
+					 KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
+					KSWAPD_ZONE_BALANCE_GAP_RATIO);
+			balance_gap += high_wmark_pages(zone) +
+					(2UL << sc->order);
+			free = zone_page_state(zone, NR_FREE_PAGES);
+			if (unlikely(free >= balance_gap))
+				continue;
+
 			nr_soft_scanned = 0;
 			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
 						sc->order, sc->gfp_mask,
-						&nr_soft_scanned);
+						&nr_soft_scanned,
+						balance_gap - free);
 			sc->nr_reclaimed += nr_soft_reclaimed;
 			sc->nr_scanned += nr_soft_scanned;
 			/* need some check for avoid more shrink_zone() */
@@ -2460,11 +2476,12 @@ unsigned long try_to_free_pages(struct z
 unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
-						unsigned long *nr_scanned)
+						unsigned long *nr_scanned,
+						unsigned long nr_to_reclaim)
 {
 	struct scan_control sc = {
 		.nr_scanned = 0,
-		.nr_to_reclaim = SWAP_CLUSTER_MAX,
+		.nr_to_reclaim = nr_to_reclaim,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = !noswap,
@@ -2755,7 +2772,7 @@ loop_again:
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 			int nr_slab;
-			unsigned long balance_gap;
+			unsigned long balance_gap, free;

 			if (!populated_zone(zone))
 				continue;
@@ -2765,16 +2782,6 @@ loop_again:

 			sc.nr_scanned = 0;

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
@@ -2787,8 +2794,24 @@ loop_again:
 				(zone->present_pages +
 					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
 				KSWAPD_ZONE_BALANCE_GAP_RATIO);
+			balance_gap += high_wmark_pages(zone);
+			free = zone_page_state(zone, NR_FREE_PAGES);
+			if (unlikely(balance_gap <= free))
+				goto check_wm;
+
+			nr_soft_scanned = 0;
+			/*
+			 * Call soft limit reclaim before calling shrink_zone.
+			 */
+			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
+							order, sc.gfp_mask,
+							&nr_soft_scanned,
+							balance_gap - free);
+			sc.nr_reclaimed += nr_soft_reclaimed;
+			total_scanned += nr_soft_scanned;
+check_wm:
 			if (!zone_watermark_ok_safe(zone, order,
-					high_wmark_pages(zone) + balance_gap,
+					balance_gap,
 					end_zone, 0)) {
 				shrink_zone(priority, zone, &sc);

--- a/include/linux/memcontrol.h	Thu Jan 19 22:03:14 2012
+++ b/include/linux/memcontrol.h	Thu Jan 19 22:11:42 2012
@@ -159,7 +159,8 @@ static inline void mem_cgroup_dec_page_s

 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask,
-						unsigned long *total_scanned);
+						unsigned long *total_scanned,
+						unsigned long nr_required);
 u64 mem_cgroup_get_limit(struct mem_cgroup *memcg);

 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
@@ -369,7 +370,8 @@ static inline void mem_cgroup_dec_page_s
 static inline
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 					    gfp_t gfp_mask,
-					    unsigned long *total_scanned)
+					    unsigned long *total_scanned,
+					    unsigned long nr_required)
 {
 	return 0;
 }
--- a/include/linux/swap.h	Thu Jan 19 22:04:00 2012
+++ b/include/linux/swap.h	Thu Jan 19 22:13:00 2012
@@ -253,7 +253,8 @@ extern unsigned long try_to_free_mem_cgr
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
-						unsigned long *nr_scanned);
+						unsigned long *nr_scanned,
+						unsigned long nr_to_reclaim);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
