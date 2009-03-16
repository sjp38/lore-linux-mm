Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9D06B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 09:32:36 -0400 (EDT)
Date: Mon, 16 Mar 2009 13:32:32 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00/35] Cleanup and optimise the page allocator V3
Message-ID: <20090316133232.GA24293@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <20090316104054.GA23046@wotan.suse.de> <20090316111906.GA6382@csn.ul.ie> <20090316113358.GA30802@wotan.suse.de> <20090316120216.GB6382@csn.ul.ie> <20090316122505.GD30802@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090316122505.GD30802@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 01:25:05PM +0100, Nick Piggin wrote:
> On Mon, Mar 16, 2009 at 12:02:17PM +0000, Mel Gorman wrote:
> > On Mon, Mar 16, 2009 at 12:33:58PM +0100, Nick Piggin wrote:
> > > Wheras if you defer this until the point you need a higher order
> > > page, the only thing you have to work with are the pages that are
> > > free *right now*.
> > > 
> > 
> > Well, buddy always uses the smallest available page first. Even with
> > deferred coalescing, it will merge up to order-5 at least. Lets say they
> > could have merged up to order-10 in ordinary circumstances, they are
> > still avoided for as long as possible. Granted, it might mean that an
> > order-5 is split that could have been merged but it's hard to tell how
> > much of a difference that makes.
> 
> But the kinds of pages *you* are interested in are order-10, right?
> 

Yes, but my expectation is that multiple free order-5 pages can be
merged to make up an order-10. If they can't, then lumpy reclaim kicks
in as normal. My expectation actually is that order-10 allocations often
end up using lumpy reclaim and the pages are not automatically
available.

As it is though, I have done something wrong and success rates have dropped
where they were ok 10 days ago. I need to investigate further but as the
first cut-off point at 25 patches is before the lazy buddy patch, it's not
an immediate problem.

>  
> > > Your anti-frag tests probably don't stress this long term fragmentation
> > > problem.
> > > 
> > 
> > Probably not, but we have little data on long-term fragmentation other than
> > anecdotal evidence that it's ok these days.
> 
> Well, I think before anti-frag there was lots of anecdotal evidence
> that it's "ok", except for loads heavily using large higher order
> allocations. I don't know if we'd have many systems running with
> hundreds of days of uptime on such workloads post-anti-frag? 
> 

I doubt it. I probably won't see proper reports on how it behaves until
it's part of a major distro release.

> Google might? But I don't know how long their uptimes are. I expect
> we'd have a better idea in a couple more years after the next
> enterprise distro release cycles with anti-frag.
> 

Exactly.

>  
> > > Still, it's significant enough that I think it should be made
> > > optional (and arguably default to on) even if it does harm higher
> > > order allocations a bit.
> > > 
> > 
> > I could make PAGE_ORDER_MERGE_ORDER a proc tunable? If it's placed as a
> > read-mostly variable beside the gfp_zone table, it might even fit in the
> > same cache line.
> 
> Hmm, possibly. OTOH I don't like tunables.

Neither do I, but in this case it would make it easier to test where the
proper cut-off point is without requiring kernel recompiles and make a
final static decision later.

> If you don't think it will
> be a problem for hugepage allocations, then I would prefer just to
> leave it on and 5 by default (or even less? COSTLY_ORDER?)
> 

I went with 5 because it means we merge up to at least the size the pcp->batch
size. As the page allocator gives back pages in contiguous order if a buddy
split occured, it made sense that pcp batch refills are contiguous where
possible.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
