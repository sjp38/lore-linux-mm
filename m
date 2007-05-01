Message-ID: <46373A71.4030200@shadowen.org>
Date: Tue, 01 May 2007 14:02:41 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: 2.6.22 -mm merge plans -- lumpy reclaim
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070501101651.GA29957@skynet.ie>
In-Reply-To: <20070501101651.GA29957@skynet.ie>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, clameter@sgi.com, y-goto@jp.fujitsu.com, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:

<snip>

>>  lumpy-reclaim-v4.patch
> 
> And I guess this patch also moves here
> 
> lumpy-move-to-using-pfn_valid_within.patch
> 
>> This is in a similar situation to the moveable-zone work.  Sounds great on
>> paper, but it needs considerable third-party testing and review.  It is a
>> major change to core MM and, we hope, a significant advance.  On paper.
> 
> Andy will probably comment more here. Like the fragmentation stuff, we have
> beaten this heavily in tests.

With this stack the basic functionality for Lumpy reclaim is complete.
Better integration with kswapd is desirable, but IMO that should be a
separate change.

In testing it has produced significant improvements the likelyhood of
reclaiming a page (reclaim effectiveness) at very high orders (where the
likelyhood of success is least), and effectiveness at lower orders
should be better again.  In general -mm testing lumpy is triggered for
any stalled allocation above order-0; it is common to see stack
allocations triggering lumpy under higher load.  kswapd also now
utilises lumpy when required.

As Mel has indicated a lot of automated testing has been done on these
patches.  As reclaim is only entered when low on memory, our testing
focuses on triggering pushing the system to a heavily fragmented state
where reclaim is used heavily.  This testing has not shown any
regressions and shows improved effectiveness particularly under load.

Effectiveness for regular reclaim is based on random distributions, as
such it is only likely to successfully reclaim pages at lower orders.
Lumpy reclaim improves on this by actively targeting reclaim on areas at
the orders required and so succeeds at significantly higher order.  Very
high order allocations require better layout, from the mobility patches.

I have some primitive stats patches which we have used performance
testing.  Perhaps those could be brought up to date to provide better
visibility into lumpy's operation.  Again this would be a separate patch.

> I'm not sure of it's review situation.

As lumpy reclaim and grouping-by-mobility are complementary patch sets
(in that they both assist at the highest order) we work pretty closely
and I generally pass all my patches past Mel before general release.
Early versions were based on patches from Peter Zijlstra who also
reviewed earlier versions if memory serves.  The changes since then have
been reviewed by Mel and Andrew Morton only to my knowledge.

Perhaps Peter would have some time to take a look over the latest stack
as it appears in -mm when that releases; ping me for a patch kit if you
want it before then :).

<snip>

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
