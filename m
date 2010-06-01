Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7BDF56B01D6
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:50:08 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o51Ko4Ws015565
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 13:50:04 -0700
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by wpaz33.hot.corp.google.com with ESMTP id o51Ko2lB030267
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 13:50:03 -0700
Received: by pxi2 with SMTP id 2so3970186pxi.18
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 13:50:02 -0700 (PDT)
Date: Tue, 1 Jun 2010 13:49:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
In-Reply-To: <20100601173535.GD23428@uudg.org>
Message-ID: <alpine.DEB.2.00.1006011347060.13136@chino.kir.corp.google.com>
References: <20100528164826.GJ11364@uudg.org> <20100531092133.73705339.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTikFk_HnZWPG0s_VrRkro2rruEc8OBX5KfKp_QdX@mail.gmail.com> <20100531140443.b36a4f02.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTil75ziCd6bivhpmwojvhaJ2LVxwEaEaBEmZf2yN@mail.gmail.com>
 <20100531145415.5e53f837.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTilcuY5e1DNmLhUWfXtiQgPUafz2zRTUuTVl-88l@mail.gmail.com> <20100531155102.9a122772.kamezawa.hiroyu@jp.fujitsu.com> <20100531135227.GC19784@uudg.org> <20100601085006.f732c049.kamezawa.hiroyu@jp.fujitsu.com>
 <20100601173535.GD23428@uudg.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531400454-399898958-1275425400=:13136"
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531400454-399898958-1275425400=:13136
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 1 Jun 2010, Luis Claudio R. Goncalves wrote:

> oom-kill: give the dying task a higher priority (v5)
> 
> In a system under heavy load it was observed that even after the
> oom-killer selects a task to die, the task may take a long time to die.
> 
> Right before sending a SIGKILL to the task selected by the oom-killer
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
> 
> Another good suggestion, implemented here, was to avoid boosting the
> dying task priority in case of mem_cgroup OOM.
> 
> Signed-off-by: Luis Claudio R. Goncalves <lclaudio@uudg.org>
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 709aedf..67e18ca 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -52,6 +52,22 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
>  	return 0;
>  }
>  
> +/*
> + * If this is a system OOM (not a memcg OOM) and the task selected to be
> + * killed is not already running at high (RT) priorities, speed up the
> + * recovery by boosting the dying task to the lowest FIFO priority.
> + * That helps with the recovery and avoids interfering with RT tasks.
> + */
> +static void boost_dying_task_prio(struct task_struct *p,
> +					struct mem_cgroup *mem)
> +{
> +	if ((mem == NULL) && !rt_task(p)) {
> +		struct sched_param param;
> +		param.sched_priority = 1;
> +		sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
> +	}
> +}
> +
>  /**
>   * badness - calculate a numeric value for how bad this task has been
>   * @p: task struct of which task we should calculate
> @@ -277,8 +293,10 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>  		 * blocked waiting for another task which itself is waiting
>  		 * for memory. Is there a better alternative?
>  		 */
> -		if (test_tsk_thread_flag(p, TIF_MEMDIE))
> +		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
> +			boost_dying_task_prio(p, mem);
>  			return ERR_PTR(-1UL);
> +		}
>  
>  		/*
>  		 * This is in the process of releasing memory so wait for it

That's unnecessary, if p already has TIF_MEMDIE set, then 
boost_dying_task_prio(p) has already been called.

> @@ -291,9 +309,10 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>  		 * Otherwise we could get an easy OOM deadlock.
>  		 */
>  		if (p->flags & PF_EXITING) {
> -			if (p != current)
> +			if (p != current) {
> +				boost_dying_task_prio(p, mem);
>  				return ERR_PTR(-1UL);
> -
> +			}
>  			chosen = p;
>  			*ppoints = ULONG_MAX;
>  		}

This has the potential to actually make it harder to free memory if p is 
waiting to acquire a writelock on mm->mmap_sem in the exit path while the 
thread holding mm->mmap_sem is trying to run.
--531400454-399898958-1275425400=:13136--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
