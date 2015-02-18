Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 78CF96B0032
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 03:25:07 -0500 (EST)
Received: by wesw55 with SMTP id w55so3134714wes.5
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 00:25:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wv9si33735442wjb.187.2015.02.18.00.25.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 00:25:05 -0800 (PST)
Date: Wed, 18 Feb 2015 09:25:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150218082502.GA4478@dhcp22.suse.cz>
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
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Wed 18-02-15 09:54:30, Dave Chinner wrote:
> [ cc xfs list - experienced kernel devs should not have to be
> reminded to do this ]
> 
> On Tue, Feb 17, 2015 at 07:53:15AM -0500, Johannes Weiner wrote:
[...]
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
> emits warnings about allocations failing.

Such a warning should be part of the allocator and the whole point why
I like the patch is that we should really warn at a single place. I
was thinking about a simple warning (e.g. like the above) and having
something more sophisticated when lockdep is enabled.

> It's obvious that the
> problem being dealt with here is a fundamental design issue w.r.t.
> to locking and the OOM killer, but the proposed special casing
> hack^H^H^H^Hband aid^W^Wsolution is not "working" because some code
> in XFS started emitting warnings about allocations failing more
> often.
> 
> So the answer is to remove the warning?  That's like killing the
> canary to stop the methane leak in the coal mine. No canary? No
> problems!

Not at all. I cannot speak for Johannes but I am pretty sure his
motivation wasn't to simply silence the warning. The thing is that no
kernel code paths except for the page allocator shouldn't emulate
behavior for which we have a gfp flag.

> Right now, the oom killer is a liability. Over the past 6 months
> I've slowly had to exclude filesystem regression tests from running
> on small memory machines because the OOM killer is now so unreliable
> that it kills the test harness regularly rather than the process
> generating memory pressure.

It would be great to get bug reports.

> That's a big red flag to me that all
> this hacking around the edges is not solving the underlying problem,
> but instead is breaking things that did once work.

I am heavily trying to discourage people from adding random hacks to
the already complicated and subtle OOM code.

> And, well, then there's this (gfp.h):
> 
>  * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
>  * cannot handle allocation failures.  This modifier is deprecated and no new
>  * users should be added.
> 
> So, is this another policy relevation from the mm developers about
> the kmalloc API? i.e. that __GFP_NOFAIL is no longer deprecated?

It is deprecated and shouldn't be used. But that doesn't mean that users
should workaround this by developing their own alternative. I agree the
wording could be more clear and mention that if the allocation failure
is absolutely unacceptable then the flags can be used rather than
creating the loop around. What do you think about the following?

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index b840e3b2770d..ee6440ccb75d 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -57,8 +57,12 @@ struct vm_area_struct;
  * _might_ fail.  This depends upon the particular VM implementation.
  *
  * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
- * cannot handle allocation failures.  This modifier is deprecated and no new
- * users should be added.
+ * cannot handle allocation failures.  This modifier is deprecated for allocation
+ * with order > 1. Besides that this modifier is very dangerous when allocation
+ * happens under a lock because it creates a lock dependency invisible for the
+ * OOM killer so it can livelock. If the allocation failure is _absolutely_
+ * unacceptable then the flags has to be used rather than looping around
+ * allocator.
  *
  * __GFP_NORETRY: The VM implementation must not retry indefinitely.
  *

> Or just another symptom of frantic thrashing because nobody actually
> understands the problem or those that do are unwilling to throw out
> the broken crap and redesign it?
> 
> If you are changing allocator behaviour and constraints, then you
> better damn well think through that changes fully, then document
> those changes, change all the relevant code to use the new API (not
> just those that throw warnings in your face) and make sure
> *everyone* knows about it. e.g. a LWN article explaining the changes
> and how memory allocation is going to work into the future would be
> a good start.

Well, I think the first step is to change the users of the allocator
to not lie about gfp flags. So if the code is infinitely trying then
it really should use GFP_NOFAIL flag.  In the meantime page allocator
should develop a proper diagnostic to help identify all the potential
dependencies. Next we should start thinking whether all the existing
GFP_NOFAIL paths are really necessary or the code can be
refactored/reimplemented to accept allocation failures.

> Otherwise, this just looks like another knee-jerk band aid for an
> architectural problem that needs more than special case hacks to
> solve.
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
