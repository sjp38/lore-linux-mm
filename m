Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id EB7F86B0074
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 06:38:12 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id eu11so911144pac.23
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 03:38:12 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id cg3si3852664pbc.149.2014.10.24.03.38.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 03:38:11 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 6/9] list_lru: get rid of ->active_nodes
Date: Fri, 24 Oct 2014 14:37:37 +0400
Message-ID: <3a4dd483ceeb26225af7181083ea695c54f0f895.1414145863.git.vdavydov@parallels.com>
In-Reply-To: <cover.1414145862.git.vdavydov@parallels.com>
References: <cover.1414145862.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Dave Chinner <david@fromorbit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The active_nodes mask allows us to skip empty nodes when walking over
list_lru items from all nodes in list_lru_count/walk. However, these
functions are never called from hot paths, so it doesn't seem we need
such kind of optimization there. OTOH, removing the mask will make it
easier to make list_lru per-memcg.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/list_lru.h |    5 ++---
 mm/list_lru.c            |   10 +++-------
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index f500a2e39b13..53c1d6b78270 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -31,7 +31,6 @@ struct list_lru_node {
 
 struct list_lru {
 	struct list_lru_node	*node;
-	nodemask_t		active_nodes;
 };
 
 void list_lru_destroy(struct list_lru *lru);
@@ -94,7 +93,7 @@ static inline unsigned long list_lru_count(struct list_lru *lru)
 	long count = 0;
 	int nid;
 
-	for_each_node_mask(nid, lru->active_nodes)
+	for_each_node_state(nid, N_NORMAL_MEMORY)
 		count += list_lru_count_node(lru, nid);
 
 	return count;
@@ -142,7 +141,7 @@ list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
 	long isolated = 0;
 	int nid;
 
-	for_each_node_mask(nid, lru->active_nodes) {
+	for_each_node_state(nid, N_NORMAL_MEMORY) {
 		isolated += list_lru_walk_node(lru, nid, isolate,
 					       cb_arg, &nr_to_walk);
 		if (nr_to_walk <= 0)
diff --git a/mm/list_lru.c b/mm/list_lru.c
index f1a0db194173..07e198c77888 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -19,8 +19,7 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
 	WARN_ON_ONCE(nlru->nr_items < 0);
 	if (list_empty(item)) {
 		list_add_tail(item, &nlru->list);
-		if (nlru->nr_items++ == 0)
-			node_set(nid, lru->active_nodes);
+		nlru->nr_items++;
 		spin_unlock(&nlru->lock);
 		return true;
 	}
@@ -37,8 +36,7 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 	spin_lock(&nlru->lock);
 	if (!list_empty(item)) {
 		list_del_init(item);
-		if (--nlru->nr_items == 0)
-			node_clear(nid, lru->active_nodes);
+		nlru->nr_items--;
 		WARN_ON_ONCE(nlru->nr_items < 0);
 		spin_unlock(&nlru->lock);
 		return true;
@@ -90,8 +88,7 @@ restart:
 		case LRU_REMOVED_RETRY:
 			assert_spin_locked(&nlru->lock);
 		case LRU_REMOVED:
-			if (--nlru->nr_items == 0)
-				node_clear(nid, lru->active_nodes);
+			nlru->nr_items--;
 			WARN_ON_ONCE(nlru->nr_items < 0);
 			isolated++;
 			/*
@@ -133,7 +130,6 @@ int list_lru_init_key(struct list_lru *lru, struct lock_class_key *key)
 	if (!lru->node)
 		return -ENOMEM;
 
-	nodes_clear(lru->active_nodes);
 	for (i = 0; i < nr_node_ids; i++) {
 		spin_lock_init(&lru->node[i].lock);
 		if (key)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
