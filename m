Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D3BAE6B0528
	for <linux-mm@kvack.org>; Thu, 17 May 2018 14:18:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b25-v6so3158660pfn.10
        for <linux-mm@kvack.org>; Thu, 17 May 2018 11:18:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i64-v6si5572826pli.274.2018.05.17.11.18.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 17 May 2018 11:18:16 -0700 (PDT)
Date: Thu, 17 May 2018 11:18:15 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/dmapool: localize page allocations
Message-ID: <20180517181815.GC26718@bombadil.infradead.org>
References: <1526578581-7658-1-git-send-email-okaya@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1526578581-7658-1-git-send-email-okaya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sinan Kaya <okaya@codeaurora.org>
Cc: linux-mm@kvack.org, timur@codeaurora.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org, open list <linux-kernel@vger.kernel.org>

On Thu, May 17, 2018 at 01:36:19PM -0400, Sinan Kaya wrote:
> Try to keep the pool closer to the device's NUMA node by changing kmalloc()
> to kmalloc_node() and devres_alloc() to devres_alloc_node().

Have you measured any performance gains by doing this?  The thing is that
these allocations are for the metadata about the page, and the page is
going to be used by CPUs in every node.  So it's not clear to me that
allocating it on the node nearest to the device is going to be any sort
of a win.

> @@ -504,7 +504,8 @@ struct dma_pool *dmam_pool_create(const char *name, struct device *dev,
>  {
>  	struct dma_pool **ptr, *pool;
>  
> -	ptr = devres_alloc(dmam_pool_release, sizeof(*ptr), GFP_KERNEL);
> +	ptr = devres_alloc_node(dmam_pool_release, sizeof(*ptr), GFP_KERNEL,
> +				dev_to_node(dev));
>  	if (!ptr)
>  		return NULL;

... are we really calling devres_alloc() for sizeof(void *)?  That's sad.
