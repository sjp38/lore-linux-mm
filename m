Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 1C5F06B005D
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 16:18:14 -0400 (EDT)
Message-Id: <0000013a043aca17-be81d17b-47c7-4511-9a52-853a493a0437-000000@email.amazonses.com>
Date: Wed, 26 Sep 2012 20:18:12 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK1 [10/13] Do not define KMALLOC array definitions for SLOB
References: <20120926200005.911809821@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

SLOB has no support for an array of kmalloc caches. Create a section
in include/linux/slab.h that is dedicated to the kmalloc cache
definition but disabled if SLOB is selected.

slab_common.c also has functions that are not needed for slob.
Disable those as well.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2012-09-18 12:13:16.222754746 -0500
+++ linux/include/linux/slab.h	2012-09-18 12:27:10.971944526 -0500
@@ -143,21 +143,6 @@ unsigned int kmem_cache_size(struct kmem
 		(__flags), NULL)
 
 /*
- * The largest kmalloc size supported by the slab allocators is
- * 32 megabyte (2^25) or the maximum allocatable page order if that is
- * less than 32 MB.
- *
- * WARNING: Its not easy to increase this value since the allocators have
- * to do various tricks to work around compiler limitations in order to
- * ensure proper constant folding.
- */
-#define KMALLOC_SHIFT_HIGH	((MAX_ORDER + PAGE_SHIFT - 1) <= 25 ? \
-				(MAX_ORDER + PAGE_SHIFT - 1) : 25)
-
-#define KMALLOC_MAX_SIZE	(1UL << KMALLOC_SHIFT_HIGH)
-#define KMALLOC_MAX_ORDER	(KMALLOC_SHIFT_HIGH - PAGE_SHIFT)
-
-/*
  * Some archs want to perform DMA into kmalloc caches and need a guaranteed
  * alignment larger than the alignment of a 64-bit integer.
  * Setting ARCH_KMALLOC_MINALIGN in arch headers allows that.
@@ -178,8 +163,24 @@ unsigned int kmem_cache_size(struct kmem
 #endif
 
 /*
+ * The largest kmalloc size supported by the slab allocators is
+ * 32 megabyte (2^25) or the maximum allocatable page order if that is
+ * less than 32 MB.
+ *
+ * WARNING: Its not easy to increase this value since the allocators have
+ * to do various tricks to work around compiler limitations in order to
+ * ensure proper constant folding.
+ */
+#define KMALLOC_SHIFT_HIGH	((MAX_ORDER + PAGE_SHIFT - 1) <= 25 ? \
+				(MAX_ORDER + PAGE_SHIFT - 1) : 25)
+
+#define KMALLOC_MAX_SIZE	(1UL << KMALLOC_SHIFT_HIGH)
+#define KMALLOC_MAX_ORDER	(KMALLOC_SHIFT_HIGH - PAGE_SHIFT)
+
+/*
  * Kmalloc subsystem.
  */
+#ifndef CONFIG_SLOB
 #if defined(ARCH_DMA_MINALIGN) && ARCH_DMA_MINALIGN > 8
 #define KMALLOC_MIN_SIZE ARCH_DMA_MINALIGN
 #else
@@ -260,6 +261,7 @@ static __always_inline int kmalloc_size(
 
 	return 0;
 }
+#endif
 
 /*
  * Common kmalloc functions provided by all allocators
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-09-18 12:13:16.230754925 -0500
+++ linux/mm/slab_common.c	2012-09-18 12:16:28.354706953 -0500
@@ -218,6 +218,8 @@ int slab_is_available(void)
 	return slab_state >= UP;
 }
 
+#ifndef CONFIG_SLOB
+
 /* Create a cache during boot when no slab services are available yet */
 void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t size,
 		unsigned long flags)
@@ -249,3 +251,5 @@ struct kmem_cache *__init create_kmalloc
 	s->refcount = 1;
 	return s;
 }
+
+#endif /* !CONFIG_SLOB */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
