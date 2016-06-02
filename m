Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 282966B0005
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 11:46:24 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id rs7so25911849lbb.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 08:46:24 -0700 (PDT)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id bb7si1464448wjc.82.2016.06.02.08.46.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 08:46:22 -0700 (PDT)
Received: by mail-wm0-f45.google.com with SMTP id n184so86377146wmn.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 08:46:22 -0700 (PDT)
Date: Thu, 2 Jun 2016 17:46:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160602154619.GU1995@dhcp22.suse.cz>
References: <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
 <20160519081146.GS3193@twins.programming.kicks-ass.net>
 <20160520001714.GC26977@dastard>
 <20160601131758.GO26601@dhcp22.suse.cz>
 <20160601181617.GV3190@twins.programming.kicks-ass.net>
 <20160602145048.GS1995@dhcp22.suse.cz>
 <20160602151116.GD3190@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160602151116.GD3190@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Thu 02-06-16 17:11:16, Peter Zijlstra wrote:
> On Thu, Jun 02, 2016 at 04:50:49PM +0200, Michal Hocko wrote:
> > On Wed 01-06-16 20:16:17, Peter Zijlstra wrote:
> 
> > > So my favourite is the dedicated GFP flag, but if that's unpalatable for
> > > the mm folks then something like the below might work. It should be
> > > similar in effect to your proposal, except its more limited in scope.
> > [...]
> > > @@ -2876,11 +2883,36 @@ static void __lockdep_trace_alloc(gfp_t gfp_mask, unsigned long flags)
> > >  	if (DEBUG_LOCKS_WARN_ON(irqs_disabled_flags(flags)))
> > >  		return;
> > >  
> > > +	/*
> > > +	 * Skip _one_ allocation as per the lockdep_skip_alloc() request.
> > > +	 * Must be done last so that we don't loose the annotation for
> > > +	 * GFP_ATOMIC like things from IRQ or other nesting contexts.
> > > +	 */
> > > +	if (current->lockdep_reclaim_gfp & __GFP_SKIP_ALLOC) {
> > > +		current->lockdep_reclaim_gfp &= ~__GFP_SKIP_ALLOC;
> > > +		return;
> > > +	}
> > > +
> > >  	mark_held_locks(curr, RECLAIM_FS);
> > >  }
> > 
> > I might be missing something but does this work actually? Say you would
> > want a kmalloc(size), it would call
> > slab_alloc_node
> >   slab_pre_alloc_hook
> >     lockdep_trace_alloc
> > [...]
> >   ____cache_alloc_node
> >     cache_grow_begin
> >       kmem_getpages
> >         __alloc_pages_node
> > 	  __alloc_pages_nodemask
> > 	    lockdep_trace_alloc
> 
> Bugger :/ You're right, that would fail.
> 
> So how about doing:
> 
> #define __GFP_NOLOCKDEP	(1u << __GFP_BITS_SHIFT)

Hmm, now that I looked closer this would break GFP_SLAB_BUG_MASK :/
The whole thing is a bit hysterical because I really do not see any
reason to blow up just because somebody has used incorrect gfp mask
(we have users who give us combinations without any sense in the tree...)

We can fix that either by dropping the whole GFP_SLAB_BUG_MASK thingy
or to update it with __GFP_NOLOCKDEP. It just shows how this might get
really tricky and subtle.

> this means it cannot be part of address_space::flags or
> radix_tree_root::gfp_mask, but that might not be a bad thing.

True, those shouldn't really care.

> And this solves the scarcity thing, because per pagemap we need to have
> 5 'spare' bits anyway.
> 
> > I understand your concerns about the scope but usually all allocations
> > have to be __GFP_NOFS or none in the same scope so I would see it as a
> > huge deal.
> 
> With scope I mostly meant the fact that you have two calls that you need
> to pair up. That's not really nice as you can 'annotate' a _lot_ of code
> in between. I prefer the narrower annotations where you annotate a
> single specific site.

Yes, I can see you point. What I meant to say is that we would most
probably end up with the following pattern
	lockdep_trace_alloc_enable()
	some_foo_with_alloc(gfp_mask);
	lockdep_trace_alloc_disable()

and some_foo_with_alloc might be a lot of code. But at the same time we
know that _any_ allocation done from that context is safe from the
reclaim recursiveness POV. If not then annotation is buggy and needs to
be done at a different level but that would be exactly same if we did
some_foo_with_alloc(gfp_mask|__GFP_NOLOCKDEP) because all the
allocations down that road would reuse the same gfp mask anyway.

That being said I completely agree that a single entry point is much
less error prone but it also is tricky as we can see. So I would rather
go with something less tricky. It's not like people are not used to
enable/disable pattern.

Anyway I will leave the decision to you. If you really insist on
__GFP_NOLOCKDEP which doesn't consume new flag then I can review the
resulting patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
