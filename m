Date: Sun, 21 May 2006 02:19:05 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 2/2] mm: handle unaligned zones
Message-Id: <20060521021905.0f73e01a.akpm@osdl.org>
In-Reply-To: <44702358.1090801@yahoo.com.au>
References: <4470232B.7040802@yahoo.com.au>
	<44702358.1090801@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: apw@shadowen.org, mel@csn.ul.ie, stable@kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> Allow unaligned zones, and make this an opt-in CONFIG_ option because
> some architectures appear to be relying on unaligned zones being handled
> correctly.
> 
> - Also, the bad_range checks are removed, they are checked at meminit time
>   since the last patch.
> 
> ...
> 
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c	2006-05-21 17:53:36.000000000 +1000
> +++ linux-2.6/mm/page_alloc.c	2006-05-21 18:20:13.000000000 +1000
>
> ...
>
> +{
> +#ifdef CONFIG_HOLES_IN_ZONE

(Why is this a config option?  If we can optionally handle it, why not
always just handle it?

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

You'll want a `ret = 0' here.

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
> +
> +out:
> +#endif
> +
> +	return ret;
> +}
> +
> +/*
> + * In some memory configurations, buddy pages may be found which are
> + * outside the zone pages. Check for those here.
> + */
> +static int buddy_outside_zone(struct page *page, struct page *buddy)
> +{
> +	if (page_in_zone_hole(buddy))
> +		return 1;
> +
> +	if (buddy_outside_zone_span(page, buddy))
> +		return 1;
> +
> +	return 0;
> +}
> +
> +/*
> + * This function checks whether a buddy is free and is the buddy of page.
> + * We can coalesce a page and its buddy if
> + * (a) the buddy is not "outside" the zone &&
>   * (b) the buddy is in the buddy system &&
>   * (c) a page and its buddy have the same order.
>   *
> @@ -292,15 +320,13 @@ __find_combined_index(unsigned long page
>   *
>   * For recording page's order, we use page_private(page).
>   */
> -static inline int page_is_buddy(struct page *page, int order)
> +static inline int page_is_buddy(struct page *page, struct page *buddy, int order)
>  {
> -#ifdef CONFIG_HOLES_IN_ZONE
> -	if (!pfn_valid(page_to_pfn(page)))
> +	if (buddy_outside_zone(page, buddy))
>  		return 0;

This is a heck of a lot of code to be throwing into the page-freeing
hotpath.  Surely there's a way of moving all this work to
initialisation/hotadd time?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
