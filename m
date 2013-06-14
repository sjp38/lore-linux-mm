Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 0E9C96B0036
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 15:55:14 -0400 (EDT)
Message-ID: <0000013f44418b5a-367c5d75-ac30-46d2-9f33-55857b7fd3f0-000000@email.amazonses.com>
Date: Fri, 14 Jun 2013 19:55:13 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [3.11 2/4] slob: Rework #ifdeffery in slab.h
References: <20130614195500.373711648@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Make the SLOB specific stuff harmonize more with the way the other allocators
do it. Create the typical kmalloc constants for that purpose. SLOB does not
support it but the constants help us avoid #ifdefs.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2013-06-14 12:25:33.443671057 -0500
+++ linux/include/linux/slab.h	2013-06-14 13:19:19.597081306 -0500
@@ -169,11 +169,7 @@ struct kmem_cache {
 	struct list_head list;	/* List of all slab caches on the system */
 };
 
-#define KMALLOC_MAX_SIZE (1UL << 30)
-
-#include <linux/slob_def.h>
-
-#else /* CONFIG_SLOB */
+#endif /* CONFIG_SLOB */
 
 /*
  * Kmalloc array related definitions
@@ -195,7 +191,9 @@ struct kmem_cache {
 #ifndef KMALLOC_SHIFT_LOW
 #define KMALLOC_SHIFT_LOW	5
 #endif
-#else
+#endif
+
+#ifdef CONFIG_SLUB
 /*
  * SLUB allocates up to order 2 pages directly and otherwise
  * passes the request to the page allocator.
@@ -207,6 +205,19 @@ struct kmem_cache {
 #endif
 #endif
 
+#ifdef CONFIG_SLOB
+/*
+ * SLOB passes all page size and larger requests to the page allocator.
+ * No kmalloc array is necessary since objects of different sizes can
+ * be allocated from the same page.
+ */
+#define KMALLOC_SHIFT_MAX	30
+#define KMALLOC_SHIFT_HIGH	PAGE_SHIFT
+#ifndef KMALLOC_SHIFT_LOW
+#define KMALLOC_SHIFT_LOW	3
+#endif
+#endif
+
 /* Maximum allocatable size */
 #define KMALLOC_MAX_SIZE	(1UL << KMALLOC_SHIFT_MAX)
 /* Maximum size for which we actually use a slab cache */
@@ -221,6 +232,7 @@ struct kmem_cache {
 #define KMALLOC_MIN_SIZE (1 << KMALLOC_SHIFT_LOW)
 #endif
 
+#ifndef CONFIG_SLOB
 extern struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
 #ifdef CONFIG_ZONE_DMA
 extern struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
@@ -275,13 +287,18 @@ static __always_inline int kmalloc_index
 	/* Will never be reached. Needed because the compiler may complain */
 	return -1;
 }
+#endif /* !CONFIG_SLOB */
 
 #ifdef CONFIG_SLAB
 #include <linux/slab_def.h>
-#elif defined(CONFIG_SLUB)
+#endif
+
+#ifdef CONFIG_SLUB
 #include <linux/slub_def.h>
-#else
-#error "Unknown slab allocator"
+#endif
+
+#ifdef CONFIG_SLOB
+#include <linux/slob_def.h>
 #endif
 
 /*
@@ -291,6 +308,7 @@ static __always_inline int kmalloc_index
  */
 static __always_inline int kmalloc_size(int n)
 {
+#ifndef CONFIG_SLOB
 	if (n > 2)
 		return 1 << n;
 
@@ -299,10 +317,9 @@ static __always_inline int kmalloc_size(
 
 	if (n == 2 && KMALLOC_MIN_SIZE <= 64)
 		return 192;
-
+#endif
 	return 0;
 }
-#endif /* !CONFIG_SLOB */
 
 /*
  * Setting ARCH_SLAB_MINALIGN in arch headers allows a different alignment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
