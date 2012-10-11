Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id EE8E86B005A
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 11:35:06 -0400 (EDT)
Date: Thu, 11 Oct 2012 16:35:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00/33] AutoNUMA27
Message-ID: <20121011153503.GX3317@csn.ul.ie>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <20121011101930.GM3317@csn.ul.ie>
 <20121011145611.GI1818@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121011145611.GI1818@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, Oct 11, 2012 at 04:56:11PM +0200, Andrea Arcangeli wrote:
> Hi Mel,
> 
> On Thu, Oct 11, 2012 at 11:19:30AM +0100, Mel Gorman wrote:
> > As a basic sniff test I added a test to MMtests for the AutoNUMA
> > Benchmark on a 4-node machine and the following fell out.
> > 
> >                                      3.6.0                 3.6.0
> >                                    vanilla        autonuma-v33r6
> > User    SMT             82851.82 (  0.00%)    33084.03 ( 60.07%)
> > User    THREAD_ALLOC   142723.90 (  0.00%)    47707.38 ( 66.57%)
> > System  SMT               396.68 (  0.00%)      621.46 (-56.67%)
> > System  THREAD_ALLOC      675.22 (  0.00%)      836.96 (-23.95%)
> > Elapsed SMT              1987.08 (  0.00%)      828.57 ( 58.30%)
> > Elapsed THREAD_ALLOC     3222.99 (  0.00%)     1101.31 ( 65.83%)
> > CPU     SMT              4189.00 (  0.00%)     4067.00 (  2.91%)
> > CPU     THREAD_ALLOC     4449.00 (  0.00%)     4407.00 (  0.94%)
> 
> Thanks a lot for the help and for looking into it!
> 
> Just curious, why are you running only numa02_SMT and
> numa01_THREAD_ALLOC? And not numa01 and numa02? (the standard version
> without _suffix)
> 

Bug in the testing script on my end. Each of them are run separtly and it
looks like in retrospect that a THREAD_ALLOC test actually ran numa01 then
numa01_THREAD_ALLOC. The intention was to allow additional stats to be
gathered independently of what start_bench.sh collects. Will improve it
in the future.

> > 
> > The performance improvements are certainly there for this basic test but
> > I note the System CPU usage is very high.
> 
> Yes, migrate is expensive, but after convergence has been reached the
> system time should be the same as upstream.
> 

Ok.

> btw, I improved things further in autonuma28 (new branch in aa.git).
> 

Ok.

> > 
> > The vmstats showed up this
> > 
> > THP fault alloc               81376       86070
> > THP collapse alloc               14       40423
> > THP splits                        8       41792
> > 
> > So we're doing a lot of splits and collapses for THP there. There is a
> > possibility that khugepaged and the autonuma kernel thread are doing some
> > busy work. Not a show-stopped, just interesting.
> > 
> > I've done no analysis at all and this was just to have something to look
> > at before looking at the code closer.
> 
> Sure, the idea is to have THP native migration, then we'll do zero
> collapse/splits.
> 

Seems reasonably. It should be obvious to measure when/if that happens.

> > > The objective of AutoNUMA is to provide out-of-the-box performance as
> > > close as possible to (and potentially faster than) manual NUMA hard
> > > bindings.
> > > 
> > > It is not very intrusive into the kernel core and is well structured
> > > into separate source modules.
> > > 
> > > AutoNUMA was extensively tested against 3.x upstream kernels and other
> > > NUMA placement algorithms such as numad (in userland through cpusets)
> > > and schednuma (in kernel too) and was found superior in all cases.
> > > 
> > > Most important: not a single benchmark showed a regression yet when
> > > compared to vanilla kernels. Not even on the 2 node systems where the
> > > NUMA effects are less significant.
> > > 
> > 
> > Ok, I have not run a general regression test and won't get the chance to
> > soon but hopefully others will. One thing they might want to watch out
> > for is System CPU time. It's possible that your AutoNUMA benchmark
> > triggers a worst-case but it's worth keeping an eye on because any cost
> > from that has to be offset by gains from better NUMA placements.
> 
> Good idea to monitor it indeed.
> 

If System CPU time really does go down as this converges then that
should be obvious from monitoring vmstat over time for a test. Early on
- high usage with that dropping as it converges. If that doesn't happen
  then the tasks are not converging, the phases change constantly or
something unexpected happened that needs to be identified.

> > Is STREAM really a good benchmark in this case? Unless you also ran it in
> > parallel mode, it basically operations against three arrays and not really
> > NUMA friendly once the total size is greater than a NUMA node. I guess
> > it makes sense to run it just to see does autonuma break it :)
> 
> The way this is run is that there is 1 stream, then 4 stream, then 8
> until we max out all CPUs.
> 

Ok. Are they separate STREAM instances or threads running on the same
arrays? 

> I think we could run "memhog" instead of "stream" and it'd be the
> same. stream probably better resembles real life computations.
> 
> The upstream scheduler lacks any notion of affinity so eventually
> during the 5 min run, on process changes node, it doesn't notice its
> memory was elsewhere so it stays there, and the memory can't follow
> the cpu either. So then it runs much slower.
> 
> So it's the simplest test of all to get right, all it requires is some
> notion of node affinity.
> 

Ok.

> It's also the only workload that the home node design in schednuma in
> tip.git can get right (schednuma post current tip.git introduced
> cpu-follow-memory design of AutoNUMA so schednuma will have a chance
> to get right more stuff than just the stream multi instance
> benchmark).
> 
> So it's just for a verification than the simple stuff (single threaded
> process computing) is ok and the upstream regression vs hard NUMA
> bindings is fixed.
> 

Verification of the simple stuff makes sense.

> stream is also one case where we have to perform identical to the hard
> NUMA bindings. No migration of CPU or memory must ever happen with
> AutoNUMA in the stream benchmark. AutoNUMA will just monitor it and
> find that it is already in the best place and it will leave it alone.
> 
> With the autonuma-benchmark it's impossible to reach identical
> performance of the _HARD_BIND case because _HARD_BIND doesn't need to
> do any memory migration (I'm 3 seconds away from hard bindings in a
> 198 sec run though, just the 3 seconds it takes to migrate 3g of ram ;).
> 
> > 
> > > 
> > > == iozone ==
> > > 
> > >                      ALL  INIT   RE             RE   RANDOM RANDOM BACKWD  RECRE STRIDE  F      FRE     F      FRE
> > > FILE     TYPE (KB)  IOS  WRITE  WRITE   READ   READ   READ  WRITE   READ  WRITE   READ  WRITE  WRITE   READ   READ
> > > ====--------------------------------------------------------------------------------------------------------------
> > > noautonuma ALL      2492   1224   1874   2699   3669   3724   2327   2638   4091   3525   1142   1692   2668   3696
> > > autonuma   ALL      2531   1221   1886   2732   3757   3760   2380   2650   4192   3599   1150   1731   2712   3825
> > > 
> > > AutoNUMA can't help much for I/O loads but you can see it seems a
> > > small improvement there too. The important thing for I/O loads, is to
> > > verify that there is no regression.
> > > 
> > 
> > It probably is unreasonable to expect autonuma to handle the case where
> > a file-based workload has not been tuned for NUMA. In too many cases
> > it's going to be read/write based so you're not going to get the
> > statistics you need.
> 
> Agreed. Some statistic may still accumulate and it's still better than
> nothing but unless the workload is CPU and memory bound, we can't
> expect to see any difference.
> 
> This is meant as a verification that we're not introducing regression
> to I/O bound load.
> 

Ok, that's more or less what I had guessed but nice to know for sure.
Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
