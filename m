Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 893B96B000E
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 01:13:45 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id c6-v6so11421976pll.4
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 22:13:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s11-v6sor2926434pgv.34.2018.06.18.22.13.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Jun 2018 22:13:44 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH 1/3] mm: memcg: remote memcg charging for kmem allocations
Date: Mon, 18 Jun 2018 22:13:25 -0700
Message-Id: <20180619051327.149716-2-shakeelb@google.com>
In-Reply-To: <20180619051327.149716-1-shakeelb@google.com>
References: <20180619051327.149716-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Shakeel Butt <shakeelb@google.com>, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>

Introduce the memcg variant for kmalloc[_node] and
kmem_cache_alloc[_node]. For kmem_cache_alloc, the kernel switches the
root kmem cache with the memcg specific kmem cache for __GFP_ACCOUNT
allocations to charge those allocations to the memcg. However, the memcg
to charge is extracted from the current task_struct. This patch
introduces the variant of kmem cache allocation functions where the memcg
can be provided explicitly by the caller instead of deducing the memcg
from the current task.

The kmalloc allocations are underlying served using the kmem caches unless
the size of the allocation request is larger than KMALLOC_MAX_CACHE_SIZE,
in which case, the kmem caches are bypassed and the request is routed
directly to page allocator. So, for __GFP_ACCOUNT kmalloc allocations,
the memcg of current task is charged. This patch introduces memcg variant
of kmalloc functions to allow callers to provide memcg for charging.

These functions are useful for use-cases where the allocations should be
charged to the memcg different from the memcg of the caller. One such
concrete use-case is the allocations for fsnotify event objects where the
objects should be charged to the listener instead of the producer.

One requirement to call these functions is that the caller must have the
reference to the memcg provided to these functions. If reference
acquition on the given memcg is failed (it can fail if memcg is offline)
then the current's memcg is tried. These functions implicitly assumes
that the caller wants a __GFP_ACCOUNT allocation.

This patch also introduces scope API for targeted memcg charging. All
the __GFP_ACCOUNT allocations between memalloc_memcg_save(target_memcg)
and memalloc_memcg_restore(old_memcg) will be charged to target_memcg.

Traditionally kmem charging is skipped for allocations by kthreads and
allocations during interrupts. The reason is that the current's memcg
might not be the right owner for such allocations. However targeted
memcg charging does not have such limitation and can work even for
allocations by kthreads and for allocations during interrupts. For now
due to lack of actual use-case, targeted memcg charging for such
allocations is not added. Though this might change in future.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Amir Goldstein <amir73il@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
Changelog sinve v5:
- Added more explanation in commit message.
- Added handling of NULL memcg for targeted memcg allocation functions.

Changelog since v4:
- Removed branch from hot path of memory charging.

Changelog since v3:
- Added node variant of directed kmem allocation functions.

Changelog since v2:
- Merge the kmalloc_memcg patch into this patch.
- Instead of plumbing memcg throughout, use field in task_struct to pass
  the target_memcg.

Changelog since v1:
- Fixed build for SLOB

 include/linux/sched.h    |  3 ++
 include/linux/sched/mm.h | 24 ++++++++++++
 include/linux/slab.h     | 83 ++++++++++++++++++++++++++++++++++++++++
 kernel/fork.c            |  3 ++
 mm/memcontrol.c          | 18 ++++++++-
 5 files changed, 129 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 87bf02d93a27..cbd0def60fd4 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1149,6 +1149,9 @@ struct task_struct {
 
 	/* Number of pages to reclaim on returning to userland: */
 	unsigned int			memcg_nr_pages_over_high;
+
+	/* Used by memcontrol for targeted memcg charge: */
+	struct mem_cgroup		*target_memcg;
 #endif
 
 #ifdef CONFIG_UPROBES
diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
index 44d356f5e47c..2ffb194f3f32 100644
--- a/include/linux/sched/mm.h
+++ b/include/linux/sched/mm.h
@@ -248,6 +248,30 @@ static inline void memalloc_noreclaim_restore(unsigned int flags)
 	current->flags = (current->flags & ~PF_MEMALLOC) | flags;
 }
 
+#ifdef CONFIG_MEMCG
+static inline struct mem_cgroup *memalloc_memcg_save(struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *old_memcg = current->target_memcg;
+
+	current->target_memcg = memcg;
+	return old_memcg;
+}
+
+static inline void memalloc_memcg_restore(struct mem_cgroup *memcg)
+{
+	current->target_memcg = memcg;
+}
+#else
+static inline struct mem_cgroup *memalloc_memcg_save(struct mem_cgroup *memcg)
+{
+	return NULL;
+}
+
+static inline void memalloc_memcg_restore(struct mem_cgroup *memcg)
+{
+}
+#endif /* CONFIG_MEMCG */
+
 #ifdef CONFIG_MEMBARRIER
 enum {
 	MEMBARRIER_STATE_PRIVATE_EXPEDITED_READY		= (1U << 0),
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 14e3fe4bd6a1..2f6319fa0d3d 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -16,6 +16,7 @@
 #include <linux/overflow.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
+#include <linux/sched/mm.h>
 
 
 /*
@@ -375,6 +376,27 @@ static __always_inline void kfree_bulk(size_t size, void **p)
 	kmem_cache_free_bulk(NULL, size, p);
 }
 
+/*
+ * Calling kmem_cache_alloc_memcg implicitly assumes that the caller wants
+ * a __GFP_ACCOUNT allocation. However if memcg is NULL then
+ * kmem_cache_alloc_memcg is same as kmem_cache_alloc.
+ */
+static __always_inline void *kmem_cache_alloc_memcg(struct kmem_cache *cachep,
+						    gfp_t flags,
+						    struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *old_memcg;
+	void *ptr;
+
+	if (!memcg)
+		return kmem_cache_alloc(cachep, flags);
+
+	old_memcg = memalloc_memcg_save(memcg);
+	ptr = kmem_cache_alloc(cachep, flags | __GFP_ACCOUNT);
+	memalloc_memcg_restore(old_memcg);
+	return ptr;
+}
+
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node) __assume_kmalloc_alignment __malloc;
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node) __assume_slab_alignment __malloc;
@@ -390,6 +412,27 @@ static __always_inline void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t f
 }
 #endif
 
+/*
+ * Calling kmem_cache_alloc_node_memcg implicitly assumes that the caller
+ * wants a __GFP_ACCOUNT allocation. However if memcg is NULL then
+ * kmem_cache_alloc_node_memcg is same as kmem_cache_alloc_node.
+ */
+static __always_inline void *
+kmem_cache_alloc_node_memcg(struct kmem_cache *cachep, gfp_t flags, int node,
+			    struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *old_memcg;
+	void *ptr;
+
+	if (!memcg)
+		return kmem_cache_alloc_node(cachep, flags, node);
+
+	old_memcg = memalloc_memcg_save(memcg);
+	ptr = kmem_cache_alloc_node(cachep, flags | __GFP_ACCOUNT, node);
+	memalloc_memcg_restore(old_memcg);
+	return ptr;
+}
+
 #ifdef CONFIG_TRACING
 extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t, size_t) __assume_slab_alignment __malloc;
 
@@ -518,6 +561,26 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
 	return __kmalloc(size, flags);
 }
 
+/*
+ * Calling kmalloc_memcg implicitly assumes that the caller wants a
+ * __GFP_ACCOUNT allocation. However if memcg is NULL then kmalloc_memcg
+ * is same as kmalloc.
+ */
+static __always_inline void *kmalloc_memcg(size_t size, gfp_t flags,
+					   struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *old_memcg;
+	void *ptr;
+
+	if (!memcg)
+		return kmalloc(size, flags);
+
+	old_memcg = memalloc_memcg_save(memcg);
+	ptr = kmalloc(size, flags | __GFP_ACCOUNT);
+	memalloc_memcg_restore(old_memcg);
+	return ptr;
+}
+
 /*
  * Determine size used for the nth kmalloc cache.
  * return size or 0 if a kmalloc cache for that
@@ -555,6 +618,26 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 	return __kmalloc_node(size, flags, node);
 }
 
+/*
+ * Calling kmalloc_node_memcg implicitly assumes that the caller wants a
+ * __GFP_ACCOUNT allocation. However if memcg is NULL then kmalloc_node_memcg
+ * is same as kmalloc_node.
+ */
+static __always_inline void *
+kmalloc_node_memcg(size_t size, gfp_t flags, int node, struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *old_memcg;
+	void *ptr;
+
+	if (!memcg)
+		return kmalloc_node(size, flags, node);
+
+	old_memcg = memalloc_memcg_save(memcg);
+	ptr = kmalloc_node(size, flags | __GFP_ACCOUNT, node);
+	memalloc_memcg_restore(old_memcg);
+	return ptr;
+}
+
 struct memcg_cache_array {
 	struct rcu_head rcu;
 	struct kmem_cache *entries[0];
diff --git a/kernel/fork.c b/kernel/fork.c
index a64d0a19f174..5bf300015790 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -843,6 +843,9 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	tsk->fail_nth = 0;
 #endif
 
+#ifdef CONFIG_MEMCG
+	tsk->target_memcg = NULL;
+#endif
 	return tsk;
 
 free_stack:
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 02e77c88967a..08bfb8c2411b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -701,6 +701,20 @@ static struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 	return memcg;
 }
 
+static __always_inline struct mem_cgroup *get_mem_cgroup(
+				struct mem_cgroup *memcg, struct mm_struct *mm)
+{
+	if (unlikely(memcg)) {
+		rcu_read_lock();
+		if (css_tryget_online(&memcg->css)) {
+			rcu_read_unlock();
+			return memcg;
+		}
+		rcu_read_unlock();
+	}
+	return get_mem_cgroup_from_mm(mm);
+}
+
 /**
  * mem_cgroup_iter - iterate over memory cgroup hierarchy
  * @root: hierarchy root
@@ -2260,7 +2274,7 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
 	if (current->memcg_kmem_skip_account)
 		return cachep;
 
-	memcg = get_mem_cgroup_from_mm(current->mm);
+	memcg = get_mem_cgroup(current->target_memcg, current->mm);
 	kmemcg_id = READ_ONCE(memcg->kmemcg_id);
 	if (kmemcg_id < 0)
 		goto out;
@@ -2344,7 +2358,7 @@ int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
 	if (memcg_kmem_bypass())
 		return 0;
 
-	memcg = get_mem_cgroup_from_mm(current->mm);
+	memcg = get_mem_cgroup(current->target_memcg, current->mm);
 	if (!mem_cgroup_is_root(memcg)) {
 		ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);
 		if (!ret)
-- 
2.18.0.rc1.244.gcf134e6275-goog
