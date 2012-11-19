Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id E08A76B004D
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 19:18:56 -0500 (EST)
Date: Sun, 18 Nov 2012 19:18:46 -0500
From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH] mm: dmapool: use provided gfp flags for all
 dma_alloc_coherent() calls
Message-ID: <20121119001846.GB22106@titan.lakedaemon.net>
References: <1352356737-14413-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1352356737-14413-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, Kyungmin Park <kyungmin.park@samsung.com>, Soren Moch <smoch@web.de>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

Marek,

I've added the maintainers for mm/*.  Hopefully they can let us know if
this is good for v3.8...

thx,

Jason.

On Thu, Nov 08, 2012 at 07:38:57AM +0100, Marek Szyprowski wrote:
> dmapool always calls dma_alloc_coherent() with GFP_ATOMIC flag, regardless
> the flags provided by the caller. This causes excessive pruning of
> emergency memory pools without any good reason. This patch changes the code
> to correctly use gfp flags provided by the dmapool caller. This should
> solve the dmapool usage on ARM architecture, where GFP_ATOMIC DMA
> allocations can be served only from the special, very limited memory pool.
> 
> Reported-by: Soren Moch <smoch@web.de>
> Reported-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> ---
>  mm/dmapool.c |   27 +++++++--------------------
>  1 file changed, 7 insertions(+), 20 deletions(-)
> 
> diff --git a/mm/dmapool.c b/mm/dmapool.c
> index c5ab33b..86de9b2 100644
> --- a/mm/dmapool.c
> +++ b/mm/dmapool.c
> @@ -62,8 +62,6 @@ struct dma_page {		/* cacheable header for 'allocation' bytes */
>  	unsigned int offset;
>  };
>  
> -#define	POOL_TIMEOUT_JIFFIES	((100 /* msec */ * HZ) / 1000)
> -
>  static DEFINE_MUTEX(pools_lock);
>  
>  static ssize_t
> @@ -227,7 +225,6 @@ static struct dma_page *pool_alloc_page(struct dma_pool *pool, gfp_t mem_flags)
>  		memset(page->vaddr, POOL_POISON_FREED, pool->allocation);
>  #endif
>  		pool_initialise_page(pool, page);
> -		list_add(&page->page_list, &pool->page_list);
>  		page->in_use = 0;
>  		page->offset = 0;
>  	} else {
> @@ -315,30 +312,21 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
>  	might_sleep_if(mem_flags & __GFP_WAIT);
>  
>  	spin_lock_irqsave(&pool->lock, flags);
> - restart:
>  	list_for_each_entry(page, &pool->page_list, page_list) {
>  		if (page->offset < pool->allocation)
>  			goto ready;
>  	}
> -	page = pool_alloc_page(pool, GFP_ATOMIC);
> -	if (!page) {
> -		if (mem_flags & __GFP_WAIT) {
> -			DECLARE_WAITQUEUE(wait, current);
>  
> -			__set_current_state(TASK_UNINTERRUPTIBLE);
> -			__add_wait_queue(&pool->waitq, &wait);
> -			spin_unlock_irqrestore(&pool->lock, flags);
> +	/* pool_alloc_page() might sleep, so temporarily drop &pool->lock */
> +	spin_unlock_irqrestore(&pool->lock, flags);
>  
> -			schedule_timeout(POOL_TIMEOUT_JIFFIES);
> +	page = pool_alloc_page(pool, mem_flags);
> +	if (!page)
> +		return NULL;
>  
> -			spin_lock_irqsave(&pool->lock, flags);
> -			__remove_wait_queue(&pool->waitq, &wait);
> -			goto restart;
> -		}
> -		retval = NULL;
> -		goto done;
> -	}
> +	spin_lock_irqsave(&pool->lock, flags);
>  
> +	list_add(&page->page_list, &pool->page_list);
>   ready:
>  	page->in_use++;
>  	offset = page->offset;
> @@ -348,7 +336,6 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
>  #ifdef	DMAPOOL_DEBUG
>  	memset(retval, POOL_POISON_ALLOCATED, pool->size);
>  #endif
> - done:
>  	spin_unlock_irqrestore(&pool->lock, flags);
>  	return retval;
>  }
> -- 
> 1.7.9.5
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
