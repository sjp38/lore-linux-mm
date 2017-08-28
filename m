Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF1C06B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 08:10:59 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id a47so454667wra.0
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 05:10:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j28si198527wra.391.2017.08.28.05.10.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Aug 2017 05:10:57 -0700 (PDT)
Date: Mon, 28 Aug 2017 14:10:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
Message-ID: <20170828121055.GI17097@dhcp22.suse.cz>
References: <1503921210-4603-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1503921210-4603-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, tj@kernel.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>

On Mon 28-08-17 20:53:30, Tetsuo Handa wrote:
> I noticed that drain_local_pages_wq work stuck for minutes despite it is
> on WQ_MEM_RECLAIM mm_percpu_wq workqueue. Tejun Heo pointed out [1]:
> 
>   Rescuer helps if the worker pool that the workqueue is associated with
>   hangs. If we have other work items actively running, e.g., for reclaim
>   on the pool, the pool isn't stalled and rescuers won't be woken up. If
>   the work items need preferential execution, it should use WQ_HIGHPRI.
> 
> Since work items on mm_percpu_wq workqueue are expected to be executed
> as soon as possible, let's use WQ_HIGHPRI. Note that even with WQ_HIGHPRI,
> up to a few seconds of delay seems to be unavoidable.

I am not sure I understand how WQ_HIGHPRI actually helps. The work item
will get served by a thread with higher priority and from a different
pool than regular WQs. But what prevents the same issue as described
above when the highprio pool gets congested? In other words what make
WQ_HIGHPRI less prone to long stalls when we are under low memory
situation and new workers cannot be allocated?

> If we do want to make
> sure that work items on mm_percpu_wq workqueue are executed without delays,
> we need to consider using kthread_workers instead of workqueue. (Or, maybe
> somehow we can share one kthread with constantly manipulating cpumask?)

Hmm, that doesn't sound like a bad idea to me. We already have a rescuer
thread that basically sits idle all the time so having a dedicated
kernel thread will not be more expensive wrt. resources. So I think this
is a more reasonable approach than playing with WQ_HIGHPRI which smells
like a quite obscure workaround than a real fix to me.

> [1] http://lkml.kernel.org/r/201707111951.IHA98084.OHQtVOFJMLOSFF@I-love.SAKURA.ne.jp
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/vmstat.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 4bb13e7..cb7e198 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1923,7 +1923,8 @@ void __init init_mm_internals(void)
>  {
>  	int ret __maybe_unused;
>  
> -	mm_percpu_wq = alloc_workqueue("mm_percpu_wq", WQ_MEM_RECLAIM, 0);
> +	mm_percpu_wq = alloc_workqueue("mm_percpu_wq",
> +				       WQ_MEM_RECLAIM | WQ_HIGHPRI, 0);
>  
>  #ifdef CONFIG_SMP
>  	ret = cpuhp_setup_state_nocalls(CPUHP_MM_VMSTAT_DEAD, "mm/vmstat:dead",
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
