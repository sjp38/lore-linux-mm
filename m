Date: Mon, 21 Apr 2008 11:12:32 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH]Fix usemap for DISCONTIG/FLATMEM with not-aligned zone initilaization.
Message-ID: <20080421101231.GA629@csn.ul.ie>
References: <20080418161522.GB9147@csn.ul.ie> <48080706.50305@cn.fujitsu.com> <48080930.5090905@cn.fujitsu.com> <48080B86.7040200@cn.fujitsu.com> <20080418211214.299f91cd.kamezawa.hiroyu@jp.fujitsu.com> <21878461.1208539556838.kamezawa.hiroyu@jp.fujitsu.com> <20080421112048.78f0ec76.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080421112048.78f0ec76.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Shi Weihua <shiwh@cn.fujitsu.com>, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On (21/04/08 11:20), KAMEZAWA Hiroyuki didst pronounce:
> On Sat, 19 Apr 2008 02:25:56 +0900 (JST)
> kamezawa.hiroyu@jp.fujitsu.com wrote:
>  
> > >What about something like the following? Instead of expanding the size of
> > >structures, it sanity checks input parameters. It touches a number of places
> > >because of an API change but it is otherwise straight-forward.
> > >
> > >Unfortunately, I do not have an IA-64 machine that can reproduce the problem
> > >to see if this still fixes it or not so a test as well as a review would be
> > >appreciated. What should happen is the machine boots but prints a warning
> > >about the unexpected PFN ranges. It boot-tested fine on a number of other
> > >machines (x86-32 x86-64 and ppc64).
> > >
> > ok, I'll test today if I have a chance. At least, I think I can test this
> > until Monday. but I have one concern (below)
> > 
> I tested and found your patch doesn't work.
> It seems because all valid page struct is not initialized.

The fact I didn't calculate end_pfn properly as pointed out by Dave Hansen
didn't help either. If that was corrected, I'd be surprised if the patch
didn't work. If it is broken, it implies that arch-specific code is using
PFN ranges that do not contain valid memory - something I find surprising.

> (By pfn_valid(), a page struct is valid if it exists regardless of zones.)
> 
> How about below ? I think this is simple.
> Tested and worked well.
> 

This patch is fine. It checks the ranges passed in a less-invasive
fashion than the previous patch. Thanks

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ==
> usemap must be initialized only when pfn is within zone.
> If not, it corrupts memory.
> 
> After intialization, usemap is used for only pfn in valid range.
> (We have to init memmap even in invalid range.)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  mm/page_alloc.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.25/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.25.orig/mm/page_alloc.c
> +++ linux-2.6.25/mm/page_alloc.c
> @@ -2518,6 +2518,7 @@ void __meminit memmap_init_zone(unsigned
>  	struct page *page;
>  	unsigned long end_pfn = start_pfn + size;
>  	unsigned long pfn;
> +	struct zone *z;
>  
>  	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
>  		/*
> @@ -2536,7 +2537,7 @@ void __meminit memmap_init_zone(unsigned
>  		init_page_count(page);
>  		reset_page_mapcount(page);
>  		SetPageReserved(page);
> -
> +		z = page_zone(page);
>  		/*
>  		 * Mark the block movable so that blocks are reserved for
>  		 * movable at startup. This will force kernel allocations
> @@ -2546,7 +2547,9 @@ void __meminit memmap_init_zone(unsigned
>  		 * the start are marked MIGRATE_RESERVE by
>  		 * setup_zone_migrate_reserve()
>  		 */
> -		if ((pfn & (pageblock_nr_pages-1)))
> +		if ((z->zone_start_pfn < pfn)
> +		    && (pfn < z->zone_start_pfn + z->spanned_pages)
> +		    && !(pfn & (pageblock_nr_pages-1)))
>  			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
>  
>  		INIT_LIST_HEAD(&page->lru);
> @@ -4460,6 +4463,8 @@ void set_pageblock_flags_group(struct pa
>  	pfn = page_to_pfn(page);
>  	bitmap = get_pageblock_bitmap(zone, pfn);
>  	bitidx = pfn_to_bitidx(zone, pfn);
> +	VM_BUG_ON(pfn < zone->zone_start_pfn);
> +	VM_BUG_ON(pfn >= zone->zone_start_pfn + zone->spanned_pages);
>  
>  	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
>  		if (flags & value)
>  
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
