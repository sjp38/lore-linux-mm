Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E55426B004F
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 09:55:54 -0400 (EDT)
Date: Wed, 7 Oct 2009 14:55:40 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] adjust gfp mask passed on nested vmalloc() invocation
 (v2)
In-Reply-To: <4ACCA98202000078000187DF@vpn.id2.novell.com>
Message-ID: <Pine.LNX.4.64.0910071451090.4695@sister.anvils>
References: <4ACCA98202000078000187DF@vpn.id2.novell.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jan Beulich <JBeulich@novell.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Oct 2009, Jan Beulich wrote:

> - avoid wasting more precious resources (DMA or DMA32 pools), when
>   being called through vmalloc_32{,_user}()
> - explicitly allow using high memory here even if the outer allocation
>   request doesn't allow it, unless is collides with __GFP_ZERO
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                            that's no longer an issue in the patch
> 
> Signed-off-by: Jan Beulich <jbeulich@novell.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>

The patch looks good to me now, much nicer, thanks:
Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> 
> ---
>  mm/vmalloc.c |    7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> --- linux-2.6.32-rc3/mm/vmalloc.c	2009-10-05 11:59:56.000000000 +0200
> +++ 2.6.32-rc3-vmalloc-nested-gfp/mm/vmalloc.c	2009-10-07 14:39:38.000000000 +0200
> @@ -1410,6 +1410,7 @@ static void *__vmalloc_area_node(struct 
>  {
>  	struct page **pages;
>  	unsigned int nr_pages, array_size, i;
> +	gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
>  
>  	nr_pages = (area->size - PAGE_SIZE) >> PAGE_SHIFT;
>  	array_size = (nr_pages * sizeof(struct page *));
> @@ -1417,13 +1418,11 @@ static void *__vmalloc_area_node(struct 
>  	area->nr_pages = nr_pages;
>  	/* Please note that the recursion is strictly bounded. */
>  	if (array_size > PAGE_SIZE) {
> -		pages = __vmalloc_node(array_size, gfp_mask | __GFP_ZERO,
> +		pages = __vmalloc_node(array_size, nested_gfp | __GFP_HIGHMEM,
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
