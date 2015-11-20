Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 01DC16B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 04:06:30 -0500 (EST)
Received: by wmdw130 with SMTP id w130so11271467wmd.0
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 01:06:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t132si2811656wmt.17.2015.11.20.01.06.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 20 Nov 2015 01:06:28 -0800 (PST)
Date: Fri, 20 Nov 2015 10:06:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
Message-ID: <20151120090626.GB16698@dhcp22.suse.cz>
References: <1447851840-15640-1-git-send-email-mhocko@kernel.org>
 <1447851840-15640-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1511191455310.17510@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511191455310.17510@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu 19-11-15 15:01:38, David Rientjes wrote:
> On Wed, 18 Nov 2015, Michal Hocko wrote:
[...]
> > @@ -3155,13 +3165,57 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	if (gfp_mask & __GFP_NORETRY)
> >  		goto noretry;
> >  
> > -	/* Keep reclaiming pages as long as there is reasonable progress */
> > +	/*
> > +	 * Do not retry high order allocations unless they are __GFP_REPEAT
> > +	 * and even then do not retry endlessly unless explicitly told so
> > +	 */
> >  	pages_reclaimed += did_some_progress;
> > -	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
> > -	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
> > -		/* Wait for some write requests to complete then retry */
> > -		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
> > -		goto retry;
> > +	if (order > PAGE_ALLOC_COSTLY_ORDER) {
> > +		if (!(gfp_mask & __GFP_NOFAIL) &&
> > +		   (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order)))
> > +			goto noretry;
> > +
> > +		if (did_some_progress)
> > +			goto retry;
> > +	}
> 
> First of all, thanks very much for attacking this issue!
> 
> I'm concerned that we'll reach stall_backoff == MAX_STALL_BACKOFF too 
> quickly if the wait_iff_congested() is removed.  While not immediately 
> being available for reclaim, this has at least partially stalled in the 
> past which may have resulted in external memory freeing.  I'm wondering if 
> it would make sense to keep if nothing more than to avoid an immediate 
> retry.

My experiments show that wait_iff_congested slept only very rarely if at
all (even for loads with a heavy IO). There might be other loads where
it really hits, though. If you have any of those I would be more than
happy if you could share them or at least test them with these patches.

If you are concerned about removed wait_iff_congested for costly
__GFP_REPEAT allocations then the follow up patch changes that to use a
common sleep&retry logic.

> > +
> > +	/*
> > +	 * Be optimistic and consider all pages on reclaimable LRUs as usable
> > +	 * but make sure we converge to OOM if we cannot make any progress after
> > +	 * multiple consecutive failed attempts.
> > +	 */
> > +	if (did_some_progress)
> > +		stall_backoff = 0;
> > +	else
> > +		stall_backoff = min(stall_backoff+1, MAX_STALL_BACKOFF);
> > +
> > +	/*
> > +	 * Keep reclaiming pages while there is a chance this will lead somewhere.
> > +	 * If none of the target zones can satisfy our allocation request even
> > +	 * if all reclaimable pages are considered then we are screwed and have
> > +	 * to go OOM.
> > +	 */
> > +	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx, ac->nodemask) {
> > +		unsigned long free = zone_page_state(zone, NR_FREE_PAGES);
> 
> This is concerning, I would think that you would want to use 
> zone_page_state_snapshot() at the very list for when 
> stall_backoff == MAX_STALL_BACKOFF.

OK, this is a fair point. In an extreme case where vmstat counters are
way outdated we might loop endlessly. I will just use _snapshot variant.
The overhead shouldn't be a concern as this is a slow path.

Other counters are using backoff so they do not need this special
treatment.

> > +		unsigned long reclaimable;
> > +		unsigned long target;
> > +
> > +		reclaimable = zone_reclaimable_pages(zone) +
> > +			      zone_page_state(zone, NR_ISOLATED_FILE) +
> > +			      zone_page_state(zone, NR_ISOLATED_ANON);
> 
> Does NR_ISOLATED_ANON mean anything relevant here in swapless 
> environments?

It should be 0 so I didn't bother to check for swapless configuration.

[...]

> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index a4507ecaefbf..9060a71e5a90 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -192,7 +192,7 @@ static bool sane_reclaim(struct scan_control *sc)
> >  }
> >  #endif
> >  
> > -static unsigned long zone_reclaimable_pages(struct zone *zone)
> > +unsigned long zone_reclaimable_pages(struct zone *zone)
> >  {
> >  	unsigned long nr;
> >  
> > @@ -2594,10 +2594,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> >  
> >  		if (shrink_zone(zone, sc, zone_idx(zone) == classzone_idx))
> >  			reclaimable = true;
> > -
> > -		if (global_reclaim(sc) &&
> > -		    !reclaimable && zone_reclaimable(zone))
> > -			reclaimable = true;
> >  	}
> >  
> >  	/*
> 
> It's possible to just make shrink_zones() void and drop the reclaimable 
> variable.

True, will do that.
 
> Otherwise looks good!

Thanks for the review!

Here is what I will fold it to the original patch
---
commit b8687e8406f4ec1b194b259acaea115711d319cd
Author: Michal Hocko <mhocko@suse.com>
Date:   Fri Nov 20 10:04:22 2015 +0100

    fold me: mm, oom: refactor oom detection
    
    [rientjes@google.com: use zone_page_state_snapshot for NR_FREE_PAGES]
    [rientjes@google.com: shrink_zones doesn't need to return anything]

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 999c8cdbe7b5..54476e71b572 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3192,7 +3192,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * to go OOM.
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx, ac->nodemask) {
-		unsigned long free = zone_page_state(zone, NR_FREE_PAGES);
+		unsigned long free = zone_page_state_snapshot(zone, NR_FREE_PAGES);
 		unsigned long reclaimable;
 		unsigned long target;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9060a71e5a90..784e2b28d2fb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2511,10 +2511,8 @@ static inline bool compaction_ready(struct zone *zone, int order)
  *
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
- *
- * Returns true if a zone was reclaimable.
  */
-static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
+static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 {
 	struct zoneref *z;
 	struct zone *zone;
@@ -2522,7 +2520,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	unsigned long nr_soft_scanned;
 	gfp_t orig_mask;
 	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
-	bool reclaimable = false;
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2587,13 +2584,10 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 						&nr_soft_scanned);
 			sc->nr_reclaimed += nr_soft_reclaimed;
 			sc->nr_scanned += nr_soft_scanned;
-			if (nr_soft_reclaimed)
-				reclaimable = true;
 			/* need some check for avoid more shrink_zone() */
 		}
 
-		if (shrink_zone(zone, sc, zone_idx(zone) == classzone_idx))
-			reclaimable = true;
+		shrink_zone(zone, sc, zone_idx(zone));
 	}
 
 	/*
@@ -2601,8 +2595,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	 * promoted it to __GFP_HIGHMEM.
 	 */
 	sc->gfp_mask = orig_mask;
-
-	return reclaimable;
 }
 
 /*
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
