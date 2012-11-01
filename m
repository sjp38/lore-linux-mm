Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 8E0E46B0082
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 08:09:12 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 17/29] consider a memcg parameter in kmem_create_cache
Date: Thu,  1 Nov 2012 16:07:33 +0400
Message-Id: <1351771665-11076-18-git-send-email-glommer@parallels.com>
In-Reply-To: <1351771665-11076-1-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

Allow a memcg parameter to be passed during cache creation.  When the
slub allocator is being used, it will only merge caches that belong to
the same memcg. We'll do this by scanning the global list, and then
translating the cache to a memcg-specific cache

Default function is created as a wrapper, passing NULL to the memcg
version. We only merge caches that belong to the same memcg.

A helper is provided, memcg_css_id: because slub needs a unique cache
name for sysfs. Since this is visible, but not the canonical location
for slab data, the cache name is not used, the css_id should suffice.

[ v2: moved to idr/ida instead of redoing the indexes ]
[ v3: moved call to ida_init away from cgroup creation to fix a bug ]
[ v4: no longer using the index mechanism ]
[ v6: renamed memcg_css_id to memcg_cache_id, and return a proper id ]

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
CC: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h | 26 +++++++++++++++++++++++
 include/linux/slab.h       | 14 ++++++++++++-
 mm/memcontrol.c            | 51 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/slab.h                  | 23 +++++++++++++++++----
 mm/slab_common.c           | 42 ++++++++++++++++++++++++++++++--------
 mm/slub.c                  | 19 +++++++++++++----
 6 files changed, 157 insertions(+), 18 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 2a2ae05..ea1e66f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -28,6 +28,7 @@ struct mem_cgroup;
 struct page_cgroup;
 struct page;
 struct mm_struct;
+struct kmem_cache;
 
 /* Stats that can be updated by kernel. */
 enum mem_cgroup_page_stat_item {
@@ -434,6 +435,11 @@ void __memcg_kmem_commit_charge(struct page *page,
 				       struct mem_cgroup *memcg, int order);
 void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
+int memcg_cache_id(struct mem_cgroup *memcg);
+int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s);
+void memcg_release_cache(struct kmem_cache *cachep);
+void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep);
+
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
  * @gfp: the gfp allocation flags.
@@ -518,6 +524,26 @@ static inline void
 memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg, int order)
 {
 }
+
+static inline int memcg_cache_id(struct mem_cgroup *memcg)
+{
+	return -1;
+}
+
+static inline int memcg_register_cache(struct mem_cgroup *memcg,
+				       struct kmem_cache *s)
+{
+	return 0;
+}
+
+static inline void memcg_release_cache(struct kmem_cache *cachep)
+{
+}
+
+static inline void memcg_cache_list_add(struct mem_cgroup *memcg,
+					struct kmem_cache *s)
+{
+}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 8860e08..892367e 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -116,6 +116,7 @@ struct kmem_cache {
 };
 #endif
 
+struct mem_cgroup;
 /*
  * struct kmem_cache related prototypes
  */
@@ -125,6 +126,9 @@ int slab_is_available(void);
 struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
 			void (*)(void *));
+struct kmem_cache *
+kmem_cache_create_memcg(struct mem_cgroup *, const char *, size_t, size_t,
+			unsigned long, void (*)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);
@@ -192,15 +196,23 @@ unsigned int kmem_cache_size(struct kmem_cache *);
  * Child caches will hold extra metadata needed for its operation. Fields are:
  *
  * @memcg: pointer to the memcg this cache belongs to
+ * @list: list_head for the list of all caches in this memcg
+ * @root_cache: pointer to the global, root cache, this cache was derived from
  */
 struct memcg_cache_params {
 	bool is_root_cache;
 	union {
 		struct kmem_cache *memcg_caches[0];
-		struct mem_cgroup *memcg;
+		struct {
+			struct mem_cgroup *memcg;
+			struct list_head list;
+			struct kmem_cache *root_cache;
+		};
 	};
 };
 
+int memcg_update_all_caches(int num_memcgs);
+
 /*
  * Common kmalloc functions provided by all allocators
  */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5e8962c..fb5b1e6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -339,6 +339,14 @@ struct mem_cgroup {
 #if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
 	struct tcp_memcontrol tcp_mem;
 #endif
+#if defined(CONFIG_MEMCG_KMEM)
+	/* analogous to slab_common's slab_caches list. per-memcg */
+	struct list_head memcg_slab_caches;
+	/* Not a spinlock, we can take a lot of time walking the list */
+	struct mutex slab_caches_mutex;
+        /* Index in the kmem_cache->memcg_params->memcg_caches array */
+	int kmemcg_id;
+#endif
 };
 
 /* internal only representation about the status of kmem accounting. */
@@ -2754,6 +2762,47 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 		mem_cgroup_put(memcg);
 }
 
+void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
+{
+	if (!memcg)
+		return;
+
+	mutex_lock(&memcg->slab_caches_mutex);
+	list_add(&cachep->memcg_params->list, &memcg->memcg_slab_caches);
+	mutex_unlock(&memcg->slab_caches_mutex);
+}
+
+/*
+ * helper for acessing a memcg's index. It will be used as an index in the
+ * child cache array in kmem_cache, and also to derive its name. This function
+ * will return -1 when this is not a kmem-limited memcg.
+ */
+int memcg_cache_id(struct mem_cgroup *memcg)
+{
+	return memcg ? memcg->kmemcg_id : -1;
+}
+
+int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s)
+{
+	size_t size = sizeof(struct memcg_cache_params);
+
+	if (!memcg_kmem_enabled())
+		return 0;
+
+	s->memcg_params = kzalloc(size, GFP_KERNEL);
+	if (!s->memcg_params)
+		return -ENOMEM;
+
+	if (memcg)
+		s->memcg_params->memcg = memcg;
+	return 0;
+}
+
+void memcg_release_cache(struct kmem_cache *s)
+{
+	kfree(s->memcg_params);
+}
+
 /*
  * We need to verify if the allocation against current->mm->owner's memcg is
  * possible for the given order. But the page is not allocated yet, so we'll
@@ -4991,7 +5040,9 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 #ifdef CONFIG_MEMCG_KMEM
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
+	memcg->kmemcg_id = -1;
 	memcg_propagate_kmem(memcg);
+
 	return mem_cgroup_sockets_init(memcg, ss);
 };
 
diff --git a/mm/slab.h b/mm/slab.h
index 5ee1851..22eb5aa2 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -35,12 +35,15 @@ extern struct kmem_cache *kmem_cache;
 /* Functions provided by the slab allocators */
 extern int __kmem_cache_create(struct kmem_cache *, unsigned long flags);
 
+struct mem_cgroup;
 #ifdef CONFIG_SLUB
-struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
-	size_t align, unsigned long flags, void (*ctor)(void *));
+struct kmem_cache *
+__kmem_cache_alias(struct mem_cgroup *memcg, const char *name, size_t size,
+		   size_t align, unsigned long flags, void (*ctor)(void *));
 #else
-static inline struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
-	size_t align, unsigned long flags, void (*ctor)(void *))
+static inline struct kmem_cache *
+__kmem_cache_alias(struct mem_cgroup *memcg, const char *name, size_t size,
+		   size_t align, unsigned long flags, void (*ctor)(void *))
 { return NULL; }
 #endif
 
@@ -98,11 +101,23 @@ static inline bool is_root_cache(struct kmem_cache *s)
 {
 	return !s->memcg_params || s->memcg_params->is_root_cache;
 }
+
+static inline bool cache_match_memcg(struct kmem_cache *cachep,
+				     struct mem_cgroup *memcg)
+{
+	return (is_root_cache(cachep) && !memcg) ||
+				(cachep->memcg_params->memcg == memcg);
+}
 #else
 static inline bool is_root_cache(struct kmem_cache *s)
 {
 	return true;
 }
 
+static inline bool cache_match_memcg(struct kmem_cache *cachep,
+				     struct mem_cgroup *memcg)
+{
+	return true;
+}
 #endif
 #endif
diff --git a/mm/slab_common.c b/mm/slab_common.c
index b705be7..0578731 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -18,6 +18,7 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 #include <asm/page.h>
+#include <linux/memcontrol.h>
 
 #include "slab.h"
 
@@ -27,7 +28,8 @@ DEFINE_MUTEX(slab_mutex);
 struct kmem_cache *kmem_cache;
 
 #ifdef CONFIG_DEBUG_VM
-static int kmem_cache_sanity_check(const char *name, size_t size)
+static int kmem_cache_sanity_check(struct mem_cgroup *memcg, const char *name,
+				   size_t size)
 {
 	struct kmem_cache *s = NULL;
 
@@ -53,7 +55,13 @@ static int kmem_cache_sanity_check(const char *name, size_t size)
 			continue;
 		}
 
-		if (!strcmp(s->name, name)) {
+		/*
+		 * For simplicity, we won't check this in the list of memcg
+		 * caches. We have control over memcg naming, and if there
+		 * aren't duplicates in the global list, there won't be any
+		 * duplicates in the memcg lists as well.
+		 */
+		if (!memcg && !strcmp(s->name, name)) {
 			pr_err("%s (%s): Cache name already exists.\n",
 			       __func__, name);
 			dump_stack();
@@ -66,7 +74,8 @@ static int kmem_cache_sanity_check(const char *name, size_t size)
 	return 0;
 }
 #else
-static inline int kmem_cache_sanity_check(const char *name, size_t size)
+static inline int kmem_cache_sanity_check(struct mem_cgroup *memcg,
+					  const char *name, size_t size)
 {
 	return 0;
 }
@@ -97,8 +106,9 @@ static inline int kmem_cache_sanity_check(const char *name, size_t size)
  * as davem.
  */
 
-struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align,
-		unsigned long flags, void (*ctor)(void *))
+struct kmem_cache *
+kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
+			size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s = NULL;
 	int err = 0;
@@ -106,7 +116,7 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
 	get_online_cpus();
 	mutex_lock(&slab_mutex);
 
-	if (!kmem_cache_sanity_check(name, size) == 0)
+	if (!kmem_cache_sanity_check(memcg, name, size) == 0)
 		goto out_locked;
 
 	/*
@@ -117,7 +127,7 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
 	 */
 	flags &= CACHE_CREATE_MASK;
 
-	s = __kmem_cache_alias(name, size, align, flags, ctor);
+	s = __kmem_cache_alias(memcg, name, size, align, flags, ctor);
 	if (s)
 		goto out_locked;
 
@@ -126,6 +136,13 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
 		s->object_size = s->size = size;
 		s->align = align;
 		s->ctor = ctor;
+
+		if (memcg_register_cache(memcg, s)) {
+			kmem_cache_free(kmem_cache, s);
+			err = -ENOMEM;
+			goto out_locked;
+		}
+
 		s->name = kstrdup(name, GFP_KERNEL);
 		if (!s->name) {
 			kmem_cache_free(kmem_cache, s);
@@ -135,10 +152,9 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
 
 		err = __kmem_cache_create(s, flags);
 		if (!err) {
-
 			s->refcount = 1;
 			list_add(&s->list, &slab_caches);
-
+			memcg_cache_list_add(memcg, s);
 		} else {
 			kfree(s->name);
 			kmem_cache_free(kmem_cache, s);
@@ -166,6 +182,13 @@ out_locked:
 
 	return s;
 }
+
+struct kmem_cache *
+kmem_cache_create(const char *name, size_t size, size_t align,
+		  unsigned long flags, void (*ctor)(void *))
+{
+	return kmem_cache_create_memcg(NULL, name, size, align, flags, ctor);
+}
 EXPORT_SYMBOL(kmem_cache_create);
 
 void kmem_cache_destroy(struct kmem_cache *s)
@@ -181,6 +204,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
 			if (s->flags & SLAB_DESTROY_BY_RCU)
 				rcu_barrier();
 
+			memcg_release_cache(s);
 			kfree(s->name);
 			kmem_cache_free(kmem_cache, s);
 		} else {
diff --git a/mm/slub.c b/mm/slub.c
index 259bc2c..a105bdc 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -31,6 +31,7 @@
 #include <linux/fault-inject.h>
 #include <linux/stacktrace.h>
 #include <linux/prefetch.h>
+#include <linux/memcontrol.h>
 
 #include <trace/events/kmem.h>
 
@@ -3880,7 +3881,7 @@ static int slab_unmergeable(struct kmem_cache *s)
 	return 0;
 }
 
-static struct kmem_cache *find_mergeable(size_t size,
+static struct kmem_cache *find_mergeable(struct mem_cgroup *memcg, size_t size,
 		size_t align, unsigned long flags, const char *name,
 		void (*ctor)(void *))
 {
@@ -3916,17 +3917,21 @@ static struct kmem_cache *find_mergeable(size_t size,
 		if (s->size - size >= sizeof(void *))
 			continue;
 
+		if (!cache_match_memcg(s, memcg))
+			continue;
+
 		return s;
 	}
 	return NULL;
 }
 
-struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
-		size_t align, unsigned long flags, void (*ctor)(void *))
+struct kmem_cache *
+__kmem_cache_alias(struct mem_cgroup *memcg, const char *name, size_t size,
+		   size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
 
-	s = find_mergeable(size, align, flags, name, ctor);
+	s = find_mergeable(memcg, size, align, flags, name, ctor);
 	if (s) {
 		s->refcount++;
 		/*
@@ -5246,6 +5251,12 @@ static char *create_unique_id(struct kmem_cache *s)
 	if (p != name + 1)
 		*p++ = '-';
 	p += sprintf(p, "%07d", s->size);
+
+#ifdef CONFIG_MEMCG_KMEM
+	if (!is_root_cache(s))
+		p += sprintf(p, "-%08d", memcg_cache_id(s->memcg_params->memcg));
+#endif
+
 	BUG_ON(p > name + ID_STR_LENGTH - 1);
 	return name;
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
