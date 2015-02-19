Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 265B4900015
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 05:24:43 -0500 (EST)
Received: by wesx3 with SMTP id x3so6342055wes.7
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 02:24:42 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id fo7si40219569wic.114.2015.02.19.02.24.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Feb 2015 02:24:41 -0800 (PST)
Date: Thu, 19 Feb 2015 05:24:31 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150219102431.GA15569@phnom.home.cmpxchg.org>
References: <20141230112158.GA15546@dhcp22.suse.cz>
 <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
 <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150217225430.GJ4251@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Wed, Feb 18, 2015 at 09:54:30AM +1100, Dave Chinner wrote:
> [ cc xfs list - experienced kernel devs should not have to be
> reminded to do this ]
> 
> On Tue, Feb 17, 2015 at 07:53:15AM -0500, Johannes Weiner wrote:
> > On Tue, Feb 17, 2015 at 09:23:26PM +0900, Tetsuo Handa wrote:
> > > Tetsuo Handa wrote:
> > > > Johannes Weiner wrote:
> > > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > > index 8e20f9c2fa5a..f77c58ebbcfa 100644
> > > > > --- a/mm/page_alloc.c
> > > > > +++ b/mm/page_alloc.c
> > > > > @@ -2382,8 +2382,15 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> > > > >  		if (high_zoneidx < ZONE_NORMAL)
> > > > >  			goto out;
> > > > >  		/* The OOM killer does not compensate for light reclaim */
> > > > > -		if (!(gfp_mask & __GFP_FS))
> > > > > +		if (!(gfp_mask & __GFP_FS)) {
> > > > > +			/*
> > > > > +			 * XXX: Page reclaim didn't yield anything,
> > > > > +			 * and the OOM killer can't be invoked, but
> > > > > +			 * keep looping as per should_alloc_retry().
> > > > > +			 */
> > > > > +			*did_some_progress = 1;
> > > > >  			goto out;
> > > > > +		}
> > > > 
> > > > Why do you omit out_of_memory() call for GFP_NOIO / GFP_NOFS allocations?
> > > 
> > > I can see "possible memory allocation deadlock in %s (mode:0x%x)" warnings
> > > at kmem_alloc() in fs/xfs/kmem.c . I think commit 9879de7373fcfb46 "mm:
> > > page_alloc: embed OOM killing naturally into allocation slowpath" introduced
> > > a regression and below one is the fix.
> > > 
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -2381,9 +2381,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> > >                 /* The OOM killer does not needlessly kill tasks for lowmem */
> > >                 if (high_zoneidx < ZONE_NORMAL)
> > >                         goto out;
> > > -               /* The OOM killer does not compensate for light reclaim */
> > > -               if (!(gfp_mask & __GFP_FS))
> > > -                       goto out;
> > >                 /*
> > >                  * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
> > >                  * Sanity check for bare calls of __GFP_THISNODE, not real OOM.
> > 
> > Again, we don't want to OOM kill on behalf of allocations that can't
> > initiate IO, or even actively prevent others from doing it.  Not per
> > default anyway, because most callers can deal with the failure without
> > having to resort to killing tasks, and NOFS reclaim *can* easily fail.
> > It's the exceptions that should be annotated instead:
> > 
> > void *
> > kmem_alloc(size_t size, xfs_km_flags_t flags)
> > {
> > 	int	retries = 0;
> > 	gfp_t	lflags = kmem_flags_convert(flags);
> > 	void	*ptr;
> > 
> > 	do {
> > 		ptr = kmalloc(size, lflags);
> > 		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
> > 			return ptr;
> > 		if (!(++retries % 100))
> > 			xfs_err(NULL,
> > 		"possible memory allocation deadlock in %s (mode:0x%x)",
> > 					__func__, lflags);
> > 		congestion_wait(BLK_RW_ASYNC, HZ/50);
> > 	} while (1);
> > }
> > 
> > This should use __GFP_NOFAIL, which is not only designed to annotate
> > broken code like this, but also recognizes that endless looping on a
> > GFP_NOFS allocation needs the OOM killer after all to make progress.
> > 
> > diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> > index a7a3a63bb360..17ced1805d3a 100644
> > --- a/fs/xfs/kmem.c
> > +++ b/fs/xfs/kmem.c
> > @@ -45,20 +45,12 @@ kmem_zalloc_greedy(size_t *size, size_t minsize, size_t maxsize)
> >  void *
> >  kmem_alloc(size_t size, xfs_km_flags_t flags)
> >  {
> > -	int	retries = 0;
> >  	gfp_t	lflags = kmem_flags_convert(flags);
> > -	void	*ptr;
> >  
> > -	do {
> > -		ptr = kmalloc(size, lflags);
> > -		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
> > -			return ptr;
> > -		if (!(++retries % 100))
> > -			xfs_err(NULL,
> > -		"possible memory allocation deadlock in %s (mode:0x%x)",
> > -					__func__, lflags);
> > -		congestion_wait(BLK_RW_ASYNC, HZ/50);
> > -	} while (1);
> > +	if (!(flags & (KM_MAYFAIL | KM_NOSLEEP)))
> > +		lflags |= __GFP_NOFAIL;
> > +
> > +	return kmalloc(size, lflags);
> >  }
> 
> Hmmm - the only reason there is a focus on this loop is that it
> emits warnings about allocations failing. It's obvious that the
> problem being dealt with here is a fundamental design issue w.r.t.
> to locking and the OOM killer, but the proposed special casing
> hack^H^H^H^Hband aid^W^Wsolution is not "working" because some code
> in XFS started emitting warnings about allocations failing more
> often.
> 
> So the answer is to remove the warning?  That's like killing the
> canary to stop the methane leak in the coal mine. No canary? No
> problems!

That's not what happened.  The patch that affected behavior here
transformed code that an incoherent collection of conditions to
something that has an actual model.  That model is that we don't loop
in the allocator if there are no means to making forward progress.  In
this case, it was GFP_NOFS triggering an early exit from the allocator
because it's not allowed to invoke the OOM killer per default, and
there is little point in looping for times to better on their own.

So these deadlock warnings happen, ironically, by the page allocator
now bailing out of a locked-up state in which it's not making forward
progress.  They don't strike me as a very useful canary in this case.

> Right now, the oom killer is a liability. Over the past 6 months
> I've slowly had to exclude filesystem regression tests from running
> on small memory machines because the OOM killer is now so unreliable
> that it kills the test harness regularly rather than the process
> generating memory pressure. That's a big red flag to me that all
> this hacking around the edges is not solving the underlying problem,
> but instead is breaking things that did once work.
> 
> And, well, then there's this (gfp.h):
> 
>  * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
>  * cannot handle allocation failures.  This modifier is deprecated and no new
>  * users should be added.
> 
> So, is this another policy relevation from the mm developers about
> the kmalloc API? i.e. that __GFP_NOFAIL is no longer deprecated?
> Or just another symptom of frantic thrashing because nobody actually
> understands the problem or those that do are unwilling to throw out
> the broken crap and redesign it?

Well, understand our dilemma here.  __GFP_NOFAIL is a liability
because it can trap tasks with unknown state and locks in a
potentially never ending loop, and we don't want people to start using
it as a convenient solution to get out of having a fallback strategy.

However, if your entire architecture around a particular allocation is
that failure is not an option at this point, and you can't reasonably
preallocate - although that would always be preferrable - then please
do not open code an endless loop around the call to the allocator but
use __GFP_NOFAIL instead so that these callsites are annotated and can
be reviewed.  By giving the allocator this information, it can then
also adjust its behavior, like it is the case right here: we don't
usually want to OOM kill for regular GFP_NOFS allocations because
their reclaim powers are weak and we don't want to kill tasks
prematurely.  But if your NOFS allocation can not fail under any
circumstances, then the OOM killer should very much be employed to
make any kind of forward progress at all for this allocation.  It's
just that the allocator needs to be made aware of this requirement.

So yes, we are wary of __GFP_NOFAIL allocations, but this is an
instance where it's the right way to communicate with the allocator,
it was introduced to replace such open-coded endless loops and have
the liability of making progress with the allocator, not the caller.

And please understand that this callsite blowing up is a chance to
better the code and behavior here.  Where previously it would just
endlessly loop in the allocator without any means to make progress,
converting it to a __GFP_NOFAIL allocation tells the allocator that
it's fine to use the OOM killer in such an instance, improving the
chances that this caller will actually make headway under heavy load.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
