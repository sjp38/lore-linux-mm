Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 580DA6B0039
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 08:10:23 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v5 4/8] memcg: enhance memcg iterator to support predicates
Date: Tue, 18 Jun 2013 14:09:43 +0200
Message-Id: <1371557387-22434-5-git-send-email-mhocko@suse.cz>
In-Reply-To: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
References: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

The caller of the iterator might know that some nodes or even subtrees
should be skipped but there is no way to tell iterators about that so
the only choice left is to let iterators to visit each node and do the
selection outside of the iterating code. This, however, doesn't scale
well with hierarchies with many groups where only few groups are
interesting.

This patch adds mem_cgroup_iter_cond variant of the iterator with a
callback which gets called for every visited node. There are three
possible ways how the callback can influence the walk. Either the node
is visited, it is skipped but the tree walk continues down the tree or
the whole subtree of the current group is skipped.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/memcontrol.h | 48 +++++++++++++++++++++++++----
 mm/memcontrol.c            | 77 ++++++++++++++++++++++++++++++++++++----------
 mm/vmscan.c                | 16 +++-------
 3 files changed, 108 insertions(+), 33 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 065ecef..1276be3 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -41,6 +41,23 @@ struct mem_cgroup_reclaim_cookie {
 	unsigned int generation;
 };
 
+enum mem_cgroup_filter_t {
+	VISIT,		/* visit current node */
+	SKIP,		/* skip the current node and continue traversal */
+	SKIP_TREE,	/* skip the whole subtree and continue traversal */
+};
+
+/*
+ * mem_cgroup_filter_t predicate might instruct mem_cgroup_iter_cond how to
+ * iterate through the hierarchy tree. Each tree element is checked by the
+ * predicate before it is returned by the iterator. If a filter returns
+ * SKIP or SKIP_TREE then the iterator code continues traversal (with the
+ * next node down the hierarchy or the next node that doesn't belong under the
+ * memcg's subtree).
+ */
+typedef enum mem_cgroup_filter_t
+(*mem_cgroup_iter_filter)(struct mem_cgroup *memcg, struct mem_cgroup *root);
+
 #ifdef CONFIG_MEMCG
 /*
  * All "charge" functions with gfp_mask should use GFP_KERNEL or
@@ -108,9 +125,18 @@ mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
 extern void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 	struct page *oldpage, struct page *newpage, bool migration_ok);
 
-struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
-				   struct mem_cgroup *,
-				   struct mem_cgroup_reclaim_cookie *);
+struct mem_cgroup *mem_cgroup_iter_cond(struct mem_cgroup *root,
+				   struct mem_cgroup *prev,
+				   struct mem_cgroup_reclaim_cookie *reclaim,
+				   mem_cgroup_iter_filter cond);
+
+static inline struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
+				   struct mem_cgroup *prev,
+				   struct mem_cgroup_reclaim_cookie *reclaim)
+{
+	return mem_cgroup_iter_cond(root, prev, reclaim, NULL);
+}
+
 void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
 
 /*
@@ -180,7 +206,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
-bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
+enum mem_cgroup_filter_t
+mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
 		struct mem_cgroup *root);
 
 void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
@@ -295,6 +322,14 @@ static inline void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 		struct page *oldpage, struct page *newpage, bool migration_ok)
 {
 }
+static inline struct mem_cgroup *
+mem_cgroup_iter_cond(struct mem_cgroup *root,
+		struct mem_cgroup *prev,
+		struct mem_cgroup_reclaim_cookie *reclaim,
+		mem_cgroup_iter_filter cond)
+{
+	return NULL;
+}
 
 static inline struct mem_cgroup *
 mem_cgroup_iter(struct mem_cgroup *root,
@@ -358,10 +393,11 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 }
 
 static inline
-bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
+enum mem_cgroup_filter_t
+mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
 		struct mem_cgroup *root)
 {
-	return false;
+	return VISIT;
 }
 
 static inline void mem_cgroup_split_huge_fixup(struct page *head)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 90217f3..1364ca5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -959,6 +959,15 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 	return memcg;
 }
 
+static enum mem_cgroup_filter_t
+mem_cgroup_filter(struct mem_cgroup *memcg, struct mem_cgroup *root,
+		mem_cgroup_iter_filter cond)
+{
+	if (!cond)
+		return VISIT;
+	return cond(memcg, root);
+}
+
 /*
  * Returns a next (in a pre-order walk) alive memcg (with elevated css
  * ref. count) or NULL if the whole root's subtree has been visited.
@@ -966,7 +975,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
  * helper function to be used by mem_cgroup_iter
  */
 static struct mem_cgroup *__mem_cgroup_iter_next(struct mem_cgroup *root,
-		struct mem_cgroup *last_visited)
+		struct mem_cgroup *last_visited, mem_cgroup_iter_filter cond)
 {
 	struct cgroup *prev_cgroup, *next_cgroup;
 
@@ -974,10 +983,18 @@ static struct mem_cgroup *__mem_cgroup_iter_next(struct mem_cgroup *root,
 	 * Root is not visited by cgroup iterators so it needs an
 	 * explicit visit.
 	 */
-	if (!last_visited)
-		return root;
+	if (!last_visited) {
+		switch(mem_cgroup_filter(root, root, cond)) {
+		case VISIT:
+			return root;
+		case SKIP:
+			break;
+		case SKIP_TREE:
+			return NULL;
+		}
+	}
 
-	prev_cgroup = (last_visited == root) ? NULL
+	prev_cgroup = (last_visited == root || !last_visited) ? NULL
 		: last_visited->css.cgroup;
 skip_node:
 	next_cgroup = cgroup_next_descendant_pre(
@@ -993,11 +1010,30 @@ skip_node:
 	if (next_cgroup) {
 		struct mem_cgroup *mem = mem_cgroup_from_cont(
 				next_cgroup);
-		if (css_tryget(&mem->css))
-			return mem;
-		else {
+
+		switch (mem_cgroup_filter(mem, root, cond)) {
+		case SKIP:
 			prev_cgroup = next_cgroup;
 			goto skip_node;
+		case SKIP_TREE:
+			/*
+			 * cgroup_rightmost_descendant is not an optimal way to
+			 * skip through a subtree (especially for imbalanced
+			 * trees leaning to right) but that's what we have right
+			 * now. More effective solution would be traversing
+			 * right-up for first non-NULL without calling
+			 * cgroup_next_descendant_pre afterwards.
+			 */
+			prev_cgroup = cgroup_rightmost_descendant(next_cgroup);
+			goto skip_node;
+		case VISIT:
+			if (css_tryget(&mem->css))
+				return mem;
+			else {
+				prev_cgroup = next_cgroup;
+				goto skip_node;
+			}
+			break;
 		}
 	}
 
@@ -1061,6 +1097,7 @@ static void mem_cgroup_iter_update(struct mem_cgroup_reclaim_iter *iter,
  * @root: hierarchy root
  * @prev: previously returned memcg, NULL on first invocation
  * @reclaim: cookie for shared reclaim walks, NULL for full walks
+ * @cond: filter for visited nodes, NULL for no filter
  *
  * Returns references to children of the hierarchy below @root, or
  * @root itself, or %NULL after a full round-trip.
@@ -1073,9 +1110,10 @@ static void mem_cgroup_iter_update(struct mem_cgroup_reclaim_iter *iter,
  * divide up the memcgs in the hierarchy among all concurrent
  * reclaimers operating on the same zone and priority.
  */
-struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
+struct mem_cgroup *mem_cgroup_iter_cond(struct mem_cgroup *root,
 				   struct mem_cgroup *prev,
-				   struct mem_cgroup_reclaim_cookie *reclaim)
+				   struct mem_cgroup_reclaim_cookie *reclaim,
+				   mem_cgroup_iter_filter cond)
 {
 	struct mem_cgroup *memcg = NULL;
 	struct mem_cgroup *last_visited = NULL;
@@ -1092,7 +1130,9 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 	if (!root->use_hierarchy && root != root_mem_cgroup) {
 		if (prev)
 			goto out_css_put;
-		return root;
+		if (mem_cgroup_filter(root, root, cond) == VISIT)
+			return root;
+		return NULL;
 	}
 
 	rcu_read_lock();
@@ -1116,7 +1156,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 			last_visited = mem_cgroup_iter_load(iter, root, &seq);
 		}
 
-		memcg = __mem_cgroup_iter_next(root, last_visited);
+		memcg = __mem_cgroup_iter_next(root, last_visited, cond);
 
 		if (reclaim) {
 			mem_cgroup_iter_update(iter, last_visited, memcg, seq);
@@ -1127,7 +1167,11 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				reclaim->generation = iter->generation;
 		}
 
-		if (prev && !memcg)
+		/*
+		 * We have finished the whole tree walk or no group has been
+		 * visited because filter told us to skip the root node.
+		 */
+		if (!memcg && (prev || (cond && !last_visited)))
 			goto out_unlock;
 	}
 out_unlock:
@@ -1875,13 +1919,14 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
  * 	a) it is over its soft limit
  * 	b) any parent up the hierarchy is over its soft limit
  */
-bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
+enum mem_cgroup_filter_t
+mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
 		struct mem_cgroup *root)
 {
 	struct mem_cgroup *parent = memcg;
 
 	if (res_counter_soft_limit_excess(&memcg->res))
-		return true;
+		return VISIT;
 
 	/*
 	 * If any parent up to the root in the hierarchy is over its soft limit
@@ -1889,12 +1934,12 @@ bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
 	 */
 	while((parent = parent_mem_cgroup(parent))) {
 		if (res_counter_soft_limit_excess(&parent->res))
-			return true;
+			return VISIT;
 		if (parent == root)
 			break;
 	}
 
-	return false;
+	return SKIP;
 }
 
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 13d746d..79d59ec 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2145,21 +2145,16 @@ __shrink_zone(struct zone *zone, struct scan_control *sc, bool soft_reclaim)
 			.zone = zone,
 			.priority = sc->priority,
 		};
-		struct mem_cgroup *memcg;
+		struct mem_cgroup *memcg = NULL;
+		mem_cgroup_iter_filter filter = (soft_reclaim) ?
+			mem_cgroup_soft_reclaim_eligible : NULL;
 
 		nr_reclaimed = sc->nr_reclaimed;
 		nr_scanned = sc->nr_scanned;
 
-		memcg = mem_cgroup_iter(root, NULL, &reclaim);
-		do {
+		while ((memcg = mem_cgroup_iter_cond(root, memcg, &reclaim, filter))) {
 			struct lruvec *lruvec;
 
-			if (soft_reclaim &&
-			    !mem_cgroup_soft_reclaim_eligible(memcg, root)) {
-				memcg = mem_cgroup_iter(root, memcg, &reclaim);
-				continue;
-			}
-
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 
 			shrink_lruvec(lruvec, sc);
@@ -2179,8 +2174,7 @@ __shrink_zone(struct zone *zone, struct scan_control *sc, bool soft_reclaim)
 				mem_cgroup_iter_break(root, memcg);
 				break;
 			}
-			memcg = mem_cgroup_iter(root, memcg, &reclaim);
-		} while (memcg);
+		}
 
 		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
 			   sc->nr_scanned - nr_scanned,
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
