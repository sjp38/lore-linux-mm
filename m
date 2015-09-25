Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7C02C6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 05:33:44 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so12476472wic.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 02:33:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lc2si3667075wjb.25.2015.09.25.02.33.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Sep 2015 02:33:43 -0700 (PDT)
Subject: Re: [PATCH v2 4/9] mm/compaction: remove compaction deferring
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1440382773-16070-5-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <560514F2.2060407@suse.cz>
Date: Fri, 25 Sep 2015 11:33:38 +0200
MIME-Version: 1.0
In-Reply-To: <1440382773-16070-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/24/2015 04:19 AM, Joonsoo Kim wrote:
> Now, we have a way to determine compaction depleted state and compaction
> activity will be limited according this state and depletion depth so
> compaction overhead would be well controlled without compaction deferring.
> So, this patch remove compaction deferring completely and enable
> compaction activity limit.
> 
> Various functions are renamed and tracepoint outputs are changed due to
> this removing.

It's more like renaming "deferred" to "failed" and the whole result is somewhat
hard to follow, as the changelog doesn't describe a lot. So if I understand
correctly:
- compaction has to fail 4 times to cause __reset_isolation_suitable(), which
also resets the fail counter back to 0
- thus after each 4 failures, depletion depth is adjusted
- when successes cross the depletion threshold, compaction_depleted() becomes
false and then compact_zone will clear the flag
- with flag clear, scan limit is no longer applied at all, but depletion depth
stays as it is... it will be set to 0 when the flag is set again

Maybe the switch from "depleted with some depth" to "not depleted at all" could
be more gradual?
Also I have a suspicion that the main feature of this (IIUC) which is the scan
limiting (and which I do consider improvement! and IIRC David wished for
something like that too) could be achieved with less code churn that is renaming
"deferred" to "failed" and adding another "depleted" state. E.g.
compact_defer_shift looks similar to compact_depletion_depth, and deferring
could be repurposed for scan limiting instead of binary go/no-go decisions. BTW
the name "depleted" also suggests a binary state, so it's not that much better
name than "deferred" IMHO.

Also I think my objection from patch 2 stays - __reset_isolation_suitable()
called from kswapd will set zone->compact_success = 0, potentially increase
depletion depth etc, with no connection to the number of failed compactions.

[...]

> @@ -1693,13 +1667,13 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
>  		if (cc->order == -1)
>  			__reset_isolation_suitable(zone);
>  
> -		if (cc->order == -1 || !compaction_deferred(zone, cc->order))
> +		if (cc->order == -1)

This change means kswapd no longer compacts from balance_pgdat() ->
compact_pgdat(). Probably you meant to call compact_zone unconditionally here?

>  			compact_zone(zone, cc);
>  
>  		if (cc->order > 0) {
>  			if (zone_watermark_ok(zone, cc->order,
>  						low_wmark_pages(zone), 0, 0))
> -				compaction_defer_reset(zone, cc->order, false);
> +				compaction_failed_reset(zone, cc->order, false);
>  		}
>  
>  		VM_BUG_ON(!list_empty(&cc->freepages));
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0e9cc98..c67f853 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2827,7 +2827,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  		struct zone *zone = page_zone(page);
>  
>  		zone->compact_blockskip_flush = false;
> -		compaction_defer_reset(zone, order, true);
> +		compaction_failed_reset(zone, order, true);
>  		count_vm_event(COMPACTSUCCESS);
>  		return page;
>  	}
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 37e90db..a561b5f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2469,10 +2469,10 @@ static inline bool compaction_ready(struct zone *zone, int order)
>  	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0, 0);
>  
>  	/*
> -	 * If compaction is deferred, reclaim up to a point where
> +	 * If compaction is depleted, reclaim up to a point where
>  	 * compaction will have a chance of success when re-enabled
>  	 */
> -	if (compaction_deferred(zone, order))
> +	if (test_bit(ZONE_COMPACTION_DEPLETED, &zone->flags))
>  		return watermark_ok;

Hm this is a deviation from the "replace go/no-go with scan limit" principle.
Also compaction_deferred() could recover after some retries, and this flag won't.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
