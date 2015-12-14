Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8F7FA6B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 05:29:56 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id n186so111491702wmn.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 02:29:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x5si44928243wjx.154.2015.12.14.02.29.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Dec 2015 02:29:55 -0800 (PST)
Subject: Re: [PATCH 2/2] mm/compaction: speed up pageblock_pfn_to_page() when
 zone is contiguous
References: <1450069341-28875-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1450069341-28875-2-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <566E9A21.9000503@suse.cz>
Date: Mon, 14 Dec 2015 11:29:53 +0100
MIME-Version: 1.0
In-Reply-To: <1450069341-28875-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/14/2015 06:02 AM, Joonsoo Kim wrote:
> There is a performance drop report due to hugepage allocation and in there
> half of cpu time are spent on pageblock_pfn_to_page() in compaction [1].
> In that workload, compaction is triggered to make hugepage but most of
> pageblocks are un-available for compaction due to pageblock type and
> skip bit so compaction usually fails. Most costly operations in this case
> is to find valid pageblock while scanning whole zone range. To check
> if pageblock is valid to compact, valid pfn within pageblock is required
> and we can obtain it by calling pageblock_pfn_to_page(). This function
> checks whether pageblock is in a single zone and return valid pfn
> if possible. Problem is that we need to check it every time before
> scanning pageblock even if we re-visit it and this turns out to
> be very expensive in this workload.

Hm I wonder if this is safe wrt memory hotplug? Shouldn't there be a 
rechecking plugged into the appropriate hotplug add/remove callbacks? 
Which would make the whole thing generic too, zone->contiguous 
information doesn't have to be limited to compaction. And it would 
remove the rather ugly part where cached pfn info is used as an 
indication of zone->contiguous being already set...

> Although we have no way to skip this pageblock check in the system
> where hole exists at arbitrary position, we can use cached value for
> zone continuity and just do pfn_to_page() in the system where hole doesn't
> exist. This optimization considerably speeds up in above workload.
>
> Before vs After
> Max: 1096 MB/s vs 1325 MB/s
> Min: 635 MB/s 1015 MB/s
> Avg: 899 MB/s 1194 MB/s
>
> Avg is improved by roughly 30% [2].

Unless I'm mistaken, these results also include my RFC series (Aaron can 
you clarify?). These patches should better be tested standalone on top 
of base, as being simpler they will probably be included sooner (the RFC 
series needs reviews at the very least :) - although the memory hotplug 
concerns might make the "sooner" here relative too.

Anyway it's interesting that this patch improved "Min", and variance in 
general (on top of my RFC) so much. I would expect the overhead of 
pageblock_pfn_to_page() to be quite stable, hmm.

> Not to disturb the system where compaction isn't triggered, checking will
> be done at first compaction invocation.
>
> [1]: http://www.spinics.net/lists/linux-mm/msg97378.html
> [2]: https://lkml.org/lkml/2015/12/9/23
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   include/linux/mmzone.h |  1 +
>   mm/compaction.c        | 49 ++++++++++++++++++++++++++++++++++++++++++++++++-
>   2 files changed, 49 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 68cc063..cd3736e 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -521,6 +521,7 @@ struct zone {
>   #if defined CONFIG_COMPACTION || defined CONFIG_CMA
>   	/* Set to true when the PG_migrate_skip bits should be cleared */
>   	bool			compact_blockskip_flush;
> +	bool			contiguous;
>   #endif
>
>   	ZONE_PADDING(_pad3_)
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 56fa321..ce60b38 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -88,7 +88,7 @@ static inline bool migrate_async_suitable(int migratetype)
>    * the first and last page of a pageblock and avoid checking each individual
>    * page in a pageblock.
>    */
> -static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> +static struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
>   				unsigned long end_pfn, struct zone *zone)
>   {
>   	struct page *start_page;
> @@ -114,6 +114,51 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
>   	return start_page;
>   }
>
> +static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> +				unsigned long end_pfn, struct zone *zone)
> +{
> +	if (zone->contiguous)
> +		return pfn_to_page(start_pfn);
> +
> +	return __pageblock_pfn_to_page(start_pfn, end_pfn, zone);
> +}
> +
> +static void check_zone_contiguous(struct zone *zone)
> +{
> +	unsigned long block_start_pfn = zone->zone_start_pfn;
> +	unsigned long block_end_pfn;
> +	unsigned long pfn;
> +
> +	/* Already initialized if cached pfn is non-zero */
> +	if (zone->compact_cached_migrate_pfn[0] ||
> +		zone->compact_cached_free_pfn)
> +		return;
> +
> +	/* Mark that checking is in progress */
> +	zone->compact_cached_free_pfn = ULONG_MAX;
> +
> +	block_end_pfn = ALIGN(block_start_pfn + 1, pageblock_nr_pages);
> +	for (; block_start_pfn < zone_end_pfn(zone);
> +		block_start_pfn = block_end_pfn,
> +		block_end_pfn += pageblock_nr_pages) {
> +
> +		block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
> +
> +		if (!__pageblock_pfn_to_page(block_start_pfn,
> +					block_end_pfn, zone))
> +			return;
> +
> +		/* Check validity of pfn within pageblock */
> +		for (pfn = block_start_pfn; pfn < block_end_pfn; pfn++) {
> +			if (!pfn_valid_within(pfn))
> +				return;
> +		}
> +	}
> +
> +	/* We confirm that there is no hole */
> +	zone->contiguous = true;
> +}
> +
>   #ifdef CONFIG_COMPACTION
>
>   /* Do not skip compaction more than 64 times */
> @@ -1357,6 +1402,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>   		;
>   	}
>
> +	check_zone_contiguous(zone);
> +
>   	/*
>   	 * Clear pageblock skip if there were failures recently and compaction
>   	 * is about to be retried after being deferred. kswapd does not do
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
