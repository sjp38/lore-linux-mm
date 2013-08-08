Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 2FA386B0031
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 16:57:55 -0400 (EDT)
From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] [RFC] kmemcg: remove union from memcg_params
Date: Fri,  9 Aug 2013 00:51:26 +0400
Message-Id: <1375995086-15456-1-git-send-email-avagin@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrey Vagin <avagin@openvz.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

struct memcg_cache_params {
        bool is_root_cache;
        union {
                struct kmem_cache *memcg_caches[0];
                struct {
                        struct mem_cgroup *memcg;
                        struct list_head list;
                        struct kmem_cache *root_cache;
                        bool dead;
                        atomic_t nr_pages;
                        struct work_struct destroy;
                };
        };
};

This union is a bit dangerous. //Andrew Morton

The first problem was fixed in v3.10-rc5-67-gf101a94.
The second problem is that the size of memory for root
caches is calculated incorrectly:

	ssize_t size = memcg_caches_array_size(num_groups);

	size *= sizeof(void *);
	size += sizeof(struct memcg_cache_params);

The last line should be fixed like this:
	size += offsetof(struct memcg_cache_params, memcg_caches)

Andrew suggested to rework this code without union and
this patch tries to do that.

This patch removes is_root_cache and union. The size of the
memcg_cache_params structure is not changed.

memcg_caches is moved from memcg_cache_params to kmem_cache.

Cc: Glauber Costa <glommer@parallels.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 include/linux/slab.h     | 18 ++++--------
 include/linux/slab_def.h |  1 +
 include/linux/slub_def.h |  1 +
 mm/memcontrol.c          | 74 +++++++++++++++++++++---------------------------
 mm/slab.h                |  4 +--
 5 files changed, 43 insertions(+), 55 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 6c5cc0e..fbed77f 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -352,18 +352,12 @@ static __always_inline int kmalloc_size(int n)
  *           ready, to destroy this cache.
  */
 struct memcg_cache_params {
-	bool is_root_cache;
-	union {
-		struct kmem_cache *memcg_caches[0];
-		struct {
-			struct mem_cgroup *memcg;
-			struct list_head list;
-			struct kmem_cache *root_cache;
-			bool dead;
-			atomic_t nr_pages;
-			struct work_struct destroy;
-		};
-	};
+	struct mem_cgroup *memcg;
+	struct list_head list;
+	struct kmem_cache *root_cache;
+	bool dead;
+	atomic_t nr_pages;
+	struct work_struct destroy;
 };
 
 int memcg_update_all_caches(int num_memcgs);
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index cd40158..15751cd 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -80,6 +80,7 @@ struct kmem_cache {
 	int obj_offset;
 #endif /* CONFIG_DEBUG_SLAB */
 #ifdef CONFIG_MEMCG_KMEM
+	struct kmem_cache **memcg_caches;
 	struct memcg_cache_params *memcg_params;
 #endif
 
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 027276f..b9dfc3c 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -91,6 +91,7 @@ struct kmem_cache {
 	struct kobject kobj;	/* For sysfs */
 #endif
 #ifdef CONFIG_MEMCG_KMEM
+	struct kmem_cache **memcg_caches;
 	struct memcg_cache_params *memcg_params;
 	int max_attr_size; /* for propagation, maximum size of a stored attr */
 #endif
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c5792a5..d1041de 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -41,6 +41,7 @@
 #include <linux/mutex.h>
 #include <linux/rbtree.h>
 #include <linux/slab.h>
+#include "slab.h"
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/spinlock.h>
@@ -2948,9 +2949,8 @@ static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
 {
 	struct kmem_cache *cachep;
 
-	VM_BUG_ON(p->is_root_cache);
 	cachep = p->root_cache;
-	return cachep->memcg_params->memcg_caches[memcg_cache_id(p->memcg)];
+	return cachep->memcg_caches[memcg_cache_id(p->memcg)];
 }
 
 #ifdef CONFIG_SLABINFO
@@ -3131,25 +3131,22 @@ static void kmem_cache_destroy_work_func(struct work_struct *w);
 
 int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 {
-	struct memcg_cache_params *cur_params = s->memcg_params;
+	struct kmem_cache **cur_caches = s->memcg_caches;
 
-	VM_BUG_ON(s->memcg_params && !s->memcg_params->is_root_cache);
+	VM_BUG_ON(!is_root_cache(s));
 
 	if (num_groups > memcg_limited_groups_array_size) {
 		int i;
 		ssize_t size = memcg_caches_array_size(num_groups);
 
 		size *= sizeof(void *);
-		size += sizeof(struct memcg_cache_params);
 
-		s->memcg_params = kzalloc(size, GFP_KERNEL);
-		if (!s->memcg_params) {
-			s->memcg_params = cur_params;
+		s->memcg_caches = kzalloc(size, GFP_KERNEL);
+		if (!s->memcg_caches) {
+			s->memcg_caches = cur_caches;
 			return -ENOMEM;
 		}
 
-		s->memcg_params->is_root_cache = true;
-
 		/*
 		 * There is the chance it will be bigger than
 		 * memcg_limited_groups_array_size, if we failed an allocation
@@ -3160,10 +3157,9 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 		 * memcg_limited_groups_array_size is certainly unused
 		 */
 		for (i = 0; i < memcg_limited_groups_array_size; i++) {
-			if (!cur_params->memcg_caches[i])
+			if (!cur_caches[i])
 				continue;
-			s->memcg_params->memcg_caches[i] =
-						cur_params->memcg_caches[i];
+			s->memcg_caches[i] = cur_caches[i];
 		}
 
 		/*
@@ -3175,7 +3171,7 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 		 * bigger than the others. And all updates will reset this
 		 * anyway.
 		 */
-		kfree(cur_params);
+		kfree(cur_caches);
 	}
 	return 0;
 }
@@ -3183,25 +3179,28 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
 			 struct kmem_cache *root_cache)
 {
-	size_t size = sizeof(struct memcg_cache_params);
+	size_t size;
 
 	if (!memcg_kmem_enabled())
 		return 0;
 
-	if (!memcg)
-		size += memcg_limited_groups_array_size * sizeof(void *);
-
-	s->memcg_params = kzalloc(size, GFP_KERNEL);
-	if (!s->memcg_params)
-		return -ENOMEM;
-
-	if (memcg) {
+	if (!memcg) {
+		VM_BUG_ON(s->memcg_params);
+		size = memcg_limited_groups_array_size * sizeof(void *);
+		s->memcg_caches = kzalloc(size, GFP_KERNEL);
+		if (!s->memcg_caches)
+			return -ENOMEM;
+	} else {
+		VM_BUG_ON(s->memcg_caches);
+		size = sizeof(struct memcg_cache_params);
+		s->memcg_params = kzalloc(size, GFP_KERNEL);
+		if (!s->memcg_params)
+			return -ENOMEM;
 		s->memcg_params->memcg = memcg;
 		s->memcg_params->root_cache = root_cache;
 		INIT_WORK(&s->memcg_params->destroy,
 				kmem_cache_destroy_work_func);
-	} else
-		s->memcg_params->is_root_cache = true;
+	}
 
 	return 0;
 }
@@ -3212,6 +3211,8 @@ void memcg_release_cache(struct kmem_cache *s)
 	struct mem_cgroup *memcg;
 	int id;
 
+	kfree(s->memcg_caches);
+
 	/*
 	 * This happens, for instance, when a root cache goes away before we
 	 * add any memcg.
@@ -3219,21 +3220,17 @@ void memcg_release_cache(struct kmem_cache *s)
 	if (!s->memcg_params)
 		return;
 
-	if (s->memcg_params->is_root_cache)
-		goto out;
-
 	memcg = s->memcg_params->memcg;
 	id  = memcg_cache_id(memcg);
 
 	root = s->memcg_params->root_cache;
-	root->memcg_params->memcg_caches[id] = NULL;
+	root->memcg_caches[id] = NULL;
 
 	mutex_lock(&memcg->slab_caches_mutex);
 	list_del(&s->memcg_params->list);
 	mutex_unlock(&memcg->slab_caches_mutex);
 
 	css_put(&memcg->css);
-out:
 	kfree(s->memcg_params);
 }
 
@@ -3391,7 +3388,7 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	idx = memcg_cache_id(memcg);
 
 	mutex_lock(&memcg_cache_mutex);
-	new_cachep = cachep->memcg_params->memcg_caches[idx];
+	new_cachep = cachep->memcg_caches[idx];
 	if (new_cachep) {
 		css_put(&memcg->css);
 		goto out;
@@ -3406,7 +3403,7 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 
 	atomic_set(&new_cachep->memcg_params->nr_pages , 0);
 
-	cachep->memcg_params->memcg_caches[idx] = new_cachep;
+	cachep->memcg_caches[idx] = new_cachep;
 	/*
 	 * the readers won't lock, make sure everybody sees the updated value,
 	 * so they won't put stuff in the queue again for no reason
@@ -3422,9 +3419,7 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 	struct kmem_cache *c;
 	int i;
 
-	if (!s->memcg_params)
-		return;
-	if (!s->memcg_params->is_root_cache)
+	if (!s->memcg_caches)
 		return;
 
 	/*
@@ -3438,7 +3433,7 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 	 */
 	mutex_lock(&set_limit_mutex);
 	for (i = 0; i < memcg_limited_groups_array_size; i++) {
-		c = s->memcg_params->memcg_caches[i];
+		c = s->memcg_caches[i];
 		if (!c)
 			continue;
 
@@ -3552,9 +3547,6 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 	struct mem_cgroup *memcg;
 	int idx;
 
-	VM_BUG_ON(!cachep->memcg_params);
-	VM_BUG_ON(!cachep->memcg_params->is_root_cache);
-
 	if (!current->mm || current->memcg_kmem_skip_account)
 		return cachep;
 
@@ -3571,8 +3563,8 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 	 * code updating memcg_caches will issue a write barrier to match this.
 	 */
 	read_barrier_depends();
-	if (likely(cachep->memcg_params->memcg_caches[idx])) {
-		cachep = cachep->memcg_params->memcg_caches[idx];
+	if (likely(cachep->memcg_caches[idx])) {
+		cachep = cachep->memcg_caches[idx];
 		goto out;
 	}
 
diff --git a/mm/slab.h b/mm/slab.h
index 620ceed..fe82b4b 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -116,7 +116,7 @@ ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 #ifdef CONFIG_MEMCG_KMEM
 static inline bool is_root_cache(struct kmem_cache *s)
 {
-	return !s->memcg_params || s->memcg_params->is_root_cache;
+	return !s->memcg_params;
 }
 
 static inline bool cache_match_memcg(struct kmem_cache *cachep,
@@ -162,7 +162,7 @@ static inline const char *cache_name(struct kmem_cache *s)
 
 static inline struct kmem_cache *cache_from_memcg(struct kmem_cache *s, int idx)
 {
-	return s->memcg_params->memcg_caches[idx];
+	return s->memcg_caches[idx];
 }
 
 static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
