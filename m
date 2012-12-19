Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 822F76B0068
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 09:03:15 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 1/3] slab: single entry-point for slab allocation
Date: Wed, 19 Dec 2012 18:01:40 +0400
Message-Id: <1355925702-7537-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1355925702-7537-1-git-send-email-glommer@parallels.com>
References: <1355925702-7537-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>

This patch modifies slab's slab_alloc so it becomes node-aware at
all times. The code sharing is already quite big. The main difference
is how to behave when nodeid is specified as -1.

This is always the case for the not node aware allocation entry point,
that would do unconditionally:

        if (unlikely(current->flags & (PF_SPREAD_SLAB | PF_MEMPOLICY)))
        {
                objp = alternate_node_alloc(cache, flags);
                if (objp)
                        goto out;
        }

meaning that it will allocate from the current node unless some
task flags are set, in which case we'll try to spread it around.

We can easily assume that any call to kmem_cache_alloc_node() that
passes -1 as node would not mind seeing this behavior. So what this
patch does is to add a check like that to the nodeid == -1 case of
slab_alloc_node, and then convert every caller to slab_alloc to
slab_alloc_node.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: David Rientjes <rientjes@google.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab.c | 88 +++++++++++++++------------------------------------------------
 1 file changed, 21 insertions(+), 67 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index e7667a3..a98295f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3475,33 +3475,23 @@ done:
  * Fallback to other node is possible if __GFP_THISNODE is not set.
  */
 static __always_inline void *
-slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
-		   unsigned long caller)
+__do_slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
-	unsigned long save_flags;
 	void *ptr;
 	int slab_node = numa_mem_id();
 
-	flags &= gfp_allowed_mask;
-
-	lockdep_trace_alloc(flags);
-
-	if (slab_should_failslab(cachep, flags))
-		return NULL;
-
-	cachep = memcg_kmem_get_cache(cachep, flags);
-
-	cache_alloc_debugcheck_before(cachep, flags);
-	local_irq_save(save_flags);
-
-	if (nodeid == NUMA_NO_NODE)
+	if (nodeid == NUMA_NO_NODE) {
+		if (unlikely(current->flags & (PF_SPREAD_SLAB | PF_MEMPOLICY))) {
+			ptr = alternate_node_alloc(cachep, flags);
+			if (ptr)
+				return ptr;
+		}
 		nodeid = slab_node;
+	}
 
-	if (unlikely(!cachep->nodelists[nodeid])) {
+	if (unlikely(!cachep->nodelists[nodeid]))
 		/* Node not bootstrapped yet */
-		ptr = fallback_alloc(cachep, flags);
-		goto out;
-	}
+		return fallback_alloc(cachep, flags);
 
 	if (nodeid == slab_node) {
 		/*
@@ -3512,59 +3502,23 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 		 */
 		ptr = ____cache_alloc(cachep, flags);
 		if (ptr)
-			goto out;
+			return ptr;
 	}
 	/* ___cache_alloc_node can fall back to other nodes */
-	ptr = ____cache_alloc_node(cachep, flags, nodeid);
-  out:
-	local_irq_restore(save_flags);
-	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
-	kmemleak_alloc_recursive(ptr, cachep->object_size, 1, cachep->flags,
-				 flags);
-
-	if (likely(ptr))
-		kmemcheck_slab_alloc(cachep, flags, ptr, cachep->object_size);
-
-	if (unlikely((flags & __GFP_ZERO) && ptr))
-		memset(ptr, 0, cachep->object_size);
-
-	return ptr;
-}
-
-static __always_inline void *
-__do_cache_alloc(struct kmem_cache *cache, gfp_t flags)
-{
-	void *objp;
-
-	if (unlikely(current->flags & (PF_SPREAD_SLAB | PF_MEMPOLICY))) {
-		objp = alternate_node_alloc(cache, flags);
-		if (objp)
-			goto out;
-	}
-	objp = ____cache_alloc(cache, flags);
-
-	/*
-	 * We may just have run out of memory on the local node.
-	 * ____cache_alloc_node() knows how to locate memory on other nodes
-	 */
-	if (!objp)
-		objp = ____cache_alloc_node(cache, flags, numa_mem_id());
-
-  out:
-	return objp;
+	return ____cache_alloc_node(cachep, flags, nodeid);
 }
 #else
-
 static __always_inline void *
-__do_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
+__do_slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
+
 	return ____cache_alloc(cachep, flags);
 }
-
 #endif /* CONFIG_NUMA */
 
 static __always_inline void *
-slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
+slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
+		unsigned long caller)
 {
 	unsigned long save_flags;
 	void *objp;
@@ -3580,11 +3534,11 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 
 	cache_alloc_debugcheck_before(cachep, flags);
 	local_irq_save(save_flags);
-	objp = __do_cache_alloc(cachep, flags);
+	objp = __do_slab_alloc_node(cachep, flags, nodeid);
 	local_irq_restore(save_flags);
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp, caller);
 	kmemleak_alloc_recursive(objp, cachep->object_size, 1, cachep->flags,
-				 flags);
+				flags);
 	prefetchw(objp);
 
 	if (likely(objp))
@@ -3742,7 +3696,7 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
  */
 void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
-	void *ret = slab_alloc(cachep, flags, _RET_IP_);
+	void *ret = slab_alloc_node(cachep, flags, NUMA_NO_NODE, _RET_IP_);
 
 	trace_kmem_cache_alloc(_RET_IP_, ret,
 			       cachep->object_size, cachep->size, flags);
@@ -3757,7 +3711,7 @@ kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
 {
 	void *ret;
 
-	ret = slab_alloc(cachep, flags, _RET_IP_);
+	ret = slab_alloc_node(cachep, flags, NUMA_NO_NODE, _RET_IP_);
 
 	trace_kmalloc(_RET_IP_, ret,
 		      size, cachep->size, flags);
@@ -3850,7 +3804,7 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 	cachep = __find_general_cachep(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
-	ret = slab_alloc(cachep, flags, caller);
+	ret = slab_alloc_node(cachep, flags, NUMA_NO_NODE, caller);
 
 	trace_kmalloc(caller, ret,
 		      size, cachep->size, flags);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
