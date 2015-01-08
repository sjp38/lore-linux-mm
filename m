Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id D3DA26B0075
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 05:54:00 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so11059473pad.10
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 02:54:00 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id y8si8075407pdm.53.2015.01.08.02.53.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 02:53:58 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 8/9] list_lru: introduce per-memcg lists
Date: Thu, 8 Jan 2015 13:53:18 +0300
Message-ID: <f6b91440fb3201d54b63502e1efee2ea71751d1f.1420711973.git.vdavydov@parallels.com>
In-Reply-To: <cover.1420711973.git.vdavydov@parallels.com>
References: <cover.1420711973.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Dave Chinner <david@fromorbit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

There are several FS shrinkers, including super_block::s_shrink, that
keep reclaimable objects in the list_lru structure. Hence to turn them
to memcg-aware shrinkers, it is enough to make list_lru per-memcg.

This patch does the trick. It adds an array of lru lists to the
list_lru_node structure (per-node part of the list_lru), one for each
kmem-active memcg, and dispatches every item addition or removal to the
list corresponding to the memcg which the item is accounted to. So now
the list_lru structure is not just per node, but per node and per memcg.

Not all list_lrus need this feature, so this patch also adds a new
method, list_lru_init_memcg, which initializes a list_lru as memcg
aware. Otherwise (i.e. if initialized with old list_lru_init), the
list_lru won't have per memcg lists.

Just like per memcg caches arrays, the arrays of per-memcg lists are
indexed by memcg_cache_id, so we must grow them whenever
memcg_nr_cache_ids is increased. So we introduce a callback,
memcg_update_all_list_lrus, invoked by memcg_alloc_cache_id if the id
space is full.

The locking is implemented in a manner similar to lruvecs, i.e. we have
one lock per node that protects all lists (both global and per cgroup)
on the node.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/list_lru.h   |   52 ++++--
 include/linux/memcontrol.h |   14 ++
 mm/list_lru.c              |  374 +++++++++++++++++++++++++++++++++++++++++---
 mm/memcontrol.c            |   20 +++
 4 files changed, 424 insertions(+), 36 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index ee9486ac0621..305b598abac2 100644
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
@@ -22,11 +24,26 @@ enum lru_status {
 				   internally, but has to return locked. */
 };
 
-struct list_lru_node {
-	spinlock_t		lock;
+struct list_lru_one {
 	struct list_head	list;
 	/* kept as signed so we can catch imbalance bugs */
 	long			nr_items;
+};
+
+struct list_lru_memcg {
+	/* array of per cgroup lists, indexed by memcg_cache_id */
+	struct list_lru_one	*lru[0];
+};
+
+struct list_lru_node {
+	/* protects all lists on the node, including per cgroup */
+	spinlock_t		lock;
+	/* global list, used for the root cgroup in cgroup aware lrus */
+	struct list_lru_one	lru;
+#ifdef CONFIG_MEMCG_KMEM
+	/* for cgroup aware lrus points to per cgroup lists, otherwise NULL */
+	struct list_lru_memcg	*memcg_lrus;
+#endif
 } ____cacheline_aligned_in_smp;
 
 struct list_lru {
@@ -37,11 +54,14 @@ struct list_lru {
 };
 
 void list_lru_destroy(struct list_lru *lru);
-int list_lru_init_key(struct list_lru *lru, struct lock_class_key *key);
-static inline int list_lru_init(struct list_lru *lru)
-{
-	return list_lru_init_key(lru, NULL);
-}
+int __list_lru_init(struct list_lru *lru, bool memcg_aware,
+		    struct lock_class_key *key);
+
+#define list_lru_init(lru)		__list_lru_init((lru), false, NULL)
+#define list_lru_init_key(lru, key)	__list_lru_init((lru), false, (key))
+#define list_lru_init_memcg(lru)	__list_lru_init((lru), true, NULL)
+
+int memcg_update_all_list_lrus(int num_memcgs);
 
 /**
  * list_lru_add: add an element to the lru list's tail
@@ -75,20 +95,23 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item);
 bool list_lru_del(struct list_lru *lru, struct list_head *item);
 
 /**
- * list_lru_count_node: return the number of objects currently held by @lru
+ * list_lru_count_one: return the number of objects currently held by @lru
  * @lru: the lru pointer.
  * @nid: the node id to count from.
+ * @memcg: the cgroup to count from.
  *
  * Always return a non-negative number, 0 for empty lists. There is no
  * guarantee that the list is not updated while the count is being computed.
  * Callers that want such a guarantee need to provide an outer lock.
  */
+unsigned long list_lru_count_one(struct list_lru *lru,
+				 int nid, struct mem_cgroup *memcg);
 unsigned long list_lru_count_node(struct list_lru *lru, int nid);
 
 static inline unsigned long list_lru_shrink_count(struct list_lru *lru,
 						  struct shrink_control *sc)
 {
-	return list_lru_count_node(lru, sc->nid);
+	return list_lru_count_one(lru, sc->nid, sc->memcg);
 }
 
 static inline unsigned long list_lru_count(struct list_lru *lru)
@@ -105,9 +128,10 @@ static inline unsigned long list_lru_count(struct list_lru *lru)
 typedef enum lru_status
 (*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock, void *cb_arg);
 /**
- * list_lru_walk_node: walk a list_lru, isolating and disposing freeable items.
+ * list_lru_walk_one: walk a list_lru, isolating and disposing freeable items.
  * @lru: the lru pointer.
  * @nid: the node id to scan from.
+ * @memcg: the cgroup to scan from.
  * @isolate: callback function that is resposible for deciding what to do with
  *  the item currently being scanned
  * @cb_arg: opaque type that will be passed to @isolate
@@ -125,6 +149,10 @@ typedef enum lru_status
  *
  * Return value: the number of objects effectively removed from the LRU.
  */
+unsigned long list_lru_walk_one(struct list_lru *lru,
+				int nid, struct mem_cgroup *memcg,
+				list_lru_walk_cb isolate, void *cb_arg,
+				unsigned long *nr_to_walk);
 unsigned long list_lru_walk_node(struct list_lru *lru, int nid,
 				 list_lru_walk_cb isolate, void *cb_arg,
 				 unsigned long *nr_to_walk);
@@ -133,8 +161,8 @@ static inline unsigned long
 list_lru_shrink_walk(struct list_lru *lru, struct shrink_control *sc,
 		     list_lru_walk_cb isolate, void *cb_arg)
 {
-	return list_lru_walk_node(lru, sc->nid, isolate, cb_arg,
-				  &sc->nr_to_scan);
+	return list_lru_walk_one(lru, sc->nid, sc->memcg, isolate, cb_arg,
+				 &sc->nr_to_scan);
 }
 
 static inline unsigned long
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 8dafad6bb248..22bb13afa399 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -401,6 +401,8 @@ int memcg_cache_id(struct mem_cgroup *memcg);
 struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep);
 void __memcg_kmem_put_cache(struct kmem_cache *cachep);
 
+struct mem_cgroup *__mem_cgroup_from_kmem(void *ptr);
+
 int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
 		      unsigned long nr_pages);
 void memcg_uncharge_kmem(struct mem_cgroup *memcg, unsigned long nr_pages);
@@ -497,6 +499,13 @@ static __always_inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
 	if (memcg_kmem_enabled())
 		__memcg_kmem_put_cache(cachep);
 }
+
+static __always_inline struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
+{
+	if (!memcg_kmem_enabled())
+		return NULL;
+	return __mem_cgroup_from_kmem(ptr);
+}
 #else
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
@@ -548,6 +557,11 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 static inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
 {
 }
+
+static inline struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
+{
+	return NULL;
+}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/list_lru.c b/mm/list_lru.c
index a9021cb3ccde..79aee70c3b9d 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -10,6 +10,7 @@
 #include <linux/list_lru.h>
 #include <linux/slab.h>
 #include <linux/mutex.h>
+#include <linux/memcontrol.h>
 
 #ifdef CONFIG_MEMCG_KMEM
 static LIST_HEAD(list_lrus);
@@ -38,16 +39,71 @@ static void list_lru_unregister(struct list_lru *lru)
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
+#ifdef CONFIG_MEMCG_KMEM
+static inline bool list_lru_memcg_aware(struct list_lru *lru)
+{
+	return !!lru->node[0].memcg_lrus;
+}
+
+static inline struct list_lru_one *
+list_lru_from_memcg_idx(struct list_lru_node *nlru, int idx)
+{
+	/*
+	 * The lock protects the array of per cgroup lists from relocation
+	 * (see memcg_update_list_lru_node).
+	 */
+	lockdep_assert_held(&nlru->lock);
+	if (nlru->memcg_lrus && idx >= 0)
+		return nlru->memcg_lrus->lru[idx];
+
+	return &nlru->lru;
+}
+
+static inline struct list_lru_one *
+list_lru_from_kmem(struct list_lru_node *nlru, void *ptr)
+{
+	struct mem_cgroup *memcg;
+
+	if (!nlru->memcg_lrus)
+		return &nlru->lru;
+
+	memcg = mem_cgroup_from_kmem(ptr);
+	if (!memcg)
+		return &nlru->lru;
+
+	return list_lru_from_memcg_idx(nlru, memcg_cache_id(memcg));
+}
+#else
+static inline bool list_lru_memcg_aware(struct list_lru *lru)
+{
+	return false;
+}
+
+static inline struct list_lru_one *
+list_lru_from_memcg_idx(struct list_lru_node *nlru, int idx)
+{
+	return &nlru->lru;
+}
+
+static inline struct list_lru_one *
+list_lru_from_kmem(struct list_lru_node *nlru, void *ptr)
+{
+	return &nlru->lru;
+}
+#endif /* CONFIG_MEMCG_KMEM */
+
 bool list_lru_add(struct list_lru *lru, struct list_head *item)
 {
 	int nid = page_to_nid(virt_to_page(item));
 	struct list_lru_node *nlru = &lru->node[nid];
+	struct list_lru_one *l;
 
 	spin_lock(&nlru->lock);
-	WARN_ON_ONCE(nlru->nr_items < 0);
+	l = list_lru_from_kmem(nlru, item);
+	WARN_ON_ONCE(l->nr_items < 0);
 	if (list_empty(item)) {
-		list_add_tail(item, &nlru->list);
-		nlru->nr_items++;
+		list_add_tail(item, &l->list);
+		l->nr_items++;
 		spin_unlock(&nlru->lock);
 		return true;
 	}
@@ -60,12 +116,14 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 {
 	int nid = page_to_nid(virt_to_page(item));
 	struct list_lru_node *nlru = &lru->node[nid];
+	struct list_lru_one *l;
 
 	spin_lock(&nlru->lock);
+	l = list_lru_from_kmem(nlru, item);
 	if (!list_empty(item)) {
 		list_del_init(item);
-		nlru->nr_items--;
-		WARN_ON_ONCE(nlru->nr_items < 0);
+		l->nr_items--;
+		WARN_ON_ONCE(l->nr_items < 0);
 		spin_unlock(&nlru->lock);
 		return true;
 	}
@@ -74,33 +132,58 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 }
 EXPORT_SYMBOL_GPL(list_lru_del);
 
-unsigned long
-list_lru_count_node(struct list_lru *lru, int nid)
+static unsigned long __list_lru_count_one(struct list_lru *lru,
+					  int nid, int memcg_idx)
 {
-	unsigned long count = 0;
 	struct list_lru_node *nlru = &lru->node[nid];
+	struct list_lru_one *l;
+	unsigned long count;
 
 	spin_lock(&nlru->lock);
-	WARN_ON_ONCE(nlru->nr_items < 0);
-	count += nlru->nr_items;
+	l = list_lru_from_memcg_idx(nlru, memcg_idx);
+	WARN_ON_ONCE(l->nr_items < 0);
+	count = l->nr_items;
 	spin_unlock(&nlru->lock);
 
 	return count;
 }
+
+unsigned long list_lru_count_one(struct list_lru *lru,
+				 int nid, struct mem_cgroup *memcg)
+{
+	return __list_lru_count_one(lru, nid, memcg_cache_id(memcg));
+}
+EXPORT_SYMBOL_GPL(list_lru_count_one);
+
+unsigned long list_lru_count_node(struct list_lru *lru, int nid)
+{
+	long count = 0;
+	int memcg_idx;
+
+	count += __list_lru_count_one(lru, nid, -1);
+	if (list_lru_memcg_aware(lru)) {
+		for_each_memcg_cache_index(memcg_idx)
+			count += __list_lru_count_one(lru, nid, memcg_idx);
+	}
+	return count;
+}
 EXPORT_SYMBOL_GPL(list_lru_count_node);
 
-unsigned long
-list_lru_walk_node(struct list_lru *lru, int nid, list_lru_walk_cb isolate,
-		   void *cb_arg, unsigned long *nr_to_walk)
+static unsigned long
+__list_lru_walk_one(struct list_lru *lru, int nid, int memcg_idx,
+		    list_lru_walk_cb isolate, void *cb_arg,
+		    unsigned long *nr_to_walk)
 {
 
-	struct list_lru_node	*nlru = &lru->node[nid];
+	struct list_lru_node *nlru = &lru->node[nid];
+	struct list_lru_one *l;
 	struct list_head *item, *n;
 	unsigned long isolated = 0;
 
 	spin_lock(&nlru->lock);
+	l = list_lru_from_memcg_idx(nlru, memcg_idx);
 restart:
-	list_for_each_safe(item, n, &nlru->list) {
+	list_for_each_safe(item, n, &l->list) {
 		enum lru_status ret;
 
 		/*
@@ -116,8 +199,8 @@ restart:
 		case LRU_REMOVED_RETRY:
 			assert_spin_locked(&nlru->lock);
 		case LRU_REMOVED:
-			nlru->nr_items--;
-			WARN_ON_ONCE(nlru->nr_items < 0);
+			l->nr_items--;
+			WARN_ON_ONCE(l->nr_items < 0);
 			isolated++;
 			/*
 			 * If the lru lock has been dropped, our list
@@ -128,7 +211,7 @@ restart:
 				goto restart;
 			break;
 		case LRU_ROTATE:
-			list_move_tail(item, &nlru->list);
+			list_move_tail(item, &l->list);
 			break;
 		case LRU_SKIP:
 			break;
@@ -147,36 +230,279 @@ restart:
 	spin_unlock(&nlru->lock);
 	return isolated;
 }
+
+unsigned long
+list_lru_walk_one(struct list_lru *lru, int nid, struct mem_cgroup *memcg,
+		  list_lru_walk_cb isolate, void *cb_arg,
+		  unsigned long *nr_to_walk)
+{
+	return __list_lru_walk_one(lru, nid, memcg_cache_id(memcg),
+				   isolate, cb_arg, nr_to_walk);
+}
+EXPORT_SYMBOL_GPL(list_lru_walk_one);
+
+unsigned long list_lru_walk_node(struct list_lru *lru, int nid,
+				 list_lru_walk_cb isolate, void *cb_arg,
+				 unsigned long *nr_to_walk)
+{
+	long isolated = 0;
+	int memcg_idx;
+
+	isolated += __list_lru_walk_one(lru, nid, -1, isolate, cb_arg,
+					nr_to_walk);
+	if (*nr_to_walk > 0 && list_lru_memcg_aware(lru)) {
+		for_each_memcg_cache_index(memcg_idx) {
+			isolated += __list_lru_walk_one(lru, nid, memcg_idx,
+						isolate, cb_arg, nr_to_walk);
+			if (*nr_to_walk <= 0)
+				break;
+		}
+	}
+	return isolated;
+}
 EXPORT_SYMBOL_GPL(list_lru_walk_node);
 
-int list_lru_init_key(struct list_lru *lru, struct lock_class_key *key)
+static void init_one_lru(struct list_lru_one *l)
+{
+	INIT_LIST_HEAD(&l->list);
+	l->nr_items = 0;
+}
+
+#ifdef CONFIG_MEMCG_KMEM
+static void __memcg_destroy_list_lru_node(struct list_lru_memcg *memcg_lrus,
+					  int begin, int end)
+{
+	int i;
+
+	for (i = begin; i < end; i++)
+		kfree(memcg_lrus->lru[i]);
+}
+
+static int __memcg_init_list_lru_node(struct list_lru_memcg *memcg_lrus,
+				      int begin, int end)
+{
+	int i;
+
+	for (i = begin; i < end; i++) {
+		struct list_lru_one *l;
+
+		l = kmalloc(sizeof(struct list_lru_one), GFP_KERNEL);
+		if (!l)
+			goto fail;
+
+		init_one_lru(l);
+		memcg_lrus->lru[i] = l;
+	}
+	return 0;
+fail:
+	__memcg_destroy_list_lru_node(memcg_lrus, begin, i - 1);
+	return -ENOMEM;
+}
+
+static int memcg_init_list_lru_node(struct list_lru_node *nlru)
+{
+	int size = memcg_nr_cache_ids;
+
+	nlru->memcg_lrus = kmalloc(size * sizeof(void *), GFP_KERNEL);
+	if (!nlru->memcg_lrus)
+		return -ENOMEM;
+
+	if (__memcg_init_list_lru_node(nlru->memcg_lrus, 0, size)) {
+		kfree(nlru->memcg_lrus);
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void memcg_destroy_list_lru_node(struct list_lru_node *nlru)
+{
+	__memcg_destroy_list_lru_node(nlru->memcg_lrus, 0, memcg_nr_cache_ids);
+	kfree(nlru->memcg_lrus);
+}
+
+static int memcg_update_list_lru_node(struct list_lru_node *nlru,
+				      int old_size, int new_size)
+{
+	struct list_lru_memcg *old, *new;
+
+	BUG_ON(old_size > new_size);
+
+	old = nlru->memcg_lrus;
+	new = kmalloc(new_size * sizeof(void *), GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
+
+	if (__memcg_init_list_lru_node(new, old_size, new_size)) {
+		kfree(new);
+		return -ENOMEM;
+	}
+
+	memcpy(new, old, old_size * sizeof(void *));
+
+	/*
+	 * The lock guarantees that we won't race with a reader
+	 * (see list_lru_from_memcg_idx).
+	 *
+	 * Since list_lru_{add,del} may be called under an IRQ-safe lock,
+	 * we have to use IRQ-safe primitives here to avoid deadlock.
+	 */
+	spin_lock_irq(&nlru->lock);
+	nlru->memcg_lrus = new;
+	spin_unlock_irq(&nlru->lock);
+
+	kfree(old);
+	return 0;
+}
+
+static void memcg_cancel_update_list_lru_node(struct list_lru_node *nlru,
+					      int old_size, int new_size)
+{
+	/* do not bother shrinking the array back to the old size, because we
+	 * cannot handle allocation failures here */
+	__memcg_destroy_list_lru_node(nlru->memcg_lrus, old_size, new_size);
+}
+
+static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
+{
+	int i;
+
+	for (i = 0; i < nr_node_ids; i++) {
+		if (!memcg_aware)
+			lru->node[i].memcg_lrus = NULL;
+		else if (memcg_init_list_lru_node(&lru->node[i]))
+			goto fail;
+	}
+	return 0;
+fail:
+	for (i = i - 1; i >= 0; i--)
+		memcg_destroy_list_lru_node(&lru->node[i]);
+	return -ENOMEM;
+}
+
+static void memcg_destroy_list_lru(struct list_lru *lru)
+{
+	int i;
+
+	if (!list_lru_memcg_aware(lru))
+		return;
+
+	for (i = 0; i < nr_node_ids; i++)
+		memcg_destroy_list_lru_node(&lru->node[i]);
+}
+
+static int memcg_update_list_lru(struct list_lru *lru,
+				 int old_size, int new_size)
+{
+	int i;
+
+	if (!list_lru_memcg_aware(lru))
+		return 0;
+
+	for (i = 0; i < nr_node_ids; i++) {
+		if (memcg_update_list_lru_node(&lru->node[i],
+					       old_size, new_size))
+			goto fail;
+	}
+	return 0;
+fail:
+	for (i = i - 1; i >= 0; i--)
+		memcg_cancel_update_list_lru_node(&lru->node[i],
+						  old_size, new_size);
+	return -ENOMEM;
+}
+
+static void memcg_cancel_update_list_lru(struct list_lru *lru,
+					 int old_size, int new_size)
+{
+	int i;
+
+	if (!list_lru_memcg_aware(lru))
+		return;
+
+	for (i = 0; i < nr_node_ids; i++)
+		memcg_cancel_update_list_lru_node(&lru->node[i],
+						  old_size, new_size);
+}
+
+int memcg_update_all_list_lrus(int new_size)
+{
+	int ret = 0;
+	struct list_lru *lru;
+	int old_size = memcg_nr_cache_ids;
+
+	mutex_lock(&list_lrus_mutex);
+	list_for_each_entry(lru, &list_lrus, list) {
+		ret = memcg_update_list_lru(lru, old_size, new_size);
+		if (ret)
+			goto fail;
+	}
+out:
+	mutex_unlock(&list_lrus_mutex);
+	return ret;
+fail:
+	list_for_each_entry_continue_reverse(lru, &list_lrus, list)
+		memcg_cancel_update_list_lru(lru, old_size, new_size);
+	goto out;
+}
+#else
+static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
+{
+	return 0;
+}
+
+static void memcg_destroy_list_lru(struct list_lru *lru)
+{
+}
+#endif /* CONFIG_MEMCG_KMEM */
+
+int __list_lru_init(struct list_lru *lru, bool memcg_aware,
+		    struct lock_class_key *key)
 {
 	int i;
 	size_t size = sizeof(*lru->node) * nr_node_ids;
+	int err = -ENOMEM;
+
+	memcg_get_cache_ids();
 
 	lru->node = kzalloc(size, GFP_KERNEL);
 	if (!lru->node)
-		return -ENOMEM;
+		goto out;
 
 	for (i = 0; i < nr_node_ids; i++) {
 		spin_lock_init(&lru->node[i].lock);
 		if (key)
 			lockdep_set_class(&lru->node[i].lock, key);
-		INIT_LIST_HEAD(&lru->node[i].list);
-		lru->node[i].nr_items = 0;
+		init_one_lru(&lru->node[i].lru);
+	}
+
+	err = memcg_init_list_lru(lru, memcg_aware);
+	if (err) {
+		kfree(lru->node);
+		goto out;
 	}
+
 	list_lru_register(lru);
-	return 0;
+out:
+	memcg_put_cache_ids();
+	return err;
 }
-EXPORT_SYMBOL_GPL(list_lru_init_key);
+EXPORT_SYMBOL_GPL(__list_lru_init);
 
 void list_lru_destroy(struct list_lru *lru)
 {
 	/* Already destroyed or not yet initialized? */
 	if (!lru->node)
 		return;
+
+	memcg_get_cache_ids();
+
 	list_lru_unregister(lru);
+
+	memcg_destroy_list_lru(lru);
 	kfree(lru->node);
 	lru->node = NULL;
+
+	memcg_put_cache_ids();
 }
 EXPORT_SYMBOL_GPL(list_lru_destroy);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3596f44875c1..825ef6a273e9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2581,6 +2581,8 @@ static int memcg_alloc_cache_id(void)
 
 	err = memcg_update_all_caches(size);
 	if (!err)
+		err = memcg_update_all_list_lrus(size);
+	if (!err)
 		memcg_nr_cache_ids = size;
 
 	up_write(&memcg_cache_ids_sem);
@@ -2774,6 +2776,24 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	memcg_uncharge_kmem(memcg, 1 << order);
 	page->mem_cgroup = NULL;
 }
+
+struct mem_cgroup *__mem_cgroup_from_kmem(void *ptr)
+{
+	struct mem_cgroup *memcg = NULL;
+	struct kmem_cache *cachep;
+	struct page *page;
+
+	page = virt_to_head_page(ptr);
+	if (PageSlab(page)) {
+		cachep = page->slab_cache;
+		if (!is_root_cache(cachep))
+			memcg = cachep->memcg_params->memcg;
+	} else
+		/* page allocated by alloc_kmem_pages */
+		memcg = page->mem_cgroup;
+
+	return memcg;
+}
 #endif /* CONFIG_MEMCG_KMEM */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
