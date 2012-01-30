Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id D23E56B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 06:48:24 -0500 (EST)
Date: Mon, 30 Jan 2012 11:48:20 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/15] mm: compaction: introduce isolate_freepages_range()
Message-ID: <20120130114820.GG25268@csn.ul.ie>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-5-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1327568457-27734-5-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Thu, Jan 26, 2012 at 10:00:46AM +0100, Marek Szyprowski wrote:
> From: Michal Nazarewicz <mina86@mina86.com>
> 
> This commit introduces isolate_freepages_range() function which
> generalises isolate_freepages_block() so that it can be used on
> arbitrary PFN ranges.
> 
> isolate_freepages_block() is left with only minor changes.
> 

The minor changes to isolate_freepages_block() look fine in
terms of how current compaction works. I have a minor comment on
isolate_freepages_range() but it is up to you whether to address them
or not. Whether you alter isolate_freepages_range() or not;

Acked-by: Mel Gorman <mel@csn.ul.ie>

> <SNIP>
> @@ -105,6 +109,80 @@ static unsigned long isolate_freepages_block(struct zone *zone,
>  	return total_isolated;
>  }
>  
> +/**
> + * isolate_freepages_range() - isolate free pages.
> + * @start_pfn: The first PFN to start isolating.
> + * @end_pfn:   The one-past-last PFN.
> + *
> + * Non-free pages, invalid PFNs, or zone boundaries within the
> + * [start_pfn, end_pfn) range are considered errors, cause function to
> + * undo its actions and return zero.
> + *
> + * Otherwise, function returns one-past-the-last PFN of isolated page
> + * (which may be greater then end_pfn if end fell in a middle of
> + * a free page).
> + */
> +static unsigned long
> +isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
> +{
> +	unsigned long isolated, pfn, block_end_pfn, flags;
> +	struct zone *zone = NULL;
> +	LIST_HEAD(freelist);
> +	struct page *page;
> +
> +	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
> +		if (!pfn_valid(pfn))
> +			break;
> +
> +		if (!zone)
> +			zone = page_zone(pfn_to_page(pfn));
> +		else if (zone != page_zone(pfn_to_page(pfn)))
> +			break;
> +

So what you are checking for here is if you straddle zones.
You could just initialise zone outside of the for loop. You can
then check outside the loop if end_pfn is in a different zone to
start_pfn. If it is, either adjust end_pfn accordingly or bail the
entire operation avoiding the need for release_freepages() later. This
will be a little cheaper.

> +		/*
> +		 * On subsequent iterations round_down() is actually not
> +		 * needed, but we keep it that we not to complicate the code.
> +		 */
> +		block_end_pfn = round_down(pfn, pageblock_nr_pages)
> +			+ pageblock_nr_pages;

Seems a little more involved than it needs to be. Something like
this might suit and be a bit nicer?

block_end_pfn = ALIGN(pfn+1, pageblock_nr_pages);

> +		block_end_pfn = min(block_end_pfn, end_pfn);
> +
> +		spin_lock_irqsave(&zone->lock, flags);
> +		isolated = isolate_freepages_block(pfn, block_end_pfn,
> +						   &freelist, true);
> +		spin_unlock_irqrestore(&zone->lock, flags);
> +
> +		/*
> +		 * In strict mode, isolate_freepages_block() returns 0 if
> +		 * there are any holes in the block (ie. invalid PFNs or
> +		 * non-free pages).
> +		 */
> +		if (!isolated)
> +			break;
> +
> +		/*
> +		 * If we managed to isolate pages, it is always (1 << n) *
> +		 * pageblock_nr_pages for some non-negative n.  (Max order
> +		 * page may span two pageblocks).
> +		 */
> +	}
> +
> +	/* split_free_page does not map the pages */
> +	list_for_each_entry(page, &freelist, lru) {
> +		arch_alloc_page(page, 0);
> +		kernel_map_pages(page, 1, 1);
> +	}
> +

This block is copied in two places - isolate_freepages and
isolate_freepages_range() so sharing a common helper would be nice. I
suspect you didn't because it would interfere with existing code more
than was strictly necessary which I complained about previously as
it made review harder. If that was your thinking, then just create
this helper in a separate patch. It's not critical though.

> +	if (pfn < end_pfn) {
> +		/* Loop terminated early, cleanup. */
> +		release_freepages(&freelist);
> +		return 0;
> +	}
> +
> +	/* We don't use freelists for anything. */
> +	return pfn;
> +}
> +
>  /* Returns true if the page is within a block suitable for migration to */
>  static bool suitable_migration_target(struct page *page)
>  {

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
