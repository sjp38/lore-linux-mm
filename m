Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1ECD26B0279
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 03:57:37 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r21-v6so1837435edp.23
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 00:57:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i63-v6si11321588edi.139.2018.07.09.00.57.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 00:57:35 -0700 (PDT)
Date: Mon, 9 Jul 2018 09:57:31 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER should always sleep at
 should_reclaim_retry().
Message-ID: <20180709075731.GB22049@dhcp22.suse.cz>
References: <1531046158-4010-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1531046158-4010-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@suse.de>, Vladimir Davydov <vdavydov@virtuozzo.com>, Vlastimil Babka <vbabka@suse.cz>

On Sun 08-07-18 19:35:58, Tetsuo Handa wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> should_reclaim_retry() should be a natural reschedule point. PF_WQ_WORKER
> is a special case which needs a stronger rescheduling policy. However,
> since schedule_timeout_uninterruptible(1) for PF_WQ_WORKER depends on
> __zone_watermark_ok() == true, PF_WQ_WORKER is currently counting on
> mutex_trylock(&oom_lock) == 0 in __alloc_pages_may_oom() which is a bad
> expectation.

I think your reference to the oom_lock is more confusing than helpful
actually. I would simply use the following from your previous [1]
changelog:
: should_reclaim_retry() should be a natural reschedule point. PF_WQ_WORKER
: is a special case which needs a stronger rescheduling policy. Doing that
: unconditionally seems more straightforward than depending on a zone being
: a good candidate for a further reclaim.
: 
: Thus, move the short sleep when we are waiting for the owner of oom_lock
: (which coincidentally also serves as a guaranteed sleep for PF_WQ_WORKER
: threads) to should_reclaim_retry().

> unconditionally seems more straightforward than depending on a zone being
> a good candidate for a further reclaim.

[1] http://lkml.kernel.org/r/1528369223-7571-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp

[Tetsuo: changelog]
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Joonsoo Kim <js1304@gmail.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>

Your s-o-b is still missing.

> ---
>  mm/page_alloc.c | 34 ++++++++++++++++++----------------
>  1 file changed, 18 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1521100..f56cc09 100644
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
