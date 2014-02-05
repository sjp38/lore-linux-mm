Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id E8ADB6B003D
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 13:39:42 -0500 (EST)
Received: by mail-la0-f54.google.com with SMTP id y1so639203lam.41
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 10:39:42 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id w4si15514818lal.172.2014.02.05.10.39.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Feb 2014 10:39:40 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v15 09/13] list_lru: add per-memcg lists
Date: Wed, 5 Feb 2014 22:39:25 +0400
Message-ID: <3af6160b5c42881e83887b8caff2f6462b270750.1391624021.git.vdavydov@parallels.com>
In-Reply-To: <cover.1391624021.git.vdavydov@parallels.com>
References: <cover.1391624021.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dchinner@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

There are several FS shrinkers, including super_block::s_shrink, that
keep reclaimable objects in the list_lru structure. That said, to turn
them to memcg-aware shrinkers, it is enough to make list_lru per-memcg.

This patch does the trick. It adds an array of LRU lists to the list_lru
structure, one for each kmem-active memcg, and dispatches every item
addition or removal operation to the list corresponding to the memcg the
item is accounted to.

Since we already pass a shrink_control object to count and walk list_lru
functions to specify the NUMA node to scan, and the target memcg is held
in this structure, there is no need in changing the list_lru interface.

To make sure each kmem-active memcg has its list initialized in each
memcg-enabled list_lru, we keep all memcg-enabled list_lrus in a linked
list, which we iterate over allocating per-memcg LRUs whenever a new
kmem-active memcg is added. To synchronize this with creation of new
list_lrus, we have to take activate_kmem_mutex. Since using this mutex
as is would make all mounts proceed serially, we turn it to an rw
semaphore and take it for writing whenever a new kmem-active memcg is
created and for reading when we are going to create a list_lru. This
still does not allow mount_fs() proceed concurrently with creation of a
kmem-active memcg, but since creation of memcgs is rather a rare event,
this is not that critical.

The idea lying behind the patch as well as the initial implementation
belong to Glauber Costa.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/list_lru.h   |  112 ++++++++++++------
 include/linux/memcontrol.h |   13 +++
 mm/list_lru.c              |  271 +++++++++++++++++++++++++++++++++++++++-----
 mm/memcontrol.c            |  186 ++++++++++++++++++++++++++++--
 4 files changed, 511 insertions(+), 71 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 6ca43b2486fc..92d29cd790b2 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -11,6 +11,8 @@
 #include <linux/nodemask.h>
 #include <linux/shrinker.h>
 
+struct mem_cgroup;
+
 /* list_lru_walk_cb has to always return one of those */
 enum lru_status {
 	LRU_REMOVED,		/* item removed from list */
@@ -32,10 +34,52 @@ struct list_lru_node {
 struct list_lru {
 	struct list_lru_node	*node;
 	nodemask_t		active_nodes;
+#ifdef CONFIG_MEMCG_KMEM
+	/*
+	 * In order to provide ability of scanning objects from different
+	 * memory cgroups independently, we keep a separate LRU list for each
+	 * kmem-active memcg in this array. The array is RCU-protected and
+	 * indexed by memcg_cache_id().
+	 */
+	struct list_lru_node	**memcg;
+	/*
+	 * Every time a kmem-active memcg is created or destroyed, we have to
+	 * update the array of per-memcg LRUs in each memcg enabled list_lru
+	 * structure. To achieve that, we keep all memcg enabled list_lru
+	 * structures in the all_memcg_lrus list.
+	 */
+	struct list_head	memcg_lrus_list;
+	/*
+	 * Since the array of per-memcg LRUs is RCU-protected, we can only free
+	 * it after a call to synchronize_rcu(). To avoid multiple calls to
+	 * synchronize_rcu() when a lot of LRUs get updated at the same time,
+	 * which is a typical scenario, we will store the pointer to the
+	 * previous version of the array in the memcg_old field for each
+	 * list_lru structure, and then free them all at once after a single
+	 * call to synchronize_rcu().
+	 */
+	void			*memcg_old;
+#endif /* CONFIG_MEMCG_KMEM */
 };
 
+#ifdef CONFIG_MEMCG_KMEM
+int list_lru_memcg_alloc(struct list_lru *lru, int memcg_id);
+void list_lru_memcg_free(struct list_lru *lru, int memcg_id);
+int list_lru_grow_memcg(struct list_lru *lru, size_t new_array_size);
+#endif
+
 void list_lru_destroy(struct list_lru *lru);
-int list_lru_init(struct list_lru *lru);
+int __list_lru_init(struct list_lru *lru, bool memcg_enabled);
+
+static inline int list_lru_init(struct list_lru *lru)
+{
+	return __list_lru_init(lru, false);
+}
+
+static inline int list_lru_init_memcg(struct list_lru *lru)
+{
+	return __list_lru_init(lru, true);
+}
 
 /**
  * list_lru_add: add an element to the lru list's tail
@@ -69,39 +113,41 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item);
 bool list_lru_del(struct list_lru *lru, struct list_head *item);
 
 /**
- * list_lru_count_node: return the number of objects currently held by @lru
+ * list_lru_count_node_memcg: return the number of objects currently held by a
+ *  list_lru.
  * @lru: the lru pointer.
  * @nid: the node id to count from.
+ * @memcg: the memcg to count from.
  *
  * Always return a non-negative number, 0 for empty lists. There is no
  * guarantee that the list is not updated while the count is being computed.
  * Callers that want such a guarantee need to provide an outer lock.
  */
-unsigned long list_lru_count_node(struct list_lru *lru, int nid);
+unsigned long list_lru_count_node_memcg(struct list_lru *lru,
+					int nid, struct mem_cgroup *memcg);
 
-static inline unsigned long list_lru_shrink_count(struct list_lru *lru,
-						  struct shrink_control *sc)
+unsigned long list_lru_count(struct list_lru *lru);
+
+static inline unsigned long list_lru_count_node(struct list_lru *lru, int nid)
 {
-	return list_lru_count_node(lru, sc->nid);
+	return list_lru_count_node_memcg(lru, nid, NULL);
 }
 
-static inline unsigned long list_lru_count(struct list_lru *lru)
+static inline unsigned long list_lru_shrink_count(struct list_lru *lru,
+						  struct shrink_control *sc)
 {
-	long count = 0;
-	int nid;
-
-	for_each_node_mask(nid, lru->active_nodes)
-		count += list_lru_count_node(lru, nid);
-
-	return count;
+	return list_lru_count_node_memcg(lru, sc->nid, sc->memcg);
 }
 
 typedef enum lru_status
 (*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock, void *cb_arg);
+
 /**
- * list_lru_walk_node: walk a list_lru, isolating and disposing freeable items.
+ * list_lru_walk_node_memcg: walk a list_lru, isolating and disposing freeable
+ *  items.
  * @lru: the lru pointer.
  * @nid: the node id to scan from.
+ * @memcg: the memcg to scan from.
  * @isolate: callback function that is resposible for deciding what to do with
  *  the item currently being scanned
  * @cb_arg: opaque type that will be passed to @isolate
@@ -119,31 +165,29 @@ typedef enum lru_status
  *
  * Return value: the number of objects effectively removed from the LRU.
  */
-unsigned long list_lru_walk_node(struct list_lru *lru, int nid,
-				 list_lru_walk_cb isolate, void *cb_arg,
-				 unsigned long *nr_to_walk);
+unsigned long list_lru_walk_node_memcg(struct list_lru *lru,
+				       int nid, struct mem_cgroup *memcg,
+				       list_lru_walk_cb isolate, void *cb_arg,
+				       unsigned long *nr_to_walk);
+
+unsigned long list_lru_walk(struct list_lru *lru,
+			    list_lru_walk_cb isolate, void *cb_arg,
+			    unsigned long nr_to_walk);
 
 static inline unsigned long
-list_lru_shrink_walk(struct list_lru *lru, struct shrink_control *sc,
-		     list_lru_walk_cb isolate, void *cb_arg)
+list_lru_walk_node(struct list_lru *lru, int nid,
+		   list_lru_walk_cb isolate, void *cb_arg,
+		   unsigned long *nr_to_walk)
 {
-	return list_lru_walk_node(lru, sc->nid, isolate, cb_arg,
-				  &sc->nr_to_scan);
+	return list_lru_walk_node_memcg(lru, nid, NULL,
+					isolate, cb_arg, nr_to_walk);
 }
 
 static inline unsigned long
-list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
-	      void *cb_arg, unsigned long nr_to_walk)
+list_lru_shrink_walk(struct list_lru *lru, struct shrink_control *sc,
+		     list_lru_walk_cb isolate, void *cb_arg)
 {
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
+	return list_lru_walk_node_memcg(lru, sc->nid, sc->memcg,
+					isolate, cb_arg, &sc->nr_to_scan);
 }
 #endif /* _LRU_LIST_H */
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index fc4a24d31e99..3b310c58822a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -29,6 +29,7 @@ struct page_cgroup;
 struct page;
 struct mm_struct;
 struct kmem_cache;
+struct list_lru;
 
 /*
  * The corresponding mem_cgroup_stat_names is defined in mm/memcontrol.c,
@@ -539,6 +540,9 @@ __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 void mem_cgroup_destroy_cache(struct kmem_cache *cachep);
 void kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
+int memcg_list_lru_init(struct list_lru *lru, bool memcg_enabled);
+void memcg_list_lru_destroy(struct list_lru *lru);
+
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
  * @gfp: the gfp allocation flags.
@@ -705,6 +709,15 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 static inline void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 {
 }
+
+static inline int memcg_list_lru_init(struct list_lru *lru, bool memcg_enabled)
+{
+	return 0;
+}
+
+static inline void memcg_list_lru_destroy(struct list_lru *lru)
+{
+}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 7f5b73e2513b..d9c4c48bb8d0 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -7,19 +7,94 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mm.h>
-#include <linux/list_lru.h>
 #include <linux/slab.h>
+#include <linux/memcontrol.h>
+#include <linux/page_cgroup.h>
+#include <linux/list_lru.h>
+
+#ifdef CONFIG_MEMCG_KMEM
+static inline bool lru_has_memcg(struct list_lru *lru)
+{
+	return !!lru->memcg;
+}
+
+static struct list_lru_node *lru_node_of_index(struct list_lru *lru,
+					int nid, int memcg_id, bool *is_global)
+{
+	struct list_lru_node **memcg_lrus;
+	struct list_lru_node *nlru = NULL;
+
+	if (memcg_id < 0 || !lru_has_memcg(lru)) {
+		*is_global = true;
+		return &lru->node[nid];
+	}
+
+	rcu_read_lock();
+	memcg_lrus = rcu_dereference(lru->memcg);
+	nlru = memcg_lrus[memcg_id];
+	rcu_read_unlock();
+
+	*is_global = false;
+
+	/*
+	 * Make sure we will access the up-to-date value. The code updating
+	 * memcg_lrus issues a write barrier to match this (see
+	 * list_lru_memcg_alloc()).
+	 */
+	smp_read_barrier_depends();
+	return nlru;
+}
+
+static struct list_lru_node *lru_node_of_page(struct list_lru *lru,
+					struct page *page, bool *is_global)
+{
+	struct page_cgroup *pc;
+	struct mem_cgroup *memcg;
+
+	/*
+	 * Since a kmem page cannot change its cgroup after its allocation is
+	 * committed, we do not need to lock_page_cgroup() here.
+	 */
+	pc = lookup_page_cgroup(compound_head(page));
+	memcg = PageCgroupUsed(pc) ? pc->mem_cgroup : NULL;
+
+	return lru_node_of_index(lru, page_to_nid(page),
+				 memcg_cache_id(memcg), is_global);
+}
+#else /* !CONFIG_MEMCG_KMEM */
+static inline bool lru_has_memcg(struct list_lru *lru)
+{
+	return false;
+}
+
+static inline struct list_lru_node *lru_node_of_index(struct list_lru *lru,
+					int nid, int memcg_id, bool *is_global)
+{
+	*is_global = true;
+	return &lru->node[nid];
+}
+
+static inline struct list_lru_node *lru_node_of_page(struct list_lru *lru,
+					struct page *page, bool *is_global)
+{
+	return lru_node_of_index(lru, page_to_nid(page), -1, is_global);
+}
+#endif /* CONFIG_MEMCG_KMEM */
 
 bool list_lru_add(struct list_lru *lru, struct list_head *item)
 {
-	int nid = page_to_nid(virt_to_page(item));
-	struct list_lru_node *nlru = &lru->node[nid];
+	struct page *page = virt_to_page(item);
+	int nid = page_to_nid(page);
+	bool is_global;
+	struct list_lru_node *nlru;
+
+	nlru = lru_node_of_page(lru, page, &is_global);
 
 	spin_lock(&nlru->lock);
 	WARN_ON_ONCE(nlru->nr_items < 0);
 	if (list_empty(item)) {
 		list_add_tail(item, &nlru->list);
-		if (nlru->nr_items++ == 0)
+		if (nlru->nr_items++ == 0 && is_global)
 			node_set(nid, lru->active_nodes);
 		spin_unlock(&nlru->lock);
 		return true;
@@ -31,13 +106,17 @@ EXPORT_SYMBOL_GPL(list_lru_add);
 
 bool list_lru_del(struct list_lru *lru, struct list_head *item)
 {
-	int nid = page_to_nid(virt_to_page(item));
-	struct list_lru_node *nlru = &lru->node[nid];
+	struct page *page = virt_to_page(item);
+	int nid = page_to_nid(page);
+	bool is_global;
+	struct list_lru_node *nlru;
+
+	nlru = lru_node_of_page(lru, page, &is_global);
 
 	spin_lock(&nlru->lock);
 	if (!list_empty(item)) {
 		list_del_init(item);
-		if (--nlru->nr_items == 0)
+		if (--nlru->nr_items == 0 && is_global)
 			node_clear(nid, lru->active_nodes);
 		WARN_ON_ONCE(nlru->nr_items < 0);
 		spin_unlock(&nlru->lock);
@@ -48,11 +127,14 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 }
 EXPORT_SYMBOL_GPL(list_lru_del);
 
-unsigned long
-list_lru_count_node(struct list_lru *lru, int nid)
+unsigned long list_lru_count_node_memcg(struct list_lru *lru,
+					int nid, struct mem_cgroup *memcg)
 {
 	unsigned long count = 0;
-	struct list_lru_node *nlru = &lru->node[nid];
+	bool is_global;
+	struct list_lru_node *nlru;
+
+	nlru = lru_node_of_index(lru, nid, memcg_cache_id(memcg), &is_global);
 
 	spin_lock(&nlru->lock);
 	WARN_ON_ONCE(nlru->nr_items < 0);
@@ -61,16 +143,41 @@ list_lru_count_node(struct list_lru *lru, int nid)
 
 	return count;
 }
-EXPORT_SYMBOL_GPL(list_lru_count_node);
+EXPORT_SYMBOL_GPL(list_lru_count_node_memcg);
+
+unsigned long list_lru_count(struct list_lru *lru)
+{
+	long count = 0;
+	int nid;
+	struct mem_cgroup *memcg;
+
+	for_each_node_mask(nid, lru->active_nodes)
+		count += list_lru_count_node(lru, nid);
+
+	if (!lru_has_memcg(lru))
+		goto out;
+
+	for_each_mem_cgroup(memcg) {
+		if (memcg_kmem_is_active(memcg))
+			count += list_lru_count_node_memcg(lru, 0, memcg);
+	}
+out:
+	return count;
+}
+EXPORT_SYMBOL_GPL(list_lru_count);
 
-unsigned long
-list_lru_walk_node(struct list_lru *lru, int nid, list_lru_walk_cb isolate,
-		   void *cb_arg, unsigned long *nr_to_walk)
+unsigned long list_lru_walk_node_memcg(struct list_lru *lru,
+				       int nid, struct mem_cgroup *memcg,
+				       list_lru_walk_cb isolate, void *cb_arg,
+				       unsigned long *nr_to_walk)
 {
 
-	struct list_lru_node	*nlru = &lru->node[nid];
 	struct list_head *item, *n;
 	unsigned long isolated = 0;
+	bool is_global;
+	struct list_lru_node *nlru;
+
+	nlru = lru_node_of_index(lru, nid, memcg_cache_id(memcg), &is_global);
 
 	spin_lock(&nlru->lock);
 restart:
@@ -90,7 +197,7 @@ restart:
 		case LRU_REMOVED_RETRY:
 			assert_spin_locked(&nlru->lock);
 		case LRU_REMOVED:
-			if (--nlru->nr_items == 0)
+			if (--nlru->nr_items == 0 && is_global)
 				node_clear(nid, lru->active_nodes);
 			WARN_ON_ONCE(nlru->nr_items < 0);
 			isolated++;
@@ -122,29 +229,141 @@ restart:
 	spin_unlock(&nlru->lock);
 	return isolated;
 }
-EXPORT_SYMBOL_GPL(list_lru_walk_node);
+EXPORT_SYMBOL_GPL(list_lru_walk_node_memcg);
+
+unsigned long list_lru_walk(struct list_lru *lru,
+			    list_lru_walk_cb isolate, void *cb_arg,
+			    unsigned long nr_to_walk)
+{
+	long isolated = 0;
+	int nid;
+	struct mem_cgroup *memcg;
+
+	for_each_node_mask(nid, lru->active_nodes) {
+		isolated += list_lru_walk_node(lru, nid, isolate,
+					       cb_arg, &nr_to_walk);
+		if (nr_to_walk <= 0)
+			goto out;
+	}
+
+	if (!lru_has_memcg(lru))
+		goto out;
+
+	for_each_mem_cgroup(memcg) {
+		if (!memcg_kmem_is_active(memcg))
+			continue;
+		isolated += list_lru_walk_node_memcg(lru, 0, memcg, isolate,
+						     cb_arg, &nr_to_walk);
+		if (nr_to_walk <= 0) {
+			mem_cgroup_iter_break(NULL, memcg);
+			break;
+		}
+	}
+out:
+	return isolated;
+}
+EXPORT_SYMBOL_GPL(list_lru_walk);
 
-int list_lru_init(struct list_lru *lru)
+static void list_lru_node_init(struct list_lru_node *nlru)
+{
+	spin_lock_init(&nlru->lock);
+	INIT_LIST_HEAD(&nlru->list);
+	nlru->nr_items = 0;
+}
+
+int __list_lru_init(struct list_lru *lru, bool memcg_enabled)
 {
 	int i;
-	size_t size = sizeof(*lru->node) * nr_node_ids;
+	int err = 0;
 
-	lru->node = kzalloc(size, GFP_KERNEL);
+	lru->node = kcalloc(nr_node_ids, sizeof(*lru->node), GFP_KERNEL);
 	if (!lru->node)
 		return -ENOMEM;
 
 	nodes_clear(lru->active_nodes);
-	for (i = 0; i < nr_node_ids; i++) {
-		spin_lock_init(&lru->node[i].lock);
-		INIT_LIST_HEAD(&lru->node[i].list);
-		lru->node[i].nr_items = 0;
+	for (i = 0; i < nr_node_ids; i++)
+		list_lru_node_init(&lru->node[i]);
+
+	err = memcg_list_lru_init(lru, memcg_enabled);
+	if (err) {
+		kfree(lru->node);
+		lru->node = NULL; /* see list_lru_destroy() */
 	}
-	return 0;
+
+	return err;
 }
-EXPORT_SYMBOL_GPL(list_lru_init);
+EXPORT_SYMBOL_GPL(__list_lru_init);
 
 void list_lru_destroy(struct list_lru *lru)
 {
+	/*
+	 * We might be called after partial initialization (e.g. due to ENOMEM
+	 * error) so handle that appropriately.
+	 */
+	if (!lru->node)
+		return;
+
 	kfree(lru->node);
+	memcg_list_lru_destroy(lru);
 }
 EXPORT_SYMBOL_GPL(list_lru_destroy);
+
+#ifdef CONFIG_MEMCG_KMEM
+int list_lru_memcg_alloc(struct list_lru *lru, int memcg_id)
+{
+	struct list_lru_node *nlru;
+
+	nlru = kmalloc(sizeof(*nlru), GFP_KERNEL);
+	if (!nlru)
+		return -ENOMEM;
+
+	list_lru_node_init(nlru);
+
+	/*
+	 * Since readers won't lock (see lru_node_of_index()), we need a
+	 * barrier here to ensure nobody will see the list_lru_node partially
+	 * initialized.
+	 */
+	smp_wmb();
+
+	VM_BUG_ON(lru->memcg[memcg_id]);
+	lru->memcg[memcg_id] = nlru;
+	return 0;
+}
+
+void list_lru_memcg_free(struct list_lru *lru, int memcg_id)
+{
+	if (lru->memcg[memcg_id]) {
+		kfree(lru->memcg[memcg_id]);
+		lru->memcg[memcg_id] = NULL;
+	}
+}
+
+int list_lru_grow_memcg(struct list_lru *lru, size_t new_array_size)
+{
+	int i;
+	struct list_lru_node **memcg_lrus;
+
+	memcg_lrus = kcalloc(new_array_size, sizeof(*memcg_lrus), GFP_KERNEL);
+	if (!memcg_lrus)
+		return -ENOMEM;
+
+	if (lru->memcg) {
+		for_each_memcg_cache_index(i) {
+			if (lru->memcg[i])
+				memcg_lrus[i] = lru->memcg[i];
+		}
+	}
+
+	/*
+	 * Since we access the lru->memcg array lockless, inside an RCU
+	 * critical section (see lru_node_of_index()), we cannot free the old
+	 * version of the array right now. So we save it to lru->memcg_old to
+	 * be freed by the caller after a grace period.
+	 */
+	VM_BUG_ON(lru->memcg_old);
+	lru->memcg_old = lru->memcg;
+	rcu_assign_pointer(lru->memcg, memcg_lrus);
+	return 0;
+}
+#endif /* CONFIG_MEMCG_KMEM */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 24557d09213c..27f6d795090a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -56,6 +56,7 @@
 #include <linux/oom.h>
 #include <linux/lockdep.h>
 #include <linux/file.h>
+#include <linux/list_lru.h>
 #include "internal.h"
 #include <net/sock.h>
 #include <net/ip.h>
@@ -3004,7 +3005,11 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 static DEFINE_MUTEX(set_limit_mutex);
 
 #ifdef CONFIG_MEMCG_KMEM
-static DEFINE_MUTEX(activate_kmem_mutex);
+/*
+ * This semaphore serializes activations of kmem accounting for memory cgroups.
+ * Holding it for reading guarantees no cgroups will become kmem active.
+ */
+static DECLARE_RWSEM(activate_kmem_sem);
 
 static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 {
@@ -3338,6 +3343,154 @@ void memcg_unregister_cache(struct kmem_cache *s)
 }
 
 /*
+ * The list of all memcg-enabled list_lru structures. Needed for updating all
+ * per-memcg LRUs whenever a kmem-active memcg is created or destroyed. The
+ * list is updated under the activate_kmem_sem held for reading so to safely
+ * iterate over it, it is enough to take the activate_kmem_sem for writing.
+ */
+static LIST_HEAD(all_memcg_lrus);
+static DEFINE_SPINLOCK(all_memcg_lrus_lock);
+
+static void __memcg_destroy_all_lrus(int memcg_id)
+{
+	struct list_lru *lru;
+
+	list_for_each_entry(lru, &all_memcg_lrus, memcg_lrus_list)
+		list_lru_memcg_free(lru, memcg_id);
+}
+
+/*
+ * This function is called when a kmem-active memcg is destroyed in order to
+ * free LRUs corresponding to the memcg in all list_lru structures.
+ */
+static void memcg_destroy_all_lrus(struct mem_cgroup *memcg)
+{
+	int memcg_id;
+
+	memcg_id = memcg_cache_id(memcg);
+	if (memcg_id >= 0) {
+		down_write(&activate_kmem_sem);
+		__memcg_destroy_all_lrus(memcg_id);
+		up_write(&activate_kmem_sem);
+	}
+}
+
+/*
+ * This function allocates LRUs for a memcg in all list_lru structures. It is
+ * called with activate_kmem_sem held for writing when a new kmem-active memcg
+ * is added.
+ */
+static int memcg_init_all_lrus(int new_memcg_id)
+{
+	int err = 0;
+	int num_memcgs = new_memcg_id + 1;
+	int grow = (num_memcgs > memcg_limited_groups_array_size);
+	size_t new_array_size = memcg_caches_array_size(num_memcgs);
+	struct list_lru *lru;
+
+	if (grow) {
+		list_for_each_entry(lru, &all_memcg_lrus, memcg_lrus_list) {
+			err = list_lru_grow_memcg(lru, new_array_size);
+			if (err)
+				goto out;
+		}
+	}
+
+	list_for_each_entry(lru, &all_memcg_lrus, memcg_lrus_list) {
+		err = list_lru_memcg_alloc(lru, new_memcg_id);
+		if (err) {
+			__memcg_destroy_all_lrus(new_memcg_id);
+			break;
+		}
+	}
+out:
+	if (grow) {
+		synchronize_rcu();
+		list_for_each_entry(lru, &all_memcg_lrus, memcg_lrus_list) {
+			kfree(lru->memcg_old);
+			lru->memcg_old = NULL;
+		}
+	}
+	return err;
+}
+
+int memcg_list_lru_init(struct list_lru *lru, bool memcg_enabled)
+{
+	int err = 0;
+	int i;
+	struct mem_cgroup *memcg;
+
+	lru->memcg = NULL;
+	lru->memcg_old = NULL;
+	INIT_LIST_HEAD(&lru->memcg_lrus_list);
+
+	if (!memcg_enabled)
+		return 0;
+
+	down_read(&activate_kmem_sem);
+	if (!memcg_kmem_enabled())
+		goto out_list_add;
+
+	lru->memcg = kcalloc(memcg_limited_groups_array_size,
+			     sizeof(*lru->memcg), GFP_KERNEL);
+	if (!lru->memcg) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	for_each_mem_cgroup(memcg) {
+		int memcg_id;
+
+		memcg_id = memcg_cache_id(memcg);
+		if (memcg_id < 0)
+			continue;
+
+		err = list_lru_memcg_alloc(lru, memcg_id);
+		if (err) {
+			mem_cgroup_iter_break(NULL, memcg);
+			goto out_free_lru_memcg;
+		}
+	}
+out_list_add:
+	spin_lock(&all_memcg_lrus_lock);
+	list_add(&lru->memcg_lrus_list, &all_memcg_lrus);
+	spin_unlock(&all_memcg_lrus_lock);
+out:
+	up_read(&activate_kmem_sem);
+	return err;
+
+out_free_lru_memcg:
+	for (i = 0; i < memcg_limited_groups_array_size; i++)
+		list_lru_memcg_free(lru, i);
+	kfree(lru->memcg);
+	goto out;
+}
+
+void memcg_list_lru_destroy(struct list_lru *lru)
+{
+	int i, array_size;
+
+	if (list_empty(&lru->memcg_lrus_list))
+		return;
+
+	down_read(&activate_kmem_sem);
+
+	array_size = memcg_limited_groups_array_size;
+
+	spin_lock(&all_memcg_lrus_lock);
+	list_del(&lru->memcg_lrus_list);
+	spin_unlock(&all_memcg_lrus_lock);
+
+	up_read(&activate_kmem_sem);
+
+	if (lru->memcg) {
+		for (i = 0; i < array_size; i++)
+			list_lru_memcg_free(lru, i);
+		kfree(lru->memcg);
+	}
+}
+
+/*
  * During the creation a new cache, we need to disable our accounting mechanism
  * altogether. This is true even if we are not creating, but rather just
  * enqueing new caches to be created.
@@ -3486,10 +3639,9 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 	 *
 	 * Still, we don't want anyone else freeing memcg_caches under our
 	 * noses, which can happen if a new memcg comes to life. As usual,
-	 * we'll take the activate_kmem_mutex to protect ourselves against
-	 * this.
+	 * we'll take the activate_kmem_sem to protect ourselves against this.
 	 */
-	mutex_lock(&activate_kmem_mutex);
+	down_read(&activate_kmem_sem);
 	for_each_memcg_cache_index(i) {
 		c = cache_from_memcg_idx(s, i);
 		if (!c)
@@ -3512,7 +3664,7 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		cancel_work_sync(&c->memcg_params->destroy);
 		kmem_cache_destroy(c);
 	}
-	mutex_unlock(&activate_kmem_mutex);
+	up_read(&activate_kmem_sem);
 }
 
 struct create_work {
@@ -5179,7 +5331,7 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 }
 
 #ifdef CONFIG_MEMCG_KMEM
-/* should be called with activate_kmem_mutex held */
+/* should be called with activate_kmem_sem held for writing */
 static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 				 unsigned long long limit)
 {
@@ -5222,12 +5374,21 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 	}
 
 	/*
+	 * Initialize this cgroup's lists in each list_lru. This must be done
+	 * before calling memcg_update_all_caches(), where we update the
+	 * limited_groups_array_size.
+	 */
+	err = memcg_init_all_lrus(memcg_id);
+	if (err)
+		goto out_rmid;
+
+	/*
 	 * Make sure we have enough space for this cgroup in each root cache's
 	 * memcg_params.
 	 */
 	err = memcg_update_all_caches(memcg_id + 1);
 	if (err)
-		goto out_rmid;
+		goto out_destroy_all_lrus;
 
 	memcg->kmemcg_id = memcg_id;
 
@@ -5249,6 +5410,8 @@ out:
 	memcg_resume_kmem_account();
 	return err;
 
+out_destroy_all_lrus:
+	__memcg_destroy_all_lrus(memcg_id);
 out_rmid:
 	ida_simple_remove(&kmem_limited_groups, memcg_id);
 	goto out;
@@ -5259,9 +5422,9 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg,
 {
 	int ret;
 
-	mutex_lock(&activate_kmem_mutex);
+	down_write(&activate_kmem_sem);
 	ret = __memcg_activate_kmem(memcg, limit);
-	mutex_unlock(&activate_kmem_mutex);
+	up_write(&activate_kmem_sem);
 	return ret;
 }
 
@@ -5285,14 +5448,14 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 	if (!parent)
 		return 0;
 
-	mutex_lock(&activate_kmem_mutex);
+	down_write(&activate_kmem_sem);
 	/*
 	 * If the parent cgroup is not kmem-active now, it cannot be activated
 	 * after this point, because it has at least one child already.
 	 */
 	if (memcg_kmem_is_active(parent))
 		ret = __memcg_activate_kmem(memcg, RES_COUNTER_MAX);
-	mutex_unlock(&activate_kmem_mutex);
+	up_write(&activate_kmem_sem);
 	return ret;
 }
 #else
@@ -5989,6 +6152,7 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
 	mem_cgroup_sockets_destroy(memcg);
+	memcg_destroy_all_lrus(memcg);
 }
 
 static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
