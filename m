Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2E680900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 01:52:12 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id fp1so603100pdb.31
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 22:52:11 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id cd2si40449125pbb.90.2014.06.11.22.52.10
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 22:52:11 -0700 (PDT)
Date: Thu, 12 Jun 2014 14:52:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 04/10] DMA, CMA: support alignment constraint on cma
 region
Message-ID: <20140612055219.GG12415@bbox>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-5-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402543307-29800-5-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, kvm@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexander Graf <agraf@suse.de>, kvm-ppc@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paolo Bonzini <pbonzini@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Thu, Jun 12, 2014 at 12:21:41PM +0900, Joonsoo Kim wrote:
> ppc kvm's cma area management needs alignment constraint on
> cma region. So support it to prepare generalization of cma area
> management functionality.
> 
> Additionally, add some comments which tell us why alignment
> constraint is needed on cma region.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> index 8a44c82..bc4c171 100644
> --- a/drivers/base/dma-contiguous.c
> +++ b/drivers/base/dma-contiguous.c
> @@ -32,6 +32,7 @@
>  #include <linux/swap.h>
>  #include <linux/mm_types.h>
>  #include <linux/dma-contiguous.h>
> +#include <linux/log2.h>
>  
>  struct cma {
>  	unsigned long	base_pfn;
> @@ -219,6 +220,7 @@ core_initcall(cma_init_reserved_areas);
>   * @size: Size of the reserved area (in bytes),
>   * @base: Base address of the reserved area optional, use 0 for any
>   * @limit: End address of the reserved memory (optional, 0 for any).
> + * @alignment: Alignment for the contiguous memory area, should be power of 2
>   * @res_cma: Pointer to store the created cma region.
>   * @fixed: hint about where to place the reserved area
>   *

Pz, move the all description to new API function rather than internal one.

> @@ -233,15 +235,15 @@ core_initcall(cma_init_reserved_areas);
>   */
>  static int __init __dma_contiguous_reserve_area(phys_addr_t size,
>  				phys_addr_t base, phys_addr_t limit,
> +				phys_addr_t alignment,
>  				struct cma **res_cma, bool fixed)
>  {
>  	struct cma *cma = &cma_areas[cma_area_count];
> -	phys_addr_t alignment;
>  	int ret = 0;
>  
> -	pr_debug("%s(size %lx, base %08lx, limit %08lx)\n", __func__,
> -		 (unsigned long)size, (unsigned long)base,
> -		 (unsigned long)limit);
> +	pr_debug("%s(size %lx, base %08lx, limit %08lx align_order %08lx)\n",

Why is it called by "align_order"?

> +		__func__, (unsigned long)size, (unsigned long)base,
> +		(unsigned long)limit, (unsigned long)alignment);
>  
>  	/* Sanity checks */
>  	if (cma_area_count == ARRAY_SIZE(cma_areas)) {
> @@ -253,8 +255,17 @@ static int __init __dma_contiguous_reserve_area(phys_addr_t size,
>  	if (!size)
>  		return -EINVAL;
>  
> -	/* Sanitise input arguments */
> -	alignment = PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order);
> +	if (alignment && !is_power_of_2(alignment))
> +		return -EINVAL;
> +
> +	/*
> +	 * Sanitise input arguments.
> +	 * CMA area should be at least MAX_ORDER - 1 aligned. Otherwise,
> +	 * CMA area could be merged into other MIGRATE_TYPE by buddy mechanism

I'm not a native but try for clear documenation.

         Pages both ends in CMA area could be merged into adjacent unmovable
         migratetype page by page allocator's buddy algorithm. In the case,
         you couldn't get a contiguous memory, which is not what we want.

> +	 * and CMA property will be broken.
> +	 */
> +	alignment = max(alignment,
> +		(phys_addr_t)PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order));
>  	base = ALIGN(base, alignment);
>  	size = ALIGN(size, alignment);
>  	limit &= ~(alignment - 1);
> @@ -302,7 +313,8 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
>  {
>  	int ret;
>  
> -	ret = __dma_contiguous_reserve_area(size, base, limit, res_cma, fixed);
> +	ret = __dma_contiguous_reserve_area(size, base, limit, 0,
> +						res_cma, fixed);
>  	if (ret)
>  		return ret;
>  
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
