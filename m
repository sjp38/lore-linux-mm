Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 321BD6B00B3
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 21:08:48 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so4775219pbb.36
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 18:08:47 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id db3si17873451pbb.85.2014.06.02.18.08.46
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 18:08:47 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 2/3] DMA, CMA: use general CMA reserved area management framework
Date: Tue,  3 Jun 2014 10:11:57 +0900
Message-Id: <1401757919-30018-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1401757919-30018-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1401757919-30018-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, we have general CMA reserved area management framework,
so use it for future maintainabilty. There is no functional change.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index b3fe1cc..4eac559 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -283,16 +283,6 @@ config CMA_ALIGNMENT
 
 	  If unsure, leave the default value "8".
 
-config DMA_CMA_AREAS
-	int "Maximum count of the CMA device-private areas"
-	default 7
-	help
-	  CMA allows to create CMA areas for particular devices. This parameter
-	  sets the maximum number of such device private CMA areas in the
-	  system.
-
-	  If unsure, leave the default value "7".
-
 endif
 
 endmenu
diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index 48cdac8..4bce4e1 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -24,23 +24,9 @@
 
 #include <linux/memblock.h>
 #include <linux/err.h>
-#include <linux/mm.h>
-#include <linux/mutex.h>
-#include <linux/page-isolation.h>
 #include <linux/sizes.h>
-#include <linux/slab.h>
-#include <linux/swap.h>
-#include <linux/mm_types.h>
 #include <linux/dma-contiguous.h>
-
-struct cma {
-	unsigned long	base_pfn;
-	unsigned long	count;
-	unsigned long	*bitmap;
-	struct mutex	lock;
-};
-
-struct cma *dma_contiguous_default_area;
+#include <linux/cma.h>
 
 #ifdef CONFIG_CMA_SIZE_MBYTES
 #define CMA_SIZE_MBYTES CONFIG_CMA_SIZE_MBYTES
@@ -48,6 +34,8 @@ struct cma *dma_contiguous_default_area;
 #define CMA_SIZE_MBYTES 0
 #endif
 
+struct cma *dma_contiguous_default_area;
+
 /*
  * Default global CMA area size can be defined in kernel's .config.
  * This is useful mainly for distro maintainers to create a kernel
@@ -154,55 +142,6 @@ void __init dma_contiguous_reserve(phys_addr_t limit)
 	}
 }
 
-static DEFINE_MUTEX(cma_mutex);
-
-static int __init cma_activate_area(struct cma *cma)
-{
-	int bitmap_size = BITS_TO_LONGS(cma->count) * sizeof(long);
-	unsigned long base_pfn = cma->base_pfn, pfn = base_pfn;
-	unsigned i = cma->count >> pageblock_order;
-	struct zone *zone;
-
-	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
-
-	if (!cma->bitmap)
-		return -ENOMEM;
-
-	WARN_ON_ONCE(!pfn_valid(pfn));
-	zone = page_zone(pfn_to_page(pfn));
-
-	do {
-		unsigned j;
-		base_pfn = pfn;
-		for (j = pageblock_nr_pages; j; --j, pfn++) {
-			WARN_ON_ONCE(!pfn_valid(pfn));
-			if (page_zone(pfn_to_page(pfn)) != zone)
-				return -EINVAL;
-		}
-		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
-	} while (--i);
-
-	mutex_init(&cma->lock);
-	return 0;
-}
-
-static struct cma cma_areas[MAX_DMA_CMA_AREAS];
-static unsigned cma_area_count;
-
-static int __init cma_init_reserved_areas(void)
-{
-	int i;
-
-	for (i = 0; i < cma_area_count; i++) {
-		int ret = cma_activate_area(&cma_areas[i]);
-		if (ret)
-			return ret;
-	}
-
-	return 0;
-}
-core_initcall(cma_init_reserved_areas);
-
 /**
  * dma_contiguous_reserve_area() - reserve custom contiguous area
  * @size: Size of the reserved area (in bytes),
@@ -224,176 +163,31 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
 				       phys_addr_t limit, struct cma **res_cma,
 				       bool fixed)
 {
-	struct cma *cma = &cma_areas[cma_area_count];
-	phys_addr_t alignment;
-	int ret = 0;
-
-	pr_debug("%s(size %lx, base %08lx, limit %08lx)\n", __func__,
-		 (unsigned long)size, (unsigned long)base,
-		 (unsigned long)limit);
-
-	/* Sanity checks */
-	if (cma_area_count == ARRAY_SIZE(cma_areas)) {
-		pr_err("Not enough slots for CMA reserved regions!\n");
-		return -ENOSPC;
-	}
-
-	if (!size)
-		return -EINVAL;
-
-	/* Sanitise input arguments */
-	alignment = PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order);
-	base = ALIGN(base, alignment);
-	size = ALIGN(size, alignment);
-	limit &= ~(alignment - 1);
-
-	/* Reserve memory */
-	if (base && fixed) {
-		if (memblock_is_region_reserved(base, size) ||
-		    memblock_reserve(base, size) < 0) {
-			ret = -EBUSY;
-			goto err;
-		}
-	} else {
-		phys_addr_t addr = memblock_alloc_range(size, alignment, base,
-							limit);
-		if (!addr) {
-			ret = -ENOMEM;
-			goto err;
-		} else {
-			base = addr;
-		}
-	}
-
-	/*
-	 * Each reserved area must be initialised later, when more kernel
-	 * subsystems (like slab allocator) are available.
-	 */
-	cma->base_pfn = PFN_DOWN(base);
-	cma->count = size >> PAGE_SHIFT;
-	*res_cma = cma;
-	cma_area_count++;
+	int ret;
+	struct cma *cma;
 
-	pr_info("CMA: reserved %ld MiB at %08lx\n", (unsigned long)size / SZ_1M,
-		(unsigned long)base);
+	ret = cma_declare_contiguous(size, base, limit, 0, 0, fixed, &cma);
+	if (ret)
+		return ret;
 
 	/* Architecture specific contiguous memory fixup. */
 	dma_contiguous_early_fixup(base, size);
-	return 0;
-err:
-	pr_err("CMA: failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
-	return ret;
-}
+	*res_cma = cma;
 
-static void clear_cma_bitmap(struct cma *cma, unsigned long pfn, int count)
-{
-	mutex_lock(&cma->lock);
-	bitmap_clear(cma->bitmap, pfn - cma->base_pfn, count);
-	mutex_unlock(&cma->lock);
+	return 0;
 }
 
-/**
- * dma_alloc_from_contiguous() - allocate pages from contiguous area
- * @dev:   Pointer to device for which the allocation is performed.
- * @count: Requested number of pages.
- * @align: Requested alignment of pages (in PAGE_SIZE order).
- *
- * This function allocates memory buffer for specified device. It uses
- * device specific contiguous memory area if available or the default
- * global one. Requires architecture specific dev_get_cma_area() helper
- * function.
- */
 struct page *dma_alloc_from_contiguous(struct device *dev, int count,
 				       unsigned int align)
 {
-	unsigned long mask, pfn, pageno, start = 0;
-	struct cma *cma = dev_get_cma_area(dev);
-	struct page *page = NULL;
-	int ret;
-
-	if (!cma || !cma->count)
-		return NULL;
-
 	if (align > CONFIG_CMA_ALIGNMENT)
 		align = CONFIG_CMA_ALIGNMENT;
 
-	pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,
-		 count, align);
-
-	if (!count)
-		return NULL;
-
-	mask = (1 << align) - 1;
-
-
-	for (;;) {
-		mutex_lock(&cma->lock);
-		pageno = bitmap_find_next_zero_area(cma->bitmap, cma->count,
-						    start, count, mask);
-		if (pageno >= cma->count) {
-			mutex_unlock(&cma->lock);
-			break;
-		}
-		bitmap_set(cma->bitmap, pageno, count);
-		/*
-		 * It's safe to drop the lock here. We've marked this region for
-		 * our exclusive use. If the migration fails we will take the
-		 * lock again and unmark it.
-		 */
-		mutex_unlock(&cma->lock);
-
-		pfn = cma->base_pfn + pageno;
-		mutex_lock(&cma_mutex);
-		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
-		mutex_unlock(&cma_mutex);
-		if (ret == 0) {
-			page = pfn_to_page(pfn);
-			break;
-		} else if (ret != -EBUSY) {
-			clear_cma_bitmap(cma, pfn, count);
-			break;
-		}
-		clear_cma_bitmap(cma, pfn, count);
-		pr_debug("%s(): memory range at %p is busy, retrying\n",
-			 __func__, pfn_to_page(pfn));
-		/* try again with a bit different memory target */
-		start = pageno + mask + 1;
-	}
-
-	pr_debug("%s(): returned %p\n", __func__, page);
-	return page;
+	return cma_alloc(dev_get_cma_area(dev), count, align);
 }
 
-/**
- * dma_release_from_contiguous() - release allocated pages
- * @dev:   Pointer to device for which the pages were allocated.
- * @pages: Allocated pages.
- * @count: Number of allocated pages.
- *
- * This function releases memory allocated by dma_alloc_from_contiguous().
- * It returns false when provided pages do not belong to contiguous area and
- * true otherwise.
- */
 bool dma_release_from_contiguous(struct device *dev, struct page *pages,
 				 int count)
 {
-	struct cma *cma = dev_get_cma_area(dev);
-	unsigned long pfn;
-
-	if (!cma || !pages)
-		return false;
-
-	pr_debug("%s(page %p)\n", __func__, (void *)pages);
-
-	pfn = page_to_pfn(pages);
-
-	if (pfn < cma->base_pfn || pfn >= cma->base_pfn + cma->count)
-		return false;
-
-	VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
-
-	free_contig_range(pfn, count);
-	clear_cma_bitmap(cma, pfn, count);
-
-	return true;
+	return cma_release(dev_get_cma_area(dev), pages, count);
 }
diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguous.h
index dfb1dc9..ecb85ac 100644
--- a/include/linux/dma-contiguous.h
+++ b/include/linux/dma-contiguous.h
@@ -53,9 +53,10 @@
 
 #ifdef __KERNEL__
 
+#include <linux/device.h>
+
 struct cma;
 struct page;
-struct device;
 
 #ifdef CONFIG_DMA_CMA
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
