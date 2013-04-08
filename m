Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id D23CA6B00DD
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 10:02:18 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 24/32] list_lru: also include memcg lists in counts and scans
Date: Mon,  8 Apr 2013 18:00:51 +0400
Message-Id: <1365429659-22108-25-git-send-email-glommer@parallels.com>
In-Reply-To: <1365429659-22108-1-git-send-email-glommer@parallels.com>
References: <1365429659-22108-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Dave Shrinnker <david@fromorbit.com>, Serge Hallyn <serge.hallyn@canonical.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@parallels.com>, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

As elements are added to per-memcg lists, they will be invisible to
global reclaimers. This patch mainly modifies list_lru walk and count
functions to take that into account.

Counting is very simple: since we already have total figures for the
node, which we use to figure out when to set or clear the node in the
bitmap, we can just use that.

For walking, we need to walk the memcg lists as well as the global list.
To achieve that, this patch introduces the helper macro
for_each_memcg_lru_index. Locking semantics are simple, since
introducing a new LRU in the list does not influence the memcg walkers.

The only operation we race against is memcg creation and teardown.  For
those, barriers should be enough to guarantee that we are seeing
up-to-date information and not accessing invalid pointers.

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
 include/linux/memcontrol.h |  2 ++
 lib/list_lru.c             | 90 ++++++++++++++++++++++++++++++++++------------
 2 files changed, 69 insertions(+), 23 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1e74610..6dc1d7a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -592,6 +592,8 @@ static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
 
+#define memcg_limited_groups_array_size 0
+
 static inline bool memcg_kmem_enabled(void)
 {
 	return false;
diff --git a/lib/list_lru.c b/lib/list_lru.c
index 676ade7..dfc2c4a 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -69,6 +69,23 @@ memcg_kmem_lru_of_page(struct list_lru *lru, struct page *page)
 	return lru_node_of_index(lru, memcg_id, nid);
 }
 
+/*
+ * This helper will loop through all node-data in the LRU, either global or
+ * per-memcg.  If memcg is either not present or not used,
+ * memcg_limited_groups_array_size will be 0. _idx starts at -1, and it will
+ * still be allowed to execute once.
+ *
+ * We convention that for _idx = -1, the global node info should be used.
+ * After that, we will go through each of the memcgs, starting at 0.
+ *
+ * We don't need any kind of locking for the loop because
+ * memcg_limited_groups_array_size can only grow, gaining new fields at the
+ * end. The old ones are just copied, and any interesting manipulation happen
+ * in the node list itself, and we already lock the list.
+ */
+#define for_each_memcg_lru_index(_idx)	\
+	for ((_idx) = -1; ((_idx) < memcg_limited_groups_array_size); (_idx)++)
+
 int
 list_lru_add(
 	struct list_lru	*lru,
@@ -136,12 +153,12 @@ list_lru_count_nodemask(
 	int nid;
 
 	for_each_node_mask(nid, *nodes_to_count) {
-		struct list_lru_node *nlru = &lru->node[nid];
-
-		spin_lock(&nlru->lock);
-		BUG_ON(nlru->nr_items < 0);
-		count += nlru->nr_items;
-		spin_unlock(&nlru->lock);
+		/*
+		 * We don't need to loop through all memcgs here, because we
+		 * have the node_totals information for the node. If we hadn't,
+		 * this would still be achieavable by a loop-over-all-groups
+		 */
+		count += atomic_long_read(&lru->node_totals[nid]);
 	}
 
 	return count;
@@ -151,12 +168,12 @@ EXPORT_SYMBOL_GPL(list_lru_count_nodemask);
 static long
 list_lru_walk_node(
 	struct list_lru		*lru,
+	struct list_lru_node	*nlru,
 	int			nid,
 	list_lru_walk_cb	isolate,
 	void			*cb_arg,
 	long			*nr_to_walk)
 {
-	struct list_lru_node	*nlru = &lru->node[nid];
 	struct list_head *item, *n;
 	long isolated = 0;
 restart:
@@ -200,12 +217,28 @@ list_lru_walk_nodemask(
 {
 	long isolated = 0;
 	int nid;
+	nodemask_t nodes;
+	int idx;
+	struct list_lru_node *nlru;
 
-	for_each_node_mask(nid, *nodes_to_walk) {
-		isolated += list_lru_walk_node(lru, nid, isolate,
-					       cb_arg, &nr_to_walk);
-		if (nr_to_walk <= 0)
-			break;
+	/*
+	 * Conservative code can call this setting nodes with node_setall.
+	 * This will generate an out of bound access for memcg.
+	 */
+	nodes_and(nodes, *nodes_to_walk, node_online_map);
+
+	for_each_node_mask(nid, nodes) {
+		for_each_memcg_lru_index(idx) {
+
+			nlru = lru_node_of_index(lru, idx, nid);
+			if (!nlru)
+				continue;
+
+			isolated += list_lru_walk_node(lru, nlru, nid, isolate,
+						       cb_arg, &nr_to_walk);
+			if (nr_to_walk <= 0)
+				break;
+		}
 	}
 	return isolated;
 }
@@ -217,23 +250,34 @@ list_lru_dispose_all_node(
 	int			nid,
 	list_lru_dispose_cb	dispose)
 {
-	struct list_lru_node	*nlru = &lru->node[nid];
+	struct list_lru_node *nlru;
 	LIST_HEAD(dispose_list);
 	long disposed = 0;
+	int idx;
 
-	spin_lock(&nlru->lock);
-	while (!list_empty(&nlru->list)) {
-		list_splice_init(&nlru->list, &dispose_list);
-		disposed += nlru->nr_items;
-		nlru->nr_items = 0;
-		node_clear(nid, lru->active_nodes);
-		spin_unlock(&nlru->lock);
-
-		dispose(&dispose_list);
+	for_each_memcg_lru_index(idx) {
+		nlru = lru_node_of_index(lru, idx, nid);
+		if (!nlru)
+			continue;
 
 		spin_lock(&nlru->lock);
+		while (!list_empty(&nlru->list)) {
+			list_splice_init(&nlru->list, &dispose_list);
+
+			if (atomic_long_sub_and_test(nlru->nr_items,
+							&lru->node_totals[nid]))
+				node_clear(nid, lru->active_nodes);
+			disposed += nlru->nr_items;
+			nlru->nr_items = 0;
+			spin_unlock(&nlru->lock);
+
+			dispose(&dispose_list);
+
+			spin_lock(&nlru->lock);
+		}
+		spin_unlock(&nlru->lock);
 	}
-	spin_unlock(&nlru->lock);
+
 	return disposed;
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
