Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE896B0253
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 05:07:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i128so2444589wme.11
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 02:07:50 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id o187si2623654wmd.60.2016.10.25.02.07.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 02:07:49 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 79so596277wmy.4
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 02:07:49 -0700 (PDT)
Date: Tue, 25 Oct 2016 11:07:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: do not recurse in direct reclaim
Message-ID: <20161025090747.GD31137@dhcp22.suse.cz>
References: <20161024203005.5547-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161024203005.5547-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon 24-10-16 16:30:05, Johannes Weiner wrote:
> On 4.0, we saw a stack corruption from a page fault entering direct
> memory cgroup reclaim, calling into btrfs_releasepage(), which then
> tried to allocate an extent and recursed back into a kmem charge ad
> nauseam:
> 
> [...]
> [<ffffffff8136590c>] btrfs_releasepage+0x2c/0x30
> [<ffffffff811559a2>] try_to_release_page+0x32/0x50
> [<ffffffff81168cea>] shrink_page_list+0x6da/0x7a0
> [<ffffffff811693b5>] shrink_inactive_list+0x1e5/0x510
> [<ffffffff8116a0a5>] shrink_lruvec+0x605/0x7f0
> [<ffffffff8116a37e>] shrink_zone+0xee/0x320
> [<ffffffff8116a934>] do_try_to_free_pages+0x174/0x440
> [<ffffffff8116adf7>] try_to_free_mem_cgroup_pages+0xa7/0x130
> [<ffffffff811b738b>] try_charge+0x17b/0x830
> [<ffffffff811bb5b0>] memcg_charge_kmem+0x40/0x80
> [<ffffffff811a96a9>] new_slab+0x2d9/0x5a0
> [<ffffffff817b2547>] __slab_alloc+0x2fd/0x44f
> [<ffffffff811a9b03>] kmem_cache_alloc+0x193/0x1e0
> [<ffffffff813801e1>] alloc_extent_state+0x21/0xc0
> [<ffffffff813820c5>] __clear_extent_bit+0x2b5/0x400
> [<ffffffff81386d03>] try_release_extent_mapping+0x1a3/0x220
> [<ffffffff813658a1>] __btrfs_releasepage+0x31/0x70
> [<ffffffff8136590c>] btrfs_releasepage+0x2c/0x30
> [<ffffffff811559a2>] try_to_release_page+0x32/0x50
> [<ffffffff81168cea>] shrink_page_list+0x6da/0x7a0
> [<ffffffff811693b5>] shrink_inactive_list+0x1e5/0x510
> [<ffffffff8116a0a5>] shrink_lruvec+0x605/0x7f0
> [<ffffffff8116a37e>] shrink_zone+0xee/0x320
> [<ffffffff8116a934>] do_try_to_free_pages+0x174/0x440
> [<ffffffff8116adf7>] try_to_free_mem_cgroup_pages+0xa7/0x130
> [<ffffffff811b738b>] try_charge+0x17b/0x830
> [<ffffffff811bbfd5>] mem_cgroup_try_charge+0x65/0x1c0
> [<ffffffff8118338f>] handle_mm_fault+0x117f/0x1510
> [<ffffffff81041cf7>] __do_page_fault+0x177/0x420
> [<ffffffff81041fac>] do_page_fault+0xc/0x10
> [<ffffffff817c0182>] page_fault+0x22/0x30
> 
> On later kernels, kmem charging is opt-in rather than opt-out, and
> that particular kmem allocation in btrfs_releasepage() is no longer
> being charged and won't recurse and overrun the stack anymore. But
> it's not impossible for an accounted allocation to happen from the
> memcg direct reclaim context, and we needed to reproduce this crash
> many times before we even got a useful stack trace out of it.

I agree that stack overruns are really nasty to debug. Been there done
that, hate it...

I would argue that we shouldn't account arbitrary objects and most of
them should be directly related to a user visible API which shouldn't
happen from the reclaim path. But the reality is that we reuse the code
and we can easily end up in the situation similat to the one above so I
agree that being more careful is definitely worth it.

> Like other direct reclaimers, mark tasks in memcg reclaim PF_MEMALLOC
> to avoid recursing into any other form of direct reclaim. Then let
> recursive charges from PF_MEMALLOC contexts bypass the cgroup limit.

Yes, as long as the allocation is still properly accounted then this is
the right way to go. We can breach the limit already. The outer reclaim
loop would push back to the limit anyway.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

One nit below

> ---
>  mm/memcontrol.c | 9 +++++----
>  mm/vmscan.c     | 2 ++
>  2 files changed, 7 insertions(+), 4 deletions(-)
> 
> Hey guys, can anyone think of a reason why this might not be a good
> idea? We've never really needed this in the past because page reclaim
> doesn't recurse into instantiating another LRU page, especially with
> GFP_NOFS. But with a wider variety of tracked allocations, it's no
> longer that obvious. It seems like a risky hole to leave around.
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ae052b5e3315..3dac6f4ba4cf 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1908,13 +1908,14 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  
>  	/*
>  	 * Unlike in global OOM situations, memcg is not in a physical
> -	 * memory shortage.  Allow dying and OOM-killed tasks to
> -	 * bypass the last charges so that they can exit quickly and
> -	 * free their memory.
> +	 * memory shortage. Allow dying and OOM-killed tasks to bypass
> +	 * the last charges so that they can exit quickly and free
> +	 * their memory. The same applies for recursing reclaimers.
>  	 */
>  	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
>  		     fatal_signal_pending(current) ||
> -		     current->flags & PF_EXITING))
> +		     current->flags & PF_EXITING ||
> +		     current->flags & PF_MEMALLOC))
>  		goto force;

I would prefer to have the PF_MEMALLOC condition in a check on its own
with a short explanation that we really do not want to recurse to the
reclaim due to stack overflows.
  
>  	if (unlikely(task_in_memcg_oom(current)))
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 744f926af442..76fda2268148 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3043,7 +3043,9 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>  					    sc.gfp_mask,
>  					    sc.reclaim_idx);
>  
> +	current->flags |= PF_MEMALLOC;
>  	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
> +	current->flags &= ~PF_MEMALLOC;
>  
>  	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
>  
> -- 
> 2.10.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
