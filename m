Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BEAFF6B0012
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 13:30:36 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id w9so5375410pfl.2
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 10:30:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x4sor3511216pfb.28.2018.03.05.10.30.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 10:30:34 -0800 (PST)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v4 1/2] mm: memcg: remote memcg charging for kmem allocations
Date: Mon,  5 Mar 2018 10:29:50 -0800
Message-Id: <20180305182951.34462-2-shakeelb@google.com>
In-Reply-To: <20180305182951.34462-1-shakeelb@google.com>
References: <20180305182951.34462-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

Introducing the memcg variant for kmalloc[_node] and
kmem_cache_alloc[_node]. For kmem_cache_alloc, the kernel switches the
root kmem cache with the memcg specific kmem cache for __GFP_ACCOUNT
allocations to charge those allocations to the memcg. However, the
memcg to charge is extracted from the current task_struct. This patch
introduces the variant of kmem cache allocation functions where the
memcg can be provided explicitly by the caller instead of deducing the
memcg from the current task.

The kmalloc allocations are underlying served using the kmem caches
unless the size of the allocation request is larger than
KMALLOC_MAX_CACHE_SIZE, in which case, the kmem caches are bypassed and
the request is routed directly to page allocator. So, for __GFP_ACCOUNT
kmalloc allocations, the memcg of current task is charged. This patch
introduces memcg variant of kmalloc functions to allow callers to
provide memcg for charging.

These functions are useful for use-cases where the allocations should be
charged to the memcg different from the memcg of the caller. One such
concrete use-case is the allocations for fsnotify event objects where
the objects should be charged to the listener instead of the producer.

One requirement to call these functions is that the caller must have the
reference to the memcg. Using kmalloc_memcg and kmem_cache_alloc_memcg
implicitly assumes that the caller is requesting a __GFP_ACCOUNT
allocation.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
Changelog since v3:
- Added node variant of directed kmem allocation functions.

Changelog since v2:
- Merge the kmalloc_memcg patch into this patch.
- Instead of plumbing memcg throughout, use field in task_struct to pass
  the target_memcg.

Changelog since v1:
- Fixed build for SLOB

 include/linux/sched.h    |  3 ++
 include/linux/sched/mm.h | 23 ++++++++++++++++
 include/linux/slab.h     | 59 ++++++++++++++++++++++++++++++++++++++++
 kernel/fork.c            |  3 ++
 mm/memcontrol.c          | 23 +++++++++++++---
 5 files changed, 107 insertions(+), 4 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index b161ef8a902e..847cb94fead7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1069,6 +1069,9 @@ struct task_struct {
 
 	/* Number of pages to reclaim on returning to userland: */
 	unsigned int			memcg_nr_pages_over_high;
+
+	/* Used by memcontrol for targeted memcg charge: */
+	struct mem_cgroup		*target_memcg;
 #endif
 
 #ifdef CONFIG_UPROBES
diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
index 2c570cd934af..c9255cbd94d3 100644
--- a/include/linux/sched/mm.h
+++ b/include/linux/sched/mm.h
@@ -206,6 +206,29 @@ static inline void memalloc_noreclaim_restore(unsigned int flags)
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
index 508aa9b596b3..70b6f540588f 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -15,6 +15,7 @@
 #include <linux/gfp.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
+#include <linux/sched/mm.h>
 
 
 /*
@@ -373,6 +374,21 @@ static __always_inline void kfree_bulk(size_t size, void **p)
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
@@ -388,6 +404,21 @@ static __always_inline void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t f
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
 
@@ -516,6 +547,20 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
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
@@ -553,6 +598,20 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
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
index 833941a06e41..a32e1c4311b2 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -833,6 +833,9 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	tsk->fail_nth = 0;
 #endif
 
+#ifdef CONFIG_MEMCG
+	tsk->target_memcg = NULL;
+#endif
 	return tsk;
 
 free_stack:
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index afdb35cf4d0e..5a2acfbc4962 100644
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
@@ -2248,7 +2257,7 @@ static inline bool memcg_kmem_bypass(void)
  */
 struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
 {
-	struct mem_cgroup *memcg;
+	struct mem_cgroup *memcg = NULL;
 	struct kmem_cache *memcg_cachep;
 	int kmemcg_id;
 
@@ -2260,7 +2269,10 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
 	if (current->memcg_kmem_skip_account)
 		return cachep;
 
-	memcg = get_mem_cgroup_from_mm(current->mm);
+	if (current->target_memcg)
+		memcg = get_mem_cgroup(current->target_memcg);
+	if (!memcg)
+		memcg = get_mem_cgroup_from_mm(current->mm);
 	kmemcg_id = READ_ONCE(memcg->kmemcg_id);
 	if (kmemcg_id < 0)
 		goto out;
@@ -2338,13 +2350,16 @@ int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
  */
 int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
 {
-	struct mem_cgroup *memcg;
+	struct mem_cgroup *memcg = NULL;
 	int ret = 0;
 
 	if (memcg_kmem_bypass())
 		return 0;
 
-	memcg = get_mem_cgroup_from_mm(current->mm);
+	if (current->target_memcg)
+		memcg = get_mem_cgroup(current->target_memcg);
+	if (!memcg)
+		memcg = get_mem_cgroup_from_mm(current->mm);
 	if (!mem_cgroup_is_root(memcg)) {
 		ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);
 		if (!ret)
-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
