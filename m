Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 9EDDD6B002B
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 15:29:39 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so1570508bkc.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 12:29:37 -0800 (PST)
Date: Mon, 10 Dec 2012 21:29:33 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: NUMA performance comparison between three NUMA kernels and
 mainline. [Mid-size NUMA system edition.]
Message-ID: <20121210202933.GA15363@gmail.com>
References: <1354913744-29902-1-git-send-email-mingo@kernel.org>
 <20121207215357.GA30130@gmail.com>
 <20121210123336.GI1009@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121210123336.GI1009@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mike Galbraith <efault@gmx.de>


* Mel Gorman <mgorman@suse.de> wrote:

> > NUMA convergence latency measurements
> > -------------------------------------
> > 
> > 'NUMA convergence' latency is the number of seconds a 
> > workload takes to reach 'perfectly NUMA balanced' state. 
> > This is measured on the CPU placement side: once it has 
> > converged then memory typically follows within a couple of 
> > seconds.
> 
> This is a sortof misleading metric so be wary of it as the 
> speed a workload converges is not necessarily useful. It only 
> makes a difference for short-lived workloads or during phase 
> changes. If the workload is short-lived, it's not interesting 
> anyway. If the workload is rapidly changing phases then the 
> migration costs can be a major factor and rapidly converging 
> might actually be slower overall.
> 
> The speed the workload converges will depend very heavily on 
> when the PTEs are marked pte_numa and when the faults are 
> incurred. If this is happening very rapidly then a workload 
> will converge quickly *but* this can incur a high system CPU 
> cost (PTE scanning, fault trapping etc).  This metric can be 
> gamed by always scanning rapidly but the overall performance 
> may be worse.
> 
> I'm not saying that this metric is not useful, it is. Just be 
> careful of optimising for it. numacores system CPU usage has 
> been really high in a number of benchmarks and it may be 
> because you are optimising to minimise time to convergence.

You are missing a big part of the NUMA balancing picture here: 
the primary use of 'latency of convergence' is to determine 
whether a workload converges *at all*.

For example if you look at the 4-process / 8-threads-per-process 
latency results:

                            [ Lower numbers are better. ]
 
  [test unit]            :   v3.7 |balancenuma-v10|  AutoNUMA-v28 |   numa-u-v3   |
 ------------------------------------------------------------------------------------------
  4x8-convergence        :  101.1 |         101.3 |           3.4 |           3.9 |  secs

You'll see that balancenuma does not converge this workload. 

Where does such a workload matter? For example in the 4x JVM 
SPECjbb tests that Thomas Gleixner has reported today:

    http://lkml.org/lkml/2012/12/10/437

There balancenuma does worse than AutoNUMA and the -v3 tree 
exactly because it does not NUMA-converge as well (or at all).

> I'm trying to understand what you're measuring a bit better.  
> Take 1x4 for example -- one process, 4 threads. If I'm reading 
> this description then all 4 threads use the same memory. Is 
> this correct? If so, this is basically a variation of numa01 
> which is an adverse workload. [...]

No, 1x4 and 1x8 are like the SPECjbb JVM tests you have been 
performing - not an 'adverse' workload. The threads of the JVM 
are sharing memory significantly enough to justify moving them 
on the same node.

> [...]  balancenuma will not migrate memory in this case as 
> it'll never get past the two-stage filter. If there are few 
> threads, it might never get scheduled on a new node in which 
> case it'll also do nothing.
> 
> The correct action in this case is to interleave memory and 
> spread the tasks between nodes but it lacks the information to 
> do that. [...]

No, the correct action is to move related threads close to each 
other.

> [...] This was deliberate as I was expecting numacore or 
> autonuma to be rebased on top and I didn't want to collide.
> 
> Does the memory requirement of all threads fit in a single 
> node? This is related to my second question -- how do you 
> define convergence?

NUMA-convergence is to achieve the ideal CPU and memory 
placement of tasks.

> > The 'balancenuma' kernel does not converge any of the 
> > workloads where worker threads or processes relate to each 
> > other.
> 
> I'd like to know if it is because the workload fits on one 
> node. If the buffers are all really small, balancenuma would 
> have skipped them entirely for example due to this check
> 
>         /* Skip small VMAs. They are not likely to be of relevance */
>         if (((vma->vm_end - vma->vm_start) >> PAGE_SHIFT) < HPAGE_PMD_NR)
>                 continue;

No, the memory areas are larger than 2MB.

> Another possible explanation is that in the 4x4 case that the 
> processes threads are getting scheduled on separate nodes. As 
> each thread is sharing data it would not get past the 
> two-stage filter.
> 
> How realistic is it that threads are accessing the same data? 

In practice? Very ...

> That looks like it would be a bad idea even from a caching 
> perspective if the data is being updated. I would expect that 
> the majority of HPC workloads would have each thread accessing 
> mostly private data until the final stages where the results 
> are aggregated together.

You tested such a workload many times in the past: the 4x JVM 
SPECjbb test ...

> > NUMA workload bandwidth measurements
> > ------------------------------------
> > 
> > The other set of numbers I've collected are workload 
> > bandwidth measurements, run over 20 seconds. Using 20 
> > seconds gives a healthy mix of pre-convergence and 
> > post-convergence bandwidth,
> 
> 20 seconds is *really* short. That might not even be enough 
> time for autonumas knumad thread to find the process and 
> update it as IIRC it starts pretty slowly.

If you check the convergence latency tables you'll see that 
AutoNUMA is able to converge within 20 seconds.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
