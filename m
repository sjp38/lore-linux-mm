Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2A856B05B1
	for <linux-mm@kvack.org>; Sun, 30 Jul 2017 11:28:31 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v102so43881971wrb.2
        for <linux-mm@kvack.org>; Sun, 30 Jul 2017 08:28:31 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w21si4088914eda.64.2017.07.30.08.28.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 30 Jul 2017 08:28:30 -0700 (PDT)
Date: Sun, 30 Jul 2017 11:28:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] mm/sched: memdelay: memory health interface for
 systems and workloads
Message-ID: <20170730152813.GA26672@cmpxchg.org>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
 <20170727153010.23347-4-hannes@cmpxchg.org>
 <20170729091055.GA6524@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170729091055.GA6524@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Sat, Jul 29, 2017 at 11:10:55AM +0200, Peter Zijlstra wrote:
> On Thu, Jul 27, 2017 at 11:30:10AM -0400, Johannes Weiner wrote:
> > +static void domain_cpu_update(struct memdelay_domain *md, int cpu,
> > +			      int old, int new)
> > +{
> > +	enum memdelay_domain_state state;
> > +	struct memdelay_domain_cpu *mdc;
> > +	unsigned long now, delta;
> > +	unsigned long flags;
> > +
> > +	mdc = per_cpu_ptr(md->mdcs, cpu);
> > +	spin_lock_irqsave(&mdc->lock, flags);
> 
> Afaict this is inside scheduler locks, this cannot be a spinlock. Also,
> do we really want to add more atomics there?

I think we should be able to get away without an additional lock and
rely on the rq lock instead. schedule, enqueue, dequeue already hold
it, memdelay_enter/leave could be added. I need to think about what to
do with try_to_wake_up in order to get the cpu move accounting inside
the locked section of ttwu_queue(), but that should be doable too.

> > +	if (old) {
> > +		WARN_ONCE(!mdc->tasks[old], "cpu=%d old=%d new=%d counter=%d\n",
> > +			  cpu, old, new, mdc->tasks[old]);
> > +		mdc->tasks[old] -= 1;
> > +	}
> > +	if (new)
> > +		mdc->tasks[new] += 1;
> > +
> > +	/*
> > +	 * The domain is somewhat delayed when a number of tasks are
> > +	 * delayed but there are still others running the workload.
> > +	 *
> > +	 * The domain is fully delayed when all non-idle tasks on the
> > +	 * CPU are delayed, or when a delayed task is actively running
> > +	 * and preventing productive tasks from making headway.
> > +	 *
> > +	 * The state times then add up over all CPUs in the domain: if
> > +	 * the domain is fully blocked on one CPU and there is another
> > +	 * one running the workload, the domain is considered fully
> > +	 * blocked 50% of the time.
> > +	 */
> > +	if (!mdc->tasks[MTS_DELAYED_ACTIVE] && !mdc->tasks[MTS_DELAYED])
> > +		state = MDS_NONE;
> > +	else if (mdc->tasks[MTS_WORKING])
> > +		state = MDS_SOME;
> > +	else
> > +		state = MDS_FULL;
> > +
> > +	if (mdc->state == state)
> > +		goto unlock;
> > +
> > +	now = ktime_to_ns(ktime_get());
> 
> ktime_get_ns(), also no ktime in scheduler code.

Okay.

I actually don't need a time source that's comparable across CPUs
since accounting periods are always fully contained within one
CPU. From the comment docs, it sounds like cpu_clock() is what I want
to use there?

> > +	/* Account domain state changes */
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(task);
> > +	do {
> > +		struct memdelay_domain *md;
> > +
> > +		md = memcg_domain(memcg);
> > +		md->aggregate += delay;
> > +		domain_cpu_update(md, cpu, old, new);
> > +	} while (memcg && (memcg = parent_mem_cgroup(memcg)));
> > +	rcu_read_unlock();
> 
> We are _NOT_ going to do a 3rd cgroup iteration for every task action.

I'll look into that.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
