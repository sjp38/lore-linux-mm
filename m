Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2246B0567
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 15:43:57 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y206so3833572wmd.1
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 12:43:57 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id y30si18651441edc.248.2017.07.28.12.43.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 28 Jul 2017 12:43:55 -0700 (PDT)
Date: Fri, 28 Jul 2017 15:43:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/3] memdelay: memory health metric for systems and
 workloads
Message-ID: <20170728194337.GA18981@cmpxchg.org>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
 <20170727134325.2c8cff2a6dc84e34ae6dc8ab@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727134325.2c8cff2a6dc84e34ae6dc8ab@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi Andrew,

On Thu, Jul 27, 2017 at 01:43:25PM -0700, Andrew Morton wrote:
> On Thu, 27 Jul 2017 11:30:07 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > This patch series implements a fine-grained metric for memory
> > health.
> 
> I assume some Documentation/ is forthcoming.

Yep, I'll describe the interface and how to use this more extensively.

> Consuming another page flag hurts.  What's our current status there?

I would say we can make it 64-bit only, but I also need this refault
distinction flag in the LRU balancing patches [1] to apply pressure on
anon pages only when the page cache is actually thrashing, not when
it's just transitioning to another workingset. So let's see...

20 flags are always defined.

21 if you have an MMU.

23 with the zone bits for DMA, Normal, HighMem, Movable.

29 with the sparsemem section bits,

30 if PAE is enabled.

On that config, NUMA gets 2 bits for 4 nodes. If I take the 31st bit,
it'd be left with 2 possible nodes. If that's not enough, that system
can switch to discontigmem and regain the 6 or 7 sparsemem bits.

> I'd be interested in seeing some usage examples.  Perhaps anecdotes
> where "we observed problem X so we used memdelay in manner Y and saw
> result Z".

The very first thing that had me look at this was the pathological
behavior of memory pressure after switching my systems from spinning
disks to SSDs. Just like vmpressure, the OOM killer depends on reclaim
efficiency dropping through the floor - but that doesn't really happen
anymore. Sometimes my systems lock up for seconds, sometimes minutes,
or until I hard-reset them. The page cache, including executables, is
thrashing like crazy while reclaim efficiency hovers around 100%.

The same happens at FB data centers, where we lose machines during
peak times with no kernel-side remedy for recovering this livelock.

The OOM killer really needs to be hooked up to a portable measure of
thrashing impact rather than an inability of the VM to recycle pages.
I think expressing this cutoff in terms of unproductive time makes the
most sense: e.g. 60%+ of the last 10 seconds of elapsed walltime the
system was doing nothing but waiting for refaults or reclaiming; time
to kill something to free up memory and reduce access frequencies.

But even before OOM, we need to know when we start packing machines
and containers too tightly in terms of memory. Free pages don't mean
anything because of the page cache, and the refault rate on its own
doesn't tell you anything about throughput or latency deterioration.

A recurring scenario for me is that somebody has a machine running a
workload with peaks of 100% CPU, 100% IO, bursts of refaults and a
slowdown in the application. What resource is really lacking here? A
lack of memory can result in high CPU and IO times, but it could also
be mostly the application's own appetite for those resources. The
memdelay code shows us how much of the slowdown is caused by memory.

Figuring this out with tracing and profiling is *sometimes* possible,
but takes a ridiculous amount of effort and a reproducible workload.
In many cases it's not an option due to the scale we're dealing with.

For example, we have large pools of machines that run some hundred
jobs whose peak activity depends in part on factors out of our
control, such as user activity. When the peaks of several jobs align,
their individual throughput and latency goes down, and like above we
see the CPU, IO, latency spikes. Separating out how much of that is
due to memory then feeds into the job scheduler, which adjusts the job
placement, cgroup limits etc. accordingly throughout the pool.

Another thing is detecting regressions. Kernel developers tend to run
handpicked, idempotent A/B tests, on single machines, to detect
walltime impact of VM changes. That's often not very representative of
real applications. By tracking memdelay trends averaged over thousands
of machines that run similar workloads, we can tell whether a kernel
upgrade introduced a VM regression that matters to real applications
down to sub-percent walltime impact fairly easily and reliably.

Even with workloads that have their own clear throughput metrics to
detect regressions, knowing where to look makes finding problems
easier, which makes upgrades faster, which means we can run yet more
recent kernels :)

> I assume that some userspace code which utilizes this interface exists
> already.  What's the long-term plan here?  systemd changes?

We're putting it into our custom job scheduler/load balancers and
fleet monitoring infrastructure to track capacity and regressions.

System health monitoring tools like top, atop etc. can incorporate
this in their summaries as well as per-task statistics.

Things like systemd-cgtop that give container overviews can as well.

And as mentioned above, IMO the OOM killer is a prime candidate for
being an in-kernel user of this.

Thanks

[1] https://lwn.net/Articles/690079/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
