Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 5C1F16B0062
	for <linux-mm@kvack.org>; Thu, 30 May 2013 06:36:22 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v9 14/35] list_lru: per-node API
Date: Thu, 30 May 2013 14:36:00 +0400
Message-Id: <1369910181-20026-15-git-send-email-glommer@openvz.org>
In-Reply-To: <1369910181-20026-1-git-send-email-glommer@openvz.org>
References: <1369910181-20026-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>

This patch adapts the list_lru API to accept an optional node argument,
to be used by NUMA aware shrinking functions. Code that does not care
about the NUMA placement of objects can still call into the very same
functions as before. They will simply iterate over all nodes.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
---
 include/linux/list_lru.h | 35 ++++++++++++++++++++++++++++++++---
 lib/list_lru.c           | 41 +++++++++--------------------------------
 2 files changed, 41 insertions(+), 35 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 668f1f1..cf59a8a 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -42,15 +42,44 @@ struct list_lru {
 int list_lru_init(struct list_lru *lru);
 int list_lru_add(struct list_lru *lru, struct list_head *item);
 int list_lru_del(struct list_lru *lru, struct list_head *item);
-unsigned long list_lru_count(struct list_lru *lru);
+
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
 
 typedef void (*list_lru_dispose_cb)(struct list_head *dispose_list);
 
-unsigned long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
-		   void *cb_arg, unsigned long nr_to_walk);
+
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
 
 unsigned long
 list_lru_dispose_all(struct list_lru *lru, list_lru_dispose_cb dispose);
diff --git a/lib/list_lru.c b/lib/list_lru.c
index 7611df7..dae13d6 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -54,25 +54,21 @@ list_lru_del(
 EXPORT_SYMBOL_GPL(list_lru_del);
 
 unsigned long
-list_lru_count(struct list_lru *lru)
+list_lru_count_node(struct list_lru *lru, int nid)
 {
 	long count = 0;
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
 list_lru_walk_node(
 	struct list_lru		*lru,
 	int			nid,
@@ -118,26 +114,7 @@ restart:
 	spin_unlock(&nlru->lock);
 	return isolated;
 }
-
-unsigned long
-list_lru_walk(
-	struct list_lru	*lru,
-	list_lru_walk_cb isolate,
-	void		*cb_arg,
-	unsigned long	nr_to_walk)
-{
-	long isolated = 0;
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
+EXPORT_SYMBOL_GPL(list_lru_walk_node);
 
 static unsigned long
 list_lru_dispose_all_node(
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
