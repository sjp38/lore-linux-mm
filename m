Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 92BA96B0078
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 11:01:41 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so5168862pad.41
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 08:01:41 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id ru9si12131915pab.173.2014.11.27.08.01.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 27 Nov 2014 08:01:38 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFP0013QGNEW870@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 27 Nov 2014 16:04:26 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v8 08/12] mm: slub: add kernel address sanitizer support for
 slub allocator
Date: Thu, 27 Nov 2014 19:00:52 +0300
Message-id: <1417104057-20335-9-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

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
 mm/slub.c             | 36 ++++++++++++++++++--
 9 files changed, 192 insertions(+), 6 deletions(-)

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
index 8a2457d..5dc0d69 100644
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
index 386cc8b..1fa4fe8 100644
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
index 930b52d..088c68e 100644
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
index b336073..7bb20ad 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -30,6 +30,7 @@
 #include <linux/kasan.h>
 
 #include "kasan.h"
+#include "../slab.h"
 
 /*
  * Poisons the shadow memory for 'size' bytes starting from 'addr'.
@@ -261,6 +262,97 @@ void kasan_free_pages(struct page *page, unsigned int order)
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
+	unsigned long size = cache->object_size;
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
index 2a6a961..049349b 100644
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
index 8ac3b6b..185d04c 100644
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
@@ -76,11 +81,31 @@ static void print_error_description(struct access_info *info)
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
index e03dd6f..4dcbc2d 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -789,6 +789,7 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 	page = alloc_kmem_pages(flags, order);
 	ret = page ? page_address(page) : NULL;
 	kmemleak_alloc(ret, size, 1, flags);
+	kasan_kmalloc_large(ret, size);
 	return ret;
 }
 EXPORT_SYMBOL(kmalloc_order);
@@ -973,8 +974,10 @@ static __always_inline void *__do_krealloc(const void *p, size_t new_size,
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
index 88ad8b8..cb2aba4 100644
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
@@ -1264,6 +1269,7 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s,
 	flags &= gfp_allowed_mask;
 	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
 	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags, flags);
+	kasan_slab_alloc(s, object);
 }
 
 static inline void slab_free_hook(struct kmem_cache *s, void *x)
@@ -1287,6 +1293,8 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
 #endif
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(x, s->object_size);
+
+	kasan_slab_free(s, x);
 }
 
 /*
@@ -1381,8 +1389,11 @@ static void setup_object(struct kmem_cache *s, struct page *page,
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
@@ -1419,8 +1430,10 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
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
@@ -2491,6 +2504,7 @@ void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
 {
 	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
 	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
+	kasan_kmalloc(s, ret, size);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_trace);
@@ -2517,6 +2531,8 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, s->size, gfpflags, node);
+
+	kasan_kmalloc(s, ret, size);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
@@ -2900,6 +2916,7 @@ static void early_kmem_cache_node_alloc(int node)
 	init_object(kmem_cache_node, n, SLUB_RED_ACTIVE);
 	init_tracking(kmem_cache_node, n);
 #endif
+	kasan_kmalloc(kmem_cache_node, n, sizeof(struct kmem_cache_node));
 	init_kmem_cache_node(n);
 	inc_slabs_node(kmem_cache_node, node, page->objects);
 
@@ -3272,6 +3289,8 @@ void *__kmalloc(size_t size, gfp_t flags)
 
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
+	kasan_kmalloc(s, ret, size);
+
 	return ret;
 }
 EXPORT_SYMBOL(__kmalloc);
@@ -3315,12 +3334,14 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 
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
 
@@ -3336,6 +3357,15 @@ size_t ksize(const void *object)
 
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
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
