Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2816B0035
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 09:22:52 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so1495261lbi.37
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 06:22:51 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id xv7si21313767lbb.49.2014.06.06.06.22.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jun 2014 06:22:50 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 2/8] memcg: destroy kmem caches when last slab is freed
Date: Fri, 6 Jun 2014 17:22:39 +0400
Message-ID: <6884cccbbf6382c91a9ce2d26f922b2102af441f.1402060096.git.vdavydov@parallels.com>
In-Reply-To: <cover.1402060096.git.vdavydov@parallels.com>
References: <cover.1402060096.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When the memcg_cache_params->refcnt goes to 0, schedule the worker that
will unregister the cache. To prevent this from happening when the owner
memcg is alive, keep the refcnt incremented during memcg lifetime.

Note, this doesn't guarantee that the cache that belongs to a dead memcg
will go away as soon as the last object is freed, because SL[AU]B
implementation can cache empty slabs for performance reasons. Hence the
cache may be hanging around indefinitely after memcg offline. This is to
be resolved by the next patches.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 include/linux/slab.h |    2 ++
 mm/memcontrol.c      |   22 ++++++++++++++++++++--
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1985bd9bec7d..d9716fdc8211 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -527,6 +527,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
  * @refcnt: reference counter
+ * @unregister_work: worker to destroy the cache
  */
 struct memcg_cache_params {
 	bool is_root_cache;
@@ -540,6 +541,7 @@ struct memcg_cache_params {
 			struct list_head list;
 			struct kmem_cache *root_cache;
 			atomic_long_t refcnt;
+			struct work_struct unregister_work;
 		};
 	};
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 98a24e5ea4b5..886b5b414958 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3114,6 +3114,8 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 	return 0;
 }
 
+static void memcg_unregister_cache_func(struct work_struct *work);
+
 int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 			     struct kmem_cache *root_cache)
 {
@@ -3135,6 +3137,9 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 	if (memcg) {
 		s->memcg_params->memcg = memcg;
 		s->memcg_params->root_cache = root_cache;
+		atomic_long_set(&s->memcg_params->refcnt, 1);
+		INIT_WORK(&s->memcg_params->unregister_work,
+			  memcg_unregister_cache_func);
 		css_get(&memcg->css);
 	} else
 		s->memcg_params->is_root_cache = true;
@@ -3216,6 +3221,17 @@ static void memcg_unregister_cache(struct kmem_cache *cachep)
 	kmem_cache_destroy(cachep);
 }
 
+static void memcg_unregister_cache_func(struct work_struct *work)
+{
+	struct memcg_cache_params *params =
+		container_of(work, struct memcg_cache_params, unregister_work);
+	struct kmem_cache *cachep = memcg_params_to_cache(params);
+
+	mutex_lock(&memcg_slab_mutex);
+	memcg_unregister_cache(cachep);
+	mutex_unlock(&memcg_slab_mutex);
+}
+
 /*
  * During the creation a new cache, we need to disable our accounting mechanism
  * altogether. This is true even if we are not creating, but rather just
@@ -3279,7 +3295,7 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
 		cachep = memcg_params_to_cache(params);
 		kmem_cache_shrink(cachep);
-		if (atomic_long_read(&cachep->memcg_params->refcnt) == 0)
+		if (atomic_long_dec_and_test(&cachep->memcg_params->refcnt))
 			memcg_unregister_cache(cachep);
 	}
 	mutex_unlock(&memcg_slab_mutex);
@@ -3360,7 +3376,9 @@ int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
 {
 	memcg_uncharge_kmem(cachep->memcg_params->memcg, PAGE_SIZE << order);
-	atomic_long_dec(&cachep->memcg_params->refcnt);
+
+	if (unlikely(atomic_long_dec_and_test(&cachep->memcg_params->refcnt)))
+		schedule_work(&cachep->memcg_params->unregister_work);
 }
 
 /*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
