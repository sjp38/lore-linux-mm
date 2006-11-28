Date: Mon, 27 Nov 2006 22:33:28 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC] Extract kmalloc.h and slob.h from slab.h
Message-ID: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

slab.h really defines multiple APIs. One is the classic slab api
where one can define a slab cache by specifying exactly how
the slab has to be generated. This API is not frequently used.

Another is the kmalloc API. Quite a number of kernel source code files 
need kmalloc but do not need to generate custom slabs. The kmalloc API 
also use some funky macros that may be better isolated in an additional .h 
file in order to ease future cleanup. Make kmalloc.h self contained by 
adding two extern definitions local to kmalloc and kmalloc_node.

Then there is the SLOB api mixed in with slab. Take that out and define it 
in its own header file.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc6-mm1/include/linux/kmalloc.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.19-rc6-mm1/include/linux/kmalloc.h	2006-11-27 21:57:25.000000000 -0800
@@ -0,0 +1,221 @@
+#ifndef _LINUX_KMALLOC_H
+#define	_LINUX_KMALLOC_H
+
+#include <linux/gfp.h>
+#include <asm/page.h>		/* kmalloc_sizes.h needs PAGE_SIZE */
+#include <asm/cache.h>		/* kmalloc_sizes.h needs L1_CACHE_BYTES */
+
+#ifdef __KERNEL__
+
+/* Size description struct for general caches. */
+struct cache_sizes {
+	size_t		 cs_size;
+	struct kmem_cache *cs_cachep;
+#ifdef CONFIG_ZONE_DMA
+	struct kmem_cache *cs_dmacachep;
+#else
+#define cs_dmacachep cs_cachep
+#endif
+};
+extern struct cache_sizes malloc_sizes[];
+
+extern void *__kmalloc(size_t, gfp_t);
+
+/**
+ * kmalloc - allocate memory
+ * @size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate.
+ *
+ * kmalloc is the normal method of allocating memory
+ * in the kernel.
+ *
+ * The @flags argument may be one of:
+ *
+ * %GFP_USER - Allocate memory on behalf of user.  May sleep.
+ *
+ * %GFP_KERNEL - Allocate normal kernel ram.  May sleep.
+ *
+ * %GFP_ATOMIC - Allocation will not sleep.
+ *   For example, use this inside interrupt handlers.
+ *
+ * %GFP_HIGHUSER - Allocate pages from high memory.
+ *
+ * %GFP_NOIO - Do not do any I/O at all while trying to get memory.
+ *
+ * %GFP_NOFS - Do not make any fs calls while trying to get memory.
+ *
+ * Also it is possible to set different flags by OR'ing
+ * in one or more of the following additional @flags:
+ *
+ * %__GFP_COLD - Request cache-cold pages instead of
+ *   trying to return cache-warm pages.
+ *
+ * %__GFP_DMA - Request memory from the DMA-capable zone.
+ *
+ * %__GFP_HIGH - This allocation has high priority and may use emergency pools.
+ *
+ * %__GFP_HIGHMEM - Allocated memory may be from highmem.
+ *
+ * %__GFP_NOFAIL - Indicate that this allocation is in no way allowed to fail
+ *   (think twice before using).
+ *
+ * %__GFP_NORETRY - If memory is not immediately available,
+ *   then give up at once.
+ *
+ * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
+ *
+ * %__GFP_REPEAT - If allocation fails initially, try once more before failing.
+ */
+static inline void *kmalloc(size_t size, gfp_t flags)
+{
+	extern void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
+
+	if (__builtin_constant_p(size)) {
+		int i = 0;
+#define CACHE(x) \
+		if (size <= x) \
+			goto found; \
+		else \
+			i++;
+#include "kmalloc_sizes.h"
+#undef CACHE
+		{
+			extern void __you_cannot_kmalloc_that_much(void);
+			__you_cannot_kmalloc_that_much();
+		}
+found:
+		return kmem_cache_alloc((flags & GFP_DMA) ?
+			malloc_sizes[i].cs_dmacachep :
+			malloc_sizes[i].cs_cachep, flags);
+	}
+	return __kmalloc(size, flags);
+}
+
+/*
+ * kmalloc_track_caller is a special version of kmalloc that records the
+ * calling function of the routine calling it for slab leak tracking instead
+ * of just the calling function (confusing, eh?).
+ * It's useful when the call to kmalloc comes from a widely-used standard
+ * allocator where we care about the real place the memory allocation
+ * request comes from.
+ */
+#ifndef CONFIG_DEBUG_SLAB
+#define kmalloc_track_caller(size, flags) \
+	__kmalloc(size, flags)
+#else
+extern void *__kmalloc_track_caller(size_t, gfp_t, void*);
+#define kmalloc_track_caller(size, flags) \
+	__kmalloc_track_caller(size, flags, __builtin_return_address(0))
+#endif
+
+extern void *__kzalloc(size_t, gfp_t);
+
+/**
+ * kzalloc - allocate memory. The memory is set to zero.
+ * @size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate (see kmalloc).
+ */
+static inline void *kzalloc(size_t size, gfp_t flags)
+{
+	extern void *kmem_cache_zalloc(struct kmem_cache *, gfp_t);
+
+	if (__builtin_constant_p(size)) {
+		int i = 0;
+#define CACHE(x) \
+		if (size <= x) \
+			goto found; \
+		else \
+			i++;
+#include "kmalloc_sizes.h"
+#undef CACHE
+		{
+			extern void __you_cannot_kzalloc_that_much(void);
+			__you_cannot_kzalloc_that_much();
+		}
+found:
+		return kmem_cache_zalloc((flags & GFP_DMA) ?
+			malloc_sizes[i].cs_dmacachep :
+			malloc_sizes[i].cs_cachep, flags);
+	}
+	return __kzalloc(size, flags);
+}
+
+/**
+ * kcalloc - allocate memory for an array. The memory is set to zero.
+ * @n: number of elements.
+ * @size: element size.
+ * @flags: the type of memory to allocate.
+ */
+static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
+{
+	if (n != 0 && size > ULONG_MAX / n)
+		return NULL;
+	return kzalloc(n * size, flags);
+}
+
+extern void kfree(const void *);
+extern unsigned int ksize(const void *);
+
+#ifdef CONFIG_NUMA
+extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
+
+static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags,
+								int node);
+
+	if (__builtin_constant_p(size)) {
+		int i = 0;
+#define CACHE(x) \
+		if (size <= x) \
+			goto found; \
+		else \
+			i++;
+#include "kmalloc_sizes.h"
+#undef CACHE
+		{
+			extern void __you_cannot_kmalloc_that_much(void);
+			__you_cannot_kmalloc_that_much();
+		}
+found:
+		return kmem_cache_alloc_node((flags & GFP_DMA) ?
+			malloc_sizes[i].cs_dmacachep :
+			malloc_sizes[i].cs_cachep, flags, node);
+	}
+	return __kmalloc_node(size, flags, node);
+}
+
+/*
+ * kmalloc_node_track_caller is a special version of kmalloc_node that
+ * records the calling function of the routine calling it for slab leak
+ * tracking instead of just the calling function (confusing, eh?).
+ * It's useful when the call to kmalloc_node comes from a widely-used
+ * standard allocator where we care about the real place the memory
+ * allocation request comes from.
+ */
+#ifndef CONFIG_DEBUG_SLAB
+#define kmalloc_node_track_caller(size, flags, node) \
+	__kmalloc_node(size, flags, node)
+#else
+extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, void *);
+#define kmalloc_node_track_caller(size, flags, node) \
+	__kmalloc_node_track_caller(size, flags, node, \
+				__builtin_return_address(0))
+#endif
+#else
+static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return kmalloc(size, flags);
+}
+
+#define kmalloc_node_track_caller(size, flags, node) \
+	kmalloc_track_caller(size, flags)
+#endif
+
+extern void __init kmem_cache_init(void);
+extern int slab_is_available(void);
+extern int kmem_cache_reap(int);
+
+#endif	/* __KERNEL__ */
+
+#endif	/* _LINUX_KMALLOC_H */
Index: linux-2.6.19-rc6-mm1/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/slab.h	2006-11-27 21:56:49.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/slab.h	2006-11-27 22:05:32.000000000 -0800
@@ -15,8 +15,6 @@
 #include	<linux/gfp.h>
 #include	<linux/init.h>
 #include	<linux/types.h>
-#include	<asm/page.h>		/* kmalloc_sizes.h needs PAGE_SIZE */
-#include	<asm/cache.h>		/* kmalloc_sizes.h needs L1_CACHE_BYTES */
 
 /* flags for kmem_cache_alloc() */
 #define	SLAB_NOFS		GFP_NOFS
@@ -53,11 +51,11 @@
 #define SLAB_CTOR_ATOMIC	0x002UL		/* tell constructor it can't sleep */
 #define	SLAB_CTOR_VERIFY	0x004UL		/* tell constructor it's a verify call */
 
-#ifndef CONFIG_SLOB
+#ifdef CONFIG_SLOB
+#include <linux/slob.h>
+#else
 
 /* prototypes */
-extern void __init kmem_cache_init(void);
-
 extern struct kmem_cache *kmem_cache_create(const char *,
 		size_t, size_t, unsigned long,
 		void (*)(void *, struct kmem_cache *, unsigned long),
@@ -69,258 +67,24 @@
 extern void kmem_cache_free(struct kmem_cache *, void *);
 extern unsigned int kmem_cache_size(struct kmem_cache *);
 extern const char *kmem_cache_name(struct kmem_cache *);
+extern int kmem_ptr_validate(struct kmem_cache *cachep, void *ptr);
 
-/* Size description struct for general caches. */
-struct cache_sizes {
-	size_t		 cs_size;
-	struct kmem_cache *cs_cachep;
-#ifdef CONFIG_ZONE_DMA
-	struct kmem_cache *cs_dmacachep;
-#else
-#define cs_dmacachep cs_cachep
-#endif
-};
-extern struct cache_sizes malloc_sizes[];
-
-extern void *__kmalloc(size_t, gfp_t);
-
-/**
- * kmalloc - allocate memory
- * @size: how many bytes of memory are required.
- * @flags: the type of memory to allocate.
- *
- * kmalloc is the normal method of allocating memory
- * in the kernel.
- *
- * The @flags argument may be one of:
- *
- * %GFP_USER - Allocate memory on behalf of user.  May sleep.
- *
- * %GFP_KERNEL - Allocate normal kernel ram.  May sleep.
- *
- * %GFP_ATOMIC - Allocation will not sleep.
- *   For example, use this inside interrupt handlers.
- *
- * %GFP_HIGHUSER - Allocate pages from high memory.
- *
- * %GFP_NOIO - Do not do any I/O at all while trying to get memory.
- *
- * %GFP_NOFS - Do not make any fs calls while trying to get memory.
- *
- * Also it is possible to set different flags by OR'ing
- * in one or more of the following additional @flags:
- *
- * %__GFP_COLD - Request cache-cold pages instead of
- *   trying to return cache-warm pages.
- *
- * %__GFP_DMA - Request memory from the DMA-capable zone.
- *
- * %__GFP_HIGH - This allocation has high priority and may use emergency pools.
- *
- * %__GFP_HIGHMEM - Allocated memory may be from highmem.
- *
- * %__GFP_NOFAIL - Indicate that this allocation is in no way allowed to fail
- *   (think twice before using).
- *
- * %__GFP_NORETRY - If memory is not immediately available,
- *   then give up at once.
- *
- * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
- *
- * %__GFP_REPEAT - If allocation fails initially, try once more before failing.
- */
-static inline void *kmalloc(size_t size, gfp_t flags)
-{
-	if (__builtin_constant_p(size)) {
-		int i = 0;
-#define CACHE(x) \
-		if (size <= x) \
-			goto found; \
-		else \
-			i++;
-#include "kmalloc_sizes.h"
-#undef CACHE
-		{
-			extern void __you_cannot_kmalloc_that_much(void);
-			__you_cannot_kmalloc_that_much();
-		}
-found:
-		return kmem_cache_alloc((flags & GFP_DMA) ?
-			malloc_sizes[i].cs_dmacachep :
-			malloc_sizes[i].cs_cachep, flags);
-	}
-	return __kmalloc(size, flags);
-}
-
-/*
- * kmalloc_track_caller is a special version of kmalloc that records the
- * calling function of the routine calling it for slab leak tracking instead
- * of just the calling function (confusing, eh?).
- * It's useful when the call to kmalloc comes from a widely-used standard
- * allocator where we care about the real place the memory allocation
- * request comes from.
- */
-#ifndef CONFIG_DEBUG_SLAB
-#define kmalloc_track_caller(size, flags) \
-	__kmalloc(size, flags)
-#else
-extern void *__kmalloc_track_caller(size_t, gfp_t, void*);
-#define kmalloc_track_caller(size, flags) \
-	__kmalloc_track_caller(size, flags, __builtin_return_address(0))
-#endif
-
-extern void *__kzalloc(size_t, gfp_t);
-
-/**
- * kzalloc - allocate memory. The memory is set to zero.
- * @size: how many bytes of memory are required.
- * @flags: the type of memory to allocate (see kmalloc).
- */
-static inline void *kzalloc(size_t size, gfp_t flags)
-{
-	if (__builtin_constant_p(size)) {
-		int i = 0;
-#define CACHE(x) \
-		if (size <= x) \
-			goto found; \
-		else \
-			i++;
-#include "kmalloc_sizes.h"
-#undef CACHE
-		{
-			extern void __you_cannot_kzalloc_that_much(void);
-			__you_cannot_kzalloc_that_much();
-		}
-found:
-		return kmem_cache_zalloc((flags & GFP_DMA) ?
-			malloc_sizes[i].cs_dmacachep :
-			malloc_sizes[i].cs_cachep, flags);
-	}
-	return __kzalloc(size, flags);
-}
-
-/**
- * kcalloc - allocate memory for an array. The memory is set to zero.
- * @n: number of elements.
- * @size: element size.
- * @flags: the type of memory to allocate.
- */
-static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
-{
-	if (n != 0 && size > ULONG_MAX / n)
-		return NULL;
-	return kzalloc(n * size, flags);
-}
-
-extern void kfree(const void *);
-extern unsigned int ksize(const void *);
-extern int slab_is_available(void);
+struct shrinker;
+extern void kmem_set_shrinker(kmem_cache_t *cachep, struct shrinker *shrinker);
 
 #ifdef CONFIG_NUMA
 extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
-extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
-
-static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
-{
-	if (__builtin_constant_p(size)) {
-		int i = 0;
-#define CACHE(x) \
-		if (size <= x) \
-			goto found; \
-		else \
-			i++;
-#include "kmalloc_sizes.h"
-#undef CACHE
-		{
-			extern void __you_cannot_kmalloc_that_much(void);
-			__you_cannot_kmalloc_that_much();
-		}
-found:
-		return kmem_cache_alloc_node((flags & GFP_DMA) ?
-			malloc_sizes[i].cs_dmacachep :
-			malloc_sizes[i].cs_cachep, flags, node);
-	}
-	return __kmalloc_node(size, flags, node);
-}
-
-/*
- * kmalloc_node_track_caller is a special version of kmalloc_node that
- * records the calling function of the routine calling it for slab leak
- * tracking instead of just the calling function (confusing, eh?).
- * It's useful when the call to kmalloc_node comes from a widely-used
- * standard allocator where we care about the real place the memory
- * allocation request comes from.
- */
-#ifndef CONFIG_DEBUG_SLAB
-#define kmalloc_node_track_caller(size, flags, node) \
-	__kmalloc_node(size, flags, node)
-#else
-extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, void *);
-#define kmalloc_node_track_caller(size, flags, node) \
-	__kmalloc_node_track_caller(size, flags, node, \
-			__builtin_return_address(0))
-#endif
 #else /* CONFIG_NUMA */
 static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
 					gfp_t flags, int node)
 {
 	return kmem_cache_alloc(cachep, flags);
 }
-static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
-{
-	return kmalloc(size, flags);
-}
-
-#define kmalloc_node_track_caller(size, flags, node) \
-	kmalloc_track_caller(size, flags)
 #endif
 
-extern int FASTCALL(kmem_cache_reap(int));
-extern int FASTCALL(kmem_ptr_validate(struct kmem_cache *cachep, void *ptr));
-
-struct shrinker;
-extern void kmem_set_shrinker(kmem_cache_t *cachep, struct shrinker *shrinker);
-
-#else /* CONFIG_SLOB */
-
-/* SLOB allocator routines */
-
-void kmem_cache_init(void);
-struct kmem_cache *kmem_cache_create(const char *c, size_t, size_t,
-	unsigned long,
-	void (*)(void *, struct kmem_cache *, unsigned long),
-	void (*)(void *, struct kmem_cache *, unsigned long));
-void kmem_cache_destroy(struct kmem_cache *c);
-void *kmem_cache_alloc(struct kmem_cache *c, gfp_t flags);
-void *kmem_cache_zalloc(struct kmem_cache *, gfp_t);
-void kmem_cache_free(struct kmem_cache *c, void *b);
-const char *kmem_cache_name(struct kmem_cache *);
-void *kmalloc(size_t size, gfp_t flags);
-void *__kzalloc(size_t size, gfp_t flags);
-void kfree(const void *m);
-unsigned int ksize(const void *m);
-unsigned int kmem_cache_size(struct kmem_cache *c);
-
-static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
-{
-	return __kzalloc(n * size, flags);
-}
-
-#define kmem_cache_shrink(d) (0)
-#define kmem_cache_reap(a)
-#define kmem_ptr_validate(a, b) (0)
-#define kmem_cache_alloc_node(c, f, n) kmem_cache_alloc(c, f)
-#define kmalloc_node(s, f, n) kmalloc(s, f)
-#define kzalloc(s, f) __kzalloc(s, f)
-#define kmalloc_track_caller kmalloc
-
-#define kmalloc_node_track_caller kmalloc_node
-
-struct shrinker;
-static inline void kmem_set_shrinker(kmem_cache_t *cachep,
-				     struct shrinker *shrinker) {}
+#include <linux/kmalloc.h>
 
-#endif /* CONFIG_SLOB */
+#endif /* !CONFIG_SLOB */
 
 #endif	/* __KERNEL__ */
 
Index: linux-2.6.19-rc6-mm1/include/linux/slob.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.19-rc6-mm1/include/linux/slob.h	2006-11-27 22:16:32.000000000 -0800
@@ -0,0 +1,47 @@
+#ifndef _LINUX_SLOB_H
+#define	_LINUX_SLOB_H
+
+#if	defined(__KERNEL__)
+
+#include <linux/slab.h>
+
+/* SLOB allocator routines */
+
+void kmem_cache_init(void);
+struct kmem_cache *kmem_cache_create(const char *c, size_t, size_t,
+	unsigned long,
+	void (*)(void *, struct kmem_cache *, unsigned long),
+	void (*)(void *, struct kmem_cache *, unsigned long));
+void kmem_cache_destroy(struct kmem_cache *c);
+void *kmem_cache_alloc(struct kmem_cache *c, gfp_t flags);
+void *kmem_cache_zalloc(struct kmem_cache *, gfp_t);
+void kmem_cache_free(struct kmem_cache *c, void *b);
+const char *kmem_cache_name(struct kmem_cache *);
+void *kmalloc(size_t size, gfp_t flags);
+void *__kzalloc(size_t size, gfp_t flags);
+void kfree(const void *m);
+unsigned int ksize(const void *m);
+unsigned int kmem_cache_size(struct kmem_cache *c);
+
+static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
+{
+	return __kzalloc(n * size, flags);
+}
+
+#define kmem_cache_shrink(d) (0)
+#define kmem_cache_reap(a)
+#define kmem_ptr_validate(a, b) (0)
+#define kmem_cache_alloc_node(c, f, n) kmem_cache_alloc(c, f)
+#define kmalloc_node(s, f, n) kmalloc(s, f)
+#define kzalloc(s, f) __kzalloc(s, f)
+#define kmalloc_track_caller kmalloc
+
+#define kmalloc_node_track_caller kmalloc_node
+
+struct shrinker;
+static inline void kmem_set_shrinker(kmem_cache_t *cachep,
+				struct shrinker *shrinker) {}
+
+#endif	/* __KERNEL__ */
+
+#endif	/* _LINUX_SLOB_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
