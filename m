Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 127176B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 18:54:48 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id z107so12390071qgd.7
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 15:54:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l5si3299956qaf.97.2014.09.05.15.54.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Sep 2014 15:54:47 -0700 (PDT)
Date: Fri, 5 Sep 2014 18:54:35 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] slab: implement kmalloc guard
Message-ID: <alpine.LRH.2.02.1409051833510.9790@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Alasdair G. Kergon" <agk@redhat.com>, Mike Snitzer <msnitzer@redhat.com>, Milan Broz <gmazyland@gmail.com>, kkolasa@winsoft.pl, dm-devel@redhat.com

This patch adds a new option DEBUG_KMALLOC that makes it possible to 
detect writes beyond the end of space allocated with kmalloc. Normally, 
the kmalloc function rounds the size to the next power of two (there is 
exception to this rule - sizes 96 and 192). Slab debugging detects only 
writes beyond the end of the slab object, it is unable to detect writes 
beyond the end of kmallocated size that fit into the slab object.

The motivation for this patch was this: There was 6 year old bug in 
dm-crypt (d49ec52ff6ddcda178fc2476a109cf1bd1fa19ed) where the driver would 
write beyond the end of kmallocated space, but the bug went undetected 
because the write would fit into the power-of-two-sized slab object. Only 
recent changes to dm-crypt made the bug show up. There is similar problem 
in the nx-crypto driver in the function nx_crypto_ctx_init - again, 
because kmalloc rounds the size up to the next power of two, this bug went 
undetected.

This patch works for slab, slub and slob subsystems. The end of slab block 
can be found out with ksize (this patch renames it to __ksize). At the end 
of the block, we put a structure kmalloc_guard. This structure contains a 
magic number and a real size of the block - the exact size given to 
kmalloc. Just beyond the allocated block, we put an unaliged 64-bit magic 
number. If some code writes beyond the end of the allocated area, this 
magic number will be changed. This is detected at kfree time. We don't use 
kmalloc guard for slabs with the maximum size - this is for simplicity, so 
that we can leave the macro KMALLOC_MAX_SIZE unchanged.

I suggest backporting to the stable kernels - this patch doesn't fix any
bug, but it makes detection of other bugs possible, so it is benefical to
backport it.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Cc: stable@vger.kernel.org

---
 include/linux/slab.h |   43 +++++++++++++++++++--
 mm/Kconfig.debug     |    7 +++
 mm/slab.c            |   27 +++++++++----
 mm/slab_common.c     |  102 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/slob.c            |   23 +++++++----
 mm/slub.c            |   39 ++++++++++++++-----
 6 files changed, 208 insertions(+), 33 deletions(-)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2014-09-04 23:04:28.000000000 +0200
+++ linux-2.6/include/linux/slab.h	2014-09-04 23:05:03.000000000 +0200
@@ -143,7 +143,6 @@ void * __must_check __krealloc(const voi
 void * __must_check krealloc(const void *, size_t, gfp_t);
 void kfree(const void *);
 void kzfree(const void *);
-size_t ksize(const void *);
 
 /*
  * Some archs want to perform DMA into kmalloc caches and need a guaranteed
@@ -312,6 +311,37 @@ static __always_inline int kmalloc_index
 }
 #endif /* !CONFIG_SLOB */
 
+size_t __ksize(const void *ptr);
+
+#ifndef CONFIG_DEBUG_KMALLOC
+
+static inline size_t kmalloc_guard_size(size_t size)
+{
+	return size;
+}
+
+static inline void kmalloc_guard_setup(void *ptr, size_t size)
+{
+}
+
+static inline void kmalloc_guard_verify(const void *ptr)
+{
+}
+
+static inline size_t ksize(const void *ptr)
+{
+	return __ksize(ptr);
+}
+
+#else
+
+size_t kmalloc_guard_size(size_t size);
+void kmalloc_guard_setup(void *ptr, size_t size);
+void kmalloc_guard_verify(const void *ptr);
+size_t ksize(const void *ptr);
+
+#endif
+
 void *__kmalloc(size_t size, gfp_t flags);
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags);
 
@@ -385,8 +415,11 @@ kmalloc_order_trace(size_t size, gfp_t f
 
 static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
 {
-	unsigned int order = get_order(size);
-	return kmalloc_order_trace(size, flags, order);
+	void *ret;
+	unsigned int order = get_order(kmalloc_guard_size(size));
+	ret = kmalloc_order_trace(size, flags, order);
+	kmalloc_guard_setup(ret, size);
+	return ret;
 }
 
 /**
@@ -444,6 +477,7 @@ static __always_inline void *kmalloc_lar
  */
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
+#ifndef CONFIG_DEBUG_KMALLOC
 	if (__builtin_constant_p(size)) {
 		if (size > KMALLOC_MAX_CACHE_SIZE)
 			return kmalloc_large(size, flags);
@@ -459,6 +493,7 @@ static __always_inline void *kmalloc(siz
 		}
 #endif
 	}
+#endif
 	return __kmalloc(size, flags);
 }
 
@@ -484,7 +519,7 @@ static __always_inline int kmalloc_size(
 
 static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
-#ifndef CONFIG_SLOB
+#if !defined(CONFIG_SLOB) && !defined(CONFIG_DEBUG_KMALLOC)
 	if (__builtin_constant_p(size) &&
 		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & GFP_DMA)) {
 		int i = kmalloc_index(size);
Index: linux-2.6/mm/Kconfig.debug
===================================================================
--- linux-2.6.orig/mm/Kconfig.debug	2014-09-02 23:12:58.000000000 +0200
+++ linux-2.6/mm/Kconfig.debug	2014-09-04 23:05:04.000000000 +0200
@@ -17,6 +17,13 @@ config DEBUG_PAGEALLOC
 	  that would result in incorrect warnings of memory corruption after
 	  a resume because free pages are not saved to the suspend image.
 
+config DEBUG_KMALLOC
+	bool "Kmalloc guard"
+	depends on DEBUG_KERNEL
+	---help---
+	  Verify that the kernel doesn't modify memory allocated with kmalloc
+	  beyond the requested size.
+
 config WANT_PAGE_DEBUG_FLAGS
 	bool
 
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2014-09-04 23:04:31.000000000 +0200
+++ linux-2.6/mm/slab.c	2014-09-04 23:05:04.000000000 +0200
@@ -253,8 +253,8 @@ static void cache_reap(struct work_struc
 
 static int slab_early_init = 1;
 
-#define INDEX_AC kmalloc_index(sizeof(struct arraycache_init))
-#define INDEX_NODE kmalloc_index(sizeof(struct kmem_cache_node))
+#define INDEX_AC kmalloc_index(kmalloc_guard_size(sizeof(struct arraycache_init)))
+#define INDEX_NODE kmalloc_index(kmalloc_guard_size(sizeof(struct kmem_cache_node)))
 
 static void kmem_cache_node_init(struct kmem_cache_node *parent)
 {
@@ -3496,11 +3496,16 @@ static __always_inline void *
 __do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller)
 {
 	struct kmem_cache *cachep;
+	void *ret;
 
-	cachep = kmalloc_slab(size, flags);
+	cachep = kmalloc_slab(kmalloc_guard_size(size), flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
-	return kmem_cache_alloc_node_trace(cachep, flags, node, size);
+	ret = kmem_cache_alloc_node_trace(cachep, flags, node, size);
+
+	kmalloc_guard_setup(ret, size);
+
+	return ret;
 }
 
 #if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
@@ -3537,7 +3542,7 @@ static __always_inline void *__do_kmallo
 	struct kmem_cache *cachep;
 	void *ret;
 
-	cachep = kmalloc_slab(size, flags);
+	cachep = kmalloc_slab(kmalloc_guard_size(size), flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
 	ret = slab_alloc(cachep, flags, caller);
@@ -3545,6 +3550,8 @@ static __always_inline void *__do_kmallo
 	trace_kmalloc(caller, ret,
 		      size, cachep->size, flags);
 
+	kmalloc_guard_setup(ret, size);
+
 	return ret;
 }
 
@@ -3612,6 +3619,8 @@ void kfree(const void *objp)
 
 	trace_kfree(_RET_IP_, objp);
 
+	kmalloc_guard_verify(objp);
+
 	if (unlikely(ZERO_OR_NULL_PTR(objp)))
 		return;
 	local_irq_save(flags);
@@ -4296,18 +4305,18 @@ module_init(slab_proc_init);
 #endif
 
 /**
- * ksize - get the actual amount of memory allocated for a given object
+ * __ksize - get the actual amount of memory allocated for a given object
  * @objp: Pointer to the object
  *
  * kmalloc may internally round up allocations and return more memory
- * than requested. ksize() can be used to determine the actual amount of
+ * than requested. __ksize() can be used to determine the actual amount of
  * memory allocated. The caller may use this additional memory, even though
  * a smaller amount of memory was initially specified with the kmalloc call.
  * The caller must guarantee that objp points to a valid object previously
  * allocated with either kmalloc() or kmem_cache_alloc(). The object
  * must not be freed during the duration of the call.
  */
-size_t ksize(const void *objp)
+size_t __ksize(const void *objp)
 {
 	BUG_ON(!objp);
 	if (unlikely(objp == ZERO_SIZE_PTR))
@@ -4315,4 +4324,4 @@ size_t ksize(const void *objp)
 
 	return virt_to_cache(objp)->object_size;
 }
-EXPORT_SYMBOL(ksize);
+EXPORT_SYMBOL(__ksize);
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2014-09-04 23:04:31.000000000 +0200
+++ linux-2.6/mm/slob.c	2014-09-04 23:05:04.000000000 +0200
@@ -429,26 +429,27 @@ __do_kmalloc_node(size_t size, gfp_t gfp
 	unsigned int *m;
 	int align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 	void *ret;
+	size_t real_size = kmalloc_guard_size(size);
 
 	gfp &= gfp_allowed_mask;
 
 	lockdep_trace_alloc(gfp);
 
-	if (size < PAGE_SIZE - align) {
-		if (!size)
+	if (real_size < PAGE_SIZE - align) {
+		if (!real_size)
 			return ZERO_SIZE_PTR;
 
-		m = slob_alloc(size + align, gfp, align, node);
+		m = slob_alloc(real_size + align, gfp, align, node);
 
 		if (!m)
 			return NULL;
-		*m = size;
+		*m = real_size;
 		ret = (void *)m + align;
 
 		trace_kmalloc_node(caller, ret,
-				   size, size + align, gfp, node);
+				   size, real_size + align, gfp, node);
 	} else {
-		unsigned int order = get_order(size);
+		unsigned int order = get_order(real_size);
 
 		if (likely(order))
 			gfp |= __GFP_COMP;
@@ -458,6 +459,8 @@ __do_kmalloc_node(size_t size, gfp_t gfp
 				   size, PAGE_SIZE << order, gfp, node);
 	}
 
+	kmalloc_guard_setup(ret, size);
+
 	kmemleak_alloc(ret, size, 1, gfp);
 	return ret;
 }
@@ -489,6 +492,8 @@ void kfree(const void *block)
 
 	trace_kfree(_RET_IP_, block);
 
+	kmalloc_guard_verify(block);
+
 	if (unlikely(ZERO_OR_NULL_PTR(block)))
 		return;
 	kmemleak_free(block);
@@ -503,8 +508,8 @@ void kfree(const void *block)
 }
 EXPORT_SYMBOL(kfree);
 
-/* can't use ksize for kmem_cache_alloc memory, only kmalloc */
-size_t ksize(const void *block)
+/* can't use __ksize for kmem_cache_alloc memory, only kmalloc */
+size_t __ksize(const void *block)
 {
 	struct page *sp;
 	int align;
@@ -522,7 +527,7 @@ size_t ksize(const void *block)
 	m = (unsigned int *)(block - align);
 	return SLOB_UNITS(*m) * SLOB_UNIT;
 }
-EXPORT_SYMBOL(ksize);
+EXPORT_SYMBOL(__ksize);
 
 int __kmem_cache_create(struct kmem_cache *c, unsigned long flags)
 {
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2014-09-04 23:04:31.000000000 +0200
+++ linux-2.6/mm/slub.c	2014-09-04 23:05:04.000000000 +0200
@@ -3252,11 +3252,12 @@ void *__kmalloc(size_t size, gfp_t flags
 {
 	struct kmem_cache *s;
 	void *ret;
+	size_t real_size = kmalloc_guard_size(size);
 
-	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE))
+	if (unlikely(real_size > KMALLOC_MAX_CACHE_SIZE))
 		return kmalloc_large(size, flags);
 
-	s = kmalloc_slab(size, flags);
+	s = kmalloc_slab(real_size, flags);
 
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
@@ -3265,6 +3266,8 @@ void *__kmalloc(size_t size, gfp_t flags
 
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
+	kmalloc_guard_setup(ret, size);
+
 	return ret;
 }
 EXPORT_SYMBOL(__kmalloc);
@@ -3276,11 +3279,14 @@ static void *kmalloc_large_node(size_t s
 	void *ptr = NULL;
 
 	flags |= __GFP_COMP | __GFP_NOTRACK;
-	page = alloc_kmem_pages_node(node, flags, get_order(size));
+	page = alloc_kmem_pages_node(node, flags, get_order(kmalloc_guard_size(size)));
 	if (page)
 		ptr = page_address(page);
 
 	kmalloc_large_node_hook(ptr, size, flags);
+
+	kmalloc_guard_setup(ptr, size);
+
 	return ptr;
 }
 
@@ -3288,8 +3294,9 @@ void *__kmalloc_node(size_t size, gfp_t
 {
 	struct kmem_cache *s;
 	void *ret;
+	size_t real_size = kmalloc_guard_size(size);
 
-	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE)) {
+	if (unlikely(real_size > KMALLOC_MAX_CACHE_SIZE)) {
 		ret = kmalloc_large_node(size, flags, node);
 
 		trace_kmalloc_node(_RET_IP_, ret,
@@ -3299,7 +3306,7 @@ void *__kmalloc_node(size_t size, gfp_t
 		return ret;
 	}
 
-	s = kmalloc_slab(size, flags);
+	s = kmalloc_slab(real_size, flags);
 
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
@@ -3308,12 +3315,14 @@ void *__kmalloc_node(size_t size, gfp_t
 
 	trace_kmalloc_node(_RET_IP_, ret, size, s->size, flags, node);
 
+	kmalloc_guard_setup(ret, size);
+
 	return ret;
 }
 EXPORT_SYMBOL(__kmalloc_node);
 #endif
 
-size_t ksize(const void *object)
+size_t __ksize(const void *object)
 {
 	struct page *page;
 
@@ -3329,7 +3338,7 @@ size_t ksize(const void *object)
 
 	return slab_ksize(page->slab_cache);
 }
-EXPORT_SYMBOL(ksize);
+EXPORT_SYMBOL(__ksize);
 
 void kfree(const void *x)
 {
@@ -3338,6 +3347,8 @@ void kfree(const void *x)
 
 	trace_kfree(_RET_IP_, x);
 
+	kmalloc_guard_verify(x);
+
 	if (unlikely(ZERO_OR_NULL_PTR(x)))
 		return;
 
@@ -3787,11 +3798,12 @@ void *__kmalloc_track_caller(size_t size
 {
 	struct kmem_cache *s;
 	void *ret;
+	size_t real_size = kmalloc_guard_size(size);
 
-	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE))
+	if (unlikely(real_size > KMALLOC_MAX_CACHE_SIZE))
 		return kmalloc_large(size, gfpflags);
 
-	s = kmalloc_slab(size, gfpflags);
+	s = kmalloc_slab(real_size, gfpflags);
 
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
@@ -3801,6 +3813,8 @@ void *__kmalloc_track_caller(size_t size
 	/* Honor the call site pointer we received. */
 	trace_kmalloc(caller, ret, size, s->size, gfpflags);
 
+	kmalloc_guard_setup(ret, size);
+
 	return ret;
 }
 
@@ -3810,8 +3824,9 @@ void *__kmalloc_node_track_caller(size_t
 {
 	struct kmem_cache *s;
 	void *ret;
+	size_t real_size = kmalloc_guard_size(size);
 
-	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE)) {
+	if (unlikely(real_size > KMALLOC_MAX_CACHE_SIZE)) {
 		ret = kmalloc_large_node(size, gfpflags, node);
 
 		trace_kmalloc_node(caller, ret,
@@ -3821,7 +3836,7 @@ void *__kmalloc_node_track_caller(size_t
 		return ret;
 	}
 
-	s = kmalloc_slab(size, gfpflags);
+	s = kmalloc_slab(real_size, gfpflags);
 
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
@@ -3831,6 +3846,8 @@ void *__kmalloc_node_track_caller(size_t
 	/* Honor the call site pointer we received. */
 	trace_kmalloc_node(caller, ret, size, s->size, gfpflags, node);
 
+	kmalloc_guard_setup(ret, size);
+
 	return ret;
 }
 #endif
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2014-09-04 23:04:31.000000000 +0200
+++ linux-2.6/mm/slab_common.c	2014-09-04 23:05:04.000000000 +0200
@@ -18,6 +18,7 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 #include <asm/page.h>
+#include <asm/unaligned.h>
 #include <linux/memcontrol.h>
 
 #define CREATE_TRACE_POINTS
@@ -639,6 +640,107 @@ void *kmalloc_order_trace(size_t size, g
 EXPORT_SYMBOL(kmalloc_order_trace);
 #endif
 
+#ifdef CONFIG_DEBUG_KMALLOC
+
+#define KMALLOC_GUARD_MAGIC1	0x1abe11d0d295d462ULL
+#define KMALLOC_GUARD_MAGIC2	0xefa7d205787335f6ULL
+
+struct kmalloc_guard {
+	size_t size;
+	unsigned long long magic2;
+};
+
+#define KMALLOC_GUARD_OVERHEAD	(sizeof(unsigned long long) + sizeof(struct kmalloc_guard))
+
+#define guard_location(ptr, real_size)	((struct kmalloc_guard *)((char *)(ptr) + (real_size)) - 1)
+
+size_t kmalloc_guard_size(size_t size)
+{
+	size_t new;
+	if (unlikely((size - 1) >= KMALLOC_MAX_SIZE))
+		return size;
+	new = size + KMALLOC_GUARD_OVERHEAD;
+	if (unlikely(new > KMALLOC_MAX_SIZE))
+		return KMALLOC_MAX_SIZE;
+	return new;
+}
+
+void kmalloc_guard_setup(void *ptr, size_t size)
+{
+	size_t real_size;
+	struct kmalloc_guard *g;
+
+	if (unlikely(ZERO_OR_NULL_PTR(ptr)))
+		return;
+
+	real_size = __ksize(ptr);
+	if (unlikely(real_size >= KMALLOC_MAX_SIZE))
+		return;
+
+	if (unlikely(size + KMALLOC_GUARD_OVERHEAD > real_size)) {
+		pr_err("kmalloc: size not padded, size %zu, allocated size %zu\n",
+			size, real_size);
+		dump_stack();
+		return;
+	}
+
+	put_unaligned(KMALLOC_GUARD_MAGIC1, (unsigned long long *)((char *)ptr + size));
+	g = guard_location(ptr, real_size);
+	g->size = size;
+	g->magic2 = KMALLOC_GUARD_MAGIC2;
+}
+
+void kmalloc_guard_verify(const void *ptr)
+{
+	size_t real_size;
+	const struct kmalloc_guard *g;
+	unsigned long long magic;
+
+	if (unlikely(ZERO_OR_NULL_PTR(ptr)))
+		return;
+
+	real_size = __ksize(ptr);
+	if (unlikely(real_size >= KMALLOC_MAX_SIZE))
+		return;
+
+	g = guard_location(ptr, real_size);
+	if (unlikely(g->magic2 != KMALLOC_GUARD_MAGIC2) ||
+	    unlikely(g->size > real_size - KMALLOC_GUARD_OVERHEAD)) {
+		pr_err("kmalloc: structure damaged, pointer %p, allocated size %zu, magic2 %llx, size %zu\n",
+			ptr, real_size, g->magic2, g->size);
+		dump_stack();
+		return;
+	}
+
+	magic = get_unaligned((const unsigned long long *)((const char *)ptr + g->size));
+	if (unlikely(magic != KMALLOC_GUARD_MAGIC1)) {
+		pr_err("kmalloc: red zone damaged, pointer %p, real_size %zu, size %zu, red zone %llx\n",
+			ptr, real_size, g->size, magic);
+		dump_stack();
+		return;
+	}
+}
+
+size_t ksize(const void *ptr)
+{
+	size_t real_size;
+	const struct kmalloc_guard *g;
+
+	kmalloc_guard_verify(ptr);
+
+	real_size = __ksize(ptr);
+	if (unlikely(!real_size) ||
+	    unlikely(real_size >= KMALLOC_MAX_SIZE))
+		return real_size;
+
+	g = guard_location(ptr, real_size);
+
+	return g->size;
+}
+EXPORT_SYMBOL(ksize);
+
+#endif
+
 #ifdef CONFIG_SLABINFO
 
 #ifdef CONFIG_SLAB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
