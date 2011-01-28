Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C36988D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 11:29:06 -0500 (EST)
Date: Fri, 28 Jan 2011 17:28:31 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110128162831.GH16981@random.random>
References: <20110126154203.GS926@random.random>
 <20110126163655.GU18984@csn.ul.ie>
 <20110126174236.GV18984@csn.ul.ie>
 <20110127134057.GA32039@csn.ul.ie>
 <20110127152755.GB30919@random.random>
 <20110127160301.GA29291@csn.ul.ie>
 <20110127185215.GE16981@random.random>
 <20110127213106.GA25933@csn.ul.ie>
 <4D41FD2F.3050006@redhat.com>
 <20110128103539.GA14669@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110128103539.GA14669@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 10:35:39AM +0000, Mel Gorman wrote:
> I'd be ok with high+low as a starting point to solve the immediate
> problem of way too much memory being free and then treat "kswapd must go
> to sleep" as a separate problem. I'm less keen on 1% but only because it
> could be too large a value.

min(1%, low) sounds best to me. Because on the 4G system "low" is likely
bigger than 1%.

But really to me it sounds best to apply my first patch and stick to
the high watermark and remove the gap.

What is going on is dma zone and pci32 zones are at high+gap. over-4g
zone is at "high". kswapd keeps running until all are above high. But
as long as there's at least one not over high, the others are shrunk
up to high+gap.

The allocator is tought that it should try to always allocate from the
over4g zone. And the over-4g zone is never below the "low" wmark
because 100% of the cache is clean so kswapd keeps the normal and dma
zones at high+gap and the over-4g zone at "high".

In previous email you asked me how kswapd get stuck in D state and
never stops working, and that it should stop earlier. This sounds
impossible, kswapd behavior can't possibly change, simply there is
less memory freed by lowering that "gap". Also you can make the gap as
big as you want but it'll only make a difference the first time, then
kswapd will stop shrinking normal and dma zone when they reach
high+gap. Regardless of the gap size. So kswapd can't possibly change
behavior and it can't possibly be in D state by just changing this
"gap" size. Which is why I think the gap should be zero and I'd like
my first patch to be applied. There's no point to waste ram for a
feature that can't gaurantee we rotate the zone allocation.

The balancing problem can't be solved in kswapd. It can only be solved
in the allocator if you really aim to give more rotation to the
lrus. As long as the "over4g" zone will be allocated first, at some
point the lrus in the normal/dma zone will have to stop
rotating. Either that or kswapd will shrink 100% of the ram in
dma/normal zone which would destroy all the cache which is clearly
wrong.

And if you change the allocator to allocate in rotation from the 3
zones (clearly we would never want to allocate from the dma zone, so
it's magic area here) there is absolutely no need of any "gap" in
kswapd to keep the shrinking balanced.

In short I think the zone balancing problem tackled in kswapd is wrong
and kswapd should stick to the high wmark only, and if you care about
zone balancing it should be done in the allocator only, then kswapd
will cope with whatever the allocator decides just fine.

I guess the LRU caching behavior of a 4g system with a little memory
over 4g is going to be worse than if you boot with mem=4g and there's
nothing kswapd can do about it as long as the allocator always grabs
the new cache page from the highest zone. Clearly on a 64bit system
allocating below 4g may be ok, but on 32bit system allocating in the
normal zone below 800m must be absolutely avoided. So it's not simple
problem. Personally I never liked per-zone lru because of this. But
kswapd isn't the solution and it just wastes memory with no benefit
possible except for the first 5sec when the free memory goes up from
170M to 700M and then it remains stuck at 700M while cp runs for
another 2 hours to read all 500G of hd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
