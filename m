Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE6F6B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 06:08:39 -0400 (EDT)
Date: Thu, 19 Mar 2009 19:01:18 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] fix unused/stale swap cache handling on memcg  v2
Message-Id: <20090319190118.db8a1dd7.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090319180631.44b0130f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
	<20090317143903.a789cf57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317151113.79a3cc9d.nishimura@mxp.nes.nec.co.jp>
	<20090317162950.70c1245c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317183850.67c35b27.kamezawa.hiroyu@jp.fujitsu.com>
	<20090318101727.f00dfc2f.nishimura@mxp.nes.nec.co.jp>
	<20090318103418.7d38dce0.kamezawa.hiroyu@jp.fujitsu.com>
	<20090318125154.f8ffe652.nishimura@mxp.nes.nec.co.jp>
	<20090318175734.f5a8a446.kamezawa.hiroyu@jp.fujitsu.com>
	<20090318231738.4e042cbd.d-nishimura@mtf.biglobe.ne.jp>
	<20090319084523.1fbcc3cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090319111629.dcc9fe43.kamezawa.hiroyu@jp.fujitsu.com>
	<20090319180631.44b0130f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Mar 2009 18:06:31 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Core logic are much improved and I confirmed this logic can reduce
> orphan swap-caches. (But the patch size is bigger than expected.)
> Long term test is required and we have to verify paramaters are reasonable
> and whether this doesn't make swapped-out applications slow..
> 
Thank you for your patch.
I'll test this version and check what happens about swapcache usage.

Thanks,
Daisuke Nishimura.

> -Kame
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Nishimura reported unused-swap-cache is not reclaimed well well under memcg.
> 
> Assume that memory cgroup well limits the memory usage of all applications
> and file caches, and global-LRU-scan (kswapd() etc..) never runs.
> 
> First, there is *allowed* race to SwapCache on global LRU. There can be
> SwapCaches on global LRU, even when swp_entry is not referred by anyone(ptes).
> When global LRU scan runs, it will be reclaimed by try_to_free_swap().
> But, they will not appear in memcg's private LRU and never reclaimed by
> memcg's reclaim routines.
> 
> Second, there are readahead SwapCaches, some of then tend to be not used
> and reclaimed by global LRU when scan runs, at last. But they are not on
> memcg's private LRU and will not be reclaimed until global-lru-scan runs.
> 
> From memcg's point of view, above 2 is not very good. Especially, *unused*
> swp_entry adds pressure to memcg's mem+swap controller and finally cause OOM.
> (Nishimura confirmed this can cause OOM.)
> 
> This patch tries to reclaim unused-swapcache by 
>   - add a list for unused-swapcache (orphan_list)
>   - try to recalim orhan list by some threshold.
> 
> BTW, if we don't remove "2" (unused swapcache), we can't detect correct
> threshold for reclaiming stale entries. So, the pages should be dropped
> to some extent. try_to_free_swap() cannot be used for "2", so I added
> try_to_drop_swapcache(). remove_mapping() checks all critical things.
> 
> Changelog: v1 -> v2
>  - use kmalloc_node() instead of kmalloc()
>  - added try_to_drop_swapcache()
>  - fixed silly bugs.
>  - If only root cgroup, no logic will work. (all jobs are done be global LRU)
> 
> Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/page_cgroup.h |   13 ++
>  include/linux/swap.h        |    6 +
>  mm/memcontrol.c             |  195 +++++++++++++++++++++++++++++++++++++++++++-
>  mm/swapfile.c               |   23 +++++
>  4 files changed, 236 insertions(+), 1 deletion(-)
> 
> Index: mmotm-2.6.29-Mar11/include/linux/page_cgroup.h
> ===================================================================
> --- mmotm-2.6.29-Mar11.orig/include/linux/page_cgroup.h
> +++ mmotm-2.6.29-Mar11/include/linux/page_cgroup.h
> @@ -26,6 +26,7 @@ enum {
>  	PCG_LOCK,  /* page cgroup is locked */
>  	PCG_CACHE, /* charged as cache */
>  	PCG_USED, /* this object is in use. */
> +	PCG_ORPHAN, /* this is not used from memcg:s view but on global LRU */
>  };
>  
>  #define TESTPCGFLAG(uname, lname)			\
> @@ -40,12 +41,24 @@ static inline void SetPageCgroup##uname(
>  static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
>  	{ clear_bit(PCG_##lname, &pc->flags);  }
>  
> +#define TESTSETPCGFLAG(uname, lname) \
> +static inline int TestSetPageCgroup##uname(struct page_cgroup *pc) \
> +	{ return test_and_set_bit(PCG_##lname, &pc->flags); }
> +
> +#define TESTCLEARPCGFLAG(uname, lname) \
> +static inline int TestClearPageCgroup##uname(struct page_cgroup *pc) \
> +	{ return test_and_clear_bit(PCG_##lname, &pc->flags); }
> +
>  /* Cache flag is set only once (at allocation) */
>  TESTPCGFLAG(Cache, CACHE)
>  
>  TESTPCGFLAG(Used, USED)
>  CLEARPCGFLAG(Used, USED)
>  
> +TESTPCGFLAG(Orphan, ORPHAN)
> +TESTSETPCGFLAG(Orphan, ORPHAN)
> +TESTCLEARPCGFLAG(Orphan, ORPHAN)
> +
>  static inline int page_cgroup_nid(struct page_cgroup *pc)
>  {
>  	return page_to_nid(pc->page);
> Index: mmotm-2.6.29-Mar11/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.29-Mar11.orig/mm/memcontrol.c
> +++ mmotm-2.6.29-Mar11/mm/memcontrol.c
> @@ -371,6 +371,64 @@ static int mem_cgroup_walk_tree(struct m
>   * When moving account, the page is not on LRU. It's isolated.
>   */
>  
> +/*
> + * Orphan List is a list for page_cgroup which is not free but not under
> + * any cgroup. SwapCache which is prefetched by readahead() is typical type but
> + * there are other corner cases.
> + *
> + * Usually, updates to this list happens when swap cache is readaheaded and
> + * finally used by process.
> + */
> +
> +/* for orphan page_cgroups, updated under zone->lru_lock. */
> +
> +struct orphan_list_node {
> +	struct orphan_list_zone {
> +		int event;
> +		struct list_head list;
> +	} zone[MAX_NR_ZONES];
> +};
> +struct orphan_list_node *orphan_list[MAX_NUMNODES] __read_mostly;
> +#define ORPHAN_EVENT_THRESH (256)
> +static void check_orphan_stat(void);
> +static atomic_t nr_orphan_caches;
> +static int memory_cgroup_is_used __read_mostly;
> +
> +static inline struct orphan_list_zone *orphan_lru(int nid, int zid)
> +{
> +	/*
> +	 * 2 cases for this BUG_ON(), swapcache is generated while init.
> +	 * or NID should be invalid.
> +	 */
> +	BUG_ON(!orphan_list[nid]);
> +	return  &orphan_list[nid]->zone[zid];
> +}
> +
> +static inline void remove_orphan_list(struct page_cgroup *pc)
> +{
> +	if (TestClearPageCgroupOrphan(pc)) {
> +		list_del_init(&pc->lru);
> +		atomic_dec(&nr_orphan_caches);
> +	}
> +}
> +
> +static void add_orphan_list(struct page *page, struct page_cgroup *pc)
> +{
> +	if (!TestSetPageCgroupOrphan(pc)) {
> +		struct orphan_list_zone *opl;
> +		opl = orphan_lru(page_to_nid(page), page_zonenum(page));
> +		list_add_tail(&pc->lru, &opl->list);
> +		atomic_inc(&nr_orphan_caches);
> +		if (unlikely(opl->event++ > ORPHAN_EVENT_THRESH)) {
> +			/* Orphan is not problem if no mem_cgroup is used */
> +			if (memory_cgroup_is_used)
> +				check_orphan_stat();
> +			opl->event = 0;
> +		}
> +	}
> +}
> +
> +
>  void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
>  {
>  	struct page_cgroup *pc;
> @@ -380,6 +438,14 @@ void mem_cgroup_del_lru_list(struct page
>  	if (mem_cgroup_disabled())
>  		return;
>  	pc = lookup_page_cgroup(page);
> +	/*
> +	 * If the page is SwapCache and already on global LRU, it will be on
> +	 * orphan list. remove here
> +	 */
> +	if (unlikely(PageCgroupOrphan(pc))) {
> +		remove_orphan_list(pc);
> +		return;
> +	}
>  	/* can happen while we handle swapcache. */
>  	if (list_empty(&pc->lru) || !pc->mem_cgroup)
>  		return;
> @@ -433,8 +499,11 @@ void mem_cgroup_add_lru_list(struct page
>  	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
>  	 */
>  	smp_rmb();
> -	if (!PageCgroupUsed(pc))
> +	if (!PageCgroupUsed(pc)) {
> +		/* handle swap cache here */
> +		add_orphan_list(page, pc);
>  		return;
> +	}
>  
>  	mz = page_cgroup_zoneinfo(pc);
>  	MEM_CGROUP_ZSTAT(mz, lru) += 1;
> @@ -471,6 +540,9 @@ static void mem_cgroup_lru_add_after_com
>  	struct page_cgroup *pc = lookup_page_cgroup(page);
>  
>  	spin_lock_irqsave(&zone->lru_lock, flags);
> +	if (PageCgroupOrphan(pc))
> +		remove_orphan_list(pc);
> +
>  	/* link when the page is linked to LRU but page_cgroup isn't */
>  	if (PageLRU(page) && list_empty(&pc->lru))
>  		mem_cgroup_add_lru_list(page, page_lru(page));
> @@ -785,6 +857,125 @@ static int mem_cgroup_count_children(str
>  }
>  
>  /*
> + * Using big number here for avoiding to free orphan swap-cache by readahead
> + * We don't want to delete swap caches read by readahead.
> + */
> +static int orphan_thresh(void)
> +{
> +	int nr_pages = (1 << page_cluster); /* max size of a swap readahead */
> +	int base = num_online_cpus() * 256; /* 1M per cpu if swap is 4k */
> +
> +	nr_pages *= nr_threads; /* nr_threads can be too big, too small */
> +
> +	/* too small value will kill readahead */
> +	if (nr_pages < base)
> +		return base;
> +
> +	/* too big is not suitable here */
> +	if (nr_pages > base * 4)
> +		return base * 4;
> +
> +	return nr_pages;
> +}
> +
> +/*
> + * In usual, *unused* swap cache are reclaimed by global LRU. But, if no one
> + * kicks global LRU, they will not be reclaimed. When using memcg, it's trouble.
> + */
> +static int drain_orphan_swapcaches(int nid, int zid)
> +{
> +	struct page_cgroup *pc;
> +	struct zone *zone;
> +	struct page *page;
> +	struct orphan_list_zone *lru = orphan_lru(nid, zid);
> +	unsigned long flags;
> +	int drain, scan;
> +
> +	zone = &NODE_DATA(nid)->node_zones[zid];
> +	scan = ORPHAN_EVENT_THRESH/2;
> +	spin_lock_irqsave(&zone->lru_lock, flags);
> +	while (!list_empty(&lru->list) && (scan > 0)) {
> +		scan--;
> +		pc = list_entry(lru->list.next, struct page_cgroup, lru);
> +		page = pc->page;
> +		/* Rotate */
> +		list_del(&pc->lru);
> +		list_add_tail(&pc->lru, &lru->list);
> +		spin_unlock_irqrestore(&zone->lru_lock, flags);
> +		/* Remove from LRU */
> +		if (!isolate_lru_page(page)) { /* get_page is called */
> +			if (!page_mapped(page) && trylock_page(page)) {
> +				/* This does all necessary jobs */
> +				drain += try_to_drop_swapcache(page);
> +				unlock_page(page);
> +			}
> +			putback_lru_page(page); /* put_page is called */
> +		}
> +		spin_lock_irqsave(&zone->lru_lock, flags);
> +	}
> +	spin_unlock_irqrestore(&zone->lru_lock, flags);
> +
> +	return drain;
> +}
> +
> +/*
> + * last_visit is marker to remember which node should be scanned next.
> + * Only one worker can enter this routine at the same time.
> + */
> +static int last_visit;
> +void try_delete_orphan_caches(struct work_struct *work)
> +{
> +	int nid, zid, drain;
> +	static atomic_t orphan_scan_worker;
> +
> +	if (atomic_inc_return(&orphan_scan_worker) > 1) {
> +		atomic_dec(&orphan_scan_worker);
> +		return;
> +	}
> +	nid = last_visit;
> +	drain = 0;
> +	while (!drain) {
> +		nid = next_node(nid, node_states[N_HIGH_MEMORY]);
> +		if (nid == MAX_NUMNODES)
> +			nid = 0;
> +		last_visit = nid;
> +		if (node_state(nid, N_HIGH_MEMORY))
> +			for (zid = 0; zid < MAX_NR_ZONES; zid++)
> +				drain += drain_orphan_swapcaches(nid, zid);
> +		if (nid == 0)
> +			break;
> +	}
> +	atomic_dec(&orphan_scan_worker);
> +}
> +DECLARE_WORK(orphan_delete_work, try_delete_orphan_caches);
> +
> +static void check_orphan_stat(void)
> +{
> +	if (atomic_read(&nr_orphan_caches) > orphan_thresh())
> +		schedule_work(&orphan_delete_work);
> +}
> +
> +static __init void init_orphan_lru(void)
> +{
> +	struct orphan_list_node *opl;
> +	int nid, zid;
> +	int size = sizeof(struct orphan_list_node);
> +
> +	for_each_node_state(nid, N_POSSIBLE) {
> +		if (node_state(nid, N_NORMAL_MEMORY))
> +			opl = kmalloc_node(size,  GFP_KERNEL, nid);
> +		else
> +			opl = kmalloc(size, GFP_KERNEL);
> +		BUG_ON(!opl);
> +		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> +			INIT_LIST_HEAD(&opl->zone[zid].list);
> +			opl->zone[zid].event = 0;
> +		}
> +		orphan_list[nid] = opl;
> +	}
> +}
> +
> +/*
>   * Visit the first child (need not be the first child as per the ordering
>   * of the cgroup list, since we track last_scanned_child) of @mem and use
>   * that to reclaim free pages from.
> @@ -2454,10 +2645,12 @@ mem_cgroup_create(struct cgroup_subsys *
>  	/* root ? */
>  	if (cont->parent == NULL) {
>  		enable_swap_cgroup();
> +		init_orphan_lru();
>  		parent = NULL;
>  	} else {
>  		parent = mem_cgroup_from_cont(cont->parent);
>  		mem->use_hierarchy = parent->use_hierarchy;
> +		memory_cgroup_is_used = 1;
>  	}
>  
>  	if (parent && parent->use_hierarchy) {
> Index: mmotm-2.6.29-Mar11/mm/swapfile.c
> ===================================================================
> --- mmotm-2.6.29-Mar11.orig/mm/swapfile.c
> +++ mmotm-2.6.29-Mar11/mm/swapfile.c
> @@ -571,6 +571,29 @@ int try_to_free_swap(struct page *page)
>  }
>  
>  /*
> + * Similar to try_to_free_swap() but this drops SwapCache without checking
> + * page_swapcount(). By this, this function removes not only unused swap entry
> + * but alos a swap-cache which is on memory but never used.
> + * The caller should have a reference to this page and it must be locked.
> + */
> +int try_to_drop_swapcache(struct page *page)
> +{
> +	VM_BUG_ON(!PageLocked(page));
> +
> +	if (!PageSwapCache(page))
> +		return 0;
> +	if (PageWriteback(page))
> +		return 0;
> +	if (page_mapped(page))
> +		return 0;
> +	/*
> +	 * remove_mapping() will success only when there is no extra
> + 	 * user of swap cache. (Keeping sanity be speculative lookup)
> + 	 */
> +	return remove_mapping(&swapper_space, page);
> +}
> +
> +/*
>   * Free the swap entry like above, but also try to
>   * free the page cache entry if it is the last user.
>   */
> Index: mmotm-2.6.29-Mar11/include/linux/swap.h
> ===================================================================
> --- mmotm-2.6.29-Mar11.orig/include/linux/swap.h
> +++ mmotm-2.6.29-Mar11/include/linux/swap.h
> @@ -312,6 +312,7 @@ extern sector_t swapdev_block(int, pgoff
>  extern struct swap_info_struct *get_swap_info_struct(unsigned);
>  extern int reuse_swap_page(struct page *);
>  extern int try_to_free_swap(struct page *);
> +extern int try_to_drop_swapcache(struct page *);
>  struct backing_dev_info;
>  
>  /* linux/mm/thrash.c */
> @@ -414,6 +415,11 @@ static inline int try_to_free_swap(struc
>  	return 0;
>  }
>  
> +static inline int try_to_drop_swapcache(struct page *page)
> +{
> +	return 0;
> +}
> +
>  static inline swp_entry_t get_swap_page(void)
>  {
>  	swp_entry_t entry;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
