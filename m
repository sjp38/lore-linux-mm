Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A675E6B0291
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 09:55:00 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LSN006SFDBINR50@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 06 Oct 2011 14:54:54 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LSN005YMDBIQT@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 06 Oct 2011 14:54:54 +0100 (BST)
Date: Thu, 06 Oct 2011 15:54:46 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 6/9] drivers: add Contiguous Memory Allocator
In-reply-to: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1317909290-29832-7-git-send-email-m.szyprowski@samsung.com>
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

The Contiguous Memory Allocator is a set of helper functions for DMA
mapping framework that improves allocations of contiguous memory chunks.

CMA grabs memory on system boot, marks it with CMA_MIGRATE_TYPE and
gives back to the system. Kernel is allowed to allocate movable pages
within CMA's managed memory so that it can be used for example for page
cache when DMA mapping do not use it. On dma_alloc_from_contiguous()
request such pages are migrated out of CMA area to free required
contiguous block and fulfill the request. This allows to allocate large
contiguous chunks of memory at any time assuming that there is enough
free memory available in the system.

This code is heavily based on earlier works by Michal Nazarewicz.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
CC: Michal Nazarewicz <mina86@mina86.com>
---
 arch/Kconfig                         |    3 +
 drivers/base/Kconfig                 |   79 +++++++
 drivers/base/Makefile                |    1 +
 drivers/base/dma-contiguous.c        |  386 ++++++++++++++++++++++++++++++++++
 include/asm-generic/dma-contiguous.h |   27 +++
 include/linux/device.h               |    4 +
 include/linux/dma-contiguous.h       |  106 ++++++++++
 7 files changed, 606 insertions(+), 0 deletions(-)
 create mode 100644 drivers/base/dma-contiguous.c
 create mode 100644 include/asm-generic/dma-contiguous.h
 create mode 100644 include/linux/dma-contiguous.h

diff --git a/arch/Kconfig b/arch/Kconfig
index 4b0669c..a3b39a2 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -124,6 +124,9 @@ config HAVE_ARCH_TRACEHOOK
 config HAVE_DMA_ATTRS
 	bool
 
+config HAVE_DMA_CONTIGUOUS
+	bool
+
 config USE_GENERIC_SMP_HELPERS
 	bool
 
diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 21cf46f..a5e6d75 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -174,4 +174,83 @@ config SYS_HYPERVISOR
 
 source "drivers/base/regmap/Kconfig"
 
+config CMA
+	bool "Contiguous Memory Allocator (EXPERIMENTAL)"
+	depends on HAVE_DMA_CONTIGUOUS && HAVE_MEMBLOCK && EXPERIMENTAL
+	select MIGRATION
+	select CMA_MIGRATE_TYPE
+	help
+	  This enables the Contiguous Memory Allocator which allows drivers
+	  to allocate big physically-contiguous blocks of memory for use with
+	  hardware components that do not support I/O map nor scatter-gather.
+
+	  For more information see <include/linux/dma-contiguous.h>.
+	  If unsure, say "n".
+
+if CMA
+
+config CMA_DEBUG
+	bool "CMA debug messages (DEVELOPEMENT)"
+	help
+	  Turns on debug messages in CMA.  This produces KERN_DEBUG
+	  messages for every CMA call as well as various messages while
+	  processing calls such as dma_alloc_from_contiguous().
+	  This option does not affect warning and error messages.
+
+comment "Default contiguous memory area size:"
+
+config CMA_SIZE_ABSOLUTE
+	int "Absolute size (in MiB)"
+	depends on !CMA_SIZE_SEL_PERCENTAGE
+	default 16
+	help
+	  Defines the size (in MiB) of the default memory area for Contiguous
+	  Memory Allocator.
+
+config CMA_SIZE_PERCENTAGE
+	int "Percentage of total memory"
+	depends on !CMA_SIZE_SEL_ABSOLUTE
+	default 10
+	help
+	  Defines the size of the default memory area for Contiguous Memory
+	  Allocator as a percentage of the total memory in the system.
+
+choice
+	prompt "Selected region size"
+	default CMA_SIZE_SEL_ABSOLUTE
+
+config CMA_SIZE_SEL_ABSOLUTE
+	bool "Use absolute value only"
+
+config CMA_SIZE_SEL_PERCENTAGE
+	bool "Use percentage value only"
+
+config CMA_SIZE_SEL_MIN
+	bool "Use lower value (minimum)"
+
+config CMA_SIZE_SEL_MAX
+	bool "Use higher value (maximum)"
+
+endchoice
+
+config CMA_ALIGNMENT
+	int "Maximum PAGE_SIZE order of alignment for contiguous buffers"
+	range 4 9
+	default 8
+	help
+	  DMA mapping framework by default aligns all buffers to the smallest
+	  PAGE_SIZE order which is greater than or equal to the requested buffer
+	  size. This works well for buffers up to a few hundreds kilobytes, but
+	  for larger buffers it just a memory waste. With this parameter you can
+	  specify the maximum PAGE_SIZE order for contiguous buffers. Larger
+	  buffers will be aligned only to this specified order. The order is
+	  expressed as a power of two multiplied by the PAGE_SIZE.
+
+	  For example, if your system defaults to 4KiB pages, the order value
+	  of 8 means that the buffers will be aligned up to 1MiB only.
+
+	  If unsure, leave the default value "8".
+
+endif
+
 endmenu
diff --git a/drivers/base/Makefile b/drivers/base/Makefile
index 99a375a..794546f 100644
--- a/drivers/base/Makefile
+++ b/drivers/base/Makefile
@@ -5,6 +5,7 @@ obj-y			:= core.o sys.o bus.o dd.o syscore.o \
 			   cpu.o firmware.o init.o map.o devres.o \
 			   attribute_container.o transport_class.o
 obj-$(CONFIG_DEVTMPFS)	+= devtmpfs.o
+obj-$(CONFIG_CMA) += dma-contiguous.o
 obj-y			+= power/
 obj-$(CONFIG_HAS_DMA)	+= dma-mapping.o
 obj-$(CONFIG_HAVE_GENERIC_DMA_COHERENT) += dma-coherent.o
diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
new file mode 100644
index 0000000..e54bb76
--- /dev/null
+++ b/drivers/base/dma-contiguous.c
@@ -0,0 +1,386 @@
+/*
+ * Contiguous Memory Allocator for DMA mapping framework
+ * Copyright (c) 2010-2011 by Samsung Electronics.
+ * Written by:
+ *	Marek Szyprowski <m.szyprowski@samsung.com>
+ *	Michal Nazarewicz <mina86@mina86.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ */
+
+#define pr_fmt(fmt) "cma: " fmt
+
+#ifdef CONFIG_CMA_DEBUG
+#ifndef DEBUG
+#  define DEBUG
+#endif
+#endif
+
+#include <asm/page.h>
+#include <asm/dma-contiguous.h>
+
+#include <linux/memblock.h>
+#include <linux/err.h>
+#include <linux/mm.h>
+#include <linux/mutex.h>
+#include <linux/page-isolation.h>
+#include <linux/slab.h>
+#include <linux/swap.h>
+#include <linux/mm_types.h>
+#include <linux/dma-contiguous.h>
+
+#ifndef SZ_1M
+#define SZ_1M (1 << 20)
+#endif
+
+#ifdef phys_to_pfn
+/* nothing to do */
+#elif defined __phys_to_pfn
+#  define phys_to_pfn __phys_to_pfn
+#elif defined __va
+#  define phys_to_pfn(x) page_to_pfn(virt_to_page(__va(x)))
+#else
+#  error phys_to_pfn implementation needed
+#endif
+
+struct cma {
+	unsigned long	base_pfn;
+	unsigned long	count;
+	unsigned long	*bitmap;
+};
+
+struct cma *dma_contiguous_default_area;
+
+#ifndef CONFIG_CMA_SIZE_ABSOLUTE
+#define CONFIG_CMA_SIZE_ABSOLUTE 0
+#endif
+
+#ifndef CONFIG_CMA_SIZE_PERCENTAGE
+#define CONFIG_CMA_SIZE_PERCENTAGE 0
+#endif
+
+static unsigned long size_abs = CONFIG_CMA_SIZE_ABSOLUTE * SZ_1M;
+static unsigned long size_percent = CONFIG_CMA_SIZE_PERCENTAGE;
+static long size_cmdline = -1;
+
+static int __init early_cma(char *p)
+{
+	pr_debug("%s(%s)\n", __func__, p);
+	size_cmdline = memparse(p, &p);
+	return 0;
+}
+early_param("cma", early_cma);
+
+static unsigned long __init __cma_early_get_total_pages(void)
+{
+	struct memblock_region *reg;
+	unsigned long total_pages = 0;
+
+	/*
+	 * We cannot use memblock_phys_mem_size() here, because
+	 * memblock_analyze() has not been called yet.
+	 */
+	for_each_memblock(memory, reg)
+		total_pages += memblock_region_memory_end_pfn(reg) -
+			       memblock_region_memory_base_pfn(reg);
+	return total_pages;
+}
+
+/**
+ * dma_contiguous_reserve() - reserve area for contiguous memory handling
+ *
+ * This funtion reserves memory from early allocator. It should be
+ * called by arch specific code once the early allocator (memblock or bootmem)
+ * has been activated and all other subsystems have already allocated/reserved
+ * memory.
+ */
+void __init dma_contiguous_reserve(phys_addr_t limit)
+{
+	unsigned long selected_size = 0;
+	unsigned long total_pages;
+
+	pr_debug("%s(limit %08lx)\n", __func__, (unsigned long)limit);
+
+	total_pages = __cma_early_get_total_pages();
+	size_percent *= (total_pages << PAGE_SHIFT) / 100;
+
+	pr_debug("%s: total available: %ld MiB, size absolute: %ld MiB, size percentage: %ld MiB\n",
+		 __func__, (total_pages << PAGE_SHIFT) / SZ_1M,
+		size_abs / SZ_1M, size_percent / SZ_1M);
+
+#ifdef CONFIG_CMA_SIZE_SEL_ABSOLUTE
+	selected_size = size_abs;
+#elif defined(CONFIG_CMA_SIZE_SEL_PERCENTAGE)
+	selected_size = size_percent;
+#elif defined(CONFIG_CMA_SIZE_SEL_MIN)
+	selected_size = min(size_abs, size_percent);
+#elif defined(CONFIG_CMA_SIZE_SEL_MAX)
+	selected_size = max(size_abs, size_percent);
+#endif
+
+	if (size_cmdline != -1)
+		selected_size = size_cmdline;
+
+	if (!selected_size)
+		return;
+
+	pr_debug("%s: reserving %ld MiB for global area\n", __func__,
+		 selected_size / SZ_1M);
+
+	dma_declare_contiguous(NULL, selected_size, 0, limit);
+};
+
+static DEFINE_MUTEX(cma_mutex);
+
+static void __cma_activate_area(unsigned long base_pfn, unsigned long count)
+{
+	unsigned long pfn = base_pfn;
+	unsigned i = count >> pageblock_order;
+	struct zone *zone;
+
+	VM_BUG_ON(!pfn_valid(pfn));
+	zone = page_zone(pfn_to_page(pfn));
+
+	do {
+		unsigned j;
+		base_pfn = pfn;
+		for (j = pageblock_nr_pages; j; --j, pfn++) {
+			VM_BUG_ON(!pfn_valid(pfn));
+			VM_BUG_ON(page_zone(pfn_to_page(pfn)) != zone);
+		}
+		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
+	} while (--i);
+}
+
+static struct cma *__cma_create_area(unsigned long base_pfn,
+				     unsigned long count)
+{
+	int bitmap_size = BITS_TO_LONGS(count) * sizeof(long);
+	struct cma *cma;
+
+	pr_debug("%s(base %08lx, count %lx)\n", __func__, base_pfn, count);
+
+	cma = kmalloc(sizeof *cma, GFP_KERNEL);
+	if (!cma)
+		return ERR_PTR(-ENOMEM);
+
+	cma->base_pfn = base_pfn;
+	cma->count = count;
+	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
+
+	if (!cma->bitmap)
+		goto no_mem;
+
+	__cma_activate_area(base_pfn, count);
+
+	pr_debug("%s: returned %p\n", __func__, (void *)cma);
+	return cma;
+
+no_mem:
+	kfree(cma);
+	return ERR_PTR(-ENOMEM);
+}
+
+static struct cma_reserved {
+	phys_addr_t start;
+	unsigned long size;
+	struct device *dev;
+} cma_reserved[MAX_CMA_AREAS] __initdata;
+static unsigned cma_reserved_count __initdata;
+
+static int __init __cma_init_reserved_areas(void)
+{
+	struct cma_reserved *r = cma_reserved;
+	unsigned i = cma_reserved_count;
+
+	pr_debug("%s()\n", __func__);
+
+	for (; i; --i, ++r) {
+		struct cma *cma;
+		cma = __cma_create_area(phys_to_pfn(r->start),
+					r->size >> PAGE_SHIFT);
+		if (!IS_ERR(cma)) {
+			if (r->dev)
+				set_dev_cma_area(r->dev, cma);
+			else
+				dma_contiguous_default_area = cma;
+		}
+	}
+	return 0;
+}
+core_initcall(__cma_init_reserved_areas);
+
+/**
+ * dma_declare_contiguous() - reserve area for contiguous memory handling
+ *			      for particular device
+ * @dev:   Pointer to device structure.
+ * @size:  Size of the reserved memory.
+ * @start: Start address of the reserved memory (optional, 0 for any).
+ * @limit: End address of the reserved memory (optional, 0 for any).
+ *
+ * This funtion reserves memory for specified device. It should be
+ * called by board specific code when early allocator (memblock or bootmem)
+ * is still activate.
+ */
+int __init dma_declare_contiguous(struct device *dev, unsigned long size,
+				  phys_addr_t base, phys_addr_t limit)
+{
+	struct cma_reserved *r = &cma_reserved[cma_reserved_count];
+	unsigned long alignment;
+
+	pr_debug("%s(size %lx, base %08lx, limit %08lx)\n", __func__,
+		 (unsigned long)size, (unsigned long)base,
+		 (unsigned long)limit);
+
+	/* Sanity checks */
+	if (cma_reserved_count == ARRAY_SIZE(cma_reserved))
+		return -ENOSPC;
+
+	if (!size)
+		return -EINVAL;
+
+	/* Sanitise input arguments */
+	alignment = PAGE_SIZE << max(MAX_ORDER, pageblock_order);
+	base = ALIGN(base, alignment);
+	size = ALIGN(size, alignment);
+	limit = ALIGN(limit, alignment);
+
+	/* Reserve memory */
+	if (base) {
+		if (memblock_is_region_reserved(base, size) ||
+		    memblock_reserve(base, size) < 0) {
+			base = -EBUSY;
+			goto err;
+		}
+	} else {
+		/*
+		 * Use __memblock_alloc_base() since
+		 * memblock_alloc_base() panic()s.
+		 */
+		phys_addr_t addr = __memblock_alloc_base(size, alignment, limit);
+		if (!addr) {
+			base = -ENOMEM;
+			goto err;
+		} else if (addr + size > ~(unsigned long)0) {
+			memblock_free(addr, size);
+			base = -EOVERFLOW;
+			goto err;
+		} else {
+			base = addr;
+		}
+	}
+
+	/*
+	 * Each reserved area must be initialised later, when more kernel
+	 * subsystems (like slab allocator) are available.
+	 */
+	r->start = base;
+	r->size = size;
+	r->dev = dev;
+	cma_reserved_count++;
+	printk(KERN_INFO "CMA: reserved %ld MiB at %08lx\n", size / SZ_1M,
+	       (unsigned long)base);
+
+	/*
+	 * Architecture specific contiguous memory fixup.
+	 */
+	dma_contiguous_early_fixup(base, size);
+	return 0;
+err:
+	printk(KERN_ERR "CMA: failed to reserve %ld MiB\n", size / SZ_1M);
+	return base;
+}
+
+/**
+ * dma_alloc_from_contiguous() - allocate pages from contiguous area
+ * @dev:   Pointer to device for which the allocation is performed.
+ * @count: Requested number of pages.
+ * @align: Requested alignment of pages (in PAGE_SIZE order).
+ *
+ * This funtion allocates memory buffer for specified device. It uses
+ * device specific contiguous memory area if available or the default
+ * global one. Requires architecture specific get_dev_cma_area() helper
+ * function.
+ */
+struct page *dma_alloc_from_contiguous(struct device *dev, int count,
+				       unsigned int align)
+{
+	struct cma *cma = get_dev_cma_area(dev);
+	unsigned long pfn, pageno;
+	int ret;
+
+	if (!cma)
+		return NULL;
+
+	if (align > CONFIG_CMA_ALIGNMENT)
+		align = CONFIG_CMA_ALIGNMENT;
+
+	pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,
+		 count, align);
+
+	if (!count)
+		return NULL;
+
+	mutex_lock(&cma_mutex);
+
+	pageno = bitmap_find_next_zero_area(cma->bitmap, cma->count, 0, count,
+					    (1 << align) - 1);
+	if (pageno >= cma->count) {
+		ret = -ENOMEM;
+		goto error;
+	}
+	bitmap_set(cma->bitmap, pageno, count);
+
+	pfn = cma->base_pfn + pageno;
+	ret = alloc_contig_range(pfn, pfn + count, 0, MIGRATE_CMA);
+	if (ret)
+		goto free;
+
+	mutex_unlock(&cma_mutex);
+
+	pr_debug("%s(): returned %p\n", __func__, pfn_to_page(pfn));
+	return pfn_to_page(pfn);
+free:
+	bitmap_clear(cma->bitmap, pageno, count);
+error:
+	mutex_unlock(&cma_mutex);
+	return NULL;
+}
+
+/**
+ * dma_release_from_contiguous() - release allocated pages
+ * @dev:   Pointer to device for which the pages were allocated.
+ * @pages: Allocated pages.
+ * @count: Number of allocated pages.
+ *
+ * This funtion releases memory allocated by dma_alloc_from_contiguous().
+ * It return 0 when provided pages doen't belongs to contiguous area and
+ * 1 on success.
+ */
+int dma_release_from_contiguous(struct device *dev, struct page *pages,
+				int count)
+{
+	struct cma *cma = get_dev_cma_area(dev);
+	unsigned long pfn;
+
+	if (!cma || !pages)
+		return 0;
+
+	pr_debug("%s(page %p)\n", __func__, (void *)pages);
+
+	pfn = page_to_pfn(pages);
+
+	if (pfn < cma->base_pfn || pfn >= cma->base_pfn + cma->count)
+		return 0;
+
+	mutex_lock(&cma_mutex);
+
+	bitmap_clear(cma->bitmap, pfn - cma->base_pfn, count);
+	free_contig_pages(pfn, count);
+
+	mutex_unlock(&cma_mutex);
+	return 1;
+}
diff --git a/include/asm-generic/dma-contiguous.h b/include/asm-generic/dma-contiguous.h
new file mode 100644
index 0000000..8c76649
--- /dev/null
+++ b/include/asm-generic/dma-contiguous.h
@@ -0,0 +1,27 @@
+#ifndef ASM_DMA_CONTIGUOUS_H
+#define ASM_DMA_CONTIGUOUS_H
+
+#ifdef __KERNEL__
+
+#include <linux/device.h>
+#include <linux/dma-contiguous.h>
+
+#ifdef CONFIG_CMA
+
+static inline struct cma *get_dev_cma_area(struct device *dev)
+{
+	if (dev && dev->cma_area)
+		return dev->cma_area;
+	return dma_contiguous_default_area;
+}
+
+static inline void set_dev_cma_area(struct device *dev, struct cma *cma)
+{
+	if (dev)
+		dev->cma_area = cma;
+	dma_contiguous_default_area = cma;
+}
+
+#endif
+#endif
+#endif
diff --git a/include/linux/device.h b/include/linux/device.h
index 8bab5c4..cc1e7f0 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -592,6 +592,10 @@ struct device {
 
 	struct dma_coherent_mem	*dma_mem; /* internal for coherent mem
 					     override */
+#ifdef CONFIG_CMA
+	struct cma *cma_area;		/* contiguous memory area for dma
+					   allocations */
+#endif
 	/* arch specific additions */
 	struct dev_archdata	archdata;
 
diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguous.h
new file mode 100644
index 0000000..7ca81c9
--- /dev/null
+++ b/include/linux/dma-contiguous.h
@@ -0,0 +1,106 @@
+#ifndef __LINUX_CMA_H
+#define __LINUX_CMA_H
+
+/*
+ * Contiguous Memory Allocator for DMA mapping framework
+ * Copyright (c) 2010-2011 by Samsung Electronics.
+ * Written by:
+ *	Marek Szyprowski <m.szyprowski@samsung.com>
+ *	Michal Nazarewicz <mina86@mina86.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ */
+
+/*
+ * Contiguous Memory Allocator
+ *
+ *   The Contiguous Memory Allocator (CMA) makes it possible to
+ *   allocate big contiguous chunks of memory after the system has
+ *   booted.
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
+ *   CMA should not be used by the device drivers directly. It is
+ *   only a helper framework for dma-mapping subsystem.
+ *
+ *   For more information, see kernel-docs in drivers/base/dma-contiguous.c
+ */
+
+#ifdef __KERNEL__
+
+struct cma;
+struct page;
+struct device;
+
+#ifdef CONFIG_CMA
+
+#define MAX_CMA_AREAS	(8)
+
+extern struct cma *dma_contiguous_default_area;
+
+void dma_contiguous_reserve(phys_addr_t addr_limit);
+int dma_declare_contiguous(struct device *dev, unsigned long size,
+			   phys_addr_t base, phys_addr_t limit);
+
+struct page *dma_alloc_from_contiguous(struct device *dev, int count,
+				       unsigned int order);
+int dma_release_from_contiguous(struct device *dev, struct page *pages,
+				int count);
+
+#else
+
+#define MAX_CMA_AREAS	(0)
+
+static inline void dma_contiguous_reserve(phys_addr_t limit) { }
+
+static inline
+int dma_declare_contiguous(struct device *dev, unsigned long size,
+			   phys_addr_t base, phys_addr_t limit)
+{
+	return -ENOSYS;
+}
+
+static inline
+struct page *dma_alloc_from_contiguous(struct device *dev, int count,
+				       unsigned int order)
+{
+	return NULL;
+}
+
+static inline
+int dma_release_from_contiguous(struct device *dev, struct page *pages,
+				int count)
+{
+	return 0;
+}
+
+#endif
+
+#endif
+
+#endif
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
