Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id D4D676B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 02:17:29 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so2207425pbc.1
        for <linux-mm@kvack.org>; Wed, 21 May 2014 23:17:29 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id qf10si9185530pbb.86.2014.05.21.23.17.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 21 May 2014 23:17:29 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N5Y005WEPGLPZ70@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 May 2014 07:17:09 +0100 (BST)
Message-id: <537D9671.6030505@samsung.com>
Date: Thu, 22 May 2014 08:17:21 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] arm: dma-mapping: add checking cma area initialized
References: <1400733503-1302-1-git-send-email-gioh.kim@lge.com>
In-reply-to: <1400733503-1302-1-git-send-email-gioh.kim@lge.com>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, mina86@mina86.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, heesub.shin@samsung.com, mgorman@suse.de, hannes@cmpxchg.org
Cc: gunho.lee@lge.com, chanho.min@lge.com, gurugio@gmail.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello,

On 2014-05-22 06:38, Gioh Kim wrote:
> If CMA is turned on and CMA size is set to zero, kernel should
> behave as if CMA was not enabled at compile time.
> Every dma allocation should check existence of cma area
> before requesting memory.
>
> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>

Thanks for this patch! The initial version was really ugly, but
this one really does what should be there from the begging.

I've applied this patch with redundant empty line add removed.

> ---
>   arch/arm/mm/dma-mapping.c |    7 ++++---
>   1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 18e98df..9173a13 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -390,12 +390,13 @@ static int __init atomic_pool_init(void)
>   	if (!pages)
>   		goto no_pages;
>   
> -	if (IS_ENABLED(CONFIG_DMA_CMA))
> +	if (dev_get_cma_area(NULL))
>   		ptr = __alloc_from_contiguous(NULL, pool->size, prot, &page,
>   					      atomic_pool_init);
>   	else
>   		ptr = __alloc_remap_buffer(NULL, pool->size, gfp, prot, &page,
>   					   atomic_pool_init);
> +
>   	if (ptr) {
>   		int i;
>   
> @@ -701,7 +702,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
>   		addr = __alloc_simple_buffer(dev, size, gfp, &page);
>   	else if (!(gfp & __GFP_WAIT))
>   		addr = __alloc_from_pool(size, &page);
> -	else if (!IS_ENABLED(CONFIG_DMA_CMA))
> +	else if (!dev_get_cma_area(dev))
>   		addr = __alloc_remap_buffer(dev, size, gfp, prot, &page, caller);
>   	else
>   		addr = __alloc_from_contiguous(dev, size, prot, &page, caller);
> @@ -790,7 +791,7 @@ static void __arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
>   		__dma_free_buffer(page, size);
>   	} else if (__free_from_pool(cpu_addr, size)) {
>   		return;
> -	} else if (!IS_ENABLED(CONFIG_DMA_CMA)) {
> +	} else if (!dev_get_cma_area(dev)) {
>   		__dma_free_remap(cpu_addr, size);
>   		__dma_free_buffer(page, size);
>   	} else {

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
