Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 85EB66B0073
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 14:14:25 -0500 (EST)
Message-Id: <0000013c25e260b7-34570e70-3561-424f-a8d5-94415cbdbed1-000000@email.amazonses.com>
Date: Thu, 10 Jan 2013 19:14:19 +0000
From: Christoph Lameter <cl@linux.com>
Subject: REN2 [03/13] Common kmalloc slab index determination
References: <20130110190027.780479755@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

Extract the function to determine the index of the slab within
the array of kmalloc caches as well as a function to determine
maximum object size from the nr of the kmalloc slab.

This is used here only to simplify slub bootstrap but will
be used later also for SLAB.

Acked-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Christoph Lameter <cl@linux.com> 

Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2013-01-10 09:38:49.808987765 -0600
+++ linux/include/linux/slub_def.h	2013-01-10 09:39:21.601476033 -0600
@@ -116,17 +116,6 @@ struct kmem_cache {
 };
 
 /*
- * Kmalloc subsystem.
- */
-#if defined(ARCH_DMA_MINALIGN) && ARCH_DMA_MINALIGN > 8
-#define KMALLOC_MIN_SIZE ARCH_DMA_MINALIGN
-#else
-#define KMALLOC_MIN_SIZE 8
-#endif
-
-#define KMALLOC_SHIFT_LOW ilog2(KMALLOC_MIN_SIZE)
-
-/*
  * Maximum kmalloc object size handled by SLUB. Larger object allocations
  * are passed through to the page allocator. The page allocator "fastpath"
  * is relatively slow so we need this value sufficiently high so that
@@ -153,58 +142,6 @@ struct kmem_cache {
 extern struct kmem_cache *kmalloc_caches[SLUB_PAGE_SHIFT];
 
 /*
- * Sorry that the following has to be that ugly but some versions of GCC
- * have trouble with constant propagation and loops.
- */
-static __always_inline int kmalloc_index(size_t size)
-{
-	if (!size)
-		return 0;
-
-	if (size <= KMALLOC_MIN_SIZE)
-		return KMALLOC_SHIFT_LOW;
-
-	if (KMALLOC_MIN_SIZE <= 32 && size > 64 && size <= 96)
-		return 1;
-	if (KMALLOC_MIN_SIZE <= 64 && size > 128 && size <= 192)
-		return 2;
-	if (size <=          8) return 3;
-	if (size <=         16) return 4;
-	if (size <=         32) return 5;
-	if (size <=         64) return 6;
-	if (size <=        128) return 7;
-	if (size <=        256) return 8;
-	if (size <=        512) return 9;
-	if (size <=       1024) return 10;
-	if (size <=   2 * 1024) return 11;
-	if (size <=   4 * 1024) return 12;
-/*
- * The following is only needed to support architectures with a larger page
- * size than 4k. We need to support 2 * PAGE_SIZE here. So for a 64k page
- * size we would have to go up to 128k.
- */
-	if (size <=   8 * 1024) return 13;
-	if (size <=  16 * 1024) return 14;
-	if (size <=  32 * 1024) return 15;
-	if (size <=  64 * 1024) return 16;
-	if (size <= 128 * 1024) return 17;
-	if (size <= 256 * 1024) return 18;
-	if (size <= 512 * 1024) return 19;
-	if (size <= 1024 * 1024) return 20;
-	if (size <=  2 * 1024 * 1024) return 21;
-	BUG();
-	return -1; /* Will never be reached */
-
-/*
- * What we really wanted to do and cannot do because of compiler issues is:
- *	int i;
- *	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++)
- *		if (size <= (1 << i))
- *			return i;
- */
-}
-
-/*
  * Find the slab cache for a given combination of allocation flags and size.
  *
  * This ought to end up with a global pointer to the right cache
Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2013-01-10 09:39:20.697462154 -0600
+++ linux/include/linux/slab.h	2013-01-10 09:42:25.640301677 -0600
@@ -94,29 +94,6 @@
 #define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <= \
 				(unsigned long)ZERO_SIZE_PTR)
 
-/*
- * Common fields provided in kmem_cache by all slab allocators
- * This struct is either used directly by the allocator (SLOB)
- * or the allocator must include definitions for all fields
- * provided in kmem_cache_common in their definition of kmem_cache.
- *
- * Once we can do anonymous structs (C11 standard) we could put a
- * anonymous struct definition in these allocators so that the
- * separate allocations in the kmem_cache structure of SLAB and
- * SLUB is no longer needed.
- */
-#ifdef CONFIG_SLOB
-struct kmem_cache {
-	unsigned int object_size;/* The original size of the object */
-	unsigned int size;	/* The aligned/padded/added on size  */
-	unsigned int align;	/* Alignment as calculated */
-	unsigned long flags;	/* Active flags on the slab */
-	const char *name;	/* Slab name for sysfs */
-	int refcount;		/* Use counter */
-	void (*ctor)(void *);	/* Called on object slot creation */
-	struct list_head list;	/* List of all slab caches on the system */
-};
-#endif
 
 struct mem_cgroup;
 /*
@@ -156,6 +133,35 @@ void kfree(const void *);
 void kzfree(const void *);
 size_t ksize(const void *);
 
+#ifdef CONFIG_SLOB
+/*
+ * Common fields provided in kmem_cache by all slab allocators
+ * This struct is either used directly by the allocator (SLOB)
+ * or the allocator must include definitions for all fields
+ * provided in kmem_cache_common in their definition of kmem_cache.
+ *
+ * Once we can do anonymous structs (C11 standard) we could put a
+ * anonymous struct definition in these allocators so that the
+ * separate allocations in the kmem_cache structure of SLAB and
+ * SLUB is no longer needed.
+ */
+struct kmem_cache {
+	unsigned int object_size;/* The original size of the object */
+	unsigned int size;	/* The aligned/padded/added on size  */
+	unsigned int align;	/* Alignment as calculated */
+	unsigned long flags;	/* Active flags on the slab */
+	const char *name;	/* Slab name for sysfs */
+	int refcount;		/* Use counter */
+	void (*ctor)(void *);	/* Called on object slot creation */
+	struct list_head list;	/* List of all slab caches on the system */
+};
+
+#define KMALLOC_MAX_SIZE (1UL << 30)
+
+#include <linux/slob_def.h>
+
+#else /* CONFIG_SLOB */
+
 /*
  * The largest kmalloc size supported by the slab allocators is
  * 32 megabyte (2^25) or the maximum allocatable page order if that is
@@ -172,6 +178,99 @@ size_t ksize(const void *);
 #define KMALLOC_MAX_ORDER	(KMALLOC_SHIFT_HIGH - PAGE_SHIFT)
 
 /*
+ * Kmalloc subsystem.
+ */
+#if defined(ARCH_DMA_MINALIGN) && ARCH_DMA_MINALIGN > 8
+#define KMALLOC_MIN_SIZE ARCH_DMA_MINALIGN
+#else
+#ifdef CONFIG_SLAB
+#define KMALLOC_MIN_SIZE 32
+#else
+#define KMALLOC_MIN_SIZE 8
+#endif
+#endif
+
+#define KMALLOC_SHIFT_LOW ilog2(KMALLOC_MIN_SIZE)
+
+/*
+ * Figure out which kmalloc slab an allocation of a certain size
+ * belongs to.
+ * 0 = zero alloc
+ * 1 =  65 .. 96 bytes
+ * 2 = 120 .. 192 bytes
+ * n = 2^(n-1) .. 2^n -1
+ */
+static __always_inline int kmalloc_index(size_t size)
+{
+	if (!size)
+		return 0;
+
+	if (size <= KMALLOC_MIN_SIZE)
+		return KMALLOC_SHIFT_LOW;
+
+	if (KMALLOC_MIN_SIZE <= 32 && size > 64 && size <= 96)
+		return 1;
+	if (KMALLOC_MIN_SIZE <= 64 && size > 128 && size <= 192)
+		return 2;
+	if (size <=          8) return 3;
+	if (size <=         16) return 4;
+	if (size <=         32) return 5;
+	if (size <=         64) return 6;
+	if (size <=        128) return 7;
+	if (size <=        256) return 8;
+	if (size <=        512) return 9;
+	if (size <=       1024) return 10;
+	if (size <=   2 * 1024) return 11;
+	if (size <=   4 * 1024) return 12;
+	if (size <=   8 * 1024) return 13;
+	if (size <=  16 * 1024) return 14;
+	if (size <=  32 * 1024) return 15;
+	if (size <=  64 * 1024) return 16;
+	if (size <= 128 * 1024) return 17;
+	if (size <= 256 * 1024) return 18;
+	if (size <= 512 * 1024) return 19;
+	if (size <= 1024 * 1024) return 20;
+	if (size <=  2 * 1024 * 1024) return 21;
+	if (size <=  4 * 1024 * 1024) return 22;
+	if (size <=  8 * 1024 * 1024) return 23;
+	if (size <=  16 * 1024 * 1024) return 24;
+	if (size <=  32 * 1024 * 1024) return 25;
+	if (size <=  64 * 1024 * 1024) return 26;
+	BUG();
+
+	/* Will never be reached. Needed because the compiler may complain */
+	return -1;
+}
+
+#ifdef CONFIG_SLAB
+#include <linux/slab_def.h>
+#elif defined(CONFIG_SLUB)
+#include <linux/slub_def.h>
+#else
+#error "Unknown slab allocator"
+#endif
+
+/*
+ * Determine size used for the nth kmalloc cache.
+ * return size or 0 if a kmalloc cache for that
+ * size does not exist
+ */
+static __always_inline int kmalloc_size(int n)
+{
+	if (n > 2)
+		return 1 << n;
+
+	if (n == 1 && KMALLOC_MIN_SIZE <= 32)
+		return 96;
+
+	if (n == 2 && KMALLOC_MIN_SIZE <= 64)
+		return 192;
+
+	return 0;
+}
+#endif /* !CONFIG_SLOB */
+
+/*
  * Some archs want to perform DMA into kmalloc caches and need a guaranteed
  * alignment larger than the alignment of a 64-bit integer.
  * Setting ARCH_KMALLOC_MINALIGN in arch headers allows that.
@@ -233,33 +332,6 @@ struct seq_file;
 int cache_show(struct kmem_cache *s, struct seq_file *m);
 void print_slabinfo_header(struct seq_file *m);
 
-/*
- * Allocator specific definitions. These are mainly used to establish optimized
- * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by
- * selecting the appropriate general cache at compile time.
- *
- * Allocators must define at least:
- *
- *	kmem_cache_alloc()
- *	__kmalloc()
- *	kmalloc()
- *
- * Those wishing to support NUMA must also define:
- *
- *	kmem_cache_alloc_node()
- *	kmalloc_node()
- *
- * See each allocator definition file for additional comments and
- * implementation notes.
- */
-#ifdef CONFIG_SLUB
-#include <linux/slub_def.h>
-#elif defined(CONFIG_SLOB)
-#include <linux/slob_def.h>
-#else
-#include <linux/slab_def.h>
-#endif
-
 /**
  * kmalloc_array - allocate memory for an array.
  * @n: number of elements.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
