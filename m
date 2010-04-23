Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 146416B01EE
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 06:51:08 -0400 (EDT)
Date: Fri, 23 Apr 2010 11:50:45 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100423105044.GK30306@csn.ul.ie>
References: <20100414014041.GD2493@dastard> <20100414155233.D153.A69D9226@jp.fujitsu.com> <20100414072830.GK2493@dastard> <20100414085132.GJ25756@csn.ul.ie> <20100415013436.GO2493@dastard> <20100415102837.GB10966@csn.ul.ie> <20100416041412.GY2493@dastard> <20100416151403.GM19264@csn.ul.ie> <20100419152034.GW19264@csn.ul.ie> <20100423010632.GA10390@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100423010632.GA10390@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 23, 2010 at 11:06:32AM +1000, Dave Chinner wrote:
> On Mon, Apr 19, 2010 at 04:20:34PM +0100, Mel Gorman wrote:
> > On Fri, Apr 16, 2010 at 04:14:03PM +0100, Mel Gorman wrote:
> > > > > Your patch fixes 2, avoids 1, breaks 3 and haven't thought about 4 but I
> > > > > guess dirty pages can cycle around more so it'd need to be cared for.
> > > > 
> > > > Well, you keep saying that they break #3, but I haven't seen any
> > > > test cases or results showing that. I've been unable to confirm that
> > > > lumpy reclaim is broken by disallowing writeback in my testing, so
> > > > I'm interested to know what tests you are running that show it is
> > > > broken...
> > > > 
> > > 
> > > Ok, I haven't actually tested this. The machines I use are tied up
> > > retesting the compaction patches at the moment. The reason why I reckon
> > > it'll be a problem is that when these sync-writeback changes were
> > > introduced, it significantly helped lumpy reclaim for huge pages. I am
> > > making an assumption that backing out those changes will hurt it.
> > > 
> > > I'll test for real on Monday and see what falls out.
> > > 
> > 
> > One machine has completed the test and the results are as expected. When
> > allocating huge pages under stress, your patch drops the success rates
> > significantly. On X86-64, it showed
> > 
> > STRESS-HIGHALLOC
> >               stress-highalloc   stress-highalloc
> >             enable-directreclaim disable-directreclaim
> > Under Load 1    89.00 ( 0.00)    73.00 (-16.00)
> > Under Load 2    90.00 ( 0.00)    85.00 (-5.00)
> > At Rest         90.00 ( 0.00)    90.00 ( 0.00)
> > 
> > So with direct reclaim, it gets 89% of memory as huge pages at the first
> > attempt but 73% with your patch applied. The "Under Load 2" test happens
> > immediately after. With the start kernel, the first and second attempts
> > are usually the same or very close together. With your patch applied,
> > there are big differences as it was no longer trying to clean pages.
> 
> What was the machine config you were testing on (RAM, CPUs, etc)?

2G RAM, AMD Phenom with 4 cores.

> And what are these loads?

Compile-based loads that fill up memory and put it under heavy memory
pressure that also dirties memory. While they are running, a kernel module
is loaded that starts allocating huge pages one at a time so that accurate
timing and the state of the system can be gathered at allocation time. The
number of allocation attempts is 90% of the number of huge pages that exist
in the system.

> Do you have a script that generates
> them? If so, can you share them, please?
> 

Yes, but unfortunately they are not in a publishable state. Parts of
them depend on an automation harness that I don't hold the copyright to.

> OOC, what was the effect on the background load - did it go faster
> or slower when writeback was disabled?

Unfortunately, I don't know what the effect on the underlying load is
as it takes longer than the huge page allocation attempts do. The tests
objective is to check how well lumpy reclaim works undedmemory pressure.

However, the time it takes to allocate a huge page increases with direct
reclaim disabled (i.e. your patch) early in the test up until about 40%
of memory was allocated as huge pages. After that, the latencies with
disable-directreclaim are lower until the gives up while the latencies with
enable-directreclaim increase.

In other words, with direct reclaim writing back pages, lumpy reclaim is a
lot more determined to get the pages cleaned and wait on them if necessary. A
compromise patch might be to have a wait_on_page_dirty to be cleared instead
of queueing the IO and wait_on_page_writeback? How long it stalled would
depend heavily on what rate pages were getting cleaned in the background.

> i.e. did we trade of more
> large pages for better overall throughput?
> 
> Also, I'm curious as to the repeatability of the tests you are
> doing. I found that from run to run I could see a *massive*
> variance in the results. e.g. one run might only get ~80 huge
> pages at the first attempt, the test run from the same initial
> conditions next might get 440 huge pages at the first attempt.

You are using the nr_hugepages interface and writing a large number to it
so you are also triggering the hugetlbfs retry-logic and have little control
over how many times the allocator gets called on each attempt. How many huge
pages it allocates depends on how much progress it is able to make during
lumpy reclaim.

It's why the tests I run allocate huge pages one at a time and measure
the latencies as it goes. The results tend to be quite reproducible.
Success figures would be the same between runs and the rate of
allocation success would generally be comparable as well.

Your test could do something similar by only ever requesting one additional
page. It will be good enough to measure allocation latency.  The gathering
of other system state at the time of failure is not very important here
(where as it was important during anti-frag development hence the use of a
kernel module).

> I saw
> the same variance with or without writeback from direct reclaim
> enabled. Hence only after averaging over tens of runs could I see
> any sort of trend emerge, and it makes me wonder if your testing is
> also seeing this sort of variance....
> 

Typically, there is not much variance between tests. Maybe 1-2% in allocation
success rates.

> FWIW, if we look results of the test I did, it showed a 20%
> improvement in large page allocation with a 15% increase in load
> throughput, while you're showing a 16% degradation in large page
> allocation.

With writeback, lumpy reclaim takes a range of pages, cleans them, waits for
the IO before moving on. This causes a seeky IO pattern and takes time. Also
causes a nice amount of trashing.

With your patch, lumpy reclaim would just skip over ranges with dirty pages
until it found clean pages in a suitable range. When there is plenty of
usable memore early in the test, it probably scans more but causes less
IO so would appear faster. Later in the test, it scans more but eventually
encounters too many dirty pages and gives up. Hence, its success rates will
be more random because it depends on where exactly the dirty pages were.

If this is accurate, it will always be the case that your patch causes less
disruption in the system and will appear faster due to the lack of IO but
will be less predictable and give up easier so will have lower success
rates when there are dirty pages in the system.

> Effectively we've got two workloads that show results
> at either end of the spectrum (perhaps they are best case vs worst
> case) but there's no real in-between. What other tests can we run to
> get a better picture of the effect?
> 

The underlying workload is only important in how many pages it is
dirtying at any given time. Heck, at one point my test workload was a
single process that created a mapping the size of physical memory and in
test a) would constantly read it and in test b) would constantly write
it. Lumpy reclaim with dirty-page-writeback was always more predictable
and had higher success rates.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
