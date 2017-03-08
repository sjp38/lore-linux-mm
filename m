Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 17CAF831D3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 06:23:58 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id d2so39435178oif.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 03:23:58 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r74si1402502ota.326.2017.03.08.03.23.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 03:23:56 -0800 (PST)
Subject: Re: [RFC PATCH 3/4] xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-4-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <e7f932bf-313a-917d-6304-81528aca5994@I-love.SAKURA.ne.jp>
Date: Wed, 8 Mar 2017 20:23:37 +0900
MIME-Version: 1.0
In-Reply-To: <20170307154843.32516-4-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Darrick J. Wong" <darrick.wong@oracle.com>

On 2017/03/08 0:48, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> KM_MAYFAIL didn't have any suitable GFP_FOO counterpart until recently
> so it relied on the default page allocator behavior for the given set
> of flags. This means that small allocations actually never failed.
> 
> Now that we have __GFP_RETRY_MAYFAIL flag which works independently on the
> allocation request size we can map KM_MAYFAIL to it. The allocator will
> try as hard as it can to fulfill the request but fails eventually if
> the progress cannot be made.
> 
> Cc: Darrick J. Wong <darrick.wong@oracle.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  fs/xfs/kmem.h | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
> index ae08cfd9552a..ac80a4855c83 100644
> --- a/fs/xfs/kmem.h
> +++ b/fs/xfs/kmem.h
> @@ -54,6 +54,16 @@ kmem_flags_convert(xfs_km_flags_t flags)
>  			lflags &= ~__GFP_FS;
>  	}
>  
> +	/*
> +	 * Default page/slab allocator behavior is to retry for ever
> +	 * for small allocations. We can override this behavior by using
> +	 * __GFP_RETRY_MAYFAIL which will tell the allocator to retry as long
> +	 * as it is feasible but rather fail than retry for ever for all
> +	 * request sizes.
> +	 */
> +	if (flags & KM_MAYFAIL)
> +		lflags |= __GFP_RETRY_MAYFAIL;

I don't see advantages of supporting both __GFP_NORETRY and __GFP_RETRY_MAYFAIL.
kmem_flags_convert() can always set __GFP_NORETRY because the callers use
opencoded __GFP_NOFAIL loop (with possible allocation lockup warning) unless
KM_MAYFAIL is set.

> +
>  	if (flags & KM_ZERO)
>  		lflags |= __GFP_ZERO;
>  
> 

Well, commit 9a67f6488eca926f ("mm: consolidate GFP_NOFAIL checks in the
allocator slowpath") unexpectedly changed to always give up without using
memory reserves (unless __GFP_NOFAIL is set) if TIF_MEMDIE is set to current
thread when current thread is inside __alloc_pages_may_oom() (precisely speaking,
if TIF_MEMDIE is set when current thread is after

        if (gfp_pfmemalloc_allowed(gfp_mask))
                alloc_flags = ALLOC_NO_WATERMARKS;

line and before

        /* Avoid allocations with no watermarks from looping endlessly */
        if (test_thread_flag(TIF_MEMDIE))
                goto nopage;

line, which is likely always true); but this is off-topic for this thread.

The lines which are executed only when __GFP_RETRY_MAYFAIL is set rather than
__GFP_NORETRY is set are

        /* Do not loop if specifically requested */
        if (gfp_mask & __GFP_NORETRY)
                goto nopage;

        /*
         * Do not retry costly high order allocations unless they are
         * __GFP_RETRY_MAYFAIL
         */
        if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_RETRY_MAYFAIL))
                goto nopage;

        if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
                                 did_some_progress > 0, &no_progress_loops))
                goto retry;

        /*
         * It doesn't make any sense to retry for the compaction if the order-0
         * reclaim is not able to make any progress because the current
         * implementation of the compaction depends on the sufficient amount
         * of free memory (see __compaction_suitable)
         */
        if (did_some_progress > 0 &&
                        should_compact_retry(ac, order, alloc_flags,
                                compact_result, &compact_priority,
                                &compaction_retries))
                goto retry;

        /*
         * It's possible we raced with cpuset update so the OOM would be
         * premature (see below the nopage: label for full explanation).
         */
        if (read_mems_allowed_retry(cpuset_mems_cookie))
                goto retry_cpuset;

        /* Reclaim has failed us, start killing things */
        page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
        if (page)
                goto got_pg;

__alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
        const struct alloc_context *ac, unsigned long *did_some_progress)
{
        struct oom_control oc = {
                .zonelist = ac->zonelist,
                .nodemask = ac->nodemask,
                .memcg = NULL,
                .gfp_mask = gfp_mask,
                .order = order,
        };
        struct page *page;

        *did_some_progress = 0;

        /*
         * Acquire the oom lock.  If that fails, somebody else is
         * making progress for us.
         */
        if (!mutex_trylock(&oom_lock)) {
                *did_some_progress = 1;
                schedule_timeout_uninterruptible(1);
                return NULL;
        }

        /*
         * Go through the zonelist yet one more time, keep very high watermark
         * here, this is only to catch a parallel oom killing, we must fail if
         * we're still under heavy pressure.
         */
        page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL, order,
                                        ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
        if (page)
                goto out;

        /* Coredumps can quickly deplete all memory reserves */
        if (current->flags & PF_DUMPCORE)
                goto out;
        /* The OOM killer will not help higher order allocs */
        if (order > PAGE_ALLOC_COSTLY_ORDER)
                goto out;
        /*
         * We have already exhausted all our reclaim opportunities without any
         * success so it is time to admit defeat. We will skip the OOM killer
         * because it is very likely that the caller has a more reasonable
         * fallback than shooting a random task.
         */
        if (gfp_mask & __GFP_RETRY_MAYFAIL)
                goto out;

where both __GFP_NORETRY and __GFP_RETRY_MAYFAIL are checked after
direct reclaim and compaction failed. __GFP_RETRY_MAYFAIL optimistically
retries based on one of should_reclaim_retry() or should_compact_retry()
or read_mems_allowed_retry() returns true or mutex_trylock(&oom_lock) in
__alloc_pages_may_oom() returns 0. If !__GFP_FS allocation requests are
holding oom_lock each other, __GFP_RETRY_MAYFAIL allocation requests (which
are likely !__GFP_FS allocation requests due to __GFP_FS allocation requests
being blocked on direct reclaim) can be blocked for uncontrollable duration
without making progress. It seems to me that the difference between
__GFP_NORETRY and __GFP_RETRY_MAYFAIL is not useful. Rather, the caller can
set __GFP_NORETRY and retry with any control (e.g. set __GFP_HIGH upon first
timeout, give up upon second timeout).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
