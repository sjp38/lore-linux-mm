Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4018F8D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:34:49 -0500 (EST)
Date: Fri, 28 Jan 2011 18:34:21 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110128173421.GL16981@random.random>
References: <20110126174236.GV18984@csn.ul.ie>
 <20110127134057.GA32039@csn.ul.ie>
 <20110127152755.GB30919@random.random>
 <20110127160301.GA29291@csn.ul.ie>
 <20110127185215.GE16981@random.random>
 <20110127213106.GA25933@csn.ul.ie>
 <4D41FD2F.3050006@redhat.com>
 <20110128103539.GA14669@csn.ul.ie>
 <20110128162831.GH16981@random.random>
 <20110128164624.GA23905@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110128164624.GA23905@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 04:46:24PM +0000, Mel Gorman wrote:
> On Fri, Jan 28, 2011 at 05:28:31PM +0100, Andrea Arcangeli wrote:
> > On Fri, Jan 28, 2011 at 10:35:39AM +0000, Mel Gorman wrote:
> > > I'd be ok with high+low as a starting point to solve the immediate
> > > problem of way too much memory being free and then treat "kswapd must go
> > > to sleep" as a separate problem. I'm less keen on 1% but only because it
> > > could be too large a value.
> > 
> > min(1%, low) sounds best to me. Because on the 4G system "low" is likely
> > bigger than 1%.
> > 
> 
> On a 4G system, sure. On a 16G system, the gap is larger than
> min_free_kbytes. Granted, in that case it's less of a problem because we
> don't have a small higher zone causing problems.

Agreed, there I also prefer the low wmark ;).

> Yep, this is why there is an excess of free memory and kswapd stuck in D state
> as it's stuck in balance_pgdat().

kswapd in the "cp /dev/sda /dev/null" workload can't possibly be stuck
in D state at any given tiem. There's no I/O it has to do, it's 100%
clean cache. It's always in S or R state. But every time it gets waken
up when the over4g zone hits the low wmark, it shrinks the over4g
until it's over "high" and also until all below zones are
"high+gap". So in 5 sec what happens is the other zones are stuck at
"high+gap" and it stops shrinking them forever, and it only keeps the
over-4g zone from "low" to "high", because the allocator picks always
from the over4g zone.

> A consequence of this is that it's much harder for pages in a small high zone
> to get old while kswapd stays awake. They get reclaimed far sooner than pages
> in the Normal soon which no doubt leads to some unexpected slowdowns. It's
> another reason why we should be making sure kswapd gets to sleep when
> there is no pressure.

The problem it's not kswapd, it's the allocator. There's nothing
kswapd can do about it. kswapd has no fatigue in shrinking any zone,
it's all 100% clean immediately reclaimable cache, we could shrink it
even from GFP_ATOMIC context from irq (just not nmi) if we wanted.

> There might be less memory freed by lowering that gap but it still needs to
> exit balance_pgdat() and go to sleep. Otherwise it'll keep freeing zones up
> to the high watermark + gap and calling congestion_wait (hence the D state).

I just can't see how the size of the "gap" can make any difference, 0
gap or 1g gap, the only thing that will change is the amount of memory
free you see, the kswapd state not.

> Ok, the gap idea will certainly work in that there will be less memory
> freed. It's the first obvious problem and it's the best solution so far.
> I will double check myself later if kswapd is stuck in D state due to looping
> around balance_pgdat().

I'll check that too, but I don't see how the gap can affect that.

Setting the gap to 600M with high set to 100M, is like setting high to
700M manually for that zone and eliminate the gap. Only thing that
changes is the behavior of min_free_kbytes.

> Rotating through the zones is no problem to implement. The expected problem
> is that allocations that could use HighMem or Normal instead use DMA32
> potentially causing a request that requires DMA32 to fail later.

Exactly. Note the lowmem reserve ratio algorithm exists exactly to
reserve a portion of memory to the users of the lowmem
zones. Otherwise things go bad when all memory is free. So thanks to
the lowmem reserve ratio algorithm, it's less of an issue to rotate
across the zones. But it's a separate issue.

> > I guess the LRU caching behavior of a 4g system with a little memory
> > over 4g is going to be worse than if you boot with mem=4g and there's
> > nothing kswapd can do about it as long as the allocator always grabs
> > the new cache page from the highest zone.
> 
> Agreed.
> 
> > Clearly on a 64bit system
> > allocating below 4g may be ok, but on 32bit system allocating in the
> > normal zone below 800m must be absolutely avoided. So it's not simple
> > problem.
> 
> Exactly.

Full agreement here.

As said above it is very possible the lowmem reserve ratio is enough
and we can now rotate freely across the zones. The lowmem reserve
ratio is already tuned in a way that on a 32G x86_32 all the normal
zone will be forbidden. It scales down as the ratio between the
highemm vs normal zone goes down. On a 1g system most of the normal
zone becomes available also for highmem allocations. It's made exactly
for that.

If we want to tackle this later we can and we can try to depend
entirely on the lowmem reserve ratio to do the right thing at
allocation time by making all wmark variable depending on who's
allocating what, but kswapd should just stick to "high" IMHO and gap
0.

However if I'm proven wrong then I'm also ok with min(1%, low), no
problem with me. Once we fix this (either with gap 0 or gap
min(1%,low)), running -set-recommended-min_free_kbytes should lead to
less memory wasted (in the 4g setup with a little memory over 4g) then
before running -set-recommended-min_free_kbytes at boot.

> > Personally I never liked per-zone lru because of this. But
> > kswapd isn't the solution and it just wastes memory with no benefit
> > possible except for the first 5sec when the free memory goes up from
> > 170M to 700M and then it remains stuck at 700M while cp runs for
> > another 2 hours to read all 500G of hd.
> > 
> 
> :/

;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
