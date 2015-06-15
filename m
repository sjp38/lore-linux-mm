Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 51B1E6B006C
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 08:45:20 -0400 (EDT)
Received: by wgez8 with SMTP id z8so67908560wge.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 05:45:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i18si21844846wjs.183.2015.06.15.05.45.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Jun 2015 05:45:18 -0700 (PDT)
Date: Mon, 15 Jun 2015 14:45:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] panic_on_oom_timeout
Message-ID: <20150615124515.GC29447@dhcp22.suse.cz>
References: <20150609170310.GA8990@dhcp22.suse.cz>
 <201506102120.FEC87595.OQSJLOVtMFOHFF@I-love.SAKURA.ne.jp>
 <20150610142801.GD4501@dhcp22.suse.cz>
 <20150610155646.GE4501@dhcp22.suse.cz>
 <201506130022.FJF05762.LSQMOFtVFFOJOH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506130022.FJF05762.LSQMOFtVFFOJOH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Sat 13-06-15 00:23:00, Tetsuo Handa wrote:
[...]
> >From e59b64683827151a35257384352c70bce61babdd Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 12 Jun 2015 23:56:18 +0900
> Subject: [RFC] oom: implement memdie_task_panic_secs
> 
> OOM killer is a desperate last resort reclaim attempt to free some
> memory. It is based on heuristics which will never be 100% and may
> result in an unusable or a locked up system.
> 
> panic_on_oom sysctl knob allows to set the OOM policy to panic the
> system instead of trying to resolve the OOM condition. This might be
> useful for several reasons - e.g. reduce the downtime to a predictable
> amount of time, allow to get a crash dump of the system and debug the
> issue post-mortem.
> 
> panic_on_oom is, however, a big hammer in many situations when the
> OOM condition could be resolved in a reasonable time. So it would be
> good to have some middle ground and allow the OOM killer to do its job
> but have a failover when things go wrong and it is not able to make any
> further progress for a considerable amount of time.
> 
> This patch implements system_memdie_panic_secs sysctl which configures
> a maximum timeout for the OOM killer to resolve the OOM situation.
> If the system is still under OOM (i.e. the OOM victim cannot release
> memory) after the timeout expires, it will panic the system. A
> reasonably chosen timeout can protect from both temporal OOM conditions
> and allows to have a predictable time frame for the OOM condition.
> 
> Since there are memcg OOM, cpuset OOM, mempolicy OOM as with system OOM,
> this patch also implements {memcg,cpuset,mempolicy}_memdie_panic_secs .

I really hate having so many knobs. What would they be good for? Why
cannot you simply use a single timeout and decide whether to panic or
not based on panic_on_oom value? Or do you have any strong reason to
put this aside from panic_on_oom?

> These will allow administrator to use different timeout settings for
> each type of OOM, for administrator still has chance to perform steps
> to resolve the potential lockup or trashing from the global context
> (e.g. by relaxing restrictions or even rebooting cleanly).
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  include/linux/oom.h   |  8 +++++
>  include/linux/sched.h |  1 +
>  kernel/sysctl.c       | 39 ++++++++++++++++++++++++
>  mm/oom_kill.c         | 83 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 131 insertions(+)
> 
[...]
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index dff991e..40d7b6d0 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
[...]
> +static void check_memdie_task(struct task_struct *p, struct mem_cgroup *memcg,
> +			      const nodemask_t *nodemask)
> +{
> +	unsigned long start = p->memdie_start;
> +	unsigned long spent;
> +	unsigned long timeout = 0;
> +
> +	/* If task does not have TIF_MEMDIE flag, there is nothing to do. */
> +	if (!start)
> +		return;
> +	spent = jiffies - start;
> +#ifdef CONFIG_MEMCG
> +	/* task_in_mem_cgroup(p, memcg) is true. */
> +	if (memcg)
> +		timeout = sysctl_cgroup_memdie_panic_secs;
> +#endif
> +#ifdef CONFIG_NUMA
> +	/* has_intersects_mems_allowed(p, nodemask) is true. */
> +	else if (nodemask)
> +		timeout = sysctl_mempolicy_memdie_panic_secs;
> +	else
> +		timeout = sysctl_cpuset_memdie_panic_secs;
> +#endif
> +	if (!timeout)
> +		timeout = sysctl_system_memdie_panic_secs;
> +	/* If timeout is disabled, there is nothing to do. */
> +	if (!timeout)
> +		return;
> +#ifdef CONFIG_NUMA
> +	{
> +		struct task_struct *t;
> +
> +		rcu_read_lock();
> +		for_each_thread(p, t) {
> +			start = t->memdie_start;
> +			if (start && time_after(spent, timeout * HZ))
> +				break;
> +		}
> +		rcu_read_unlock();

This doesn't make any sense to me. What are you trying to achieve here?
Why would you want to check all threads and do that only for CONFIG_NUMA
and even then do a noop if the timeout expired?

> +	}
> +#endif
> +	if (time_before(spent, timeout * HZ))
> +		return;

I think the whole function is way too much complicated without a good
reason. Why don't you simply store the expire time when marking the task
oom victim and compare it with the current jiffies with time_after and
be done with it. This is few lines of code...

> +	panic("Out of memory: %s (%u) did not die within %lu seconds.\n",
> +	      p->comm, p->pid, timeout);

It would be better to sync this message with what check_panic_on_oom
does.

> +}
> +
>  /* return true if the task is not adequate as candidate victim task. */
>  static bool oom_unkillable_task(struct task_struct *p,
>  		struct mem_cgroup *memcg, const nodemask_t *nodemask)
> @@ -135,6 +209,7 @@ static bool oom_unkillable_task(struct task_struct *p,
>  	if (!has_intersects_mems_allowed(p, nodemask))
>  		return true;
>  
> +	check_memdie_task(p, memcg, nodemask);

This is not sufficient. oom_scan_process_thread would break out from the
loop when encountering the first TIF_MEMDIE task and could have missed
an older one later in the task_list.
Besides that oom_unkillable_task doesn't sound like a good match to
evaluate this logic. I would expect it to be in oom_scan_process_thread.

>  	return false;
>  }
>  
> @@ -416,10 +491,17 @@ bool oom_killer_disabled __read_mostly;
>   */
>  void mark_oom_victim(struct task_struct *tsk)
>  {
> +	unsigned long start;
> +
>  	WARN_ON(oom_killer_disabled);
>  	/* OOM killer might race with memcg OOM */
>  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
>  		return;
> +	/* Set current time for is_killable_memdie_task() check. */
> +	start = jiffies;
> +	if (!start)
> +		start = 1;
> +	tsk->memdie_start = start;

I would rather go with tsk->oom_expire = jiffies + timeout and set the
timeout depending on panic_on_oom value (which would require nodemask
and memcg parameters here).

>  	/*
>  	 * Make sure that the task is woken up from uninterruptible sleep
>  	 * if it is frozen because OOM killer wouldn't be able to free
> @@ -435,6 +517,7 @@ void mark_oom_victim(struct task_struct *tsk)
>   */
>  void exit_oom_victim(void)
>  {
> +	current->memdie_start = 0;

Is this really needed? OOM killer shouldn't see the task because it has
already released its mm. oom_scan_process_thread checks mm after it
TIF_MEMDIE so we can race theoretically but this shouldn't matter much.
If a task is still visible after the timeout then there obviously was a
problem in making progress.

>  	clear_thread_flag(TIF_MEMDIE);
>  
>  	if (!atomic_dec_return(&oom_victims))
> -- 
> 1.8.3.1
> ------------------------------------------------------------
> 
> By the way, with introduction of per "struct task_struct" variable, I think
> that we can replace TIF_MEMDIE checks with memdie_start checks via
> 
>   test_tsk_thread_flag(p, TIF_MEMDIE) => p->memdie_start
> 
>   test_and_clear_thread_flag(TIF_MEMDIE) => xchg(&current->memdie_start, 0)
> 
>   test_and_set_tsk_thread_flag(p, TIF_MEMDIE)
>   => xchg(&p->memdie_start, jiffies (or 1 if jiffies == 0))
> 
> though above patch did not replace TIF_MEMDIE in order to focus on one thing.

I fail to see a direct advantage other than to safe one bit in flags. Is
something asking for it?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
