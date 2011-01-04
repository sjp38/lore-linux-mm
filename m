Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4B36B0087
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 15:37:40 -0500 (EST)
Date: Tue, 4 Jan 2011 12:37:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Take lock only once in dma_pool_free()
Message-Id: <20110104123736.5ff6643e.akpm@linux-foundation.org>
In-Reply-To: <201012201803.06873.eike-kernel@sf-tec.de>
References: <201012201803.06873.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rolf Eike Beer <eike-kernel@sf-tec.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 Dec 2010 18:03:06 +0100
Rolf Eike Beer <eike-kernel@sf-tec.de> wrote:

> >From 0db01c2ea9476609c399de3e9fdf7861df07d2f1 Mon Sep 17 00:00:00 2001
> From: Rolf Eike Beer <eike-kernel@sf-tec.de>
> Date: Mon, 20 Dec 2010 17:29:33 +0100
> Subject: [PATCH] Speed up dma_pool_free()
> 
> dma_pool_free() scans for the page to free in the pool list holding the pool
> lock. Then it releases the lock basically to acquire it immediately again.
> Modify the code to only take the lock once.
> 
> This will do some additional loops and computations with the lock held in if 
> memory debugging is activated. If it is not activated the only new operations 
> with this lock is one if and one substraction.
> 

Fair enough, I guess.

> 
> diff --git a/mm/dmapool.c b/mm/dmapool.c
> index 4df2de7..a2f6295 100644
> --- a/mm/dmapool.c
> +++ b/mm/dmapool.c
> @@ -355,20 +355,15 @@ EXPORT_SYMBOL(dma_pool_alloc);
>  
>  static struct dma_page *pool_find_page(struct dma_pool *pool, dma_addr_t dma)
>  {
> -	unsigned long flags;
>  	struct dma_page *page;
>  
> -	spin_lock_irqsave(&pool->lock, flags);
>  	list_for_each_entry(page, &pool->page_list, page_list) {
>  		if (dma < page->dma)
>  			continue;
>  		if (dma < (page->dma + pool->allocation))
> -			goto done;
> +			return page;
>  	}
> -	page = NULL;
> - done:
> -	spin_unlock_irqrestore(&pool->lock, flags);
> -	return page;
> +	return NULL;
>  }
>  
>  /**
> @@ -386,8 +381,10 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr, 
> dma_addr_t dma)

You have some wordwrapping there.

>  	unsigned long flags;
>  	unsigned int offset;
>  
> +	spin_lock_irqsave(&pool->lock, flags);
>  	page = pool_find_page(pool, dma);
>  	if (!page) {
> +		spin_unlock_irqrestore(&pool->lock, flags);
>  		if (pool->dev)
>  			dev_err(pool->dev,
>  				"dma_pool_free %s, %p/%lx (bad dma)\n",
> @@ -401,6 +398,7 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr, 
> dma_addr_t dma)
>  	offset = vaddr - page->vaddr;
>  #ifdef	DMAPOOL_DEBUG
>  	if ((dma - page->dma) != offset) {
> +		spin_unlock_irqrestore(&pool->lock, flags);
>  		if (pool->dev)
>  			dev_err(pool->dev,
>  				"dma_pool_free %s, %p (bad vaddr)/%Lx\n",
> @@ -418,6 +416,7 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr, 
> dma_addr_t dma)
>  				chain = *(int *)(page->vaddr + chain);
>  				continue;
>  			}
> +			spin_unlock_irqrestore(&pool->lock, flags);
>  			if (pool->dev)
>  				dev_err(pool->dev, "dma_pool_free %s, dma %Lx "
>  					"already free\n", pool->name,
> @@ -432,7 +431,6 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr, 
> dma_addr_t dma)
>  	memset(vaddr, POOL_POISON_FREED, pool->size);
>  #endif
>  
> -	spin_lock_irqsave(&pool->lock, flags);
>  	page->in_use--;
>  	*(int *)vaddr = page->offset;
>  	page->offset = offset;

It's a bit scary that the code is playing with the dma_page outside the
lock, but I guess the refcounting takes care of that.  As does the
apparently-intentional leakiness of leaving a cache of pages around.

The use of TASK_INTERRUPTIBLE in dma_pool_alloc() looks like a bug -
the code will busywait if signal_pending().

--- a/mm/dmapool.c~a
+++ a/mm/dmapool.c
@@ -324,7 +324,7 @@ void *dma_pool_alloc(struct dma_pool *po
 		if (mem_flags & __GFP_WAIT) {
 			DECLARE_WAITQUEUE(wait, current);
 
-			__set_current_state(TASK_INTERRUPTIBLE);
+			__set_current_state(TASK_UNINTERRUPTIBLE);
 			__add_wait_queue(&pool->waitq, &wait);
 			spin_unlock_irqrestore(&pool->lock, flags);
 
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
