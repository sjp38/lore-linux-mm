Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id BD88D900014
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 06:38:19 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id et14so920491pad.31
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 03:38:19 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id kj10si3966501pbd.12.2014.10.24.03.38.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 03:38:18 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 8/9] list_lru: introduce per-memcg lists
Date: Fri, 24 Oct 2014 14:37:39 +0400
Message-ID: <d64dc9c03d3336ad91deade1a4baa36c2138be7a.1414145863.git.vdavydov@parallels.com>
In-Reply-To: <cover.1414145862.git.vdavydov@parallels.com>
References: <cover.1414145862.git.vdavydov@parallels.com>
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
memcg_max_cache_ids is increased. So we introduce a callback,
memcg_update_all_list_lrus, invoked by memcg_alloc_cache_id if the id
space is full.

The locking is implemented in a manner similar to lruvecs, i.e. we have
one lock per node that protects all lists (both global and per cgroup)
on the node.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/list_lru.h   |   54 ++++++--
 include/linux/memcontrol.h |    7 +
 mm/list_lru.c              |  325 ++++++++++++++++++++++++++++++++++++++++----
 mm/memcontrol.c            |   27 ++++
 4 files changed, 377 insertions(+), 36 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index ee9486ac0621..731acd3bd6e6 100644
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
@@ -36,12 +53,17 @@ struct list_lru {
 #endif
 };
 
+#ifdef CONFIG_MEMCG_KMEM
+int memcg_update_all_list_lrus(int num_memcgs);
+#endif
+
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
 
 /**
  * list_lru_add: add an element to the lru list's tail
@@ -75,20 +97,23 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item);
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
@@ -105,9 +130,10 @@ static inline unsigned long list_lru_count(struct list_lru *lru)
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
@@ -125,6 +151,10 @@ typedef enum lru_status
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
@@ -133,8 +163,8 @@ static inline unsigned long
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
index eebb56b94d23..fd1219cb8ee5 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -419,6 +419,8 @@ static inline bool memcg_kmem_enabled(void)
 bool memcg_kmem_is_active(struct mem_cgroup *memcg);
 bool memcg_kmem_is_active_subtree(struct mem_cgroup *memcg);
 
+struct mem_cgroup *mem_cgroup_from_kmem(void *ptr);
+
 /*
  * In general, we'll do everything in our power to not incur in any overhead
  * for non-memcg users for the kmem functions. Not even a function call, if we
@@ -554,6 +556,11 @@ static inline bool memcg_kmem_is_active_subtree(struct mem_cgroup *memcg)
 	return false;
 }
 
+static inline struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
+{
+	return NULL;
+}
+
 static inline bool
 memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
 {
diff --git a/mm/list_lru.c b/mm/list_lru.c
index a9021cb3ccde..4041e5a1569b 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -10,6 +10,7 @@
 #include <linux/list_lru.h>
 #include <linux/slab.h>
 #include <linux/mutex.h>
+#include <linux/memcontrol.h>
 
 #ifdef CONFIG_MEMCG_KMEM
 static LIST_HEAD(list_lrus);
@@ -38,16 +39,56 @@ static void list_lru_unregister(struct list_lru *lru)
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
+#ifdef CONFIG_MEMCG_KMEM
+static inline bool list_lru_memcg_aware(struct list_lru *lru)
+{
+	return !!lru->node[0].memcg_lrus;
+}
+
+/*
+ * For the given list_lru_node return the list corresponding to the memory
+ * cgroup whose memcg_cache_id equals @idx. If @idx < 0 or the list_lru is not
+ * cgroup aware, the global list is returned.
+ */
+static inline struct list_lru_one *
+lru_from_memcg_idx(struct list_lru_node *nlru, int idx)
+{
+	/*
+	 * The lock protects the array of per cgroup lists from relocation
+	 * (see update_memcg_lrus).
+	 */
+	lockdep_assert_held(&nlru->lock);
+	if (nlru->memcg_lrus && idx >= 0)
+		return nlru->memcg_lrus->lru[idx];
+
+	return &nlru->lru;
+}
+#else
+static inline bool list_lru_memcg_aware(struct list_lru *lru)
+{
+	return false;
+}
+
+static inline struct list_lru_one *
+lru_from_memcg_idx(struct list_lru_node *nlru, int idx)
+{
+	return &nlru->lru;
+}
+#endif /* CONFIG_MEMCG_KMEM */
+
 bool list_lru_add(struct list_lru *lru, struct list_head *item)
 {
 	int nid = page_to_nid(virt_to_page(item));
 	struct list_lru_node *nlru = &lru->node[nid];
+	struct mem_cgroup *memcg = mem_cgroup_from_kmem(item);
+	struct list_lru_one *l;
 
 	spin_lock(&nlru->lock);
-	WARN_ON_ONCE(nlru->nr_items < 0);
+	l = lru_from_memcg_idx(nlru, memcg_cache_id(memcg));
+	WARN_ON_ONCE(l->nr_items < 0);
 	if (list_empty(item)) {
-		list_add_tail(item, &nlru->list);
-		nlru->nr_items++;
+		list_add_tail(item, &l->list);
+		l->nr_items++;
 		spin_unlock(&nlru->lock);
 		return true;
 	}
@@ -60,12 +101,15 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 {
 	int nid = page_to_nid(virt_to_page(item));
 	struct list_lru_node *nlru = &lru->node[nid];
+	struct mem_cgroup *memcg = mem_cgroup_from_kmem(item);
+	struct list_lru_one *l;
 
 	spin_lock(&nlru->lock);
+	l = lru_from_memcg_idx(nlru, memcg_cache_id(memcg));
 	if (!list_empty(item)) {
 		list_del_init(item);
-		nlru->nr_items--;
-		WARN_ON_ONCE(nlru->nr_items < 0);
+		l->nr_items--;
+		WARN_ON_ONCE(l->nr_items < 0);
 		spin_unlock(&nlru->lock);
 		return true;
 	}
@@ -74,33 +118,58 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
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
+	l = lru_from_memcg_idx(nlru, memcg_idx);
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
+	l = lru_from_memcg_idx(nlru, memcg_idx);
 restart:
-	list_for_each_safe(item, n, &nlru->list) {
+	list_for_each_safe(item, n, &l->list) {
 		enum lru_status ret;
 
 		/*
@@ -116,8 +185,8 @@ restart:
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
@@ -128,7 +197,7 @@ restart:
 				goto restart;
 			break;
 		case LRU_ROTATE:
-			list_move_tail(item, &nlru->list);
+			list_move_tail(item, &l->list);
 			break;
 		case LRU_SKIP:
 			break;
@@ -147,12 +216,205 @@ restart:
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
+/*
+ * Free the given array of per cgroup lists.
+ */
+static void list_lru_memcg_free(struct list_lru_memcg *p)
+{
+	int i, nr;
+
+	if (p) {
+		nr = ksize(p) / sizeof(void *);
+		for (i = 0; i < nr; i++)
+			kfree(p->lru[i]);
+		kfree(p);
+	}
+}
+
+/*
+ * Allocate an array of per cgroup lists that may store up to @nr lists and
+ * initialize it starting from @init_from.
+ */
+static struct list_lru_memcg *list_lru_memcg_alloc(int nr, int init_from)
+{
+	int i;
+	struct list_lru_memcg *p;
+	struct list_lru_one *l;
+
+	p = kmalloc(nr * sizeof(void *), GFP_KERNEL);
+	if (!p)
+		return NULL;
+
+	/*
+	 * Instead of storing the array size along with the array, we employ
+	 * ksize(). Therefore we must zero the whole structure to make sure
+	 * list_lru_memcg_free() won't dereference crap.
+	 */
+	memset(p, 0, ksize(p));
+
+	for (i = init_from; i < nr; i++) {
+		l = kmalloc(sizeof(struct list_lru_one), GFP_KERNEL);
+		if (!l) {
+			list_lru_memcg_free(p);
+			return NULL;
+		}
+		init_one_lru(l);
+		p->lru[i] = l;
+	}
+	return p;
+}
+
+/*
+ * Destroy per cgroup lists on each node for the given list_lru.
+ */
+static void list_lru_destroy_memcg_lrus(struct list_lru *lru)
+{
+	int i;
+
+	for (i = 0; i < nr_node_ids; i++)
+		list_lru_memcg_free(lru->node[i].memcg_lrus);
+}
+
+/*
+ * Initialize per cgroup lists on each node for the given list_lru.
+ */
+static int list_lru_init_memcg_lrus(struct list_lru *lru)
+{
+	int i;
+	struct list_lru_memcg *p;
+
+	for (i = 0; i < nr_node_ids; i++) {
+		/*
+		 * If memcg_max_cache_ids equals 0 (i.e. kmem accounting is
+		 * inactive), kmalloc will return ZERO_SIZE_PTR (not NULL), so
+		 * that the lru will still be cgroup aware.
+		 */
+		p = list_lru_memcg_alloc(memcg_max_cache_ids, 0);
+		if (!p) {
+			list_lru_destroy_memcg_lrus(lru);
+			return -ENOMEM;
+		}
+		lru->node[i].memcg_lrus = p;
+	}
+	return 0;
+}
+
+/*
+ * Update per cgroup list arrays on each node for the given list_lru to be able
+ * to store up to @num_memcgs elements.
+ */
+static int list_lru_update_memcg_lrus(struct list_lru *lru, int num_memcgs)
+{
+	int i;
+	struct list_lru_node *nlru;
+	struct list_lru_memcg *old, *new;
+
+	for (i = 0; i < nr_node_ids; i++) {
+		nlru = &lru->node[i];
+		old = nlru->memcg_lrus;
+
+		new = list_lru_memcg_alloc(num_memcgs, memcg_max_cache_ids);
+		if (!new)
+			return -ENOMEM;
+
+		memcpy(new, old, memcg_max_cache_ids * sizeof(void *));
+
+		/*
+		 * The lock guarantees that we won't race with a reader
+		 * (see also lru_from_memcg_idx).
+		 *
+		 * Since list_lru functions may be called under an IRQ-safe
+		 * lock, we have to use IRQ-safe primitives here to avoid
+		 * deadlock.
+		 */
+		spin_lock_irq(&nlru->lock);
+		nlru->memcg_lrus = new;
+		spin_unlock_irq(&nlru->lock);
+
+		kfree(old);
+	}
+	return 0;
+}
+
+/*
+ * This function is called from the memory cgroup core before increasing
+ * memcg_max_cache_ids. We must update all lrus' arrays of per cgroup lists to
+ * conform to the new size. The memcg_cache_id_space_sem is held for writing.
+ */
+int memcg_update_all_list_lrus(int num_memcgs)
+{
+	int ret = 0;
+	struct list_lru *lru;
+
+	mutex_lock(&list_lrus_mutex);
+	list_for_each_entry(lru, &list_lrus, list) {
+		ret = list_lru_update_memcg_lrus(lru, num_memcgs);
+		/*
+		 * It isn't worth the trouble to revert to the old size if we
+		 * fail, so we just leave the lrus updated to this point.
+		 */
+		if (ret)
+			break;
+	}
+	mutex_unlock(&list_lrus_mutex);
+	return ret;
+}
+#else
+static int list_lru_init_memcg_lrus(struct list_lru *lru)
+{
+	return 0;
+}
+
+static void list_lru_destroy_memcg_lrus(struct list_lru *lru)
+{
+}
+#endif /* CONFIG_MEMCG_KMEM */
+
+int __list_lru_init(struct list_lru *lru, bool memcg_aware,
+		    struct lock_class_key *key)
 {
 	int i;
 	size_t size = sizeof(*lru->node) * nr_node_ids;
+	int err = 0;
 
 	lru->node = kzalloc(size, GFP_KERNEL);
 	if (!lru->node)
@@ -162,13 +424,27 @@ int list_lru_init_key(struct list_lru *lru, struct lock_class_key *key)
 		spin_lock_init(&lru->node[i].lock);
 		if (key)
 			lockdep_set_class(&lru->node[i].lock, key);
-		INIT_LIST_HEAD(&lru->node[i].list);
-		lru->node[i].nr_items = 0;
+		init_one_lru(&lru->node[i].lru);
 	}
-	list_lru_register(lru);
-	return 0;
+
+	/*
+	 * Note, memcg_max_cache_ids must remain stable while we are
+	 * allocating per cgroup lrus *and* registering the list_lru,
+	 * otherwise memcg_update_all_list_lrus can skip our list_lru.
+	 */
+	memcg_lock_cache_id_space();
+	if (memcg_aware)
+		err = list_lru_init_memcg_lrus(lru);
+
+	if (!err)
+		list_lru_register(lru);
+	else
+		kfree(lru->node);
+
+	memcg_unlock_cache_id_space();
+	return err;
 }
-EXPORT_SYMBOL_GPL(list_lru_init_key);
+EXPORT_SYMBOL_GPL(__list_lru_init);
 
 void list_lru_destroy(struct list_lru *lru)
 {
@@ -176,6 +452,7 @@ void list_lru_destroy(struct list_lru *lru)
 	if (!lru->node)
 		return;
 	list_lru_unregister(lru);
+	list_lru_destroy_memcg_lrus(lru);
 	kfree(lru->node);
 	lru->node = NULL;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 444bf8fe5f1d..81f4d2485fbc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2625,6 +2625,9 @@ static int memcg_alloc_cache_id(void)
 	mutex_unlock(&memcg_slab_mutex);
 
 	if (!err)
+		err = memcg_update_all_list_lrus(size);
+
+	if (!err)
 		memcg_max_cache_ids = size;
 	up_write(&memcg_cache_id_space_sem);
 
@@ -3013,6 +3016,30 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	memcg_uncharge_kmem(memcg, 1 << order);
 	pc->mem_cgroup = NULL;
 }
+
+struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
+{
+	struct mem_cgroup *memcg = NULL;
+	struct page_cgroup *pc;
+	struct kmem_cache *cachep;
+	struct page *page;
+
+	if (!memcg_kmem_enabled())
+		return NULL;
+
+	page = virt_to_head_page(ptr);
+	if (PageSlab(page)) {
+		cachep = page->slab_cache;
+		if (!is_root_cache(cachep))
+			memcg = cachep->memcg_params->memcg;
+	} else {
+		/* page allocated with alloc_kmem_pages */
+		pc = lookup_page_cgroup(page);
+		if (pc->mem_cgroup)
+			memcg = pc->mem_cgroup;
+	}
+	return memcg;
+}
 #else
 static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
