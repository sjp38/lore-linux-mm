Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2DED96B009D
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 16:38:44 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id u10so1059313lbd.10
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 13:38:43 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id dr3si55742733lbc.33.2014.06.12.13.38.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jun 2014 13:38:42 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 3/8] memcg: mark caches that belong to offline memcgs as dead
Date: Fri, 13 Jun 2014 00:38:17 +0400
Message-ID: <8f3b741b0d62204c34c6935fe6b00f73c3e1fc49.1402602126.git.vdavydov@parallels.com>
In-Reply-To: <cover.1402602126.git.vdavydov@parallels.com>
References: <cover.1402602126.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This will be used by the next patches.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |    2 ++
 mm/memcontrol.c      |    3 +++
 mm/slab.h            |   25 +++++++++++++++++++++++++
 3 files changed, 30 insertions(+)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index d9716fdc8211..d99d5212b815 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -527,6 +527,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
  * @refcnt: reference counter
+ * @dead: set to true when owner memcg is turned offline
  * @unregister_work: worker to destroy the cache
  */
 struct memcg_cache_params {
@@ -541,6 +542,7 @@ struct memcg_cache_params {
 			struct list_head list;
 			struct kmem_cache *root_cache;
 			atomic_long_t refcnt;
+			bool dead;
 			struct work_struct unregister_work;
 		};
 	};
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 886b5b414958..8f08044d26a7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3294,7 +3294,10 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 	mutex_lock(&memcg_slab_mutex);
 	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
 		cachep = memcg_params_to_cache(params);
+
+		memcg_cache_mark_dead(cachep);
 		kmem_cache_shrink(cachep);
+
 		if (atomic_long_dec_and_test(&cachep->memcg_params->refcnt))
 			memcg_unregister_cache(cachep);
 	}
diff --git a/mm/slab.h b/mm/slab.h
index 961a3fb1f5a2..2af5a0bc00a4 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -121,6 +121,26 @@ static inline bool is_root_cache(struct kmem_cache *s)
 	return !s->memcg_params || s->memcg_params->is_root_cache;
 }
 
+static inline bool memcg_cache_dead(struct kmem_cache *s)
+{
+	if (is_root_cache(s))
+		return false;
+
+	/*
+	 * Since this function can be called without holding any locks, it
+	 * needs a barrier here to guarantee the read won't be reordered.
+	 */
+	smp_rmb();
+	return s->memcg_params->dead;
+}
+
+static inline void memcg_cache_mark_dead(struct kmem_cache *s)
+{
+	BUG_ON(is_root_cache(s));
+	s->memcg_params->dead = true;
+	smp_wmb();		/* matches rmb in memcg_cache_dead() */
+}
+
 static inline bool slab_equal_or_root(struct kmem_cache *s,
 					struct kmem_cache *p)
 {
@@ -203,6 +223,11 @@ static inline bool is_root_cache(struct kmem_cache *s)
 	return true;
 }
 
+static inline bool memcg_cache_dead(struct kmem_cache *s)
+{
+	return false;
+}
+
 static inline bool slab_equal_or_root(struct kmem_cache *s,
 				      struct kmem_cache *p)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
