Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 6E0986B0125
	for <linux-mm@kvack.org>; Wed,  9 May 2012 11:10:13 -0400 (EDT)
Message-Id: <20120509151011.835746458@linux.com>
Date: Wed, 09 May 2012 10:09:59 -0500
From: cl@linux.com
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup 9/9] slub: pass page to node_match() instead of kmem_cache_cpu structure
References: <20120509150950.243797150@linux.com>
Content-Disposition: inline; filename=page_parameter_to_node_match
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Avoid passing the kmem_cache_cpu pointer to node_match. This makes the
node_match function more generic and easier to understand.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-04-10 10:33:26.850750391 -0500
+++ linux-2.6/mm/slub.c	2012-04-10 10:33:32.078750283 -0500
@@ -2050,10 +2050,10 @@ static void flush_all(struct kmem_cache
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
@@ -2226,7 +2226,7 @@ static void *__slab_alloc(struct kmem_ca
 		goto new_slab;
 redo:
 
-	if (unlikely(!node_match(c, node))) {
+	if (unlikely(!node_match(page, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
 		deactivate_slab(s, page, c->freelist);
 		c->page = NULL;
@@ -2313,6 +2313,7 @@ static __always_inline void *slab_alloc(
 {
 	void **object;
 	struct kmem_cache_cpu *c;
+	struct page *page;
 	unsigned long tid;
 
 	if (slab_pre_alloc_hook(s, gfpflags))
@@ -2338,7 +2339,8 @@ redo:
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
