Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5DC6B0006
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:46:42 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w21-v6so1005273wmc.4
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:46:42 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id p127-v6si1505023wmg.127.2018.07.18.05.46.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Jul 2018 05:46:40 -0700 (PDT)
Date: Wed, 18 Jul 2018 14:46:27 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180718124627.GD2476@hirez.programming.kicks-ass.net>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712172942.10094-9-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:

> +static inline void psi_enqueue(struct task_struct *p, u64 now, bool wakeup)
> +{
> +	int clear = 0, set = TSK_RUNNING;
> +
> +	if (psi_disabled)
> +		return;
> +
> +	if (!wakeup || p->sched_psi_wake_requeue) {
> +		if (p->flags & PF_MEMSTALL)
> +			set |= TSK_MEMSTALL;
> +		if (p->sched_psi_wake_requeue)
> +			p->sched_psi_wake_requeue = 0;
> +	} else {
> +		if (p->in_iowait)
> +			clear |= TSK_IOWAIT;
> +	}
> +
> +	psi_task_change(p, now, clear, set);
> +}
> +
> +static inline void psi_dequeue(struct task_struct *p, u64 now, bool sleep)
> +{
> +	int clear = TSK_RUNNING, set = 0;
> +
> +	if (psi_disabled)
> +		return;
> +
> +	if (!sleep) {
> +		if (p->flags & PF_MEMSTALL)
> +			clear |= TSK_MEMSTALL;
> +	} else {
> +		if (p->in_iowait)
> +			set |= TSK_IOWAIT;
> +	}
> +
> +	psi_task_change(p, now, clear, set);
> +}

> +/**
> + * psi_memstall_enter - mark the beginning of a memory stall section
> + * @flags: flags to handle nested sections
> + *
> + * Marks the calling task as being stalled due to a lack of memory,
> + * such as waiting for a refault or performing reclaim.
> + */
> +void psi_memstall_enter(unsigned long *flags)
> +{
> +	struct rq_flags rf;
> +	struct rq *rq;
> +
> +	if (psi_disabled)
> +		return;
> +
> +	*flags = current->flags & PF_MEMSTALL;
> +	if (*flags)
> +		return;
> +	/*
> +	 * PF_MEMSTALL setting & accounting needs to be atomic wrt
> +	 * changes to the task's scheduling state, otherwise we can
> +	 * race with CPU migration.
> +	 */
> +	rq = this_rq_lock_irq(&rf);
> +
> +	update_rq_clock(rq);
> +
> +	current->flags |= PF_MEMSTALL;
> +	psi_task_change(current, rq_clock(rq), 0, TSK_MEMSTALL);
> +
> +	rq_unlock_irq(rq, &rf);
> +}

I'm confused by this whole MEMSTALL thing... I thought the idea was to
account the time we were _blocked_ because of memstall, but you seem to
count the time we're _running_ with PF_MEMSTALL.


And esp. the wait_on_page_bit_common caller seems performance sensitive,
and the above function is quite expensive.
