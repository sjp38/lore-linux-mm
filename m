Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 971CE6B0257
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:16:27 -0500 (EST)
Received: by wmnn186 with SMTP id n186so38362437wmn.0
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 08:16:27 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id wk7si26381197wjb.244.2015.12.11.08.16.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 08:16:26 -0800 (PST)
Date: Fri, 11 Dec 2015 11:16:15 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
Message-ID: <20151211161615.GA5593@cmpxchg.org>
References: <1448974607-10208-1-git-send-email-mhocko@kernel.org>
 <1448974607-10208-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448974607-10208-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.com>

On Tue, Dec 01, 2015 at 01:56:45PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __alloc_pages_slowpath has traditionally relied on the direct reclaim
> and did_some_progress as an indicator that it makes sense to retry
> allocation rather than declaring OOM. shrink_zones had to rely on
> zone_reclaimable if shrink_zone didn't make any progress to prevent
> from a premature OOM killer invocation - the LRU might be full of dirty
> or writeback pages and direct reclaim cannot clean those up.
> 
> zone_reclaimable allows to rescan the reclaimable lists several
> times and restart if a page is freed. This is really subtle behavior
> and it might lead to a livelock when a single freed page keeps allocator
> looping but the current task will not be able to allocate that single
> page. OOM killer would be more appropriate than looping without any
> progress for unbounded amount of time.
> 
> This patch changes OOM detection logic and pulls it out from shrink_zone
> which is too low to be appropriate for any high level decisions such as OOM
> which is per zonelist property. It is __alloc_pages_slowpath which knows
> how many attempts have been done and what was the progress so far
> therefore it is more appropriate to implement this logic.
> 
> The new heuristic tries to be more deterministic and easier to follow.
> It builds on an assumption that retrying makes sense only if the
> currently reclaimable memory + free pages would allow the current
> allocation request to succeed (as per __zone_watermark_ok) at least for
> one zone in the usable zonelist.
> 
> This alone wouldn't be sufficient, though, because the writeback might
> get stuck and reclaimable pages might be pinned for a really long time
> or even depend on the current allocation context. Therefore there is a
> feedback mechanism implemented which reduces the reclaim target after
> each reclaim round without any progress. This means that we should
> eventually converge to only NR_FREE_PAGES as the target and fail on the
> wmark check and proceed to OOM. The backoff is simple and linear with
> 1/16 of the reclaimable pages for each round without any progress. We
> are optimistic and reset counter for successful reclaim rounds.
> 
> Costly high order pages mostly preserve their semantic and those without
> __GFP_REPEAT fail right away while those which have the flag set will
> back off after the amount of reclaimable pages reaches equivalent of the
> requested order. The only difference is that if there was no progress
> during the reclaim we rely on zone watermark check. This is more logical
> thing to do than previous 1<<order attempts which were a result of
> zone_reclaimable faking the progress.
> 
> [rientjes@google.com: use zone_page_state_snapshot for NR_FREE_PAGES]
> [rientjes@google.com: shrink_zones doesn't need to return anything]
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

This makes sense to me and the patch looks good. Just a few nitpicks.

Could you change the word "refactor" in the title? This is not a
non-functional change.

> @@ -2984,6 +2984,13 @@ static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
>  	return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
>  }
>  
> +/*
> + * Number of backoff steps for potentially reclaimable pages if the direct reclaim
> + * cannot make any progress. Each step will reduce 1/MAX_STALL_BACKOFF of the
> + * reclaimable memory.
> + */
> +#define MAX_STALL_BACKOFF 16

"stall backoff" is a fairly non-descript and doesn't give a good clue
at what exactly the variable is going to be doing.

How about MAX_DISCOUNT_RECLAIMABLE?

> @@ -3155,13 +3165,53 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (gfp_mask & __GFP_NORETRY)
>  		goto noretry;
>  
> -	/* Keep reclaiming pages as long as there is reasonable progress */
> +	/*
> +	 * Do not retry high order allocations unless they are __GFP_REPEAT
> +	 * and even then do not retry endlessly unless explicitly told so
> +	 */
>  	pages_reclaimed += did_some_progress;
> -	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
> -	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
> -		/* Wait for some write requests to complete then retry */
> -		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
> -		goto retry;
> +	if (order > PAGE_ALLOC_COSTLY_ORDER) {
> +		if (!(gfp_mask & __GFP_NOFAIL) &&
> +		   (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order)))
> +			goto noretry;
> +
> +		if (did_some_progress)
> +			goto retry;
> +	}

I'm a bit bothered by this change as goto noretry is not the inverse
of not doing goto retry: goto noretry jumps over _may_oom().

Of course, _may_oom() would filter a higher-order allocation anyway,
and we could say that it's such a fundamental concept that will never
change in the kernel that it's not a problem to repeat this clause
here. But you could probably say the same thing about not invoking OOM
for < ZONE_NORMAL, for !__GFP_FS, for __GFP_THISNODE, and I'm a bit
wary of these things spreading out of _may_oom() again after I just
put effort into consolidating all the OOM clauses in there.

It should be possible to keep the original branch and then nest the
decaying retry logic in there.

> +	/*
> +	 * Be optimistic and consider all pages on reclaimable LRUs as usable
> +	 * but make sure we converge to OOM if we cannot make any progress after
> +	 * multiple consecutive failed attempts.
> +	 */
> +	if (did_some_progress)
> +		stall_backoff = 0;
> +	else
> +		stall_backoff = min(stall_backoff+1, MAX_STALL_BACKOFF);

The rest of the backoff logic would be nasty to shift out by another
tab, but it could easily live in its own function.

In fact, the longer I think about it, it would probably be better for
__alloc_pages_slowpath anyway as that zonelist walk looks a bit too
low-level and unwieldy for the highlevel control flow function.

The outer control flow could look something like this:

	/* Do not loop if specifically requested */
	if (gfp_mask & __GFP_NORETRY)
		goto noretry;

	/* Keep reclaiming pages as long as there is reasonable progress */
	if (did_some_progress) {
		pages_reclaimed += did_some_progress;
		no_progress_loops = 0;
	} else {
		no_progress_loops++;
	}
	if (should_retry_reclaim(gfp_mask, order, ac, did_some_progress,
				 no_progress_loops, pages_reclaimed)) {
		/* Wait for some write requests to complete then retry */
		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
		goto retry;
	}

	/* Reclaim has failed us, start killing things */
	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
	if (page)
		goto got_pg;

	/* Retry as long as the OOM killer is making progress */
	if (did_some_progress) {
		no_progress_loops = 0;
		goto retry;
	}

noretry:

> +	/*
> +	 * Keep reclaiming pages while there is a chance this will lead somewhere.
> +	 * If none of the target zones can satisfy our allocation request even
> +	 * if all reclaimable pages are considered then we are screwed and have
> +	 * to go OOM.
> +	 */
> +	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx, ac->nodemask) {
> +		unsigned long free = zone_page_state_snapshot(zone, NR_FREE_PAGES);
> +		unsigned long target;
> +
> +		target = zone_reclaimable_pages(zone);
> +		target -= DIV_ROUND_UP(stall_backoff * target, MAX_STALL_BACKOFF);
> +		target += free;

target is also a little non-descript. Maybe available?

		available += zone_reclaimable_pages(zone);
		available -= DIV_ROUND_UP(discount_reclaimable * available,
					  MAX_DISCOUNT_RECLAIMABLE);
		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);

But yeah, this is mostly bikeshed territory now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
