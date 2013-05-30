Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 0AAC76B009E
	for <linux-mm@kvack.org>; Thu, 30 May 2013 06:37:22 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v9 28/35] list_lru: per-memcg walks
Date: Thu, 30 May 2013 14:36:14 +0400
Message-Id: <1369910181-20026-29-git-send-email-glommer@openvz.org>
In-Reply-To: <1369910181-20026-1-git-send-email-glommer@openvz.org>
References: <1369910181-20026-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>

This patch extend the list_lru interfaces to allow for a memcg
parameter. Because most of its users won't need it, instead of
modifying the function signatures we create a new set of _memcg()
functions and write the old API ontop of that.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
c: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/list_lru.h   | 26 ++++++++++++---
 include/linux/memcontrol.h |  2 ++
 lib/list_lru.c             | 82 ++++++++++++++++++++++++++++++++++++----------
 3 files changed, 88 insertions(+), 22 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 3b8c301..dcb67dc 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -100,7 +100,15 @@ static inline int list_lru_init_memcg(struct list_lru *lru)
 int list_lru_add(struct list_lru *lru, struct list_head *item);
 int list_lru_del(struct list_lru *lru, struct list_head *item);
 
-unsigned long list_lru_count_node(struct list_lru *lru, int nid);
+unsigned long list_lru_count_node_memcg(struct list_lru *lru, int nid,
+					struct mem_cgroup *memcg);
+
+static inline unsigned long
+list_lru_count_node(struct list_lru *lru, int nid)
+{
+	return list_lru_count_node_memcg(lru, nid, NULL);
+}
+
 static inline unsigned long list_lru_count(struct list_lru *lru)
 {
 	long count = 0;
@@ -118,9 +126,19 @@ typedef enum lru_status
 typedef void (*list_lru_dispose_cb)(struct list_head *dispose_list);
 
 
-unsigned long list_lru_walk_node(struct list_lru *lru, int nid,
-				 list_lru_walk_cb isolate, void *cb_arg,
-				 unsigned long *nr_to_walk);
+unsigned long
+list_lru_walk_node_memcg(struct list_lru *lru, int nid,
+			 list_lru_walk_cb isolate, void *cb_arg,
+			 unsigned long *nr_to_walk, struct mem_cgroup *memcg);
+
+static inline unsigned long
+list_lru_walk_node(struct list_lru *lru, int nid,
+		 list_lru_walk_cb isolate, void *cb_arg,
+		 unsigned long *nr_to_walk)
+{
+	return list_lru_walk_node_memcg(lru, nid, isolate, cb_arg,
+					nr_to_walk, NULL);
+}
 
 static inline unsigned long
 list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 50f199f..3eeece8 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -593,6 +593,8 @@ static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
 
+#define memcg_limited_groups_array_size 0
+
 static inline bool memcg_kmem_enabled(void)
 {
 	return false;
diff --git a/lib/list_lru.c b/lib/list_lru.c
index 128af5e..316c95a 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -80,6 +80,23 @@ memcg_kmem_lru_of_page(struct list_lru *lru, struct page *page)
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
@@ -139,10 +156,19 @@ list_lru_del(
 EXPORT_SYMBOL_GPL(list_lru_del);
 
 unsigned long
-list_lru_count_node(struct list_lru *lru, int nid)
+list_lru_count_node_memcg(struct list_lru *lru, int nid,
+			  struct mem_cgroup *memcg)
 {
 	long count = 0;
-	struct list_lru_node *nlru = &lru->node[nid];
+	int memcg_id = -1;
+	struct list_lru_node *nlru;
+
+	if (memcg && memcg_kmem_is_active(memcg))
+		memcg_id = memcg_cache_id(memcg);
+
+	nlru = lru_node_of_index(lru, memcg_id, nid);
+	if (!nlru)
+		return 0;
 
 	spin_lock(&nlru->lock);
 	BUG_ON(nlru->nr_items < 0);
@@ -151,19 +177,28 @@ list_lru_count_node(struct list_lru *lru, int nid)
 
 	return count;
 }
-EXPORT_SYMBOL_GPL(list_lru_count_node);
+EXPORT_SYMBOL_GPL(list_lru_count_node_memcg);
 
 unsigned long
-list_lru_walk_node(
+list_lru_walk_node_memcg(
 	struct list_lru		*lru,
 	int			nid,
 	list_lru_walk_cb	isolate,
 	void			*cb_arg,
-	unsigned long		*nr_to_walk)
+	unsigned long		*nr_to_walk,
+	struct mem_cgroup	*memcg)
 {
-	struct list_lru_node	*nlru = &lru->node[nid];
 	struct list_head *item, *n;
 	unsigned long isolated = 0;
+	struct list_lru_node *nlru;
+	int memcg_id = -1;
+
+	if (memcg && memcg_kmem_is_active(memcg))
+		memcg_id = memcg_cache_id(memcg);
+
+	nlru = lru_node_of_index(lru, memcg_id, nid);
+	if (!nlru)
+		return 0;
 
 	spin_lock(&nlru->lock);
 	list_for_each_safe(item, n, &nlru->list) {
@@ -200,7 +235,7 @@ restart:
 	spin_unlock(&nlru->lock);
 	return isolated;
 }
-EXPORT_SYMBOL_GPL(list_lru_walk_node);
+EXPORT_SYMBOL_GPL(list_lru_walk_node_memcg);
 
 static unsigned long
 list_lru_dispose_all_node(
@@ -208,23 +243,34 @@ list_lru_dispose_all_node(
 	int			nid,
 	list_lru_dispose_cb	dispose)
 {
-	struct list_lru_node	*nlru = &lru->node[nid];
+	struct list_lru_node *nlru;
 	LIST_HEAD(dispose_list);
 	unsigned long disposed = 0;
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
