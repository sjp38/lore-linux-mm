Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 061366B006A
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:56:31 -0400 (EDT)
Date: Mon, 16 Mar 2009 16:56:28 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00/35] Cleanup and optimise the page allocator V3
Message-ID: <20090316165628.GP24293@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <20090316104054.GA23046@wotan.suse.de> <20090316111906.GA6382@csn.ul.ie> <20090316113358.GA30802@wotan.suse.de> <20090316120216.GB6382@csn.ul.ie> <20090316122505.GD30802@wotan.suse.de> <20090316133232.GA24293@csn.ul.ie> <20090316155342.GH30802@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090316155342.GH30802@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 04:53:42PM +0100, Nick Piggin wrote:
> On Mon, Mar 16, 2009 at 01:32:32PM +0000, Mel Gorman wrote:
> > On Mon, Mar 16, 2009 at 01:25:05PM +0100, Nick Piggin wrote:
> > > > Well, buddy always uses the smallest available page first. Even with
> > > > deferred coalescing, it will merge up to order-5 at least. Lets say they
> > > > could have merged up to order-10 in ordinary circumstances, they are
> > > > still avoided for as long as possible. Granted, it might mean that an
> > > > order-5 is split that could have been merged but it's hard to tell how
> > > > much of a difference that makes.
> > > 
> > > But the kinds of pages *you* are interested in are order-10, right?
> > > 
> > 
> > Yes, but my expectation is that multiple free order-5 pages can be
> > merged to make up an order-10.
> 
> Yes, but lazy buddy will give out part of an order-10 free area
> to an order-5 request even when there are genuine order-5,6,7,8,9
> free areas available.
> 

True.

> Now it could be assumed that not too much else in the kernel
> asks for anything over order-3, so you are unlikely to get these
> kinds of requests.

Which is an assumption I was working with.

> But it's worse than that actually, because
> lazy buddy will also split half of an order-10 free area in order
> to satisfy an order-0 allocation in cases that there are no smaller
> orders than 5 available.
> 

Also true. In movable areas it probably makes no difference but it might
if large high-order unmovable allocations were common.

> So yes definitely I think there should be a very real impact on
> higher order coalescing no matter what you do.
> 

Because this is not straight-forward at all, I'll put lazy buddy onto
the back-burner and exhaust all other possibilities before revisiting it
again.

> 
> > If they can't, then lumpy reclaim kicks
> > in as normal. My expectation actually is that order-10 allocations often
> > end up using lumpy reclaim and the pages are not automatically
> > available.
> 
> movable zone is less interesting, although it will make it harder
> to allocate these guys from movable zone. But the pages are
> movable so eventually they should be able to be reclaimed.
> 

Exactly.

> unmovable zone fragmentation is more important point because it
> eventually can destroy the movable zone.
> 

Which is why rmqueue_fallback() also merges up all buddies before making
any decisions but I accept your points. This is hard enough to
mind-experiment with that it should be considered last.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
