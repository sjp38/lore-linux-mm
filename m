Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 801D06B0072
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 11:16:11 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lf10so2975546pab.22
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 08:16:11 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id h9si11924776pat.157.2014.09.21.08.16.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Sep 2014 08:16:10 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 13/14] list_lru: introduce per-memcg lists
Date: Sun, 21 Sep 2014 19:14:45 +0400
Message-ID: <d6275f11381a89905375c2ed4e2c3f58919b9de6.1411301245.git.vdavydov@parallels.com>
In-Reply-To: <cover.1411301245.git.vdavydov@parallels.com>
References: <cover.1411301245.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

There are several FS shrinkers, including super_block::s_shrink, that
keep reclaimable objects in the list_lru structure. Hence to turn them
to memcg-aware shrinkers, it is enough to make list_lru per-memcg.

This patch does the trick. It adds an array of lru lists to the
list_lru_node structure (per-node part of the list_lru), one for each
kmem-active memcg, and dispatches every item addition or removal to the
list corresponding to the memcg which the item is accounted to. So now
the list_lru structure is not just per node, but per node and per memcg.

Not all list_lrus need this feature, so this patch also adds the
memcg_aware bool argument to list_lru_init. One has to pass true in it
to make the list_lru memcg-aware.

Just like per memcg caches arrays, the arrays of per-memcg lists are
indexed by memcg_cache_id, so we must grow them whenever
memcg_max_cache_ids is increased. So we introduce a callback,
memcg_update_all_list_lrus, invoked by memcg_alloc_cache_id if the id
space is full.

Since on memcg destruction (css offline) we release its cache id to
avoid uncontrollable per-memcg arrays growth, we must deal with
list_lrus corresponding to dead memcgs somehow. In this patch, all
elements from the lru lists corresponding to the dead memcg are moved to
its parent's lists (reparented). This is kind of tricky, because this
can race with concurrent lru walkers and items insertions/removals. To
achieve that we have to remove nr_items<0 checks, because it can become
negative for a short time during reparenting. Secondly, reparenting
imposes a limitation on the locking scheme of the list_lru. We must have
a stable lock for all per-memcg lrus. That's why all per-memcg lrus on
the same node are protected by the node's list_lru_node->lock. This is
similar to how lruvecs locking works.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/gfs2/main.c             |    2 +-
 fs/super.c                 |    4 +-
 fs/xfs/xfs_buf.c           |    2 +-
 fs/xfs/xfs_qm.c            |    2 +-
 include/linux/list_lru.h   |   85 +++++-----
 include/linux/memcontrol.h |    7 +
 mm/list_lru.c              |  403 +++++++++++++++++++++++++++++++++++++++++---
 mm/memcontrol.c            |   36 ++++
 mm/workingset.c            |    3 +-
 9 files changed, 471 insertions(+), 73 deletions(-)

diff --git a/fs/gfs2/main.c b/fs/gfs2/main.c
index 82b6ac829656..fb51e99a0281 100644
--- a/fs/gfs2/main.c
+++ b/fs/gfs2/main.c
@@ -84,7 +84,7 @@ static int __init init_gfs2_fs(void)
 	if (error)
 		return error;
 
-	error = list_lru_init(&gfs2_qd_lru);
+	error = list_lru_init(&gfs2_qd_lru, false);
 	if (error)
 		goto fail_lru;
 
diff --git a/fs/super.c b/fs/super.c
index a2b735a42e74..a82e97b0b8b9 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -189,9 +189,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 	INIT_HLIST_BL_HEAD(&s->s_anon);
 	INIT_LIST_HEAD(&s->s_inodes);
 
-	if (list_lru_init(&s->s_dentry_lru))
+	if (list_lru_init(&s->s_dentry_lru, false))
 		goto fail;
-	if (list_lru_init(&s->s_inode_lru))
+	if (list_lru_init(&s->s_inode_lru, false))
 		goto fail;
 
 	init_rwsem(&s->s_umount);
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index e02a49a30f89..1f789f805dcc 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -1681,7 +1681,7 @@ xfs_alloc_buftarg(
 	if (xfs_setsize_buftarg_early(btp, bdev))
 		goto error;
 
-	if (list_lru_init(&btp->bt_lru))
+	if (list_lru_init(&btp->bt_lru, false))
 		goto error;
 
 	btp->bt_shrinker.count_objects = xfs_buftarg_shrink_count;
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index 51167f44c408..a6a56197656f 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -576,7 +576,7 @@ xfs_qm_init_quotainfo(
 
 	qinf = mp->m_quotainfo = kmem_zalloc(sizeof(xfs_quotainfo_t), KM_SLEEP);
 
-	error = list_lru_init(&qinf->qi_lru);
+	error = list_lru_init(&qinf->qi_lru, false);
 	if (error)
 		goto out_free_qinf;
 
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index ee9486ac0621..9fe8b09f496e 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -22,11 +22,26 @@ enum lru_status {
 				   internally, but has to return locked. */
 };
 
-struct list_lru_node {
-	spinlock_t		lock;
+struct list_lru_one {
 	struct list_head	list;
-	/* kept as signed so we can catch imbalance bugs */
+	/* may become negative during memcg reparenting */
 	long			nr_items;
+};
+
+struct list_lru_memcg {
+	/* array of per-memcg lists, indexed by memcg_cache_id */
+	struct list_lru_one	*lru[0];
+};
+
+struct list_lru_node {
+	/* protects all lists on the node, including per-memcg */
+	spinlock_t		lock;
+	/* global list, used by the root cgroup in memcg-aware lrus */
+	struct list_lru_one	lru;
+#ifdef CONFIG_MEMCG_KMEM
+	/* for memcg-aware lrus points to per-memcg lists, otherwise NULL */
+	struct list_lru_memcg	*memcg_lrus;
+#endif
 } ____cacheline_aligned_in_smp;
 
 struct list_lru {
@@ -36,11 +51,17 @@ struct list_lru {
 #endif
 };
 
+#ifdef CONFIG_MEMCG_KMEM
+int memcg_update_all_list_lrus(int num_memcgs);
+void memcg_reparent_all_list_lrus(int from_idx, int to_idx);
+#endif
+
 void list_lru_destroy(struct list_lru *lru);
-int list_lru_init_key(struct list_lru *lru, struct lock_class_key *key);
-static inline int list_lru_init(struct list_lru *lru)
+int list_lru_init_key(struct list_lru *lru, bool memcg_aware,
+		      struct lock_class_key *key);
+static inline int list_lru_init(struct list_lru *lru, bool memcg_aware)
 {
-	return list_lru_init_key(lru, NULL);
+	return list_lru_init_key(lru, memcg_aware, NULL);
 }
 
 /**
@@ -75,39 +96,32 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item);
 bool list_lru_del(struct list_lru *lru, struct list_head *item);
 
 /**
- * list_lru_count_node: return the number of objects currently held by @lru
+ * list_lru_count_one: return the number of objects currently held by @lru
  * @lru: the lru pointer.
  * @nid: the node id to count from.
+ * @memcg: the memcg to count from.
  *
  * Always return a non-negative number, 0 for empty lists. There is no
  * guarantee that the list is not updated while the count is being computed.
  * Callers that want such a guarantee need to provide an outer lock.
  */
-unsigned long list_lru_count_node(struct list_lru *lru, int nid);
+unsigned long list_lru_count_one(struct list_lru *lru,
+				 int nid, struct mem_cgroup *memcg);
+unsigned long list_lru_count(struct list_lru *lru);
 
 static inline unsigned long list_lru_shrink_count(struct list_lru *lru,
 						  struct shrink_control *sc)
 {
-	return list_lru_count_node(lru, sc->nid);
-}
-
-static inline unsigned long list_lru_count(struct list_lru *lru)
-{
-	long count = 0;
-	int nid;
-
-	for_each_node_state(nid, N_NORMAL_MEMORY)
-		count += list_lru_count_node(lru, nid);
-
-	return count;
+	return list_lru_count_one(lru, sc->nid, sc->memcg);
 }
 
 typedef enum lru_status
 (*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock, void *cb_arg);
 /**
- * list_lru_walk_node: walk a list_lru, isolating and disposing freeable items.
+ * list_lru_walk_one: walk a list_lru, isolating and disposing freeable items.
  * @lru: the lru pointer.
  * @nid: the node id to scan from.
+ * @memcg: the memcg to scan from.
  * @isolate: callback function that is resposible for deciding what to do with
  *  the item currently being scanned
  * @cb_arg: opaque type that will be passed to @isolate
@@ -125,31 +139,18 @@ typedef enum lru_status
  *
  * Return value: the number of objects effectively removed from the LRU.
  */
-unsigned long list_lru_walk_node(struct list_lru *lru, int nid,
-				 list_lru_walk_cb isolate, void *cb_arg,
-				 unsigned long *nr_to_walk);
+unsigned long list_lru_walk_one(struct list_lru *lru,
+				int nid, struct mem_cgroup *memcg,
+				list_lru_walk_cb isolate, void *cb_arg,
+				unsigned long *nr_to_walk);
+unsigned long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
+			    void *cb_arg, unsigned long nr_to_walk);
 
 static inline unsigned long
 list_lru_shrink_walk(struct list_lru *lru, struct shrink_control *sc,
 		     list_lru_walk_cb isolate, void *cb_arg)
 {
-	return list_lru_walk_node(lru, sc->nid, isolate, cb_arg,
-				  &sc->nr_to_scan);
-}
-
-static inline unsigned long
-list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
-	      void *cb_arg, unsigned long nr_to_walk)
-{
-	long isolated = 0;
-	int nid;
-
-	for_each_node_state(nid, N_NORMAL_MEMORY) {
-		isolated += list_lru_walk_node(lru, nid, isolate,
-					       cb_arg, &nr_to_walk);
-		if (nr_to_walk <= 0)
-			break;
-	}
-	return isolated;
+	return list_lru_walk_one(lru, sc->nid, sc->memcg, isolate, cb_arg,
+				 &sc->nr_to_scan);
 }
 #endif /* _LRU_LIST_H */
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f2cd342d6544..d1ab65b4ce02 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -435,6 +435,8 @@ static inline bool memcg_kmem_enabled(void)
 bool memcg_kmem_is_active(struct mem_cgroup *memcg);
 bool memcg_kmem_is_active_subtree(struct mem_cgroup *memcg);
 
+struct mem_cgroup *mem_cgroup_from_kmem(void *ptr);
+
 /*
  * In general, we'll do everything in our power to not incur in any overhead
  * for non-memcg users for the kmem functions. Not even a function call, if we
@@ -570,6 +572,11 @@ static inline bool memcg_kmem_is_active_subtree(struct mem_cgroup *memcg)
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
index 53086eda7942..f10529e47788 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -9,11 +9,28 @@
 #include <linux/mm.h>
 #include <linux/list_lru.h>
 #include <linux/slab.h>
+#include <linux/memcontrol.h>
 
 #ifdef CONFIG_MEMCG_KMEM
 static LIST_HEAD(list_lrus);
 static DEFINE_SPINLOCK(list_lrus_lock);
 
+/*
+ * Insertion/deletion to the list_lrus list must be atomic (nobody expects
+ * list_lru_destroy to block), but we still want to sleep while iterating over
+ * the list (e.g. to allocate).
+ *
+ * To make it possible we employ the fact that list removals don't require the
+ * caller to know the list to delete the item from. As a result, we can move
+ * list_lrus which we walked over to a temporary list and iterate over the
+ * list_lrus list releasing the lock whenever necessary until it empties. When
+ * we are done, we put all the elements we removed from the list during the
+ * walk back to the list_lrus list.
+ *
+ * The list_lrus_walk_mutex is used to synchronize concurrent walkers.
+ */
+static DEFINE_MUTEX(list_lrus_walk_mutex);
+
 static void list_lru_register(struct list_lru *lru)
 {
 	spin_lock(&list_lrus_lock);
@@ -37,16 +54,44 @@ static void list_lru_unregister(struct list_lru *lru)
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
+static inline bool list_lru_memcg_aware(struct list_lru *lru)
+{
+#ifdef CONFIG_MEMCG_KMEM
+	return !!lru->node[0].memcg_lrus;
+#else
+	return false;
+#endif
+}
+
+static inline struct list_lru_one *
+lru_from_memcg_idx(struct list_lru_node *nlru, int idx)
+{
+	struct list_lru_one *l = &nlru->lru;
+
+#ifdef CONFIG_MEMCG_KMEM
+	/*
+	 * The lock protects memcg_lrus array from relocation
+	 * (see update_memcg_lru).
+	 */
+	lockdep_assert_held(&nlru->lock);
+	if (nlru->memcg_lrus && idx >= 0)
+		l = nlru->memcg_lrus->lru[idx];
+#endif
+	return l;
+}
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
 	if (list_empty(item)) {
-		list_add_tail(item, &nlru->list);
-		nlru->nr_items++;
+		list_add_tail(item, &l->list);
+		l->nr_items++;
 		spin_unlock(&nlru->lock);
 		return true;
 	}
@@ -59,12 +104,14 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
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
 		spin_unlock(&nlru->lock);
 		return true;
 	}
@@ -73,33 +120,60 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
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
+	long count;
 
 	spin_lock(&nlru->lock);
-	WARN_ON_ONCE(nlru->nr_items < 0);
-	count += nlru->nr_items;
+	l = lru_from_memcg_idx(nlru, memcg_idx);
+	count = l->nr_items;
 	spin_unlock(&nlru->lock);
 
+	return count > 0 ? count : 0;
+}
+
+unsigned long list_lru_count_one(struct list_lru *lru,
+				 int nid, struct mem_cgroup *memcg)
+{
+	return __list_lru_count_one(lru, nid, memcg_cache_id(memcg));
+}
+EXPORT_SYMBOL_GPL(list_lru_count_one);
+
+unsigned long list_lru_count(struct list_lru *lru)
+{
+	long count = 0;
+	int nid, memcg_idx;
+
+	for_each_node_state(nid, N_NORMAL_MEMORY) {
+		count += __list_lru_count_one(lru, nid, -1);
+		if (!list_lru_memcg_aware(lru))
+			continue;
+		for (memcg_idx = 0;
+		     memcg_idx < memcg_max_cache_ids; memcg_idx++)
+			count += __list_lru_count_one(lru, nid, memcg_idx);
+	}
 	return count;
 }
-EXPORT_SYMBOL_GPL(list_lru_count_node);
+EXPORT_SYMBOL_GPL(list_lru_count);
 
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
@@ -115,8 +189,7 @@ restart:
 		case LRU_REMOVED_RETRY:
 			assert_spin_locked(&nlru->lock);
 		case LRU_REMOVED:
-			nlru->nr_items--;
-			WARN_ON_ONCE(nlru->nr_items < 0);
+			l->nr_items--;
 			isolated++;
 			/*
 			 * If the lru lock has been dropped, our list
@@ -127,7 +200,7 @@ restart:
 				goto restart;
 			break;
 		case LRU_ROTATE:
-			list_move_tail(item, &nlru->list);
+			list_move_tail(item, &l->list);
 			break;
 		case LRU_SKIP:
 			break;
@@ -146,12 +219,279 @@ restart:
 	spin_unlock(&nlru->lock);
 	return isolated;
 }
-EXPORT_SYMBOL_GPL(list_lru_walk_node);
 
-int list_lru_init_key(struct list_lru *lru, struct lock_class_key *key)
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
+unsigned long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
+			    void *cb_arg, unsigned long nr_to_walk)
+{
+	long isolated = 0;
+	int nid, memcg_idx;
+
+	for_each_node_state(nid, N_NORMAL_MEMORY) {
+		isolated += __list_lru_walk_one(lru, nid, -1,
+					isolate, cb_arg, &nr_to_walk);
+		if (nr_to_walk <= 0)
+			goto out;
+		if (!list_lru_memcg_aware(lru))
+			continue;
+		for (memcg_idx = 0;
+		     memcg_idx < memcg_max_cache_ids; memcg_idx++) {
+			isolated += __list_lru_walk_one(lru, nid, memcg_idx,
+						isolate, cb_arg, &nr_to_walk);
+			if (nr_to_walk <= 0)
+				goto out;
+		}
+	}
+out:
+	return isolated;
+}
+EXPORT_SYMBOL_GPL(list_lru_walk);
+
+static void init_one_lru(struct list_lru_one *l)
+{
+	INIT_LIST_HEAD(&l->list);
+	l->nr_items = 0;
+}
+
+#ifdef CONFIG_MEMCG_KMEM
+static void free_list_lru_memcg(struct list_lru_memcg *memcg_lrus)
+{
+	int i, nr;
+
+	if (memcg_lrus) {
+		nr = ksize(memcg_lrus) / sizeof(void *);
+		for (i = 0; i < nr; i++)
+			kfree(memcg_lrus->lru[i]);
+		kfree(memcg_lrus);
+	}
+}
+
+static struct list_lru_memcg *alloc_list_lru_memcg(int nr, int init_from)
+{
+	struct list_lru_memcg *memcg_lrus;
+	struct list_lru_one *l;
+	int i;
+	
+	memcg_lrus = kmalloc(nr * sizeof(void *), GFP_KERNEL);
+	if (!memcg_lrus)
+		return NULL;
+
+	/* make sure free_list_lru_memcg won't dereference crap */
+	memset(memcg_lrus, 0, ksize(memcg_lrus));
+
+	for (i = init_from; i < nr; i++) {
+		l = kmalloc(sizeof(struct list_lru_one), GFP_KERNEL);
+		if (!l) {
+			free_list_lru_memcg(memcg_lrus);
+			return NULL;
+		}
+		init_one_lru(l);
+		memcg_lrus->lru[i] = l;
+	}
+	return memcg_lrus;
+}
+
+static void list_lru_destroy_memcg(struct list_lru *lru)
+{
+	int i;
+
+	for (i = 0; i < nr_node_ids; i++)
+		free_list_lru_memcg(lru->node[i].memcg_lrus);
+}
+
+static int list_lru_init_memcg(struct list_lru *lru)
+{
+	int i;
+
+	for (i = 0; i < nr_node_ids; i++) {
+		/*
+		 * memcg_max_cache_ids can be 0, but memcg_lrus won't be NULL
+		 * then, it will be equal to ZERO_SIZE_PTR.
+		 */
+		lru->node[i].memcg_lrus =
+			alloc_list_lru_memcg(memcg_max_cache_ids, 0);
+		if (!lru->node[i].memcg_lrus) {
+			list_lru_destroy_memcg(lru);
+			return -ENOMEM;
+		}
+	}
+	return 0;
+}
+
+static void update_memcg_lru(struct list_lru_node *nlru,
+			      struct list_lru_memcg *new)
+{
+	struct list_lru_memcg *old = nlru->memcg_lrus;
+
+	memcpy(new, old, memcg_max_cache_ids * sizeof(void *));
+
+	spin_lock(&nlru->lock);
+	nlru->memcg_lrus = new;
+	spin_unlock(&nlru->lock);
+
+	kfree(old);
+}
+
+/*
+ * This function is called from the memory cgroup core before increasing
+ * memcg_max_cache_ids. We must update all lrus to conform to the new size.
+ * The memcg_cache_id_space_sem must be held for writing.
+ */
+int memcg_update_all_list_lrus(int num_memcgs)
+{
+	LIST_HEAD(updated);
+	struct list_lru_memcg **memcg_lrus;
+	bool memcg_lrus_allocated = false;
+	int i, ret = 0;
+
+	memcg_lrus = kmalloc(nr_node_ids * sizeof(void *), GFP_KERNEL);
+	if (!memcg_lrus)
+		return -ENOMEM;
+
+	mutex_lock(&list_lrus_walk_mutex);
+	spin_lock(&list_lrus_lock);
+	while (!list_empty(&list_lrus)) {
+		struct list_lru *lru;
+
+		lru = list_first_entry(&list_lrus, struct list_lru, list);
+		if (!list_lru_memcg_aware(lru))
+			goto next;
+
+		if (memcg_lrus_allocated)
+			goto update;
+
+		spin_unlock(&list_lrus_lock);
+		for (i = 0; i < nr_node_ids; i++) {
+			memcg_lrus[i] = alloc_list_lru_memcg(num_memcgs,
+							memcg_max_cache_ids);
+			if (!memcg_lrus[i]) {
+				ret = -ENOMEM;
+				break;
+			}
+		}
+		/* even if failed, we need to free what was allocated */
+		memset(memcg_lrus + i, 0, (nr_node_ids - i) * sizeof(void *));
+		memcg_lrus_allocated = true;
+		spin_lock(&list_lrus_lock);
+
+		if (ret)
+			break;
+		/*
+		 * We released the lock so we must check if there are still
+		 * memcg-aware list_lrus left on the list.
+		 */
+		continue;
+update:
+		for (i = 0; i < nr_node_ids; i++)
+			update_memcg_lru(&lru->node[i], memcg_lrus[i]);
+		memcg_lrus_allocated = false;
+next:
+		list_move(&lru->list, &updated);
+	}
+	list_splice(&updated, &list_lrus);
+	spin_unlock(&list_lrus_lock);
+	mutex_unlock(&list_lrus_walk_mutex);
+
+	if (memcg_lrus_allocated) {
+		for (i = 0; i < nr_node_ids; i++)
+			free_list_lru_memcg(memcg_lrus[i]);
+	}
+	kfree(memcg_lrus);
+	return ret;
+}
+
+static bool reparent_memcg_lru(struct list_lru_node *nlru,
+			       int from_idx, int to_idx)
+{
+	const int max_batch = 32;
+	int batch = 0;
+	struct list_lru_one *from, *to;
+	bool done;
+
+	/*
+	 * We can't just splice the lists, because walkers can drop the lock
+	 * after removing an element from the list, but before decreasing
+	 * nr_items. Splicing could therefore result in permanent divergence
+	 * between nr_items and the actual number of elements on the list. So
+	 * we iterate over all elements and move them one by one accounting
+	 * nr_items accordingly. This way the race with a walker is still
+	 * possible, but nr_items will be fixed once the walker reacquires the
+	 * lock.
+	 */
+	spin_lock(&nlru->lock);
+	from = lru_from_memcg_idx(nlru, from_idx);
+	to = lru_from_memcg_idx(nlru, to_idx);
+	while (!list_empty(&from->list)) {
+		list_move(from->list.next, &to->list);
+		from->nr_items--;
+		to->nr_items++;
+		if (++batch >= max_batch)
+			break;
+	}
+	done = list_empty(&from->list);
+	spin_unlock(&nlru->lock);
+	return done;
+}
+
+/*
+ * When a memcg dies, there still might be elements on its list_lrus. We can't
+ * just leave them there, because we want to release it cache id. So we move
+ * them to its parent's lrus.
+ */
+void memcg_reparent_all_list_lrus(int from_idx, int to_idx)
+{
+	LIST_HEAD(reparented);
+	int i;
+
+	mutex_lock(&list_lrus_walk_mutex);
+	spin_lock(&list_lrus_lock);
+	while (!list_empty(&list_lrus)) {
+		struct list_lru *lru;
+		bool done = true;
+
+		lru = list_first_entry(&list_lrus, struct list_lru, list);
+		if (!list_lru_memcg_aware(lru))
+			goto next;
+
+		for (i = 0; i < nr_node_ids; i++)
+			if (!reparent_memcg_lru(&lru->node[i],
+						from_idx, to_idx))
+				done = false;
+next:
+		if (done)
+			list_move(&lru->list, &reparented);
+		cond_resched_lock(&list_lrus_lock);
+	}
+	list_splice(&reparented, &list_lrus);
+	spin_unlock(&list_lrus_lock);
+	mutex_unlock(&list_lrus_walk_mutex);
+}
+#else
+static int list_lru_init_memcg(struct list_lru *lru)
+{
+	return 0;
+}
+
+static void list_lru_destroy_memcg(struct list_lru *lru)
+{
+}
+#endif /* CONFIG_MEMCG_KMEM */
+
+int list_lru_init_key(struct list_lru *lru, bool memcg_aware,
+		      struct lock_class_key *key)
 {
 	int i;
 	size_t size = sizeof(*lru->node) * nr_node_ids;
+	int err = 0;
 
 	lru->node = kzalloc(size, GFP_KERNEL);
 	if (!lru->node)
@@ -161,17 +501,30 @@ int list_lru_init_key(struct list_lru *lru, struct lock_class_key *key)
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
+	 * allocating per-memcg lrus *and* registering the list_lru,
+	 * otherwise memcg_update_all_list_lrus can skip our list_lru.
+	 */
+	memcg_lock_cache_id_space();
+	if (memcg_aware)
+		err = list_lru_init_memcg(lru);
+
+	if (!err)
+		list_lru_register(lru);
+
+	memcg_unlock_cache_id_space();
+	return err;
 }
 EXPORT_SYMBOL_GPL(list_lru_init_key);
 
 void list_lru_destroy(struct list_lru *lru)
 {
 	list_lru_unregister(lru);
+	list_lru_destroy_memcg(lru);
 	kfree(lru->node);
 }
 EXPORT_SYMBOL_GPL(list_lru_destroy);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0c6d412ae5a3..b82a6ea32ead 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2963,6 +2963,9 @@ static int memcg_alloc_cache_id(void)
 	mutex_unlock(&memcg_slab_mutex);
 
 	if (!err)
+		err = memcg_update_all_list_lrus(size);
+
+	if (!err)
 		memcg_max_cache_ids = size;
 	up_write(&memcg_cache_id_space_sem);
 
@@ -3150,6 +3153,15 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 	css_for_each_descendant_post(iter, &memcg->css)
 		mem_cgroup_from_css(iter)->kmemcg_id = parent_id;
 
+	/*
+	 * Move all elements from the dead cgroup's list_lrus to its parent's
+	 * so that we could release the id.
+	 *
+	 * This must be done strictly after we updated the cgroup's id in order
+	 * to guarantee no new elements will be added there afterwards.
+	 */
+	memcg_reparent_all_list_lrus(id, parent_id);
+
 	/* The id is not used anymore, free it so that it could be reused. */
 	memcg_free_cache_id(id);
 }
@@ -3411,6 +3423,30 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
 	memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
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
+		if (PageCgroupUsed(pc))
+			memcg = pc->mem_cgroup;
+	}
+	return memcg;
+}
 #else
 static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 {
diff --git a/mm/workingset.c b/mm/workingset.c
index d4fa7fb10a52..f8aae7497723 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -399,7 +399,8 @@ static int __init workingset_init(void)
 {
 	int ret;
 
-	ret = list_lru_init_key(&workingset_shadow_nodes, &shadow_nodes_key);
+	ret = list_lru_init_key(&workingset_shadow_nodes, false,
+				&shadow_nodes_key);
 	if (ret)
 		goto err;
 	ret = register_shrinker(&workingset_shadow_shrinker);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
