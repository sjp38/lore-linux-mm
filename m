Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A32226B003D
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 04:42:15 -0400 (EDT)
Date: Thu, 23 Apr 2009 10:42:33 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Patch] mm tracepoints update - use case.
Message-ID: <20090423084233.GF599@elte.hu>
References: <1240402037.4682.3.camel@dhcp47-138.lab.bos.redhat.com> <1240428151.11613.46.camel@dhcp-100-19-198.bos.redhat.com> <20090423092933.F6E9.A69D9226@jp.fujitsu.com> <20090422215055.5be60685.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090422215055.5be60685.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Larry Woodman <lwoodman@redhat.com>, =?utf-8?B?RnLpppjpp7tpYw==?= Weisbecker <fweisbec@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, eduard.munteanu@linux360.ro, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, rostedt@goodmis.org
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 23 Apr 2009 09:48:04 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > On Wed, 2009-04-22 at 08:07 -0400, Larry Woodman wrote:
> > > > On Wed, 2009-04-22 at 11:57 +0200, Ingo Molnar wrote:
> > > > > * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > 
> > > > > > In past thread, Andrew pointed out bare page tracer isn't useful. 
> > > > > 
> > > > > (do you have a link to that mail?)
> 
> http://lkml.indiana.edu/hypermail/linux/kernel/0903.0/02674.html
> 
> And Larry's example use case here tends to reinforce what I said then.  Look:
> 
> : In addition I could see that the priority was decremented to zero and
> : that 12342 pages had been reclaimed rather than just enough to satisfy
> : the page allocation request.
> : 
> : -----------------------------------------------------------------------------
> : # tracer: nop
> : #
> : #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
> : #              | |       |          |         |
> : <mem>-10723 [005]  6976.285610: mm_directreclaim_reclaimzone: reclaimed=12342, priority=0
> 
> and
> 
> : -----------------------------------------------------------------------------
> : # tracer: nop
> : #
> : #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
> : #              | |       |          |         |
> :            <mem>-10723 [005]   282.776271: mm_pagereclaim_shrinkzone: reclaimed=12342
> :            <mem>-10723 [005]   282.781209: mm_pagereclaim_shrinkzone: reclaimed=3540
> :            <mem>-10723 [005]   282.801194: mm_pagereclaim_shrinkzone: reclaimed=7528
> : -----------------------------------------------------------------------------
> 
> This diagnosis was successful because the "reclaimed" number was 
> weird. By sheer happy coincidence, page-reclaim is already 
> generating the aggregated numbers for us, and the tracer just 
> prints it out.
> 
> If some other problem is being worked on and if there _isn't_ some 
> convenient already-present aggregated result for the tracer to 
> print, the problem won't be solved.  Unless a vast number of trace 
> events are emitted and problem-specific userspace code is written 
> to aggregate them into something which the developer can use.

Not so in the usescases i made use of tracers. The key is not to 
trace everything, but to have a few key _concepts_ traced 
pervasively. Having a dynamic notion of a per event changes is also 
obviously good. In a fast changing workload you cannot just tell 
based on summary statistics whether rapid changes are the product of 
the inherent entropy of the workload, or the result of the MM being 
confused.

/proc/ statisitics versus good tracing is like the difference 
between a magnifying glass and an electron microscope. Both have 
their strengths, and they are best if used together.

One such conceptual thing in the scheduler is the lifetime of a 
task, its schedule, deschedule and wakeup events. It can already 
show a massive amount of badness in practice, and it only takes a 
few tracepoints to do.

Same goes for the MM IMHO. Number of pages reclaimed is obviously a 
key metric to follow. Larry is an expert who fixed a _lot_ of MM 
crap in the last 5-10 years at Red Hat, so if he says that these 
tracepoints are useful to him, we shouldnt just dismiss that 
experience like that. I wish Larry spent some of his energies on 
fixing the upstream MM too ;-)

A balanced number of MM tracepoints, showing the concepts and the 
inner dynamics of the MM would be useful. We dont need every little 
detail traced (we have the function tracer for that), but a few key 
aspects would be nice to capture ...

pagefaults, allocations, cache-misses, cache flushes and how pages 
shift between various queues in the MM would be a good start IMHO.

Anyway, i suspect your answer means a NAK :-( Would be nice if you 
would suggest a path out of that NAK.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
