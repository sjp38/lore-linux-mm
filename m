Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 31DEF6B0068
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 13:48:39 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c4so4413696eek.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 10:48:37 -0800 (PST)
Date: Mon, 12 Nov 2012 19:48:33 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Benchmark results: "Enhanced NUMA scheduling with adaptive affinity"
Message-ID: <20121112184833.GA17503@gmail.com>
References: <20121112160451.189715188@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121112160451.189715188@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>


* Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Hi,
> 
> This series implements an improved version of NUMA scheduling, 
> based on the review and testing feedback we got.
>
> [...]
>
> This new scheduler code is then able to group tasks that are 
> "memory related" via their memory access patterns together: in 
> the NUMA context moving them on the same node if possible, and 
> spreading them amongst nodes if they use private memory.

Here are some preliminary performance figures, comparing the 
vanilla kernel against the CONFIG_SCHED_NUMA=y kernel.

Java SPEC benchmark, running on a 4 node, 64 GB, 32-way server 
system (higher numbers are better):

   v3.7-vanilla:    run #1:    475630
                    run #2:    538271
                    run #3:    533888
                    run #4:    431525
                    ----------------------------------
                       avg:    494828 transactions/sec

   v3.7-NUMA:       run #1:    626692
                    run #2:    622069
                    run #3:    630335
                    run #4:    629817
                    ----------------------------------
                       avg:    627228 transactions/sec    [ +26.7% ]

Beyond the +26.7% performance improvement in throughput, the 
standard deviation of the results is much lower as well with 
NUMA scheduling enabled, by about an order of magnitude.

[ That is probably so because memory and task placement is more 
  balanced with NUMA scheduling enabled - while with the vanilla 
  kernel initial placement of the working set determines the 
  final performance figure. ]

I've also tested Andrea's 'autonumabench' benchmark suite 
against vanilla and the NUMA kernel, because Mel reported that 
the CONFIG_SCHED_NUMA=y code regressed. It does not regress 
anymore:

  #
  # NUMA01
  #
  perf stat --null --repeat 3 ./numa01

   v3.7-vanilla:           340.3 seconds           ( +/- 0.31% )
   v3.7-NUMA:              216.9 seconds  [ +56% ] ( +/- 8.32% )
   -------------------------------------
   v3.7-HARD_BIND:         166.6 seconds

Here the new NUMA code is faster than vanilla by 56% - that is 
because with the vanilla kernel all memory is allocated on 
node0, overloading that node's memory bandwidth.

[ Standard deviation on the vanilla kernel is low, because the 
  autonuma test causes close to the worst-case placement for the 
  vanilla kernel - and there's not much space to deviate away 
  from the worst-case. Despite that, stddev in the NUMA seems a 
  tad high, suggesting further room for improvement. ]

  #
  # NUMA01_THREAD_ALLOC
  #
  perf stat --null --repeat 3 ./numa01_THREAD_ALLOC

   v3.7-vanilla:            425.1 seconds             ( +/- 1.04% )
   v3.7-NUMA:               118.7 seconds  [ +250% ]  ( +/- 0.49% )
   -------------------------------------
   v3.7-HARD_BIND:          200.56 seconds

Here the NUMA kernel was able to go beyond the (naive) 
hard-binding result and achieved 3.5x the performance of the 
vanilla kernel, with a low stddev.

  #
  # NUMA02
  #
  perf stat --null --repeat 3 ./numa02

   v3.7-vanilla:           56.1 seconds               ( +/- 0.72% )
   v3.7-NUMA:              17.0 seconds    [ +230% ]  ( +/- 0.18% )
   -------------------------------------
   v3.7-HARD_BIND:         14.9 seconds

Here the NUMA kernel runs the test much (3.3x) faster than the 
vanilla kernel. The workload is able to converge very quickly 
and approximate the hard-binding ideal number very closely. If 
runtime was a bit longer it would approximate it even closer.

Standard deviation is also 3 times lower than vanilla, 
suggesting stable NUMA convergence.

  #
  # NUMA02_SMT
  #
  perf stat --null --repeat 3 ./numa02_SMT
   v3.7-vanilla:            56.1 seconds                 ( +- 0.42% )
   v3.7-NUMA:               17.3 seconds     [ +220% ]   ( +- 0.88% )
   -------------------------------------
   v3.7-HARD_BIND:          14.6 seconds

In this test too the NUMA kernel outperforms the vanilla kernel, 
by a factor of 3.2x. It comes very close to the ideal 
hard-binding convergence result. Standard deviation is a bit 
high.

I have also created a new perf benchmarking and workload 
generation tool: 'perf bench numa' (I'll post it later in a 
separate reply).

Via 'perf bench numa' we can generate arbitrary process and 
thread layouts, with arbitrary memory sharing arrangements 
between them.

Here are various comparisons to the vanilla kernel (higher 
numbers are better):

  #
  # 4 processes with 4 threads per process, sharing 4x 1GB of 
  # process-wide memory:
  #
  # perf bench numa mem -l 100 -zZ0 -p 4 -t 4 -P 1024 -T    0
  #
           v3.7-vanilla:       14.8 GB/sec
           v3.7-NUMA:          32.9 GB/sec    [ +122.3% ]

2.2 times faster.

  #
  # 4 processes with 4 threads per process, sharing 4x 1GB of 
  # process-wide memory:
  #
  # perf bench numa mem -l 100 -zZ0 -p 4 -t 4 -P    0 -T 1024
  #

           v3.7-vanilla:        17.0 GB/sec
           v3.7-NUMA:           36.3 GB/sec    [ +113.5% ]

2.1 times faster.

So it's a nice improvement all around. With this version the 
regressions that Mel Gorman reported a week ago appear to be 
fixed as well.

Thanks,

	Ingo

ps. If anyone is curious about further details, let me know.
    The base kernel I used for measurement was commit
    02743c9c03f1 + the 8 patches Peter sent out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
