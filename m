Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 87E176B005D
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 06:19:35 -0400 (EDT)
Date: Thu, 11 Oct 2012 11:19:30 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00/33] AutoNUMA27
Message-ID: <20121011101930.GM3317@csn.ul.ie>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Oct 04, 2012 at 01:50:42AM +0200, Andrea Arcangeli wrote:
> Hello everyone,
> 
> This is a new AutoNUMA27 release for Linux v3.6.
> 
> I believe that this autonuma version answers all of the review
> comments I got upstream. This patch set has undergone a huge series of
> changes that includes changing the page migration implementation to
> synchronous, reduction of memory overhead to minimum, internal
> documentation, external documentation and benchmarking. I'm grateful
> for all the reviews and contributions, that includes Rik, Karen, Avi,
> Peter, Konrad, Hillf and all others, plus all runtime feedback
> received (bugreports, KVM benchmarks, etc..).
> 
> The last 4 months were fully dedicated to answer the upstream review.
> 
> Linus, Andrew, please review, as the handful of performance results
> show we're in excellent shape for inclusion. Further changes such as
> transparent huge page native migration and more are expected but at
> this point I would ask you to accept the current series and further
> changes will be added in traditional gradual steps.
> 

As a basic sniff test I added a test to MMtests for the AutoNUMA
Benchmark on a 4-node machine and the following fell out.

                                     3.6.0                 3.6.0
                                   vanilla        autonuma-v33r6
User    SMT             82851.82 (  0.00%)    33084.03 ( 60.07%)
User    THREAD_ALLOC   142723.90 (  0.00%)    47707.38 ( 66.57%)
System  SMT               396.68 (  0.00%)      621.46 (-56.67%)
System  THREAD_ALLOC      675.22 (  0.00%)      836.96 (-23.95%)
Elapsed SMT              1987.08 (  0.00%)      828.57 ( 58.30%)
Elapsed THREAD_ALLOC     3222.99 (  0.00%)     1101.31 ( 65.83%)
CPU     SMT              4189.00 (  0.00%)     4067.00 (  2.91%)
CPU     THREAD_ALLOC     4449.00 (  0.00%)     4407.00 (  0.94%)

The performance improvements are certainly there for this basic test but
I note the System CPU usage is very high.

The vmstats showed up this

THP fault alloc               81376       86070
THP collapse alloc               14       40423
THP splits                        8       41792

So we're doing a lot of splits and collapses for THP there. There is a
possibility that khugepaged and the autonuma kernel thread are doing some
busy work. Not a show-stopped, just interesting.

I've done no analysis at all and this was just to have something to look
at before looking at the code closer.

> The objective of AutoNUMA is to provide out-of-the-box performance as
> close as possible to (and potentially faster than) manual NUMA hard
> bindings.
> 
> It is not very intrusive into the kernel core and is well structured
> into separate source modules.
> 
> AutoNUMA was extensively tested against 3.x upstream kernels and other
> NUMA placement algorithms such as numad (in userland through cpusets)
> and schednuma (in kernel too) and was found superior in all cases.
> 
> Most important: not a single benchmark showed a regression yet when
> compared to vanilla kernels. Not even on the 2 node systems where the
> NUMA effects are less significant.
> 

Ok, I have not run a general regression test and won't get the chance to
soon but hopefully others will. One thing they might want to watch out
for is System CPU time. It's possible that your AutoNUMA benchmark
triggers a worst-case but it's worth keeping an eye on because any cost
from that has to be offset by gains from better NUMA placements.

> === Some benchmark result ===
> 
> <SNIP>

Looked good for the most part.

> == stream modified to run each instance for ~5min ==
> 

Is STREAM really a good benchmark in this case? Unless you also ran it in
parallel mode, it basically operations against three arrays and not really
NUMA friendly once the total size is greater than a NUMA node. I guess
it makes sense to run it just to see does autonuma break it :)

> 
> == iozone ==
> 
>                      ALL  INIT   RE             RE   RANDOM RANDOM BACKWD  RECRE STRIDE  F      FRE     F      FRE
> FILE     TYPE (KB)  IOS  WRITE  WRITE   READ   READ   READ  WRITE   READ  WRITE   READ  WRITE  WRITE   READ   READ
> ====--------------------------------------------------------------------------------------------------------------
> noautonuma ALL      2492   1224   1874   2699   3669   3724   2327   2638   4091   3525   1142   1692   2668   3696
> autonuma   ALL      2531   1221   1886   2732   3757   3760   2380   2650   4192   3599   1150   1731   2712   3825
> 
> AutoNUMA can't help much for I/O loads but you can see it seems a
> small improvement there too. The important thing for I/O loads, is to
> verify that there is no regression.
> 

It probably is unreasonable to expect autonuma to handle the case where
a file-based workload has not been tuned for NUMA. In too many cases
it's going to be read/write based so you're not going to get the
statistics you need.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
