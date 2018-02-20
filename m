Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC2D96B0026
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 14:42:06 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p188so3288229pfp.1
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:42:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j2sor1264407pgn.253.2018.02.20.11.42.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Feb 2018 11:42:04 -0800 (PST)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH 1/3] mm: memcg: plumbing memcg for kmem cache allocations
Date: Tue, 20 Feb 2018 11:41:47 -0800
Message-Id: <20180220194149.242009-2-shakeelb@google.com>
In-Reply-To: <20180220194149.242009-1-shakeelb@google.com>
References: <20180220194149.242009-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

Introducing the memcg variant for kmem cache allocation functions.
Currently the kernel switches the root kmem cache with the memcg
specific kmem cache for __GFP_ACCOUNT allocations to charge those
allocations to the memcg. However, the memcg to charge is extracted from
the current task_struct. This patch introduces the variant of kmem cache
allocation functions where the memcg can be provided explicitly by the
caller instead of deducing the memcg from the current task.

These functions are useful for use-cases where the allocations should be
charged to the memcg different from the memcg of the caller. One such
concrete use-case is the allocations for fsnotify event objects where
the objects should be charged to the listener instead of the producer.

One requirement to call these functions is that the caller must have the
reference to the memcg.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 include/linux/memcontrol.h |  3 +-
 include/linux/slab.h       | 41 ++++++++++++++++++++
 mm/memcontrol.c            | 18 +++++++--
 mm/slab.c                  | 78 +++++++++++++++++++++++++++++++++-----
 mm/slab.h                  |  6 +--
 mm/slub.c                  | 77 ++++++++++++++++++++++++++++++-------
 6 files changed, 192 insertions(+), 31 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c79cdf9f8138..48eaf19859e9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1174,7 +1174,8 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 }
 #endif
 
-struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep);
+struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep,
+					struct mem_cgroup *memcg);
 void memcg_kmem_put_cache(struct kmem_cache *cachep);
 int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 			    struct mem_cgroup *memcg);
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 231abc8976c5..24355bc9e655 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -353,6 +353,8 @@ static __always_inline int kmalloc_index(size_t size)
 
 void *__kmalloc(size_t size, gfp_t flags) __assume_kmalloc_alignment __malloc;
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags) __assume_slab_alignment __malloc;
+void *kmem_cache_alloc_memcg(struct kmem_cache *, gfp_t flags,
+		struct mem_cgroup *memcg) __assume_slab_alignment __malloc;
 void kmem_cache_free(struct kmem_cache *, void *);
 
 /*
@@ -377,6 +379,8 @@ static __always_inline void kfree_bulk(size_t size, void **p)
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node) __assume_kmalloc_alignment __malloc;
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node) __assume_slab_alignment __malloc;
+void *kmem_cache_alloc_node_memcg(struct kmem_cache *, gfp_t flags, int node,
+		struct mem_cgroup *memcg) __assume_slab_alignment __malloc;
 #else
 static __always_inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
@@ -387,15 +391,26 @@ static __always_inline void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t f
 {
 	return kmem_cache_alloc(s, flags);
 }
+
+static __always_inline void *kmem_cache_alloc_node_memcg(struct kmem_cache *s,
+				gfp_t flags, int node, struct mem_cgroup *memcg)
+{
+	return kmem_cache_alloc_memcg(s, flags, memcg);
+}
 #endif
 
 #ifdef CONFIG_TRACING
 extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t, size_t) __assume_slab_alignment __malloc;
+extern void *kmem_cache_alloc_memcg_trace(struct kmem_cache *, gfp_t, size_t,
+		struct mem_cgroup *memcg) __assume_slab_alignment __malloc;
 
 #ifdef CONFIG_NUMA
 extern void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 					   gfp_t gfpflags,
 					   int node, size_t size) __assume_slab_alignment __malloc;
+extern void *kmem_cache_alloc_node_memcg_trace(struct kmem_cache *s,
+		gfp_t gfpflags, int node, size_t size,
+		struct mem_cgroup *memcg) __assume_slab_alignment __malloc;
 #else
 static __always_inline void *
 kmem_cache_alloc_node_trace(struct kmem_cache *s,
@@ -404,6 +419,13 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
 {
 	return kmem_cache_alloc_trace(s, gfpflags, size);
 }
+
+static __always_inline void *
+kmem_cache_alloc_node_memcg_trace(struct kmem_cache *s, gfp_t gfpflags,
+				int node, size_t size, struct mem_cgroup *memcg)
+{
+	return kmem_cache_alloc_memcg_trace(s, gfpflags, size, memcg);
+}
 #endif /* CONFIG_NUMA */
 
 #else /* CONFIG_TRACING */
@@ -416,6 +438,15 @@ static __always_inline void *kmem_cache_alloc_trace(struct kmem_cache *s,
 	return ret;
 }
 
+static __always_inline void *kmem_cache_alloc_memcg_trace(struct kmem_cache *s,
+		gfp_t flags, size_t size, struct mem_cgroup *memcg)
+{
+	void *ret = kmem_cache_alloc_memcg(s, flags, memcg);
+
+	kasan_kmalloc(s, ret, size, flags);
+	return ret;
+}
+
 static __always_inline void *
 kmem_cache_alloc_node_trace(struct kmem_cache *s,
 			      gfp_t gfpflags,
@@ -426,6 +457,16 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
 	kasan_kmalloc(s, ret, size, gfpflags);
 	return ret;
 }
+
+static __always_inline void *
+kmem_cache_alloc_node_memcg_trace(struct kmem_cache *s, gfp_t gfpflags,
+				int node, size_t size, struct mem_cgroup *memcg)
+{
+	void *ret = kmem_cache_alloc_node_memcg(s, gfpflags, node, memcg);
+
+	kasan_kmalloc(s, ret, size, gfpflags);
+	return ret;
+}
 #endif /* CONFIG_TRACING */
 
 extern void *kmalloc_order(size_t size, gfp_t flags, unsigned int order) __assume_page_alignment __malloc;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fffe502a2c7f..bd37e855e277 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -701,6 +701,15 @@ static struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 	return memcg;
 }
 
+static struct mem_cgroup *get_mem_cgroup(struct mem_cgroup *memcg)
+{
+	rcu_read_lock();
+	if (!css_tryget_online(&memcg->css))
+		memcg = NULL;
+	rcu_read_unlock();
+	return memcg;
+}
+
 /**
  * mem_cgroup_iter - iterate over memory cgroup hierarchy
  * @root: hierarchy root
@@ -2246,9 +2255,9 @@ static inline bool memcg_kmem_bypass(void)
  * done with it, memcg_kmem_put_cache() must be called to release the
  * reference.
  */
-struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
+struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep,
+					struct mem_cgroup *memcg)
 {
-	struct mem_cgroup *memcg;
 	struct kmem_cache *memcg_cachep;
 	int kmemcg_id;
 
@@ -2260,7 +2269,10 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
 	if (current->memcg_kmem_skip_account)
 		return cachep;
 
-	memcg = get_mem_cgroup_from_mm(current->mm);
+	if (memcg)
+		memcg = get_mem_cgroup(memcg);
+	if (!memcg)
+		memcg = get_mem_cgroup_from_mm(current->mm);
 	kmemcg_id = READ_ONCE(memcg->kmemcg_id);
 	if (kmemcg_id < 0)
 		goto out;
diff --git a/mm/slab.c b/mm/slab.c
index 324446621b3e..3daeda62bd0c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3276,14 +3276,14 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 
 static __always_inline void *
 slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
-		   unsigned long caller)
+		struct mem_cgroup *memcg, unsigned long caller)
 {
 	unsigned long save_flags;
 	void *ptr;
 	int slab_node = numa_mem_id();
 
 	flags &= gfp_allowed_mask;
-	cachep = slab_pre_alloc_hook(cachep, flags);
+	cachep = slab_pre_alloc_hook(cachep, flags, memcg);
 	if (unlikely(!cachep))
 		return NULL;
 
@@ -3356,13 +3356,14 @@ __do_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 #endif /* CONFIG_NUMA */
 
 static __always_inline void *
-slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
+slab_alloc(struct kmem_cache *cachep, gfp_t flags, struct mem_cgroup *memcg,
+	   unsigned long caller)
 {
 	unsigned long save_flags;
 	void *objp;
 
 	flags &= gfp_allowed_mask;
-	cachep = slab_pre_alloc_hook(cachep, flags);
+	cachep = slab_pre_alloc_hook(cachep, flags, memcg);
 	if (unlikely(!cachep))
 		return NULL;
 
@@ -3536,7 +3537,7 @@ void ___cache_free(struct kmem_cache *cachep, void *objp,
  */
 void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
-	void *ret = slab_alloc(cachep, flags, _RET_IP_);
+	void *ret = slab_alloc(cachep, flags, NULL,  _RET_IP_);
 
 	kasan_slab_alloc(cachep, ret, flags);
 	trace_kmem_cache_alloc(_RET_IP_, ret,
@@ -3546,6 +3547,19 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
+void *kmem_cache_alloc_memcg(struct kmem_cache *cachep, gfp_t flags,
+			     struct mem_cgroup *memcg)
+{
+	void *ret = slab_alloc(cachep, flags, memcg, _RET_IP_);
+
+	kasan_slab_alloc(cachep, ret, flags);
+	trace_kmem_cache_alloc(_RET_IP_, ret,
+			       cachep->object_size, cachep->size, flags);
+
+	return ret;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_memcg);
+
 static __always_inline void
 cache_alloc_debugcheck_after_bulk(struct kmem_cache *s, gfp_t flags,
 				  size_t size, void **p, unsigned long caller)
@@ -3561,7 +3575,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 {
 	size_t i;
 
-	s = slab_pre_alloc_hook(s, flags);
+	s = slab_pre_alloc_hook(s, flags, NULL);
 	if (!s)
 		return 0;
 
@@ -3602,7 +3616,7 @@ kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
 {
 	void *ret;
 
-	ret = slab_alloc(cachep, flags, _RET_IP_);
+	ret = slab_alloc(cachep, flags, NULL, _RET_IP_);
 
 	kasan_kmalloc(cachep, ret, size, flags);
 	trace_kmalloc(_RET_IP_, ret,
@@ -3610,6 +3624,21 @@ kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_trace);
+
+void *
+kmem_cache_alloc_memcg_trace(struct kmem_cache *cachep, gfp_t flags,
+			     size_t size, struct mem_cgroup *memcg)
+{
+	void *ret;
+
+	ret = slab_alloc(cachep, flags, memcg, _RET_IP_);
+
+	kasan_kmalloc(cachep, ret, size, flags);
+	trace_kmalloc(_RET_IP_, ret,
+		      size, cachep->size, flags);
+	return ret;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_memcg_trace);
 #endif
 
 #ifdef CONFIG_NUMA
@@ -3626,7 +3655,7 @@ EXPORT_SYMBOL(kmem_cache_alloc_trace);
  */
 void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
-	void *ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
+	void *ret = slab_alloc_node(cachep, flags, nodeid, NULL, _RET_IP_);
 
 	kasan_slab_alloc(cachep, ret, flags);
 	trace_kmem_cache_alloc_node(_RET_IP_, ret,
@@ -3637,6 +3666,20 @@ void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 
+void *kmem_cache_alloc_node_memcg(struct kmem_cache *cachep, gfp_t flags,
+				  int nodeid, struct mem_cgroup *memcg)
+{
+	void *ret = slab_alloc_node(cachep, flags, nodeid, memcg, _RET_IP_);
+
+	kasan_slab_alloc(cachep, ret, flags);
+	trace_kmem_cache_alloc_node(_RET_IP_, ret,
+				    cachep->object_size, cachep->size,
+				    flags, nodeid);
+
+	return ret;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_node_memcg);
+
 #ifdef CONFIG_TRACING
 void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
 				  gfp_t flags,
@@ -3645,7 +3688,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
 {
 	void *ret;
 
-	ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
+	ret = slab_alloc_node(cachep, flags, nodeid, NULL, _RET_IP_);
 
 	kasan_kmalloc(cachep, ret, size, flags);
 	trace_kmalloc_node(_RET_IP_, ret,
@@ -3654,6 +3697,21 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
+
+void *kmem_cache_alloc_node_memcg_trace(struct kmem_cache *cachep, gfp_t flags,
+			int nodeid, size_t size, struct mem_cgroup *memcg)
+{
+	void *ret;
+
+	ret = slab_alloc_node(cachep, flags, nodeid, memcg, _RET_IP_);
+
+	kasan_kmalloc(cachep, ret, size, flags);
+	trace_kmalloc_node(_RET_IP_, ret,
+			   size, cachep->size,
+			   flags, nodeid);
+	return ret;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_node_memcg_trace);
 #endif
 
 static __always_inline void *
@@ -3700,7 +3758,7 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 	cachep = kmalloc_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
-	ret = slab_alloc(cachep, flags, caller);
+	ret = slab_alloc(cachep, flags, NULL, caller);
 
 	kasan_kmalloc(cachep, ret, size, flags);
 	trace_kmalloc(caller, ret,
diff --git a/mm/slab.h b/mm/slab.h
index 51813236e773..77b02583ee2c 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -410,7 +410,7 @@ static inline size_t slab_ksize(const struct kmem_cache *s)
 }
 
 static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
-						     gfp_t flags)
+					gfp_t flags, struct mem_cgroup *memcg)
 {
 	flags &= gfp_allowed_mask;
 
@@ -423,8 +423,8 @@ static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
 		return NULL;
 
 	if (memcg_kmem_enabled() &&
-	    ((flags & __GFP_ACCOUNT) || (s->flags & SLAB_ACCOUNT)))
-		return memcg_kmem_get_cache(s);
+	    ((flags & __GFP_ACCOUNT) || (s->flags & SLAB_ACCOUNT) || memcg))
+		return memcg_kmem_get_cache(s, memcg);
 
 	return s;
 }
diff --git a/mm/slub.c b/mm/slub.c
index e381728a3751..061cfbc7c3d7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2641,14 +2641,15 @@ static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
  * Otherwise we can simply pick the next object from the lockless free list.
  */
 static __always_inline void *slab_alloc_node(struct kmem_cache *s,
-		gfp_t gfpflags, int node, unsigned long addr)
+		gfp_t gfpflags, int node, struct mem_cgroup *memcg,
+		unsigned long addr)
 {
 	void *object;
 	struct kmem_cache_cpu *c;
 	struct page *page;
 	unsigned long tid;
 
-	s = slab_pre_alloc_hook(s, gfpflags);
+	s = slab_pre_alloc_hook(s, gfpflags, memcg);
 	if (!s)
 		return NULL;
 redo:
@@ -2727,15 +2728,15 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
 	return object;
 }
 
-static __always_inline void *slab_alloc(struct kmem_cache *s,
-		gfp_t gfpflags, unsigned long addr)
+static __always_inline void *slab_alloc(struct kmem_cache *s, gfp_t gfpflags,
+				struct mem_cgroup *memcg, unsigned long addr)
 {
-	return slab_alloc_node(s, gfpflags, NUMA_NO_NODE, addr);
+	return slab_alloc_node(s, gfpflags, NUMA_NO_NODE, memcg, addr);
 }
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
-	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
+	void *ret = slab_alloc(s, gfpflags, NULL, _RET_IP_);
 
 	trace_kmem_cache_alloc(_RET_IP_, ret, s->object_size,
 				s->size, gfpflags);
@@ -2744,21 +2745,44 @@ void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
+void *kmem_cache_alloc_memcg(struct kmem_cache *s, gfp_t gfpflags,
+			     struct mem_cgroup *memcg)
+{
+	void *ret = slab_alloc(s, gfpflags, memcg, _RET_IP_);
+
+	trace_kmem_cache_alloc(_RET_IP_, ret, s->object_size,
+				s->size, gfpflags);
+
+	return ret;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_memcg);
+
 #ifdef CONFIG_TRACING
 void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
 {
-	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
+	void *ret = slab_alloc(s, gfpflags, NULL, _RET_IP_);
 	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
 	kasan_kmalloc(s, ret, size, gfpflags);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_trace);
+
+void *kmem_cache_alloc_memcg_trace(struct kmem_cache *s, gfp_t gfpflags,
+				   size_t size, struct mem_cgroup *memcg)
+{
+	void *ret = slab_alloc(s, gfpflags, memcg, _RET_IP_);
+
+	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
+	kasan_kmalloc(s, ret, size, gfpflags);
+	return ret;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_memcg_trace);
 #endif
 
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
 {
-	void *ret = slab_alloc_node(s, gfpflags, node, _RET_IP_);
+	void *ret = slab_alloc_node(s, gfpflags, node, NULL, _RET_IP_);
 
 	trace_kmem_cache_alloc_node(_RET_IP_, ret,
 				    s->object_size, s->size, gfpflags, node);
@@ -2767,12 +2791,24 @@ void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 
+void *kmem_cache_alloc_node_memcg(struct kmem_cache *s, gfp_t gfpflags,
+				  int node, struct mem_cgroup *memcg)
+{
+	void *ret = slab_alloc_node(s, gfpflags, node, memcg, _RET_IP_);
+
+	trace_kmem_cache_alloc_node(_RET_IP_, ret,
+				    s->object_size, s->size, gfpflags, node);
+
+	return ret;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_node_memcg);
+
 #ifdef CONFIG_TRACING
 void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 				    gfp_t gfpflags,
 				    int node, size_t size)
 {
-	void *ret = slab_alloc_node(s, gfpflags, node, _RET_IP_);
+	void *ret = slab_alloc_node(s, gfpflags, node, NULL, _RET_IP_);
 
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, s->size, gfpflags, node);
@@ -2781,6 +2817,19 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
+
+void *kmem_cache_alloc_node_memcg_trace(struct kmem_cache *s, gfp_t gfpflags,
+				int node, size_t size, struct mem_cgroup *memcg)
+{
+	void *ret = slab_alloc_node(s, gfpflags, node, memcg, _RET_IP_);
+
+	trace_kmalloc_node(_RET_IP_, ret,
+			   size, s->size, gfpflags, node);
+
+	kasan_kmalloc(s, ret, size, gfpflags);
+	return ret;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_node_memcg_trace);
 #endif
 #endif
 
@@ -3109,7 +3158,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	int i;
 
 	/* memcg and kmem_cache debug support */
-	s = slab_pre_alloc_hook(s, flags);
+	s = slab_pre_alloc_hook(s, flags, NULL);
 	if (unlikely(!s))
 		return false;
 	/*
@@ -3755,7 +3804,7 @@ void *__kmalloc(size_t size, gfp_t flags)
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc(s, flags, _RET_IP_);
+	ret = slab_alloc(s, flags, NULL, _RET_IP_);
 
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
@@ -3800,7 +3849,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc_node(s, flags, node, _RET_IP_);
+	ret = slab_alloc_node(s, flags, node, NULL, _RET_IP_);
 
 	trace_kmalloc_node(_RET_IP_, ret, size, s->size, flags, node);
 
@@ -4305,7 +4354,7 @@ void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, unsigned long caller)
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc(s, gfpflags, caller);
+	ret = slab_alloc(s, gfpflags, NULL, caller);
 
 	/* Honor the call site pointer we received. */
 	trace_kmalloc(caller, ret, size, s->size, gfpflags);
@@ -4335,7 +4384,7 @@ void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc_node(s, gfpflags, node, caller);
+	ret = slab_alloc_node(s, gfpflags, node, NULL, caller);
 
 	/* Honor the call site pointer we received. */
 	trace_kmalloc_node(caller, ret, size, s->size, gfpflags, node);
-- 
2.16.1.291.g4437f3f132-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
