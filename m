Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 60B126B00B2
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 13:04:33 -0500 (EST)
Date: Wed, 4 Mar 2009 18:04:26 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
Message-ID: <20090304180426.GB25260@csn.ul.ie>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie> <1235639427.11390.11.camel@minggr> <20090226110336.GC32756@csn.ul.ie> <1235647139.16552.34.camel@penberg-laptop> <20090226112232.GE32756@csn.ul.ie> <1235724283.11610.212.camel@minggr> <20090302112122.GC21145@csn.ul.ie> <1236132307.2567.25.camel@ymzhang>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1236132307.2567.25.camel@ymzhang>
Sender: owner-linux-mm@kvack.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Lin Ming <ming.m.lin@intel.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 04, 2009 at 10:05:07AM +0800, Zhang, Yanmin wrote:
> On Mon, 2009-03-02 at 11:21 +0000, Mel Gorman wrote:
> > (Added Ingo as a second scheduler guy as there are queries on tg_shares_up)
> > 
> > On Fri, Feb 27, 2009 at 04:44:43PM +0800, Lin Ming wrote:
> > > On Thu, 2009-02-26 at 19:22 +0800, Mel Gorman wrote: 
> > > > In that case, Lin, could I also get the profiles for UDP-U-4K please so I
> > > > can see how time is being spent and why it might have gotten worse?
> > > 
> > > I have done the profiling (oltp and UDP-U-4K) with and without your v2
> > > patches applied to 2.6.29-rc6.
> > > I also enabled CONFIG_DEBUG_INFO so you can translate address to source
> > > line with addr2line.
> > > 
> > > You can download the oprofile data and vmlinux from below link,
> > > http://www.filefactory.com/file/af2330b/
> > > 
> > 
> > Perfect, thanks a lot for profiling this. It is a big help in figuring out
> > how the allocator is actually being used for your workloads.
> > 
> > The OLTP results had the following things to say about the page allocator.
>
> In case we might mislead you guys, I want to clarify that here OLTP is
> sysbench (oltp)+mysql, not the famous OLTP which needs lots of disks and big
> memory.
> 

Ah good. I'm testing with sysbench+postgres and I've seen similar
regressions on some machines so I have something to investigate.

> Ma Chinang, another Intel guy, does work on the famous OLTP running.
> 

Good to know. It's too early to test remotely near there but when this
is ready for merging a run on that setup would be really nice time was
available.

> > <SNIP>
> > Question 1: Would it be possible to increase the sample rate and track cache
> > misses as well please?
>
> I will try to capture cache miss with oprofile.
> 

Great, thanks. I did a cache miss capture for one of the machines and
noted cache misses increased but it'd still good to know.

> > Another interesting fact is that we are spending about 15% of the overall
> > time is spent in tg_shares_up() for both kernels but the vanilla kernel
> > recorded 977348 samples and the patched kernel recorded 514576 samples. We
> > are spending less time in the kernel and it's not obvious why or if that is
> > a good thing or not. You'd think less time in kernel is good but it might
> > mean we are doing less work overall.
> > 
> > Total aside from the page allocator, I checked what we were doing
> > in tg_shares_up where the vast amount of time is being spent. This has
> > something to do with CONFIG_FAIR_GROUP_SCHED. 
> > 
> > Question 2: Scheduler guys, can you think of what it means to be spending
> > less time in tg_shares_up please?
> > 
> > I don't know enough of how it works to guess why we are in there. FWIW,
> > we are appear to be spending the most time in the following lines
> > 
> >                 weight = tg->cfs_rq[i]->load.weight;
> >                 if (!weight)
> >                         weight = NICE_0_LOAD;
> > 
> >                 tg->cfs_rq[i]->rq_weight = weight;
> >                 rq_weight += weight;
> >                 shares += tg->cfs_rq[i]->shares;
> > 
> > So.... cfs_rq is SMP aligned, but we iterate though it with for_each_cpu()
> > and we're writing to it. How often is this function run by multiple CPUs? If
> > the answer is "lots", does that not mean we are cache line bouncing in
> > here like mad? Another crazy amount of time is spent accessing tg->se when
> > validating. Basically, any access of the task_group appears to incur huge
> > costs and cache line bounces would be the obvious explanation.
>
> ???FAIR_GROUP_SCHED is a feature to support configurable cpu weight for different users.
> We did find it takes lots of time to check/update the share weight which might create
> lots of cache ping-pang. With sysbench(oltp)+mysql, that becomes more severe because
> mysql runs as user mysql and sysbench runs as another regular user. When starting
> the testing with 1 thread in command line, there are 2 mysql threads and 1 sysbench
> thread are proactive.
> 

Very interesting, I don't think this will affect the page allocator but
I'll keep it in mind when worrying about the workload as a whole instead
of just one corner of it.

> > 
> > 
> > More stupid poking around. We appear to update these share things on each
> > fork().
> > 
> > Question 3: Scheduler guys, If the database or clients being used for OLTP is
> > fork-based instead of thread-based, then we are going to be balancing a lot,
> > right? What does that mean, how can it be avoided?
> > 
> > Question 4: Lin, this is unrelated to the page allocator but do you know
> > what the performance difference between vanilla-with-group-sched and
> > vanilla-without-group-sched is?
>
> When ???FAIR_GROUP_SCHED appeared in kernel at the first time, we did many such testing.
> There is another thread to discuss it at http://lkml.org/lkml/2008/9/10/214.
> 
> set s???ched_shares_ratelimit to a large value could reduce the regression.
> 
> Scheduler guys keep improving it. 
> 

Good to know. I haven't read the thread yet but it's now on my TODO
list.

> > The UDP results are screwy as the profiles are not matching up to the
> > images. For example
> Mostly, it's caused by not cleaning up old oprofile data when starting
> new sampling.
> 
> I will retry.
> 

Thanks
> > 
> > oltp.oprofile.2.6.29-rc6:           ffffffff802808a0 11022     0.1727  get_page_from_freelist
> > oltp.oprofile.2.6.29-rc6-mg-v2:     ffffffff80280610 7958      0.2403  get_page_from_freelist
> > UDP-U-4K.oprofile.2.6.29-rc6:       ffffffff802808a0 29914     1.2866  get_page_from_freelist
> > UDP-U-4K.oprofile.2.6.29-rc6-mg-v2: ffffffff802808a0 28153     1.1708  get_page_from_freelist
> > 
> > Look at the addresses. UDP-U-4K.oprofile.2.6.29-rc6-mg-v2 has the address
> > for UDP-U-4K.oprofile.2.6.29-rc6 so I have no idea what I'm looking at here
> > for the patched kernel :(.
> > 
> > Question 5: Lin, would it be possible to get whatever script you use for
> > running netperf so I can try reproducing it?

> Below is a simple script. As for formal testing, we add parameter "-i 50,3 -I" 99,5"
> to get a more stable result.
> 
> PROG_DIR=/home/ymzhang/test/netperf/src
> taskset -c 0 ${PROG_DIR}/netserver
> sleep 2
> taskset -c 7 ${PROG_DIR}/netperf -t UDP_STREAM -l 60 -H 127.0.0.1 -- -P 15895 12391 -s 32768 -S 32768 -m 4096
> killall netserver
> 

Thanks, simple is good enough to start with. Just have to get around to
wrapping the automation around it.

> Basically, we start 1 client and bind client/server to different physical cpu.
> 
> > 
> > Going by the vanilla kernel, a *large* amount of time is spent doing
> > high-order allocations. Over 25% of the cost of buffered_rmqueue() is in
> > the branch dealing with high-order allocations. Does UDP-U-4K mean that 8K
> > pages are required for the packets? That means high-order allocations and
> > high contention on the zone-list. That is bad obviously and has implications
> > for the SLUB-passthru patch because whether 8K allocations are handled by
> > SL*B or the page allocator has a big impact on locking.
> > 
> > Next, a little over 50% of the cost get_page_from_freelist() is being spent
> > acquiring the zone spinlock. The implication is that the SL*B allocators
> > passing in order-1 allocations to the page allocator are currently going to
> > hit scalability problems in a big way. The solution may be to extend the
> > per-cpu allocator to handle magazines up to PAGE_ALLOC_COSTLY_ORDER. I'll
> > check it out.
> > 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
