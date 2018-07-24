Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 91F886B0007
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 11:51:27 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id t10-v6so2402614ywc.7
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 08:51:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h63-v6sor2760381ybc.125.2018.07.24.08.51.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 08:51:26 -0700 (PDT)
Date: Tue, 24 Jul 2018 11:54:15 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 09/10] psi: cgroup support
Message-ID: <20180724155415.GB11598@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-10-hannes@cmpxchg.org>
 <20180717154059.GB2476@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717154059.GB2476@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi Peter,

On Tue, Jul 17, 2018 at 05:40:59PM +0200, Peter Zijlstra wrote:
> On Thu, Jul 12, 2018 at 01:29:41PM -0400, Johannes Weiner wrote:
> > +/**
> > + * cgroup_move_task - move task to a different cgroup
> > + * @task: the task
> > + * @to: the target css_set
> > + *
> > + * Move task to a new cgroup and safely migrate its associated stall
> > + * state between the different groups.
> > + *
> > + * This function acquires the task's rq lock to lock out concurrent
> > + * changes to the task's scheduling state and - in case the task is
> > + * running - concurrent changes to its stall state.
> > + */
> > +void cgroup_move_task(struct task_struct *task, struct css_set *to)
> > +{
> > +	unsigned int task_flags = 0;
> > +	struct rq_flags rf;
> > +	struct rq *rq;
> > +	u64 now;
> > +
> > +	rq = task_rq_lock(task, &rf);
> > +
> > +	if (task_on_rq_queued(task)) {
> > +		task_flags = TSK_RUNNING;
> > +	} else if (task->in_iowait) {
> > +		task_flags = TSK_IOWAIT;
> > +	}
> > +	if (task->flags & PF_MEMSTALL)
> > +		task_flags |= TSK_MEMSTALL;
> > +
> > +	if (task_flags) {
> > +		update_rq_clock(rq);
> > +		now = rq_clock(rq);
> > +		psi_task_change(task, now, task_flags, 0);
> > +	}
> > +
> > +	/*
> > +	 * Lame to do this here, but the scheduler cannot be locked
> > +	 * from the outside, so we move cgroups from inside sched/.
> > +	 */
> > +	rcu_assign_pointer(task->cgroups, to);
> > +
> > +	if (task_flags)
> > +		psi_task_change(task, now, 0, task_flags);
> > +
> > +	task_rq_unlock(rq, task, &rf);
> > +}
> 
> Why is that not part of cpu_cgroup_attach() / sched_move_task() ?

Hm, there is some overlap, but it's not the same operation.

cpu_cgroup_attach() handles rq migration between cgroups that have the
cpu controller enabled, but psi needs to migrate task counts around
for memory and IO as well, as we always need to know nr_runnable.

The cpu controller is super expensive, though, and e.g. we had to
disable it for cost purposes while still running psi, so it wouldn't
be great to need full hierarchical per-cgroup scheduling policy just
to know the runnable count in a group.

Likewise, I don't think we'd want to change the cgroup core to call
->attach for *all* cgroups and have the callback figure out whether
the controller is actually enabled on them or not for this one case.
