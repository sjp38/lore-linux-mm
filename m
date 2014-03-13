Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id CEDB96B003C
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 11:06:59 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id w7so783443lbi.2
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 08:06:59 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id rd2si1641452lac.135.2014.03.13.08.06.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Mar 2014 08:06:58 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND -mm 05/12] memcg: add pointer from memcg_cache_params to cache
Date: Thu, 13 Mar 2014 19:06:43 +0400
Message-ID: <99561ce2ebc2284279d9c12e11de1993777f063f.1394708827.git.vdavydov@parallels.com>
In-Reply-To: <cover.1394708827.git.vdavydov@parallels.com>
References: <cover.1394708827.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

While iterating over the memcg_slab_caches list we need to obtain the
cache a particular memcg_params is corresponding to, because
memcg_params are actually linked, not caches. Currently to achieve that,
we employ the fact that each root cache tracks all its child caches in
its memcg_caches array, so that given a memcg_params we can find the
memcg cache by doing something like this:

  root = memcg_params->root_cache;
  memcg = memcg_params->memcg;
  memcg_cache = root->memcg_params->memcg_caches[memcg->kmemcg_id];

Apart from being cumbersome, this is not going to work when reparenting
of memcg caches is introduced. So let's embed a pointer back to the
memcg cache into the memcg_cache_params struct.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
---
 include/linux/slab.h |    2 ++
 mm/memcontrol.c      |   28 +++-------------------------
 2 files changed, 5 insertions(+), 25 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index ee9f1b0382ac..f2fd4212976e 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -520,6 +520,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  *
  * Child caches will hold extra metadata needed for its operation. Fields are:
  *
+ * @cachep: back pointer to the memcg cache
  * @memcg: pointer to the memcg this cache belongs to
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
@@ -536,6 +537,7 @@ struct memcg_cache_params {
 			struct kmem_cache *memcg_caches[0];
 		};
 		struct {
+			struct kmem_cache *cachep;
 			struct mem_cgroup *memcg;
 			struct list_head list;
 			struct kmem_cache *root_cache;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3659d90d5a40..626a37e01126 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2912,19 +2912,6 @@ static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 		memcg_kmem_is_active(memcg);
 }
 
-/*
- * This is a bit cumbersome, but it is rarely used and avoids a backpointer
- * in the memcg_cache_params struct.
- */
-static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
-{
-	struct kmem_cache *cachep;
-
-	VM_BUG_ON(p->is_root_cache);
-	cachep = p->root_cache;
-	return cache_from_memcg_idx(cachep, memcg_cache_id(p->memcg));
-}
-
 #ifdef CONFIG_SLABINFO
 static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 {
@@ -2938,7 +2925,7 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 
 	mutex_lock(&memcg->slab_caches_mutex);
 	list_for_each_entry(params, &memcg->memcg_slab_caches, list)
-		cache_show(memcg_params_to_cache(params), m);
+		cache_show(params->cachep, m);
 	mutex_unlock(&memcg->slab_caches_mutex);
 
 	return 0;
@@ -3137,6 +3124,7 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 		return -ENOMEM;
 
 	if (memcg) {
+		s->memcg_params->cachep = s;
 		s->memcg_params->memcg = memcg;
 		s->memcg_params->root_cache = root_cache;
 		INIT_WORK(&s->memcg_params->destroy,
@@ -3184,11 +3172,6 @@ void memcg_register_cache(struct kmem_cache *s)
 	 */
 	smp_wmb();
 
-	/*
-	 * Initialize the pointer to this cache in its parent's memcg_params
-	 * before adding it to the memcg_slab_caches list, otherwise we can
-	 * fail to convert memcg_params_to_cache() while traversing the list.
-	 */
 	VM_BUG_ON(root->memcg_params->memcg_caches[id]);
 	root->memcg_params->memcg_caches[id] = s;
 
@@ -3220,11 +3203,6 @@ void memcg_unregister_cache(struct kmem_cache *s)
 	list_del(&s->memcg_params->list);
 	mutex_unlock(&memcg->slab_caches_mutex);
 
-	/*
-	 * Clear the pointer to this cache in its parent's memcg_params only
-	 * after removing it from the memcg_slab_caches list, otherwise we can
-	 * fail to convert memcg_params_to_cache() while traversing the list.
-	 */
 	VM_BUG_ON(root->memcg_params->memcg_caches[id] != s);
 	root->memcg_params->memcg_caches[id] = NULL;
 }
@@ -3266,7 +3244,7 @@ static void kmem_cache_destroy_work_func(struct work_struct *w)
 	struct memcg_cache_params *params;
 
 	params = container_of(w, struct memcg_cache_params, destroy);
-	cachep = memcg_params_to_cache(params);
+	cachep = params->cachep;
 
 	if (atomic_read(&params->refcount) != 0) {
 		/*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
