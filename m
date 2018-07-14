Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2066F6B0007
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 05:02:55 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id q18-v6so21264340pll.3
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 02:02:55 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x1-v6si19580280pga.480.2018.07.14.02.02.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Jul 2018 02:02:54 -0700 (PDT)
Date: Sat, 14 Jul 2018 11:02:44 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180714090244.GC4920@worktop.programming.kicks-ass.net>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180713092153.GU2494@hirez.programming.kicks-ass.net>
 <20180713161756.GA21168@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180713161756.GA21168@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Jul 13, 2018 at 12:17:56PM -0400, Johannes Weiner wrote:
> On Fri, Jul 13, 2018 at 11:21:53AM +0200, Peter Zijlstra wrote:
> > On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> > > +static inline void psi_ttwu_dequeue(struct task_struct *p)
> > > +{
> > > +	if (psi_disabled)
> > > +		return;
> > > +	/*
> > > +	 * Is the task being migrated during a wakeup? Make sure to
> > > +	 * deregister its sleep-persistent psi states from the old
> > > +	 * queue, and let psi_enqueue() know it has to requeue.
> > > +	 */
> > > +	if (unlikely(p->in_iowait || (p->flags & PF_MEMSTALL))) {
> > > +		struct rq_flags rf;
> > > +		struct rq *rq;
> > > +		int clear = 0;
> > > +
> > > +		if (p->in_iowait)
> > > +			clear |= TSK_IOWAIT;
> > > +		if (p->flags & PF_MEMSTALL)
> > > +			clear |= TSK_MEMSTALL;
> > > +
> > > +		rq = __task_rq_lock(p, &rf);
> > > +		update_rq_clock(rq);
> > > +		psi_task_change(p, rq_clock(rq), clear, 0);
> > > +		p->sched_psi_wake_requeue = 1;
> > > +		__task_rq_unlock(rq, &rf);
> > > +	}
> > > +}
> > 
> > Still NAK, what happened to this here:

> That's my thought process, anyway. I'd be more than happy to make this
> more lightweight, but I don't see a way to do it without losing
> significant functional precision.

I think you're going to have to. We put a lot of effort into not taking
the old rq->lock on remote wakeups and got a significant performance
benefit from that.

You just utterly destroyed that for workloads with a high number of
iowait wakeups.
