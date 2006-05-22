Message-ID: <447173EF.9090000@shadowen.org>
Date: Mon, 22 May 2006 09:18:55 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [patch 2/2] mm: handle unaligned zones
References: <4470232B.7040802@yahoo.com.au> <44702358.1090801@yahoo.com.au>
In-Reply-To: <44702358.1090801@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> 2/2
> 
> 
> ------------------------------------------------------------------------
> 
> Allow unaligned zones, and make this an opt-in CONFIG_ option because
> some architectures appear to be relying on unaligned zones being handled
> correctly.
> 
> - Also, the bad_range checks are removed, they are checked at meminit time
>   since the last patch.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c	2006-05-21 17:53:36.000000000 +1000
> +++ linux-2.6/mm/page_alloc.c	2006-05-21 18:20:13.000000000 +1000
> @@ -85,55 +85,6 @@ int min_free_kbytes = 1024;
>  unsigned long __initdata nr_kernel_pages;
>  unsigned long __initdata nr_all_pages;
>  
> -#ifdef CONFIG_DEBUG_VM
> -static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
> -{
> -	int ret = 0;
> -	unsigned seq;
> -	unsigned long pfn = page_to_pfn(page);
> -
> -	do {
> -		seq = zone_span_seqbegin(zone);
> -		if (pfn >= zone->zone_start_pfn + zone->spanned_pages)
> -			ret = 1;
> -		else if (pfn < zone->zone_start_pfn)
> -			ret = 1;
> -	} while (zone_span_seqretry(zone, seq));
> -
> -	return ret;
> -}
> -
> -static int page_is_consistent(struct zone *zone, struct page *page)
> -{
> -#ifdef CONFIG_HOLES_IN_ZONE
> -	if (!pfn_valid(page_to_pfn(page)))
> -		return 0;
> -#endif
> -	if (zone != page_zone(page))
> -		return 0;
> -
> -	return 1;
> -}
> -/*
> - * Temporary debugging check for pages not lying within a given zone.
> - */
> -static int bad_range(struct zone *zone, struct page *page)
> -{
> -	if (page_outside_zone_boundaries(zone, page))
> -		return 1;
> -	if (!page_is_consistent(zone, page))
> -		return 1;
> -
> -	return 0;
> -}
> -
> -#else
> -static inline int bad_range(struct zone *zone, struct page *page)
> -{
> -	return 0;
> -}
> -#endif
> -
>  static void bad_page(struct page *page)
>  {
>  	printk(KERN_EMERG "Bad page state in process '%s'\n"
> @@ -281,9 +232,86 @@ __find_combined_index(unsigned long page
>  }
>  
>  /*
> - * This function checks whether a page is free && is the buddy
> - * we can do coalesce a page and its buddy if
> - * (a) the buddy is not in a hole &&
> + * If the mem_map may have holes (invalid pfns) in it, which are not on
> + * MAX_ORDER<<1 aligned boundaries, CONFIG_HOLES_IN_ZONE must be set by the
> + * architecture, because the buddy allocator will otherwise attempt to access
> + * their underlying struct page when finding a buddy to merge.
> + */
> +static inline int page_in_zone_hole(struct page *page)
> +{
> +#ifdef CONFIG_HOLES_IN_ZONE
> +	/*
> +	 *
> +	 */
> +	if (!pfn_valid(page_to_pfn(page)))
> +		return 1;
> +#endif
> +	return 0;
> +}
> +
> +/*
> + * If the the zone's mem_map is not 1<<MAX_ORDER aligned, CONFIG_ALIGNED_ZONE
> + * must *not* be set by the architecture, because the buddy allocator will run
> + * into "buddies" which are outside mem_map.
> + *
> + * It is not enough for the node's mem_map to be aligned, because unaligned
> + * zone boundaries can cause a buddies to be in different zones.
> + */
> +static inline int buddy_outside_zone_span(struct page *page, struct page *buddy)
> +{
> +	int ret = 0;
> +
> +#ifndef CONFIG_ALIGNED_ZONE
> +	unsigned int seq;
> +	unsigned long pfn;
> +	struct zone *zone;
> +
> +	pfn = page_to_pfn(page);
> +	zone = page_zone(page);
> +
> +	do {
> +
> +		seq = zone_span_seqbegin(zone);
> +		if (pfn >= zone->zone_start_pfn + zone->spanned_pages)
> +			ret = 1;
> +		else if (pfn < zone->zone_start_pfn)
> +			ret = 1;
> +	} while (zone_span_seqretry(zone, seq));
> +	if (ret)
> +		goto out;
> +
> +	/*
> +	 * page_zone_idx accesses page->flags, so this test must go after
> +	 * the above, which ensures that buddy is within the zone.
> +	 */
> +	if (page_zone_idx(page) != page_zone_idx(buddy))
> +		ret = 1;

Ok.  I agree that that unaligned zones should be opt-in, it always was
that way before and as the code stands now we are only adding in a
couple of shifts, ands, and a comparison to cachelines which will be
needed in the common case in the next few lines.  I'll drop a patch I've
been using in testing to making the option that way round here following
up to this email.

However, this patch here seems redundant.  The requirement from the
buddy allocator has been an aligned node_mem_map out to MAX_ORDER either
side of the zones in that node.  With the recent patch from Bob Picco it
is now allocated that way always.  So we will always have a page* from
either the adjoining zone or from the node_mem_map padding to examine
when we are looking for a buddy to coelesce with.  It should always be
safe to examine that page*'s flags to see if its free to coelesce.  For
pages outside any zone PG_buddy will never be true, for those in another
zone the page_zone_idx() check is sufficient.

With the page_zone_idx check enabled and the node_mem_map aligned, I
cannot see why we would also need to check the zone pfn numbers too?  If
we did need to check them, then there would be no benefit in checking
the page_zone_idx as that check would always succeed.

I think the smallest, lightest weight set of changes for this problem is
the node_mem_map alignement patch from Bob Picco, plus the changes to
add just the page_zone_idx checks to the allocator.  If the stack that
makes this an opt-out option is too large, a two liner to check just
page_zone_idx always would be a good option for stable.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
