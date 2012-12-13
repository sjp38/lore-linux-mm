Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 9A4616B0073
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 16:44:28 -0500 (EST)
Message-Id: <0000013b9639c674-c9b923f9-1e6e-41f4-a15c-3145e3da08dd-000000@email.amazonses.com>
Date: Thu, 13 Dec 2012 21:44:27 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Ren [08/12] Common definition for the array of kmalloc caches
References: <20121213211413.134419945@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

Have a common definition fo the kmalloc cache arrays in
SLAB and SLUB

Acked-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-11-05 09:26:05.700871190 -0600
+++ linux/mm/slab_common.c	2012-11-05 09:27:58.804850588 -0600
@@ -263,6 +263,14 @@ struct kmem_cache *__init create_kmalloc
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
--- linux.orig/include/linux/slub_def.h	2012-11-05 09:27:55.028851371 -0600
+++ linux/include/linux/slub_def.h	2012-11-05 09:27:58.804850588 -0600
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
--- linux.orig/mm/slub.c	2012-11-05 09:27:55.028851371 -0600
+++ linux/mm/slub.c	2012-11-05 09:27:58.804850588 -0600
@@ -3164,13 +3164,6 @@ int __kmem_cache_shutdown(struct kmem_ca
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
--- linux.orig/include/linux/slab.h	2012-11-05 09:27:55.028851371 -0600
+++ linux/include/linux/slab.h	2012-11-05 09:27:58.804850588 -0600
@@ -199,6 +199,11 @@ struct kmem_cache {
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
--- linux.orig/mm/slab.c	2012-11-05 09:27:51.392852117 -0600
+++ linux/mm/slab.c	2012-11-05 09:27:58.804850588 -0600
@@ -317,14 +317,6 @@ static void free_block(struct kmem_cache
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
--- linux.orig/include/linux/slab_def.h	2012-11-05 09:27:19.532858407 -0600
+++ linux/include/linux/slab_def.h	2012-11-05 09:27:58.808850587 -0600
@@ -99,9 +99,6 @@ struct kmem_cache {
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
