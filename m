Date: Thu, 14 Feb 2008 14:14:42 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch 4/5] slub: Use __GFP_MOVABLE for slabs of HPAGE_SIZE
Message-ID: <20080214141442.GF17641@csn.ul.ie>
References: <20080214040245.915842795@sgi.com> <20080214040314.118141086@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080214040314.118141086@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (13/02/08 20:02), Christoph Lameter didst pronounce:
> This is the same trick as done by the hugetlb support in the kernel.
> If we allocate a huge page use __GFP_MOVABLE because an allocation
> of a HUGE_PAGE size is the large allocation unit that cannot cause
> fragmentation.
> 
> This will make a system that was booted with
> 
> 	slub_min_order = 9
> 
> not have any reclaimable slab allocations anymore. All slab allocations
> will be of type MOVABLE (although they are not movable like huge pages
> are also not movable). This means that we only have MOVABLE and UNMOVABLE
> sections of memory which reduces the types of sections and therefore the
> danger of fragmenting memory.

hmmm.

The only reason to have an allocation like this set as MOVABLE is so it can
make use of the partition created by movablecore= which has a few specific
purposes. One of them is that on a shared system, a partition can be created
that is of the same size as the largest hugepage pool required for any job. As
jobs run, they can grow or shrink the pool as desired.  When the jobs complete,
the hugepages are no longer in use and the partition becomes essentially free.

SLAB pages do not have the same property. Even with all processes exited,
there will be slab allocations lying around, probably in this partition
preventing the hugepage pool being resized (or memory hot-remove for that
matter which can work on a section-boundary on POWER).

If the administrator has created a partition for memory hot-remove or
for having a known quantity when resizing the hugepage pool, it is
unlikely they want SLAB pages to be allocated from the same place
putting a spanner in the works. Without the partition and
slub_min_order==hugepage_size, this patch does nothing so;

NACK.

> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  mm/slub.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2008-02-13 18:57:16.036710088 -0800
> +++ linux-2.6/mm/slub.c	2008-02-13 18:59:08.561004851 -0800
> @@ -2363,6 +2363,10 @@ static int calculate_sizes(struct kmem_c
>  	if (s->flags & SLAB_CACHE_DMA)
>  		s->allocflags |= SLUB_DMA;
>  
> +	if (s->order && s->order == get_order(HPAGE_SIZE))
> +		/* Huge pages are always allocated as movable */
> +		s->allocflags |= __GFP_MOVABLE;
> +	else
>  	if (s->flags & SLAB_RECLAIM_ACCOUNT)
>  		s->allocflags |= __GFP_RECLAIMABLE;
>  
> 
> -- 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
