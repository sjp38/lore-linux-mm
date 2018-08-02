Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4576B0271
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 16:08:11 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id p5-v6so2105288pfh.11
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 13:08:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v21-v6si2611966pgn.371.2018.08.02.13.08.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 Aug 2018 13:08:10 -0700 (PDT)
Date: Thu, 2 Aug 2018 13:08:04 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 4/9] dmapool: improve scalability of dma_pool_alloc
Message-ID: <20180802200804.GA14318@bombadil.infradead.org>
References: <1dbe6204-17fc-efd9-2381-48186cae2b94@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1dbe6204-17fc-efd9-2381-48186cae2b94@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On Thu, Aug 02, 2018 at 03:58:40PM -0400, Tony Battersby wrote:
> @@ -339,11 +360,16 @@ void *dma_pool_alloc(struct dma_pool *po
>  
>  	spin_lock_irqsave(&pool->lock, flags);
>  
> -	list_add(&page->page_list, &pool->page_list);
> +	list_add(&page->dma_list, &pool->page_list[POOL_AVAIL_IDX]);
>   ready:
>  	page->in_use++;
>  	offset = page->offset;
>  	page->offset = *(int *)(page->vaddr + offset);
> +	if (page->offset >= pool->allocation) {
> +		/* Move page from the "available" list to the "full" list. */
> +		list_del(&page->dma_list);
> +		list_add(&page->dma_list, &pool->page_list[POOL_FULL_IDX]);

I think this should be:

		list_move_tail(&page->dma_list,
				&pool->page_list[POOL_FULL_IDX]);

> @@ -444,6 +476,11 @@ void dma_pool_free(struct dma_pool *pool
>  #endif
>  
>  	page->in_use--;
> +	if (page->offset >= pool->allocation) {
> +		/* Move page from the "full" list to the "available" list. */
> +		list_del(&page->dma_list);
> +		list_add(&page->dma_list, &pool->page_list[POOL_AVAIL_IDX]);

This one probably wants to be
		list_move(&page->dma_list, &pool->page_list[POOL_AVAIL_IDX]);

so that it's first-in-line to be allocated from for cache warmth purposes.
