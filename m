Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 20F586B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 07:41:17 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id q7so9932699ioi.3
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 04:41:17 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h8si937996oib.415.2017.09.21.04.41.15
        for <linux-mm@kvack.org>;
        Thu, 21 Sep 2017 04:41:15 -0700 (PDT)
Subject: Re: [PATCH 4/4] iommu/dma, numa: Use NUMA aware memory allocations in
 __iommu_dma_alloc_pages
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
 <20170921085922.11659-5-ganapatrao.kulkarni@cavium.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <9d65676f-e4e8-e0a6-602c-361d83ce83c1@arm.com>
Date: Thu, 21 Sep 2017 12:41:11 +0100
MIME-Version: 1.0
In-Reply-To: <20170921085922.11659-5-ganapatrao.kulkarni@cavium.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Will.Deacon@arm.com, lorenzo.pieralisi@arm.com, hanjun.guo@linaro.org, joro@8bytes.org, vbabka@suse.cz, akpm@linux-foundation.org, mhocko@suse.com, Tomasz.Nowicki@cavium.com, Robert.Richter@cavium.com, jnair@caviumnetworks.com, gklkml16@gmail.com

On 21/09/17 09:59, Ganapatrao Kulkarni wrote:
> Change function __iommu_dma_alloc_pages to allocate memory/pages
> for dma from respective device numa node.
> 
> Signed-off-by: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
> ---
>  drivers/iommu/dma-iommu.c | 17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
> index 9d1cebe..0626b58 100644
> --- a/drivers/iommu/dma-iommu.c
> +++ b/drivers/iommu/dma-iommu.c
> @@ -428,20 +428,21 @@ static void __iommu_dma_free_pages(struct page **pages, int count)
>  	kvfree(pages);
>  }
>  
> -static struct page **__iommu_dma_alloc_pages(unsigned int count,
> -		unsigned long order_mask, gfp_t gfp)
> +static struct page **__iommu_dma_alloc_pages(struct device *dev,
> +		unsigned int count, unsigned long order_mask, gfp_t gfp)
>  {
>  	struct page **pages;
>  	unsigned int i = 0, array_size = count * sizeof(*pages);
> +	int numa_node = dev_to_node(dev);
>  
>  	order_mask &= (2U << MAX_ORDER) - 1;
>  	if (!order_mask)
>  		return NULL;
>  
>  	if (array_size <= PAGE_SIZE)
> -		pages = kzalloc(array_size, GFP_KERNEL);
> +		pages = kzalloc_node(array_size, GFP_KERNEL, numa_node);
>  	else
> -		pages = vzalloc(array_size);
> +		pages = vzalloc_node(array_size, numa_node);

kvzalloc{,_node}() didn't exist when this code was first written, but it
does now - since you're touching it you may as well get rid of the whole
if-else and array_size local.

Further nit: some of the indentation below is a bit messed up.

Robin.

>  	if (!pages)
>  		return NULL;
>  
> @@ -462,8 +463,9 @@ static struct page **__iommu_dma_alloc_pages(unsigned int count,
>  			unsigned int order = __fls(order_mask);
>  
>  			order_size = 1U << order;
> -			page = alloc_pages((order_mask - order_size) ?
> -					   gfp | __GFP_NORETRY : gfp, order);
> +			page = alloc_pages_node(numa_node,
> +					(order_mask - order_size) ?
> +				   gfp | __GFP_NORETRY : gfp, order);
>  			if (!page)
>  				continue;
>  			if (!order)
> @@ -548,7 +550,8 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
>  		alloc_sizes = min_size;
>  
>  	count = PAGE_ALIGN(size) >> PAGE_SHIFT;
> -	pages = __iommu_dma_alloc_pages(count, alloc_sizes >> PAGE_SHIFT, gfp);
> +	pages = __iommu_dma_alloc_pages(dev, count, alloc_sizes >> PAGE_SHIFT,
> +			gfp);
>  	if (!pages)
>  		return NULL;
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
