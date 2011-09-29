Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 841D79000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 17:02:08 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 04/10] mm: memcg: per-priority per-zone hierarchy scan generations
Date: Thu, 29 Sep 2011 23:00:58 +0200
Message-Id: <1317330064-28893-5-git-send-email-jweiner@redhat.com>
In-Reply-To: <1317330064-28893-1-git-send-email-jweiner@redhat.com>
References: <1317330064-28893-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Memory cgroup limit reclaim currently picks one memory cgroup out of
the target hierarchy, remembers it as the last scanned child, and
reclaims all zones in it with decreasing priority levels.

The new hierarchy reclaim code will pick memory cgroups from the same
hierarchy concurrently from different zones and priority levels, it
becomes necessary that hierarchy roots not only remember the last
scanned child, but do so for each zone and priority level.

Until now, we reclaimed memcgs like this:

    mem = mem_cgroup_iter(root)
    for each priority level:
      for each zone in zonelist:
        reclaim(mem, zone)

But subsequent patches will move the memcg iteration inside the loop
over the zones:

    for each priority level:
      for each zone in zonelist:
        mem = mem_cgroup_iter(root)
        reclaim(mem, zone)

And to keep with the original scan order - memcg -> priority -> zone -
the last scanned memcg has to be remembered per zone and per priority
level.

Furthermore, global reclaim will be switched to the hierarchy walk as
well.  Different from limit reclaim, which can just recheck the limit
after some reclaim progress, its target is to scan all memcgs for the
desired zone pages, proportional to the memcg size, and so reliably
detecting a full hierarchy round-trip will become crucial.

Currently, the code relies on one reclaimer encountering the same
memcg twice, but that is error-prone with concurrent reclaimers.
Instead, use a generation counter that is increased every time the
child with the highest ID has been visited, so that reclaimers can
stop when the generation changes.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |   65 +++++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 47 insertions(+), 18 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0ba59f6..38d195d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -121,6 +121,13 @@ struct mem_cgroup_stat_cpu {
 	unsigned long targets[MEM_CGROUP_NTARGETS];
 };
 
+struct mem_cgroup_reclaim_iter {
+	/* css_id of the last scanned hierarchy member */
+	int position;
+	/* scan generation, increased every round-trip */
+	unsigned int generation;
+};
+
 /*
  * per-zone information in memory controller.
  */
@@ -131,6 +138,8 @@ struct mem_cgroup_per_zone {
 	struct list_head	lists[NR_LRU_LISTS];
 	unsigned long		count[NR_LRU_LISTS];
 
+	struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY + 1];
+
 	struct zone_reclaim_stat reclaim_stat;
 	struct rb_node		tree_node;	/* RB tree node */
 	unsigned long long	usage_in_excess;/* Set to the value by which */
@@ -231,11 +240,6 @@ struct mem_cgroup {
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
@@ -781,9 +785,16 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 	return memcg;
 }
 
-static struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
-					  struct mem_cgroup *prev,
-					  bool reclaim)
+struct mem_cgroup_reclaim_cookie {
+	struct zone *zone;
+	int priority;
+	unsigned int generation;
+};
+
+static struct mem_cgroup *
+mem_cgroup_iter(struct mem_cgroup *root,
+		struct mem_cgroup *prev,
+		struct mem_cgroup_reclaim_cookie *reclaim)
 {
 	struct mem_cgroup *mem = NULL;
 	int id = 0;
@@ -804,10 +815,20 @@ static struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 	}
 
 	while (!mem) {
+		struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
 		struct cgroup_subsys_state *css;
 
-		if (reclaim)
-			id = root->last_scanned_child;
+		if (reclaim) {
+			int nid = zone_to_nid(reclaim->zone);
+			int zid = zone_idx(reclaim->zone);
+			struct mem_cgroup_per_zone *mz;
+
+			mz = mem_cgroup_zoneinfo(root, nid, zid);
+			iter = &mz->reclaim_iter[reclaim->priority];
+			if (prev && reclaim->generation != iter->generation)
+				return NULL;
+			id = iter->position;
+		}
 
 		rcu_read_lock();
 		css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
@@ -818,8 +839,13 @@ static struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 			id = 0;
 		rcu_read_unlock();
 
-		if (reclaim)
-			root->last_scanned_child = id;
+		if (reclaim) {
+			iter->position = id;
+			if (!css)
+				iter->generation++;
+			else if (!prev && mem)
+				reclaim->generation = iter->generation;
+		}
 
 		if (prev && !css)
 			return NULL;
@@ -842,14 +868,14 @@ static void mem_cgroup_iter_break(struct mem_cgroup *root,
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
@@ -1619,6 +1645,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
 	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
 	unsigned long excess;
 	unsigned long nr_scanned;
+	struct mem_cgroup_reclaim_cookie reclaim = {
+		.zone = zone,
+		.priority = 0,
+	};
 
 	excess = res_counter_soft_limit_excess(&root_memcg->res) >> PAGE_SHIFT;
 
@@ -1627,7 +1657,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
 		noswap = true;
 
 	while (1) {
-		victim = mem_cgroup_iter(root_memcg, victim, true);
+		victim = mem_cgroup_iter(root_memcg, victim, &reclaim);
 		if (!victim) {
 			loop++;
 			/*
@@ -4878,7 +4908,6 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		res_counter_init(&memcg->res, NULL);
 		res_counter_init(&memcg->memsw, NULL);
 	}
-	memcg->last_scanned_child = 0;
 	memcg->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&memcg->oom_notify);
 
-- 
1.7.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
