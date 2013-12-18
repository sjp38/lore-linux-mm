Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 077B36B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 10:00:42 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so3694510eaj.9
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 07:00:42 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si321928eei.186.2013.12.18.07.00.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 07:00:42 -0800 (PST)
Date: Wed, 18 Dec 2013 15:00:38 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/6] Configurable fair allocation zone policy v3
Message-ID: <20131218150038.GP11295@suse.de>
References: <1387298904-8824-1-git-send-email-mgorman@suse.de>
 <20131217200210.GG21724@cmpxchg.org>
 <20131218061750.GK21724@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131218061750.GK21724@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 18, 2013 at 01:17:50AM -0500, Johannes Weiner wrote:
> On Tue, Dec 17, 2013 at 03:02:10PM -0500, Johannes Weiner wrote:
> > Hi Mel,
> > 
> > On Tue, Dec 17, 2013 at 04:48:18PM +0000, Mel Gorman wrote:
> > > This series is currently untested and is being posted to sync up discussions
> > > on the treatment of page cache pages, particularly the sysv part. I have
> > > not thought it through in detail but postings patches is the easiest way
> > > to highlight where I think a problem might be.
> > >
> > > Changelog since v2
> > > o Drop an accounting patch, behaviour is deliberate
> > > o Special case tmpfs and shmem pages for discussion
> > > 
> > > Changelog since v1
> > > o Fix lot of brain damage in the configurable policy patch
> > > o Yoink a page cache annotation patch
> > > o Only account batch pages against allocations eligible for the fair policy
> > > o Add patch that default distributes file pages on remote nodes
> > > 
> > > Commit 81c0a2bb ("mm: page_alloc: fair zone allocator policy") solved a
> > > bug whereby new pages could be reclaimed before old pages because of how
> > > the page allocator and kswapd interacted on the per-zone LRU lists.
> > 
> > Not just that, it was about ensuring predictable cache replacement and
> > maximizing the cache's effectiveness.  This implicitely fixed the
> > kswapd interaction bug, but that was not the sole reason (I realize
> > that the original changelog is incomplete and I apologize for that).
> > 
> > I have had offline discussions with Andrea back then and his first
> > suggestion was too to make this a zone fairness placement that is
> > exclusive to the local node, but eventually he agreed that the problem
> > applies just as much on the global level and that we should apply
> > fairness throughout the system as long as we honor zone_reclaim_mode
> > and hard bindings.  During our discussions now, it turned out that
> > zone_reclaim_mode is a terrible predictor for preferred locality, but
> > we also more or less agreed that the locality issues in the first
> > place are not really applicable to cache loads dominated by IO cost.
> > 
> > So I think the main discrepancy between the original patch and what we
> > truly want is that aging fairness is really only relevant for actual
> > cache backed by secondary storage, because cache replacement is an
> > ongoing operation that involves IO.  As opposed to memory types that
> > involve IO only in extreme cases (anon, tmpfs, shmem) or no IO at all
> > (slab, kernel allocations), in which case we prefer NUMA locality.
> > 
> > > Unfortunately a side-effect missed during review was that it's now very
> > > easy to allocate remote memory on NUMA machines. The problem is that
> > > it is not a simple case of just restoring local allocation policies as
> > > there are genuine reasons why global page aging may be prefereable. It's
> > > still a major change to default behaviour so this patch makes the policy
> > > configurable and sets what I think is a sensible default.
> > > 
> > > The patches are on top of some NUMA balancing patches currently in -mm.
> > > It's untested and posted to discuss patches 4 and 6.
> > 
> > It might be easier in dealing with -stable if we start with the
> > critical fix(es) to restore sane functionality as much and as compact
> > as possible and then place the cleanups on top?
> > 
> > In my local tree, I have the following as the first patch:
> 
> Updated version with your tmpfs __GFP_PAGECACHE parts added and
> documentation, changelog updated as necessary.  I remain unconvinced
> that tmpfs pages should be round-robined, but I agree with you that it
> is the conservative change to do for 3.12 and 3.12 and we can figure
> out the rest later. 

Assume you with 3.12 and 3.13 here.

> I sure hope that this doesn't drive most people
> on NUMA to disable pagecache interleaving right away as I expect most
> tmpfs workloads to see little to no reclaim and prefer locality... :/
> 

I hope you're right but I expect the experience will be like
zone_reclaim_mode. We're going to be looking out for bug reports that
are "fixed" by disabling pagecache locality and pushing back on them by
fixing the real problem.

This was the experience with zone_reclaim_mode when it started going
wrong. It was also the experience with THP for a very long time.
Disabling THP was a workaround for all sorts of problems and it was very
important to fix them and push back on anyone documenting disabling THP
as a standard workaround.

> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: page_alloc: restrict fair allocator policy to pagecache
> 

Monolithic patch with multiple changes but meh. I'm not pushed because I
know what the breakout looks like. FWIW, I had intended the entire of my
broken-out series for 3.12 and 3.13 once it got ironed out. I find the
series easier to understand but of course I would.

> 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy") was merged
> in order to ensure predictable pagecache replacement and to maximize
> the cache's effectiveness of reducing IO regardless of zone or node
> topology.
> 
> However, it was overzealous in round-robin placing every type of
> allocation over all allowable nodes, instead of preferring locality,
> which resulted in severe regressions on certain NUMA workloads that
> have nothing to do with pagecache.
> 
> This patch drastically reduces the impact of the original change by
> having the round-robin placement policy only apply to pagecache
> allocations and no longer to anonymous memory, shmem, slab and other
> types of kernel allocations.
> 
> This still changes the long-standing behavior of pagecache adhering to
> the configured memory policy and preferring local allocations per
> default, so make it configurable in case somebody relies on it.
> However, we also expect the majority of users to prefer maximium cache
> effectiveness and a predictable replacement behavior over memory
> locality, so reflect this in the default setting of the sysctl.
> 
> No-signoff-without-Mel's
> Cc: <stable@kernel.org> # 3.12
> ---
>  Documentation/sysctl/vm.txt             | 20 ++++++++++++++++
>  Documentation/vm/numa_memory_policy.txt |  7 ++++++
>  include/linux/gfp.h                     |  4 +++-
>  include/linux/pagemap.h                 |  2 +-
>  include/linux/swap.h                    |  2 ++
>  kernel/sysctl.c                         |  8 +++++++
>  mm/filemap.c                            |  2 ++
>  mm/page_alloc.c                         | 41 +++++++++++++++++++++++++--------
>  mm/shmem.c                              | 14 +++++++++++
>  9 files changed, 88 insertions(+), 12 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 1fbd4eb7b64a..308c342f62ad 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -38,6 +38,7 @@ Currently, these files are in /proc/sys/vm:
>  - memory_failure_early_kill
>  - memory_failure_recovery
>  - min_free_kbytes
> +- pagecache_mempolicy_mode
>  - min_slab_ratio
>  - min_unmapped_ratio
>  - mmap_min_addr

Sure about the name?

This is a boolean and "mode" implies it might be a bitmask. That said, I
recognise that my own naming also sucked because complaining about yours
I can see that mine also sucks.

> @@ -404,6 +405,25 @@ Setting this too high will OOM your machine instantly.
>  
>  =============================================================
>  
> +pagecache_mempolicy_mode:
> +
> +This is available only on NUMA kernels.
> +
> +Per default, pagecache is allocated in an interleaving fashion over
> +all allowed nodes (hardbindings and zone_reclaim_mode excluded),
> +regardless of the selected memory policy.
> +
> +The assumption is that, when it comes to pagecache, users generally
> +prefer predictable replacement behavior regardless of NUMA topology
> +and maximizing the cache's effectiveness in reducing IO over memory
> +locality.
> +
> +This behavior can be changed by enabling pagecache_mempolicy_mode, in
> +which case page cache allocations will be placed according to the
> +configured memory policy (Documentation/vm/numa_memory_policy.txt).
> +

Ok this indicates that pagecache will still be interleaved on zones local
to the node the process is allocating on. Good because that preserves a
very important aspect of your original patch.

The current description feels a little backwards though -- "Enable this
to *not* interleave pagecache". This documented behaviour says to me
that pagecache_obey_mempolicy might be a better name if enabling it uses
the system default memory policy.  However, even that might put us in a
corner. Ultimately we want this to be controllable on a per-process basis
using memory policies.

Merging what I have in v3, unreleased v4 and this thing I ended up with
this. The observation about cpusets was raised by Michal Hocko on IRC.

---8<---
mpol_interleave_files

This is available only on NUMA kernels.

Historically, the default behaviour of the system is to allocate memory
local to the process. The behaviour was usually modified through the use
of memory policies while zone_reclaim_mode controls how strict the local
memory allocation policy is.

Issues arise when the allocating process is frequently running on the same
node. The kernels memory reclaim daemon runs one instance per NUMA node.
A consequence is that relatively new memory may be reclaimed by kswapd when
the allocating process is running on a specific node. The user-visible
impact is that the system appears to do more IO than necessary when a
workload is accessing files that are larger than a given NUMA node.

To address this problem, the default system memory policy is modified by
this tunable.

When this tunable is enabled, the system default memory policy will
interleave batches of file-backed pages over all allowed zones and nodes.
The assumption is that, when it comes to file pages that users generally
prefer predictable replacement behavior regardless of NUMA topology and
maximizing the page cache's effectiveness in reducing IO over memory
locality.

The tunable zone_reclaim_mode overrides this and enabling zone_reclaim_mode
functionally disables mpol_interleave_pagecache.

A process running within a memory cpuset will obey the cpuset policy and
ignore mpol_interleave_files.

At the time of writing, this parameter cannot be overridden by a process
using set_mempolicy to set the task memory policy. Similarly, numactl
setting the task memory policy will not override this setting. This may
change in the future.

The tunable is default enabled and has two recognised parameters;

0: Use the MPOL_LOCAL policy as the system-wide default
1: Batch interleave file-backed allocations over all allowed nodes

One enabled, the downside is that some file accesses will now be to remote
memory even though the local node had available resources. This will hurt
workloads with small or short lived files that fit easily within one node.
The upside is that workloads working on files larger than a NUMA node will
not reclaim active pages prematurely.
---8<---

> +=============================================================
> +
>  min_slab_ratio:
>  
>  This is available only on NUMA kernels.
> diff --git a/Documentation/vm/numa_memory_policy.txt b/Documentation/vm/numa_memory_policy.txt
> index 4e7da6543424..72247e565908 100644
> --- a/Documentation/vm/numa_memory_policy.txt
> +++ b/Documentation/vm/numa_memory_policy.txt
> @@ -16,6 +16,13 @@ programming interface that a NUMA-aware application can take advantage of.  When
>  both cpusets and policies are applied to a task, the restrictions of the cpuset
>  takes priority.  See "MEMORY POLICIES AND CPUSETS" below for more details.
>  
> +Note that, per default, the memory policies do not apply to pagecache.  Instead
> +it will be interleaved fairly over all allowable nodes (respecting hardbindings
> +and zone_reclaim_mode) in order to maximize the cache's effectiveness in
> +reducing IO and to ensure predictable cache replacement.  Special setups that
> +require pagecache to adhere to the configured memory policy can change this
> +behavior by enabling pagecache_mempolicy_mode (see Documentation/sysctl/vm.txt).
> +

Manual pages should also be updated.

>  MEMORY POLICY CONCEPTS
>  
>  Scope of Memory Policies
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 9b4dd491f7e8..f69e4cb78ccf 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -35,6 +35,7 @@ struct vm_area_struct;
>  #define ___GFP_NO_KSWAPD	0x400000u
>  #define ___GFP_OTHER_NODE	0x800000u
>  #define ___GFP_WRITE		0x1000000u
> +#define ___GFP_PAGECACHE	0x2000000u
>  /* If the above are modified, __GFP_BITS_SHIFT may need updating */
>  
>  /*
> @@ -92,6 +93,7 @@ struct vm_area_struct;
>  #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
>  #define __GFP_KMEMCG	((__force gfp_t)___GFP_KMEMCG) /* Allocation comes from a memcg-accounted resource */
>  #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
> +#define __GFP_PAGECACHE ((__force gfp_t)___GFP_PAGECACHE)   /* Page cache allocation */
>  
>  /*
>   * This may seem redundant, but it's a way of annotating false positives vs.
> @@ -99,7 +101,7 @@ struct vm_area_struct;
>   */
>  #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
>  
> -#define __GFP_BITS_SHIFT 25	/* Room for N __GFP_FOO bits */
> +#define __GFP_BITS_SHIFT 26	/* Room for N __GFP_FOO bits */
>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
>  
>  /* This equals 0, but use constants in case they ever change */
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index e3dea75a078b..bda48453af8e 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -221,7 +221,7 @@ extern struct page *__page_cache_alloc(gfp_t gfp);
>  #else
>  static inline struct page *__page_cache_alloc(gfp_t gfp)
>  {
> -	return alloc_pages(gfp, 0);
> +	return alloc_pages(gfp | __GFP_PAGECACHE, 0);
>  }
>  #endif
>  
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 46ba0c6c219f..3458994b0881 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -320,11 +320,13 @@ extern unsigned long vm_total_pages;
>  
>  #ifdef CONFIG_NUMA
>  extern int zone_reclaim_mode;
> +extern int pagecache_mempolicy_mode;
>  extern int sysctl_min_unmapped_ratio;
>  extern int sysctl_min_slab_ratio;
>  extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
>  #else
>  #define zone_reclaim_mode 0
> +#define pagecache_mempolicy_mode 0
>  static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned int order)
>  {
>  	return 0;
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 34a604726d0b..a8c56c1dc98e 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1359,6 +1359,14 @@ static struct ctl_table vm_table[] = {
>  		.extra1		= &zero,
>  	},
>  	{
> +		.procname	= "pagecache_mempolicy_mode",
> +		.data		= &pagecache_mempolicy_mode,
> +		.maxlen		= sizeof(pagecache_mempolicy_mode),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +		.extra1		= &zero,
> +	},
> +	{
>  		.procname	= "min_unmapped_ratio",
>  		.data		= &sysctl_min_unmapped_ratio,
>  		.maxlen		= sizeof(sysctl_min_unmapped_ratio),
> diff --git a/mm/filemap.c b/mm/filemap.c
> index b7749a92021c..5bb922506906 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -517,6 +517,8 @@ struct page *__page_cache_alloc(gfp_t gfp)
>  	int n;
>  	struct page *page;
>  
> +	gfp |= __GFP_PAGECACHE;
> +
>  	if (cpuset_do_page_mem_spread()) {
>  		unsigned int cpuset_mems_cookie;
>  		do {
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 580a5f075ed0..f7c0ecb5bb8b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1547,7 +1547,15 @@ again:
>  					  get_pageblock_migratetype(page));
>  	}
>  
> +	/*
> +	 * All allocations eat into the round-robin batch, even
> +	 * allocations that are not subject to round-robin placement
> +	 * themselves.  This makes sure that allocations that ARE
> +	 * subject to round-robin placement compensate for the
> +	 * allocations that aren't, to have equal placement overall.
> +	 */
>  	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
> +
>  	__count_zone_vm_events(PGALLOC, zone, 1 << order);
>  	zone_statistics(preferred_zone, zone, gfp_flags);
>  	local_irq_restore(flags);

Thanks.

> @@ -1699,6 +1707,15 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
>  
>  #ifdef CONFIG_NUMA
>  /*
> + * pagecache_mempolicy_mode - whether pagecache allocations should
> + * honor the configured memory policy and allocate from the zonelist
> + * in order of preference, or whether they should interleave fairly
> + * over all allowed zones in the given zonelist to maximize cache
> + * effects and ensure predictable cache replacement.
> + */
> +int pagecache_mempolicy_mode __read_mostly;
> +
> +/*
>   * zlc_setup - Setup for "zonelist cache".  Uses cached zone data to
>   * skip over zones that are not allowed by the cpuset, or that have
>   * been recently (in last second) found to be nearly full.  See further
> @@ -1816,7 +1833,7 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
>  
>  static bool zone_local(struct zone *local_zone, struct zone *zone)
>  {
> -	return node_distance(local_zone->node, zone->node) == LOCAL_DISTANCE;
> +	return local_zone->node == zone->node;
>  }

Does that not break on !CONFIG_NUMA?

It's why I used zone_to_nid

>  
>  static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
> @@ -1908,22 +1925,25 @@ zonelist_scan:
>  		if (unlikely(alloc_flags & ALLOC_NO_WATERMARKS))
>  			goto try_this_zone;
>  		/*
> -		 * Distribute pages in proportion to the individual
> -		 * zone size to ensure fair page aging.  The zone a
> -		 * page was allocated in should have no effect on the
> -		 * time the page has in memory before being reclaimed.
> +		 * Distribute pagecache pages in proportion to the
> +		 * individual zone size to ensure fair page aging.
> +		 * The zone a page was allocated in should have no
> +		 * effect on the time the page has in memory before
> +		 * being reclaimed.
>  		 *
> -		 * When zone_reclaim_mode is enabled, try to stay in
> -		 * local zones in the fastpath.  If that fails, the
> +		 * When pagecache_mempolicy_mode or zone_reclaim_mode
> +		 * is enabled, try to allocate from zones within the
> +		 * preferred node in the fastpath.  If that fails, the
>  		 * slowpath is entered, which will do another pass
>  		 * starting with the local zones, but ultimately fall
>  		 * back to remote zones that do not partake in the
>  		 * fairness round-robin cycle of this zonelist.
>  		 */
> -		if (alloc_flags & ALLOC_WMARK_LOW) {
> +		if ((alloc_flags & ALLOC_WMARK_LOW) &&
> +		    (gfp_mask & __GFP_PAGECACHE)) {
>  			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
>  				continue;

NR_ALLOC_BATCH is updated regardless of zone_reclaim_mode or
pagecache_mempolicy_mode. We only reset batch in the prepare_slowpath in
some cases. Looks a bit fishy even though I can't quite put my finger on it.

I also got details wrong here in the v3 of the series. In an unreleased
v4 of the series I had corrected the treatment of slab pages in line
with your wishes and reused the broken out helper in prepare_slowpath to
keep the decision in sync.

It's still in development but even if it gets rejected it'll act as a
comparison point to yours.

> -			if (zone_reclaim_mode &&
> +			if ((zone_reclaim_mode || pagecache_mempolicy_mode) &&
>  			    !zone_local(preferred_zone, zone))
>  				continue;
>  		}

Documention says "enabling pagecache_mempolicy_mode, in which case page cache
allocations will be placed according to the configured memory policy". Should
that be !pagecache_mempolicy_mode? I'm getting confused with the double nots.

Breaking this out would be more comprehensible.

On a semi-related note, we might encounter a problem later where the
interleaving causes us to skip over usable zones and zones with available
batches are !zone_dirty_ok. We'd fall back to the slowpatch resetting the
batches so it will not be particularly visible but there might be some
interactions there.

> @@ -2390,7 +2410,8 @@ static void prepare_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 * thrash fairness information for zones that are not
>  		 * actually part of this zonelist's round-robin cycle.
>  		 */
> -		if (zone_reclaim_mode && !zone_local(preferred_zone, zone))
> +		if ((zone_reclaim_mode || pagecache_mempolicy_mode) &&
> +		    !zone_local(preferred_zone, zone))
>  			continue;
>  		mod_zone_page_state(zone, NR_ALLOC_BATCH,
>  				    high_wmark_pages(zone) -
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 8297623fcaed..02d7a9c03463 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -929,6 +929,17 @@ static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
>  	return page;
>  }
>  
> +/* Fugly method of distinguishing sysv/MAP_SHARED anon from tmpfs */
> +static bool shmem_inode_on_tmpfs(struct shmem_inode_info *info)
> +{
> +	/* If no internal shm_mount then it must be tmpfs */
> +	if (IS_ERR(shm_mnt))
> +		return true;
> +
> +	/* Consider it to be tmpfs if the superblock is not the internal mount */
> +	return info->vfs_inode.i_sb != shm_mnt->mnt_sb;
> +}
> +
>  static struct page *shmem_alloc_page(gfp_t gfp,
>  			struct shmem_inode_info *info, pgoff_t index)
>  {
> @@ -942,6 +953,9 @@ static struct page *shmem_alloc_page(gfp_t gfp,
>  	pvma.vm_ops = NULL;
>  	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
>  
> +	if (shmem_inode_on_tmpfs(info))
> +		gfp |= __GFP_PAGECACHE;
> +
>  	page = alloc_page_vma(gfp, &pvma, 0);
>  
>  	/* Drop reference taken by mpol_shared_policy_lookup() */

For what it's worth, this is what I've currently kicked off testes for

git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git mm-pgalloc-interleave-zones-v4r12

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
