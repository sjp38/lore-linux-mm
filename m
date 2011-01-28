Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EB42E8D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 11:46:50 -0500 (EST)
Date: Fri, 28 Jan 2011 16:46:24 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: too big min_free_kbytes
Message-ID: <20110128164624.GA23905@csn.ul.ie>
References: <20110126163655.GU18984@csn.ul.ie> <20110126174236.GV18984@csn.ul.ie> <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110127160301.GA29291@csn.ul.ie> <20110127185215.GE16981@random.random> <20110127213106.GA25933@csn.ul.ie> <4D41FD2F.3050006@redhat.com> <20110128103539.GA14669@csn.ul.ie> <20110128162831.GH16981@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110128162831.GH16981@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 05:28:31PM +0100, Andrea Arcangeli wrote:
> On Fri, Jan 28, 2011 at 10:35:39AM +0000, Mel Gorman wrote:
> > I'd be ok with high+low as a starting point to solve the immediate
> > problem of way too much memory being free and then treat "kswapd must go
> > to sleep" as a separate problem. I'm less keen on 1% but only because it
> > could be too large a value.
> 
> min(1%, low) sounds best to me. Because on the 4G system "low" is likely
> bigger than 1%.
> 

On a 4G system, sure. On a 16G system, the gap is larger than
min_free_kbytes. Granted, in that case it's less of a problem because we
don't have a small higher zone causing problems.

> But really to me it sounds best to apply my first patch and stick to
> the high watermark and remove the gap.
> 
> What is going on is dma zone and pci32 zones are at high+gap. over-4g
> zone is at "high". kswapd keeps running until all are above high. But
> as long as there's at least one not over high, the others are shrunk
> up to high+gap.
> 

Yep, this is why there is an excess of free memory and kswapd stuck in D state
as it's stuck in balance_pgdat().

> The allocator is tought that it should try to always allocate from the
> over4g zone. And the over-4g zone is never below the "low" wmark
> because 100% of the cache is clean so kswapd keeps the normal and dma
> zones at high+gap and the over-4g zone at "high".
> 

A consequence of this is that it's much harder for pages in a small high zone
to get old while kswapd stays awake. They get reclaimed far sooner than pages
in the Normal soon which no doubt leads to some unexpected slowdowns. It's
another reason why we should be making sure kswapd gets to sleep when
there is no pressure.

> In previous email you asked me how kswapd get stuck in D state and
> never stops working, and that it should stop earlier. This sounds
> impossible, kswapd behavior can't possibly change, simply there is
> less memory freed by lowering that "gap".

There might be less memory freed by lowering that gap but it still needs to
exit balance_pgdat() and go to sleep. Otherwise it'll keep freeing zones up
to the high watermark + gap and calling congestion_wait (hence the D state).

> Also you can make the gap as
> big as you want but it'll only make a difference the first time, then
> kswapd will stop shrinking normal and dma zone when they reach
> high+gap. Regardless of the gap size. So kswapd can't possibly change
> behavior and it can't possibly be in D state by just changing this
> "gap" size. Which is why I think the gap should be zero and I'd like
> my first patch to be applied. There's no point to waste ram for a
> feature that can't gaurantee we rotate the zone allocation.
> 

Ok, the gap idea will certainly work in that there will be less memory
freed. It's the first obvious problem and it's the best solution so far.
I will double check myself later if kswapd is stuck in D state due to looping
around balance_pgdat().

> The balancing problem can't be solved in kswapd. It can only be solved
> in the allocator if you really aim to give more rotation to the
> lrus. As long as the "over4g" zone will be allocated first, at some
> point the lrus in the normal/dma zone will have to stop
> rotating. Either that or kswapd will shrink 100% of the ram in
> dma/normal zone which would destroy all the cache which is clearly
> wrong.
> 
> And if you change the allocator to allocate in rotation from the 3
> zones (clearly we would never want to allocate from the dma zone, so
> it's magic area here) there is absolutely no need of any "gap" in
> kswapd to keep the shrinking balanced.
> 

Rotating through the zones is no problem to implement. The expected problem
is that allocations that could use HighMem or Normal instead use DMA32
potentially causing a request that requires DMA32 to fail later.

> In short I think the zone balancing problem tackled in kswapd is wrong
> and kswapd should stick to the high wmark only, and if you care about
> zone balancing it should be done in the allocator only, then kswapd
> will cope with whatever the allocator decides just fine.
> 

Potentially. We'd need to be careful that allocation requests are not getting
stalled but it's worth investigating.

> I guess the LRU caching behavior of a 4g system with a little memory
> over 4g is going to be worse than if you boot with mem=4g and there's
> nothing kswapd can do about it as long as the allocator always grabs
> the new cache page from the highest zone.

Agreed.

> Clearly on a 64bit system
> allocating below 4g may be ok, but on 32bit system allocating in the
> normal zone below 800m must be absolutely avoided. So it's not simple
> problem.

Exactly.

> Personally I never liked per-zone lru because of this. But
> kswapd isn't the solution and it just wastes memory with no benefit
> possible except for the first 5sec when the free memory goes up from
> 170M to 700M and then it remains stuck at 700M while cp runs for
> another 2 hours to read all 500G of hd.
> 

:/

-- 
Mel Gorman
Linux Technology Center
IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
