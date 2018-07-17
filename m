Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A27316B0266
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:41:14 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m185-v6so1438963itm.1
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:41:14 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id j26-v6si893112jam.96.2018.07.17.08.41.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Jul 2018 08:41:13 -0700 (PDT)
Date: Tue, 17 Jul 2018 17:40:59 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 09/10] psi: cgroup support
Message-ID: <20180717154059.GB2476@hirez.programming.kicks-ass.net>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-10-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712172942.10094-10-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 12, 2018 at 01:29:41PM -0400, Johannes Weiner wrote:
> +/**
> + * cgroup_move_task - move task to a different cgroup
> + * @task: the task
> + * @to: the target css_set
> + *
> + * Move task to a new cgroup and safely migrate its associated stall
> + * state between the different groups.
> + *
> + * This function acquires the task's rq lock to lock out concurrent
> + * changes to the task's scheduling state and - in case the task is
> + * running - concurrent changes to its stall state.
> + */
> +void cgroup_move_task(struct task_struct *task, struct css_set *to)
> +{
> +	unsigned int task_flags = 0;
> +	struct rq_flags rf;
> +	struct rq *rq;
> +	u64 now;
> +
> +	rq = task_rq_lock(task, &rf);
> +
> +	if (task_on_rq_queued(task)) {
> +		task_flags = TSK_RUNNING;
> +	} else if (task->in_iowait) {
> +		task_flags = TSK_IOWAIT;
> +	}
> +	if (task->flags & PF_MEMSTALL)
> +		task_flags |= TSK_MEMSTALL;
> +
> +	if (task_flags) {
> +		update_rq_clock(rq);
> +		now = rq_clock(rq);
> +		psi_task_change(task, now, task_flags, 0);
> +	}
> +
> +	/*
> +	 * Lame to do this here, but the scheduler cannot be locked
> +	 * from the outside, so we move cgroups from inside sched/.
> +	 */
> +	rcu_assign_pointer(task->cgroups, to);
> +
> +	if (task_flags)
> +		psi_task_change(task, now, 0, task_flags);
> +
> +	task_rq_unlock(rq, task, &rf);
> +}

Why is that not part of cpu_cgroup_attach() / sched_move_task() ?
