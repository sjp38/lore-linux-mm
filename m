Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 624CA6B0267
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 06:58:11 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 04/11] mm: memcg: per-priority per-zone hierarchy scan generations
Date: Mon, 12 Sep 2011 12:57:21 +0200
Message-Id: <1315825048-3437-5-git-send-email-jweiner@redhat.com>
In-Reply-To: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Memory cgroup limit reclaim currently picks one memory cgroup out of
the target hierarchy, remembers it as the last scanned child, and
reclaims all zones in it with decreasing priority levels.

The new hierarchy reclaim code will pick memory cgroups from the same
hierarchy concurrently from different zones and priority levels, it
becomes necessary that hierarchy roots not only remember the last
scanned child, but do so for each zone and priority level.

Furthermore, detecting full hierarchy round-trips reliably will become
crucial, so instead of counting on one iterator site seeing a certain
memory cgroup twice, use a generation counter that is increased every
time the child with the highest ID has been visited.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/memcontrol.c |   60 +++++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 43 insertions(+), 17 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 912c7c7..f4b404e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -121,6 +121,11 @@ struct mem_cgroup_stat_cpu {
 	unsigned long targets[MEM_CGROUP_NTARGETS];
 };
 
+struct mem_cgroup_iter_state {
+	int position;
+	unsigned int generation;
+};
+
 /*
  * per-zone information in memory controller.
  */
@@ -131,6 +136,8 @@ struct mem_cgroup_per_zone {
 	struct list_head	lists[NR_LRU_LISTS];
 	unsigned long		count[NR_LRU_LISTS];
 
+	struct mem_cgroup_iter_state iter_state[DEF_PRIORITY + 1];
+
 	struct zone_reclaim_stat reclaim_stat;
 	struct rb_node		tree_node;	/* RB tree node */
 	unsigned long long	usage_in_excess;/* Set to the value by which */
@@ -231,11 +238,6 @@ struct mem_cgroup {
 	 * per zone LRU lists.
 	 */
 	struct mem_cgroup_lru_info info;
-	/*
-	 * While reclaiming in a hierarchy, we cache the last child we
-	 * reclaimed from.
-	 */
-	int last_scanned_child;
 	int last_scanned_node;
 #if MAX_NUMNODES > 1
 	nodemask_t	scan_nodes;
@@ -781,9 +783,15 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 	return memcg;
 }
 
+struct mem_cgroup_iter {
+	struct zone *zone;
+	int priority;
+	unsigned int generation;
+};
+
 static struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 					  struct mem_cgroup *prev,
-					  bool remember)
+					  struct mem_cgroup_iter *iter)
 {
 	struct mem_cgroup *mem = NULL;
 	int id = 0;
@@ -791,7 +799,7 @@ static struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 	if (!root)
 		root = root_mem_cgroup;
 
-	if (prev && !remember)
+	if (prev && !iter)
 		id = css_id(&prev->css);
 
 	if (prev && prev != root)
@@ -804,10 +812,20 @@ static struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 	}
 
 	while (!mem) {
+		struct mem_cgroup_iter_state *uninitialized_var(is);
 		struct cgroup_subsys_state *css;
 
-		if (remember)
-			id = root->last_scanned_child;
+		if (iter) {
+			int nid = zone_to_nid(iter->zone);
+			int zid = zone_idx(iter->zone);
+			struct mem_cgroup_per_zone *mz;
+
+			mz = mem_cgroup_zoneinfo(root, nid, zid);
+			is = &mz->iter_state[iter->priority];
+			if (prev && iter->generation != is->generation)
+				return NULL;
+			id = is->position;
+		}
 
 		rcu_read_lock();
 		css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
@@ -818,8 +836,13 @@ static struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 			id = 0;
 		rcu_read_unlock();
 
-		if (remember)
-			root->last_scanned_child = id;
+		if (iter) {
+			is->position = id;
+			if (!css)
+				is->generation++;
+			else if (!prev && mem)
+				iter->generation = is->generation;
+		}
 
 		if (prev && !css)
 			return NULL;
@@ -842,14 +865,14 @@ static void mem_cgroup_iter_break(struct mem_cgroup *root,
  * be used for reference counting.
  */
 #define for_each_mem_cgroup_tree(iter, root)		\
-	for (iter = mem_cgroup_iter(root, NULL, false);	\
+	for (iter = mem_cgroup_iter(root, NULL, NULL);	\
 	     iter != NULL;				\
-	     iter = mem_cgroup_iter(root, iter, false))
+	     iter = mem_cgroup_iter(root, iter, NULL))
 
 #define for_each_mem_cgroup(iter)			\
-	for (iter = mem_cgroup_iter(NULL, NULL, false);	\
+	for (iter = mem_cgroup_iter(NULL, NULL, NULL);	\
 	     iter != NULL;				\
-	     iter = mem_cgroup_iter(NULL, iter, false))
+	     iter = mem_cgroup_iter(NULL, iter, NULL))
 
 static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
 {
@@ -1619,6 +1642,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
 	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
 	unsigned long excess;
 	unsigned long nr_scanned;
+	struct mem_cgroup_iter iter = {
+		.zone = zone,
+		.priority = 0,
+	};
 
 	excess = res_counter_soft_limit_excess(&root_memcg->res) >> PAGE_SHIFT;
 
@@ -1627,7 +1654,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
 		noswap = true;
 
 	while (1) {
-		victim = mem_cgroup_iter(root_memcg, victim, true);
+		victim = mem_cgroup_iter(root_memcg, victim, &iter);
 		if (!victim) {
 			loop++;
 			/*
@@ -4878,7 +4905,6 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		res_counter_init(&memcg->res, NULL);
 		res_counter_init(&memcg->memsw, NULL);
 	}
-	memcg->last_scanned_child = 0;
 	memcg->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&memcg->oom_notify);
 
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
