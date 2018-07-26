Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 21D5E6B0006
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 07:40:02 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l1-v6so692941edi.11
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 04:40:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 25-v6si1033045edu.218.2018.07.26.04.40.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 04:40:00 -0700 (PDT)
Date: Thu, 26 Jul 2018 13:39:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
Message-ID: <20180726113958.GE28386@dhcp22.suse.cz>
References: <ca3da8b8-1bb5-c302-b190-fa6cebab58ca@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ca3da8b8-1bb5-c302-b190-fa6cebab58ca@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 26-07-18 20:06:24, Tetsuo Handa wrote:
> Before applying "an OOM lockup mitigation patch", I want to apply this
> "another OOM lockup avoidance" patch.

I do not really see why. All these are borderline interesting as the
system is basically dead by the time you reach this state.

> Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20180726.txt.xz
> (which was captured with
> 
>   --- a/mm/oom_kill.c
>   +++ b/mm/oom_kill.c
>   @@ -1071,6 +1071,12 @@ bool out_of_memory(struct oom_control *oc)
>    {
>    	unsigned long freed = 0;
>    	bool delay = false; /* if set, delay next allocation attempt */
>   +	static unsigned long last_warned;
>   +	if (!last_warned || time_after(jiffies, last_warned + 10 * HZ)) {
>   +		pr_warn("%s(%d) gfp_mask=%#x(%pGg), order=%d\n", current->comm,
>   +			current->pid, oc->gfp_mask, &oc->gfp_mask, oc->order);
>   +		last_warned = jiffies;
>   +	}
>    
>    	oc->constraint = CONSTRAINT_NONE;
>    	if (oom_killer_disabled)
> 
> in order to demonstrate that the GFP_NOIO allocation from disk_events_workfn() is
> calling out_of_memory() rather than by error failing to give up direct reclaim).
> 
> [  258.619119] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
> [  268.622732] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
> [  278.635344] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
> [  288.639360] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
> [  298.642715] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0

Hmm, so there is no other memory allocation to trigger the oom or they
all just back off on the oom_lock trylock? In other words what is
preventing from the oom killer invocation?
 
[...]

> Since the patch shown below was suggested by Michal Hocko at
> https://marc.info/?l=linux-mm&m=152723708623015 , it is from Michal Hocko.
> 
> >From cd8095242de13ace61eefca0c3d6f2a5a7b40032 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 26 Jul 2018 14:40:03 +0900
> Subject: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at should_reclaim_retry().
> 
> Tetsuo Handa has reported that it is possible to bypass the short sleep
> for PF_WQ_WORKER threads which was introduced by commit 373ccbe5927034b5
> ("mm, vmstat: allow WQ concurrency to discover memory reclaim doesn't make
> any progress") and moved by commit ede37713737834d9 ("mm: throttle on IO
> only when there are too many dirty and writeback pages") and lock up the
> system if OOM.
> 
> This is because we are implicitly counting on falling back to
> schedule_timeout_uninterruptible() in __alloc_pages_may_oom() when
> schedule_timeout_uninterruptible() in should_reclaim_retry() was not
> called due to __zone_watermark_ok() == false.

How do we rely on that?

> However, schedule_timeout_uninterruptible() in __alloc_pages_may_oom() is
> not called if all allocating threads but a PF_WQ_WORKER thread got stuck at
> __GFP_FS direct reclaim, for mutex_trylock(&oom_lock) by that PF_WQ_WORKER
> thread succeeds and out_of_memory() remains no-op unless that PF_WQ_WORKER
> thread is doing __GFP_FS allocation.

I have really hard time to parse and understand this.

> Tetsuo is observing that GFP_NOIO
> allocation request from disk_events_workfn() is preventing other pending
> works from starting.

What about any other allocation from !PF_WQ_WORKER context? Why those do
not jump in?

> Since should_reclaim_retry() should be a natural reschedule point,
> let's do the short sleep for PF_WQ_WORKER threads unconditionally
> in order to guarantee that other pending works are started.

OK, this is finally makes some sense. But it doesn't explain why it
handles the live lock.

> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Your s-o-b is missing again. I have already told you that previously
when you were posting the patch.

I do not mind this change per se but I am not happy about _your_ changelog.
It doesn't explain the underlying problem IMHO. Having a natural and
unconditional scheduling point in should_reclaim_retry is a reasonable
thing. But how the hack it relates to the livelock you are seeing. So
namely the changelog should explain
1) why nobody is able to make forward progress during direct reclaim
2) why nobody is able to trigger oom killer as the last resort

> Cc: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Tejun Heo <tj@kernel.org>
> ---
>  mm/page_alloc.c | 34 ++++++++++++++++++----------------
>  1 file changed, 18 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a790ef4..0c2c0a2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3922,6 +3922,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  {
>  	struct zone *zone;
>  	struct zoneref *z;
> +	bool ret = false;
>  
>  	/*
>  	 * Costly allocations might have made a progress but this doesn't mean
> @@ -3985,25 +3986,26 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  				}
>  			}
>  
> -			/*
> -			 * Memory allocation/reclaim might be called from a WQ
> -			 * context and the current implementation of the WQ
> -			 * concurrency control doesn't recognize that
> -			 * a particular WQ is congested if the worker thread is
> -			 * looping without ever sleeping. Therefore we have to
> -			 * do a short sleep here rather than calling
> -			 * cond_resched().
> -			 */
> -			if (current->flags & PF_WQ_WORKER)
> -				schedule_timeout_uninterruptible(1);
> -			else
> -				cond_resched();
> -
> -			return true;
> +			ret = true;
> +			goto out;
>  		}
>  	}
>  
> -	return false;
> +out:
> +	/*
> +	 * Memory allocation/reclaim might be called from a WQ
> +	 * context and the current implementation of the WQ
> +	 * concurrency control doesn't recognize that
> +	 * a particular WQ is congested if the worker thread is
> +	 * looping without ever sleeping. Therefore we have to
> +	 * do a short sleep here rather than calling
> +	 * cond_resched().
> +	 */
> +	if (current->flags & PF_WQ_WORKER)
> +		schedule_timeout_uninterruptible(1);
> +	else
> +		cond_resched();
> +	return ret;
>  }
>  
>  static inline bool
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
