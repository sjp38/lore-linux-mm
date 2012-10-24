Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 0FC826B007D
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 11:06:30 -0400 (EDT)
Message-Id: <0000013a934f6baa-f14783e0-6087-4096-af87-ed20597ef21b-000000@email.amazonses.com>
Date: Wed, 24 Oct 2012 15:06:26 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK4 [12/15] Common definition for the array of kmalloc caches
References: <20121024150518.156629201@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

Have a common definition fo the kmalloc cache arrays in
SLAB and SLUB

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-10-24 09:22:57.120974042 -0500
+++ linux/mm/slab_common.c	2012-10-24 09:23:23.229346735 -0500
@@ -256,6 +256,14 @@ struct kmem_cache *__init create_kmalloc
 	return s;
 }
 
+struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
+EXPORT_SYMBOL(kmalloc_caches);
+
+#ifdef CONFIG_ZONE_DMA
+struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
+EXPORT_SYMBOL(kmalloc_dma_caches);
+#endif
+
 #endif /* !CONFIG_SLOB */
 
 
Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2012-10-24 09:23:21.317319439 -0500
+++ linux/include/linux/slub_def.h	2012-10-24 09:23:23.229346735 -0500
@@ -119,12 +119,6 @@ struct kmem_cache {
 #endif
 
 /*
- * We keep the general caches in an array of slab caches that are used for
- * 2^x bytes of allocations.
- */
-extern struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
-
-/*
  * Find the slab cache for a given combination of allocation flags and size.
  *
  * This ought to end up with a global pointer to the right cache
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-10-24 09:23:21.317319439 -0500
+++ linux/mm/slub.c	2012-10-24 09:23:23.229346735 -0500
@@ -3176,13 +3176,6 @@ int __kmem_cache_shutdown(struct kmem_ca
  *		Kmalloc subsystem
  *******************************************************************/
 
-struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
-EXPORT_SYMBOL(kmalloc_caches);
-
-#ifdef CONFIG_ZONE_DMA
-static struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
-#endif
-
 static int __init setup_slub_min_order(char *str)
 {
 	get_option(&str, &slub_min_order);
Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2012-10-24 09:23:21.317319439 -0500
+++ linux/include/linux/slab.h	2012-10-24 09:23:23.229346735 -0500
@@ -200,6 +200,11 @@ struct kmem_cache {
 #define KMALLOC_MIN_SIZE (1 << KMALLOC_SHIFT_LOW)
 #endif
 
+extern struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
+#ifdef CONFIG_ZONE_DMA
+extern struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
+#endif
+
 /*
  * Figure out which kmalloc slab an allocation of a certain size
  * belongs to.
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-10-24 09:23:17.877270331 -0500
+++ linux/mm/slab.c	2012-10-24 09:23:23.233346788 -0500
@@ -334,14 +334,6 @@ static void free_block(struct kmem_cache
 static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp);
 static void cache_reap(struct work_struct *unused);
 
-struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
-EXPORT_SYMBOL(kmalloc_caches);
-
-#ifdef CONFIG_ZONE_DMA
-struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
-EXPORT_SYMBOL(kmalloc_dma_caches);
-#endif
-
 static int slab_early_init = 1;
 
 #define INDEX_AC kmalloc_index(sizeof(struct arraycache_init))
Index: linux/include/linux/slab_def.h
===================================================================
--- linux.orig/include/linux/slab_def.h	2012-10-24 09:23:17.877270331 -0500
+++ linux/include/linux/slab_def.h	2012-10-24 09:23:23.233346788 -0500
@@ -95,9 +95,6 @@ struct kmem_cache {
 	 */
 };
 
-extern struct kmem_cache *kmalloc_caches[PAGE_SHIFT + MAX_ORDER];
-extern struct kmem_cache *kmalloc_dma_caches[PAGE_SHIFT + MAX_ORDER];
-
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
