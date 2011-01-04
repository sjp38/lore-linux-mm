Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0F26B0089
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 18:56:26 -0500 (EST)
Date: Tue, 4 Jan 2011 15:56:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
Message-Id: <20110104155613.2b092adb.akpm@linux-foundation.org>
In-Reply-To: <20101209000440.GM2356@cmpxchg.org>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
	<20101208141909.5c9c60e8.akpm@linux-foundation.org>
	<20101209000440.GM2356@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Dec 2010 01:04:40 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Wed, Dec 08, 2010 at 02:19:09PM -0800, Andrew Morton wrote:
> > On Wed,  8 Dec 2010 16:16:59 +0100
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > Kswapd tries to rebalance zones persistently until their high
> > > watermarks are restored.

So we still haven't fixed this.

> > > If the amount of unreclaimable pages in a zone makes this impossible
> > > for reclaim, though, kswapd will end up in a busy loop without a
> > > chance of reaching its goal.
> > > 
> > > This behaviour was observed on a virtual machine with a tiny
> > > Normal-zone that filled up with unreclaimable slab objects.
> > 
> > Doesn't this mean that vmscan is incorrectly handling its
> > zone->all_unreclaimable logic?
> 
> I don't think so.  What leads to the problem is that we only declare a
> zone unreclaimable after a lot of work, but reset it with a single
> page that gets released back to the allocator (past the pcp queue,
> that is).
> 
> That's probably a good idea per-se, we don't want to leave a zone
> behind and retry it eagerly when pages are freed up.
> 
> > presumably in certain cases that's a bit more efficient than doing the
> > scan and using ->all_unreclaimable.  But the scanner shouldn't have got
> > stuck!  That's a regresion which got added, and I don't think that new
> > code of this nature was needed to fix that regression.
> 
> I'll dig through the history.  But we observed this on a very odd
> configuration (24MB ZONE_NORMAL), maybe this was never hit before?

I expect scenarios like this _were_ tested, back in the day.  More
usually with a highmem zone which is much smaller than the normal zone.

> > Did this zone end up with ->all_unreclaimable set?  If so, why was
> > kswapd stuck in a loop scanning an all-unreclaimable zone?
> 
> It wasn't.  This state is just not very sticky.  After all, the zone
> is not all_unreclaimable, just not reclaimable enough to restore the
> high watermark.  But the remaining reclaimable pages of that zone may
> very well be in constant flux.

Perhaps this was caused by the breakage of the prev_priority logic. 
With prev_priority we'd only do a small amount of scanning against that
zone before declaring that it is still all_unreclaimable.

> > Also, if I'm understanding the new logic then if the "goal" is 100
> > pages and zone_reclaimable_pages() says "50 pages potentially
> > reclaimable" then kswapd won't reclaim *any* pages.  If so, is that
> > good behaviour?  Should we instead attempt to reclaim some of those 50
> > pages and then give up?  That sounds like a better strategy if we want
> > to keep (say) network Rx happening in a tight memory situation.
> 
> Yes, that is probably a good idea.  I'll see that this is improved for
> atomic allocators.

Having rethought, it still feels to me that we'd be implementing two
ways of doing basically the same thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
