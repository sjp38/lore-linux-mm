Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9008A900015
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 04:40:25 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so7796126wid.5
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 01:40:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id li6si40042013wjb.193.2015.02.19.01.40.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Feb 2015 01:40:23 -0800 (PST)
Date: Thu, 19 Feb 2015 10:40:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150219094020.GE28427@dhcp22.suse.cz>
References: <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150218082502.GA4478@dhcp22.suse.cz>
 <20150218104859.GM12722@dastard>
 <20150218121602.GC4478@dhcp22.suse.cz>
 <20150218213118.GN12722@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150218213118.GN12722@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Thu 19-02-15 08:31:18, Dave Chinner wrote:
> On Wed, Feb 18, 2015 at 01:16:02PM +0100, Michal Hocko wrote:
> > On Wed 18-02-15 21:48:59, Dave Chinner wrote:
> > > On Wed, Feb 18, 2015 at 09:25:02AM +0100, Michal Hocko wrote:
> > > > On Wed 18-02-15 09:54:30, Dave Chinner wrote:
> > [...]
> > > Also, this reads as an excuse for the OOM killer being broken and
> > > not fixing it.  Keep in mind that we tell the memory alloc/reclaim
> > > subsystem that *we hold locks* when we call into it. That's what
> > > GFP_NOFS originally meant, and it's what it still means today in an
> > > XFS context.
> > 
> > Sure, and OOM killer will not be invoked in NOFS context. See
> > __alloc_pages_may_oom and __GFP_FS check in there. So I do not see where
> > is the OOM killer broken.
> 
> I suspect that the page cache missing the correct GFP_NOFS was one
> of the sources of the problems I've been seeing.
> 
> However, the oom killer exceptions are not checked if __GFP_NOFAIL

Yes this is true. This is an effect of 9879de7373fc (mm: page_alloc:
embed OOM killing naturally into allocation slowpath) and IMO a
desirable one. Requiring infinite retrying with a seriously restricted
reclaim context calls for troubles (e.g. livelock without no way out
because regular reclaim cannot make any progress and OOM killer as the
last resort will not happen).

> is present and so if we start using __GFP_NOFAIL then it will be
> called in GFP_NOFS contexts...
> 
> > The crucial problem we are dealing with is not GFP_NOFAIL triggering the
> > OOM killer but a lock dependency introduced by the following sequence:
> > 
> > 	taskA			taskB			taskC
> > lock(A)							alloc()
> > alloc(gfp | __GFP_NOFAIL)	lock(A)			  out_of_memory
> > # looping for ever if we				    select_bad_process
> > # cannot make any progress				      victim = taskB
> > 
> > There is no way OOM killer can tell taskB is blocked and that there is
> > dependency between A and B (without lockdep). That is why I call NOFAIL
> > under a lock as dangerous and a bug.
> 
> Sure. However, eventually the OOM killer with select task A to be
> killed because nothing else is working.

That would require OOM killer to be able to select another victim while
the current one is still alive. There were time based heuristics
suggested to do this but I do not think they are the right way to handle
the problem and should be considered only if all other options fail.

One potential way would be giving access to give GFP_NOFAIL context
access to memory reserves when the allocation domain
(global/memcg/cpuset) is OOM. Andrea was suggesting something like that
IIRC.

> That, at least, marks
> taskA with TIF_MEMDIE and gives us a potential way to break the
> deadlock.
> 
> But the bigger problem is this:
> 
> 	taskA			taskB
> lock(A)
> alloc(GFP_NOFS|GFP_NOFAIL)		lock(A)
>   out_of_memory
>     select_bad_process
>       victim = taskB
> 
> Because there is no way to *ever* resolve that dependency because
> taskA never leaves the allocator. Even if the oom killer selects
> taskA and set TIF_MEMDIE on it, the allocator ignores TIF_MEMDIE
> because GFP_NOFAIL is set and continues to loop.

TIF_MEMDIE will at least give the task access to memory reserves. Anyway
this is essentially the same category of livelock as above.

> This is why GFP_NOFAIL is not a solution to the "never fail"
> alloation problem. The caller doing the "no fail" allocation _must
> be able to set failure policy_. i.e. the choice of aborting and
> shutting down because progress cannot be made, or continuing and
> hoping for forwards progress is owned by the allocating context, no
> the allocator.

I completely agree that the failure policy is the caller responsibility
and I would have no objections to something like:

	do {
		ptr = kmalloc(size, GFP_NOFS);
		if (ptr)
			return ptr;
		if (fatal_signal_pending(current))
			break;
		if (looping_too_long())
			break;
	} while (1);

	fallback_solution();

But this is not the case in kmem_alloc which is essentially GFP_NOFAIL
allocation with a warning and congestion_wait. There is no failure
policy defined there. The warning should be part of the allocator and
the NOFAIL policy should be explicit. So why exactly do you oppose to
changing kmem_alloc (and others which are doing essentially the same)?

> The memory allocation subsystem cannot make that
> choice for us as it has no concept of the failure characteristics of
> the allocating context.

Of course. I wasn't arguing we should change allocation loops which have
a fallback policy as well. That is an entirely different thing. My point
was we want to turn GFP_NOFAIL equivalents to use GFP_NOFAIL so that the
allocator can prevent from livelocks if possible.

> The situations in which this actually matters are extremely *rare* -
> we've had these allocaiton loops in XFS for > 13 years, and we might
> get a one or two reports a year of these "possible allocation
> deadlock" messages occurring. Changing *everything* for such a rare,
> unusual event is not an efficient use of time or resources.
> 
> > > If the OOM killer is not obeying GFP_NOFS and deadlocking on locks
> > > that the invoking context holds, then that is a OOM killer bug, not
> > > a bug in the subsystem calling kmalloc(GFP_NOFS).
> > 
> > I guess we are talking about different things here or what am I missing?
> 
> From my perspective, you are tightly focussed on one aspect of the
> problem and hence are not seeing the bigger picture: this is a
> corner case of behaviour in a "last hope", brute force memory
> reclaim technique that no production machine relies on for correct
> or performant operation.

Of course this is a corner case. And I am trying to prevent heuristics
which would optimize for such a corner case (there were multiple of
them suggested in this thread).

The reason I care about GFP_NOFAIL is that there are apparently code
paths which do not tell allocator they are basically GFP_NOFAIL without
any fallback. This leads to two main problems 1) we do not have a good
overview how many code paths have such a strong requirements and so
cannot estimate e.g. how big memory reserves should be and 2) allocator
cannot help those paths (e.g. by giving them access to reserves to break
out of the livelock).

> > [...]
> > > > In the meantime page allocator
> > > > should develop a proper diagnostic to help identify all the potential
> > > > dependencies. Next we should start thinking whether all the existing
> > > > GFP_NOFAIL paths are really necessary or the code can be
> > > > refactored/reimplemented to accept allocation failures.
> > > 
> > > Last time the "just make filesystems handle memory allocation
> > > failures" I pointed out what that meant for XFS: dirty transaction
> > > rollback is required. That's freakin' complex, will double the
> > > memory footprint of transactions, roughly double the CPU cost, and
> > > greatly increase the complexity of the transaction subsystem. It's a
> > > *major* rework of a significant amount of the XFS codebase and will
> > > take at least a couple of years design, test and stabilise before
> > > it could be rolled out to production.
> > > 
> > > I'm not about to spend a couple of years rewriting XFS just so the
> > > VM can get rid of a GFP_NOFAIL user. Especially as the we already
> > > tell the Hammer of Last Resort the context in which it can work.
> > > 
> > > Move the OOM killer to kswapd - get it out of the direct reclaim
> > > path altogether.
> > 
> > This doesn't change anything as explained in other email. The triggering
> > path doesn't wait for the victim to die.
> 
> But it does - we wouldn't be talking about deadlocks if there were
> no blocking dependencies. In this case, allocation keeps retrying
> until the memory freed by the killed tasks enables it to make
> forward progress. That's a side effect of the last relevation that
> was made in this thread that low order allocations never fail...

Sure, low order allocations being almost GFP_NOFAIL makes things much
worse of course. And this should be changed. We just have to think about
the way how to do it without breaking the universe. I hope we can
discuss this at LSF.

But even then I do not see how triggering the OOM killer from kswapd
would help here. Victims would be looping in the allocator whether the
actual killing happens from their or any other context.

> > > If the system is that backed up on locks that it
> > > cannot free any memory and has no reserves to satisfy the allocation
> > > that kicked the OOM killer, then the OOM killer was not invoked soon
> > > enough.
> > > 
> > > Hell, if you want a better way to proceed, then how about you allow
> > > us to tell the MM subsystem how much memory reserve a specific set
> > > of operations is going to require to complete? That's something that
> > > we can do rough calculations for, and it integrates straight into
> > > the existing transaction reservation system we already use for log
> > > space and disk space, and we can tell the mm subsystem when the
> > > reserve is no longer needed (i.e. last thing in transaction commit).
> > > 
> > > That way we don't start a transaction until the mm subsystem has
> > > reserved enough pages for us to work with, and the reserve only
> > > needs to be used when normal allocation has already failed. i.e
> > > rather than looping we get a page allocated from the reserve pool.
> > 
> > I am not sure I understand the above but isn't the mempools a tool for
> > this purpose?
> 
> I knew this question would be the next one - I even deleted a one
> line comment from my last email that said "And no, mempools are not
> a solution" because that needs a more thorough explanation than a
> dismissive one-liner.
> 
> As you know, mempools require a forward progress guarantee on a
> single type of object and the objects must be slab based.
> 
> In transaction context we allocate from inode slabs, xfs_buf slabs,
> log item slabs (6 different ones, IIRC), btree cursor slabs, etc,
> but then we also have direct page allocations for buffers, vm_map_ram()
> for mapping multi-page buffers, uncounted heap allocations, etc.
> We cannot make all of these mempools, nor can me meet the forwards
> progress requirements of a mempool because other allocations can
> block and prevent progress.
> 
> Further, the object have lifetimes that don't correspond to the
> transaction life cycles, and hence even if we complete the
> transaction there is no guarantee that the objects allocated within
> a transaction are going to be returned to the mempool at it's
> completion.
> 
> IOWs, we have need for forward allocation progress guarantees on
> (potentially) several megabytes of allocations from slab caches, the
> heap and the page allocator, with all allocations all in
> unpredictable order, with objects of different life times and life
> cycles, and at which may, at any time, get stuck behind
> objects locked in other transactions and hence can randomly block
> until some other thread makes forward progress and completes a
> transaction and unlocks the object.

Thanks for the clarification, I have to think about it some more,
though. My thinking was that mempools could be used for an emergency
pool with a pre-allocated memory which would be used in the non failing
contexts.

> The reservation would only need to cover the memory we need to
> allocate and hold in the transaction (i.e. dirtied objects). There
> is potentially unbound amounts of memory required through demand
> paging of buffers to find the metadata we need to modify, but demand
> paged metadata that is read and then released is recoverable. i.e
> the shrinkers will free it as other memory demand requires, so it's
> not included in reservation pools because it doesn't deplete the
> amount of free memory.
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
