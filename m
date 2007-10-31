From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 04/33] mm: allow mempool to fall back to memalloc reserves
Date: Wed, 31 Oct 2007 14:40:54 +1100
References: <20071030160401.296770000@chello.nl> <20071030160911.031845000@chello.nl>
In-Reply-To: <20071030160911.031845000@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710311440.54695.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> Allow the mempool to use the memalloc reserves when all else fails and
> the allocation context would otherwise allow it.

I don't see what this is for. The whole point of when I fixed this
to *not* use the memalloc reserves is because processes that were
otherwise allowed to use those reserves, were. They should not.



> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  mm/mempool.c |   12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
>
> Index: linux-2.6/mm/mempool.c
> ===================================================================
> --- linux-2.6.orig/mm/mempool.c
> +++ linux-2.6/mm/mempool.c
> @@ -14,6 +14,7 @@
>  #include <linux/mempool.h>
>  #include <linux/blkdev.h>
>  #include <linux/writeback.h>
> +#include "internal.h"
>
>  static void add_element(mempool_t *pool, void *element)
>  {
> @@ -204,7 +205,7 @@ void * mempool_alloc(mempool_t *pool, gf
>  	void *element;
>  	unsigned long flags;
>  	wait_queue_t wait;
> -	gfp_t gfp_temp;
> +	gfp_t gfp_temp, gfp_orig = gfp_mask;
>
>  	might_sleep_if(gfp_mask & __GFP_WAIT);
>
> @@ -228,6 +229,15 @@ repeat_alloc:
>  	}
>  	spin_unlock_irqrestore(&pool->lock, flags);
>
> +	/* if we really had right to the emergency reserves try those */
> +	if (gfp_to_alloc_flags(gfp_orig) & ALLOC_NO_WATERMARKS) {
> +		if (gfp_temp & __GFP_NOMEMALLOC) {
> +			gfp_temp &= ~(__GFP_NOMEMALLOC|__GFP_NOWARN);
> +			goto repeat_alloc;
> +		} else
> +			gfp_temp |= __GFP_NOMEMALLOC|__GFP_NOWARN;
> +	}
> +
>  	/* We must not sleep in the GFP_ATOMIC case */
>  	if (!(gfp_mask & __GFP_WAIT))
>  		return NULL;
>
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
