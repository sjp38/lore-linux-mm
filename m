Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2C1B86B017D
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 19:57:37 -0400 (EDT)
Received: by ggdk5 with SMTP id k5so2116792ggd.14
        for <linux-mm@kvack.org>; Fri, 14 Oct 2011 16:57:34 -0700 (PDT)
Date: Fri, 14 Oct 2011 16:57:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/9] drivers: add Contiguous Memory Allocator
Message-Id: <20111014165730.e98aee8a.akpm@linux-foundation.org>
In-Reply-To: <1317909290-29832-7-git-send-email-m.szyprowski@samsung.com>
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
	<1317909290-29832-7-git-send-email-m.szyprowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Thu, 06 Oct 2011 15:54:46 +0200
Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> The Contiguous Memory Allocator is a set of helper functions for DMA
> mapping framework that improves allocations of contiguous memory chunks.
> 
> CMA grabs memory on system boot, marks it with CMA_MIGRATE_TYPE and
> gives back to the system. Kernel is allowed to allocate movable pages
> within CMA's managed memory so that it can be used for example for page
> cache when DMA mapping do not use it. On dma_alloc_from_contiguous()
> request such pages are migrated out of CMA area to free required
> contiguous block and fulfill the request. This allows to allocate large
> contiguous chunks of memory at any time assuming that there is enough
> free memory available in the system.
> 
> This code is heavily based on earlier works by Michal Nazarewicz.
> 
>
> ...
>
> +#ifdef phys_to_pfn
> +/* nothing to do */
> +#elif defined __phys_to_pfn
> +#  define phys_to_pfn __phys_to_pfn
> +#elif defined __va
> +#  define phys_to_pfn(x) page_to_pfn(virt_to_page(__va(x)))
> +#else
> +#  error phys_to_pfn implementation needed
> +#endif

Yikes!

This hackery should not be here, please.  If we need a phys_to_pfn()
then let's write a proper one which lives in core MM and arch, then get
it suitably reviewed and integrated and then maintained.

> +struct cma {
> +	unsigned long	base_pfn;
> +	unsigned long	count;
> +	unsigned long	*bitmap;
> +};
> +
> +struct cma *dma_contiguous_default_area;
> +
> +#ifndef CONFIG_CMA_SIZE_ABSOLUTE
> +#define CONFIG_CMA_SIZE_ABSOLUTE 0
> +#endif
> +
> +#ifndef CONFIG_CMA_SIZE_PERCENTAGE
> +#define CONFIG_CMA_SIZE_PERCENTAGE 0
> +#endif

No, .c files should not #define CONFIG_ variables like this.

One approach is

#ifdef CONFIG_FOO
#define BAR CONFIG_FOO
#else
#define BAR 0
#endif

but that's merely cosmetic fluff.  A superior fix is to get the Kconfig
correct, so CONFIG_FOO cannot ever be undefined if we're compiling this
.c file.

> +static unsigned long size_abs = CONFIG_CMA_SIZE_ABSOLUTE * SZ_1M;
> +static unsigned long size_percent = CONFIG_CMA_SIZE_PERCENTAGE;
> +static long size_cmdline = -1;

Maybe a little documentation for these, explaining their role in
everything?

> +static int __init early_cma(char *p)
> +{
> +	pr_debug("%s(%s)\n", __func__, p);
> +	size_cmdline = memparse(p, &p);
> +	return 0;
> +}
> +early_param("cma", early_cma);

Did this get added to Documentation/kernel-parameters.txt?

> +static unsigned long __init __cma_early_get_total_pages(void)

The leading __ seems unnecessay for a static function.

> +{
> +	struct memblock_region *reg;
> +	unsigned long total_pages = 0;
> +
> +	/*
> +	 * We cannot use memblock_phys_mem_size() here, because
> +	 * memblock_analyze() has not been called yet.
> +	 */
> +	for_each_memblock(memory, reg)
> +		total_pages += memblock_region_memory_end_pfn(reg) -
> +			       memblock_region_memory_base_pfn(reg);
> +	return total_pages;
> +}
> +
> +/**
> + * dma_contiguous_reserve() - reserve area for contiguous memory handling
> + *
> + * This funtion reserves memory from early allocator. It should be
> + * called by arch specific code once the early allocator (memblock or bootmem)
> + * has been activated and all other subsystems have already allocated/reserved
> + * memory.
> + */

Forgot to document the argument.

> +void __init dma_contiguous_reserve(phys_addr_t limit)
> +{
> +	unsigned long selected_size = 0;
> +	unsigned long total_pages;
> +
> +	pr_debug("%s(limit %08lx)\n", __func__, (unsigned long)limit);
> +
> +	total_pages = __cma_early_get_total_pages();
> +	size_percent *= (total_pages << PAGE_SHIFT) / 100;
> +
> +	pr_debug("%s: total available: %ld MiB, size absolute: %ld MiB, size percentage: %ld MiB\n",
> +		 __func__, (total_pages << PAGE_SHIFT) / SZ_1M,
> +		size_abs / SZ_1M, size_percent / SZ_1M);
> +
> +#ifdef CONFIG_CMA_SIZE_SEL_ABSOLUTE
> +	selected_size = size_abs;
> +#elif defined(CONFIG_CMA_SIZE_SEL_PERCENTAGE)
> +	selected_size = size_percent;
> +#elif defined(CONFIG_CMA_SIZE_SEL_MIN)
> +	selected_size = min(size_abs, size_percent);
> +#elif defined(CONFIG_CMA_SIZE_SEL_MAX)
> +	selected_size = max(size_abs, size_percent);
> +#endif

geeze, what's all that stuff?

Whatever it's doing, it seems a bad idea to relegate these decisions to
Kconfig-time.  The vast majority of users don't have control of their
kernel configuration!  The code would be more flexible and generic if
this was done at runtime somehow.

> +	if (size_cmdline != -1)
> +		selected_size = size_cmdline;
> +
> +	if (!selected_size)
> +		return;
> +
> +	pr_debug("%s: reserving %ld MiB for global area\n", __func__,
> +		 selected_size / SZ_1M);
> +
> +	dma_declare_contiguous(NULL, selected_size, 0, limit);
> +};
> +
>
> ...
>
> +static struct cma *__cma_create_area(unsigned long base_pfn,

s/__//?

> +				     unsigned long count)
> +{
> +	int bitmap_size = BITS_TO_LONGS(count) * sizeof(long);
> +	struct cma *cma;
> +
> +	pr_debug("%s(base %08lx, count %lx)\n", __func__, base_pfn, count);
> +
> +	cma = kmalloc(sizeof *cma, GFP_KERNEL);
> +	if (!cma)
> +		return ERR_PTR(-ENOMEM);
> +
> +	cma->base_pfn = base_pfn;
> +	cma->count = count;
> +	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> +
> +	if (!cma->bitmap)
> +		goto no_mem;
> +
> +	__cma_activate_area(base_pfn, count);
> +
> +	pr_debug("%s: returned %p\n", __func__, (void *)cma);
> +	return cma;
> +
> +no_mem:
> +	kfree(cma);
> +	return ERR_PTR(-ENOMEM);
> +}
>
> ...
>
> +int __init dma_declare_contiguous(struct device *dev, unsigned long size,
> +				  phys_addr_t base, phys_addr_t limit)
> +{
> +	struct cma_reserved *r = &cma_reserved[cma_reserved_count];
> +	unsigned long alignment;
> +
> +	pr_debug("%s(size %lx, base %08lx, limit %08lx)\n", __func__,
> +		 (unsigned long)size, (unsigned long)base,
> +		 (unsigned long)limit);
> +
> +	/* Sanity checks */
> +	if (cma_reserved_count == ARRAY_SIZE(cma_reserved))
> +		return -ENOSPC;

I think a loud printk() is appropriate if the kernel fails in this
manner.

> +	if (!size)
> +		return -EINVAL;
> +
> +	/* Sanitise input arguments */
> +	alignment = PAGE_SIZE << max(MAX_ORDER, pageblock_order);
> +	base = ALIGN(base, alignment);
> +	size = ALIGN(size, alignment);
> +	limit = ALIGN(limit, alignment);
> +
> +	/* Reserve memory */
> +	if (base) {
> +		if (memblock_is_region_reserved(base, size) ||
> +		    memblock_reserve(base, size) < 0) {
> +			base = -EBUSY;
> +			goto err;
> +		}
> +	} else {
> +		/*
> +		 * Use __memblock_alloc_base() since
> +		 * memblock_alloc_base() panic()s.
> +		 */
> +		phys_addr_t addr = __memblock_alloc_base(size, alignment, limit);
> +		if (!addr) {
> +			base = -ENOMEM;
> +			goto err;
> +		} else if (addr + size > ~(unsigned long)0) {
> +			memblock_free(addr, size);
> +			base = -EOVERFLOW;

EOVERFLOW is a numeric/float thing.  It seems inappropriate to use it
here.

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
> +	r->start = base;
> +	r->size = size;
> +	r->dev = dev;
> +	cma_reserved_count++;
> +	printk(KERN_INFO "CMA: reserved %ld MiB at %08lx\n", size / SZ_1M,
> +	       (unsigned long)base);
> +
> +	/*
> +	 * Architecture specific contiguous memory fixup.
> +	 */
> +	dma_contiguous_early_fixup(base, size);
> +	return 0;
> +err:
> +	printk(KERN_ERR "CMA: failed to reserve %ld MiB\n", size / SZ_1M);
> +	return base;
> +}
> +
>
> ...
>
> +static inline struct cma *get_dev_cma_area(struct device *dev)
> +{
> +	if (dev && dev->cma_area)
> +		return dev->cma_area;
> +	return dma_contiguous_default_area;
> +}
> +
> +static inline void set_dev_cma_area(struct device *dev, struct cma *cma)
> +{
> +	if (dev)
> +		dev->cma_area = cma;
> +	dma_contiguous_default_area = cma;
> +}

dev_[get|set]_cma_area() would be better names.

> +#endif
> +#endif
> +#endif
>
> ...
>
> +
> +#ifdef CONFIG_CMA
> +
> +#define MAX_CMA_AREAS	(8)

What are the implications of this decision?

Should it be in Kconfig?  Everything else is :)

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
