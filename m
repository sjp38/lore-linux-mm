Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 007B36B04D7
	for <linux-mm@kvack.org>; Wed,  9 May 2018 06:21:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n78so26059384pfj.4
        for <linux-mm@kvack.org>; Wed, 09 May 2018 03:21:14 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r8-v6si25864411pli.119.2018.05.09.03.21.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 03:21:14 -0700 (PDT)
Date: Wed, 9 May 2018 12:21:00 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180509102100.GN12217@hirez.programming.kicks-ass.net>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-7-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180507210135.1823-7-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Mon, May 07, 2018 at 05:01:34PM -0400, Johannes Weiner wrote:
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
> +	*flags = current->flags & PF_MEMSTALL;
> +	if (*flags)
> +		return;
> +	/*
> +	 * PF_MEMSTALL setting & accounting needs to be atomic wrt
> +	 * changes to the task's scheduling state, otherwise we can
> +	 * race with CPU migration.
> +	 */
> +	local_irq_disable();
> +	rq = this_rq();
> +	raw_spin_lock(&rq->lock);
> +	rq_pin_lock(rq, &rf);

Given that churn in sched.h, you seen rq_lock() and friends.

Either write this like:

	local_irq_disable();
	rq = this_rq();
	rq_lock(rq, &rf);

Or instroduce "rq = this_rq_lock_irq()", which we could also use in
do_sched_yield().

> +	update_rq_clock(rq);
> +
> +	current->flags |= PF_MEMSTALL;
> +	psi_task_change(current, rq_clock(rq), 0, TSK_MEMSTALL);
> +
> +	rq_unpin_lock(rq, &rf);
> +	raw_spin_unlock(&rq->lock);
> +	local_irq_enable();

That's called rq_unlock_irq().

> +}
> +
> +/**
> + * psi_memstall_leave - mark the end of an memory stall section
> + * @flags: flags to handle nested memdelay sections
> + *
> + * Marks the calling task as no longer stalled due to lack of memory.
> + */
> +void psi_memstall_leave(unsigned long *flags)
> +{
> +	struct rq_flags rf;
> +	struct rq *rq;
> +
> +	if (*flags)
> +		return;
> +	/*
> +	 * PF_MEMSTALL clearing & accounting needs to be atomic wrt
> +	 * changes to the task's scheduling state, otherwise we could
> +	 * race with CPU migration.
> +	 */
> +	local_irq_disable();
> +	rq = this_rq();
> +	raw_spin_lock(&rq->lock);
> +	rq_pin_lock(rq, &rf);
> +
> +	update_rq_clock(rq);
> +
> +	current->flags &= ~PF_MEMSTALL;
> +	psi_task_change(current, rq_clock(rq), TSK_MEMSTALL, 0);
> +
> +	rq_unpin_lock(rq, &rf);
> +	raw_spin_unlock(&rq->lock);
> +	local_irq_enable();
> +}

Idem.
