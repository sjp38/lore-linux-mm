Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 88C29900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 03:13:21 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so700209pad.21
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 00:13:21 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id uc7si40679398pbc.40.2014.06.12.00.13.18
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 00:13:20 -0700 (PDT)
Date: Thu, 12 Jun 2014 16:13:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 06/10] CMA: generalize CMA reserved area management
 functionality
Message-ID: <20140612071311.GJ12415@bbox>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-7-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402543307-29800-7-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, kvm@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexander Graf <agraf@suse.de>, kvm-ppc@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paolo Bonzini <pbonzini@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Thu, Jun 12, 2014 at 12:21:43PM +0900, Joonsoo Kim wrote:
> Currently, there are two users on CMA functionality, one is the DMA
> subsystem and the other is the kvm on powerpc. They have their own code
> to manage CMA reserved area even if they looks really similar.
> >From my guess, it is caused by some needs on bitmap management. Kvm side
> wants to maintain bitmap not for 1 page, but for more size. Eventually it
> use bitmap where one bit represents 64 pages.
> 
> When I implement CMA related patches, I should change those two places
> to apply my change and it seem to be painful to me. I want to change
> this situation and reduce future code management overhead through
> this patch.
> 
> This change could also help developer who want to use CMA in their
> new feature development, since they can use CMA easily without
> copying & pasting this reserved area management code.
> 
> In previous patches, we have prepared some features to generalize
> CMA reserved area management and now it's time to do it. This patch
> moves core functions to mm/cma.c and change DMA APIs to use
> these functions.
> 
> There is no functional change in DMA APIs.
> 
> v2: There is no big change from v1 in mm/cma.c. Mostly renaming.
> 
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acutally, I want to remove bool return of cma_release but it's not
a out of scope in this patchset.

Acked-by: Minchan Kim <minchan@kernel.org>

> 
> diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
> index 00e13ce..4eac559 100644
> --- a/drivers/base/Kconfig
> +++ b/drivers/base/Kconfig
> @@ -283,16 +283,6 @@ config CMA_ALIGNMENT
>  
>  	  If unsure, leave the default value "8".
>  
> -config CMA_AREAS
> -	int "Maximum count of the CMA device-private areas"
> -	default 7
> -	help
> -	  CMA allows to create CMA areas for particular devices. This parameter
> -	  sets the maximum number of such device private CMA areas in the
> -	  system.
> -
> -	  If unsure, leave the default value "7".
> -
>  endif
>  
>  endmenu
> diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> index 9bc9340..f177f73 100644
> --- a/drivers/base/dma-contiguous.c
> +++ b/drivers/base/dma-contiguous.c
> @@ -24,25 +24,10 @@
>  
>  #include <linux/memblock.h>
>  #include <linux/err.h>
> -#include <linux/mm.h>
> -#include <linux/mutex.h>
> -#include <linux/page-isolation.h>
>  #include <linux/sizes.h>
> -#include <linux/slab.h>
> -#include <linux/swap.h>
> -#include <linux/mm_types.h>
>  #include <linux/dma-contiguous.h>
>  #include <linux/log2.h>

Should we remain log2.h in here?

> -
> -struct cma {
> -	unsigned long	base_pfn;
> -	unsigned long	count;
> -	unsigned long	*bitmap;
> -	int order_per_bit; /* Order of pages represented by one bit */
> -	struct mutex	lock;
> -};
> -
> -struct cma *dma_contiguous_default_area;
> +#include <linux/cma.h>
>  
>  #ifdef CONFIG_CMA_SIZE_MBYTES
>  #define CMA_SIZE_MBYTES CONFIG_CMA_SIZE_MBYTES
> @@ -50,6 +35,8 @@ struct cma *dma_contiguous_default_area;
>  #define CMA_SIZE_MBYTES 0
>  #endif
>  
> +struct cma *dma_contiguous_default_area;
> +
>  /*
>   * Default global CMA area size can be defined in kernel's .config.
>   * This is useful mainly for distro maintainers to create a kernel
> @@ -156,199 +143,13 @@ void __init dma_contiguous_reserve(phys_addr_t limit)
>  	}
>  }
>  
> -static DEFINE_MUTEX(cma_mutex);
> -
> -static unsigned long cma_bitmap_aligned_mask(struct cma *cma, int align_order)
> -{
> -	return (1 << (align_order >> cma->order_per_bit)) - 1;
> -}
> -
> -static unsigned long cma_bitmap_maxno(struct cma *cma)
> -{
> -	return cma->count >> cma->order_per_bit;
> -}
> -
> -static unsigned long cma_bitmap_pages_to_bits(struct cma *cma,
> -						unsigned long pages)
> -{
> -	return ALIGN(pages, 1 << cma->order_per_bit) >> cma->order_per_bit;
> -}
> -
> -static void clear_cma_bitmap(struct cma *cma, unsigned long pfn, int count)
> -{
> -	unsigned long bitmapno, nr_bits;
> -
> -	bitmapno = (pfn - cma->base_pfn) >> cma->order_per_bit;
> -	nr_bits = cma_bitmap_pages_to_bits(cma, count);
> -
> -	mutex_lock(&cma->lock);
> -	bitmap_clear(cma->bitmap, bitmapno, nr_bits);
> -	mutex_unlock(&cma->lock);
> -}
> -
> -static int __init cma_activate_area(struct cma *cma)
> -{
> -	int bitmap_maxno = cma_bitmap_maxno(cma);
> -	int bitmap_size = BITS_TO_LONGS(bitmap_maxno) * sizeof(long);
> -	unsigned long base_pfn = cma->base_pfn, pfn = base_pfn;
> -	unsigned i = cma->count >> pageblock_order;
> -	struct zone *zone;
> -
> -	pr_debug("%s()\n", __func__);
> -
> -	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> -	if (!cma->bitmap)
> -		return -ENOMEM;
> -
> -	WARN_ON_ONCE(!pfn_valid(pfn));
> -	zone = page_zone(pfn_to_page(pfn));
> -
> -	do {
> -		unsigned j;
> -		base_pfn = pfn;
> -		for (j = pageblock_nr_pages; j; --j, pfn++) {
> -			WARN_ON_ONCE(!pfn_valid(pfn));
> -			/*
> -			 * alloc_contig_range requires the pfn range
> -			 * specified to be in the same zone. Make this
> -			 * simple by forcing the entire CMA resv range
> -			 * to be in the same zone.
> -			 */
> -			if (page_zone(pfn_to_page(pfn)) != zone)
> -				goto err;
> -		}
> -		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
> -	} while (--i);
> -
> -	mutex_init(&cma->lock);
> -	return 0;
> -
> -err:
> -	kfree(cma->bitmap);
> -	return -EINVAL;
> -}
> -
> -static struct cma cma_areas[MAX_CMA_AREAS];
> -static unsigned cma_area_count;
> -
> -static int __init cma_init_reserved_areas(void)
> -{
> -	int i;
> -
> -	for (i = 0; i < cma_area_count; i++) {
> -		int ret = cma_activate_area(&cma_areas[i]);
> -		if (ret)
> -			return ret;
> -	}
> -
> -	return 0;
> -}
> -core_initcall(cma_init_reserved_areas);
> -
> -/**
> - * dma_contiguous_reserve_area() - reserve custom contiguous area
> - * @size: Size of the reserved area (in bytes),
> - * @base: Base address of the reserved area optional, use 0 for any
> - * @limit: End address of the reserved memory (optional, 0 for any).
> - * @alignment: Alignment for the contiguous memory area, should be power of 2
> - * @order_per_bit: Order of pages represented by one bit on bitmap.
> - * @res_cma: Pointer to store the created cma region.
> - * @fixed: hint about where to place the reserved area
> - *
> - * This function reserves memory from early allocator. It should be
> - * called by arch specific code once the early allocator (memblock or bootmem)
> - * has been activated and all other subsystems have already allocated/reserved
> - * memory. This function allows to create custom reserved areas for specific
> - * devices.
> - *
> - * If @fixed is true, reserve contiguous area at exactly @base.  If false,
> - * reserve in range from @base to @limit.
> - */
> -static int __init __dma_contiguous_reserve_area(phys_addr_t size,
> -				phys_addr_t base, phys_addr_t limit,
> -				phys_addr_t alignment, int order_per_bit,
> -				struct cma **res_cma, bool fixed)
> -{
> -	struct cma *cma = &cma_areas[cma_area_count];
> -	int ret = 0;
> -
> -	pr_debug("%s(size %lx, base %08lx, limit %08lx align_order %08lx)\n",
> -		__func__, (unsigned long)size, (unsigned long)base,
> -		(unsigned long)limit, (unsigned long)alignment);
> -
> -	/* Sanity checks */
> -	if (cma_area_count == ARRAY_SIZE(cma_areas)) {
> -		pr_err("%s(): Not enough slots for CMA reserved regions!\n",
> -			__func__);
> -		return -ENOSPC;
> -	}
> -
> -	if (!size)
> -		return -EINVAL;
> -
> -	if (alignment && !is_power_of_2(alignment))
> -		return -EINVAL;
> -
> -	/*
> -	 * Sanitise input arguments.
> -	 * CMA area should be at least MAX_ORDER - 1 aligned. Otherwise,
> -	 * CMA area could be merged into other MIGRATE_TYPE by buddy mechanism
> -	 * and CMA property will be broken.
> -	 */
> -	alignment = max(alignment,
> -		(phys_addr_t)PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order));
> -	base = ALIGN(base, alignment);
> -	size = ALIGN(size, alignment);
> -	limit &= ~(alignment - 1);
> -	/* size should be aligned with order_per_bit */
> -	BUG_ON(!IS_ALIGNED(size >> PAGE_SHIFT, 1 << order_per_bit));
> -
> -	/* Reserve memory */
> -	if (base && fixed) {
> -		if (memblock_is_region_reserved(base, size) ||
> -		    memblock_reserve(base, size) < 0) {
> -			ret = -EBUSY;
> -			goto err;
> -		}
> -	} else {
> -		phys_addr_t addr = memblock_alloc_range(size, alignment, base,
> -							limit);
> -		if (!addr) {
> -			ret = -ENOMEM;
> -			goto err;
> -		} else {
> -			base = addr;
> -		}
> -	}
> -
> -	/*
> -	 * Each reserved area must be initialised later, when more kernel
> -	 * subsystems (like slab allocator) are available.
> -	 */
> -	cma->base_pfn = PFN_DOWN(base);
> -	cma->count = size >> PAGE_SHIFT;
> -	cma->order_per_bit = order_per_bit;
> -	*res_cma = cma;
> -	cma_area_count++;
> -
> -	pr_info("%s(): reserved %ld MiB at %08lx\n",
> -		__func__, (unsigned long)size / SZ_1M, (unsigned long)base);
> -	return 0;
> -
> -err:
> -	pr_err("%s(): failed to reserve %ld MiB\n",
> -		__func__, (unsigned long)size / SZ_1M);
> -	return ret;
> -}
> -
>  int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
>  				       phys_addr_t limit, struct cma **res_cma,
>  				       bool fixed)
>  {
>  	int ret;
>  
> -	ret = __dma_contiguous_reserve_area(size, base, limit, 0, 0,
> -						res_cma, fixed);
> +	ret = cma_declare_contiguous(size, base, limit, 0, 0, res_cma, fixed);
>  	if (ret)
>  		return ret;
>  
> @@ -358,124 +159,17 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
>  	return 0;
>  }
>  
> -/**
> - * dma_alloc_from_contiguous() - allocate pages from contiguous area
> - * @dev:   Pointer to device for which the allocation is performed.
> - * @count: Requested number of pages.
> - * @align: Requested alignment of pages (in PAGE_SIZE order).
> - *
> - * This function allocates memory buffer for specified device. It uses
> - * device specific contiguous memory area if available or the default
> - * global one. Requires architecture specific dev_get_cma_area() helper
> - * function.
> - */
> -static struct page *__dma_alloc_from_contiguous(struct cma *cma, int count,
> -				       unsigned int align)
> -{
> -	unsigned long mask, pfn, start = 0;
> -	unsigned long bitmap_maxno, bitmapno, nr_bits;
> -	struct page *page = NULL;
> -	int ret;
> -
> -	if (!cma || !cma->count)
> -		return NULL;
> -
> -	pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,
> -		 count, align);
> -
> -	if (!count)
> -		return NULL;
> -
> -	mask = cma_bitmap_aligned_mask(cma, align);
> -	bitmap_maxno = cma_bitmap_maxno(cma);
> -	nr_bits = cma_bitmap_pages_to_bits(cma, count);
> -
> -	for (;;) {
> -		mutex_lock(&cma->lock);
> -		bitmapno = bitmap_find_next_zero_area(cma->bitmap,
> -					bitmap_maxno, start, nr_bits, mask);
> -		if (bitmapno >= bitmap_maxno) {
> -			mutex_unlock(&cma->lock);
> -			break;
> -		}
> -		bitmap_set(cma->bitmap, bitmapno, nr_bits);
> -		/*
> -		 * It's safe to drop the lock here. We've marked this region for
> -		 * our exclusive use. If the migration fails we will take the
> -		 * lock again and unmark it.
> -		 */
> -		mutex_unlock(&cma->lock);
> -
> -		pfn = cma->base_pfn + (bitmapno << cma->order_per_bit);
> -		mutex_lock(&cma_mutex);
> -		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
> -		mutex_unlock(&cma_mutex);
> -		if (ret == 0) {
> -			page = pfn_to_page(pfn);
> -			break;
> -		} else if (ret != -EBUSY) {
> -			clear_cma_bitmap(cma, pfn, count);
> -			break;
> -		}
> -		clear_cma_bitmap(cma, pfn, count);
> -		pr_debug("%s(): memory range at %p is busy, retrying\n",
> -			 __func__, pfn_to_page(pfn));
> -		/* try again with a bit different memory target */
> -		start = bitmapno + mask + 1;
> -	}
> -
> -	pr_debug("%s(): returned %p\n", __func__, page);
> -	return page;
> -}
> -
>  struct page *dma_alloc_from_contiguous(struct device *dev, int count,
>  				       unsigned int align)
>  {
> -	struct cma *cma = dev_get_cma_area(dev);
> -
>  	if (align > CONFIG_CMA_ALIGNMENT)
>  		align = CONFIG_CMA_ALIGNMENT;
>  
> -	return __dma_alloc_from_contiguous(cma, count, align);
> -}
> -
> -/**
> - * dma_release_from_contiguous() - release allocated pages
> - * @dev:   Pointer to device for which the pages were allocated.
> - * @pages: Allocated pages.
> - * @count: Number of allocated pages.
> - *
> - * This function releases memory allocated by dma_alloc_from_contiguous().
> - * It returns false when provided pages do not belong to contiguous area and
> - * true otherwise.
> - */
> -static bool __dma_release_from_contiguous(struct cma *cma, struct page *pages,
> -				 int count)
> -{
> -	unsigned long pfn;
> -
> -	if (!cma || !pages)
> -		return false;
> -
> -	pr_debug("%s(page %p)\n", __func__, (void *)pages);
> -
> -	pfn = page_to_pfn(pages);
> -
> -	if (pfn < cma->base_pfn || pfn >= cma->base_pfn + cma->count)
> -		return false;
> -
> -	VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
> -
> -	free_contig_range(pfn, count);
> -	clear_cma_bitmap(cma, pfn, count);
> -
> -	return true;
> +	return cma_alloc(dev_get_cma_area(dev), count, align);
>  }
>  
>  bool dma_release_from_contiguous(struct device *dev, struct page *pages,
>  				 int count)
>  {
> -	struct cma *cma = dev_get_cma_area(dev);
> -
> -	return __dma_release_from_contiguous(cma, pages, count);
> +	return cma_release(dev_get_cma_area(dev), pages, count);
>  }
> diff --git a/include/linux/cma.h b/include/linux/cma.h
> new file mode 100644
> index 0000000..e38efe9
> --- /dev/null
> +++ b/include/linux/cma.h
> @@ -0,0 +1,12 @@
> +#ifndef __CMA_H__
> +#define __CMA_H__
> +
> +struct cma;
> +
> +extern int __init cma_declare_contiguous(phys_addr_t size,
> +				phys_addr_t base, phys_addr_t limit,
> +				phys_addr_t alignment, int order_per_bit,
> +				struct cma **res_cma, bool fixed);
> +extern struct page *cma_alloc(struct cma *cma, int count, unsigned int align);
> +extern bool cma_release(struct cma *cma, struct page *pages, int count);
> +#endif
> diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguous.h
> index 772eab5..a40c1f3 100644
> --- a/include/linux/dma-contiguous.h
> +++ b/include/linux/dma-contiguous.h
> @@ -53,9 +53,10 @@
>  
>  #ifdef __KERNEL__
>  
> +#include <linux/device.h>
> +
>  struct cma;
>  struct page;
> -struct device;
>  
>  #ifdef CONFIG_DMA_CMA
>  
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 3e9977a..f4899ec 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -508,6 +508,17 @@ config CMA_DEBUG
>  	  processing calls such as dma_alloc_from_contiguous().
>  	  This option does not affect warning and error messages.
>  
> +config CMA_AREAS
> +	int "Maximum count of the CMA areas"
> +	depends on CMA
> +	default 7
> +	help
> +	  CMA allows to create CMA areas for particular purpose, mainly,
> +	  used as device private area. This parameter sets the maximum
> +	  number of CMA area in the system.
> +
> +	  If unsure, leave the default value "7".
> +
>  config ZBUD
>  	tristate
>  	default n
> diff --git a/mm/Makefile b/mm/Makefile
> index 1eaa70b..bc0422b 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -62,3 +62,4 @@ obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
>  obj-$(CONFIG_ZBUD)	+= zbud.o
>  obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
>  obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
> +obj-$(CONFIG_CMA)	+= cma.o
> diff --git a/mm/cma.c b/mm/cma.c
> new file mode 100644
> index 0000000..1e1b017
> --- /dev/null
> +++ b/mm/cma.c
> @@ -0,0 +1,330 @@
> +/*
> + * Contiguous Memory Allocator
> + *
> + * Copyright (c) 2010-2011 by Samsung Electronics.
> + * Copyright IBM Corporation, 2013
> + * Copyright LG Electronics Inc., 2014
> + * Written by:
> + *	Marek Szyprowski <m.szyprowski@samsung.com>
> + *	Michal Nazarewicz <mina86@mina86.com>
> + *	Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> + *	Joonsoo Kim <iamjoonsoo.kim@lge.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation; either version 2 of the
> + * License or (at your optional) any later version of the license.
> + */
> +
> +#define pr_fmt(fmt) "cma: " fmt
> +
> +#ifdef CONFIG_CMA_DEBUG
> +#ifndef DEBUG
> +#  define DEBUG
> +#endif
> +#endif
> +
> +#include <linux/memblock.h>
> +#include <linux/err.h>
> +#include <linux/mm.h>
> +#include <linux/mutex.h>
> +#include <linux/sizes.h>
> +#include <linux/slab.h>
> +
> +struct cma {
> +	unsigned long	base_pfn;
> +	unsigned long	count;
> +	unsigned long	*bitmap;
> +	int order_per_bit; /* Order of pages represented by one bit */
> +	struct mutex	lock;
> +};
> +
> +/*
> + * There is always at least global CMA area and a few optional
> + * areas configured in kernel .config.
> + */
> +#define MAX_CMA_AREAS	(1 + CONFIG_CMA_AREAS)
> +
> +static struct cma cma_areas[MAX_CMA_AREAS];
> +static unsigned cma_area_count;
> +static DEFINE_MUTEX(cma_mutex);
> +
> +static unsigned long cma_bitmap_aligned_mask(struct cma *cma, int align_order)
> +{
> +	return (1 << (align_order >> cma->order_per_bit)) - 1;
> +}
> +
> +static unsigned long cma_bitmap_maxno(struct cma *cma)
> +{
> +	return cma->count >> cma->order_per_bit;
> +}
> +
> +static unsigned long cma_bitmap_pages_to_bits(struct cma *cma,
> +						unsigned long pages)
> +{
> +	return ALIGN(pages, 1 << cma->order_per_bit) >> cma->order_per_bit;
> +}
> +
> +static void clear_cma_bitmap(struct cma *cma, unsigned long pfn, int count)
> +{
> +	unsigned long bitmapno, nr_bits;
> +
> +	bitmapno = (pfn - cma->base_pfn) >> cma->order_per_bit;
> +	nr_bits = cma_bitmap_pages_to_bits(cma, count);
> +
> +	mutex_lock(&cma->lock);
> +	bitmap_clear(cma->bitmap, bitmapno, nr_bits);
> +	mutex_unlock(&cma->lock);
> +}
> +
> +static int __init cma_activate_area(struct cma *cma)
> +{
> +	int bitmap_maxno = cma_bitmap_maxno(cma);
> +	int bitmap_size = BITS_TO_LONGS(bitmap_maxno) * sizeof(long);
> +	unsigned long base_pfn = cma->base_pfn, pfn = base_pfn;
> +	unsigned i = cma->count >> pageblock_order;
> +	struct zone *zone;
> +
> +	pr_debug("%s()\n", __func__);
> +
> +	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> +	if (!cma->bitmap)
> +		return -ENOMEM;
> +
> +	WARN_ON_ONCE(!pfn_valid(pfn));
> +	zone = page_zone(pfn_to_page(pfn));
> +
> +	do {
> +		unsigned j;
> +
> +		base_pfn = pfn;
> +		for (j = pageblock_nr_pages; j; --j, pfn++) {
> +			WARN_ON_ONCE(!pfn_valid(pfn));
> +			/*
> +			 * alloc_contig_range requires the pfn range
> +			 * specified to be in the same zone. Make this
> +			 * simple by forcing the entire CMA resv range
> +			 * to be in the same zone.
> +			 */
> +			if (page_zone(pfn_to_page(pfn)) != zone)
> +				goto err;
> +		}
> +		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
> +	} while (--i);
> +
> +	mutex_init(&cma->lock);
> +	return 0;
> +
> +err:
> +	kfree(cma->bitmap);
> +	return -EINVAL;
> +}
> +
> +static int __init cma_init_reserved_areas(void)
> +{
> +	int i;
> +
> +	for (i = 0; i < cma_area_count; i++) {
> +		int ret = cma_activate_area(&cma_areas[i]);
> +
> +		if (ret)
> +			return ret;
> +	}
> +
> +	return 0;
> +}
> +core_initcall(cma_init_reserved_areas);
> +
> +/**
> + * cma_declare_contiguous() - reserve custom contiguous area
> + * @size: Size of the reserved area (in bytes),
> + * @base: Base address of the reserved area optional, use 0 for any
> + * @limit: End address of the reserved memory (optional, 0 for any).
> + * @alignment: Alignment for the contiguous memory area, should be power of 2
> + * @order_per_bit: Order of pages represented by one bit on bitmap.
> + * @res_cma: Pointer to store the created cma region.
> + * @fixed: hint about where to place the reserved area
> + *
> + * This function reserves memory from early allocator. It should be
> + * called by arch specific code once the early allocator (memblock or bootmem)
> + * has been activated and all other subsystems have already allocated/reserved
> + * memory. This function allows to create custom reserved areas.
> + *
> + * If @fixed is true, reserve contiguous area at exactly @base.  If false,
> + * reserve in range from @base to @limit.
> + */
> +int __init cma_declare_contiguous(phys_addr_t size,
> +				phys_addr_t base, phys_addr_t limit,
> +				phys_addr_t alignment, int order_per_bit,
> +				struct cma **res_cma, bool fixed)
> +{
> +	struct cma *cma = &cma_areas[cma_area_count];
> +	int ret = 0;
> +
> +	pr_debug("%s(size %lx, base %08lx, limit %08lx alignment %08lx)\n",
> +		__func__, (unsigned long)size, (unsigned long)base,
> +		(unsigned long)limit, (unsigned long)alignment);
> +
> +	/* Sanity checks */
> +	if (cma_area_count == ARRAY_SIZE(cma_areas)) {
> +		pr_err("%s(): Not enough slots for CMA reserved regions!\n",
> +			__func__);
> +		return -ENOSPC;
> +	}
> +
> +	if (!size)
> +		return -EINVAL;
> +
> +	if (alignment && !is_power_of_2(alignment))
> +		return -EINVAL;
> +
> +	/*
> +	 * Sanitise input arguments.
> +	 * CMA area should be at least MAX_ORDER - 1 aligned. Otherwise,
> +	 * CMA area could be merged into other MIGRATE_TYPE by buddy mechanism
> +	 * and CMA property will be broken.
> +	 */
> +	alignment = max(alignment,
> +		(phys_addr_t)PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order));
> +	base = ALIGN(base, alignment);
> +	size = ALIGN(size, alignment);
> +	limit &= ~(alignment - 1);
> +	/* size should be aligned with order_per_bit */
> +	BUG_ON(!IS_ALIGNED(size >> PAGE_SHIFT, 1 << order_per_bit));
> +
> +	/* Reserve memory */
> +	if (base && fixed) {
> +		if (memblock_is_region_reserved(base, size) ||
> +		    memblock_reserve(base, size) < 0) {
> +			ret = -EBUSY;
> +			goto err;
> +		}
> +	} else {
> +		phys_addr_t addr = memblock_alloc_range(size, alignment, base,
> +							limit);
> +		if (!addr) {
> +			ret = -ENOMEM;
> +			goto err;
> +		} else {
> +			base = addr;
> +		}
> +	}
> +
> +	/*
> +	 * Each reserved area must be initialised later, when more kernel
> +	 * subsystems (like slab allocator) are available.
> +	 */
> +	cma->base_pfn = PFN_DOWN(base);
> +	cma->count = size >> PAGE_SHIFT;
> +	cma->order_per_bit = order_per_bit;
> +	*res_cma = cma;
> +	cma_area_count++;
> +
> +	pr_info("%s(): reserved %ld MiB at %08lx\n",
> +		__func__, (unsigned long)size / SZ_1M, (unsigned long)base);
> +	return 0;
> +
> +err:
> +	pr_err("%s(): failed to reserve %ld MiB\n",
> +		__func__, (unsigned long)size / SZ_1M);
> +	return ret;
> +}
> +
> +/**
> + * cma_alloc() - allocate pages from contiguous area
> + * @cma:   Contiguous memory region for which the allocation is performed.
> + * @count: Requested number of pages.
> + * @align: Requested alignment of pages (in PAGE_SIZE order).
> + *
> + * This function allocates part of contiguous memory on specific
> + * contiguous memory area.
> + */
> +struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
> +{
> +	unsigned long mask, pfn, start = 0;
> +	unsigned long bitmap_maxno, bitmapno, nr_bits;
> +	struct page *page = NULL;
> +	int ret;
> +
> +	if (!cma || !cma->count)
> +		return NULL;
> +
> +	pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,
> +		 count, align);
> +
> +	if (!count)
> +		return NULL;
> +
> +	mask = cma_bitmap_aligned_mask(cma, align);
> +	bitmap_maxno = cma_bitmap_maxno(cma);
> +	nr_bits = cma_bitmap_pages_to_bits(cma, count);
> +
> +	for (;;) {
> +		mutex_lock(&cma->lock);
> +		bitmapno = bitmap_find_next_zero_area(cma->bitmap,
> +					bitmap_maxno, start, nr_bits, mask);
> +		if (bitmapno >= bitmap_maxno) {
> +			mutex_unlock(&cma->lock);
> +			break;
> +		}
> +		bitmap_set(cma->bitmap, bitmapno, nr_bits);
> +		/*
> +		 * It's safe to drop the lock here. We've marked this region for
> +		 * our exclusive use. If the migration fails we will take the
> +		 * lock again and unmark it.
> +		 */
> +		mutex_unlock(&cma->lock);
> +
> +		pfn = cma->base_pfn + (bitmapno << cma->order_per_bit);
> +		mutex_lock(&cma_mutex);
> +		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
> +		mutex_unlock(&cma_mutex);
> +		if (ret == 0) {
> +			page = pfn_to_page(pfn);
> +			break;
> +		} else if (ret != -EBUSY) {
> +			clear_cma_bitmap(cma, pfn, count);
> +			break;
> +		}
> +		clear_cma_bitmap(cma, pfn, count);
> +		pr_debug("%s(): memory range at %p is busy, retrying\n",
> +			 __func__, pfn_to_page(pfn));
> +		/* try again with a bit different memory target */
> +		start = bitmapno + mask + 1;
> +	}
> +
> +	pr_debug("%s(): returned %p\n", __func__, page);
> +	return page;
> +}
> +
> +/**
> + * cma_release() - release allocated pages
> + * @cma:   Contiguous memory region for which the allocation is performed.
> + * @pages: Allocated pages.
> + * @count: Number of allocated pages.
> + *
> + * This function releases memory allocated by alloc_cma().
> + * It returns false when provided pages do not belong to contiguous area and
> + * true otherwise.
> + */
> +bool cma_release(struct cma *cma, struct page *pages, int count)
> +{
> +	unsigned long pfn;
> +
> +	if (!cma || !pages)
> +		return false;
> +
> +	pr_debug("%s(page %p)\n", __func__, (void *)pages);
> +
> +	pfn = page_to_pfn(pages);
> +
> +	if (pfn < cma->base_pfn || pfn >= cma->base_pfn + cma->count)
> +		return false;
> +
> +	VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
> +
> +	free_contig_range(pfn, count);
> +	clear_cma_bitmap(cma, pfn, count);
> +
> +	return true;
> +}
> -- 
> 1.7.9.5

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
