Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20B4C6B0289
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 00:04:36 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t83so247589181oie.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 21:04:36 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id q2si4468542ota.230.2016.09.22.21.04.33
        for <linux-mm@kvack.org>;
        Thu, 22 Sep 2016 21:04:34 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20160906135258.18335-1-vbabka@suse.cz> <20160906135258.18335-3-vbabka@suse.cz> <20160921171348.GF24210@dhcp22.suse.cz> <f1670976-b4da-5d2c-0a85-37f9a87d6868@suse.cz> <20160922140821.GG11875@dhcp22.suse.cz> <20160922145237.GH11875@dhcp22.suse.cz> <1f47ebe3-61bc-ba8a-defb-9fd8e78614d7@suse.cz>
In-Reply-To: <1f47ebe3-61bc-ba8a-defb-9fd8e78614d7@suse.cz>
Subject: Re: [PATCH 2/4] mm, compaction: more reliably increase direct compaction priority
Date: Fri, 23 Sep 2016 12:04:15 +0800
Message-ID: <005b01d2154f$8d38b830$a7aa2890$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>, 'Michal Hocko' <mhocko@kernel.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Arkadiusz Miskiewicz' <a.miskiewicz@gmail.com>, 'Ralf-Peter Rohbeck' <Ralf-Peter.Rohbeck@quantum.com>, 'Olaf Hering' <olaf@aepfle.de>, linux-kernel@vger.kernel.org, 'Linus Torvalds' <torvalds@linux-foundation.org>, linux-mm@kvack.org, 'Mel Gorman' <mgorman@techsingularity.net>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, 'David Rientjes' <rientjes@google.com>, 'Rik van Riel' <riel@redhat.com>

> 
> ----8<----
> From a7921e57ba1189b9c08fc4879358a908c390e47c Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Thu, 22 Sep 2016 17:02:37 +0200
> Subject: [PATCH] mm, page_alloc: pull no_progress_loops update to
>  should_reclaim_retry()
> 
> The should_reclaim_retry() makes decisions based on no_progress_loops, so it
> makes sense to also update the counter there. It will be also consistent with
> should_compact_retry() and compaction_retries. No functional change.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/page_alloc.c | 28 ++++++++++++++--------------
>  1 file changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 582820080601..a01359ab3ed6 100644
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
> +		no_progress_loops = 0;

s/no/*no/
> +	else
> +		no_progress_loops++;

s/no_progress_loops/(*no_progress_loops)/

With that feel free to add
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
