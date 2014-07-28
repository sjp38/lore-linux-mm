Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED926B003A
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 05:32:02 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so10252887pad.27
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 02:32:02 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id kn9si8604058pdb.409.2014.07.28.02.32.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jul 2014 02:32:01 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 4/6] list_lru: add per-memcg lists
Date: Mon, 28 Jul 2014 13:31:26 +0400
Message-ID: <d2b925bea8086db902bdca0e48aff999467d1807.1406536261.git.vdavydov@parallels.com>
In-Reply-To: <cover.1406536261.git.vdavydov@parallels.com>
References: <cover.1406536261.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, david@fromorbit.com, viro@zeniv.linux.org.uk, gthelen@google.com, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

There are several FS shrinkers, including super_block::s_shrink, that
keep reclaimable objects in the list_lru structure. Hence to turn them
to memcg-aware shrinkers, it is enough to make list_lru per-memcg.

This patch does the trick. It adds an array of LRU lists to the list_lru
structure, one for each kmem-active memcg, and dispatches every item
addition or removal operation to the list corresponding to the memcg the
item is accounted to.

To make a list_lru user memcg-aware, it's enough to pass
memcg_aware=true to list_lru_init, everything else is done
automatically.

Note, this patch removes VM_BUG_ON(!current->mm) from
memcg_{stop,resume}_kmem_account. This is, because these functions may
be invoked by memcg_register_list_lru while mounting filesystems on
early init, where we don't have ->mm yet. Calling them from kernel
threads won't hurt anyway.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/gfs2/main.c             |    2 +-
 fs/super.c                 |    4 +-
 fs/xfs/xfs_buf.c           |    2 +-
 fs/xfs/xfs_qm.c            |    2 +-
 include/linux/list_lru.h   |   86 ++++++++++--------
 include/linux/memcontrol.h |   42 +++++++++
 mm/list_lru.c              |  132 +++++++++++++++++++++++-----
 mm/memcontrol.c            |  208 ++++++++++++++++++++++++++++++++++++++++----
 mm/workingset.c            |    3 +-
 9 files changed, 402 insertions(+), 79 deletions(-)

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
index 1f34321e15b4..477102d59c7e 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -187,9 +187,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
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
index 1a5e178fd8d0..405ff6044a60 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -1669,7 +1669,7 @@ xfs_alloc_buftarg(
 	if (xfs_setsize_buftarg_early(btp, bdev))
 		goto error;
 
-	if (list_lru_init(&btp->bt_lru))
+	if (list_lru_init(&btp->bt_lru, false))
 		goto error;
 
 	btp->bt_shrinker.count_objects = xfs_buftarg_shrink_count;
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index 76640cd73a23..cb7267297783 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -670,7 +670,7 @@ xfs_qm_init_quotainfo(
 
 	qinf = mp->m_quotainfo = kmem_zalloc(sizeof(xfs_quotainfo_t), KM_SLEEP);
 
-	error = list_lru_init(&qinf->qi_lru);
+	error = list_lru_init(&qinf->qi_lru, false);
 	if (error)
 		goto out_free_qinf;
 
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index f500a2e39b13..cf1e73825431 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -11,6 +11,8 @@
 #include <linux/nodemask.h>
 #include <linux/shrinker.h>
 
+struct list_lru;
+
 /* list_lru_walk_cb has to always return one of those */
 enum lru_status {
 	LRU_REMOVED,		/* item removed from list */
@@ -29,16 +31,50 @@ struct list_lru_node {
 	long			nr_items;
 } ____cacheline_aligned_in_smp;
 
+struct memcg_list_lru_params {
+	/* list_lru which this struct is for */
+	struct list_lru		*owner;
+
+	/* list node for connecting to the list of all memcg-aware lrus */
+	struct list_head	list;
+
+	struct rcu_head		rcu_head;
+
+	/* array of per-memcg lrus, indexed by mem_cgroup->kmemcg_id */
+	struct list_lru_node	*node[0];
+};
+
 struct list_lru {
 	struct list_lru_node	*node;
 	nodemask_t		active_nodes;
+#ifdef CONFIG_MEMCG_KMEM
+	struct memcg_list_lru_params *memcg_params;
+#endif
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	struct lock_class_key	*key;
+#endif
 };
 
+#ifdef CONFIG_MEMCG_KMEM
+static inline bool list_lru_memcg_aware(struct list_lru *lru)
+{
+	return !!lru->memcg_params;
+}
+#else
+static inline bool list_lru_memcg_aware(struct list_lru *lru)
+{
+	return false;
+}
+#endif
+
+void list_lru_node_init(struct list_lru_node *n, struct list_lru *lru);
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
@@ -76,28 +112,20 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item);
  * list_lru_count_node: return the number of objects currently held by @lru
  * @lru: the lru pointer.
  * @nid: the node id to count from.
+ * @memcg: the memcg to count from
  *
  * Always return a non-negative number, 0 for empty lists. There is no
  * guarantee that the list is not updated while the count is being computed.
  * Callers that want such a guarantee need to provide an outer lock.
  */
-unsigned long list_lru_count_node(struct list_lru *lru, int nid);
+unsigned long list_lru_count_node(struct list_lru *lru,
+				  int nid, struct mem_cgroup *memcg);
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
-	for_each_node_mask(nid, lru->active_nodes)
-		count += list_lru_count_node(lru, nid);
-
-	return count;
+	return list_lru_count_node(lru, sc->nid, sc->memcg);
 }
 
 typedef enum lru_status
@@ -106,6 +134,7 @@ typedef enum lru_status
  * list_lru_walk_node: walk a list_lru, isolating and disposing freeable items.
  * @lru: the lru pointer.
  * @nid: the node id to scan from.
+ * @memcg: the memcg to scan from.
  * @isolate: callback function that is resposible for deciding what to do with
  *  the item currently being scanned
  * @cb_arg: opaque type that will be passed to @isolate
@@ -123,31 +152,18 @@ typedef enum lru_status
  *
  * Return value: the number of objects effectively removed from the LRU.
  */
-unsigned long list_lru_walk_node(struct list_lru *lru, int nid,
+unsigned long list_lru_walk_node(struct list_lru *lru,
+				 int nid, struct mem_cgroup *memcg,
 				 list_lru_walk_cb isolate, void *cb_arg,
 				 unsigned long *nr_to_walk);
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
-	for_each_node_mask(nid, lru->active_nodes) {
-		isolated += list_lru_walk_node(lru, nid, isolate,
-					       cb_arg, &nr_to_walk);
-		if (nr_to_walk <= 0)
-			break;
-	}
-	return isolated;
+	return list_lru_walk_node(lru, sc->nid, sc->memcg,
+				  isolate, cb_arg, &sc->nr_to_scan);
 }
 #endif /* _LRU_LIST_H */
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d0f3d8f0990c..962e36cb95ae 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -53,6 +53,21 @@ struct mem_cgroup_reclaim_cookie {
 	unsigned int generation;
 };
 
+/*
+ * Iteration constructs for visiting all cgroups (under a tree).  If
+ * loops are exited prematurely (break), mem_cgroup_iter_break() must
+ * be used for reference counting.
+ */
+#define for_each_mem_cgroup_tree(iter, root)		\
+	for (iter = mem_cgroup_iter(root, NULL, NULL);	\
+	     iter != NULL;				\
+	     iter = mem_cgroup_iter(root, iter, NULL))
+
+#define for_each_mem_cgroup(iter)			\
+	for (iter = mem_cgroup_iter(NULL, NULL, NULL);	\
+	     iter != NULL;				\
+	     iter = mem_cgroup_iter(NULL, iter, NULL))
+
 #ifdef CONFIG_MEMCG
 int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 			  gfp_t gfp_mask, struct mem_cgroup **memcgp);
@@ -459,6 +474,12 @@ void memcg_free_cache_params(struct kmem_cache *s);
 int memcg_update_cache_size(struct kmem_cache *s, int num_groups);
 void memcg_update_array_size(int num_groups);
 
+int memcg_register_list_lru(struct list_lru *lru);
+void memcg_unregister_list_lru(struct list_lru *lru);
+struct list_lru_node *memcg_list_lru(struct list_lru *lru,
+				     struct mem_cgroup *memcg);
+struct list_lru_node *memcg_list_lru_from_obj(struct list_lru *lru, void *obj);
+
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
@@ -611,6 +632,27 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
 	return cachep;
 }
+
+static inline int memcg_register_list_lru(struct list_lru *lru)
+{
+	return 0;
+}
+
+static inline void memcg_unregister_list_lru(struct list_lru *lru)
+{
+}
+
+static inline struct list_lru_node *memcg_list_lru(struct list_lru *lru,
+						   struct mem_cgroup *memcg)
+{
+	return NULL;
+}
+
+static inline struct list_lru_node *memcg_list_lru_from_obj(struct list_lru *lru,
+							    void *obj)
+{
+	return NULL;
+}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/list_lru.c b/mm/list_lru.c
index f1a0db194173..b914f0930c67 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -9,17 +9,24 @@
 #include <linux/mm.h>
 #include <linux/list_lru.h>
 #include <linux/slab.h>
+#include <linux/memcontrol.h>
 
 bool list_lru_add(struct list_lru *lru, struct list_head *item)
 {
-	int nid = page_to_nid(virt_to_page(item));
-	struct list_lru_node *nlru = &lru->node[nid];
+	int nid = -1;
+	struct list_lru_node *nlru;
+
+	nlru = memcg_list_lru_from_obj(lru, item);
+	if (!nlru) {
+		nid = page_to_nid(virt_to_page(item));
+		nlru = &lru->node[nid];
+	}
 
 	spin_lock(&nlru->lock);
 	WARN_ON_ONCE(nlru->nr_items < 0);
 	if (list_empty(item)) {
 		list_add_tail(item, &nlru->list);
-		if (nlru->nr_items++ == 0)
+		if (nlru->nr_items++ == 0 && nid >= 0)
 			node_set(nid, lru->active_nodes);
 		spin_unlock(&nlru->lock);
 		return true;
@@ -31,13 +38,19 @@ EXPORT_SYMBOL_GPL(list_lru_add);
 
 bool list_lru_del(struct list_lru *lru, struct list_head *item)
 {
-	int nid = page_to_nid(virt_to_page(item));
-	struct list_lru_node *nlru = &lru->node[nid];
+	int nid = -1;
+	struct list_lru_node *nlru;
+
+	nlru = memcg_list_lru_from_obj(lru, item);
+	if (!nlru) {
+		nid = page_to_nid(virt_to_page(item));
+		nlru = &lru->node[nid];
+	}
 
 	spin_lock(&nlru->lock);
 	if (!list_empty(item)) {
 		list_del_init(item);
-		if (--nlru->nr_items == 0)
+		if (--nlru->nr_items == 0 && nid >= 0)
 			node_clear(nid, lru->active_nodes);
 		WARN_ON_ONCE(nlru->nr_items < 0);
 		spin_unlock(&nlru->lock);
@@ -48,12 +61,18 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 }
 EXPORT_SYMBOL_GPL(list_lru_del);
 
-unsigned long
-list_lru_count_node(struct list_lru *lru, int nid)
+unsigned long list_lru_count_node(struct list_lru *lru,
+				  int nid, struct mem_cgroup *memcg)
 {
 	unsigned long count = 0;
 	struct list_lru_node *nlru = &lru->node[nid];
 
+	if (memcg) {
+		nlru = memcg_list_lru(lru, memcg);
+		if (!nlru)
+			return 0;
+	}
+
 	spin_lock(&nlru->lock);
 	WARN_ON_ONCE(nlru->nr_items < 0);
 	count += nlru->nr_items;
@@ -63,15 +82,41 @@ list_lru_count_node(struct list_lru *lru, int nid)
 }
 EXPORT_SYMBOL_GPL(list_lru_count_node);
 
-unsigned long
-list_lru_walk_node(struct list_lru *lru, int nid, list_lru_walk_cb isolate,
-		   void *cb_arg, unsigned long *nr_to_walk)
+unsigned long list_lru_count(struct list_lru *lru)
+{
+	long count = 0;
+	int nid;
+
+	for_each_node_mask(nid, lru->active_nodes)
+		count += list_lru_count_node(lru, nid, NULL);
+
+	if (list_lru_memcg_aware(lru)) {
+		struct mem_cgroup *memcg;
+
+		for_each_mem_cgroup(memcg)
+			count += list_lru_count_node(lru, 0, memcg);
+	}
+	return count;
+}
+EXPORT_SYMBOL_GPL(list_lru_count);
+
+unsigned long list_lru_walk_node(struct list_lru *lru,
+				 int nid, struct mem_cgroup *memcg,
+				 list_lru_walk_cb isolate, void *cb_arg,
+				 unsigned long *nr_to_walk)
 {
 
-	struct list_lru_node	*nlru = &lru->node[nid];
+	struct list_lru_node *nlru = &lru->node[nid];
 	struct list_head *item, *n;
 	unsigned long isolated = 0;
 
+	if (memcg) {
+		nlru = memcg_list_lru(lru, memcg);
+		if (!nlru)
+			return 0;
+		nid = -1;
+	}
+
 	spin_lock(&nlru->lock);
 restart:
 	list_for_each_safe(item, n, &nlru->list) {
@@ -90,7 +135,7 @@ restart:
 		case LRU_REMOVED_RETRY:
 			assert_spin_locked(&nlru->lock);
 		case LRU_REMOVED:
-			if (--nlru->nr_items == 0)
+			if (--nlru->nr_items == 0 && nid >= 0)
 				node_clear(nid, lru->active_nodes);
 			WARN_ON_ONCE(nlru->nr_items < 0);
 			isolated++;
@@ -124,7 +169,47 @@ restart:
 }
 EXPORT_SYMBOL_GPL(list_lru_walk_node);
 
-int list_lru_init_key(struct list_lru *lru, struct lock_class_key *key)
+unsigned long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
+			    void *cb_arg, unsigned long nr_to_walk)
+{
+	long isolated = 0;
+	int nid;
+
+	for_each_node_mask(nid, lru->active_nodes) {
+		isolated += list_lru_walk_node(lru, nid, NULL,
+					isolate, cb_arg, &nr_to_walk);
+		if (nr_to_walk <= 0)
+			break;
+	}
+	if (list_lru_memcg_aware(lru)) {
+		struct mem_cgroup *memcg;
+
+		for_each_mem_cgroup(memcg) {
+			isolated += list_lru_walk_node(lru, 0, memcg,
+						isolate, cb_arg, &nr_to_walk);
+			if (nr_to_walk <= 0) {
+				mem_cgroup_iter_break(NULL, memcg);
+				break;
+			}
+		}
+	}
+	return isolated;
+}
+EXPORT_SYMBOL_GPL(list_lru_walk);
+
+void list_lru_node_init(struct list_lru_node *n, struct list_lru *lru)
+{
+	spin_lock_init(&n->lock);
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	if (lru->key)
+		lockdep_set_class(&n->lock, lru->key);
+#endif
+	INIT_LIST_HEAD(&n->list);
+	n->nr_items = 0;
+}
+
+int list_lru_init_key(struct list_lru *lru, bool memcg_aware,
+		      struct lock_class_key *key)
 {
 	int i;
 	size_t size = sizeof(*lru->node) * nr_node_ids;
@@ -133,13 +218,19 @@ int list_lru_init_key(struct list_lru *lru, struct lock_class_key *key)
 	if (!lru->node)
 		return -ENOMEM;
 
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	lru->key = key;
+#endif
 	nodes_clear(lru->active_nodes);
-	for (i = 0; i < nr_node_ids; i++) {
-		spin_lock_init(&lru->node[i].lock);
-		if (key)
-			lockdep_set_class(&lru->node[i].lock, key);
-		INIT_LIST_HEAD(&lru->node[i].list);
-		lru->node[i].nr_items = 0;
+	for (i = 0; i < nr_node_ids; i++)
+		list_lru_node_init(&lru->node[i], lru);
+
+#ifdef CONFIG_MEMCG_KMEM
+	lru->memcg_params = NULL;
+#endif
+	if (memcg_aware && memcg_register_list_lru(lru)) {
+		list_lru_destroy(lru);
+		return -ENOMEM;
 	}
 	return 0;
 }
@@ -147,6 +238,7 @@ EXPORT_SYMBOL_GPL(list_lru_init_key);
 
 void list_lru_destroy(struct list_lru *lru)
 {
+	memcg_unregister_list_lru(lru);
 	kfree(lru->node);
 }
 EXPORT_SYMBOL_GPL(list_lru_destroy);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6a96a3994692..1030bba4b94f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1268,21 +1268,6 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
 		css_put(&prev->css);
 }
 
-/*
- * Iteration constructs for visiting all cgroups (under a tree).  If
- * loops are exited prematurely (break), mem_cgroup_iter_break() must
- * be used for reference counting.
- */
-#define for_each_mem_cgroup_tree(iter, root)		\
-	for (iter = mem_cgroup_iter(root, NULL, NULL);	\
-	     iter != NULL;				\
-	     iter = mem_cgroup_iter(root, iter, NULL))
-
-#define for_each_mem_cgroup(iter)			\
-	for (iter = mem_cgroup_iter(NULL, NULL, NULL);	\
-	     iter != NULL;				\
-	     iter = mem_cgroup_iter(NULL, iter, NULL))
-
 void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 	struct mem_cgroup *memcg;
@@ -3140,13 +3125,11 @@ static void memcg_unregister_cache(struct kmem_cache *cachep)
  */
 static inline void memcg_stop_kmem_account(void)
 {
-	VM_BUG_ON(!current->mm);
 	current->memcg_kmem_skip_account++;
 }
 
 static inline void memcg_resume_kmem_account(void)
 {
-	VM_BUG_ON(!current->mm);
 	current->memcg_kmem_skip_account--;
 }
 
@@ -3436,6 +3419,193 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
 	memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
 }
+
+/*
+ * List of all memcg-aware list_lrus, linked through
+ * memcg_list_lru_params->list, protected by memcg_slab_mutex.
+ */
+static LIST_HEAD(memcg_list_lrus);
+
+static void memcg_free_list_lru_params(struct memcg_list_lru_params *params,
+				       int size)
+{
+	int i;
+
+	for (i = 0; i < size; i++)
+		kfree(params->node[i]);
+	kfree(params);
+}
+
+static struct memcg_list_lru_params *
+memcg_alloc_list_lru_params(struct list_lru *lru, int size)
+{
+	struct memcg_list_lru_params *params, *old_params;
+	int i, old_size = 0;
+
+	memcg_stop_kmem_account();
+	params = kzalloc(sizeof(*params) + size * sizeof(*params->node),
+			 GFP_KERNEL);
+	if (!params)
+		goto out;
+
+	old_params = lru->memcg_params;
+	if (old_params)
+		old_size = memcg_limited_groups_array_size;
+
+	for (i = old_size; i < size; i++) {
+		struct list_lru_node *n;
+
+		n = kmalloc(sizeof(*n), GFP_KERNEL);
+		if (!n) {
+			memcg_free_list_lru_params(params, size);
+			params = NULL;
+			goto out;
+		}
+		list_lru_node_init(n, lru);
+		params->node[i] = n;
+	}
+
+	if (old_params)
+		memcpy(params->node, old_params->node,
+		       old_size * sizeof(*params->node));
+out:
+	memcg_resume_kmem_account();
+	return params;
+}
+
+int memcg_register_list_lru(struct list_lru *lru)
+{
+	struct memcg_list_lru_params *params;
+
+	if (mem_cgroup_disabled())
+		return 0;
+
+	BUG_ON(lru->memcg_params);
+
+	mutex_lock(&memcg_slab_mutex);
+	params = memcg_alloc_list_lru_params(lru,
+			memcg_limited_groups_array_size);
+	if (!params) {
+		mutex_unlock(&memcg_slab_mutex);
+		return -ENOMEM;
+	}
+	params->owner = lru;
+	list_add(&params->list, &memcg_list_lrus);
+	lru->memcg_params = params;
+	mutex_unlock(&memcg_slab_mutex);
+
+	return 0;
+}
+
+void memcg_unregister_list_lru(struct list_lru *lru)
+{
+	struct memcg_list_lru_params *params = lru->memcg_params;
+
+	if (!params)
+		return;
+
+	BUG_ON(params->owner != lru);
+
+	mutex_lock(&memcg_slab_mutex);
+	list_del(&params->list);
+	memcg_free_list_lru_params(params, memcg_limited_groups_array_size);
+	mutex_unlock(&memcg_slab_mutex);
+
+	lru->memcg_params = NULL;
+}
+
+static int memcg_update_all_list_lrus(int num_groups)
+{
+	struct memcg_list_lru_params *params, *tmp, *new_params;
+	struct list_lru *lru;
+	int new_size;
+
+	lockdep_assert_held(&memcg_slab_mutex);
+
+	if (num_groups <= memcg_limited_groups_array_size)
+		return 0;
+
+	new_size = memcg_caches_array_size(num_groups);
+
+	list_for_each_entry_safe(params, tmp, &memcg_list_lrus, list) {
+		lru = params->owner;
+
+		new_params = memcg_alloc_list_lru_params(lru, new_size);
+		if (!new_params)
+			return -ENOMEM;
+
+		new_params->owner = lru;
+		list_replace(&params->list, &new_params->list);
+
+		rcu_assign_pointer(lru->memcg_params, new_params);
+		kfree_rcu(params, rcu_head);
+	}
+	return 0;
+}
+
+/**
+ * memcg_list_lru: get list_lru node corresponding to memory cgroup
+ * @lru: the list_lru
+ * @memcg: the memory cgroup
+ *
+ * Returns NULL if no node corresponds to @memcg in @lru.
+ */
+struct list_lru_node *memcg_list_lru(struct list_lru *lru,
+				     struct mem_cgroup *memcg)
+{
+	struct memcg_list_lru_params *params;
+	struct list_lru_node *n;
+
+	if (!lru->memcg_params)
+		return NULL;
+	if (!memcg_kmem_is_active(memcg))
+		return NULL;
+
+	rcu_read_lock();
+	params = rcu_dereference(lru->memcg_params);
+	n = params->node[memcg_cache_id(memcg)];
+	rcu_read_unlock();
+
+	return n;
+}
+
+/**
+ * memcg_list_lru_from_obj: get list_lru node corresponding to memory cgroup
+ * which object is accounted to
+ * @lru: the list_lru
+ * @obj: the object ptr
+ *
+ * Return NULL if no node corresponds to the memory cgroup which @obj is
+ * accounted to or if @obj is not accounted to any memory cgroup.
+ *
+ * The object must be allocated from kmem.
+ */
+struct list_lru_node *memcg_list_lru_from_obj(struct list_lru *lru, void *obj)
+{
+	struct mem_cgroup *memcg = NULL;
+	struct kmem_cache *cachep;
+	struct page_cgroup *pc;
+	struct page *page;
+
+	if (!lru->memcg_params)
+		return NULL;
+
+	page = virt_to_head_page(obj);
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
+	if (!memcg)
+		return NULL;
+
+	return memcg_list_lru(lru, memcg);
+}
 #else
 static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 {
@@ -4215,7 +4385,9 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 	 * memcg_params.
 	 */
 	mutex_lock(&memcg_slab_mutex);
-	err = memcg_update_all_caches(memcg_id + 1);
+	err = memcg_update_all_list_lrus(memcg_id + 1);
+	if (!err)
+		err = memcg_update_all_caches(memcg_id + 1);
 	mutex_unlock(&memcg_slab_mutex);
 	if (err)
 		goto out_rmid;
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
