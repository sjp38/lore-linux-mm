Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1863D6B0083
	for <linux-mm@kvack.org>; Sun, 29 Mar 2015 20:32:47 -0400 (EDT)
Received: by pacgg7 with SMTP id gg7so21413260pac.0
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 17:32:46 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id bk2si12396090pbd.70.2015.03.29.17.32.44
        for <linux-mm@kvack.org>;
        Sun, 29 Mar 2015 17:32:45 -0700 (PDT)
Date: Mon, 30 Mar 2015 11:32:40 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch 00/12] mm: page_alloc: improve OOM mechanism and policy
Message-ID: <20150330003240.GB28621@dastard>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <20150326195822.GB28129@dastard>
 <20150327150509.GA21119@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150327150509.GA21119@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

On Fri, Mar 27, 2015 at 11:05:09AM -0400, Johannes Weiner wrote:
> On Fri, Mar 27, 2015 at 06:58:22AM +1100, Dave Chinner wrote:
> > On Wed, Mar 25, 2015 at 02:17:04AM -0400, Johannes Weiner wrote:
> > > Hi everybody,
> > > 
> > > in the recent past we've had several reports and discussions on how to
> > > deal with allocations hanging in the allocator upon OOM.
> > > 
> > > The idea of this series is mainly to make the mechanism of detecting
> > > OOM situations reliable enough that we can be confident about failing
> > > allocations, and then leave the fallback strategy to the caller rather
> > > than looping forever in the allocator.
> > > 
> > > The other part is trying to reduce the __GFP_NOFAIL deadlock rate, at
> > > least for the short term while we don't have a reservation system yet.
> > 
> > A valid goal, but I think this series goes about it the wrong way.
> > i.e. it forces us to use __GFP_NOFAIL rather than providing us a
> > valid fallback mechanism to access reserves.
> 
> I think you misunderstood the goal.
> 
> While I agree that reserves would be the optimal fallback strategy,
> this series is about avoiding deadlocks in existing callsites that
> currently can not fail.  This is about getting the best out of our
> existing mechanisms until we have universal reservation coverage,
> which will take time to devise and transition our codebase to.

That might be the goal, but it looks like the wrong path to me.

> GFP_NOFS sites are currently one of the sites that can deadlock inside
> the allocator, even though many of them seem to have fallback code.
> My reasoning here is that if you *have* an exit strategy for failing
> allocations that is smarter than hanging, we should probably use that.

We already do that for allocations where we can handle failure in
GFP_NOFS conditions. It is, however, somewhat useless if we can't
tell the allocator to try really hard if we've already had a failure
and we are already in memory reclaim conditions (e.g. a shrinker
trying to clean dirty objects so they can be reclaimed).

>From that perspective, I think that this patch set aims force us
away from handling fallbacks ourselves because a) it makes GFP_NOFS
more likely to fail, and b) provides no mechanism to "try harder"
when we really need the allocation to succeed.

> > >  mm: page_alloc: emergency reserve access for __GFP_NOFAIL allocations
> > > 
> > > An exacerbation of the victim-stuck-behind-allocation scenario are
> > > __GFP_NOFAIL allocations, because they will actually deadlock.  To
> > > avoid this, or try to, give __GFP_NOFAIL allocations access to not
> > > just the OOM reserves but also the system's emergency reserves.
> > > 
> > > This is basically a poor man's reservation system, which could or
> > > should be replaced later on with an explicit reservation system that
> > > e.g. filesystems have control over for use by transactions.
> > > 
> > > It's obviously not bulletproof and might still lock up, but it should
> > > greatly reduce the likelihood.  AFAIK Andrea, whose idea this was, has
> > > been using this successfully for some time.
> > 
> > So, if we want GFP_NOFS allocations to be able to dip into a
> > small extra reservation to make progress at ENOMEM, we have to use
> > use __GFP_NOFAIL because looping ourselves won't allow use of these
> > extra reserves?
> 
> As I said, this series is not about providing reserves just yet.  It
> is about using the fallback strategies you already implemented.  And
> where you don't have any, it's about making the allocator's last way
> of forward progress, the OOM killer, more reliable.

Sure - but you're doing that by adding a special reserve for
GFP_NOFAIL allocations to dip into when the OOM killer is active.
That can only be accessed by GFP_NOFAIL allocations - anyone who
has a fallback but really needs the allocation to succeed if at all
possible (i.e. should only fail to avoid a deadlock situation) can't
communicate that fact to the allocator....

....

> > > This patch makes NOFS allocations fail if reclaim can't free anything.
> > > 
> > > It would be good if the filesystem people could weigh in on whether
> > > they can deal with failing GFP_NOFS allocations, or annotate the
> > > exceptions with __GFP_NOFAIL etc.  It could well be that a middle
> > > ground is required that allows using the OOM killer before giving up.
> > 
> > ... which looks to me like a catch-22 situation for us: We
> > have reserves, but callers need to use __GFP_NOFAIL to access them.
> > GFP_NOFS is going to fail more often, so callers need to handle that
> > in some way, either by looping or erroring out.
> > 
> > But if we loop manually because we try to handle ENOMEM situations
> > gracefully (e.g. try a number of times before erroring out) we can't
> > dip into the reserves because the only semantics being provided are
> > "try-once-without-reserves" or "try-forever-with-reserves".  i.e.
> > what we actually need here is "try-once-with-reserves" semantics so
> > that we can make progress after a failing GFP_NOFS
> > "try-once-without-reserves" allocation.
> >
> > IOWS, __GFP_NOFAIL is not the answer here - it's GFP_NOFS |
> > __GFP_USE_RESERVE that we need on the failure fallback path. Which,
> > incidentally, is trivial to add to the XFS allocation code. Indeed,
> > I'll request that you test series like this on metadata intensive
> > filesystem workloads on XFS under memory stress and quantify how
> > many new "XFS: possible deadlock in memory allocation" warnings are
> > emitted. If the patch set floods the system with such warnings, then
> > it means the proposed means the fallback for "caller handles
> > allocation failure" is not making progress.
> 
> Again, we don't have reserves with this series, we only have a small
> pool to compensate for OOM kills getting stuck behind the allocation.

Which is, in effect, a reserve pool to make progress and prevent
deadlocks.

> They are an extension of the OOM killer that can not live on their own
> right now, so the best we could do at this point is give you a way to
> annotate NOFS allocations to OOM kill (and then try the OOM reserves)
> before failing the allocation.

Well, yes, that's exactly what I'm saying we need, especially if you
are making GFP_NOFS more likely to fail. And the patchset that makes
GFP_NOFS more likely to fail also needs to add those "retry harder"
flags to subsystems that are adversely affected by making GFP_NOFS
fail more easily.

> However, since that can still fail, what would be your ultimate course
> of action?

Ultimately, that is my problem and not yours. The allocation/reclaim
subsystem provides mechanism, not policy.

> The reason I'm asking is because the message you are
> quoting is from this piece of code:
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
> and that does not implement a fallback strategy.

You're wrong - there's a clear fallback strategy in that code.

Look at the ((flags & (KM_MAYFAIL|KM_NOSLEEP)) check - KM_MAYFAIL is
the *XFS annotation* that tells the *XFS allocator* that failure can
be handled by the caller. There are quite a few places where it is
used and we are slowly adding more as we add code to handle ENOMEM
into the higher layers of XFS.

Indeed, a prime example is this code in xfs_iflush_cluster():

	ilist = kmem_alloc(ilist_size, KM_MAYFAIL|KM_NOFS);
	if (!ilist)
		goto out_put;

That allocation context is used because it can be called by the
inode reclaim shrinker to clean dirty inodes that need to be
reclaimed. We need to be in GFP_NOFS context because we can't
recurse into FS reclaim again, but we can allow failures because the
shrinker will come back and try to reclaim the inode again later.

i.e. this is a case where we are using GFP_NOFS to prevent reclaim
recursion deadlocks rather than a place where we are using GFP_NOFS
because we hold filesystem locks or are in a filesystem transaction
context.

However, because of it's context in the memory reclaim path, we need
to be able to make use of all possible memory reserves here because
the only memory that is reclaimable might be dirty inodes that need
writeback. Hence making GFP_NOFS allocations fail more easily will
make it harder to write back dirty inodes when there is severe
memory pressure. Therefore we really need to be able to fail, then
try harder (i.e. the "use oom reserves" falgs), and then if that
fails we then return failure.

FWIW, in the IRC discussion on #xfs between xfs developers, we
talked about configurable error behaviour (e.g thru sysfs) for
handling different types of errors. That came about through this RFC
for handling IO errors in different ways (e.g. for optimising error
handling on thinp devices):

http://oss.sgi.com/archives/xfs/2015-02/msg00343.html

ENOMEM handling was another error we talked about in this context,
allowing the admin of the system to determine how many allocation
retries should be allowed before we consider the allocation a
"failed" and hence should fail and shutdown the fs rather than try
forever. Hence admins can chose to loop forever and hope that it
doesn't deadlock, or if deadlocks are occurring they can be broken
by allowing the fs to fail and potentially shut down. i.e. the admin
can chose the lesser evil for their production system workloads....

i.e. yet another potential fallback strategy, but one that is also
reliant on being able to ask the mm subsytem to only fail if there
really is no memory available at all....

> The only way to not
> trigger those warnings is continuing to loop in the allocator, so you
> might as well use __GFP_NOFAIL here.

You're assuming we want those warnings to go away. We don't - we
want to see those warnings because it's a telltale sign to XFS
developers during problem triage that low memory problems are
occuring and may be caused by or related to filesystem issues...

> This is not the sort of callsite
> that "mm: page_alloc: do not lock up GFP_NOFS allocations upon OOM"
> had in mind, because it will continue to lock up on OOM either way.
> Only instead of in the allocator, it will lock up in the xfs code.

Precisely why I said that you need to test changes like like this
against filesystem workloads to determine if you're making things
worse or not. Changing GFP_NOFS allocation behaviour will have
unexpected side effects for a lot of people and subsystems, so it
should not be done without a *lot* of testing....

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
