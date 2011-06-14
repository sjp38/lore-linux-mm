Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6AA6F6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 17:16:41 -0400 (EDT)
Date: Tue, 14 Jun 2011 16:16:36 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slob: push the min alignment to long long
In-Reply-To: <20110614201031.GA19848@Chamillionaire.breakpoint.cc>
Message-ID: <alpine.DEB.2.00.1106141614480.10017@router.home>
References: <20110614201031.GA19848@Chamillionaire.breakpoint.cc>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, netfilter@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

Maybe this would work too?


Subject: slauob: Unify alignment definition

Every slab has its on alignment definition in include/linux/sl?b_def.h. Extract those
and define a common set in include/linux/slab.h.

SLOB: As notes sometimes we need double word alignment on 32 bit. This gives all
structures allocated by SLOB a unsigned long long alignment like the others do.

SLAB: If ARCH_SLAB_MINALIGN is not set SLAB would set ARCH_SLAB_MINALIGN to
zero meaning no alignment at all. Give it the default unsigned long long alignment.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 include/linux/slab.h     |   10 ++++++++++
 include/linux/slab_def.h |   26 --------------------------
 include/linux/slob_def.h |   10 ----------
 include/linux/slub_def.h |   10 ----------
 4 files changed, 10 insertions(+), 46 deletions(-)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2011-06-14 15:46:38.000000000 -0500
+++ linux-2.6/include/linux/slab.h	2011-06-14 15:46:59.000000000 -0500
@@ -133,6 +133,16 @@ unsigned int kmem_cache_size(struct kmem
 #define KMALLOC_MAX_SIZE	(1UL << KMALLOC_SHIFT_HIGH)
 #define KMALLOC_MAX_ORDER	(KMALLOC_SHIFT_HIGH - PAGE_SHIFT)

+#ifdef ARCH_DMA_MINALIGN
+#define ARCH_KMALLOC_MINALIGN ARCH_DMA_MINALIGN
+#else
+#define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
+#endif
+
+#ifndef ARCH_SLAB_MINALIGN
+#define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
+#endif
+
 /*
  * Common kmalloc functions provided by all allocators
  */
Index: linux-2.6/include/linux/slab_def.h
===================================================================
--- linux-2.6.orig/include/linux/slab_def.h	2011-06-14 15:47:04.000000000 -0500
+++ linux-2.6/include/linux/slab_def.h	2011-06-14 15:50:04.000000000 -0500
@@ -18,32 +18,6 @@
 #include <trace/events/kmem.h>

 /*
- * Enforce a minimum alignment for the kmalloc caches.
- * Usually, the kmalloc caches are cache_line_size() aligned, except when
- * DEBUG and FORCED_DEBUG are enabled, then they are BYTES_PER_WORD aligned.
- * Some archs want to perform DMA into kmalloc caches and need a guaranteed
- * alignment larger than the alignment of a 64-bit integer.
- * ARCH_KMALLOC_MINALIGN allows that.
- * Note that increasing this value may disable some debug features.
- */
-#ifdef ARCH_DMA_MINALIGN
-#define ARCH_KMALLOC_MINALIGN ARCH_DMA_MINALIGN
-#else
-#define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
-#endif
-
-#ifndef ARCH_SLAB_MINALIGN
-/*
- * Enforce a minimum alignment for all caches.
- * Intended for archs that get misalignment faults even for BYTES_PER_WORD
- * aligned buffers. Includes ARCH_KMALLOC_MINALIGN.
- * If possible: Do not enable this flag for CONFIG_DEBUG_SLAB, it disables
- * some debug features.
- */
-#define ARCH_SLAB_MINALIGN 0
-#endif
-
-/*
  * struct kmem_cache
  *
  * manages a cache.
Index: linux-2.6/include/linux/slob_def.h
===================================================================
--- linux-2.6.orig/include/linux/slob_def.h	2011-06-14 15:47:33.000000000 -0500
+++ linux-2.6/include/linux/slob_def.h	2011-06-14 15:47:40.000000000 -0500
@@ -1,16 +1,6 @@
 #ifndef __LINUX_SLOB_DEF_H
 #define __LINUX_SLOB_DEF_H

-#ifdef ARCH_DMA_MINALIGN
-#define ARCH_KMALLOC_MINALIGN ARCH_DMA_MINALIGN
-#else
-#define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long)
-#endif
-
-#ifndef ARCH_SLAB_MINALIGN
-#define ARCH_SLAB_MINALIGN __alignof__(unsigned long)
-#endif
-
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);

 static __always_inline void *kmem_cache_alloc(struct kmem_cache *cachep,
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2011-06-14 15:46:24.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2011-06-14 15:46:32.000000000 -0500
@@ -113,16 +113,6 @@ struct kmem_cache {

 #define KMALLOC_SHIFT_LOW ilog2(KMALLOC_MIN_SIZE)

-#ifdef ARCH_DMA_MINALIGN
-#define ARCH_KMALLOC_MINALIGN ARCH_DMA_MINALIGN
-#else
-#define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
-#endif
-
-#ifndef ARCH_SLAB_MINALIGN
-#define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
-#endif
-
 /*
  * Maximum kmalloc object size handled by SLUB. Larger object allocations
  * are passed through to the page allocator. The page allocator "fastpath"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
