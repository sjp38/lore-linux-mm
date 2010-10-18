Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DEDD46B00DC
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:13:47 -0400 (EDT)
Date: Mon, 18 Oct 2010 13:13:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
In-Reply-To: <20101013141455.GQ30667@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1010181305000.2092@router.home>
References: <20101005185725.088808842@linux.com> <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com> <alpine.DEB.2.00.1010061054410.31538@router.home> <20101013141455.GQ30667@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, npiggin@kernel.dk, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Wed, 13 Oct 2010, Mel Gorman wrote:

> Minimally, I see the same sort of hackbench socket performance regression
> as reported elsewhere (10-15% regression). Otherwise, it isn't particularly
> exciting results. The machine is very basic - 2 socket, 4 cores, x86-64,
> 2G RAM. Macine model is an IBM BladeCenter HS20. Processor is Xeon but I'm
> not sure exact what model. It appears to be from around the P4 times.

Looks not good. Something must still be screwed up. Trouble is to find
time to do this work. When working on SLAB we had a team to implement the
NUMA stuff and deal with the performance issues.

> Christoph, in particular while it tests netperf, it is not binding to any
> particular CPU (although it can), server and client are running on the local
> machine (which has particular performance characterisitcs of its own) and
> the tests is STREAM, not RR so the tarball is not a replacement for more
> targetting testing or workload-specific testing. Still, it should catch
> some of the common snags before getting into specific workloads without
> taking an extraordinary amount of time to complete. sysbench might take a
> long time for many-core machines, limit the number of threads it tests with
> OLTP_MAX_THREADS in the config file.

That should not matter too much. The performance results should replicate
SLABs caching behavior and I do not see that in the tests.

> NETPERF UDP
>                    netperf-udp       netperf-udp          udp-slub
>                   slab-vanilla      slub-vanilla      unified-v4r1
>       64    52.23 ( 0.00%)*    53.80 ( 2.92%)     50.56 (-3.30%)               1.36%             1.00%             1.00%
>      128   103.70 ( 0.00%)    107.43 ( 3.47%)    101.23 (-2.44%)
>      256   208.62 ( 0.00%)*   212.15 ( 1.66%)    202.35 (-3.10%)               1.73%             1.00%             1.00%
>     1024   814.86 ( 0.00%)    827.42 ( 1.52%)    799.13 (-1.97%)
>     2048  1585.65 ( 0.00%)   1614.76 ( 1.80%)   1563.52 (-1.42%)
>     3312  2512.44 ( 0.00%)   2556.70 ( 1.73%)   2460.37 (-2.12%)
>     4096  3016.81 ( 0.00%)*  3058.16 ( 1.35%)   2901.87 (-3.96%)               1.15%             1.00%             1.00%
>     8192  5384.46 ( 0.00%)   5092.95 (-5.72%)   4912.71 (-9.60%)
>    16384  8091.96 ( 0.00%)*  8249.26 ( 1.91%)   8004.40 (-1.09%)               1.70%             1.00%             1.00%


Seems that we lost some of the netperf wins.

> SYSBENCH
>             sysbench-slab-vanilla-sysbenchsysbench-slub-vanilla-sysbench     sysbench-slub
>                   slab-vanilla      slub-vanilla      unified-v4r1
>            1  7521.24 ( 0.00%)  7719.38 ( 2.57%)  7589.13 ( 0.89%)
>            2 14872.85 ( 0.00%) 15275.09 ( 2.63%) 15054.08 ( 1.20%)
>            3 16502.53 ( 0.00%) 16676.53 ( 1.04%) 16465.69 (-0.22%)
>            4 17831.19 ( 0.00%) 17900.09 ( 0.38%) 17819.03 (-0.07%)
>            5 18158.40 ( 0.00%) 18432.74 ( 1.49%) 18341.99 ( 1.00%)
>            6 18673.68 ( 0.00%) 18878.41 ( 1.08%) 18614.92 (-0.32%)
>            7 17689.75 ( 0.00%) 17871.89 ( 1.02%) 17633.19 (-0.32%)
>            8 16885.68 ( 0.00%) 16838.37 (-0.28%) 16498.41 (-2.35%)

Same here. Seems that we combined the worst of both.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
