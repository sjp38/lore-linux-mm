Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78A8C6B0253
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 05:45:04 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id j26so421989iod.5
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 02:45:04 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c4si4260965oih.306.2017.09.18.02.45.02
        for <linux-mm@kvack.org>;
        Mon, 18 Sep 2017 02:45:03 -0700 (PDT)
Subject: Re: [V5, 2/3] mm: dmapool: Align to ARCH_DMA_MINALIGN in non-coherent
 DMA mode
References: <1505708548-4750-1-git-send-email-chenhc@lemote.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <601437ae-2860-c48a-aa7c-4da37aeb6256@arm.com>
Date: Mon, 18 Sep 2017 10:44:54 +0100
MIME-Version: 1.0
In-Reply-To: <1505708548-4750-1-git-send-email-chenhc@lemote.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huacai Chen <chenhc@lemote.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fuxin Zhang <zhangfx@lemote.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 18/09/17 05:22, Huacai Chen wrote:
> In non-coherent DMA mode, kernel uses cache flushing operations to
> maintain I/O coherency, so the dmapool objects should be aligned to
> ARCH_DMA_MINALIGN. Otherwise, it will cause data corruption, at least
> on MIPS:
> 
> 	Step 1, dma_map_single
> 	Step 2, cache_invalidate (no writeback)
> 	Step 3, dma_from_device
> 	Step 4, dma_unmap_single

This is a massive red warning flag for the whole series, because DMA
pools don't work like that. At best, this will do nothing, and at worst
it is papering over egregious bugs elsewhere. Streaming mappings of
coherent allocations means completely broken code.

> If a DMA buffer and a kernel structure share a same cache line, and if
> the kernel structure has dirty data, cache_invalidate (no writeback)
> will cause data lost.

DMA pools are backed by coherent allocations, and those should already
be at *page* granularity, so this doubly cannot happen for correct code.

More generally, the whole point of having the DMA APIs is that drivers
and subsystems should not have to be aware of details like hardware
coherency. Besides, cache line sharing that could pose a correctness
issue for non-hardware-coherent systems could still be a performance
issue in the presence of hardware coherency (due to unnecessary line
migration), so there's still an argument for not treating them differently.

Robin.

> Cc: stable@vger.kernel.org
> Signed-off-by: Huacai Chen <chenhc@lemote.com>
> ---
>  mm/dmapool.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/dmapool.c b/mm/dmapool.c
> index 4d90a64..6263905 100644
> --- a/mm/dmapool.c
> +++ b/mm/dmapool.c
> @@ -140,6 +140,9 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
>  	else if (align & (align - 1))
>  		return NULL;
>  
> +	if (!device_is_coherent(dev))
> +		align = max_t(size_t, align, dma_get_cache_alignment());
> +
>  	if (size == 0)
>  		return NULL;
>  	else if (size < 4)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
