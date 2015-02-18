Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEBE6B0078
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 05:49:06 -0500 (EST)
Received: by paceu11 with SMTP id eu11so301630pac.10
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 02:49:06 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id pw7si956599pdb.132.2015.02.18.02.49.03
        for <linux-mm@kvack.org>;
        Wed, 18 Feb 2015 02:49:05 -0800 (PST)
Date: Wed, 18 Feb 2015 21:48:59 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150218104859.GM12722@dastard>
References: <20141230112158.GA15546@dhcp22.suse.cz>
 <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
 <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150218082502.GA4478@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150218082502.GA4478@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Wed, Feb 18, 2015 at 09:25:02AM +0100, Michal Hocko wrote:
> On Wed 18-02-15 09:54:30, Dave Chinner wrote:
> > [ cc xfs list - experienced kernel devs should not have to be
> > reminded to do this ]
> > 
> > On Tue, Feb 17, 2015 at 07:53:15AM -0500, Johannes Weiner wrote:
> [...]
> > > void *
> > > kmem_alloc(size_t size, xfs_km_flags_t flags)
> > > {
> > > 	int	retries = 0;
> > > 	gfp_t	lflags = kmem_flags_convert(flags);
> > > 	void	*ptr;
> > > 
> > > 	do {
> > > 		ptr = kmalloc(size, lflags);
> > > 		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
> > > 			return ptr;
> > > 		if (!(++retries % 100))
> > > 			xfs_err(NULL,
> > > 		"possible memory allocation deadlock in %s (mode:0x%x)",
> > > 					__func__, lflags);
> > > 		congestion_wait(BLK_RW_ASYNC, HZ/50);
> > > 	} while (1);
> > > }
> > > 
> > > This should use __GFP_NOFAIL, which is not only designed to annotate
> > > broken code like this, but also recognizes that endless looping on a
> > > GFP_NOFS allocation needs the OOM killer after all to make progress.
> > > 
> > > diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> > > index a7a3a63bb360..17ced1805d3a 100644
> > > --- a/fs/xfs/kmem.c
> > > +++ b/fs/xfs/kmem.c
> > > @@ -45,20 +45,12 @@ kmem_zalloc_greedy(size_t *size, size_t minsize, size_t maxsize)
> > >  void *
> > >  kmem_alloc(size_t size, xfs_km_flags_t flags)
> > >  {
> > > -	int	retries = 0;
> > >  	gfp_t	lflags = kmem_flags_convert(flags);
> > > -	void	*ptr;
> > >  
> > > -	do {
> > > -		ptr = kmalloc(size, lflags);
> > > -		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
> > > -			return ptr;
> > > -		if (!(++retries % 100))
> > > -			xfs_err(NULL,
> > > -		"possible memory allocation deadlock in %s (mode:0x%x)",
> > > -					__func__, lflags);
> > > -		congestion_wait(BLK_RW_ASYNC, HZ/50);
> > > -	} while (1);
> > > +	if (!(flags & (KM_MAYFAIL | KM_NOSLEEP)))
> > > +		lflags |= __GFP_NOFAIL;
> > > +
> > > +	return kmalloc(size, lflags);
> > >  }
> > 
> > Hmmm - the only reason there is a focus on this loop is that it
> > emits warnings about allocations failing.
> 
> Such a warning should be part of the allocator and the whole point why
> I like the patch is that we should really warn at a single place. I
> was thinking about a simple warning (e.g. like the above) and having
> something more sophisticated when lockdep is enabled.
> 
> > It's obvious that the
> > problem being dealt with here is a fundamental design issue w.r.t.
> > to locking and the OOM killer, but the proposed special casing
> > hack^H^H^H^Hband aid^W^Wsolution is not "working" because some code
> > in XFS started emitting warnings about allocations failing more
> > often.
> > 
> > So the answer is to remove the warning?  That's like killing the
> > canary to stop the methane leak in the coal mine. No canary? No
> > problems!
> 
> Not at all. I cannot speak for Johannes but I am pretty sure his
> motivation wasn't to simply silence the warning. The thing is that no
> kernel code paths except for the page allocator shouldn't emulate
> behavior for which we have a gfp flag.
> 
> > Right now, the oom killer is a liability. Over the past 6 months
> > I've slowly had to exclude filesystem regression tests from running
> > on small memory machines because the OOM killer is now so unreliable
> > that it kills the test harness regularly rather than the process
> > generating memory pressure.
> 
> It would be great to get bug reports.

I thought we were talking about a manifestation of the problems I've
been seeing....

> > That's a big red flag to me that all
> > this hacking around the edges is not solving the underlying problem,
> > but instead is breaking things that did once work.
> 
> I am heavily trying to discourage people from adding random hacks to
> the already complicated and subtle OOM code.
> 
> > And, well, then there's this (gfp.h):
> > 
> >  * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
> >  * cannot handle allocation failures.  This modifier is deprecated and no new
> >  * users should be added.
> > 
> > So, is this another policy relevation from the mm developers about
> > the kmalloc API? i.e. that __GFP_NOFAIL is no longer deprecated?
> 
> It is deprecated and shouldn't be used. But that doesn't mean that users
> should workaround this by developing their own alternative.

I'm kinda sick of hearing that, as if saying it enough times will
make reality change. We have a *hard requirement* for memory
allocation to make forwards progress, otherwise we *fail
catastrophically*.

History lesson - June 2004:

http://oss.sgi.com/cgi-bin/gitweb.cgi?p=archive/xfs-import.git;a=commitdiff;h=b30a2f7bf90593b12dbc912e4390b1b8ee133ea9

So, we're hardly working around the deprecation of GFP_NOFAIL when
the code existed 5 years before GFP_NOFAIL was deprecated. Indeed,
GFP_NOFAIL was shiny and new back then, having been introduced by
Andrew Morton back in 2003.

> I agree the
> wording could be more clear and mention that if the allocation failure
> is absolutely unacceptable then the flags can be used rather than
> creating the loop around. What do you think about the following?
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index b840e3b2770d..ee6440ccb75d 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -57,8 +57,12 @@ struct vm_area_struct;
>   * _might_ fail.  This depends upon the particular VM implementation.
>   *
>   * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
> - * cannot handle allocation failures.  This modifier is deprecated and no new
> - * users should be added.
> + * cannot handle allocation failures.  This modifier is deprecated for allocation
> + * with order > 1. Besides that this modifier is very dangerous when allocation
> + * happens under a lock because it creates a lock dependency invisible for the
> + * OOM killer so it can livelock. If the allocation failure is _absolutely_
> + * unacceptable then the flags has to be used rather than looping around
> + * allocator.

Doesn't change anything from an XFS point of view. We do order >1
allocations through kmem_alloc() wrapper, and so we are still doing
something that is "not supported" even if we use GFP_NOFAIL rather
than our own loop.

Also, this reads as an excuse for the OOM killer being broken and
not fixing it.  Keep in mind that we tell the memory alloc/reclaim
subsystem that *we hold locks* when we call into it. That's what
GFP_NOFS originally meant, and it's what it still means today in an
XFS context.

If the OOM killer is not obeying GFP_NOFS and deadlocking on locks
that the invoking context holds, then that is a OOM killer bug, not
a bug in the subsystem calling kmalloc(GFP_NOFS).

>   *
>   * __GFP_NORETRY: The VM implementation must not retry indefinitely.
>   *
> 
> > Or just another symptom of frantic thrashing because nobody actually
> > understands the problem or those that do are unwilling to throw out
> > the broken crap and redesign it?
> > 
> > If you are changing allocator behaviour and constraints, then you
> > better damn well think through that changes fully, then document
> > those changes, change all the relevant code to use the new API (not
> > just those that throw warnings in your face) and make sure
> > *everyone* knows about it. e.g. a LWN article explaining the changes
> > and how memory allocation is going to work into the future would be
> > a good start.
> 
> Well, I think the first step is to change the users of the allocator
> to not lie about gfp flags. So if the code is infinitely trying then
> it really should use GFP_NOFAIL flag.

That's a complete non-issue when it comes to deciding whether it is
safe to invoke the OOM killer or not!

> In the meantime page allocator
> should develop a proper diagnostic to help identify all the potential
> dependencies. Next we should start thinking whether all the existing
> GFP_NOFAIL paths are really necessary or the code can be
> refactored/reimplemented to accept allocation failures.

Last time the "just make filesystems handle memory allocation
failures" I pointed out what that meant for XFS: dirty transaction
rollback is required. That's freakin' complex, will double the
memory footprint of transactions, roughly double the CPU cost, and
greatly increase the complexity of the transaction subsystem. It's a
*major* rework of a significant amount of the XFS codebase and will
take at least a couple of years design, test and stabilise before
it could be rolled out to production.

I'm not about to spend a couple of years rewriting XFS just so the
VM can get rid of a GFP_NOFAIL user. Especially as the we already
tell the Hammer of Last Resort the context in which it can work.

Move the OOM killer to kswapd - get it out of the direct reclaim
path altogether. If the system is that backed up on locks that it
cannot free any memory and has no reserves to satisfy the allocation
that kicked the OOM killer, then the OOM killer was not invoked soon
enough.

Hell, if you want a better way to proceed, then how about you allow
us to tell the MM subsystem how much memory reserve a specific set
of operations is going to require to complete? That's something that
we can do rough calculations for, and it integrates straight into
the existing transaction reservation system we already use for log
space and disk space, and we can tell the mm subsystem when the
reserve is no longer needed (i.e. last thing in transaction commit).

That way we don't start a transaction until the mm subsystem has
reserved enough pages for us to work with, and the reserve only
needs to be used when normal allocation has already failed. i.e
rather than looping we get a page allocated from the reserve pool.

The reservations wouldn't be perfect, but the majority of the time
we'd be able to make progress and not need the OOM killer. And best
of all, there's no responsibilty on the MM subsystem for preventing
OOM - getting the reservations right is the responsibiity of the
subsystem using them.

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
