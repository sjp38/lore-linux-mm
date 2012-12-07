Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 128EA6B0082
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 16:54:04 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so413704eaa.14
        for <linux-mm@kvack.org>; Fri, 07 Dec 2012 13:54:02 -0800 (PST)
Date: Fri, 7 Dec 2012 22:53:57 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: NUMA performance comparison between three NUMA kernels and mainline.
 [Mid-size NUMA system edition.]
Message-ID: <20121207215357.GA30130@gmail.com>
References: <1354913744-29902-1-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1354913744-29902-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mike Galbraith <efault@gmx.de>


Here's a (strongly NUMA-centric) performance comparison of the 
three NUMA kernels: the 'balancenuma-v10' tree from Mel, the 
AutoNUMA-v28 kernel from Andrea and the unified NUMA -v3 tree 
Peter and me are working on.

The goal of these measurements is to specifically quantify the 
NUMA optimization qualities of each of the three NUMA-optimizing 
kernels.

There are lots of numbers in this mail and lot of material to 
read - sorry about that! :-/

I used the latest available kernel versions everywhere: 
furthermore the AutoNUMA-v28 tree has been patched with Hugh 
Dickin's THP-migration support patch, to make it a fair 
apples-to-apples comparison.

I have used the 'perf bench numa' tool to do the measurements, 
which tool can be found at:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git perf/bench

   # to build it install numactl-dev[el] and do "cd tools/perf; make -j install'

To get the raw numbers I ran "perf bench numa mem -a" multiple 
times on each kernel, on a 32-way, 64 GB RAM, 4-node Opteron 
test-system. Each kernel used the same base .config, copied from 
a Fedora RPM kernel, with the NUMA-balancing options enabled.

( Note that the testcases are tailored to my test-system: on
  a smaller system you'd want to run slightly smaller testcases,
  on a larger system you'd want to run a couple of larger 
  testcases as well. )

NUMA convergence latency measurements
-------------------------------------

'NUMA convergence' latency is the number of seconds a workload 
takes to reach 'perfectly NUMA balanced' state. This is measured 
on the CPU placement side: once it has converged then memory 
typically follows within a couple of seconds.

Because convergence is not guaranteed, a 100 seconds latency 
time-out is used in the benchmark. If you see a 100 seconds 
result in the table it means that that particular NUMA kernel 
did not manage to converge that workload unit test within 100 
seconds.

The NxM denotion means process/thread relationship: a 1x4 test 
is 1 process with 4 thread that share a workload - a 4x6 test 
are 4 processes with 6 threads in each process, the processes 
isolated from each other but the threads working on the same 
working set.

I used a wide set of test-cases I collected in the past:

                           [ Lower numbers are better. ]

 [test unit]            :   v3.7 |balancenuma-v10|  AutoNUMA-v28 |   numa-u-v3   |
------------------------------------------------------------------------------------------
 1x3-convergence        :  100.1 |         100.0 |           0.2 |           2.3 |  secs
 1x4-convergence        :  100.2 |         100.1 |         100.2 |           2.1 |  secs
 1x6-convergence        :  100.3 |         100.4 |         100.8 |           7.3 |  secs
 2x3-convergence        :  100.6 |         100.6 |         100.5 |           4.1 |  secs
 3x3-convergence        :  100.6 |         100.5 |         100.5 |           7.6 |  secs
 4x4-convergence        :  100.6 |         100.5 |           4.1 |           7.4 |  secs
 4x4-convergence-NOTHP  :  101.1 |         100.5 |          12.2 |           9.2 |  secs
 4x6-convergence        :    5.4 |         101.2 |          16.6 |          11.7 |  secs
 4x8-convergence        :  101.1 |         101.3 |           3.4 |           3.9 |  secs
 8x4-convergence        :  100.9 |         100.8 |          18.3 |           8.9 |  secs
 8x4-convergence-NOTHP  :  101.9 |         101.0 |          15.7 |          12.1 |  secs
 3x1-convergence        :    0.7 |           1.0 |           0.8 |           0.9 |  secs
 4x1-convergence        :    0.6 |           0.8 |           0.8 |           0.7 |  secs
 8x1-convergence        :    2.8 |           2.9 |           2.9 |           1.2 |  secs
 16x1-convergence       :    3.5 |           3.7 |           2.5 |           2.0 |  secs
 32x1-convergence       :    3.6 |           2.8 |           3.0 |           1.9 |  secs

As expected, mainline only manages to converge workloads where 
each worker process is isolated and the default 
spread-to-all-nodes scheduling policy creates an ideal layout, 
regardless of task ordering.

[ Note that the mainline kernel got a 'lucky strike' convergence 
  in the 4x6 workload: it's always possible for the workload
  to accidentally converge. On a repeat test this did not occur, 
  but I did not erase the outlier because luck is a valid and 
  existing phenomenon. ]

The 'balancenuma' kernel does not converge any of the workloads 
where worker threads or processes relate to each other.

AutoNUMA does pretty well, but it did not manage to converge for 
4 testcases of shared, under-loaded workloads.

The unified NUMA-v3 tree converged well in every testcase.


NUMA workload bandwidth measurements
------------------------------------

The other set of numbers I've collected are workload bandwidth 
measurements, run over 20 seconds. Using 20 seconds gives a 
healthy mix of pre-convergence and post-convergence bandwidth, 
giving the (non-trivial) expense of convergence and memory 
migraton a weight in the result as well. So these are not 
'ideal' results with long runtimes where migration cost gets 
averaged out.

[ The denotion of the workloads is similar to the latency 
  measurements: for example "2x3" means 2 processes, 3 threads 
  per process. See the 'perf bench' tool for details. ]

The 'numa02' and 'numa01-THREAD' tests are AutoNUMA-benchmark 
work-alike workloads, with a shorter runtime for numa01.

The results are:

                           [ Higher numbers are better. ]

 [test unit]            :   v3.7 |balancenuma-v10|  AutoNUMA-v28 | numa-u-v3     |
------------------------------------------------------------------------------------------
 2x1-bw-process         :   6.248|  6.136:  -1.8%|  8.073:  29.2%|  9.647:  54.4%|  GB/sec
 3x1-bw-process         :   7.292|  7.250:  -0.6%| 12.583:  72.6%| 14.528:  99.2%|  GB/sec
 4x1-bw-process         :   6.007|  6.867:  14.3%| 12.313: 105.0%| 18.903: 214.7%|  GB/sec
 8x1-bw-process         :   6.100|  7.974:  30.7%| 20.237: 231.8%| 26.829: 339.8%|  GB/sec
 8x1-bw-process-NOTHP   :   5.944|  5.937:  -0.1%| 17.831: 200.0%| 22.237: 274.1%|  GB/sec
 16x1-bw-process        :   5.607|  5.592:  -0.3%|  5.959:   6.3%| 29.294: 422.5%|  GB/sec
 4x1-bw-thread          :   6.035| 13.598: 125.3%| 17.443: 189.0%| 19.290: 219.6%|  GB/sec
 8x1-bw-thread          :   5.941| 16.356: 175.3%| 22.433: 277.6%| 26.391: 344.2%|  GB/sec
 16x1-bw-thread         :   5.648| 24.608: 335.7%| 20.204: 257.7%| 29.557: 423.3%|  GB/sec
 32x1-bw-thread         :   5.929| 25.477: 329.7%| 18.230: 207.5%| 30.232: 409.9%|  GB/sec
 2x3-bw-thread          :   5.756|  8.785:  52.6%| 14.652: 154.6%| 15.327: 166.3%|  GB/sec
 4x4-bw-thread          :   5.605|  6.366:  13.6%|  9.835:  75.5%| 27.957: 398.8%|  GB/sec
 4x6-bw-thread          :   5.771|  6.287:   8.9%| 15.372: 166.4%| 27.877: 383.1%|  GB/sec
 4x8-bw-thread          :   5.858|  5.860:   0.0%| 11.865: 102.5%| 28.439: 385.5%|  GB/sec
 4x8-bw-thread-NOTHP    :   5.645|  6.167:   9.2%|  9.224:  63.4%| 25.067: 344.1%|  GB/sec
 3x3-bw-thread          :   5.937|  8.235:  38.7%|  6.635:  11.8%| 21.560: 263.1%|  GB/sec
 5x5-bw-thread          :   5.771|  5.762:  -0.2%|  9.575:  65.9%| 26.081: 351.9%|  GB/sec
 2x16-bw-thread         :   5.953|  5.920:  -0.6%|  5.945:  -0.1%| 23.269: 290.9%|  GB/sec
 1x32-bw-thread         :   5.879|  5.828:  -0.9%|  5.848:  -0.5%| 18.985: 222.9%|  GB/sec
 numa02-bw              :   6.049| 29.054: 380.3%| 24.744: 309.1%| 31.431: 419.6%|  GB/sec
 numa02-bw-NOTHP        :   5.850| 27.064: 362.6%| 20.415: 249.0%| 29.104: 397.5%|  GB/sec
 numa01-bw-thread       :   5.834| 20.338: 248.6%| 15.169: 160.0%| 28.607: 390.3%|  GB/sec
 numa01-bw-thread-NOTHP :   5.581| 18.528: 232.0%| 12.108: 117.0%| 21.119: 278.4%|  GB/sec
------------------------------------------------------------------------------------------

The first column shows mainline kernel bandwidth in GB/sec, the 
following 3 colums show pairs of GB/sec bandwidth and percentage 
results, where percentage shows the speed difference to the 
mainline kernel.

Noise is 1-2% in these tests with these durations, so the good 
news is that none of the NUMA kernels regresses on these 
workloads against the mainline kernel. Perhaps balancenuma's 
"2x1-bw-process" and "3x1-bw-process" results might be worth a 
closer look.

No kernel shows particular vulnerability to the NOTHP tests that 
were mixed into the test stream.

As can be expected from the convergence latency results, the 
'balancenuma' tree does well with workloads where there's no 
relationship between threads - but even there it's outperformed 
by the AutoNUMA kernel, and outperformed by an even larger 
margin by the NUMA-v3 kernel. Workloads like the 4x JVM SPECjbb 
on the other hand pose a challenge to the balancenuma kernel, 
both the AutoNUMA and the NUMA-v3 kernels are several times 
faster in those tests.

The AutoNUMA kernel does well in most workloads - its weakness 
are system-wide shared workloads like 2x16-bw-thread and 
1x32-bw-thread, where it falls back to mainline performance.

The NUMA-v3 kernel outperforms every other NUMA kernel.

Here's a direct comparison between the two fastest kernels, the 
AutoNUMA and the NUMA-v3 kernels:


                        [ Higher numbers are better. ]

 [test unit]            :AutoNUMA| numa-u-v3     |
----------------------------------------------------------
 2x1-bw-process         :   8.073|  9.647:  19.5%|  GB/sec
 3x1-bw-process         :  12.583| 14.528:  15.5%|  GB/sec
 4x1-bw-process         :  12.313| 18.903:  53.5%|  GB/sec
 8x1-bw-process         :  20.237| 26.829:  32.6%|  GB/sec
 8x1-bw-process-NOTHP   :  17.831| 22.237:  24.7%|  GB/sec
 16x1-bw-process        :   5.959| 29.294: 391.6%|  GB/sec
 4x1-bw-thread          :  17.443| 19.290:  10.6%|  GB/sec
 8x1-bw-thread          :  22.433| 26.391:  17.6%|  GB/sec
 16x1-bw-thread         :  20.204| 29.557:  46.3%|  GB/sec
 32x1-bw-thread         :  18.230| 30.232:  65.8%|  GB/sec
 2x3-bw-thread          :  14.652| 15.327:   4.6%|  GB/sec
 4x4-bw-thread          :   9.835| 27.957: 184.3%|  GB/sec
 4x6-bw-thread          :  15.372| 27.877:  81.3%|  GB/sec
 4x8-bw-thread          :  11.865| 28.439: 139.7%|  GB/sec
 4x8-bw-thread-NOTHP    :   9.224| 25.067: 171.8%|  GB/sec
 3x3-bw-thread          :   6.635| 21.560: 224.9%|  GB/sec
 5x5-bw-thread          :   9.575| 26.081: 172.4%|  GB/sec
 2x16-bw-thread         :   5.945| 23.269: 291.4%|  GB/sec
 1x32-bw-thread         :   5.848| 18.985: 224.6%|  GB/sec
 numa02-bw              :  24.744| 31.431:  27.0%|  GB/sec
 numa02-bw-NOTHP        :  20.415| 29.104:  42.6%|  GB/sec
 numa01-bw-thread       :  15.169| 28.607:  88.6%|  GB/sec
 numa01-bw-thread-NOTHP :  12.108| 21.119:  74.4%|  GB/sec


NUMA workload "spread" measurements
-----------------------------------

A third, somewhat obscure category of measurements deals with 
the 'execution spread' between threads. Workloads that have to 
wait for the result of every thread before they can declare a 
result are directly limited by this spread.

The 'spread' is measured by the percentage difference between 
the slowest and fastest thread's execution time in a workload:

                           [ Lower numbers are better. ]

 [test unit]            :   v3.7  |balancenuma-v10|  AutoNUMA-v28 |   numa-u-v3   |
------------------------------------------------------------------------------------------
 RAM-bw-local           :    0.0% |          0.0% |          0.0% |          0.0% |  %
 RAM-bw-local-NOTHP     :    0.2% |          0.2% |          0.2% |          0.2% |  %
 RAM-bw-remote          :    0.0% |          0.0% |          0.0% |          0.0% |  %
 RAM-bw-local-2x        :    0.3% |          0.0% |          0.2% |          0.3% |  %
 RAM-bw-remote-2x       :    0.0% |          0.2% |          0.0% |          0.2% |  %
 RAM-bw-cross           :    0.4% |          0.2% |          0.0% |          0.1% |  %
 2x1-bw-process         :    0.5% |          0.2% |          0.2% |          0.2% |  %
 3x1-bw-process         :    0.6% |          0.2% |          0.2% |          0.1% |  %
 4x1-bw-process         :    0.4% |          0.8% |          0.2% |          0.3% |  %
 8x1-bw-process         :    0.8% |          0.1% |          0.2% |          0.2% |  %
 8x1-bw-process-NOTHP   :    0.9% |          0.7% |          0.4% |          0.5% |  %
 16x1-bw-process        :    1.0% |          0.9% |          0.6% |          0.1% |  %
 4x1-bw-thread          :    0.1% |          0.1% |          0.1% |          0.1% |  %
 8x1-bw-thread          :    0.2% |          0.1% |          0.1% |          0.2% |  %
 16x1-bw-thread         :    0.3% |          0.1% |          0.1% |          0.1% |  %
 32x1-bw-thread         :    0.3% |          0.1% |          0.1% |          0.1% |  %
 2x3-bw-thread          :    0.4% |          0.3% |          0.3% |          0.3% |  %
 4x4-bw-thread          :    2.3% |          1.4% |          0.8% |          0.4% |  %
 4x6-bw-thread          :    2.5% |          2.2% |          1.0% |          0.6% |  %
 4x8-bw-thread          :    3.9% |          3.7% |          1.3% |          0.9% |  %
 4x8-bw-thread-NOTHP    :    6.0% |          2.5% |          1.5% |          1.0% |  %
 3x3-bw-thread          :    0.5% |          0.4% |          0.5% |          0.3% |  %
 5x5-bw-thread          :    1.8% |          2.7% |          1.3% |          0.7% |  %
 2x16-bw-thread         :    3.7% |          4.1% |          3.6% |          1.1% |  %
 1x32-bw-thread         :    2.9% |          7.3% |          3.5% |          4.4% |  %
 numa02-bw              :    0.1% |          0.0% |          0.1% |          0.1% |  %
 numa02-bw-NOTHP        :    0.4% |          0.3% |          0.3% |          0.3% |  %
 numa01-bw-thread       :    1.3% |          0.4% |          0.3% |          0.3% |  %
 numa01-bw-thread-NOTHP :    1.8% |          0.8% |          0.8% |          0.9% |  %

The results are pretty good because the runs were relatively 
short with 20 seconds runtime.

Both mainline and balancenuma has trouble with the spread of 
shared workloads - possibly signalling memory allocation 
assymetries. Longer - 60 seconds or more - runs of the key 
workloads would certainly be informative there.

NOTHP (4K ptes) increases the spread and non-determinism of 
every NUMA kernel.

The AutoNUMA and NUMA-v3 kernels have the lowest spread, 
signalling stable NUMA convergence in most scenarios.

Finally, below is the (long!) dump of all the raw data, in case 
someone wants to double-check my results. The perf/bench tool 
can be used to double check the measurements on other systems.

Thanks,

	Ingo

-------------------->

Here are the exact kernel versions used:

 # kernel 1: {v3.7-rc8-18a2f371f5ed}
 # kernel 2: {balancenuma-v10}
 # kernel 3: {autonuma-v28-c4bba428cc5c}
 # kernel 4: {numa/base-v3}

-------------------->

 #
 # Running test on: Linux vega 3.7.0-rc8+ #3 SMP Fri Dec 7 18:29:16 CET 2012 x86_64 x86_64 x86_64 GNU/Linux
 #
# Running numa/mem benchmark...

 # Running main, "perf bench numa mem -a"

 # Running RAM-bw-local, "perf bench numa mem -p 1 -t 1 -P 1024 -C 0 -M 0 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-local,                           20.111, secs,           runtime-max/thread
 RAM-bw-local,                           20.106, secs,           runtime-min/thread
 RAM-bw-local,                           20.106, secs,           runtime-avg/thread
 RAM-bw-local,                            0.013, %,              spread-runtime/thread
 RAM-bw-local,                          169.651, GB,             data/thread
 RAM-bw-local,                          169.651, GB,             data-total
 RAM-bw-local,                            0.119, nsecs,          runtime/byte/thread
 RAM-bw-local,                            8.436, GB/sec,         thread-speed
 RAM-bw-local,                            8.436, GB/sec,         total-speed

 # Running RAM-bw-local-NOTHP, "perf bench numa mem -p 1 -t 1 -P 1024 -C 0 -M 0 -s 20 -zZq --thp  1 --no-data_rand_walk --thp -1"
 RAM-bw-local-NOTHP,                     20.125, secs,           runtime-max/thread
 RAM-bw-local-NOTHP,                     20.050, secs,           runtime-min/thread
 RAM-bw-local-NOTHP,                     20.050, secs,           runtime-avg/thread
 RAM-bw-local-NOTHP,                      0.187, %,              spread-runtime/thread
 RAM-bw-local-NOTHP,                    169.651, GB,             data/thread
 RAM-bw-local-NOTHP,                    169.651, GB,             data-total
 RAM-bw-local-NOTHP,                      0.119, nsecs,          runtime/byte/thread
 RAM-bw-local-NOTHP,                      8.430, GB/sec,         thread-speed
 RAM-bw-local-NOTHP,                      8.430, GB/sec,         total-speed

 # Running RAM-bw-remote, "perf bench numa mem -p 1 -t 1 -P 1024 -C 0 -M 1 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-remote,                          20.141, secs,           runtime-max/thread
 RAM-bw-remote,                          20.134, secs,           runtime-min/thread
 RAM-bw-remote,                          20.134, secs,           runtime-avg/thread
 RAM-bw-remote,                           0.017, %,              spread-runtime/thread
 RAM-bw-remote,                         135.291, GB,             data/thread
 RAM-bw-remote,                         135.291, GB,             data-total
 RAM-bw-remote,                           0.149, nsecs,          runtime/byte/thread
 RAM-bw-remote,                           6.717, GB/sec,         thread-speed
 RAM-bw-remote,                           6.717, GB/sec,         total-speed

 # Running RAM-bw-local-2x, "perf bench numa mem -p 2 -t 1 -P 1024 -C 0,2 -M 0x2 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-local-2x,                        20.128, secs,           runtime-max/thread
 RAM-bw-local-2x,                        20.006, secs,           runtime-min/thread
 RAM-bw-local-2x,                        20.064, secs,           runtime-avg/thread
 RAM-bw-local-2x,                         0.302, %,              spread-runtime/thread
 RAM-bw-local-2x,                       132.607, GB,             data/thread
 RAM-bw-local-2x,                       265.214, GB,             data-total
 RAM-bw-local-2x,                         0.152, nsecs,          runtime/byte/thread
 RAM-bw-local-2x,                         6.588, GB/sec,         thread-speed
 RAM-bw-local-2x,                        13.177, GB/sec,         total-speed

 # Running RAM-bw-remote-2x, "perf bench numa mem -p 2 -t 1 -P 1024 -C 0,2 -M 1x2 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-remote-2x,                       20.102, secs,           runtime-max/thread
 RAM-bw-remote-2x,                       20.094, secs,           runtime-min/thread
 RAM-bw-remote-2x,                       20.094, secs,           runtime-avg/thread
 RAM-bw-remote-2x,                        0.021, %,              spread-runtime/thread
 RAM-bw-remote-2x,                       74.088, GB,             data/thread
 RAM-bw-remote-2x,                      148.176, GB,             data-total
 RAM-bw-remote-2x,                        0.271, nsecs,          runtime/byte/thread
 RAM-bw-remote-2x,                        3.686, GB/sec,         thread-speed
 RAM-bw-remote-2x,                        7.371, GB/sec,         total-speed

 # Running RAM-bw-cross, "perf bench numa mem -p 2 -t 1 -P 1024 -C 0,8 -M 1,0 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-cross,                           20.159, secs,           runtime-max/thread
 RAM-bw-cross,                           20.011, secs,           runtime-min/thread
 RAM-bw-cross,                           20.081, secs,           runtime-avg/thread
 RAM-bw-cross,                            0.369, %,              spread-runtime/thread
 RAM-bw-cross,                          122.407, GB,             data/thread
 RAM-bw-cross,                          244.813, GB,             data-total
 RAM-bw-cross,                            0.165, nsecs,          runtime/byte/thread
 RAM-bw-cross,                            6.072, GB/sec,         thread-speed
 RAM-bw-cross,                           12.144, GB/sec,         total-speed

 # Running  1x3-convergence, "perf bench numa mem -p 1 -t 3 -P 512 -s 100 -zZ0qcm --thp  1"
  1x3-convergence,                      100.103, secs,           NUMA-convergence-latency
  1x3-convergence,                      100.103, secs,           runtime-max/thread
  1x3-convergence,                      100.082, secs,           runtime-min/thread
  1x3-convergence,                      100.093, secs,           runtime-avg/thread
  1x3-convergence,                        0.010, %,              spread-runtime/thread
  1x3-convergence,                      278.636, GB,             data/thread
  1x3-convergence,                      835.908, GB,             data-total
  1x3-convergence,                        0.359, nsecs,          runtime/byte/thread
  1x3-convergence,                        2.784, GB/sec,         thread-speed
  1x3-convergence,                        8.351, GB/sec,         total-speed

 # Running  1x4-convergence, "perf bench numa mem -p 1 -t 4 -P 512 -s 100 -zZ0qcm --thp  1"
  1x4-convergence,                      100.211, secs,           NUMA-convergence-latency
  1x4-convergence,                      100.211, secs,           runtime-max/thread
  1x4-convergence,                      100.070, secs,           runtime-min/thread
  1x4-convergence,                      100.140, secs,           runtime-avg/thread
  1x4-convergence,                        0.070, %,              spread-runtime/thread
  1x4-convergence,                      154.887, GB,             data/thread
  1x4-convergence,                      619.549, GB,             data-total
  1x4-convergence,                        0.647, nsecs,          runtime/byte/thread
  1x4-convergence,                        1.546, GB/sec,         thread-speed
  1x4-convergence,                        6.182, GB/sec,         total-speed

 # Running  1x6-convergence, "perf bench numa mem -p 1 -t 6 -P 1020 -s 100 -zZ0qcm --thp  1"
  1x6-convergence,                      100.343, secs,           NUMA-convergence-latency
  1x6-convergence,                      100.343, secs,           runtime-max/thread
  1x6-convergence,                      100.235, secs,           runtime-min/thread
  1x6-convergence,                      100.303, secs,           runtime-avg/thread
  1x6-convergence,                        0.054, %,              spread-runtime/thread
  1x6-convergence,                       95.725, GB,             data/thread
  1x6-convergence,                      574.347, GB,             data-total
  1x6-convergence,                        1.048, nsecs,          runtime/byte/thread
  1x6-convergence,                        0.954, GB/sec,         thread-speed
  1x6-convergence,                        5.724, GB/sec,         total-speed

 # Running  2x3-convergence, "perf bench numa mem -p 3 -t 3 -P 1020 -s 100 -zZ0qcm --thp  1"
  2x3-convergence,                      100.601, secs,           NUMA-convergence-latency
  2x3-convergence,                      100.601, secs,           runtime-max/thread
  2x3-convergence,                      100.054, secs,           runtime-min/thread
  2x3-convergence,                      100.307, secs,           runtime-avg/thread
  2x3-convergence,                        0.272, %,              spread-runtime/thread
  2x3-convergence,                       65.837, GB,             data/thread
  2x3-convergence,                      592.529, GB,             data-total
  2x3-convergence,                        1.528, nsecs,          runtime/byte/thread
  2x3-convergence,                        0.654, GB/sec,         thread-speed
  2x3-convergence,                        5.890, GB/sec,         total-speed

 # Running  3x3-convergence, "perf bench numa mem -p 3 -t 3 -P 1020 -s 100 -zZ0qcm --thp  1"
  3x3-convergence,                      100.572, secs,           NUMA-convergence-latency
  3x3-convergence,                      100.572, secs,           runtime-max/thread
  3x3-convergence,                      100.095, secs,           runtime-min/thread
  3x3-convergence,                      100.330, secs,           runtime-avg/thread
  3x3-convergence,                        0.238, %,              spread-runtime/thread
  3x3-convergence,                       65.837, GB,             data/thread
  3x3-convergence,                      592.529, GB,             data-total
  3x3-convergence,                        1.528, nsecs,          runtime/byte/thread
  3x3-convergence,                        0.655, GB/sec,         thread-speed
  3x3-convergence,                        5.892, GB/sec,         total-speed

 # Running  4x4-convergence, "perf bench numa mem -p 4 -t 4 -P 512 -s 100 -zZ0qcm --thp  1"
  4x4-convergence,                      100.571, secs,           NUMA-convergence-latency
  4x4-convergence,                      100.571, secs,           runtime-max/thread
  4x4-convergence,                      100.122, secs,           runtime-min/thread
  4x4-convergence,                      100.386, secs,           runtime-avg/thread
  4x4-convergence,                        0.223, %,              spread-runtime/thread
  4x4-convergence,                       35.266, GB,             data/thread
  4x4-convergence,                      564.251, GB,             data-total
  4x4-convergence,                        2.852, nsecs,          runtime/byte/thread
  4x4-convergence,                        0.351, GB/sec,         thread-speed
  4x4-convergence,                        5.610, GB/sec,         total-speed

 # Running  4x4-convergence-NOTHP, "perf bench numa mem -p 4 -t 4 -P 512 -s 100 -zZ0qcm --thp  1 --thp -1"
  4x4-convergence-NOTHP,                101.051, secs,           NUMA-convergence-latency
  4x4-convergence-NOTHP,                101.051, secs,           runtime-max/thread
  4x4-convergence-NOTHP,                100.066, secs,           runtime-min/thread
  4x4-convergence-NOTHP,                100.683, secs,           runtime-avg/thread
  4x4-convergence-NOTHP,                  0.487, %,              spread-runtime/thread
  4x4-convergence-NOTHP,                 35.769, GB,             data/thread
  4x4-convergence-NOTHP,                572.304, GB,             data-total
  4x4-convergence-NOTHP,                  2.825, nsecs,          runtime/byte/thread
  4x4-convergence-NOTHP,                  0.354, GB/sec,         thread-speed
  4x4-convergence-NOTHP,                  5.664, GB/sec,         total-speed

 # Running  4x6-convergence, "perf bench numa mem -p 4 -t 6 -P 1020 -s 100 -zZ0qcm --thp  1"
  4x6-convergence,                        5.444, secs,           NUMA-convergence-latency
  4x6-convergence,                        5.444, secs,           runtime-max/thread
  4x6-convergence,                        2.853, secs,           runtime-min/thread
  4x6-convergence,                        4.531, secs,           runtime-avg/thread
  4x6-convergence,                       23.794, %,              spread-runtime/thread
  4x6-convergence,                        1.292, GB,             data/thread
  4x6-convergence,                       31.017, GB,             data-total
  4x6-convergence,                        4.212, nsecs,          runtime/byte/thread
  4x6-convergence,                        0.237, GB/sec,         thread-speed
  4x6-convergence,                        5.698, GB/sec,         total-speed

 # Running  4x8-convergence, "perf bench numa mem -p 4 -t 8 -P 512 -s 100 -zZ0qcm --thp  1"
  4x8-convergence,                      101.133, secs,           NUMA-convergence-latency
  4x8-convergence,                      101.133, secs,           runtime-max/thread
  4x8-convergence,                      100.455, secs,           runtime-min/thread
  4x8-convergence,                      100.803, secs,           runtime-avg/thread
  4x8-convergence,                        0.335, %,              spread-runtime/thread
  4x8-convergence,                       18.522, GB,             data/thread
  4x8-convergence,                      592.705, GB,             data-total
  4x8-convergence,                        5.460, nsecs,          runtime/byte/thread
  4x8-convergence,                        0.183, GB/sec,         thread-speed
  4x8-convergence,                        5.861, GB/sec,         total-speed

 # Running  8x4-convergence, "perf bench numa mem -p 8 -t 4 -P 512 -s 100 -zZ0qcm --thp  1"
  8x4-convergence,                      100.878, secs,           NUMA-convergence-latency
  8x4-convergence,                      100.878, secs,           runtime-max/thread
  8x4-convergence,                      100.021, secs,           runtime-min/thread
  8x4-convergence,                      100.567, secs,           runtime-avg/thread
  8x4-convergence,                        0.425, %,              spread-runtime/thread
  8x4-convergence,                       18.388, GB,             data/thread
  8x4-convergence,                      588.411, GB,             data-total
  8x4-convergence,                        5.486, nsecs,          runtime/byte/thread
  8x4-convergence,                        0.182, GB/sec,         thread-speed
  8x4-convergence,                        5.833, GB/sec,         total-speed

 # Running  8x4-convergence-NOTHP, "perf bench numa mem -p 8 -t 4 -P 512 -s 100 -zZ0qcm --thp  1 --thp -1"
  8x4-convergence-NOTHP,                101.868, secs,           NUMA-convergence-latency
  8x4-convergence-NOTHP,                101.868, secs,           runtime-max/thread
  8x4-convergence-NOTHP,                100.499, secs,           runtime-min/thread
  8x4-convergence-NOTHP,                101.118, secs,           runtime-avg/thread
  8x4-convergence-NOTHP,                  0.672, %,              spread-runtime/thread
  8x4-convergence-NOTHP,                 17.851, GB,             data/thread
  8x4-convergence-NOTHP,                571.231, GB,             data-total
  8x4-convergence-NOTHP,                  5.707, nsecs,          runtime/byte/thread
  8x4-convergence-NOTHP,                  0.175, GB/sec,         thread-speed
  8x4-convergence-NOTHP,                  5.608, GB/sec,         total-speed

 # Running  3x1-convergence, "perf bench numa mem -p 3 -t 1 -P 512 -s 100 -zZ0qcm --thp  1"
  3x1-convergence,                        0.652, secs,           NUMA-convergence-latency
  3x1-convergence,                        0.652, secs,           runtime-max/thread
  3x1-convergence,                        0.471, secs,           runtime-min/thread
  3x1-convergence,                        0.584, secs,           runtime-avg/thread
  3x1-convergence,                       13.878, %,              spread-runtime/thread
  3x1-convergence,                        1.432, GB,             data/thread
  3x1-convergence,                        4.295, GB,             data-total
  3x1-convergence,                        0.456, nsecs,          runtime/byte/thread
  3x1-convergence,                        2.195, GB/sec,         thread-speed
  3x1-convergence,                        6.584, GB/sec,         total-speed

 # Running  4x1-convergence, "perf bench numa mem -p 4 -t 1 -P 512 -s 100 -zZ0qcm --thp  1"
  4x1-convergence,                        0.643, secs,           NUMA-convergence-latency
  4x1-convergence,                        0.643, secs,           runtime-max/thread
  4x1-convergence,                        0.479, secs,           runtime-min/thread
  4x1-convergence,                        0.562, secs,           runtime-avg/thread
  4x1-convergence,                       12.750, %,              spread-runtime/thread
  4x1-convergence,                        1.074, GB,             data/thread
  4x1-convergence,                        4.295, GB,             data-total
  4x1-convergence,                        0.599, nsecs,          runtime/byte/thread
  4x1-convergence,                        1.669, GB/sec,         thread-speed
  4x1-convergence,                        6.677, GB/sec,         total-speed

 # Running  8x1-convergence, "perf bench numa mem -p 8 -t 1 -P 512 -s 100 -zZ0qcm --thp  1"
  8x1-convergence,                        2.803, secs,           NUMA-convergence-latency
  8x1-convergence,                        2.803, secs,           runtime-max/thread
  8x1-convergence,                        2.509, secs,           runtime-min/thread
  8x1-convergence,                        2.664, secs,           runtime-avg/thread
  8x1-convergence,                        5.250, %,              spread-runtime/thread
  8x1-convergence,                        2.147, GB,             data/thread
  8x1-convergence,                       17.180, GB,             data-total
  8x1-convergence,                        1.305, nsecs,          runtime/byte/thread
  8x1-convergence,                        0.766, GB/sec,         thread-speed
  8x1-convergence,                        6.129, GB/sec,         total-speed

 # Running 16x1-convergence, "perf bench numa mem -p 16 -t 1 -P 256 -s 100 -zZ0qcm --thp  1"
 16x1-convergence,                        3.482, secs,           NUMA-convergence-latency
 16x1-convergence,                        3.482, secs,           runtime-max/thread
 16x1-convergence,                        3.162, secs,           runtime-min/thread
 16x1-convergence,                        3.328, secs,           runtime-avg/thread
 16x1-convergence,                        4.603, %,              spread-runtime/thread
 16x1-convergence,                        1.242, GB,             data/thread
 16x1-convergence,                       19.864, GB,             data-total
 16x1-convergence,                        2.805, nsecs,          runtime/byte/thread
 16x1-convergence,                        0.357, GB/sec,         thread-speed
 16x1-convergence,                        5.704, GB/sec,         total-speed

 # Running 32x1-convergence, "perf bench numa mem -p 32 -t 1 -P 128 -s 100 -zZ0qcm --thp  1"
 32x1-convergence,                        3.612, secs,           NUMA-convergence-latency
 32x1-convergence,                        3.612, secs,           runtime-max/thread
 32x1-convergence,                        3.170, secs,           runtime-min/thread
 32x1-convergence,                        3.456, secs,           runtime-avg/thread
 32x1-convergence,                        6.118, %,              spread-runtime/thread
 32x1-convergence,                        0.671, GB,             data/thread
 32x1-convergence,                       21.475, GB,             data-total
 32x1-convergence,                        5.382, nsecs,          runtime/byte/thread
 32x1-convergence,                        0.186, GB/sec,         thread-speed
 32x1-convergence,                        5.945, GB/sec,         total-speed

 # Running  2x1-bw-process, "perf bench numa mem -p 2 -t 1 -P 1024 -s 20 -zZ0q --thp  1"
  2x1-bw-process,                        20.280, secs,           runtime-max/thread
  2x1-bw-process,                        20.059, secs,           runtime-min/thread
  2x1-bw-process,                        20.166, secs,           runtime-avg/thread
  2x1-bw-process,                         0.546, %,              spread-runtime/thread
  2x1-bw-process,                        63.351, GB,             data/thread
  2x1-bw-process,                       126.702, GB,             data-total
  2x1-bw-process,                         0.320, nsecs,          runtime/byte/thread
  2x1-bw-process,                         3.124, GB/sec,         thread-speed
  2x1-bw-process,                         6.248, GB/sec,         total-speed

 # Running  3x1-bw-process, "perf bench numa mem -p 3 -t 1 -P 1024 -s 20 -zZ0q --thp  1"
  3x1-bw-process,                        20.320, secs,           runtime-max/thread
  3x1-bw-process,                        20.078, secs,           runtime-min/thread
  3x1-bw-process,                        20.202, secs,           runtime-avg/thread
  3x1-bw-process,                         0.595, %,              spread-runtime/thread
  3x1-bw-process,                        49.392, GB,             data/thread
  3x1-bw-process,                       148.176, GB,             data-total
  3x1-bw-process,                         0.411, nsecs,          runtime/byte/thread
  3x1-bw-process,                         2.431, GB/sec,         thread-speed
  3x1-bw-process,                         7.292, GB/sec,         total-speed

 # Running  4x1-bw-process, "perf bench numa mem -p 4 -t 1 -P 1024 -s 20 -zZ0q --thp  1"
  4x1-bw-process,                        20.379, secs,           runtime-max/thread
  4x1-bw-process,                        20.210, secs,           runtime-min/thread
  4x1-bw-process,                        20.291, secs,           runtime-avg/thread
  4x1-bw-process,                         0.413, %,              spread-runtime/thread
  4x1-bw-process,                        30.602, GB,             data/thread
  4x1-bw-process,                       122.407, GB,             data-total
  4x1-bw-process,                         0.666, nsecs,          runtime/byte/thread
  4x1-bw-process,                         1.502, GB/sec,         thread-speed
  4x1-bw-process,                         6.007, GB/sec,         total-speed

 # Running  8x1-bw-process, "perf bench numa mem -p 8 -t 1 -P  512 -s 20 -zZ0q --thp  1"
  8x1-bw-process,                        20.419, secs,           runtime-max/thread
  8x1-bw-process,                        20.073, secs,           runtime-min/thread
  8x1-bw-process,                        20.328, secs,           runtime-avg/thread
  8x1-bw-process,                         0.848, %,              spread-runtime/thread
  8x1-bw-process,                        15.569, GB,             data/thread
  8x1-bw-process,                       124.554, GB,             data-total
  8x1-bw-process,                         1.311, nsecs,          runtime/byte/thread
  8x1-bw-process,                         0.762, GB/sec,         thread-speed
  8x1-bw-process,                         6.100, GB/sec,         total-speed

 # Running  8x1-bw-process-NOTHP, "perf bench numa mem -p 8 -t 1 -P  512 -s 20 -zZ0q --thp  1 --thp -1"
  8x1-bw-process-NOTHP,                  20.502, secs,           runtime-max/thread
  8x1-bw-process-NOTHP,                  20.113, secs,           runtime-min/thread
  8x1-bw-process-NOTHP,                  20.307, secs,           runtime-avg/thread
  8x1-bw-process-NOTHP,                   0.950, %,              spread-runtime/thread
  8x1-bw-process-NOTHP,                  15.234, GB,             data/thread
  8x1-bw-process-NOTHP,                 121.870, GB,             data-total
  8x1-bw-process-NOTHP,                   1.346, nsecs,          runtime/byte/thread
  8x1-bw-process-NOTHP,                   0.743, GB/sec,         thread-speed
  8x1-bw-process-NOTHP,                   5.944, GB/sec,         total-speed

 # Running 16x1-bw-process, "perf bench numa mem -p 16 -t 1 -P 256 -s 20 -zZ0q --thp  1"
 16x1-bw-process,                        20.539, secs,           runtime-max/thread
 16x1-bw-process,                        20.145, secs,           runtime-min/thread
 16x1-bw-process,                        20.407, secs,           runtime-avg/thread
 16x1-bw-process,                         0.959, %,              spread-runtime/thread
 16x1-bw-process,                         7.197, GB,             data/thread
 16x1-bw-process,                       115.159, GB,             data-total
 16x1-bw-process,                         2.854, nsecs,          runtime/byte/thread
 16x1-bw-process,                         0.350, GB/sec,         thread-speed
 16x1-bw-process,                         5.607, GB/sec,         total-speed

 # Running  4x1-bw-thread, "perf bench numa mem -p 1 -t 4 -T 256 -s 20 -zZ0q --thp  1"
  4x1-bw-thread,                         20.105, secs,           runtime-max/thread
  4x1-bw-thread,                         20.047, secs,           runtime-min/thread
  4x1-bw-thread,                         20.071, secs,           runtime-avg/thread
  4x1-bw-thread,                          0.144, %,              spread-runtime/thread
  4x1-bw-thread,                         30.333, GB,             data/thread
  4x1-bw-thread,                        121.333, GB,             data-total
  4x1-bw-thread,                          0.663, nsecs,          runtime/byte/thread
  4x1-bw-thread,                          1.509, GB/sec,         thread-speed
  4x1-bw-thread,                          6.035, GB/sec,         total-speed

 # Running  8x1-bw-thread, "perf bench numa mem -p 1 -t 8 -T 256 -s 20 -zZ0q --thp  1"
  8x1-bw-thread,                         20.106, secs,           runtime-max/thread
  8x1-bw-thread,                         20.021, secs,           runtime-min/thread
  8x1-bw-thread,                         20.062, secs,           runtime-avg/thread
  8x1-bw-thread,                          0.213, %,              spread-runtime/thread
  8x1-bw-thread,                         14.932, GB,             data/thread
  8x1-bw-thread,                        119.454, GB,             data-total
  8x1-bw-thread,                          1.347, nsecs,          runtime/byte/thread
  8x1-bw-thread,                          0.743, GB/sec,         thread-speed
  8x1-bw-thread,                          5.941, GB/sec,         total-speed

 # Running 16x1-bw-thread, "perf bench numa mem -p 1 -t 16 -T 128 -s 20 -zZ0q --thp  1"
 16x1-bw-thread,                         20.176, secs,           runtime-max/thread
 16x1-bw-thread,                         20.049, secs,           runtime-min/thread
 16x1-bw-thread,                         20.125, secs,           runtime-avg/thread
 16x1-bw-thread,                          0.314, %,              spread-runtime/thread
 16x1-bw-thread,                          7.122, GB,             data/thread
 16x1-bw-thread,                        113.951, GB,             data-total
 16x1-bw-thread,                          2.833, nsecs,          runtime/byte/thread
 16x1-bw-thread,                          0.353, GB/sec,         thread-speed
 16x1-bw-thread,                          5.648, GB/sec,         total-speed

 # Running 32x1-bw-thread, "perf bench numa mem -p 1 -t 32 -T 64 -s 20 -zZ0q --thp  1"
 32x1-bw-thread,                         20.159, secs,           runtime-max/thread
 32x1-bw-thread,                         20.034, secs,           runtime-min/thread
 32x1-bw-thread,                         20.120, secs,           runtime-avg/thread
 32x1-bw-thread,                          0.309, %,              spread-runtime/thread
 32x1-bw-thread,                          3.735, GB,             data/thread
 32x1-bw-thread,                        119.521, GB,             data-total
 32x1-bw-thread,                          5.397, nsecs,          runtime/byte/thread
 32x1-bw-thread,                          0.185, GB/sec,         thread-speed
 32x1-bw-thread,                          5.929, GB/sec,         total-speed

 # Running  2x3-bw-thread, "perf bench numa mem -p 2 -t 3 -P 512 -s 20 -zZ0q --thp  1"
  2x3-bw-thread,                         20.239, secs,           runtime-max/thread
  2x3-bw-thread,                         20.092, secs,           runtime-min/thread
  2x3-bw-thread,                         20.183, secs,           runtime-avg/thread
  2x3-bw-thread,                          0.363, %,              spread-runtime/thread
  2x3-bw-thread,                         19.417, GB,             data/thread
  2x3-bw-thread,                        116.501, GB,             data-total
  2x3-bw-thread,                          1.042, nsecs,          runtime/byte/thread
  2x3-bw-thread,                          0.959, GB/sec,         thread-speed
  2x3-bw-thread,                          5.756, GB/sec,         total-speed

 # Running  4x4-bw-thread, "perf bench numa mem -p 4 -t 4 -P 512 -s 20 -zZ0q --thp  1"
  4x4-bw-thread,                         20.978, secs,           runtime-max/thread
  4x4-bw-thread,                         20.005, secs,           runtime-min/thread
  4x4-bw-thread,                         20.576, secs,           runtime-avg/thread
  4x4-bw-thread,                          2.321, %,              spread-runtime/thread
  4x4-bw-thread,                          7.348, GB,             data/thread
  4x4-bw-thread,                        117.575, GB,             data-total
  4x4-bw-thread,                          2.855, nsecs,          runtime/byte/thread
  4x4-bw-thread,                          0.350, GB/sec,         thread-speed
  4x4-bw-thread,                          5.605, GB/sec,         total-speed

 # Running  4x6-bw-thread, "perf bench numa mem -p 4 -t 6 -P 512 -s 20 -zZ0q --thp  1"
  4x6-bw-thread,                         21.118, secs,           runtime-max/thread
  4x6-bw-thread,                         20.082, secs,           runtime-min/thread
  4x6-bw-thread,                         20.819, secs,           runtime-avg/thread
  4x6-bw-thread,                          2.451, %,              spread-runtime/thread
  4x6-bw-thread,                          5.078, GB,             data/thread
  4x6-bw-thread,                        121.870, GB,             data-total
  4x6-bw-thread,                          4.159, nsecs,          runtime/byte/thread
  4x6-bw-thread,                          0.240, GB/sec,         thread-speed
  4x6-bw-thread,                          5.771, GB/sec,         total-speed

 # Running  4x8-bw-thread, "perf bench numa mem -p 4 -t 8 -P 512 -s 20 -zZ0q --thp  1"
  4x8-bw-thread,                         21.994, secs,           runtime-max/thread
  4x8-bw-thread,                         20.290, secs,           runtime-min/thread
  4x8-bw-thread,                         21.387, secs,           runtime-avg/thread
  4x8-bw-thread,                          3.874, %,              spread-runtime/thread
  4x8-bw-thread,                          4.027, GB,             data/thread
  4x8-bw-thread,                        128.849, GB,             data-total
  4x8-bw-thread,                          5.462, nsecs,          runtime/byte/thread
  4x8-bw-thread,                          0.183, GB/sec,         thread-speed
  4x8-bw-thread,                          5.858, GB/sec,         total-speed

 # Running  4x8-bw-thread-NOTHP, "perf bench numa mem -p 4 -t 8 -P 512 -s 20 -zZ0q --thp  1 --thp -1"
  4x8-bw-thread-NOTHP,                   22.728, secs,           runtime-max/thread
  4x8-bw-thread-NOTHP,                   20.013, secs,           runtime-min/thread
  4x8-bw-thread-NOTHP,                   21.968, secs,           runtime-avg/thread
  4x8-bw-thread-NOTHP,                    5.975, %,              spread-runtime/thread
  4x8-bw-thread-NOTHP,                    4.010, GB,             data/thread
  4x8-bw-thread-NOTHP,                  128.312, GB,             data-total
  4x8-bw-thread-NOTHP,                    5.668, nsecs,          runtime/byte/thread
  4x8-bw-thread-NOTHP,                    0.176, GB/sec,         thread-speed
  4x8-bw-thread-NOTHP,                    5.645, GB/sec,         total-speed

 # Running  3x3-bw-thread, "perf bench numa mem -p 3 -t 3 -P 512 -s 20 -zZ0q --thp  1"
  3x3-bw-thread,                         20.526, secs,           runtime-max/thread
  3x3-bw-thread,                         20.317, secs,           runtime-min/thread
  3x3-bw-thread,                         20.467, secs,           runtime-avg/thread
  3x3-bw-thread,                          0.510, %,              spread-runtime/thread
  3x3-bw-thread,                         13.541, GB,             data/thread
  3x3-bw-thread,                        121.870, GB,             data-total
  3x3-bw-thread,                          1.516, nsecs,          runtime/byte/thread
  3x3-bw-thread,                          0.660, GB/sec,         thread-speed
  3x3-bw-thread,                          5.937, GB/sec,         total-speed

 # Running  5x5-bw-thread, "perf bench numa mem -p 5 -t 5 -P 512 -s 20 -zZ0q --thp  1"
  5x5-bw-thread,                         21.023, secs,           runtime-max/thread
  5x5-bw-thread,                         20.252, secs,           runtime-min/thread
  5x5-bw-thread,                         20.701, secs,           runtime-avg/thread
  5x5-bw-thread,                          1.833, %,              spread-runtime/thread
  5x5-bw-thread,                          4.853, GB,             data/thread
  5x5-bw-thread,                        121.333, GB,             data-total
  5x5-bw-thread,                          4.332, nsecs,          runtime/byte/thread
  5x5-bw-thread,                          0.231, GB/sec,         thread-speed
  5x5-bw-thread,                          5.771, GB/sec,         total-speed

 # Running 2x16-bw-thread, "perf bench numa mem -p 2 -t 16 -P 512 -s 20 -zZ0q --thp  1"
 2x16-bw-thread,                         21.646, secs,           runtime-max/thread
 2x16-bw-thread,                         20.065, secs,           runtime-min/thread
 2x16-bw-thread,                         21.026, secs,           runtime-avg/thread
 2x16-bw-thread,                          3.652, %,              spread-runtime/thread
 2x16-bw-thread,                          4.027, GB,             data/thread
 2x16-bw-thread,                        128.849, GB,             data-total
 2x16-bw-thread,                          5.376, nsecs,          runtime/byte/thread
 2x16-bw-thread,                          0.186, GB/sec,         thread-speed
 2x16-bw-thread,                          5.953, GB/sec,         total-speed

 # Running 1x32-bw-thread, "perf bench numa mem -p 1 -t 32 -P 2048 -s 20 -zZ0q --thp  1"
 1x32-bw-thread,                         23.377, secs,           runtime-max/thread
 1x32-bw-thread,                         22.030, secs,           runtime-min/thread
 1x32-bw-thread,                         22.936, secs,           runtime-avg/thread
 1x32-bw-thread,                          2.881, %,              spread-runtime/thread
 1x32-bw-thread,                          4.295, GB,             data/thread
 1x32-bw-thread,                        137.439, GB,             data-total
 1x32-bw-thread,                          5.443, nsecs,          runtime/byte/thread
 1x32-bw-thread,                          0.184, GB/sec,         thread-speed
 1x32-bw-thread,                          5.879, GB/sec,         total-speed

 # Running numa02-bw, "perf bench numa mem -p 1 -t 32 -T 32 -s 20 -zZ0q --thp  1"
 numa02-bw,                              20.065, secs,           runtime-max/thread
 numa02-bw,                              20.012, secs,           runtime-min/thread
 numa02-bw,                              20.050, secs,           runtime-avg/thread
 numa02-bw,                               0.132, %,              spread-runtime/thread
 numa02-bw,                               3.793, GB,             data/thread
 numa02-bw,                             121.366, GB,             data-total
 numa02-bw,                               5.290, nsecs,          runtime/byte/thread
 numa02-bw,                               0.189, GB/sec,         thread-speed
 numa02-bw,                               6.049, GB/sec,         total-speed

 # Running numa02-bw-NOTHP, "perf bench numa mem -p 1 -t 32 -T 32 -s 20 -zZ0q --thp  1 --thp -1"
 numa02-bw-NOTHP,                        20.132, secs,           runtime-max/thread
 numa02-bw-NOTHP,                        19.987, secs,           runtime-min/thread
 numa02-bw-NOTHP,                        20.049, secs,           runtime-avg/thread
 numa02-bw-NOTHP,                         0.360, %,              spread-runtime/thread
 numa02-bw-NOTHP,                         3.681, GB,             data/thread
 numa02-bw-NOTHP,                       117.776, GB,             data-total
 numa02-bw-NOTHP,                         5.470, nsecs,          runtime/byte/thread
 numa02-bw-NOTHP,                         0.183, GB/sec,         thread-speed
 numa02-bw-NOTHP,                         5.850, GB/sec,         total-speed

 # Running numa01-bw-thread, "perf bench numa mem -p 2 -t 16 -T 192 -s 20 -zZ0q --thp  1"
 numa01-bw-thread,                       20.704, secs,           runtime-max/thread
 numa01-bw-thread,                       20.185, secs,           runtime-min/thread
 numa01-bw-thread,                       20.571, secs,           runtime-avg/thread
 numa01-bw-thread,                        1.254, %,              spread-runtime/thread
 numa01-bw-thread,                        3.775, GB,             data/thread
 numa01-bw-thread,                      120.796, GB,             data-total
 numa01-bw-thread,                        5.485, nsecs,          runtime/byte/thread
 numa01-bw-thread,                        0.182, GB/sec,         thread-speed
 numa01-bw-thread,                        5.834, GB/sec,         total-speed

 # Running numa01-bw-thread-NOTHP, "perf bench numa mem -p 2 -t 16 -T 192 -s 20 -zZ0q --thp  1 --thp -1"
 numa01-bw-thread-NOTHP,                 20.780, secs,           runtime-max/thread
 numa01-bw-thread-NOTHP,                 20.023, secs,           runtime-min/thread
 numa01-bw-thread-NOTHP,                 20.418, secs,           runtime-avg/thread
 numa01-bw-thread-NOTHP,                  1.821, %,              spread-runtime/thread
 numa01-bw-thread-NOTHP,                  3.624, GB,             data/thread
 numa01-bw-thread-NOTHP,                115.964, GB,             data-total
 numa01-bw-thread-NOTHP,                  5.734, nsecs,          runtime/byte/thread
 numa01-bw-thread-NOTHP,                  0.174, GB/sec,         thread-speed
 numa01-bw-thread-NOTHP,                  5.581, GB/sec,         total-speed

 #
 # Running test on: Linux vega 3.7.0-rc6+ #2 SMP Fri Dec 7 17:59:13 CET 2012 x86_64 x86_64 x86_64 GNU/Linux
 #
# Running numa/mem benchmark...

 # Running main, "perf bench numa mem -a"

 # Running RAM-bw-local, "perf bench numa mem -p 1 -t 1 -P 1024 -C 0 -M 0 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-local,                           20.049, secs,           runtime-max/thread
 RAM-bw-local,                           20.044, secs,           runtime-min/thread
 RAM-bw-local,                           20.044, secs,           runtime-avg/thread
 RAM-bw-local,                            0.014, %,              spread-runtime/thread
 RAM-bw-local,                          172.872, GB,             data/thread
 RAM-bw-local,                          172.872, GB,             data-total
 RAM-bw-local,                            0.116, nsecs,          runtime/byte/thread
 RAM-bw-local,                            8.622, GB/sec,         thread-speed
 RAM-bw-local,                            8.622, GB/sec,         total-speed

 # Running RAM-bw-local-NOTHP, "perf bench numa mem -p 1 -t 1 -P 1024 -C 0 -M 0 -s 20 -zZq --thp  1 --no-data_rand_walk --thp -1"
 RAM-bw-local-NOTHP,                     20.135, secs,           runtime-max/thread
 RAM-bw-local-NOTHP,                     20.059, secs,           runtime-min/thread
 RAM-bw-local-NOTHP,                     20.059, secs,           runtime-avg/thread
 RAM-bw-local-NOTHP,                      0.189, %,              spread-runtime/thread
 RAM-bw-local-NOTHP,                    172.872, GB,             data/thread
 RAM-bw-local-NOTHP,                    172.872, GB,             data-total
 RAM-bw-local-NOTHP,                      0.116, nsecs,          runtime/byte/thread
 RAM-bw-local-NOTHP,                      8.586, GB/sec,         thread-speed
 RAM-bw-local-NOTHP,                      8.586, GB/sec,         total-speed

 # Running RAM-bw-remote, "perf bench numa mem -p 1 -t 1 -P 1024 -C 0 -M 1 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-remote,                          20.080, secs,           runtime-max/thread
 RAM-bw-remote,                          20.073, secs,           runtime-min/thread
 RAM-bw-remote,                          20.073, secs,           runtime-avg/thread
 RAM-bw-remote,                           0.017, %,              spread-runtime/thread
 RAM-bw-remote,                         135.291, GB,             data/thread
 RAM-bw-remote,                         135.291, GB,             data-total
 RAM-bw-remote,                           0.148, nsecs,          runtime/byte/thread
 RAM-bw-remote,                           6.738, GB/sec,         thread-speed
 RAM-bw-remote,                           6.738, GB/sec,         total-speed

 # Running RAM-bw-local-2x, "perf bench numa mem -p 2 -t 1 -P 1024 -C 0,2 -M 0x2 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-local-2x,                        20.127, secs,           runtime-max/thread
 RAM-bw-local-2x,                        20.111, secs,           runtime-min/thread
 RAM-bw-local-2x,                        20.116, secs,           runtime-avg/thread
 RAM-bw-local-2x,                         0.038, %,              spread-runtime/thread
 RAM-bw-local-2x,                       130.997, GB,             data/thread
 RAM-bw-local-2x,                       261.993, GB,             data-total
 RAM-bw-local-2x,                         0.154, nsecs,          runtime/byte/thread
 RAM-bw-local-2x,                         6.509, GB/sec,         thread-speed
 RAM-bw-local-2x,                        13.017, GB/sec,         total-speed

 # Running RAM-bw-remote-2x, "perf bench numa mem -p 2 -t 1 -P 1024 -C 0,2 -M 1x2 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-remote-2x,                       20.183, secs,           runtime-max/thread
 RAM-bw-remote-2x,                       20.110, secs,           runtime-min/thread
 RAM-bw-remote-2x,                       20.143, secs,           runtime-avg/thread
 RAM-bw-remote-2x,                        0.180, %,              spread-runtime/thread
 RAM-bw-remote-2x,                       75.162, GB,             data/thread
 RAM-bw-remote-2x,                      150.324, GB,             data-total
 RAM-bw-remote-2x,                        0.269, nsecs,          runtime/byte/thread
 RAM-bw-remote-2x,                        3.724, GB/sec,         thread-speed
 RAM-bw-remote-2x,                        7.448, GB/sec,         total-speed

 # Running RAM-bw-cross, "perf bench numa mem -p 2 -t 1 -P 1024 -C 0,8 -M 1,0 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-cross,                           20.159, secs,           runtime-max/thread
 RAM-bw-cross,                           20.071, secs,           runtime-min/thread
 RAM-bw-cross,                           20.111, secs,           runtime-avg/thread
 RAM-bw-cross,                            0.220, %,              spread-runtime/thread
 RAM-bw-cross,                          124.017, GB,             data/thread
 RAM-bw-cross,                          248.034, GB,             data-total
 RAM-bw-cross,                            0.163, nsecs,          runtime/byte/thread
 RAM-bw-cross,                            6.152, GB/sec,         thread-speed
 RAM-bw-cross,                           12.304, GB/sec,         total-speed

 # Running  1x3-convergence, "perf bench numa mem -p 1 -t 3 -P 512 -s 100 -zZ0qcm --thp  1"
  1x3-convergence,                      100.038, secs,           NUMA-convergence-latency
  1x3-convergence,                      100.038, secs,           runtime-max/thread
  1x3-convergence,                      100.005, secs,           runtime-min/thread
  1x3-convergence,                      100.016, secs,           runtime-avg/thread
  1x3-convergence,                        0.016, %,              spread-runtime/thread
  1x3-convergence,                      379.210, GB,             data/thread
  1x3-convergence,                     1137.629, GB,             data-total
  1x3-convergence,                        0.264, nsecs,          runtime/byte/thread
  1x3-convergence,                        3.791, GB/sec,         thread-speed
  1x3-convergence,                       11.372, GB/sec,         total-speed

 # Running  1x4-convergence, "perf bench numa mem -p 1 -t 4 -P 512 -s 100 -zZ0qcm --thp  1"
  1x4-convergence,                      100.091, secs,           NUMA-convergence-latency
  1x4-convergence,                      100.091, secs,           runtime-max/thread
  1x4-convergence,                      100.016, secs,           runtime-min/thread
  1x4-convergence,                      100.053, secs,           runtime-avg/thread
  1x4-convergence,                        0.037, %,              spread-runtime/thread
  1x4-convergence,                      162.672, GB,             data/thread
  1x4-convergence,                      650.688, GB,             data-total
  1x4-convergence,                        0.615, nsecs,          runtime/byte/thread
  1x4-convergence,                        1.625, GB/sec,         thread-speed
  1x4-convergence,                        6.501, GB/sec,         total-speed

 # Running  1x6-convergence, "perf bench numa mem -p 1 -t 6 -P 1020 -s 100 -zZ0qcm --thp  1"
  1x6-convergence,                      100.366, secs,           NUMA-convergence-latency
  1x6-convergence,                      100.366, secs,           runtime-max/thread
  1x6-convergence,                      100.005, secs,           runtime-min/thread
  1x6-convergence,                      100.144, secs,           runtime-avg/thread
  1x6-convergence,                        0.180, %,              spread-runtime/thread
  1x6-convergence,                      103.924, GB,             data/thread
  1x6-convergence,                      623.546, GB,             data-total
  1x6-convergence,                        0.966, nsecs,          runtime/byte/thread
  1x6-convergence,                        1.035, GB/sec,         thread-speed
  1x6-convergence,                        6.213, GB/sec,         total-speed

 # Running  2x3-convergence, "perf bench numa mem -p 3 -t 3 -P 1020 -s 100 -zZ0qcm --thp  1"
  2x3-convergence,                      100.632, secs,           NUMA-convergence-latency
  2x3-convergence,                      100.632, secs,           runtime-max/thread
  2x3-convergence,                      100.080, secs,           runtime-min/thread
  2x3-convergence,                      100.376, secs,           runtime-avg/thread
  2x3-convergence,                        0.274, %,              spread-runtime/thread
  2x3-convergence,                       87.941, GB,             data/thread
  2x3-convergence,                      791.465, GB,             data-total
  2x3-convergence,                        1.144, nsecs,          runtime/byte/thread
  2x3-convergence,                        0.874, GB/sec,         thread-speed
  2x3-convergence,                        7.865, GB/sec,         total-speed

 # Running  3x3-convergence, "perf bench numa mem -p 3 -t 3 -P 1020 -s 100 -zZ0qcm --thp  1"
  3x3-convergence,                      100.474, secs,           NUMA-convergence-latency
  3x3-convergence,                      100.474, secs,           runtime-max/thread
  3x3-convergence,                      100.070, secs,           runtime-min/thread
  3x3-convergence,                      100.338, secs,           runtime-avg/thread
  3x3-convergence,                        0.201, %,              spread-runtime/thread
  3x3-convergence,                      118.363, GB,             data/thread
  3x3-convergence,                     1065.269, GB,             data-total
  3x3-convergence,                        0.849, nsecs,          runtime/byte/thread
  3x3-convergence,                        1.178, GB/sec,         thread-speed
  3x3-convergence,                       10.602, GB/sec,         total-speed

 # Running  4x4-convergence, "perf bench numa mem -p 4 -t 4 -P 512 -s 100 -zZ0qcm --thp  1"
  4x4-convergence,                      100.527, secs,           NUMA-convergence-latency
  4x4-convergence,                      100.527, secs,           runtime-max/thread
  4x4-convergence,                      100.179, secs,           runtime-min/thread
  4x4-convergence,                      100.353, secs,           runtime-avg/thread
  4x4-convergence,                        0.173, %,              spread-runtime/thread
  4x4-convergence,                       65.230, GB,             data/thread
  4x4-convergence,                     1043.677, GB,             data-total
  4x4-convergence,                        1.541, nsecs,          runtime/byte/thread
  4x4-convergence,                        0.649, GB/sec,         thread-speed
  4x4-convergence,                       10.382, GB/sec,         total-speed

 # Running  4x4-convergence-NOTHP, "perf bench numa mem -p 4 -t 4 -P 512 -s 100 -zZ0qcm --thp  1 --thp -1"
  4x4-convergence-NOTHP,                100.532, secs,           NUMA-convergence-latency
  4x4-convergence-NOTHP,                100.532, secs,           runtime-max/thread
  4x4-convergence-NOTHP,                100.095, secs,           runtime-min/thread
  4x4-convergence-NOTHP,                100.343, secs,           runtime-avg/thread
  4x4-convergence-NOTHP,                  0.217, %,              spread-runtime/thread
  4x4-convergence-NOTHP,                 57.311, GB,             data/thread
  4x4-convergence-NOTHP,                916.976, GB,             data-total
  4x4-convergence-NOTHP,                  1.754, nsecs,          runtime/byte/thread
  4x4-convergence-NOTHP,                  0.570, GB/sec,         thread-speed
  4x4-convergence-NOTHP,                  9.121, GB/sec,         total-speed

 # Running  4x6-convergence, "perf bench numa mem -p 4 -t 6 -P 1020 -s 100 -zZ0qcm --thp  1"
  4x6-convergence,                      101.230, secs,           NUMA-convergence-latency
  4x6-convergence,                      101.230, secs,           runtime-max/thread
  4x6-convergence,                      100.093, secs,           runtime-min/thread
  4x6-convergence,                      100.825, secs,           runtime-avg/thread
  4x6-convergence,                        0.562, %,              spread-runtime/thread
  4x6-convergence,                       28.076, GB,             data/thread
  4x6-convergence,                      673.815, GB,             data-total
  4x6-convergence,                        3.606, nsecs,          runtime/byte/thread
  4x6-convergence,                        0.277, GB/sec,         thread-speed
  4x6-convergence,                        6.656, GB/sec,         total-speed

 # Running  4x8-convergence, "perf bench numa mem -p 4 -t 8 -P 512 -s 100 -zZ0qcm --thp  1"
  4x8-convergence,                      101.310, secs,           NUMA-convergence-latency
  4x8-convergence,                      101.310, secs,           runtime-max/thread
  4x8-convergence,                      100.052, secs,           runtime-min/thread
  4x8-convergence,                      100.679, secs,           runtime-avg/thread
  4x8-convergence,                        0.621, %,              spread-runtime/thread
  4x8-convergence,                       18.740, GB,             data/thread
  4x8-convergence,                      599.685, GB,             data-total
  4x8-convergence,                        5.406, nsecs,          runtime/byte/thread
  4x8-convergence,                        0.185, GB/sec,         thread-speed
  4x8-convergence,                        5.919, GB/sec,         total-speed

 # Running  8x4-convergence, "perf bench numa mem -p 8 -t 4 -P 512 -s 100 -zZ0qcm --thp  1"
  8x4-convergence,                      100.849, secs,           NUMA-convergence-latency
  8x4-convergence,                      100.849, secs,           runtime-max/thread
  8x4-convergence,                      100.020, secs,           runtime-min/thread
  8x4-convergence,                      100.570, secs,           runtime-avg/thread
  8x4-convergence,                        0.411, %,              spread-runtime/thread
  8x4-convergence,                       22.364, GB,             data/thread
  8x4-convergence,                      715.649, GB,             data-total
  8x4-convergence,                        4.509, nsecs,          runtime/byte/thread
  8x4-convergence,                        0.222, GB/sec,         thread-speed
  8x4-convergence,                        7.096, GB/sec,         total-speed

 # Running  8x4-convergence-NOTHP, "perf bench numa mem -p 8 -t 4 -P 512 -s 100 -zZ0qcm --thp  1 --thp -1"
  8x4-convergence-NOTHP,                100.976, secs,           NUMA-convergence-latency
  8x4-convergence-NOTHP,                100.976, secs,           runtime-max/thread
  8x4-convergence-NOTHP,                100.066, secs,           runtime-min/thread
  8x4-convergence-NOTHP,                100.580, secs,           runtime-avg/thread
  8x4-convergence-NOTHP,                  0.451, %,              spread-runtime/thread
  8x4-convergence-NOTHP,                 27.146, GB,             data/thread
  8x4-convergence-NOTHP,                868.657, GB,             data-total
  8x4-convergence-NOTHP,                  3.720, nsecs,          runtime/byte/thread
  8x4-convergence-NOTHP,                  0.269, GB/sec,         thread-speed
  8x4-convergence-NOTHP,                  8.603, GB/sec,         total-speed

 # Running  3x1-convergence, "perf bench numa mem -p 3 -t 1 -P 512 -s 100 -zZ0qcm --thp  1"
  3x1-convergence,                        1.010, secs,           NUMA-convergence-latency
  3x1-convergence,                        1.010, secs,           runtime-max/thread
  3x1-convergence,                        0.869, secs,           runtime-min/thread
  3x1-convergence,                        0.958, secs,           runtime-avg/thread
  3x1-convergence,                        6.944, %,              spread-runtime/thread
  3x1-convergence,                        2.326, GB,             data/thread
  3x1-convergence,                        6.979, GB,             data-total
  3x1-convergence,                        0.434, nsecs,          runtime/byte/thread
  3x1-convergence,                        2.305, GB/sec,         thread-speed
  3x1-convergence,                        6.914, GB/sec,         total-speed

 # Running  4x1-convergence, "perf bench numa mem -p 4 -t 1 -P 512 -s 100 -zZ0qcm --thp  1"
  4x1-convergence,                        0.782, secs,           NUMA-convergence-latency
  4x1-convergence,                        0.782, secs,           runtime-max/thread
  4x1-convergence,                        0.623, secs,           runtime-min/thread
  4x1-convergence,                        0.689, secs,           runtime-avg/thread
  4x1-convergence,                       10.122, %,              spread-runtime/thread
  4x1-convergence,                        1.208, GB,             data/thread
  4x1-convergence,                        4.832, GB,             data-total
  4x1-convergence,                        0.647, nsecs,          runtime/byte/thread
  4x1-convergence,                        1.545, GB/sec,         thread-speed
  4x1-convergence,                        6.181, GB/sec,         total-speed

 # Running  8x1-convergence, "perf bench numa mem -p 8 -t 1 -P 512 -s 100 -zZ0qcm --thp  1"
  8x1-convergence,                        2.914, secs,           NUMA-convergence-latency
  8x1-convergence,                        2.914, secs,           runtime-max/thread
  8x1-convergence,                        2.533, secs,           runtime-min/thread
  8x1-convergence,                        2.750, secs,           runtime-avg/thread
  8x1-convergence,                        6.538, %,              spread-runtime/thread
  8x1-convergence,                        2.215, GB,             data/thread
  8x1-convergence,                       17.717, GB,             data-total
  8x1-convergence,                        1.316, nsecs,          runtime/byte/thread
  8x1-convergence,                        0.760, GB/sec,         thread-speed
  8x1-convergence,                        6.080, GB/sec,         total-speed

 # Running 16x1-convergence, "perf bench numa mem -p 16 -t 1 -P 256 -s 100 -zZ0qcm --thp  1"
 16x1-convergence,                        3.688, secs,           NUMA-convergence-latency
 16x1-convergence,                        3.688, secs,           runtime-max/thread
 16x1-convergence,                        3.358, secs,           runtime-min/thread
 16x1-convergence,                        3.533, secs,           runtime-avg/thread
 16x1-convergence,                        4.481, %,              spread-runtime/thread
 16x1-convergence,                        1.292, GB,             data/thread
 16x1-convergence,                       20.670, GB,             data-total
 16x1-convergence,                        2.855, nsecs,          runtime/byte/thread
 16x1-convergence,                        0.350, GB/sec,         thread-speed
 16x1-convergence,                        5.604, GB/sec,         total-speed

 # Running 32x1-convergence, "perf bench numa mem -p 32 -t 1 -P 128 -s 100 -zZ0qcm --thp  1"
 32x1-convergence,                        2.762, secs,           NUMA-convergence-latency
 32x1-convergence,                        2.762, secs,           runtime-max/thread
 32x1-convergence,                        2.552, secs,           runtime-min/thread
 32x1-convergence,                        2.735, secs,           runtime-avg/thread
 32x1-convergence,                        3.807, %,              spread-runtime/thread
 32x1-convergence,                        0.516, GB,             data/thread
 32x1-convergence,                       16.509, GB,             data-total
 32x1-convergence,                        5.354, nsecs,          runtime/byte/thread
 32x1-convergence,                        0.187, GB/sec,         thread-speed
 32x1-convergence,                        5.976, GB/sec,         total-speed

 # Running  2x1-bw-process, "perf bench numa mem -p 2 -t 1 -P 1024 -s 20 -zZ0q --thp  1"
  2x1-bw-process,                        20.123, secs,           runtime-max/thread
  2x1-bw-process,                        20.053, secs,           runtime-min/thread
  2x1-bw-process,                        20.085, secs,           runtime-avg/thread
  2x1-bw-process,                         0.173, %,              spread-runtime/thread
  2x1-bw-process,                        61.740, GB,             data/thread
  2x1-bw-process,                       123.480, GB,             data-total
  2x1-bw-process,                         0.326, nsecs,          runtime/byte/thread
  2x1-bw-process,                         3.068, GB/sec,         thread-speed
  2x1-bw-process,                         6.136, GB/sec,         total-speed

 # Running  3x1-bw-process, "perf bench numa mem -p 3 -t 1 -P 1024 -s 20 -zZ0q --thp  1"
  3x1-bw-process,                        20.143, secs,           runtime-max/thread
  3x1-bw-process,                        20.043, secs,           runtime-min/thread
  3x1-bw-process,                        20.091, secs,           runtime-avg/thread
  3x1-bw-process,                         0.249, %,              spread-runtime/thread
  3x1-bw-process,                        48.676, GB,             data/thread
  3x1-bw-process,                       146.029, GB,             data-total
  3x1-bw-process,                         0.414, nsecs,          runtime/byte/thread
  3x1-bw-process,                         2.417, GB/sec,         thread-speed
  3x1-bw-process,                         7.250, GB/sec,         total-speed

 # Running  4x1-bw-process, "perf bench numa mem -p 4 -t 1 -P 1024 -s 20 -zZ0q --thp  1"
  4x1-bw-process,                        20.327, secs,           runtime-max/thread
  4x1-bw-process,                        20.020, secs,           runtime-min/thread
  4x1-bw-process,                        20.168, secs,           runtime-avg/thread
  4x1-bw-process,                         0.754, %,              spread-runtime/thread
  4x1-bw-process,                        34.897, GB,             data/thread
  4x1-bw-process,                       139.586, GB,             data-total
  4x1-bw-process,                         0.582, nsecs,          runtime/byte/thread
  4x1-bw-process,                         1.717, GB/sec,         thread-speed
  4x1-bw-process,                         6.867, GB/sec,         total-speed

 # Running  8x1-bw-process, "perf bench numa mem -p 8 -t 1 -P  512 -s 20 -zZ0q --thp  1"
  8x1-bw-process,                        20.063, secs,           runtime-max/thread
  8x1-bw-process,                        20.004, secs,           runtime-min/thread
  8x1-bw-process,                        20.034, secs,           runtime-avg/thread
  8x1-bw-process,                         0.148, %,              spread-runtime/thread
  8x1-bw-process,                        19.998, GB,             data/thread
  8x1-bw-process,                       159.988, GB,             data-total
  8x1-bw-process,                         1.003, nsecs,          runtime/byte/thread
  8x1-bw-process,                         0.997, GB/sec,         thread-speed
  8x1-bw-process,                         7.974, GB/sec,         total-speed

 # Running  8x1-bw-process-NOTHP, "perf bench numa mem -p 8 -t 1 -P  512 -s 20 -zZ0q --thp  1 --thp -1"
  8x1-bw-process-NOTHP,                  20.435, secs,           runtime-max/thread
  8x1-bw-process-NOTHP,                  20.150, secs,           runtime-min/thread
  8x1-bw-process-NOTHP,                  20.255, secs,           runtime-avg/thread
  8x1-bw-process-NOTHP,                   0.699, %,              spread-runtime/thread
  8x1-bw-process-NOTHP,                  15.167, GB,             data/thread
  8x1-bw-process-NOTHP,                 121.333, GB,             data-total
  8x1-bw-process-NOTHP,                   1.347, nsecs,          runtime/byte/thread
  8x1-bw-process-NOTHP,                   0.742, GB/sec,         thread-speed
  8x1-bw-process-NOTHP,                   5.937, GB/sec,         total-speed

 # Running 16x1-bw-process, "perf bench numa mem -p 16 -t 1 -P 256 -s 20 -zZ0q --thp  1"
 16x1-bw-process,                        20.451, secs,           runtime-max/thread
 16x1-bw-process,                        20.078, secs,           runtime-min/thread
 16x1-bw-process,                        20.311, secs,           runtime-avg/thread
 16x1-bw-process,                         0.912, %,              spread-runtime/thread
 16x1-bw-process,                         7.147, GB,             data/thread
 16x1-bw-process,                       114.354, GB,             data-total
 16x1-bw-process,                         2.861, nsecs,          runtime/byte/thread
 16x1-bw-process,                         0.349, GB/sec,         thread-speed
 16x1-bw-process,                         5.592, GB/sec,         total-speed

 # Running  4x1-bw-thread, "perf bench numa mem -p 1 -t 4 -T 256 -s 20 -zZ0q --thp  1"
  4x1-bw-thread,                         20.038, secs,           runtime-max/thread
  4x1-bw-thread,                         20.006, secs,           runtime-min/thread
  4x1-bw-thread,                         20.023, secs,           runtime-avg/thread
  4x1-bw-thread,                          0.079, %,              spread-runtime/thread
  4x1-bw-thread,                         68.115, GB,             data/thread
  4x1-bw-thread,                        272.462, GB,             data-total
  4x1-bw-thread,                          0.294, nsecs,          runtime/byte/thread
  4x1-bw-thread,                          3.399, GB/sec,         thread-speed
  4x1-bw-thread,                         13.598, GB/sec,         total-speed

 # Running  8x1-bw-thread, "perf bench numa mem -p 1 -t 8 -T 256 -s 20 -zZ0q --thp  1"
  8x1-bw-thread,                         20.055, secs,           runtime-max/thread
  8x1-bw-thread,                         20.001, secs,           runtime-min/thread
  8x1-bw-thread,                         20.033, secs,           runtime-avg/thread
  8x1-bw-thread,                          0.136, %,              spread-runtime/thread
  8x1-bw-thread,                         41.004, GB,             data/thread
  8x1-bw-thread,                        328.028, GB,             data-total
  8x1-bw-thread,                          0.489, nsecs,          runtime/byte/thread
  8x1-bw-thread,                          2.045, GB/sec,         thread-speed
  8x1-bw-thread,                         16.356, GB/sec,         total-speed

 # Running 16x1-bw-thread, "perf bench numa mem -p 1 -t 16 -T 128 -s 20 -zZ0q --thp  1"
 16x1-bw-thread,                         20.044, secs,           runtime-max/thread
 16x1-bw-thread,                         19.994, secs,           runtime-min/thread
 16x1-bw-thread,                         20.021, secs,           runtime-avg/thread
 16x1-bw-thread,                          0.124, %,              spread-runtime/thread
 16x1-bw-thread,                         30.828, GB,             data/thread
 16x1-bw-thread,                        493.250, GB,             data-total
 16x1-bw-thread,                          0.650, nsecs,          runtime/byte/thread
 16x1-bw-thread,                          1.538, GB/sec,         thread-speed
 16x1-bw-thread,                         24.608, GB/sec,         total-speed

 # Running 32x1-bw-thread, "perf bench numa mem -p 1 -t 32 -T 64 -s 20 -zZ0q --thp  1"
 32x1-bw-thread,                         19.990, secs,           runtime-max/thread
 32x1-bw-thread,                         19.955, secs,           runtime-min/thread
 32x1-bw-thread,                         19.996, secs,           runtime-avg/thread
 32x1-bw-thread,                          0.087, %,              spread-runtime/thread
 32x1-bw-thread,                         15.915, GB,             data/thread
 32x1-bw-thread,                        509.289, GB,             data-total
 32x1-bw-thread,                          1.256, nsecs,          runtime/byte/thread
 32x1-bw-thread,                          0.796, GB/sec,         thread-speed
 32x1-bw-thread,                         25.477, GB/sec,         total-speed

 # Running  2x3-bw-thread, "perf bench numa mem -p 2 -t 3 -P 512 -s 20 -zZ0q --thp  1"
  2x3-bw-thread,                         20.168, secs,           runtime-max/thread
  2x3-bw-thread,                         20.028, secs,           runtime-min/thread
  2x3-bw-thread,                         20.103, secs,           runtime-avg/thread
  2x3-bw-thread,                          0.346, %,              spread-runtime/thread
  2x3-bw-thread,                         29.528, GB,             data/thread
  2x3-bw-thread,                        177.167, GB,             data-total
  2x3-bw-thread,                          0.683, nsecs,          runtime/byte/thread
  2x3-bw-thread,                          1.464, GB/sec,         thread-speed
  2x3-bw-thread,                          8.785, GB/sec,         total-speed

 # Running  4x4-bw-thread, "perf bench numa mem -p 4 -t 4 -P 512 -s 20 -zZ0q --thp  1"
  4x4-bw-thread,                         20.576, secs,           runtime-max/thread
  4x4-bw-thread,                         20.002, secs,           runtime-min/thread
  4x4-bw-thread,                         20.312, secs,           runtime-avg/thread
  4x4-bw-thread,                          1.394, %,              spread-runtime/thread
  4x4-bw-thread,                          8.187, GB,             data/thread
  4x4-bw-thread,                        130.997, GB,             data-total
  4x4-bw-thread,                          2.513, nsecs,          runtime/byte/thread
  4x4-bw-thread,                          0.398, GB/sec,         thread-speed
  4x4-bw-thread,                          6.366, GB/sec,         total-speed

 # Running  4x6-bw-thread, "perf bench numa mem -p 4 -t 6 -P 512 -s 20 -zZ0q --thp  1"
  4x6-bw-thread,                         21.007, secs,           runtime-max/thread
  4x6-bw-thread,                         20.075, secs,           runtime-min/thread
  4x6-bw-thread,                         20.573, secs,           runtime-avg/thread
  4x6-bw-thread,                          2.219, %,              spread-runtime/thread
  4x6-bw-thread,                          5.503, GB,             data/thread
  4x6-bw-thread,                        132.070, GB,             data-total
  4x6-bw-thread,                          3.817, nsecs,          runtime/byte/thread
  4x6-bw-thread,                          0.262, GB/sec,         thread-speed
  4x6-bw-thread,                          6.287, GB/sec,         total-speed

 # Running  4x8-bw-thread, "perf bench numa mem -p 4 -t 8 -P 512 -s 20 -zZ0q --thp  1"
  4x8-bw-thread,                         21.986, secs,           runtime-max/thread
  4x8-bw-thread,                         20.359, secs,           runtime-min/thread
  4x8-bw-thread,                         21.300, secs,           runtime-avg/thread
  4x8-bw-thread,                          3.701, %,              spread-runtime/thread
  4x8-bw-thread,                          4.027, GB,             data/thread
  4x8-bw-thread,                        128.849, GB,             data-total
  4x8-bw-thread,                          5.460, nsecs,          runtime/byte/thread
  4x8-bw-thread,                          0.183, GB/sec,         thread-speed
  4x8-bw-thread,                          5.860, GB/sec,         total-speed

 # Running  4x8-bw-thread-NOTHP, "perf bench numa mem -p 4 -t 8 -P 512 -s 20 -zZ0q --thp  1 --thp -1"
  4x8-bw-thread-NOTHP,                   21.155, secs,           runtime-max/thread
  4x8-bw-thread-NOTHP,                   20.115, secs,           runtime-min/thread
  4x8-bw-thread-NOTHP,                   20.705, secs,           runtime-avg/thread
  4x8-bw-thread-NOTHP,                    2.459, %,              spread-runtime/thread
  4x8-bw-thread-NOTHP,                    4.077, GB,             data/thread
  4x8-bw-thread-NOTHP,                  130.460, GB,             data-total
  4x8-bw-thread-NOTHP,                    5.189, nsecs,          runtime/byte/thread
  4x8-bw-thread-NOTHP,                    0.193, GB/sec,         thread-speed
  4x8-bw-thread-NOTHP,                    6.167, GB/sec,         total-speed

 # Running  3x3-bw-thread, "perf bench numa mem -p 3 -t 3 -P 512 -s 20 -zZ0q --thp  1"
  3x3-bw-thread,                         20.211, secs,           runtime-max/thread
  3x3-bw-thread,                         20.044, secs,           runtime-min/thread
  3x3-bw-thread,                         20.127, secs,           runtime-avg/thread
  3x3-bw-thread,                          0.413, %,              spread-runtime/thread
  3x3-bw-thread,                         18.492, GB,             data/thread
  3x3-bw-thread,                        166.430, GB,             data-total
  3x3-bw-thread,                          1.093, nsecs,          runtime/byte/thread
  3x3-bw-thread,                          0.915, GB/sec,         thread-speed
  3x3-bw-thread,                          8.235, GB/sec,         total-speed

 # Running  5x5-bw-thread, "perf bench numa mem -p 5 -t 5 -P 512 -s 20 -zZ0q --thp  1"
  5x5-bw-thread,                         21.244, secs,           runtime-max/thread
  5x5-bw-thread,                         20.115, secs,           runtime-min/thread
  5x5-bw-thread,                         20.873, secs,           runtime-avg/thread
  5x5-bw-thread,                          2.657, %,              spread-runtime/thread
  5x5-bw-thread,                          4.896, GB,             data/thread
  5x5-bw-thread,                        122.407, GB,             data-total
  5x5-bw-thread,                          4.339, nsecs,          runtime/byte/thread
  5x5-bw-thread,                          0.230, GB/sec,         thread-speed
  5x5-bw-thread,                          5.762, GB/sec,         total-speed

 # Running 2x16-bw-thread, "perf bench numa mem -p 2 -t 16 -P 512 -s 20 -zZ0q --thp  1"
 2x16-bw-thread,                         21.854, secs,           runtime-max/thread
 2x16-bw-thread,                         20.047, secs,           runtime-min/thread
 2x16-bw-thread,                         21.157, secs,           runtime-avg/thread
 2x16-bw-thread,                          4.135, %,              spread-runtime/thread
 2x16-bw-thread,                          4.043, GB,             data/thread
 2x16-bw-thread,                        129.386, GB,             data-total
 2x16-bw-thread,                          5.405, nsecs,          runtime/byte/thread
 2x16-bw-thread,                          0.185, GB/sec,         thread-speed
 2x16-bw-thread,                          5.920, GB/sec,         total-speed

 # Running 1x32-bw-thread, "perf bench numa mem -p 1 -t 32 -P 2048 -s 20 -zZ0q --thp  1"
 1x32-bw-thread,                         23.952, secs,           runtime-max/thread
 1x32-bw-thread,                         20.470, secs,           runtime-min/thread
 1x32-bw-thread,                         22.975, secs,           runtime-avg/thread
 1x32-bw-thread,                          7.268, %,              spread-runtime/thread
 1x32-bw-thread,                          4.362, GB,             data/thread
 1x32-bw-thread,                        139.586, GB,             data-total
 1x32-bw-thread,                          5.491, nsecs,          runtime/byte/thread
 1x32-bw-thread,                          0.182, GB/sec,         thread-speed
 1x32-bw-thread,                          5.828, GB/sec,         total-speed

 # Running numa02-bw, "perf bench numa mem -p 1 -t 32 -T 32 -s 20 -zZ0q --thp  1"
 numa02-bw,                              19.990, secs,           runtime-max/thread
 numa02-bw,                              19.975, secs,           runtime-min/thread
 numa02-bw,                              19.995, secs,           runtime-avg/thread
 numa02-bw,                               0.037, %,              spread-runtime/thread
 numa02-bw,                              18.150, GB,             data/thread
 numa02-bw,                             580.794, GB,             data-total
 numa02-bw,                               1.101, nsecs,          runtime/byte/thread
 numa02-bw,                               0.908, GB/sec,         thread-speed
 numa02-bw,                              29.054, GB/sec,         total-speed

 # Running numa02-bw-NOTHP, "perf bench numa mem -p 1 -t 32 -T 32 -s 20 -zZ0q --thp  1 --thp -1"
 numa02-bw-NOTHP,                        20.072, secs,           runtime-max/thread
 numa02-bw-NOTHP,                        19.965, secs,           runtime-min/thread
 numa02-bw-NOTHP,                        19.998, secs,           runtime-avg/thread
 numa02-bw-NOTHP,                         0.266, %,              spread-runtime/thread
 numa02-bw-NOTHP,                        16.975, GB,             data/thread
 numa02-bw-NOTHP,                       543.213, GB,             data-total
 numa02-bw-NOTHP,                         1.182, nsecs,          runtime/byte/thread
 numa02-bw-NOTHP,                         0.846, GB/sec,         thread-speed
 numa02-bw-NOTHP,                        27.064, GB/sec,         total-speed

 # Running numa01-bw-thread, "perf bench numa mem -p 2 -t 16 -T 192 -s 20 -zZ0q --thp  1"
 numa01-bw-thread,                       20.125, secs,           runtime-max/thread
 numa01-bw-thread,                       19.980, secs,           runtime-min/thread
 numa01-bw-thread,                       20.094, secs,           runtime-avg/thread
 numa01-bw-thread,                        0.361, %,              spread-runtime/thread
 numa01-bw-thread,                       12.791, GB,             data/thread
 numa01-bw-thread,                      409.297, GB,             data-total
 numa01-bw-thread,                        1.573, nsecs,          runtime/byte/thread
 numa01-bw-thread,                        0.636, GB/sec,         thread-speed
 numa01-bw-thread,                       20.338, GB/sec,         total-speed

 # Running numa01-bw-thread-NOTHP, "perf bench numa mem -p 2 -t 16 -T 192 -s 20 -zZ0q --thp  1 --thp -1"
 numa01-bw-thread-NOTHP,                 20.298, secs,           runtime-max/thread
 numa01-bw-thread-NOTHP,                 19.965, secs,           runtime-min/thread
 numa01-bw-thread-NOTHP,                 20.055, secs,           runtime-avg/thread
 numa01-bw-thread-NOTHP,                  0.820, %,              spread-runtime/thread
 numa01-bw-thread-NOTHP,                 11.752, GB,             data/thread
 numa01-bw-thread-NOTHP,                376.078, GB,             data-total
 numa01-bw-thread-NOTHP,                  1.727, nsecs,          runtime/byte/thread
 numa01-bw-thread-NOTHP,                  0.579, GB/sec,         thread-speed
 numa01-bw-thread-NOTHP,                 18.528, GB/sec,         total-speed

 #
 # Running test on: Linux vega 3.6.0+ #4 SMP Fri Dec 7 19:14:49 CET 2012 x86_64 x86_64 x86_64 GNU/Linux
 #
# Running numa/mem benchmark...

 # Running main, "perf bench numa mem -a"

 # Running RAM-bw-local, "perf bench numa mem -p 1 -t 1 -P 1024 -C 0 -M 0 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-local,                           20.080, secs,           runtime-max/thread
 RAM-bw-local,                           20.073, secs,           runtime-min/thread
 RAM-bw-local,                           20.073, secs,           runtime-avg/thread
 RAM-bw-local,                            0.018, %,              spread-runtime/thread
 RAM-bw-local,                          170.725, GB,             data/thread
 RAM-bw-local,                          170.725, GB,             data-total
 RAM-bw-local,                            0.118, nsecs,          runtime/byte/thread
 RAM-bw-local,                            8.502, GB/sec,         thread-speed
 RAM-bw-local,                            8.502, GB/sec,         total-speed

 # Running RAM-bw-local-NOTHP, "perf bench numa mem -p 1 -t 1 -P 1024 -C 0 -M 0 -s 20 -zZq --thp  1 --no-data_rand_walk --thp -1"
 RAM-bw-local-NOTHP,                     20.112, secs,           runtime-max/thread
 RAM-bw-local-NOTHP,                     20.028, secs,           runtime-min/thread
 RAM-bw-local-NOTHP,                     20.028, secs,           runtime-avg/thread
 RAM-bw-local-NOTHP,                      0.209, %,              spread-runtime/thread
 RAM-bw-local-NOTHP,                    169.651, GB,             data/thread
 RAM-bw-local-NOTHP,                    169.651, GB,             data-total
 RAM-bw-local-NOTHP,                      0.119, nsecs,          runtime/byte/thread
 RAM-bw-local-NOTHP,                      8.435, GB/sec,         thread-speed
 RAM-bw-local-NOTHP,                      8.435, GB/sec,         total-speed

 # Running RAM-bw-remote, "perf bench numa mem -p 1 -t 1 -P 1024 -C 0 -M 1 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-remote,                          20.101, secs,           runtime-max/thread
 RAM-bw-remote,                          20.093, secs,           runtime-min/thread
 RAM-bw-remote,                          20.093, secs,           runtime-avg/thread
 RAM-bw-remote,                           0.021, %,              spread-runtime/thread
 RAM-bw-remote,                         134.218, GB,             data/thread
 RAM-bw-remote,                         134.218, GB,             data-total
 RAM-bw-remote,                           0.150, nsecs,          runtime/byte/thread
 RAM-bw-remote,                           6.677, GB/sec,         thread-speed
 RAM-bw-remote,                           6.677, GB/sec,         total-speed

 # Running RAM-bw-local-2x, "perf bench numa mem -p 2 -t 1 -P 1024 -C 0,2 -M 0x2 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-local-2x,                        20.109, secs,           runtime-max/thread
 RAM-bw-local-2x,                        20.011, secs,           runtime-min/thread
 RAM-bw-local-2x,                        20.056, secs,           runtime-avg/thread
 RAM-bw-local-2x,                         0.243, %,              spread-runtime/thread
 RAM-bw-local-2x,                       135.291, GB,             data/thread
 RAM-bw-local-2x,                       270.583, GB,             data-total
 RAM-bw-local-2x,                         0.149, nsecs,          runtime/byte/thread
 RAM-bw-local-2x,                         6.728, GB/sec,         thread-speed
 RAM-bw-local-2x,                        13.456, GB/sec,         total-speed

 # Running RAM-bw-remote-2x, "perf bench numa mem -p 2 -t 1 -P 1024 -C 0,2 -M 1x2 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-remote-2x,                       20.292, secs,           runtime-max/thread
 RAM-bw-remote-2x,                       20.279, secs,           runtime-min/thread
 RAM-bw-remote-2x,                       20.281, secs,           runtime-avg/thread
 RAM-bw-remote-2x,                        0.034, %,              spread-runtime/thread
 RAM-bw-remote-2x,                       74.625, GB,             data/thread
 RAM-bw-remote-2x,                      149.250, GB,             data-total
 RAM-bw-remote-2x,                        0.272, nsecs,          runtime/byte/thread
 RAM-bw-remote-2x,                        3.677, GB/sec,         thread-speed
 RAM-bw-remote-2x,                        7.355, GB/sec,         total-speed

 # Running RAM-bw-cross, "perf bench numa mem -p 2 -t 1 -P 1024 -C 0,8 -M 1,0 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-cross,                           20.177, secs,           runtime-max/thread
 RAM-bw-cross,                           20.158, secs,           runtime-min/thread
 RAM-bw-cross,                           20.163, secs,           runtime-avg/thread
 RAM-bw-cross,                            0.048, %,              spread-runtime/thread
 RAM-bw-cross,                          122.943, GB,             data/thread
 RAM-bw-cross,                          245.887, GB,             data-total
 RAM-bw-cross,                            0.164, nsecs,          runtime/byte/thread
 RAM-bw-cross,                            6.093, GB/sec,         thread-speed
 RAM-bw-cross,                           12.187, GB/sec,         total-speed

 # Running  1x3-convergence, "perf bench numa mem -p 1 -t 3 -P 512 -s 100 -zZ0qcm --thp  1"
  1x3-convergence,                        0.224, secs,           NUMA-convergence-latency
  1x3-convergence,                        0.224, secs,           runtime-max/thread
  1x3-convergence,                        0.205, secs,           runtime-min/thread
  1x3-convergence,                        0.214, secs,           runtime-avg/thread
  1x3-convergence,                        4.078, %,              spread-runtime/thread
  1x3-convergence,                        0.537, GB,             data/thread
  1x3-convergence,                        1.611, GB,             data-total
  1x3-convergence,                        0.417, nsecs,          runtime/byte/thread
  1x3-convergence,                        2.401, GB/sec,         thread-speed
  1x3-convergence,                        7.202, GB/sec,         total-speed

 # Running  1x4-convergence, "perf bench numa mem -p 1 -t 4 -P 512 -s 100 -zZ0qcm --thp  1"
  1x4-convergence,                      100.173, secs,           NUMA-convergence-latency
  1x4-convergence,                      100.173, secs,           runtime-max/thread
  1x4-convergence,                      100.026, secs,           runtime-min/thread
  1x4-convergence,                      100.067, secs,           runtime-avg/thread
  1x4-convergence,                        0.073, %,              spread-runtime/thread
  1x4-convergence,                      162.672, GB,             data/thread
  1x4-convergence,                      650.688, GB,             data-total
  1x4-convergence,                        0.616, nsecs,          runtime/byte/thread
  1x4-convergence,                        1.624, GB/sec,         thread-speed
  1x4-convergence,                        6.496, GB/sec,         total-speed

 # Running  1x6-convergence, "perf bench numa mem -p 1 -t 6 -P 1020 -s 100 -zZ0qcm --thp  1"
  1x6-convergence,                      100.821, secs,           NUMA-convergence-latency
  1x6-convergence,                      100.821, secs,           runtime-max/thread
  1x6-convergence,                      100.428, secs,           runtime-min/thread
  1x6-convergence,                      100.706, secs,           runtime-avg/thread
  1x6-convergence,                        0.195, %,              spread-runtime/thread
  1x6-convergence,                       99.111, GB,             data/thread
  1x6-convergence,                      594.668, GB,             data-total
  1x6-convergence,                        1.017, nsecs,          runtime/byte/thread
  1x6-convergence,                        0.983, GB/sec,         thread-speed
  1x6-convergence,                        5.898, GB/sec,         total-speed

 # Running  2x3-convergence, "perf bench numa mem -p 3 -t 3 -P 1020 -s 100 -zZ0qcm --thp  1"
  2x3-convergence,                      100.539, secs,           NUMA-convergence-latency
  2x3-convergence,                      100.539, secs,           runtime-max/thread
  2x3-convergence,                      100.015, secs,           runtime-min/thread
  2x3-convergence,                      100.273, secs,           runtime-avg/thread
  2x3-convergence,                        0.260, %,              spread-runtime/thread
  2x3-convergence,                      147.954, GB,             data/thread
  2x3-convergence,                     1331.587, GB,             data-total
  2x3-convergence,                        0.680, nsecs,          runtime/byte/thread
  2x3-convergence,                        1.472, GB/sec,         thread-speed
  2x3-convergence,                       13.245, GB/sec,         total-speed

 # Running  3x3-convergence, "perf bench numa mem -p 3 -t 3 -P 1020 -s 100 -zZ0qcm --thp  1"
  3x3-convergence,                      100.463, secs,           NUMA-convergence-latency
  3x3-convergence,                      100.463, secs,           runtime-max/thread
  3x3-convergence,                      100.066, secs,           runtime-min/thread
  3x3-convergence,                      100.216, secs,           runtime-avg/thread
  3x3-convergence,                        0.198, %,              spread-runtime/thread
  3x3-convergence,                      132.624, GB,             data/thread
  3x3-convergence,                     1193.615, GB,             data-total
  3x3-convergence,                        0.758, nsecs,          runtime/byte/thread
  3x3-convergence,                        1.320, GB/sec,         thread-speed
  3x3-convergence,                       11.881, GB/sec,         total-speed

 # Running  4x4-convergence, "perf bench numa mem -p 4 -t 4 -P 512 -s 100 -zZ0qcm --thp  1"
  4x4-convergence,                        4.119, secs,           NUMA-convergence-latency
  4x4-convergence,                        4.119, secs,           runtime-max/thread
  4x4-convergence,                        3.751, secs,           runtime-min/thread
  4x4-convergence,                        3.948, secs,           runtime-avg/thread
  4x4-convergence,                        4.462, %,              spread-runtime/thread
  4x4-convergence,                        1.980, GB,             data/thread
  4x4-convergence,                       31.675, GB,             data-total
  4x4-convergence,                        2.081, nsecs,          runtime/byte/thread
  4x4-convergence,                        0.481, GB/sec,         thread-speed
  4x4-convergence,                        7.690, GB/sec,         total-speed

 # Running  4x4-convergence-NOTHP, "perf bench numa mem -p 4 -t 4 -P 512 -s 100 -zZ0qcm --thp  1 --thp -1"
  4x4-convergence-NOTHP,                 12.166, secs,           NUMA-convergence-latency
  4x4-convergence-NOTHP,                 12.166, secs,           runtime-max/thread
  4x4-convergence-NOTHP,                 11.801, secs,           runtime-min/thread
  4x4-convergence-NOTHP,                 11.917, secs,           runtime-avg/thread
  4x4-convergence-NOTHP,                  1.502, %,              spread-runtime/thread
  4x4-convergence-NOTHP,                  5.234, GB,             data/thread
  4x4-convergence-NOTHP,                 83.752, GB,             data-total
  4x4-convergence-NOTHP,                  2.324, nsecs,          runtime/byte/thread
  4x4-convergence-NOTHP,                  0.430, GB/sec,         thread-speed
  4x4-convergence-NOTHP,                  6.884, GB/sec,         total-speed

 # Running  4x6-convergence, "perf bench numa mem -p 4 -t 6 -P 1020 -s 100 -zZ0qcm --thp  1"
  4x6-convergence,                       16.592, secs,           NUMA-convergence-latency
  4x6-convergence,                       16.592, secs,           runtime-max/thread
  4x6-convergence,                       15.407, secs,           runtime-min/thread
  4x6-convergence,                       16.109, secs,           runtime-avg/thread
  4x6-convergence,                        3.572, %,              spread-runtime/thread
  4x6-convergence,                        6.729, GB,             data/thread
  4x6-convergence,                      161.502, GB,             data-total
  4x6-convergence,                        2.466, nsecs,          runtime/byte/thread
  4x6-convergence,                        0.406, GB/sec,         thread-speed
  4x6-convergence,                        9.734, GB/sec,         total-speed

 # Running  4x8-convergence, "perf bench numa mem -p 4 -t 8 -P 512 -s 100 -zZ0qcm --thp  1"
  4x8-convergence,                        3.385, secs,           NUMA-convergence-latency
  4x8-convergence,                        3.385, secs,           runtime-max/thread
  4x8-convergence,                        1.465, secs,           runtime-min/thread
  4x8-convergence,                        2.846, secs,           runtime-avg/thread
  4x8-convergence,                       28.361, %,              spread-runtime/thread
  4x8-convergence,                        0.638, GB,             data/thread
  4x8-convergence,                       20.401, GB,             data-total
  4x8-convergence,                        5.309, nsecs,          runtime/byte/thread
  4x8-convergence,                        0.188, GB/sec,         thread-speed
  4x8-convergence,                        6.028, GB/sec,         total-speed

 # Running  8x4-convergence, "perf bench numa mem -p 8 -t 4 -P 512 -s 100 -zZ0qcm --thp  1"
  8x4-convergence,                       18.295, secs,           NUMA-convergence-latency
  8x4-convergence,                       18.295, secs,           runtime-max/thread
  8x4-convergence,                       16.808, secs,           runtime-min/thread
  8x4-convergence,                       17.809, secs,           runtime-avg/thread
  8x4-convergence,                        4.064, %,              spread-runtime/thread
  8x4-convergence,                        3.406, GB,             data/thread
  8x4-convergence,                      108.985, GB,             data-total
  8x4-convergence,                        5.372, nsecs,          runtime/byte/thread
  8x4-convergence,                        0.186, GB/sec,         thread-speed
  8x4-convergence,                        5.957, GB/sec,         total-speed

 # Running  8x4-convergence-NOTHP, "perf bench numa mem -p 8 -t 4 -P 512 -s 100 -zZ0qcm --thp  1 --thp -1"
  8x4-convergence-NOTHP,                 15.675, secs,           NUMA-convergence-latency
  8x4-convergence-NOTHP,                 15.675, secs,           runtime-max/thread
  8x4-convergence-NOTHP,                 14.861, secs,           runtime-min/thread
  8x4-convergence-NOTHP,                 15.321, secs,           runtime-avg/thread
  8x4-convergence-NOTHP,                  2.596, %,              spread-runtime/thread
  8x4-convergence-NOTHP,                  5.302, GB,             data/thread
  8x4-convergence-NOTHP,                169.651, GB,             data-total
  8x4-convergence-NOTHP,                  2.957, nsecs,          runtime/byte/thread
  8x4-convergence-NOTHP,                  0.338, GB/sec,         thread-speed
  8x4-convergence-NOTHP,                 10.823, GB/sec,         total-speed

 # Running  3x1-convergence, "perf bench numa mem -p 3 -t 1 -P 512 -s 100 -zZ0qcm --thp  1"
  3x1-convergence,                        0.811, secs,           NUMA-convergence-latency
  3x1-convergence,                        0.811, secs,           runtime-max/thread
  3x1-convergence,                        0.739, secs,           runtime-min/thread
  3x1-convergence,                        0.782, secs,           runtime-avg/thread
  3x1-convergence,                        4.431, %,              spread-runtime/thread
  3x1-convergence,                        1.969, GB,             data/thread
  3x1-convergence,                        5.906, GB,             data-total
  3x1-convergence,                        0.412, nsecs,          runtime/byte/thread
  3x1-convergence,                        2.428, GB/sec,         thread-speed
  3x1-convergence,                        7.284, GB/sec,         total-speed

 # Running  4x1-convergence, "perf bench numa mem -p 4 -t 1 -P 512 -s 100 -zZ0qcm --thp  1"
  4x1-convergence,                        0.806, secs,           NUMA-convergence-latency
  4x1-convergence,                        0.806, secs,           runtime-max/thread
  4x1-convergence,                        0.728, secs,           runtime-min/thread
  4x1-convergence,                        0.780, secs,           runtime-avg/thread
  4x1-convergence,                        4.838, %,              spread-runtime/thread
  4x1-convergence,                        1.476, GB,             data/thread
  4x1-convergence,                        5.906, GB,             data-total
  4x1-convergence,                        0.546, nsecs,          runtime/byte/thread
  4x1-convergence,                        1.832, GB/sec,         thread-speed
  4x1-convergence,                        7.329, GB/sec,         total-speed

 # Running  8x1-convergence, "perf bench numa mem -p 8 -t 1 -P 512 -s 100 -zZ0qcm --thp  1"
  8x1-convergence,                        2.879, secs,           NUMA-convergence-latency
  8x1-convergence,                        2.879, secs,           runtime-max/thread
  8x1-convergence,                        2.737, secs,           runtime-min/thread
  8x1-convergence,                        2.805, secs,           runtime-avg/thread
  8x1-convergence,                        2.475, %,              spread-runtime/thread
  8x1-convergence,                        3.288, GB,             data/thread
  8x1-convergence,                       26.307, GB,             data-total
  8x1-convergence,                        0.876, nsecs,          runtime/byte/thread
  8x1-convergence,                        1.142, GB/sec,         thread-speed
  8x1-convergence,                        9.137, GB/sec,         total-speed

 # Running 16x1-convergence, "perf bench numa mem -p 16 -t 1 -P 256 -s 100 -zZ0qcm --thp  1"
 16x1-convergence,                        2.484, secs,           NUMA-convergence-latency
 16x1-convergence,                        2.484, secs,           runtime-max/thread
 16x1-convergence,                        2.169, secs,           runtime-min/thread
 16x1-convergence,                        2.376, secs,           runtime-avg/thread
 16x1-convergence,                        6.353, %,              spread-runtime/thread
 16x1-convergence,                        0.906, GB,             data/thread
 16x1-convergence,                       14.496, GB,             data-total
 16x1-convergence,                        2.742, nsecs,          runtime/byte/thread
 16x1-convergence,                        0.365, GB/sec,         thread-speed
 16x1-convergence,                        5.835, GB/sec,         total-speed

 # Running 32x1-convergence, "perf bench numa mem -p 32 -t 1 -P 128 -s 100 -zZ0qcm --thp  1"
 32x1-convergence,                        3.039, secs,           NUMA-convergence-latency
 32x1-convergence,                        3.039, secs,           runtime-max/thread
 32x1-convergence,                        2.755, secs,           runtime-min/thread
 32x1-convergence,                        2.983, secs,           runtime-avg/thread
 32x1-convergence,                        4.672, %,              spread-runtime/thread
 32x1-convergence,                        0.579, GB,             data/thread
 32x1-convergence,                       18.522, GB,             data-total
 32x1-convergence,                        5.251, nsecs,          runtime/byte/thread
 32x1-convergence,                        0.190, GB/sec,         thread-speed
 32x1-convergence,                        6.094, GB/sec,         total-speed

 # Running  2x1-bw-process, "perf bench numa mem -p 2 -t 1 -P 1024 -s 20 -zZ0q --thp  1"
  2x1-bw-process,                        20.217, secs,           runtime-max/thread
  2x1-bw-process,                        20.126, secs,           runtime-min/thread
  2x1-bw-process,                        20.168, secs,           runtime-avg/thread
  2x1-bw-process,                         0.224, %,              spread-runtime/thread
  2x1-bw-process,                        81.604, GB,             data/thread
  2x1-bw-process,                       163.209, GB,             data-total
  2x1-bw-process,                         0.248, nsecs,          runtime/byte/thread
  2x1-bw-process,                         4.036, GB/sec,         thread-speed
  2x1-bw-process,                         8.073, GB/sec,         total-speed

 # Running  3x1-bw-process, "perf bench numa mem -p 3 -t 1 -P 1024 -s 20 -zZ0q --thp  1"
  3x1-bw-process,                        20.138, secs,           runtime-max/thread
  3x1-bw-process,                        20.075, secs,           runtime-min/thread
  3x1-bw-process,                        20.105, secs,           runtime-avg/thread
  3x1-bw-process,                         0.156, %,              spread-runtime/thread
  3x1-bw-process,                        84.468, GB,             data/thread
  3x1-bw-process,                       253.403, GB,             data-total
  3x1-bw-process,                         0.238, nsecs,          runtime/byte/thread
  3x1-bw-process,                         4.194, GB/sec,         thread-speed
  3x1-bw-process,                        12.583, GB/sec,         total-speed

 # Running  4x1-bw-process, "perf bench numa mem -p 4 -t 1 -P 1024 -s 20 -zZ0q --thp  1"
  4x1-bw-process,                        20.143, secs,           runtime-max/thread
  4x1-bw-process,                        20.052, secs,           runtime-min/thread
  4x1-bw-process,                        20.079, secs,           runtime-avg/thread
  4x1-bw-process,                         0.227, %,              spread-runtime/thread
  4x1-bw-process,                        62.009, GB,             data/thread
  4x1-bw-process,                       248.034, GB,             data-total
  4x1-bw-process,                         0.325, nsecs,          runtime/byte/thread
  4x1-bw-process,                         3.078, GB/sec,         thread-speed
  4x1-bw-process,                        12.313, GB/sec,         total-speed

 # Running  8x1-bw-process, "perf bench numa mem -p 8 -t 1 -P  512 -s 20 -zZ0q --thp  1"
  8x1-bw-process,                        20.109, secs,           runtime-max/thread
  8x1-bw-process,                        20.013, secs,           runtime-min/thread
  8x1-bw-process,                        20.072, secs,           runtime-avg/thread
  8x1-bw-process,                         0.238, %,              spread-runtime/thread
  8x1-bw-process,                        50.869, GB,             data/thread
  8x1-bw-process,                       406.948, GB,             data-total
  8x1-bw-process,                         0.395, nsecs,          runtime/byte/thread
  8x1-bw-process,                         2.530, GB/sec,         thread-speed
  8x1-bw-process,                        20.237, GB/sec,         total-speed

 # Running  8x1-bw-process-NOTHP, "perf bench numa mem -p 8 -t 1 -P  512 -s 20 -zZ0q --thp  1 --thp -1"
  8x1-bw-process-NOTHP,                  20.203, secs,           runtime-max/thread
  8x1-bw-process-NOTHP,                  20.033, secs,           runtime-min/thread
  8x1-bw-process-NOTHP,                  20.071, secs,           runtime-avg/thread
  8x1-bw-process-NOTHP,                   0.422, %,              spread-runtime/thread
  8x1-bw-process-NOTHP,                  45.030, GB,             data/thread
  8x1-bw-process-NOTHP,                 360.240, GB,             data-total
  8x1-bw-process-NOTHP,                   0.449, nsecs,          runtime/byte/thread
  8x1-bw-process-NOTHP,                   2.229, GB/sec,         thread-speed
  8x1-bw-process-NOTHP,                  17.831, GB/sec,         total-speed

 # Running 16x1-bw-process, "perf bench numa mem -p 16 -t 1 -P 256 -s 20 -zZ0q --thp  1"
 16x1-bw-process,                        20.271, secs,           runtime-max/thread
 16x1-bw-process,                        20.021, secs,           runtime-min/thread
 16x1-bw-process,                        20.175, secs,           runtime-avg/thread
 16x1-bw-process,                         0.615, %,              spread-runtime/thread
 16x1-bw-process,                         7.550, GB,             data/thread
 16x1-bw-process,                       120.796, GB,             data-total
 16x1-bw-process,                         2.685, nsecs,          runtime/byte/thread
 16x1-bw-process,                         0.372, GB/sec,         thread-speed
 16x1-bw-process,                         5.959, GB/sec,         total-speed

 # Running  4x1-bw-thread, "perf bench numa mem -p 1 -t 4 -T 256 -s 20 -zZ0q --thp  1"
  4x1-bw-thread,                         20.052, secs,           runtime-max/thread
  4x1-bw-thread,                         20.013, secs,           runtime-min/thread
  4x1-bw-thread,                         20.030, secs,           runtime-avg/thread
  4x1-bw-thread,                          0.097, %,              spread-runtime/thread
  4x1-bw-thread,                         87.443, GB,             data/thread
  4x1-bw-thread,                        349.771, GB,             data-total
  4x1-bw-thread,                          0.229, nsecs,          runtime/byte/thread
  4x1-bw-thread,                          4.361, GB/sec,         thread-speed
  4x1-bw-thread,                         17.443, GB/sec,         total-speed

 # Running  8x1-bw-thread, "perf bench numa mem -p 1 -t 8 -T 256 -s 20 -zZ0q --thp  1"
  8x1-bw-thread,                         20.067, secs,           runtime-max/thread
  8x1-bw-thread,                         20.011, secs,           runtime-min/thread
  8x1-bw-thread,                         20.038, secs,           runtime-avg/thread
  8x1-bw-thread,                          0.140, %,              spread-runtime/thread
  8x1-bw-thread,                         56.271, GB,             data/thread
  8x1-bw-thread,                        450.166, GB,             data-total
  8x1-bw-thread,                          0.357, nsecs,          runtime/byte/thread
  8x1-bw-thread,                          2.804, GB/sec,         thread-speed
  8x1-bw-thread,                         22.433, GB/sec,         total-speed

 # Running 16x1-bw-thread, "perf bench numa mem -p 1 -t 16 -T 128 -s 20 -zZ0q --thp  1"
 16x1-bw-thread,                         20.029, secs,           runtime-max/thread
 16x1-bw-thread,                         20.002, secs,           runtime-min/thread
 16x1-bw-thread,                         20.020, secs,           runtime-avg/thread
 16x1-bw-thread,                          0.067, %,              spread-runtime/thread
 16x1-bw-thread,                         25.292, GB,             data/thread
 16x1-bw-thread,                        404.666, GB,             data-total
 16x1-bw-thread,                          0.792, nsecs,          runtime/byte/thread
 16x1-bw-thread,                          1.263, GB/sec,         thread-speed
 16x1-bw-thread,                         20.204, GB/sec,         total-speed

 # Running 32x1-bw-thread, "perf bench numa mem -p 1 -t 32 -T 64 -s 20 -zZ0q --thp  1"
 32x1-bw-thread,                         19.989, secs,           runtime-max/thread
 32x1-bw-thread,                         19.962, secs,           runtime-min/thread
 32x1-bw-thread,                         20.004, secs,           runtime-avg/thread
 32x1-bw-thread,                          0.068, %,              spread-runtime/thread
 32x1-bw-thread,                         11.388, GB,             data/thread
 32x1-bw-thread,                        364.401, GB,             data-total
 32x1-bw-thread,                          1.755, nsecs,          runtime/byte/thread
 32x1-bw-thread,                          0.570, GB/sec,         thread-speed
 32x1-bw-thread,                         18.230, GB/sec,         total-speed

 # Running  2x3-bw-thread, "perf bench numa mem -p 2 -t 3 -P 512 -s 20 -zZ0q --thp  1"
  2x3-bw-thread,                         20.190, secs,           runtime-max/thread
  2x3-bw-thread,                         20.082, secs,           runtime-min/thread
  2x3-bw-thread,                         20.110, secs,           runtime-avg/thread
  2x3-bw-thread,                          0.268, %,              spread-runtime/thread
  2x3-bw-thread,                         49.303, GB,             data/thread
  2x3-bw-thread,                        295.816, GB,             data-total
  2x3-bw-thread,                          0.410, nsecs,          runtime/byte/thread
  2x3-bw-thread,                          2.442, GB/sec,         thread-speed
  2x3-bw-thread,                         14.652, GB/sec,         total-speed

 # Running  4x4-bw-thread, "perf bench numa mem -p 4 -t 4 -P 512 -s 20 -zZ0q --thp  1"
  4x4-bw-thread,                         20.307, secs,           runtime-max/thread
  4x4-bw-thread,                         20.002, secs,           runtime-min/thread
  4x4-bw-thread,                         20.202, secs,           runtime-avg/thread
  4x4-bw-thread,                          0.750, %,              spread-runtime/thread
  4x4-bw-thread,                         12.482, GB,             data/thread
  4x4-bw-thread,                        199.716, GB,             data-total
  4x4-bw-thread,                          1.627, nsecs,          runtime/byte/thread
  4x4-bw-thread,                          0.615, GB/sec,         thread-speed
  4x4-bw-thread,                          9.835, GB/sec,         total-speed

 # Running  4x6-bw-thread, "perf bench numa mem -p 4 -t 6 -P 512 -s 20 -zZ0q --thp  1"
  4x6-bw-thread,                         20.431, secs,           runtime-max/thread
  4x6-bw-thread,                         20.007, secs,           runtime-min/thread
  4x6-bw-thread,                         20.283, secs,           runtime-avg/thread
  4x6-bw-thread,                          1.036, %,              spread-runtime/thread
  4x6-bw-thread,                         13.086, GB,             data/thread
  4x6-bw-thread,                        314.069, GB,             data-total
  4x6-bw-thread,                          1.561, nsecs,          runtime/byte/thread
  4x6-bw-thread,                          0.641, GB/sec,         thread-speed
  4x6-bw-thread,                         15.372, GB/sec,         total-speed

 # Running  4x8-bw-thread, "perf bench numa mem -p 4 -t 8 -P 512 -s 20 -zZ0q --thp  1"
  4x8-bw-thread,                         20.543, secs,           runtime-max/thread
  4x8-bw-thread,                         20.015, secs,           runtime-min/thread
  4x8-bw-thread,                         20.324, secs,           runtime-avg/thread
  4x8-bw-thread,                          1.287, %,              spread-runtime/thread
  4x8-bw-thread,                          7.617, GB,             data/thread
  4x8-bw-thread,                        243.739, GB,             data-total
  4x8-bw-thread,                          2.697, nsecs,          runtime/byte/thread
  4x8-bw-thread,                          0.371, GB/sec,         thread-speed
  4x8-bw-thread,                         11.865, GB/sec,         total-speed

 # Running  4x8-bw-thread-NOTHP, "perf bench numa mem -p 4 -t 8 -P 512 -s 20 -zZ0q --thp  1 --thp -1"
  4x8-bw-thread-NOTHP,                   20.661, secs,           runtime-max/thread
  4x8-bw-thread-NOTHP,                   20.023, secs,           runtime-min/thread
  4x8-bw-thread-NOTHP,                   20.292, secs,           runtime-avg/thread
  4x8-bw-thread-NOTHP,                    1.546, %,              spread-runtime/thread
  4x8-bw-thread-NOTHP,                    5.956, GB,             data/thread
  4x8-bw-thread-NOTHP,                  190.589, GB,             data-total
  4x8-bw-thread-NOTHP,                    3.469, nsecs,          runtime/byte/thread
  4x8-bw-thread-NOTHP,                    0.288, GB/sec,         thread-speed
  4x8-bw-thread-NOTHP,                    9.224, GB/sec,         total-speed

 # Running  3x3-bw-thread, "perf bench numa mem -p 3 -t 3 -P 512 -s 20 -zZ0q --thp  1"
  3x3-bw-thread,                         20.310, secs,           runtime-max/thread
  3x3-bw-thread,                         20.116, secs,           runtime-min/thread
  3x3-bw-thread,                         20.202, secs,           runtime-avg/thread
  3x3-bw-thread,                          0.480, %,              spread-runtime/thread
  3x3-bw-thread,                         14.973, GB,             data/thread
  3x3-bw-thread,                        134.755, GB,             data-total
  3x3-bw-thread,                          1.356, nsecs,          runtime/byte/thread
  3x3-bw-thread,                          0.737, GB/sec,         thread-speed
  3x3-bw-thread,                          6.635, GB/sec,         total-speed

 # Running  5x5-bw-thread, "perf bench numa mem -p 5 -t 5 -P 512 -s 20 -zZ0q --thp  1"
  5x5-bw-thread,                         20.578, secs,           runtime-max/thread
  5x5-bw-thread,                         20.039, secs,           runtime-min/thread
  5x5-bw-thread,                         20.379, secs,           runtime-avg/thread
  5x5-bw-thread,                          1.309, %,              spread-runtime/thread
  5x5-bw-thread,                          7.881, GB,             data/thread
  5x5-bw-thread,                        197.032, GB,             data-total
  5x5-bw-thread,                          2.611, nsecs,          runtime/byte/thread
  5x5-bw-thread,                          0.383, GB/sec,         thread-speed
  5x5-bw-thread,                          9.575, GB/sec,         total-speed

 # Running 2x16-bw-thread, "perf bench numa mem -p 2 -t 16 -P 512 -s 20 -zZ0q --thp  1"
 2x16-bw-thread,                         21.581, secs,           runtime-max/thread
 2x16-bw-thread,                         20.043, secs,           runtime-min/thread
 2x16-bw-thread,                         20.958, secs,           runtime-avg/thread
 2x16-bw-thread,                          3.564, %,              spread-runtime/thread
 2x16-bw-thread,                          4.010, GB,             data/thread
 2x16-bw-thread,                        128.312, GB,             data-total
 2x16-bw-thread,                          5.382, nsecs,          runtime/byte/thread
 2x16-bw-thread,                          0.186, GB/sec,         thread-speed
 2x16-bw-thread,                          5.945, GB/sec,         total-speed

 # Running 1x32-bw-thread, "perf bench numa mem -p 1 -t 32 -P 2048 -s 20 -zZ0q --thp  1"
 1x32-bw-thread,                         23.503, secs,           runtime-max/thread
 1x32-bw-thread,                         21.850, secs,           runtime-min/thread
 1x32-bw-thread,                         22.953, secs,           runtime-avg/thread
 1x32-bw-thread,                          3.518, %,              spread-runtime/thread
 1x32-bw-thread,                          4.295, GB,             data/thread
 1x32-bw-thread,                        137.439, GB,             data-total
 1x32-bw-thread,                          5.472, nsecs,          runtime/byte/thread
 1x32-bw-thread,                          0.183, GB/sec,         thread-speed
 1x32-bw-thread,                          5.848, GB/sec,         total-speed

 # Running numa02-bw, "perf bench numa mem -p 1 -t 32 -T 32 -s 20 -zZ0q --thp  1"
 numa02-bw,                              19.948, secs,           runtime-max/thread
 numa02-bw,                              19.921, secs,           runtime-min/thread
 numa02-bw,                              19.983, secs,           runtime-avg/thread
 numa02-bw,                               0.068, %,              spread-runtime/thread
 numa02-bw,                              15.425, GB,             data/thread
 numa02-bw,                             493.586, GB,             data-total
 numa02-bw,                               1.293, nsecs,          runtime/byte/thread
 numa02-bw,                               0.773, GB/sec,         thread-speed
 numa02-bw,                              24.744, GB/sec,         total-speed

 # Running numa02-bw-NOTHP, "perf bench numa mem -p 1 -t 32 -T 32 -s 20 -zZ0q --thp  1 --thp -1"
 numa02-bw-NOTHP,                        20.055, secs,           runtime-max/thread
 numa02-bw-NOTHP,                        19.948, secs,           runtime-min/thread
 numa02-bw-NOTHP,                        19.991, secs,           runtime-avg/thread
 numa02-bw-NOTHP,                         0.267, %,              spread-runtime/thread
 numa02-bw-NOTHP,                        12.795, GB,             data/thread
 numa02-bw-NOTHP,                       409.431, GB,             data-total
 numa02-bw-NOTHP,                         1.567, nsecs,          runtime/byte/thread
 numa02-bw-NOTHP,                         0.638, GB/sec,         thread-speed
 numa02-bw-NOTHP,                        20.415, GB/sec,         total-speed

 # Running numa01-bw-thread, "perf bench numa mem -p 2 -t 16 -T 192 -s 20 -zZ0q --thp  1"
 numa01-bw-thread,                       20.107, secs,           runtime-max/thread
 numa01-bw-thread,                       19.978, secs,           runtime-min/thread
 numa01-bw-thread,                       20.067, secs,           runtime-avg/thread
 numa01-bw-thread,                        0.320, %,              spread-runtime/thread
 numa01-bw-thread,                        9.532, GB,             data/thread
 numa01-bw-thread,                      305.010, GB,             data-total
 numa01-bw-thread,                        2.110, nsecs,          runtime/byte/thread
 numa01-bw-thread,                        0.474, GB/sec,         thread-speed
 numa01-bw-thread,                       15.169, GB/sec,         total-speed

 # Running numa01-bw-thread-NOTHP, "perf bench numa mem -p 2 -t 16 -T 192 -s 20 -zZ0q --thp  1 --thp -1"
 numa01-bw-thread-NOTHP,                 20.319, secs,           runtime-max/thread
 numa01-bw-thread-NOTHP,                 19.978, secs,           runtime-min/thread
 numa01-bw-thread-NOTHP,                 20.076, secs,           runtime-avg/thread
 numa01-bw-thread-NOTHP,                  0.839, %,              spread-runtime/thread
 numa01-bw-thread-NOTHP,                  7.688, GB,             data/thread
 numa01-bw-thread-NOTHP,                246.021, GB,             data-total
 numa01-bw-thread-NOTHP,                  2.643, nsecs,          runtime/byte/thread
 numa01-bw-thread-NOTHP,                  0.378, GB/sec,         thread-speed
 numa01-bw-thread-NOTHP,                 12.108, GB/sec,         total-speed

 #
 # Running test on: Linux vega 3.7.0-rc8+ #2 SMP Fri Dec 7 02:46:02 CET 2012 x86_64 x86_64 x86_64 GNU/Linux
 #
# Running numa/mem benchmark...

 # Running main, "perf bench numa mem -a"

 # Running RAM-bw-local, "perf bench numa mem -p 1 -t 1 -P 1024 -C 0 -M 0 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-local,                           20.132, secs,           runtime-max/thread
 RAM-bw-local,                           20.123, secs,           runtime-min/thread
 RAM-bw-local,                           20.123, secs,           runtime-avg/thread
 RAM-bw-local,                            0.024, %,              spread-runtime/thread
 RAM-bw-local,                          171.799, GB,             data/thread
 RAM-bw-local,                          171.799, GB,             data-total
 RAM-bw-local,                            0.117, nsecs,          runtime/byte/thread
 RAM-bw-local,                            8.534, GB/sec,         thread-speed
 RAM-bw-local,                            8.534, GB/sec,         total-speed

 # Running RAM-bw-local-NOTHP, "perf bench numa mem -p 1 -t 1 -P 1024 -C 0 -M 0 -s 20 -zZq --thp  1 --no-data_rand_walk --thp -1"
 RAM-bw-local-NOTHP,                     20.133, secs,           runtime-max/thread
 RAM-bw-local-NOTHP,                     20.047, secs,           runtime-min/thread
 RAM-bw-local-NOTHP,                     20.047, secs,           runtime-avg/thread
 RAM-bw-local-NOTHP,                      0.214, %,              spread-runtime/thread
 RAM-bw-local-NOTHP,                    169.651, GB,             data/thread
 RAM-bw-local-NOTHP,                    169.651, GB,             data-total
 RAM-bw-local-NOTHP,                      0.119, nsecs,          runtime/byte/thread
 RAM-bw-local-NOTHP,                      8.427, GB/sec,         thread-speed
 RAM-bw-local-NOTHP,                      8.427, GB/sec,         total-speed

 # Running RAM-bw-remote, "perf bench numa mem -p 1 -t 1 -P 1024 -C 0 -M 1 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-remote,                          20.127, secs,           runtime-max/thread
 RAM-bw-remote,                          20.117, secs,           runtime-min/thread
 RAM-bw-remote,                          20.117, secs,           runtime-avg/thread
 RAM-bw-remote,                           0.025, %,              spread-runtime/thread
 RAM-bw-remote,                         134.218, GB,             data/thread
 RAM-bw-remote,                         134.218, GB,             data-total
 RAM-bw-remote,                           0.150, nsecs,          runtime/byte/thread
 RAM-bw-remote,                           6.669, GB/sec,         thread-speed
 RAM-bw-remote,                           6.669, GB/sec,         total-speed

 # Running RAM-bw-local-2x, "perf bench numa mem -p 2 -t 1 -P 1024 -C 0,2 -M 0x2 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-local-2x,                        20.139, secs,           runtime-max/thread
 RAM-bw-local-2x,                        20.011, secs,           runtime-min/thread
 RAM-bw-local-2x,                        20.070, secs,           runtime-avg/thread
 RAM-bw-local-2x,                         0.319, %,              spread-runtime/thread
 RAM-bw-local-2x,                       130.997, GB,             data/thread
 RAM-bw-local-2x,                       261.993, GB,             data-total
 RAM-bw-local-2x,                         0.154, nsecs,          runtime/byte/thread
 RAM-bw-local-2x,                         6.505, GB/sec,         thread-speed
 RAM-bw-local-2x,                        13.009, GB/sec,         total-speed

 # Running RAM-bw-remote-2x, "perf bench numa mem -p 2 -t 1 -P 1024 -C 0,2 -M 1x2 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-remote-2x,                       20.177, secs,           runtime-max/thread
 RAM-bw-remote-2x,                       20.083, secs,           runtime-min/thread
 RAM-bw-remote-2x,                       20.125, secs,           runtime-avg/thread
 RAM-bw-remote-2x,                        0.233, %,              spread-runtime/thread
 RAM-bw-remote-2x,                       74.088, GB,             data/thread
 RAM-bw-remote-2x,                      148.176, GB,             data-total
 RAM-bw-remote-2x,                        0.272, nsecs,          runtime/byte/thread
 RAM-bw-remote-2x,                        3.672, GB/sec,         thread-speed
 RAM-bw-remote-2x,                        7.344, GB/sec,         total-speed

 # Running RAM-bw-cross, "perf bench numa mem -p 2 -t 1 -P 1024 -C 0,8 -M 1,0 -s 20 -zZq --thp  1 --no-data_rand_walk"
 RAM-bw-cross,                           20.122, secs,           runtime-max/thread
 RAM-bw-cross,                           20.094, secs,           runtime-min/thread
 RAM-bw-cross,                           20.103, secs,           runtime-avg/thread
 RAM-bw-cross,                            0.070, %,              spread-runtime/thread
 RAM-bw-cross,                          121.870, GB,             data/thread
 RAM-bw-cross,                          243.739, GB,             data-total
 RAM-bw-cross,                            0.165, nsecs,          runtime/byte/thread
 RAM-bw-cross,                            6.057, GB/sec,         thread-speed
 RAM-bw-cross,                           12.113, GB/sec,         total-speed

 # Running  1x3-convergence, "perf bench numa mem -p 1 -t 3 -P 512 -s 100 -zZ0qcm --thp  1"
  1x3-convergence,                        2.333, secs,           NUMA-convergence-latency
  1x3-convergence,                        2.333, secs,           runtime-max/thread
  1x3-convergence,                        2.304, secs,           runtime-min/thread
  1x3-convergence,                        2.313, secs,           runtime-avg/thread
  1x3-convergence,                        0.620, %,              spread-runtime/thread
  1x3-convergence,                        7.516, GB,             data/thread
  1x3-convergence,                       22.549, GB,             data-total
  1x3-convergence,                        0.310, nsecs,          runtime/byte/thread
  1x3-convergence,                        3.222, GB/sec,         thread-speed
  1x3-convergence,                        9.665, GB/sec,         total-speed

 # Running  1x4-convergence, "perf bench numa mem -p 1 -t 4 -P 512 -s 100 -zZ0qcm --thp  1"
  1x4-convergence,                        2.057, secs,           NUMA-convergence-latency
  1x4-convergence,                        2.057, secs,           runtime-max/thread
  1x4-convergence,                        1.958, secs,           runtime-min/thread
  1x4-convergence,                        1.998, secs,           runtime-avg/thread
  1x4-convergence,                        2.403, %,              spread-runtime/thread
  1x4-convergence,                        4.429, GB,             data/thread
  1x4-convergence,                       17.717, GB,             data-total
  1x4-convergence,                        0.464, nsecs,          runtime/byte/thread
  1x4-convergence,                        2.154, GB/sec,         thread-speed
  1x4-convergence,                        8.614, GB/sec,         total-speed

 # Running  1x6-convergence, "perf bench numa mem -p 1 -t 6 -P 1020 -s 100 -zZ0qcm --thp  1"
  1x6-convergence,                        7.327, secs,           NUMA-convergence-latency
  1x6-convergence,                        7.327, secs,           runtime-max/thread
  1x6-convergence,                        6.879, secs,           runtime-min/thread
  1x6-convergence,                        7.187, secs,           runtime-avg/thread
  1x6-convergence,                        3.063, %,              spread-runtime/thread
  1x6-convergence,                       11.052, GB,             data/thread
  1x6-convergence,                       66.312, GB,             data-total
  1x6-convergence,                        0.663, nsecs,          runtime/byte/thread
  1x6-convergence,                        1.508, GB/sec,         thread-speed
  1x6-convergence,                        9.050, GB/sec,         total-speed

 # Running  2x3-convergence, "perf bench numa mem -p 3 -t 3 -P 1020 -s 100 -zZ0qcm --thp  1"
  2x3-convergence,                        4.086, secs,           NUMA-convergence-latency
  2x3-convergence,                        4.086, secs,           runtime-max/thread
  2x3-convergence,                        3.779, secs,           runtime-min/thread
  2x3-convergence,                        3.960, secs,           runtime-avg/thread
  2x3-convergence,                        3.761, %,              spread-runtime/thread
  2x3-convergence,                        6.774, GB,             data/thread
  2x3-convergence,                       60.964, GB,             data-total
  2x3-convergence,                        0.603, nsecs,          runtime/byte/thread
  2x3-convergence,                        1.658, GB/sec,         thread-speed
  2x3-convergence,                       14.920, GB/sec,         total-speed

 # Running  3x3-convergence, "perf bench numa mem -p 3 -t 3 -P 1020 -s 100 -zZ0qcm --thp  1"
  3x3-convergence,                        7.627, secs,           NUMA-convergence-latency
  3x3-convergence,                        7.627, secs,           runtime-max/thread
  3x3-convergence,                        7.380, secs,           runtime-min/thread
  3x3-convergence,                        7.504, secs,           runtime-avg/thread
  3x3-convergence,                        1.624, %,              spread-runtime/thread
  3x3-convergence,                       15.093, GB,             data/thread
  3x3-convergence,                      135.833, GB,             data-total
  3x3-convergence,                        0.505, nsecs,          runtime/byte/thread
  3x3-convergence,                        1.979, GB/sec,         thread-speed
  3x3-convergence,                       17.809, GB/sec,         total-speed

 # Running  4x4-convergence, "perf bench numa mem -p 4 -t 4 -P 512 -s 100 -zZ0qcm --thp  1"
  4x4-convergence,                        7.381, secs,           NUMA-convergence-latency
  4x4-convergence,                        7.381, secs,           runtime-max/thread
  4x4-convergence,                        7.149, secs,           runtime-min/thread
  4x4-convergence,                        7.277, secs,           runtime-avg/thread
  4x4-convergence,                        1.569, %,              spread-runtime/thread
  4x4-convergence,                        7.181, GB,             data/thread
  4x4-convergence,                      114.890, GB,             data-total
  4x4-convergence,                        1.028, nsecs,          runtime/byte/thread
  4x4-convergence,                        0.973, GB/sec,         thread-speed
  4x4-convergence,                       15.566, GB/sec,         total-speed

 # Running  4x4-convergence-NOTHP, "perf bench numa mem -p 4 -t 4 -P 512 -s 100 -zZ0qcm --thp  1 --thp -1"
  4x4-convergence-NOTHP,                  9.200, secs,           NUMA-convergence-latency
  4x4-convergence-NOTHP,                  9.200, secs,           runtime-max/thread
  4x4-convergence-NOTHP,                  8.944, secs,           runtime-min/thread
  4x4-convergence-NOTHP,                  9.047, secs,           runtime-avg/thread
  4x4-convergence-NOTHP,                  1.391, %,              spread-runtime/thread
  4x4-convergence-NOTHP,                 11.778, GB,             data/thread
  4x4-convergence-NOTHP,                188.442, GB,             data-total
  4x4-convergence-NOTHP,                  0.781, nsecs,          runtime/byte/thread
  4x4-convergence-NOTHP,                  1.280, GB/sec,         thread-speed
  4x4-convergence-NOTHP,                 20.483, GB/sec,         total-speed

 # Running  4x6-convergence, "perf bench numa mem -p 4 -t 6 -P 1020 -s 100 -zZ0qcm --thp  1"
  4x6-convergence,                       11.664, secs,           NUMA-convergence-latency
  4x6-convergence,                       11.664, secs,           runtime-max/thread
  4x6-convergence,                       11.155, secs,           runtime-min/thread
  4x6-convergence,                       11.420, secs,           runtime-avg/thread
  4x6-convergence,                        2.180, %,              spread-runtime/thread
  4x6-convergence,                       11.319, GB,             data/thread
  4x6-convergence,                      271.665, GB,             data-total
  4x6-convergence,                        1.030, nsecs,          runtime/byte/thread
  4x6-convergence,                        0.970, GB/sec,         thread-speed
  4x6-convergence,                       23.292, GB/sec,         total-speed

 # Running  4x8-convergence, "perf bench numa mem -p 4 -t 8 -P 512 -s 100 -zZ0qcm --thp  1"
  4x8-convergence,                        3.880, secs,           NUMA-convergence-latency
  4x8-convergence,                        3.880, secs,           runtime-max/thread
  4x8-convergence,                        3.613, secs,           runtime-min/thread
  4x8-convergence,                        3.784, secs,           runtime-avg/thread
  4x8-convergence,                        3.440, %,              spread-runtime/thread
  4x8-convergence,                        2.047, GB,             data/thread
  4x8-convergence,                       65.498, GB,             data-total
  4x8-convergence,                        1.896, nsecs,          runtime/byte/thread
  4x8-convergence,                        0.528, GB/sec,         thread-speed
  4x8-convergence,                       16.882, GB/sec,         total-speed

 # Running  8x4-convergence, "perf bench numa mem -p 8 -t 4 -P 512 -s 100 -zZ0qcm --thp  1"
  8x4-convergence,                        8.938, secs,           NUMA-convergence-latency
  8x4-convergence,                        8.938, secs,           runtime-max/thread
  8x4-convergence,                        8.556, secs,           runtime-min/thread
  8x4-convergence,                        8.744, secs,           runtime-avg/thread
  8x4-convergence,                        2.135, %,              spread-runtime/thread
  8x4-convergence,                        4.396, GB,             data/thread
  8x4-convergence,                      140.660, GB,             data-total
  8x4-convergence,                        2.033, nsecs,          runtime/byte/thread
  8x4-convergence,                        0.492, GB/sec,         thread-speed
  8x4-convergence,                       15.738, GB/sec,         total-speed

 # Running  8x4-convergence-NOTHP, "perf bench numa mem -p 8 -t 4 -P 512 -s 100 -zZ0qcm --thp  1 --thp -1"
  8x4-convergence-NOTHP,                 12.123, secs,           NUMA-convergence-latency
  8x4-convergence-NOTHP,                 12.123, secs,           runtime-max/thread
  8x4-convergence-NOTHP,                 11.749, secs,           runtime-min/thread
  8x4-convergence-NOTHP,                 11.936, secs,           runtime-avg/thread
  8x4-convergence-NOTHP,                  1.542, %,              spread-runtime/thread
  8x4-convergence-NOTHP,                  4.480, GB,             data/thread
  8x4-convergence-NOTHP,                143.345, GB,             data-total
  8x4-convergence-NOTHP,                  2.706, nsecs,          runtime/byte/thread
  8x4-convergence-NOTHP,                  0.370, GB/sec,         thread-speed
  8x4-convergence-NOTHP,                 11.824, GB/sec,         total-speed

 # Running  3x1-convergence, "perf bench numa mem -p 3 -t 1 -P 512 -s 100 -zZ0qcm --thp  1"
  3x1-convergence,                        0.879, secs,           NUMA-convergence-latency
  3x1-convergence,                        0.879, secs,           runtime-max/thread
  3x1-convergence,                        0.810, secs,           runtime-min/thread
  3x1-convergence,                        0.839, secs,           runtime-avg/thread
  3x1-convergence,                        3.911, %,              spread-runtime/thread
  3x1-convergence,                        2.326, GB,             data/thread
  3x1-convergence,                        6.979, GB,             data-total
  3x1-convergence,                        0.378, nsecs,          runtime/byte/thread
  3x1-convergence,                        2.647, GB/sec,         thread-speed
  3x1-convergence,                        7.941, GB/sec,         total-speed

 # Running  4x1-convergence, "perf bench numa mem -p 4 -t 1 -P 512 -s 100 -zZ0qcm --thp  1"
  4x1-convergence,                        0.685, secs,           NUMA-convergence-latency
  4x1-convergence,                        0.685, secs,           runtime-max/thread
  4x1-convergence,                        0.617, secs,           runtime-min/thread
  4x1-convergence,                        0.650, secs,           runtime-avg/thread
  4x1-convergence,                        4.967, %,              spread-runtime/thread
  4x1-convergence,                        1.476, GB,             data/thread
  4x1-convergence,                        5.906, GB,             data-total
  4x1-convergence,                        0.464, nsecs,          runtime/byte/thread
  4x1-convergence,                        2.154, GB/sec,         thread-speed
  4x1-convergence,                        8.616, GB/sec,         total-speed

 # Running  8x1-convergence, "perf bench numa mem -p 8 -t 1 -P 512 -s 100 -zZ0qcm --thp  1"
  8x1-convergence,                        1.158, secs,           NUMA-convergence-latency
  8x1-convergence,                        1.158, secs,           runtime-max/thread
  8x1-convergence,                        1.010, secs,           runtime-min/thread
  8x1-convergence,                        1.060, secs,           runtime-avg/thread
  8x1-convergence,                        6.396, %,              spread-runtime/thread
  8x1-convergence,                        1.745, GB,             data/thread
  8x1-convergence,                       13.959, GB,             data-total
  8x1-convergence,                        0.664, nsecs,          runtime/byte/thread
  8x1-convergence,                        1.507, GB/sec,         thread-speed
  8x1-convergence,                       12.054, GB/sec,         total-speed

 # Running 16x1-convergence, "perf bench numa mem -p 16 -t 1 -P 256 -s 100 -zZ0qcm --thp  1"
 16x1-convergence,                        2.010, secs,           NUMA-convergence-latency
 16x1-convergence,                        2.010, secs,           runtime-max/thread
 16x1-convergence,                        1.939, secs,           runtime-min/thread
 16x1-convergence,                        1.991, secs,           runtime-avg/thread
 16x1-convergence,                        1.760, %,              spread-runtime/thread
 16x1-convergence,                        2.668, GB,             data/thread
 16x1-convergence,                       42.681, GB,             data-total
 16x1-convergence,                        0.753, nsecs,          runtime/byte/thread
 16x1-convergence,                        1.327, GB/sec,         thread-speed
 16x1-convergence,                       21.237, GB/sec,         total-speed

 # Running 32x1-convergence, "perf bench numa mem -p 32 -t 1 -P 128 -s 100 -zZ0qcm --thp  1"
 32x1-convergence,                        1.946, secs,           NUMA-convergence-latency
 32x1-convergence,                        1.946, secs,           runtime-max/thread
 32x1-convergence,                        1.850, secs,           runtime-min/thread
 32x1-convergence,                        1.946, secs,           runtime-avg/thread
 32x1-convergence,                        2.479, %,              spread-runtime/thread
 32x1-convergence,                        1.242, GB,             data/thread
 32x1-convergence,                       39.728, GB,             data-total
 32x1-convergence,                        1.568, nsecs,          runtime/byte/thread
 32x1-convergence,                        0.638, GB/sec,         thread-speed
 32x1-convergence,                       20.410, GB/sec,         total-speed

 # Running  2x1-bw-process, "perf bench numa mem -p 2 -t 1 -P 1024 -s 20 -zZ0q --thp  1"
  2x1-bw-process,                        20.146, secs,           runtime-max/thread
  2x1-bw-process,                        20.068, secs,           runtime-min/thread
  2x1-bw-process,                        20.102, secs,           runtime-avg/thread
  2x1-bw-process,                         0.193, %,              spread-runtime/thread
  2x1-bw-process,                        97.174, GB,             data/thread
  2x1-bw-process,                       194.347, GB,             data-total
  2x1-bw-process,                         0.207, nsecs,          runtime/byte/thread
  2x1-bw-process,                         4.824, GB/sec,         thread-speed
  2x1-bw-process,                         9.647, GB/sec,         total-speed

 # Running  3x1-bw-process, "perf bench numa mem -p 3 -t 1 -P 1024 -s 20 -zZ0q --thp  1"
  3x1-bw-process,                        20.177, secs,           runtime-max/thread
  3x1-bw-process,                        20.127, secs,           runtime-min/thread
  3x1-bw-process,                        20.146, secs,           runtime-avg/thread
  3x1-bw-process,                         0.126, %,              spread-runtime/thread
  3x1-bw-process,                        97.711, GB,             data/thread
  3x1-bw-process,                       293.132, GB,             data-total
  3x1-bw-process,                         0.207, nsecs,          runtime/byte/thread
  3x1-bw-process,                         4.843, GB/sec,         thread-speed
  3x1-bw-process,                        14.528, GB/sec,         total-speed

 # Running  4x1-bw-process, "perf bench numa mem -p 4 -t 1 -P 1024 -s 20 -zZ0q --thp  1"
  4x1-bw-process,                        20.165, secs,           runtime-max/thread
  4x1-bw-process,                        20.025, secs,           runtime-min/thread
  4x1-bw-process,                        20.078, secs,           runtime-avg/thread
  4x1-bw-process,                         0.348, %,              spread-runtime/thread
  4x1-bw-process,                        95.295, GB,             data/thread
  4x1-bw-process,                       381.178, GB,             data-total
  4x1-bw-process,                         0.212, nsecs,          runtime/byte/thread
  4x1-bw-process,                         4.726, GB/sec,         thread-speed
  4x1-bw-process,                        18.903, GB/sec,         total-speed

 # Running  8x1-bw-process, "perf bench numa mem -p 8 -t 1 -P  512 -s 20 -zZ0q --thp  1"
  8x1-bw-process,                        20.131, secs,           runtime-max/thread
  8x1-bw-process,                        20.066, secs,           runtime-min/thread
  8x1-bw-process,                        20.090, secs,           runtime-avg/thread
  8x1-bw-process,                         0.161, %,              spread-runtime/thread
  8x1-bw-process,                        67.512, GB,             data/thread
  8x1-bw-process,                       540.092, GB,             data-total
  8x1-bw-process,                         0.298, nsecs,          runtime/byte/thread
  8x1-bw-process,                         3.354, GB/sec,         thread-speed
  8x1-bw-process,                        26.829, GB/sec,         total-speed

 # Running  8x1-bw-process-NOTHP, "perf bench numa mem -p 8 -t 1 -P  512 -s 20 -zZ0q --thp  1 --thp -1"
  8x1-bw-process-NOTHP,                  20.208, secs,           runtime-max/thread
  8x1-bw-process-NOTHP,                  20.002, secs,           runtime-min/thread
  8x1-bw-process-NOTHP,                  20.067, secs,           runtime-avg/thread
  8x1-bw-process-NOTHP,                   0.509, %,              spread-runtime/thread
  8x1-bw-process-NOTHP,                  56.170, GB,             data/thread
  8x1-bw-process-NOTHP,                 449.361, GB,             data-total
  8x1-bw-process-NOTHP,                   0.360, nsecs,          runtime/byte/thread
  8x1-bw-process-NOTHP,                   2.780, GB/sec,         thread-speed
  8x1-bw-process-NOTHP,                  22.237, GB/sec,         total-speed

 # Running 16x1-bw-process, "perf bench numa mem -p 16 -t 1 -P 256 -s 20 -zZ0q --thp  1"
 16x1-bw-process,                        20.068, secs,           runtime-max/thread
 16x1-bw-process,                        20.014, secs,           runtime-min/thread
 16x1-bw-process,                        20.042, secs,           runtime-avg/thread
 16x1-bw-process,                         0.136, %,              spread-runtime/thread
 16x1-bw-process,                        36.742, GB,             data/thread
 16x1-bw-process,                       587.874, GB,             data-total
 16x1-bw-process,                         0.546, nsecs,          runtime/byte/thread
 16x1-bw-process,                         1.831, GB/sec,         thread-speed
 16x1-bw-process,                        29.294, GB/sec,         total-speed

 # Running  4x1-bw-thread, "perf bench numa mem -p 1 -t 4 -T 256 -s 20 -zZ0q --thp  1"
  4x1-bw-thread,                         20.053, secs,           runtime-max/thread
  4x1-bw-thread,                         20.003, secs,           runtime-min/thread
  4x1-bw-thread,                         20.025, secs,           runtime-avg/thread
  4x1-bw-thread,                          0.123, %,              spread-runtime/thread
  4x1-bw-thread,                         96.704, GB,             data/thread
  4x1-bw-thread,                        386.815, GB,             data-total
  4x1-bw-thread,                          0.207, nsecs,          runtime/byte/thread
  4x1-bw-thread,                          4.822, GB/sec,         thread-speed
  4x1-bw-thread,                         19.290, GB/sec,         total-speed

 # Running  8x1-bw-thread, "perf bench numa mem -p 1 -t 8 -T 256 -s 20 -zZ0q --thp  1"
  8x1-bw-thread,                         20.068, secs,           runtime-max/thread
  8x1-bw-thread,                         20.004, secs,           runtime-min/thread
  8x1-bw-thread,                         20.031, secs,           runtime-avg/thread
  8x1-bw-thread,                          0.160, %,              spread-runtime/thread
  8x1-bw-thread,                         66.203, GB,             data/thread
  8x1-bw-thread,                        529.623, GB,             data-total
  8x1-bw-thread,                          0.303, nsecs,          runtime/byte/thread
  8x1-bw-thread,                          3.299, GB/sec,         thread-speed
  8x1-bw-thread,                         26.391, GB/sec,         total-speed

 # Running 16x1-bw-thread, "perf bench numa mem -p 1 -t 16 -T 128 -s 20 -zZ0q --thp  1"
 16x1-bw-thread,                         20.044, secs,           runtime-max/thread
 16x1-bw-thread,                         20.007, secs,           runtime-min/thread
 16x1-bw-thread,                         20.029, secs,           runtime-avg/thread
 16x1-bw-thread,                          0.092, %,              spread-runtime/thread
 16x1-bw-thread,                         37.027, GB,             data/thread
 16x1-bw-thread,                        592.437, GB,             data-total
 16x1-bw-thread,                          0.541, nsecs,          runtime/byte/thread
 16x1-bw-thread,                          1.847, GB/sec,         thread-speed
 16x1-bw-thread,                         29.557, GB/sec,         total-speed

 # Running 32x1-bw-thread, "perf bench numa mem -p 1 -t 32 -T 64 -s 20 -zZ0q --thp  1"
 32x1-bw-thread,                         20.029, secs,           runtime-max/thread
 32x1-bw-thread,                         19.975, secs,           runtime-min/thread
 32x1-bw-thread,                         20.015, secs,           runtime-avg/thread
 32x1-bw-thread,                          0.134, %,              spread-runtime/thread
 32x1-bw-thread,                         18.923, GB,             data/thread
 32x1-bw-thread,                        605.523, GB,             data-total
 32x1-bw-thread,                          1.058, nsecs,          runtime/byte/thread
 32x1-bw-thread,                          0.945, GB/sec,         thread-speed
 32x1-bw-thread,                         30.232, GB/sec,         total-speed

 # Running  2x3-bw-thread, "perf bench numa mem -p 2 -t 3 -P 512 -s 20 -zZ0q --thp  1"
  2x3-bw-thread,                         20.176, secs,           runtime-max/thread
  2x3-bw-thread,                         20.072, secs,           runtime-min/thread
  2x3-bw-thread,                         20.136, secs,           runtime-avg/thread
  2x3-bw-thread,                          0.257, %,              spread-runtime/thread
  2x3-bw-thread,                         51.540, GB,             data/thread
  2x3-bw-thread,                        309.238, GB,             data-total
  2x3-bw-thread,                          0.391, nsecs,          runtime/byte/thread
  2x3-bw-thread,                          2.555, GB/sec,         thread-speed
  2x3-bw-thread,                         15.327, GB/sec,         total-speed

 # Running  4x4-bw-thread, "perf bench numa mem -p 4 -t 4 -P 512 -s 20 -zZ0q --thp  1"
  4x4-bw-thread,                         20.183, secs,           runtime-max/thread
  4x4-bw-thread,                         20.013, secs,           runtime-min/thread
  4x4-bw-thread,                         20.086, secs,           runtime-avg/thread
  4x4-bw-thread,                          0.421, %,              spread-runtime/thread
  4x4-bw-thread,                         35.266, GB,             data/thread
  4x4-bw-thread,                        564.251, GB,             data-total
  4x4-bw-thread,                          0.572, nsecs,          runtime/byte/thread
  4x4-bw-thread,                          1.747, GB/sec,         thread-speed
  4x4-bw-thread,                         27.957, GB/sec,         total-speed

 # Running  4x6-bw-thread, "perf bench numa mem -p 4 -t 6 -P 512 -s 20 -zZ0q --thp  1"
  4x6-bw-thread,                         20.298, secs,           runtime-max/thread
  4x6-bw-thread,                         20.061, secs,           runtime-min/thread
  4x6-bw-thread,                         20.184, secs,           runtime-avg/thread
  4x6-bw-thread,                          0.584, %,              spread-runtime/thread
  4x6-bw-thread,                         23.578, GB,             data/thread
  4x6-bw-thread,                        565.862, GB,             data-total
  4x6-bw-thread,                          0.861, nsecs,          runtime/byte/thread
  4x6-bw-thread,                          1.162, GB/sec,         thread-speed
  4x6-bw-thread,                         27.877, GB/sec,         total-speed

 # Running  4x8-bw-thread, "perf bench numa mem -p 4 -t 8 -P 512 -s 20 -zZ0q --thp  1"
  4x8-bw-thread,                         20.350, secs,           runtime-max/thread
  4x8-bw-thread,                         20.004, secs,           runtime-min/thread
  4x8-bw-thread,                         20.190, secs,           runtime-avg/thread
  4x8-bw-thread,                          0.851, %,              spread-runtime/thread
  4x8-bw-thread,                         18.086, GB,             data/thread
  4x8-bw-thread,                        578.747, GB,             data-total
  4x8-bw-thread,                          1.125, nsecs,          runtime/byte/thread
  4x8-bw-thread,                          0.889, GB/sec,         thread-speed
  4x8-bw-thread,                         28.439, GB/sec,         total-speed

 # Running  4x8-bw-thread-NOTHP, "perf bench numa mem -p 4 -t 8 -P 512 -s 20 -zZ0q --thp  1 --thp -1"
  4x8-bw-thread-NOTHP,                   20.411, secs,           runtime-max/thread
  4x8-bw-thread-NOTHP,                   19.990, secs,           runtime-min/thread
  4x8-bw-thread-NOTHP,                   20.246, secs,           runtime-avg/thread
  4x8-bw-thread-NOTHP,                    1.032, %,              spread-runtime/thread
  4x8-bw-thread-NOTHP,                   15.989, GB,             data/thread
  4x8-bw-thread-NOTHP,                  511.638, GB,             data-total
  4x8-bw-thread-NOTHP,                    1.277, nsecs,          runtime/byte/thread
  4x8-bw-thread-NOTHP,                    0.783, GB/sec,         thread-speed
  4x8-bw-thread-NOTHP,                   25.067, GB/sec,         total-speed

 # Running  3x3-bw-thread, "perf bench numa mem -p 3 -t 3 -P 512 -s 20 -zZ0q --thp  1"
  3x3-bw-thread,                         20.170, secs,           runtime-max/thread
  3x3-bw-thread,                         20.050, secs,           runtime-min/thread
  3x3-bw-thread,                         20.109, secs,           runtime-avg/thread
  3x3-bw-thread,                          0.299, %,              spread-runtime/thread
  3x3-bw-thread,                         48.318, GB,             data/thread
  3x3-bw-thread,                        434.865, GB,             data-total
  3x3-bw-thread,                          0.417, nsecs,          runtime/byte/thread
  3x3-bw-thread,                          2.396, GB/sec,         thread-speed
  3x3-bw-thread,                         21.560, GB/sec,         total-speed

 # Running  5x5-bw-thread, "perf bench numa mem -p 5 -t 5 -P 512 -s 20 -zZ0q --thp  1"
  5x5-bw-thread,                         20.276, secs,           runtime-max/thread
  5x5-bw-thread,                         20.004, secs,           runtime-min/thread
  5x5-bw-thread,                         20.155, secs,           runtime-avg/thread
  5x5-bw-thread,                          0.671, %,              spread-runtime/thread
  5x5-bw-thread,                         21.153, GB,             data/thread
  5x5-bw-thread,                        528.818, GB,             data-total
  5x5-bw-thread,                          0.959, nsecs,          runtime/byte/thread
  5x5-bw-thread,                          1.043, GB/sec,         thread-speed
  5x5-bw-thread,                         26.081, GB/sec,         total-speed

 # Running 2x16-bw-thread, "perf bench numa mem -p 2 -t 16 -P 512 -s 20 -zZ0q --thp  1"
 2x16-bw-thread,                         20.465, secs,           runtime-max/thread
 2x16-bw-thread,                         20.004, secs,           runtime-min/thread
 2x16-bw-thread,                         20.284, secs,           runtime-avg/thread
 2x16-bw-thread,                          1.127, %,              spread-runtime/thread
 2x16-bw-thread,                         14.881, GB,             data/thread
 2x16-bw-thread,                        476.204, GB,             data-total
 2x16-bw-thread,                          1.375, nsecs,          runtime/byte/thread
 2x16-bw-thread,                          0.727, GB/sec,         thread-speed
 2x16-bw-thread,                         23.269, GB/sec,         total-speed

 # Running 1x32-bw-thread, "perf bench numa mem -p 1 -t 32 -P 2048 -s 20 -zZ0q --thp  1"
 1x32-bw-thread,                         21.944, secs,           runtime-max/thread
 1x32-bw-thread,                         20.031, secs,           runtime-min/thread
 1x32-bw-thread,                         20.878, secs,           runtime-avg/thread
 1x32-bw-thread,                          4.358, %,              spread-runtime/thread
 1x32-bw-thread,                         13.019, GB,             data/thread
 1x32-bw-thread,                        416.612, GB,             data-total
 1x32-bw-thread,                          1.686, nsecs,          runtime/byte/thread
 1x32-bw-thread,                          0.593, GB/sec,         thread-speed
 1x32-bw-thread,                         18.985, GB/sec,         total-speed

 # Running numa02-bw, "perf bench numa mem -p 1 -t 32 -T 32 -s 20 -zZ0q --thp  1"
 numa02-bw,                              20.000, secs,           runtime-max/thread
 numa02-bw,                              19.967, secs,           runtime-min/thread
 numa02-bw,                              19.994, secs,           runtime-avg/thread
 numa02-bw,                               0.081, %,              spread-runtime/thread
 numa02-bw,                              19.644, GB,             data/thread
 numa02-bw,                             628.609, GB,             data-total
 numa02-bw,                               1.018, nsecs,          runtime/byte/thread
 numa02-bw,                               0.982, GB/sec,         thread-speed
 numa02-bw,                              31.431, GB/sec,         total-speed

 # Running numa02-bw-NOTHP, "perf bench numa mem -p 1 -t 32 -T 32 -s 20 -zZ0q --thp  1 --thp -1"
 numa02-bw-NOTHP,                        20.062, secs,           runtime-max/thread
 numa02-bw-NOTHP,                        19.940, secs,           runtime-min/thread
 numa02-bw-NOTHP,                        19.988, secs,           runtime-avg/thread
 numa02-bw-NOTHP,                         0.304, %,              spread-runtime/thread
 numa02-bw-NOTHP,                        18.246, GB,             data/thread
 numa02-bw-NOTHP,                       583.881, GB,             data-total
 numa02-bw-NOTHP,                         1.100, nsecs,          runtime/byte/thread
 numa02-bw-NOTHP,                         0.909, GB/sec,         thread-speed
 numa02-bw-NOTHP,                        29.104, GB/sec,         total-speed

 # Running numa01-bw-thread, "perf bench numa mem -p 2 -t 16 -T 192 -s 20 -zZ0q --thp  1"
 numa01-bw-thread,                       20.106, secs,           runtime-max/thread
 numa01-bw-thread,                       19.989, secs,           runtime-min/thread
 numa01-bw-thread,                       20.052, secs,           runtime-avg/thread
 numa01-bw-thread,                        0.293, %,              spread-runtime/thread
 numa01-bw-thread,                       17.975, GB,             data/thread
 numa01-bw-thread,                      575.190, GB,             data-total
 numa01-bw-thread,                        1.119, nsecs,          runtime/byte/thread
 numa01-bw-thread,                        0.894, GB/sec,         thread-speed
 numa01-bw-thread,                       28.607, GB/sec,         total-speed

 # Running numa01-bw-thread-NOTHP, "perf bench numa mem -p 2 -t 16 -T 192 -s 20 -zZ0q --thp  1 --thp -1"
 numa01-bw-thread-NOTHP,                 20.391, secs,           runtime-max/thread
 numa01-bw-thread-NOTHP,                 20.010, secs,           runtime-min/thread
 numa01-bw-thread-NOTHP,                 20.085, secs,           runtime-avg/thread
 numa01-bw-thread-NOTHP,                  0.936, %,              spread-runtime/thread
 numa01-bw-thread-NOTHP,                 13.457, GB,             data/thread
 numa01-bw-thread-NOTHP,                430.638, GB,             data-total
 numa01-bw-thread-NOTHP,                  1.515, nsecs,          runtime/byte/thread
 numa01-bw-thread-NOTHP,                  0.660, GB/sec,         thread-speed
 numa01-bw-thread-NOTHP,                 21.119, GB/sec,         total-speed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
