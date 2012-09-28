Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 2B4DE6B006E
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:25:13 -0400 (EDT)
Message-Id: <0000013a0e56f9f8-c2fbfbbb-0907-4c81-bb7d-b676ba798c96-000000@email.amazonses.com>
Date: Fri, 28 Sep 2012 19:25:12 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK2 [11/15] Common definition for the array of kmalloc caches
References: <20120928191715.368450474@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Have a common definition fo the kmalloc cache arrays in
SLAB and SLUB

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-09-28 13:31:22.809287368 -0500
+++ linux/mm/slab_common.c	2012-09-28 13:41:04.541431894 -0500
@@ -251,5 +251,13 @@ struct kmem_cache *__init create_kmalloc
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
--- linux.orig/include/linux/slub_def.h	2012-09-28 13:41:01.125360578 -0500
+++ linux/include/linux/slub_def.h	2012-09-28 13:41:04.541431894 -0500
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
--- linux.orig/mm/slub.c	2012-09-28 13:41:01.129360663 -0500
+++ linux/mm/slub.c	2012-09-28 13:41:04.541431894 -0500
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
Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2012-09-28 13:41:01.125360578 -0500
+++ linux/include/linux/slab.h	2012-09-28 13:41:04.541431894 -0500
@@ -189,6 +189,11 @@ struct kmem_cache {
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
