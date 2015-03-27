Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB1C6B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 11:05:23 -0400 (EDT)
Received: by wgra20 with SMTP id a20so102057882wgr.3
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 08:05:23 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o7si3682965wiv.59.2015.03.27.08.05.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 08:05:21 -0700 (PDT)
Date: Fri, 27 Mar 2015 11:05:09 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 00/12] mm: page_alloc: improve OOM mechanism and policy
Message-ID: <20150327150509.GA21119@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <20150326195822.GB28129@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326195822.GB28129@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

On Fri, Mar 27, 2015 at 06:58:22AM +1100, Dave Chinner wrote:
> On Wed, Mar 25, 2015 at 02:17:04AM -0400, Johannes Weiner wrote:
> > Hi everybody,
> > 
> > in the recent past we've had several reports and discussions on how to
> > deal with allocations hanging in the allocator upon OOM.
> > 
> > The idea of this series is mainly to make the mechanism of detecting
> > OOM situations reliable enough that we can be confident about failing
> > allocations, and then leave the fallback strategy to the caller rather
> > than looping forever in the allocator.
> > 
> > The other part is trying to reduce the __GFP_NOFAIL deadlock rate, at
> > least for the short term while we don't have a reservation system yet.
> 
> A valid goal, but I think this series goes about it the wrong way.
> i.e. it forces us to use __GFP_NOFAIL rather than providing us a
> valid fallback mechanism to access reserves.

I think you misunderstood the goal.

While I agree that reserves would be the optimal fallback strategy,
this series is about avoiding deadlocks in existing callsites that
currently can not fail.  This is about getting the best out of our
existing mechanisms until we have universal reservation coverage,
which will take time to devise and transition our codebase to.

GFP_NOFS sites are currently one of the sites that can deadlock inside
the allocator, even though many of them seem to have fallback code.
My reasoning here is that if you *have* an exit strategy for failing
allocations that is smarter than hanging, we should probably use that.

> >  mm: page_alloc: emergency reserve access for __GFP_NOFAIL allocations
> > 
> > An exacerbation of the victim-stuck-behind-allocation scenario are
> > __GFP_NOFAIL allocations, because they will actually deadlock.  To
> > avoid this, or try to, give __GFP_NOFAIL allocations access to not
> > just the OOM reserves but also the system's emergency reserves.
> > 
> > This is basically a poor man's reservation system, which could or
> > should be replaced later on with an explicit reservation system that
> > e.g. filesystems have control over for use by transactions.
> > 
> > It's obviously not bulletproof and might still lock up, but it should
> > greatly reduce the likelihood.  AFAIK Andrea, whose idea this was, has
> > been using this successfully for some time.
> 
> So, if we want GFP_NOFS allocations to be able to dip into a
> small extra reservation to make progress at ENOMEM, we have to use
> use __GFP_NOFAIL because looping ourselves won't allow use of these
> extra reserves?

As I said, this series is not about providing reserves just yet.  It
is about using the fallback strategies you already implemented.  And
where you don't have any, it's about making the allocator's last way
of forward progress, the OOM killer, more reliable.

If you have an allocation site that is endlessly looping around calls
to the allocator, it means you DON'T have a fallback strategy.  In
that case, it would be in your interest to tell the allocator, such
that it can take measures to break the infinite loop.

However, those measures are not without their own risk and they need
to be carefully sequenced to reduce the risk for deadlocks.  E.g. we
can not give __GFP_NOFAIL allocations access to the statically-sized
emergency reserves without taking steps to free memory at the same
time, because then we'd just trade forward progress of that allocation
against forward progress of some memory reclaimer later on which finds
the emergency reserves exhausted.

> >  mm: page_alloc: do not lock up GFP_NOFS allocations upon OOM
> > 
> > Another hang that was reported was from NOFS allocations.  The trouble
> > with these is that they can't issue or wait for writeback during page
> > reclaim, and so we don't want to OOM kill on their behalf.  However,
> > with such restrictions on making progress, they are prone to hangs.
> 
> And because this effectively means GFP_NOFS allocations are
> going to fail much more often, we're either going to have to loop
> ourselves or use __GFP_NOFAIL...
> 
> > This patch makes NOFS allocations fail if reclaim can't free anything.
> > 
> > It would be good if the filesystem people could weigh in on whether
> > they can deal with failing GFP_NOFS allocations, or annotate the
> > exceptions with __GFP_NOFAIL etc.  It could well be that a middle
> > ground is required that allows using the OOM killer before giving up.
> 
> ... which looks to me like a catch-22 situation for us: We
> have reserves, but callers need to use __GFP_NOFAIL to access them.
> GFP_NOFS is going to fail more often, so callers need to handle that
> in some way, either by looping or erroring out.
> 
> But if we loop manually because we try to handle ENOMEM situations
> gracefully (e.g. try a number of times before erroring out) we can't
> dip into the reserves because the only semantics being provided are
> "try-once-without-reserves" or "try-forever-with-reserves".  i.e.
> what we actually need here is "try-once-with-reserves" semantics so
> that we can make progress after a failing GFP_NOFS
> "try-once-without-reserves" allocation.
>
> IOWS, __GFP_NOFAIL is not the answer here - it's GFP_NOFS |
> __GFP_USE_RESERVE that we need on the failure fallback path. Which,
> incidentally, is trivial to add to the XFS allocation code. Indeed,
> I'll request that you test series like this on metadata intensive
> filesystem workloads on XFS under memory stress and quantify how
> many new "XFS: possible deadlock in memory allocation" warnings are
> emitted. If the patch set floods the system with such warnings, then
> it means the proposed means the fallback for "caller handles
> allocation failure" is not making progress.

Again, we don't have reserves with this series, we only have a small
pool to compensate for OOM kills getting stuck behind the allocation.
They are an extension of the OOM killer that can not live on their own
right now, so the best we could do at this point is give you a way to
annotate NOFS allocations to OOM kill (and then try the OOM reserves)
before failing the allocation.

However, since that can still fail, what would be your ultimate course
of action?  The reason I'm asking is because the message you are
quoting is from this piece of code:

void *
kmem_alloc(size_t size, xfs_km_flags_t flags)
{
	int	retries = 0;
	gfp_t	lflags = kmem_flags_convert(flags);
	void	*ptr;

	do {
		ptr = kmalloc(size, lflags);
		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
			return ptr;
		if (!(++retries % 100))
			xfs_err(NULL,
		"possible memory allocation deadlock in %s (mode:0x%x)",
					__func__, lflags);
		congestion_wait(BLK_RW_ASYNC, HZ/50);
	} while (1);
}

and that does not implement a fallback strategy.  The only way to not
trigger those warnings is continuing to loop in the allocator, so you
might as well use __GFP_NOFAIL here.  This is not the sort of callsite
that "mm: page_alloc: do not lock up GFP_NOFS allocations upon OOM"
had in mind, because it will continue to lock up on OOM either way.
Only instead of in the allocator, it will lock up in the xfs code.

This is a NOFAIL caller, so it would benefit from those changes in the
series that make __GFP_NOFAIL more reliable.

But what about your other NOFS callers?  Are there any that have
actual fallback code?  Those that the allocator should fail rather
than hang if it runs out of memory?  Those are what 11/12 is about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
