Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 328BF828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 01:44:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so489729216pfa.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 22:44:01 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id xj8si2301180pab.203.2016.07.05.22.43.59
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 22:44:00 -0700 (PDT)
Date: Wed, 6 Jul 2016 14:47:23 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 13/17] mm, compaction: use correct watermark when
 checking allocation success
Message-ID: <20160706054722.GF23627@js1304-P5Q-DELUXE>
References: <20160624095437.16385-1-vbabka@suse.cz>
 <20160624095437.16385-14-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160624095437.16385-14-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Fri, Jun 24, 2016 at 11:54:33AM +0200, Vlastimil Babka wrote:
> The __compact_finished() function uses low watermark in a check that has to
> pass if the direct compaction is to finish and allocation should succeed. This
> is too pessimistic, as the allocation will typically use min watermark. It may
> happen that during compaction, we drop below the low watermark (due to parallel
> activity), but still form the target high-order page. By checking against low
> watermark, we might needlessly continue compaction.
> 
> Similarly, __compaction_suitable() uses low watermark in a check whether
> allocation can succeed without compaction. Again, this is unnecessarily
> pessimistic.
> 
> After this patch, these check will use direct compactor's alloc_flags to
> determine the watermark, which is effectively the min watermark.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/compaction.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 76897850c3c2..371760a85085 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1320,7 +1320,7 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
>  		return COMPACT_CONTINUE;
>  
>  	/* Compaction run is not finished if the watermark is not met */
> -	watermark = low_wmark_pages(zone);
> +	watermark = zone->watermark[cc->alloc_flags & ALLOC_WMARK_MASK];

finish condition is changed. We have two more watermark checks in
try_to_compact_pages() and kcompactd_do_work() and they should be
changed too.

Thanks.
>  
>  	if (!zone_watermark_ok(zone, cc->order, watermark, cc->classzone_idx,
>  							cc->alloc_flags))
> @@ -1385,7 +1385,7 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
>  	if (is_via_compact_memory(order))
>  		return COMPACT_CONTINUE;
>  
> -	watermark = low_wmark_pages(zone);
> +	watermark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
>  	/*
>  	 * If watermarks for high-order allocation are already met, there
>  	 * should be no need for compaction at all.
> @@ -1399,7 +1399,7 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
>  	 * This is because during migration, copies of pages need to be
>  	 * allocated and for a short time, the footprint is higher
>  	 */
> -	watermark += (2UL << order);
> +	watermark = low_wmark_pages(zone) + (2UL << order);
>  	if (!__zone_watermark_ok(zone, 0, watermark, classzone_idx,
>  				 alloc_flags, wmark_target))
>  		return COMPACT_SKIPPED;
> -- 
> 2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
