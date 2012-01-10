Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 46ADA6B005A
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 08:44:01 -0500 (EST)
Date: Tue, 10 Jan 2012 13:43:51 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/11] mm: compaction: introduce
 isolate_{free,migrate}pages_range().
Message-ID: <20120110134351.GA3910@csn.ul.ie>
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
 <1325162352-24709-3-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1325162352-24709-3-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Thu, Dec 29, 2011 at 01:39:03PM +0100, Marek Szyprowski wrote:
> From: Michal Nazarewicz <mina86@mina86.com>
> 
> This commit introduces isolate_freepages_range() and
> isolate_migratepages_range() functions.  The first one replaces
> isolate_freepages_block() and the second one extracts functionality
> from isolate_migratepages().
> 
> They are more generic and instead of operating on pageblocks operate
> on PFN ranges.
> 
> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> ---
>  mm/compaction.c |  184 ++++++++++++++++++++++++++++++++++++++-----------------
>  1 files changed, 127 insertions(+), 57 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 899d956..ae73b6f 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -54,55 +54,86 @@ static unsigned long release_freepages(struct list_head *freelist)
>  	return count;
>  }
>  
> -/* Isolate free pages onto a private freelist. Must hold zone->lock */
> -static unsigned long isolate_freepages_block(struct zone *zone,
> -				unsigned long blockpfn,
> -				struct list_head *freelist)
> +/**
> + * isolate_freepages_range() - isolate free pages, must hold zone->lock.
> + * @zone:	Zone pages are in.
> + * @start_pfn:	The first PFN to start isolating.
> + * @end_pfn:	The one-past-last PFN.
> + * @freelist:	A list to save isolated pages to.
> + *
> + * If @freelist is not provided, holes in range (either non-free pages
> + * or invalid PFNs) are considered an error and function undos its
> + * actions and returns zero.
> + *
> + * If @freelist is provided, function will simply skip non-free and
> + * missing pages and put only the ones isolated on the list.
> + *
> + * Returns number of isolated pages.  This may be more then end_pfn-start_pfn
> + * if end fell in a middle of a free page.
> + */
> +static unsigned long
> +isolate_freepages_range(struct zone *zone,
> +			unsigned long start_pfn, unsigned long end_pfn,
> +			struct list_head *freelist)
>  {
> -	unsigned long zone_end_pfn, end_pfn;
> -	int nr_scanned = 0, total_isolated = 0;
> -	struct page *cursor;
> -
> -	/* Get the last PFN we should scan for free pages at */
> -	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
> -	end_pfn = min(blockpfn + pageblock_nr_pages, zone_end_pfn);
> +	unsigned long nr_scanned = 0, total_isolated = 0;
> +	unsigned long pfn = start_pfn;
> +	struct page *page;
>  
> -	/* Find the first usable PFN in the block to initialse page cursor */
> -	for (; blockpfn < end_pfn; blockpfn++) {
> -		if (pfn_valid_within(blockpfn))
> -			break;
> -	}
> -	cursor = pfn_to_page(blockpfn);
> +	VM_BUG_ON(!pfn_valid(pfn));
> +	page = pfn_to_page(pfn);

The existing code is able to find the first usable PFN in a pageblock
with pfn_valid_within(). It's allowed to do that because it knows
the pageblock is valid so calling pfn_valid() is unnecessary.

It is curious to change this to something that can sometimes BUG_ON
!pfn_valid(pfn) instead of having a PFN walker that knows how to
handle pfn_valid().

>  
>  	/* Isolate free pages. This assumes the block is valid */

You leave this comment intact but you are no longer scanning a page
block. It is in fact assuming that the entire range is valid.

> -	for (; blockpfn < end_pfn; blockpfn++, cursor++) {
> -		int isolated, i;
> -		struct page *page = cursor;
> +	while (pfn < end_pfn) {
> +		int n = 0, i;
>  
> -		if (!pfn_valid_within(blockpfn))
> -			continue;
> -		nr_scanned++;
> +		if (!pfn_valid_within(pfn))
> +			goto next;
> +		++nr_scanned;
>  
>  		if (!PageBuddy(page))
> -			continue;
> +			goto next;
>  
>  		/* Found a free page, break it into order-0 pages */
> -		isolated = split_free_page(page);
> -		total_isolated += isolated;
> -		for (i = 0; i < isolated; i++) {
> -			list_add(&page->lru, freelist);
> -			page++;
> +		n = split_free_page(page);
> +		total_isolated += n;
> +		if (freelist) {
> +			struct page *p = page;
> +			for (i = n; i; --i, ++p)
> +				list_add(&p->lru, freelist);

Maybe it's just me, but the original code of

		for (i = 0; i < isolated; i++) {
			list_add(&page->lru, freelist);
			page++;
		}

Was a lot easier to read than this increment/decrement with zero
check for loop. Even 

for (i = 0; i < n; i++)
	list_add(&p[i].lru, freelist)

would have been a bit easier to parse. I also don't even get why you
renamed "isolated" to the less obvious name "n".

Neither are wrong, it just looks obscure for the sake of it.

>  		}
>  
> -		/* If a page was split, advance to the end of it */
> -		if (isolated) {
> -			blockpfn += isolated - 1;
> -			cursor += isolated - 1;
> +next:
> +		if (!n) {
> +			/* If n == 0, we have isolated no pages. */
> +			if (!freelist)
> +				goto cleanup;
> +			n = 1;
>  		}

That needs a better comment explaining why we undo what has happened up
until now if freelist == NULL.

> +
> +		/*
> +		 * If we pass max order page, we might end up in a different
> +		 * vmemmap, so account for that.
> +		 */
> +		pfn += n;
> +		if (pfn & (MAX_ORDER_NR_PAGES - 1))
> +			page += n;
> +		else
> +			page = pfn_to_page(pfn);
>  	}

You never check that the pfn is actually valid. There could be a
memory hole between start_pfn and end_pfn for example. This is probably
not true of the CMA caller or the existing compaction caller but it is
still unnecessarily fragile.

>  
>  	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
>  	return total_isolated;
> +
> +cleanup:
> +	/*
> +	 * Undo what we have done so far, and return.  We know all pages from
> +	 * [start_pfn, pfn) are free because we have just freed them.  If one of
> +	 * the page in the range was not freed, we would end up here earlier.
> +	 */
> +	for (; start_pfn < pfn; ++start_pfn)
> +		__free_page(pfn_to_page(start_pfn));
> +	return 0;

This returns 0 even though you could have isolated some pages.

Overall, there would have been less contortion if you
implemented isolate_freepages_range() in terms of the existing
isolate_freepages_block. Something that looked kinda like this not
compiled untested illustration.

static unsigned long isolate_freepages_range(struct zone *zone,
                        unsigned long start_pfn, unsigned long end_pfn,
                        struct list_head *list)
{
        unsigned long pfn = start_pfn;
        unsigned long isolated;

        for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
                if (!pfn_valid(pfn))
                        continue;

                isolated += isolate_freepages_block(zone, pfn, list);
        }

        return isolated;
}

I neglected to update isolate_freepages_block() to take the end_pfn
meaning it will in fact isolate too much but that would be easy to
address. It would be up to yourself whether to shuffle the tracepoint
around because with this example it will be triggered once per
pageblock. You'd still need the cleanup code and freelist check in
isolate_freepages_block() of course.

The point is that it would minimise the disruption to the existing
code and easier to get details like pfn_valid() right without odd
contortions, more gotos than should be necessary and trying to keep
pfn and page straight.

>  }
>  
>  /* Returns true if the page is within a block suitable for migration to */
> @@ -135,7 +166,7 @@ static void isolate_freepages(struct zone *zone,
>  				struct compact_control *cc)
>  {
>  	struct page *page;
> -	unsigned long high_pfn, low_pfn, pfn;
> +	unsigned long high_pfn, low_pfn, pfn, zone_end_pfn, end_pfn;
>  	unsigned long flags;
>  	int nr_freepages = cc->nr_freepages;
>  	struct list_head *freelist = &cc->freepages;
> @@ -155,6 +186,8 @@ static void isolate_freepages(struct zone *zone,
>  	 */
>  	high_pfn = min(low_pfn, pfn);
>  
> +	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
> +
>  	/*
>  	 * Isolate free pages until enough are available to migrate the
>  	 * pages on cc->migratepages. We stop searching if the migrate
> @@ -191,7 +224,9 @@ static void isolate_freepages(struct zone *zone,
>  		isolated = 0;
>  		spin_lock_irqsave(&zone->lock, flags);
>  		if (suitable_migration_target(page)) {
> -			isolated = isolate_freepages_block(zone, pfn, freelist);
> +			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
> +			isolated = isolate_freepages_range(zone, pfn,
> +					end_pfn, freelist);
>  			nr_freepages += isolated;
>  		}
>  		spin_unlock_irqrestore(&zone->lock, flags);
> @@ -250,31 +285,34 @@ typedef enum {
>  	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
>  } isolate_migrate_t;
>  
> -/*
> - * Isolate all pages that can be migrated from the block pointed to by
> - * the migrate scanner within compact_control.
> +/**
> + * isolate_migratepages_range() - isolate all migrate-able pages in range.
> + * @zone:	Zone pages are in.
> + * @cc:		Compaction control structure.
> + * @low_pfn:	The first PFN of the range.
> + * @end_pfn:	The one-past-the-last PFN of the range.
> + *
> + * Isolate all pages that can be migrated from the range specified by
> + * [low_pfn, end_pfn).  Returns zero if there is a fatal signal
> + * pending), otherwise PFN of the first page that was not scanned
> + * (which may be both less, equal to or more then end_pfn).
> + *
> + * Assumes that cc->migratepages is empty and cc->nr_migratepages is
> + * zero.
> + *
> + * Other then cc->migratepages and cc->nr_migratetypes this function
> + * does not modify any cc's fields, ie. it does not modify (or read
> + * for that matter) cc->migrate_pfn.
>   */
> -static isolate_migrate_t isolate_migratepages(struct zone *zone,
> -					struct compact_control *cc)
> +static unsigned long
> +isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
> +			   unsigned long low_pfn, unsigned long end_pfn)
>  {
> -	unsigned long low_pfn, end_pfn;
>  	unsigned long last_pageblock_nr = 0, pageblock_nr;
>  	unsigned long nr_scanned = 0, nr_isolated = 0;
>  	struct list_head *migratelist = &cc->migratepages;
>  	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
>  
> -	/* Do not scan outside zone boundaries */
> -	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
> -
> -	/* Only scan within a pageblock boundary */
> -	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
> -
> -	/* Do not cross the free scanner or scan within a memory hole */
> -	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
> -		cc->migrate_pfn = end_pfn;
> -		return ISOLATE_NONE;
> -	}
> -
>  	/*
>  	 * Ensure that there are not too many pages isolated from the LRU
>  	 * list by either parallel reclaimers or compaction. If there are,
> @@ -283,12 +321,12 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	while (unlikely(too_many_isolated(zone))) {
>  		/* async migration should just abort */
>  		if (!cc->sync)
> -			return ISOLATE_ABORT;
> +			return 0;
>  
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		if (fatal_signal_pending(current))
> -			return ISOLATE_ABORT;
> +			return 0;
>  	}
>  
>  	/* Time to isolate some pages for migration */
> @@ -365,17 +403,49 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  		nr_isolated++;
>  
>  		/* Avoid isolating too much */
> -		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX)
> +		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX) {
> +			++low_pfn;
>  			break;
> +		}
>  	}

This minor optimisation is unrelated to the implementation of
isolate_migratepages_range() and should be in its own patch.

Otherwise nothing jumped out.

>  
>  	acct_isolated(zone, cc);
>  
>  	spin_unlock_irq(&zone->lru_lock);
> -	cc->migrate_pfn = low_pfn;
>  
>  	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
>  
> +	return low_pfn;
> +}
> +
> +/*
> + * Isolate all pages that can be migrated from the block pointed to by
> + * the migrate scanner within compact_control.
> + */
> +static isolate_migrate_t isolate_migratepages(struct zone *zone,
> +					struct compact_control *cc)
> +{
> +	unsigned long low_pfn, end_pfn;
> +
> +	/* Do not scan outside zone boundaries */
> +	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
> +
> +	/* Only scan within a pageblock boundary */
> +	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
> +
> +	/* Do not cross the free scanner or scan within a memory hole */
> +	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
> +		cc->migrate_pfn = end_pfn;
> +		return ISOLATE_NONE;
> +	}
> +
> +	/* Perform the isolation */
> +	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
> +	if (!low_pfn)
> +		return ISOLATE_ABORT;
> +
> +	cc->migrate_pfn = low_pfn;
> +
>  	return ISOLATE_SUCCESS;
>  }
>  

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
