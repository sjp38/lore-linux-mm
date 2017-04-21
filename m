Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B2FEC6B03A0
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 03:21:30 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id z63so117911160ioz.23
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 00:21:30 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d26si9420982plj.35.2017.04.21.00.21.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 00:21:29 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v9 1/3] mm, THP, swap: Delay splitting THP during swap out
References: <20170419070625.19776-1-ying.huang@intel.com>
	<20170419070625.19776-2-ying.huang@intel.com>
	<1492755096.24636.2.camel@gmail.com>
Date: Fri, 21 Apr 2017 15:21:24 +0800
In-Reply-To: <1492755096.24636.2.camel@gmail.com> (Balbir Singh's message of
	"Fri, 21 Apr 2017 16:11:36 +1000")
Message-ID: <87r30mfcp7.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, cgroups@vger.kernel.org

Balbir Singh <bsingharora@gmail.com> writes:

> On Wed, 2017-04-19 at 15:06 +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> In this patch, splitting huge page is delayed from almost the first
>> step of swapping out to after allocating the swap space for the
>> THP (Transparent Huge Page) and adding the THP into the swap cache.
>> This will batch the corresponding operation, thus improve THP swap out
>> throughput.
>> 
>> This is the first step for the THP swap optimization.  The plan is to
>> delay splitting the THP step by step and avoid splitting the THP
>> finally.
>> 
>> The advantages of the THP swap support include:
>> 
>> - Batch the swap operations for the THP and reduce lock
>>   acquiring/releasing, including allocating/freeing the swap space,
>>   adding/deleting to/from the swap cache, and writing/reading the swap
>>   space, etc.  This will help to improve the THP swap performance.
>> 
>> - The THP swap space read/write will be 2M sequential IO.  It is
>>   particularly helpful for the swap read, which usually are 4k random
>>   IO.  This will help to improve the THP swap performance.
>> 
>> - It will help the memory fragmentation, especially when the THP is
>>   heavily used by the applications.  The 2M continuous pages will be
>>   free up after the THP swapping out.
>> 
>> - It will improve the THP utilization on the system with the swap
>>   turned on.  Because the speed for khugepaged to collapse the normal
>>   pages into the THP is quite slow.  After the THP is split during the
>>   swapping out, it will take quite long time for the normal pages to
>>   collapse back into the THP after being swapped in.  The high THP
>>   utilization helps the efficiency of the page based memory management
>>   too.
>> 
>> There are some concerns regarding THP swap in, mainly because possible
>> enlarged read/write IO size (for swap in/out) may put more overhead on
>> the storage device.  To deal with that, the THP swap in should be
>> turned on only when necessary.  For example, it can be selected via
>> "always/never/madvise" logic, to be turned on globally, turned off
>> globally, or turned on only for VMA with MADV_HUGEPAGE, etc.
>> 
>> In this patch, one swap cluster is used to hold the contents of each
>> THP swapped out.  So, the size of the swap cluster is changed to that
>> of the THP (Transparent Huge Page) on x86_64 architecture (512).  For
>> other architectures which want such THP swap optimization,
>> ARCH_USES_THP_SWAP_CLUSTER needs to be selected in the Kconfig file
>> for the architecture. 
>
> Does the arch need to do anything else?

All other code are architecture in-dependent change, so nothing else
need to be done.

>  In effect, this will enlarge swap cluster size
>> by 2 times on x86_64.  Which may make it harder to find a free cluster
>> when the swap space becomes fragmented.  So that, this may reduce the
>> continuous swap space allocation and sequential write in theory.  The
>> performance test in 0day shows no regressions caused by this.
>
> This will also depend on the swap configuration, with swap files this
> should hopefully be less of an issue, with swap partitions, maybe?

I think a not too small swap partition should be OK.  On x86_64, it
increases the size of the swap cluster from 1M to 2M, so a swap
partition with more than several GB should still have enough number of
swap clusters.

>> 
>> In the future of THP swap optimization, some information of the
>> swapped out THP (such as compound map count) will be recorded in the
>> swap_cluster_info data structure.
>> 
>> The mem cgroup swap accounting functions are enhanced to support
>> charge or uncharge a swap cluster backing a THP as a whole.
>
> Thanks and in the future it will be good to add stats to indicate
> the number of THP swapped out for tracking.

Sure.

>> 
>> The swap cluster allocate/free functions are added to allocate/free a
>> swap cluster for a THP.  A fair simple algorithm is used for swap
>> cluster allocation, that is, only the first swap device in priority
>> list will be tried to allocate the swap cluster.
>
> I think this needs to be fixed in the long run, otherwise the bandwidth
> utilization issues you mention will not be solved. If the underlying
> storage provides RAID/LVM and uses a single swap partition, then your
> strategy is OK.

Current solution has no bandwidth utilization issue, because the swap
devices with same priority with be rotated after each allocation.  That
is, for consecutive swap cluster allocations, every time, a different
swap device will be used if there are more than one swap devices has
free swap clusters.

The issue of current solution is that if there are some swap devices has
free swap clusters but some other not, the swap cluster allocation may
fail unnecessarily.

>   The function will
>> fail if the trying is not successful, and the caller will fallback to
>> allocate a single swap slot instead.  This works good enough for
>> normal cases.  If the difference of the number of the free swap
>> clusters among multiple swap devices is significant, it is possible
>> that some THPs are split earlier than necessary.  For example, this
>> could be caused by big size difference among multiple swap devices.
>> 
>> The swap cache functions is enhanced to support add/delete THP to/from
>> the swap cache as a set of (HPAGE_PMD_NR) sub-pages.  This may be
>> enhanced in the future with multi-order radix tree.  But because we
>> will split the THP soon during swapping out, that optimization doesn't
>> make much sense for this first step.
>> 
>> The THP splitting functions are enhanced to support to split THP in
>> swap cache during swapping out.  The page lock will be held during
>> allocating the swap cluster, adding the THP into the swap cache and
>> splitting the THP.  So in the code path other than swapping out, if
>> the THP need to be split, the PageSwapCache(THP) will be always false.
>> 
>> The swap cluster is only available for SSD, so the THP swap
>> optimization in this patchset has no effect for HDD.
>
> Is this due to lack of testing or its known that HDDs don't do well
> with THP swap in/swap out?

Because the implementation is based on the swap cluster feature, which
is disabled for HDD now.  So THP swap optimization could not be enabled
for HDD for now.

>> 
>> With the patch, the swap out throughput improves 11.5% (from about
>> 3.73GB/s to about 4.16GB/s) in the vm-scalability swap-w-seq test case
>> with 8 processes.  The test is done on a Xeon E5 v3 system.  The swap
>> device used is a RAM simulated PMEM (persistent memory) device. 
>
> I am not sure if RAM simulating PMEM is a fair way to test, its just
> memcpy and no swap out.

PMEM could be used as a block device (kind of RAMDISK), then we can
create swap on it.

We use PMEM because we want to optimize for the really high speed
storage device, that is, to stress the software implementation as much
as possible.

>  To
>> test the sequential swapping out, the test case creates 8 processes,
>> which sequentially allocate and write to the anonymous pages until the
>> RAM and part of the swap device is used up.
>> 
>> [hannes@cmpxchg.org: extensive cleanups and simplifications, reduce code size]
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Tejun Heo <tj@kernel.org>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Shaohua Li <shli@kernel.org>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: cgroups@vger.kernel.org
>> Suggested-by: Andrew Morton <akpm@linux-foundation.org> [for config option]
>> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com> [for changes in huge_memory.c and huge_mm.h]
>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>> ---
>>  arch/x86/Kconfig            |   1 +
>>  include/linux/page-flags.h  |   7 +-
>>  include/linux/swap.h        |  25 ++++-
>>  include/linux/swap_cgroup.h |   6 +-
>>  mm/Kconfig                  |  12 +++
>>  mm/huge_memory.c            |  11 +-
>>  mm/memcontrol.c             |  49 ++++-----
>>  mm/shmem.c                  |   2 +-
>>  mm/swap_cgroup.c            |  40 +++++--
>>  mm/swap_slots.c             |  16 ++-
>>  mm/swap_state.c             | 115 ++++++++++++--------
>>  mm/swapfile.c               | 256 ++++++++++++++++++++++++++++++++------------
>>  12 files changed, 375 insertions(+), 165 deletions(-)
>> 
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index c43f47622440..aaa7cdd601fe 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -72,6 +72,7 @@ config X86
>>  	select ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH if SMP
>>  	select ARCH_WANT_FRAME_POINTERS
>>  	select ARCH_WANTS_DYNAMIC_TASK_STRUCT
>> +	select ARCH_WANTS_THP_SWAP		if X86_64
>>  	select BUILDTIME_EXTABLE_SORT
>>  	select CLKEVT_I8253
>>  	select CLOCKSOURCE_VALIDATE_LAST_CYCLE
>> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
>> index 6b5818d6de32..d33e3280c8ad 100644
>> --- a/include/linux/page-flags.h
>> +++ b/include/linux/page-flags.h
>> @@ -326,11 +326,14 @@ PAGEFLAG_FALSE(HighMem)
>>  #ifdef CONFIG_SWAP
>>  static __always_inline int PageSwapCache(struct page *page)
>>  {
>> +#ifdef CONFIG_THP_SWAP
>> +	page = compound_head(page);
>> +#endif
>
> Can we please add a static inline THPSwapPage() that returns page_compound(page)
> for CONFIG_THP_SWAP and page otherwise?

Then we will add a function of about 5 lines, which has only one
caller.  Is it really good thing to do?

>>  	return PageSwapBacked(page) && test_bit(PG_swapcache, &page->flags);
>>  
>>  }
>> -SETPAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
>> -CLEARPAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
>> +SETPAGEFLAG(SwapCache, swapcache, PF_NO_TAIL)
>> +CLEARPAGEFLAG(SwapCache, swapcache, PF_NO_TAIL)
>>  #else
>>  PAGEFLAG_FALSE(SwapCache)
>>  #endif
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index ba5882419a7d..b60fea3748f8 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -29,6 +29,12 @@ struct bio;
>>  				 SWAP_FLAG_DISCARD_PAGES)
>>  #define SWAP_BATCH 64
>>  
>> +#ifdef CONFIG_THP_SWAP
>> +#define SWAPFILE_CLUSTER	HPAGE_PMD_NR
>
> I wonder if this should be max(HPAGE_PMD_NR, 256)?

Now, we must use one swap cluster for each THP.  This makes
implementation much easier and in the future, we will use struct
swap_cluster_info to store some THP specific informatoin, such as
compound map count, etc.

>> +#else
>> +#define SWAPFILE_CLUSTER	256
>> +#endif
>> +
>>  static inline int current_is_kswapd(void)
>>  {
>>  	return current->flags & PF_KSWAPD;
>> @@ -386,9 +392,9 @@ static inline long get_nr_swap_pages(void)
>>  }
>>  
>>  extern void si_swapinfo(struct sysinfo *);
>> -extern swp_entry_t get_swap_page(void);
>> +extern swp_entry_t get_swap_page(struct page *page);
>>  extern swp_entry_t get_swap_page_of_type(int);
>> -extern int get_swap_pages(int n, swp_entry_t swp_entries[]);
>> +extern int get_swap_pages(int n, bool cluster, swp_entry_t swp_entries[]);
>>  extern int add_swap_count_continuation(swp_entry_t, gfp_t);
>>  extern void swap_shmem_alloc(swp_entry_t);
>>  extern int swap_duplicate(swp_entry_t);
>> @@ -515,7 +521,7 @@ static inline int try_to_free_swap(struct page *page)
>>  	return 0;
>>  }
>>  
>> -static inline swp_entry_t get_swap_page(void)
>> +static inline swp_entry_t get_swap_page(struct page *page)
>>  {
>>  	swp_entry_t entry;
>>  	entry.val = 0;
>> @@ -548,7 +554,7 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
>>  #ifdef CONFIG_MEMCG_SWAP
>>  extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
>>  extern int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry);
>> -extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
>> +extern void mem_cgroup_uncharge_swap(swp_entry_t entry, unsigned int nr_pages);
>>  extern long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg);
>>  extern bool mem_cgroup_swap_full(struct page *page);
>>  #else
>> @@ -562,7 +568,8 @@ static inline int mem_cgroup_try_charge_swap(struct page *page,
>>  	return 0;
>>  }
>>  
>> -static inline void mem_cgroup_uncharge_swap(swp_entry_t entry)
>> +static inline void mem_cgroup_uncharge_swap(swp_entry_t entry,
>> +					    unsigned int nr_pages)
>>  {
>>  }
>>  
>> @@ -577,5 +584,13 @@ static inline bool mem_cgroup_swap_full(struct page *page)
>>  }
>>  #endif
>>  
>> +#ifdef CONFIG_THP_SWAP
>> +extern void swapcache_free_cluster(swp_entry_t entry);
>> +#else
>> +static inline void swapcache_free_cluster(swp_entry_t entry)
>> +{
>> +}
>> +#endif
>> +
>>  #endif /* __KERNEL__*/
>>  #endif /* _LINUX_SWAP_H */
>> diff --git a/include/linux/swap_cgroup.h b/include/linux/swap_cgroup.h
>> index 145306bdc92f..b2b8ec7bda3f 100644
>> --- a/include/linux/swap_cgroup.h
>> +++ b/include/linux/swap_cgroup.h
>> @@ -7,7 +7,8 @@
>>  
>>  extern unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
>>  					unsigned short old, unsigned short new);
>> -extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
>> +extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id,
>> +					 unsigned int nr_ents);
>>  extern unsigned short lookup_swap_cgroup_id(swp_entry_t ent);
>>  extern int swap_cgroup_swapon(int type, unsigned long max_pages);
>>  extern void swap_cgroup_swapoff(int type);
>> @@ -15,7 +16,8 @@ extern void swap_cgroup_swapoff(int type);
>>  #else
>>  
>>  static inline
>> -unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
>> +unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id,
>> +				  unsigned int nr_ents)
>>  {
>>  	return 0;
>>  }
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index c89f472b658c..660fb765bf7d 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -447,6 +447,18 @@ choice
>>  	  benefit.
>>  endchoice
>>  
>> +config ARCH_WANTS_THP_SWAP
>> +       def_bool n
>> +
>> +config THP_SWAP
>> +	def_bool y
>> +	depends on TRANSPARENT_HUGEPAGE && ARCH_WANTS_THP_SWAP
>> +	help
>> +	  Swap transparent huge pages in one piece, without splitting.
>> +	  XXX: For now this only does clustered swap space allocation.
>> +
>> +	  For selection by architectures with reasonable THP sizes.
>> +
>>  config	TRANSPARENT_HUGE_PAGECACHE
>>  	def_bool y
>>  	depends on TRANSPARENT_HUGEPAGE
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index a84909cf20d3..b7c06476590e 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -2197,7 +2197,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
>>  	 * atomic_set() here would be safe on all archs (and not only on x86),
>>  	 * it's safer to use atomic_inc()/atomic_add().
>>  	 */
>> -	if (PageAnon(head)) {
>> +	if (PageAnon(head) && !PageSwapCache(head)) {
>>  		page_ref_inc(page_tail);
>>  	} else {
>>  		/* Additional pin to radix tree */
>> @@ -2208,6 +2208,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
>>  	page_tail->flags |= (head->flags &
>>  			((1L << PG_referenced) |
>>  			 (1L << PG_swapbacked) |
>> +			 (1L << PG_swapcache) |
>>  			 (1L << PG_mlocked) |
>>  			 (1L << PG_uptodate) |
>>  			 (1L << PG_active) |
>> @@ -2270,7 +2271,11 @@ static void __split_huge_page(struct page *page, struct list_head *list,
>>  	ClearPageCompound(head);
>>  	/* See comment in __split_huge_page_tail() */
>>  	if (PageAnon(head)) {
>> -		page_ref_inc(head);
>> +		/* Additional pin to radix tree of swap cache */
>> +		if (PageSwapCache(head))
>> +			page_ref_add(head, 2);
>> +		else
>> +			page_ref_inc(head);
>>  	} else {
>>  		/* Additional pin to radix tree */
>>  		page_ref_add(head, 2);
>> @@ -2426,7 +2431,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>>  			ret = -EBUSY;
>>  			goto out;
>>  		}
>> -		extra_pins = 0;
>> +		extra_pins = PageSwapCache(page) ? HPAGE_PMD_NR : 0;
>>  		mapping = NULL;
>>  		anon_vma_lock_write(anon_vma);
>>  	} else {
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index ff73899af61a..e374582c1d9c 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2376,10 +2376,9 @@ void mem_cgroup_split_huge_fixup(struct page *head)
>>  
>>  #ifdef CONFIG_MEMCG_SWAP
>>  static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
>> -					 bool charge)
>> +				       int nr_entries)
>>  {
>> -	int val = (charge) ? 1 : -1;
>> -	this_cpu_add(memcg->stat->count[MEMCG_SWAP], val);
>> +	this_cpu_add(memcg->stat->count[MEMCG_SWAP], nr_entries);
>>  }
>>  
>>  /**
>> @@ -2405,8 +2404,8 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
>>  	new_id = mem_cgroup_id(to);
>>  
>>  	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
>> -		mem_cgroup_swap_statistics(from, false);
>> -		mem_cgroup_swap_statistics(to, true);
>> +		mem_cgroup_swap_statistics(from, -1);
>> +		mem_cgroup_swap_statistics(to, 1);
>>  		return 0;
>>  	}
>>  	return -EINVAL;
>> @@ -5445,7 +5444,7 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
>>  		 * let's not wait for it.  The page already received a
>>  		 * memory+swap charge, drop the swap entry duplicate.
>>  		 */
>> -		mem_cgroup_uncharge_swap(entry);
>> +		mem_cgroup_uncharge_swap(entry, nr_pages);
>>  	}
>>  }
>>  
>> @@ -5873,9 +5872,9 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>>  	 * ancestor for the swap instead and transfer the memory+swap charge.
>>  	 */
>>  	swap_memcg = mem_cgroup_id_get_online(memcg);
>> -	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg));
>> +	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg), 1);
>>  	VM_BUG_ON_PAGE(oldid, page);
>> -	mem_cgroup_swap_statistics(swap_memcg, true);
>> +	mem_cgroup_swap_statistics(swap_memcg, 1);
>>  
>>  	page->mem_cgroup = NULL;
>>  
>> @@ -5902,19 +5901,20 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>>  		css_put(&memcg->css);
>>  }
>>  
>> -/*
>> - * mem_cgroup_try_charge_swap - try charging a swap entry
>> +/**
>> + * mem_cgroup_try_charge_swap - try charging swap space for a page
>>   * @page: page being added to swap
>>   * @entry: swap entry to charge
>>   *
>> - * Try to charge @entry to the memcg that @page belongs to.
>> + * Try to charge @page's memcg for the swap space at @entry.
>>   *
>>   * Returns 0 on success, -ENOMEM on failure.
>>   */
>>  int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
>>  {
>> -	struct mem_cgroup *memcg;
>> +	unsigned int nr_pages = hpage_nr_pages(page);
>>  	struct page_counter *counter;
>> +	struct mem_cgroup *memcg;
>>  	unsigned short oldid;
>>  
>>  	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) || !do_swap_account)
>> @@ -5929,25 +5929,26 @@ int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
>>  	memcg = mem_cgroup_id_get_online(memcg);
>>  
>>  	if (!mem_cgroup_is_root(memcg) &&
>> -	    !page_counter_try_charge(&memcg->swap, 1, &counter)) {
>> +	    !page_counter_try_charge(&memcg->swap, nr_pages, &counter)) {
>>  		mem_cgroup_id_put(memcg);
>>  		return -ENOMEM;
>>  	}
>>  
>> -	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
>> +	if (nr_pages > 1)
>> +		mem_cgroup_id_get_many(memcg, nr_pages - 1);
>
> The nr_pages -1 is not initutive, a comment about mem_cgroup_id_get_online()
> getting 1 would help.

Sure.  Will do that.

>> +	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg), nr_pages);
>>  	VM_BUG_ON_PAGE(oldid, page);
>> -	mem_cgroup_swap_statistics(memcg, true);
>> +	mem_cgroup_swap_statistics(memcg, nr_pages);
>>  
>>  	return 0;
>>  }
>>  
>>  /**
>> - * mem_cgroup_uncharge_swap - uncharge a swap entry
>> + * mem_cgroup_uncharge_swap - uncharge swap space
>>   * @entry: swap entry to uncharge
>> - *
>> - * Drop the swap charge associated with @entry.
>> + * @nr_pages: the amount of swap space to uncharge
>>   */
>> -void mem_cgroup_uncharge_swap(swp_entry_t entry)
>> +void mem_cgroup_uncharge_swap(swp_entry_t entry, unsigned int nr_pages)
>>  {
>>  	struct mem_cgroup *memcg;
>>  	unsigned short id;
>> @@ -5955,18 +5956,18 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
>>  	if (!do_swap_account)
>>  		return;
>>  
>> -	id = swap_cgroup_record(entry, 0);
>> +	id = swap_cgroup_record(entry, 0, nr_pages);
>>  	rcu_read_lock();
>>  	memcg = mem_cgroup_from_id(id);
>>  	if (memcg) {
>>  		if (!mem_cgroup_is_root(memcg)) {
>>  			if (cgroup_subsys_on_dfl(memory_cgrp_subsys))
>> -				page_counter_uncharge(&memcg->swap, 1);
>> +				page_counter_uncharge(&memcg->swap, nr_pages);
>>  			else
>> -				page_counter_uncharge(&memcg->memsw, 1);
>> +				page_counter_uncharge(&memcg->memsw, nr_pages);
>>  		}
>> -		mem_cgroup_swap_statistics(memcg, false);
>> -		mem_cgroup_id_put(memcg);
>> +		mem_cgroup_swap_statistics(memcg, -nr_pages);
>> +		mem_cgroup_id_put_many(memcg, nr_pages);
>>  	}
>>  	rcu_read_unlock();
>>  }
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index e67d6ba4e98e..29948d7da172 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -1290,7 +1290,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
>>  		SetPageUptodate(page);
>>  	}
>>  
>> -	swap = get_swap_page();
>> +	swap = get_swap_page(page);
>>  	if (!swap.val)
>>  		goto redirty;
>>  
>> diff --git a/mm/swap_cgroup.c b/mm/swap_cgroup.c
>> index ac6318a064d3..aee4b36d5207 100644
>> --- a/mm/swap_cgroup.c
>> +++ b/mm/swap_cgroup.c
>> @@ -58,21 +58,27 @@ static int swap_cgroup_prepare(int type)
>>  	return -ENOMEM;
>>  }
>>  
>> +static struct swap_cgroup *__lookup_swap_cgroup(struct swap_cgroup_ctrl *ctrl,
>> +						pgoff_t offset)
>> +{
>> +	struct page *mappage;
>> +	struct swap_cgroup *sc;
>> +
>> +	mappage = ctrl->map[offset / SC_PER_PAGE];
>> +	sc = page_address(mappage);
>> +	return sc + offset % SC_PER_PAGE;
>> +}
>> +
>>  static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
>>  					struct swap_cgroup_ctrl **ctrlp)
>>  {
>>  	pgoff_t offset = swp_offset(ent);
>>  	struct swap_cgroup_ctrl *ctrl;
>> -	struct page *mappage;
>> -	struct swap_cgroup *sc;
>>  
>>  	ctrl = &swap_cgroup_ctrl[swp_type(ent)];
>>  	if (ctrlp)
>>  		*ctrlp = ctrl;
>> -
>> -	mappage = ctrl->map[offset / SC_PER_PAGE];
>> -	sc = page_address(mappage);
>> -	return sc + offset % SC_PER_PAGE;
>> +	return __lookup_swap_cgroup(ctrl, offset);
>>  }
>>  
>>  /**
>> @@ -105,25 +111,39 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
>>  }
>>  
>>  /**
>> - * swap_cgroup_record - record mem_cgroup for this swp_entry.
>> - * @ent: swap entry to be recorded into
>> + * swap_cgroup_record - record mem_cgroup for a set of swap entries
>> + * @ent: the first swap entry to be recorded into
>>   * @id: mem_cgroup to be recorded
>> + * @nr_ents: number of swap entries to be recorded
>>   *
>>   * Returns old value at success, 0 at failure.
>>   * (Of course, old value can be 0.)
>>   */
>> -unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
>> +unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id,
>> +				  unsigned int nr_ents)
>>  {
>>  	struct swap_cgroup_ctrl *ctrl;
>>  	struct swap_cgroup *sc;
>>  	unsigned short old;
>>  	unsigned long flags;
>> +	pgoff_t offset = swp_offset(ent);
>> +	pgoff_t end = offset + nr_ents;
>>  
>>  	sc = lookup_swap_cgroup(ent, &ctrl);
>>  
>>  	spin_lock_irqsave(&ctrl->lock, flags);
>>  	old = sc->id;
>> -	sc->id = id;
>> +	for (;;) {
>> +		VM_BUG_ON(sc->id != old);
>> +		sc->id = id;
>> +		offset++;
>> +		if (offset == end)
>> +			break;
>> +		if (offset % SC_PER_PAGE)
>> +			sc++;
>> +		else
>> +			sc = __lookup_swap_cgroup(ctrl, offset);
>> +	}
>>  	spin_unlock_irqrestore(&ctrl->lock, flags);
>>  
>>  	return old;
>> diff --git a/mm/swap_slots.c b/mm/swap_slots.c
>> index 58f6c78f1dad..eb7524f8296d 100644
>> --- a/mm/swap_slots.c
>> +++ b/mm/swap_slots.c
>> @@ -263,7 +263,8 @@ static int refill_swap_slots_cache(struct swap_slots_cache *cache)
>>  
>>  	cache->cur = 0;
>>  	if (swap_slot_cache_active)
>> -		cache->nr = get_swap_pages(SWAP_SLOTS_CACHE_SIZE, cache->slots);
>> +		cache->nr = get_swap_pages(SWAP_SLOTS_CACHE_SIZE, false,
>> +					   cache->slots);
>>  
>>  	return cache->nr;
>>  }
>> @@ -301,11 +302,19 @@ int free_swap_slot(swp_entry_t entry)
>>  	return 0;
>>  }
>>  
>> -swp_entry_t get_swap_page(void)
>> +swp_entry_t get_swap_page(struct page *page)
>>  {
>>  	swp_entry_t entry, *pentry;
>>  	struct swap_slots_cache *cache;
>>  
>> +	entry.val = 0;
>> +
>> +	if (PageTransHuge(page)) {
>> +		if (hpage_nr_pages(page) == SWAPFILE_CLUSTER)
>> +			get_swap_pages(1, true, &entry);
>
> Are we ready to support multiple THP pages in one SWAPFILE_CLUSTER?
> Is there a design limitation?

Yes.  We support only one THP page in one swap cluster.  More
information is in above reply.

>> +		return entry;
>> +	}
>> +
>>  	/*
>>  	 * Preemption is allowed here, because we may sleep
>>  	 * in refill_swap_slots_cache().  But it is safe, because
>> @@ -317,7 +326,6 @@ swp_entry_t get_swap_page(void)
>>  	 */
>>  	cache = raw_cpu_ptr(&swp_slots);
>>  
>> -	entry.val = 0;
>>  	if (check_cache_active()) {
>>  		mutex_lock(&cache->alloc_lock);
>>  		if (cache->slots) {
>> @@ -337,7 +345,7 @@ swp_entry_t get_swap_page(void)
>>  			return entry;
>>  	}
>>  
>> -	get_swap_pages(1, &entry);
>> +	get_swap_pages(1, false, &entry);
>>  
>>  	return entry;
>>  }
>> diff --git a/mm/swap_state.c b/mm/swap_state.c
>> index 539b8885e3d1..c3478ee6e633 100644
>> --- a/mm/swap_state.c
>> +++ b/mm/swap_state.c
>> @@ -19,6 +19,7 @@
>>  #include <linux/migrate.h>
>>  #include <linux/vmalloc.h>
>>  #include <linux/swap_slots.h>
>> +#include <linux/huge_mm.h>
>>  
>>  #include <asm/pgtable.h>
>>  
>> @@ -38,6 +39,7 @@ struct address_space *swapper_spaces[MAX_SWAPFILES];
>>  static unsigned int nr_swapper_spaces[MAX_SWAPFILES];
>>  
>>  #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
>> +#define ADD_CACHE_INFO(x, nr)	do { swap_cache_info.x += (nr); } while (0)
>>  
>>  static struct {
>>  	unsigned long add_total;
>> @@ -90,39 +92,46 @@ void show_swap_cache_info(void)
>>   */
>>  int __add_to_swap_cache(struct page *page, swp_entry_t entry)
>>  {
>> -	int error;
>> +	int error, i, nr = hpage_nr_pages(page);
>>  	struct address_space *address_space;
>> +	pgoff_t idx = swp_offset(entry);
>>  
>>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>>  	VM_BUG_ON_PAGE(PageSwapCache(page), page);
>>  	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
>>  
>> -	get_page(page);
>> +	page_ref_add(page, nr);
>>  	SetPageSwapCache(page);
>> -	set_page_private(page, entry.val);
>>  
>>  	address_space = swap_address_space(entry);
>>  	spin_lock_irq(&address_space->tree_lock);
>> -	error = radix_tree_insert(&address_space->page_tree,
>> -				  swp_offset(entry), page);
>> -	if (likely(!error)) {
>> -		address_space->nrpages++;
>> -		__inc_node_page_state(page, NR_FILE_PAGES);
>> -		INC_CACHE_INFO(add_total);
>> +	for (i = 0; i < nr; i++) {
>> +		set_page_private(page + i, entry.val + i);
>> +		error = radix_tree_insert(&address_space->page_tree,
>> +					  idx + i, page + i);
>> +		if (unlikely(error))
>> +			break;
>>  	}
>> -	spin_unlock_irq(&address_space->tree_lock);
>> -
>> -	if (unlikely(error)) {
>> +	if (likely(!error)) {
>> +		address_space->nrpages += nr;
>> +		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, nr);
>> +		ADD_CACHE_INFO(add_total, nr);
>> +	} else {
>>  		/*
>>  		 * Only the context which have set SWAP_HAS_CACHE flag
>>  		 * would call add_to_swap_cache().
>>  		 * So add_to_swap_cache() doesn't returns -EEXIST.
>>  		 */
>>  		VM_BUG_ON(error == -EEXIST);
>> -		set_page_private(page, 0UL);
>> +		set_page_private(page + i, 0UL);
>> +		while (i--) {
>> +			radix_tree_delete(&address_space->page_tree, idx + i);
>> +			set_page_private(page + i, 0UL);
>> +		}
>>  		ClearPageSwapCache(page);
>> -		put_page(page);
>> +		page_ref_sub(page, nr);
>>  	}
>> +	spin_unlock_irq(&address_space->tree_lock);
>>  
>>  	return error;
>>  }
>> @@ -132,7 +141,7 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
>>  {
>>  	int error;
>>  
>> -	error = radix_tree_maybe_preload(gfp_mask);
>> +	error = radix_tree_maybe_preload_order(gfp_mask, compound_order(page));
>>  	if (!error) {
>>  		error = __add_to_swap_cache(page, entry);
>>  		radix_tree_preload_end();
>> @@ -146,8 +155,10 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
>>   */
>>  void __delete_from_swap_cache(struct page *page)
>>  {
>> -	swp_entry_t entry;
>>  	struct address_space *address_space;
>> +	int i, nr = hpage_nr_pages(page);
>> +	swp_entry_t entry;
>> +	pgoff_t idx;
>>  
>>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>>  	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
>> @@ -155,12 +166,15 @@ void __delete_from_swap_cache(struct page *page)
>>  
>>  	entry.val = page_private(page);
>>  	address_space = swap_address_space(entry);
>> -	radix_tree_delete(&address_space->page_tree, swp_offset(entry));
>> -	set_page_private(page, 0);
>> +	idx = swp_offset(entry);
>> +	for (i = 0; i < nr; i++) {
>> +		radix_tree_delete(&address_space->page_tree, idx + i);
>> +		set_page_private(page + i, 0);
>> +	}
>>  	ClearPageSwapCache(page);
>> -	address_space->nrpages--;
>> -	__dec_node_page_state(page, NR_FILE_PAGES);
>> -	INC_CACHE_INFO(del_total);
>> +	address_space->nrpages -= nr;
>> +	__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
>> +	ADD_CACHE_INFO(del_total, nr);
>>  }
>>  
>>  /**
>> @@ -178,20 +192,12 @@ int add_to_swap(struct page *page, struct list_head *list)
>>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>>  	VM_BUG_ON_PAGE(!PageUptodate(page), page);
>>  
>> -	entry = get_swap_page();
>> +retry:
>> +	entry = get_swap_page(page);
>>  	if (!entry.val)
>> -		return 0;
>> -
>> -	if (mem_cgroup_try_charge_swap(page, entry)) {
>> -		swapcache_free(entry);
>> -		return 0;
>> -	}
>> -
>> -	if (unlikely(PageTransHuge(page)))
>> -		if (unlikely(split_huge_page_to_list(page, list))) {
>> -			swapcache_free(entry);
>> -			return 0;
>> -		}
>> +		goto fail;
>> +	if (mem_cgroup_try_charge_swap(page, entry))
>> +		goto fail_free;
>>  
>>  	/*
>>  	 * Radix-tree node allocations from PF_MEMALLOC contexts could
>> @@ -206,17 +212,34 @@ int add_to_swap(struct page *page, struct list_head *list)
>>  	 */
>>  	err = add_to_swap_cache(page, entry,
>>  			__GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN);
>> -
>> -	if (!err) {
>> -		return 1;
>> -	} else {	/* -ENOMEM radix-tree allocation failure */
>> +	/* -ENOMEM radix-tree allocation failure */
>> +	if (err)
>>  		/*
>>  		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
>>  		 * clear SWAP_HAS_CACHE flag.
>>  		 */
>> -		swapcache_free(entry);
>> -		return 0;
>> +		goto fail_free;
>> +
>> +	if (unlikely(PageTransHuge(page))) {
>> +		err = split_huge_page_to_list(page, list);
>> +		if (err) {
>> +			delete_from_swap_cache(page);
>> +			return 0;
>> +		}
>>  	}
>> +
>> +	return 1;
>> +
>> +fail_free:
>> +	if (unlikely(PageTransHuge(page)))
>> +		swapcache_free_cluster(entry);
>> +	else
>> +		swapcache_free(entry);
>> +fail:
>> +	if (unlikely(PageTransHuge(page)) &&
>> +	    !split_huge_page_to_list(page, list))
>> +		goto retry;
>> +	return 0;
>>  }
>>  
>>  /*
>> @@ -237,8 +260,12 @@ void delete_from_swap_cache(struct page *page)
>>  	__delete_from_swap_cache(page);
>>  	spin_unlock_irq(&address_space->tree_lock);
>>  
>> -	swapcache_free(entry);
>> -	put_page(page);
>> +	if (PageTransHuge(page))
>> +		swapcache_free_cluster(entry);
>> +	else
>> +		swapcache_free(entry);
>> +
>> +	page_ref_sub(page, hpage_nr_pages(page));
>>  }
>>  
>>  /* 
>> @@ -295,7 +322,7 @@ struct page * lookup_swap_cache(swp_entry_t entry)
>>  
>>  	page = find_get_page(swap_address_space(entry), swp_offset(entry));
>>  
>> -	if (page) {
>> +	if (page && likely(!PageTransCompound(page))) {
>>  		INC_CACHE_INFO(find_success);
>>  		if (TestClearPageReadahead(page))
>>  			atomic_inc(&swapin_readahead_hits);
>> @@ -506,7 +533,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
>>  						gfp_mask, vma, addr);
>>  		if (!page)
>>  			continue;
>> -		if (offset != entry_offset)
>> +		if (offset != entry_offset && likely(!PageTransCompound(page)))
>>  			SetPageReadahead(page);
>>  		put_page(page);
>>  	}
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index f23c56e9be39..596306272059 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -200,7 +200,6 @@ static void discard_swap_cluster(struct swap_info_struct *si,
>>  	}
>>  }
>>  
>> -#define SWAPFILE_CLUSTER	256
>>  #define LATENCY_LIMIT		256
>>  
>>  static inline void cluster_set_flag(struct swap_cluster_info *info,
>> @@ -375,6 +374,14 @@ static void swap_cluster_schedule_discard(struct swap_info_struct *si,
>>  	schedule_work(&si->discard_work);
>>  }
>>  
>> +static void __free_cluster(struct swap_info_struct *si, unsigned long idx)
>> +{
>> +	struct swap_cluster_info *ci = si->cluster_info;
>> +
>> +	cluster_set_flag(ci + idx, CLUSTER_FLAG_FREE);
>> +	cluster_list_add_tail(&si->free_clusters, ci, idx);
>> +}
>> +
>>  /*
>>   * Doing discard actually. After a cluster discard is finished, the cluster
>>   * will be added to free cluster list. caller should hold si->lock.
>> @@ -395,10 +402,7 @@ static void swap_do_scheduled_discard(struct swap_info_struct *si)
>>  
>>  		spin_lock(&si->lock);
>>  		ci = lock_cluster(si, idx * SWAPFILE_CLUSTER);
>> -		cluster_set_flag(ci, CLUSTER_FLAG_FREE);
>> -		unlock_cluster(ci);
>> -		cluster_list_add_tail(&si->free_clusters, info, idx);
>> -		ci = lock_cluster(si, idx * SWAPFILE_CLUSTER);
>> +		__free_cluster(si, idx);
>>  		memset(si->swap_map + idx * SWAPFILE_CLUSTER,
>>  				0, SWAPFILE_CLUSTER);
>>  		unlock_cluster(ci);
>> @@ -416,6 +420,34 @@ static void swap_discard_work(struct work_struct *work)
>>  	spin_unlock(&si->lock);
>>  }
>>  
>> +static void alloc_cluster(struct swap_info_struct *si, unsigned long idx)
>> +{
>> +	struct swap_cluster_info *ci = si->cluster_info;
>> +
>> +	VM_BUG_ON(cluster_list_first(&si->free_clusters) != idx);
>> +	cluster_list_del_first(&si->free_clusters, ci);
>> +	cluster_set_count_flag(ci + idx, 0, 0);
>> +}
>> +
>> +static void free_cluster(struct swap_info_struct *si, unsigned long idx)
>> +{
>> +	struct swap_cluster_info *ci = si->cluster_info + idx;
>> +
>> +	VM_BUG_ON(cluster_count(ci) != 0);
>> +	/*
>> +	 * If the swap is discardable, prepare discard the cluster
>> +	 * instead of free it immediately. The cluster will be freed
>> +	 * after discard.
>> +	 */
>> +	if ((si->flags & (SWP_WRITEOK | SWP_PAGE_DISCARD)) ==
>> +	    (SWP_WRITEOK | SWP_PAGE_DISCARD)) {
>> +		swap_cluster_schedule_discard(si, idx);
>> +		return;
>> +	}
>> +
>> +	__free_cluster(si, idx);
>> +}
>> +
>>  /*
>>   * The cluster corresponding to page_nr will be used. The cluster will be
>>   * removed from free cluster list and its usage counter will be increased.
>> @@ -427,11 +459,8 @@ static void inc_cluster_info_page(struct swap_info_struct *p,
>>  
>>  	if (!cluster_info)
>>  		return;
>> -	if (cluster_is_free(&cluster_info[idx])) {
>> -		VM_BUG_ON(cluster_list_first(&p->free_clusters) != idx);
>> -		cluster_list_del_first(&p->free_clusters, cluster_info);
>> -		cluster_set_count_flag(&cluster_info[idx], 0, 0);
>> -	}
>> +	if (cluster_is_free(&cluster_info[idx]))
>> +		alloc_cluster(p, idx);
>>  
>>  	VM_BUG_ON(cluster_count(&cluster_info[idx]) >= SWAPFILE_CLUSTER);
>>  	cluster_set_count(&cluster_info[idx],
>> @@ -455,21 +484,8 @@ static void dec_cluster_info_page(struct swap_info_struct *p,
>>  	cluster_set_count(&cluster_info[idx],
>>  		cluster_count(&cluster_info[idx]) - 1);
>>  
>> -	if (cluster_count(&cluster_info[idx]) == 0) {
>> -		/*
>> -		 * If the swap is discardable, prepare discard the cluster
>> -		 * instead of free it immediately. The cluster will be freed
>> -		 * after discard.
>> -		 */
>> -		if ((p->flags & (SWP_WRITEOK | SWP_PAGE_DISCARD)) ==
>> -				 (SWP_WRITEOK | SWP_PAGE_DISCARD)) {
>> -			swap_cluster_schedule_discard(p, idx);
>> -			return;
>> -		}
>> -
>> -		cluster_set_flag(&cluster_info[idx], CLUSTER_FLAG_FREE);
>> -		cluster_list_add_tail(&p->free_clusters, cluster_info, idx);
>> -	}
>> +	if (cluster_count(&cluster_info[idx]) == 0)
>> +		free_cluster(p, idx);
>>  }
>>  
>>  /*
>> @@ -559,6 +575,60 @@ static bool scan_swap_map_try_ssd_cluster(struct swap_info_struct *si,
>>  	return found_free;
>>  }
>>  
>> +static void swap_range_alloc(struct swap_info_struct *si, unsigned long offset,
>> +			     unsigned int nr_entries)
>> +{
>> +	unsigned int end = offset + nr_entries - 1;
>> +
>> +	if (offset == si->lowest_bit)
>> +		si->lowest_bit += nr_entries;
>> +	if (end == si->highest_bit)
>> +		si->highest_bit -= nr_entries;
>> +	si->inuse_pages += nr_entries;
>> +	if (si->inuse_pages == si->pages) {
>> +		si->lowest_bit = si->max;
>> +		si->highest_bit = 0;
>> +		spin_lock(&swap_avail_lock);
>> +		plist_del(&si->avail_list, &swap_avail_head);
>> +		spin_unlock(&swap_avail_lock);
>> +	}
>> +}
>> +
>> +static void swap_range_free(struct swap_info_struct *si, unsigned long offset,
>> +			    unsigned int nr_entries)
>> +{
>> +	unsigned long end = offset + nr_entries - 1;
>> +	void (*swap_slot_free_notify)(struct block_device *, unsigned long);
>> +
>> +	if (offset < si->lowest_bit)
>> +		si->lowest_bit = offset;
>> +	if (end > si->highest_bit) {
>> +		bool was_full = !si->highest_bit;
>> +
>> +		si->highest_bit = end;
>> +		if (was_full && (si->flags & SWP_WRITEOK)) {
>> +			spin_lock(&swap_avail_lock);
>> +			WARN_ON(!plist_node_empty(&si->avail_list));
>> +			if (plist_node_empty(&si->avail_list))
>> +				plist_add(&si->avail_list, &swap_avail_head);
>> +			spin_unlock(&swap_avail_lock);
>> +		}
>> +	}
>> +	atomic_long_add(nr_entries, &nr_swap_pages);
>> +	si->inuse_pages -= nr_entries;
>> +	if (si->flags & SWP_BLKDEV)
>> +		swap_slot_free_notify =
>> +			si->bdev->bd_disk->fops->swap_slot_free_notify;
>> +	else
>> +		swap_slot_free_notify = NULL;
>> +	while (offset <= end) {
>> +		frontswap_invalidate_page(si->type, offset);
>> +		if (swap_slot_free_notify)
>> +			swap_slot_free_notify(si->bdev, offset);
>> +		offset++;
>> +	}
>> +}
>> +
>>  static int scan_swap_map_slots(struct swap_info_struct *si,
>>  			       unsigned char usage, int nr,
>>  			       swp_entry_t slots[])
>> @@ -677,18 +747,7 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
>>  	inc_cluster_info_page(si, si->cluster_info, offset);
>>  	unlock_cluster(ci);
>>  
>> -	if (offset == si->lowest_bit)
>> -		si->lowest_bit++;
>> -	if (offset == si->highest_bit)
>> -		si->highest_bit--;
>> -	si->inuse_pages++;
>> -	if (si->inuse_pages == si->pages) {
>> -		si->lowest_bit = si->max;
>> -		si->highest_bit = 0;
>> -		spin_lock(&swap_avail_lock);
>> -		plist_del(&si->avail_list, &swap_avail_head);
>> -		spin_unlock(&swap_avail_lock);
>> -	}
>> +	swap_range_alloc(si, offset, 1);
>>  	si->cluster_next = offset + 1;
>>  	slots[n_ret++] = swp_entry(si->type, offset);
>>  
>> @@ -767,6 +826,52 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
>>  	return n_ret;
>>  }
>>  
>> +#ifdef CONFIG_THP_SWAP
>> +static int swap_alloc_cluster(struct swap_info_struct *si, swp_entry_t *slot)
>> +{
>> +	unsigned long idx;
>> +	struct swap_cluster_info *ci;
>> +	unsigned long offset, i;
>> +	unsigned char *map;
>> +
>> +	if (cluster_list_empty(&si->free_clusters))
>> +		return 0;
>> +
>> +	idx = cluster_list_first(&si->free_clusters);
>> +	offset = idx * SWAPFILE_CLUSTER;
>> +	ci = lock_cluster(si, offset);
>> +	alloc_cluster(si, idx);
>> +	cluster_set_count_flag(ci, SWAPFILE_CLUSTER, 0);
>> +
>> +	map = si->swap_map + offset;
>> +	for (i = 0; i < SWAPFILE_CLUSTER; i++)
>> +		map[i] = SWAP_HAS_CACHE;
>> +	unlock_cluster(ci);
>> +	swap_range_alloc(si, offset, SWAPFILE_CLUSTER);
>> +	*slot = swp_entry(si->type, offset);
>> +
>> +	return 1;
>> +}
>> +
>> +static void swap_free_cluster(struct swap_info_struct *si, unsigned long idx)
>> +{
>> +	unsigned long offset = idx * SWAPFILE_CLUSTER;
>> +	struct swap_cluster_info *ci;
>> +
>> +	ci = lock_cluster(si, offset);
>> +	cluster_set_count_flag(ci, 0, 0);
>> +	free_cluster(si, idx);
>> +	unlock_cluster(ci);
>> +	swap_range_free(si, offset, SWAPFILE_CLUSTER);
>> +}
>> +#else
>> +static int swap_alloc_cluster(struct swap_info_struct *si, swp_entry_t *slot)
>> +{
>> +	VM_WARN_ON_ONCE(1);
>> +	return 0;
>> +}
>> +#endif /* CONFIG_THP_SWAP */
>> +
>>  static unsigned long scan_swap_map(struct swap_info_struct *si,
>>  				   unsigned char usage)
>>  {
>> @@ -782,13 +887,17 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
>>  
>>  }
>>  
>> -int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
>> +int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
>>  {
>> +	unsigned long nr_pages = cluster ? SWAPFILE_CLUSTER : 1;
>>  	struct swap_info_struct *si, *next;
>>  	long avail_pgs;
>>  	int n_ret = 0;
>>  
>> -	avail_pgs = atomic_long_read(&nr_swap_pages);
>> +	/* Only single cluster request supported */
>> +	WARN_ON_ONCE(n_goal > 1 && cluster);
>> +
>> +	avail_pgs = atomic_long_read(&nr_swap_pages) / nr_pages;
>>  	if (avail_pgs <= 0)
>>  		goto noswap;
>>  
>> @@ -798,7 +907,7 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
>>  	if (n_goal > avail_pgs)
>>  		n_goal = avail_pgs;
>>  
>> -	atomic_long_sub(n_goal, &nr_swap_pages);
>> +	atomic_long_sub(n_goal * nr_pages, &nr_swap_pages);
>>  
>>  	spin_lock(&swap_avail_lock);
>>  
>> @@ -824,10 +933,13 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
>>  			spin_unlock(&si->lock);
>>  			goto nextsi;
>>  		}
>> -		n_ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
>> -					    n_goal, swp_entries);
>> +		if (likely(cluster))
>> +			n_ret = swap_alloc_cluster(si, swp_entries);
>> +		else
>> +			n_ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
>> +						    n_goal, swp_entries);
>>  		spin_unlock(&si->lock);
>> -		if (n_ret)
>> +		if (n_ret || unlikely(cluster))
>>  			goto check_out;
>>  		pr_debug("scan_swap_map of si %d failed to find offset\n",
>>  			si->type);
>> @@ -853,7 +965,8 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
>>  
>>  check_out:
>>  	if (n_ret < n_goal)
>> -		atomic_long_add((long) (n_goal-n_ret), &nr_swap_pages);
>> +		atomic_long_add((long)(n_goal - n_ret) * nr_pages,
>> +				&nr_swap_pages);
>>  noswap:
>>  	return n_ret;
>>  }
>> @@ -1009,32 +1122,8 @@ static void swap_entry_free(struct swap_info_struct *p, swp_entry_t entry)
>>  	dec_cluster_info_page(p, p->cluster_info, offset);
>>  	unlock_cluster(ci);
>>  
>> -	mem_cgroup_uncharge_swap(entry);
>> -	if (offset < p->lowest_bit)
>> -		p->lowest_bit = offset;
>> -	if (offset > p->highest_bit) {
>> -		bool was_full = !p->highest_bit;
>> -
>> -		p->highest_bit = offset;
>> -		if (was_full && (p->flags & SWP_WRITEOK)) {
>> -			spin_lock(&swap_avail_lock);
>> -			WARN_ON(!plist_node_empty(&p->avail_list));
>> -			if (plist_node_empty(&p->avail_list))
>> -				plist_add(&p->avail_list,
>> -					  &swap_avail_head);
>> -			spin_unlock(&swap_avail_lock);
>> -		}
>> -	}
>> -	atomic_long_inc(&nr_swap_pages);
>> -	p->inuse_pages--;
>> -	frontswap_invalidate_page(p->type, offset);
>> -	if (p->flags & SWP_BLKDEV) {
>> -		struct gendisk *disk = p->bdev->bd_disk;
>> -
>> -		if (disk->fops->swap_slot_free_notify)
>> -			disk->fops->swap_slot_free_notify(p->bdev,
>> -							  offset);
>> -	}
>> +	mem_cgroup_uncharge_swap(entry, 1);
>> +	swap_range_free(p, offset, 1);
>>  }
>>  
>>  /*
>> @@ -1066,6 +1155,33 @@ void swapcache_free(swp_entry_t entry)
>>  	}
>>  }
>>  
>> +#ifdef CONFIG_THP_SWAP
>> +void swapcache_free_cluster(swp_entry_t entry)
>> +{
>> +	unsigned long offset = swp_offset(entry);
>> +	unsigned long idx = offset / SWAPFILE_CLUSTER;
>> +	struct swap_cluster_info *ci;
>> +	struct swap_info_struct *si;
>> +	unsigned char *map;
>> +	unsigned int i;
>> +
>> +	si = swap_info_get(entry);
>> +	if (!si)
>> +		return;
>> +
>> +	ci = lock_cluster(si, offset);
>> +	map = si->swap_map + offset;
>> +	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
>> +		VM_BUG_ON(map[i] != SWAP_HAS_CACHE);
>> +		map[i] = 0;
>> +	}
>> +	unlock_cluster(ci);
>> +	mem_cgroup_uncharge_swap(entry, SWAPFILE_CLUSTER);
>> +	swap_free_cluster(si, idx);
>> +	spin_unlock(&si->lock);
>> +}
>> +#endif /* CONFIG_THP_SWAP */
>> +
>>  static int swp_entry_cmp(const void *ent1, const void *ent2)
>>  {
>>  	const swp_entry_t *e1 = ent1, *e2 = ent2;
>
>
> This is a massive patch, I presume you've got recommendations to keep it
> this way?

Yes.  Johannes think this way is better than my previous organization,
which uses several smaller patches, but with function implementation and
function usage in different patches.

Best Regards,
Huang, Ying

> Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
