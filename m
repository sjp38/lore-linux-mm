Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB6E6B0044
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 13:52:43 -0500 (EST)
Date: Fri, 27 Nov 2009 18:52:34 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH-RFC] cfq: Disable low_latency by default for 2.6.32
Message-ID: <20091127185234.GQ13095@csn.ul.ie>
References: <20091126121945.GB13095@csn.ul.ie> <4e5e476b0911260547r33424098v456ed23203a61dd@mail.gmail.com> <20091126141738.GE13095@csn.ul.ie> <4e5e476b0911260718h35fab3b1hc63587b23c02d43f@mail.gmail.com> <20091127114450.GK13095@csn.ul.ie> <4e5e476b0911270403n1387dcdco6a36e5923b8e04bc@mail.gmail.com> <20091127155841.GM13095@csn.ul.ie> <4e5e476b0911271014k1d507a02o60c11723948dcfa@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4e5e476b0911271014k1d507a02o60c11723948dcfa@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Corrado Zoccolo <czoccolo@gmail.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 27, 2009 at 07:14:41PM +0100, Corrado Zoccolo wrote:
> On Fri, Nov 27, 2009 at 4:58 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Fri, Nov 27, 2009 at 01:03:29PM +0100, Corrado Zoccolo wrote:
> >> On Fri, Nov 27, 2009 at 12:44 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > How would one go about selecting the proper ratio at which to disable
> > the low_latency logic?
>
> Can we measure the dirty ratio when the allocation failures start to happen?
> 

Would the number of dirty pages in the page allocation failure message to
kern.log be enough? You won't get them all because of printk suppress but
it's something. Alternatively, tell me exactly what stats from /proc you
want and I'll stick a monitor on there. Assuming you want nr_dirty vs total
number of pages though, the monitor tends to execute too late to be useful.

> >> >
> >> > I haven't tested the high-order allocation scenario yet but the results
> >> > as thing stands are below. There are four kernels being compared
> >> >
> >> > 1. with-low-latency               is 2.6.32-rc8 vanilla
> >> > 2. with-low-latency-block-2.6.33  is with the for-2.6.33 from linux-block applied
> >> > 3. with-low-latency-async-rampup  is with "[RFC,PATCH] cfq-iosched: improve async queue ramp up formula"
> >> > 4. without-low-latency            is with low_latency disabled
> >> >
> >> > desktop-net-gitk
> >> >                     gitk-with       low-latency       low-latency      gitk-without
> >> >                   low-latency      block-2.6.33      async-rampup       low-latency
> >> > min            954.46 ( 0.00%)   570.06 (40.27%)   796.22 (16.58%)   640.65 (32.88%)
> >> > mean           964.79 ( 0.00%)   573.96 (40.51%)   798.01 (17.29%)   655.57 (32.05%)
> >> > stddev          10.01 ( 0.00%)     2.65 (73.55%)     1.91 (80.95%)    13.33 (-33.18%)
> >> > max            981.23 ( 0.00%)   577.21 (41.17%)   800.91 (18.38%)   675.65 (31.14%)
> >> >
> >> > The changes for block in 2.6.33 make a massive difference here, notably
> >> > beating the disabling of low_latency.
> >>
> > I did a quick test for when high-order-atomic-allocations-for-network
> > are happening but the results are not great. By quick test, I mean I
> > only did the gitk tests as there wasn't time to do the sysbench and
> > iozone tests as well before I'd go offline.
> >
> > desktop-net-gitk
> >                     high-with       low-latency       low-latency      high-without
> >                   low-latency      block-2.6.33      async-rampup       low-latency
> > min            861.03 ( 0.00%)   467.83 (45.67%)  1185.51 (-37.69%)   303.43 (64.76%)
> > mean           866.60 ( 0.00%)   616.28 (28.89%)  1201.82 (-38.68%)   459.69 (46.96%)
> > stddev           4.39 ( 0.00%)    86.90 (-1877.46%)    23.63 (-437.75%)    92.75 (-2010.76%)
> > max            872.56 ( 0.00%)   679.36 (22.14%)  1242.63 (-42.41%)   537.31 (38.42%)
> > pgalloc-fail       25 ( 0.00%)       10 (50.00%)       39 (-95.00%)       20 ( 0.00%)
> >
> > The patches for 2.6.33 help a little all right but the async-rampup
> > patches both make the performance worse and causes more page allocation
> > failures to occur. In other words, on most machines it'll appear fine
> > but people with wireless cards doing high-order allocations may run into
> > trouble.
> >
> > Disabling low_latency again helps performance significantly in this
> > scenario. There were still page allocation failures because not all the
> > patches related to that problem made it to mainline.
>
> I'm puzzled how almost all kernels, excluding the async rampup,
> perform better when high order allocations are enabled, than in
> previous test.
> 

Two major differences. 1, the previous non-high-order tests had also
run sysbench and iozone so the starting conditions are different. I had
disabled those tests to get some of the high-order figures before I went
offline. However, the starting conditions are probably not as important as
the fact that kswapd is working to free order-2 pages and staying awake
until watermarks are reached. kswapd working harder is probably making a
big difference.

> > I was somewhat aggrevated by the page allocation failures until I remembered
> > that there are three patches in -mm that I failed to convince either Jens or
> > Andrew of them being suitable for mainline. When they are added to the mix,
> > the results are as follows;
> >
> > desktop-net-gitk
> >                  atomics-with       low-latency       low-latency   atomics-without
> >                   low-latency      block-2.6.33      async-rampup       low-latency
> > min            641.12 ( 0.00%)   627.91 ( 2.06%)  1254.75 (-95.71%)   375.05 (41.50%)
> > mean           743.61 ( 0.00%)   631.20 (15.12%)  1272.70 (-71.15%)   389.71 (47.59%)
> > stddev          60.30 ( 0.00%)     2.53 (95.80%)    10.64 (82.35%)    22.38 (62.89%)
> > max            793.85 ( 0.00%)   633.76 (20.17%)  1281.65 (-61.45%)   428.41 (46.03%)
> > pgalloc-fail        3 ( 0.00%)        2 ( 0.00%)       23 ( 0.00%)        0 ( 0.00%)
> >
>
> Those patches penalize block-2.6.33, that was the one with lowest
> number of failures in previous test.
> I think the heuristics were tailored to 2.6.32. They need to be
> re-tuned for 2.6.33.
> 

I made a mistake in the script that was generating the summary. I neglected to
take into account printk rate suppressions. When they are taken into account,
the first round of figures look like

desktop-net-gitk
                     high-with       low-latency       low-latency      high-without
                   low-latency      block-2.6.33      async-rampup       low-latency
min            861.03 ( 0.00%)   467.83 (45.67%)  1185.51 (-37.69%)   303.43 (64.76%)
mean           866.60 ( 0.00%)   616.28 (28.89%)  1201.82 (-38.68%)   459.69 (46.96%)
stddev           4.39 ( 0.00%)    86.90 (-1877.46%)    23.63 (-437.75%)    92.75 (-2010.76%)
max            872.56 ( 0.00%)   679.36 (22.14%)  1242.63 (-42.41%)   537.31 (38.42%)
pgalloc-fail       65 ( 0.00%)       10 (84.62%)      293 (-350.77%)       20 (69.23%)

So the async-rampup is getting smacked very hard with allocation failures
in the high-order case. With the three additional applied for allocation
failures, the figures look like

desktop-net-gitk
                  atomics-with       low-latency       low-latency   atomics-without
                   low-latency      block-2.6.33      async-rampup       low-latency
min            641.12 ( 0.00%)   627.91 ( 2.06%)  1254.75 (-95.71%)   375.05 (41.50%)
mean           743.61 ( 0.00%)   631.20 (15.12%)  1272.70 (-71.15%)   389.71 (47.59%)
stddev          60.30 ( 0.00%)     2.53 (95.80%)    10.64 (82.35%)    22.38 (62.89%)
max            793.85 ( 0.00%)   633.76 (20.17%)  1281.65 (-61.45%)   428.41 (46.03%)
pgalloc-fail        3 ( 0.00%)        2 ( 0.00%)       27 ( 0.00%)        0 ( 0.00%)

So again, async-rampup is getting smacked in terms of allocation failures
although the three additional patches help a lot. This is a real pity
because it looked nice in the tests involving no high-order allocations for
the network.

> > Again, plain old disabling low_latency both performs the best and fails page
> > allocations the least. The three patches for page allocation failures are
> > in -mm but not mainline are;
> >
> > [PATCH 3/5] page allocator: Wait on both sync and async congestion after direct reclaim
> > [PATCH 4/5] vmscan: Have kswapd sleep for a short interval and double check it should be asleep
> > [PATCH 5/5] vmscan: Take order into consideration when deciding if kswapd is in trouble
> >
> > It still seems to be that the route of least damage is to disable low_latency
> > by default for 2.6.32. It's very unfortunate that I wasn't able to fully
> > justify the 3 patches for page allocation failures in time but all that
> > can be done there is consider them for -stable I suppose.
> 
> Just disabling low_latency will not solve the allocation issues (20
> instead of 25).

20 instead of 65 and I know it doesn't fully help the problem with
high-order allocations. The patches that do help that problem aren't in
mainline but they do exist.

> Moreover, it will improve some workloads, but penalize others.
> 

It really does appear to hurt a lot when the machine is kinda low on
memory though. That is a fairly common situation with a desktop loaded
up with random apps. Well..... by common, I mean I hit that situation a
lot on my laptop. I don't hit it on server workloads because I make sure
the machines are not overloaded.

> Your 3 patches, though, seem to improve the situation also for
> low_latency enabled, both for performance and allocation failures (25
> to 3). Having those 3 patches with low_latency enabled seems better,
> since it won't penalize the workloads that are benefited by
> low_latency (if you add a sequential read to your test, you should see
> a big difference).
> 

This is true and I would like to see them merged. However, this close to
release, with Jens unhappiness with the explanation of why
congestion_wait() changes made a difference and Andrew feeling there
wasn't enough cause to merge them, I'm doubtful it'll happen. Will see
Monday what the story is.


-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
