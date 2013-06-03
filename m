Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id E5C2C6B0080
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 06:19:13 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [patch -v4 4/8] memcg: enhance memcg iterator to support predicates
Date: Mon,  3 Jun 2013 12:18:51 +0200
Message-Id: <1370254735-13012-5-git-send-email-mhocko@suse.cz>
In-Reply-To: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
References: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>

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

TODO is it correct to reclaim + cond together? What if the cache simply
skips interesting nodes which another predicate would find interesting?

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/memcontrol.h |   40 +++++++++++++++++++++----
 mm/memcontrol.c            |   69 ++++++++++++++++++++++++++++++++++----------
 mm/vmscan.c                |   16 ++++------
 3 files changed, 92 insertions(+), 33 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 80ed1b6..811967a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -41,6 +41,15 @@ struct mem_cgroup_reclaim_cookie {
 	unsigned int generation;
 };
 
+enum mem_cgroup_filter_t {
+	VISIT,
+	SKIP,
+	SKIP_TREE,
+};
+
+typedef enum mem_cgroup_filter_t
+(*mem_cgroup_iter_filter)(struct mem_cgroup *memcg, struct mem_cgroup *root);
+
 #ifdef CONFIG_MEMCG
 /*
  * All "charge" functions with gfp_mask should use GFP_KERNEL or
@@ -107,9 +116,18 @@ mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
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
@@ -179,7 +197,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
-bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
+enum mem_cgroup_filter_t
+mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
 		struct mem_cgroup *root);
 
 void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
@@ -294,6 +313,14 @@ static inline void mem_cgroup_end_migration(struct mem_cgroup *memcg,
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
@@ -357,10 +384,11 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
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
index 9f8dd37..da7ea80 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -969,6 +969,15 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
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
@@ -976,7 +985,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
  * helper function to be used by mem_cgroup_iter
  */
 static struct mem_cgroup *__mem_cgroup_iter_next(struct mem_cgroup *root,
-		struct mem_cgroup *last_visited)
+		struct mem_cgroup *last_visited, mem_cgroup_iter_filter cond)
 {
 	struct cgroup *prev_cgroup, *next_cgroup;
 
@@ -984,10 +993,18 @@ static struct mem_cgroup *__mem_cgroup_iter_next(struct mem_cgroup *root,
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
@@ -1003,11 +1020,22 @@ skip_node:
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
 
@@ -1019,6 +1047,7 @@ skip_node:
  * @root: hierarchy root
  * @prev: previously returned memcg, NULL on first invocation
  * @reclaim: cookie for shared reclaim walks, NULL for full walks
+ * @cond: filter for visited nodes, NULL for no filter
  *
  * Returns references to children of the hierarchy below @root, or
  * @root itself, or %NULL after a full round-trip.
@@ -1031,9 +1060,10 @@ skip_node:
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
@@ -1051,7 +1081,9 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 	if (!root->use_hierarchy && root != root_mem_cgroup) {
 		if (prev)
 			goto out_css_put;
-		return root;
+		if (mem_cgroup_filter(root, root, cond) == VISIT)
+			return root;
+		return NULL;
 	}
 
 	rcu_read_lock();
@@ -1094,7 +1126,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 			}
 		}
 
-		memcg = __mem_cgroup_iter_next(root, last_visited);
+		memcg = __mem_cgroup_iter_next(root, last_visited, cond);
 
 		if (reclaim) {
 			if (last_visited)
@@ -1110,7 +1142,11 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
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
@@ -1857,13 +1893,14 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
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
@@ -1871,12 +1908,12 @@ bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
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
index e21c1aa..10bcbc2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1964,21 +1964,16 @@ __shrink_zone(struct zone *zone, struct scan_control *sc, bool soft_reclaim)
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
@@ -1998,8 +1993,7 @@ __shrink_zone(struct zone *zone, struct scan_control *sc, bool soft_reclaim)
 				mem_cgroup_iter_break(root, memcg);
 				break;
 			}
-			memcg = mem_cgroup_iter(root, memcg, &reclaim);
-		} while (memcg);
+		}
 
 		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
 			   sc->nr_scanned - nr_scanned,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
