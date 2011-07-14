Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 45B166B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 02:10:57 -0400 (EDT)
Date: Thu, 14 Jul 2011 07:10:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/3] mm: page allocator: Reconsider zones for allocation
 after direct reclaim
Message-ID: <20110714061049.GK7529@suse.de>
References: <1310389274-13995-1-git-send-email-mgorman@suse.de>
 <1310389274-13995-4-git-send-email-mgorman@suse.de>
 <4E1CE9FF.3050707@jp.fujitsu.com>
 <20110713111017.GG7529@suse.de>
 <4E1E6086.4060902@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4E1E6086.4060902@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 14, 2011 at 12:20:38PM +0900, KOSAKI Motohiro wrote:
> (2011/07/13 20:10), Mel Gorman wrote:
> > On Wed, Jul 13, 2011 at 09:42:39AM +0900, KOSAKI Motohiro wrote:
> >> (2011/07/11 22:01), Mel Gorman wrote:
> >>> With zone_reclaim_mode enabled, it's possible for zones to be considered
> >>> full in the zonelist_cache so they are skipped in the future. If the
> >>> process enters direct reclaim, the ZLC may still consider zones to be
> >>> full even after reclaiming pages. Reconsider all zones for allocation
> >>> if direct reclaim returns successfully.
> >>>
> >>> Signed-off-by: Mel Gorman <mgorman@suse.de>
> >>
> >> Hmmm...
> >>
> >> I like the concept, but I'm worry about a corner case a bit.
> >>
> >> If users are using cpusets/mempolicy, direct reclaim don't scan all zones.
> >> Then, zlc_clear_zones_full() seems too aggressive operation.
> > 
> > As the system is likely to be running slow if it is in direct reclaim
> > that the complexity of being careful about which zone was cleared was
> > not worth it.
> > 
> >> Instead, couldn't we turn zlc->fullzones off from kswapd?
> >>
> > 
> > Which zonelist should it clear (there are two) and when should it
> > happen? If it clears it on each cycle around balance_pgdat(), there
> > is no guarantee that it'll be cleared between when direct reclaim
> > finishes and an attempt is made to allocate.
> 
> Hmm..
> 
> Probably I'm now missing the point of this patch. Why do we need
> to guarantee tightly coupled zlc cache and direct reclaim?

Because direct reclaim may free enough memory such that the zlc cache
stating the zone is full is wrong.

> IIUC,
> zlc cache mean "to avoid free list touch if they have no free mem".
> So, any free page increasing point is acceptable good, I thought.
> In the other hand, direct reclaim finishing has no guarantee to
> zones of zonelist have enough free memory because it has bailing out logic.
> 

It has no guarantee but there is a reasonable expectation that direct
reclaim will free some memory that means we should reconsider the
zone for allocation.

> So, I think we don't need to care zonelist, just kswapd turn off
> their own node.
> 

I don't understand what you mean by this.

> And, just curious, If we will have a proper zlc clear point, why
> do we need to keep HZ timeout?
> 

Yes because we are not guaranteed to call direct reclaim either. Memory
could be freed by a process exiting and I'd rather not add cost to
the free path to find and clear all zonelists referencing the zone the
page being freed belongs to.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
