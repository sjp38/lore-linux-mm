Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9CED56B0068
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 05:04:17 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id b8so4225391lan.31
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 02:04:16 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id w6si2788773laj.97.2014.04.27.02.04.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Apr 2014 02:04:16 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 2/6] memcg: allocate memcg_caches array on first per memcg cache creation
Date: Sun, 27 Apr 2014 13:04:04 +0400
Message-ID: <a7d8045bbaa5232a0f14b584f61a43ac4c76c395.1398587474.git.vdavydov@parallels.com>
In-Reply-To: <cover.1398587474.git.vdavydov@parallels.com>
References: <cover.1398587474.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

There is no need to allocate the memcg_caches array on kmem cache
creation, because we perfectly handle root caches without memcg_params
everywhere. Since not all caches will necessarily be used by memory
cgroups, this rather looks like a waste of memory. So let's allocate
the memcg_caches array on the first per memcg cache creation.

A couple of things to note about this patch:

 - after it is applied memcg_alloc_cache_params does nothing for root
   caches so that it can be inlined into memcg_kmem_create_cache;

 - since memcg_limited_groups_array_size is now accessed under
   activate_kmem_mutex, we can move memcg_limited_groups_array_size
   update (memcg_update_array_size) out of slab_mutex, which is nice,
   because it isn't something specific to kmem caches - it will be used
   in per memcg list_lru in the future;

 - memcg_caches allocation scheme is now spread between slab_common.c
   and memcontrol.c, but that'll be fixed by the next patches where I'll
   move it completely to slab_common.c

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |    1 +
 mm/memcontrol.c      |   59 ++++++++++++++++++++++++++++++++------------------
 mm/slab_common.c     |   33 ++++++++++++++++++++++++++++
 3 files changed, 72 insertions(+), 21 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 86e5b26fbdab..095ce8e47a36 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -119,6 +119,7 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *,
 					   struct kmem_cache *,
 					   const char *);
+int kmem_cache_init_memcg_array(struct kmem_cache *, int);
 #endif
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 605d72044533..08937040ed75 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3059,6 +3059,9 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 
 	VM_BUG_ON(!is_root_cache(s));
 
+	if (!cur_params)
+		return 0;
+
 	if (num_groups > memcg_limited_groups_array_size) {
 		int i;
 		struct memcg_cache_params *new_params;
@@ -3099,8 +3102,7 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 		 * anyway.
 		 */
 		rcu_assign_pointer(s->memcg_params, new_params);
-		if (cur_params)
-			kfree_rcu(cur_params, rcu_head);
+		kfree_rcu(cur_params, rcu_head);
 	}
 	return 0;
 }
@@ -3108,27 +3110,16 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 			     struct kmem_cache *root_cache)
 {
-	size_t size;
-
-	if (!memcg_kmem_enabled())
+	if (!memcg)
 		return 0;
 
-	if (!memcg) {
-		size = offsetof(struct memcg_cache_params, memcg_caches);
-		size += memcg_limited_groups_array_size * sizeof(void *);
-	} else
-		size = sizeof(struct memcg_cache_params);
-
-	s->memcg_params = kzalloc(size, GFP_KERNEL);
+	s->memcg_params = kzalloc(sizeof(*s->memcg_params), GFP_KERNEL);
 	if (!s->memcg_params)
 		return -ENOMEM;
 
-	if (memcg) {
-		s->memcg_params->memcg = memcg;
-		s->memcg_params->root_cache = root_cache;
-		css_get(&memcg->css);
-	} else
-		s->memcg_params->is_root_cache = true;
+	s->memcg_params->memcg = memcg;
+	s->memcg_params->root_cache = root_cache;
+	css_get(&memcg->css);
 
 	return 0;
 }
@@ -3142,6 +3133,30 @@ void memcg_free_cache_params(struct kmem_cache *s)
 	kfree(s->memcg_params);
 }
 
+/*
+ * Prepares the memcg_caches array of the given kmem cache for disposing
+ * memcgs' copies.
+ */
+static int memcg_prepare_kmem_cache(struct kmem_cache *cachep)
+{
+	int ret;
+
+	BUG_ON(!is_root_cache(cachep));
+
+	if (cachep->memcg_params)
+		return 0;
+
+	/* activate_kmem_mutex guarantees a stable value of
+	 * memcg_limited_groups_array_size */
+	mutex_lock(&activate_kmem_mutex);
+	mutex_lock(&memcg_slab_mutex);
+	ret = kmem_cache_init_memcg_array(cachep,
+			memcg_limited_groups_array_size);
+	mutex_unlock(&memcg_slab_mutex);
+	mutex_unlock(&activate_kmem_mutex);
+	return ret;
+}
+
 static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 				    struct kmem_cache *root_cache)
 {
@@ -3287,10 +3302,13 @@ static void memcg_create_cache_work_func(struct work_struct *w)
 	struct mem_cgroup *memcg = cw->memcg;
 	struct kmem_cache *cachep = cw->cachep;
 
+	if (memcg_prepare_kmem_cache(cachep) != 0)
+		goto out;
+
 	mutex_lock(&memcg_slab_mutex);
 	memcg_kmem_create_cache(memcg, cachep);
 	mutex_unlock(&memcg_slab_mutex);
-
+out:
 	css_put(&memcg->css);
 	kfree(cw);
 }
@@ -3371,8 +3389,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 	struct mem_cgroup *memcg;
 	struct kmem_cache *memcg_cachep;
 
-	VM_BUG_ON(!cachep->memcg_params);
-	VM_BUG_ON(!cachep->memcg_params->is_root_cache);
+	VM_BUG_ON(!is_root_cache(cachep));
 
 	if (!current->mm || current->memcg_kmem_skip_account)
 		return cachep;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 6b6397d2e05e..ce5e96aff4e6 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -77,6 +77,39 @@ static inline int kmem_cache_sanity_check(const char *name, size_t size)
 #endif
 
 #ifdef CONFIG_MEMCG_KMEM
+static int __kmem_cache_init_memcg_array(struct kmem_cache *s, int nr_entries)
+{
+	size_t size;
+	struct memcg_cache_params *new;
+
+	size = offsetof(struct memcg_cache_params, memcg_caches);
+	size += nr_entries * sizeof(void *);
+
+	new = kzalloc(size, GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
+
+	new->is_root_cache = true;
+
+	/* matching rcu_dereference is in cache_from_memcg_idx */
+	rcu_assign_pointer(s->memcg_params, new);
+
+	return 0;
+}
+
+int kmem_cache_init_memcg_array(struct kmem_cache *s, int nr_entries)
+{
+	int ret = 0;
+
+	BUG_ON(!is_root_cache(s));
+
+	mutex_lock(&slab_mutex);
+	if (!s->memcg_params)
+		ret = __kmem_cache_init_memcg_array(s, nr_entries);
+	mutex_unlock(&slab_mutex);
+	return ret;
+}
+
 int memcg_update_all_caches(int num_memcgs)
 {
 	struct kmem_cache *s;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
