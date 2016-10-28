Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDF636B027A
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 10:59:33 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id d33so51806772uad.2
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 07:59:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o17si6292867uab.199.2016.10.28.07.59.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 07:59:02 -0700 (PDT)
Message-ID: <1477666740.31844.9.camel@redhat.com>
Subject: Re: [net-next PATCH RFC 07/26] arch/c6x: Add option to skip sync on
 DMA map and unmap
From: Mark Salter <msalter@redhat.com>
Date: Fri, 28 Oct 2016 10:59:00 -0400
In-Reply-To: <20161024120503.16276.44357.stgit@ahduyck-blue-test.jf.intel.com>
References: 
	<20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
	 <20161024120503.16276.44357.stgit@ahduyck-blue-test.jf.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: brouer@redhat.com, davem@davemloft.net, linux-c6x-dev@linux-c6x.org, Aurelien Jacquiot <a-jacquiot@ti.com>

On Mon, 2016-10-24 at 08:05 -0400, Alexander Duyck wrote:
> This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
> avoid invoking cache line invalidation if the driver will just handle it
> later via a sync_for_cpu or sync_for_device call.
> 
> Cc: Mark Salter <msalter@redhat.com>
> Cc: Aurelien Jacquiot <a-jacquiot@ti.com>
> Cc: linux-c6x-dev@linux-c6x.org
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---

Acked-by: Mark Salter <msalter@redhat.com>

> A arch/c6x/kernel/dma.c |A A A 16 +++++++++++-----
> A 1 file changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/c6x/kernel/dma.c b/arch/c6x/kernel/dma.c
> index db4a6a3..d28df74 100644
> --- a/arch/c6x/kernel/dma.c
> +++ b/arch/c6x/kernel/dma.c
> @@ -42,14 +42,17 @@ static dma_addr_t c6x_dma_map_page(struct device *dev, struct page *page,
> A {
> A 	dma_addr_t handle = virt_to_phys(page_address(page) + offset);
> A 
> -	c6x_dma_sync(handle, size, dir);
> +	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
> +		c6x_dma_sync(handle, size, dir);
> +
> A 	return handle;
> A }
> A 
> A static void c6x_dma_unmap_page(struct device *dev, dma_addr_t handle,
> A 		size_t size, enum dma_data_direction dir, unsigned long attrs)
> A {
> -	c6x_dma_sync(handle, size, dir);
> +	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
> +		c6x_dma_sync(handle, size, dir);
> A }
> A 
> A static int c6x_dma_map_sg(struct device *dev, struct scatterlist *sglist,
> @@ -60,7 +63,8 @@ static int c6x_dma_map_sg(struct device *dev, struct scatterlist *sglist,
> A 
> A 	for_each_sg(sglist, sg, nents, i) {
> A 		sg->dma_address = sg_phys(sg);
> -		c6x_dma_sync(sg->dma_address, sg->length, dir);
> +		if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
> +			c6x_dma_sync(sg->dma_address, sg->length, dir);
> A 	}
> A 
> A 	return nents;
> @@ -72,8 +76,10 @@ static void c6x_dma_unmap_sg(struct device *dev, struct scatterlist *sglist,
> A 	struct scatterlist *sg;
> A 	int i;
> A 
> -	for_each_sg(sglist, sg, nents, i)
> -		c6x_dma_sync(sg_dma_address(sg), sg->length, dir);
> +	for_each_sg(sglist, sg, nents, i) {
> +		if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
> +			c6x_dma_sync(sg_dma_address(sg), sg->length, dir);
> +	}
> A 
> A }
> A 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
