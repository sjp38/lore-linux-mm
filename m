Message-ID: <459E816D.9050903@shadowen.org>
Date: Fri, 05 Jan 2007 16:48:45 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [patch] fix memmap accounting
References: <20070105145501.GA9602@osiris.boeblingen.de.ibm.com>
In-Reply-To: <20070105145501.GA9602@osiris.boeblingen.de.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Heiko Carstens wrote:
> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Using some rather large holes in memory gives me an error.
> Present memory areas are 0-1GB and 1023GB-1023.5GB (1.5GB in total)
> 
> Kernel output on s390 with vmemmap is this:
> 
> Entering add_active_range(0, 0, 262143) 0 entries of 256 used
> Entering add_active_range(0, 268173312, 268304383) 1 entries of 256 used
> Detected 4 CPU's
> Boot cpu address  0
> Zone PFN ranges:
>   DMA             0 ->   524288
>   Normal     524288 -> 268304384
> early_node_map[2] active PFN ranges
>     0:        0 ->   262143
>     0: 268173312 -> 268304383
> On node 0 totalpages: 393214
>   DMA zone: 9216 pages used for memmap
>   DMA zone: 0 pages reserved
>   DMA zone: 252927 pages, LIFO batch:31
> 
>   Normal zone: 4707071 pages exceeds realsize 131071  <------
> 
>   Normal zone: 131071 pages, LIFO batch:31
> Built 1 zonelists.  Total pages: 383998  
> 
> So the calculation of the number of pages needed for the memmap is wrong.
> It just doesn't work with virtual memmaps since it expects that all pages
> of a memmap are actually backed with physical pages which is not the case
> here.
> 
> This patch fixes it, but I guess something similar is also needed for
> SPARSEMEM and ia64 (with vmemmap).
> 
> Cc: Dave Hansen <haveblue@us.ibm.com>
> Cc: Andy Whitcroft <apw@shadowen.org>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> ---
>  arch/s390/Kconfig |    3 +++
>  mm/page_alloc.c   |    4 ++++
>  2 files changed, 7 insertions(+)
> 
> Index: linux-2.6/arch/s390/Kconfig
> ===================================================================
> --- linux-2.6.orig/arch/s390/Kconfig
> +++ linux-2.6/arch/s390/Kconfig
> @@ -30,6 +30,9 @@ config ARCH_HAS_ILOG2_U64
>  	bool
>  	default n
>  
> +config ARCH_HAS_VMEMMAP
> +	def_bool y
> +
>  config GENERIC_HWEIGHT
>  	bool
>  	default y
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -2629,7 +2629,11 @@ static void __meminit free_area_init_cor
>  		 * is used by this zone for memmap. This affects the watermark
>  		 * and per-cpu initialisations
>  		 */
> +#ifdef CONFIG_ARCH_HAS_VMEMMAP
> +		memmap_pages = (realsize * sizeof(struct page)) >> PAGE_SHIFT;

This is a pretty crude estimate.  We could be using half a page in 100
pages and get the number way out.  That said its also really only a hint
to try and get the water marks right.  All that based on the assumption
that the pages which back the zone are from the zone.  Is that even a
valid assumption.  On numa-q they are 'outside' the node, on x86 they
are all out of node 0.  Hmmm.

> +#else
>  		memmap_pages = (size * sizeof(struct page)) >> PAGE_SHIFT;
> +#endif
>  		if (realsize >= memmap_pages) {
>  			realsize -= memmap_pages;
>  			printk(KERN_DEBUG

I think Dave has the right of it in that we should be pushing the memmap
'consumption' issue back to the memory model not exposing it here.

However, it is key to note that these are estimates and used to set the
water marks and the like.  As mentioned earlier they are already
somewhat inaccurate as we may not be allocating them from the zone
itself or even from accounted memory.

The correct fix would seem to be to have a memmap_size(zone) style
interface provided by the memory models.  Of course at the time we need
the information the actual zone is not yet initialised at all.

Perhaps we could take a stab at this improving the situation, improving
the estimates without completly fixing things.  Something like this
which would just make a judgement about the 'sparseness' of the memmap.

int memmap_size(struct zone *zone)
{
#if defined(CONFIG_SPARSEMEM) || defined(ARCH_HAS_VMMEMMAP)
	return (zone->present_pages * sizeof(struct page)
					>> PAGE_SHIFT);
#else
	return (zone->spanned_pages * sizeof(struct page)
					>> PAGE_SHIFT);
}

Of course this would mean changing the order a little in
free_area_init_core() so that we have these filled in at least.


Perhaps we are looking at this the wrong way round.  We only care about
the realsize in the context of working out sensible watermarks.  If we
simply initialised all of the zones ignoring the size of the memmap it
would get allocated from wherever.  Once _all_ zones are up and running
we could do a second pass and look at the _real_ number of pages free in
the zone and make the requisite percentage of _that_.  Obviously highmem
is released separately and so that would need calculating later.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
