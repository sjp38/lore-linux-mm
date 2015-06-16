Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 32DF26B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 09:46:59 -0400 (EDT)
Received: by lblr1 with SMTP id r1so11299058lbl.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 06:46:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cr5si1828963wjb.214.2015.06.16.06.46.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 06:46:57 -0700 (PDT)
Date: Tue, 16 Jun 2015 15:46:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] panic_on_oom_timeout
Message-ID: <20150616134650.GC24296@dhcp22.suse.cz>
References: <201506102120.FEC87595.OQSJLOVtMFOHFF@I-love.SAKURA.ne.jp>
 <20150610142801.GD4501@dhcp22.suse.cz>
 <20150610155646.GE4501@dhcp22.suse.cz>
 <201506130022.FJF05762.LSQMOFtVFFOJOH@I-love.SAKURA.ne.jp>
 <20150615124515.GC29447@dhcp22.suse.cz>
 <201506162214.IGG12982.QOFHMOFLOJFtSV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506162214.IGG12982.QOFHMOFLOJFtSV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Tue 16-06-15 22:14:28, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > This patch implements system_memdie_panic_secs sysctl which configures
> > > a maximum timeout for the OOM killer to resolve the OOM situation.
> > > If the system is still under OOM (i.e. the OOM victim cannot release
> > > memory) after the timeout expires, it will panic the system. A
> > > reasonably chosen timeout can protect from both temporal OOM conditions
> > > and allows to have a predictable time frame for the OOM condition.
> > > 
> > > Since there are memcg OOM, cpuset OOM, mempolicy OOM as with system OOM,
> > > this patch also implements {memcg,cpuset,mempolicy}_memdie_panic_secs .
> > 
> > I really hate having so many knobs. What would they be good for? Why
> > cannot you simply use a single timeout and decide whether to panic or
> > not based on panic_on_oom value? Or do you have any strong reason to
> > put this aside from panic_on_oom?
> > 
> 
> The reason would depend on
> 
>  (a) whether {memcg,cpuset,mempolicy} OOM stall is possible
>
>  (b) what {memcg,cpuset,mempolicy} users want to do when (a) is possible
>      and {memcg,cpuset,mempolicy} OOM stall occurred

The system as such is still usable. And an administrator might
intervene. E.g. enlarge the memcg limit or relax the numa restrictions
for the same purpose.

> Since memcg OOM is less critical than system OOM because administrator still
> has chance to perform steps to resolve the OOM state, we could give longer
> timeout (e.g. 600 seconds) for memcg OOM while giving shorter timeout (e.g.
> 10 seconds) for system OOM. But if (a) is impossible, trying to configure
> different timeout for non-system OOM stall makes no sense.

I still do not see any point for a separate timeouts.

Again panic_on_oom=2 sounds very dubious to me as already mentioned. The
life would be so much easier if we simply start by supporting
panic_on_oom=1 for now. It would be a simple timer (as we cannot use
DELAYED_WORK) which would just panic the machine after a timeout. We
wouldn't have a full oom report but that shouldn't matter much because
the original one would be in the log. Yes we could race with mempolicy
resp. memcg OOM killers when canceling the timer but does this matter
much? Dunno to be honest but having a simpler solution sounds much more
attractive to me. Shouldn't we go this way first?

[...]

> But I forgot that for_each_process_thread() in select_bad_process() already
> checked all threads of all processes. Thus, this block would be a garbage
> because checking all threads of a process here is unnecessary.

Exactly.
 
[...]
> > Besides that oom_unkillable_task doesn't sound like a good match to
> > evaluate this logic. I would expect it to be in oom_scan_process_thread.
> 
> Well, select_bad_process() which calls oom_scan_process_thread() would
> break out from the loop when encountering the first TIF_MEMDIE task.
> We need to change
> 
> 	case OOM_SCAN_ABORT:
> 		rcu_read_unlock();
> 		return (struct task_struct *)(-1UL);
> 
> to defer returning of (-1UL) when a TIF_MEMDIE thread was found, in order to
> make sure that all TIF_MEMDIE threads are examined for timeout. With that
> change made,
> 
> 	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> 		/*** this location ***/
> 		if (!force_kill)
> 			return OOM_SCAN_ABORT;
> 	}
> 
> in oom_scan_process_thread() will be an appropriate place for evaluating
> this logic.

You can also keep select_bad_process untouched and simply check the
remaining TIF_MEMDIE tasks in oom_scan_process_thread (if the timeout is > 0
of course so the most configurations will be unaffected).

> > > @@ -416,10 +491,17 @@ bool oom_killer_disabled __read_mostly;
> > >   */
> > >  void mark_oom_victim(struct task_struct *tsk)
> > >  {
> > > +	unsigned long start;
> > > +
> > >  	WARN_ON(oom_killer_disabled);
> > >  	/* OOM killer might race with memcg OOM */
> > >  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> > >  		return;
> > > +	/* Set current time for is_killable_memdie_task() check. */
> > > +	start = jiffies;
> > > +	if (!start)
> > > +		start = 1;
> > > +	tsk->memdie_start = start;
> > 
> > I would rather go with tsk->oom_expire = jiffies + timeout and set the
> > timeout depending on panic_on_oom value (which would require nodemask
> > and memcg parameters here).
> > 
> 
> I got lost when making distinction between mempolicy/cpuset OOM and
> system OOM. I consider that memcg OOM is memcg != NULL.

right

> I consider that system OOM is memcg == NULL && nodemask == NULL.
> But has_intersects_mems_allowed() thinks as mempolicy OOM if
> nodemask != NULL and thinks as cpuset OOM if nodemask == NULL.

cpuset is an interface to enforce nodemask. So nodemask != is an OOM
caused by a NUMA policy.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
