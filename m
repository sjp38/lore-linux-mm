Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id B0C9D6B0070
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 04:59:19 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so4222187wiv.7
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 01:59:19 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o6si47523393wjb.41.2014.12.08.01.59.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 01:59:18 -0800 (PST)
Message-ID: <54857675.5080400@suse.cz>
Date: Mon, 08 Dec 2014 10:59:17 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm/compaction: stop the isolation when we isolate
 enough freepage
References: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com> <1418022980-4584-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1418022980-4584-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On 12/08/2014 08:16 AM, Joonsoo Kim wrote:
> From: Joonsoo Kim <js1304@gmail.com>
>
> Currently, freepage isolation in one pageblock doesn't consider how many
> freepages we isolate. When I traced flow of compaction, compaction
> sometimes isolates more than 256 freepages to migrate just 32 pages.
>
> In this patch, freepage isolation is stopped at the point that we
> have more isolated freepage than isolated page for migration. This
> results in slowing down free page scanner and make compaction success
> rate higher.
>
> stress-highalloc test in mmtests with non movable order 7 allocation shows
> increase of compaction success rate and slight improvement of allocation
> success rate.
>
> Allocation success rate on phase 1 (%)
> 62.70 : 64.00
>
> Compaction success rate (Compaction success * 100 / Compaction stalls, %)
> 35.13 : 41.50

This is weird. I could maybe understand that isolating too many 
freepages and then returning them is a waste of time if compaction 
terminates immediately after the following migration (otherwise we would 
keep those free pages for the future migrations within same compaction 
run). And wasting time could reduce success rates for async compaction 
terminating prematurely due to cond_resched(), but that should be all 
the difference, unless there's another subtle bug, no?

> pfn where both scanners meets on compaction complete
> (separate test due to enormous tracepoint buffer)
> (zone_start=4096, zone_end=1048576)
> 586034 : 654378

The difference here suggests that there is indeed another subtle bug 
related to where free scanner restarts, and we must be leaving the 
excessively isolated (and then returned) freepages behind. Otherwise I 
think the scanners should meet at the same place regardless of your patch.

> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> ---
>   mm/compaction.c |   17 ++++++++++-------
>   1 file changed, 10 insertions(+), 7 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 2fd5f79..12223b9 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -422,6 +422,13 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>
>   		/* If a page was split, advance to the end of it */
>   		if (isolated) {
> +			cc->nr_freepages += isolated;
> +			if (!strict &&
> +				cc->nr_migratepages <= cc->nr_freepages) {
> +				blockpfn += isolated;
> +				break;
> +			}
> +
>   			blockpfn += isolated - 1;
>   			cursor += isolated - 1;
>   			continue;
> @@ -831,7 +838,6 @@ static void isolate_freepages(struct compact_control *cc)
>   	unsigned long isolate_start_pfn; /* exact pfn we start at */
>   	unsigned long block_end_pfn;	/* end of current pageblock */
>   	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
> -	int nr_freepages = cc->nr_freepages;
>   	struct list_head *freelist = &cc->freepages;
>
>   	/*
> @@ -856,11 +862,11 @@ static void isolate_freepages(struct compact_control *cc)
>   	 * pages on cc->migratepages. We stop searching if the migrate
>   	 * and free page scanners meet or enough free pages are isolated.
>   	 */
> -	for (; block_start_pfn >= low_pfn && cc->nr_migratepages > nr_freepages;
> +	for (; block_start_pfn >= low_pfn &&
> +			cc->nr_migratepages > cc->nr_freepages;
>   				block_end_pfn = block_start_pfn,
>   				block_start_pfn -= pageblock_nr_pages,
>   				isolate_start_pfn = block_start_pfn) {
> -		unsigned long isolated;
>
>   		/*
>   		 * This can iterate a massively long zone without finding any
> @@ -885,9 +891,8 @@ static void isolate_freepages(struct compact_control *cc)
>   			continue;
>
>   		/* Found a block suitable for isolating free pages from. */
> -		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
> +		isolate_freepages_block(cc, &isolate_start_pfn,
>   					block_end_pfn, freelist, false);
> -		nr_freepages += isolated;
>
>   		/*
>   		 * Remember where the free scanner should restart next time,
> @@ -919,8 +924,6 @@ static void isolate_freepages(struct compact_control *cc)
>   	 */
>   	if (block_start_pfn < low_pfn)
>   		cc->free_pfn = cc->migrate_pfn;
> -
> -	cc->nr_freepages = nr_freepages;
>   }
>
>   /*
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
