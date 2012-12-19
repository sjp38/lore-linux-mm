Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id BF7EC6B005D
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 09:03:10 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 2/3] slub: remove slab_alloc wrapper
Date: Wed, 19 Dec 2012 18:01:41 +0400
Message-Id: <1355925702-7537-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1355925702-7537-1-git-send-email-glommer@parallels.com>
References: <1355925702-7537-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>

Being slab_alloc such a simple and unconditional wrapper around
slab_alloc_node, we should get rid of it for simplicity, patching
the callers directly.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: David Rientjes <rientjes@google.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slub.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ba2ca53..b72569c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2389,15 +2389,9 @@ redo:
 	return object;
 }
 
-static __always_inline void *slab_alloc(struct kmem_cache *s,
-		gfp_t gfpflags, unsigned long addr)
-{
-	return slab_alloc_node(s, gfpflags, NUMA_NO_NODE, addr);
-}
-
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
-	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
+	void *ret = slab_alloc_node(s, gfpflags, NUMA_NO_NODE, _RET_IP_);
 
 	trace_kmem_cache_alloc(_RET_IP_, ret, s->object_size, s->size, gfpflags);
 
@@ -2408,7 +2402,7 @@ EXPORT_SYMBOL(kmem_cache_alloc);
 #ifdef CONFIG_TRACING
 void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
 {
-	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
+	void *ret = slab_alloc_node(s, gfpflags, NUMA_NO_NODE, _RET_IP_);
 	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
 	return ret;
 }
@@ -3288,7 +3282,7 @@ void *__kmalloc(size_t size, gfp_t flags)
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc(s, flags, _RET_IP_);
+	ret = slab_alloc_node(s, flags, NUMA_NO_NODE, _RET_IP_);
 
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
@@ -3938,7 +3932,7 @@ void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, unsigned long caller)
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc(s, gfpflags, caller);
+	ret = slab_alloc_node(s, gfpflags, NUMA_NO_NODE, caller);
 
 	/* Honor the call site pointer we received. */
 	trace_kmalloc(caller, ret, size, s->size, gfpflags);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
