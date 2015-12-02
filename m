Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id D83906B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 03:52:14 -0500 (EST)
Received: by wmuu63 with SMTP id u63so205184593wmu.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 00:52:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r7si2933655wjy.100.2015.12.02.00.52.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Dec 2015 00:52:13 -0800 (PST)
Date: Wed, 2 Dec 2015 09:52:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 3/3] mm: use watermak checks for __GFP_REPEAT high order
 allocations
Message-ID: <20151202085207.GB25284@dhcp22.suse.cz>
References: <1448974607-10208-1-git-send-email-mhocko@kernel.org>
 <1448974607-10208-4-git-send-email-mhocko@kernel.org>
 <04a801d12cd0$1a601820$4f204860$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04a801d12cd0$1a601820$4f204860$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>

On Wed 02-12-15 15:07:26, Hillf Danton wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > __alloc_pages_slowpath retries costly allocations until at least
> > order worth of pages were reclaimed or the watermark check for at least
> > one zone would succeed after all reclaiming all pages if the reclaim
> > hasn't made any progress.
> > 
> > The first condition was added by a41f24ea9fd6 ("page allocator: smarter
> > retry of costly-order allocations) and it assumed that lumpy reclaim
> > could have created a page of the sufficient order. Lumpy reclaim,
> > has been removed quite some time ago so the assumption doesn't hold
> > anymore. It would be more appropriate to check the compaction progress
> > instead but this patch simply removes the check and relies solely
> > on the watermark check.
> > 
> > To prevent from too many retries the stall_backoff is not reseted after
> > a reclaim which made progress because we cannot assume it helped high
> > order situation.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/page_alloc.c | 20 ++++++++------------
> >  1 file changed, 8 insertions(+), 12 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 168a675e9116..45de14cd62f4 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2998,7 +2998,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
> >  	struct page *page = NULL;
> >  	int alloc_flags;
> > -	unsigned long pages_reclaimed = 0;
> >  	unsigned long did_some_progress;
> >  	enum migrate_mode migration_mode = MIGRATE_ASYNC;
> >  	bool deferred_compaction = false;
> > @@ -3167,24 +3166,21 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > 
> >  	/*
> >  	 * Do not retry high order allocations unless they are __GFP_REPEAT
> > -	 * and even then do not retry endlessly unless explicitly told so
> > +	 * unless explicitly told so.
> 
> s/unless/or/

Fixed
 
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

Thanks!

> 
> >  	 */
> > -	pages_reclaimed += did_some_progress;
> > -	if (order > PAGE_ALLOC_COSTLY_ORDER) {
> > -		if (!(gfp_mask & __GFP_NOFAIL) &&
> > -		   (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order)))
> > -			goto noretry;
> > -
> > -		if (did_some_progress)
> > -			goto retry;
> > -	}
> > +	if (order > PAGE_ALLOC_COSTLY_ORDER &&
> > +			!(gfp_mask & (__GFP_REPEAT|__GFP_NOFAIL)))
> > +		goto noretry;
> > 
> >  	/*
> >  	 * Be optimistic and consider all pages on reclaimable LRUs as usable
> >  	 * but make sure we converge to OOM if we cannot make any progress after
> >  	 * multiple consecutive failed attempts.
> > +	 * Costly __GFP_REPEAT allocations might have made a progress but this
> > +	 * doesn't mean their order will become available due to high fragmentation
> > +	 * so do not reset the backoff for them
> >  	 */
> > -	if (did_some_progress)
> > +	if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
> >  		stall_backoff = 0;
> >  	else
> >  		stall_backoff = min(stall_backoff+1, MAX_STALL_BACKOFF);
> > --
> > 2.6.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
