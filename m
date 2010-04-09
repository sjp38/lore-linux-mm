Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 504916B0205
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 06:51:50 -0400 (EDT)
Date: Fri, 9 Apr 2010 11:51:27 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 56 of 67] Memory compaction core
Message-ID: <20100409105127.GK25756@csn.ul.ie>
References: <patchbomb.1270691443@v2.random> <a86f1d01d86dffb4ab53.1270691499@v2.random> <20100408161814.GC28964@cmpxchg.org> <20100408164630.GL5749@random.random> <20100408170948.GQ5749@random.random> <20100408171458.GS5749@random.random> <20100408175604.GD28964@cmpxchg.org> <20100408175847.GV5749@random.random> <20100408184842.GE28964@cmpxchg.org> <20100408212332.GD5749@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100408212332.GD5749@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 08, 2010 at 11:23:32PM +0200, Andrea Arcangeli wrote:
> On Thu, Apr 08, 2010 at 08:48:42PM +0200, Johannes Weiner wrote:
> > On Thu, Apr 08, 2010 at 07:58:47PM +0200, Andrea Arcangeli wrote:
> > > On Thu, Apr 08, 2010 at 07:56:04PM +0200, Johannes Weiner wrote:
> > > > Humm, maybe the start pfn could be huge page aligned?  That would make
> > > > it possible to check for PageTransHuge() and skip over compound_order()
> > > > pages.  This way, we should never actually run into PG_tail pages.
> > > 
> > > The problem here are random compound pages that aren't owned by the
> > > transparent hugepage subsystem. If we can't identify those, it's
> > > unsafe to call compound_order (like it's unsafe to call page_order for
> > > pagebuddy pages).
> > 
> > But transparent huge pages are the only compound pages on the LRU, so
> > we should be able to identify them.
> > 
> > The lru_lock excludes isolation, splitting and collapsing, so I think
> > this is safe:
> > 
> > 	if (PageLRU() && PageTransCompound()) {
> > 		low_pfn += (1 << compound_order()) - 1
> > 		continue
> > 	}
> > 
> > 	if (__isolate_lru_page())
> > 		continue
> > 
> > 	...
> 
> I don't see anything wrong with this. You're right lru_lock excludes
> isolation, splitting and collapsing (collapsing if it's pagelru it
> means it already happened).
> 
> Thanks for thinking this optimization in detail. I guess retaining the
> other optimization will be harder. It depends how costly it is to take
> the zone->lock, the main annoyance is that we can only do that if we
> release the lru_lock first or we get lock inversion deadlocks.

I would find it very difficult to justify the cost of dropping one lock
and taking the other myself. It's potentially stalling other allocators for
order-0 pages (i.e. per-cpu refill) so that direct compaction for high-order
pages can go very slightly faster. 

> So it
> costs 4 locked ops to skip max 1024 pages (but in average it'll be
> much less than 1024 pages, more like 128 [no math just random guess]
> when there's quite some ram free).
> 

4 irq-safe locked ops. I don't know off-hand what the cycle cost of disabling
and enabling IRQs is but I'd expect it to be longer than what it takes to
scan over a few pages.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
