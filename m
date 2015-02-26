Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id BE37F6B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 19:23:53 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id hn18so10574866igb.2
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:23:53 -0800 (PST)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com. [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id u2si169097igm.46.2015.02.25.16.23.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 16:23:53 -0800 (PST)
Received: by iecrd18 with SMTP id rd18so9802266iec.5
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:23:53 -0800 (PST)
Date: Wed, 25 Feb 2015 16:23:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/2] mm: remove GFP_THISNODE
Message-ID: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, dev@openvswitch.org

NOTE: this is not about __GFP_THISNODE, this is only about GFP_THISNODE.

GFP_THISNODE is a secret combination of gfp bits that have different
behavior than expected.  It is a combination of __GFP_THISNODE,
__GFP_NORETRY, and __GFP_NOWARN and is special-cased in the page allocator
slowpath to fail without trying reclaim even though it may be used in
combination with __GFP_WAIT.

An example of the problem this creates: commit e97ca8e5b864 ("mm: fix 
GFP_THISNODE callers and clarify") fixed up many users of GFP_THISNODE
that really just wanted __GFP_THISNODE.  The problem doesn't end there,
however, because even it was a no-op for alloc_misplaced_dst_page(),
which also sets __GFP_NORETRY and __GFP_NOWARN, and
migrate_misplaced_transhuge_page(), where __GFP_NORETRY and __GFP_NOWAIT
is set in GFP_TRANSHUGE.  Converting GFP_THISNODE to __GFP_THISNODE is
a no-op in these cases since the page allocator special-cases
__GFP_THISNODE && __GFP_NORETRY && __GFP_NOWARN.

It's time to just remove GFP_TRANSHUGE entirely.  We leave __GFP_THISNODE
to restrict an allocation to a local node, but remove GFP_TRANSHUGE and
it's obscurity.  Instead, we require that a caller clear __GFP_WAIT if it
wants to avoid reclaim.

This allows the aforementioned functions to actually reclaim as they
should.  It also enables any future callers that want to do
__GFP_THISNODE but also __GFP_NORETRY && __GFP_NOWARN to reclaim.  The
rule is simple: if you don't want to reclaim, then don't set __GFP_WAIT.

Aside: ovs_flow_stats_update() really wants to avoid reclaim as well, so
it is unchanged.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/gfp.h    | 10 ----------
 mm/page_alloc.c        | 22 ++++++----------------
 mm/slab.c              | 22 ++++++++++++++++++----
 net/openvswitch/flow.c |  4 +++-
 4 files changed, 27 insertions(+), 31 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -117,16 +117,6 @@ struct vm_area_struct;
 			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN | \
 			 __GFP_NO_KSWAPD)
 
-/*
- * GFP_THISNODE does not perform any reclaim, you most likely want to
- * use __GFP_THISNODE to allocate from a given node without fallback!
- */
-#ifdef CONFIG_NUMA
-#define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
-#else
-#define GFP_THISNODE	((__force gfp_t)0)
-#endif
-
 /* This mask makes up all the page movable related flags */
 #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2355,13 +2355,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		/* The OOM killer does not compensate for light reclaim */
 		if (!(gfp_mask & __GFP_FS))
 			goto out;
-		/*
-		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
-		 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.
-		 * The caller should handle page allocation failure by itself if
-		 * it specifies __GFP_THISNODE.
-		 * Note: Hugepage uses it but will hit PAGE_ALLOC_COSTLY_ORDER.
-		 */
+		/* The OOM killer may not free memory on a specific node */
 		if (gfp_mask & __GFP_THISNODE)
 			goto out;
 	}
@@ -2615,15 +2609,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	}
 
 	/*
-	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
-	 * __GFP_NOWARN set) should not cause reclaim since the subsystem
-	 * (f.e. slab) using GFP_THISNODE may choose to trigger reclaim
-	 * using a larger set of nodes after it has established that the
-	 * allowed per node queues are empty and that nodes are
-	 * over allocated.
+	 * If this allocation cannot block and it is for a specific node, then
+	 * fail early.  There's no need to wakeup kswapd or retry for a
+	 * speculative node-specific allocation.
 	 */
-	if (IS_ENABLED(CONFIG_NUMA) &&
-	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
+	if (IS_ENABLED(CONFIG_NUMA) && (gfp_mask & __GFP_THISNODE) && !wait)
 		goto nopage;
 
 retry:
@@ -2816,7 +2806,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	/*
 	 * Check the zones suitable for the gfp_mask contain at least one
 	 * valid zone. It's possible to have an empty zonelist as a result
-	 * of GFP_THISNODE and a memoryless node
+	 * of __GFP_THISNODE and a memoryless node
 	 */
 	if (unlikely(!zonelist->_zonerefs->zone))
 		return NULL;
diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -857,6 +857,11 @@ static inline void *____cache_alloc_node(struct kmem_cache *cachep,
 	return NULL;
 }
 
+static inline gfp_t gfp_exact_node(gfp_t flags)
+{
+	return flags;
+}
+
 #else	/* CONFIG_NUMA */
 
 static void *____cache_alloc_node(struct kmem_cache *, gfp_t, int);
@@ -1023,6 +1028,15 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 
 	return __cache_free_alien(cachep, objp, node, page_node);
 }
+
+/*
+ * Construct gfp mask to allocate from a specific node but do not invoke reclaim
+ * or warn about failures.
+ */
+static inline gfp_t gfp_exact_node(gfp_t flags)
+{
+	return (flags | __GFP_THISNODE | __GFP_NOWARN) & ~__GFP_WAIT;
+}
 #endif
 
 /*
@@ -2825,7 +2839,7 @@ alloc_done:
 	if (unlikely(!ac->avail)) {
 		int x;
 force_grow:
-		x = cache_grow(cachep, flags | GFP_THISNODE, node, NULL);
+		x = cache_grow(cachep, gfp_exact_node(flags), node, NULL);
 
 		/* cache_grow can reenable interrupts, then ac could change. */
 		ac = cpu_cache_get(cachep);
@@ -3019,7 +3033,7 @@ retry:
 			get_node(cache, nid) &&
 			get_node(cache, nid)->free_objects) {
 				obj = ____cache_alloc_node(cache,
-					flags | GFP_THISNODE, nid);
+					gfp_exact_node(flags), nid);
 				if (obj)
 					break;
 		}
@@ -3047,7 +3061,7 @@ retry:
 			nid = page_to_nid(page);
 			if (cache_grow(cache, flags, nid, page)) {
 				obj = ____cache_alloc_node(cache,
-					flags | GFP_THISNODE, nid);
+					gfp_exact_node(flags), nid);
 				if (!obj)
 					/*
 					 * Another processor may allocate the
@@ -3118,7 +3132,7 @@ retry:
 
 must_grow:
 	spin_unlock(&n->list_lock);
-	x = cache_grow(cachep, flags | GFP_THISNODE, nodeid, NULL);
+	x = cache_grow(cachep, gfp_exact_node(flags), nodeid, NULL);
 	if (x)
 		goto retry;
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -100,7 +100,9 @@ void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
 
 				new_stats =
 					kmem_cache_alloc_node(flow_stats_cache,
-							      GFP_THISNODE |
+							      GFP_NOWAIT |
+							      __GFP_THISNODE |
+							      __GFP_NOWARN |
 							      __GFP_NOMEMALLOC,
 							      node);
 				if (likely(new_stats)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
