Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E93FC280273
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 16:15:08 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id n4so106946400lfb.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:15:08 -0700 (PDT)
Received: from mail-lf0-f67.google.com (mail-lf0-f67.google.com. [209.85.215.67])
        by mx.google.com with ESMTPS id e6si7997246lfg.167.2016.09.26.13.15.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 13:15:07 -0700 (PDT)
Received: by mail-lf0-f67.google.com with SMTP id s29so10758299lfg.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:15:07 -0700 (PDT)
Date: Mon, 26 Sep 2016 22:15:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] mm, compaction: ignore fragindex from
 compaction_zonelist_suitable()
Message-ID: <20160926201503.GB23827@dhcp22.suse.cz>
References: <20160926162025.21555-1-vbabka@suse.cz>
 <20160926162025.21555-4-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160926162025.21555-4-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

On Mon 26-09-16 18:20:24, Vlastimil Babka wrote:
> The compaction_zonelist_suitable() function tries to determine if compaction
> will be able to proceed after sufficient reclaim, i.e. whether there are
> enough reclaimable pages to provide enough order-0 freepages for compaction.
> 
> This addition of reclaimable pages to the free pages works well for the order-0
> watermark check, but in the fragmentation index check we only consider truly
> free pages. Thus we can get fragindex value close to 0 which indicates failure
> do to lack of memory, and wrongly decide that compaction won't be suitable even
> after reclaim.
> 
> Instead of trying to somehow adjust fragindex for reclaimable pages, let's just
> skip it from compaction_zonelist_suitable().

Yes this makes a lot of sense to me. The fragidx should be mostly about
a balance between reclaim and the compaction so it shouldn't be used for
fail or retry decisions.

> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/compaction.c | 35 ++++++++++++++++++-----------------
>  1 file changed, 18 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 86d4d0bbfc7c..5ff7f801c345 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1379,7 +1379,6 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
>  					int classzone_idx,
>  					unsigned long wmark_target)
>  {
> -	int fragindex;
>  	unsigned long watermark;
>  
>  	if (is_via_compact_memory(order))
> @@ -1415,6 +1414,18 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
>  						ALLOC_CMA, wmark_target))
>  		return COMPACT_SKIPPED;
>  
> +	return COMPACT_CONTINUE;
> +}
> +
> +enum compact_result compaction_suitable(struct zone *zone, int order,
> +					unsigned int alloc_flags,
> +					int classzone_idx)
> +{
> +	enum compact_result ret;
> +	int fragindex;
> +
> +	ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx,
> +				    zone_page_state(zone, NR_FREE_PAGES));
>  	/*
>  	 * fragmentation index determines if allocation failures are due to
>  	 * low memory or external fragmentation
> @@ -1426,21 +1437,12 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
>  	 *
>  	 * Only compact if a failure would be due to fragmentation.
>  	 */
> -	fragindex = fragmentation_index(zone, order);
> -	if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
> -		return COMPACT_NOT_SUITABLE_ZONE;
> -
> -	return COMPACT_CONTINUE;
> -}
> -
> -enum compact_result compaction_suitable(struct zone *zone, int order,
> -					unsigned int alloc_flags,
> -					int classzone_idx)
> -{
> -	enum compact_result ret;
> +	if (ret == COMPACT_CONTINUE) {
> +		fragindex = fragmentation_index(zone, order);
> +		if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
> +			return COMPACT_NOT_SUITABLE_ZONE;
> +	}
>  
> -	ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx,
> -				    zone_page_state(zone, NR_FREE_PAGES));
>  	trace_mm_compaction_suitable(zone, order, ret);
>  	if (ret == COMPACT_NOT_SUITABLE_ZONE)
>  		ret = COMPACT_SKIPPED;
> @@ -1473,8 +1475,7 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
>  		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
>  		compact_result = __compaction_suitable(zone, order, alloc_flags,
>  				ac_classzone_idx(ac), available);
> -		if (compact_result != COMPACT_SKIPPED &&
> -				compact_result != COMPACT_NOT_SUITABLE_ZONE)
> +		if (compact_result != COMPACT_SKIPPED)
>  			return true;
>  	}
>  
> -- 
> 2.10.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
