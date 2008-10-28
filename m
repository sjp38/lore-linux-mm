Date: Tue, 28 Oct 2008 20:40:41 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 2/4][mmotm] memcg: introduce charge-commit-cancel style
 of functions.
Message-Id: <20081028204041.54dc1873.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081028191125.2197d276.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081028190911.6857b0a6.kamezawa.hiroyu@jp.fujitsu.com>
	<20081028191125.2197d276.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Oct 2008 19:11:25 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> There is a small race in do_swap_page(). When the page swapped-in is charged,
> the mapcount can be greater than 0. But, at the same time some process (shares
> it ) call unmap and make mapcount 1->0 and the page is uncharged.
> 
>       CPUA 			CPUB
>        mapcount == 1.
>    (1) charge if mapcount==0     zap_pte_range()
>                                 (2) mapcount 1 => 0.
> 			        (3) uncharge(). (success)
>    (4) set page's rmap()
>        mapcount 0=>1
> 
> Then, this swap page's account is leaked.
> 
> For fixing this, I added a new interface.
>   - charge
>    account to res_counter by PAGE_SIZE and try to free pages if necessary.
>   - commit	
>    register page_cgroup and add to LRU if necessary.
>   - cancel
>    uncharge PAGE_SIZE because of do_swap_page failure.
> 
> 
>      CPUA              
>   (1) charge (always)
>   (2) set page's rmap (mapcount > 0)
>   (3) commit charge was necessary or not after set_pte().
> 
> This protocol uses PCG_USED bit on page_cgroup for avoiding over accounting.
> Usual mem_cgroup_charge_common() does charge -> commit at a time.
> 
> And this patch also adds following function to clarify all charges.
> 
>   - mem_cgroup_newpage_charge() ....replacement for mem_cgroup_charge()
> 	called against newly allocated anon pages.
> 
>   - mem_cgroup_charge_migrate_fixup()
>         called only from remove_migration_ptes().
> 	we'll have to rewrite this later.(this patch just keeps old behavior)
> 	This function will be removed by additional patch to make migration
> 	clearer.
> 
> Good for clarify "what we does"
> 
> Then, we have 4 following charge points.
>   - newpage
>   - swap-in
>   - add-to-cache.
>   - migration.
> 
> Changelog v8 -> v9
>  - fixed text
> Changelog v7 -> v8
>  - handles that try_charge() sets NULL to *memcg.
> 
> Changelog v5 -> v7:
>  - added newpage_charge() and migrate_fixup().
>  - renamed  functions for swap-in from "swap" to "swapin"
>  - add more precise description.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
Looks good to me.

	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>


>  include/linux/memcontrol.h |   35 +++++++++-
>  mm/memcontrol.c            |  155 ++++++++++++++++++++++++++++++++++++---------
>  mm/memory.c                |   12 ++-
>  mm/migrate.c               |    2 
>  mm/swapfile.c              |    6 +
>  5 files changed, 169 insertions(+), 41 deletions(-)
> 
> Index: mmotm-2.6.28rc2+/include/linux/memcontrol.h
> ===================================================================
> --- mmotm-2.6.28rc2+.orig/include/linux/memcontrol.h
> +++ mmotm-2.6.28rc2+/include/linux/memcontrol.h
> @@ -27,8 +27,17 @@ struct mm_struct;
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  
> -extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
> +extern int mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
>  				gfp_t gfp_mask);
> +extern int mem_cgroup_charge_migrate_fixup(struct page *page,
> +				struct mm_struct *mm, gfp_t gfp_mask);
> +/* for swap handling */
> +extern int mem_cgroup_try_charge(struct mm_struct *mm,
> +		gfp_t gfp_mask, struct mem_cgroup **ptr);
> +extern void mem_cgroup_commit_charge_swapin(struct page *page,
> +					struct mem_cgroup *ptr);
> +extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *ptr);
> +
>  extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  					gfp_t gfp_mask);
>  extern void mem_cgroup_move_lists(struct page *page, enum lru_list lru);
> @@ -71,7 +80,9 @@ extern long mem_cgroup_calc_reclaim(stru
>  
>  
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
> -static inline int mem_cgroup_charge(struct page *page,
> +struct mem_cgroup;
> +
> +static inline int mem_cgroup_newpage_charge(struct page *page,
>  					struct mm_struct *mm, gfp_t gfp_mask)
>  {
>  	return 0;
> @@ -83,6 +94,26 @@ static inline int mem_cgroup_cache_charg
>  	return 0;
>  }
>  
> +static inline int mem_cgroup_charge_migrate_fixup(struct page *page,
> +					struct mm_struct *mm, gfp_t gfp_mask)
> +{
> +	return 0;
> +}
> +
> +static int mem_cgroup_try_charge(struct mm_struct *mm,
> +				gfp_t gfp_mask, struct mem_cgroup **ptr)
> +{
> +	return 0;
> +}
> +
> +static void mem_cgroup_commit_charge_swapin(struct page *page,
> +					  struct mem_cgroup *ptr)
> +{
> +}
> +static void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *ptr)
> +{
> +}
> +
>  static inline void mem_cgroup_uncharge_page(struct page *page)
>  {
>  }
> Index: mmotm-2.6.28rc2+/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.28rc2+.orig/mm/memcontrol.c
> +++ mmotm-2.6.28rc2+/mm/memcontrol.c
> @@ -467,35 +467,31 @@ unsigned long mem_cgroup_isolate_pages(u
>  	return nr_taken;
>  }
>  
> -/*
> - * Charge the memory controller for page usage.
> - * Return
> - * 0 if the charge was successful
> - * < 0 if the cgroup is over its limit
> +
> +/**
> + * mem_cgroup_try_charge - get charge of PAGE_SIZE.
> + * @mm: an mm_struct which is charged against. (when *memcg is NULL)
> + * @gfp_mask: gfp_mask for reclaim.
> + * @memcg: a pointer to memory cgroup which is charged against.
> + *
> + * charge against memory cgroup pointed by *memcg. if *memcg == NULL, estimated
> + * memory cgroup from @mm is got and stored in *memcg.
> + *
> + * Returns 0 if success. -ENOMEM at failure.
>   */
> -static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
> -				gfp_t gfp_mask, enum charge_type ctype,
> -				struct mem_cgroup *memcg)
> +
> +int mem_cgroup_try_charge(struct mm_struct *mm,
> +			gfp_t gfp_mask, struct mem_cgroup **memcg)
>  {
>  	struct mem_cgroup *mem;
> -	struct page_cgroup *pc;
> -	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> -	struct mem_cgroup_per_zone *mz;
> -	unsigned long flags;
> -
> -	pc = lookup_page_cgroup(page);
> -	/* can happen at boot */
> -	if (unlikely(!pc))
> -		return 0;
> -	prefetchw(pc);
> +	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
>  	/*
>  	 * We always charge the cgroup the mm_struct belongs to.
>  	 * The mm_struct's mem_cgroup changes on task migration if the
>  	 * thread group leader migrates. It's possible that mm is not
>  	 * set, if so charge the init_mm (happens for pagecache usage).
>  	 */
> -
> -	if (likely(!memcg)) {
> +	if (likely(!*memcg)) {
>  		rcu_read_lock();
>  		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
>  		if (unlikely(!mem)) {
> @@ -506,15 +502,17 @@ static int mem_cgroup_charge_common(stru
>  		 * For every charge from the cgroup, increment reference count
>  		 */
>  		css_get(&mem->css);
> +		*memcg = mem;
>  		rcu_read_unlock();
>  	} else {
> -		mem = memcg;
> -		css_get(&memcg->css);
> +		mem = *memcg;
> +		css_get(&mem->css);
>  	}
>  
> +
>  	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE))) {
>  		if (!(gfp_mask & __GFP_WAIT))
> -			goto out;
> +			goto nomem;
>  
>  		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
>  			continue;
> @@ -531,18 +529,37 @@ static int mem_cgroup_charge_common(stru
>  
>  		if (!nr_retries--) {
>  			mem_cgroup_out_of_memory(mem, gfp_mask);
> -			goto out;
> +			goto nomem;
>  		}
>  	}
> +	return 0;
> +nomem:
> +	css_put(&mem->css);
> +	return -ENOMEM;
> +}
> +
> +/*
> + * commit a charge got by mem_cgroup_try_charge() and makes page_cgroup to be
> + * USED state. If already USED, uncharge and return.
> + */
>  
> +static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
> +				     struct page_cgroup *pc,
> +				     enum charge_type ctype)
> +{
> +	struct mem_cgroup_per_zone *mz;
> +	unsigned long flags;
> +
> +	/* try_charge() can return NULL to *memcg, taking care of it. */
> +	if (!mem)
> +		return;
>  
>  	lock_page_cgroup(pc);
>  	if (unlikely(PageCgroupUsed(pc))) {
>  		unlock_page_cgroup(pc);
>  		res_counter_uncharge(&mem->res, PAGE_SIZE);
>  		css_put(&mem->css);
> -
> -		goto done;
> +		return;
>  	}
>  	pc->mem_cgroup = mem;
>  	/*
> @@ -557,15 +574,39 @@ static int mem_cgroup_charge_common(stru
>  	__mem_cgroup_add_list(mz, pc);
>  	spin_unlock_irqrestore(&mz->lru_lock, flags);
>  	unlock_page_cgroup(pc);
> +}
> +
> +/*
> + * Charge the memory controller for page usage.
> + * Return
> + * 0 if the charge was successful
> + * < 0 if the cgroup is over its limit
> + */
> +static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
> +				gfp_t gfp_mask, enum charge_type ctype,
> +				struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup *mem;
> +	struct page_cgroup *pc;
> +	int ret;
>  
> -done:
> +	pc = lookup_page_cgroup(page);
> +	/* can happen at boot */
> +	if (unlikely(!pc))
> +		return 0;
> +	prefetchw(pc);
> +
> +	mem = memcg;
> +	ret = mem_cgroup_try_charge(mm, gfp_mask, &mem);
> +	if (ret)
> +		return ret;
> +
> +	__mem_cgroup_commit_charge(mem, pc, ctype);
>  	return 0;
> -out:
> -	css_put(&mem->css);
> -	return -ENOMEM;
>  }
>  
> -int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
> +int mem_cgroup_newpage_charge(struct page *page,
> +			      struct mm_struct *mm, gfp_t gfp_mask)
>  {
>  	if (mem_cgroup_subsys.disabled)
>  		return 0;
> @@ -586,6 +627,34 @@ int mem_cgroup_charge(struct page *page,
>  				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
>  }
>  
> +/*
> + * same as mem_cgroup_newpage_charge(), now.
> + * But what we assume is different from newpage, and this is special case.
> + * treat this in special function. easy for maintenance.
> + */
> +
> +int mem_cgroup_charge_migrate_fixup(struct page *page,
> +				struct mm_struct *mm, gfp_t gfp_mask)
> +{
> +	if (mem_cgroup_subsys.disabled)
> +		return 0;
> +
> +	if (PageCompound(page))
> +		return 0;
> +
> +	if (page_mapped(page) || (page->mapping && !PageAnon(page)))
> +		return 0;
> +
> +	if (unlikely(!mm))
> +		mm = &init_mm;
> +
> +	return mem_cgroup_charge_common(page, mm, gfp_mask,
> +				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
> +}
> +
> +
> +
> +
>  int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  				gfp_t gfp_mask)
>  {
> @@ -628,6 +697,30 @@ int mem_cgroup_cache_charge(struct page 
>  				MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
>  }
>  
> +
> +void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
> +{
> +	struct page_cgroup *pc;
> +
> +	if (mem_cgroup_subsys.disabled)
> +		return;
> +	if (!ptr)
> +		return;
> +	pc = lookup_page_cgroup(page);
> +	__mem_cgroup_commit_charge(ptr, pc, MEM_CGROUP_CHARGE_TYPE_MAPPED);
> +}
> +
> +void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
> +{
> +	if (mem_cgroup_subsys.disabled)
> +		return;
> +	if (!mem)
> +		return;
> +	res_counter_uncharge(&mem->res, PAGE_SIZE);
> +	css_put(&mem->css);
> +}
> +
> +
>  /*
>   * uncharge if !page_mapped(page)
>   */
> Index: mmotm-2.6.28rc2+/mm/memory.c
> ===================================================================
> --- mmotm-2.6.28rc2+.orig/mm/memory.c
> +++ mmotm-2.6.28rc2+/mm/memory.c
> @@ -1889,7 +1889,7 @@ gotten:
>  	cow_user_page(new_page, old_page, address, vma);
>  	__SetPageUptodate(new_page);
>  
> -	if (mem_cgroup_charge(new_page, mm, GFP_KERNEL))
> +	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
>  		goto oom_free_new;
>  
>  	/*
> @@ -2285,6 +2285,7 @@ static int do_swap_page(struct mm_struct
>  	struct page *page;
>  	swp_entry_t entry;
>  	pte_t pte;
> +	struct mem_cgroup *ptr = NULL;
>  	int ret = 0;
>  
>  	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
> @@ -2323,7 +2324,7 @@ static int do_swap_page(struct mm_struct
>  	lock_page(page);
>  	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
>  
> -	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
> +	if (mem_cgroup_try_charge(mm, GFP_KERNEL, &ptr) == -ENOMEM) {
>  		ret = VM_FAULT_OOM;
>  		unlock_page(page);
>  		goto out;
> @@ -2353,6 +2354,7 @@ static int do_swap_page(struct mm_struct
>  	flush_icache_page(vma, page);
>  	set_pte_at(mm, address, page_table, pte);
>  	page_add_anon_rmap(page, vma, address);
> +	mem_cgroup_commit_charge_swapin(page, ptr);
>  
>  	swap_free(entry);
>  	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
> @@ -2373,7 +2375,7 @@ unlock:
>  out:
>  	return ret;
>  out_nomap:
> -	mem_cgroup_uncharge_page(page);
> +	mem_cgroup_cancel_charge_swapin(ptr);
>  	pte_unmap_unlock(page_table, ptl);
>  	unlock_page(page);
>  	page_cache_release(page);
> @@ -2403,7 +2405,7 @@ static int do_anonymous_page(struct mm_s
>  		goto oom;
>  	__SetPageUptodate(page);
>  
> -	if (mem_cgroup_charge(page, mm, GFP_KERNEL))
> +	if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))
>  		goto oom_free_page;
>  
>  	entry = mk_pte(page, vma->vm_page_prot);
> @@ -2496,7 +2498,7 @@ static int __do_fault(struct mm_struct *
>  				ret = VM_FAULT_OOM;
>  				goto out;
>  			}
> -			if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
> +			if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL)) {
>  				ret = VM_FAULT_OOM;
>  				page_cache_release(page);
>  				goto out;
> Index: mmotm-2.6.28rc2+/mm/migrate.c
> ===================================================================
> --- mmotm-2.6.28rc2+.orig/mm/migrate.c
> +++ mmotm-2.6.28rc2+/mm/migrate.c
> @@ -133,7 +133,7 @@ static void remove_migration_pte(struct 
>  	 * be reliable, and this charge can actually fail: oh well, we don't
>  	 * make the situation any worse by proceeding as if it had succeeded.
>  	 */
> -	mem_cgroup_charge(new, mm, GFP_ATOMIC);
> +	mem_cgroup_charge_migrate_fixup(new, mm, GFP_ATOMIC);
>  
>  	get_page(new);
>  	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
> Index: mmotm-2.6.28rc2+/mm/swapfile.c
> ===================================================================
> --- mmotm-2.6.28rc2+.orig/mm/swapfile.c
> +++ mmotm-2.6.28rc2+/mm/swapfile.c
> @@ -530,17 +530,18 @@ unsigned int count_swap_pages(int type, 
>  static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
>  		unsigned long addr, swp_entry_t entry, struct page *page)
>  {
> +	struct mem_cgroup *ptr = NULL;
>  	spinlock_t *ptl;
>  	pte_t *pte;
>  	int ret = 1;
>  
> -	if (mem_cgroup_charge(page, vma->vm_mm, GFP_KERNEL))
> +	if (mem_cgroup_try_charge(vma->vm_mm, GFP_KERNEL, &ptr))
>  		ret = -ENOMEM;
>  
>  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>  	if (unlikely(!pte_same(*pte, swp_entry_to_pte(entry)))) {
>  		if (ret > 0)
> -			mem_cgroup_uncharge_page(page);
> +			mem_cgroup_cancel_charge_swapin(ptr);
>  		ret = 0;
>  		goto out;
>  	}
> @@ -550,6 +551,7 @@ static int unuse_pte(struct vm_area_stru
>  	set_pte_at(vma->vm_mm, addr, pte,
>  		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
>  	page_add_anon_rmap(page, vma, addr);
> +	mem_cgroup_commit_charge_swapin(page, ptr);
>  	swap_free(entry);
>  	/*
>  	 * Move the page to the active list so it is not
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
