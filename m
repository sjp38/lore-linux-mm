Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id A957D6B0253
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 08:28:34 -0400 (EDT)
Received: by wieq12 with SMTP id q12so80668774wie.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 05:28:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lp12si29315514wic.50.2015.10.14.05.28.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Oct 2015 05:28:33 -0700 (PDT)
Subject: Re: [PATCH v2 9/9] mm/compaction: new threshold for compaction
 depleted zone
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1440382773-16070-10-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <561E4A6F.5070801@suse.cz>
Date: Wed, 14 Oct 2015 14:28:31 +0200
MIME-Version: 1.0
In-Reply-To: <1440382773-16070-10-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/24/2015 04:19 AM, Joonsoo Kim wrote:
> Now, compaction algorithm become powerful. Migration scanner traverses
> whole zone range. So, old threshold for depleted zone which is designed
> to imitate compaction deferring approach isn't appropriate for current
> compaction algorithm. If we adhere to current threshold, 1, we can't
> avoid excessive overhead caused by compaction, because one compaction
> for low order allocation would be easily successful in any situation.
> 
> This patch re-implements threshold calculation based on zone size and
> allocation requested order. We judge whther compaction possibility is
> depleted or not by number of successful compaction. Roughly, 1/100
> of future scanned area should be allocated for high order page during
> one comaction iteration in order to determine whether zone's compaction
> possiblity is depleted or not.

Finally finishing my review, sorry it took that long...

> Below is test result with following setup.
> 
> Memory is artificially fragmented to make order 3 allocation hard. And,
> most of pageblocks are changed to movable migratetype.
> 
>   System: 512 MB with 32 MB Zram
>   Memory: 25% memory is allocated to make fragmentation and 200 MB is
>   	occupied by memory hogger. Most pageblocks are movable
>   	migratetype.
>   Fragmentation: Successful order 3 allocation candidates may be around
>   	1500 roughly.
>   Allocation attempts: Roughly 3000 order 3 allocation attempts
>   	with GFP_NORETRY. This value is determined to saturate allocation
>   	success.
> 
> Test: hogger-frag-movable
> 
> Success(N)                    94              83
> compact_stall               3642            4048
> compact_success              144             212
> compact_fail                3498            3835
> pgmigrate_success       15897219          216387
> compact_isolated        31899553          487712
> compact_migrate_scanned 59146745         2513245
> compact_free_scanned    49566134         4124319

The decrease in scanned/isolated/migrated counts looks definitely nice, but why
did success regress when compact_success improved substantially?

> This change results in greatly decreasing compaction overhead when
> zone's compaction possibility is nearly depleted. But, I should admit
> that it's not perfect because compaction success rate is decreased.
> More precise tuning threshold would restore this regression, but,
> it highly depends on workload so I'm not doing it here.
> 
> Other test doesn't show big regression.
> 
>   System: 512 MB with 32 MB Zram
>   Memory: 25% memory is allocated to make fragmentation and kernel
>   	build is running on background. Most pageblocks are movable
>   	migratetype.
>   Fragmentation: Successful order 3 allocation candidates may be around
>   	1500 roughly.
>   Allocation attempts: Roughly 3000 order 3 allocation attempts
>   	with GFP_NORETRY. This value is determined to saturate allocation
>   	success.
> 
> Test: build-frag-movable
> 
> Success(N)                    89              87
> compact_stall               4053            3642
> compact_success              264             202
> compact_fail                3788            3440
> pgmigrate_success        6497642          153413
> compact_isolated        13292640          353445
> compact_migrate_scanned 69714502         2307433
> compact_free_scanned    20243121         2325295

Here compact_success decreased relatively a lot, while success just barely.
Less counterintuitive than the first result, but still a bit.

> This looks like reasonable trade-off.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/compaction.c | 19 ++++++++++++-------
>  1 file changed, 12 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index e61ee77..e1b44a5 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -129,19 +129,24 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
>  
>  /* Do not skip compaction more than 64 times */
>  #define COMPACT_MAX_FAILED 4
> -#define COMPACT_MIN_DEPLETE_THRESHOLD 1UL
> +#define COMPACT_MIN_DEPLETE_THRESHOLD 4UL
>  #define COMPACT_MIN_SCAN_LIMIT (pageblock_nr_pages)
>  
>  static bool compaction_depleted(struct zone *zone)
>  {
> -	unsigned long threshold;
> +	unsigned long nr_possible;
>  	unsigned long success = zone->compact_success;
> +	unsigned long threshold;
>  
> -	/*
> -	 * Now, to imitate current compaction deferring approach,
> -	 * choose threshold to 1. It will be changed in the future.
> -	 */
> -	threshold = COMPACT_MIN_DEPLETE_THRESHOLD;
> +	nr_possible = zone->managed_pages >> zone->compact_order_failed;
> +
> +	/* Migration scanner normally scans less than 1/4 range of zone */
> +	nr_possible >>= 2;
> +
> +	/* We hope to succeed more than 1/100 roughly */
> +	threshold = nr_possible >> 7;
> +
> +	threshold = max(threshold, COMPACT_MIN_DEPLETE_THRESHOLD);
>  	if (success >= threshold)
>  		return false;

I wonder if compact_depletion_depth should play some "positive" role here. The
bigger the depth, the lower the migration_scan_limit, which means higher chance
of failing and so on. Ideally, the system should stabilize itself, so that
migration_scan_limit is set based how many pages on average have to be scanned
to succeed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
