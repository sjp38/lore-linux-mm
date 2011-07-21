Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 63C666B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 06:31:55 -0400 (EDT)
Date: Thu, 21 Jul 2011 11:31:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/3] mm: page allocator: Reconsider zones for allocation
 after direct reclaim
Message-ID: <20110721103149.GR5349@suse.de>
References: <1310389274-13995-1-git-send-email-mgorman@suse.de>
 <1310389274-13995-4-git-send-email-mgorman@suse.de>
 <4E1CE9FF.3050707@jp.fujitsu.com>
 <20110713111017.GG7529@suse.de>
 <4E1E6086.4060902@jp.fujitsu.com>
 <20110714061049.GK7529@suse.de>
 <4E27F2EC.2010902@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4E27F2EC.2010902@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 21, 2011 at 06:35:40PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> 
> 
> 
> 
> >> So, I think we don't need to care zonelist, just kswapd turn off
> >> their own node.
> > 
> > I don't understand what you mean by this.
> 
> This was the answer of following your comments.
> 
> > Instead, couldn't we turn zlc->fullzones off from kswapd?
> > >
> > > Which zonelist should it clear (there are two)
> 
> I mean, buddy list is belong to zone, not zonelist. therefore, kswapd
> don't need to look up zonelist.
> 
> So, I'd suggest either following way,
>  - use direct reclaim path, but only clear a zlc bit of zones in reclaimed zonelist, not all. or

We certainly could narrow the number of zones the bits are
cleared on by exporting knowledge of the ZLC to vmscan for use in
shrink_zones(). I think in practice the end result will be the same
though as shrink_zones() examples all zones in the zonelist. How much
of a gain do you expect the additional complexity to give us?

>  - use kswapd and only clear a zlc bit at kswap exiting balance_pgdat
> 

That is potentially a long time if there are streaming readers keeping a
zone under the high watermark for a long time.

> I'm prefer to add a branch to slowpath (ie reclaim path) rather than fast path.
> 

The clearing of the zonelist is already happening after direct reclaim
which is the slow path. What fast path are you concerned with here?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
