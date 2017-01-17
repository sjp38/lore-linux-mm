Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC2576B0266
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 18:54:24 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so22089012pgc.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 15:54:24 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id r11si26385947pgn.300.2017.01.17.15.54.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 15:54:23 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id 194so9133335pgd.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 15:54:23 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 06/10] slab: implement slab_root_caches list
Date: Tue, 17 Jan 2017 15:54:07 -0800
Message-Id: <20170117235411.9408-7-tj@kernel.org>
In-Reply-To: <20170117235411.9408-1-tj@kernel.org>
References: <20170117235411.9408-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com, Tejun Heo <tj@kernel.org>

With kmem cgroup support enabled, kmem_caches can be created and
destroyed frequently and a great number of near empty kmem_caches can
accumulate if there are a lot of transient cgroups and the system is
not under memory pressure.  When memory reclaim starts under such
conditions, it can lead to consecutive deactivation and destruction of
many kmem_caches, easily hundreds of thousands on moderately large
systems, exposing scalability issues in the current slab management
code.  This is one of the patches to address the issue.

slab_caches currently lists all caches including root and memcg ones.
This is the only data structure which lists the root caches and
iterating root caches can only be done by walking the list while
skipping over memcg caches.  As there can be a huge number of memcg
caches, this can become very expensive.

This also can make /proc/slabinfo behave very badly.  seq_file
processes reads in 4k chunks and seeks to the previous Nth position on
slab_caches list to resume after each chunk.  With a lot of memcg
cache churns on the list, reading /proc/slabinfo can become very slow
and its content often ends up with duplicate and/or missing entries.

This patch adds a new list slab_root_caches which lists only the root
caches.  When memcg is not enabled, it becomes just an alias of
slab_caches.  memcg specific list operations are collected into
memcg_[un]link_cache().

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Jay Vana <jsvana@fb.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/slab.h |  3 +++
 mm/slab.h            | 15 +++++++++++++
 mm/slab_common.c     | 59 ++++++++++++++++++++++++++++++----------------------
 mm/slub.c            |  1 +
 4 files changed, 53 insertions(+), 25 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 95b4d9d..41c49cc 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -556,6 +556,8 @@ struct memcg_cache_array {
  *		used to index child cachces during allocation and cleared
  *		early during shutdown.
  *
+ * @root_caches_node: List node for slab_root_caches list.
+ *
  * @children:	List of all child caches.  While the child caches are also
  *		reachable through @memcg_caches, a child cache remains on
  *		this list until it is actually destroyed.
@@ -573,6 +575,7 @@ struct memcg_cache_params {
 	union {
 		struct {
 			struct memcg_cache_array __rcu *memcg_caches;
+			struct list_head __root_caches_node;
 			struct list_head children;
 		};
 		struct {
diff --git a/mm/slab.h b/mm/slab.h
index 4cb67a3..a0450ba 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -195,6 +195,11 @@ void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
 int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
 
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+
+/* List of all root caches. */
+extern struct list_head		slab_root_caches;
+#define root_caches_node	memcg_params.__root_caches_node
+
 /*
  * Iterate over all memcg caches of the given root cache. The caller must hold
  * slab_mutex.
@@ -294,9 +299,14 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 }
 
 extern void slab_init_memcg_params(struct kmem_cache *);
+extern void memcg_link_cache(struct kmem_cache *s);
 
 #else /* CONFIG_MEMCG && !CONFIG_SLOB */
 
+/* If !memcg, all caches are root. */
+#define slab_root_caches	slab_caches
+#define root_caches_node	list
+
 #define for_each_memcg_cache(iter, root) \
 	for ((void)(iter), (void)(root); 0; )
 
@@ -341,6 +351,11 @@ static inline void memcg_uncharge_slab(struct page *page, int order,
 static inline void slab_init_memcg_params(struct kmem_cache *s)
 {
 }
+
+static inline void memcg_link_cache(struct kmem_cache *s)
+{
+}
+
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 85292cc..638cbc1 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -138,6 +138,9 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
 }
 
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+
+LIST_HEAD(slab_root_caches);
+
 void slab_init_memcg_params(struct kmem_cache *s)
 {
 	s->memcg_params.root_cache = NULL;
@@ -183,9 +186,6 @@ static int update_memcg_params(struct kmem_cache *s, int new_array_size)
 {
 	struct memcg_cache_array *old, *new;
 
-	if (!is_root_cache(s))
-		return 0;
-
 	new = kzalloc(sizeof(struct memcg_cache_array) +
 		      new_array_size * sizeof(void *), GFP_KERNEL);
 	if (!new)
@@ -209,7 +209,7 @@ int memcg_update_all_caches(int num_memcgs)
 	int ret = 0;
 
 	mutex_lock(&slab_mutex);
-	list_for_each_entry(s, &slab_caches, list) {
+	list_for_each_entry(s, &slab_root_caches, root_caches_node) {
 		ret = update_memcg_params(s, num_memcgs);
 		/*
 		 * Instead of freeing the memory, we'll just leave the caches
@@ -222,10 +222,26 @@ int memcg_update_all_caches(int num_memcgs)
 	return ret;
 }
 
-static void unlink_memcg_cache(struct kmem_cache *s)
+void memcg_link_cache(struct kmem_cache *s)
+{
+	if (is_root_cache(s)) {
+		list_add(&s->root_caches_node, &slab_root_caches);
+	} else {
+		list_add(&s->memcg_params.children_node,
+			 &s->memcg_params.root_cache->memcg_params.children);
+		list_add(&s->memcg_params.kmem_caches_node,
+			 &s->memcg_params.memcg->kmem_caches);
+	}
+}
+
+static void memcg_unlink_cache(struct kmem_cache *s)
 {
-	list_del(&s->memcg_params.children_node);
-	list_del(&s->memcg_params.kmem_caches_node);
+	if (is_root_cache(s)) {
+		list_del(&s->root_caches_node);
+	} else {
+		list_del(&s->memcg_params.children_node);
+		list_del(&s->memcg_params.kmem_caches_node);
+	}
 }
 #else
 static inline int init_memcg_params(struct kmem_cache *s,
@@ -238,7 +254,7 @@ static inline void destroy_memcg_params(struct kmem_cache *s)
 {
 }
 
-static inline void unlink_memcg_cache(struct kmem_cache *s)
+static inline void memcg_unlink_cache(struct kmem_cache *s)
 {
 }
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
@@ -282,7 +298,7 @@ struct kmem_cache *find_mergeable(size_t size, size_t align,
 	size = ALIGN(size, align);
 	flags = kmem_cache_flags(size, flags, name, NULL);
 
-	list_for_each_entry_reverse(s, &slab_caches, list) {
+	list_for_each_entry_reverse(s, &slab_root_caches, root_caches_node) {
 		if (slab_unmergeable(s))
 			continue;
 
@@ -366,6 +382,7 @@ static struct kmem_cache *create_cache(const char *name,
 
 	s->refcount = 1;
 	list_add(&s->list, &slab_caches);
+	memcg_link_cache(s);
 out:
 	if (err)
 		return ERR_PTR(err);
@@ -511,9 +528,8 @@ static int shutdown_cache(struct kmem_cache *s)
 	if (__kmem_cache_shutdown(s) != 0)
 		return -EBUSY;
 
+	memcg_unlink_cache(s);
 	list_del(&s->list);
-	if (!is_root_cache(s))
-		unlink_memcg_cache(s);
 
 	if (s->flags & SLAB_DESTROY_BY_RCU) {
 		list_add_tail(&s->list, &slab_caches_to_rcu_destroy);
@@ -593,10 +609,6 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 		goto out_unlock;
 	}
 
-	list_add(&s->memcg_params.children_node,
-		 &root_cache->memcg_params.children);
-	list_add(&s->memcg_params.kmem_caches_node, &memcg->kmem_caches);
-
 	/*
 	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
 	 * barrier here to ensure nobody will see the kmem_cache partially
@@ -624,10 +636,7 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 	get_online_mems();
 
 	mutex_lock(&slab_mutex);
-	list_for_each_entry(s, &slab_caches, list) {
-		if (!is_root_cache(s))
-			continue;
-
+	list_for_each_entry(s, &slab_root_caches, root_caches_node) {
 		arr = rcu_dereference_protected(s->memcg_params.memcg_caches,
 						lockdep_is_held(&slab_mutex));
 		c = arr->entries[idx];
@@ -826,6 +835,7 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
 
 	create_boot_cache(s, name, size, flags);
 	list_add(&s->list, &slab_caches);
+	memcg_link_cache(s);
 	s->refcount = 1;
 	return s;
 }
@@ -1136,12 +1146,12 @@ static void print_slabinfo_header(struct seq_file *m)
 void *slab_start(struct seq_file *m, loff_t *pos)
 {
 	mutex_lock(&slab_mutex);
-	return seq_list_start(&slab_caches, *pos);
+	return seq_list_start(&slab_root_caches, *pos);
 }
 
 void *slab_next(struct seq_file *m, void *p, loff_t *pos)
 {
-	return seq_list_next(p, &slab_caches, pos);
+	return seq_list_next(p, &slab_root_caches, pos);
 }
 
 void slab_stop(struct seq_file *m, void *p)
@@ -1193,12 +1203,11 @@ static void cache_show(struct kmem_cache *s, struct seq_file *m)
 
 static int slab_show(struct seq_file *m, void *p)
 {
-	struct kmem_cache *s = list_entry(p, struct kmem_cache, list);
+	struct kmem_cache *s = list_entry(p, struct kmem_cache, root_caches_node);
 
-	if (p == slab_caches.next)
+	if (p == slab_root_caches.next)
 		print_slabinfo_header(m);
-	if (is_root_cache(s))
-		cache_show(s, m);
+	cache_show(s, m);
 	return 0;
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index 2b78c82..8f37896 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4119,6 +4119,7 @@ static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 	}
 	slab_init_memcg_params(s);
 	list_add(&s->list, &slab_caches);
+	memcg_link_cache(s);
 	return s;
 }
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
