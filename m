Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 16A088D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:47:11 -0500 (EST)
Date: Fri, 28 Jan 2011 18:46:44 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110128174644.GM16981@random.random>
References: <20110127134057.GA32039@csn.ul.ie>
 <20110127152755.GB30919@random.random>
 <20110127160301.GA29291@csn.ul.ie>
 <20110127185215.GE16981@random.random>
 <20110127213106.GA25933@csn.ul.ie>
 <4D41FD2F.3050006@redhat.com>
 <20110128103539.GA14669@csn.ul.ie>
 <20110128162831.GH16981@random.random>
 <20110128164624.GA23905@csn.ul.ie>
 <4D42F9E3.2010605@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D42F9E3.2010605@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 12:16:19PM -0500, Rik van Riel wrote:
> On 01/28/2011 11:46 AM, Mel Gorman wrote:
> > On Fri, Jan 28, 2011 at 05:28:31PM +0100, Andrea Arcangeli wrote:
> 
> >> In previous email you asked me how kswapd get stuck in D state and
> >> never stops working, and that it should stop earlier. This sounds
> >> impossible, kswapd behavior can't possibly change, simply there is
> >> less memory freed by lowering that "gap".
> >
> > There might be less memory freed by lowering that gap but it still needs to
> > exit balance_pgdat() and go to sleep. Otherwise it'll keep freeing zones up
> > to the high watermark + gap and calling congestion_wait (hence the D state).
> 
> The gap works because kswapd has different thresholds for
> different things:
> 
> 1) get woken up if every zone on an allocator's zone list
>     is below the low watermark
> 
> 2) exit the loop if _every_ zone is at or above the
>     high watermark
> 
> 3) skip a zone in the freeing loop if the zone has more
>     than high + gap free memory

Exactly.

> 
> Continuing the loop as long as one zone is below the low
> watermark is what equalizes memory pressure between zones.

I think you meant below high wmark here.

> Skipping the freeing of pages in a zone that already has
> excessive amounts of free memory helps avoid memory waste
> and excessive swapping.  We simply equalize the balance
> between zones a little more slowly.  What matters is that
> the memory pressure gets equalized over time.

The main problem I could see is for the lowmem reserve ratio. The only
real wmark that will be relevant to the allocator will be the one of
the "exact" zone asked to the allocator, not the below zones because
of the reserve ratio. So then kswapd will only satisfy the high wmark
from the view of the caller for the "exact" zone asked (not the below
zones that also must take the lowmem reserve ratio into
account). Which is enough but kswapd isn't helping the allocator for
the below zones. In any case the gap won't ever be as big as the
reserve ratio of the lower zones, so it can't solve this regardless
with the gap. Probably what we have right now is already optimal so to
put more shrinking pressure on the highest zone asked.

Overall I don't see the point of the gap as it's just like setting the
below zone wmark higher and I doubt it makes a significant balancing
difference. But hey I'm also ok to keep the gap above zero, I just
feel it's wasted memory. Surely it should be easy to prove it's wasted
memory for the "cp /dev/sda /dev/null" workload on a 4g system with a
little ram above 4g. For mixed workloads things are little more
interesting but I think on average it's not worth it.

My whole point in claiming it can't affect the balancing of the lrus,
is that the real lru rotation is entirely controlled by the
allocator. It doesn't matter if kswapd stops at high or high+gap, for
any zone at any time, as long as the allocator only allocates from one
zone or the other. And if the allocator allocates from all zones in a
perfectly balanced way, again kswapd will shrink in a perfectly
balanced way over time regardless of high or high+gap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
