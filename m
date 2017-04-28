Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 314936B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 08:21:42 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j127so6299749pgc.10
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 05:21:42 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e67si6005481pfl.88.2017.04.28.05.21.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 05:21:40 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v10 1/3] mm, THP, swap: Delay splitting THP during swap out
References: <20170425125658.28684-1-ying.huang@intel.com>
	<20170425125658.28684-2-ying.huang@intel.com>
	<20170427053141.GA1925@bbox> <87mvb21fz1.fsf@yhuang-dev.intel.com>
	<20170428084044.GB19510@bbox>
Date: Fri, 28 Apr 2017 20:21:37 +0800
In-Reply-To: <20170428084044.GB19510@bbox> (Minchan Kim's message of "Fri, 28
	Apr 2017 17:40:44 +0900")
Message-ID: <87d1bwvi26.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, cgroups@vger.kernel.org

Minchan Kim <minchan@kernel.org> writes:

> On Thu, Apr 27, 2017 at 03:12:34PM +0800, Huang, Ying wrote:
>> Minchan Kim <minchan@kernel.org> writes:
>> 
>> > On Tue, Apr 25, 2017 at 08:56:56PM +0800, Huang, Ying wrote:
>> >> From: Huang Ying <ying.huang@intel.com>
>> >> 
>> >> In this patch, splitting huge page is delayed from almost the first
>> >> step of swapping out to after allocating the swap space for the
>> >> THP (Transparent Huge Page) and adding the THP into the swap cache.
>> >> This will batch the corresponding operation, thus improve THP swap out
>> >> throughput.
>> >> 
>> >> This is the first step for the THP swap optimization.  The plan is to
>> >> delay splitting the THP step by step and avoid splitting the THP
>> >> finally.
>> >> 
>> >> The advantages of the THP swap support include:
>> >> 
>> >> - Batch the swap operations for the THP and reduce lock
>> >>   acquiring/releasing, including allocating/freeing the swap space,
>> >>   adding/deleting to/from the swap cache, and writing/reading the swap
>> >>   space, etc.  This will help to improve the THP swap performance.
>> >> 
>> >> - The THP swap space read/write will be 2M sequential IO.  It is
>> >>   particularly helpful for the swap read, which usually are 4k random
>> >>   IO.  This will help to improve the THP swap performance.
>> >> 
>> >> - It will help the memory fragmentation, especially when the THP is
>> >>   heavily used by the applications.  The 2M continuous pages will be
>> >>   free up after the THP swapping out.
>> >> 
>> >> - It will improve the THP utilization on the system with the swap
>> >>   turned on.  Because the speed for khugepaged to collapse the normal
>> >>   pages into the THP is quite slow.  After the THP is split during the
>> >>   swapping out, it will take quite long time for the normal pages to
>> >>   collapse back into the THP after being swapped in.  The high THP
>> >>   utilization helps the efficiency of the page based memory management
>> >>   too.
>> >> 
>> >> There are some concerns regarding THP swap in, mainly because possible
>> >> enlarged read/write IO size (for swap in/out) may put more overhead on
>> >> the storage device.  To deal with that, the THP swap in should be
>> >> turned on only when necessary.  For example, it can be selected via
>> >> "always/never/madvise" logic, to be turned on globally, turned off
>> >> globally, or turned on only for VMA with MADV_HUGEPAGE, etc.
>> >> 
>> >> In this patch, one swap cluster is used to hold the contents of each
>> >> THP swapped out.  So, the size of the swap cluster is changed to that
>> >> of the THP (Transparent Huge Page) on x86_64 architecture (512).  For
>> >> other architectures which want such THP swap optimization,
>> >> ARCH_USES_THP_SWAP_CLUSTER needs to be selected in the Kconfig file
>> >> for the architecture.  In effect, this will enlarge swap cluster size
>> >> by 2 times on x86_64.  Which may make it harder to find a free cluster
>> >> when the swap space becomes fragmented.  So that, this may reduce the
>> >> continuous swap space allocation and sequential write in theory.  The
>> >> performance test in 0day shows no regressions caused by this.
>> >
>> > What about other architecures?
>> >
>> > I mean THP page size on every architectures would be various.
>> > If THP page size is much bigger than 2M, the architecture should
>> > have big swap cluster size for supporting THP swap-out feature.
>> > It means fast empty-swap cluster consumption so that it can suffer
>> > from fragmentation easily which causes THP swap void and swap slot
>> > allocations slow due to not being able to use per-cpu.
>> >
>> > What I suggested was contiguous multiple swap cluster allocations
>> > to meet THP page size. If some of architecure's THP size is 64M
>> > and SWAP_CLUSTER_SIZE is 2M, it should allocate 32 contiguos
>> > swap clusters. For that, swap layer need to manage clusters sort
>> > in order which would be more overhead in CONFIG_THP_SWAP case
>> > but I think it's tradeoff. With that, every architectures can
>> > support THP swap easily without arch-specific something.
>> 
>> That may be a good solution for other architectures.  But I am afraid I
>> am not the right person to work on that.  Because I don't know the
>> requirement of other architectures, and I have no other architectures
>> machines to work on and measure the performance.
>
> IMO, THP swapout is good thing for every architecture so I dobut
> you need to know other architecture's requirement.
>
>> 
>> And the swap clusters aren't sorted in order now intentionally to avoid
>> cache line false sharing between the spinlock of struct
>> swap_cluster_info.  If we want to sort clusters in order, we need a
>> solution for that.
>
> Does it really matter for this work? IOW, if we couldn't solve it,
> cannot we support THP swapout? I don't think so. That's the least
> of your worries.
> Also, if we have sorted cluster data structure, we need to change
> current single linked list of swap cluster to other one so we would
> need to revisit to see whether it's really problem.
>
>> 
>> > If (PAGE_SIZE * 512) swap cluster size were okay for most of
>> > architecture, just increase it. It's orthogonal work regardless of
>> > THP swapout. Then, we don't need to manage swap clusters sort
>> > in order in x86_64 which SWAP_CLUSTER_SIZE is equal to
>> > THP_PAGE_SIZE. It's just a bonus by side-effect.
>> 
>> Andrew suggested to make swap cluster size = huge page size (or turn on
>> THP swap optimization) only if we enabled CONFIG_THP_SWAP.  So that, THP
>> swap optimization will not be turned on unintentionally.
>> 
>> We may adjust default swap cluster size, but I don't think it need to be
>> in this patchset.
>
> That's it. This feature shouldn't be aware of swap cluster size. IOW,
> it would be better to work with every swap cluster size if the align
> between THP and swap cluster size is matched at least.

Using one swap cluster for each THP is simpler, so why not start from
the simple design?  Complex design may be necessary in the future, but
we can work on that at that time.

>> >> --- a/mm/shmem.c
>> >> +++ b/mm/shmem.c
>> >> @@ -1290,7 +1290,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
>> >>  		SetPageUptodate(page);
>> >>  	}
>> >>  
>> >> -	swap = get_swap_page();
>> >> +	swap = get_swap_page(page);
>> >>  	if (!swap.val)
>> >>  		goto redirty;
>> >>  
>> >
>> > If swap is non-ssd, swap.val could be zero. Right?
>> > If so, could we retry like anonymous page swapout?
>> 
>> This is for shmem, where the THP will be split before goes here.  That
>> is, "page" here is always normal page.
>
> Thanks. I missed it.
>
> However, get_swap_page is ugly now. The caller should take care of
> failure and should retry after split. I hope get_swap_page includes
> split and retry logic in itself without reling on the caller.

The current interface of get_swap_page() and swapcache_free() is
proposed by Johannes.

Hi, Johannes, what do you think about Minchan's interface proposal?

Best Regards,
Huang, Ying

> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index b60fea3748f8..96d41fade8d9 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -392,7 +392,7 @@ static inline long get_nr_swap_pages(void)
>  }
>  
>  extern void si_swapinfo(struct sysinfo *);
> -extern swp_entry_t get_swap_page(struct page *page);
> +extern swp_entry_t get_swap_page(struct page *page, struct list_head *list);
>  extern swp_entry_t get_swap_page_of_type(int);
>  extern int get_swap_pages(int n, bool cluster, swp_entry_t swp_entries[]);
>  extern int add_swap_count_continuation(swp_entry_t, gfp_t);
> @@ -400,7 +400,7 @@ extern void swap_shmem_alloc(swp_entry_t);
>  extern int swap_duplicate(swp_entry_t);
>  extern int swapcache_prepare(swp_entry_t);
>  extern void swap_free(swp_entry_t);
> -extern void swapcache_free(swp_entry_t);
> +extern void swapcache_free(struct page *page, swp_entry_t);
>  extern void swapcache_free_entries(swp_entry_t *entries, int n);
>  extern int free_swap_and_cache(swp_entry_t);
>  extern int swap_type_of(dev_t, sector_t, struct block_device **);
> @@ -459,7 +459,7 @@ static inline void swap_free(swp_entry_t swp)
>  {
>  }
>  
> -static inline void swapcache_free(swp_entry_t swp)
> +static inline void swapcache_free(struct page *page, swp_entry_t swp)
>  {
>  }
>  
> @@ -521,7 +521,8 @@ static inline int try_to_free_swap(struct page *page)
>  	return 0;
>  }
>  
> -static inline swp_entry_t get_swap_page(struct page *page)
> +static inline swp_entry_t get_swap_page(struct page *page,
> +					struct list_head *list)
>  {
>  	swp_entry_t entry;
>  	entry.val = 0;
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 29948d7da172..59afa7fc4313 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1290,7 +1290,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
>  		SetPageUptodate(page);
>  	}
>  
> -	swap = get_swap_page(page);
> +	swap = get_swap_page(page, NULL);
>  	if (!swap.val)
>  		goto redirty;
>  
> @@ -1326,7 +1326,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
>  
>  	mutex_unlock(&shmem_swaplist_mutex);
>  free_swap:
> -	swapcache_free(swap);
> +	swapcache_free(page, swap);
>  redirty:
>  	set_page_dirty(page);
>  	if (wbc->for_reclaim)
> diff --git a/mm/swap_slots.c b/mm/swap_slots.c
> index eb7524f8296d..ed5170f0bb7e 100644
> --- a/mm/swap_slots.c
> +++ b/mm/swap_slots.c
> @@ -302,7 +302,7 @@ int free_swap_slot(swp_entry_t entry)
>  	return 0;
>  }
>  
> -swp_entry_t get_swap_page(struct page *page)
> +swp_entry_t get_swap_page(struct page *page, struct list_head *list)
>  {
>  	swp_entry_t entry, *pentry;
>  	struct swap_slots_cache *cache;
> @@ -312,7 +312,15 @@ swp_entry_t get_swap_page(struct page *page)
>  	if (PageTransHuge(page)) {
>  		if (hpage_nr_pages(page) == SWAPFILE_CLUSTER)
>  			get_swap_pages(1, true, &entry);
> -		return entry;
> +		if (entry.val != 0)
> +			return entry;
> +		/*
> +		 * If swap device is not a SSD or cannot find
> +		 * a empty cluster, split the page and fall back
> +		 * to swap slot allocation.
> +		 */
> +		if (split_huge_page_to_list(page, list))
> +			return entry;
>  	}
>  
>  	/*
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 16ff89d058f4..d218c8513ff1 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -192,12 +192,12 @@ int add_to_swap(struct page *page, struct list_head *list)
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	VM_BUG_ON_PAGE(!PageUptodate(page), page);
>  
> -retry:
> -	entry = get_swap_page(page);
> +	entry = get_swap_page(page, list);
>  	if (!entry.val)
> -		goto fail;
> +		return 0;
> +
>  	if (mem_cgroup_try_charge_swap(page, entry))
> -		goto fail_free;
> +		goto fail;
>  
>  	/*
>  	 * Radix-tree node allocations from PF_MEMALLOC contexts could
> @@ -218,7 +218,7 @@ int add_to_swap(struct page *page, struct list_head *list)
>  		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
>  		 * clear SWAP_HAS_CACHE flag.
>  		 */
> -		goto fail_free;
> +		goto fail;
>  
>  	if (PageTransHuge(page)) {
>  		err = split_huge_page_to_list(page, list);
> @@ -230,14 +230,8 @@ int add_to_swap(struct page *page, struct list_head *list)
>  
>  	return 1;
>  
> -fail_free:
> -	if (PageTransHuge(page))
> -		swapcache_free_cluster(entry);
> -	else
> -		swapcache_free(entry);
>  fail:
> -	if (PageTransHuge(page) && !split_huge_page_to_list(page, list))
> -		goto retry;
> +	swapcache_free(page, entry);
>  	return 0;
>  }
>  
> @@ -259,11 +253,7 @@ void delete_from_swap_cache(struct page *page)
>  	__delete_from_swap_cache(page);
>  	spin_unlock_irq(&address_space->tree_lock);
>  
> -	if (PageTransHuge(page))
> -		swapcache_free_cluster(entry);
> -	else
> -		swapcache_free(entry);
> -
> +	swapcache_free(page, entry);
>  	page_ref_sub(page, hpage_nr_pages(page));
>  }
>  
> @@ -415,7 +405,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
>  		 * clear SWAP_HAS_CACHE flag.
>  		 */
> -		swapcache_free(entry);
> +		swapcache_free(new_page, entry);
>  	} while (err != -ENOMEM);
>  
>  	if (new_page)
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 596306272059..9496cc3e955a 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1144,7 +1144,7 @@ void swap_free(swp_entry_t entry)
>  /*
>   * Called after dropping swapcache to decrease refcnt to swap entries.
>   */
> -void swapcache_free(swp_entry_t entry)
> +void __swapcache_free(swp_entry_t entry)
>  {
>  	struct swap_info_struct *p;
>  
> @@ -1156,7 +1156,7 @@ void swapcache_free(swp_entry_t entry)
>  }
>  
>  #ifdef CONFIG_THP_SWAP
> -void swapcache_free_cluster(swp_entry_t entry)
> +void __swapcache_free_cluster(swp_entry_t entry)
>  {
>  	unsigned long offset = swp_offset(entry);
>  	unsigned long idx = offset / SWAPFILE_CLUSTER;
> @@ -1182,6 +1182,14 @@ void swapcache_free_cluster(swp_entry_t entry)
>  }
>  #endif /* CONFIG_THP_SWAP */
>  
> +void swapcache_free(struct page *page, swp_entry_t entry)
> +{
> +	if (!PageTransHuge(page))
> +		__swapcache_free(entry);
> +	else
> +		__swapcache_free_cluster(entry);
> +}
> +
>  static int swp_entry_cmp(const void *ent1, const void *ent2)
>  {
>  	const swp_entry_t *e1 = ent1, *e2 = ent2;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 5ebf468c5429..0f8ca3d1761d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -708,7 +708,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
>  		mem_cgroup_swapout(page, swap);
>  		__delete_from_swap_cache(page);
>  		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> -		swapcache_free(swap);
> +		swapcache_free(page, swap);
>  	} else {
>  		void (*freepage)(struct page *);
>  		void *shadow = NULL;
>> 
>> >>  
>> >> -swp_entry_t get_swap_page(void)
>> >> +swp_entry_t get_swap_page(struct page *page)
>> >>  {
>> >>  	swp_entry_t entry, *pentry;
>> >>  	struct swap_slots_cache *cache;
>> >>  
>> >> +	entry.val = 0;
>> >> +
>> >> +	if (PageTransHuge(page)) {
>> >> +		if (hpage_nr_pages(page) == SWAPFILE_CLUSTER)
>> >> +			get_swap_pages(1, true, &entry);
>> >> +		return entry;
>> >> +	}
>> >> +
>> >
>> >
>> > < snip >
>> >
>> >>  /**
>> >> @@ -178,20 +192,12 @@ int add_to_swap(struct page *page, struct list_head *list)
>> >>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>> >>  	VM_BUG_ON_PAGE(!PageUptodate(page), page);
>> >>  
>> >> -	entry = get_swap_page();
>> >> +retry:
>> >> +	entry = get_swap_page(page);
>> >>  	if (!entry.val)
>> >> -		return 0;
>> >> -
>> >> -	if (mem_cgroup_try_charge_swap(page, entry)) {
>> >> -		swapcache_free(entry);
>> >> -		return 0;
>> >> -	}
>> >> -
>> >> -	if (unlikely(PageTransHuge(page)))
>> >> -		if (unlikely(split_huge_page_to_list(page, list))) {
>> >> -			swapcache_free(entry);
>> >> -			return 0;
>> >> -		}
>> >> +		goto fail;
>> >
>> > So, with non-SSD swap, THP page *always* get the fail to get swp_entry_t
>> > and retry after split the page. However, it makes unncessary get_swap_pages
>> > call which is not trivial. If there is no SSD swap, thp-swap out should
>> > be void without adding any performance overhead.
>> > Hmm, but I have no good idea to do it simple. :(
>> 
>> For HDD swap, the device raw throughput is so low (< 100M Bps
>> typically), that the added overhead here will not be a big issue.  Do
>> you agree?
>
> I agree. Actually, I wanted to remove the pointless overhead
> if we have a enough *simple* solution. However, as I said,
> I have no idea so just raised an issue wit hope that someone might
> have an idea.
>
> Frankly speaking, I think we should support THP swap with hdd
> as well as ssd but it's limited to just *implementation* direction
> which is really unfortunate. :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
