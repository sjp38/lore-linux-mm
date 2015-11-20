Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8FFC76B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 04:15:50 -0500 (EST)
Received: by wmdw130 with SMTP id w130so11564459wmd.0
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 01:15:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iz1si17108000wjb.58.2015.11.20.01.15.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 20 Nov 2015 01:15:49 -0800 (PST)
Date: Fri, 20 Nov 2015 10:15:48 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 2/3] mm: throttle on IO only when there are too many dirty
 and writeback pages
Message-ID: <20151120091548.GC16698@dhcp22.suse.cz>
References: <1447851840-15640-1-git-send-email-mhocko@kernel.org>
 <1447851840-15640-3-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1511191507030.17510@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511191507030.17510@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu 19-11-15 15:12:39, David Rientjes wrote:
> On Wed, 18 Nov 2015, Michal Hocko wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > wait_iff_congested has been used to throttle allocator before it retried
> > another round of direct reclaim to allow the writeback to make some
> > progress and prevent reclaim from looping over dirty/writeback pages
> > without making any progress. We used to do congestion_wait before
> > 0e093d99763e ("writeback: do not sleep on the congestion queue if
> > there are no congested BDIs or if significant congestion is not being
> > encountered in the current zone") but that led to undesirable stalls
> > and sleeping for the full timeout even when the BDI wasn't congested.
> > Hence wait_iff_congested was used instead. But it seems that even
> > wait_iff_congested doesn't work as expected. We might have a small file
> > LRU list with all pages dirty/writeback and yet the bdi is not congested
> > so this is just a cond_resched in the end and can end up triggering pre
> > mature OOM.
> > 
> > This patch replaces the unconditional wait_iff_congested by
> > congestion_wait which is executed only if we _know_ that the last round
> > of direct reclaim didn't make any progress and dirty+writeback pages are
> > more than a half of the reclaimable pages on the zone which might be
> > usable for our target allocation. This shouldn't reintroduce stalls
> > fixed by 0e093d99763e because congestion_wait is called only when we
> > are getting hopeless when sleeping is a better choice than OOM with many
> > pages under IO.
> > 
> 
> Why HZ/10 instead of HZ/50?

My idea was to give the writeback more time. As we only wait when there
is a lot of dirty/writeback data it shouldn't stall pointlessly.

> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/page_alloc.c | 16 ++++++++++++++--
> >  1 file changed, 14 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 020c005c5bc0..e6271bc19e6a 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3212,8 +3212,20 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		 */
> >  		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
> >  				ac->high_zoneidx, alloc_flags, target)) {
> > -			/* Wait for some write requests to complete then retry */
> > -			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
> > +			unsigned long writeback = zone_page_state(zone, NR_WRITEBACK),
> > +				      dirty = zone_page_state(zone, NR_FILE_DIRTY);
> > +
> > +			/*
> > +			 * If we didn't make any progress and have a lot of
> > +			 * dirty + writeback pages then we should wait for
> > +			 * an IO to complete to slow down the reclaim and
> > +			 * prevent from pre mature OOM
> > +			 */
> > +			if (!did_some_progress && 2*(writeback + dirty) > reclaimable)
> > +				congestion_wait(BLK_RW_ASYNC, HZ/10);
> 
> The purpose of the heuristic seems logical, but I'm concerned about the 
> threshold for determining when to wait and when to just resched and retry 
> again.
> 
> This triggers for environments without swap when
> 
> 2 * (NR_WRITEBACK + NR_DIRTY) > (NR_ACTIVE_FILE + NR_INACTIVE_FILE +
> 				 NR_ISOLATED_FILE + NR_ISOLATED_ANON)
> 
>  [ The use of NR_ISOLATED_ANON in swapless is asked about in patch 1. ]
> 
> How exactly was this chosen?  Why not when the two sides equal each other?

The idea was to stall when the to-be-flushed pages form at least half of
the reclaimable memory which sounds like an easy concept to start with.
This worked reasonably well in my OOM stress tests but I am opened to
suggestions. Ideally this should be a function of the writeback speed
and maybe we will get there one day but I would like to start with
something simple which works most of the time.

> 
> > +			else
> > +				cond_resched();
> > +
> >  			goto retry;
> >  		}
> >  	}

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
