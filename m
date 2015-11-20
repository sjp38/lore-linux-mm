Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 785EF6B0254
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 04:18:27 -0500 (EST)
Received: by wmec201 with SMTP id c201so12701867wme.1
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 01:18:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xt8si17059984wjb.197.2015.11.20.01.18.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 20 Nov 2015 01:18:26 -0800 (PST)
Date: Fri, 20 Nov 2015 10:18:25 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 3/3] mm: use watermak checks for __GFP_REPEAT high order
 allocations
Message-ID: <20151120091825.GD16698@dhcp22.suse.cz>
References: <1447851840-15640-1-git-send-email-mhocko@kernel.org>
 <1447851840-15640-4-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1511191515170.17510@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511191515170.17510@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu 19-11-15 15:17:35, David Rientjes wrote:
> On Wed, 18 Nov 2015, Michal Hocko wrote:
[...]
> > @@ -3167,24 +3166,21 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  
> >  	/*
> >  	 * Do not retry high order allocations unless they are __GFP_REPEAT
> > -	 * and even then do not retry endlessly unless explicitly told so
> > +	 * unless explicitly told so.
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
> 
> Who is allocating order > PAGE_ALLOC_COSTLY_ORDER with __GFP_REPEAT and 
> would be affected by this change?

E.g. hugetlb pages. I have tested this in my testing scenario 3.

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
> 
> This makes sense if there are high-order users of __GFP_REPEAT since 
> only using a number of pages reclaimed by itself isn't helpful.

Yes, that was my thinking

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
