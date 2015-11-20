Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 40A076B0038
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 18:33:19 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so130171445pac.3
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 15:33:19 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id u81si1777156pfa.147.2015.11.20.15.33.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 15:33:18 -0800 (PST)
Received: by padhx2 with SMTP id hx2so130212658pad.1
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 15:33:18 -0800 (PST)
Date: Fri, 20 Nov 2015 15:33:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 3/3] mm: use watermak checks for __GFP_REPEAT high order
 allocations
In-Reply-To: <20151120091825.GD16698@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1511201530420.10092@chino.kir.corp.google.com>
References: <1447851840-15640-1-git-send-email-mhocko@kernel.org> <1447851840-15640-4-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1511191515170.17510@chino.kir.corp.google.com> <20151120091825.GD16698@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, 20 Nov 2015, Michal Hocko wrote:

> > > @@ -3167,24 +3166,21 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > >  
> > >  	/*
> > >  	 * Do not retry high order allocations unless they are __GFP_REPEAT
> > > -	 * and even then do not retry endlessly unless explicitly told so
> > > +	 * unless explicitly told so.
> > >  	 */
> > > -	pages_reclaimed += did_some_progress;
> > > -	if (order > PAGE_ALLOC_COSTLY_ORDER) {
> > > -		if (!(gfp_mask & __GFP_NOFAIL) &&
> > > -		   (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order)))
> > > -			goto noretry;
> > > -
> > > -		if (did_some_progress)
> > > -			goto retry;
> > > -	}
> > > +	if (order > PAGE_ALLOC_COSTLY_ORDER &&
> > > +			!(gfp_mask & (__GFP_REPEAT|__GFP_NOFAIL)))
> > > +		goto noretry;
> > 
> > Who is allocating order > PAGE_ALLOC_COSTLY_ORDER with __GFP_REPEAT and 
> > would be affected by this change?
> 
> E.g. hugetlb pages. I have tested this in my testing scenario 3.
> 

If that's the only high-order user of __GFP_REPEAT, we might want to 
consider dropping it.  I believe the hugetlb usecase would only be 
relevant in early init (when __GFP_REPEAT shouldn't logically help) and 
when returning surplus pages due to hugetlb overcommit.  Since hugetlb 
overcommit is best effort and we already know that the
pages_reclaimed >= (1<<order) check is ridiculous for order-9 pages, I 
think you could just drop hugetlb's usage of __GFP_REPEAT and nobody would 
notice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
