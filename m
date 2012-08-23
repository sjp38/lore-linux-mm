Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 8D2D46B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 03:33:23 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout3.samsung.com [203.254.224.33])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M97001H56B92P10@mailout3.samsung.com> for
 linux-mm@kvack.org; Thu, 23 Aug 2012 16:33:22 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M97002YW6B6HG50@mmp1.samsung.com> for linux-mm@kvack.org;
 Thu, 23 Aug 2012 16:33:21 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1345702229-9539-1-git-send-email-hdoyu@nvidia.com>
 <1345702229-9539-5-git-send-email-hdoyu@nvidia.com>
In-reply-to: <1345702229-9539-5-git-send-email-hdoyu@nvidia.com>
Subject: RE: [v2 4/4] ARM: dma-mapping: IOMMU allocates pages from atomic_pool
 with GFP_ATOMIC
Date: Thu, 23 Aug 2012 09:33:05 +0200
Message-id: <013c01cd8101$8ccfa020$a66ee060$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hiroshi Doyu' <hdoyu@nvidia.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, konrad.wilk@oracle.com, subashrp@gmail.com, minchan@kernel.org, pullip.cho@samsung.com

Hi Hiroshi,

On Thursday, August 23, 2012 8:10 AM Hiroshi Doyu wrote:

> Makes use of the same atomic pool from DMA, and skips kernel page
> mapping which can involve sleep'able operations at allocating a kernel
> page table.
> 
> Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
> ---
>  arch/arm/mm/dma-mapping.c |   30 +++++++++++++++++++++++++-----
>  1 files changed, 25 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 7ab016b..433312a 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -1063,7 +1063,6 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t
> size,
>  	struct page **pages;
>  	int count = size >> PAGE_SHIFT;
>  	int array_size = count * sizeof(struct page *);
> -	int err;
> 
>  	if ((array_size <= PAGE_SIZE) || (gfp & GFP_ATOMIC))
>  		pages = kzalloc(array_size, gfp);
> @@ -1072,9 +1071,20 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t
> size,
>  	if (!pages)
>  		return NULL;
> 
> -	err = __alloc_fill_pages(&pages, count, gfp);
> -	if (err)
> -		goto error
> +	if (gfp & GFP_ATOMIC) {
> +		struct page *page;
> +		int i;
> +		void *addr = __alloc_from_pool(size, &page);
> +		if (!addr)
> +			goto error;
> +
> +		for (i = 0; i < count; i++)
> +			pages[i] = page + i;
> +	} else {
> +		int err = __alloc_fill_pages(&pages, count, gfp);
> +		if (err)
> +			goto error;
> +	}
> 
>  	return pages;
> 
> @@ -1091,9 +1101,15 @@ static int __iommu_free_buffer(struct device *dev, struct page **pages,
> size_t s
>  	int count = size >> PAGE_SHIFT;
>  	int array_size = count * sizeof(struct page *);
>  	int i;
> +
> +	if (__free_from_pool(page_address(pages[0]), size))
> +		goto out;
> +
>  	for (i = 0; i < count; i++)
>  		if (pages[i])
>  			__free_pages(pages[i], 0);
> +
> +out:
>  	if ((array_size <= PAGE_SIZE) ||
>  	    __in_atomic_pool(page_address(pages[0]), size))
>  		kfree(pages);
> @@ -1221,6 +1237,9 @@ static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
>  	if (*handle == DMA_ERROR_CODE)
>  		goto err_buffer;
> 
> +	if (gfp & GFP_ATOMIC)
> +		return page_address(pages[0]);
> +
>  	if (dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, attrs))
>  		return pages;
> 

I've read the whole code and it looks that it starts to become a little spaghetti - there are too
many places altered by those atomic changes and it is hard to follow the logic at the first sight.

IMHO it will be better to add a following function:

static void *__iommu_alloc_atomic(struct device *dev, size_t size,
                                  dma_addr_t *handle)
{
        struct page *page, **pages;
        int count = size >> PAGE_SHIFT;
        int array_size = count * sizeof(struct page *);
        void *addr;
        int i;

        pages = kzalloc(array_size, gfp);
        if (!pages)
                return NULL;

        addr = __alloc_from_pool(size, &page);
        if (!addr)
                goto err_pool;

        for (i = 0; i < count; i++)
                pages[i] = page + i;

        *handle = __iommu_create_mapping(dev, pages, size);
        if (*handle == DMA_ERROR_CODE)
                goto err_mapping;

        return addr;

err_mapping:
        __free_from_pool(addr, size);
err_pool:
        kfree(pages);
        return NULL;
}

and then call it at the beginning of the arm_iommu_alloc_attrs():

        if (gfp & GFP_ATOMIC)
                return __iommu_alloc_atomic(dev, size, handle);

You should also add support for the allocation from atomic_pool to __iommu_get_pages() function
to get dma_mmap() and dma_get_sgtable() working correctly.
 
> @@ -1279,7 +1298,8 @@ void arm_iommu_free_attrs(struct device *dev, size_t size, void
> *cpu_addr,
>  		return;
>  	}
> 
> -	if (!dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, attrs)) {
> +	if (!dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, attrs) ||
> +	    !__in_atomic_pool(cpu_addr, size)) {
>  		unmap_kernel_range((unsigned long)cpu_addr, size);
>  		vunmap(cpu_addr);
>  	}

Are you sure this one works?  __iommu_get_pages() won't find pages array, because atomic
allocations don't get their separate vm_struct area, so this check will be never reached. Maybe
a __iommu_free_atomic() function would also make it safer and easier to understand.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
