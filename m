Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id CAE366B025A
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 12:15:05 -0500 (EST)
Received: by wmww144 with SMTP id w144so73404335wmw.0
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 09:15:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s3si7059481wmb.30.2015.12.04.09.15.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 04 Dec 2015 09:15:04 -0800 (PST)
Subject: Re: [PATCH v3 5/7] mm/compaction: respect compaction order when
 updating defer counter
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1449126681-19647-6-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5661CA16.9010304@suse.cz>
Date: Fri, 4 Dec 2015 18:15:02 +0100
MIME-Version: 1.0
In-Reply-To: <1449126681-19647-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/03/2015 08:11 AM, Joonsoo Kim wrote:
> It doesn't make sense that we reset defer counter
> in compaction_defer_reset() when compaction request under the order of
> compact_order_failed succeed. Fix it.

Right.

> And, it does make sense that giving enough chance for updated failed
> order compaction before deferring. Change it.

Sorry, can't understand the meaning here. From the code it seems that 
you want to reset defer_shift to 0 instead of increasing it, when the 
current order is lower than the failed one? That makes sense, yeah.
How about this?

"On the other hand, when deferring compaction for an order lower than 
the current compact_order_failed, we can assume the lower order will 
recover more quickly, so we should reset the progress made previously on 
compact_defer_shift with the higher order."

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/compaction.c | 19 +++++++++++--------
>   1 file changed, 11 insertions(+), 8 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 67b8d90..1a75a6e 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -126,11 +126,14 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
>    */
>   static void defer_compaction(struct zone *zone, int order)
>   {
> -	zone->compact_considered = 0;
> -	zone->compact_defer_shift++;
> -
> -	if (order < zone->compact_order_failed)
> +	if (order < zone->compact_order_failed) {
> +		zone->compact_considered = 0;
> +		zone->compact_defer_shift = 0;
>   		zone->compact_order_failed = order;
> +	} else {
> +		zone->compact_considered = 0;
> +		zone->compact_defer_shift++;
> +	}
>
>   	if (zone->compact_defer_shift > COMPACT_MAX_DEFER_SHIFT)
>   		zone->compact_defer_shift = COMPACT_MAX_DEFER_SHIFT;
> @@ -161,11 +164,11 @@ bool compaction_deferred(struct zone *zone, int order)
>   /* Update defer tracking counters after successful compaction of given order */
>   static void compaction_defer_reset(struct zone *zone, int order)
>   {
> -	zone->compact_considered = 0;
> -	zone->compact_defer_shift = 0;
> -
> -	if (order >= zone->compact_order_failed)
> +	if (order >= zone->compact_order_failed) {
> +		zone->compact_considered = 0;
> +		zone->compact_defer_shift = 0;
>   		zone->compact_order_failed = order + 1;
> +	}
>
>   	trace_mm_compaction_defer_reset(zone, order);
>   }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
