Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 192A76B0033
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 06:48:34 -0400 (EDT)
Date: Fri, 5 Jul 2013 12:48:28 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 07/13] sched: Split accounting of NUMA hinting faults
 that pass two-stage filter
Message-ID: <20130705104828.GO23916@twins.programming.kicks-ass.net>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-8-git-send-email-mgorman@suse.de>
 <20130703215654.GN17812@cmpxchg.org>
 <20130704092356.GK1875@suse.de>
 <20130704193638.GP17812@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130704193638.GP17812@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 04, 2013 at 03:36:38PM -0400, Johannes Weiner wrote:

> I was going for the opposite conclusion: that it does not matter
> whether memory is accessed privately or in a shared fashion, because
> there is no obvious connection to its access frequency, not to me at
> least.  

There is a relation to access freq; however due to the low sample rate
(once every 100ms or so) we obviously miss all high freq data there.

> > I acknowledge it's a problem and basically I'm making a big assumption
> > that private-dominated workloads are going to be the common case. Threaded
> > application on UMA with heavy amounts of shared data (within cache lines)
> > already suck in terms of performance so I'm expecting programmers already
> > try and avoid this sort of sharing. Obviously we are at a page granularity
> > here so the assumption will depend entirely on alignments and buffer sizes
> > so it might still fall apart.
> 
> Don't basically all VM-based mulithreaded programs have this usage
> pattern?  The whole runtime (text, heap) is shared between threads.
> If some thread-local memory spills over to another node, should the
> scheduler move this thread off node from a memory standpoint?  I don't
> think so at all.  I would expect it to always gravitate back towards
> this node with the VM on it, only get moved off for CPU load reasons,
> and get moved back as soon as the load situation permits.

All data being allocated on the same heap and being shared in the access
sense doesn't imply all threads will indeed use all data; even if TLS is
not used.

For a concurrent program to reach any useful level of concurrency gain
you need data partitioning. Threads must work on different data sets
otherwise they'd constantly be waiting on serialization -- which makes
your concurrency gain tank.

There's two main issues here:

Firstly; the question is if there's much false sharing on page
granularity. Typically you want the compute time per data fragment to be
significantly higher than the demux + mux overhead which favours larger
data units.

Secondly; you want your scan freq to be at least half the compute time
per data fragment. Otherwise you'll run the risk of not seeing the data
being local to that thread.

So for optimal benefit you want to minimize sharing pages between data
fragments and have your data fragment compute time as long as possible.
Luckily both are also goals for maximizing concurrency gain so we should
be good there.

This should cover all 'traditional' concurrent stuff; most of the 'new'
concurrency stuff can be different though -- some of it simply never
thought/designed for concurrency and just hopes it works. Others most
notably the multi-core concurrency stuff assumes the demux+mux cost are
_very_ low and therefore the data fragment and associated compute time
shrink to useless levels :/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
