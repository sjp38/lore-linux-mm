Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4946B006E
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 06:23:50 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so38357854pab.0
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 03:23:50 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id xu7si133671pab.18.2015.01.19.03.23.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jan 2015 03:23:48 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 2/7] slab: link memcg caches of the same kind into a list
Date: Mon, 19 Jan 2015 14:23:20 +0300
Message-ID: <fe925697d47fce2e3d148449ed0384e08a3ad078.1421664712.git.vdavydov@parallels.com>
In-Reply-To: <cover.1421664712.git.vdavydov@parallels.com>
References: <cover.1421664712.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Sometimes, we need to iterate over all memcg copies of a particular root
kmem cache. Currently, we use memcg_cache_params->memcg_caches array for
that, because it contains all existing memcg caches.

However, it's a bad practice to keep all caches, including those that
belong to offline cgroups, in this array, because it will be growing
beyond any bounds then. I'm going to wipe away dead caches from it to
save space. To still be able to perform iterations over all memcg caches
of the same kind, let us link them into a list.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |    4 ++++
 mm/slab.c            |   13 +++++--------
 mm/slab.h            |   17 +++++++++++++++++
 mm/slab_common.c     |   21 ++++++++++-----------
 mm/slub.c            |   19 +++++--------------
 5 files changed, 41 insertions(+), 33 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1e03c11bbfbd..26d99f41b410 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -491,9 +491,13 @@ struct memcg_cache_array {
  *
  * @memcg: pointer to the memcg this cache belongs to
  * @root_cache: pointer to the global, root cache, this cache was derived from
+ *
+ * Both root and child caches of the same kind are linked into a list chained
+ * through @list.
  */
 struct memcg_cache_params {
 	bool is_root_cache;
+	struct list_head list;
 	union {
 		struct memcg_cache_array __rcu *memcg_caches;
 		struct {
diff --git a/mm/slab.c b/mm/slab.c
index 65b5dcb6f671..7894017bc160 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3708,8 +3708,7 @@ static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
 				int batchcount, int shared, gfp_t gfp)
 {
 	int ret;
-	struct kmem_cache *c = NULL;
-	int i = 0;
+	struct kmem_cache *c;
 
 	ret = __do_tune_cpucache(cachep, limit, batchcount, shared, gfp);
 
@@ -3719,12 +3718,10 @@ static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
 	if ((ret < 0) || !is_root_cache(cachep))
 		return ret;
 
-	VM_BUG_ON(!mutex_is_locked(&slab_mutex));
-	for_each_memcg_cache_index(i) {
-		c = cache_from_memcg_idx(cachep, i);
-		if (c)
-			/* return value determined by the parent cache only */
-			__do_tune_cpucache(c, limit, batchcount, shared, gfp);
+	lockdep_assert_held(&slab_mutex);
+	for_each_memcg_cache(c, cachep) {
+		/* return value determined by the root cache only */
+		__do_tune_cpucache(c, limit, batchcount, shared, gfp);
 	}
 
 	return ret;
diff --git a/mm/slab.h b/mm/slab.h
index 53a623f85931..2fc16c2ed198 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -163,6 +163,18 @@ ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 		       size_t count, loff_t *ppos);
 
 #ifdef CONFIG_MEMCG_KMEM
+/*
+ * Iterate over all memcg caches of the given root cache. The caller must hold
+ * slab_mutex.
+ */
+#define for_each_memcg_cache(iter, root) \
+	list_for_each_entry(iter, &(root)->memcg_params.list, \
+			    memcg_params.list)
+
+#define for_each_memcg_cache_safe(iter, tmp, root) \
+	list_for_each_entry_safe(iter, tmp, &(root)->memcg_params.list, \
+				 memcg_params.list)
+
 static inline bool is_root_cache(struct kmem_cache *s)
 {
 	return s->memcg_params.is_root_cache;
@@ -241,6 +253,11 @@ extern void slab_init_memcg_params(struct kmem_cache *);
 
 #else /* !CONFIG_MEMCG_KMEM */
 
+#define for_each_memcg_cache(iter, root) \
+	for (iter = NULL, (root); 0; )
+#define for_each_memcg_cache_safe(iter, tmp, root) \
+	for (iter = NULL, tmp = NULL, (root); 0; )
+
 static inline bool is_root_cache(struct kmem_cache *s)
 {
 	return true;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 0c44a91a5354..6a5a1dde84c1 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -109,6 +109,7 @@ static inline int kmem_cache_sanity_check(const char *name, size_t size)
 void slab_init_memcg_params(struct kmem_cache *s)
 {
 	s->memcg_params.is_root_cache = true;
+	INIT_LIST_HEAD(&s->memcg_params.list);
 	RCU_INIT_POINTER(s->memcg_params.memcg_caches, NULL);
 }
 
@@ -448,6 +449,7 @@ static int do_kmem_cache_shutdown(struct kmem_cache *s,
 						lockdep_is_held(&slab_mutex));
 		BUG_ON(arr->entries[idx] != s);
 		arr->entries[idx] = NULL;
+		list_del(&s->memcg_params.list);
 	}
 #endif
 	list_move(&s->list, release);
@@ -528,6 +530,8 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 		goto out_unlock;
 	}
 
+	list_add(&s->memcg_params.list, &root_cache->memcg_params.list);
+
 	/*
 	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
 	 * barrier here to ensure nobody will see the kmem_cache partially
@@ -580,11 +584,13 @@ void slab_kmem_cache_release(struct kmem_cache *s)
 
 void kmem_cache_destroy(struct kmem_cache *s)
 {
-	int i;
+	struct kmem_cache *c, *c2;
 	LIST_HEAD(release);
 	bool need_rcu_barrier = false;
 	bool busy = false;
 
+	BUG_ON(!is_root_cache(s));
+
 	get_online_cpus();
 	get_online_mems();
 
@@ -594,10 +600,8 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (s->refcount)
 		goto out_unlock;
 
-	for_each_memcg_cache_index(i) {
-		struct kmem_cache *c = cache_from_memcg_idx(s, i);
-
-		if (c && do_kmem_cache_shutdown(c, &release, &need_rcu_barrier))
+	for_each_memcg_cache_safe(c, c2, s) {
+		if (do_kmem_cache_shutdown(c, &release, &need_rcu_barrier))
 			busy = true;
 	}
 
@@ -931,16 +935,11 @@ memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
 {
 	struct kmem_cache *c;
 	struct slabinfo sinfo;
-	int i;
 
 	if (!is_root_cache(s))
 		return;
 
-	for_each_memcg_cache_index(i) {
-		c = cache_from_memcg_idx(s, i);
-		if (!c)
-			continue;
-
+	for_each_memcg_cache(c, s) {
 		memset(&sinfo, 0, sizeof(sinfo));
 		get_slabinfo(c, &sinfo);
 
diff --git a/mm/slub.c b/mm/slub.c
index 93e3469c0b2b..5ed1a73e2ec8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3636,13 +3636,10 @@ struct kmem_cache *
 __kmem_cache_alias(const char *name, size_t size, size_t align,
 		   unsigned long flags, void (*ctor)(void *))
 {
-	struct kmem_cache *s;
+	struct kmem_cache *s, *c;
 
 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
-		int i;
-		struct kmem_cache *c;
-
 		s->refcount++;
 
 		/*
@@ -3652,10 +3649,7 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 		s->object_size = max(s->object_size, (int)size);
 		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
 
-		for_each_memcg_cache_index(i) {
-			c = cache_from_memcg_idx(s, i);
-			if (!c)
-				continue;
+		for_each_memcg_cache(c, s) {
 			c->object_size = s->object_size;
 			c->inuse = max_t(int, c->inuse,
 					 ALIGN(size, sizeof(void *)));
@@ -4921,7 +4915,7 @@ static ssize_t slab_attr_store(struct kobject *kobj,
 	err = attribute->store(s, buf, len);
 #ifdef CONFIG_MEMCG_KMEM
 	if (slab_state >= FULL && err >= 0 && is_root_cache(s)) {
-		int i;
+		struct kmem_cache *c;
 
 		mutex_lock(&slab_mutex);
 		if (s->max_attr_size < len)
@@ -4944,11 +4938,8 @@ static ssize_t slab_attr_store(struct kobject *kobj,
 		 * directly either failed or succeeded, in which case we loop
 		 * through the descendants with best-effort propagation.
 		 */
-		for_each_memcg_cache_index(i) {
-			struct kmem_cache *c = cache_from_memcg_idx(s, i);
-			if (c)
-				attribute->store(c, buf, len);
-		}
+		for_each_memcg_cache(c, s)
+			attribute->store(c, buf, len);
 		mutex_unlock(&slab_mutex);
 	}
 #endif
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
