Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8F22B90001A
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 12:47:56 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v10so5981963pde.18
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 09:47:56 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id os3si5943004pac.97.2014.10.27.09.47.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Oct 2014 09:47:53 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NE4000EE44F13A0@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Oct 2014 16:50:39 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v5 09/12] mm: slub: add kernel address sanitizer support for
 slub allocator
Date: Mon, 27 Oct 2014 19:46:56 +0300
Message-id: <1414428419-17860-10-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1414428419-17860-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1414428419-17860-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

With this patch kasan will be able to catch bugs in memory allocated
by slub.
Initially all objects in newly allocated slab page, marked as free.
Later, when allocation of slub object happens, requested by caller
number of bytes marked as accessible, and the rest of the object
(including slub's metadata) marked as redzone (inaccessible).

We also mark object as accessible if ksize was called for this object.
There is some places in kernel where ksize function is called to inquire
size of really allocated area. Such callers could validly access whole
allocated memory, so it should be marked as accessible.

Code in slub.c and slab_common.c files could validly access to object's
metadata, so instrumentation for this files are disabled.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 include/linux/kasan.h | 21 ++++++++++++
 include/linux/slab.h  | 11 ++++--
 lib/Kconfig.kasan     |  1 +
 mm/Makefile           |  3 ++
 mm/kasan/kasan.c      | 92 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.h      |  4 +++
 mm/kasan/report.c     | 25 ++++++++++++++
 mm/slab_common.c      |  5 ++-
 mm/slub.c             | 35 ++++++++++++++++++--
 9 files changed, 191 insertions(+), 6 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 9714fba..0463b90 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -32,6 +32,16 @@ void kasan_unpoison_shadow(const void *address, size_t size);
 
 void kasan_alloc_pages(struct page *page, unsigned int order);
 void kasan_free_pages(struct page *page, unsigned int order);
+void kasan_mark_slab_padding(struct kmem_cache *s, void *object,
+			struct page *page);
+
+void kasan_kmalloc_large(const void *ptr, size_t size);
+void kasan_kfree_large(const void *ptr);
+void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size);
+void kasan_krealloc(const void *object, size_t new_size);
+
+void kasan_slab_alloc(struct kmem_cache *s, void *object);
+void kasan_slab_free(struct kmem_cache *s, void *object);
 
 #else /* CONFIG_KASAN */
 
@@ -42,6 +52,17 @@ static inline void kasan_disable_local(void) {}
 
 static inline void kasan_alloc_pages(struct page *page, unsigned int order) {}
 static inline void kasan_free_pages(struct page *page, unsigned int order) {}
+static inline void kasan_mark_slab_padding(struct kmem_cache *s, void *object,
+					struct page *page) {}
+
+static inline void kasan_kmalloc_large(void *ptr, size_t size) {}
+static inline void kasan_kfree_large(const void *ptr) {}
+static inline void kasan_kmalloc(struct kmem_cache *s, const void *object,
+				size_t size) {}
+static inline void kasan_krealloc(const void *object, size_t new_size) {}
+
+static inline void kasan_slab_alloc(struct kmem_cache *s, void *object) {}
+static inline void kasan_slab_free(struct kmem_cache *s, void *object) {}
 
 #endif /* CONFIG_KASAN */
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index c265bec..5f97037 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -104,6 +104,7 @@
 				(unsigned long)ZERO_SIZE_PTR)
 
 #include <linux/kmemleak.h>
+#include <linux/kasan.h>
 
 struct mem_cgroup;
 /*
@@ -326,7 +327,10 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
 static __always_inline void *kmem_cache_alloc_trace(struct kmem_cache *s,
 		gfp_t flags, size_t size)
 {
-	return kmem_cache_alloc(s, flags);
+	void *ret = kmem_cache_alloc(s, flags);
+
+	kasan_kmalloc(s, ret, size);
+	return ret;
 }
 
 static __always_inline void *
@@ -334,7 +338,10 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
 			      gfp_t gfpflags,
 			      int node, size_t size)
 {
-	return kmem_cache_alloc_node(s, gfpflags, node);
+	void *ret = kmem_cache_alloc_node(s, gfpflags, node);
+
+	kasan_kmalloc(s, ret, size);
+	return ret;
 }
 #endif /* CONFIG_TRACING */
 
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index b458a00..d16b899 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -6,6 +6,7 @@ if HAVE_ARCH_KASAN
 config KASAN
 	bool "AddressSanitizer: runtime memory debugger"
 	depends on !MEMORY_HOTPLUG
+	depends on SLUB_DEBUG
 	help
 	  Enables address sanitizer - runtime memory debugger,
 	  designed to find out-of-bounds accesses and use-after-free bugs.
diff --git a/mm/Makefile b/mm/Makefile
index 63b7871..aa16cec 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -2,6 +2,9 @@
 # Makefile for the linux memory manager.
 #
 
+KASAN_SANITIZE_slab_common.o := n
+KASAN_SANITIZE_slub.o := n
+
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= gup.o highmem.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 2853c92..0ce187c 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -30,6 +30,7 @@
 #include <linux/kasan.h>
 
 #include "kasan.h"
+#include "../slab.h"
 
 static inline bool kasan_enabled(void)
 {
@@ -273,6 +274,97 @@ void kasan_free_pages(struct page *page, unsigned int order)
 				KASAN_FREE_PAGE);
 }
 
+void kasan_mark_slab_padding(struct kmem_cache *s, void *object,
+			struct page *page)
+{
+	unsigned long object_end = (unsigned long)object + s->size;
+	unsigned long padding_start = round_up(object_end,
+					KASAN_SHADOW_SCALE_SIZE);
+	unsigned long padding_end = (unsigned long)page_address(page) +
+					(PAGE_SIZE << compound_order(page));
+	size_t size = padding_end - padding_start;
+
+	kasan_poison_shadow((void *)padding_start, size, KASAN_SLAB_PADDING);
+}
+
+void kasan_slab_alloc(struct kmem_cache *cache, void *object)
+{
+	kasan_kmalloc(cache, object, cache->object_size);
+}
+
+void kasan_slab_free(struct kmem_cache *cache, void *object)
+{
+	unsigned long size = cache->size;
+	unsigned long rounded_up_size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
+
+	/* RCU slabs could be legally used after free within the RCU period */
+	if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
+		return;
+
+	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
+}
+
+void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size)
+{
+	unsigned long redzone_start;
+	unsigned long redzone_end;
+
+	if (unlikely(object == NULL))
+		return;
+
+	redzone_start = round_up((unsigned long)(object + size),
+				KASAN_SHADOW_SCALE_SIZE);
+	redzone_end = (unsigned long)object + cache->size;
+
+	kasan_unpoison_shadow(object, size);
+	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
+		KASAN_KMALLOC_REDZONE);
+
+}
+EXPORT_SYMBOL(kasan_kmalloc);
+
+void kasan_kmalloc_large(const void *ptr, size_t size)
+{
+	struct page *page;
+	unsigned long redzone_start;
+	unsigned long redzone_end;
+
+	if (unlikely(ptr == NULL))
+		return;
+
+	page = virt_to_page(ptr);
+	redzone_start = round_up((unsigned long)(ptr + size),
+				KASAN_SHADOW_SCALE_SIZE);
+	redzone_end = (unsigned long)ptr + (PAGE_SIZE << compound_order(page));
+
+	kasan_unpoison_shadow(ptr, size);
+	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
+		KASAN_PAGE_REDZONE);
+}
+
+void kasan_krealloc(const void *object, size_t size)
+{
+	struct page *page;
+
+	if (unlikely(object == ZERO_SIZE_PTR))
+		return;
+
+	page = virt_to_head_page(object);
+
+	if (unlikely(!PageSlab(page)))
+		kasan_kmalloc_large(object, size);
+	else
+		kasan_kmalloc(page->slab_cache, object, size);
+}
+
+void kasan_kfree_large(const void *ptr)
+{
+	struct page *page = virt_to_page(ptr);
+
+	kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
+			KASAN_FREE_PAGE);
+}
+
 void __asan_load1(unsigned long addr)
 {
 	check_memory_region(addr, 1, false);
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index ee572c4..b70a3d1 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -7,6 +7,10 @@
 #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
 
 #define KASAN_FREE_PAGE         0xFF  /* page was freed */
+#define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
+#define KASAN_SLAB_PADDING      0xFD  /* Slab page padding, does not belong to any slub object */
+#define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
+#define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
 #define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memory */
 
 struct access_info {
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 707323b..03ce28e 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -24,6 +24,7 @@
 #include <linux/kasan.h>
 
 #include "kasan.h"
+#include "../slab.h"
 
 /* Shadow layout customization. */
 #define SHADOW_BYTES_PER_BLOCK 1
@@ -54,10 +55,14 @@ static void print_error_description(struct access_info *info)
 	shadow_val = *(u8 *)kasan_mem_to_shadow(info->first_bad_addr);
 
 	switch (shadow_val) {
+	case KASAN_PAGE_REDZONE:
+	case KASAN_SLAB_PADDING:
+	case KASAN_KMALLOC_REDZONE:
 	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
 		bug_type = "out of bounds access";
 		break;
 	case KASAN_FREE_PAGE:
+	case KASAN_KMALLOC_FREE:
 		bug_type = "use after free";
 		break;
 	case KASAN_SHADOW_GAP:
@@ -73,11 +78,31 @@ static void print_error_description(struct access_info *info)
 static void print_address_description(struct access_info *info)
 {
 	struct page *page;
+	struct kmem_cache *cache;
 	u8 shadow_val = *(u8 *)kasan_mem_to_shadow(info->first_bad_addr);
 
 	page = virt_to_head_page((void *)info->access_addr);
 
 	switch (shadow_val) {
+	case KASAN_SLAB_PADDING:
+		cache = page->slab_cache;
+		slab_err(cache, page, "access to slab redzone");
+		dump_stack();
+		break;
+	case KASAN_KMALLOC_FREE:
+	case KASAN_KMALLOC_REDZONE:
+	case 1 ... KASAN_SHADOW_SCALE_SIZE - 1:
+		if (PageSlab(page)) {
+			void *object;
+			void *slab_page = page_address(page);
+
+			cache = page->slab_cache;
+			object = virt_to_obj(cache, slab_page,
+					(void *)info->access_addr);
+			object_err(cache, page, object, "kasan error");
+			break;
+		}
+	case KASAN_PAGE_REDZONE:
 	case KASAN_FREE_PAGE:
 		dump_page(page, "kasan error");
 		dump_stack();
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 4069442..ff8d1a5 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -785,6 +785,7 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 	page = alloc_kmem_pages(flags, order);
 	ret = page ? page_address(page) : NULL;
 	kmemleak_alloc(ret, size, 1, flags);
+	kasan_kmalloc_large(ret, size);
 	return ret;
 }
 EXPORT_SYMBOL(kmalloc_order);
@@ -959,8 +960,10 @@ static __always_inline void *__do_krealloc(const void *p, size_t new_size,
 	if (p)
 		ks = ksize(p);
 
-	if (ks >= new_size)
+	if (ks >= new_size) {
+		kasan_krealloc((void *)p, new_size);
 		return (void *)p;
+	}
 
 	ret = kmalloc_track_caller(new_size, flags);
 	if (ret && p)
diff --git a/mm/slub.c b/mm/slub.c
index 2116ccd..b1f614e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -33,6 +33,7 @@
 #include <linux/stacktrace.h>
 #include <linux/prefetch.h>
 #include <linux/memcontrol.h>
+#include <linux/kasan.h>
 
 #include <trace/events/kmem.h>
 
@@ -469,10 +470,12 @@ static int disable_higher_order_debug;
 
 static inline void metadata_access_enable(void)
 {
+	kasan_disable_local();
 }
 
 static inline void metadata_access_disable(void)
 {
+	kasan_enable_local();
 }
 
 /*
@@ -1242,11 +1245,13 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
 static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
 {
 	kmemleak_alloc(ptr, size, 1, flags);
+	kasan_kmalloc_large(ptr, size);
 }
 
 static inline void kfree_hook(const void *x)
 {
 	kmemleak_free(x);
+	kasan_kfree_large(x);
 }
 
 static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
@@ -1264,11 +1269,13 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s,
 	flags &= gfp_allowed_mask;
 	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
 	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags, flags);
+	kasan_slab_alloc(s, object);
 }
 
 static inline void slab_free_hook(struct kmem_cache *s, void *x)
 {
 	kmemleak_free_recursive(x, s->flags);
+	kasan_slab_free(s, x);
 
 	/*
 	 * Trouble is that we may no longer disable interrupts in the fast path
@@ -1381,8 +1388,11 @@ static void setup_object(struct kmem_cache *s, struct page *page,
 				void *object)
 {
 	setup_object_debug(s, page, object);
-	if (unlikely(s->ctor))
+	if (unlikely(s->ctor)) {
+		kasan_slab_alloc(s, object);
 		s->ctor(object);
+	}
+	kasan_slab_free(s, object);
 }
 
 static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
@@ -1416,8 +1426,10 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 		setup_object(s, page, p);
 		if (likely(idx < page->objects))
 			set_freepointer(s, p, p + s->size);
-		else
+		else {
 			set_freepointer(s, p, NULL);
+			kasan_mark_slab_padding(s, p, page);
+		}
 	}
 
 	page->freelist = start;
@@ -2488,6 +2500,7 @@ void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
 {
 	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
 	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
+	kasan_kmalloc(s, ret, size);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_trace);
@@ -2514,6 +2527,8 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, s->size, gfpflags, node);
+
+	kasan_kmalloc(s, ret, size);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
@@ -2897,6 +2912,7 @@ static void early_kmem_cache_node_alloc(int node)
 	init_object(kmem_cache_node, n, SLUB_RED_ACTIVE);
 	init_tracking(kmem_cache_node, n);
 #endif
+	kasan_kmalloc(kmem_cache_node, n, sizeof(struct kmem_cache_node));
 	init_kmem_cache_node(n);
 	inc_slabs_node(kmem_cache_node, node, page->objects);
 
@@ -3269,6 +3285,8 @@ void *__kmalloc(size_t size, gfp_t flags)
 
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
+	kasan_kmalloc(s, ret, size);
+
 	return ret;
 }
 EXPORT_SYMBOL(__kmalloc);
@@ -3312,12 +3330,14 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 
 	trace_kmalloc_node(_RET_IP_, ret, size, s->size, flags, node);
 
+	kasan_kmalloc(s, ret, size);
+
 	return ret;
 }
 EXPORT_SYMBOL(__kmalloc_node);
 #endif
 
-size_t ksize(const void *object)
+static size_t __ksize(const void *object)
 {
 	struct page *page;
 
@@ -3333,6 +3353,15 @@ size_t ksize(const void *object)
 
 	return slab_ksize(page->slab_cache);
 }
+
+size_t ksize(const void *object)
+{
+	size_t size = __ksize(object);
+	/* We assume that ksize callers could use whole allocated area,
+	   so we need unpoison this area. */
+	kasan_krealloc(object, size);
+	return size;
+}
 EXPORT_SYMBOL(ksize);
 
 void kfree(const void *x)
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
