Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5702F6B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 08:53:00 -0500 (EST)
Date: Mon, 1 Mar 2010 13:52:42 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] mm: adjust kswapd nice level for high priority page
	allocators
Message-ID: <20100301135242.GE3852@csn.ul.ie>
References: <alpine.DEB.2.00.1003010213480.26824@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003010213480.26824@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Con Kolivas <kernel@kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 01, 2010 at 02:14:39AM -0800, David Rientjes wrote:
> From: Con Kolivas <kernel@kolivas.org>
> 
> When kswapd is awoken due to reclaim by a running task, set the priority
> of kswapd to that of the task allocating pages thus making memory reclaim
> cpu activity affected by nice level.
> 

Why?

When a process kicks kswapd, the watermark at which a process enters
direct reclaim has not been reached yet. In other words, there is no
guarantee that a process will stall due to memory pressure.

The exception would be if there are many high-priority processes allocating
pages at a steady rate that are starving kswapd of CPU time and
consequently entering direct reclaim. In this case, the high-priority
processes effectively should stall until they have reclaimed the pages.
As Con is involved, I'm guessing there are high-priority interactive
processes that jitter in low-memory situations but as I've never
observed such a scenario I'm not sure.

My main concern is that in the case there are a mix of high and low processes
with kswapd towards the higher priority as a result of this patch, kswapd
could be keeping CPU time from low-priority processes that are well behaved
that would would make less forward progress as a result of this patch.

I'm not against it as such, but I'd like to know more about the problem
this solves and what the before and after behaviour looks like.

> [rientjes@google.com: refactor for current]
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Con Kolivas <kernel@kolivas.org>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/vmscan.c |   33 ++++++++++++++++++++++++++++++++-
>  1 files changed, 32 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1658,6 +1658,33 @@ static void shrink_zone(int priority, struct zone *zone,
>  }
>  
>  /*
> + * Helper functions to adjust nice level of kswapd, based on the priority of
> + * the task allocating pages. If it is already higher priority we do not
> + * demote its nice level since it is still working on behalf of a higher
> + * priority task. With kernel threads we leave it at nice 0.
> + *
> + * We don't ever run kswapd real time, so if a real time task calls kswapd we
> + * set it to highest SCHED_NORMAL priority.
> + */
> +static int effective_sc_prio(struct task_struct *p)
> +{
> +	if (likely(p->mm)) {
> +		if (rt_task(p))
> +			return -20;
> +		return task_nice(p);
> +	}
> +	return 0;
> +}
> +
> +static void set_kswapd_nice(struct task_struct *kswapd, int active)
> +{
> +	long nice = effective_sc_prio(current);
> +
> +	if (task_nice(kswapd) > nice || !active)
> +		set_user_nice(kswapd, nice);
> +}
> +
> +/*
>   * This is the direct reclaim path, for page-allocating processes.  We only
>   * try to reclaim pages from zones which will satisfy the caller's allocation
>   * request.
> @@ -2257,6 +2284,7 @@ static int kswapd(void *p)
>  				}
>  			}
>  
> +			set_user_nice(tsk, 0);
>  			order = pgdat->kswapd_max_order;
>  		}
>  		finish_wait(&pgdat->kswapd_wait, &wait);
> @@ -2281,6 +2309,7 @@ static int kswapd(void *p)
>  void wakeup_kswapd(struct zone *zone, int order)
>  {
>  	pg_data_t *pgdat;
> +	int active;
>  
>  	if (!populated_zone(zone))
>  		return;
> @@ -2292,7 +2321,9 @@ void wakeup_kswapd(struct zone *zone, int order)
>  		pgdat->kswapd_max_order = order;
>  	if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>  		return;
> -	if (!waitqueue_active(&pgdat->kswapd_wait))
> +	active = waitqueue_active(&pgdat->kswapd_wait);
> +	set_kswapd_nice(pgdat->kswapd, active);
> +	if (!active)
>  		return;
>  	wake_up_interruptible(&pgdat->kswapd_wait);
>  }
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
