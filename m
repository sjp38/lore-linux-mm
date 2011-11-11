Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6B26B0087
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:33 -0500 (EST)
Message-Id: <20111111200729.687435163@linux.com>
Date: Fri, 11 Nov 2011 14:07:18 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 07/18] slub: pass page to node_match() instead of kmem_cache_cpu structure
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=page_parameter_to_node_match
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

The page field in struct kmem_cache_cpu will go away soon and so its more
convenient to pass the page struct to kmem_cache_cpu instead.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-09 11:11:32.231598204 -0600
+++ linux-2.6/mm/slub.c	2011-11-09 11:11:42.081654804 -0600
@@ -2009,10 +2009,10 @@ static void flush_all(struct kmem_cache
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
@@ -2178,7 +2178,7 @@ static void *__slab_alloc(struct kmem_ca
 		goto new_slab;
 redo:
 
-	if (unlikely(!node_match(c, node))) {
+	if (unlikely(!node_match(page, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
 		deactivate_slab(s, page, c->freelist);
 		c->page = NULL;
@@ -2263,6 +2263,7 @@ static __always_inline void *slab_alloc(
 {
 	void **object;
 	struct kmem_cache_cpu *c;
+	struct page *page;
 	unsigned long tid;
 
 	if (slab_pre_alloc_hook(s, gfpflags))
@@ -2288,7 +2289,8 @@ redo:
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
