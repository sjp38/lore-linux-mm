Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 535016B0072
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 15:17:12 -0500 (EST)
Message-Id: <20120123201710.576227239@linux.com>
Date: Mon, 23 Jan 2012 14:16:55 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup 9/9] slub: pass page to node_match() instead of kmem_cache_cpu structure
References: <20120123201646.924319545@linux.com>
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
--- linux-2.6.orig/mm/slub.c	2012-01-13 08:47:35.018748303 -0600
+++ linux-2.6/mm/slub.c	2012-01-13 08:47:37.898748244 -0600
@@ -2025,10 +2025,10 @@ static void flush_all(struct kmem_cache
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
@@ -2201,7 +2201,7 @@ static void *__slab_alloc(struct kmem_ca
 		goto new_slab;
 redo:
 
-	if (unlikely(!node_match(c, node))) {
+	if (unlikely(!node_match(page, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
 		deactivate_slab(s, page, c->freelist);
 		c->page = NULL;
@@ -2288,6 +2288,7 @@ static __always_inline void *slab_alloc(
 {
 	void **object;
 	struct kmem_cache_cpu *c;
+	struct page *page;
 	unsigned long tid;
 
 	if (slab_pre_alloc_hook(s, gfpflags))
@@ -2313,7 +2314,8 @@ redo:
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
