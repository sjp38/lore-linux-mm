Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A89D6B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 22:18:25 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id l5so80924748ioa.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 19:18:25 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id t10si10647857paw.5.2016.06.09.19.18.22
        for <linux-mm@kvack.org>;
        Thu, 09 Jun 2016 19:18:23 -0700 (PDT)
Date: Fri, 10 Jun 2016 11:19:35 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 10/10] mm: balance LRU lists based on relative thrashing
Message-ID: <20160610021935.GF29779@bbox>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-11-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606194836.3624-11-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

Hi Hannes,

On Mon, Jun 06, 2016 at 03:48:36PM -0400, Johannes Weiner wrote:
> Since the LRUs were split into anon and file lists, the VM has been
> balancing between page cache and anonymous pages based on per-list
> ratios of scanned vs. rotated pages. In most cases that tips page
> reclaim towards the list that is easier to reclaim and has the fewest
> actively used pages, but there are a few problems with it:
> 
> 1. Refaults and in-memory rotations are weighted the same way, even
>    though one costs IO and the other costs CPU. When the balance is
>    off, the page cache can be thrashing while anonymous pages are aged
>    comparably slower and thus have more time to get even their coldest
>    pages referenced. The VM would consider this a fair equilibrium.
> 
> 2. The page cache has usually a share of use-once pages that will
>    further dilute its scanned/rotated ratio in the above-mentioned
>    scenario. This can cease scanning of the anonymous list almost
>    entirely - again while the page cache is thrashing and IO-bound.
> 
> Historically, swap has been an emergency overflow for high memory
> pressure, and we avoided using it as long as new page allocations
> could be served from recycling page cache. However, when recycling
> page cache incurs a higher cost in IO than swapping out a few unused
> anonymous pages would, it makes sense to increase swap pressure.
> 
> In order to accomplish this, we can extend the thrash detection code
> that currently detects workingset changes within the page cache: when
> inactive cache pages are thrashing, the VM raises LRU pressure on the
> otherwise protected active file list to increase competition. However,
> when active pages begin refaulting as well, it means that the page
> cache is thrashing as a whole and the LRU balance should tip toward
> anonymous. This is what this patch implements.
> 
> To tell inactive from active refaults, a page flag is introduced that
> marks pages that have been on the active list in their lifetime. This
> flag is remembered in the shadow page entry on reclaim, and restored
> when the page refaults. It is also set on anonymous pages during
> swapin. When a page with that flag set is added to the LRU, the LRU
> balance is adjusted for the IO cost of reclaiming the thrashing list.
> 
> Rotations continue to influence the LRU balance as well, but with a
> different weight factor. That factor is statically chosen such that
> refaults are considered more costly than rotations at this point. We
> might want to revisit this for ultra-fast swap or secondary memory
> devices, where rotating referenced pages might be more costly than
> swapping or relocating them directly and have some of them refault.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/mmzone.h         |   6 +-
>  include/linux/page-flags.h     |   2 +
>  include/linux/swap.h           |  10 ++-
>  include/trace/events/mmflags.h |   1 +
>  mm/filemap.c                   |   9 +--
>  mm/migrate.c                   |   4 ++
>  mm/swap.c                      |  38 ++++++++++-
>  mm/swap_state.c                |   1 +
>  mm/vmscan.c                    |   5 +-
>  mm/vmstat.c                    |   6 +-
>  mm/workingset.c                | 142 +++++++++++++++++++++++++++++++----------
>  11 files changed, 172 insertions(+), 52 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 4d257d00fbf5..d7aaee25b536 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -148,9 +148,9 @@ enum zone_stat_item {
>  	NUMA_LOCAL,		/* allocation from local node */
>  	NUMA_OTHER,		/* allocation from other node */
>  #endif
> -	WORKINGSET_REFAULT,
> -	WORKINGSET_ACTIVATE,
> -	WORKINGSET_NODERECLAIM,
> +	REFAULT_INACTIVE_FILE,
> +	REFAULT_ACTIVE_FILE,
> +	REFAULT_NODERECLAIM,
>  	NR_ANON_TRANSPARENT_HUGEPAGES,
>  	NR_FREE_CMA_PAGES,
>  	NR_VM_ZONE_STAT_ITEMS };
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index e5a32445f930..a1b9d7dddd68 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -79,6 +79,7 @@ enum pageflags {
>  	PG_dirty,
>  	PG_lru,
>  	PG_active,
> +	PG_workingset,

I think PG_workingset might be a good flag in the future, core MM might
utilize it to optimize something so I hope it supports for 32bit, too.

A usecase with PG_workingset in old was cleancache. A few year ago,
Dan tried it to only cache activated page from page cache to cleancache,
IIRC. As well, many system using zram(i.e., fast swap) are still 32 bit
architecture.

Just an idea. we might be able to move less important flag(i.e., enabled
in specific configuration, for example, PG_hwpoison or PG_uncached) in 32bit
to page_extra to avoid allocate extra memory space and charge the bit as
PG_workingset. :)

Other concern about PG_workingset is naming. For file-backed pages, it's
good because file-backed pages started from inactive's head and promoted
active LRU once two touch so it's likely to be workingset. However,
for anonymous page, it starts from active list so every anonymous page
has PG_workingset while mlocked pages cannot have a chance to have it.
It wouldn't matter in eclaim POV but if we would use PG_workingset as
indicator to identify real workingset page, it might be confused.
Maybe, We could mark mlocked pages as workingset unconditionally.

>  	PG_slab,
>  	PG_owner_priv_1,	/* Owner use. If pagecache, fs may use*/
>  	PG_arch_1,
> @@ -259,6 +260,7 @@ PAGEFLAG(Dirty, dirty, PF_HEAD) TESTSCFLAG(Dirty, dirty, PF_HEAD)
>  PAGEFLAG(LRU, lru, PF_HEAD) __CLEARPAGEFLAG(LRU, lru, PF_HEAD)
>  PAGEFLAG(Active, active, PF_HEAD) __CLEARPAGEFLAG(Active, active, PF_HEAD)
>  	TESTCLEARFLAG(Active, active, PF_HEAD)
> +PAGEFLAG(Workingset, workingset, PF_HEAD)
>  __PAGEFLAG(Slab, slab, PF_NO_TAIL)
>  __PAGEFLAG(SlobFree, slob_free, PF_NO_TAIL)
>  PAGEFLAG(Checked, checked, PF_NO_COMPOUND)	   /* Used by some filesystems */
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index c461ce0533da..9923b51ee8e9 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -250,7 +250,7 @@ struct swap_info_struct {
>  
>  /* linux/mm/workingset.c */
>  void *workingset_eviction(struct address_space *mapping, struct page *page);
> -bool workingset_refault(void *shadow);
> +void workingset_refault(struct page *page, void *shadow);
>  void workingset_activation(struct page *page);
>  extern struct list_lru workingset_shadow_nodes;
>  
> @@ -295,8 +295,12 @@ extern unsigned long nr_free_pagecache_pages(void);
>  
>  
>  /* linux/mm/swap.c */
> -extern void lru_note_cost(struct lruvec *lruvec, bool file,
> -			  unsigned int nr_pages);
> +enum lru_cost_type {
> +	COST_CPU,
> +	COST_IO,
> +};
> +extern void lru_note_cost(struct lruvec *lruvec, enum lru_cost_type cost,
> +			  bool file, unsigned int nr_pages);
>  extern void lru_cache_add(struct page *);
>  extern void lru_cache_putback(struct page *page);
>  extern void lru_add_page_tail(struct page *page, struct page *page_tail,
> diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
> index 43cedbf0c759..bc05e0ac1b8c 100644
> --- a/include/trace/events/mmflags.h
> +++ b/include/trace/events/mmflags.h
> @@ -86,6 +86,7 @@
>  	{1UL << PG_dirty,		"dirty"		},		\
>  	{1UL << PG_lru,			"lru"		},		\
>  	{1UL << PG_active,		"active"	},		\
> +	{1UL << PG_workingset,		"workingset"	},		\
>  	{1UL << PG_slab,		"slab"		},		\
>  	{1UL << PG_owner_priv_1,	"owner_priv_1"	},		\
>  	{1UL << PG_arch_1,		"arch_1"	},		\
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 9665b1d4f318..1b356b47381b 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -700,12 +700,9 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
>  		 * data from the working set, only to cache data that will
>  		 * get overwritten with something else, is a waste of memory.
>  		 */
> -		if (!(gfp_mask & __GFP_WRITE) &&
> -		    shadow && workingset_refault(shadow)) {
> -			SetPageActive(page);
> -			workingset_activation(page);
> -		} else
> -			ClearPageActive(page);
> +		WARN_ON_ONCE(PageActive(page));
> +		if (!(gfp_mask & __GFP_WRITE) && shadow)
> +			workingset_refault(page, shadow);
>  		lru_cache_add(page);
>  	}
>  	return ret;
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 9baf41c877ff..115d49441c6c 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -544,6 +544,8 @@ void migrate_page_copy(struct page *newpage, struct page *page)
>  		SetPageActive(newpage);
>  	} else if (TestClearPageUnevictable(page))
>  		SetPageUnevictable(newpage);
> +	if (PageWorkingset(page))
> +		SetPageWorkingset(newpage);

When I see this, popped thought is how we handle PG_workingset
when split/collapsing THP and then, I can't find any logic. :(
Every anonymous page is PG_workingset by birth so you ignore it
intentionally?


>  	if (PageChecked(page))
>  		SetPageChecked(newpage);
>  	if (PageMappedToDisk(page))
> @@ -1809,6 +1811,8 @@ fail_putback:
>  		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>  
>  		/* Reverse changes made by migrate_page_copy() */
> +		if (TestClearPageWorkingset(new_page))
> +			ClearPageWorkingset(page);
>  		if (TestClearPageActive(new_page))
>  			SetPageActive(page);
>  		if (TestClearPageUnevictable(new_page))
> diff --git a/mm/swap.c b/mm/swap.c
> index ae07b469ddca..cb6773e1424e 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -249,8 +249,28 @@ void rotate_reclaimable_page(struct page *page)
>  	}
>  }
>  
> -void lru_note_cost(struct lruvec *lruvec, bool file, unsigned int nr_pages)
> +void lru_note_cost(struct lruvec *lruvec, enum lru_cost_type cost,
> +		   bool file, unsigned int nr_pages)
>  {
> +	if (cost == COST_IO) {
> +		/*
> +		 * Reflect the relative reclaim cost between incurring
> +		 * IO from refaults on one hand, and incurring CPU
> +		 * cost from rotating scanned pages on the other.
> +		 *
> +		 * XXX: For now, the relative cost factor for IO is
> +		 * set statically to outweigh the cost of rotating
> +		 * referenced pages. This might change with ultra-fast
> +		 * IO devices, or with secondary memory devices that
> +		 * allow users continued access of swapped out pages.
> +		 *
> +		 * Until then, the value is chosen simply such that we
> +		 * balance for IO cost first and optimize for CPU only
> +		 * once the thrashing subsides.
> +		 */
> +		nr_pages *= SWAP_CLUSTER_MAX;
> +	}
> +
>  	lruvec->balance.numer[file] += nr_pages;
>  	lruvec->balance.denom += nr_pages;

So, lru_cost_type is binary. COST_IO and COST_CPU. 'bool' is enough to
represent it if you doesn't have further plan to expand it.
But if you did to make it readable, I'm not against. Just trivial.

>  }
> @@ -262,6 +282,7 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
>  		int lru = page_lru_base_type(page);
>  
>  		del_page_from_lru_list(page, lruvec, lru);
> +		SetPageWorkingset(page);
>  		SetPageActive(page);
>  		lru += LRU_ACTIVE;
>  		add_page_to_lru_list(page, lruvec, lru);
> @@ -821,13 +842,28 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
>  static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
>  				 void *arg)
>  {
> +	unsigned int nr_pages = hpage_nr_pages(page);
>  	enum lru_list lru = page_lru(page);
> +	bool active = is_active_lru(lru);
> +	bool file = is_file_lru(lru);
> +	bool new = (bool)arg;
>  
>  	VM_BUG_ON_PAGE(PageLRU(page), page);
>  
>  	SetPageLRU(page);
>  	add_page_to_lru_list(page, lruvec, lru);
>  
> +	if (new) {
> +		/*
> +		 * If the workingset is thrashing, note the IO cost of
> +		 * reclaiming that list and steer reclaim away from it.
> +		 */
> +		if (PageWorkingset(page))
> +			lru_note_cost(lruvec, COST_IO, file, nr_pages);
> +		else if (active)
> +			SetPageWorkingset(page);
> +	}
> +
>  	trace_mm_lru_insertion(page, lru);
>  }
>  
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 5400f814ae12..43561a56ba5d 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -365,6 +365,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  			/*
>  			 * Initiate read into locked page and return.
>  			 */

How about putting the comment you said to Tim in here?

"
There are no shadow entries for anonymous evictions, only page cache
evictions. All swap-ins are treated as "eligible" refaults and push back
against cache, whereas cache only pushes against anon if the cache
workingset is determined to fit into memory.
That implies a fixed hierarchy where the VM always tries to fit the
anonymous workingset into memory first and the page cache second.
If the anonymous set is bigger than memory, the algorithm won't stop
counting IO cost from anonymous refaults and pressuring page cache.
"
Or put it in workingset.c. I see you wrote up a little bit about
anonymous refault in there but I think adding abvove paragraph is
very helpful.


> +			SetPageWorkingset(new_page);
>  			lru_cache_add(new_page);
>  			*new_page_allocated = true;
>  			return new_page;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index acbd212eab6e..b2cb4f4f9d31 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1216,6 +1216,7 @@ activate_locked:
>  		if (PageSwapCache(page) && mem_cgroup_swap_full(page))
>  			try_to_free_swap(page);
>  		VM_BUG_ON_PAGE(PageActive(page), page);
> +		SetPageWorkingset(page);
>  		SetPageActive(page);
>  		pgactivate++;
>  keep_locked:
> @@ -1524,7 +1525,7 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
>  			 * Rotating pages costs CPU without actually
>  			 * progressing toward the reclaim goal.
>  			 */
> -			lru_note_cost(lruvec, file, numpages);
> +			lru_note_cost(lruvec, COST_CPU, file, numpages);
>  		}
>  
>  		if (put_page_testzero(page)) {
> @@ -1849,7 +1850,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	 * Rotating pages costs CPU without actually
>  	 * progressing toward the reclaim goal.
>  	 */
> -	lru_note_cost(lruvec, file, nr_rotated);
> +	lru_note_cost(lruvec, COST_CPU, file, nr_rotated);
>  
>  	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
>  	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 77e42ef388c2..6c8d658f5b7f 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -727,9 +727,9 @@ const char * const vmstat_text[] = {
>  	"numa_local",
>  	"numa_other",
>  #endif
> -	"workingset_refault",
> -	"workingset_activate",
> -	"workingset_nodereclaim",
> +	"refault_inactive_file",
> +	"refault_active_file",
> +	"refault_nodereclaim",
>  	"nr_anon_transparent_hugepages",
>  	"nr_free_cma",
>  
> diff --git a/mm/workingset.c b/mm/workingset.c
> index 8a75f8d2916a..261cf583fb62 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -118,7 +118,7 @@
>   * the only thing eating into inactive list space is active pages.
>   *
>   *
> - *		Activating refaulting pages
> + *		Refaulting inactive pages
>   *
>   * All that is known about the active list is that the pages have been
>   * accessed more than once in the past.  This means that at any given
> @@ -131,6 +131,10 @@
>   * used less frequently than the refaulting page - or even not used at
>   * all anymore.
>   *
> + * That means, if inactive cache is refaulting with a suitable refault
> + * distance, we assume the cache workingset is transitioning and put
> + * pressure on the existing cache pages on the active list.
> + *
>   * If this is wrong and demotion kicks in, the pages which are truly
>   * used more frequently will be reactivated while the less frequently
>   * used once will be evicted from memory.
> @@ -139,6 +143,30 @@
>   * and the used pages get to stay in cache.
>   *
>   *
> + *		Refaulting active pages
> + *
> + * If, on the other hand, the refaulting pages have been recently
> + * deactivated, it means that the active list is no longer protecting
> + * actively used cache from reclaim: the cache is not transitioning to
> + * a different workingset, the existing workingset is thrashing in the
> + * space allocated to the page cache.
> + *
> + * When that is the case, mere activation of the refaulting pages is
> + * not enough. The page reclaim code needs to be informed of the high
> + * IO cost associated with the continued reclaim of page cache, so
> + * that it can steer pressure to the anonymous list.
> + *
> + * Just as when refaulting inactive pages, it's possible that there
> + * are cold(er) anonymous pages that can be swapped and forgotten in
> + * order to increase the space available to the page cache as a whole.
> + *
> + * If anonymous pages start thrashing as well, the reclaim scanner
> + * will aim for the list that imposes the lowest cost on the system,
> + * where cost is defined as:
> + *
> + *	refault rate * relative IO cost (as determined by swappiness)
> + *
> + *
>   *		Implementation
>   *
>   * For each zone's file LRU lists, a counter for inactive evictions
> @@ -150,10 +178,25 @@
>   *
>   * On cache misses for which there are shadow entries, an eligible
>   * refault distance will immediately activate the refaulting page.
> + *
> + * On activation, cache pages are marked PageWorkingset, which is not
> + * cleared until the page is freed. Shadow entries will remember that
> + * flag to be able to tell inactive from active refaults. Refaults of
> + * previous workingset pages will restore that page flag and inform
> + * page reclaim of the IO cost.
> + *
> + * XXX: Since we don't track anonymous references, every swap-in event
> + * is considered a workingset refault - regardless of distance. Swapin
> + * floods will thus always raise the assumed IO cost of reclaiming the
> + * anonymous LRU lists, even if the pages haven't been used recently.
> + * Temporary events don't matter that much other than they might delay
> + * the stabilization a bit. But during continuous thrashing, anonymous
> + * pages can have a leg-up against page cache. This might need fixing
> + * for ultra-fast IO devices or secondary memory types.
>   */
>  
> -#define EVICTION_SHIFT	(RADIX_TREE_EXCEPTIONAL_ENTRY + \
> -			 ZONES_SHIFT + NODES_SHIFT +	\
> +#define EVICTION_SHIFT	(RADIX_TREE_EXCEPTIONAL_ENTRY +			\
> +			 1 + ZONES_SHIFT + NODES_SHIFT +		\
>  			 MEM_CGROUP_ID_SHIFT)
>  #define EVICTION_MASK	(~0UL >> EVICTION_SHIFT)
>  
> @@ -167,24 +210,29 @@
>   */
>  static unsigned int bucket_order __read_mostly;
>  
> -static void *pack_shadow(int memcgid, struct zone *zone, unsigned long eviction)
> +static void *pack_shadow(int memcgid, struct zone *zone, unsigned long eviction,
> +			 bool workingset)
>  {
>  	eviction >>= bucket_order;
>  	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
>  	eviction = (eviction << NODES_SHIFT) | zone_to_nid(zone);
>  	eviction = (eviction << ZONES_SHIFT) | zone_idx(zone);
> +	eviction = (eviction << 1) | workingset;
>  	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
>  
>  	return (void *)(eviction | RADIX_TREE_EXCEPTIONAL_ENTRY);
>  }
>  
>  static void unpack_shadow(void *shadow, int *memcgidp, struct zone **zonep,
> -			  unsigned long *evictionp)
> +			  unsigned long *evictionp, bool *workingsetp)
>  {
>  	unsigned long entry = (unsigned long)shadow;
>  	int memcgid, nid, zid;
> +	bool workingset;
>  
>  	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
> +	workingset = entry & 1;
> +	entry >>= 1;
>  	zid = entry & ((1UL << ZONES_SHIFT) - 1);
>  	entry >>= ZONES_SHIFT;
>  	nid = entry & ((1UL << NODES_SHIFT) - 1);
> @@ -195,6 +243,7 @@ static void unpack_shadow(void *shadow, int *memcgidp, struct zone **zonep,
>  	*memcgidp = memcgid;
>  	*zonep = NODE_DATA(nid)->node_zones + zid;
>  	*evictionp = entry << bucket_order;
> +	*workingsetp = workingset;
>  }
>  
>  /**
> @@ -220,19 +269,18 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
>  
>  	lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>  	eviction = atomic_long_inc_return(&lruvec->inactive_age);
> -	return pack_shadow(memcgid, zone, eviction);
> +	return pack_shadow(memcgid, zone, eviction, PageWorkingset(page));
>  }
>  
>  /**
>   * workingset_refault - evaluate the refault of a previously evicted page
> + * @page: the freshly allocated replacement page
>   * @shadow: shadow entry of the evicted page
>   *
>   * Calculates and evaluates the refault distance of the previously
>   * evicted page in the context of the zone it was allocated in.
> - *
> - * Returns %true if the page should be activated, %false otherwise.
>   */
> -bool workingset_refault(void *shadow)
> +void workingset_refault(struct page *page, void *shadow)
>  {
>  	unsigned long refault_distance;
>  	unsigned long active_file;
> @@ -240,10 +288,12 @@ bool workingset_refault(void *shadow)
>  	unsigned long eviction;
>  	struct lruvec *lruvec;
>  	unsigned long refault;
> +	unsigned long anon;
>  	struct zone *zone;
> +	bool workingset;
>  	int memcgid;
>  
> -	unpack_shadow(shadow, &memcgid, &zone, &eviction);
> +	unpack_shadow(shadow, &memcgid, &zone, &eviction, &workingset);
>  
>  	rcu_read_lock();
>  	/*
> @@ -263,40 +313,64 @@ bool workingset_refault(void *shadow)
>  	 * configurations instead.
>  	 */
>  	memcg = mem_cgroup_from_id(memcgid);
> -	if (!mem_cgroup_disabled() && !memcg) {
> -		rcu_read_unlock();
> -		return false;
> -	}
> +	if (!mem_cgroup_disabled() && !memcg)
> +		goto out;
>  	lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>  	refault = atomic_long_read(&lruvec->inactive_age);
>  	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE);
> -	rcu_read_unlock();
> +	if (mem_cgroup_get_nr_swap_pages(memcg) > 0)
> +		anon = lruvec_lru_size(lruvec, LRU_ACTIVE_ANON) +
> +		       lruvec_lru_size(lruvec, LRU_INACTIVE_ANON);
> +	else
> +		anon = 0;
>  
>  	/*
> -	 * The unsigned subtraction here gives an accurate distance
> -	 * across inactive_age overflows in most cases.
> +	 * Calculate the refault distance.
>  	 *
> -	 * There is a special case: usually, shadow entries have a
> -	 * short lifetime and are either refaulted or reclaimed along
> -	 * with the inode before they get too old.  But it is not
> -	 * impossible for the inactive_age to lap a shadow entry in
> -	 * the field, which can then can result in a false small
> -	 * refault distance, leading to a false activation should this
> -	 * old entry actually refault again.  However, earlier kernels
> -	 * used to deactivate unconditionally with *every* reclaim
> -	 * invocation for the longest time, so the occasional
> -	 * inappropriate activation leading to pressure on the active
> -	 * list is not a problem.
> +	 * The unsigned subtraction here gives an accurate distance
> +	 * across inactive_age overflows in most cases. There is a
> +	 * special case: usually, shadow entries have a short lifetime
> +	 * and are either refaulted or reclaimed along with the inode
> +	 * before they get too old.  But it is not impossible for the
> +	 * inactive_age to lap a shadow entry in the field, which can
> +	 * then can result in a false small refault distance, leading
> +	 * to a false activation should this old entry actually
> +	 * refault again.  However, earlier kernels used to deactivate
> +	 * unconditionally with *every* reclaim invocation for the
> +	 * longest time, so the occasional inappropriate activation
> +	 * leading to pressure on the active list is not a problem.
>  	 */
>  	refault_distance = (refault - eviction) & EVICTION_MASK;
>  
> -	inc_zone_state(zone, WORKINGSET_REFAULT);
> +	/*
> +	 * Compare the distance with the existing workingset. We don't
> +	 * act on pages that couldn't stay resident even with all the
> +	 * memory available to the page cache.
> +	 */
> +	if (refault_distance > active_file + anon)
> +		goto out;
>  
> -	if (refault_distance <= active_file) {
> -		inc_zone_state(zone, WORKINGSET_ACTIVATE);
> -		return true;
> +	/*
> +	 * If inactive cache is refaulting, activate the page to
> +	 * challenge the current cache workingset. The existing cache
> +	 * might be stale, or at least colder than the contender.
> +	 *
> +	 * If active cache is refaulting (PageWorkingset set at time
> +	 * of eviction), it means that the page cache as a whole is
> +	 * thrashing. Restore PageWorkingset to inform the LRU code
> +	 * about the additional cost of reclaiming more page cache.
> +	 */
> +	SetPageActive(page);
> +	atomic_long_inc(&lruvec->inactive_age);
> +
> +	if (workingset) {
> +		SetPageWorkingset(page);
> +		inc_zone_state(zone, REFAULT_ACTIVE_FILE);
> +	} else {
> +		inc_zone_state(zone, REFAULT_INACTIVE_FILE);
>  	}
> -	return false;
> +out:
> +	rcu_read_unlock();
>  }
>  
>  /**
> @@ -433,7 +507,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
>  		}
>  	}
>  	BUG_ON(node->count);
> -	inc_zone_state(page_zone(virt_to_page(node)), WORKINGSET_NODERECLAIM);
> +	inc_zone_state(page_zone(virt_to_page(node)), REFAULT_NODERECLAIM);
>  	if (!__radix_tree_delete_node(&mapping->page_tree, node))
>  		BUG();
>  
> -- 
> 2.8.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
