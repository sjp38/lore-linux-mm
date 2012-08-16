Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id AD2886B0072
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 16:54:20 -0400 (EDT)
Received: by mail-we0-f201.google.com with SMTP id x56so145165wey.2
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 13:54:20 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH 6/6] memcg: shrink slab during memcg reclaim
Date: Thu, 16 Aug 2012 13:54:19 -0700
Message-Id: <1345150459-31170-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org

This patch makes target reclaim shrinks slabs in addition to userpages.

Slab shrinkers determine the amount of pressure to put on slabs based on how
many pages are on lru (inversely proportional relationship). Calculate the
lru_pages correctly based on memcg lru lists instead of global lru lists.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |    8 ++++++++
 mm/memcontrol.c            |   40 ++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                |   22 +++++++++++-----------
 3 files changed, 59 insertions(+), 11 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 8d9489f..8cc221e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -182,6 +182,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						unsigned long *total_scanned);
 
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
+unsigned long mem_cgroup_get_lru_pages(struct mem_cgroup *memcg);
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
@@ -370,6 +371,13 @@ static inline
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
+
+static inline unsigned long
+mem_cgroup_get_lru_pages(struct mem_cgroup *mem)
+{
+	BUG();
+	return 0;
+}
 static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
 				struct page *newpage)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f86a763..6db5651 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1238,6 +1238,46 @@ int mem_cgroup_inactive_file_is_low(struct lruvec *lruvec)
 	return (active > inactive);
 }
 
+static inline bool mem_cgroup_can_swap(struct mem_cgroup *memcg)
+{
+	if (nr_swap_pages == 0)
+		return false;
+	if (!do_swap_account)
+		return false;
+	if (memcg->memsw_is_minimum)
+		return false;
+	return res_counter_margin(&memcg->memsw) > 0;
+}
+
+/*
+ * mem_cgroup_get_lru_pages - returns the number of lru pages under memcg's
+ * hierarchy.
+ * @root: memcg that is target of the reclaim
+ */
+unsigned long mem_cgroup_get_lru_pages(struct mem_cgroup *root)
+{
+	unsigned long nr;
+	struct mem_cgroup *memcg;
+
+	VM_BUG_ON(!root);
+
+	memcg = mem_cgroup_iter(root, NULL, NULL);
+	do {
+		nr = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_FILE)) +
+		     mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ACTIVE_FILE));
+
+		if (mem_cgroup_can_swap(memcg))
+			nr +=
+			  mem_cgroup_nr_lru_pages(memcg,
+						  BIT(LRU_INACTIVE_ANON)) +
+			  mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ACTIVE_ANON));
+
+		memcg = mem_cgroup_iter(root, memcg, NULL);
+	} while (memcg);
+
+	return nr;
+}
+
 #define mem_cgroup_from_res_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7a3a1a4..191c83e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2087,6 +2087,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	struct zone *zone;
 	unsigned long writeback_threshold;
 	bool aborted_reclaim;
+	unsigned long lru_pages;
 
 	delayacct_freepages_start();
 
@@ -2095,14 +2096,10 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 	do {
 		sc->nr_scanned = 0;
+		lru_pages = 0;
 		aborted_reclaim = shrink_zones(zonelist, sc);
 
-		/*
-		 * Don't shrink slabs when reclaiming memory from
-		 * over limit cgroups
-		 */
 		if (global_reclaim(sc)) {
-			unsigned long lru_pages = 0;
 			for_each_zone_zonelist(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask)) {
 				if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
@@ -2110,12 +2107,15 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 				lru_pages += zone_reclaimable_pages(zone);
 			}
-			shrink->priority = sc->priority;
-			shrink_slab(shrink, sc->nr_scanned, lru_pages);
-			if (reclaim_state) {
-				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-				reclaim_state->reclaimed_slab = 0;
-			}
+		} else
+			lru_pages =
+			       mem_cgroup_get_lru_pages(sc->target_mem_cgroup);
+
+		shrink->priority = sc->priority;
+		shrink_slab(shrink, sc->nr_scanned, lru_pages);
+		if (reclaim_state) {
+			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
+			reclaim_state->reclaimed_slab = 0;
 		}
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
