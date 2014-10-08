Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8A36B0038
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 21:11:23 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id cc10so9480297wib.1
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 18:11:22 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gq6si15961754wib.42.2014.10.07.18.11.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Oct 2014 18:11:22 -0700 (PDT)
Date: Tue, 7 Oct 2014 21:11:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/3] mm: memcontrol: fix transparent huge page
 allocations under pressure
Message-ID: <20141008011106.GA12339@cmpxchg.org>
References: <1411571338-8178-1-git-send-email-hannes@cmpxchg.org>
 <1411571338-8178-4-git-send-email-hannes@cmpxchg.org>
 <20140929135707.GA25956@dhcp22.suse.cz>
 <20140929175700.GA20053@cmpxchg.org>
 <20141007135950.GD14243@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141007135950.GD14243@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 07, 2014 at 03:59:50PM +0200, Michal Hocko wrote:
> On Mon 29-09-14 13:57:00, Johannes Weiner wrote:
> > Every change we make is a trade-off and bears a certain risk.  THP is
> > a trade-off, it's pretty pointless to ignore the upsides and ride
> > around on the downsides.  Of course there are downsides.  This patch
> > makes THP work properly inside memcg, which invites both the upsides
> > as well as the downsides of THP into memcg.  But they are well known
> > and we can deal with them. 
> 
> I do not see any evaluation nor discussion of the upsides and downsides
> in the changelog. You are selling this as a net win which I cannot
> agree with.

I'm not sure why you want me to regurgitate the pros and cons of
transparent huge pages here.  They have been a well-established
default feature for a while now, and they are currently not working
properly inside memcg, which this patch addresses.

The only valid argument against merging this patch at this point can
be that THP inside memcg will lead to distinct issues that do not
exist on the global level.  So let's find out if there are any, okay?

> I am completely missing any notes about potential excessive
> swapouts or longer reclaim stalls which are a natural side effect of direct
> reclaim with a larger target (or is this something we do not agree on?).

Yes, we disagree here.  Why is reclaiming 2MB once worse than entering
reclaim 16 times to reclaim SWAP_CLUSTER_MAX?  There is no inherent
difference in reclaiming a big chunk and reclaiming many small chunks
that add up to the same size.

It's only different if you don't actually use the full 2MB pages, but
then the issue simply boils down to increased memory consumption.  But
that is easy to deal with and I offered two solutions in my changelog.

> What is an admin/user supposed to do when one of the above happens?
> Disable THP globally?

I already wrote all that.  It would be easier if you read my entire
line of reasoning instead of attacking fragments in isolation, so that
we can make forward progress on this.

> I still remember when THP was introduced and we have seen boatload of
> reclaim related bugs. These were exactly those long stalls, excessive
> swapouts and reclaim.

THP certainly had a bumpy introduction, and I can understand that you
want to prevent the same happening to memcg.

But it's important to evaluate which THP costs actually translate to
memcg.  The worst problems we had came *not* from faulting in bigger
steps, but from creating physically contiguous pages: aggressive lumpy
reclaim, (synchroneous) migration, reclaim beyond the allocation size
to create breathing room for compaction etc.  This is a massive amount
of work ON TOP of the bigger fault granularity.

Memcg only has to reclaim the allocation size in individual 4k pages.
Our only risk from THP is internal fragmentation from users not fully
utilizing the entire 2MB regions, but the work we MIGHT waste is
negligible compared to the work we are DEFINITELY wasting right now by
failing to charge already allocated THPs.

> > Why is THP inside memcg special?
> 
> For one thing the global case is hitting its limit (watermarks) much
> more slowly and gracefully because it has kswapd working on the
> background before we are getting into troubles. Memcg will just hit the
> wall and rely solely on the direct reclaim so everything we do will end
> up latency sensitive.

THP allocations do not wake up kswapd, they go into direct reclaim.
It's likely that kswapd balancing triggered by concurrent order-0
allocations will help THP somewhat, but because the global level needs
contiguous pages, it will still likely enter direct reclaim and direct
compaction.  For example, on my 16G desktop, there are 12MB between
the high and low watermark in the Normal zone; compaction needs double
the allocation size to work, so kswapd can cache reclaim work for up
to 3 THP in the best case (which those concurrent order-0 allocations
that woke kswapd in the first place will likely eat into), and direct
compaction will still have to run.

So AFAICS the synchroneous work required to fit a THP inside memcg is
much less.  And again, under pressure all this global work is already
expensed at that point anyway.

> Moreover, THP allocations have self regulatory mechanisms to prevent
> from excessive stalls. This means that THP allocations are less probable
> under heavy memory pressure.

These mechanisms exist for migration/compaction, but direct reclaim is
still fairly persistent - again, see should_continue_reclaim().

Am I missing something?

> On the other hand, memcg might be under serious memory pressure when
> THP charge comes. The only back off mechanism we use in memcg is
> GFP_NORETRY and that happens after one round of the reclaim. So we
> should make sure that the first round of the reclaim doesn't take
> terribly long.

The same applies globally.  ANY allocation under serious memory
pressure will have a high latency, but nobody forces you to use THP in
an already underprovisioned environment.

> Another part that matters is the size. Memcgs might be really small and
> that changes the math. Large reclaim target will get to low prio reclaim
> and thus the excessive reclaim.

I already addressed page size vs. memcg size before.

However, low priority reclaim does not result in excessive reclaim.
The reclaim goal is checked every time it scanned SWAP_CLUSTER_MAX
pages, and it exits if the goal has been met.  See shrink_lruvec(),
shrink_zone() etc.

> The size also makes any potential problem much more probable because the
> limit would be hit much more often than extremely low memory conditions
> globally.
>
> Also the reclaim decisions are subtly different for memcg because of the
> missing per-memcg dirty throttling and flushing. So we can stall on
> pages under writeback or get stuck in the write out path which is not
> the case for direct reclaim during THP allocation. A large reclaim
> target is more probable to hit into dirty or writeback pages.

These things again boil down to potential internal fragmentation and
higher memory consumption, as 16 128k reclaims are equally likely to
hit both problems as one 2MB reclaim.

> > Preventing THP faults from swapping is a reasonable proposal, but
> > again has nothing to do with memcg.
> 
> If we can do this inside the direct reclaim path then I am all for it
> because this means less trickery in the memcg code.
> 
> I am still not sure this is sufficient because memcg still might stall
> on IO so the safest approach would be ~GFP_IO reclaim for memcg reclaim
> path.
> 
> I feel strong about the first one (.may_swap = 0) and would be OK with
> your patch if this is added (to the memcg or common path).
> GFP_IO is an extra safety step. Smaller groups would be more likely to
> fail to reclaim enough and so THP success rate will be lower but that
> doesn't sound terribly wrong to me. I am not insisting on it, though.

Would you like to propose the no-swapping patch for the generic
reclaim code?  I'm certainly not against it, but I think the reason
nobody has proposed this yet is that the VM is heavily tuned to prefer
cache reclaim anyway and it's rare that environments run out of cache
and actually swap.  It usually means that memory is underprovisioned.

So I wouldn't be opposed to it as a fail-safe, in case worst comes to
worst, but I think it's a lot less important than you do.

> > However, in this particular case a regression is trivial to pinpoint
> > (comparing vmstat, profiles), and trivial to rectify in the field by
> > changing the memcg limits or disabling THP.
> 
> > What we DO know is that there are very good use cases for THP, but THP
> > inside memcg is broken:
> 
> All those usecases rely on amortizing THP initial costs by less faults
> (assuming the memory range is not used sparsely too much) and the TLB
> pressure reduction. Once we are hitting swap or excessive reclaim all
> the bets are off and THP is no longer beneficial.

Yes, we agree on this, just disagree on the importance of that case.
And both problem and solution would be unrelated to this patch.

> > THP does worse inside a memcg when compared to
> > bare metal environments of the same size, both in terms of success
> > rate, as well as in fault latency due to wasted page allocator work.
> 
> Because memcg is not equivalent to the bare metal with the same amount
> of memory. If for nothing else then because the background reclaim is
> missing.

Which THP is explicitely not using globally.

> > Plus, the code is illogical, redundant, and full of magic numbers.
> 
> I am not objecting to the removal of magic numbers and to getting rid of
> retry loops outside of direct reclaim path (aka mem_cgroup_reclaim). I
> would be willing to take a risk and get rid of them just to make the
> code saner. Because those were never justified properly and look more or
> less random. This would be a separate patch of course.
>  
> > Based on this, this patch seems like a net improvement.
> 
> Sigh, yes, if we ignore all the downsides everything will look like a
> net improvement :/

I don't think you honestly read my email.

> > > > This brings memcg's THP policy in line with the system policy: if the
> > > > allocator painstakingly assembles a hugepage, memcg will at least make
> > > > an honest effort to charge it.  As a result, transparent hugepage
> > > > allocation rates amid cache activity are drastically improved:
> > > > 
> > > >                                       vanilla                 patched
> > > > pgalloc                 4717530.80 (  +0.00%)   4451376.40 (  -5.64%)
> > > > pgfault                  491370.60 (  +0.00%)    225477.40 ( -54.11%)
> > > > pgmajfault                    2.00 (  +0.00%)         1.80 (  -6.67%)
> > > > thp_fault_alloc               0.00 (  +0.00%)       531.60 (+100.00%)
> > > > thp_fault_fallback          749.00 (  +0.00%)       217.40 ( -70.88%)
> > > 
> > > What is the load and configuration that you have measured?
> > 
> > It's just a single linear disk writer and another thread that faults
> > in an anonymous range in 4k steps.
> 
> This is really vague description...
> Which portion of the limit is the anon consumer, what is the memcg limit
> size, IO size, etc...? I find it really interesting that _all_ THP
> charges failed so the memcg had to be almost fully populated by the page
> cache already when the thread tries so fault in the first huge page.
>
> Also 4k steps is basically the best case for THP because the full THP
> block is populated. The question is how the system behaves when THP
> ranges are populated sparsely (because this is often the case).

You are missing the point :(

Sure there are cases that don't benefit from THP, this test just shows
that THP inside memcg can be trivially broken - which harms cases that
WOULD benefit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
