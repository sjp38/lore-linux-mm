Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id C2C646B006C
	for <linux-mm@kvack.org>; Mon, 31 Dec 2012 20:16:02 -0500 (EST)
Received: by mail-yh0-f50.google.com with SMTP id q3so164843yhf.37
        for <linux-mm@kvack.org>; Mon, 31 Dec 2012 17:16:01 -0800 (PST)
Message-ID: <50E238CF.1050708@gmail.com>
Date: Mon, 31 Dec 2012 17:15:59 -0800
From: Subash Patel <subashrp@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC] ARM: DMA-Mapping: add a new attribute to clear buffer
References: <1356656433-2278-1-git-send-email-daeinki@gmail.com>
In-Reply-To: <1356656433-2278-1-git-send-email-daeinki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: daeinki@gmail.com
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, Inki Dae <inki.dae@samsung.com>



On Thursday 27 December 2012 05:00 PM, daeinki@gmail.com wrote:
> From: Inki Dae <inki.dae@samsung.com>
>
> This patch adds a new attribute, DMA_ATTR_SKIP_BUFFER_CLEAR
> to skip buffer clearing. The buffer clearing also flushes CPU cache
> so this operation has performance deterioration a little bit.
>
> With this patch, allocated buffer region is cleared as default.
> So if you want to skip the buffer clearing, just set this attribute.
>
> But this flag should be used carefully because this use might get
> access to some vulnerable content such as security data. So with this
> patch, we make sure that all pages will be somehow cleared before
> exposing to userspace.
>
> For example, let's say that the security data had been stored
> in some memory and freed without clearing it.
> And then malicious process allocated the region though some buffer
> allocator such as gem and ion without clearing it, and requested blit
> operation with cleared another buffer though gpu or other drivers.
> At this time, the malicious process could access the security data.

Isnt it always good to use such security related buffers through TZ 
rather than trying to guard them in the non-secure zone?

>
> Signed-off-by: Inki Dae <inki.dae@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>   arch/arm/mm/dma-mapping.c |    6 ++++--
>   include/linux/dma-attrs.h |    1 +
>   2 files changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 6b2fb87..fbe9dff 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -1058,7 +1058,8 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,
>   		if (!page)
>   			goto error;
>
> -		__dma_clear_buffer(page, size);
> +		if (!dma_get_attr(DMA_ATTR_SKIP_BUFFER_CLEAR, attrs))
> +			__dma_clear_buffer(page, size);
>
>   		for (i = 0; i < count; i++)
>   			pages[i] = page + i;
> @@ -1082,7 +1083,8 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,
>   				pages[i + j] = pages[i] + j;
>   		}
>
> -		__dma_clear_buffer(pages[i], PAGE_SIZE << order);
> +		if (!dma_get_attr(DMA_ATTR_SKIP_BUFFER_CLEAR, attrs))
> +			__dma_clear_buffer(pages[i], PAGE_SIZE << order);
>   		i += 1 << order;
>   		count -= 1 << order;
>   	}
> diff --git a/include/linux/dma-attrs.h b/include/linux/dma-attrs.h
> index c8e1831..2592c05 100644
> --- a/include/linux/dma-attrs.h
> +++ b/include/linux/dma-attrs.h
> @@ -18,6 +18,7 @@ enum dma_attr {
>   	DMA_ATTR_NO_KERNEL_MAPPING,
>   	DMA_ATTR_SKIP_CPU_SYNC,
>   	DMA_ATTR_FORCE_CONTIGUOUS,
> +	DMA_ATTR_SKIP_BUFFER_CLEAR,
>   	DMA_ATTR_MAX,

How is this new macro different from SKIP_CPU_SYNC?

>   };
>
>

Regards,
Subash

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
