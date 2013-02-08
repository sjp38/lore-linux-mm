Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id ADD376B000C
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 08:07:40 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 5/7] list_lru: per-memcg walks
Date: Fri,  8 Feb 2013 17:07:35 +0400
Message-Id: <1360328857-28070-6-git-send-email-glommer@parallels.com>
In-Reply-To: <1360328857-28070-1-git-send-email-glommer@parallels.com>
References: <1360328857-28070-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Dave Shrinnker <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, Glauber Costa <glommer@parallels.com>, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

This patch extend the list_lru interfaces to allow for a memcg
parameter. Because most of its users won't need it, instead of
modifying the function signatures we create a new set of _memcg()
functions and write the old API ontop of that.

At this point, the infrastructure is mostly in place. We already walk
the nodes using all memcg indexes, so we just need to make sure we skip
all but the one we're interested in. We could just go directly to the
memcg of interest, but I am assuming that given the gained simplicity,
spending a few cycles here won't hurt *that* much (but that can be
improved if needed, of course).

Signed-off-by: Glauber Costa <glommer@parallels.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/list_lru.h | 24 ++++++++++++++++++++----
 lib/list_lru.c           | 41 ++++++++++++++++++++++++++++++++---------
 2 files changed, 52 insertions(+), 13 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 5d8f7ab..c7e6115 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -81,20 +81,36 @@ lru_node_of_index(struct list_lru *lru, int index, int nid);
 int list_lru_init(struct list_lru *lru);
 int list_lru_add(struct list_lru *lru, struct list_head *item);
 int list_lru_del(struct list_lru *lru, struct list_head *item);
-long list_lru_count_nodemask(struct list_lru *lru, nodemask_t *nodes_to_count);
+
+long list_lru_count_nodemask_memcg(struct list_lru *lru,
+			nodemask_t *nodes_to_count, struct mem_cgroup *memcg);
+
+static inline long
+list_lru_count_nodemask(struct list_lru *lru, nodemask_t *nodes_to_count)
+{
+	return list_lru_count_nodemask_memcg(lru, nodes_to_count, NULL);
+}
 
 static inline long list_lru_count(struct list_lru *lru)
 {
 	return list_lru_count_nodemask(lru, &lru->active_nodes);
 }
 
-
 typedef int (*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock,
 				void *cb_arg);
 typedef void (*list_lru_dispose_cb)(struct list_head *dispose_list);
 
-long list_lru_walk_nodemask(struct list_lru *lru, list_lru_walk_cb isolate,
-		   void *cb_arg, long nr_to_walk, nodemask_t *nodes_to_walk);
+long list_lru_walk_nodemask_memcg(struct list_lru *lru,
+	list_lru_walk_cb isolate, void *cb_arg, long nr_to_walk,
+	nodemask_t *nodes_to_walk, struct mem_cgroup *memcg);
+
+static inline long list_lru_walk_nodemask(struct list_lru *lru,
+	list_lru_walk_cb isolate, void *cb_arg, long nr_to_walk,
+	nodemask_t *nodes_to_walk)
+{
+	return list_lru_walk_nodemask_memcg(lru, isolate, cb_arg, nr_to_walk,
+					    &lru->active_nodes, NULL);
+}
 
 static inline long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
 				 void *cb_arg, long nr_to_walk)
diff --git a/lib/list_lru.c b/lib/list_lru.c
index 1d16404..e2bbde6 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -86,25 +86,44 @@ list_lru_del(
 EXPORT_SYMBOL_GPL(list_lru_del);
 
 long
-list_lru_count_nodemask(
+list_lru_count_nodemask_memcg(
 	struct list_lru *lru,
-	nodemask_t	*nodes_to_count)
+	nodemask_t	*nodes_to_count,
+	struct mem_cgroup *memcg)
 {
 	long count = 0;
 	int nid;
+	nodemask_t nodes;
+	struct list_lru_node *nlru;
+	int memcg_id = memcg_cache_id(memcg);
+
+	/*
+	 * Conservative code can call this setting nodes with node_setall.
+	 * This will generate an out of bound access for memcg.
+	 */
+	nodes_and(nodes, *nodes_to_count, node_online_map);
 
-	for_each_node_mask(nid, *nodes_to_count) {
+	for_each_node_mask(nid, nodes) {
 		/*
 		 * We don't need to loop through all memcgs here, because we
 		 * have the node_totals information for the node. If we hadn't,
 		 * this would still be achieavable by a loop-over-all-groups
 		 */
-		count += atomic_long_read(&lru->node_totals[nid]);
-	}
+		if (!memcg)
+			count += atomic_long_read(&lru->node_totals[nid]);
+		else {
+			nlru = lru_node_of_index(lru, memcg_id, nid);
+			WARN_ON(!nlru);
 
+			spin_lock(&nlru->lock);
+			BUG_ON(nlru->nr_items < 0);
+			count += nlru->nr_items;
+			spin_unlock(&nlru->lock);
+		}
+	}
 	return count;
 }
-EXPORT_SYMBOL_GPL(list_lru_count_nodemask);
+EXPORT_SYMBOL_GPL(list_lru_count_nodemask_memcg);
 
 static long
 list_lru_walk_node(
@@ -151,16 +170,18 @@ restart:
 }
 
 long
-list_lru_walk_nodemask(
+list_lru_walk_nodemask_memcg(
 	struct list_lru	*lru,
 	list_lru_walk_cb isolate,
 	void		*cb_arg,
 	long		nr_to_walk,
-	nodemask_t	*nodes_to_walk)
+	nodemask_t	*nodes_to_walk,
+	struct mem_cgroup *memcg)
 {
 	long isolated = 0;
 	int nid;
 	nodemask_t nodes;
+	int memcg_id = memcg_cache_id(memcg);
 	int idx;
 	struct list_lru_node *nlru;
 
@@ -172,6 +193,8 @@ list_lru_walk_nodemask(
 
 	for_each_node_mask(nid, nodes) {
 		for_each_memcg_lru_index(lru, idx, nid) {
+			if ((memcg_id >= 0) &&  (idx != memcg_id))
+				continue;
 
 			nlru = lru_node_of_index(lru, idx, nid);
 			if (!nlru)
@@ -185,7 +208,7 @@ list_lru_walk_nodemask(
 	}
 	return isolated;
 }
-EXPORT_SYMBOL_GPL(list_lru_walk_nodemask);
+EXPORT_SYMBOL_GPL(list_lru_walk_nodemask_memcg);
 
 long
 list_lru_dispose_all_node(
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
