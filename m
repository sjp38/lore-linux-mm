Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE7B16B0278
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 04:23:14 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l138so9804177wmg.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:23:14 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id xy1si6421549wjc.198.2016.09.23.01.23.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 01:23:13 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id l132so1502162wmf.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:23:13 -0700 (PDT)
Date: Fri, 23 Sep 2016 10:23:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160923082312.GD4478@dhcp22.suse.cz>
References: <20160906135258.18335-1-vbabka@suse.cz>
 <20160906135258.18335-3-vbabka@suse.cz>
 <20160921171348.GF24210@dhcp22.suse.cz>
 <f1670976-b4da-5d2c-0a85-37f9a87d6868@suse.cz>
 <20160922140821.GG11875@dhcp22.suse.cz>
 <20160922145237.GH11875@dhcp22.suse.cz>
 <1f47ebe3-61bc-ba8a-defb-9fd8e78614d7@suse.cz>
 <005b01d2154f$8d38b830$a7aa2890$@alibaba-inc.com>
 <98b0c783-28dc-62c4-5a94-74c9e27bebe0@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <98b0c783-28dc-62c4-5a94-74c9e27bebe0@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Arkadiusz Miskiewicz' <a.miskiewicz@gmail.com>, 'Ralf-Peter Rohbeck' <Ralf-Peter.Rohbeck@quantum.com>, 'Olaf Hering' <olaf@aepfle.de>, linux-kernel@vger.kernel.org, 'Linus Torvalds' <torvalds@linux-foundation.org>, linux-mm@kvack.org, 'Mel Gorman' <mgorman@techsingularity.net>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, 'David Rientjes' <rientjes@google.com>, 'Rik van Riel' <riel@redhat.com>

On Fri 23-09-16 08:55:33, Vlastimil Babka wrote:
[...]
> >From 1623d5bd441160569ffad3808aeeec852048e558 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Thu, 22 Sep 2016 17:02:37 +0200
> Subject: [PATCH] mm, page_alloc: pull no_progress_loops update to
>  should_reclaim_retry()
> 
> The should_reclaim_retry() makes decisions based on no_progress_loops, so it
> makes sense to also update the counter there. It will be also consistent with
> should_compact_retry() and compaction_retries. No functional change.
> 
> [hillf.zj@alibaba-inc.com: fix missing pointer dereferences]
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

OK, this looks reasonable to me. Could you post both patches in a
separate thread please? They shouldn't be really needed to mitigate the
pre-mature oom killer issues. Feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/page_alloc.c | 28 ++++++++++++++--------------
>  1 file changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 582820080601..6039ff40452c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3401,16 +3401,26 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  static inline bool
>  should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  		     struct alloc_context *ac, int alloc_flags,
> -		     bool did_some_progress, int no_progress_loops)
> +		     bool did_some_progress, int *no_progress_loops)
>  {
>  	struct zone *zone;
>  	struct zoneref *z;
>  
>  	/*
> +	 * Costly allocations might have made a progress but this doesn't mean
> +	 * their order will become available due to high fragmentation so
> +	 * always increment the no progress counter for them
> +	 */
> +	if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
> +		*no_progress_loops = 0;
> +	else
> +		(*no_progress_loops)++;
> +
> +	/*
>  	 * Make sure we converge to OOM if we cannot make any progress
>  	 * several times in the row.
>  	 */
> -	if (no_progress_loops > MAX_RECLAIM_RETRIES)
> +	if (*no_progress_loops > MAX_RECLAIM_RETRIES)
>  		return false;
>  
>  	/*
> @@ -3425,7 +3435,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  		unsigned long reclaimable;
>  
>  		available = reclaimable = zone_reclaimable_pages(zone);
> -		available -= DIV_ROUND_UP(no_progress_loops * available,
> +		available -= DIV_ROUND_UP((*no_progress_loops) * available,
>  					  MAX_RECLAIM_RETRIES);
>  		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
>  
> @@ -3641,18 +3651,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
>  		goto nopage;
>  
> -	/*
> -	 * Costly allocations might have made a progress but this doesn't mean
> -	 * their order will become available due to high fragmentation so
> -	 * always increment the no progress counter for them
> -	 */
> -	if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
> -		no_progress_loops = 0;
> -	else
> -		no_progress_loops++;
> -
>  	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
> -				 did_some_progress > 0, no_progress_loops))
> +				 did_some_progress > 0, &no_progress_loops))
>  		goto retry;
>  
>  	/*
> -- 
> 2.10.0
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
