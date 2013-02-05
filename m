Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 76FB96B0005
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 11:36:48 -0500 (EST)
Date: Tue, 5 Feb 2013 16:36:47 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: next-20130204 - bisected slab problem to "slab: Common constants
 for kmalloc boundaries"
In-Reply-To: <alpine.DEB.2.02.1302042019170.32396@gentwo.org>
Message-ID: <0000013cab3780f7-5e49ef46-e41a-4ff2-88f8-46bf216d677e-000000@email.amazonses.com>
References: <510FE051.7080107@imgtec.com> <51100E79.9080101@wwwdotorg.org> <alpine.DEB.2.02.1302042019170.32396@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Warren <swarren@wwwdotorg.org>
Cc: James Hogan <james.hogan@imgtec.com>, linux-next <linux-next@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

OK I was able to reproduce it by setting ARCH_DMA_MINALIGN in slab.h. This
patch fixes it here:


Subject: slab: Handle ARCH_DMA_MINALIGN correctly

A fixed KMALLOC_SHIFT_LOW does not work for arches with higher alignment
requirements.

Determine KMALLOC_SHIFT_LOW from ARCH_DMA_MINALIGN instead.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2013-02-05 10:30:53.917724146 -0600
+++ linux/include/linux/slab.h	2013-02-05 10:31:01.181836707 -0600
@@ -133,6 +133,19 @@ void kfree(const void *);
 void kzfree(const void *);
 size_t ksize(const void *);

+/*
+ * Some archs want to perform DMA into kmalloc caches and need a guaranteed
+ * alignment larger than the alignment of a 64-bit integer.
+ * Setting ARCH_KMALLOC_MINALIGN in arch headers allows that.
+ */
+#if defined(ARCH_DMA_MINALIGN) && ARCH_DMA_MINALIGN > 8
+#define ARCH_KMALLOC_MINALIGN ARCH_DMA_MINALIGN
+#define KMALLOC_MIN_SIZE ARCH_DMA_MINALIGN
+#define KMALLOC_SHIFT_LOW ilog2(ARCH_DMA_MINALIGN)
+#else
+#define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
+#endif
+
 #ifdef CONFIG_SLOB
 /*
  * Common fields provided in kmem_cache by all slab allocators
@@ -179,7 +192,9 @@ struct kmem_cache {
 #define KMALLOC_SHIFT_HIGH	((MAX_ORDER + PAGE_SHIFT - 1) <= 25 ? \
 				(MAX_ORDER + PAGE_SHIFT - 1) : 25)
 #define KMALLOC_SHIFT_MAX	KMALLOC_SHIFT_HIGH
+#ifndef KMALLOC_SHIFT_LOW
 #define KMALLOC_SHIFT_LOW	5
+#endif
 #else
 /*
  * SLUB allocates up to order 2 pages directly and otherwise
@@ -187,8 +202,10 @@ struct kmem_cache {
  */
 #define KMALLOC_SHIFT_HIGH	(PAGE_SHIFT + 1)
 #define KMALLOC_SHIFT_MAX	(MAX_ORDER + PAGE_SHIFT)
+#ifndef KMALLOC_SHIFT_LOW
 #define KMALLOC_SHIFT_LOW	3
 #endif
+#endif

 /* Maximum allocatable size */
 #define KMALLOC_MAX_SIZE	(1UL << KMALLOC_SHIFT_MAX)
@@ -200,9 +217,7 @@ struct kmem_cache {
 /*
  * Kmalloc subsystem.
  */
-#if defined(ARCH_DMA_MINALIGN) && ARCH_DMA_MINALIGN > 8
-#define KMALLOC_MIN_SIZE ARCH_DMA_MINALIGN
-#else
+#ifndef KMALLOC_MIN_SIZE
 #define KMALLOC_MIN_SIZE (1 << KMALLOC_SHIFT_LOW)
 #endif

@@ -285,17 +300,6 @@ static __always_inline int kmalloc_size(
 #endif /* !CONFIG_SLOB */

 /*
- * Some archs want to perform DMA into kmalloc caches and need a guaranteed
- * alignment larger than the alignment of a 64-bit integer.
- * Setting ARCH_KMALLOC_MINALIGN in arch headers allows that.
- */
-#ifdef ARCH_DMA_MINALIGN
-#define ARCH_KMALLOC_MINALIGN ARCH_DMA_MINALIGN
-#else
-#define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
-#endif
-
-/*
  * Setting ARCH_SLAB_MINALIGN in arch headers allows a different alignment.
  * Intended for arches that get misalignment faults even for 64 bit integer
  * aligned buffers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
