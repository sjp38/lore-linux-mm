Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9648866001E
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:26 -0400 (EDT)
Message-Id: <20100804024525.562559967@linux.com>
Date: Tue, 03 Aug 2010 21:45:17 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 03/23] slub: Use a constant for a unspecified node.
References: <20100804024514.139976032@linux.com>
Content-Disposition: inline; filename=slab_node_unspecified
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

kmalloc_node() and friends can be passed a constant -1 to indicate
that no choice was made for the node from which the object needs to
come.

Use NUMA_NO_NODE instead of -1.

CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-26 12:57:52.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-07-26 12:57:59.000000000 -0500
@@ -1073,7 +1073,7 @@ static inline struct page *alloc_slab_pa
 
 	flags |= __GFP_NOTRACK;
 
-	if (node == -1)
+	if (node == NUMA_NO_NODE)
 		return alloc_pages(flags, order);
 	else
 		return alloc_pages_exact_node(node, flags, order);
@@ -1387,7 +1387,7 @@ static struct page *get_any_partial(stru
 static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
 {
 	struct page *page;
-	int searchnode = (node == -1) ? numa_node_id() : node;
+	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
 
 	page = get_partial_node(get_node(s, searchnode));
 	if (page || (flags & __GFP_THISNODE) || node != -1)
@@ -1515,7 +1515,7 @@ static void flush_all(struct kmem_cache 
 static inline int node_match(struct kmem_cache_cpu *c, int node)
 {
 #ifdef CONFIG_NUMA
-	if (node != -1 && c->node != node)
+	if (node != NUMA_NO_NODE && c->node != node)
 		return 0;
 #endif
 	return 1;
@@ -1727,7 +1727,7 @@ static __always_inline void *slab_alloc(
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
-	void *ret = slab_alloc(s, gfpflags, -1, _RET_IP_);
+	void *ret = slab_alloc(s, gfpflags, NUMA_NO_NODE, _RET_IP_);
 
 	trace_kmem_cache_alloc(_RET_IP_, ret, s->objsize, s->size, gfpflags);
 
@@ -1738,7 +1738,7 @@ EXPORT_SYMBOL(kmem_cache_alloc);
 #ifdef CONFIG_TRACING
 void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
 {
-	return slab_alloc(s, gfpflags, -1, _RET_IP_);
+	return slab_alloc(s, gfpflags, NUMA_NO_NODE, _RET_IP_);
 }
 EXPORT_SYMBOL(kmem_cache_alloc_notrace);
 #endif
@@ -2728,7 +2728,7 @@ void *__kmalloc(size_t size, gfp_t flags
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc(s, flags, -1, _RET_IP_);
+	ret = slab_alloc(s, flags, NUMA_NO_NODE, _RET_IP_);
 
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
@@ -3312,7 +3312,7 @@ void *__kmalloc_track_caller(size_t size
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc(s, gfpflags, -1, caller);
+	ret = slab_alloc(s, gfpflags, NUMA_NO_NODE, caller);
 
 	/* Honor the call site pointer we recieved. */
 	trace_kmalloc(caller, ret, size, s->size, gfpflags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
