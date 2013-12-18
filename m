Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0A05C6B0036
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:51:48 -0500 (EST)
Received: by mail-bk0-f54.google.com with SMTP id v16so379014bkz.13
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 11:51:48 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ul10si554696bkb.173.2013.12.18.11.51.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 11:51:47 -0800 (PST)
Date: Wed, 18 Dec 2013 14:48:13 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 0/6] Configurable fair allocation zone policy v3
Message-ID: <20131218194813.GB20038@cmpxchg.org>
References: <1387298904-8824-1-git-send-email-mgorman@suse.de>
 <20131217200210.GG21724@cmpxchg.org>
 <20131218061750.GK21724@cmpxchg.org>
 <20131218150038.GP11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131218150038.GP11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 18, 2013 at 03:00:38PM +0000, Mel Gorman wrote:
> On Wed, Dec 18, 2013 at 01:17:50AM -0500, Johannes Weiner wrote:
> > On Tue, Dec 17, 2013 at 03:02:10PM -0500, Johannes Weiner wrote:
> > > Hi Mel,
> > > 
> > > On Tue, Dec 17, 2013 at 04:48:18PM +0000, Mel Gorman wrote:
> > > > This series is currently untested and is being posted to sync up discussions
> > > > on the treatment of page cache pages, particularly the sysv part. I have
> > > > not thought it through in detail but postings patches is the easiest way
> > > > to highlight where I think a problem might be.
> > > >
> > > > Changelog since v2
> > > > o Drop an accounting patch, behaviour is deliberate
> > > > o Special case tmpfs and shmem pages for discussion
> > > > 
> > > > Changelog since v1
> > > > o Fix lot of brain damage in the configurable policy patch
> > > > o Yoink a page cache annotation patch
> > > > o Only account batch pages against allocations eligible for the fair policy
> > > > o Add patch that default distributes file pages on remote nodes
> > > > 
> > > > Commit 81c0a2bb ("mm: page_alloc: fair zone allocator policy") solved a
> > > > bug whereby new pages could be reclaimed before old pages because of how
> > > > the page allocator and kswapd interacted on the per-zone LRU lists.
> > > 
> > > Not just that, it was about ensuring predictable cache replacement and
> > > maximizing the cache's effectiveness.  This implicitely fixed the
> > > kswapd interaction bug, but that was not the sole reason (I realize
> > > that the original changelog is incomplete and I apologize for that).
> > > 
> > > I have had offline discussions with Andrea back then and his first
> > > suggestion was too to make this a zone fairness placement that is
> > > exclusive to the local node, but eventually he agreed that the problem
> > > applies just as much on the global level and that we should apply
> > > fairness throughout the system as long as we honor zone_reclaim_mode
> > > and hard bindings.  During our discussions now, it turned out that
> > > zone_reclaim_mode is a terrible predictor for preferred locality, but
> > > we also more or less agreed that the locality issues in the first
> > > place are not really applicable to cache loads dominated by IO cost.
> > > 
> > > So I think the main discrepancy between the original patch and what we
> > > truly want is that aging fairness is really only relevant for actual
> > > cache backed by secondary storage, because cache replacement is an
> > > ongoing operation that involves IO.  As opposed to memory types that
> > > involve IO only in extreme cases (anon, tmpfs, shmem) or no IO at all
> > > (slab, kernel allocations), in which case we prefer NUMA locality.
> > > 
> > > > Unfortunately a side-effect missed during review was that it's now very
> > > > easy to allocate remote memory on NUMA machines. The problem is that
> > > > it is not a simple case of just restoring local allocation policies as
> > > > there are genuine reasons why global page aging may be prefereable. It's
> > > > still a major change to default behaviour so this patch makes the policy
> > > > configurable and sets what I think is a sensible default.
> > > > 
> > > > The patches are on top of some NUMA balancing patches currently in -mm.
> > > > It's untested and posted to discuss patches 4 and 6.
> > > 
> > > It might be easier in dealing with -stable if we start with the
> > > critical fix(es) to restore sane functionality as much and as compact
> > > as possible and then place the cleanups on top?
> > > 
> > > In my local tree, I have the following as the first patch:
> > 
> > Updated version with your tmpfs __GFP_PAGECACHE parts added and
> > documentation, changelog updated as necessary.  I remain unconvinced
> > that tmpfs pages should be round-robined, but I agree with you that it
> > is the conservative change to do for 3.12 and 3.12 and we can figure
> > out the rest later. 
> 
> Assume you with 3.12 and 3.13 here.

Yes :)

> > ---
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Subject: [patch] mm: page_alloc: restrict fair allocator policy to pagecache
> > 
> 
> Monolithic patch with multiple changes but meh. I'm not pushed because I
> know what the breakout looks like. FWIW, I had intended the entire of my
> broken-out series for 3.12 and 3.13 once it got ironed out. I find the
> series easier to understand but of course I would.

And of course I can live without the cleanups to make code I wrote
more readable ;-) I'm happy to defer on this, let's keep logical
changes separated.

> > 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy") was merged
> > in order to ensure predictable pagecache replacement and to maximize
> > the cache's effectiveness of reducing IO regardless of zone or node
> > topology.
> > 
> > However, it was overzealous in round-robin placing every type of
> > allocation over all allowable nodes, instead of preferring locality,
> > which resulted in severe regressions on certain NUMA workloads that
> > have nothing to do with pagecache.
> > 
> > This patch drastically reduces the impact of the original change by
> > having the round-robin placement policy only apply to pagecache
> > allocations and no longer to anonymous memory, shmem, slab and other
> > types of kernel allocations.
> > 
> > This still changes the long-standing behavior of pagecache adhering to
> > the configured memory policy and preferring local allocations per
> > default, so make it configurable in case somebody relies on it.
> > However, we also expect the majority of users to prefer maximium cache
> > effectiveness and a predictable replacement behavior over memory
> > locality, so reflect this in the default setting of the sysctl.
> > 
> > No-signoff-without-Mel's
> > Cc: <stable@kernel.org> # 3.12
> > ---
> >  Documentation/sysctl/vm.txt             | 20 ++++++++++++++++
> >  Documentation/vm/numa_memory_policy.txt |  7 ++++++
> >  include/linux/gfp.h                     |  4 +++-
> >  include/linux/pagemap.h                 |  2 +-
> >  include/linux/swap.h                    |  2 ++
> >  kernel/sysctl.c                         |  8 +++++++
> >  mm/filemap.c                            |  2 ++
> >  mm/page_alloc.c                         | 41 +++++++++++++++++++++++++--------
> >  mm/shmem.c                              | 14 +++++++++++
> >  9 files changed, 88 insertions(+), 12 deletions(-)
> > 
> > diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> > index 1fbd4eb7b64a..308c342f62ad 100644
> > --- a/Documentation/sysctl/vm.txt
> > +++ b/Documentation/sysctl/vm.txt
> > @@ -38,6 +38,7 @@ Currently, these files are in /proc/sys/vm:
> >  - memory_failure_early_kill
> >  - memory_failure_recovery
> >  - min_free_kbytes
> > +- pagecache_mempolicy_mode
> >  - min_slab_ratio
> >  - min_unmapped_ratio
> >  - mmap_min_addr
> 
> Sure about the name?
> 
> This is a boolean and "mode" implies it might be a bitmask. That said, I
> recognise that my own naming also sucked because complaining about yours
> I can see that mine also sucks.

Is it because of how we use zone_reclaim_mode?  I don't see anything
wrong with a "mode" toggle that switches between only two modes of
operation instead of three or more.  But English being a second
language and all...

> > @@ -1816,7 +1833,7 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
> >  
> >  static bool zone_local(struct zone *local_zone, struct zone *zone)
> >  {
> > -	return node_distance(local_zone->node, zone->node) == LOCAL_DISTANCE;
> > +	return local_zone->node == zone->node;
> >  }
> 
> Does that not break on !CONFIG_NUMA?
> 
> It's why I used zone_to_nid

There is a separate definition for !CONFIG_NUMA, it fit nicely next to
the zlc stuff.

> >  static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
> > @@ -1908,22 +1925,25 @@ zonelist_scan:
> >  		if (unlikely(alloc_flags & ALLOC_NO_WATERMARKS))
> >  			goto try_this_zone;
> >  		/*
> > -		 * Distribute pages in proportion to the individual
> > -		 * zone size to ensure fair page aging.  The zone a
> > -		 * page was allocated in should have no effect on the
> > -		 * time the page has in memory before being reclaimed.
> > +		 * Distribute pagecache pages in proportion to the
> > +		 * individual zone size to ensure fair page aging.
> > +		 * The zone a page was allocated in should have no
> > +		 * effect on the time the page has in memory before
> > +		 * being reclaimed.
> >  		 *
> > -		 * When zone_reclaim_mode is enabled, try to stay in
> > -		 * local zones in the fastpath.  If that fails, the
> > +		 * When pagecache_mempolicy_mode or zone_reclaim_mode
> > +		 * is enabled, try to allocate from zones within the
> > +		 * preferred node in the fastpath.  If that fails, the
> >  		 * slowpath is entered, which will do another pass
> >  		 * starting with the local zones, but ultimately fall
> >  		 * back to remote zones that do not partake in the
> >  		 * fairness round-robin cycle of this zonelist.
> >  		 */
> > -		if (alloc_flags & ALLOC_WMARK_LOW) {
> > +		if ((alloc_flags & ALLOC_WMARK_LOW) &&
> > +		    (gfp_mask & __GFP_PAGECACHE)) {
> >  			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
> >  				continue;
> 
> NR_ALLOC_BATCH is updated regardless of zone_reclaim_mode or
> pagecache_mempolicy_mode. We only reset batch in the prepare_slowpath in
> some cases. Looks a bit fishy even though I can't quite put my finger on it.
> 
> I also got details wrong here in the v3 of the series. In an unreleased
> v4 of the series I had corrected the treatment of slab pages in line
> with your wishes and reused the broken out helper in prepare_slowpath to
> keep the decision in sync.
> 
> It's still in development but even if it gets rejected it'll act as a
> comparison point to yours.
> 
> > -			if (zone_reclaim_mode &&
> > +			if ((zone_reclaim_mode || pagecache_mempolicy_mode) &&
> >  			    !zone_local(preferred_zone, zone))
> >  				continue;
> >  		}
> 
> Documention says "enabling pagecache_mempolicy_mode, in which case page cache
> allocations will be placed according to the configured memory policy". Should
> that be !pagecache_mempolicy_mode? I'm getting confused with the double nots.

Yes, it's a bit weird.

We want to consider the round-robin batches for local zones but at the
same time avoid exhausted batches from pushing the allocation off-node
when either of those modes are enabled.  So in the fastpath we filter
for both and in the slowpath, once kswapd has been woken at the same
time that the batches have been reset to launch the new aging cycle,
we try in order of zonelist preference.

However, to answer your question above, if the slowpath still has to
fall back to a remote zone, we don't want to reset its batch because
we didn't verify it was actually exhausted in the fastpath and we
could risk cutting short the aging cycle for that particular zone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
