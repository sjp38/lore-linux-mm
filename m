Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id BE5626B006E
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 09:14:36 -0400 (EDT)
Received: by obctg8 with SMTP id tg8so10944302obc.3
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 06:14:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b6si611360oby.16.2015.06.16.06.14.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 06:14:35 -0700 (PDT)
Subject: Re: [RFC] panic_on_oom_timeout
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201506102120.FEC87595.OQSJLOVtMFOHFF@I-love.SAKURA.ne.jp>
	<20150610142801.GD4501@dhcp22.suse.cz>
	<20150610155646.GE4501@dhcp22.suse.cz>
	<201506130022.FJF05762.LSQMOFtVFFOJOH@I-love.SAKURA.ne.jp>
	<20150615124515.GC29447@dhcp22.suse.cz>
In-Reply-To: <20150615124515.GC29447@dhcp22.suse.cz>
Message-Id: <201506162214.IGG12982.QOFHMOFLOJFtSV@I-love.SAKURA.ne.jp>
Date: Tue, 16 Jun 2015 22:14:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > This patch implements system_memdie_panic_secs sysctl which configures
> > a maximum timeout for the OOM killer to resolve the OOM situation.
> > If the system is still under OOM (i.e. the OOM victim cannot release
> > memory) after the timeout expires, it will panic the system. A
> > reasonably chosen timeout can protect from both temporal OOM conditions
> > and allows to have a predictable time frame for the OOM condition.
> > 
> > Since there are memcg OOM, cpuset OOM, mempolicy OOM as with system OOM,
> > this patch also implements {memcg,cpuset,mempolicy}_memdie_panic_secs .
> 
> I really hate having so many knobs. What would they be good for? Why
> cannot you simply use a single timeout and decide whether to panic or
> not based on panic_on_oom value? Or do you have any strong reason to
> put this aside from panic_on_oom?
> 

The reason would depend on

 (a) whether {memcg,cpuset,mempolicy} OOM stall is possible

 (b) what {memcg,cpuset,mempolicy} users want to do when (a) is possible
     and {memcg,cpuset,mempolicy} OOM stall occurred

.

Since memcg OOM is less critical than system OOM because administrator still
has chance to perform steps to resolve the OOM state, we could give longer
timeout (e.g. 600 seconds) for memcg OOM while giving shorter timeout (e.g.
10 seconds) for system OOM. But if (a) is impossible, trying to configure
different timeout for non-system OOM stall makes no sense.



> > +#ifdef CONFIG_NUMA
> > +	{
> > +		struct task_struct *t;
> > +
> > +		rcu_read_lock();
> > +		for_each_thread(p, t) {
> > +			start = t->memdie_start;
> > +			if (start && time_after(spent, timeout * HZ))
> > +				break;
> > +		}
> > +		rcu_read_unlock();
> 
> This doesn't make any sense to me. What are you trying to achieve here?
> Why would you want to check all threads and do that only for CONFIG_NUMA
> and even then do a noop if the timeout expired?
> 
> > +	}
> > +#endif

This block tried to mimic what has_intersects_mems_allowed() does.
Since TIF_MEMDIE is set to only one thread than all threads in a process,
I thought that I need to check all threads of a process when searching for
a TIF_MEMDIE thread.

But I forgot that for_each_process_thread() in select_bad_process() already
checked all threads of all processes. Thus, this block would be a garbage
because checking all threads of a process here is unnecessary.



> > @@ -135,6 +209,7 @@ static bool oom_unkillable_task(struct task_struct *p,
> >  	if (!has_intersects_mems_allowed(p, nodemask))
> >  		return true;
> >  
> > +	check_memdie_task(p, memcg, nodemask);
> 
> This is not sufficient. oom_scan_process_thread would break out from the
> loop when encountering the first TIF_MEMDIE task and could have missed
> an older one later in the task_list.

Indeed, not sufficient for this "tear just this part out" version.

My concern is to allow timeout for

 (1) choosing next OOM victim if previous OOM victim fails to release memory
 (2) triggering kernel panic if none of OOM victims can release memory
 (3) invoking OOM killer for !__GFP_FS allocations

for system OOM stall, for we can see that any mechanism is unreliable due to
e.g. workqueue being not processed, kswapd / rescuer threads making no
progress.

My "full" version tried to be sufficient because it makes
oom_unkillable_task() return true when timer for (1) expires. But indeed,
still not sufficient because older victim's timer for (2) could fail to
expire until younger victim's timer for (1) expires.

> Besides that oom_unkillable_task doesn't sound like a good match to
> evaluate this logic. I would expect it to be in oom_scan_process_thread.

Well, select_bad_process() which calls oom_scan_process_thread() would
break out from the loop when encountering the first TIF_MEMDIE task.
We need to change

	case OOM_SCAN_ABORT:
		rcu_read_unlock();
		return (struct task_struct *)(-1UL);

to defer returning of (-1UL) when a TIF_MEMDIE thread was found, in order to
make sure that all TIF_MEMDIE threads are examined for timeout. With that
change made,

	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
		/*** this location ***/
		if (!force_kill)
			return OOM_SCAN_ABORT;
	}

in oom_scan_process_thread() will be an appropriate place for evaluating
this logic.



> > @@ -416,10 +491,17 @@ bool oom_killer_disabled __read_mostly;
> >   */
> >  void mark_oom_victim(struct task_struct *tsk)
> >  {
> > +	unsigned long start;
> > +
> >  	WARN_ON(oom_killer_disabled);
> >  	/* OOM killer might race with memcg OOM */
> >  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> >  		return;
> > +	/* Set current time for is_killable_memdie_task() check. */
> > +	start = jiffies;
> > +	if (!start)
> > +		start = 1;
> > +	tsk->memdie_start = start;
> 
> I would rather go with tsk->oom_expire = jiffies + timeout and set the
> timeout depending on panic_on_oom value (which would require nodemask
> and memcg parameters here).
> 

I got lost when making distinction between mempolicy/cpuset OOM and
system OOM. I consider that memcg OOM is memcg != NULL.
I consider that system OOM is memcg == NULL && nodemask == NULL.
But has_intersects_mems_allowed() thinks as mempolicy OOM if
nodemask != NULL and thinks as cpuset OOM if nodemask == NULL.

If (a) is possible and we want to configure different timeout for
cpuset OOM stall and system OOM stall, where is distinction between
cpuset OOM and system OOM? Are cpuset OOM and system OOM identical?



> > @@ -435,6 +517,7 @@ void mark_oom_victim(struct task_struct *tsk)
> >   */
> >  void exit_oom_victim(void)
> >  {
> > +	current->memdie_start = 0;
> 
> Is this really needed? OOM killer shouldn't see the task because it has
> already released its mm. oom_scan_process_thread checks mm after it
> TIF_MEMDIE so we can race theoretically but this shouldn't matter much.

Only to show that we could replace TIF_MEMDIE with memdie_start.

> If a task is still visible after the timeout then there obviously was a
> problem in making progress.
> 

I can see that an OOM victim is still visible after the timeout regarding
system OOM. That's why I want timeout for (1), (2) and (3).
(This RFC focuses on only timeout for (2).)



> > By the way, with introduction of per "struct task_struct" variable, I think
> > that we can replace TIF_MEMDIE checks with memdie_start checks via
> > 
> >   test_tsk_thread_flag(p, TIF_MEMDIE) => p->memdie_start
> > 
> >   test_and_clear_thread_flag(TIF_MEMDIE) => xchg(&current->memdie_start, 0)
> > 
> >   test_and_set_tsk_thread_flag(p, TIF_MEMDIE)
> >   => xchg(&p->memdie_start, jiffies (or 1 if jiffies == 0))
> > 
> > though above patch did not replace TIF_MEMDIE in order to focus on one thing.
> 
> I fail to see a direct advantage other than to safe one bit in flags. Is
> something asking for it?

So far, nothing but saving one bit in flags.

If we remove TIF_MEMDIE, we could reuse that bit as TIF_MEMALLOC_STALLING
which is similar to TIF_NEED_RESCHED. TIF_MEMALLOC_STALLING is set via
timer which is enabled at

	/*
	 * Try direct compaction. The first pass is asynchronous. Subsequent
	 * attempts after direct reclaim are synchronous
	 */

in __alloc_pages_slowpath() in order to indicate that current thread is
spending too much time inside the memory allocator (a sign of failing to
make forward progress, hint for triggering (3) above).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
