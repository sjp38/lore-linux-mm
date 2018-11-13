Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF2EE6B027A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:30:41 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id e89so1593891pfb.17
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 22:30:41 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1-v6si20941356pln.299.2018.11.12.22.30.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Nov 2018 22:30:40 -0800 (PST)
Date: Mon, 12 Nov 2018 22:30:37 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 8/9] dmapool: improve accuracy of debug statistics
Message-ID: <20181113063037.GS21824@bombadil.infradead.org>
References: <bb0ee76c-78ac-b75b-b32d-8c94d881f7d6@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bb0ee76c-78ac-b75b-b32d-8c94d881f7d6@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org

On Mon, Nov 12, 2018 at 10:45:58AM -0500, Tony Battersby wrote:
> +++ linux/mm/dmapool.c	2018-08-06 17:52:53.000000000 -0400
> @@ -61,6 +61,7 @@ struct dma_pool {		/* the pool */
>  	struct device *dev;
>  	unsigned int allocation;
>  	unsigned int boundary;
> +	unsigned int blks_per_alloc;
>  	char name[32];
>  	struct list_head pools;
>  };

This one I'm not totally happy with.  You're storing this value when
it could be easily calculated each time through the show_pools() code.
I appreciate this is a topic where reasonable people might have different
opinions about which solution is preferable.

> @@ -182,6 +182,9 @@ struct dma_pool *dma_pool_create(const c
>  	retval->size = size;
>  	retval->boundary = boundary;
>  	retval->allocation = allocation;
> +	retval->blks_per_alloc =
> +		(allocation / boundary) * (boundary / size) +
> +		(allocation % boundary) / size;
>  
>  	INIT_LIST_HEAD(&retval->pools);
>  
> 
