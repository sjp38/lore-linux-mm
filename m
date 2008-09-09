Date: Tue, 9 Sep 2008 12:57:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
Message-Id: <20080909125751.37042345.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080908152810.GA12065@balbir.in.ibm.com>
References: <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com>
	<200809011743.42658.nickpiggin@yahoo.com.au>
	<48BD0641.4040705@linux.vnet.ibm.com>
	<20080902190256.1375f593.kamezawa.hiroyu@jp.fujitsu.com>
	<48BD0E4A.5040502@linux.vnet.ibm.com>
	<20080902190723.841841f0.kamezawa.hiroyu@jp.fujitsu.com>
	<48BD119B.8020605@linux.vnet.ibm.com>
	<20080902195717.224b0822.kamezawa.hiroyu@jp.fujitsu.com>
	<48BD337E.40001@linux.vnet.ibm.com>
	<20080903123306.316beb9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20080908152810.GA12065@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Sep 2008 20:58:10 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> Sorry for the delay in sending out the new patch, I am traveling and
> thus a little less responsive. Here is the update patch
> 
> 
Hmm.. I've considered this approach for a while and my answer is that
this is not what you really want.

Because you just moves the placement of pointer from memmap to
radix_tree both in GFP_KERNEL, total kernel memory usage is not changed.
So, at least, you have to add some address calculation (as I did in March)
to getting address of page_cgroup. But page_cgroup itself consumes 32bytes
per page. Then.....

My proposal to 32bit system is following 
 - remove page_cgroup completely.
   - As a result, there is no per-cgroup lru. But it will not be bad
     bacause the number of cgroups and pages are not big.
     just a trade-off between kernel-memory-space v.s. speed.
   - Removing page_cgroup and just remember address of mem_cgroup per page.

How do you think ?

Thanks,
-Kame


> v3...v2
> 1. Convert flags to unsigned long
> 2. Move page_cgroup->lock to a bit spin lock in flags
> 
> v2...v1
> 
> 1. Fix a small bug, don't call radix_tree_preload_end(), if preload fails
> 
> This is a rewrite of a patch I had written long back to remove struct page
> (I shared the patches with Kamezawa, but never posted them anywhere else).
> I spent the weekend, cleaning them up for 2.6.27-rc5-mmotm (29 Aug 2008).
> 
> I've tested the patches on an x86_64 box, I've run a simple test running
> under the memory control group and the same test running concurrently under
> two different groups (and creating pressure within their groups). I've also
> compiled the patch with CGROUP_MEM_RES_CTLR turned off.
> 
> Advantages of the patch
> 
> 1. It removes the extra pointer in struct page
> 
> Disadvantages
> 
> 1. Radix tree lookup is not an O(1) operation, once the page is known
>    getting to the page_cgroup (pc) is a little more expensive now.
> 
> This is an initial RFC for comments
> 
> TODOs
> 
> 1. Test the page migration changes
> 
> Performance
> 
> In a unixbench run, these patches had a performance impact of 2% (slowdown).
> 
> Comments/Reviews?
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  include/linux/memcontrol.h |   23 +++++
>  include/linux/mm_types.h   |    4 
>  mm/memcontrol.c            |  187 +++++++++++++++++++++++++++++----------------
>  3 files changed, 144 insertions(+), 70 deletions(-)
> 
> diff -puN mm/memcontrol.c~memcg_move_to_radix_tree mm/memcontrol.c
> --- linux-2.6.27-rc5/mm/memcontrol.c~memcg_move_to_radix_tree	2008-09-04 15:45:54.000000000 +0530
> +++ linux-2.6.27-rc5-balbir/mm/memcontrol.c	2008-09-08 20:15:30.000000000 +0530
> @@ -24,6 +24,7 @@
>  #include <linux/smp.h>
>  #include <linux/page-flags.h>
>  #include <linux/backing-dev.h>
> +#include <linux/radix-tree.h>
>  #include <linux/bit_spinlock.h>
>  #include <linux/rcupdate.h>
>  #include <linux/slab.h>
> @@ -40,6 +41,9 @@ struct cgroup_subsys mem_cgroup_subsys _
>  static struct kmem_cache *page_cgroup_cache __read_mostly;
>  #define MEM_CGROUP_RECLAIM_RETRIES	5
>  
> +static struct radix_tree_root mem_cgroup_tree;
> +static spinlock_t mem_cgroup_tree_lock;
> +
>  /*
>   * Statistics for memory cgroup.
>   */
> @@ -137,20 +141,6 @@ struct mem_cgroup {
>  static struct mem_cgroup init_mem_cgroup;
>  
>  /*
> - * We use the lower bit of the page->page_cgroup pointer as a bit spin
> - * lock.  We need to ensure that page->page_cgroup is at least two
> - * byte aligned (based on comments from Nick Piggin).  But since
> - * bit_spin_lock doesn't actually set that lock bit in a non-debug
> - * uniprocessor kernel, we should avoid setting it here too.
> - */
> -#define PAGE_CGROUP_LOCK_BIT 	0x0
> -#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
> -#define PAGE_CGROUP_LOCK 	(1 << PAGE_CGROUP_LOCK_BIT)
> -#else
> -#define PAGE_CGROUP_LOCK	0x0
> -#endif
> -
> -/*
>   * A page_cgroup page is associated with every page descriptor. The
>   * page_cgroup helps us identify information about the cgroup
>   */
> @@ -158,12 +148,17 @@ struct page_cgroup {
>  	struct list_head lru;		/* per cgroup LRU list */
>  	struct page *page;
>  	struct mem_cgroup *mem_cgroup;
> -	int flags;
> +	unsigned long flags;
>  };
> -#define PAGE_CGROUP_FLAG_CACHE	   (0x1)	/* charged as cache */
> -#define PAGE_CGROUP_FLAG_ACTIVE    (0x2)	/* page is active in this cgroup */
> -#define PAGE_CGROUP_FLAG_FILE	   (0x4)	/* page is file system backed */
> -#define PAGE_CGROUP_FLAG_UNEVICTABLE (0x8)	/* page is unevictableable */
> +
> +/*
> + * LOCK_BIT is 0, with value 1
> + */
> +#define PAGE_CGROUP_FLAG_LOCK_BIT   (0x0)  /* lock bit */
> +#define PAGE_CGROUP_FLAG_CACHE	   (0x2)   /* charged as cache */
> +#define PAGE_CGROUP_FLAG_ACTIVE    (0x4)   /* page is active in this cgroup */
> +#define PAGE_CGROUP_FLAG_FILE	   (0x8)   /* page is file system backed */
> +#define PAGE_CGROUP_FLAG_UNEVICTABLE (0x10)/* page is unevictableable */
>  
>  static int page_cgroup_nid(struct page_cgroup *pc)
>  {
> @@ -248,35 +243,81 @@ struct mem_cgroup *mem_cgroup_from_task(
>  				struct mem_cgroup, css);
>  }
>  
> -static inline int page_cgroup_locked(struct page *page)
> +static inline void lock_page_cgroup(struct page_cgroup *pc)
>  {
> -	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
> +	bit_spin_lock(PAGE_CGROUP_FLAG_LOCK_BIT, &pc->flags);
>  }
>  
> -static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
> +static inline int trylock_page_cgroup(struct page_cgroup *pc)
>  {
> -	VM_BUG_ON(!page_cgroup_locked(page));
> -	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
> +	return bit_spin_trylock(PAGE_CGROUP_FLAG_LOCK_BIT, &pc->flags);
>  }
>  
> -struct page_cgroup *page_get_page_cgroup(struct page *page)
> +static inline void unlock_page_cgroup(struct page_cgroup *pc)
>  {
> -	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
> +	bit_spin_unlock(PAGE_CGROUP_FLAG_LOCK_BIT, &pc->flags);
>  }
>  
> -static void lock_page_cgroup(struct page *page)
> +static int page_assign_page_cgroup(struct page *page, struct page_cgroup *pc,
> +					gfp_t gfp_mask)
>  {
> -	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
> -}
> +	unsigned long pfn = page_to_pfn(page);
> +	unsigned long flags;
> +	int err = 0;
> +	struct page_cgroup *old_pc;
>  
> -static int try_lock_page_cgroup(struct page *page)
> -{
> -	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
> +	if (pc) {
> +		err = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> +		if (err) {
> +			printk(KERN_WARNING "could not preload radix tree "
> +				"in %s\n", __func__);
> +			goto done;
> +		}
> +	}
> +
> +	spin_lock_irqsave(&mem_cgroup_tree_lock, flags);
> +	old_pc = radix_tree_lookup(&mem_cgroup_tree, pfn);
> +	if (pc && old_pc) {
> +		err = -EEXIST;
> +		goto pc_race;
> +	}
> +	if (pc) {
> +		err = radix_tree_insert(&mem_cgroup_tree, pfn, pc);
> +		if (err)
> +			printk(KERN_WARNING "Inserting into radix tree failed "
> +				"in %s\n", __func__);
> +	} else
> +		radix_tree_delete(&mem_cgroup_tree, pfn);
> +pc_race:
> +	spin_unlock_irqrestore(&mem_cgroup_tree_lock, flags);
> +	if (pc)
> +		radix_tree_preload_end();
> +done:
> +	return err;
>  }
>  
> -static void unlock_page_cgroup(struct page *page)
> +struct page_cgroup *__page_get_page_cgroup(struct page *page, bool lock,
> +						bool trylock)
>  {
> -	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
> +	unsigned long pfn = page_to_pfn(page);
> +	struct page_cgroup *pc;
> +	int ret;
> +
> +	rcu_read_lock();
> +	pc = radix_tree_lookup(&mem_cgroup_tree, pfn);
> +
> +	if (pc && lock)
> +		lock_page_cgroup(pc);
> +
> +	if (pc && trylock) {
> +		ret = trylock_page_cgroup(pc);
> +		if (!ret)
> +			pc = NULL;
> +	}
> +
> +	rcu_read_unlock();
> +
> +	return pc;
>  }
>  
>  static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
> @@ -377,17 +418,15 @@ void mem_cgroup_move_lists(struct page *
>  	 * safely get to page_cgroup without it, so just try_lock it:
>  	 * mem_cgroup_isolate_pages allows for page left on wrong list.
>  	 */
> -	if (!try_lock_page_cgroup(page))
> +	pc = page_get_page_cgroup_trylock(page);
> +	if (!pc)
>  		return;
>  
> -	pc = page_get_page_cgroup(page);
> -	if (pc) {
> -		mz = page_cgroup_zoneinfo(pc);
> -		spin_lock_irqsave(&mz->lru_lock, flags);
> -		__mem_cgroup_move_lists(pc, lru);
> -		spin_unlock_irqrestore(&mz->lru_lock, flags);
> -	}
> -	unlock_page_cgroup(page);
> +	mz = page_cgroup_zoneinfo(pc);
> +	spin_lock_irqsave(&mz->lru_lock, flags);
> +	__mem_cgroup_move_lists(pc, lru);
> +	spin_unlock_irqrestore(&mz->lru_lock, flags);
> +	unlock_page_cgroup(pc);
>  }
>  
>  /*
> @@ -516,7 +555,7 @@ static int mem_cgroup_charge_common(stru
>  				struct mem_cgroup *memcg)
>  {
>  	struct mem_cgroup *mem;
> -	struct page_cgroup *pc;
> +	struct page_cgroup *pc, *old_pc;
>  	unsigned long flags;
>  	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
>  	struct mem_cgroup_per_zone *mz;
> @@ -569,35 +608,49 @@ static int mem_cgroup_charge_common(stru
>  
>  	pc->mem_cgroup = mem;
>  	pc->page = page;
> +	pc->flags = 0;		/* No lock, no other bits either */
> +
>  	/*
>  	 * If a page is accounted as a page cache, insert to inactive list.
>  	 * If anon, insert to active list.
>  	 */
>  	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE) {
> -		pc->flags = PAGE_CGROUP_FLAG_CACHE;
> +		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
>  		if (page_is_file_cache(page))
>  			pc->flags |= PAGE_CGROUP_FLAG_FILE;
>  		else
>  			pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
>  	} else
> -		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
> +		pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
> +
> +	old_pc = page_get_page_cgroup_locked(page);
> +	if (old_pc) {
> +		unlock_page_cgroup(old_pc);
> +		res_counter_uncharge(&mem->res, PAGE_SIZE);
> +		css_put(&mem->css);
> +		kmem_cache_free(page_cgroup_cache, pc);
> +		goto done;
> +	}
>  
> -	lock_page_cgroup(page);
> -	if (unlikely(page_get_page_cgroup(page))) {
> -		unlock_page_cgroup(page);
> +	lock_page_cgroup(pc);
> +	/*
> +	 * page_get_page_cgroup() does not necessarily guarantee that
> +	 * there will be no race in checking for pc, page_assign_page_pc()
> +	 * will definitely catch it.
> +	 */
> +	if (page_assign_page_cgroup(page, pc, gfp_mask)) {
> +		unlock_page_cgroup(pc);
>  		res_counter_uncharge(&mem->res, PAGE_SIZE);
>  		css_put(&mem->css);
>  		kmem_cache_free(page_cgroup_cache, pc);
>  		goto done;
>  	}
> -	page_assign_page_cgroup(page, pc);
>  
>  	mz = page_cgroup_zoneinfo(pc);
>  	spin_lock_irqsave(&mz->lru_lock, flags);
>  	__mem_cgroup_add_list(mz, pc);
>  	spin_unlock_irqrestore(&mz->lru_lock, flags);
> -
> -	unlock_page_cgroup(page);
> +	unlock_page_cgroup(pc);
>  done:
>  	return 0;
>  out:
> @@ -645,15 +698,13 @@ int mem_cgroup_cache_charge(struct page 
>  	if (!(gfp_mask & __GFP_WAIT)) {
>  		struct page_cgroup *pc;
>  
> -		lock_page_cgroup(page);
> -		pc = page_get_page_cgroup(page);
> +		pc = page_get_page_cgroup_locked(page);
>  		if (pc) {
>  			VM_BUG_ON(pc->page != page);
>  			VM_BUG_ON(!pc->mem_cgroup);
> -			unlock_page_cgroup(page);
> +			unlock_page_cgroup(pc);
>  			return 0;
>  		}
> -		unlock_page_cgroup(page);
>  	}
>  
>  	if (unlikely(!mm))
> @@ -673,6 +724,7 @@ __mem_cgroup_uncharge_common(struct page
>  	struct mem_cgroup *mem;
>  	struct mem_cgroup_per_zone *mz;
>  	unsigned long flags;
> +	int ret;
>  
>  	if (mem_cgroup_subsys.disabled)
>  		return;
> @@ -680,8 +732,7 @@ __mem_cgroup_uncharge_common(struct page
>  	/*
>  	 * Check if our page_cgroup is valid
>  	 */
> -	lock_page_cgroup(page);
> -	pc = page_get_page_cgroup(page);
> +	pc = page_get_page_cgroup_locked(page);
>  	if (unlikely(!pc))
>  		goto unlock;
>  
> @@ -697,8 +748,9 @@ __mem_cgroup_uncharge_common(struct page
>  	__mem_cgroup_remove_list(mz, pc);
>  	spin_unlock_irqrestore(&mz->lru_lock, flags);
>  
> -	page_assign_page_cgroup(page, NULL);
> -	unlock_page_cgroup(page);
> +	ret = page_assign_page_cgroup(page, NULL, GFP_KERNEL);
> +	VM_BUG_ON(ret);
> +	unlock_page_cgroup(pc);
>  
>  	mem = pc->mem_cgroup;
>  	res_counter_uncharge(&mem->res, PAGE_SIZE);
> @@ -707,7 +759,14 @@ __mem_cgroup_uncharge_common(struct page
>  	kmem_cache_free(page_cgroup_cache, pc);
>  	return;
>  unlock:
> -	unlock_page_cgroup(page);
> +	unlock_page_cgroup(pc);
> +}
> +
> +void page_reset_bad_cgroup(struct page *page)
> +{
> +	int ret;
> +	ret = page_assign_page_cgroup(page, NULL, GFP_KERNEL);
> +	VM_BUG_ON(ret);
>  }
>  
>  void mem_cgroup_uncharge_page(struct page *page)
> @@ -734,15 +793,14 @@ int mem_cgroup_prepare_migration(struct 
>  	if (mem_cgroup_subsys.disabled)
>  		return 0;
>  
> -	lock_page_cgroup(page);
> -	pc = page_get_page_cgroup(page);
> +	pc = page_get_page_cgroup_locked(page);
>  	if (pc) {
>  		mem = pc->mem_cgroup;
>  		css_get(&mem->css);
>  		if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
>  			ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> +		unlock_page_cgroup(pc);
>  	}
> -	unlock_page_cgroup(page);
>  	if (mem) {
>  		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
>  			ctype, mem);
> @@ -1107,6 +1165,7 @@ mem_cgroup_create(struct cgroup_subsys *
>  	if (unlikely((cont->parent) == NULL)) {
>  		mem = &init_mem_cgroup;
>  		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
> +		spin_lock_init(&mem_cgroup_tree_lock);
>  	} else {
>  		mem = mem_cgroup_alloc();
>  		if (!mem)
> diff -puN include/linux/memcontrol.h~memcg_move_to_radix_tree include/linux/memcontrol.h
> --- linux-2.6.27-rc5/include/linux/memcontrol.h~memcg_move_to_radix_tree	2008-09-04 15:45:54.000000000 +0530
> +++ linux-2.6.27-rc5-balbir/include/linux/memcontrol.h	2008-09-04 15:45:54.000000000 +0530
> @@ -27,9 +27,28 @@ struct mm_struct;
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  
> -#define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
> +extern void page_reset_bad_cgroup(struct page *page);
> +extern struct page_cgroup *__page_get_page_cgroup(struct page *page, bool lock,
> +							bool trylock);
> +
> +static __always_inline
> +struct page_cgroup *page_get_page_cgroup(struct page *page)
> +{
> +	return __page_get_page_cgroup(page, false, false);
> +}
> +
> +static __always_inline
> +struct page_cgroup *page_get_page_cgroup_trylock(struct page *page)
> +{
> +	return __page_get_page_cgroup(page, false, true);
> +}
> +
> +static __always_inline
> +struct page_cgroup *page_get_page_cgroup_locked(struct page *page)
> +{
> +	return __page_get_page_cgroup(page, true, false);
> +}
>  
> -extern struct page_cgroup *page_get_page_cgroup(struct page *page);
>  extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
>  				gfp_t gfp_mask);
>  extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> diff -puN include/linux/mm_types.h~memcg_move_to_radix_tree include/linux/mm_types.h
> --- linux-2.6.27-rc5/include/linux/mm_types.h~memcg_move_to_radix_tree	2008-09-04 15:45:54.000000000 +0530
> +++ linux-2.6.27-rc5-balbir/include/linux/mm_types.h	2008-09-04 15:45:54.000000000 +0530
> @@ -92,10 +92,6 @@ struct page {
>  	void *virtual;			/* Kernel virtual address (NULL if
>  					   not kmapped, ie. highmem) */
>  #endif /* WANT_PAGE_VIRTUAL */
> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> -	unsigned long page_cgroup;
> -#endif
> -
>  #ifdef CONFIG_KMEMCHECK
>  	void *shadow;
>  #endif
> diff -puN mm/page_alloc.c~memcg_move_to_radix_tree mm/page_alloc.c
> _
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
