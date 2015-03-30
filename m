Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 14FD96B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 15:31:36 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so144137027wib.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 12:31:35 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h6si19832054wjf.31.2015.03.30.12.31.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 12:31:34 -0700 (PDT)
Date: Mon, 30 Mar 2015 15:31:18 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 00/12] mm: page_alloc: improve OOM mechanism and policy
Message-ID: <20150330193118.GA27167@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <20150326195822.GB28129@dastard>
 <20150327150509.GA21119@cmpxchg.org>
 <20150330003240.GB28621@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150330003240.GB28621@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

On Mon, Mar 30, 2015 at 11:32:40AM +1100, Dave Chinner wrote:
> On Fri, Mar 27, 2015 at 11:05:09AM -0400, Johannes Weiner wrote:
> > GFP_NOFS sites are currently one of the sites that can deadlock inside
> > the allocator, even though many of them seem to have fallback code.
> > My reasoning here is that if you *have* an exit strategy for failing
> > allocations that is smarter than hanging, we should probably use that.
> 
> We already do that for allocations where we can handle failure in
> GFP_NOFS conditions. It is, however, somewhat useless if we can't
> tell the allocator to try really hard if we've already had a failure
> and we are already in memory reclaim conditions (e.g. a shrinker
> trying to clean dirty objects so they can be reclaimed).

What do you mean you already do that?  These allocations currently
won't fail.  They loop forever in the allocator.  Fallback code is
dead code right now.  (Unless you do order-4 and up, which I doubt.)

> From that perspective, I think that this patch set aims force us
> away from handling fallbacks ourselves because a) it makes GFP_NOFS
> more likely to fail, and b) provides no mechanism to "try harder"
> when we really need the allocation to succeed.

If by "more likely" you mean "at all possible", then yes.

However, as far as trying harder goes, that sounds like a good idea.
It should be possible for NOFS contexts to use the OOM killer and its
reserves.  But still, they should be allowed to propagate allocation
failures rather than just hanging in the allocator.

> > > >  mm: page_alloc: emergency reserve access for __GFP_NOFAIL allocations
> > > > 
> > > > An exacerbation of the victim-stuck-behind-allocation scenario are
> > > > __GFP_NOFAIL allocations, because they will actually deadlock.  To
> > > > avoid this, or try to, give __GFP_NOFAIL allocations access to not
> > > > just the OOM reserves but also the system's emergency reserves.
> > > > 
> > > > This is basically a poor man's reservation system, which could or
> > > > should be replaced later on with an explicit reservation system that
> > > > e.g. filesystems have control over for use by transactions.
> > > > 
> > > > It's obviously not bulletproof and might still lock up, but it should
> > > > greatly reduce the likelihood.  AFAIK Andrea, whose idea this was, has
> > > > been using this successfully for some time.
> > > 
> > > So, if we want GFP_NOFS allocations to be able to dip into a
> > > small extra reservation to make progress at ENOMEM, we have to use
> > > use __GFP_NOFAIL because looping ourselves won't allow use of these
> > > extra reserves?
> > 
> > As I said, this series is not about providing reserves just yet.  It
> > is about using the fallback strategies you already implemented.  And
> > where you don't have any, it's about making the allocator's last way
> > of forward progress, the OOM killer, more reliable.
> 
> Sure - but you're doing that by adding a special reserve for
> GFP_NOFAIL allocations to dip into when the OOM killer is active.
> That can only be accessed by GFP_NOFAIL allocations - anyone who
> has a fallback but really needs the allocation to succeed if at all
> possible (i.e. should only fail to avoid a deadlock situation) can't
> communicate that fact to the allocator....

Hm?  It's not restricted to NOFAIL at all, look closer at my patch
series.  What you are describing is exactly how I propose the
allocator should handle all regular allocations: exhaust reclaimable
pages, use the OOM killer, dip into OOM reserves, but ultimately fail.
The only thing __GFP_NOFAIL does in *addition* to that is use the last
emergency reserves of the system in an attempt to avoid deadlocking.

[ Once those reserves are depleted, however, the system will deadlock,
  so we can only give them to allocations that would otherwise lock up
  anyway, i.e. __GFP_NOFAIL.  It would be silly to risk a system
  deadlock for an allocation that has a fallback strategy.  That is
  why you have to let the allocator know whether you can fall back. ]

The notable exception to this behavior are NOFS callers because of its
current OOM kill restrictions.  But as I said, I'm absolutely open to
addressing this and either let them generally use the OOM killer after
some time, or provide you with another annotation that lets you come
back to try harder.  I don't really care which way, that depends on
your requirements.

> > > > This patch makes NOFS allocations fail if reclaim can't free anything.
> > > > 
> > > > It would be good if the filesystem people could weigh in on whether
> > > > they can deal with failing GFP_NOFS allocations, or annotate the
> > > > exceptions with __GFP_NOFAIL etc.  It could well be that a middle
> > > > ground is required that allows using the OOM killer before giving up.
> > > 
> > > ... which looks to me like a catch-22 situation for us: We
> > > have reserves, but callers need to use __GFP_NOFAIL to access them.
> > > GFP_NOFS is going to fail more often, so callers need to handle that
> > > in some way, either by looping or erroring out.
> > > 
> > > But if we loop manually because we try to handle ENOMEM situations
> > > gracefully (e.g. try a number of times before erroring out) we can't
> > > dip into the reserves because the only semantics being provided are
> > > "try-once-without-reserves" or "try-forever-with-reserves".  i.e.
> > > what we actually need here is "try-once-with-reserves" semantics so
> > > that we can make progress after a failing GFP_NOFS
> > > "try-once-without-reserves" allocation.
> > >
> > > IOWS, __GFP_NOFAIL is not the answer here - it's GFP_NOFS |
> > > __GFP_USE_RESERVE that we need on the failure fallback path. Which,
> > > incidentally, is trivial to add to the XFS allocation code. Indeed,
> > > I'll request that you test series like this on metadata intensive
> > > filesystem workloads on XFS under memory stress and quantify how
> > > many new "XFS: possible deadlock in memory allocation" warnings are
> > > emitted. If the patch set floods the system with such warnings, then
> > > it means the proposed means the fallback for "caller handles
> > > allocation failure" is not making progress.
> > 
> > Again, we don't have reserves with this series, we only have a small
> > pool to compensate for OOM kills getting stuck behind the allocation.
> 
> Which is, in effect, a reserve pool to make progress and prevent
> deadlocks.

No, it's absolutely not.  They are meant to serve single allocations
when the allocation contexts themselves are blocking the OOM killer.
They can not guarantee forward progress for a series of allocations
from a single context, because they are not sized to that worst case.

This is is only about increasing the probability of success.  In terms
of semantics, nothing has changed: our only options continue to be to
either fail an allocation or risk deadlocking it.

> > They are an extension of the OOM killer that can not live on their own
> > right now, so the best we could do at this point is give you a way to
> > annotate NOFS allocations to OOM kill (and then try the OOM reserves)
> > before failing the allocation.
> 
> Well, yes, that's exactly what I'm saying we need, especially if you
> are making GFP_NOFS more likely to fail. And the patchset that makes
> GFP_NOFS more likely to fail also needs to add those "retry harder"
> flags to subsystems that are adversely affected by making GFP_NOFS
> fail more easily.

Okay, I think we agree on that.

> > However, since that can still fail, what would be your ultimate course
> > of action?
> 
> Ultimately, that is my problem and not yours. The allocation/reclaim
> subsystem provides mechanism, not policy.

I'm trying to hand back that control to you, but that means you have
to actually deal with allocation failures and not just emit warnings
in an endless loop.  In case of a deadlock, simply retrying without
dropping any locks doesn't magically make the allocation work, so
whether you warn after one or after 1000 loops doesn't matter.

You can see how it could be hard to sanitize the allocator behavior
when your proposed litmus test punishes the allocator for propagating
an allocation failure, and rewards hanging in the allocator instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
