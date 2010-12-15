Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 573406B0098
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 15:38:41 -0500 (EST)
Received: from spt2.w1.samsung.com (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LDH00GQBLCDZR@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 15 Dec 2010 20:38:37 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LDH00KXSLCCNU@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Dec 2010 20:38:37 +0000 (GMT)
Date: Wed, 15 Dec 2010 21:34:27 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCHv8 07/12] mm: cma: Contiguous Memory Allocator added
In-reply-to: <cover.1292443200.git.m.nazarewicz@samsung.com>
Message-id: 
 <eb8f43235c8ff2816ada7b56ffe371ea6140cae8.1292443200.git.m.nazarewicz@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The Contiguous Memory Allocator is a set of functions that lets
one initialise a region of memory which then can be used to perform
allocations of contiguous memory chunks from.

CMA allows for creation of private and non-private contexts.
The former is reserved for CMA and no other kernel subsystem can
use it.  The latter allows for movable pages to be allocated within
CMA's managed memory so that it can be used for page cache when
CMA devices do not use it.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/cma.h |  219 ++++++++++++++++++++++++++++++++++
 mm/Kconfig          |   22 ++++
 mm/Makefile         |    1 +
 mm/cma.c            |  328 +++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 570 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/cma.h
 create mode 100644 mm/cma.c

diff --git a/include/linux/cma.h b/include/linux/cma.h
new file mode 100644
index 0000000..e9575fd
--- /dev/null
+++ b/include/linux/cma.h
@@ -0,0 +1,219 @@
+#ifndef __LINUX_CMA_H
+#define __LINUX_CMA_H
+
+/*
+ * Contiguous Memory Allocator
+ * Copyright (c) 2010 by Samsung Electronics.
+ * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
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
+ *   For device driver to use CMA it needs to have a pointer to a CMA
+ *   context represented by a struct cma (which is an opaque data
+ *   type).
+ *
+ *   Once such pointer is obtained, device driver may allocate
+ *   contiguous memory chunk using the following function:
+ *
+ *     cm_alloc()
+ *
+ *   This function returns a pointer to struct cm (another opaque data
+ *   type) which represent a contiguous memory chunk.  This pointer
+ *   may be used with the following functions:
+ *
+ *     cm_free()    -- frees allocated contiguous memory
+ *     cm_pin()     -- pins memory
+ *     cm_unpin()   -- unpins memory
+ *     cm_vmap()    -- maps memory in kernel space
+ *     cm_vunmap()  -- unmaps memory from kernel space
+ *
+ *   See the respective functions for more information.
+ *
+ * Platform/machine integration
+ *
+ *   For device drivers to be able to use CMA platform or machine
+ *   initialisation code must create a CMA context and pass it to
+ *   device drivers.  The latter may be done by a global variable or
+ *   a platform/machine specific function.  For the former CMA
+ *   provides the following functions:
+ *
+ *     cma_reserve()
+ *     cma_create()
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
+#if defined __KERNEL__ && defined CONFIG_CMA
+
+/* CMA context */
+struct cma;
+/* Contiguous Memory chunk */
+struct cm;
+
+/**
+ * cma_reserve() - reserves memory.
+ * @start:	start address of the memory range in bytes hint; if unsure
+ *		pass zero.
+ * @size:	size of the memory to reserve in bytes.
+ * @alignment:	desired alignment in bytes (must be power of two or zero).
+ *
+ * It will use memblock to allocate memory.  @start and @size will be
+ * aligned to PAGE_SIZE.
+ *
+ * Returns reserved's area physical address or value that yields true
+ * when checked with IS_ERR_VALUE().
+ */
+unsigned long cma_reserve(unsigned long start, unsigned long size,
+			  unsigned long alignment);
+
+/**
+ * cma_create() - creates a CMA context.
+ * @start:	start address of the context in bytes.
+ * @size:	size of the context in bytes.
+ * @min_alignment:	minimal desired alignment or zero.
+ * @private:	whether to create private context.
+ *
+ * The range must be page aligned.  Different contexts cannot overlap.
+ *
+ * Unless @private is true the memory range must lay in ZONE_MOVABLE.
+ * If @private is true no underlaying memory checking is done and
+ * during allocation no pages migration will be performed - it is
+ * assumed that the memory is reserved and only CMA manages it.
+ *
+ * @start and @size must be page and @min_alignment alignment.
+ * @min_alignment specifies the minimal alignment that user will be
+ * able to request through cm_alloc() function.  In most cases one
+ * will probably pass zero as @min_alignment but if the CMA context
+ * will be used only for, say, 1 MiB blocks passing 1 << 20 as
+ * @min_alignment may increase performance and reduce memory usage
+ * slightly.
+ *
+ * Because this function uses kmalloc() it must be called after SLAB
+ * is initialised.  This in particular means that it cannot be called
+ * just after cma_reserve() since the former needs to be run way
+ * earlier.
+ *
+ * Returns pointer to CMA context or a pointer-error on error.
+ */
+struct cma *cma_create(unsigned long start, unsigned long size,
+		       unsigned long min_alignment, _Bool private);
+
+/**
+ * cma_destroy() - destroys CMA context.
+ * @cma:	context to destroy.
+ */
+void cma_destroy(struct cma *cma);
+
+/**
+ * cm_alloc() - allocates contiguous memory.
+ * @cma:	CMA context to use.
+ * @size:	desired chunk size in bytes (must be non-zero).
+ * @alignent:	desired minimal alignment in bytes (must be power of two
+ *		or zero).
+ *
+ * Returns pointer to structure representing contiguous memory or
+ * a pointer-error on error.
+ */
+struct cm *cm_alloc(struct cma *cma, unsigned long size,
+		    unsigned long alignment);
+
+/**
+ * cm_free() - frees contiguous memory.
+ * @cm:	contiguous memory to free.
+ *
+ * The contiguous memory must be not be pinned (see cma_pin()) and
+ * must not be mapped to kernel space (cma_vmap()).
+ */
+void cm_free(struct cm *cm);
+
+/**
+ * cm_pin() - pins contiguous memory.
+ * @cm: contiguous memory to pin.
+ *
+ * Pinning is required to obtain contiguous memory's physical address.
+ * While memory is pinned the memory will remain valid it may change
+ * if memory is unpinned and then pinned again.  This facility is
+ * provided so that memory defragmentation can be implemented inside
+ * CMA.
+ *
+ * Each call to cm_pin() must be accompanied by call to cm_unpin() and
+ * the calls may be nested.
+ *
+ * Returns chunk's physical address or a value that yields true when
+ * tested with IS_ERR_VALUE().
+ */
+unsigned long cm_pin(struct cm *cm);
+
+/**
+ * cm_unpin() - unpins contiguous memory.
+ * @cm: contiguous memory to unpin.
+ *
+ * See cm_pin().
+ */
+void cm_unpin(struct cm *cm);
+
+/**
+ * cm_vmap() - maps memory to kernel space (or returns existing mapping).
+ * @cm: contiguous memory to map.
+ *
+ * Each call to cm_vmap() must be accompanied with call to cm_vunmap()
+ * and the calls may be nested.
+ *
+ * Returns kernel virtual address or a pointer-error.
+ */
+void *cm_vmap(struct cm *cm);
+
+/**
+ * cm_vunmap() - unmpas memory from kernel space.
+ * @cm:	contiguous memory to unmap.
+ *
+ * See cm_vmap().
+ */
+void cm_vunmap(struct cm *cm);
+
+#endif
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index b911ad3..2beab4d 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -331,3 +331,25 @@ config CLEANCACHE
 	  in a negligible performance hit.
 
 	  If unsure, say Y to enable cleancache
+
+config CMA
+	bool "Contiguous Memory Allocator"
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
+	  processing calls such as cma_alloc().  This option does not
+	  affect warning and error messages.
+
+	  This is mostly used during development.  If unsure, say "n".
diff --git a/mm/Makefile b/mm/Makefile
index 0b08d1c..c6a84f1 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -43,3 +43,4 @@ obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
+obj-$(CONFIG_CMA) += cma.o
diff --git a/mm/cma.c b/mm/cma.c
new file mode 100644
index 0000000..d82361b
--- /dev/null
+++ b/mm/cma.c
@@ -0,0 +1,328 @@
+/*
+ * Contiguous Memory Allocator framework
+ * Copyright (c) 2010 by Samsung Electronics.
+ * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
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
+#include <linux/cma.h>
+
+#ifndef CONFIG_NO_BOOTMEM
+#  include <linux/bootmem.h>
+#endif
+#ifdef CONFIG_HAVE_MEMBLOCK
+#  include <linux/memblock.h>
+#endif
+
+#include <linux/err.h>
+#include <linux/genalloc.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/mutex.h>
+#include <linux/page-isolation.h>
+#include <linux/slab.h>
+#include <linux/swap.h>
+
+#include <asm/page.h>
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
+unsigned long cma_reserve(unsigned long start, unsigned long size,
+			  unsigned long alignment)
+{
+	pr_debug("%s(%p+%p/%p)\n", __func__, (void *)start, (void *)size,
+		 (void *)alignment);
+
+	/* Sanity checks */
+	if (!size || (alignment & (alignment - 1)))
+		return (unsigned long)-EINVAL;
+
+	/* Sanitise input arguments */
+	start = PAGE_ALIGN(start);
+	size  = PAGE_ALIGN(size);
+	if (alignment < PAGE_SIZE)
+		alignment = PAGE_SIZE;
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
+	return start;
+}
+
+
+/************************** CMA context ***************************/
+
+struct cma {
+	bool migrate;
+	struct gen_pool *pool;
+};
+
+static int __cma_check_range(unsigned long start, unsigned long size)
+{
+	unsigned long pfn, count;
+	struct page *page;
+	struct zone *zone;
+
+	start = phys_to_pfn(start);
+	if (WARN_ON(!pfn_valid(start)))
+		return -EINVAL;
+
+	if (WARN_ON(page_zonenum(pfn_to_page(start)) != ZONE_MOVABLE))
+		return -EINVAL;
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
+		if (WARN_ON(get_pageblock_migratetype(page) != MIGRATE_MOVABLE))
+			return -EINVAL;
+		page += pageblock_nr_pages;
+	} while (--count);
+
+	return 0;
+}
+
+struct cma *cma_create(unsigned long start, unsigned long size,
+		       unsigned long min_alignment, bool private)
+{
+	struct gen_pool *pool;
+	struct cma *cma;
+	int ret;
+
+	pr_debug("%s(%p+%p)\n", __func__, (void *)start, (void *)size);
+
+	if (!size)
+		return ERR_PTR(-EINVAL);
+	if (min_alignment & (min_alignment - 1))
+		return ERR_PTR(-EINVAL);
+	if (min_alignment < PAGE_SIZE)
+		min_alignment = PAGE_SIZE;
+	if ((start | size) & (min_alignment - 1))
+		return ERR_PTR(-EINVAL);
+	if (start + size < start)
+		return ERR_PTR(-EOVERFLOW);
+
+	if (!private) {
+		ret = __cma_check_range(start, size);
+		if (ret < 0)
+			return ERR_PTR(ret);
+	}
+
+	cma = kmalloc(sizeof *cma, GFP_KERNEL);
+	if (!cma)
+		return ERR_PTR(-ENOMEM);
+
+	pool = gen_pool_create(ffs(min_alignment) - 1, -1);
+	if (!pool) {
+		ret = -ENOMEM;
+		goto error1;
+	}
+
+	ret = gen_pool_add(pool, start, size, -1);
+	if (unlikely(ret))
+		goto error2;
+
+	cma->migrate = !private;
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
+	gen_pool_destroy((void *)cma);
+}
+
+
+/************************* Allocate and free *************************/
+
+struct cm {
+	struct cma *cma;
+	unsigned long phys, size;
+	atomic_t pinned, mapped;
+};
+
+/* Protects cm_alloc(), cm_free() as well as gen_pools of each cm. */
+static DEFINE_MUTEX(cma_mutex);
+
+struct cm *cm_alloc(struct cma *cma, unsigned long size,
+		    unsigned long alignment)
+{
+	unsigned long start;
+	int ret = -ENOMEM;
+	struct cm *cm;
+
+	pr_debug("%s(<%p>, %p/%p)\n", __func__, (void *)cma,
+		 (void *)size, (void *)alignment);
+
+	if (!size || (alignment & (alignment - 1)))
+		return ERR_PTR(-EINVAL);
+	size = PAGE_ALIGN(size);
+
+	cm = kmalloc(sizeof *cm, GFP_KERNEL);
+	if (!cm)
+		return ERR_PTR(-ENOMEM);
+
+	mutex_lock(&cma_mutex);
+
+	start = gen_pool_alloc_aligned(cma->pool, size,
+				       alignment ? ffs(alignment) - 1 : 0);
+	if (!start)
+		goto error1;
+
+	if (cma->migrate) {
+		unsigned long pfn = phys_to_pfn(start);
+		ret = alloc_contig_range(pfn, pfn + (size >> PAGE_SHIFT), 0);
+		if (ret)
+			goto error2;
+	}
+
+	mutex_unlock(&cma_mutex);
+
+	cm->cma         = cma;
+	cm->phys        = start;
+	cm->size        = size;
+	atomic_set(&cm->pinned, 0);
+	atomic_set(&cm->mapped, 0);
+
+	pr_debug("%s(): returning [%p]\n", __func__, (void *)cm);
+	return cm;
+
+error2:
+	gen_pool_free((void *)cma, start, size);
+error1:
+	mutex_unlock(&cma_mutex);
+	kfree(cm);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL_GPL(cm_alloc);
+
+void cm_free(struct cm *cm)
+{
+	pr_debug("%s([%p])\n", __func__, (void *)cm);
+
+	if (WARN_ON(atomic_read(&cm->pinned) || atomic_read(&cm->mapped)))
+		return;
+
+	mutex_lock(&cma_mutex);
+
+	gen_pool_free(cm->cma->pool, cm->phys, cm->size);
+	if (cm->cma->migrate)
+		free_contig_pages(phys_to_page(cm->phys),
+				  cm->size >> PAGE_SHIFT);
+
+	mutex_unlock(&cma_mutex);
+
+	kfree(cm);
+}
+EXPORT_SYMBOL_GPL(cm_free);
+
+
+/************************* Mapping and addresses *************************/
+
+/*
+ * Currently no-operations but keep reference counters for error
+ * checking.
+ */
+
+unsigned long cm_pin(struct cm *cm)
+{
+	pr_debug("%s([%p])\n", __func__, (void *)cm);
+	atomic_inc(&cm->pinned);
+	return cm->phys;
+}
+EXPORT_SYMBOL_GPL(cm_pin);
+
+void cm_unpin(struct cm *cm)
+{
+	pr_debug("%s([%p])\n", __func__, (void *)cm);
+	WARN_ON(!atomic_add_unless(&cm->pinned, -1, 0));
+}
+EXPORT_SYMBOL_GPL(cm_unpin);
+
+void *cm_vmap(struct cm *cm)
+{
+	pr_debug("%s([%p])\n", __func__, (void *)cm);
+	atomic_inc(&cm->mapped);
+	/*
+	 * XXX We should probably do something more clever in the
+	 * future.  The memory might be highmem after all.
+	 */
+	return phys_to_virt(cm->phys);
+}
+EXPORT_SYMBOL_GPL(cm_vmap);
+
+void cm_vunmap(struct cm *cm)
+{
+	pr_debug("%s([%p])\n", __func__, (void *)cm);
+	WARN_ON(!atomic_add_unless(&cm->mapped, -1, 0));
+}
+EXPORT_SYMBOL_GPL(cm_vunmap);
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
