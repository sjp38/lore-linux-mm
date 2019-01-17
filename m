Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A9C4E8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:36:13 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f31so3718151edf.17
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 06:36:13 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g16-v6si2551756ejf.225.2019.01.17.06.36.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 06:36:11 -0800 (PST)
Subject: Re: [PATCH 13/25] mm, compaction: Use free lists to quickly locate a
 migration target
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-14-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f9ba4f25-b0b1-8323-f2a8-a4dd639a1882@suse.cz>
Date: Thu, 17 Jan 2019 15:36:08 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-14-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/4/19 1:49 PM, Mel Gorman wrote:
> Similar to the migration scanner, this patch uses the free lists to quickly
> locate a migration target. The search is different in that lower orders
> will be searched for a suitable high PFN if necessary but the search
> is still bound. This is justified on the grounds that the free scanner
> typically scans linearly much more than the migration scanner.
> 
> If a free page is found, it is isolated and compaction continues if enough
> pages were isolated. For SYNC* scanning, the full pageblock is scanned
> for any remaining free pages so that is can be marked for skipping in
> the near future.
> 
> 1-socket thpfioscale
>                                         4.20.0                 4.20.0
>                                  isolmig-v2r15         findfree-v2r15
> Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
> Amean     fault-both-3      3066.68 (   0.00%)     2884.51 (   5.94%)
> Amean     fault-both-5      4298.49 (   0.00%)     4419.70 (  -2.82%)
> Amean     fault-both-7      5986.99 (   0.00%)     6039.04 (  -0.87%)
> Amean     fault-both-12     9324.85 (   0.00%)     9992.34 (  -7.16%)
> Amean     fault-both-18    13350.05 (   0.00%)    12690.05 (   4.94%)
> Amean     fault-both-24    13491.77 (   0.00%)    14393.93 (  -6.69%)
> Amean     fault-both-30    15630.86 (   0.00%)    16894.08 (  -8.08%)
> Amean     fault-both-32    17428.50 (   0.00%)    17813.68 (  -2.21%)
> 
> The impact on latency is variable but the search is optimistic and
> sensitive to the exact system state. Success rates are similar but
> the major impact is to the rate of scanning
> 
>                             4.20.0-rc6  4.20.0-rc6
>                           isolmig-v1r4findfree-v1r8
> Compaction migrate scanned    25516488    28324352
> Compaction free scanned       87603321    56131065
> 
> The free scan rates are reduced by 35%. The 2-socket reductions for the
> free scanner are more dramatic which is a likely reflection that the
> machine has more memory.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/compaction.c | 203 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 198 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 24e3a9db4b70..9438f0564ed5 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1136,7 +1136,7 @@ static inline bool compact_scanners_met(struct compact_control *cc)
>  
>  /* Reorder the free list to reduce repeated future searches */
>  static void
> -move_freelist_tail(struct list_head *freelist, struct page *freepage)
> +move_freelist_head(struct list_head *freelist, struct page *freepage)
>  {
>  	LIST_HEAD(sublist);
>  
> @@ -1147,6 +1147,193 @@ move_freelist_tail(struct list_head *freelist, struct page *freepage)
>  	}
>  }

Hmm this hunk appears to simply rename move_freelist_tail() to
move_freelist_head(), but fast_find_migrateblock() is unchanged, so it now calls
the new version below.

> +static void
> +move_freelist_tail(struct list_head *freelist, struct page *freepage)
> +{
> +	LIST_HEAD(sublist);
> +
> +	if (!list_is_last(freelist, &freepage->lru)) {
> +		list_cut_before(&sublist, freelist, &freepage->lru);
> +		if (!list_empty(&sublist))
> +			list_splice_tail(&sublist, freelist);
> +	}
> +}

And this differs in using list_cut_before() instead of list_cut_position(). I'm
assuming that move_freelist_tail() was supposed to be unchanged, and
move_freelist_head() different, but it's the opposite. BTW it would be nice to
document both of the functions what they are doing on the high level :) The one
above was a bit tricky to decode to me, as it seems to be moving the initial
part of list to the tail, to effectively move the latter part of the list
(including freepage) to the head.

> +static void
> +fast_isolate_around(struct compact_control *cc, unsigned long pfn, unsigned long nr_isolated)
> +{
> +	unsigned long start_pfn, end_pfn;
> +	struct page *page = pfn_to_page(pfn);
> +
> +	/* Do not search around if there are enough pages already */
> +	if (cc->nr_freepages >= cc->nr_migratepages)
> +		return;
> +
> +	/* Minimise scanning during async compaction */
> +	if (cc->direct_compaction && cc->mode == MIGRATE_ASYNC)
> +		return;
> +
> +	/* Pageblock boundaries */
> +	start_pfn = pageblock_start_pfn(pfn);
> +	end_pfn = min(start_pfn + pageblock_nr_pages, zone_end_pfn(cc->zone));
> +
> +	/* Scan before */
> +	if (start_pfn != pfn) {
> +		isolate_freepages_block(cc, &start_pfn, pfn, &cc->freepages, false);
> +		if (cc->nr_freepages >= cc->nr_migratepages)
> +			return;
> +	}
> +
> +	/* Scan after */
> +	start_pfn = pfn + nr_isolated;
> +	if (start_pfn != end_pfn)
> +		isolate_freepages_block(cc, &start_pfn, end_pfn, &cc->freepages, false);
> +
> +	/* Skip this pageblock in the future as it's full or nearly full */
> +	if (cc->nr_freepages < cc->nr_migratepages)
> +		set_pageblock_skip(page);
> +}
> +
> +static unsigned long
> +fast_isolate_freepages(struct compact_control *cc)
> +{
> +	unsigned int limit = min(1U, freelist_scan_limit(cc) >> 1);
> +	unsigned int order_scanned = 0, nr_scanned = 0;
> +	unsigned long low_pfn, min_pfn, high_pfn = 0, highest = 0;
> +	unsigned long nr_isolated = 0;
> +	unsigned long distance;
> +	struct page *page = NULL;
> +	bool scan_start = false;
> +	int order;
> +
> +	/*
> +	 * If starting the scan, use a deeper search and use the highest
> +	 * PFN found if a suitable one is not found.
> +	 */
> +	if (cc->free_pfn == pageblock_start_pfn(zone_end_pfn(cc->zone) - 1)) {
> +		limit = pageblock_nr_pages >> 1;
> +		scan_start = true;
> +	}
> +
> +	/*
> +	 * Preferred point is in the top quarter of the scan space but take
> +	 * a pfn from the top half if the search is problematic.
> +	 */
> +	distance = (cc->free_pfn - cc->migrate_pfn);
> +	low_pfn = pageblock_start_pfn(cc->free_pfn - (distance >> 2));
> +	min_pfn = pageblock_start_pfn(cc->free_pfn - (distance >> 1));
> +
> +	if (WARN_ON_ONCE(min_pfn > low_pfn))
> +		low_pfn = min_pfn;
> +
> +	for (order = cc->order - 1;
> +	     order >= 0 && !page;
> +	     order--) {
> +		struct free_area *area = &cc->zone->free_area[order];
> +		struct list_head *freelist;
> +		struct page *freepage;
> +		unsigned long flags;
> +
> +		if (!area->nr_free)
> +			continue;
> +
> +		spin_lock_irqsave(&cc->zone->lock, flags);
> +		freelist = &area->free_list[MIGRATE_MOVABLE];
> +		list_for_each_entry_reverse(freepage, freelist, lru) {
> +			unsigned long pfn;
> +
> +			order_scanned++;
> +			nr_scanned++;

Seems order_scanned is supposed to be reset to 0 for each new order? Otherwise
it's equivalent to nr_scanned...

> +			pfn = page_to_pfn(freepage);
> +
> +			if (pfn >= highest)
> +				highest = pageblock_start_pfn(pfn);
> +
> +			if (pfn >= low_pfn) {
> +				cc->fast_search_fail = 0;
> +				page = freepage;
> +				break;
> +			}
> +
> +			if (pfn >= min_pfn && pfn > high_pfn) {
> +				high_pfn = pfn;
> +
> +				/* Shorten the scan if a candidate is found */
> +				limit >>= 1;
> +			}
> +
> +			if (order_scanned >= limit)
> +				break;
> +		}
> +
> +		/* Use a minimum pfn if a preferred one was not found */
> +		if (!page && high_pfn) {
> +			page = pfn_to_page(high_pfn);
> +
> +			/* Update freepage for the list reorder below */
> +			freepage = page;
> +		}
> +
> +		/* Reorder to so a future search skips recent pages */
> +		move_freelist_head(freelist, freepage);
> +
> +		/* Isolate the page if available */
> +		if (page) {
> +			if (__isolate_free_page(page, order)) {
> +				set_page_private(page, order);
> +				nr_isolated = 1 << order;
> +				cc->nr_freepages += nr_isolated;
> +				list_add_tail(&page->lru, &cc->freepages);
> +				count_compact_events(COMPACTISOLATED, nr_isolated);
> +			} else {
> +				/* If isolation fails, abort the search */
> +				order = -1;
> +				page = NULL;
> +			}
> +		}
> +
> +		spin_unlock_irqrestore(&cc->zone->lock, flags);
> +
> +		/*
> +		 * Smaller scan on next order so the total scan ig related
> +		 * to freelist_scan_limit.
> +		 */
> +		if (order_scanned >= limit)

... and this also indicates order_scanned is supposed to be reset.

> +			limit = min(1U, limit >> 1);
> +	}
> +
> +	if (!page) {
> +		cc->fast_search_fail++;
> +		if (scan_start) {
> +			/*
> +			 * Use the highest PFN found above min. If one was
> +			 * not found, be pessemistic for direct compaction
> +			 * and use the min mark.
> +			 */
> +			if (highest) {
> +				page = pfn_to_page(highest);
> +				cc->free_pfn = highest;
> +			} else {
> +				if (cc->direct_compaction) {
> +					page = pfn_to_page(min_pfn);
> +					cc->free_pfn = min_pfn;
> +				}
> +			}
> +		}
> +	}
> +
> +	if (highest && highest > cc->zone->compact_cached_free_pfn)
> +		cc->zone->compact_cached_free_pfn = highest;
> +
> +	cc->total_free_scanned += nr_scanned;
> +	if (!page)
> +		return cc->free_pfn;
> +
> +	low_pfn = page_to_pfn(page);
> +	fast_isolate_around(cc, low_pfn, nr_isolated);
> +	return low_pfn;
> +}
> +
>  /*
>   * Based on information in the current compact_control, find blocks
>   * suitable for isolating free pages from and then isolate them.
