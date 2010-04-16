Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 582406B01F3
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:14:28 -0400 (EDT)
Date: Fri, 16 Apr 2010 16:14:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100416151403.GM19264@csn.ul.ie>
References: <20100413202021.GZ13327@think> <20100414014041.GD2493@dastard> <20100414155233.D153.A69D9226@jp.fujitsu.com> <20100414072830.GK2493@dastard> <20100414085132.GJ25756@csn.ul.ie> <20100415013436.GO2493@dastard> <20100415102837.GB10966@csn.ul.ie> <20100416041412.GY2493@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100416041412.GY2493@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2010 at 02:14:12PM +1000, Dave Chinner wrote:
> On Thu, Apr 15, 2010 at 11:28:37AM +0100, Mel Gorman wrote:
> > On Thu, Apr 15, 2010 at 11:34:36AM +1000, Dave Chinner wrote:
> > > On Wed, Apr 14, 2010 at 09:51:33AM +0100, Mel Gorman wrote:
> > > If you ask it to clean a bunch of pages around the one you want to
> > > reclaim on the LRU, there is a good chance it will also be cleaning
> > > pages that are near the end of the LRU or physically close by as
> > > well. It's not a guarantee, but for the additional IO cost of about
> > > 10% wall time on that IO to clean the page you need, you also get
> > > 1-2 orders of magnitude other pages cleaned. That sounds like a
> > > win any way you look at it...
> > 
> > At worst, it'll distort the LRU ordering slightly. Lets say the the
> > file-adjacent-page you clean was near the end of the LRU. Before such a
> > patch, it may have gotten cleaned and done another lap of the LRU.
> > After, it would be reclaimed sooner. I don't know if we depend on such
> > behaviour (very doubtful) but it's a subtle enough change. I can't
> > predict what it'll do for IO congestion. Simplistically, there is more
> > IO so it's bad but if the write pattern is less seeky and we needed to
> > write the pages anyway, it might be improved.
> 
> Fundamentally, we have so many pages on the LRU, getting a few out
> of order at the back end of it is going to be in the noise. If we
> trade off "perfect" LRU behaviour for cleaning pages an order of

haha, I don't think anyone pretends the LRU behaviour is perfect.
Altering its existing behaviour tends to be done with great care but
from what I gather that is often a case of "better the devil you know".

> magnitude faster, reclaim will find candidate pages for a whole lot
> faster. And if we have more clean pages available, faster, overall
> system throughput is going to improve and be much less likely to
> fall into deep, dark holes where the OOM-killer is the light at the
> end.....
> 
> [ snip questions Chris answered ]
> 
> > > what I'm
> > > pointing out is that the arguments that it is too hard or there are
> > > no interfaces available to issue larger IO from reclaim are not at
> > > all valid.
> > > 
> > 
> > Sure, I'm not resisting fixing this, just your first patch :) There are four
> > goals here
> > 
> > 1. Reduce stack usage
> > 2. Avoid the splicing of subsystem stack usage with direct reclaim
> > 3. Preserve lumpy reclaims cleaning of contiguous pages
> > 4. Try and not drastically alter LRU aging
> > 
> > 1 and 2 are important for you, 3 is important for me and 4 will have to
> > be dealt with on a case-by-case basis.
> 
> #4 is important to me, too, because that has direct impact on large
> file IO workloads. however, it is gross changes in behaviour that
> concern me, not subtle, probably-in-the-noise changes that you're
> concerned about. :)
> 

I'm also less concerned with this aspect. I brought it up because it was
a factor. I don't think it'll cause us problems but if problems do
arise, it's nice to have a few potential candidates to examine in
advance.

> > Your patch fixes 2, avoids 1, breaks 3 and haven't thought about 4 but I
> > guess dirty pages can cycle around more so it'd need to be cared for.
> 
> Well, you keep saying that they break #3, but I haven't seen any
> test cases or results showing that. I've been unable to confirm that
> lumpy reclaim is broken by disallowing writeback in my testing, so
> I'm interested to know what tests you are running that show it is
> broken...
> 

Ok, I haven't actually tested this. The machines I use are tied up
retesting the compaction patches at the moment. The reason why I reckon
it'll be a problem is that when these sync-writeback changes were
introduced, it significantly helped lumpy reclaim for huge pages. I am
making an assumption that backing out those changes will hurt it.

I'll test for real on Monday and see what falls out.

> > > How about this? For now, we stop direct reclaim from doing writeback
> > > only on order zero allocations, but allow it for higher order
> > > allocations. That will prevent the majority of situations where
> > > direct reclaim blows the stack and interferes with background
> > > writeout, but won't cause lumpy reclaim to change behaviour.
> > > This reduces the scope of impact and hence testing and validation
> > > the needs to be done.
> > > 
> > > Then we can work towards allowing lumpy reclaim to use background
> > > threads as Chris suggested for doing specific writeback operations
> > > to solve the remaining problems being seen. Does this seem like a
> > > reasonable compromise and approach to dealing with the problem?
> > > 
> > 
> > I'd like this to be plan b (or maybe c or d) if we cannot reduce stack usage
> > enough or come up with an alternative fix. From the goals above it mitigates
> > 1, mitigates 2, addresses 3 but potentially allows dirty pages to remain on
> > the LRU with 4 until the background cleaner or kswapd comes along.
> 
> We've been through this already, but I'll repeat it again in the
> hope it sinks in: reducing stack usage is not sufficient to stay
> within an 8k stack if we can enter writeback with an arbitrary
> amount of stack already consumed.
> 
> We've already got a report of 9k of stack usage (7200 bytes left on
> a order-2 stack) and this is without a complex storage stack - it's
> just a partition on a SATA drive. We can easily add another 1k,
> possibly 2k to that stack depth with a complex storage subsystem.
> Trimming this much (3-4k) is simply not feasible in a callchain that
> is 50-70 functions deep...
> 

Ok, based on this, I'll stop working on the stack-reduction patches.
I'll test what I have and push it but I won't bring it further for the
moment and instead look at putting writeback into its own thread. If
someone else works on it in the meantime, I'll review and test from the
perspective of lumpy reclaim.

> > One reason why I am edgy about this is that lumpy reclaim can kick in
> > for low-enough orders too like order-1 pages for stacks in some cases or
> > order-2 pages for network cards using jumbo frames or some wireless
> > cards. The network cards in particular could still cause the stack
> > overflow but be much harder to reproduce and detect.
> 
> So push lumpy reclaim into a separate thread. It already blocks, so
> waiting for some other thread to do the work won't change anything.

No, it wouldn't. As long as it can wait on the right pages, it doesn't
really matter who does the work.

> Separating high-order reclaim from LRU reclaim is probably a good
> idea, anyway - they use different algorithms and while the two are
> intertwined it's hard to optimise/improve either....
> 

They are not a million miles apart either. Lumpy reclaim uses the LRU to
select a cursor page and then reclaims around it. Improvements on LRU tend
to help lumpy reclaim as well. It's why during the tests I run I can often
allocate 80-95% of memory as huge pages on x86-64 as opposed to when anti-frag
was being developed first where getting 30% was a cause for celebration :)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
