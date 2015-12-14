Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id B96E66B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 04:34:53 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p66so52826076wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 01:34:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cc7si44703441wjc.74.2015.12.14.01.34.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Dec 2015 01:34:52 -0800 (PST)
Subject: Re: [PATCH v3 6/7] mm/compaction: introduce migration scan limit
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1449126681-19647-7-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <566E8D3A.5030804@suse.cz>
Date: Mon, 14 Dec 2015 10:34:50 +0100
MIME-Version: 1.0
In-Reply-To: <1449126681-19647-7-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/03/2015 08:11 AM, Joonsoo Kim wrote:
> This is preparation step to replace compaction deferring with compaction
> limit. Whole reason why we need to replace it will be mentioned in
> the following patch.
>
> In this patch, migration_scan_limit is assigned and accounted, but, not
> checked to finish. So, there is no functional change.
>
> Currently, amount of migration_scan_limit is chosen to imitate compaction
> deferring logic. We can tune it easily if overhead looks insane, but,
> it would be further work.
> Also, amount of migration_scan_limit is adapted by compact_defer_shift.
> More fails increase compact_defer_shift and this will limit compaction
> more.
>
> There are two interesting changes. One is that cached pfn is always
> updated while limit is activated. Otherwise, we would scan same range
> over and over. Second one is that async compaction is skipped while
> limit is activated, for algorithm correctness. Until now, even if
> failure case, sync compaction continue to work when both scanner is met
> so COMPACT_COMPLETE usually happens in sync compaction. But, limit is
> applied, sync compaction is finished if limit is exhausted so
> COMPACT_COMPLETE usually happens in async compaction. Because we don't
> consider async COMPACT_COMPLETE as actual fail while we reset cached
> scanner pfn

I don't see where compaction being sync/async applies to "reset cached 
scanner pfn". I assume you actually meant the call to defer_compaction() 
in try_to_compact_pages, which only happens for async compaction?

> defer mechanism doesn't work well. And, async compaction
> would not be easy to succeed in this case so skipping async compaction
> doesn't result in much difference.

So, the alternative to avoiding async compaction would be to call 
defer_compaction() also when async compaction completes, right? Which 
doesn't sound as scary when deferring isn't an on/off thing, but applies 
a limit.

This would also help the issue with THP fault compactions being only 
async and thus never deferring anything, which I think showed itself in 
Aaron's reports. This current patch wouldn't help there I think, as 
without sync compaction the system would never start to apply the limit 
in the first place, and would be stuck with the ill-defined contended 
compaction detection based on need_resched etc.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/compaction.c | 88 +++++++++++++++++++++++++++++++++++++++++++++++++--------
>   mm/internal.h   |  1 +
>   2 files changed, 78 insertions(+), 11 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 1a75a6e..b23f6d9 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -116,6 +116,67 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
>
>   #ifdef CONFIG_COMPACTION
>
> +/*
> + * order == -1 is expected when compacting via
> + * /proc/sys/vm/compact_memory
> + */
> +static inline bool is_via_compact_memory(int order)
> +{
> +	return order == -1;
> +}
> +
> +#define COMPACT_MIN_SCAN_LIMIT (pageblock_nr_pages)
> +
> +static bool excess_migration_scan_limit(struct compact_control *cc)
> +{
> +	/* Disable scan limit for now */
> +	return false;
> +}
> +
> +static void set_migration_scan_limit(struct compact_control *cc)
> +{
> +	struct zone *zone = cc->zone;
> +	int order = cc->order;
> +	unsigned long limit = zone->managed_pages;
> +
> +	cc->migration_scan_limit = LONG_MAX;
> +	if (is_via_compact_memory(order))
> +		return;
> +
> +	if (order < zone->compact_order_failed)
> +		return;
> +
> +	if (!zone->compact_defer_shift)
> +		return;
> +
> +	/*
> +	 * Do not allow async compaction during limit work. In this case,
> +	 * async compaction would not be easy to succeed and we need to
> +	 * ensure that COMPACT_COMPLETE occurs by sync compaction for
> +	 * algorithm correctness and prevention of async compaction will
> +	 * lead it.
> +	 */
> +	if (cc->mode == MIGRATE_ASYNC) {
> +		cc->migration_scan_limit = -1;
> +		return;
> +	}
> +
> +	/* Migration scanner usually scans less than 1/4 pages */
> +	limit >>= 2;
> +
> +	/*
> +	 * Deferred compaction restart compaction every 64 compaction
> +	 * attempts and it rescans whole zone range. To imitate it,
> +	 * we set limit to 1/64 of scannable range.
> +	 */
> +	limit >>= 6;
> +
> +	/* Degradation scan limit according to defer shift */
> +	limit >>= zone->compact_defer_shift;
> +
> +	cc->migration_scan_limit = max(limit, COMPACT_MIN_SCAN_LIMIT);
> +}
> +
>   /* Do not skip compaction more than 64 times */
>   #define COMPACT_MAX_DEFER_SHIFT 6
>
> @@ -263,10 +324,15 @@ static void update_pageblock_skip(struct compact_control *cc,
>   	if (!page)
>   		return;
>
> -	if (nr_isolated)
> +	/*
> +	 * Always update cached_pfn if compaction has scan_limit,
> +	 * otherwise we would scan same range over and over.
> +	 */
> +	if (cc->migration_scan_limit == LONG_MAX && nr_isolated)
>   		return;
>
> -	set_pageblock_skip(page);
> +	if (!nr_isolated)
> +		set_pageblock_skip(page);
>
>   	/* Update where async and sync compaction should restart */
>   	if (migrate_scanner) {
> @@ -822,6 +888,8 @@ isolate_success:
>   	if (locked)
>   		spin_unlock_irqrestore(&zone->lru_lock, flags);
>
> +	cc->migration_scan_limit -= nr_scanned;
> +
>   	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
>   						nr_scanned, nr_isolated);
>
> @@ -1186,15 +1254,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>   	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
>   }
>
> -/*
> - * order == -1 is expected when compacting via
> - * /proc/sys/vm/compact_memory
> - */
> -static inline bool is_via_compact_memory(int order)
> -{
> -	return order == -1;
> -}
> -
>   static int __compact_finished(struct zone *zone, struct compact_control *cc,
>   			    const int migratetype)
>   {
> @@ -1224,6 +1283,9 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
>   	if (is_via_compact_memory(cc->order))
>   		return COMPACT_CONTINUE;
>
> +	if (excess_migration_scan_limit(cc))
> +		return COMPACT_PARTIAL;
> +
>   	/* Compaction run is not finished if the watermark is not met */
>   	watermark = low_wmark_pages(zone);
>
> @@ -1382,6 +1444,10 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>   	}
>   	cc->last_migrated_pfn = 0;
>
> +	set_migration_scan_limit(cc);
> +	if (excess_migration_scan_limit(cc))
> +		return COMPACT_SKIPPED;
> +
>   	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn,
>   				cc->free_pfn, end_pfn, sync);
>
> diff --git a/mm/internal.h b/mm/internal.h
> index dbe0436..bb8225c 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -164,6 +164,7 @@ struct compact_control {
>   	unsigned long free_pfn;		/* isolate_freepages search base */
>   	unsigned long migrate_pfn;	/* isolate_migratepages search base */
>   	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
> +	long migration_scan_limit;      /* Limit migration scanner activity */
>   	enum migrate_mode mode;		/* Async or sync migration mode */
>   	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
>   	int order;			/* order a direct compactor needs */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
