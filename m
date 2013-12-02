Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id A56C16B00A0
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 06:22:20 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id u14so8482062lbd.13
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 03:22:19 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id du3si17584550lbc.16.2013.12.02.03.22.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 03:22:19 -0800 (PST)
Message-ID: <529C6D6A.3060307@parallels.com>
Date: Mon, 2 Dec 2013 15:22:18 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v12 00/18] kmemcg shrinkers
References: <cover.1385974612.git.vdavydov@parallels.com>
In-Reply-To: <cover.1385974612.git.vdavydov@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: Vladimir Davydov <vdavydov@parallels.com>, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org

Hi, Johannes

I tried to fix the patchset according to your comments, but there were a 
couple of places that after a bit of thinking I found impossible to 
amend exactly the way you proposed. Here they go:

>> +static unsigned long
>> +zone_nr_reclaimable_pages(struct scan_control *sc, struct zone *zone)
>> +{
>> +	if (global_reclaim(sc))
>> +		return zone_reclaimable_pages(zone);
>> +	return memcg_zone_reclaimable_pages(sc->target_mem_cgroup, zone);
>> +}
> So we have zone_reclaimable_pages() and zone_nr_reclaimable_pages()
> with completely different signatures and usecases.  Not good.
>
> The intersection between a zone and a memcg is called an lruvec,
> please use that.  Look up an lruvec as early as possible, then
> implement lruvec_reclaimable_pages() etc. for use during reclaim.

We iterate over lruvecs in shrink_zone() so AFAIU I should have put the 
lru_pages counting there. However, we're not guaranteed to iterate over 
all lruvecs eligible for current allocations if the zone is being shrunk 
concurrently. One way to fix this would be rewriting memcg iteration 
interface to always iterate over all memcgs returning in a flag in the 
cookie if the current memcg should be reclaimed, but I found this 
somewhat obfuscating and preferred simply fix the function name.

> -		for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
> -			if (!node_online(shrinkctl->nid))
> -				continue;
> -
> -			if (!(shrinker->flags & SHRINKER_NUMA_AWARE) &&
> -			    (shrinkctl->nid != 0))
> +			if (!memcg || memcg_kmem_is_active(memcg))
> +				freed += shrink_slab_one(shrinkctl, shrinker,
> +					 nr_pages_scanned, lru_pages);
> +			/*
> +			 * For non-memcg aware shrinkers, we will arrive here
> +			 * at first pass because we need to scan the root
> +			 * memcg.  We need to bail out, since exactly because
> +			 * they are not memcg aware, instead of noticing they
> +			 * have nothing to shrink, they will just shrink again,
> +			 * and deplete too many objects.
> +			 */
> I actually found the code easier to understand without this comment.
>
>> +			if (!(shrinker->flags & SHRINKER_MEMCG_AWARE))
>>   				break;
>> +			shrinkctl->target_mem_cgroup =
>> +				mem_cgroup_iter(root, memcg, NULL);
> The target memcg is always the same, don't change this.  Look at the
> lru scan code for reference.  Iterate zones (nodes in this case)
> first, then iterate the memcgs in each zone (node), look up the lruvec
> and then call shrink_slab_lruvec(lruvec, ...).

They are somewhat different: shrink_zone() calls shrink_lruvec() for 
each memcg's lruvec, but for shrink_slab() we don't have lruvecs. We do 
have memcg_list_lru though, but it's up to the shrinker to use it. In 
other words, in contrast to page cache reclaim, kmem shrinkers are 
opaque to vmscan.

Anyway, I can't help agreeing with you that changing target_mem_cgroup 
while iterating over memcgs looks ugly. So I rewrote it a bit to 
resemble the way per-node shrinking is implemented. For per-node 
shrinking we have shrink_control::nodemask, which is set by the 
shrink_slab() caller, and shrink_control::nid, which is initialized by 
shrink_slab() while iterating over online NUMA nodes and actually used 
by the shrinker. Similarly, for memory cgroups I added two fields to the 
shrink_control struct, target_mem_cgroup and memcg, the former is set by 
the shrink_slab() caller and specifies the memory cgroup tree to scan, 
and the latter is used as the iterator by shrink_slab() and as the 
target memcg by a particular memcg-aware shrinker.

I would appreciate if you could look at the new version and share your 
attitude toward it.

Thank you.

On 12/02/2013 03:19 PM, Vladimir Davydov wrote:
> Hi,
>
> This is the 12th iteration of Glauber Costa's patchset implementing targeted
> shrinking for memory cgroups when kmem limits are present. So far, we've been
> accounting kernel objects but failing allocations when short of memory. This is
> because our only option would be to call the global shrinker, depleting objects
> from all caches and breaking isolation.
>
> The main idea is to make LRU lists used by FS slab shrinkers per-memcg. When
> adding or removing an element from from the LRU, we use the page information to
> figure out which memory cgroup it belongs to and relay it to the appropriate
> list. This allows scanning kmem objects accounted to different memory cgroups
> independently.
>
> The patchset is based on top of Linux 3.13-rc2 and organized as follows:
>
>   * patches 1-8 are for cleanup/preparation;
>   * patch 9 introduces infrastructure for memcg-aware shrinkers;
>   * patches 10 and 11 implement the per-memcg LRU list structure;
>   * patch 12 uses per-memcg LRU lists to make dcache and icache shrinkers
>     memcg-aware;
>   * patch 13 implements kmem-only shrinking;
>   * patches 14-18 issue kmem shrinking on limit resize, global pressure.
>
> Known issues:
>
>   * Since FS shrinkers can't be executed on __GFP_FS allocations, such
>     allocations will fail if memcg kmem limit is less than the user limit and
>     the memcg kmem usage is close to its limit. Glauber proposed to schedule a
>     worker which would shrink kmem in the background on such allocations.
>     However, this approach does not eliminate failures completely, it just makes
>     them rarer. I'm thinking on implementing soft limits for memcg kmem so that
>     striking the soft limit will trigger the reclaimer, but won't fail the
>     allocation. I would appreciate any other proposals on how this can be fixed.
>
>   * Only dcache and icache are reclaimed on memcg pressure. Other FS objects are
>     left for global pressure only. However, it should not be a serious problem
>     to make them reclaimable too by passing on memcg to the FS-layer and letting
>     each FS decide if its internal objects are shrinkable on memcg pressure.
>
> Changelog:
>
> Changes in v12:
>   * Do not prune all slabs on kmem-only pressure.
>   * Count all on-LRU pages eligible for reclaim to pass to shrink_slab().
>   * Fix isolation issue due to using shrinker->nr_deferred on memcg pressure.
>   * Add comments to memcg_list_lru functions.
>   * Code cleanup/refactoring.
>
> Changes in v11:
>   * Rework per-memcg list_lru infrastructure.
>
> Glauber Costa (7):
>    memcg: make cache index determination more robust
>    memcg: consolidate callers of memcg_cache_id
>    memcg: move initialization to memcg creation
>    memcg: allow kmem limit to be resized down
>    vmpressure: in-kernel notifications
>    memcg: reap dead memcgs upon global memory pressure
>    memcg: flush memcg items upon memcg destruction
>
> Vladimir Davydov (11):
>    memcg: move several kmemcg functions upper
>    fs: do not use destroy_super() in alloc_super() fail path
>    vmscan: rename shrink_slab() args to make it more generic
>    vmscan: move call to shrink_slab() to shrink_zones()
>    vmscan: do_try_to_free_pages(): remove shrink_control argument
>    vmscan: shrink slab on memcg pressure
>    memcg,list_lru: add per-memcg LRU list infrastructure
>    memcg,list_lru: add function walking over all lists of a per-memcg
>      LRU
>    fs: make icache, dcache shrinkers memcg-aware
>    memcg: per-memcg kmem shrinking
>    vmscan: take at least one pass with shrinkers
>
>   fs/dcache.c                   |   25 +-
>   fs/inode.c                    |   16 +-
>   fs/internal.h                 |    9 +-
>   fs/super.c                    |   48 ++-
>   include/linux/fs.h            |    4 +-
>   include/linux/list_lru.h      |   83 +++++
>   include/linux/memcontrol.h    |   22 ++
>   include/linux/mm.h            |    3 +-
>   include/linux/shrinker.h      |   10 +-
>   include/linux/swap.h          |    2 +
>   include/linux/vmpressure.h    |    5 +
>   include/trace/events/vmscan.h |   20 +-
>   mm/memcontrol.c               |  728 ++++++++++++++++++++++++++++++++++++-----
>   mm/vmpressure.c               |   53 ++-
>   mm/vmscan.c                   |  249 +++++++++-----
>   15 files changed, 1054 insertions(+), 223 deletions(-)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
