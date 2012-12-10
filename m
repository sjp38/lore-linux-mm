Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 8BAAB6B0044
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 16:59:47 -0500 (EST)
Date: Mon, 10 Dec 2012 21:59:39 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: NUMA performance comparison between three NUMA kernels and
 mainline. [Mid-size NUMA system edition.]
Message-ID: <20121210215939.GN1009@suse.de>
References: <1354913744-29902-1-git-send-email-mingo@kernel.org>
 <20121207215357.GA30130@gmail.com>
 <20121210123336.GI1009@suse.de>
 <20121210202933.GA15363@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121210202933.GA15363@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mike Galbraith <efault@gmx.de>

On Mon, Dec 10, 2012 at 09:29:33PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > > NUMA convergence latency measurements
> > > -------------------------------------
> > > 
> > > 'NUMA convergence' latency is the number of seconds a 
> > > workload takes to reach 'perfectly NUMA balanced' state. 
> > > This is measured on the CPU placement side: once it has 
> > > converged then memory typically follows within a couple of 
> > > seconds.
> > 
> > This is a sortof misleading metric so be wary of it as the 
> > speed a workload converges is not necessarily useful. It only 
> > makes a difference for short-lived workloads or during phase 
> > changes. If the workload is short-lived, it's not interesting 
> > anyway. If the workload is rapidly changing phases then the 
> > migration costs can be a major factor and rapidly converging 
> > might actually be slower overall.
> > 
> > The speed the workload converges will depend very heavily on 
> > when the PTEs are marked pte_numa and when the faults are 
> > incurred. If this is happening very rapidly then a workload 
> > will converge quickly *but* this can incur a high system CPU 
> > cost (PTE scanning, fault trapping etc).  This metric can be 
> > gamed by always scanning rapidly but the overall performance 
> > may be worse.
> > 
> > I'm not saying that this metric is not useful, it is. Just be 
> > careful of optimising for it. numacores system CPU usage has 
> > been really high in a number of benchmarks and it may be 
> > because you are optimising to minimise time to convergence.
> 
> You are missing a big part of the NUMA balancing picture here: 
> the primary use of 'latency of convergence' is to determine 
> whether a workload converges *at all*.
> 
> For example if you look at the 4-process / 8-threads-per-process 
> latency results:
> 
>                             [ Lower numbers are better. ]
>  
>   [test unit]            :   v3.7 |balancenuma-v10|  AutoNUMA-v28 |   numa-u-v3   |
>  ------------------------------------------------------------------------------------------
>   4x8-convergence        :  101.1 |         101.3 |           3.4 |           3.9 |  secs
> 
> You'll see that balancenuma does not converge this workload. 
> 

Does it ever get scheduled on a new node? Balancenuma is completely at the
mercy of the scheduler. It makes no attempts to estimate numa loading or
hint to the load balancer. It does not even start trying to converge until
it's scheduled on a new node.

> Where does such a workload matter? For example in the 4x JVM 
> SPECjbb tests that Thomas Gleixner has reported today:
> 
>     http://lkml.org/lkml/2012/12/10/437
> 
> There balancenuma does worse than AutoNUMA and the -v3 tree 
> exactly because it does not NUMA-converge as well (or at all).
> 

I know. To do that I would have had to hook into the scheduler, build
statistics and use the load balancer to move the tasks around. This would
have directly collided with either an autonuma or a numacore rebase.  I've
made this point often enough and I'm getting very sick of repeating myself.

> > I'm trying to understand what you're measuring a bit better.  
> > Take 1x4 for example -- one process, 4 threads. If I'm reading 
> > this description then all 4 threads use the same memory. Is 
> > this correct? If so, this is basically a variation of numa01 
> > which is an adverse workload. [...]
> 
> No, 1x4 and 1x8 are like the SPECjbb JVM tests you have been 
> performing - not an 'adverse' workload. The threads of the JVM 
> are sharing memory significantly enough to justify moving them 
> on the same node.
> 

1x8 would not even be a single JVM test. It would have ranged 1x8 to
1x72 over the course of the entire test. I also still do not know what
granularity you are sharing data on. If they are using the exact same
pages, it's closer to numa01 than specjbb which has semi-private data
depending on how the heap is laid out.

> > [...]  balancenuma will not migrate memory in this case as 
> > it'll never get past the two-stage filter. If there are few 
> > threads, it might never get scheduled on a new node in which 
> > case it'll also do nothing.
> > 
> > The correct action in this case is to interleave memory and 
> > spread the tasks between nodes but it lacks the information to 
> > do that. [...]
> 
> No, the correct action is to move related threads close to each 
> other.
> 
> > [...] This was deliberate as I was expecting numacore or 
> > autonuma to be rebased on top and I didn't want to collide.
> > 
> > Does the memory requirement of all threads fit in a single 
> > node? This is related to my second question -- how do you 
> > define convergence?
> 
> NUMA-convergence is to achieve the ideal CPU and memory 
> placement of tasks.
> 

That is your goal, it does not define what convergence is. You also did not
tell me if all the threads can fit in a single node or not. If they do,
then it's possible that balancenuma never "converges" simply because the
data access are already local so it does not migrate. If your definition
of convergence includes that tasks should migrate to as many nodes as
possible to maxmise memory bandwidth then say that.

> > > The 'balancenuma' kernel does not converge any of the 
> > > workloads where worker threads or processes relate to each 
> > > other.
> > 
> > I'd like to know if it is because the workload fits on one 
> > node. If the buffers are all really small, balancenuma would 
> > have skipped them entirely for example due to this check
> > 
> >         /* Skip small VMAs. They are not likely to be of relevance */
> >         if (((vma->vm_end - vma->vm_start) >> PAGE_SHIFT) < HPAGE_PMD_NR)
> >                 continue;
> 
> No, the memory areas are larger than 2MB.
> 

Does the workload for 1x8 fit in one node? My test machines are
occupied so I cannot check myself right now.

> > Another possible explanation is that in the 4x4 case that the 
> > processes threads are getting scheduled on separate nodes. As 
> > each thread is sharing data it would not get past the 
> > two-stage filter.
> > 
> > How realistic is it that threads are accessing the same data? 
> 
> In practice? Very ...
> 

I'm skeptical. I would expect HPC workloads in particular to isolate data
between threads where possible.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
