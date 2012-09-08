Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id A82B66B00A7
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 16:50:21 -0400 (EDT)
Received: by mail-gh0-f169.google.com with SMTP id r18so248154ghr.14
        for <linux-mm@kvack.org>; Sat, 08 Sep 2012 13:50:21 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH 09/10] mm, slub: Rename slab_alloc() -> slab_alloc_node() to match SLAB
Date: Sat,  8 Sep 2012 17:47:58 -0300
Message-Id: <1347137279-17568-9-git-send-email-elezegarcia@gmail.com>
In-Reply-To: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Christoph Lameter <cl@linux.com>

This patch does not fix anything, and its only goal is to enable us
to obtain some common code between SLAB and SLUB.
Neither behavior nor produced code is affected.

Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 mm/slub.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index c67bd0a..786a181 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2311,7 +2311,7 @@ new_slab:
  *
  * Otherwise we can simply pick the next object from the lockless free list.
  */
-static __always_inline void *slab_alloc(struct kmem_cache *s,
+static __always_inline void *slab_alloc_node(struct kmem_cache *s,
 		gfp_t gfpflags, int node, unsigned long addr)
 {
 	void **object;
@@ -2381,9 +2381,15 @@ redo:
 	return object;
 }
 
+static __always_inline void *slab_alloc(struct kmem_cache *s,
+		gfp_t gfpflags, unsigned long addr)
+{
+	return slab_alloc_node(s, gfpflags, NUMA_NO_NODE, addr);
+}
+
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
-	void *ret = slab_alloc(s, gfpflags, NUMA_NO_NODE, _RET_IP_);
+	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
 
 	trace_kmem_cache_alloc(_RET_IP_, ret, s->object_size, s->size, gfpflags);
 
@@ -2394,7 +2400,7 @@ EXPORT_SYMBOL(kmem_cache_alloc);
 #ifdef CONFIG_TRACING
 void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
 {
-	void *ret = slab_alloc(s, gfpflags, NUMA_NO_NODE, _RET_IP_);
+	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
 	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
 	return ret;
 }
@@ -2412,7 +2418,7 @@ EXPORT_SYMBOL(kmalloc_order_trace);
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
 {
-	void *ret = slab_alloc(s, gfpflags, node, _RET_IP_);
+	void *ret = slab_alloc_node(s, gfpflags, node, _RET_IP_);
 
 	trace_kmem_cache_alloc_node(_RET_IP_, ret,
 				    s->object_size, s->size, gfpflags, node);
@@ -2426,7 +2432,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 				    gfp_t gfpflags,
 				    int node, size_t size)
 {
-	void *ret = slab_alloc(s, gfpflags, node, _RET_IP_);
+	void *ret = slab_alloc_node(s, gfpflags, node, _RET_IP_);
 
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, s->size, gfpflags, node);
@@ -3364,7 +3370,7 @@ void *__kmalloc(size_t size, gfp_t flags)
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc(s, flags, NUMA_NO_NODE, _RET_IP_);
+	ret = slab_alloc(s, flags, _RET_IP_);
 
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
@@ -3407,7 +3413,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc(s, flags, node, _RET_IP_);
+	ret = slab_alloc_node(s, flags, node, _RET_IP_);
 
 	trace_kmalloc_node(_RET_IP_, ret, size, s->size, flags, node);
 
@@ -4035,7 +4041,7 @@ void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, unsigned long caller)
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc(s, gfpflags, NUMA_NO_NODE, caller);
+	ret = slab_alloc(s, gfpflags, caller);
 
 	/* Honor the call site pointer we received. */
 	trace_kmalloc(caller, ret, size, s->size, gfpflags);
@@ -4065,7 +4071,7 @@ void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc(s, gfpflags, node, caller);
+	ret = slab_alloc_node(s, gfpflags, node, caller);
 
 	/* Honor the call site pointer we received. */
 	trace_kmalloc_node(caller, ret, size, s->size, gfpflags, node);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
