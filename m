Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7FD6B0005
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 19:56:35 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d22-v6so2463247pfn.3
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 16:56:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j91-v6si2462301pld.474.2018.08.02.16.56.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 Aug 2018 16:56:33 -0700 (PDT)
Date: Thu, 2 Aug 2018 16:56:26 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 8/9] dmapool: reduce footprint in struct page
Message-ID: <20180802235626.GA5773@bombadil.infradead.org>
References: <0ccfd31b-0a3f-9ae8-85c8-e176cd5453a9@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0ccfd31b-0a3f-9ae8-85c8-e176cd5453a9@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, MPT-FusionLinux.pdl@broadcom.com

On Thu, Aug 02, 2018 at 04:01:12PM -0400, Tony Battersby wrote:
> This is my attempt to shrink 'dma_free_o' and 'dma_in_use' in 'struct
> page' (originally 'offset' and 'in_use' in 'struct dma_page') to 16-bit
> so that it is unnecessary to use the '_mapcount' field of 'struct
> page'.  However, it adds complexity and makes allocating and freeing up
> to 20% slower for little gain, so I am NOT recommending that it be
> merged at this time.  I am posting it just for reference in case someone
> finds it useful in the future.

I spy some interesting pieces in here that I'd love you to submit as
patches for merging.

> One of the nice things about this is that dma_pool_free() can do some
> additional sanity checks:
> *) Check that the offset of the passed-in address corresponds to a valid
> block offset.

Can't we do that already?  Subtract the base address of the page from
the passed-in vaddr and check it's a multiple of pool->size?

>  struct dma_pool {		/* the pool */
>  #define POOL_FULL_IDX   0
>  #define POOL_AVAIL_IDX  1
>  #define POOL_N_LISTS    2
>  	struct list_head page_list[POOL_N_LISTS];
>  	spinlock_t lock;
> -	size_t size;
>  	struct device *dev;
> -	size_t allocation;
> -	size_t boundary;
> +	unsigned int size;
> +	unsigned int allocation;
> +	unsigned int boundary_shift;
> +	unsigned int blks_per_boundary;
> +	unsigned int blks_per_alloc;

s/size_t/unsigned int/ is a good saving on 64-bit systems.  We recently
did something similar for slab/slub.

> @@ -141,6 +150,7 @@ static DEVICE_ATTR(pools, 0444, show_pool
>  struct dma_pool *dma_pool_create(const char *name, struct device *dev,
>  				 size_t size, size_t align, size_t boundary)
>  {

We should change the API here too.
