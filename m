Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4B5956B0073
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 05:41:33 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so119995839pac.1
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 02:41:33 -0700 (PDT)
Received: from mail.sfc.wide.ad.jp (shonan.sfc.wide.ad.jp. [203.178.142.130])
        by mx.google.com with ESMTPS id n9si15958381pap.184.2015.04.17.02.41.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 02:41:32 -0700 (PDT)
From: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Subject: [RFC PATCH v2 04/11] lib: memory management (kernel glue code)
Date: Fri, 17 Apr 2015 18:36:07 +0900
Message-Id: <1429263374-57517-5-git-send-email-tazaki@sfc.wide.ad.jp>
In-Reply-To: <1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
 <1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Jhristoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

Signed-off-by: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
---
 arch/lib/slab.c | 203 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 203 insertions(+)
 create mode 100644 arch/lib/slab.c

diff --git a/arch/lib/slab.c b/arch/lib/slab.c
new file mode 100644
index 0000000..a08f736
--- /dev/null
+++ b/arch/lib/slab.c
@@ -0,0 +1,203 @@
+/*
+ * glue code for library version of Linux kernel
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
