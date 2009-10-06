Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 31F206B004F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 17:58:17 -0400 (EDT)
Date: Tue, 6 Oct 2009 22:58:03 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] adjust gfp mask passed on nested vmalloc() invocation
In-Reply-To: <4AC9E38E0200007800017F57@vpn.id2.novell.com>
Message-ID: <Pine.LNX.4.64.0910062241500.21409@sister.anvils>
References: <4AC9E38E0200007800017F57@vpn.id2.novell.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jan Beulich <JBeulich@novell.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Oct 2009, Jan Beulich wrote:

> - fix a latent bug resulting from blindly or-ing in __GFP_ZERO, since
>   the combination of this and __GFP_HIGHMEM (possibly passed into the
>   function) is forbidden in interrupt context
> - avoid wasting more precious resources (DMA or DMA32 pools), when
>   being called through vmalloc_32{,_user}()
> - explicitly allow using high memory here even if the outer allocation
>   request doesn't allow it, unless is collides with __GFP_ZERO
> 
> Signed-off-by: Jan Beulich <jbeulich@novell.com>

I thought vmalloc.c was a BUG_ON(in_interrupt()) zone?
The locking is all spin_lock stuff, not spin_lock_irq stuff.
That's probably why your "bug" has remained "latent".

Using HIGHMEM for internal arrays looks reasonable to me; but if
__GFP_ZERO were a problem, wouldn't it be much cleaner to skip the
"unless it collides" and #ifdef CONFIG_HIGHMEM !in_interrupt() stuff,
just memset the array returned from __vmalloc_node()?

Hugh

> 
> ---
>  mm/vmalloc.c |   12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> --- linux-2.6.32-rc3/mm/vmalloc.c	2009-10-05 11:59:56.000000000 +0200
> +++ 2.6.32-rc3-vmalloc-nested-gfp/mm/vmalloc.c	2009-10-05 08:40:36.000000000 +0200
> @@ -1410,6 +1410,7 @@ static void *__vmalloc_area_node(struct 
>  {
>  	struct page **pages;
>  	unsigned int nr_pages, array_size, i;
> +	gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
>  
>  	nr_pages = (area->size - PAGE_SIZE) >> PAGE_SHIFT;
>  	array_size = (nr_pages * sizeof(struct page *));
> @@ -1417,13 +1418,16 @@ static void *__vmalloc_area_node(struct 
>  	area->nr_pages = nr_pages;
>  	/* Please note that the recursion is strictly bounded. */
>  	if (array_size > PAGE_SIZE) {
> -		pages = __vmalloc_node(array_size, gfp_mask | __GFP_ZERO,
> +#ifdef CONFIG_HIGHMEM
> +		/* See the comment in prep_zero_page(). */
> +		if (!in_interrupt())
> +			nested_gfp |= __GFP_HIGHMEM;
> +#endif
> +		pages = __vmalloc_node(array_size, nested_gfp,
>  				PAGE_KERNEL, node, caller);
>  		area->flags |= VM_VPAGES;
>  	} else {
> -		pages = kmalloc_node(array_size,
> -				(gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO,
> -				node);
> +		pages = kmalloc_node(array_size, nested_gfp, node);
>  	}
>  	area->pages = pages;
>  	area->caller = caller;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
