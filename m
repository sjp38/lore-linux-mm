Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 645606B0387
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 03:15:59 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xr1so58047987wjb.7
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 00:15:59 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id w206si22826590wmb.82.2016.12.21.00.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 00:15:58 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id kp2so30922650wjc.0
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 00:15:58 -0800 (PST)
Date: Wed, 21 Dec 2016 09:15:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20161221081556.GG16502@dhcp22.suse.cz>
References: <20161220134904.21023-1-mhocko@kernel.org>
 <20161220134904.21023-3-mhocko@kernel.org>
 <201612210031.BFD48914.VMtHSFFJOLQFOO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612210031.BFD48914.VMtHSFFJOLQFOO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, rientjes@google.com, mgorman@suse.de, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 21-12-16 00:31:47, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index c8eed66d8abb..2dda7c3eba52 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3098,32 +3098,31 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> >  	if (page)
> >  		goto out;
> >  
> > -	if (!(gfp_mask & __GFP_NOFAIL)) {
> > -		/* Coredumps can quickly deplete all memory reserves */
> > -		if (current->flags & PF_DUMPCORE)
> > -			goto out;
> > -		/* The OOM killer will not help higher order allocs */
> > -		if (order > PAGE_ALLOC_COSTLY_ORDER)
> > -			goto out;
> > -		/* The OOM killer does not needlessly kill tasks for lowmem */
> > -		if (ac->high_zoneidx < ZONE_NORMAL)
> > -			goto out;
> > -		if (pm_suspended_storage())
> > -			goto out;
> > -		/*
> > -		 * XXX: GFP_NOFS allocations should rather fail than rely on
> > -		 * other request to make a forward progress.
> > -		 * We are in an unfortunate situation where out_of_memory cannot
> > -		 * do much for this context but let's try it to at least get
> > -		 * access to memory reserved if the current task is killed (see
> > -		 * out_of_memory). Once filesystems are ready to handle allocation
> > -		 * failures more gracefully we should just bail out here.
> > -		 */
> > +	/* Coredumps can quickly deplete all memory reserves */
> > +	if (current->flags & PF_DUMPCORE)
> > +		goto out;
> > +	/* The OOM killer will not help higher order allocs */
> > +	if (order > PAGE_ALLOC_COSTLY_ORDER)
> > +		goto out;
> > +	/* The OOM killer does not needlessly kill tasks for lowmem */
> > +	if (ac->high_zoneidx < ZONE_NORMAL)
> > +		goto out;
> > +	if (pm_suspended_storage())
> > +		goto out;
> > +	/*
> > +	 * XXX: GFP_NOFS allocations should rather fail than rely on
> > +	 * other request to make a forward progress.
> > +	 * We are in an unfortunate situation where out_of_memory cannot
> > +	 * do much for this context but let's try it to at least get
> > +	 * access to memory reserved if the current task is killed (see
> > +	 * out_of_memory). Once filesystems are ready to handle allocation
> > +	 * failures more gracefully we should just bail out here.
> > +	 */
> > +
> > +	/* The OOM killer may not free memory on a specific node */
> > +	if (gfp_mask & __GFP_THISNODE)
> > +		goto out;
> >  
> > -		/* The OOM killer may not free memory on a specific node */
> > -		if (gfp_mask & __GFP_THISNODE)
> > -			goto out;
> > -	}
> >  	/* Exhausted what can be done so it's blamo time */
> >  	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> >  		*did_some_progress = 1;
> 
> Why do we need to change this part in this patch?
> 
> This change silently prohibits invoking the OOM killer for e.g. costly
> GFP_KERNEL allocation.

We have never allowed coslty GFP_KERNEL requests to invoke the oom
killer. And there is a good reason for it which is even mentioned in the
changelog. The only change here is that GFP_NOFAIL doesn't override this
decision - again for reasons mentioned in the changelog.

> While it would be better if vmalloc() can be used,
> there might be users who cannot accept vmalloc() as a fallback (e.g.
> CONFIG_MMU=n where vmalloc() == kmalloc() ?).

I haven't ever heard any complains about this in the past. If there is a
valid usecase then we can treat nommu specialy. That would require more
changes though.

> This change is not "do not enforce OOM killer automatically" but
> "never allow OOM killer". No exception is allowed. If we change
> this part, title for this part should be something strong like
> "mm,oom: Never allow OOM killer for coredumps, costly allocations,
> lowmem etc.".

Sigh. We didn't allow the oom killer for all those cases and the only
thing that is changed here is to not override those decisions with
__GFP_NOFAIL which is imho reflected in the title. If that is not clear
then I would suggest "mm, oom: do not override OOM killer decisions with
__GFP_NOFAIL".

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
