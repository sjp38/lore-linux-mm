Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 973786B026B
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:27:50 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id f134so20512169lfg.6
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:27:50 -0700 (PDT)
Received: from cassarossa.samfundet.no (cassarossa.samfundet.no. [2001:67c:29f4::29])
        by mx.google.com with ESMTPS id x85si8210769lfa.419.2016.10.24.11.27.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:27:49 -0700 (PDT)
Date: Mon, 24 Oct 2016 20:27:40 +0200
From: Hans-Christian Noren Egtvedt <egtvedt@samfundet.no>
Subject: Re: [net-next PATCH RFC 05/26] arch/avr32: Add option to skip sync
 on DMA map
Message-ID: <20161024182739.GA19445@samfundet.no>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
 <20161024120452.16276.9594.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161024120452.16276.9594.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, Haavard Skinnemoen <hskinnemoen@gmail.com>, davem@davemloft.net

Around Mon 24 Oct 2016 08:04:53 -0400 or thereabout, Alexander Duyck wrote:
> The use of DMA_ATTR_SKIP_CPU_SYNC was not consistent across all of the DMA
> APIs in the arch/arm folder.  This change is meant to correct that so that
> we get consistent behavior.

Looks good (-:

> Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
> Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Acked-by: Hans-Christian Noren Egtvedt <egtvedt@samfundet.no>

> ---
>  arch/avr32/mm/dma-coherent.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/avr32/mm/dma-coherent.c b/arch/avr32/mm/dma-coherent.c
> index 58610d0..54534e5 100644
> --- a/arch/avr32/mm/dma-coherent.c
> +++ b/arch/avr32/mm/dma-coherent.c
> @@ -146,7 +146,8 @@ static dma_addr_t avr32_dma_map_page(struct device *dev, struct page *page,
>  {
>  	void *cpu_addr = page_address(page) + offset;
>  
> -	dma_cache_sync(dev, cpu_addr, size, direction);
> +	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
> +		dma_cache_sync(dev, cpu_addr, size, direction);
>  	return virt_to_bus(cpu_addr);
>  }
>  
> @@ -162,6 +163,10 @@ static int avr32_dma_map_sg(struct device *dev, struct scatterlist *sglist,
>  
>  		sg->dma_address = page_to_bus(sg_page(sg)) + sg->offset;
>  		virt = sg_virt(sg);
> +
> +		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
> +			continue;
> +
>  		dma_cache_sync(dev, virt, sg->length, direction);
>  	}
>  
-- 
mvh
Hans-Christian Noren Egtvedt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
