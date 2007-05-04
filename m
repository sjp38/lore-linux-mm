Message-Id: <20070504103157.215424767@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:26:59 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 08/40] mm: kmem_cache_objsize
Content-Disposition: inline; filename=mm-kmem_objsize.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Expost buffer_size in order to allow fair estimates on the actual space 
used/needed.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
---
 include/linux/slab.h |    2 ++
 mm/slab.c            |   16 ++++++++++++++--
 mm/slob.c            |   18 ++++++++++++++++++
 3 files changed, 34 insertions(+), 2 deletions(-)

Index: linux-2.6-git/include/linux/slab.h
===================================================================
--- linux-2.6-git.orig/include/linux/slab.h	2007-03-26 14:18:59.000000000 +0200
+++ linux-2.6-git/include/linux/slab.h	2007-03-26 18:33:58.000000000 +0200
@@ -54,6 +54,7 @@ void *kmem_cache_alloc(struct kmem_cache
 void *kmem_cache_zalloc(struct kmem_cache *, gfp_t);
 void kmem_cache_free(struct kmem_cache *, void *);
 unsigned int kmem_cache_size(struct kmem_cache *);
+unsigned int kmem_cache_objsize(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
 
@@ -74,6 +75,7 @@ void *__kmalloc(size_t, gfp_t);
 void *__kzalloc(size_t, gfp_t);
 void kfree(const void *);
 unsigned int ksize(const void *);
+unsigned int kobjsize(size_t);
 
 /**
  * kcalloc - allocate memory for an array. The memory is set to zero.
Index: linux-2.6-git/mm/slab.c
===================================================================
--- linux-2.6-git.orig/mm/slab.c	2007-03-26 15:44:34.000000000 +0200
+++ linux-2.6-git/mm/slab.c	2007-03-28 10:10:36.000000000 +0200
@@ -3205,12 +3205,12 @@ static inline void *____cache_alloc(stru
 }
 
 #ifdef CONFIG_SLAB_FAIR
-static inline int slab_alloc_rank(gfp_t flags)
+static __always_inline int slab_alloc_rank(gfp_t flags)
 {
 	return gfp_to_rank(flags);
 }
 #else
-static inline int slab_alloc_rank(gfp_t flags)
+static __always_inline int slab_alloc_rank(gfp_t flags)
 {
 	return 0;
 }
@@ -3815,6 +3815,12 @@ unsigned int kmem_cache_size(struct kmem
 }
 EXPORT_SYMBOL(kmem_cache_size);
 
+unsigned int kmem_cache_objsize(struct kmem_cache *cachep)
+{
+	return cachep->buffer_size;
+}
+EXPORT_SYMBOL_GPL(kmem_cache_objsize);
+
 const char *kmem_cache_name(struct kmem_cache *cachep)
 {
 	return cachep->name;
@@ -4512,3 +4518,9 @@ unsigned int ksize(const void *objp)
 
 	return obj_size(virt_to_cache(objp));
 }
+
+unsigned int kobjsize(size_t size)
+{
+	return kmem_cache_objsize(kmem_find_general_cachep(size, 0));
+}
+EXPORT_SYMBOL_GPL(kobjsize);
Index: linux-2.6-git/mm/slob.c
===================================================================
--- linux-2.6-git.orig/mm/slob.c	2007-03-26 14:18:59.000000000 +0200
+++ linux-2.6-git/mm/slob.c	2007-03-26 18:33:58.000000000 +0200
@@ -240,6 +240,15 @@ unsigned int ksize(const void *block)
 	return ((slob_t *)block - 1)->units * SLOB_UNIT;
 }
 
+unsigned int kobjsize(size_t size)
+{
+	if (size < PAGE_SIZE)
+		return size;
+
+	return PAGE_SIZE << find_order(size);
+}
+EXPORT_SYMBOL_GPL(kobjsize);
+
 struct kmem_cache {
 	unsigned int size, align;
 	const char *name;
@@ -321,6 +330,15 @@ unsigned int kmem_cache_size(struct kmem
 }
 EXPORT_SYMBOL(kmem_cache_size);
 
+unsigned int kmem_cache_objsize(struct kmem_cache *c)
+{
+	if (c->size < PAGE_SIZE)
+		return c->size + c->align;
+
+	return PAGE_SIZE << find_order(c->size);
+}
+EXPORT_SYMBOL_GPL(kmem_cache_objsize);
+
 const char *kmem_cache_name(struct kmem_cache *c)
 {
 	return c->name;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
