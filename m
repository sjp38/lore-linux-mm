Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 33DE7900148
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 16:47:45 -0400 (EDT)
Message-Id: <20110902204743.216103408@linux.com>
Date: Fri, 02 Sep 2011 15:47:04 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub rfc1 07/12] slub: pass page to node_match() instead of kmem_cache_cpu structure
References: <20110902204657.105194589@linux.com>
Content-Disposition: inline; filename=page_parameter_to_node_match
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, linux-mm@kvack.org

The page field will go away and so its more convenient to pass the
page struct to kmem_cache_cpu instead.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-09-02 08:20:39.221219372 -0500
+++ linux-2.6/mm/slub.c	2011-09-02 08:20:45.611219333 -0500
@@ -1951,10 +1951,10 @@ static void flush_all(struct kmem_cache
  * Check if the objects in a per cpu structure fit numa
  * locality expectations.
  */
-static inline int node_match(struct kmem_cache_cpu *c, int node)
+static inline int node_match(struct page *page, int node)
 {
 #ifdef CONFIG_NUMA
-	if (node != NUMA_NO_NODE && page_to_nid(c->page) != node)
+	if (node != NUMA_NO_NODE && page_to_nid(page) != node)
 		return 0;
 #endif
 	return 1;
@@ -2095,7 +2095,7 @@ static void *__slab_alloc(struct kmem_ca
 		goto new_slab;
 
 
-	if (unlikely(!node_match(c, node))) {
+	if (unlikely(!node_match(page, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
 		deactivate_slab(s, page, freelist);
 		c->page = NULL;
@@ -2189,6 +2189,7 @@ static __always_inline void *slab_alloc(
 {
 	void **object;
 	struct kmem_cache_cpu *c;
+	struct page *page;
 	unsigned long tid;
 
 	if (slab_pre_alloc_hook(s, gfpflags))
@@ -2214,7 +2215,8 @@ redo:
 	barrier();
 
 	object = c->freelist;
-	if (unlikely(!object || !node_match(c, node)))
+	page = c->page;
+	if (unlikely(!object || !node_match(page, node)))
 
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
