Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id E212D6B0069
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 09:59:52 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id cc10so7951465wib.13
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 06:59:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p5si7825317wiy.13.2014.10.07.06.59.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Oct 2014 06:59:51 -0700 (PDT)
Date: Tue, 7 Oct 2014 15:59:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/3] mm: memcontrol: fix transparent huge page
 allocations under pressure
Message-ID: <20141007135950.GD14243@dhcp22.suse.cz>
References: <1411571338-8178-1-git-send-email-hannes@cmpxchg.org>
 <1411571338-8178-4-git-send-email-hannes@cmpxchg.org>
 <20140929135707.GA25956@dhcp22.suse.cz>
 <20140929175700.GA20053@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140929175700.GA20053@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 29-09-14 13:57:00, Johannes Weiner wrote:
> Hi Michal,
> 
> On Mon, Sep 29, 2014 at 03:57:07PM +0200, Michal Hocko wrote:
> > On Wed 24-09-14 11:08:58, Johannes Weiner wrote:
> > > In a memcg with even just moderate cache pressure, success rates for
> > > transparent huge page allocations drop to zero, wasting a lot of
> > > effort that the allocator puts into assembling these pages.
> > > 
> > > The reason for this is that the memcg reclaim code was never designed
> > > for higher-order charges.  It reclaims in small batches until there is
> > > room for at least one page.  Huge page charges only succeed when these
> > > batches add up over a series of huge faults, which is unlikely under
> > > any significant load involving order-0 allocations in the group.
> > > 
> > > Remove that loop on the memcg side in favor of passing the actual
> > > reclaim goal to direct reclaim, which is already set up and optimized
> > > to meet higher-order goals efficiently.
> > 
> > I had concerns the last time you were posting similar patch
> > (http://marc.info/?l=linux-mm&m=140803277013080&w=2) but I do not see
> > any of them neither mentioned nor addressed here.
> 
> I actually made several attempts to address your concerns, but it's
> hard to discern technical objections from what you write.  Example:
>
> > Especially unexpected long stalls and excessive swapout. 512 pages
> > target for direct reclaim is too much. Especially for smaller memcgs
> > where we would need to drop the priority considerably to even scan
> > that many pages.  THP charges close to the limit are definitely a
> > problem but this is way too risky to fix this problem IMO.
> 
> Every change we make is a trade-off and bears a certain risk.  THP is
> a trade-off, it's pretty pointless to ignore the upsides and ride
> around on the downsides.  Of course there are downsides.  This patch
> makes THP work properly inside memcg, which invites both the upsides
> as well as the downsides of THP into memcg.  But they are well known
> and we can deal with them. 

I do not see any evaluation nor discussion of the upsides and downsides
in the changelog. You are selling this as a net win which I cannot
agree with. I am completely missing any notes about potential excessive
swapouts or longer reclaim stalls which are a natural side effect of direct
reclaim with a larger target (or is this something we do not agree on?).
What is an admin/user supposed to do when one of the above happens?
Disable THP globally?

I still remember when THP was introduced and we have seen boatload of
reclaim related bugs. These were exactly those long stalls, excessive
swapouts and reclaim.

> Why is THP inside memcg special?

For one thing the global case is hitting its limit (watermarks) much
more slowly and gracefully because it has kswapd working on the
background before we are getting into troubles. Memcg will just hit the
wall and rely solely on the direct reclaim so everything we do will end
up latency sensitive.

Moreover, THP allocations have self regulatory mechanisms to prevent
from excessive stalls. This means that THP allocations are less probable
under heavy memory pressure. On the other hand, memcg might be under
serious memory pressure when THP charge comes. The only back off
mechanism we use in memcg is GFP_NORETRY and that happens after one
round of the reclaim. So we should make sure that the first round of the
reclaim doesn't take terribly long.

Another part that matters is the size. Memcgs might be really small and
that changes the math. Large reclaim target will get to low prio reclaim
and thus the excessive reclaim.
The size also makes any potential problem much more probable because the
limit would be hit much more often than extremely low memory conditions
globally.

Also the reclaim decisions are subtly different for memcg because of the
missing per-memcg dirty throttling and flushing. So we can stall on
pages under writeback or get stuck in the write out path which is not
the case for direct reclaim during THP allocation. A large reclaim
target is more probable to hit into dirty or writeback pages.

> Sure, the smaller the memcg, the bigger the THP fault and scan target
> in comparison.  We don't have control over the THP size, but the user
> can always increase the size of the memcg, iff THP leads to increased
> fragmentation and memory consumption for the given workload.
> 
> [ Until he can't, at which point he has to decide whether the cost of
>   THP outweighs the benefits on a system-wide level.  For now - we
>   could certainly consider making a THP-knob available per memcg, I'm
>   just extrapolating from the fact that we don't have a per-process
>   knob that it's unlikely that we need one per memcg. ]

There actually were proposals for per-process THP configuration already.
I haven't tracked it later so I don't know the current status.
Per-process knob sounds like a better fit than a memcg knob because
requirement is basically dependent on the usage pattern which might be
different among processes living in the same memcg.

> > Maybe a better approach
> > would be to limit the reclaim to (clean) page cache (aka
> > MEM_CGROUP_RECLAIM_NOSWAP). The risk of long stalls should be much
> > lower and excessive swapouts shouldn't happen at all. What is the point
> > to swap out a large number of pages just to allow THP charge which can
> > be used very sparsely?
> 
> THP can lead to thrashing, that's not news. 

It shouldn't because the optimization doesn't make much sense
otherwise. Any thrashing is simply a bug.

> Preventing THP faults from swapping is a reasonable proposal, but
> again has nothing to do with memcg.

If we can do this inside the direct reclaim path then I am all for it
because this means less trickery in the memcg code.

I am still not sure this is sufficient because memcg still might stall
on IO so the safest approach would be ~GFP_IO reclaim for memcg reclaim
path.

I feel strong about the first one (.may_swap = 0) and would be OK with
your patch if this is added (to the memcg or common path).
GFP_IO is an extra safety step. Smaller groups would be more likely to
fail to reclaim enough and so THP success rate will be lower but that
doesn't sound terribly wrong to me. I am not insisting on it, though.

> As for this patch, we don't have sufficient data on existing
> configurations to know if this will lead to noticable regressions.  It
> might, but everything we do might cause a regression, that's just our
> reality.  That alone can't be grounds for rejecting a patch. 

That alone certainly does not but then we have to evaluate the risk and
consider other possible ways with a smaller risk.

> However, in this particular case a regression is trivial to pinpoint
> (comparing vmstat, profiles), and trivial to rectify in the field by
> changing the memcg limits or disabling THP.

> What we DO know is that there are very good use cases for THP, but THP
> inside memcg is broken:

All those usecases rely on amortizing THP initial costs by less faults
(assuming the memory range is not used sparsely too much) and the TLB
pressure reduction. Once we are hitting swap or excessive reclaim all
the bets are off and THP is no longer beneficial.

> THP does worse inside a memcg when compared to
> bare metal environments of the same size, both in terms of success
> rate, as well as in fault latency due to wasted page allocator work.

Because memcg is not equivalent to the bare metal with the same amount
of memory. If for nothing else then because the background reclaim is
missing.

> Plus, the code is illogical, redundant, and full of magic numbers.

I am not objecting to the removal of magic numbers and to getting rid of
retry loops outside of direct reclaim path (aka mem_cgroup_reclaim). I
would be willing to take a risk and get rid of them just to make the
code saner. Because those were never justified properly and look more or
less random. This would be a separate patch of course.
 
> Based on this, this patch seems like a net improvement.

Sigh, yes, if we ignore all the downsides everything will look like a
net improvement :/
 
> > > This brings memcg's THP policy in line with the system policy: if the
> > > allocator painstakingly assembles a hugepage, memcg will at least make
> > > an honest effort to charge it.  As a result, transparent hugepage
> > > allocation rates amid cache activity are drastically improved:
> > > 
> > >                                       vanilla                 patched
> > > pgalloc                 4717530.80 (  +0.00%)   4451376.40 (  -5.64%)
> > > pgfault                  491370.60 (  +0.00%)    225477.40 ( -54.11%)
> > > pgmajfault                    2.00 (  +0.00%)         1.80 (  -6.67%)
> > > thp_fault_alloc               0.00 (  +0.00%)       531.60 (+100.00%)
> > > thp_fault_fallback          749.00 (  +0.00%)       217.40 ( -70.88%)
> > 
> > What is the load and configuration that you have measured?
> 
> It's just a single linear disk writer and another thread that faults
> in an anonymous range in 4k steps.

This is really vague description...
Which portion of the limit is the anon consumer, what is the memcg limit
size, IO size, etc...? I find it really interesting that _all_ THP
charges failed so the memcg had to be almost fully populated by the page
cache already when the thread tries so fault in the first huge page.

Also 4k steps is basically the best case for THP because the full THP
block is populated. The question is how the system behaves when THP
ranges are populated sparsely (because this is often the case).

Have you checked any anon mostly load?

Finally what are the (average,highest) latencies for the page fault and
how much memory was swapped out.

I would expect this kind of information for testing of such a patch.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
