Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD6966B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 16:52:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x17so10022735pfn.10
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:52:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f7sor2484872pga.98.2018.04.16.13.52.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 13:52:08 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v5 1/2] mm: memcg: remote memcg charging for kmem allocations
Date: Mon, 16 Apr 2018 13:51:49 -0700
Message-Id: <20180416205150.113915-2-shakeelb@google.com>
In-Reply-To: <20180416205150.113915-1-shakeelb@google.com>
References: <20180416205150.113915-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>

Introduce the memcg variant for kmalloc[_node] and
kmem_cache_alloc[_node].  For kmem_cache_alloc, the kernel switches the
root kmem cache with the memcg specific kmem cache for __GFP_ACCOUNT
allocations to charge those allocations to the memcg.  However, the memcg
to charge is extracted from the current task_struct.  This patch
introduces the variant of kmem cache allocation functions where the memcg
can be provided explicitly by the caller instead of deducing the memcg
from the current task.

The kmalloc allocations are underlying served using the kmem caches unless
the size of the allocation request is larger than KMALLOC_MAX_CACHE_SIZE,
in which case, the kmem caches are bypassed and the request is routed
directly to page allocator.  So, for __GFP_ACCOUNT kmalloc allocations,
the memcg of current task is charged.  This patch introduces memcg variant
of kmalloc functions to allow callers to provide memcg for charging.

These functions are useful for use-cases where the allocations should be
charged to the memcg different from the memcg of the caller.  One such
concrete use-case is the allocations for fsnotify event objects where the
objects should be charged to the listener instead of the producer.

One requirement to call these functions is that the caller must have the
reference to the memcg.  Using kmalloc_memcg and kmem_cache_alloc_memcg
implicitly assumes that the caller is requesting a __GFP_ACCOUNT
allocation.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
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
 include/linux/sched/mm.h | 24 ++++++++++++++++
 include/linux/slab.h     | 59 ++++++++++++++++++++++++++++++++++++++++
 kernel/fork.c            |  3 ++
 mm/memcontrol.c          | 18 ++++++++++--
 5 files changed, 105 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index b3d697f3b573..d0b8c3ee717b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1097,6 +1097,9 @@ struct task_struct {
 
 	/* Number of pages to reclaim on returning to userland: */
 	unsigned int			memcg_nr_pages_over_high;
+
+	/* Used by memcontrol for targeted memcg charge: */
+	struct mem_cgroup		*target_memcg;
 #endif
 
 #ifdef CONFIG_UPROBES
diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
index 2c570cd934af..333f620a4634 100644
--- a/include/linux/sched/mm.h
+++ b/include/linux/sched/mm.h
@@ -206,6 +206,30 @@ static inline void memalloc_noreclaim_restore(unsigned int flags)
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
index 81ebd71f8c03..9ebe659bd4a5 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -15,6 +15,7 @@
 #include <linux/gfp.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
+#include <linux/sched/mm.h>
 
 
 /*
@@ -374,6 +375,21 @@ static __always_inline void kfree_bulk(size_t size, void **p)
 	kmem_cache_free_bulk(NULL, size, p);
 }
 
+/*
+ * Calling kmem_cache_alloc_memcg implicitly assumes that the caller
+ * wants a __GFP_ACCOUNT allocation.
+ */
+static __always_inline void *kmem_cache_alloc_memcg(struct kmem_cache *cachep,
+						    gfp_t flags,
+						    struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *old_memcg = memalloc_memcg_save(memcg);
+	void *ptr = kmem_cache_alloc(cachep, flags | __GFP_ACCOUNT);
+
+	memalloc_memcg_restore(old_memcg);
+	return ptr;
+}
+
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node) __assume_kmalloc_alignment __malloc;
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node) __assume_slab_alignment __malloc;
@@ -389,6 +405,21 @@ static __always_inline void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t f
 }
 #endif
 
+/*
+ * Calling kmem_cache_alloc_node_memcg implicitly assumes that the caller
+ * wants a __GFP_ACCOUNT allocation.
+ */
+static __always_inline void *
+kmem_cache_alloc_node_memcg(struct kmem_cache *cachep, gfp_t flags, int node,
+			    struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *old_memcg = memalloc_memcg_save(memcg);
+	void *ptr = kmem_cache_alloc_node(cachep, flags | __GFP_ACCOUNT, node);
+
+	memalloc_memcg_restore(old_memcg);
+	return ptr;
+}
+
 #ifdef CONFIG_TRACING
 extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t, size_t) __assume_slab_alignment __malloc;
 
@@ -517,6 +548,20 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
 	return __kmalloc(size, flags);
 }
 
+/*
+ * Calling kmalloc_memcg implicitly assumes that the caller wants a
+ * __GFP_ACCOUNT allocation.
+ */
+static __always_inline void *kmalloc_memcg(size_t size, gfp_t flags,
+					   struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *old_memcg = memalloc_memcg_save(memcg);
+	void *ptr = kmalloc(size, flags | __GFP_ACCOUNT);
+
+	memalloc_memcg_restore(old_memcg);
+	return ptr;
+}
+
 /*
  * Determine size used for the nth kmalloc cache.
  * return size or 0 if a kmalloc cache for that
@@ -554,6 +599,20 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 	return __kmalloc_node(size, flags, node);
 }
 
+/*
+ * Calling kmalloc_node_memcg implicitly assumes that the caller wants a
+ * __GFP_ACCOUNT allocation.
+ */
+static __always_inline void *
+kmalloc_node_memcg(size_t size, gfp_t flags, int node, struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *old_memcg = memalloc_memcg_save(memcg);
+	void *ptr = kmalloc_node(size, flags | __GFP_ACCOUNT, node);
+
+	memalloc_memcg_restore(old_memcg);
+	return ptr;
+}
+
 struct memcg_cache_array {
 	struct rcu_head rcu;
 	struct kmem_cache *entries[0];
diff --git a/kernel/fork.c b/kernel/fork.c
index ff0e0477c1bb..b1d877f1a0ac 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -835,6 +835,9 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	tsk->fail_nth = 0;
 #endif
 
+#ifdef CONFIG_MEMCG
+	tsk->target_memcg = NULL;
+#endif
 	return tsk;
 
 free_stack:
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d455bc08eb55..2c5f6b8819d9 100644
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
2.17.0.484.g0c8726318c-goog
