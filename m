Date: Thu, 4 Nov 2004 06:57:45 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH 2/3] higher order watermarks
Message-ID: <20041104085745.GA7186@logos.cnet>
References: <417F5584.2070400@yahoo.com.au> <417F55B9.7090306@yahoo.com.au> <417F5604.3000908@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <417F5604.3000908@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 27, 2004 at 06:02:12PM +1000, Nick Piggin wrote:
> 2/3

> 
> 
> Move the watermark checking code into a single function. Extend it to account
> for the order of the allocation and the number of free pages that could satisfy
> such a request.
> 
> Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>

Hi Nick,

I have a few comments and doubts.

>  linux-2.6-npiggin/include/linux/mmzone.h |    2 +
>  linux-2.6-npiggin/mm/page_alloc.c        |   58 ++++++++++++++++++++-----------
>  2 files changed, 41 insertions(+), 19 deletions(-)
> 
> diff -puN mm/page_alloc.c~vm-alloc-order-watermarks mm/page_alloc.c
> --- linux-2.6/mm/page_alloc.c~vm-alloc-order-watermarks	2004-10-27 16:41:32.000000000 +1000
> +++ linux-2.6-npiggin/mm/page_alloc.c	2004-10-27 17:53:33.000000000 +1000
> @@ -586,6 +586,37 @@ buffered_rmqueue(struct zone *zone, int 
>  }
>  
>  /*
> + * Return 1 if free pages are above 'mark'. This takes into account the order
> + * of the allocation.
> + */
> +int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> +		int alloc_type, int can_try_harder, int gfp_high)
> +{
> +	/* free_pages my go negative - that's OK */
> +	long min = mark, free_pages = z->free_pages - (1 << order) + 1;
> +	int o;
> +
> +	if (gfp_high)
> +		min -= min / 2;
> +	if (can_try_harder)
> +		min -= min / 4;
> +
> +	if (free_pages <= min + z->protection[alloc_type])
> +		return 0;
> +	for (o = 0; o < order; o++) {
> +		/* At the next order, this order's pages become unavailable */
> +		free_pages -= z->free_area[order].nr_free << o;
> +
> +		/* Require fewer higher order pages to be free */
> +		min >>= 1;

I can't understand this. You decrease from free_pages 
nr_order_free_pages << o, in a loop, and divide min by two.

What is the meaning of "nr_free_pages[order] << o" ? Its only meaningful
when o == order?

You're multiplying the number of free pages of the order the allocation
wants by "0, 1..order". The two values have different meanings, until 
o == order.

In the first iteration of the loop, order is 0, so you decrease from free_pages 
"z->free_area[order].nr_free". Again, the two values mean different things.

Can you enlight me?

I see you're trying to have some kind of extra protection, but the calculation 
is difficult to understand for me.

> +
> +		if (free_pages <= min)
> +			return 0;
> +	}
> +	return 1;
> +}
> +
> +/*
>   * This is the 'heart' of the zoned buddy allocator.
>   *
>   * Herein lies the mysterious "incremental min".  That's the
> @@ -606,7 +637,6 @@ __alloc_pages(unsigned int gfp_mask, uns
>  		struct zonelist *zonelist)
>  {
>  	const int wait = gfp_mask & __GFP_WAIT;
> -	unsigned long min;
>  	struct zone **zones, *z;
>  	struct page *page;
>  	struct reclaim_state reclaim_state;
> @@ -636,9 +666,9 @@ __alloc_pages(unsigned int gfp_mask, uns
>  
>  	/* Go through the zonelist once, looking for a zone with enough free */
>  	for (i = 0; (z = zones[i]) != NULL; i++) {
> -		min = z->pages_low + (1<<order) + z->protection[alloc_type];
>  
> -		if (z->free_pages < min)
> +		if (!zone_watermark_ok(z, order, z->pages_low,
> +				alloc_type, 0, 0))


The original code didnt had the can_try_harder/gfp_high decrease 
which is now on zone_watermark_ok. 

Means that those allocations will now be successful earlier, instead
of going to the next zonelist iteration. kswapd will not be awake
when it used to be.

Hopefully it doesnt matter that much. You did this by intention?

TIA

>  			continue;
>  
>  		page = buffered_rmqueue(z, order, gfp_mask);
> @@ -654,14 +684,9 @@ __alloc_pages(unsigned int gfp_mask, uns
>  	 * coming from realtime tasks to go deeper into reserves
>  	 */
>  	for (i = 0; (z = zones[i]) != NULL; i++) {
> -		min = z->pages_min;
> -		if (gfp_mask & __GFP_HIGH)
> -			min /= 2;
> -		if (can_try_harder)
> -			min -= min / 4;
> -		min += (1<<order) + z->protection[alloc_type];
> -
> -		if (z->free_pages < min)
> +		if (!zone_watermark_ok(z, order, z->pages_min,
> +				alloc_type, can_try_harder,
> +				gfp_mask & __GFP_HIGH))
>  			continue;
>  
>  		page = buffered_rmqueue(z, order, gfp_mask);
> @@ -697,14 +722,9 @@ rebalance:
>  
>  	/* go through the zonelist yet one more time */
>  	for (i = 0; (z = zones[i]) != NULL; i++) {
> -		min = z->pages_min;
> -		if (gfp_mask & __GFP_HIGH)
> -			min /= 2;
> -		if (can_try_harder)
> -			min -= min / 4;
> -		min += (1<<order) + z->protection[alloc_type];
> -
> -		if (z->free_pages < min)
> +		if (!zone_watermark_ok(z, order, z->pages_min,
> +				alloc_type, can_try_harder,
> +				gfp_mask & __GFP_HIGH))
>  			continue;
>  
>  		page = buffered_rmqueue(z, order, gfp_mask);
> diff -puN include/linux/mmzone.h~vm-alloc-order-watermarks include/linux/mmzone.h
> --- linux-2.6/include/linux/mmzone.h~vm-alloc-order-watermarks	2004-10-27 16:41:32.000000000 +1000
> +++ linux-2.6-npiggin/include/linux/mmzone.h	2004-10-27 17:52:07.000000000 +1000
> @@ -279,6 +279,8 @@ void get_zone_counts(unsigned long *acti
>  			unsigned long *free);
>  void build_all_zonelists(void);
>  void wakeup_kswapd(struct zone *zone);
> +int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> +		int alloc_type, int can_try_harder, int gfp_high);
>  
>  /*
>   * zone_idx() returns 0 for the ZONE_DMA zone, 1 for the ZONE_NORMAL zone, etc.
> 
> _

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
