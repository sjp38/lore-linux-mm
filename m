Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id E4F8F6B0069
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 03:06:38 -0500 (EST)
Received: by mail-la0-f45.google.com with SMTP id eh20so1293949lab.18
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 00:06:38 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id p10si3267449lag.166.2013.12.09.00.06.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 00:06:37 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v13 11/16] mm: list_lru: add per-memcg lists
Date: Mon, 9 Dec 2013 12:05:52 +0400
Message-ID: <0ca62dbfbf545edb22b86bd11c50e9017a3dc4db.1386571280.git.vdavydov@parallels.com>
In-Reply-To: <cover.1386571280.git.vdavydov@parallels.com>
References: <cover.1386571280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, vdavydov@parallels.com, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

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

The idea lying behind the patch as well as the initial implementation
belong to Glauber Costa.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/list_lru.h   |   44 +++++++-
 include/linux/memcontrol.h |   13 +++
 mm/list_lru.c              |  242 ++++++++++++++++++++++++++++++++++++++------
 mm/memcontrol.c            |  158 ++++++++++++++++++++++++++++-
 4 files changed, 416 insertions(+), 41 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 34e57af..e8add3d 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -28,11 +28,47 @@ struct list_lru_node {
 	long			nr_items;
 } ____cacheline_aligned_in_smp;
 
+struct list_lru_one {
+	struct list_lru_node *node;
+	nodemask_t active_nodes;
+};
+
 struct list_lru {
-	struct list_lru_node	*node;
-	nodemask_t		active_nodes;
+	struct list_lru_one	global;
+#ifdef CONFIG_MEMCG_KMEM
+	/*
+	 * In order to provide ability of scanning objects from different
+	 * memory cgroups independently, we keep a separate LRU list for each
+	 * kmem-active memcg in this array. The array is RCU-protected and
+	 * indexed by memcg_cache_id().
+	 */
+	struct list_lru_one	**memcg;
+	/*
+	 * Every time a kmem-active memcg is created or destroyed, we have to
+	 * update the array of per-memcg LRUs in each list_lru structure. To
+	 * achieve that, we keep all list_lru structures in the all_memcg_lrus
+	 * list.
+	 */
+	struct list_head	list;
+	/*
+	 * Since the array of per-memcg LRUs is RCU-protected, we can only free
+	 * it after a call to synchronize_rcu(). To avoid multiple calls to
+	 * synchronize_rcu() when a lot of LRUs get updated at the same time,
+	 * which is a typical scenario, we will store the pointer to the
+	 * previous version of the array in the memcg_old field for each
+	 * list_lru structure, and then free them all at once after a single
+	 * call to synchronize_rcu().
+	 */
+	void *memcg_old;
+#endif /* CONFIG_MEMCG_KMEM */
 };
 
+#ifdef CONFIG_MEMCG_KMEM
+int list_lru_memcg_alloc(struct list_lru *lru, int memcg_id);
+void list_lru_memcg_free(struct list_lru *lru, int memcg_id);
+int list_lru_grow_memcg(struct list_lru *lru, size_t new_array_size);
+#endif
+
 void list_lru_destroy(struct list_lru *lru);
 int list_lru_init(struct list_lru *lru);
 
@@ -70,7 +106,7 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item);
 /**
  * list_lru_count: return the number of objects currently held by @lru
  * @lru: the lru pointer.
- * @sc: if not NULL, count only from node @sc->nid.
+ * @sc: if not NULL, count only from node @sc->nid and memcg @sc->memcg.
  *
  * Always return a non-negative number, 0 for empty lists. There is no
  * guarantee that the list is not updated while the count is being computed.
@@ -83,7 +119,7 @@ typedef enum lru_status
 /**
  * list_lru_walk: walk a list_lru, isolating and disposing freeable items.
  * @lru: the lru pointer.
- * @sc: if not NULL, scan only from node @sc->nid.
+ * @sc: if not NULL, scan only from node @sc->nid and memcg @sc->memcg.
  * @isolate: callback function that is resposible for deciding what to do with
  *  the item currently being scanned
  * @cb_arg: opaque type that will be passed to @isolate
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c0f24a9..4c88d72 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -29,6 +29,7 @@ struct page_cgroup;
 struct page;
 struct mm_struct;
 struct kmem_cache;
+struct list_lru;
 
 /*
  * The corresponding mem_cgroup_stat_names is defined in mm/memcontrol.c,
@@ -523,6 +524,9 @@ __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 void mem_cgroup_destroy_cache(struct kmem_cache *cachep);
 void kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
+int memcg_list_lru_init(struct list_lru *lru);
+void memcg_list_lru_destroy(struct list_lru *lru);
+
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
  * @gfp: the gfp allocation flags.
@@ -687,6 +691,15 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 static inline void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 {
 }
+
+static inline int memcg_list_lru_init(struct list_lru *lru)
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
index 7d4a9c2..1c0f39a 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -9,19 +9,70 @@
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/shrinker.h>
+#include <linux/memcontrol.h>
+#include <linux/page_cgroup.h>
 #include <linux/list_lru.h>
 
+#ifdef CONFIG_MEMCG_KMEM
+static struct list_lru_one *lru_of_index(struct list_lru *lru,
+					 int memcg_id)
+{
+	struct list_lru_one **memcg_lrus;
+	struct list_lru_one *olru;
+
+	if (memcg_id < 0)
+		return &lru->global;
+
+	rcu_read_lock();
+	memcg_lrus = rcu_dereference(lru->memcg);
+	olru = memcg_lrus[memcg_id];
+	rcu_read_unlock();
+
+	return olru;
+}
+
+static struct list_lru_one *lru_of_page(struct list_lru *lru,
+					struct page *page)
+{
+	struct mem_cgroup *memcg = NULL;
+	struct page_cgroup *pc;
+
+	pc = lookup_page_cgroup(compound_head(page));
+	if (PageCgroupUsed(pc)) {
+		lock_page_cgroup(pc);
+		if (PageCgroupUsed(pc))
+			memcg = pc->mem_cgroup;
+		unlock_page_cgroup(pc);
+	}
+	return lru_of_index(lru, memcg_cache_id(memcg));
+}
+#else
+static inline struct list_lru_one *lru_of_index(struct list_lru *lru,
+						int memcg_id)
+{
+	return &lru->global;
+}
+
+static inline struct list_lru_one *lru_of_page(struct list_lru *lru,
+					       struct page *page)
+{
+	return &lru->global;
+}
+#endif /* CONFIG_MEMCG_KMEM */
+
 bool list_lru_add(struct list_lru *lru, struct list_head *item)
 {
-	int nid = page_to_nid(virt_to_page(item));
-	struct list_lru_node *nlru = &lru->node[nid];
+	struct page *page = virt_to_page(item);
+	int nid = page_to_nid(page);
+	struct list_lru_one *olru = lru_of_page(lru, page);
+	struct list_lru_node *nlru = &olru->node[nid];
 
 	spin_lock(&nlru->lock);
 	WARN_ON_ONCE(nlru->nr_items < 0);
 	if (list_empty(item)) {
 		list_add_tail(item, &nlru->list);
 		if (nlru->nr_items++ == 0)
-			node_set(nid, lru->active_nodes);
+			node_set(nid, olru->active_nodes);
 		spin_unlock(&nlru->lock);
 		return true;
 	}
@@ -32,14 +83,16 @@ EXPORT_SYMBOL_GPL(list_lru_add);
 
 bool list_lru_del(struct list_lru *lru, struct list_head *item)
 {
-	int nid = page_to_nid(virt_to_page(item));
-	struct list_lru_node *nlru = &lru->node[nid];
+	struct page *page = virt_to_page(item);
+	int nid = page_to_nid(page);
+	struct list_lru_one *olru = lru_of_page(lru, page);
+	struct list_lru_node *nlru = &olru->node[nid];
 
 	spin_lock(&nlru->lock);
 	if (!list_empty(item)) {
 		list_del_init(item);
 		if (--nlru->nr_items == 0)
-			node_clear(nid, lru->active_nodes);
+			node_clear(nid, olru->active_nodes);
 		WARN_ON_ONCE(nlru->nr_items < 0);
 		spin_unlock(&nlru->lock);
 		return true;
@@ -50,10 +103,10 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 EXPORT_SYMBOL_GPL(list_lru_del);
 
 static unsigned long
-list_lru_count_node(struct list_lru *lru, int nid)
+list_lru_count_node(struct list_lru_one *olru, int nid)
 {
 	unsigned long count = 0;
-	struct list_lru_node *nlru = &lru->node[nid];
+	struct list_lru_node *nlru = &olru->node[nid];
 
 	spin_lock(&nlru->lock);
 	WARN_ON_ONCE(nlru->nr_items < 0);
@@ -67,23 +120,36 @@ unsigned long list_lru_count(struct list_lru *lru, struct shrink_control *sc)
 {
 	long count = 0;
 	int nid;
+	struct list_lru_one *olru;
+	struct mem_cgroup *memcg;
 
-	if (sc)
-		return list_lru_count_node(lru, sc->nid);
+	if (sc) {
+		olru = lru_of_index(lru, memcg_cache_id(sc->memcg));
+		return list_lru_count_node(olru, sc->nid);
+	}
+
+	memcg = NULL;
+	do {
+		if (memcg && !memcg_kmem_is_active(memcg))
+			goto next;
 
-	for_each_node_mask(nid, lru->active_nodes)
-		count += list_lru_count_node(lru, nid);
+		olru = lru_of_index(lru, memcg_cache_id(memcg));
+		for_each_node_mask(nid, olru->active_nodes)
+			count += list_lru_count_node(olru, nid);
+next:
+		memcg = mem_cgroup_iter(NULL, memcg, NULL);
+	} while (memcg);
 
 	return count;
 }
 EXPORT_SYMBOL_GPL(list_lru_count);
 
 static unsigned long
-list_lru_walk_node(struct list_lru *lru, int nid, list_lru_walk_cb isolate,
+list_lru_walk_node(struct list_lru_one *olru, int nid, list_lru_walk_cb isolate,
 		   void *cb_arg, unsigned long *nr_to_walk)
 {
 
-	struct list_lru_node	*nlru = &lru->node[nid];
+	struct list_lru_node *nlru = &olru->node[nid];
 	struct list_head *item, *n;
 	unsigned long isolated = 0;
 
@@ -104,7 +170,7 @@ restart:
 		switch (ret) {
 		case LRU_REMOVED:
 			if (--nlru->nr_items == 0)
-				node_clear(nid, lru->active_nodes);
+				node_clear(nid, olru->active_nodes);
 			WARN_ON_ONCE(nlru->nr_items < 0);
 			isolated++;
 			break;
@@ -134,42 +200,154 @@ unsigned long list_lru_walk(struct list_lru *lru, struct shrink_control *sc,
 {
 	long isolated = 0;
 	int nid;
+	struct list_lru_one *olru;
+	struct mem_cgroup *memcg;
 
-	if (sc)
-		return list_lru_walk_node(lru, sc->nid, isolate,
+	if (sc) {
+		olru = lru_of_index(lru, memcg_cache_id(sc->memcg));
+		return list_lru_walk_node(olru, sc->nid, isolate,
 					  cb_arg, nr_to_walk);
-
-	for_each_node_mask(nid, lru->active_nodes) {
-		isolated += list_lru_walk_node(lru, nid, isolate,
-					       cb_arg, nr_to_walk);
-		if (*nr_to_walk <= 0)
-			break;
 	}
+
+	memcg = NULL;
+	do {
+		if (memcg && !memcg_kmem_is_active(memcg))
+			goto next;
+
+		olru = lru_of_index(lru, memcg_cache_id(memcg));
+		for_each_node_mask(nid, olru->active_nodes) {
+			isolated += list_lru_walk_node(olru, nid, isolate,
+						       cb_arg, nr_to_walk);
+			if (*nr_to_walk <= 0) {
+				mem_cgroup_iter_break(NULL, memcg);
+				goto out;
+			}
+		}
+next:
+		memcg = mem_cgroup_iter(NULL, memcg, NULL);
+	} while (memcg);
+out:
 	return isolated;
 }
 EXPORT_SYMBOL_GPL(list_lru_walk);
 
-int list_lru_init(struct list_lru *lru)
+static int list_lru_init_one(struct list_lru_one *olru)
 {
 	int i;
-	size_t size = sizeof(*lru->node) * nr_node_ids;
 
-	lru->node = kzalloc(size, GFP_KERNEL);
-	if (!lru->node)
+	olru->node = kcalloc(nr_node_ids, sizeof(*olru->node), GFP_KERNEL);
+	if (!olru->node)
 		return -ENOMEM;
 
-	nodes_clear(lru->active_nodes);
+	nodes_clear(olru->active_nodes);
 	for (i = 0; i < nr_node_ids; i++) {
-		spin_lock_init(&lru->node[i].lock);
-		INIT_LIST_HEAD(&lru->node[i].list);
-		lru->node[i].nr_items = 0;
+		struct list_lru_node *nlru = &olru->node[i];
+
+		spin_lock_init(&nlru->lock);
+		INIT_LIST_HEAD(&nlru->list);
+		nlru->nr_items = 0;
 	}
 	return 0;
 }
+
+static void list_lru_destroy_one(struct list_lru_one *olru)
+{
+	kfree(olru->node);
+}
+
+int list_lru_init(struct list_lru *lru)
+{
+	int err;
+
+	err = list_lru_init_one(&lru->global);
+	if (err)
+		goto fail;
+
+	err = memcg_list_lru_init(lru);
+	if (err)
+		goto fail;
+
+	return 0;
+fail:
+	list_lru_destroy_one(&lru->global);
+	lru->global.node = NULL; /* see list_lru_destroy() */
+	return err;
+}
 EXPORT_SYMBOL_GPL(list_lru_init);
 
 void list_lru_destroy(struct list_lru *lru)
 {
-	kfree(lru->node);
+	/*
+	 * It is common throughout the kernel source tree to call the
+	 * destructor on a zeroed out object that has not been initialized or
+	 * whose initialization failed, because it greatly simplifies fail
+	 * paths. Once the list_lru structure was implemented, its destructor
+	 * consisted of the only call to kfree() and thus conformed to the
+	 * rule, but as it growed, it became more complex so that calling
+	 * destructor on an uninitialized object would be a bug. To preserve
+	 * backward compatibility, we explicitly exit the destructor if the
+	 * object seems to be uninitialized.
+	 */
+	if (!lru->global.node)
+		return;
+
+	list_lru_destroy_one(&lru->global);
+	memcg_list_lru_destroy(lru);
 }
 EXPORT_SYMBOL_GPL(list_lru_destroy);
+
+#ifdef CONFIG_MEMCG_KMEM
+int list_lru_memcg_alloc(struct list_lru *lru, int memcg_id)
+{
+	int err;
+	struct list_lru_one *olru;
+
+	olru = kmalloc(sizeof(*olru), GFP_KERNEL);
+	if (!olru)
+		return -ENOMEM;
+
+	err = list_lru_init_one(olru);
+	if (err) {
+		kfree(olru);
+		return err;
+	}
+
+	VM_BUG_ON(lru->memcg[memcg_id]);
+	lru->memcg[memcg_id] = olru;
+	return 0;
+}
+
+void list_lru_memcg_free(struct list_lru *lru, int memcg_id)
+{
+	struct list_lru_one *olru;
+
+	olru = lru->memcg[memcg_id];
+	if (olru) {
+		list_lru_destroy_one(olru);
+		kfree(olru);
+		lru->memcg[memcg_id] = NULL;
+	}
+}
+
+int list_lru_grow_memcg(struct list_lru *lru, size_t new_array_size)
+{
+	int i;
+	struct list_lru_one **memcg_lrus;
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
+	VM_BUG_ON(lru->memcg_old);
+	lru->memcg_old = lru->memcg;
+	rcu_assign_pointer(lru->memcg, memcg_lrus);
+	return 0;
+}
+#endif /* CONFIG_MEMCG_KMEM */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a3f479b..b15219e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -55,6 +55,7 @@
 #include <linux/cpu.h>
 #include <linux/oom.h>
 #include <linux/lockdep.h>
+#include <linux/list_lru.h>
 #include "internal.h"
 #include <net/sock.h>
 #include <net/ip.h>
@@ -3034,6 +3035,137 @@ static size_t memcg_caches_array_size(int num_groups)
 }
 
 /*
+ * The list of all list_lru structures. Protected by memcg_create_mutex.
+ * Needed for updating all per-memcg LRUs whenever a kmem-enabled memcg is
+ * created or destroyed.
+ */
+static LIST_HEAD(all_memcg_lrus);
+
+static void __memcg_destroy_all_lrus(int memcg_id)
+{
+	struct list_lru *lru;
+
+	list_for_each_entry(lru, &all_memcg_lrus, list)
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
+		mutex_lock(&memcg_create_mutex);
+		__memcg_destroy_all_lrus(memcg_id);
+		mutex_unlock(&memcg_create_mutex);
+	}
+}
+
+/*
+ * This function allocates LRUs for a memcg in all list_lru structures. It is
+ * called under memcg_create_mutex when a new kmem-active memcg is added.
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
+		list_for_each_entry(lru, &all_memcg_lrus, list) {
+			err = list_lru_grow_memcg(lru, new_array_size);
+			if (err)
+				goto out;
+		}
+	}
+
+	list_for_each_entry(lru, &all_memcg_lrus, list) {
+		err = list_lru_memcg_alloc(lru, new_memcg_id);
+		if (err) {
+			__memcg_destroy_all_lrus(new_memcg_id);
+			break;
+		}
+	}
+out:
+	if (grow) {
+		synchronize_rcu();
+		list_for_each_entry(lru, &all_memcg_lrus, list) {
+			kfree(lru->memcg_old);
+			lru->memcg_old = NULL;
+		}
+	}
+	return err;
+}
+
+int memcg_list_lru_init(struct list_lru *lru)
+{
+	int err = 0;
+	int i;
+	struct mem_cgroup *memcg;
+
+	lru->memcg = NULL;
+	lru->memcg_old = NULL;
+
+	mutex_lock(&memcg_create_mutex);
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
+	list_add(&lru->list, &all_memcg_lrus);
+out:
+	mutex_unlock(&memcg_create_mutex);
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
+	mutex_lock(&memcg_create_mutex);
+	list_del(&lru->list);
+	array_size = memcg_limited_groups_array_size;
+	mutex_unlock(&memcg_create_mutex);
+
+	if (lru->memcg) {
+		for (i = 0; i < array_size; i++)
+			list_lru_memcg_free(lru, i);
+		kfree(lru->memcg);
+	}
+}
+
+/*
  * This is a bit cumbersome, but it is rarely used and avoids a backpointer
  * in the memcg_cache_params struct.
  */
@@ -3164,15 +3296,30 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 	 */
 	memcg_kmem_set_activated(memcg);
 
+	/*
+	 * We need to init the memcg lru lists before we update the caches.
+	 * Once the caches are updated, they will be able to start hosting
+	 * objects. If a cache is created very quickly and an element is used
+	 * and disposed to the lru quickly as well, we can end up with a NULL
+	 * pointer dereference while trying to add a new element to a memcg
+	 * lru.
+	 */
+	ret = memcg_init_all_lrus(num);
+	if (ret)
+		goto out;
+
 	ret = memcg_update_all_caches(num+1);
-	if (ret) {
-		ida_simple_remove(&kmem_limited_groups, num);
-		memcg_kmem_clear_activated(memcg);
-		return ret;
-	}
+	if (ret)
+		goto out_destroy_all_lrus;
 
 	memcg->kmemcg_id = num;
 	return 0;
+out_destroy_all_lrus:
+	__memcg_destroy_all_lrus(num);
+out:
+	ida_simple_remove(&kmem_limited_groups, num);
+	memcg_kmem_clear_activated(memcg);
+	return ret;
 }
 
 /*
@@ -5955,6 +6102,7 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
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
