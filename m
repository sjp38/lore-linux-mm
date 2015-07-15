Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 331CE6B02DC
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:29:09 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so46643748igb.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 14:29:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s77si4697298ioi.60.2015.07.15.14.29.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 14:29:08 -0700 (PDT)
Date: Wed, 15 Jul 2015 14:29:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] mm: Add support for __GFP_ZERO flag to
 dma_pool_alloc()
Message-Id: <20150715142907.ccfd473ea0e039642d46893d@linux-foundation.org>
In-Reply-To: <1436994883-16563-2-git-send-email-sean.stalley@intel.com>
References: <1436994883-16563-1-git-send-email-sean.stalley@intel.com>
	<1436994883-16563-2-git-send-email-sean.stalley@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Sean O. Stalley" <sean.stalley@intel.com>
Cc: corbet@lwn.net, vinod.koul@intel.com, bhelgaas@google.com, Julia.Lawall@lip6.fr, Gilles.Muller@lip6.fr, nicolas.palix@imag.fr, mmarek@suse.cz, bigeasy@linutronix.de, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, dmaengine@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, cocci@systeme.lip6.fr

On Wed, 15 Jul 2015 14:14:40 -0700 "Sean O. Stalley" <sean.stalley@intel.com> wrote:

> Currently the __GFP_ZERO flag is ignored by dma_pool_alloc().
> Make dma_pool_alloc() zero the memory if this flag is set.
> 
> ...
>
> --- a/mm/dmapool.c
> +++ b/mm/dmapool.c
> @@ -334,7 +334,7 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
>  	/* pool_alloc_page() might sleep, so temporarily drop &pool->lock */
>  	spin_unlock_irqrestore(&pool->lock, flags);
>  
> -	page = pool_alloc_page(pool, mem_flags);
> +	page = pool_alloc_page(pool, mem_flags & (~__GFP_ZERO));
>  	if (!page)
>  		return NULL;
>  
> @@ -375,6 +375,10 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
>  	memset(retval, POOL_POISON_ALLOCATED, pool->size);
>  #endif
>  	spin_unlock_irqrestore(&pool->lock, flags);
> +
> +	if (mem_flags & __GFP_ZERO)
> +		memset(retval, 0, pool->size);
> +
>  	return retval;
>  }
>  EXPORT_SYMBOL(dma_pool_alloc);

hm, this code is all a bit confused.

We'd really prefer that the __GFP_ZERO be passed all the way to the
bottom level, so that places which are responsible for zeroing memory
(eg, the page allocator) can do their designated function.  One reason
for this is that if someone comes up with a whizzy way of zeroing
memory on their architecture (eg, non-temporal store) then that will be
implemented in the core page allocator and the dma code will miss out.

Also, and just from a brief look around,
drivers/base/dma-coherent.c:dma_alloc_from_coherent() is already
zeroing the memory so under some circumstances I think we'll zero the
memory twice?  We could fix that by passing the gfp_t to
dma_alloc_from_coherent() and then changing dma_alloc_from_coherent()
to *not* zero the memory if __GFP_ZERO, but wouldn't that be peculiar?

Also, passing __GFP_ZERO will now cause pool_alloc_page()'s
memset(POOL_POISON_FREED) to be wiped out.  I guess that's harmless,
but a bit inefficient?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
