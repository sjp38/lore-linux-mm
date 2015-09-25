Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF466B0254
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 04:04:53 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so8836778wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 01:04:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hf9si3273014wjc.36.2015.09.25.01.04.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Sep 2015 01:04:52 -0700 (PDT)
Subject: Re: [PATCH v2 2/9] mm/compaction: introduce compaction depleted state
 on zone
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1440382773-16070-3-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56050021.50608@suse.cz>
Date: Fri, 25 Sep 2015 10:04:49 +0200
MIME-Version: 1.0
In-Reply-To: <1440382773-16070-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/24/2015 04:19 AM, Joonsoo Kim wrote:
> Further compaction attempt is deferred when some of compaction attempts
> already fails. But, after some number of trial are skipped, compaction
> restarts work to check whether compaction is now possible or not. It
> scans whole range of zone to determine this possibility and if compaction
> possibility doesn't recover, this whole range scan is quite big overhead.
> As a first step to reduce this overhead, this patch implement compaction
> depleted state on zone.
> 
> The way to determine depletion of compaction possility is checking number
> of success on previous compaction attempt. If number of successful
> compaction is below than specified threshold, we guess that compaction
> will not successful next time so mark the zone as compaction depleted.
> In this patch, threshold is choosed by 1 to imitate current compaction
> deferring algorithm. In the following patch, compaction algorithm will be
> changed and this threshold is also adjusted to that change.
> 
> In this patch, only state definition is implemented. There is no action
> for this new state so no functional change. But, following patch will
> add some handling for this new state.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/mmzone.h |  3 +++
>  mm/compaction.c        | 44 +++++++++++++++++++++++++++++++++++++++++---
>  2 files changed, 44 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 754c259..700e9b5 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -517,6 +517,8 @@ struct zone {
>  	unsigned int		compact_considered;
>  	unsigned int		compact_defer_shift;
>  	int			compact_order_failed;
> +	unsigned long		compact_success;
> +	unsigned long		compact_depletion_depth;
>  #endif
>  
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> @@ -543,6 +545,7 @@ enum zone_flags {
>  					 * many pages under writeback
>  					 */
>  	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
> +	ZONE_COMPACTION_DEPLETED,	/* compaction possiblity depleted */
>  };
>  
>  static inline unsigned long zone_end_pfn(const struct zone *zone)
> diff --git a/mm/compaction.c b/mm/compaction.c
> index c2d3d6a..de96e9d 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -129,6 +129,23 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
>  
>  /* Do not skip compaction more than 64 times */
>  #define COMPACT_MAX_DEFER_SHIFT 6
> +#define COMPACT_MIN_DEPLETE_THRESHOLD 1UL
> +
> +static bool compaction_depleted(struct zone *zone)
> +{
> +	unsigned long threshold;
> +	unsigned long success = zone->compact_success;
> +
> +	/*
> +	 * Now, to imitate current compaction deferring approach,
> +	 * choose threshold to 1. It will be changed in the future.
> +	 */
> +	threshold = COMPACT_MIN_DEPLETE_THRESHOLD;
> +	if (success >= threshold)
> +		return false;
> +
> +	return true;
> +}
>  
>  /*
>   * Compaction is deferred when compaction fails to result in a page
> @@ -223,6 +240,16 @@ static void __reset_isolation_suitable(struct zone *zone)
>  	zone->compact_cached_free_pfn = end_pfn;
>  	zone->compact_blockskip_flush = false;
>  
> +	if (compaction_depleted(zone)) {
> +		if (test_bit(ZONE_COMPACTION_DEPLETED, &zone->flags))
> +			zone->compact_depletion_depth++;
> +		else {
> +			set_bit(ZONE_COMPACTION_DEPLETED, &zone->flags);
> +			zone->compact_depletion_depth = 0;
> +		}
> +	}
> +	zone->compact_success = 0;

It's possible that the following comment is made moot by further patches, but:

I assume doing this in __reset_isolation_suitable() is to react on the
compaction_restarting() state. But __reset_isolation_suitable() is called also
from manually invoked compaction, and from kswapd. What if compaction has
succeeded S times, but threshold is T, S < T and T is larger than 1 (by a later
patch). Then kswapd or manual compaction will reset S to zero, without giving it
chance to reach T, even when compaction would succeed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
