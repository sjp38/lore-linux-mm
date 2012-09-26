Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id D11A06B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 16:20:29 -0400 (EDT)
Message-Id: <0000013a043cdda2-ac695ad8-fe52-454b-8c86-94990e796944-000000@email.amazonses.com>
Date: Wed, 26 Sep 2012 20:20:28 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK1 [12/13] Common names for the array of kmalloc caches
References: <20120926200005.911809821@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Have a common name fo the kmalloc cache arrays in
SLAB and SLUB

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2012-09-20 08:58:38.645735914 -0500
+++ linux/include/linux/slab.h	2012-09-20 08:58:38.657736160 -0500
@@ -203,6 +203,11 @@ unsigned int kmem_cache_size(struct kmem
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
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-09-20 08:58:38.633735660 -0500
+++ linux/mm/slab_common.c	2012-09-24 12:41:27.373725893 -0500
@@ -252,4 +252,12 @@ struct kmem_cache *__init create_kmalloc
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
--- linux.orig/include/linux/slub_def.h	2012-09-20 08:58:38.645735914 -0500
+++ linux/include/linux/slub_def.h	2012-09-20 09:17:50.294766383 -0500
@@ -111,6 +111,9 @@ struct kmem_cache {
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
+#define KMEM_CACHE_SIZE (offsetof(struct kmem_cache, node) + \
+			nr_node_ids * sizeof(struct kmem_cache_node *))
+
 #ifdef CONFIG_ZONE_DMA
 #define SLUB_DMA __GFP_DMA
 #else
@@ -119,12 +122,6 @@ struct kmem_cache {
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
--- linux.orig/mm/slub.c	2012-09-20 08:58:38.645735914 -0500
+++ linux/mm/slub.c	2012-09-24 12:41:27.377726009 -0500
@@ -3174,13 +3174,6 @@ int __kmem_cache_shutdown(struct kmem_ca
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
