Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB2546B04BD
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 14:42:15 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v31so47803306wrc.7
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 11:42:15 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w14si13423001edi.514.2017.07.31.11.42.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 31 Jul 2017 11:42:12 -0700 (PDT)
Date: Mon, 31 Jul 2017 14:41:42 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] mm/sched: memdelay: memory health interface for
 systems and workloads
Message-ID: <20170731184142.GA30943@cmpxchg.org>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
 <20170727153010.23347-4-hannes@cmpxchg.org>
 <20170729091055.GA6524@worktop.programming.kicks-ass.net>
 <20170730152813.GA26672@cmpxchg.org>
 <20170731083111.tgjgkwge5dgt5m2e@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731083111.tgjgkwge5dgt5m2e@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jul 31, 2017 at 10:31:11AM +0200, Peter Zijlstra wrote:
> On Sun, Jul 30, 2017 at 11:28:13AM -0400, Johannes Weiner wrote:
> > On Sat, Jul 29, 2017 at 11:10:55AM +0200, Peter Zijlstra wrote:
> > > On Thu, Jul 27, 2017 at 11:30:10AM -0400, Johannes Weiner wrote:
> > > > +static void domain_cpu_update(struct memdelay_domain *md, int cpu,
> > > > +			      int old, int new)
> > > > +{
> > > > +	enum memdelay_domain_state state;
> > > > +	struct memdelay_domain_cpu *mdc;
> > > > +	unsigned long now, delta;
> > > > +	unsigned long flags;
> > > > +
> > > > +	mdc = per_cpu_ptr(md->mdcs, cpu);
> > > > +	spin_lock_irqsave(&mdc->lock, flags);
> > > 
> > > Afaict this is inside scheduler locks, this cannot be a spinlock. Also,
> > > do we really want to add more atomics there?
> > 
> > I think we should be able to get away without an additional lock and
> > rely on the rq lock instead. schedule, enqueue, dequeue already hold
> > it, memdelay_enter/leave could be added. I need to think about what to
> > do with try_to_wake_up in order to get the cpu move accounting inside
> > the locked section of ttwu_queue(), but that should be doable too.
> 
> So could you start by describing what actual statistics we need? Because
> as is the scheduler already does a gazillion stats and why can't re
> repurpose some of those?

If that's possible, that would be great of course.

We want to be able to tell how many tasks in a domain (the system or a
memory cgroup) are inside a memdelay section as opposed to how many
are in a "productive" state such as runnable or iowait. Then derive
from that whether the domain as a whole is unproductive (all non-idle
tasks memdelayed), or partially unproductive (some delayed, but CPUs
are productive or there are iowait tasks). Then derive the percentages
of walltime the domain spends partially or fully unproductive.

For that we need per-domain counters for

	1) nr of tasks in memdelay sections
	2) nr of iowait or runnable/queued tasks that are NOT inside
	   memdelay sections

The memdelay and runnable counts need to be per-cpu as well. (The idea
is this: if you have one CPU and some tasks are delayed while others
are runnable, you're 100% partially productive, as the CPU is fully
used. But if you have two CPUs, and the tasks on one CPU are all
runnable while the tasks on the others are all delayed, the domain is
50% of the time fully unproductive (and not 100% partially productive)
as half the available CPU time is being squandered by delays).

On the system-level, we already count runnable/queued per cpu through
rq->nr_running.

However, we need to distinguish between productive runnables and tasks
that are in runnable while in a memdelay section (doing reclaim). The
current counters don't do that.

Lastly, and somewhat obscurely, the presence of runnable tasks means
that usually the domain is at least partially productive. But if the
CPU is used by a task in a memdelay section (direct reclaim), the
domain is fully unproductive (unless there are iowait tasks in the
domain, since they make "progress" without CPU). So we need to track
task_current() && task_memdelayed() per-domain per-cpu as well.

Now, thinking only about the system-level, we could split
rq->nr_running into a sets of delayed and non-delayed counters
(present them as sum in all current read sides).

Adding an rq counter for tasks inside memdelay sections should be
straight-forward as well (except for maybe the migration cost of that
state between CPUs in ttwu that Mike pointed out).

That leaves the question of how to track these numbers per cgroup at
an acceptable cost. The idea for a tree of cgroups is that walltime
impact of delays at each level is reported for all tasks at or below
that level. E.g. a leave group aggregates the state of its own tasks,
the root/system aggregates the state of all tasks in the system; hence
the propagation of the task state counters up the hierarchy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
