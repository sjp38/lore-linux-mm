Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 618836B0005
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 11:11:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s73so58744534pfs.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 08:11:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id qz3si27512838pab.82.2016.06.02.08.11.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 08:11:19 -0700 (PDT)
Date: Thu, 2 Jun 2016 17:11:16 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160602151116.GD3190@twins.programming.kicks-ass.net>
References: <20160516130519.GJ23146@dhcp22.suse.cz>
 <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
 <20160519081146.GS3193@twins.programming.kicks-ass.net>
 <20160520001714.GC26977@dastard>
 <20160601131758.GO26601@dhcp22.suse.cz>
 <20160601181617.GV3190@twins.programming.kicks-ass.net>
 <20160602145048.GS1995@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160602145048.GS1995@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Thu, Jun 02, 2016 at 04:50:49PM +0200, Michal Hocko wrote:
> On Wed 01-06-16 20:16:17, Peter Zijlstra wrote:

> > So my favourite is the dedicated GFP flag, but if that's unpalatable for
> > the mm folks then something like the below might work. It should be
> > similar in effect to your proposal, except its more limited in scope.
> [...]
> > @@ -2876,11 +2883,36 @@ static void __lockdep_trace_alloc(gfp_t gfp_mask, unsigned long flags)
> >  	if (DEBUG_LOCKS_WARN_ON(irqs_disabled_flags(flags)))
> >  		return;
> >  
> > +	/*
> > +	 * Skip _one_ allocation as per the lockdep_skip_alloc() request.
> > +	 * Must be done last so that we don't loose the annotation for
> > +	 * GFP_ATOMIC like things from IRQ or other nesting contexts.
> > +	 */
> > +	if (current->lockdep_reclaim_gfp & __GFP_SKIP_ALLOC) {
> > +		current->lockdep_reclaim_gfp &= ~__GFP_SKIP_ALLOC;
> > +		return;
> > +	}
> > +
> >  	mark_held_locks(curr, RECLAIM_FS);
> >  }
> 
> I might be missing something but does this work actually? Say you would
> want a kmalloc(size), it would call
> slab_alloc_node
>   slab_pre_alloc_hook
>     lockdep_trace_alloc
> [...]
>   ____cache_alloc_node
>     cache_grow_begin
>       kmem_getpages
>         __alloc_pages_node
> 	  __alloc_pages_nodemask
> 	    lockdep_trace_alloc

Bugger :/ You're right, that would fail.

So how about doing:

#define __GFP_NOLOCKDEP	(1u << __GFP_BITS_SHIFT)

this means it cannot be part of address_space::flags or
radix_tree_root::gfp_mask, but that might not be a bad thing.

And this solves the scarcity thing, because per pagemap we need to have
5 'spare' bits anyway.

> I understand your concerns about the scope but usually all allocations
> have to be __GFP_NOFS or none in the same scope so I would see it as a
> huge deal.

With scope I mostly meant the fact that you have two calls that you need
to pair up. That's not really nice as you can 'annotate' a _lot_ of code
in between. I prefer the narrower annotations where you annotate a
single specific site.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
