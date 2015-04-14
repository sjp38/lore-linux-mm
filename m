Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 870F66B0032
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 10:23:12 -0400 (EDT)
Received: by lbcga7 with SMTP id ga7so9819009lbc.1
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 07:23:11 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id e8si20435347wib.65.2015.04.14.07.23.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 07:23:09 -0700 (PDT)
Received: by widdi4 with SMTP id di4so115635481wid.0
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 07:23:09 -0700 (PDT)
Date: Tue, 14 Apr 2015 16:23:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 00/12] mm: page_alloc: improve OOM mechanism and policy
Message-ID: <20150414142307.GI17160@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <20150326195822.GB28129@dastard>
 <20150327150509.GA21119@cmpxchg.org>
 <20150330003240.GB28621@dastard>
 <20150401151920.GB23824@dhcp22.suse.cz>
 <20150407141822.GA3262@cmpxchg.org>
 <20150413124614.GA21790@dhcp22.suse.cz>
 <20150414103625.GA26264@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150414103625.GA26264@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Tue 14-04-15 06:36:25, Johannes Weiner wrote:
> On Mon, Apr 13, 2015 at 02:46:14PM +0200, Michal Hocko wrote:
[...]
> > AFAIU, David wasn't asking for the OOM killer as much as he was
> > interested in getting access to a small amount of reserves in order to
> > make a progress. __GFP_HIGH is there for this purpose.
> 
> That's not just any reserve pool available to the generic caller, it's
> the reserve pool for interrupts, which can not wait and replenish it.
> It relies on kswapd to run soon after the interrupt, or right away on
> SMP.  But locks held in the filesystem can hold up kswapd (the reason
> we even still perform direct reclaim) so NOFS allocs shouldn't use it.
> 
> [hannes@dexter linux]$ git grep '__GFP_HIGH\b' | wc -l
> 39
> [hannes@dexter linux]$ git grep GFP_ATOMIC | wc -l
> 4324
> 
> Interrupts have *no other option*. 

Atomic context in general can ALLOC_HARDER so it has an access to
additional reserves wrt. __GFP_HIGH|__GFP_WAIT.

> It's misguided to deplete their
> reserves, cause loss of network packets, loss of input events, from
> allocations that can actually perform reclaim and have perfectly
> acceptable fallback strategies in the caller.

OK, I thought that it was clear that the proposed __GFP_HIGH is a
fallback strategy for those paths which cannot do much better. Not a
random solution for "this shouldn't fail to eagerly".

> Generally, for any reserve system there must be a way to replenish it.
> For interrupts it's kswapd, for the OOM reserves I proposed it's the
> OOM victim exiting soon after the allocation, if not right away.

And my understanding was that the fallback mode would be used in the
context which would lead to release of the fs pressure thus releasing a
memory as well.

> __GFP_NOFAIL is the odd one out here because accessing the system's
> emergency reserves without any prospect of near-future replenishing is
> just slightly better than deadlocking right away.  Which is why this
> reserve access can not be separated out: if you can do *anything*
> better than hanging, do it.  If not, use __GFP_NOFAIL.

Agreed.
 
> > > My question here would be: are there any NOFS allocations that *don't*
> > > want this behavior?  Does it even make sense to require this separate
> > > annotation or should we just make it the default?
> > > 
> > > The argument here was always that NOFS allocations are very limited in
> > > their reclaim powers and will trigger OOM prematurely.  However, the
> > > way we limit dirty memory these days forces most cache to be clean at
> > > all times, and direct reclaim in general hasn't been allowed to issue
> > > page writeback for quite some time.  So these days, NOFS reclaim isn't
> > > really weaker than regular direct reclaim. 
> > 
> > What about [di]cache and some others fs specific shrinkers (and heavy
> > metadata loads)?
> 
> My bad, I forgot about those.  But it doesn't really change the basic
> question of whether we want to change the GFP_NOFS default or merely
> annotate individual sites that want to try harder.

My understanding was the later one. If you look at page cache allocations
which use mapping_gfp_mask (e.g. xfs is using GFP_NOFS for that context
all the time) then those do not really have to try harder.

> > > The only exception is that
> > > it might block writeback, so we'd go OOM if the only reclaimables left
> > > were dirty pages against that filesystem.  That should be acceptable.
> > 
> > OOM killer is hardly acceptable by most users I've heard from. OOM
> > killer is the _last_ resort and if the allocation is restricted then
> > we shouldn't use the big hammer.
> 
> We *are* talking about the last resort for these allocations!  There
> is nothing else we can do to avoid allocation failure at this point.
> Absent a reservation system, we have the choice between failing after
> reclaim - which Dave said was too fragile for XFS - or OOM killing.

As per other emails in this thread (e.g.
http://marc.info/?l=linux-mm&m=142897087230385&w=2), I understood that
the access to a small portion of emergency pool would be sufficient to
release the pressure and that sounds preferable to me over a destructive
reclaim attempts.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
