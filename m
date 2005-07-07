Message-Id: <20050707213130.510116000@homer>
Date: Thu, 07 Jul 2005 23:31:30 +0200
From: domen@coderock.org
Subject: [patch 1/1] mm/slab: fix sparse warnings
Content-Disposition: inline; filename=sparse-mm_slab
Sender: owner-linux-mm@kvack.org
From: Victor Fusco <victor@cetuc.puc-rio.br>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Victor Fusco <victor@cetuc.puc-rio.br>, domen@coderock.org
List-ID: <linux-mm.kvack.org>


Fix the sparse warning "implicit cast to nocast type"

Signed-off-by: Victor Fusco <victor@cetuc.puc-rio.br>
Signed-off-by: Domen Puncer <domen@coderock.org>


---
 include/linux/slab.h |    8 ++++++--
 mm/slab.c            |    4 ++--
 2 files changed, 8 insertions(+), 4 deletions(-)

Index: quilt/mm/slab.c
===================================================================
--- quilt.orig/mm/slab.c
+++ quilt/mm/slab.c
@@ -1425,7 +1425,7 @@ next:
 	INIT_LIST_HEAD(&cachep->lists.slabs_free);
 
 	if (flags & CFLGS_OFF_SLAB)
-		cachep->slabp_cache = kmem_find_general_cachep(slab_size,0);
+		cachep->slabp_cache = kmem_find_general_cachep(slab_size, 0u);
 	cachep->ctor = ctor;
 	cachep->dtor = dtor;
 	cachep->name = name;
@@ -2365,7 +2365,7 @@ out:
  * and can sleep. And it will allocate memory on the given node, which
  * can improve the performance for cpu bound structures.
  */
-void *kmem_cache_alloc_node(kmem_cache_t *cachep, int flags, int nodeid)
+void *kmem_cache_alloc_node(kmem_cache_t *cachep, unsigned int __nocast flags, int nodeid)
 {
 	int loop;
 	void *objp;
Index: quilt/include/linux/slab.h
===================================================================
--- quilt.orig/include/linux/slab.h
+++ quilt/include/linux/slab.h
@@ -104,10 +104,14 @@ extern void kfree(const void *);
 extern unsigned int ksize(const void *);
 
 #ifdef CONFIG_NUMA
-extern void *kmem_cache_alloc_node(kmem_cache_t *, int flags, int node);
+extern void *kmem_cache_alloc_node(kmem_cache_t *,
+                                   unsigned int __nocast flags,
+                                   int node);
 extern void *kmalloc_node(size_t size, int flags, int node);
 #else
-static inline void *kmem_cache_alloc_node(kmem_cache_t *cachep, int flags, int node)
+static inline void *kmem_cache_alloc_node(kmem_cache_t *cachep,
+                                          unsigned int __nocast flags,
+                                          int node)
 {
 	return kmem_cache_alloc(cachep, flags);
 }

--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
