Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 7BD356B005A
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:34:55 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 12/25] list_lru: per-node API
Date: Fri,  7 Jun 2013 00:34:45 +0400
Message-Id: <1370550898-26711-13-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>

This patch adapts the list_lru API to accept an optional node argument,
to be used by NUMA aware shrinking functions. Code that does not care
about the NUMA placement of objects can still call into the very same
functions as before. They will simply iterate over all nodes.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
---
 include/linux/list_lru.h | 39 ++++++++++++++++++++++++++++++++++-----
 mm/list_lru.c            | 37 +++++++++----------------------------
 2 files changed, 43 insertions(+), 33 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index f4d4cb6..2fe13e1 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -75,20 +75,32 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item);
 bool list_lru_del(struct list_lru *lru, struct list_head *item);
 
 /**
- * list_lru_count: return the number of objects currently held by @lru
+ * list_lru_count_node: return the number of objects currently held by @lru
  * @lru: the lru pointer.
+ * @nid: the node id to count from.
  *
  * Always return a non-negative number, 0 for empty lists. There is no
  * guarantee that the list is not updated while the count is being computed.
  * Callers that want such a guarantee need to provide an outer lock.
  */
-unsigned long list_lru_count(struct list_lru *lru);
+unsigned long list_lru_count_node(struct list_lru *lru, int nid);
+static inline unsigned long list_lru_count(struct list_lru *lru)
+{
+	long count = 0;
+	int nid;
+
+	for_each_node_mask(nid, lru->active_nodes)
+		count += list_lru_count_node(lru, nid);
+
+	return count;
+}
 
 typedef enum lru_status
 (*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock, void *cb_arg);
 /**
- * list_lru_walk: walk a list_lru, isolating and disposing freeable items.
+ * list_lru_walk_node: walk a list_lru, isolating and disposing freeable items.
  * @lru: the lru pointer.
+ * @nid: the node id to scan from.
  * @isolate: callback function that is resposible for deciding what to do with
  *  the item currently being scanned
  * @cb_arg: opaque type that will be passed to @isolate
@@ -106,8 +118,25 @@ typedef enum lru_status
  *
  * Return value: the number of objects effectively removed from the LRU.
  */
-unsigned long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
-		   void *cb_arg, unsigned long nr_to_walk);
+unsigned long list_lru_walk_node(struct list_lru *lru, int nid,
+				 list_lru_walk_cb isolate, void *cb_arg,
+				 unsigned long *nr_to_walk);
+
+static inline unsigned long
+list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
+	      void *cb_arg, unsigned long nr_to_walk)
+{
+	long isolated = 0;
+	int nid;
+
+	for_each_node_mask(nid, lru->active_nodes) {
+		isolated += list_lru_walk_node(lru, nid, isolate,
+					       cb_arg, &nr_to_walk);
+		if (nr_to_walk <= 0)
+			break;
+	}
+	return isolated;
+}
 
 typedef void (*list_lru_dispose_cb)(struct list_head *dispose_list);
 /**
diff --git a/mm/list_lru.c b/mm/list_lru.c
index f2d1d6e..2822817 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -47,25 +47,22 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 }
 EXPORT_SYMBOL_GPL(list_lru_del);
 
-unsigned long list_lru_count(struct list_lru *lru)
+unsigned long
+list_lru_count_node(struct list_lru *lru, int nid)
 {
 	unsigned long count = 0;
-	int nid;
-
-	for_each_node_mask(nid, lru->active_nodes) {
-		struct list_lru_node *nlru = &lru->node[nid];
+	struct list_lru_node *nlru = &lru->node[nid];
 
-		spin_lock(&nlru->lock);
-		BUG_ON(nlru->nr_items < 0);
-		count += nlru->nr_items;
-		spin_unlock(&nlru->lock);
-	}
+	spin_lock(&nlru->lock);
+	BUG_ON(nlru->nr_items < 0);
+	count += nlru->nr_items;
+	spin_unlock(&nlru->lock);
 
 	return count;
 }
-EXPORT_SYMBOL_GPL(list_lru_count);
+EXPORT_SYMBOL_GPL(list_lru_count_node);
 
-static unsigned long
+unsigned long
 list_lru_walk_node(struct list_lru *lru, int nid, list_lru_walk_cb isolate,
 		   void *cb_arg, unsigned long *nr_to_walk)
 {
@@ -120,22 +117,6 @@ restart:
 }
 EXPORT_SYMBOL_GPL(list_lru_walk_node);
 
-unsigned long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
-			    void *cb_arg, unsigned long nr_to_walk)
-{
-	unsigned long isolated = 0;
-	int nid;
-
-	for_each_node_mask(nid, lru->active_nodes) {
-		isolated += list_lru_walk_node(lru, nid, isolate,
-					       cb_arg, &nr_to_walk);
-		if (nr_to_walk <= 0)
-			break;
-	}
-	return isolated;
-}
-EXPORT_SYMBOL_GPL(list_lru_walk);
-
 static unsigned long list_lru_dispose_all_node(struct list_lru *lru, int nid,
 					       list_lru_dispose_cb dispose)
 {
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
