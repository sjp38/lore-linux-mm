Date: Tue, 2 Dec 2008 00:32:29 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 3/4] memcg: explaing memcg's gfp_mask behavior in explicit
 way.
In-Reply-To: <20081201190534.1612b0b0.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0812020001490.25510@blonde.anvils>
References: <20081201190021.f3ab1f17.kamezawa.hiroyu@jp.fujitsu.com>
 <20081201190534.1612b0b0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, nickpiggin@yahoo.com.au, knikanth@suse.de, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Dec 2008, KAMEZAWA Hiroyuki wrote:
> mem_cgroup_xxx_charge(...gfpmask) function take gfpmask as its argument.
> But this gfp_t is only used for check GFP_RECALIM_MASK. In other words,
> memcg has no interst where the memory should be reclaimed from.
> It just see usage of pages.
> 
> Using bare gfp_t is misleading and this is a patch for explaining
> expected behavior in explicit way. (better name/code is welcome.)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Sorry, but I hate it.  You're spreading mem_cgroup ugliness throughout.

This is a good demonstation of why I wanted to go the opposite way to
Nick, why I wanted to push the masking as low as possible; I accept
Nick's point, but please, not at the expense of being this ugly.

It's a pity about loop over tmpfs, IIRC without that case you could
just remove the gfp_mask argument from every one of them - that is a
change I would appreciate!  Or am I forgetting some other cases?

I think you should remove the arg from every one you can, and change
those shmem_getpage() ones to say "gfp & GFP_RECLAIM_MASK" (just as
we'll be changing the radix_tree_preload later).

Hmm, shmem_getpage()'s mem_cgroup_cache_charge(,, gfp & ~__GFP_HIGHMEM)
has morphed into mem_cgroup_cache_charge(,, GFP_HIGHUSER_MOVABLE) in
mmotm (well, mmo2daysago, I've not looked today).  How come?

It used to be the case that the mem_cgroup calls made their own
memory allocations, and that could become the case again in future:
the gfp mask was passed down for those allocations, and it was almost
everywhere GFP_KERNEL.

mem_cgroup charging may need to reclaim some memory from the memcg:
it happens that the category of memory it goes for is HIGHUSER_MOVABLE;
and it happens that the gfp mask for any incidental allocations it might
want to make, also provides the GFP_RECLAIM_MASK flags for that reclaim.
But please keep that within mem_cgroup_cache_charge_common or whatever.

Hugh

> 
>  include/linux/gfp.h |   19 +++++++++++++++++++
>  mm/filemap.c        |    2 +-
>  mm/memory.c         |   12 +++++++-----
>  mm/shmem.c          |    8 ++++----
>  mm/swapfile.c       |    2 +-
>  mm/vmscan.c         |    3 +--
>  6 files changed, 33 insertions(+), 13 deletions(-)
> 
> Index: mmotm-2.6.28-Nov30/include/linux/gfp.h
> ===================================================================
> --- mmotm-2.6.28-Nov30.orig/include/linux/gfp.h
> +++ mmotm-2.6.28-Nov30/include/linux/gfp.h
> @@ -245,4 +245,23 @@ void drain_zone_pages(struct zone *zone,
>  void drain_all_pages(void);
>  void drain_local_pages(void *dummy);
>  
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +static inline gfp_t gfp_memcg_mask(gfp_t gfp)
> +{
> +	gfp_t mask;
> +	/*
> +	 * Memory Resource Controller memory reclaim is called to reduce usage
> +	 * of memory, not to get free memory from specified area.
> +	 * Remove zone constraints.
> +	 */
> +	mask = gfp & GFP_RECLAIM_MASK;
> +	return mask | (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> +}
> +#else
> +static inline gfp_t gfp_memcg_mask(gfp_t gfp)
> +{
> +	return gfp;
> +}
> +#endif
> +
>  #endif /* __LINUX_GFP_H */
> Index: mmotm-2.6.28-Nov30/mm/filemap.c
> ===================================================================
> --- mmotm-2.6.28-Nov30.orig/mm/filemap.c
> +++ mmotm-2.6.28-Nov30/mm/filemap.c
> @@ -461,7 +461,7 @@ int add_to_page_cache_locked(struct page
>  	VM_BUG_ON(!PageLocked(page));
>  
>  	error = mem_cgroup_cache_charge(page, current->mm,
> -					gfp_mask & ~__GFP_HIGHMEM);
> +					gfp_memcg_mask(gfp_mask));
>  	if (error)
>  		goto out;
>  
> Index: mmotm-2.6.28-Nov30/mm/vmscan.c
> ===================================================================
> --- mmotm-2.6.28-Nov30.orig/mm/vmscan.c
> +++ mmotm-2.6.28-Nov30/mm/vmscan.c
> @@ -1733,8 +1733,7 @@ unsigned long try_to_free_mem_cgroup_pag
>  	if (noswap)
>  		sc.may_swap = 0;
>  
> -	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> -			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> +	sc.gfp_mask = gfp_memcg_mask(gfp_mask);
>  	zonelist = NODE_DATA(numa_node_id())->node_zonelists;
>  	return do_try_to_free_pages(zonelist, &sc);
>  }
> Index: mmotm-2.6.28-Nov30/mm/memory.c
> ===================================================================
> --- mmotm-2.6.28-Nov30.orig/mm/memory.c
> +++ mmotm-2.6.28-Nov30/mm/memory.c
> @@ -1913,7 +1913,8 @@ gotten:
>  	cow_user_page(new_page, old_page, address, vma);
>  	__SetPageUptodate(new_page);
>  
> -	if (mem_cgroup_newpage_charge(new_page, mm, GFP_HIGHUSER_MOVABLE))
> +	if (mem_cgroup_newpage_charge(new_page, mm,
> +			gfp_memcg_mask(GFP_HIGHUSER_MOVABLE)))
>  		goto oom_free_new;
>  
>  	/*
> @@ -2345,7 +2346,7 @@ static int do_swap_page(struct mm_struct
>  	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
>  
>  	if (mem_cgroup_try_charge_swapin(mm, page,
> -				GFP_HIGHUSER_MOVABLE, &ptr) == -ENOMEM) {
> +		gfp_memcg_mask(GFP_HIGHUSER_MOVABLE), &ptr) == -ENOMEM) {
>  		ret = VM_FAULT_OOM;
>  		unlock_page(page);
>  		goto out;
> @@ -2437,7 +2438,8 @@ static int do_anonymous_page(struct mm_s
>  		goto oom;
>  	__SetPageUptodate(page);
>  
> -	if (mem_cgroup_newpage_charge(page, mm, GFP_HIGHUSER_MOVABLE))
> +	if (mem_cgroup_newpage_charge(page, mm,
> +				gfp_memcg_mask(GFP_HIGHUSER_MOVABLE)))
>  		goto oom_free_page;
>  
>  	entry = mk_pte(page, vma->vm_page_prot);
> @@ -2528,8 +2530,8 @@ static int __do_fault(struct mm_struct *
>  				ret = VM_FAULT_OOM;
>  				goto out;
>  			}
> -			if (mem_cgroup_newpage_charge(page,
> -						mm, GFP_HIGHUSER_MOVABLE)) {
> +			if (mem_cgroup_newpage_charge(page, mm,
> +					gfp_memcg_mask(GFP_HIGHUSER_MOVABLE))) {
>  				ret = VM_FAULT_OOM;
>  				page_cache_release(page);
>  				goto out;
> Index: mmotm-2.6.28-Nov30/mm/swapfile.c
> ===================================================================
> --- mmotm-2.6.28-Nov30.orig/mm/swapfile.c
> +++ mmotm-2.6.28-Nov30/mm/swapfile.c
> @@ -698,7 +698,7 @@ static int unuse_pte(struct vm_area_stru
>  	int ret = 1;
>  
>  	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page,
> -					GFP_HIGHUSER_MOVABLE, &ptr))
> +				gfp_memcg_mask(GFP_HIGHUSER_MOVABLE), &ptr))
>  		ret = -ENOMEM;
>  
>  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> Index: mmotm-2.6.28-Nov30/mm/shmem.c
> ===================================================================
> --- mmotm-2.6.28-Nov30.orig/mm/shmem.c
> +++ mmotm-2.6.28-Nov30/mm/shmem.c
> @@ -924,8 +924,8 @@ found:
>  	 * Charge page using GFP_HIGHUSER_MOVABLE while we can wait.
>  	 * charged back to the user(not to caller) when swap account is used.
>  	 */
> -	error = mem_cgroup_cache_charge_swapin(page,
> -			current->mm, GFP_HIGHUSER_MOVABLE, true);
> +	error = mem_cgroup_cache_charge_swapin(page, current->mm,
> +			gfp_memcg_mask(GFP_HIGHUSER_MOVABLE), true);
>  	if (error)
>  		goto out;
>  	error = radix_tree_preload(GFP_KERNEL);
> @@ -1267,7 +1267,7 @@ repeat:
>  			 * charge against this swap cache here.
>  			 */
>  			if (mem_cgroup_cache_charge_swapin(swappage,
> -						current->mm, gfp, false)) {
> +				current->mm, gfp_memcg_mask(gfp), false)) {
>  				page_cache_release(swappage);
>  				error = -ENOMEM;
>  				goto failed;
> @@ -1385,7 +1385,7 @@ repeat:
>  
>  			/* Precharge page while we can wait, compensate after */
>  			error = mem_cgroup_cache_charge(filepage, current->mm,
> -					GFP_HIGHUSER_MOVABLE);
> +					gfp_memcg_mask(GFP_HIGHUSER_MOVABLE));
>  			if (error) {
>  				page_cache_release(filepage);
>  				shmem_unacct_blocks(info->flags, 1);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
