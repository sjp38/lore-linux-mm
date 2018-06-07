Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4836B0007
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 07:13:38 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x22-v6so4490528wmc.7
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 04:13:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n13-v6si2370064edn.415.2018.06.07.04.13.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jun 2018 04:13:36 -0700 (PDT)
Date: Thu, 7 Jun 2018 13:13:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] mm,page_alloc: Move the short sleep to
 should_reclaim_retry()
Message-ID: <20180607111335.GL32433@dhcp22.suse.cz>
References: <1528369223-7571-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1528369223-7571-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1528369223-7571-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu 07-06-18 20:00:21, Tetsuo Handa wrote:
> should_reclaim_retry() should be a natural reschedule point. PF_WQ_WORKER
> is a special case which needs a stronger rescheduling policy. Doing that
> unconditionally seems more straightforward than depending on a zone being
> a good candidate for a further reclaim.
> 
> Thus, move the short sleep when we are waiting for the owner of oom_lock
> (which coincidentally also serves as a guaranteed sleep for PF_WQ_WORKER
> threads) to should_reclaim_retry(). Note that it is not evaluated that
> whether there is negative side effect with this change. We need to test
> both real and artificial workloads for evaluation. You can compare with
> and without this patch if you noticed something unexpected.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Tejun Heo <tj@kernel.org>

Your s-o-b is missing here. And I suspect this should be From: /me
but I do not care all that much.

> ---
>  mm/page_alloc.c | 40 ++++++++++++++++++----------------------
>  1 file changed, 18 insertions(+), 22 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e90f152..210a476 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3914,6 +3914,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  {
>  	struct zone *zone;
>  	struct zoneref *z;
> +	bool ret = false;
>  
>  	/*
>  	 * Costly allocations might have made a progress but this doesn't mean
> @@ -3977,25 +3978,26 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
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
> @@ -4237,12 +4239,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  	/* Retry as long as the OOM killer is making progress */
>  	if (did_some_progress) {
>  		no_progress_loops = 0;
> -		/*
> -		 * This schedule_timeout_*() serves as a guaranteed sleep for
> -		 * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> -		 */
> -		if (!tsk_is_oom_victim(current))
> -			schedule_timeout_uninterruptible(1);
>  		goto retry;
>  	}
>  
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
