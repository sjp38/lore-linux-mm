Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 960076B0032
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 17:52:34 -0500 (EST)
Received: by paceu11 with SMTP id eu11so3093774pac.10
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 14:52:34 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id i3si30094727pdg.111.2015.02.19.14.52.32
        for <linux-mm@kvack.org>;
        Thu, 19 Feb 2015 14:52:33 -0800 (PST)
Date: Fri, 20 Feb 2015 09:52:17 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150219225217.GY12722@dastard>
References: <20141230112158.GA15546@dhcp22.suse.cz>
 <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
 <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150219102431.GA15569@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Thu, Feb 19, 2015 at 05:24:31AM -0500, Johannes Weiner wrote:
> On Wed, Feb 18, 2015 at 09:54:30AM +1100, Dave Chinner wrote:
> > [ cc xfs list - experienced kernel devs should not have to be
> > reminded to do this ]
> > 
> > On Tue, Feb 17, 2015 at 07:53:15AM -0500, Johannes Weiner wrote:
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
> > emits warnings about allocations failing. It's obvious that the
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
> That's not what happened.  The patch that affected behavior here
> transformed code that an incoherent collection of conditions to
> something that has an actual model.

Which is entirely undocumented. If you have a model, the first thing
to do is document it and communicate that model to everyone who
needs to know about that new model. I have no idea what that model
is. Keeping it in your head and changing code that other people
maintain without giving them any means of understanding WTF you are
doing is a really bad engineering practice.


And yes, I have had a bit to say about this in public recently.
Go watch my recent LCA talk, for example....

And, FWIW, email discussions on a list is no substitute for a
properly documented design that people can take their time to
understand and digest.

> That model is that we don't loop
> in the allocator if there are no means to making forward progress.  In
> this case, it was GFP_NOFS triggering an early exit from the allocator
> because it's not allowed to invoke the OOM killer per default, and
> there is little point in looping for times to better on their own.

So you keep saying....

> So these deadlock warnings happen, ironically, by the page allocator
> now bailing out of a locked-up state in which it's not making forward
> progress.  They don't strike me as a very useful canary in this case.

... yet we *rarely* see the canary warnings we emit when we do too
many allocation retries, the code has been that way for 13-odd
years.  Hence, despite your protestations that your way is *better*,
we have code that is tried, tested and proven in rugged production
environments. That's far more convincing evidence that the *code
should not change* than your assertions that it is broken and needs
to be fixed.

> > Right now, the oom killer is a liability. Over the past 6 months
> > I've slowly had to exclude filesystem regression tests from running
> > on small memory machines because the OOM killer is now so unreliable
> > that it kills the test harness regularly rather than the process
> > generating memory pressure. That's a big red flag to me that all
> > this hacking around the edges is not solving the underlying problem,
> > but instead is breaking things that did once work.
> > 
> > And, well, then there's this (gfp.h):
> > 
> >  * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
> >  * cannot handle allocation failures.  This modifier is deprecated and no new
> >  * users should be added.
> > 
> > So, is this another policy relevation from the mm developers about
> > the kmalloc API? i.e. that __GFP_NOFAIL is no longer deprecated?
> > Or just another symptom of frantic thrashing because nobody actually
> > understands the problem or those that do are unwilling to throw out
> > the broken crap and redesign it?
> 
> Well, understand our dilemma here.  __GFP_NOFAIL is a liability
> because it can trap tasks with unknown state and locks in a
> potentially never ending loop, and we don't want people to start using
> it as a convenient solution to get out of having a fallback strategy.
> 
> However, if your entire architecture around a particular allocation is
> that failure is not an option at this point, and you can't reasonably
> preallocate - although that would always be preferrable - then please
> do not open code an endless loop around the call to the allocator but
> use __GFP_NOFAIL instead so that these callsites are annotated and can
> be reviewed. 

I will actively work around aanything that causes filesystem memory
pressure to increase the chance of oom killer invocations. The OOM
killer is not a solution - it is, by definition, a loose cannon and
so we should be reducing dependencies on it.

I really don't care about the OOM Killer corner cases - it's
completely the wrong way line of development to be spending time on
and you aren't going to convince me otherwise. The OOM killer a
crutch used to justify having a memory allocation subsystem that
can't provide forward progress guarantee mechanisms to callers that
need it.

I've proposed a method of providing this forward progress guarantee
for subsystems of arbitrary complexity, and this removes the
dependency on the OOM killer for fowards allocation progress in such
contexts (e.g. filesystems). We should be discussing how to
implement that, not what bandaids we need to apply to the OOM
killer. I want to fix the underlying problems, not push them under
the OOM-killer bus...

> And please understand that this callsite blowing up is a chance to
> better the code and behavior here.  Where previously it would just
> endlessly loop in the allocator without any means to make progress,

Again, this statement ignores the fact we have *no credible
evidence* that this is actually a problem in production
environments.

And, besides, even if you do force through changing the XFS code to
GFP_NOFAIL, it'll get changed back to a retry loop in the near
future when we add admin configurable error handling behaviour to
XFS, as I pointed Michal to....
(http://oss.sgi.com/archives/xfs/2015-02/msg00346.html)

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
