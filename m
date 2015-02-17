Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E24C16B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 17:54:36 -0500 (EST)
Received: by padet14 with SMTP id et14so9711890pad.11
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 14:54:36 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id nw8si16718091pdb.143.2015.02.17.14.54.34
        for <linux-mm@kvack.org>;
        Tue, 17 Feb 2015 14:54:35 -0800 (PST)
Date: Wed, 18 Feb 2015 09:54:30 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150217225430.GJ4251@dastard>
References: <20141230112158.GA15546@dhcp22.suse.cz>
 <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
 <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150217125315.GA14287@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

[ cc xfs list - experienced kernel devs should not have to be
reminded to do this ]

On Tue, Feb 17, 2015 at 07:53:15AM -0500, Johannes Weiner wrote:
> On Tue, Feb 17, 2015 at 09:23:26PM +0900, Tetsuo Handa wrote:
> > Tetsuo Handa wrote:
> > > Johannes Weiner wrote:
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index 8e20f9c2fa5a..f77c58ebbcfa 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -2382,8 +2382,15 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> > > >  		if (high_zoneidx < ZONE_NORMAL)
> > > >  			goto out;
> > > >  		/* The OOM killer does not compensate for light reclaim */
> > > > -		if (!(gfp_mask & __GFP_FS))
> > > > +		if (!(gfp_mask & __GFP_FS)) {
> > > > +			/*
> > > > +			 * XXX: Page reclaim didn't yield anything,
> > > > +			 * and the OOM killer can't be invoked, but
> > > > +			 * keep looping as per should_alloc_retry().
> > > > +			 */
> > > > +			*did_some_progress = 1;
> > > >  			goto out;
> > > > +		}
> > > 
> > > Why do you omit out_of_memory() call for GFP_NOIO / GFP_NOFS allocations?
> > 
> > I can see "possible memory allocation deadlock in %s (mode:0x%x)" warnings
> > at kmem_alloc() in fs/xfs/kmem.c . I think commit 9879de7373fcfb46 "mm:
> > page_alloc: embed OOM killing naturally into allocation slowpath" introduced
> > a regression and below one is the fix.
> > 
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2381,9 +2381,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> >                 /* The OOM killer does not needlessly kill tasks for lowmem */
> >                 if (high_zoneidx < ZONE_NORMAL)
> >                         goto out;
> > -               /* The OOM killer does not compensate for light reclaim */
> > -               if (!(gfp_mask & __GFP_FS))
> > -                       goto out;
> >                 /*
> >                  * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
> >                  * Sanity check for bare calls of __GFP_THISNODE, not real OOM.
> 
> Again, we don't want to OOM kill on behalf of allocations that can't
> initiate IO, or even actively prevent others from doing it.  Not per
> default anyway, because most callers can deal with the failure without
> having to resort to killing tasks, and NOFS reclaim *can* easily fail.
> It's the exceptions that should be annotated instead:
> 
> void *
> kmem_alloc(size_t size, xfs_km_flags_t flags)
> {
> 	int	retries = 0;
> 	gfp_t	lflags = kmem_flags_convert(flags);
> 	void	*ptr;
> 
> 	do {
> 		ptr = kmalloc(size, lflags);
> 		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
> 			return ptr;
> 		if (!(++retries % 100))
> 			xfs_err(NULL,
> 		"possible memory allocation deadlock in %s (mode:0x%x)",
> 					__func__, lflags);
> 		congestion_wait(BLK_RW_ASYNC, HZ/50);
> 	} while (1);
> }
> 
> This should use __GFP_NOFAIL, which is not only designed to annotate
> broken code like this, but also recognizes that endless looping on a
> GFP_NOFS allocation needs the OOM killer after all to make progress.
> 
> diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> index a7a3a63bb360..17ced1805d3a 100644
> --- a/fs/xfs/kmem.c
> +++ b/fs/xfs/kmem.c
> @@ -45,20 +45,12 @@ kmem_zalloc_greedy(size_t *size, size_t minsize, size_t maxsize)
>  void *
>  kmem_alloc(size_t size, xfs_km_flags_t flags)
>  {
> -	int	retries = 0;
>  	gfp_t	lflags = kmem_flags_convert(flags);
> -	void	*ptr;
>  
> -	do {
> -		ptr = kmalloc(size, lflags);
> -		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
> -			return ptr;
> -		if (!(++retries % 100))
> -			xfs_err(NULL,
> -		"possible memory allocation deadlock in %s (mode:0x%x)",
> -					__func__, lflags);
> -		congestion_wait(BLK_RW_ASYNC, HZ/50);
> -	} while (1);
> +	if (!(flags & (KM_MAYFAIL | KM_NOSLEEP)))
> +		lflags |= __GFP_NOFAIL;
> +
> +	return kmalloc(size, lflags);
>  }

Hmmm - the only reason there is a focus on this loop is that it
emits warnings about allocations failing. It's obvious that the
problem being dealt with here is a fundamental design issue w.r.t.
to locking and the OOM killer, but the proposed special casing
hack^H^H^H^Hband aid^W^Wsolution is not "working" because some code
in XFS started emitting warnings about allocations failing more
often.

So the answer is to remove the warning?  That's like killing the
canary to stop the methane leak in the coal mine. No canary? No
problems!

Right now, the oom killer is a liability. Over the past 6 months
I've slowly had to exclude filesystem regression tests from running
on small memory machines because the OOM killer is now so unreliable
that it kills the test harness regularly rather than the process
generating memory pressure. That's a big red flag to me that all
this hacking around the edges is not solving the underlying problem,
but instead is breaking things that did once work.

And, well, then there's this (gfp.h):

 * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
 * cannot handle allocation failures.  This modifier is deprecated and no new
 * users should be added.

So, is this another policy relevation from the mm developers about
the kmalloc API? i.e. that __GFP_NOFAIL is no longer deprecated?
Or just another symptom of frantic thrashing because nobody actually
understands the problem or those that do are unwilling to throw out
the broken crap and redesign it?

If you are changing allocator behaviour and constraints, then you
better damn well think through that changes fully, then document
those changes, change all the relevant code to use the new API (not
just those that throw warnings in your face) and make sure
*everyone* knows about it. e.g. a LWN article explaining the changes
and how memory allocation is going to work into the future would be
a good start.

Otherwise, this just looks like another knee-jerk band aid for an
architectural problem that needs more than special case hacks to
solve.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
