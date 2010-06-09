Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 62D856B01D4
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 02:49:10 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o596n75S006001
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 23:49:07 -0700
Received: from pzk8 (pzk8.prod.google.com [10.243.19.136])
	by hpaq12.eem.corp.google.com with ESMTP id o596n533029534
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 23:49:06 -0700
Received: by pzk8 with SMTP id 8so935531pzk.12
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 23:49:05 -0700 (PDT)
Date: Tue, 8 Jun 2010 23:49:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/4] slub: replace SLAB_NODE_UNSPECIFIED with NUMA_NO_NODE
Message-ID: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

NUMA_NO_NODE is used in generic kernel code to define the constant -1,
which means that no specific node is actually required.

Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/slab.h |    2 --
 mm/slub.c            |   10 +++++-----
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -92,8 +92,6 @@
 #define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <= \
 				(unsigned long)ZERO_SIZE_PTR)
 
-#define SLAB_NODE_UNSPECIFIED (-1L)
-
 /*
  * struct kmem_cache related prototypes
  */
diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1092,7 +1092,7 @@ static inline struct page *alloc_slab_page(gfp_t flags, int node,
 
 	flags |= __GFP_NOTRACK;
 
-	if (node == SLAB_NODE_UNSPECIFIED)
+	if (node == NUMA_NO_NODE)
 		return alloc_pages(flags, order);
 	else
 		return alloc_pages_node(node, flags, order);
@@ -1743,7 +1743,7 @@ static __always_inline void *slab_alloc(struct kmem_cache *s,
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
-	void *ret = slab_alloc(s, gfpflags, SLAB_NODE_UNSPECIFIED, _RET_IP_);
+	void *ret = slab_alloc(s, gfpflags, NUMA_NO_NODE, _RET_IP_);
 
 	trace_kmem_cache_alloc(_RET_IP_, ret, s->objsize, s->size, gfpflags);
 
@@ -1754,7 +1754,7 @@ EXPORT_SYMBOL(kmem_cache_alloc);
 #ifdef CONFIG_TRACING
 void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
 {
-	return slab_alloc(s, gfpflags, SLAB_NODE_UNSPECIFIED, _RET_IP_);
+	return slab_alloc(s, gfpflags, NUMA_NO_NODE, _RET_IP_);
 }
 EXPORT_SYMBOL(kmem_cache_alloc_notrace);
 #endif
@@ -2758,7 +2758,7 @@ void *__kmalloc(size_t size, gfp_t flags)
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc(s, flags, SLAB_NODE_UNSPECIFIED, _RET_IP_);
+	ret = slab_alloc(s, flags, NUMA_NO_NODE, _RET_IP_);
 
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
@@ -3342,7 +3342,7 @@ void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, unsigned long caller)
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc(s, gfpflags, SLAB_NODE_UNSPECIFIED, caller);
+	ret = slab_alloc(s, gfpflags, NUMA_NO_NODE, caller);
 
 	/* Honor the call site pointer we recieved. */
 	trace_kmalloc(caller, ret, size, s->size, gfpflags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
