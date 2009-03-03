Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 137736B0087
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 16:48:46 -0500 (EST)
Date: Tue, 3 Mar 2009 21:48:42 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
Message-ID: <20090303214842.GL10577@csn.ul.ie>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie> <1235639427.11390.11.camel@minggr> <20090226110336.GC32756@csn.ul.ie> <1235647139.16552.34.camel@penberg-laptop> <20090226112232.GE32756@csn.ul.ie> <1235724283.11610.212.camel@minggr> <20090302112122.GC21145@csn.ul.ie> <alpine.DEB.1.10.0903031130550.26454@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903031130550.26454@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Lin Ming <ming.m.lin@intel.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 03, 2009 at 11:31:46AM -0500, Christoph Lameter wrote:
> On Mon, 2 Mar 2009, Mel Gorman wrote:
> 
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
> 
> Then we are increasing the number of queues dramatically in the page
> allocator. More of a memory sink. Less cache hotness.
> 

It doesn't have to be more queues and networking is doing order-1 allocations
based on a quick instrumentation so we might be justified in doing this to
avoid contending excessively on the zone lock.

Without the patchset, we do a search of the pcp lists for a page of the
appropriate migrate type. There is a patch that removes this search at
the cost of one cache line per CPU and it works reasonably well.

However, if the search was left in place, you can add pages of other orders
and just search for those which should be a lot less costly. Yes, the search
is unfortunate but you avoid acquiring the zone lock without increasing
the size of the per-cpu structure. The search will require cache lines it's
probably less than acquiring teh zone lock and going through the whole buddy
allocator for order-1 pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
