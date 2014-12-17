Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0EF396B0032
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 17:28:41 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id hl2so226152igb.11
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 14:28:40 -0800 (PST)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id yz3si4515560icb.10.2014.12.17.14.28.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 14:28:39 -0800 (PST)
Received: by mail-ig0-f175.google.com with SMTP id h15so9585611igd.14
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 14:28:39 -0800 (PST)
Date: Wed, 17 Dec 2014 14:28:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Stalled MM patches for review
In-Reply-To: <20141217021302.GA14148@phnom.home.cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1412171422330.16260@chino.kir.corp.google.com>
References: <20141215150207.67c9a25583c04202d9f4508e@linux-foundation.org> <548F7541.8040407@jp.fujitsu.com> <20141216030658.GA18569@phnom.home.cmpxchg.org> <alpine.DEB.2.10.1412161650540.19867@chino.kir.corp.google.com>
 <20141217021302.GA14148@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, 16 Dec 2014, Johannes Weiner wrote:

> > This is broken because it does not recall gfp_to_alloc_flags().  If 
> > current is the oom kill victim, then ALLOC_NO_WATERMARKS never gets set 
> > properly and the slowpath will end up looping forever.  The "restart" 
> > label which was removed in this patch needs to be reintroduced, and it can 
> > probably be moved to directly before gfp_to_alloc_flags().
> 
> Thanks for catching this.  gfp_to_alloc_flags()'s name doesn't exactly
> imply such side effects...  Here is a fixlet on top:
> 

It would have livelocked the machine on an oom kill.

> ---
> From 45362d1920340716ef58bf1024d9674b5dfa809e Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Tue, 16 Dec 2014 21:04:24 -0500
> Subject: [patch] mm: page_alloc: embed OOM killing naturally into allocation
>  slowpath fix
> 
> When retrying the allocation after potentially invoking OOM, make sure
> the alloc flags are recalculated, as they have to consider TIF_MEMDIE.
> 
> Restore the original restart label, but rename it to 'retry' to match
> the should_alloc_retry() it depends on.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/page_alloc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 83ec725aec36..e8f5997c557c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2673,6 +2673,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
>  		goto nopage;
>  
> +retry:
>  	if (!(gfp_mask & __GFP_NO_KSWAPD))
>  		wake_all_kswapds(order, zonelist, high_zoneidx,
>  				preferred_zone, nodemask);
> @@ -2695,7 +2696,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		classzone_idx = zonelist_zone_idx(preferred_zoneref);
>  	}
>  
> -rebalance:
>  	/* This is the last chance, in general, before the goto nopage. */
>  	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
>  			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
> @@ -2823,7 +2823,7 @@ rebalance:
>  		}
>  		/* Wait for some write requests to complete then retry */
>  		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
> -		goto rebalance;
> +		goto retry;
>  	} else {
>  		/*
>  		 * High-order allocations do not necessarily loop after

Why remove 'rebalance'?  In the situation where direct reclaim does free 
memory and we're waiting on writeback (no call to the oom killer is made), 
it doesn't seem necessary to recalculate classzone_idx.

Additionally, we never called wait_iff_congested() before when the oom 
killer freed memory.  This is a no-op if the preferred_zone isn't waiting 
on writeback, but seems pointless if we just freed memory by calling the 
oom killer.

In other words, I'm not sure why you're fixlet isn't this:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2673,6 +2673,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
 		goto nopage;
 
+retry:
 	if (!(gfp_mask & __GFP_NO_KSWAPD))
 		wake_all_kswapds(order, zonelist, high_zoneidx,
 				preferred_zone, nodemask);
@@ -2822,6 +2823,7 @@ rebalance:
 				BUG_ON(gfp_mask & __GFP_NOFAIL);
 				goto nopage;
 			}
+			goto retry;
 		}
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
