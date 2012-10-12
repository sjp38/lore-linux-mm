Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id EC4286B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 21:46:19 -0400 (EDT)
Date: Fri, 12 Oct 2012 03:45:53 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/33] AutoNUMA27
Message-ID: <20121012014553.GD1818@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <20121011213432.GQ3317@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121011213432.GQ3317@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Hi Mel,

On Thu, Oct 11, 2012 at 10:34:32PM +0100, Mel Gorman wrote:
> So after getting through the full review of it, there wasn't anything
> I could not stand. I think it's *very* heavy on some of the paths like
> the idle balancer which I was not keen on and the fault paths are also
> quite heavy.  I think the weight on some of these paths can be reduced
> but not to 0 if the objectives to autonuma are to be met.
> 
> I'm not fully convinced that the task exchange is actually necessary or
> beneficial because it somewhat assumes that there is a symmetry between CPU
> and memory balancing that may not be true. The fact that it only considers

The problem is that without an active task exchange and no explicit
call to stop_one_cpu*, there's no way to migrate a currently running
task and clearly we need that. We can indefinitely wait hoping the
task goes to sleep and leaves the CPU idle, or that a couple of other
tasks start and trigger load balance events.

We must move tasks even if all cpus are in a steady rq->nr_running ==
1 state and there's no other scheduler balance event that could
possibly attempt to move tasks around in such a steady state.

Of course one could hack the active idle balancing so that it does the
active NUMA balancing action, but that would be a purely artificial
complication: it would add unnecessary delay and it would provide no
benefit whatsoever.

Why don't we dump the active idle balancing too, and we hack the load
balancing to do the active idle balancing as well? Of course then the
two will be more integrated. But it'll be a mess and slower and
there's a good reason why they exist as totally separated pieces of
code working in parallel.

We can integrate it more, but in my view the result would be worse and
more complicated. Last but not the least messing the idle balancing
code to do an active NUMA balancing action (somehow invoking
stop_one_cpu* in the steady state described above) would force even
cellphones and UP kernels to deal with NUMA code somehow.

> tasks that are currently running feels a bit random but examining all tasks
> that recently ran on the node would be far too expensive to there is no

So far this seems a good tradeoff. Nothing will prevent us to scan
deeper into the runqueues later if find a way to do that efficiently.

> good answer. You are caught between a rock and a hard place and either
> direction you go is wrong for different reasons. You need something more

I think you described the problem perfectly ;).

> frequent than scans (because it'll converge too slowly) but doing it from
> the balancer misses some tasks and may run too frequently and it's unclear
> how it effects the current load balancer decisions. I don't have a good
> alternative solution for this but ideally it would be better integrated with
> the existing scheduler when there is more data on what those scheduling
> decisions should be. That will only come from a wide range of testing and
> the inevitable bug reports.
> 
> That said, this is concentrating on the problems without considering the
> situations where it would work very well.  I think it'll come down to HPC
> and anything jitter-sensitive will hate this while workloads like JVM,
> virtualisation or anything that uses a lot of memory without caring about
> placement will love it. It's not perfect but it's better than incurring
> the cost of remote access unconditionally.

Full agreement.

Your detailed full review was very appreciated, thanks!

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
