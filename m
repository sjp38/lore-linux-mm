Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 837D56B04ED
	for <linux-mm@kvack.org>; Wed,  9 May 2018 07:38:57 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m8-v6so7613840pgq.9
        for <linux-mm@kvack.org>; Wed, 09 May 2018 04:38:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z11si10176964pfm.330.2018.05.09.04.38.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 04:38:56 -0700 (PDT)
Date: Wed, 9 May 2018 13:38:49 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180509113849.GJ12235@hirez.programming.kicks-ass.net>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-7-hannes@cmpxchg.org>
 <20180509104618.GP12217@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509104618.GP12217@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Wed, May 09, 2018 at 12:46:18PM +0200, Peter Zijlstra wrote:
> On Mon, May 07, 2018 at 05:01:34PM -0400, Johannes Weiner wrote:
> 
> > @@ -2038,6 +2038,7 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
> >  	cpu = select_task_rq(p, p->wake_cpu, SD_BALANCE_WAKE, wake_flags);
> >  	if (task_cpu(p) != cpu) {
> >  		wake_flags |= WF_MIGRATED;
> > +		psi_ttwu_dequeue(p);
> >  		set_task_cpu(p, cpu);
> >  	}
> >  
> 
> > +static inline void psi_ttwu_dequeue(struct task_struct *p)
> > +{
> > +	/*
> > +	 * Is the task being migrated during a wakeup? Make sure to
> > +	 * deregister its sleep-persistent psi states from the old
> > +	 * queue, and let psi_enqueue() know it has to requeue.
> > +	 */
> > +	if (unlikely(p->in_iowait || (p->flags & PF_MEMSTALL))) {
> > +		struct rq_flags rf;
> > +		struct rq *rq;
> > +		int clear = 0;
> > +
> > +		if (p->in_iowait)
> > +			clear |= TSK_IOWAIT;
> > +		if (p->flags & PF_MEMSTALL)
> > +			clear |= TSK_MEMSTALL;
> > +
> > +		rq = __task_rq_lock(p, &rf);
> > +		update_rq_clock(rq);
> > +		psi_task_change(p, rq_clock(rq), clear, 0);
> > +		p->sched_psi_wake_requeue = 1;
> > +		__task_rq_unlock(rq, &rf);
> > +	}
> > +}
> 
> Yeah, no... not happening.
> 
> We spend a lot of time to never touch the old rq->lock on wakeups. Mason
> was the one pushing for that, so he should very well know this.
> 
> The one cross-cpu atomic (iowait) is already a problem (the whole iowait
> accounting being useless makes it even worse), adding significant remote
> prodding is just really bad.

Also, since all you need is the global number, I don't think you
actually need any of this. See what we do for nr_uninterruptible.

In general I think you want to (re)read loadavg.c some more, and maybe
reuse a bit more of that.
