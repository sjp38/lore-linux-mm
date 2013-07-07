Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 0C5ED6B0044
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:57:21 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id dy20so3131427lab.9
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:57:20 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v10 07/16] list_lru: per-memcg walks
Date: Sun,  7 Jul 2013 11:56:47 -0400
Message-Id: <1373212616-11713-8-git-send-email-glommer@openvz.org>
In-Reply-To: <1373212616-11713-1-git-send-email-glommer@openvz.org>
References: <1373212616-11713-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, akpm@linux-foundation.org, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>

This patch extends the list_lru interfaces to allow for a memcg
parameter. Because most of its users won't need it, instead of
modifying the function signatures we create a new set of _memcg()
functions and write the old API on top of that.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/list_lru.h   | 30 +++++++++++++++++++++++++-----
 include/linux/memcontrol.h |  2 ++
 mm/list_lru.c              | 25 ++++++++++++++++++-------
 3 files changed, 45 insertions(+), 12 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index e7a1199..57d0bb0 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -128,15 +128,24 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item);
 bool list_lru_del(struct list_lru *lru, struct list_head *item);
 
 /**
- * list_lru_count_node: return the number of objects currently held by @lru
+ * list_lru_count_node_memcg: return the number of objects currently held by @lru
  * @lru: the lru pointer.
  * @nid: the node id to count from.
+ * @memcg: restricts the count to this memcg, NULL for global.
  *
  * Always return a non-negative number, 0 for empty lists. There is no
  * guarantee that the list is not updated while the count is being computed.
  * Callers that want such a guarantee need to provide an outer lock.
  */
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
@@ -158,6 +167,7 @@ typedef enum lru_status
  *  the item currently being scanned
  * @cb_arg: opaque type that will be passed to @isolate
  * @nr_to_walk: how many items to scan.
+ * @memcg: restricts the scan to this memcg, NULL for global.
  *
  * This function will scan all elements in a particular list_lru, calling the
  * @isolate callback for each of those items, along with the current list
@@ -171,9 +181,19 @@ typedef enum lru_status
  *
  * Return value: the number of objects effectively removed from the LRU.
  */
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
index e069d53..a8c5493 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -591,6 +591,8 @@ static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
 
+#define memcg_limited_groups_array_size 0
+
 static inline bool memcg_kmem_enabled(void)
 {
 	return false;
diff --git a/mm/list_lru.c b/mm/list_lru.c
index bdd97cf..8ec51fa 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -128,10 +128,16 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 EXPORT_SYMBOL_GPL(list_lru_del);
 
 unsigned long
-list_lru_count_node(struct list_lru *lru, int nid)
+list_lru_count_node_memcg(struct list_lru *lru, int nid,
+			  struct mem_cgroup *memcg)
 {
 	unsigned long count = 0;
-	struct list_lru_node *nlru = &lru->node[nid];
+	int memcg_id = memcg_cache_id(memcg);
+	struct list_lru_node *nlru;
+
+	nlru = lru_node_of_index(lru, memcg_id, nid);
+	if (!nlru)
+		return 0;
 
 	spin_lock(&nlru->lock);
 	WARN_ON_ONCE(nlru->nr_items < 0);
@@ -140,16 +146,18 @@ list_lru_count_node(struct list_lru *lru, int nid)
 
 	return count;
 }
-EXPORT_SYMBOL_GPL(list_lru_count_node);
+EXPORT_SYMBOL_GPL(list_lru_count_node_memcg);
 
 unsigned long
-list_lru_walk_node(struct list_lru *lru, int nid, list_lru_walk_cb isolate,
-		   void *cb_arg, unsigned long *nr_to_walk)
+list_lru_walk_node_memcg(struct list_lru *lru, int nid,
+			 list_lru_walk_cb isolate, void *cb_arg,
+			 unsigned long *nr_to_walk, struct mem_cgroup *memcg)
 {
 
-	struct list_lru_node	*nlru = &lru->node[nid];
 	struct list_head *item, *n;
 	unsigned long isolated = 0;
+	struct list_lru_node *nlru;
+	int memcg_id = memcg_cache_id(memcg);
 	/*
 	 * If we don't keep state of at which pass we are, we can loop at
 	 * LRU_RETRY, since we have no guarantees that the caller will be able
@@ -159,6 +167,9 @@ list_lru_walk_node(struct list_lru *lru, int nid, list_lru_walk_cb isolate,
 	 */
 	bool first_pass = true;
 
+	nlru = lru_node_of_index(lru, memcg_id, nid);
+	if (!nlru)
+		return 0;
 	spin_lock(&nlru->lock);
 restart:
 	list_for_each_safe(item, n, &nlru->list) {
@@ -196,7 +207,7 @@ restart:
 	spin_unlock(&nlru->lock);
 	return isolated;
 }
-EXPORT_SYMBOL_GPL(list_lru_walk_node);
+EXPORT_SYMBOL_GPL(list_lru_walk_node_memcg);
 
 /*
  * Each list_lru that is memcg-aware is inserted into the all_memcgs_lrus,
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
