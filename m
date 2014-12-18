Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7094D6B0032
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 21:20:27 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so222263wib.16
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 18:20:26 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id mn7si9625111wjc.31.2014.12.17.18.20.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Dec 2014 18:20:26 -0800 (PST)
Date: Wed, 17 Dec 2014 21:20:19 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Stalled MM patches for review
Message-ID: <20141218022019.GA25071@phnom.home.cmpxchg.org>
References: <20141215150207.67c9a25583c04202d9f4508e@linux-foundation.org>
 <548F7541.8040407@jp.fujitsu.com>
 <20141216030658.GA18569@phnom.home.cmpxchg.org>
 <alpine.DEB.2.10.1412161650540.19867@chino.kir.corp.google.com>
 <20141217021302.GA14148@phnom.home.cmpxchg.org>
 <alpine.DEB.2.10.1412171422330.16260@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1412171422330.16260@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Dec 17, 2014 at 02:28:37PM -0800, David Rientjes wrote:
> On Tue, 16 Dec 2014, Johannes Weiner wrote:
> 
> > > This is broken because it does not recall gfp_to_alloc_flags().  If 
> > > current is the oom kill victim, then ALLOC_NO_WATERMARKS never gets set 
> > > properly and the slowpath will end up looping forever.  The "restart" 
> > > label which was removed in this patch needs to be reintroduced, and it can 
> > > probably be moved to directly before gfp_to_alloc_flags().
> > 
> > Thanks for catching this.  gfp_to_alloc_flags()'s name doesn't exactly
> > imply such side effects...  Here is a fixlet on top:
> > 
> 
> It would have livelocked the machine on an oom kill.

Very unlikely.  The allocator will loop trying to reclaim and there is
usually other activity on the system that makes progress.  There must
be, because the allocator can always hold locks that the victim needs
to exit.

> > From 45362d1920340716ef58bf1024d9674b5dfa809e Mon Sep 17 00:00:00 2001
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Date: Tue, 16 Dec 2014 21:04:24 -0500
> > Subject: [patch] mm: page_alloc: embed OOM killing naturally into allocation
> >  slowpath fix
> > 
> > When retrying the allocation after potentially invoking OOM, make sure
> > the alloc flags are recalculated, as they have to consider TIF_MEMDIE.
> > 
> > Restore the original restart label, but rename it to 'retry' to match
> > the should_alloc_retry() it depends on.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  mm/page_alloc.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 83ec725aec36..e8f5997c557c 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2673,6 +2673,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
> >  		goto nopage;
> >  
> > +retry:
> >  	if (!(gfp_mask & __GFP_NO_KSWAPD))
> >  		wake_all_kswapds(order, zonelist, high_zoneidx,
> >  				preferred_zone, nodemask);
> > @@ -2695,7 +2696,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		classzone_idx = zonelist_zone_idx(preferred_zoneref);
> >  	}
> >  
> > -rebalance:
> >  	/* This is the last chance, in general, before the goto nopage. */
> >  	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
> >  			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
> > @@ -2823,7 +2823,7 @@ rebalance:
> >  		}
> >  		/* Wait for some write requests to complete then retry */
> >  		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
> > -		goto rebalance;
> > +		goto retry;
> >  	} else {
> >  		/*
> >  		 * High-order allocations do not necessarily loop after
> 
> Why remove 'rebalance'?  In the situation where direct reclaim does free 
> memory and we're waiting on writeback (no call to the oom killer is made), 
> it doesn't seem necessary to recalculate classzone_idx.
> 
> Additionally, we never called wait_iff_congested() before when the oom 
> killer freed memory.  This is a no-op if the preferred_zone isn't waiting 
> on writeback, but seems pointless if we just freed memory by calling the 
> oom killer.

Why keep all these undocumented assumptions in the code?  It's really
simple: if we retry freeing memory (LRU reclaim or OOM kills), we wait
for congestion, kick kswapd, re-evaluate the current task state,
regardless of which reclaim method did what or anything at all.  It's
a slowpath, so there is no reason to not keep this simple and robust.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
