Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D15826B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 14:00:33 -0500 (EST)
Date: Thu, 18 Nov 2010 20:00:23 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/8] mm: migration: Allow migration to operate
 asynchronously and avoid synchronous compaction in the faster path
Message-ID: <20101118190023.GE30376@random.random>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
 <1290010969-26721-5-git-send-email-mel@csn.ul.ie>
 <20101118182105.GB30376@random.random>
 <20101118183437.GP8135@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118183437.GP8135@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 06:34:38PM +0000, Mel Gorman wrote:
> On Thu, Nov 18, 2010 at 07:21:06PM +0100, Andrea Arcangeli wrote:
> > On Wed, Nov 17, 2010 at 04:22:45PM +0000, Mel Gorman wrote:
> > > @@ -484,6 +486,7 @@ static unsigned long compact_zone_order(struct zone *zone,
> > >  		.order = order,
> > >  		.migratetype = allocflags_to_migratetype(gfp_mask),
> > >  		.zone = zone,
> > > +		.sync = false,
> > >  	};
> > >  	INIT_LIST_HEAD(&cc.freepages);
> > >  	INIT_LIST_HEAD(&cc.migratepages);
> > 
> > I like this because I'm very afraid to avoid wait-I/O latencies
> > introduced into hugepage allocations that I prefer to fail quickly and
> > be handled later by khugepaged ;).
> > 
> 
> As you can see from the graphs in the leader, it makes a big difference to
> latency as well to avoid sync migration where possible.

Yep, amazing benchmarking work you did! Great job indeed.

I thought of this sync wait in migrate myself as being troublesome a
few days ago as I was reviewing the btrfs migration bug that I helped
track down this week (triggering only with THP because it exercises
compaction and in turn migration more often than upstream, it's rare
to get any order > 4 allocation with upstream that would exercise
compaction and trip on the btrfs fs corruption, it really had nothing
to do with THP as I expected).

> We could pass gfp flags in I guess and abuse __GFP_NO_KSWAPD (from the THP
> series obviously)?

That would work for me... :)

> Yes, it's the "slower" path where we've already reclaim pages and more
> willing to wait for the compaction to occur as the alternative is failing
> the allocation.

I've noticed, which is why I think it's equivalent to invoking the
second try_to_compact_pages with (fast_scan=false, sync=true) (and the
first of course with (fast_scan=true, sync=false)).

> I'll think about it more. I could just leave it at try_to_compact_pages
> doing the zonelist scan although it's not immediately occuring to me how I
> should decide between sync and async other than "async the first time and
> sync after that". The allocator does not have the same "reclaim priority"
> awareness that reclaim does.

I think the "migrate async & fast scan first, migrate sync and full
scan later" is a simpler heuristic we can do and I expect it to work
fine and equivalent (if not better).

I'm undecided if it worth to run the hugepage page fault with "async &
fast scan always" by abusing __GFP_NO_KSWAPD or by adding a
__GFP_COMPACT_FAST. Of course it would only make a difference mostly
if the hugepage allocation has to fail often (like 95% of ram in
hugepages with slab spread over 10% of ram) so that is a corner case
that not everybody experiences... Probably not worth it.

Increasing nr_to_reclaim to 1<<order only when the compaction_suitable
checks are not satisfied and compaction becomes a noop, may also be
worth investigating (as long as there are enough cond_resched() inside
those loops ;). But hey I'm not sure if it's really needed...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
