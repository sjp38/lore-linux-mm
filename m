Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id CAEF16B0255
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 10:17:22 -0400 (EDT)
Received: by oibi136 with SMTP id i136so28377757oib.3
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:17:22 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id n3si41688502pdp.202.2015.09.03.07.17.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 07:17:21 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so49186164pac.2
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:17:21 -0700 (PDT)
From: Hajime Tazaki <thehajime@gmail.com>
Subject: [PATCH v6 02/10] slab: add SLIB (Library memory allocator) for  arch/lib
Date: Thu,  3 Sep 2015 23:16:24 +0900
Message-Id: <1441289792-64064-3-git-send-email-thehajime@gmail.com>
In-Reply-To: <1441289792-64064-1-git-send-email-thehajime@gmail.com>
References: <1431494921-24746-1-git-send-email-tazaki@sfc.wide.ad.jp>
 <1441289792-64064-1-git-send-email-thehajime@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <thehajime@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

add SLIB allocator for arch/lib (CONFIG_LIB) to wrap kmalloc and co.
This will bring user's own allocator of libos: malloc(3) etc.

Signed-off-by: Hajime Tazaki <thehajime@gmail.com>
---
 include/linux/slab.h     |   6 +-
 include/linux/slib_def.h |  21 +++++
 mm/Makefile              |   1 +
 mm/slab.h                |   4 +
 mm/slib.c                | 209 +++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 240 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/slib_def.h
 create mode 100644 mm/slib.c

diff --git a/include/linux/slab.h b/include/linux/slab.h
index a99f0e5243e1..104c1aeec560 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -191,7 +191,7 @@ size_t ksize(const void *);
 #endif
 #endif
 
-#ifdef CONFIG_SLOB
+#if defined(CONFIG_SLOB) || defined(CONFIG_SLIB)
 /*
  * SLOB passes all requests larger than one page to the page allocator.
  * No kmalloc array is necessary since objects of different sizes can
@@ -356,6 +356,9 @@ kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
 }
 #endif
 
+#ifdef CONFIG_SLIB
+#include <linux/slib_def.h>
+#else
 static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
 {
 	unsigned int order = get_order(size);
@@ -434,6 +437,7 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
 	}
 	return __kmalloc(size, flags);
 }
+#endif /* CONFIG_SLIB */
 
 /*
  * Determine size used for the nth kmalloc cache.
diff --git a/include/linux/slib_def.h b/include/linux/slib_def.h
new file mode 100644
index 000000000000..d9fe7d59bd4e
--- /dev/null
+++ b/include/linux/slib_def.h
@@ -0,0 +1,21 @@
+#ifndef _LINUX_SLLB_DEF_H
+#define _LINUX_SLLB_DEF_H
+
+
+struct kmem_cache {
+	unsigned int object_size;
+	const char *name;
+	size_t size;
+	size_t align;
+	unsigned long flags;
+	void (*ctor)(void *);
+};
+
+void *__kmalloc(size_t size, gfp_t flags);
+void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
+static __always_inline void *kmalloc(size_t size, gfp_t flags)
+{
+	return __kmalloc(size, flags);
+}
+
+#endif /* _LINUX_SLLB_DEF_H */
diff --git a/mm/Makefile b/mm/Makefile
index 98c4eaeabdcb..7d8314f95ce3 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -46,6 +46,7 @@ obj-$(CONFIG_NUMA) 	+= mempolicy.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
 obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
+obj-$(CONFIG_SLIB) += slib.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
diff --git a/mm/slab.h b/mm/slab.h
index 8da63e4e470f..2cf4f0f67a19 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -37,6 +37,10 @@ struct kmem_cache {
 #include <linux/slub_def.h>
 #endif
 
+#ifdef CONFIG_SLIB
+#include <linux/slib_def.h>
+#endif
+
 #include <linux/memcontrol.h>
 
 /*
diff --git a/mm/slib.c b/mm/slib.c
new file mode 100644
index 000000000000..974c8aed0275
--- /dev/null
+++ b/mm/slib.c
@@ -0,0 +1,209 @@
+/*
+ * Library Slab Allocator (SLIB)
+ *
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include "sim.h"
+#include "sim-assert.h"
+#include <linux/page-flags.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/slib_def.h>
+
+/* glues */
+struct kmem_cache *files_cachep;
+
+void kfree(const void *p)
+{
+	unsigned long start;
+
+	if (p == 0)
+		return;
+	start = (unsigned long)p;
+	start -= sizeof(size_t);
+	lib_free((void *)start);
+}
+size_t ksize(const void *p)
+{
+	size_t *psize = (size_t *)p;
+
+	psize--;
+	return *psize;
+}
+void *__kmalloc(size_t size, gfp_t flags)
+{
+	void *p = lib_malloc(size + sizeof(size));
+	unsigned long start;
+
+	if (!p)
+		return NULL;
+
+	if (p != 0 && (flags & __GFP_ZERO))
+		lib_memset(p, 0, size + sizeof(size));
+	lib_memcpy(p, &size, sizeof(size));
+	start = (unsigned long)p;
+	return (void *)(start + sizeof(size));
+}
+
+void *__kmalloc_track_caller(size_t size, gfp_t flags, unsigned long caller)
+{
+	return kmalloc(size, flags);
+}
+
+void *krealloc(const void *p, size_t new_size, gfp_t flags)
+{
+	void *ret;
+
+	if (!new_size) {
+		kfree(p);
+		return ZERO_SIZE_PTR;
+	}
+
+	ret = __kmalloc(new_size, flags);
+	if (ret && p != ret)
+		kfree(p);
+
+	return ret;
+}
+
+struct kmem_cache *
+kmem_cache_create(const char *name, size_t size, size_t align,
+		  unsigned long flags, void (*ctor)(void *))
+{
+	struct kmem_cache *cache = kmalloc(sizeof(struct kmem_cache), flags);
+
+	if (!cache)
+		return NULL;
+	cache->name = name;
+	cache->size = size;
+	cache->align = align;
+	cache->flags = flags;
+	cache->ctor = ctor;
+	return cache;
+}
+void kmem_cache_destroy(struct kmem_cache *cache)
+{
+	kfree(cache);
+}
+int kmem_cache_shrink(struct kmem_cache *cache)
+{
+	return 1;
+}
+const char *kmem_cache_name(struct kmem_cache *cache)
+{
+	return cache->name;
+}
+void *kmem_cache_alloc(struct kmem_cache *cache, gfp_t flags)
+{
+	void *p = kmalloc(cache->size, flags);
+
+	if (p == 0)
+		return NULL;
+	if (cache->ctor)
+		(cache->ctor)(p);
+	return p;
+
+}
+void kmem_cache_free(struct kmem_cache *cache, void *p)
+{
+	kfree(p);
+}
+
+struct page *
+__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
+		       struct zonelist *zonelist, nodemask_t *nodemask)
+{
+	void *p;
+	struct page *page;
+	unsigned long pointer;
+
+	/* typically, called from networking code by alloc_page or */
+	/* directly with an order = 0. */
+	if (order)
+		return NULL;
+	p = lib_malloc(sizeof(struct page) + (1 << PAGE_SHIFT));
+	page = (struct page *)p;
+
+	atomic_set(&page->_count, 1);
+	page->flags = 0;
+	pointer = (unsigned long)page;
+	pointer += sizeof(struct page);
+	page->virtual = (void *)pointer;
+	return page;
+}
+void __free_pages(struct page *page, unsigned int order)
+{
+	/* typically, called from networking code by __free_page */
+	lib_assert(order == 0);
+	lib_free(page);
+}
+
+void put_page(struct page *page)
+{
+	if (atomic_dec_and_test(&page->_count))
+		lib_free(page);
+}
+unsigned long get_zeroed_page(gfp_t gfp_mask)
+{
+	return __get_free_pages(gfp_mask | __GFP_ZERO, 0);
+}
+
+void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
+{
+	return alloc_pages(gfp_mask, get_order(size));
+}
+
+unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
+{
+	int size = (1 << order) * PAGE_SIZE;
+	void *p = kmalloc(size, gfp_mask);
+
+	return (unsigned long)p;
+}
+void free_pages(unsigned long addr, unsigned int order)
+{
+	if (addr != 0)
+		kfree((void *)addr);
+}
+
+void *vmalloc(unsigned long size)
+{
+	return lib_malloc(size);
+}
+void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
+{
+	return kmalloc(size, gfp_mask);
+}
+void vfree(const void *addr)
+{
+	lib_free((void *)addr);
+}
+void *vmalloc_node(unsigned long size, int node)
+{
+	return lib_malloc(size);
+}
+void vmalloc_sync_all(void)
+{
+}
+void __percpu *__alloc_percpu_gfp(size_t size, size_t align, gfp_t gfp)
+{
+	return kzalloc(size, GFP_KERNEL);
+}
+void *__alloc_percpu(size_t size, size_t align)
+{
+	return kzalloc(size, GFP_KERNEL);
+}
+void free_percpu(void __percpu *ptr)
+{
+	kfree(ptr);
+}
+void *__alloc_bootmem_nopanic(unsigned long size,
+			      unsigned long align,
+			      unsigned long goal)
+{
+	return kzalloc(size, GFP_KERNEL);
+}
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
