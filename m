Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 88BF86B0032
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 06:36:38 -0400 (EDT)
Received: by wiun10 with SMTP id n10so16291772wiu.1
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 03:36:38 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bh9si1125838wjb.19.2015.04.14.03.36.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 03:36:37 -0700 (PDT)
Date: Tue, 14 Apr 2015 06:36:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 00/12] mm: page_alloc: improve OOM mechanism and policy
Message-ID: <20150414103625.GA26264@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <20150326195822.GB28129@dastard>
 <20150327150509.GA21119@cmpxchg.org>
 <20150330003240.GB28621@dastard>
 <20150401151920.GB23824@dhcp22.suse.cz>
 <20150407141822.GA3262@cmpxchg.org>
 <20150413124614.GA21790@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150413124614.GA21790@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Mon, Apr 13, 2015 at 02:46:14PM +0200, Michal Hocko wrote:
> [Sorry for a late reply]
> 
> On Tue 07-04-15 10:18:22, Johannes Weiner wrote:
> > On Wed, Apr 01, 2015 at 05:19:20PM +0200, Michal Hocko wrote:
> > > On Mon 30-03-15 11:32:40, Dave Chinner wrote:
> > > > On Fri, Mar 27, 2015 at 11:05:09AM -0400, Johannes Weiner wrote:
> > > [...]
> > > > > GFP_NOFS sites are currently one of the sites that can deadlock inside
> > > > > the allocator, even though many of them seem to have fallback code.
> > > > > My reasoning here is that if you *have* an exit strategy for failing
> > > > > allocations that is smarter than hanging, we should probably use that.
> > > > 
> > > > We already do that for allocations where we can handle failure in
> > > > GFP_NOFS conditions. It is, however, somewhat useless if we can't
> > > > tell the allocator to try really hard if we've already had a failure
> > > > and we are already in memory reclaim conditions (e.g. a shrinker
> > > > trying to clean dirty objects so they can be reclaimed).
> > > > 
> > > > From that perspective, I think that this patch set aims force us
> > > > away from handling fallbacks ourselves because a) it makes GFP_NOFS
> > > > more likely to fail, and b) provides no mechanism to "try harder"
> > > > when we really need the allocation to succeed.
> > > 
> > > You can ask for this "try harder" by __GFP_HIGH flag. Would that help
> > > in your fallback case?
> > 
> > I would think __GFP_REPEAT would be more suitable here.  From the doc:
> > 
> >  * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
> >  * _might_ fail.  This depends upon the particular VM implementation.
> > 
> > so we can make the semantics of GFP_NOFS | __GFP_REPEAT such that they
> > are allowed to use the OOM killer and dip into the OOM reserves.
> 
> __GFP_REPEAT is quite subtle already.  It makes a difference only
> for high order allocations

That's an implementation detail, owed to the fact that smaller orders
already imply that behavior.  That doesn't change the semantics.  And
people currently *use* it all over the tree for small orders, because
of how the flag is defined in gfp.h; not because of how it's currently
implemented.

> and it is not clear to me why it should imply OOM killer for small
> orders now.  Or did you suggest making it special only with
> GFP_NOFS?  That sounds even more ugly.

Small orders already invoke the OOM killer.  I suggested using this
flag to override the specialness of GFP_NOFS not OOM killing - in
response to whether we can provide an annotation to make some GFP_NOFS
sites more robust.

This is exactly what __GFP_REPEAT is: try the allocation harder than
you would without this flag.  It identifies a caller that is willing
to put in extra effort or be more aggressive because the allocation is
more important than other allocations of the otherwise same gfp_mask.

> AFAIU, David wasn't asking for the OOM killer as much as he was
> interested in getting access to a small amount of reserves in order to
> make a progress. __GFP_HIGH is there for this purpose.

That's not just any reserve pool available to the generic caller, it's
the reserve pool for interrupts, which can not wait and replenish it.
It relies on kswapd to run soon after the interrupt, or right away on
SMP.  But locks held in the filesystem can hold up kswapd (the reason
we even still perform direct reclaim) so NOFS allocs shouldn't use it.

[hannes@dexter linux]$ git grep '__GFP_HIGH\b' | wc -l
39
[hannes@dexter linux]$ git grep GFP_ATOMIC | wc -l
4324

Interrupts have *no other option*.  It's misguided to deplete their
reserves, cause loss of network packets, loss of input events, from
allocations that can actually perform reclaim and have perfectly
acceptable fallback strategies in the caller.

Generally, for any reserve system there must be a way to replenish it.
For interrupts it's kswapd, for the OOM reserves I proposed it's the
OOM victim exiting soon after the allocation, if not right away.

__GFP_NOFAIL is the odd one out here because accessing the system's
emergency reserves without any prospect of near-future replenishing is
just slightly better than deadlocking right away.  Which is why this
reserve access can not be separated out: if you can do *anything*
better than hanging, do it.  If not, use __GFP_NOFAIL.

> > My question here would be: are there any NOFS allocations that *don't*
> > want this behavior?  Does it even make sense to require this separate
> > annotation or should we just make it the default?
> > 
> > The argument here was always that NOFS allocations are very limited in
> > their reclaim powers and will trigger OOM prematurely.  However, the
> > way we limit dirty memory these days forces most cache to be clean at
> > all times, and direct reclaim in general hasn't been allowed to issue
> > page writeback for quite some time.  So these days, NOFS reclaim isn't
> > really weaker than regular direct reclaim. 
> 
> What about [di]cache and some others fs specific shrinkers (and heavy
> metadata loads)?

My bad, I forgot about those.  But it doesn't really change the basic
question of whether we want to change the GFP_NOFS default or merely
annotate individual sites that want to try harder.

> > The only exception is that
> > it might block writeback, so we'd go OOM if the only reclaimables left
> > were dirty pages against that filesystem.  That should be acceptable.
> 
> OOM killer is hardly acceptable by most users I've heard from. OOM
> killer is the _last_ resort and if the allocation is restricted then
> we shouldn't use the big hammer.

We *are* talking about the last resort for these allocations!  There
is nothing else we can do to avoid allocation failure at this point.
Absent a reservation system, we have the choice between failing after
reclaim - which Dave said was too fragile for XFS - or OOM killing.

Or continue to deadlock in the allocator of course if we can't figure
out what the filesystem side actually wants given the current options.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
