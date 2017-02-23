Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4016B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 02:29:43 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id z61so11463336wrc.6
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 23:29:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u18si4902765wrd.248.2017.02.22.23.29.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 23:29:42 -0800 (PST)
Date: Thu, 23 Feb 2017 08:29:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm/vmscan: fix high cpu usage of kswapd if there
Message-ID: <20170223072938.6kff34eebtspv2fh@dhcp22.suse.cz>
References: <1487754288-5149-1-git-send-email-hejianet@gmail.com>
 <20170222201657.GA6534@cmpxchg.org>
 <20170222202406.GB6534@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170222202406.GB6534@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jia He <hejianet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Wed 22-02-17 15:24:06, Johannes Weiner wrote:
> On Wed, Feb 22, 2017 at 03:16:57PM -0500, Johannes Weiner wrote:
> > [...] And then it sounds pretty much like what the allocator/direct
> > reclaim already does.
> 
> On a side note: Michal, I'm not sure I fully understand why we need
> the backoff code in should_reclaim_retry(). If no_progress_loops is
> growing steadily, then we quickly reach 16 and bail anyway. Layering
> on top a backoff function that *might* cut out an iteration or two
> earlier in the cold path of an OOM situation seems unnecessary.
> Conversely, if there *are* intermittent reclaims, no_progress_loops
> gets reset straight to 0, which then also makes the backoff function
> jump back to square one. So in the only situation where backing off
> would make sense - making some progress, but not enough - it's not
> actually backing off. It seems to me it should be enough to bail after
> either 16 iterations or when free + reclaimable < watermark.

Hmm, yes you are right! I wanted to use this backoff to reduce chances
to trash over last remaining reclaimable pages. But the code evolved in
a way that this no longer works that way, as you say. I just got stuck
with the code without rethinking its relevance during the development.

That being said, I think we will eventually want some backoff logic for
those cases where we still make a little progress but not enough (e.g.
count the number of reclaimed pages and give up when we reach a portion
of available reclaimable memory), but the patch below is a good start to
make the code simpler. Feel free to add my Acked-by when posting a full
patch.

Thanks!

> 
> Hm?
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c470b8fe28cf..b0e9495c0530 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3396,11 +3396,10 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  /*
>   * Checks whether it makes sense to retry the reclaim to make a forward progress
>   * for the given allocation request.
> - * The reclaim feedback represented by did_some_progress (any progress during
> - * the last reclaim round) and no_progress_loops (number of reclaim rounds without
> - * any progress in a row) is considered as well as the reclaimable pages on the
> - * applicable zone list (with a backoff mechanism which is a function of
> - * no_progress_loops).
> + *
> + * We give up when we either have tried MAX_RECLAIM_RETRIES in a row
> + * without success, or when we couldn't even meet the watermark if we
> + * reclaimed all remaining pages on the LRU lists.
>   *
>   * Returns true if a retry is viable or false to enter the oom path.
>   */
> @@ -3441,13 +3440,11 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  		unsigned long reclaimable;
>  
>  		available = reclaimable = zone_reclaimable_pages(zone);
> -		available -= DIV_ROUND_UP((*no_progress_loops) * available,
> -					  MAX_RECLAIM_RETRIES);
>  		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
>  
>  		/*
> -		 * Would the allocation succeed if we reclaimed the whole
> -		 * available?
> +		 * Would the allocation succeed if we reclaimed all
> +		 * the reclaimable pages?
>  		 */
>  		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
>  				ac_classzone_idx(ac), alloc_flags, available)) {

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
