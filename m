Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id BAC026B007E
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 09:11:37 -0400 (EDT)
Date: Thu, 22 Mar 2012 14:11:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 1/3] memcg: add methods to access pc->mem_cgroup
Message-ID: <20120322131135.GD18665@tiehlicka.suse.cz>
References: <4F66E6A5.10804@jp.fujitsu.com>
 <4F66E773.4000807@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F66E773.4000807@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, suleiman@google.com, n-horiguchi@ah.jp.nec.com, khlebnikov@openvz.org, Tejun Heo <tj@kernel.org>

On Mon 19-03-12 16:59:47, KAMEZAWA Hiroyuki wrote:
> In order to encode pc->mem_cgroup and pc->flags to be in a word,
> access function to pc->mem_cgroup is required.
> 
> This patch replaces access to pc->mem_cgroup with
>  pc_to_mem_cgroup(pc)          : pc->mem_cgroup
>  pc_set_mem_cgroup(pc, memcg)  : pc->mem_cgroup = memcg
> 
> Following patch will remove pc->mem_cgroup.

Acked-by: Michal Hocko <mhocko@suse.cz>

> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/page_cgroup.h |   12 +++++++
>  mm/memcontrol.c             |   69 ++++++++++++++++++++++--------------------
>  2 files changed, 48 insertions(+), 33 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index a88cdba..92768cb 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -82,6 +82,18 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
>  	bit_spin_unlock(PCG_LOCK, &pc->flags);
>  }
>  
> +
> +static inline struct mem_cgroup* pc_to_mem_cgroup(struct page_cgroup *pc)
> +{
> +	return pc->mem_cgroup;
> +}
> +
> +static inline void
> +pc_set_mem_cgroup(struct page_cgroup *pc, struct mem_cgroup *memcg)
> +{
> +	pc->mem_cgroup = memcg;
> +}
> +
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct page_cgroup;
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c65e6bc..124fec9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1014,9 +1014,9 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
>  /*
>   * Following LRU functions are allowed to be used without PCG_LOCK.
>   * Operations are called by routine of global LRU independently from memcg.
> - * What we have to take care of here is validness of pc->mem_cgroup.
> + * What we have to take care of here is validness of pc's mem_cgroup.
>   *
> - * Changes to pc->mem_cgroup happens when
> + * Changes to pc's mem_cgroup happens when
>   * 1. charge
>   * 2. moving account
>   * In typical case, "charge" is done before add-to-lru. Exception is SwapCache.
> @@ -1048,7 +1048,7 @@ struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
>  		return &zone->lruvec;
>  
>  	pc = lookup_page_cgroup(page);
> -	memcg = pc->mem_cgroup;
> +	memcg = pc_to_mem_cgroup(pc);
>  
>  	/*
>  	 * Surreptitiously switch any uncharged page to root:
> @@ -1057,10 +1057,12 @@ struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
>  	 *
>  	 * Our caller holds lru_lock, and PageCgroupUsed is updated
>  	 * under page_cgroup lock: between them, they make all uses
> -	 * of pc->mem_cgroup safe.
> +	 * of pc's mem_cgroup safe.
>  	 */
> -	if (!PageCgroupUsed(pc) && memcg != root_mem_cgroup)
> -		pc->mem_cgroup = memcg = root_mem_cgroup;
> +	if (!PageCgroupUsed(pc) && memcg != root_mem_cgroup) {
> +		pc_set_mem_cgroup(pc, root_mem_cgroup);
> +		memcg = root_mem_cgroup;
> +	}
>  
>  	mz = page_cgroup_zoneinfo(memcg, page);
>  	/* compound_order() is stabilized through lru_lock */
> @@ -1088,7 +1090,7 @@ void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
>  		return;
>  
>  	pc = lookup_page_cgroup(page);
> -	memcg = pc->mem_cgroup;
> +	memcg = pc_to_mem_cgroup(pc);
>  	VM_BUG_ON(!memcg);
>  	mz = page_cgroup_zoneinfo(memcg, page);
>  	/* huge page split is done under lru_lock. so, we have no races. */
> @@ -1235,9 +1237,9 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
>  	pc = lookup_page_cgroup(page);
>  	if (!PageCgroupUsed(pc))
>  		return NULL;
> -	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
> +	/* Ensure pc's mem_cgroup is visible after reading PCG_USED. */
>  	smp_rmb();
> -	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
> +	mz = page_cgroup_zoneinfo(pc_to_mem_cgroup(pc), page);
>  	return &mz->reclaim_stat;
>  }
>  
> @@ -1314,7 +1316,7 @@ static void mem_cgroup_end_move(struct mem_cgroup *memcg)
>   *
>   * mem_cgroup_stolen() -  checking whether a cgroup is mc.from or not. This
>   *			  is used for avoiding races in accounting.  If true,
> - *			  pc->mem_cgroup may be overwritten.
> + *			  pc's mem_cgroup may be overwritten.
>   *
>   * mem_cgroup_under_move() - checking a cgroup is mc.from or mc.to or
>   *			  under hierarchy of moving cgroups. This is for
> @@ -1887,8 +1889,8 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
>   * file-stat operations happen after a page is attached to radix-tree. There
>   * are no race with "charge".
>   *
> - * Considering "uncharge", we know that memcg doesn't clear pc->mem_cgroup
> - * at "uncharge" intentionally. So, we always see valid pc->mem_cgroup even
> + * Considering "uncharge", we know that memcg doesn't clear pc's mem_cgroup
> + * at "uncharge" intentionally. So, we always see valid pc's mem_cgroup even
>   * if there are race with "uncharge". Statistics itself is properly handled
>   * by flags.
>   *
> @@ -1905,7 +1907,7 @@ void __mem_cgroup_begin_update_page_stat(struct page *page,
>  
>  	pc = lookup_page_cgroup(page);
>  again:
> -	memcg = pc->mem_cgroup;
> +	memcg = pc_to_mem_cgroup(pc);
>  	if (unlikely(!memcg || !PageCgroupUsed(pc)))
>  		return;
>  	/*
> @@ -1918,7 +1920,7 @@ again:
>  		return;
>  
>  	move_lock_mem_cgroup(memcg, flags);
> -	if (memcg != pc->mem_cgroup || !PageCgroupUsed(pc)) {
> +	if (memcg != pc_to_mem_cgroup(pc) || !PageCgroupUsed(pc)) {
>  		move_unlock_mem_cgroup(memcg, flags);
>  		goto again;
>  	}
> @@ -1930,11 +1932,11 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
>  	struct page_cgroup *pc = lookup_page_cgroup(page);
>  
>  	/*
> -	 * It's guaranteed that pc->mem_cgroup never changes while
> -	 * lock is held because a routine modifies pc->mem_cgroup
> +	 * It's guaranteed that pc's mem_cgroup never changes while
> +	 * lock is held because a routine modifies pc's mem_cgroup
>  	 * should take move_lock_page_cgroup().
>  	 */
> -	move_unlock_mem_cgroup(pc->mem_cgroup, flags);
> +	move_unlock_mem_cgroup(pc_to_mem_cgroup(pc), flags);
>  }
>  
>  void mem_cgroup_update_page_stat(struct page *page,
> @@ -1947,7 +1949,7 @@ void mem_cgroup_update_page_stat(struct page *page,
>  	if (mem_cgroup_disabled())
>  		return;
>  
> -	memcg = pc->mem_cgroup;
> +	memcg = pc_to_mem_cgroup(pc);
>  	if (unlikely(!memcg || !PageCgroupUsed(pc)))
>  		return;
>  
> @@ -2244,7 +2246,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>   * has TIF_MEMDIE, this function returns -EINTR while writing root_mem_cgroup
>   * to *ptr. There are two reasons for this. 1: fatal threads should quit as soon
>   * as possible without any hazards. 2: all pages should have a valid
> - * pc->mem_cgroup. If mm is NULL and the caller doesn't pass a valid memcg
> + * pc's mem_cgroup. If mm is NULL and the caller doesn't pass a valid memcg
>   * pointer, that is treated as a charge to root_mem_cgroup.
>   *
>   * So __mem_cgroup_try_charge() will return
> @@ -2437,7 +2439,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  	pc = lookup_page_cgroup(page);
>  	lock_page_cgroup(pc);
>  	if (PageCgroupUsed(pc)) {
> -		memcg = pc->mem_cgroup;
> +		memcg = pc_to_mem_cgroup(pc);
>  		if (memcg && !css_tryget(&memcg->css))
>  			memcg = NULL;
>  	} else if (PageSwapCache(page)) {
> @@ -2489,11 +2491,11 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
>  		}
>  	}
>  
> -	pc->mem_cgroup = memcg;
> +	pc_set_mem_cgroup(pc, memcg);
>  	/*
>  	 * We access a page_cgroup asynchronously without lock_page_cgroup().
> -	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
> -	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
> +	 * Especially when a page_cgroup is taken from a page, pc's mem_cgroup
> +	 * is accessed after testing USED bit. To make pc's mem_cgroup visible
>  	 * before USED bit, we need memory barrier here.
>  	 * See mem_cgroup_add_lru_list(), etc.
>   	 */
> @@ -2538,13 +2540,14 @@ void mem_cgroup_split_huge_fixup(struct page *head)
>  {
>  	struct page_cgroup *head_pc = lookup_page_cgroup(head);
>  	struct page_cgroup *pc;
> +	struct mem_cgroup *memcg = pc_to_mem_cgroup(head_pc);
>  	int i;
>  
>  	if (mem_cgroup_disabled())
>  		return;
>  	for (i = 1; i < HPAGE_PMD_NR; i++) {
>  		pc = head_pc + i;
> -		pc->mem_cgroup = head_pc->mem_cgroup;
> +		pc_set_mem_cgroup(pc, memcg);
>  		smp_wmb();/* see __commit_charge() */
>  		pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
>  	}
> @@ -2595,7 +2598,7 @@ static int mem_cgroup_move_account(struct page *page,
>  	lock_page_cgroup(pc);
>  
>  	ret = -EINVAL;
> -	if (!PageCgroupUsed(pc) || pc->mem_cgroup != from)
> +	if (!PageCgroupUsed(pc) || pc_to_mem_cgroup(pc) != from)
>  		goto unlock;
>  
>  	move_lock_mem_cgroup(from, &flags);
> @@ -2613,7 +2616,7 @@ static int mem_cgroup_move_account(struct page *page,
>  		__mem_cgroup_cancel_charge(from, nr_pages);
>  
>  	/* caller should have done css_get */
> -	pc->mem_cgroup = to;
> +	pc_set_mem_cgroup(pc, to);
>  	mem_cgroup_charge_statistics(to, anon, nr_pages);
>  	/*
>  	 * We charges against "to" which may not have any tasks. Then, "to"
> @@ -2956,7 +2959,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  
>  	lock_page_cgroup(pc);
>  
> -	memcg = pc->mem_cgroup;
> +	memcg = pc_to_mem_cgroup(pc);
>  
>  	if (!PageCgroupUsed(pc))
>  		goto unlock_out;
> @@ -2992,7 +2995,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  
>  	ClearPageCgroupUsed(pc);
>  	/*
> -	 * pc->mem_cgroup is not cleared here. It will be accessed when it's
> +	 * pc's mem_cgroup is not cleared here. It will be accessed when it's
>  	 * freed from LRU. This is safe because uncharged page is expected not
>  	 * to be reused (freed soon). Exception is SwapCache, it's handled by
>  	 * special functions.
> @@ -3214,7 +3217,7 @@ int mem_cgroup_prepare_migration(struct page *page,
>  	pc = lookup_page_cgroup(page);
>  	lock_page_cgroup(pc);
>  	if (PageCgroupUsed(pc)) {
> -		memcg = pc->mem_cgroup;
> +		memcg = pc_to_mem_cgroup(pc);
>  		css_get(&memcg->css);
>  		/*
>  		 * At migrating an anonymous page, its mapcount goes down
> @@ -3359,7 +3362,7 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,
>  	pc = lookup_page_cgroup(oldpage);
>  	/* fix accounting on old pages */
>  	lock_page_cgroup(pc);
> -	memcg = pc->mem_cgroup;
> +	memcg = pc_to_mem_cgroup(pc);
>  	mem_cgroup_charge_statistics(memcg, false, -1);
>  	ClearPageCgroupUsed(pc);
>  	unlock_page_cgroup(pc);
> @@ -3370,7 +3373,7 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,
>  	/*
>  	 * Even if newpage->mapping was NULL before starting replacement,
>  	 * the newpage may be on LRU(or pagevec for LRU) already. We lock
> -	 * LRU while we overwrite pc->mem_cgroup.
> +	 * LRU while we overwrite pc's mem_cgroup.
>  	 */
>  	__mem_cgroup_commit_charge(memcg, newpage, 1, pc, type, true);
>  }
> @@ -3406,7 +3409,7 @@ void mem_cgroup_print_bad_page(struct page *page)
>  	pc = lookup_page_cgroup_used(page);
>  	if (pc) {
>  		printk(KERN_ALERT "pc:%p pc->flags:%lx pc->mem_cgroup:%p\n",
> -		       pc, pc->flags, pc->mem_cgroup);
> +		       pc, pc->flags, pc_to_mem_cgroup(pc));
>  	}
>  }
>  #endif
> @@ -5197,7 +5200,7 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
>  		 * mem_cgroup_move_account() checks the pc is valid or not under
>  		 * the lock.
>  		 */
> -		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
> +		if (PageCgroupUsed(pc) && pc_to_mem_cgroup(pc) == mc.from) {
>  			ret = MC_TARGET_PAGE;
>  			if (target)
>  				target->page = page;
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
