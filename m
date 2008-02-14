Date: Thu, 14 Feb 2008 13:55:48 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch 1/5] slub: Determine gfpflags once and not every time a slab is allocated
Message-ID: <20080214135548.GD17641@csn.ul.ie>
References: <20080214040245.915842795@sgi.com> <20080214040313.318658830@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080214040313.318658830@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (13/02/08 20:02), Christoph Lameter didst pronounce:
> Currently we determine the gfp flags to pass to the page allocator
> each time a slab is being allocated.
> 
> Determine the bits to be set at the time the slab is created. Store
> in a new allocflags field and add the flags in allocate_slab().
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  include/linux/slub_def.h |    1 +
>  mm/slub.c                |   19 +++++++++++--------
>  2 files changed, 12 insertions(+), 8 deletions(-)
> 
> Index: linux-2.6/include/linux/slub_def.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slub_def.h	2008-02-13 17:13:49.378744786 -0800
> +++ linux-2.6/include/linux/slub_def.h	2008-02-13 18:50:42.235907853 -0800
> @@ -71,6 +71,7 @@ struct kmem_cache {
>  
>  	/* Allocation and freeing of slabs */
>  	int objects;		/* Number of objects in slab */
> +	gfp_t allocflags;	/* gfp flags to use on each alloc */
>  	int refcount;		/* Refcount for slab cache destroy */
>  	void (*ctor)(struct kmem_cache *, void *);
>  	int inuse;		/* Offset to metadata */
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2008-02-13 17:13:49.386744784 -0800
> +++ linux-2.6/mm/slub.c	2008-02-13 18:53:49.612240235 -0800
> @@ -1078,14 +1078,7 @@ static struct page *allocate_slab(struct
>  	struct page *page;
>  	int pages = 1 << s->order;
>  
> -	if (s->order)
> -		flags |= __GFP_COMP;
> -
> -	if (s->flags & SLAB_CACHE_DMA)
> -		flags |= SLUB_DMA;
> -
> -	if (s->flags & SLAB_RECLAIM_ACCOUNT)
> -		flags |= __GFP_RECLAIMABLE;
> +	flags |= s->allocflags;
>  
>  	if (node == -1)
>  		page = alloc_pages(flags, s->order);
> @@ -2333,6 +2326,16 @@ static int calculate_sizes(struct kmem_c
>  	if (s->order < 0)
>  		return 0;
>  
> +	s->allocflags = 0;
> +	if (s->order)
> +		s->allocflags |= __GFP_COMP;
> +
> +	if (s->flags & SLAB_CACHE_DMA)
> +		s->allocflags |= SLUB_DMA;
> +
> +	if (s->flags & SLAB_RECLAIM_ACCOUNT)
> +		s->allocflags |= __GFP_RECLAIMABLE;
> +
>  	/*
>  	 * Determine the number of objects per slab
>  	 */
> 

Seems straight-forward.

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
