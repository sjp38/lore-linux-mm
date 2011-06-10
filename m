Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E43AE6B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 05:55:08 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LMK00B3DJJUPWA0@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Jun 2011 10:55:06 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LMK006ZHJJOJE@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Jun 2011 10:55:05 +0100 (BST)
Date: Fri, 10 Jun 2011 11:54:56 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
In-reply-to: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1307699698-29369-9-git-send-email-m.szyprowski@samsung.com>
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>

The Contiguous Memory Allocator is a set of functions that lets
one initialise a region of memory which then can be used to perform
allocations of contiguous memory chunks from.

CMA allows for creation of separate contexts. Kernel is allowed to
allocate movable pages within CMA's managed memory so that it can be
used for page cache when CMA devices do not use it. On cm_alloc()
request such pages are migrated out of CMA area to free required
contiguous block.

This code is heavily based on earlier works by Michal Nazarewicz.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
CC: Michal Nazarewicz <mina86@mina86.com>
---
 include/linux/cma.h |  189 +++++++++++++++++++++++++++
 mm/Kconfig          |   21 +++
 mm/Makefile         |    1 +
 mm/cma.c            |  358 +++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 569 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/cma.h
 create mode 100644 mm/cma.c

diff --git a/include/linux/cma.h b/include/linux/cma.h
new file mode 100644
index 0000000..70a993c
--- /dev/null
+++ b/include/linux/cma.h
@@ -0,0 +1,189 @@
+#ifndef __LINUX_CMA_H
+#define __LINUX_CMA_H
+
+/*
+ * Contiguous Memory Allocator
+ * Copyright (c) 2010-2011 by Samsung Electronics.
+ * Written by:
+ *	Michal Nazarewicz <mina86@mina86.com>
+ *	Marek Szyprowski <m.szyprowski@samsung.com>
+ */
+
+/*
+ * Contiguous Memory Allocator
+ *
+ *   The Contiguous Memory Allocator (CMA) makes it possible for
+ *   device drivers to allocate big contiguous chunks of memory after
+ *   the system has booted.
+ *
+ *   It requires some machine- and/or platform-specific initialisation
+ *   code which prepares memory ranges to be used with CMA and later,
+ *   device drivers can allocate memory from those ranges.
+ *
+ * Why is it needed?
+ *
+ *   Various devices on embedded systems have no scatter-getter and/or
+ *   IO map support and require contiguous blocks of memory to
+ *   operate.  They include devices such as cameras, hardware video
+ *   coders, etc.
+ *
+ *   Such devices often require big memory buffers (a full HD frame
+ *   is, for instance, more then 2 mega pixels large, i.e. more than 6
+ *   MB of memory), which makes mechanisms such as kmalloc() or
+ *   alloc_page() ineffective.
+ *
+ *   At the same time, a solution where a big memory region is
+ *   reserved for a device is suboptimal since often more memory is
+ *   reserved then strictly required and, moreover, the memory is
+ *   inaccessible to page system even if device drivers don't use it.
+ *
+ *   CMA tries to solve this issue by operating on memory regions
+ *   where only movable pages can be allocated from.  This way, kernel
+ *   can use the memory for pagecache and when device driver requests
+ *   it, allocated pages can be migrated.
+ *
+ * Driver usage
+ *
+ *   CMA should not be used directly by the device drivers. It should
+ *   be considered as helper framework for dma-mapping subsystm and
+ *   respective (platform)bus drivers.
+ *
+ *   The CMA client needs to have a pointer to a CMA context
+ *   represented by a struct cma (which is an opaque data type).
+ *
+ *   Once such pointer is obtained, a caller may allocate contiguous
+ *   memory chunk using the following function:
+ *
+ *     cm_alloc()
+ *
+ *   This function returns a pointer to the first struct page which
+ *   represent a contiguous memory chunk.  This pointer
+ *   may be used with the following function:
+ *
+ *     cm_free()    -- frees allocated contiguous memory
+ *
+ * Platform/machine integration
+ *
+ *   CMA context must be created on platform or machine initialisation
+ *   and passed to respective subsystem that will be a client for CMA.
+ *   The latter may be done by a global variable or some filed in
+ *   struct device.  For the former CMA provides the following functions:
+ *
+ *     cma_init_migratetype()
+ *     cma_reserve()
+ *     cma_create()
+ *
+ *   The first one initialises a portion of reserved memory so that it
+ *   can be used with CMA.  The second first tries to reserve memory
+ *   (using memblock) and then initialise it.
+ *
+ *   The cma_reserve() function must be called when memblock is still
+ *   operational and reserving memory with it is still possible.  On
+ *   ARM platform the "reserve" machine callback is a perfect place to
+ *   call it.
+ *
+ *   The last function creates a CMA context on a range of previously
+ *   initialised memory addresses.  Because it uses kmalloc() it needs
+ *   to be called after SLAB is initialised.
+ */
+
+/***************************** Kernel level API *****************************/
+
+#ifdef __KERNEL__
+
+struct cma;
+struct page;
+
+#ifdef CONFIG_CMA
+
+/**
+ * cma_init_migratetype() - initialises range of physical memory to be used
+ *		with CMA context.
+ * @start:	start address of the memory range in bytes.
+ * @size:	size of the memory range in bytes.
+ *
+ * The range must be MAX_ORDER_NR_PAGES aligned and it must have been
+ * already reserved (eg. with memblock).
+ *
+ * The actual initialisation is deferred until subsys initcalls are
+ * evaluated (unless this has already happened).
+ *
+ * Returns zero on success or negative error.
+ */
+int cma_init_migratetype(unsigned long start, unsigned long end);
+
+/**
+ * cma_reserve() - reserves memory.
+ * @start:	start address of the memory range in bytes hint; if unsure
+ *		pass zero.
+ * @size:	size of the memory to reserve in bytes.
+ *
+ * It will use memblock to allocate memory. It will also call
+ * cma_init_migratetype() on reserved region so that a CMA context can
+ * be created on given range.
+ *
+ * @start and @size will be aligned to (MAX_ORDER_NR_PAGES << PAGE_SHIFT).
+ *
+ * Returns reserved's area physical address or value that yields true
+ * when checked with IS_ERR_VALUE().
+ */
+unsigned long cma_reserve(unsigned long start, unsigned long size);
+
+/**
+ * cma_create() - creates a CMA context.
+ * @start:	start address of the context in bytes.
+ * @size:	size of the context in bytes.
+ *
+ * The range must be page aligned.  Different contexts cannot overlap.
+ *
+ * The memory range must either lay in ZONE_MOVABLE or must have been
+ * initialised with cma_init_migratetype() function.
+ *
+ * @start and @size must be page aligned.
+ *
+ * Because this function uses kmalloc() it must be called after SLAB
+ * is initialised.  This in particular means that it cannot be called
+ * just after cma_reserve() since the former needs to be run way
+ * earlier.
+ *
+ * Returns pointer to CMA context or a pointer-error on error.
+ */
+struct cma *cma_create(unsigned long start, unsigned long size);
+
+/**
+ * cma_destroy() - destroys CMA context.
+ * @cma:	context to destroy.
+ */
+void cma_destroy(struct cma *cma);
+
+/**
+ * cm_alloc() - allocates contiguous memory.
+ * @cma:	CMA context to use
+ * @count:	desired chunk size in pages (must be non-zero)
+ * @order:	desired alignment in pages
+ *
+ * Returns pointer to first page structure representing contiguous memory
+ * or a pointer-error on error.
+ */
+struct page *cm_alloc(struct cma *cma, int count, unsigned int order);
+
+/**
+ * cm_free() - frees contiguous memory.
+ * @cma:	CMA context to use
+ * @pages:	contiguous memory to free
+ * @count:	desired chunk size in pages (must be non-zero)
+ *
+ */
+void cm_free(struct cma *cma, struct page *pages, int count);
+
+#else
+struct page *cm_alloc(struct cma *cma, int count, unsigned int order)
+{
+	return NULL;
+};
+void cm_free(struct cma *cma, struct page *pages, int count) { }
+#endif
+
+#endif
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 6ffedd8..b85de4c 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -346,6 +346,27 @@ choice
 	  benefit.
 endchoice
 
+config CMA
+	bool "Contiguous Memory Allocator"
+	select CMA_MIGRATE_TYPE
+	select MIGRATION
+	select GENERIC_ALLOCATOR
+	help
+	  This enables the Contiguous Memory Allocator which allows drivers
+	  to allocate big physically-contiguous blocks of memory for use with
+	  hardware components that do not support I/O map nor scatter-gather.
+
+	  For more information see <include/linux/cma.h>.  If unsure, say "n".
+
+config CMA_DEBUG
+	bool "CMA debug messages (DEVELOPEMENT)"
+	depends on CMA
+	help
+	  Turns on debug messages in CMA.  This produces KERN_DEBUG
+	  messages for every CMA call as well as various messages while
+	  processing calls such as cm_alloc().  This option does not
+	  affect warning and error messages.
+
 #
 # UP and nommu archs use km based percpu allocator
 #
diff --git a/mm/Makefile b/mm/Makefile
index 836e416..4610320 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -50,3 +50,4 @@ obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
+obj-$(CONFIG_CMA) += cma.o
diff --git a/mm/cma.c b/mm/cma.c
new file mode 100644
index 0000000..aee306c
--- /dev/null
+++ b/mm/cma.c
@@ -0,0 +1,358 @@
+/*
+ * Contiguous Memory Allocator
+ * Copyright (c) 2010-2011 by Samsung Electronics.
+ * Written by:
+ *	Michal Nazarewicz <mina86@mina86.com>
+ *	Marek Szyprowski <m.szyprowski@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ */
+
+/*
+ * See include/linux/cma.h for details.
+ */
+
+#define pr_fmt(fmt) "cma: " fmt
+
+#ifdef CONFIG_CMA_DEBUG
+#  define DEBUG
+#endif
+
+#include <asm/page.h>
+#include <asm/errno.h>
+
+#include <linux/cma.h>
+#include <linux/memblock.h>
+#include <linux/err.h>
+#include <linux/genalloc.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/mutex.h>
+#include <linux/page-isolation.h>
+#include <linux/slab.h>
+#include <linux/swap.h>
+#include <linux/mm_types.h>
+
+#include "internal.h"
+
+/* XXX Revisit */
+#ifdef phys_to_pfn
+/* nothing to do */
+#elif defined __phys_to_pfn
+#  define phys_to_pfn __phys_to_pfn
+#else
+#  warning correct phys_to_pfn implementation needed
+static unsigned long phys_to_pfn(phys_addr_t phys)
+{
+	return virt_to_pfn(phys_to_virt(phys));
+}
+#endif
+
+
+/************************* Initialise CMA *************************/
+
+static struct cma_grabbed {
+	unsigned long start;
+	unsigned long size;
+} cma_grabbed[8] __initdata;
+static unsigned cma_grabbed_count __initdata;
+
+#ifdef CONFIG_DEBUG_VM
+
+static int __cma_give_back(unsigned long start, unsigned long size)
+{
+	unsigned long pfn = phys_to_pfn(start);
+	unsigned i = size >> PAGE_SHIFT;
+	struct zone *zone;
+
+	pr_debug("%s(%p+%p)\n", __func__, (void *)start, (void *)size);
+
+	VM_BUG_ON(!pfn_valid(pfn));
+	zone = page_zone(pfn_to_page(pfn));
+
+	do {
+		VM_BUG_ON(!pfn_valid(pfn));
+		VM_BUG_ON(page_zone(pfn_to_page(pfn)) != zone);
+		if (!(pfn & (pageblock_nr_pages - 1)))
+			__free_pageblock_cma(pfn_to_page(pfn));
+		++pfn;
+		++totalram_pages;
+	} while (--i);
+
+	return 0;
+}
+
+#else
+
+static int __cma_give_back(unsigned long start, unsigned long size)
+{
+	unsigned i = size >> (PAGE_SHIFT + pageblock_order);
+	struct page *p = phys_to_page(start);
+
+	pr_debug("%s(%p+%p)\n", __func__, (void *)start, (void *)size);
+
+	do {
+		__free_pageblock_cma(p);
+		p += pageblock_nr_pages;
+		totalram_pages += pageblock_nr_pages;
+	} while (--i);
+
+	return 0;
+}
+
+#endif
+
+static int __init __cma_queue_give_back(unsigned long start, unsigned long size)
+{
+	if (cma_grabbed_count == ARRAY_SIZE(cma_grabbed))
+		return -ENOSPC;
+
+	cma_grabbed[cma_grabbed_count].start = start;
+	cma_grabbed[cma_grabbed_count].size  = size;
+	++cma_grabbed_count;
+	return 0;
+}
+
+static int (*cma_give_back)(unsigned long start, unsigned long size) =
+	__cma_queue_give_back;
+
+static int __init cma_give_back_queued(void)
+{
+	struct cma_grabbed *r = cma_grabbed;
+	unsigned i = cma_grabbed_count;
+
+	pr_debug("%s(): will give %u range(s)\n", __func__, i);
+
+	cma_give_back = __cma_give_back;
+
+	for (; i; --i, ++r)
+		__cma_give_back(r->start, r->size);
+
+	return 0;
+}
+core_initcall(cma_give_back_queued);
+
+int __ref cma_init_migratetype(unsigned long start, unsigned long size)
+{
+	pr_debug("%s(%p+%p)\n", __func__, (void *)start, (void *)size);
+
+	if (!size)
+		return -EINVAL;
+	if ((start | size) & ((MAX_ORDER_NR_PAGES << PAGE_SHIFT) - 1))
+		return -EINVAL;
+	if (start + size < start)
+		return -EOVERFLOW;
+
+	return cma_give_back(start, size);
+}
+
+unsigned long cma_reserve(unsigned long start, unsigned long size)
+{
+	unsigned long alignment;
+	int ret;
+
+	pr_debug("%s(%p+%p)\n", __func__, (void *)start, (void *)size);
+
+	/* Sanity checks */
+	if (!size)
+		return (unsigned long)-EINVAL;
+
+	/* Sanitise input arguments */
+	start = ALIGN(start, MAX_ORDER_NR_PAGES << PAGE_SHIFT);
+	size  = ALIGN(size , MAX_ORDER_NR_PAGES << PAGE_SHIFT);
+	alignment = MAX_ORDER_NR_PAGES << PAGE_SHIFT;
+
+	/* Reserve memory */
+	if (start) {
+		if (memblock_is_region_reserved(start, size) ||
+		    memblock_reserve(start, size) < 0)
+			return (unsigned long)-EBUSY;
+	} else {
+		/*
+		 * Use __memblock_alloc_base() since
+		 * memblock_alloc_base() panic()s.
+		 */
+		u64 addr = __memblock_alloc_base(size, alignment, 0);
+		if (!addr) {
+			return (unsigned long)-ENOMEM;
+		} else if (addr + size > ~(unsigned long)0) {
+			memblock_free(addr, size);
+			return (unsigned long)-EOVERFLOW;
+		} else {
+			start = addr;
+		}
+	}
+
+	/* CMA Initialise */
+	ret = cma_init_migratetype(start, size);
+	if (ret < 0) {
+		memblock_free(start, size);
+		return ret;
+	}
+
+	return start;
+}
+
+
+/************************** CMA context ***************************/
+
+struct cma {
+	int migratetype;
+	struct gen_pool *pool;
+};
+
+static int __cma_check_range(unsigned long start, unsigned long size)
+{
+	int migratetype = MIGRATE_MOVABLE;
+	unsigned long pfn, count;
+	struct page *page;
+	struct zone *zone;
+
+	start = phys_to_pfn(start);
+	if (WARN_ON(!pfn_valid(start)))
+		return -EINVAL;
+
+	if (page_zonenum(pfn_to_page(start)) != ZONE_MOVABLE)
+		migratetype = MIGRATE_CMA;
+
+	/* First check if all pages are valid and in the same zone */
+	zone  = page_zone(pfn_to_page(start));
+	count = size >> PAGE_SHIFT;
+	pfn   = start;
+	while (++pfn, --count) {
+		if (WARN_ON(!pfn_valid(pfn)) ||
+		    WARN_ON(page_zone(pfn_to_page(pfn)) != zone))
+			return -EINVAL;
+	}
+
+	/* Now check migratetype of their pageblocks. */
+	start = start & ~(pageblock_nr_pages - 1);
+	pfn   = ALIGN(pfn, pageblock_nr_pages);
+	page  = pfn_to_page(start);
+	count = (pfn - start) >> PAGE_SHIFT;
+	do {
+		if (WARN_ON(get_pageblock_migratetype(page) != migratetype))
+			return -EINVAL;
+		page += pageblock_nr_pages;
+	} while (--count);
+
+	return migratetype;
+}
+
+struct cma *cma_create(unsigned long start, unsigned long size)
+{
+	struct gen_pool *pool;
+	int migratetype, ret;
+	struct cma *cma;
+
+	pr_debug("%s(%p+%p)\n", __func__, (void *)start, (void *)size);
+
+	if (!size)
+		return ERR_PTR(-EINVAL);
+	if ((start | size) & (PAGE_SIZE - 1))
+		return ERR_PTR(-EINVAL);
+	if (start + size < start)
+		return ERR_PTR(-EOVERFLOW);
+
+	migratetype = __cma_check_range(start, size);
+	if (migratetype < 0)
+		return ERR_PTR(migratetype);
+
+	cma = kmalloc(sizeof *cma, GFP_KERNEL);
+	if (!cma)
+		return ERR_PTR(-ENOMEM);
+
+	pool = gen_pool_create(ffs(PAGE_SIZE) - 1, -1);
+	if (!pool) {
+		ret = -ENOMEM;
+		goto error1;
+	}
+
+	ret = gen_pool_add(pool, start, size, -1);
+	if (unlikely(ret))
+		goto error2;
+
+	cma->migratetype = migratetype;
+	cma->pool = pool;
+
+	pr_debug("%s: returning <%p>\n", __func__, (void *)cma);
+	return cma;
+
+error2:
+	gen_pool_destroy(pool);
+error1:
+	kfree(cma);
+	return ERR_PTR(ret);
+}
+
+void cma_destroy(struct cma *cma)
+{
+	pr_debug("%s(<%p>)\n", __func__, (void *)cma);
+	gen_pool_destroy(cma->pool);
+}
+
+
+/************************* Allocate and free *************************/
+
+/* Protects cm_alloc(), cm_free() as well as gen_pools of each cm. */
+static DEFINE_MUTEX(cma_mutex);
+
+struct page *cm_alloc(struct cma *cma, int count, unsigned int order)
+{
+	unsigned long start;
+	unsigned long size = count << PAGE_SHIFT;
+
+	if (!cma)
+		return NULL;
+
+	pr_debug("%s(<%p>, %lx/%d)\n", __func__, (void *)cma, size, order);
+
+	if (!size)
+		return NULL;
+
+	mutex_lock(&cma_mutex);
+
+	start = gen_pool_alloc_aligned(cma->pool, size, order+12);
+	if (!start)
+		goto error1;
+
+	if (cma->migratetype) {
+		unsigned long pfn = phys_to_pfn(start);
+		int ret = alloc_contig_range(pfn, pfn + (size >> PAGE_SHIFT),
+					     0, cma->migratetype);
+		if (ret)
+			goto error2;
+	}
+
+	mutex_unlock(&cma_mutex);
+
+	pr_debug("%s(): returning [%p]\n", __func__, (void *)phys_to_page(start));
+	return phys_to_page(start);
+error2:
+	gen_pool_free(cma->pool, start, size);
+error1:
+	mutex_unlock(&cma_mutex);
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(cm_alloc);
+
+void cm_free(struct cma *cma, struct page *pages, int count)
+{
+	unsigned long size = count << PAGE_SHIFT;
+	pr_debug("%s([%p])\n", __func__, (void *)pages);
+
+	if (!cma || !pages)
+		return;
+
+	mutex_lock(&cma_mutex);
+
+	gen_pool_free(cma->pool, page_to_phys(pages), size);
+	if (cma->migratetype)
+		free_contig_pages(pages, count);
+
+	mutex_unlock(&cma_mutex);
+}
+EXPORT_SYMBOL_GPL(cm_free);
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
