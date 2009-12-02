Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CBBDA6007E3
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 15:01:21 -0500 (EST)
Date: Wed, 2 Dec 2009 14:00:56 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC,PATCH 2/2] dmapool: Honor GFP_* flags.
In-Reply-To: <200912021523.39696.roger.oksanen@cs.helsinki.fi>
Message-ID: <alpine.DEB.2.00.0912021358150.2547@router.home>
References: <200912021518.35877.roger.oksanen@cs.helsinki.fi> <200912021523.39696.roger.oksanen@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Cc: linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Dec 2009, Roger Oksanen wrote:

>  1 files changed, 3 insertions(+), 1 deletions(-)
>
> diff --git a/mm/dmapool.c b/mm/dmapool.c
> index 2fdd7a1..e270f7f 100644
> --- a/mm/dmapool.c
> +++ b/mm/dmapool.c
> @@ -312,6 +312,8 @@
>  	void *retval;
>  	int tries = 0;
>  	const gfp_t can_wait = mem_flags & __GFP_WAIT;
> +	/* dma_pool_alloc uses its own wait logic */
> +	mem_flags &= ~__GFP_WAIT;

Why mask the wait flag? If you can call the page allocator with __GFP_WAIT
then you dont have to loop.

> -	page = pool_alloc_page(pool, GFP_ATOMIC | (can_wait && tries % 10
> +	page = pool_alloc_page(pool, mem_flags | (can_wait && tries % 10
>  						  ? __GFP_NOWARN : 0));

You are now uselessly calling the page allocator with __GFP_WAIT cleared
although the context allows you to wait.

Just pass through the mem_flags? Rename them gfp_flags for consistencies
sake?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
