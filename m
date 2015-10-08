Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id C41186B0255
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 12:03:00 -0400 (EDT)
Received: by lbbwt4 with SMTP id wt4so52437510lbb.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 09:03:00 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id t197si30291042lfe.92.2015.10.08.09.02.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 09:02:59 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 2/3] slab_common: clear pointers to per memcg caches on destroy
Date: Thu, 8 Oct 2015 19:02:40 +0300
Message-ID: <833ae913932949814d1063e11248e6747d0c3a2b.1444319304.git.vdavydov@virtuozzo.com>
In-Reply-To: <6a18aab2f1c3088377d7fd2207b4cc1a1a743468.1444319304.git.vdavydov@virtuozzo.com>
References: <6a18aab2f1c3088377d7fd2207b4cc1a1a743468.1444319304.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, we do not clear pointers to per memcg caches in the
memcg_params.memcg_caches array when a global cache is destroyed with
kmem_cache_destroy. It is fine if the global cache does get destroyed.
However, a cache can be left on the list if it still has active objects
when kmem_cache_destroy is called (due to a memory leak). If this
happens, the entries in the array will point to already freed areas,
which is likely to result in data corruption when the cache is reused
(via slab merging).

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/slab.h        |  6 ----
 mm/slab_common.c | 93 +++++++++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 78 insertions(+), 21 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 16cc5b0de1d8..3d667a4471ff 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -181,10 +181,6 @@ bool __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
 	list_for_each_entry(iter, &(root)->memcg_params.list, \
 			    memcg_params.list)
 
-#define for_each_memcg_cache_safe(iter, tmp, root) \
-	list_for_each_entry_safe(iter, tmp, &(root)->memcg_params.list, \
-				 memcg_params.list)
-
 static inline bool is_root_cache(struct kmem_cache *s)
 {
 	return s->memcg_params.is_root_cache;
@@ -258,8 +254,6 @@ extern void slab_init_memcg_params(struct kmem_cache *);
 
 #define for_each_memcg_cache(iter, root) \
 	for ((void)(iter), (void)(root); 0; )
-#define for_each_memcg_cache_safe(iter, tmp, root) \
-	for ((void)(iter), (void)(tmp), (void)(root); 0; )
 
 static inline bool is_root_cache(struct kmem_cache *s)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index c8d2ed7f8330..ab1f20e303e4 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -461,10 +461,6 @@ static int shutdown_cache(struct kmem_cache *s,
 	if (s->flags & SLAB_DESTROY_BY_RCU)
 		*need_rcu_barrier = true;
 
-#ifdef CONFIG_MEMCG_KMEM
-	if (!is_root_cache(s))
-		list_del(&s->memcg_params.list);
-#endif
 	list_move(&s->list, release);
 	return 0;
 }
@@ -597,6 +593,18 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 	put_online_cpus();
 }
 
+static int __shutdown_memcg_cache(struct kmem_cache *s,
+		struct list_head *release, bool *need_rcu_barrier)
+{
+	BUG_ON(is_root_cache(s));
+
+	if (shutdown_cache(s, release, need_rcu_barrier))
+		return -EBUSY;
+
+	list_del(&s->memcg_params.list);
+	return 0;
+}
+
 void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
 {
 	LIST_HEAD(release);
@@ -614,7 +622,7 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
 		 * The cgroup is about to be freed and therefore has no charges
 		 * left. Hence, all its caches must be empty by now.
 		 */
-		BUG_ON(shutdown_cache(s, &release, &need_rcu_barrier));
+		BUG_ON(__shutdown_memcg_cache(s, &release, &need_rcu_barrier));
 	}
 	mutex_unlock(&slab_mutex);
 
@@ -623,6 +631,68 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
 
 	release_caches(&release, need_rcu_barrier);
 }
+
+static int shutdown_memcg_caches(struct kmem_cache *s,
+		struct list_head *release, bool *need_rcu_barrier)
+{
+	struct memcg_cache_array *arr;
+	struct kmem_cache *c, *c2;
+	LIST_HEAD(busy);
+	int i;
+
+	BUG_ON(!is_root_cache(s));
+
+	/*
+	 * First, shutdown active caches, i.e. caches that belong to online
+	 * memory cgroups.
+	 */
+	arr = rcu_dereference_protected(s->memcg_params.memcg_caches,
+					lockdep_is_held(&slab_mutex));
+	for_each_memcg_cache_index(i) {
+		c = arr->entries[i];
+		if (!c)
+			continue;
+		if (__shutdown_memcg_cache(c, release, need_rcu_barrier))
+			/*
+			 * The cache still has objects. Move it to a temporary
+			 * list so as not to try to destroy it for a second
+			 * time while iterating over inactive caches below.
+			 */
+			list_move(&c->memcg_params.list, &busy);
+		else
+			/*
+			 * The cache is empty and will be destroyed soon. Clear
+			 * the pointer to it in the memcg_caches array so that
+			 * it will never be accessed even if the root cache
+			 * stays alive.
+			 */
+			arr->entries[i] = NULL;
+	}
+
+	/*
+	 * Second, shutdown all caches left from memory cgroups that are now
+	 * offline.
+	 */
+	list_for_each_entry_safe(c, c2, &s->memcg_params.list,
+				 memcg_params.list)
+		__shutdown_memcg_cache(c, release, need_rcu_barrier);
+
+	list_splice(&busy, &s->memcg_params.list);
+
+	/*
+	 * A cache being destroyed must be empty. In particular, this means
+	 * that all per memcg caches attached to it must be empty too.
+	 */
+	if (!list_empty(&s->memcg_params.list))
+		return -EBUSY;
+	return 0;
+}
+#else
+static inline int shutdown_memcg_caches(struct kmem_cache *s,
+		struct list_head *release, bool *need_rcu_barrier)
+{
+	return 0;
+}
 #endif /* CONFIG_MEMCG_KMEM */
 
 void slab_kmem_cache_release(struct kmem_cache *s)
@@ -634,16 +704,13 @@ void slab_kmem_cache_release(struct kmem_cache *s)
 
 void kmem_cache_destroy(struct kmem_cache *s)
 {
-	struct kmem_cache *c, *c2;
 	LIST_HEAD(release);
 	bool need_rcu_barrier = false;
-	bool busy = false;
+	int err;
 
 	if (unlikely(!s))
 		return;
 
-	BUG_ON(!is_root_cache(s));
-
 	get_online_cpus();
 	get_online_mems();
 
@@ -653,12 +720,8 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (s->refcount)
 		goto out_unlock;
 
-	for_each_memcg_cache_safe(c, c2, s) {
-		if (shutdown_cache(c, &release, &need_rcu_barrier))
-			busy = true;
-	}
-
-	if (!busy)
+	err = shutdown_memcg_caches(s, &release, &need_rcu_barrier);
+	if (!err)
 		shutdown_cache(s, &release, &need_rcu_barrier);
 
 out_unlock:
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
