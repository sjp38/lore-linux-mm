Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 3240C6B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 07:33:44 -0500 (EST)
Date: Mon, 10 Dec 2012 12:33:36 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: NUMA performance comparison between three NUMA kernels and
 mainline. [Mid-size NUMA system edition.]
Message-ID: <20121210123336.GI1009@suse.de>
References: <1354913744-29902-1-git-send-email-mingo@kernel.org>
 <20121207215357.GA30130@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121207215357.GA30130@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mike Galbraith <efault@gmx.de>

On Fri, Dec 07, 2012 at 10:53:57PM +0100, Ingo Molnar wrote:
> 
> Here's a (strongly NUMA-centric) performance comparison of the 
> three NUMA kernels: the 'balancenuma-v10' tree from Mel, the 
> AutoNUMA-v28 kernel from Andrea and the unified NUMA -v3 tree 
> Peter and me are working on.
> 
> The goal of these measurements is to specifically quantify the 
> NUMA optimization qualities of each of the three NUMA-optimizing 
> kernels.
> 
> There are lots of numbers in this mail and lot of material to 
> read - sorry about that! :-/
> 
> I used the latest available kernel versions everywhere: 
> furthermore the AutoNUMA-v28 tree has been patched with Hugh 
> Dickin's THP-migration support patch, to make it a fair 
> apples-to-apples comparison.
> 

Autonuma is still missing the TLB flush optimisations, migration scalability
fixes and the like. Not a big deal as such, I didn't include them either.

> I have used the 'perf bench numa' tool to do the measurements, 
> which tool can be found at:
> 
>    git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git perf/bench
> 
>    # to build it install numactl-dev[el] and do "cd tools/perf; make -j install'
> 
> To get the raw numbers I ran "perf bench numa mem -a" multiple 
> times on each kernel, on a 32-way, 64 GB RAM, 4-node Opteron 
> test-system. Each kernel used the same base .config, copied from 
> a Fedora RPM kernel, with the NUMA-balancing options enabled.
> 
> ( Note that the testcases are tailored to my test-system: on
>   a smaller system you'd want to run slightly smaller testcases,
>   on a larger system you'd want to run a couple of larger 
>   testcases as well. )
> 
> NUMA convergence latency measurements
> -------------------------------------
> 
> 'NUMA convergence' latency is the number of seconds a workload 
> takes to reach 'perfectly NUMA balanced' state. This is measured 
> on the CPU placement side: once it has converged then memory 
> typically follows within a couple of seconds.
> 

This is a sortof misleading metric so be wary of it as the speed a
workload converges is not necessarily useful. It only makes a difference
for short-lived workloads or during phase changes. If the workload is
short-lived, it's not interesting anyway. If the workload is rapidly
changing phases then the migration costs can be a major factor and rapidly
converging might actually be slower overall.

The speed the workload converges will depend very heavily on when the PTEs
are marked pte_numa and when the faults are incurred. If this is happening
very rapidly then a workload will converge quickly *but* this can incur a
high system CPU cost (PTE scanning, fault trapping etc).  This metric can
be gamed by always scanning rapidly but the overall performance may be worse.

I'm not saying that this metric is not useful, it is. Just be careful of
optimising for it. numacores system CPU usage has been really high in a
number of benchmarks and it may be because you are optimising to minimise
time to convergence.

> Because convergence is not guaranteed, a 100 seconds latency 
> time-out is used in the benchmark. If you see a 100 seconds 
> result in the table it means that that particular NUMA kernel 
> did not manage to converge that workload unit test within 100 
> seconds.
> 
> The NxM denotion means process/thread relationship: a 1x4 test 
> is 1 process with 4 thread that share a workload - a 4x6 test 
> are 4 processes with 6 threads in each process, the processes 
> isolated from each other but the threads working on the same 
> working set.
> 

I'm trying to understand what you're measuring a bit better.  Take 1x4 for
example -- one process, 4 threads. If I'm reading this description then all
4 threads use the same memory. Is this correct? If so, this is basically
a variation of numa01 which is an adverse workload.  balancenuma will
not migrate memory in this case as it'll never get past the two-stage
filter. If there are few threads, it might never get scheduled on a new
node in which case it'll also do nothing.

The correct action in this case is to interleave memory and spread the
tasks between nodes but it lacks the information to do that. This was
deliberate as I was expecting numacore or autonuma to be rebased on top
and I didn't want to collide.

Does the memory requirement of all threads fit in a single node? This is
related to my second question -- how do you define convergence?

balancenuma is driven by where the process gets scheduled and it makes no
special attempt to spread itself out between nodes. If the threads are
always scheduled on the same node then it will never migrate to other
nodes because it does not need to. If you define convergence to be "all
nodes are evenly used" then balancenuma will never converge if all the
threads can stay on the same node.

> I used a wide set of test-cases I collected in the past:
> 
>                            [ Lower numbers are better. ]
> 
>  [test unit]            :   v3.7 |balancenuma-v10|  AutoNUMA-v28 |   numa-u-v3   |
> ------------------------------------------------------------------------------------------
>  1x3-convergence        :  100.1 |         100.0 |           0.2 |           2.3 |  secs
>  1x4-convergence        :  100.2 |         100.1 |         100.2 |           2.1 |  secs
>  1x6-convergence        :  100.3 |         100.4 |         100.8 |           7.3 |  secs
>  2x3-convergence        :  100.6 |         100.6 |         100.5 |           4.1 |  secs
>  3x3-convergence        :  100.6 |         100.5 |         100.5 |           7.6 |  secs
>  4x4-convergence        :  100.6 |         100.5 |           4.1 |           7.4 |  secs
>  4x4-convergence-NOTHP  :  101.1 |         100.5 |          12.2 |           9.2 |  secs
>  4x6-convergence        :    5.4 |         101.2 |          16.6 |          11.7 |  secs
>  4x8-convergence        :  101.1 |         101.3 |           3.4 |           3.9 |  secs
>  8x4-convergence        :  100.9 |         100.8 |          18.3 |           8.9 |  secs
>  8x4-convergence-NOTHP  :  101.9 |         101.0 |          15.7 |          12.1 |  secs
>  3x1-convergence        :    0.7 |           1.0 |           0.8 |           0.9 |  secs
>  4x1-convergence        :    0.6 |           0.8 |           0.8 |           0.7 |  secs
>  8x1-convergence        :    2.8 |           2.9 |           2.9 |           1.2 |  secs
>  16x1-convergence       :    3.5 |           3.7 |           2.5 |           2.0 |  secs
>  32x1-convergence       :    3.6 |           2.8 |           3.0 |           1.9 |  secs
> 

So, I recognise that balancenuma is not converging when the threads use
the same memory. They are all basically variations of numa01. It converges
quickly when the memory is private between threads like numa01_thread_alloc
does for example.

The figures do imply though that numacore is able to identify when multiple
threads are sharing the same memory and interleave them.

> As expected, mainline only manages to converge workloads where 
> each worker process is isolated and the default 
> spread-to-all-nodes scheduling policy creates an ideal layout, 
> regardless of task ordering.
> 
> [ Note that the mainline kernel got a 'lucky strike' convergence 
>   in the 4x6 workload: it's always possible for the workload
>   to accidentally converge. On a repeat test this did not occur, 
>   but I did not erase the outlier because luck is a valid and 
>   existing phenomenon. ]
> 
> The 'balancenuma' kernel does not converge any of the workloads 
> where worker threads or processes relate to each other.
> 

I'd like to know if it is because the workload fits on one node. If the
buffers are all really small, balancenuma would have skipped them
entirely for example due to this check

        /* Skip small VMAs. They are not likely to be of relevance */
        if (((vma->vm_end - vma->vm_start) >> PAGE_SHIFT) < HPAGE_PMD_NR)
                continue;

Another possible explanation is that in the 4x4 case that the processes
threads are getting scheduled on separate nodes. As each thread is sharing
data it would not get past the two-stage filter.

How realistic is it that threads are accessing the same data? That looks
like it would be a bad idea even from a caching perspective if the data
is being updated. I would expect that the majority of HPC workloads would
have each thread accessing mostly private data until the final stages
where the results are aggregated together.

> AutoNUMA does pretty well, but it did not manage to converge for 
> 4 testcases of shared, under-loaded workloads.
> 
> The unified NUMA-v3 tree converged well in every testcase.
> 
> 
> NUMA workload bandwidth measurements
> ------------------------------------
> 
> The other set of numbers I've collected are workload bandwidth 
> measurements, run over 20 seconds. Using 20 seconds gives a 
> healthy mix of pre-convergence and post-convergence bandwidth, 

20 seconds is *really* short. That might not even be enough time for
autonumas knumad thread to find the process and update it as IIRC it starts
pretty slowly.

> giving the (non-trivial) expense of convergence and memory 
> migraton a weight in the result as well. So these are not 
> 'ideal' results with long runtimes where migration cost gets 
> averaged out.
> 
> [ The denotion of the workloads is similar to the latency 
>   measurements: for example "2x3" means 2 processes, 3 threads 
>   per process. See the 'perf bench' tool for details. ]
> 
> The 'numa02' and 'numa01-THREAD' tests are AutoNUMA-benchmark 
> work-alike workloads, with a shorter runtime for numa01.
> 
> The results are:
> 
>                            [ Higher numbers are better. ]
> 
>  [test unit]            :   v3.7 |balancenuma-v10|  AutoNUMA-v28 | numa-u-v3     |
> ------------------------------------------------------------------------------------------
>  2x1-bw-process         :   6.248|  6.136:  -1.8%|  8.073:  29.2%|  9.647:  54.4%|  GB/sec
>  3x1-bw-process         :   7.292|  7.250:  -0.6%| 12.583:  72.6%| 14.528:  99.2%|  GB/sec
>  4x1-bw-process         :   6.007|  6.867:  14.3%| 12.313: 105.0%| 18.903: 214.7%|  GB/sec
>  8x1-bw-process         :   6.100|  7.974:  30.7%| 20.237: 231.8%| 26.829: 339.8%|  GB/sec
>  8x1-bw-process-NOTHP   :   5.944|  5.937:  -0.1%| 17.831: 200.0%| 22.237: 274.1%|  GB/sec
>  16x1-bw-process        :   5.607|  5.592:  -0.3%|  5.959:   6.3%| 29.294: 422.5%|  GB/sec
>  4x1-bw-thread          :   6.035| 13.598: 125.3%| 17.443: 189.0%| 19.290: 219.6%|  GB/sec
>  8x1-bw-thread          :   5.941| 16.356: 175.3%| 22.433: 277.6%| 26.391: 344.2%|  GB/sec
>  16x1-bw-thread         :   5.648| 24.608: 335.7%| 20.204: 257.7%| 29.557: 423.3%|  GB/sec
>  32x1-bw-thread         :   5.929| 25.477: 329.7%| 18.230: 207.5%| 30.232: 409.9%|  GB/sec
>  2x3-bw-thread          :   5.756|  8.785:  52.6%| 14.652: 154.6%| 15.327: 166.3%|  GB/sec
>  4x4-bw-thread          :   5.605|  6.366:  13.6%|  9.835:  75.5%| 27.957: 398.8%|  GB/sec
>  4x6-bw-thread          :   5.771|  6.287:   8.9%| 15.372: 166.4%| 27.877: 383.1%|  GB/sec
>  4x8-bw-thread          :   5.858|  5.860:   0.0%| 11.865: 102.5%| 28.439: 385.5%|  GB/sec
>  4x8-bw-thread-NOTHP    :   5.645|  6.167:   9.2%|  9.224:  63.4%| 25.067: 344.1%|  GB/sec
>  3x3-bw-thread          :   5.937|  8.235:  38.7%|  6.635:  11.8%| 21.560: 263.1%|  GB/sec
>  5x5-bw-thread          :   5.771|  5.762:  -0.2%|  9.575:  65.9%| 26.081: 351.9%|  GB/sec
>  2x16-bw-thread         :   5.953|  5.920:  -0.6%|  5.945:  -0.1%| 23.269: 290.9%|  GB/sec
>  1x32-bw-thread         :   5.879|  5.828:  -0.9%|  5.848:  -0.5%| 18.985: 222.9%|  GB/sec
>  numa02-bw              :   6.049| 29.054: 380.3%| 24.744: 309.1%| 31.431: 419.6%|  GB/sec
>  numa02-bw-NOTHP        :   5.850| 27.064: 362.6%| 20.415: 249.0%| 29.104: 397.5%|  GB/sec
>  numa01-bw-thread       :   5.834| 20.338: 248.6%| 15.169: 160.0%| 28.607: 390.3%|  GB/sec
>  numa01-bw-thread-NOTHP :   5.581| 18.528: 232.0%| 12.108: 117.0%| 21.119: 278.4%|  GB/sec
> ------------------------------------------------------------------------------------------
> 

Again, balancenumas results would depend *very* heavily on how it took
for the scheduler to put a task on a new node.

> The first column shows mainline kernel bandwidth in GB/sec, the 
> following 3 colums show pairs of GB/sec bandwidth and percentage 
> results, where percentage shows the speed difference to the 
> mainline kernel.
> 
> Noise is 1-2% in these tests with these durations, so the good 
> news is that none of the NUMA kernels regresses on these 
> workloads against the mainline kernel. Perhaps balancenuma's 
> "2x1-bw-process" and "3x1-bw-process" results might be worth a 
> closer look.
> 

Balancenuma takes no action until a task is scheduled on a new node.
Until that time, it assumes that no action is necessary because its workload
is already accessing local memory. It does not take into account that two
processes could be on the same node competing for memory bandwidth. I
expect that is what is happening here. In 2x1-bw-process, both tasks
start on the same node scheduled on CPUs for that node. As long as they
both fit there and the scheduler does not migrate them in 20 seconds,
it will leave memory where it is.

Addressing this would require calculation of the per-node memory load
and spreading tasks around on that basis via the load balancer. Fairly
straight-forward to do and I believe numacore does something along these
lines but it would violate what balancenuma was for -- a common base that
either numacore or autonuma could use.

> No kernel shows particular vulnerability to the NOTHP tests that 
> were mixed into the test stream.
> 
> As can be expected from the convergence latency results, the 
> 'balancenuma' tree does well with workloads where there's no 
> relationship between threads

I don't think it's exactly about workload isolation. It's more a factor of
how long it takes for the scheduler to put tasks on new nodes and whether it
leaves them there. I can work on patches that calculate per-numa load and
hook into the load balancer but at that point I'm going to start colliding
heavily with your work.

> - but even there it's outperformed 
> by the AutoNUMA kernel, and outperformed by an even larger 
> margin by the NUMA-v3 kernel. Workloads like the 4x JVM SPECjbb 
> on the other hand pose a challenge to the balancenuma kernel, 
> both the AutoNUMA and the NUMA-v3 kernels are several times 
> faster in those tests.
> 
> The AutoNUMA kernel does well in most workloads - its weakness 
> are system-wide shared workloads like 2x16-bw-thread and 
> 1x32-bw-thread, where it falls back to mainline performance.
> 
> The NUMA-v3 kernel outperforms every other NUMA kernel.
> 
> Here's a direct comparison between the two fastest kernels, the 
> AutoNUMA and the NUMA-v3 kernels:
> 
> 
>                         [ Higher numbers are better. ]
> 
>  [test unit]            :AutoNUMA| numa-u-v3     |
> ----------------------------------------------------------
>  2x1-bw-process         :   8.073|  9.647:  19.5%|  GB/sec
>  3x1-bw-process         :  12.583| 14.528:  15.5%|  GB/sec
>  4x1-bw-process         :  12.313| 18.903:  53.5%|  GB/sec
>  8x1-bw-process         :  20.237| 26.829:  32.6%|  GB/sec
>  8x1-bw-process-NOTHP   :  17.831| 22.237:  24.7%|  GB/sec
>  16x1-bw-process        :   5.959| 29.294: 391.6%|  GB/sec
>  4x1-bw-thread          :  17.443| 19.290:  10.6%|  GB/sec
>  8x1-bw-thread          :  22.433| 26.391:  17.6%|  GB/sec
>  16x1-bw-thread         :  20.204| 29.557:  46.3%|  GB/sec
>  32x1-bw-thread         :  18.230| 30.232:  65.8%|  GB/sec
>  2x3-bw-thread          :  14.652| 15.327:   4.6%|  GB/sec
>  4x4-bw-thread          :   9.835| 27.957: 184.3%|  GB/sec
>  4x6-bw-thread          :  15.372| 27.877:  81.3%|  GB/sec
>  4x8-bw-thread          :  11.865| 28.439: 139.7%|  GB/sec
>  4x8-bw-thread-NOTHP    :   9.224| 25.067: 171.8%|  GB/sec
>  3x3-bw-thread          :   6.635| 21.560: 224.9%|  GB/sec
>  5x5-bw-thread          :   9.575| 26.081: 172.4%|  GB/sec
>  2x16-bw-thread         :   5.945| 23.269: 291.4%|  GB/sec
>  1x32-bw-thread         :   5.848| 18.985: 224.6%|  GB/sec
>  numa02-bw              :  24.744| 31.431:  27.0%|  GB/sec
>  numa02-bw-NOTHP        :  20.415| 29.104:  42.6%|  GB/sec
>  numa01-bw-thread       :  15.169| 28.607:  88.6%|  GB/sec
>  numa01-bw-thread-NOTHP :  12.108| 21.119:  74.4%|  GB/sec
> 
> 
> NUMA workload "spread" measurements
> -----------------------------------
> 
> A third, somewhat obscure category of measurements deals with 
> the 'execution spread' between threads. Workloads that have to 
> wait for the result of every thread before they can declare a 
> result are directly limited by this spread.
> 
> The 'spread' is measured by the percentage difference between 
> the slowest and fastest thread's execution time in a workload:
> 
>                            [ Lower numbers are better. ]
> 
>  [test unit]            :   v3.7  |balancenuma-v10|  AutoNUMA-v28 |   numa-u-v3   |
> ------------------------------------------------------------------------------------------
>  RAM-bw-local           :    0.0% |          0.0% |          0.0% |          0.0% |  %
>  RAM-bw-local-NOTHP     :    0.2% |          0.2% |          0.2% |          0.2% |  %
>  RAM-bw-remote          :    0.0% |          0.0% |          0.0% |          0.0% |  %
>  RAM-bw-local-2x        :    0.3% |          0.0% |          0.2% |          0.3% |  %
>  RAM-bw-remote-2x       :    0.0% |          0.2% |          0.0% |          0.2% |  %
>  RAM-bw-cross           :    0.4% |          0.2% |          0.0% |          0.1% |  %
>  2x1-bw-process         :    0.5% |          0.2% |          0.2% |          0.2% |  %
>  3x1-bw-process         :    0.6% |          0.2% |          0.2% |          0.1% |  %
>  4x1-bw-process         :    0.4% |          0.8% |          0.2% |          0.3% |  %
>  8x1-bw-process         :    0.8% |          0.1% |          0.2% |          0.2% |  %
>  8x1-bw-process-NOTHP   :    0.9% |          0.7% |          0.4% |          0.5% |  %
>  16x1-bw-process        :    1.0% |          0.9% |          0.6% |          0.1% |  %
>  4x1-bw-thread          :    0.1% |          0.1% |          0.1% |          0.1% |  %
>  8x1-bw-thread          :    0.2% |          0.1% |          0.1% |          0.2% |  %
>  16x1-bw-thread         :    0.3% |          0.1% |          0.1% |          0.1% |  %
>  32x1-bw-thread         :    0.3% |          0.1% |          0.1% |          0.1% |  %
>  2x3-bw-thread          :    0.4% |          0.3% |          0.3% |          0.3% |  %
>  4x4-bw-thread          :    2.3% |          1.4% |          0.8% |          0.4% |  %
>  4x6-bw-thread          :    2.5% |          2.2% |          1.0% |          0.6% |  %
>  4x8-bw-thread          :    3.9% |          3.7% |          1.3% |          0.9% |  %
>  4x8-bw-thread-NOTHP    :    6.0% |          2.5% |          1.5% |          1.0% |  %
>  3x3-bw-thread          :    0.5% |          0.4% |          0.5% |          0.3% |  %
>  5x5-bw-thread          :    1.8% |          2.7% |          1.3% |          0.7% |  %
>  2x16-bw-thread         :    3.7% |          4.1% |          3.6% |          1.1% |  %
>  1x32-bw-thread         :    2.9% |          7.3% |          3.5% |          4.4% |  %
>  numa02-bw              :    0.1% |          0.0% |          0.1% |          0.1% |  %
>  numa02-bw-NOTHP        :    0.4% |          0.3% |          0.3% |          0.3% |  %
>  numa01-bw-thread       :    1.3% |          0.4% |          0.3% |          0.3% |  %
>  numa01-bw-thread-NOTHP :    1.8% |          0.8% |          0.8% |          0.9% |  %
> 
> The results are pretty good because the runs were relatively 
> short with 20 seconds runtime.
> 
> Both mainline and balancenuma has trouble with the spread of 
> shared workloads - possibly signalling memory allocation 
> assymetries. Longer - 60 seconds or more - runs of the key 
> workloads would certainly be informative there.
> 
> NOTHP (4K ptes) increases the spread and non-determinism of 
> every NUMA kernel.
> 
> The AutoNUMA and NUMA-v3 kernels have the lowest spread, 
> signalling stable NUMA convergence in most scenarios.
> 
> Finally, below is the (long!) dump of all the raw data, in case 
> someone wants to double-check my results. The perf/bench tool 
> can be used to double check the measurements on other systems.
> 

I'll take your word that you got it right and nothing in the results
surprised me as such.

My reading of the results are basically that balancenuma suffers in these
comparisons because it's not hooking into the scheduler to feed information
to the load balancer on how the tasks should be spread around. As the
scheduler does not move the tasks (too few, too short lived) it looks bad
as a result. I can work on the patches to spread identify per-node load
and hook into the load balancer to spread the tasks but at that point I'll
start heavily colliding with either an autonuma or numacore rebased which
I had wanted to avoid.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
