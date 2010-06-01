Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 350316B022B
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 04:42:06 -0400 (EDT)
Date: Tue, 1 Jun 2010 18:41:57 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] forked kernel task and mm structures imbalanced on NUMA
Message-ID: <20100601084157.GS9453@laptop>
References: <20100601073343.GQ9453@laptop>
 <1275380202.27810.26214.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1275380202.27810.26214.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 01, 2010 at 10:16:42AM +0200, Peter Zijlstra wrote:
> On Tue, 2010-06-01 at 17:33 +1000, Nick Piggin wrote:
> > Another problem I found when testing this patch is that the scheduler
> > has some issues of its own when balancing. This is improved by
> > traversing the sd groups starting from a different spot each time, so
> > processes get sprinkled around the nodes a bit better.
> 
> Right, makes sense. And I think we could merge that group iteration
> without much problems.
> 
> Your alternative placement for sched_exec() seems to make sense too, the
> earlier we do that the better the memory allocations will be.
> 
> Your changes to sched_fork() and wake_up_new_task() made my head hurt a
> bit -- but that's not your fault. I'm not quite sure why you're changing
> that though.

Well because we indeed don't want to select a new CPU for it unless
there has been a cpus_allowed race in the meantime.

 
> The addition of sched_fork_suggest_cpu() to select a target node seems
> to make sense, but since you then call fork balancing a second time we
> have a chance of ending up on a totally different node all together.
> 
> So I think it would make sense to rework the fork balancing muck to be
> called only once and stick with its decision.

Just need to close that race somehow. AFAIKS we can't use TASK_WAKING
because that must not be preempted?

Otherwise I don't see a problem with just taking another balance on
the extremely rare case of task failure.


 
> One thing that would make the whole fork path much easier is fully
> ripping out that child_runs_first mess for CONFIG_SMP, I think its been
> disabled by default for long enough, and its always been broken in the
> face of fork balancing anyway.

Interesting problem. vfork is nice for fork+exec, but it's a bit
restrictive.

 
> So basically we have to move fork balancing back to sched_fork(), I'd
> have to again look at wth happens to ->cpus_allowed, but I guess it
> should be fixable, and I don't think we should care overly much about
> cpu-hotplug.

No more than simply getting it right. Simply calling into the balancer
again seems to be the simplest way to do it.

 
> A specific code comment:
> 
> > @@ -2550,14 +2561,16 @@ void wake_up_new_task(struct task_struct
> >          * We set TASK_WAKING so that select_task_rq() can drop rq->lock
> >          * without people poking at ->cpus_allowed.
> >          */
> > -       cpu = select_task_rq(rq, p, SD_BALANCE_FORK, 0);
> > -       set_task_cpu(p, cpu);
> > -
> > -       p->state = TASK_RUNNING;
> > -       task_rq_unlock(rq, &flags);
> > +       if (!cpumask_test_cpu(cpu, &p->cpus_allowed)) {
> > +               p->state = TASK_WAKING;
> > +               cpu = select_task_rq(rq, p, SD_BALANCE_FORK, 0);
> > +               set_task_cpu(p, cpu);
> > +               p->state = TASK_RUNNING;
> > +               task_rq_unlock(rq, &flags);
> > +               rq = task_rq_lock(p, &flags);
> > +       }
> >  #endif
> 
> That's iffy because p->cpus_allowed isn't stable when we're not holding
> the task's current rq->lock or p->state is not TASK_WAKING.
> 

Oop, yeah missed that. Half hearted attempt to avoid more rq locks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
