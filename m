Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 995896B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 09:44:01 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so5504459pac.3
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 06:44:01 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id rz10si6028069pbc.56.2014.07.18.06.44.00
        for <linux-mm@kvack.org>;
        Fri, 18 Jul 2014 06:44:00 -0700 (PDT)
Date: Fri, 18 Jul 2014 14:43:43 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv4 5/5] arm64: Add atomic pool for non-coherent and CMA
 allocations.
Message-ID: <20140718134343.GA4608@arm.com>
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org>
 <1404324218-4743-6-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404324218-4743-6-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Will Deacon <Will.Deacon@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jul 02, 2014 at 07:03:38PM +0100, Laura Abbott wrote:
> diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
> index 4164c5a..a2487f1 100644
> --- a/arch/arm64/mm/dma-mapping.c
> +++ b/arch/arm64/mm/dma-mapping.c
[...]
>  static void *__dma_alloc_coherent(struct device *dev, size_t size,
>  				  dma_addr_t *dma_handle, gfp_t flags,
>  				  struct dma_attrs *attrs)
> @@ -53,7 +103,8 @@ static void *__dma_alloc_coherent(struct device *dev, size_t size,
>  	if (IS_ENABLED(CONFIG_ZONE_DMA) &&
>  	    dev->coherent_dma_mask <= DMA_BIT_MASK(32))
>  		flags |= GFP_DMA;
> -	if (IS_ENABLED(CONFIG_DMA_CMA)) {
> +
> +	if (!(flags & __GFP_WAIT) && IS_ENABLED(CONFIG_DMA_CMA)) {
>  		struct page *page;
>  
>  		size = PAGE_ALIGN(size);

I think that's the wrong condition here. You want to use CMA if
(flags & __GFP_WAIT). CMA does not support atomic allocations so it can
fall back to swiotlb_alloc_coherent().

> @@ -73,50 +124,56 @@ static void __dma_free_coherent(struct device *dev, size_t size,
>  				void *vaddr, dma_addr_t dma_handle,
>  				struct dma_attrs *attrs)
>  {
> +	bool freed;
> +	phys_addr_t paddr = dma_to_phys(dev, dma_handle);
> +
>  	if (dev == NULL) {
>  		WARN_ONCE(1, "Use an actual device structure for DMA allocation\n");
>  		return;
>  	}
>  
> -	if (IS_ENABLED(CONFIG_DMA_CMA)) {
> -		phys_addr_t paddr = dma_to_phys(dev, dma_handle);
>  
> -		dma_release_from_contiguous(dev,
> +	freed = dma_release_from_contiguous(dev,
>  					phys_to_page(paddr),
>  					size >> PAGE_SHIFT);
> -	} else {
> +	if (!freed)
>  		swiotlb_free_coherent(dev, size, vaddr, dma_handle);
> -	}
>  }

Is __dma_free_coherent() ever called in atomic context? If yes, the
dma_release_from_contiguous() may not like it since it tries to acquire
a mutex. But since we don't have the gfp flags here, we don't have an
easy way to know what to call.

So the initial idea of always calling __alloc_from_pool() for both
coherent/non-coherent cases would work better (but still with a single
shared pool, see below).

>  static void *__dma_alloc_noncoherent(struct device *dev, size_t size,
>  				     dma_addr_t *dma_handle, gfp_t flags,
>  				     struct dma_attrs *attrs)
>  {
> -	struct page *page, **map;
> +	struct page *page;
>  	void *ptr, *coherent_ptr;
> -	int order, i;
>  
>  	size = PAGE_ALIGN(size);
> -	order = get_order(size);
> +
> +	if (!(flags & __GFP_WAIT)) {
> +		struct page *page = NULL;
> +		void *addr = __alloc_from_pool(size, &page);
> +
> +		if (addr)
> +			*dma_handle = phys_to_dma(dev, page_to_phys(page));
> +
> +		return addr;
> +
> +	}

If we do the above for the __dma_alloc_coherent() case, we could use the
same pool but instead of returning addr it could just return
page_address(page). The downside of sharing the pool is that you need
cache flushing for every allocation (which we already do for the
non-atomic case).

> @@ -332,6 +391,67 @@ static struct notifier_block amba_bus_nb = {
>  
>  extern int swiotlb_late_init_with_default_size(size_t default_size);
>  
> +static int __init atomic_pool_init(void)
> +{
> +	pgprot_t prot = __pgprot(PROT_NORMAL_NC);
> +	unsigned long nr_pages = atomic_pool_size >> PAGE_SHIFT;
> +	struct page *page;
> +	void *addr;
> +
> +
> +	if (dev_get_cma_area(NULL))

Is it worth using this condition for other places where we check
IS_ENABLED(CONFIG_DMA_CMA) (maybe as a separate patch).

> +		page = dma_alloc_from_contiguous(NULL, nr_pages,
> +					get_order(atomic_pool_size));
> +	else
> +		page = alloc_pages(GFP_KERNEL, get_order(atomic_pool_size));

One problem here is that the atomic pool wouldn't be able to honour
GFP_DMA (in the latest kernel, CMA is by default in ZONE_DMA). You
should probably pass GFP_KERNEL|GFP_DMA here. You could also use the
swiotlb_alloc_coherent() which, with a NULL dev, assumes 32-bit DMA mask
but it still expects GFP_DMA to be passed.

> +	if (page) {
> +		int ret;
> +
> +		atomic_pool = gen_pool_create(PAGE_SHIFT, -1);
> +		if (!atomic_pool)
> +			goto free_page;
> +
> +		addr = dma_common_contiguous_remap(page, atomic_pool_size,
> +					VM_USERMAP, prot, atomic_pool_init);
> +
> +		if (!addr)
> +			goto destroy_genpool;
> +
> +		memset(addr, 0, atomic_pool_size);
> +		__dma_flush_range(addr, addr + atomic_pool_size);

If you add the flushing in the __dma_alloc_noncoherent(), it won't be
needed here (of course, more efficient here but it would not work if we
share the pool).

> +postcore_initcall(atomic_pool_init);

Why not arch_initcall? Or even better, we could have a common DMA init
function that calls swiotlb_late_init() and atomic_pool_init() (in this
order if you decide to use swiotlb allocation above).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
