Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 345C36B0009
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 21:19:37 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id y8so35329208igp.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 18:19:37 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id uw2si2622499igb.57.2016.03.01.18.19.35
        for <linux-mm@kvack.org>;
        Tue, 01 Mar 2016 18:19:36 -0800 (PST)
Date: Wed, 2 Mar 2016 11:19:54 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160302021954.GA22355@js1304-P5Q-DELUXE>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160229210213.GX16930@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Mon, Feb 29, 2016 at 10:02:13PM +0100, Michal Hocko wrote:
> Andrew,
> could you queue this one as well, please? This is more a band aid than a
> real solution which I will be working on as soon as I am able to
> reproduce the issue but the patch should help to some degree at least.

I'm not sure that this is a way to go. See below.

> 
> On Thu 25-02-16 10:23:15, Michal Hocko wrote:
> > From d09de26cee148b4d8c486943b4e8f3bd7ad6f4be Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Thu, 4 Feb 2016 14:56:59 +0100
> > Subject: [PATCH] mm, oom: protect !costly allocations some more
> > 
> > should_reclaim_retry will give up retries for higher order allocations
> > if none of the eligible zones has any requested or higher order pages
> > available even if we pass the watermak check for order-0. This is done
> > because there is no guarantee that the reclaimable and currently free
> > pages will form the required order.
> > 
> > This can, however, lead to situations were the high-order request (e.g.
> > order-2 required for the stack allocation during fork) will trigger
> > OOM too early - e.g. after the first reclaim/compaction round. Such a
> > system would have to be highly fragmented and the OOM killer is just a
> > matter of time but let's stick to our MAX_RECLAIM_RETRIES for the high
> > order and not costly requests to make sure we do not fail prematurely.
> > 
> > This also means that we do not reset no_progress_loops at the
> > __alloc_pages_slowpath for high order allocations to guarantee a bounded
> > number of retries.
> > 
> > Longterm it would be much better to communicate with the compaction
> > and retry only if the compaction considers it meaningfull.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/page_alloc.c | 20 ++++++++++++++++----
> >  1 file changed, 16 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 269a04f20927..f05aca36469b 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3106,6 +3106,18 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
> >  		}
> >  	}
> >  
> > +	/*
> > +	 * OK, so the watermak check has failed. Make sure we do all the
> > +	 * retries for !costly high order requests and hope that multiple
> > +	 * runs of compaction will generate some high order ones for us.
> > +	 *
> > +	 * XXX: ideally we should teach the compaction to try _really_ hard
> > +	 * if we are in the retry path - something like priority 0 for the
> > +	 * reclaim
> > +	 */
> > +	if (order && order <= PAGE_ALLOC_COSTLY_ORDER)
> > +		return true;
> > +
> >  	return false;

This seems not a proper fix. Checking watermark with high order has
another meaning that there is high order page or not. This isn't
what we want here. So, following fix is needed.

'if (order)' check isn't needed. It is used to clarify the meaning of
this fix. You can remove it.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1993894..8c80375 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3125,6 +3125,10 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
        if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
                return false;
 
+       /* To check whether compaction is available or not */
+       if (order)
+               order = 0;
+
        /*
         * Keep reclaiming pages while there is a chance this will lead
         * somewhere.  If none of the target zones can satisfy our allocation

> >  }
> >  
> > @@ -3281,11 +3293,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		goto noretry;
> >  
> >  	/*
> > -	 * Costly allocations might have made a progress but this doesn't mean
> > -	 * their order will become available due to high fragmentation so do
> > -	 * not reset the no progress counter for them
> > +	 * High order allocations might have made a progress but this doesn't
> > +	 * mean their order will become available due to high fragmentation so
> > +	 * do not reset the no progress counter for them
> >  	 */
> > -	if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
> > +	if (did_some_progress && !order)
> >  		no_progress_loops = 0;
> >  	else
> >  		no_progress_loops++;

This unconditionally increases no_progress_loops for high order
allocation, so, after 16 iterations, it will fail. If compaction isn't
enabled in Kconfig, 16 times reclaim attempt would not be sufficient
to make high order page. Should we consider this case also?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
