Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 28C776B00B2
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 21:08:46 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id fa1so3716756pad.22
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 18:08:45 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ql2si17805185pbb.240.2014.06.02.18.08.43
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 18:08:45 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 1/3] CMA: generalize CMA reserved area management functionality
Date: Tue,  3 Jun 2014 10:11:56 +0900
Message-Id: <1401757919-30018-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1401757919-30018-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1401757919-30018-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, there are two users on CMA functionality, one is the DMA
subsystem and the other is the kvm on powerpc. They have their own code
to manage CMA reserved area even if they looks really similar.
>From my guess, it is caused by some needs on bitmap management. Kvm side
wants to maintain bitmap not for 1 page, but for more size. Eventually it
use bitmap where one bit represents 64 pages.

When I implement CMA related patches, I should change those two places
to apply my change and it seem to be painful to me. I want to change
this situation and reduce future code management overhead through
this patch.

This change could also help developer who want to use CMA in their
new feature development, since they can use CMA easily without
copying & pasting this reserved area management code.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 00e13ce..b3fe1cc 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -283,7 +283,7 @@ config CMA_ALIGNMENT
 
 	  If unsure, leave the default value "8".
 
-config CMA_AREAS
+config DMA_CMA_AREAS
 	int "Maximum count of the CMA device-private areas"
 	default 7
 	help
diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index 83969f8..48cdac8 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -186,7 +186,7 @@ static int __init cma_activate_area(struct cma *cma)
 	return 0;
 }
 
-static struct cma cma_areas[MAX_CMA_AREAS];
+static struct cma cma_areas[MAX_DMA_CMA_AREAS];
 static unsigned cma_area_count;
 
 static int __init cma_init_reserved_areas(void)
diff --git a/include/linux/cma.h b/include/linux/cma.h
new file mode 100644
index 0000000..60ba06f
--- /dev/null
+++ b/include/linux/cma.h
@@ -0,0 +1,28 @@
+/*
+ * Contiguous Memory Allocator
+ *
+ * Copyright LG Electronics Inc., 2014
+ * Written by:
+ *	Joonsoo Kim <iamjoonsoo.kim@lge.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ *
+ */
+
+#ifndef __CMA_H__
+#define __CMA_H__
+
+struct cma;
+
+extern struct page *cma_alloc(struct cma *cma, unsigned long count,
+				unsigned long align);
+extern bool cma_release(struct cma *cma, struct page *pages,
+				unsigned long count);
+extern int __init cma_declare_contiguous(phys_addr_t size, phys_addr_t base,
+				phys_addr_t limit, phys_addr_t alignment,
+				unsigned long bitmap_shift, bool fixed,
+				struct cma **res_cma);
+#endif
diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguous.h
index 772eab5..dfb1dc9 100644
--- a/include/linux/dma-contiguous.h
+++ b/include/linux/dma-contiguous.h
@@ -63,7 +63,7 @@ struct device;
  * There is always at least global CMA area and a few optional device
  * private areas configured in kernel .config.
  */
-#define MAX_CMA_AREAS	(1 + CONFIG_CMA_AREAS)
+#define MAX_DMA_CMA_AREAS  (1 + CONFIG_DMA_CMA_AREAS)
 
 extern struct cma *dma_contiguous_default_area;
 
@@ -123,7 +123,7 @@ bool dma_release_from_contiguous(struct device *dev, struct page *pages,
 
 #else
 
-#define MAX_CMA_AREAS	(0)
+#define MAX_DMA_CMA_AREAS	(0)
 
 static inline struct cma *dev_get_cma_area(struct device *dev)
 {
diff --git a/mm/Kconfig b/mm/Kconfig
index 7511b4a..0877ddc 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -515,6 +515,17 @@ config CMA_DEBUG
 	  processing calls such as dma_alloc_from_contiguous().
 	  This option does not affect warning and error messages.
 
+config CMA_AREAS
+	int "Maximum count of the CMA areas"
+	depends on CMA
+	default 7
+	help
+	  CMA allows to create CMA areas for particular purpose, mainly,
+	  used as device private area. This parameter sets the maximum
+	  number of CMA area in the system.
+
+	  If unsure, leave the default value "7".
+
 config ZBUD
 	tristate
 	default n
diff --git a/mm/Makefile b/mm/Makefile
index 1eaa70b..bc0422b 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -62,3 +62,4 @@ obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
 obj-$(CONFIG_ZBUD)	+= zbud.o
 obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
 obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
+obj-$(CONFIG_CMA)	+= cma.o
diff --git a/mm/cma.c b/mm/cma.c
new file mode 100644
index 0000000..0dae88d
--- /dev/null
+++ b/mm/cma.c
@@ -0,0 +1,329 @@
+/*
+ * Contiguous Memory Allocator
+ *
+ * Copyright (c) 2010-2011 by Samsung Electronics.
+ * Copyright IBM Corporation, 2013
+ * Copyright LG Electronics Inc., 2014
+ * Written by:
+ *	Marek Szyprowski <m.szyprowski@samsung.com>
+ *	Michal Nazarewicz <mina86@mina86.com>
+ *	Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
+ *	Joonsoo Kim <iamjoonsoo.kim@lge.com>
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
+#include <linux/memblock.h>
+#include <linux/err.h>
+#include <linux/mm.h>
+#include <linux/mutex.h>
+#include <linux/sizes.h>
+#include <linux/slab.h>
+
+struct cma {
+	unsigned long	base_pfn;
+	unsigned long	count;
+	unsigned long	*bitmap;
+	unsigned long	bitmap_shift;
+	struct mutex	lock;
+};
+
+/*
+ * There is always at least global CMA area and a few optional
+ * areas configured in kernel .config.
+ */
+#define MAX_CMA_AREAS	(1 + CONFIG_CMA_AREAS)
+
+static struct cma cma_areas[MAX_CMA_AREAS];
+static unsigned cma_area_count;
+static DEFINE_MUTEX(cma_mutex);
+
+static unsigned long cma_bitmap_mask(struct cma *cma,
+				unsigned long align_order)
+{
+	return (1 << (align_order >> cma->bitmap_shift)) - 1;
+}
+
+static unsigned long cma_bitmap_max_no(struct cma *cma)
+{
+	return cma->count >> cma->bitmap_shift;
+}
+
+static unsigned long cma_bitmap_pages_to_bits(struct cma *cma,
+						unsigned long pages)
+{
+	return ALIGN(pages, 1 << cma->bitmap_shift) >> cma->bitmap_shift;
+}
+
+static void clear_cma_bitmap(struct cma *cma, unsigned long pfn, int count)
+{
+	unsigned long bitmapno, nr_bits;
+
+	bitmapno = (pfn - cma->base_pfn) >> cma->bitmap_shift;
+	nr_bits = cma_bitmap_pages_to_bits(cma, count);
+
+	mutex_lock(&cma->lock);
+	bitmap_clear(cma->bitmap, bitmapno, nr_bits);
+	mutex_unlock(&cma->lock);
+}
+
+static int __init cma_activate_area(struct cma *cma)
+{
+	int max_bitmapno = cma_bitmap_max_no(cma);
+	int bitmap_size = BITS_TO_LONGS(max_bitmapno) * sizeof(long);
+	unsigned long base_pfn = cma->base_pfn, pfn = base_pfn;
+	unsigned i = cma->count >> pageblock_order;
+	struct zone *zone;
+
+	pr_debug("%s()\n", __func__);
+	if (!cma->count)
+		return 0;
+
+	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
+	if (!cma->bitmap)
+		return -ENOMEM;
+
+	WARN_ON_ONCE(!pfn_valid(pfn));
+	zone = page_zone(pfn_to_page(pfn));
+
+	do {
+		unsigned j;
+
+		base_pfn = pfn;
+		for (j = pageblock_nr_pages; j; --j, pfn++) {
+			WARN_ON_ONCE(!pfn_valid(pfn));
+			/*
+			 * alloc_contig_range requires the pfn range
+			 * specified to be in the same zone. Make this
+			 * simple by forcing the entire CMA resv range
+			 * to be in the same zone.
+			 */
+			if (page_zone(pfn_to_page(pfn)) != zone)
+				goto err;
+		}
+		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
+	} while (--i);
+
+	mutex_init(&cma->lock);
+	return 0;
+
+err:
+	kfree(cma->bitmap);
+	return -EINVAL;
+}
+
+static int __init cma_init_reserved_areas(void)
+{
+	int i;
+
+	for (i = 0; i < cma_area_count; i++) {
+		int ret = cma_activate_area(&cma_areas[i]);
+
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+core_initcall(cma_init_reserved_areas);
+
+/**
+ * cma_declare_contiguous() - reserve custom contiguous area
+ * @size: Size of the reserved area (in bytes),
+ * @base: Base address of the reserved area optional, use 0 for any
+ * @limit: End address of the reserved memory (optional, 0 for any).
+ * @bitmap_shift: Order of pages represented by one bit on bitmap.
+ * @fixed: hint about where to place the reserved area
+ * @res_cma: Pointer to store the created cma region.
+ *
+ * This function reserves memory from early allocator. It should be
+ * called by arch specific code once the early allocator (memblock or bootmem)
+ * has been activated and all other subsystems have already allocated/reserved
+ * memory. This function allows to create custom reserved areas.
+ *
+ * If @fixed is true, reserve contiguous area at exactly @base.  If false,
+ * reserve in range from @base to @limit.
+ */
+int __init cma_declare_contiguous(phys_addr_t size, phys_addr_t base,
+				phys_addr_t limit, phys_addr_t alignment,
+				unsigned long bitmap_shift, bool fixed,
+				struct cma **res_cma)
+{
+	struct cma *cma = &cma_areas[cma_area_count];
+	int ret = 0;
+
+	pr_debug("%s(size %lx, base %08lx, limit %08lx, alignment %08lx)\n",
+			__func__, (unsigned long)size, (unsigned long)base,
+			(unsigned long)limit, (unsigned long)alignment);
+
+	/* Sanity checks */
+	if (cma_area_count == ARRAY_SIZE(cma_areas)) {
+		pr_err("Not enough slots for CMA reserved regions!\n");
+		return -ENOSPC;
+	}
+
+	if (!size)
+		return -EINVAL;
+
+	/*
+	 * Sanitise input arguments.
+	 * CMA area should be at least MAX_ORDER - 1 aligned. Otherwise,
+	 * CMA area could be merged into other MIGRATE_TYPE by buddy mechanism
+	 * and CMA property will be broken.
+	 */
+	alignment >>= PAGE_SHIFT;
+	alignment = PAGE_SIZE << max3(MAX_ORDER - 1, pageblock_order,
+						(int)alignment);
+	base = ALIGN(base, alignment);
+	size = ALIGN(size, alignment);
+	limit &= ~(alignment - 1);
+	/* size should be aligned with bitmap_shift */
+	BUG_ON(!IS_ALIGNED(size >> PAGE_SHIFT, 1 << cma->bitmap_shift));
+
+	/* Reserve memory */
+	if (base && fixed) {
+		if (memblock_is_region_reserved(base, size) ||
+		    memblock_reserve(base, size) < 0) {
+			ret = -EBUSY;
+			goto err;
+		}
+	} else {
+		phys_addr_t addr = memblock_alloc_range(size, alignment, base,
+							limit);
+		if (!addr) {
+			ret = -ENOMEM;
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
+	cma->base_pfn = PFN_DOWN(base);
+	cma->count = size >> PAGE_SHIFT;
+	cma->bitmap_shift = bitmap_shift;
+	*res_cma = cma;
+	cma_area_count++;
+
+	pr_info("CMA: reserved %ld MiB at %08lx\n", (unsigned long)size / SZ_1M,
+		(unsigned long)base);
+
+	return 0;
+
+err:
+	pr_err("CMA: failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
+	return ret;
+}
+
+/**
+ * cma_alloc() - allocate pages from contiguous area
+ * @cma:   Contiguous memory region for which the allocation is performed.
+ * @count: Requested number of pages.
+ * @align: Requested alignment of pages (in PAGE_SIZE order).
+ *
+ * This function allocates part of contiguous memory on specific
+ * contiguous memory area.
+ */
+struct page *cma_alloc(struct cma *cma, unsigned long count,
+				       unsigned long align)
+{
+	unsigned long mask, pfn, start = 0;
+	unsigned long max_bitmapno, bitmapno, nr_bits;
+	struct page *page = NULL;
+	int ret;
+
+	if (!cma || !cma->count)
+		return NULL;
+
+	pr_debug("%s(cma %p, count %ld, align %ld)\n", __func__, (void *)cma,
+		 count, align);
+
+	if (!count)
+		return NULL;
+
+	mask = cma_bitmap_mask(cma, align);
+	max_bitmapno = cma_bitmap_max_no(cma);
+	nr_bits = cma_bitmap_pages_to_bits(cma, count);
+
+	for (;;) {
+		mutex_lock(&cma->lock);
+		bitmapno = bitmap_find_next_zero_area(cma->bitmap,
+					max_bitmapno, start, nr_bits, mask);
+		if (bitmapno >= max_bitmapno) {
+			mutex_unlock(&cma->lock);
+			break;
+		}
+		bitmap_set(cma->bitmap, bitmapno, nr_bits);
+		/*
+		 * It's safe to drop the lock here. We've marked this region for
+		 * our exclusive use. If the migration fails we will take the
+		 * lock again and unmark it.
+		 */
+		mutex_unlock(&cma->lock);
+
+		pfn = cma->base_pfn + (bitmapno << cma->bitmap_shift);
+		mutex_lock(&cma_mutex);
+		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
+		mutex_unlock(&cma_mutex);
+		if (ret == 0) {
+			page = pfn_to_page(pfn);
+			break;
+		}
+		clear_cma_bitmap(cma, pfn, count);
+		if (ret != -EBUSY)
+			break;
+
+		pr_debug("%s(): memory range at %p is busy, retrying\n",
+			 __func__, pfn_to_page(pfn));
+		/* try again with a bit different memory target */
+		start = bitmapno + mask + 1;
+	}
+
+	pr_debug("%s(): returned %p\n", __func__, page);
+	return page;
+}
+
+/**
+ * cma_release() - release allocated pages
+ * @cma:   Contiguous memory region for which the allocation is performed.
+ * @pages: Allocated pages.
+ * @count: Number of allocated pages.
+ *
+ * This function releases memory allocated by alloc_cma().
+ * It returns false when provided pages do not belong to contiguous area and
+ * true otherwise.
+ */
+bool cma_release(struct cma *cma, struct page *pages, unsigned long count)
+{
+	unsigned long pfn;
+
+	if (!cma || !pages)
+		return false;
+
+	pr_debug("%s(page %p)\n", __func__, (void *)pages);
+
+	pfn = page_to_pfn(pages);
+	if (pfn < cma->base_pfn || pfn >= cma->base_pfn + cma->count)
+		return false;
+
+	VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
+
+	free_contig_range(pfn, count);
+	clear_cma_bitmap(cma, pfn, count);
+
+	return true;
+}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
