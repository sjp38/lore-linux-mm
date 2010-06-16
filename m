Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D22D96B01B0
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 11:31:28 -0400 (EDT)
Received: by pwi7 with SMTP id 7so4341249pwi.14
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 08:31:27 -0700 (PDT)
Date: Thu, 17 Jun 2010 00:31:20 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 9/9] oom: give the dying task a higher priority
Message-ID: <20100616153120.GH9278@barrios-desktop>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
 <20100616203517.72EF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100616203517.72EF.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2010 at 08:36:29PM +0900, KOSAKI Motohiro wrote:
> 
> From: Luis Claudio R. Goncalves <lclaudio@uudg.org>
> 
> In a system under heavy load it was observed that even after the
> oom-killer selects a task to die, the task may take a long time to die.
> 
> Right after sending a SIGKILL to the task selected by the oom-killer
> this task has it's priority increased so that it can exit() exit soon,
> freeing memory. That is accomplished by:
> 
>         /*
>          * We give our sacrificial lamb high priority and access to
>          * all the memory it needs. That way it should be able to
>          * exit() and clear out its resources quickly...
>          */
>  	p->rt.time_slice = HZ;
>  	set_tsk_thread_flag(p, TIF_MEMDIE);
> 
> It sounds plausible giving the dying task an even higher priority to be
> sure it will be scheduled sooner and free the desired memory. It was
> suggested on LKML using SCHED_FIFO:1, the lowest RT priority so that
> this task won't interfere with any running RT task.
> 
> If the dying task is already an RT task, leave it untouched.
> Another good suggestion, implemented here, was to avoid boosting the
> dying task priority in case of mem_cgroup OOM.
> 
> Signed-off-by: Luis Claudio R. Goncalves <lclaudio@uudg.org>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/oom_kill.c |   38 +++++++++++++++++++++++++++++++++++---
>  1 files changed, 35 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 7e9942d..1ecfc7a 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -82,6 +82,28 @@ static bool has_intersects_mems_allowed(struct task_struct *tsk,
>  #endif /* CONFIG_NUMA */
>  
>  /*
> + * If this is a system OOM (not a memcg OOM) and the task selected to be
> + * killed is not already running at high (RT) priorities, speed up the
> + * recovery by boosting the dying task to the lowest FIFO priority.
> + * That helps with the recovery and avoids interfering with RT tasks.
> + */
> +static void boost_dying_task_prio(struct task_struct *p,
> +				  struct mem_cgroup *mem)
> +{
> +	struct sched_param param = { .sched_priority = 1 };
> +
> +	if (mem)
> +		return;
> +
> +	if (rt_task(p)) {
> +		p->rt.time_slice = HZ;
> +		return;

I have a question from long time ago. 
If we change rt.time_slice _without_ setscheduler, is it effective?
I mean scheduler pick up the task faster than other normal task?

> +	}
> +
> +	sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
> +}
> +
> +/*
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
