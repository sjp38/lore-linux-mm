Return-Path: <linux-kernel-owner@vger.kernel.org>
Subject: Re: [PATCH 23/25] mm, compaction: Be selective about what pageblocks
 to clear skip hints
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-24-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <73c2705a-ead3-614a-0364-458d919d8e13@suse.cz>
Date: Fri, 18 Jan 2019 13:55:24 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-24-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 1/4/19 1:50 PM, Mel Gorman wrote:
> Pageblock hints are cleared when compaction restarts or kswapd makes enough
> progress that it can sleep but it's over-eager in that the bit is cleared
> for migration sources with no LRU pages and migration targets with no free
> pages. As pageblock skip hint flushes are relatively rare and out-of-band
> with respect to kswapd, this patch makes a few more expensive checks to
> see if it's appropriate to even clear the bit. Every pageblock that is
> not cleared will avoid 512 pages being scanned unnecessarily on x86-64.
> 
> The impact is variable with different workloads showing small differences
> in latency, success rates and scan rates. This is expected as clearing
> the hints is not that common but doing a small amount of work out-of-band
> to avoid a large amount of work in-band later is generally a good thing.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Similar doubts to the previous patch wrt sampling. But if it works, ok.

> ---
>  include/linux/mmzone.h |   2 +
>  mm/compaction.c        | 119 +++++++++++++++++++++++++++++++++++++++++--------
>  2 files changed, 102 insertions(+), 19 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index cc4a507d7ca4..faa1e6523f49 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -480,6 +480,8 @@ struct zone {
>  	unsigned long		compact_cached_free_pfn;
>  	/* pfn where async and sync compaction migration scanner should start */
>  	unsigned long		compact_cached_migrate_pfn[2];
> +	unsigned long		compact_init_migrate_pfn;
> +	unsigned long		compact_init_free_pfn;
>  #endif
>  
>  #ifdef CONFIG_COMPACTION
> diff --git a/mm/compaction.c b/mm/compaction.c
> index cc532e81a7b7..7f316e1a7275 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -231,6 +231,62 @@ static bool pageblock_skip_persistent(struct page *page)
>  	return false;
>  }
>  
> +static bool
> +__reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
> +							bool check_target)
> +{
> +	struct page *page = pfn_to_online_page(pfn);
> +	struct page *end_page;
> +
> +	if (!page)
> +		return false;
> +	if (zone != page_zone(page))
> +		return false;
> +	if (pageblock_skip_persistent(page))
> +		return false;
> +
> +	/*
> +	 * If skip is already cleared do no further checking once the
> +	 * restart points have been set.
> +	 */
> +	if (check_source && check_target && !get_pageblock_skip(page))
> +		return true;
> +
> +	/*
> +	 * If clearing skip for the target scanner, do not select a
> +	 * non-movable pageblock as the starting point.
> +	 */
> +	if (!check_source && check_target &&
> +	    get_pageblock_migratetype(page) != MIGRATE_MOVABLE)
> +		return false;
> +
> +	/*
> +	 * Only clear the hint if a sample indicates there is either a
> +	 * free page or an LRU page in the block. One or other condition
> +	 * is necessary for the block to be a migration source/target.
> +	 */
> +	page = pfn_to_page(pageblock_start_pfn(pfn));
> +	if (zone != page_zone(page))
> +		return false;
> +	end_page = page + pageblock_nr_pages;

Watch out for start pfn being invalid, and end_page being invalid or after zone end?

> +
> +	do {
> +		if (check_source && PageLRU(page)) {
> +			clear_pageblock_skip(page);
> +			return true;
> +		}
> +
> +		if (check_target && PageBuddy(page)) {
> +			clear_pageblock_skip(page);
> +			return true;
> +		}
> +
> +		page += (1 << PAGE_ALLOC_COSTLY_ORDER);

Also probably check pfn_valid_within() and page_zone?

> +	} while (page < end_page);
> +
> +	return false;
> +}
> +
>  /*
>   * This function is called to clear all cached information on pageblocks that
>   * should be skipped for page isolation when the migrate and free page scanner

...

> @@ -1193,7 +1273,7 @@ fast_isolate_freepages(struct compact_control *cc)
>  	 * If starting the scan, use a deeper search and use the highest
>  	 * PFN found if a suitable one is not found.
>  	 */
> -	if (cc->free_pfn == pageblock_start_pfn(zone_end_pfn(cc->zone) - 1)) {
> +	if (cc->free_pfn >= cc->zone->compact_init_free_pfn) {
>  		limit = pageblock_nr_pages >> 1;
>  		scan_start = true;
>  	}
> @@ -1338,7 +1418,6 @@ static void isolate_freepages(struct compact_control *cc)
>  	unsigned long isolate_start_pfn; /* exact pfn we start at */
>  	unsigned long block_end_pfn;	/* end of current pageblock */
>  	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
> -	unsigned long nr_isolated;
>  	struct list_head *freelist = &cc->freepages;
>  	unsigned int stride;
>  
> @@ -1374,6 +1453,8 @@ static void isolate_freepages(struct compact_control *cc)
>  				block_end_pfn = block_start_pfn,
>  				block_start_pfn -= pageblock_nr_pages,
>  				isolate_start_pfn = block_start_pfn) {
> +		unsigned long nr_isolated;

Unrelated cleanup? Nevermind.

>  		/*
>  		 * This can iterate a massively long zone without finding any
>  		 * suitable migration targets, so periodically check resched.
> @@ -2020,7 +2101,7 @@ static enum compact_result compact_zone(struct compact_control *cc)
>  			cc->zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
>  		}
>  
> -		if (cc->migrate_pfn == start_pfn)
> +		if (cc->migrate_pfn <= cc->zone->compact_init_migrate_pfn)
>  			cc->whole_zone = true;
>  	}
>  
> 
