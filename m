Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 98D3F6B0254
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:46:39 -0500 (EST)
Received: by wmww144 with SMTP id w144so88312895wmw.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:46:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h7si18080003wjz.55.2015.11.23.01.46.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Nov 2015 01:46:38 -0800 (PST)
Date: Mon, 23 Nov 2015 10:46:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 3/3] mm: use watermak checks for __GFP_REPEAT high order
 allocations
Message-ID: <20151123094636.GE21050@dhcp22.suse.cz>
References: <1447851840-15640-1-git-send-email-mhocko@kernel.org>
 <1447851840-15640-4-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1511191515170.17510@chino.kir.corp.google.com>
 <20151120091825.GD16698@dhcp22.suse.cz>
 <alpine.DEB.2.10.1511201530420.10092@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511201530420.10092@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri 20-11-15 15:33:17, David Rientjes wrote:
> On Fri, 20 Nov 2015, Michal Hocko wrote:
> 
> > > > @@ -3167,24 +3166,21 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > > >  
> > > >  	/*
> > > >  	 * Do not retry high order allocations unless they are __GFP_REPEAT
> > > > -	 * and even then do not retry endlessly unless explicitly told so
> > > > +	 * unless explicitly told so.
> > > >  	 */
> > > > -	pages_reclaimed += did_some_progress;
> > > > -	if (order > PAGE_ALLOC_COSTLY_ORDER) {
> > > > -		if (!(gfp_mask & __GFP_NOFAIL) &&
> > > > -		   (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order)))
> > > > -			goto noretry;
> > > > -
> > > > -		if (did_some_progress)
> > > > -			goto retry;
> > > > -	}
> > > > +	if (order > PAGE_ALLOC_COSTLY_ORDER &&
> > > > +			!(gfp_mask & (__GFP_REPEAT|__GFP_NOFAIL)))
> > > > +		goto noretry;
> > > 
> > > Who is allocating order > PAGE_ALLOC_COSTLY_ORDER with __GFP_REPEAT and 
> > > would be affected by this change?
> > 
> > E.g. hugetlb pages. I have tested this in my testing scenario 3.
> > 
> 
> If that's the only high-order user of __GFP_REPEAT, we might want to 
> consider dropping it. 

There are many others. I have tried to clean this area up quite recently
http://lkml.kernel.org/r/1446740160-29094-1-git-send-email-mhocko%40kernel.org
and managed to drop half of the current usage of __GFP_REPEAT.

> I believe the hugetlb usecase would only be 
> relevant in early init (when __GFP_REPEAT shouldn't logically help) and 
> when returning surplus pages due to hugetlb overcommit.  Since hugetlb 
> overcommit is best effort and we already know that the
> pages_reclaimed >= (1<<order) check is ridiculous for order-9 pages, I 
> think you could just drop hugetlb's usage of __GFP_REPEAT and nobody would 
> notice.

Even if that was the case, which I am not sure right now, I believe this
is a separate topic. We should still support __GFP_REPEAT in some form.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
