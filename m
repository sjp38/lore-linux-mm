Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7F22D6B00FC
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 11:52:02 -0500 (EST)
Received: by mail-lb0-f176.google.com with SMTP id z11so7469307lbi.7
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 08:52:01 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j10si33172399laf.95.2014.11.03.08.52.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 08:52:00 -0800 (PST)
Date: Mon, 3 Nov 2014 17:51:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm: embed the memcg pointer directly into struct page
Message-ID: <20141103165158.GE10156@dhcp22.suse.cz>
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat 01-11-14 23:15:54, Johannes Weiner wrote:
> Memory cgroups used to have 5 per-page pointers.  To allow users to
> disable that amount of overhead during runtime, those pointers were
> allocated in a separate array, with a translation layer between them
> and struct page.
> 
> There is now only one page pointer remaining: the memcg pointer, that
> indicates which cgroup the page is associated with when charged.  The
> complexity of runtime allocation and the runtime translation overhead
> is no longer justified to save that *potential* 0.19% of memory.  With
> CONFIG_SLUB, page->mem_cgroup actually sits in the doubleword padding
> after the page->private member and doesn't even increase struct page,
> and then this patch actually saves space.  Remaining users that care
> can still compile their kernels without CONFIG_MEMCG.

CONFIG_SLAB should be OK as well because there should be one slot for
pointer left if no special debugging is enabled.

>    text    data     bss     dec     hex     filename
> 8828345 1725264  983040 11536649 b00909  vmlinux.old
> 8827425 1725264  966656 11519345 afc571  vmlinux.new
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Very nice!

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  include/linux/memcontrol.h  |   6 +-
>  include/linux/mm_types.h    |   5 +
>  include/linux/mmzone.h      |  12 --
>  include/linux/page_cgroup.h |  53 --------
>  init/main.c                 |   7 -
>  mm/memcontrol.c             | 124 +++++------------
>  mm/page_alloc.c             |   2 -
>  mm/page_cgroup.c            | 319 --------------------------------------------
>  8 files changed, 41 insertions(+), 487 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index d4575a1d6e99..dafba59b31b4 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -25,7 +25,6 @@
>  #include <linux/jump_label.h>
>  
>  struct mem_cgroup;
> -struct page_cgroup;
>  struct page;
>  struct mm_struct;
>  struct kmem_cache;
> @@ -466,8 +465,6 @@ memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
>   * memcg_kmem_uncharge_pages: uncharge pages from memcg
>   * @page: pointer to struct page being freed
>   * @order: allocation order.
> - *
> - * there is no need to specify memcg here, since it is embedded in page_cgroup
>   */
>  static inline void
>  memcg_kmem_uncharge_pages(struct page *page, int order)
> @@ -484,8 +481,7 @@ memcg_kmem_uncharge_pages(struct page *page, int order)
>   *
>   * Needs to be called after memcg_kmem_newpage_charge, regardless of success or
>   * failure of the allocation. if @page is NULL, this function will revert the
> - * charges. Otherwise, it will commit the memcg given by @memcg to the
> - * corresponding page_cgroup.
> + * charges. Otherwise, it will commit @page to @memcg.
>   */
>  static inline void
>  memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg, int order)
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index de183328abb0..57e47dffbdda 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -23,6 +23,7 @@
>  #define AT_VECTOR_SIZE (2*(AT_VECTOR_SIZE_ARCH + AT_VECTOR_SIZE_BASE + 1))
>  
>  struct address_space;
> +struct mem_cgroup;
>  
>  #define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
>  #define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
> @@ -168,6 +169,10 @@ struct page {
>  		struct page *first_page;	/* Compound tail pages */
>  	};
>  
> +#ifdef CONFIG_MEMCG
> +	struct mem_cgroup *mem_cgroup;
> +#endif
> +
>  	/*
>  	 * On machines where all RAM is mapped into kernel address space,
>  	 * we can simply calculate the virtual address. On machines with
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 48bf12ef6620..de32d9344446 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -713,9 +713,6 @@ typedef struct pglist_data {
>  	int nr_zones;
>  #ifdef CONFIG_FLAT_NODE_MEM_MAP	/* means !SPARSEMEM */
>  	struct page *node_mem_map;
> -#ifdef CONFIG_MEMCG
> -	struct page_cgroup *node_page_cgroup;
> -#endif
>  #endif
>  #ifndef CONFIG_NO_BOOTMEM
>  	struct bootmem_data *bdata;
> @@ -1069,7 +1066,6 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
>  #define SECTION_ALIGN_DOWN(pfn)	((pfn) & PAGE_SECTION_MASK)
>  
>  struct page;
> -struct page_cgroup;
>  struct mem_section {
>  	/*
>  	 * This is, logically, a pointer to an array of struct
> @@ -1087,14 +1083,6 @@ struct mem_section {
>  
>  	/* See declaration of similar field in struct zone */
>  	unsigned long *pageblock_flags;
> -#ifdef CONFIG_MEMCG
> -	/*
> -	 * If !SPARSEMEM, pgdat doesn't have page_cgroup pointer. We use
> -	 * section. (see memcontrol.h/page_cgroup.h about this.)
> -	 */
> -	struct page_cgroup *page_cgroup;
> -	unsigned long pad;
> -#endif
>  	/*
>  	 * WARNING: mem_section must be a power-of-2 in size for the
>  	 * calculation and use of SECTION_ROOT_MASK to make sense.
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 1289be6b436c..65be35785c86 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -1,59 +1,6 @@
>  #ifndef __LINUX_PAGE_CGROUP_H
>  #define __LINUX_PAGE_CGROUP_H
>  
> -struct pglist_data;
> -
> -#ifdef CONFIG_MEMCG
> -struct mem_cgroup;
> -
> -/*
> - * Page Cgroup can be considered as an extended mem_map.
> - * A page_cgroup page is associated with every page descriptor. The
> - * page_cgroup helps us identify information about the cgroup
> - * All page cgroups are allocated at boot or memory hotplug event,
> - * then the page cgroup for pfn always exists.
> - */
> -struct page_cgroup {
> -	struct mem_cgroup *mem_cgroup;
> -};
> -
> -extern void pgdat_page_cgroup_init(struct pglist_data *pgdat);
> -
> -#ifdef CONFIG_SPARSEMEM
> -static inline void page_cgroup_init_flatmem(void)
> -{
> -}
> -extern void page_cgroup_init(void);
> -#else
> -extern void page_cgroup_init_flatmem(void);
> -static inline void page_cgroup_init(void)
> -{
> -}
> -#endif
> -
> -struct page_cgroup *lookup_page_cgroup(struct page *page);
> -
> -#else /* !CONFIG_MEMCG */
> -struct page_cgroup;
> -
> -static inline void pgdat_page_cgroup_init(struct pglist_data *pgdat)
> -{
> -}
> -
> -static inline struct page_cgroup *lookup_page_cgroup(struct page *page)
> -{
> -	return NULL;
> -}
> -
> -static inline void page_cgroup_init(void)
> -{
> -}
> -
> -static inline void page_cgroup_init_flatmem(void)
> -{
> -}
> -#endif /* CONFIG_MEMCG */
> -
>  #include <linux/swap.h>
>  
>  #ifdef CONFIG_MEMCG_SWAP
> diff --git a/init/main.c b/init/main.c
> index c4912d9abaee..a091bbcadd33 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -51,7 +51,6 @@
>  #include <linux/mempolicy.h>
>  #include <linux/key.h>
>  #include <linux/buffer_head.h>
> -#include <linux/page_cgroup.h>
>  #include <linux/debug_locks.h>
>  #include <linux/debugobjects.h>
>  #include <linux/lockdep.h>
> @@ -485,11 +484,6 @@ void __init __weak thread_info_cache_init(void)
>   */
>  static void __init mm_init(void)
>  {
> -	/*
> -	 * page_cgroup requires contiguous pages,
> -	 * bigger than MAX_ORDER unless SPARSEMEM.
> -	 */
> -	page_cgroup_init_flatmem();
>  	mem_init();
>  	kmem_cache_init();
>  	percpu_init_late();
> @@ -627,7 +621,6 @@ asmlinkage __visible void __init start_kernel(void)
>  		initrd_start = 0;
>  	}
>  #endif
> -	page_cgroup_init();
>  	debug_objects_mem_init();
>  	kmemleak_init();
>  	setup_per_cpu_pageset();
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 19bac2ce827c..dc5e0abb18cb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1274,7 +1274,6 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
>  {
>  	struct mem_cgroup_per_zone *mz;
>  	struct mem_cgroup *memcg;
> -	struct page_cgroup *pc;
>  	struct lruvec *lruvec;
>  
>  	if (mem_cgroup_disabled()) {
> @@ -1282,8 +1281,7 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
>  		goto out;
>  	}
>  
> -	pc = lookup_page_cgroup(page);
> -	memcg = pc->mem_cgroup;
> +	memcg = page->mem_cgroup;
>  	/*
>  	 * Swapcache readahead pages are added to the LRU - and
>  	 * possibly migrated - before they are charged.
> @@ -2020,16 +2018,13 @@ struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page,
>  					      unsigned long *flags)
>  {
>  	struct mem_cgroup *memcg;
> -	struct page_cgroup *pc;
>  
>  	rcu_read_lock();
>  
>  	if (mem_cgroup_disabled())
>  		return NULL;
> -
> -	pc = lookup_page_cgroup(page);
>  again:
> -	memcg = pc->mem_cgroup;
> +	memcg = page->mem_cgroup;
>  	if (unlikely(!memcg))
>  		return NULL;
>  
> @@ -2038,7 +2033,7 @@ again:
>  		return memcg;
>  
>  	spin_lock_irqsave(&memcg->move_lock, *flags);
> -	if (memcg != pc->mem_cgroup) {
> +	if (memcg != page->mem_cgroup) {
>  		spin_unlock_irqrestore(&memcg->move_lock, *flags);
>  		goto again;
>  	}
> @@ -2405,15 +2400,12 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
>  struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  {
>  	struct mem_cgroup *memcg;
> -	struct page_cgroup *pc;
>  	unsigned short id;
>  	swp_entry_t ent;
>  
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  
> -	pc = lookup_page_cgroup(page);
> -	memcg = pc->mem_cgroup;
> -
> +	memcg = page->mem_cgroup;
>  	if (memcg) {
>  		if (!css_tryget_online(&memcg->css))
>  			memcg = NULL;
> @@ -2463,10 +2455,9 @@ static void unlock_page_lru(struct page *page, int isolated)
>  static void commit_charge(struct page *page, struct mem_cgroup *memcg,
>  			  bool lrucare)
>  {
> -	struct page_cgroup *pc = lookup_page_cgroup(page);
>  	int isolated;
>  
> -	VM_BUG_ON_PAGE(pc->mem_cgroup, page);
> +	VM_BUG_ON_PAGE(page->mem_cgroup, page);
>  
>  	/*
>  	 * In some cases, SwapCache and FUSE(splice_buf->radixtree), the page
> @@ -2477,7 +2468,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
>  
>  	/*
>  	 * Nobody should be changing or seriously looking at
> -	 * pc->mem_cgroup at this point:
> +	 * page->mem_cgroup at this point:
>  	 *
>  	 * - the page is uncharged
>  	 *
> @@ -2489,7 +2480,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
>  	 * - a page cache insertion, a swapin fault, or a migration
>  	 *   have the page locked
>  	 */
> -	pc->mem_cgroup = memcg;
> +	page->mem_cgroup = memcg;
>  
>  	if (lrucare)
>  		unlock_page_lru(page, isolated);
> @@ -2972,8 +2963,6 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
>  void __memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg,
>  			      int order)
>  {
> -	struct page_cgroup *pc;
> -
>  	VM_BUG_ON(mem_cgroup_is_root(memcg));
>  
>  	/* The page allocation failed. Revert */
> @@ -2981,14 +2970,12 @@ void __memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg,
>  		memcg_uncharge_kmem(memcg, 1 << order);
>  		return;
>  	}
> -	pc = lookup_page_cgroup(page);
> -	pc->mem_cgroup = memcg;
> +	page->mem_cgroup = memcg;
>  }
>  
>  void __memcg_kmem_uncharge_pages(struct page *page, int order)
>  {
> -	struct page_cgroup *pc = lookup_page_cgroup(page);
> -	struct mem_cgroup *memcg = pc->mem_cgroup;
> +	struct mem_cgroup *memcg = page->mem_cgroup;
>  
>  	if (!memcg)
>  		return;
> @@ -2996,7 +2983,7 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
>  	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
>  
>  	memcg_uncharge_kmem(memcg, 1 << order);
> -	pc->mem_cgroup = NULL;
> +	page->mem_cgroup = NULL;
>  }
>  #else
>  static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
> @@ -3014,16 +3001,15 @@ static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
>   */
>  void mem_cgroup_split_huge_fixup(struct page *head)
>  {
> -	struct page_cgroup *pc = lookup_page_cgroup(head);
>  	int i;
>  
>  	if (mem_cgroup_disabled())
>  		return;
>  
>  	for (i = 1; i < HPAGE_PMD_NR; i++)
> -		pc[i].mem_cgroup = pc[0].mem_cgroup;
> +		head[i].mem_cgroup = head->mem_cgroup;
>  
> -	__this_cpu_sub(pc[0].mem_cgroup->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
> +	__this_cpu_sub(head->mem_cgroup->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
>  		       HPAGE_PMD_NR);
>  }
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> @@ -3032,7 +3018,6 @@ void mem_cgroup_split_huge_fixup(struct page *head)
>   * mem_cgroup_move_account - move account of the page
>   * @page: the page
>   * @nr_pages: number of regular pages (>1 for huge pages)
> - * @pc:	page_cgroup of the page.
>   * @from: mem_cgroup which the page is moved from.
>   * @to:	mem_cgroup which the page is moved to. @from != @to.
>   *
> @@ -3045,7 +3030,6 @@ void mem_cgroup_split_huge_fixup(struct page *head)
>   */
>  static int mem_cgroup_move_account(struct page *page,
>  				   unsigned int nr_pages,
> -				   struct page_cgroup *pc,
>  				   struct mem_cgroup *from,
>  				   struct mem_cgroup *to)
>  {
> @@ -3065,7 +3049,7 @@ static int mem_cgroup_move_account(struct page *page,
>  		goto out;
>  
>  	/*
> -	 * Prevent mem_cgroup_migrate() from looking at pc->mem_cgroup
> +	 * Prevent mem_cgroup_migrate() from looking at page->mem_cgroup
>  	 * of its source page while we change it: page migration takes
>  	 * both pages off the LRU, but page cache replacement doesn't.
>  	 */
> @@ -3073,7 +3057,7 @@ static int mem_cgroup_move_account(struct page *page,
>  		goto out;
>  
>  	ret = -EINVAL;
> -	if (pc->mem_cgroup != from)
> +	if (page->mem_cgroup != from)
>  		goto out_unlock;
>  
>  	spin_lock_irqsave(&from->move_lock, flags);
> @@ -3093,13 +3077,13 @@ static int mem_cgroup_move_account(struct page *page,
>  	}
>  
>  	/*
> -	 * It is safe to change pc->mem_cgroup here because the page
> +	 * It is safe to change page->mem_cgroup here because the page
>  	 * is referenced, charged, and isolated - we can't race with
>  	 * uncharging, charging, migration, or LRU putback.
>  	 */
>  
>  	/* caller should have done css_get */
> -	pc->mem_cgroup = to;
> +	page->mem_cgroup = to;
>  	spin_unlock_irqrestore(&from->move_lock, flags);
>  
>  	ret = 0;
> @@ -3174,36 +3158,17 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
>  #endif
>  
>  #ifdef CONFIG_DEBUG_VM
> -static struct page_cgroup *lookup_page_cgroup_used(struct page *page)
> -{
> -	struct page_cgroup *pc;
> -
> -	pc = lookup_page_cgroup(page);
> -	/*
> -	 * Can be NULL while feeding pages into the page allocator for
> -	 * the first time, i.e. during boot or memory hotplug;
> -	 * or when mem_cgroup_disabled().
> -	 */
> -	if (likely(pc) && pc->mem_cgroup)
> -		return pc;
> -	return NULL;
> -}
> -
>  bool mem_cgroup_bad_page_check(struct page *page)
>  {
>  	if (mem_cgroup_disabled())
>  		return false;
>  
> -	return lookup_page_cgroup_used(page) != NULL;
> +	return page->mem_cgroup != NULL;
>  }
>  
>  void mem_cgroup_print_bad_page(struct page *page)
>  {
> -	struct page_cgroup *pc;
> -
> -	pc = lookup_page_cgroup_used(page);
> -	if (pc)
> -		pr_alert("pc:%p pc->mem_cgroup:%p\n", pc, pc->mem_cgroup);
> +	pr_alert("page->mem_cgroup:%p\n", page->mem_cgroup);
>  }
>  #endif
>  
> @@ -5123,7 +5088,6 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
>  		unsigned long addr, pte_t ptent, union mc_target *target)
>  {
>  	struct page *page = NULL;
> -	struct page_cgroup *pc;
>  	enum mc_target_type ret = MC_TARGET_NONE;
>  	swp_entry_t ent = { .val = 0 };
>  
> @@ -5137,13 +5101,12 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
>  	if (!page && !ent.val)
>  		return ret;
>  	if (page) {
> -		pc = lookup_page_cgroup(page);
>  		/*
>  		 * Do only loose check w/o serialization.
> -		 * mem_cgroup_move_account() checks the pc is valid or
> +		 * mem_cgroup_move_account() checks the page is valid or
>  		 * not under LRU exclusion.
>  		 */
> -		if (pc->mem_cgroup == mc.from) {
> +		if (page->mem_cgroup == mc.from) {
>  			ret = MC_TARGET_PAGE;
>  			if (target)
>  				target->page = page;
> @@ -5171,15 +5134,13 @@ static enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
>  		unsigned long addr, pmd_t pmd, union mc_target *target)
>  {
>  	struct page *page = NULL;
> -	struct page_cgroup *pc;
>  	enum mc_target_type ret = MC_TARGET_NONE;
>  
>  	page = pmd_page(pmd);
>  	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
>  	if (!move_anon())
>  		return ret;
> -	pc = lookup_page_cgroup(page);
> -	if (pc->mem_cgroup == mc.from) {
> +	if (page->mem_cgroup == mc.from) {
>  		ret = MC_TARGET_PAGE;
>  		if (target) {
>  			get_page(page);
> @@ -5378,7 +5339,6 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
>  	enum mc_target_type target_type;
>  	union mc_target target;
>  	struct page *page;
> -	struct page_cgroup *pc;
>  
>  	/*
>  	 * We don't take compound_lock() here but no race with splitting thp
> @@ -5399,9 +5359,8 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
>  		if (target_type == MC_TARGET_PAGE) {
>  			page = target.page;
>  			if (!isolate_lru_page(page)) {
> -				pc = lookup_page_cgroup(page);
>  				if (!mem_cgroup_move_account(page, HPAGE_PMD_NR,
> -							pc, mc.from, mc.to)) {
> +							     mc.from, mc.to)) {
>  					mc.precharge -= HPAGE_PMD_NR;
>  					mc.moved_charge += HPAGE_PMD_NR;
>  				}
> @@ -5429,9 +5388,7 @@ retry:
>  			page = target.page;
>  			if (isolate_lru_page(page))
>  				goto put;
> -			pc = lookup_page_cgroup(page);
> -			if (!mem_cgroup_move_account(page, 1, pc,
> -						     mc.from, mc.to)) {
> +			if (!mem_cgroup_move_account(page, 1, mc.from, mc.to)) {
>  				mc.precharge--;
>  				/* we uncharge from mc.from later. */
>  				mc.moved_charge++;
> @@ -5623,7 +5580,6 @@ static void __init enable_swap_cgroup(void)
>  void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  {
>  	struct mem_cgroup *memcg;
> -	struct page_cgroup *pc;
>  	unsigned short oldid;
>  
>  	VM_BUG_ON_PAGE(PageLRU(page), page);
> @@ -5632,8 +5588,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  	if (!do_swap_account)
>  		return;
>  
> -	pc = lookup_page_cgroup(page);
> -	memcg = pc->mem_cgroup;
> +	memcg = page->mem_cgroup;
>  
>  	/* Readahead page, never charged */
>  	if (!memcg)
> @@ -5643,7 +5598,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  	VM_BUG_ON_PAGE(oldid, page);
>  	mem_cgroup_swap_statistics(memcg, true);
>  
> -	pc->mem_cgroup = NULL;
> +	page->mem_cgroup = NULL;
>  
>  	if (!mem_cgroup_is_root(memcg))
>  		page_counter_uncharge(&memcg->memory, 1);
> @@ -5710,7 +5665,6 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
>  		goto out;
>  
>  	if (PageSwapCache(page)) {
> -		struct page_cgroup *pc = lookup_page_cgroup(page);
>  		/*
>  		 * Every swap fault against a single page tries to charge the
>  		 * page, bail as early as possible.  shmem_unuse() encounters
> @@ -5718,7 +5672,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
>  		 * the page lock, which serializes swap cache removal, which
>  		 * in turn serializes uncharging.
>  		 */
> -		if (pc->mem_cgroup)
> +		if (page->mem_cgroup)
>  			goto out;
>  	}
>  
> @@ -5871,7 +5825,6 @@ static void uncharge_list(struct list_head *page_list)
>  	next = page_list->next;
>  	do {
>  		unsigned int nr_pages = 1;
> -		struct page_cgroup *pc;
>  
>  		page = list_entry(next, struct page, lru);
>  		next = page->lru.next;
> @@ -5879,23 +5832,22 @@ static void uncharge_list(struct list_head *page_list)
>  		VM_BUG_ON_PAGE(PageLRU(page), page);
>  		VM_BUG_ON_PAGE(page_count(page), page);
>  
> -		pc = lookup_page_cgroup(page);
> -		if (!pc->mem_cgroup)
> +		if (!page->mem_cgroup)
>  			continue;
>  
>  		/*
>  		 * Nobody should be changing or seriously looking at
> -		 * pc->mem_cgroup at this point, we have fully
> +		 * page->mem_cgroup at this point, we have fully
>  		 * exclusive access to the page.
>  		 */
>  
> -		if (memcg != pc->mem_cgroup) {
> +		if (memcg != page->mem_cgroup) {
>  			if (memcg) {
>  				uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
>  					       nr_huge, page);
>  				pgpgout = nr_anon = nr_file = nr_huge = 0;
>  			}
> -			memcg = pc->mem_cgroup;
> +			memcg = page->mem_cgroup;
>  		}
>  
>  		if (PageTransHuge(page)) {
> @@ -5909,7 +5861,7 @@ static void uncharge_list(struct list_head *page_list)
>  		else
>  			nr_file += nr_pages;
>  
> -		pc->mem_cgroup = NULL;
> +		page->mem_cgroup = NULL;
>  
>  		pgpgout++;
>  	} while (next != page_list);
> @@ -5928,14 +5880,11 @@ static void uncharge_list(struct list_head *page_list)
>   */
>  void mem_cgroup_uncharge(struct page *page)
>  {
> -	struct page_cgroup *pc;
> -
>  	if (mem_cgroup_disabled())
>  		return;
>  
>  	/* Don't touch page->lru of any random page, pre-check: */
> -	pc = lookup_page_cgroup(page);
> -	if (!pc->mem_cgroup)
> +	if (!page->mem_cgroup)
>  		return;
>  
>  	INIT_LIST_HEAD(&page->lru);
> @@ -5972,7 +5921,6 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>  			bool lrucare)
>  {
>  	struct mem_cgroup *memcg;
> -	struct page_cgroup *pc;
>  	int isolated;
>  
>  	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
> @@ -5987,8 +5935,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>  		return;
>  
>  	/* Page cache replacement: new page already charged? */
> -	pc = lookup_page_cgroup(newpage);
> -	if (pc->mem_cgroup)
> +	if (newpage->mem_cgroup)
>  		return;
>  
>  	/*
> @@ -5997,15 +5944,14 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>  	 * uncharged page when the PFN walker finds a page that
>  	 * reclaim just put back on the LRU but has not released yet.
>  	 */
> -	pc = lookup_page_cgroup(oldpage);
> -	memcg = pc->mem_cgroup;
> +	memcg = oldpage->mem_cgroup;
>  	if (!memcg)
>  		return;
>  
>  	if (lrucare)
>  		lock_page_lru(oldpage, &isolated);
>  
> -	pc->mem_cgroup = NULL;
> +	oldpage->mem_cgroup = NULL;
>  
>  	if (lrucare)
>  		unlock_page_lru(oldpage, isolated);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index fa9426389c6c..6a952237a677 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -48,7 +48,6 @@
>  #include <linux/backing-dev.h>
>  #include <linux/fault-inject.h>
>  #include <linux/page-isolation.h>
> -#include <linux/page_cgroup.h>
>  #include <linux/debugobjects.h>
>  #include <linux/kmemleak.h>
>  #include <linux/compaction.h>
> @@ -4899,7 +4898,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>  #endif
>  	init_waitqueue_head(&pgdat->kswapd_wait);
>  	init_waitqueue_head(&pgdat->pfmemalloc_wait);
> -	pgdat_page_cgroup_init(pgdat);
>  
>  	for (j = 0; j < MAX_NR_ZONES; j++) {
>  		struct zone *zone = pgdat->node_zones + j;
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 5331c2bd85a2..f0f31c1d4d0c 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -1,326 +1,7 @@
>  #include <linux/mm.h>
> -#include <linux/mmzone.h>
> -#include <linux/bootmem.h>
> -#include <linux/bit_spinlock.h>
>  #include <linux/page_cgroup.h>
> -#include <linux/hash.h>
> -#include <linux/slab.h>
> -#include <linux/memory.h>
>  #include <linux/vmalloc.h>
> -#include <linux/cgroup.h>
>  #include <linux/swapops.h>
> -#include <linux/kmemleak.h>
> -
> -static unsigned long total_usage;
> -
> -#if !defined(CONFIG_SPARSEMEM)
> -
> -
> -void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
> -{
> -	pgdat->node_page_cgroup = NULL;
> -}
> -
> -struct page_cgroup *lookup_page_cgroup(struct page *page)
> -{
> -	unsigned long pfn = page_to_pfn(page);
> -	unsigned long offset;
> -	struct page_cgroup *base;
> -
> -	base = NODE_DATA(page_to_nid(page))->node_page_cgroup;
> -#ifdef CONFIG_DEBUG_VM
> -	/*
> -	 * The sanity checks the page allocator does upon freeing a
> -	 * page can reach here before the page_cgroup arrays are
> -	 * allocated when feeding a range of pages to the allocator
> -	 * for the first time during bootup or memory hotplug.
> -	 */
> -	if (unlikely(!base))
> -		return NULL;
> -#endif
> -	offset = pfn - NODE_DATA(page_to_nid(page))->node_start_pfn;
> -	return base + offset;
> -}
> -
> -static int __init alloc_node_page_cgroup(int nid)
> -{
> -	struct page_cgroup *base;
> -	unsigned long table_size;
> -	unsigned long nr_pages;
> -
> -	nr_pages = NODE_DATA(nid)->node_spanned_pages;
> -	if (!nr_pages)
> -		return 0;
> -
> -	table_size = sizeof(struct page_cgroup) * nr_pages;
> -
> -	base = memblock_virt_alloc_try_nid_nopanic(
> -			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
> -			BOOTMEM_ALLOC_ACCESSIBLE, nid);
> -	if (!base)
> -		return -ENOMEM;
> -	NODE_DATA(nid)->node_page_cgroup = base;
> -	total_usage += table_size;
> -	return 0;
> -}
> -
> -void __init page_cgroup_init_flatmem(void)
> -{
> -
> -	int nid, fail;
> -
> -	if (mem_cgroup_disabled())
> -		return;
> -
> -	for_each_online_node(nid)  {
> -		fail = alloc_node_page_cgroup(nid);
> -		if (fail)
> -			goto fail;
> -	}
> -	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
> -	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you"
> -	" don't want memory cgroups\n");
> -	return;
> -fail:
> -	printk(KERN_CRIT "allocation of page_cgroup failed.\n");
> -	printk(KERN_CRIT "please try 'cgroup_disable=memory' boot option\n");
> -	panic("Out of memory");
> -}
> -
> -#else /* CONFIG_FLAT_NODE_MEM_MAP */
> -
> -struct page_cgroup *lookup_page_cgroup(struct page *page)
> -{
> -	unsigned long pfn = page_to_pfn(page);
> -	struct mem_section *section = __pfn_to_section(pfn);
> -#ifdef CONFIG_DEBUG_VM
> -	/*
> -	 * The sanity checks the page allocator does upon freeing a
> -	 * page can reach here before the page_cgroup arrays are
> -	 * allocated when feeding a range of pages to the allocator
> -	 * for the first time during bootup or memory hotplug.
> -	 */
> -	if (!section->page_cgroup)
> -		return NULL;
> -#endif
> -	return section->page_cgroup + pfn;
> -}
> -
> -static void *__meminit alloc_page_cgroup(size_t size, int nid)
> -{
> -	gfp_t flags = GFP_KERNEL | __GFP_ZERO | __GFP_NOWARN;
> -	void *addr = NULL;
> -
> -	addr = alloc_pages_exact_nid(nid, size, flags);
> -	if (addr) {
> -		kmemleak_alloc(addr, size, 1, flags);
> -		return addr;
> -	}
> -
> -	if (node_state(nid, N_HIGH_MEMORY))
> -		addr = vzalloc_node(size, nid);
> -	else
> -		addr = vzalloc(size);
> -
> -	return addr;
> -}
> -
> -static int __meminit init_section_page_cgroup(unsigned long pfn, int nid)
> -{
> -	struct mem_section *section;
> -	struct page_cgroup *base;
> -	unsigned long table_size;
> -
> -	section = __pfn_to_section(pfn);
> -
> -	if (section->page_cgroup)
> -		return 0;
> -
> -	table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
> -	base = alloc_page_cgroup(table_size, nid);
> -
> -	/*
> -	 * The value stored in section->page_cgroup is (base - pfn)
> -	 * and it does not point to the memory block allocated above,
> -	 * causing kmemleak false positives.
> -	 */
> -	kmemleak_not_leak(base);
> -
> -	if (!base) {
> -		printk(KERN_ERR "page cgroup allocation failure\n");
> -		return -ENOMEM;
> -	}
> -
> -	/*
> -	 * The passed "pfn" may not be aligned to SECTION.  For the calculation
> -	 * we need to apply a mask.
> -	 */
> -	pfn &= PAGE_SECTION_MASK;
> -	section->page_cgroup = base - pfn;
> -	total_usage += table_size;
> -	return 0;
> -}
> -#ifdef CONFIG_MEMORY_HOTPLUG
> -static void free_page_cgroup(void *addr)
> -{
> -	if (is_vmalloc_addr(addr)) {
> -		vfree(addr);
> -	} else {
> -		struct page *page = virt_to_page(addr);
> -		size_t table_size =
> -			sizeof(struct page_cgroup) * PAGES_PER_SECTION;
> -
> -		BUG_ON(PageReserved(page));
> -		kmemleak_free(addr);
> -		free_pages_exact(addr, table_size);
> -	}
> -}
> -
> -static void __free_page_cgroup(unsigned long pfn)
> -{
> -	struct mem_section *ms;
> -	struct page_cgroup *base;
> -
> -	ms = __pfn_to_section(pfn);
> -	if (!ms || !ms->page_cgroup)
> -		return;
> -	base = ms->page_cgroup + pfn;
> -	free_page_cgroup(base);
> -	ms->page_cgroup = NULL;
> -}
> -
> -static int __meminit online_page_cgroup(unsigned long start_pfn,
> -				unsigned long nr_pages,
> -				int nid)
> -{
> -	unsigned long start, end, pfn;
> -	int fail = 0;
> -
> -	start = SECTION_ALIGN_DOWN(start_pfn);
> -	end = SECTION_ALIGN_UP(start_pfn + nr_pages);
> -
> -	if (nid == -1) {
> -		/*
> -		 * In this case, "nid" already exists and contains valid memory.
> -		 * "start_pfn" passed to us is a pfn which is an arg for
> -		 * online__pages(), and start_pfn should exist.
> -		 */
> -		nid = pfn_to_nid(start_pfn);
> -		VM_BUG_ON(!node_state(nid, N_ONLINE));
> -	}
> -
> -	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
> -		if (!pfn_present(pfn))
> -			continue;
> -		fail = init_section_page_cgroup(pfn, nid);
> -	}
> -	if (!fail)
> -		return 0;
> -
> -	/* rollback */
> -	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION)
> -		__free_page_cgroup(pfn);
> -
> -	return -ENOMEM;
> -}
> -
> -static int __meminit offline_page_cgroup(unsigned long start_pfn,
> -				unsigned long nr_pages, int nid)
> -{
> -	unsigned long start, end, pfn;
> -
> -	start = SECTION_ALIGN_DOWN(start_pfn);
> -	end = SECTION_ALIGN_UP(start_pfn + nr_pages);
> -
> -	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION)
> -		__free_page_cgroup(pfn);
> -	return 0;
> -
> -}
> -
> -static int __meminit page_cgroup_callback(struct notifier_block *self,
> -			       unsigned long action, void *arg)
> -{
> -	struct memory_notify *mn = arg;
> -	int ret = 0;
> -	switch (action) {
> -	case MEM_GOING_ONLINE:
> -		ret = online_page_cgroup(mn->start_pfn,
> -				   mn->nr_pages, mn->status_change_nid);
> -		break;
> -	case MEM_OFFLINE:
> -		offline_page_cgroup(mn->start_pfn,
> -				mn->nr_pages, mn->status_change_nid);
> -		break;
> -	case MEM_CANCEL_ONLINE:
> -		offline_page_cgroup(mn->start_pfn,
> -				mn->nr_pages, mn->status_change_nid);
> -		break;
> -	case MEM_GOING_OFFLINE:
> -		break;
> -	case MEM_ONLINE:
> -	case MEM_CANCEL_OFFLINE:
> -		break;
> -	}
> -
> -	return notifier_from_errno(ret);
> -}
> -
> -#endif
> -
> -void __init page_cgroup_init(void)
> -{
> -	unsigned long pfn;
> -	int nid;
> -
> -	if (mem_cgroup_disabled())
> -		return;
> -
> -	for_each_node_state(nid, N_MEMORY) {
> -		unsigned long start_pfn, end_pfn;
> -
> -		start_pfn = node_start_pfn(nid);
> -		end_pfn = node_end_pfn(nid);
> -		/*
> -		 * start_pfn and end_pfn may not be aligned to SECTION and the
> -		 * page->flags of out of node pages are not initialized.  So we
> -		 * scan [start_pfn, the biggest section's pfn < end_pfn) here.
> -		 */
> -		for (pfn = start_pfn;
> -		     pfn < end_pfn;
> -                     pfn = ALIGN(pfn + 1, PAGES_PER_SECTION)) {
> -
> -			if (!pfn_valid(pfn))
> -				continue;
> -			/*
> -			 * Nodes's pfns can be overlapping.
> -			 * We know some arch can have a nodes layout such as
> -			 * -------------pfn-------------->
> -			 * N0 | N1 | N2 | N0 | N1 | N2|....
> -			 */
> -			if (pfn_to_nid(pfn) != nid)
> -				continue;
> -			if (init_section_page_cgroup(pfn, nid))
> -				goto oom;
> -		}
> -	}
> -	hotplug_memory_notifier(page_cgroup_callback, 0);
> -	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
> -	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you "
> -			 "don't want memory cgroups\n");
> -	return;
> -oom:
> -	printk(KERN_CRIT "try 'cgroup_disable=memory' boot option\n");
> -	panic("Out of memory");
> -}
> -
> -void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
> -{
> -	return;
> -}
> -
> -#endif
> -
>  
>  #ifdef CONFIG_MEMCG_SWAP
>  
> -- 
> 2.1.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
