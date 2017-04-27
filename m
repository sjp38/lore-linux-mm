Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 540CF6B0388
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 03:12:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c16so19394506pfl.21
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 00:12:39 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id s184si1831331pfb.65.2017.04.27.00.12.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 00:12:38 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v10 1/3] mm, THP, swap: Delay splitting THP during swap out
References: <20170425125658.28684-1-ying.huang@intel.com>
	<20170425125658.28684-2-ying.huang@intel.com>
	<20170427053141.GA1925@bbox>
Date: Thu, 27 Apr 2017 15:12:34 +0800
In-Reply-To: <20170427053141.GA1925@bbox> (Minchan Kim's message of "Thu, 27
	Apr 2017 14:31:41 +0900")
Message-ID: <87mvb21fz1.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, cgroups@vger.kernel.org

Minchan Kim <minchan@kernel.org> writes:

> On Tue, Apr 25, 2017 at 08:56:56PM +0800, Huang, Ying wrote:
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
>> for the architecture.  In effect, this will enlarge swap cluster size
>> by 2 times on x86_64.  Which may make it harder to find a free cluster
>> when the swap space becomes fragmented.  So that, this may reduce the
>> continuous swap space allocation and sequential write in theory.  The
>> performance test in 0day shows no regressions caused by this.
>
> What about other architecures?
>
> I mean THP page size on every architectures would be various.
> If THP page size is much bigger than 2M, the architecture should
> have big swap cluster size for supporting THP swap-out feature.
> It means fast empty-swap cluster consumption so that it can suffer
> from fragmentation easily which causes THP swap void and swap slot
> allocations slow due to not being able to use per-cpu.
>
> What I suggested was contiguous multiple swap cluster allocations
> to meet THP page size. If some of architecure's THP size is 64M
> and SWAP_CLUSTER_SIZE is 2M, it should allocate 32 contiguos
> swap clusters. For that, swap layer need to manage clusters sort
> in order which would be more overhead in CONFIG_THP_SWAP case
> but I think it's tradeoff. With that, every architectures can
> support THP swap easily without arch-specific something.

That may be a good solution for other architectures.  But I am afraid I
am not the right person to work on that.  Because I don't know the
requirement of other architectures, and I have no other architectures
machines to work on and measure the performance.

And the swap clusters aren't sorted in order now intentionally to avoid
cache line false sharing between the spinlock of struct
swap_cluster_info.  If we want to sort clusters in order, we need a
solution for that.

> If (PAGE_SIZE * 512) swap cluster size were okay for most of
> architecture, just increase it. It's orthogonal work regardless of
> THP swapout. Then, we don't need to manage swap clusters sort
> in order in x86_64 which SWAP_CLUSTER_SIZE is equal to
> THP_PAGE_SIZE. It's just a bonus by side-effect.

Andrew suggested to make swap cluster size = huge page size (or turn on
THP swap optimization) only if we enabled CONFIG_THP_SWAP.  So that, THP
swap optimization will not be turned on unintentionally.

We may adjust default swap cluster size, but I don't think it need to be
in this patchset.

> AFAIR, I suggested it but cannot remember why we cannot go with
> this way.
>
>> 
>> In the future of THP swap optimization, some information of the
>> swapped out THP (such as compound map count) will be recorded in the
>> swap_cluster_info data structure.
>> 
>> The mem cgroup swap accounting functions are enhanced to support
>> charge or uncharge a swap cluster backing a THP as a whole.
>> 
>> The swap cluster allocate/free functions are added to allocate/free a
>> swap cluster for a THP.  A fair simple algorithm is used for swap
>> cluster allocation, that is, only the first swap device in priority
>> list will be tried to allocate the swap cluster.  The function will
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
>> 
>> With the patch, the swap out throughput improves 11.5% (from about
>> 3.73GB/s to about 4.16GB/s) in the vm-scalability swap-w-seq test case
>> with 8 processes.  The test is done on a Xeon E5 v3 system.  The swap
>> device used is a RAM simulated PMEM (persistent memory) device.  To
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
>>  mm/memcontrol.c             |  50 ++++-----
>>  mm/shmem.c                  |   2 +-
>>  mm/swap_cgroup.c            |  40 +++++--
>>  mm/swap_slots.c             |  16 ++-
>>  mm/swap_state.c             | 114 ++++++++++++--------
>>  mm/swapfile.c               | 256 ++++++++++++++++++++++++++++++++------------
>>  12 files changed, 375 insertions(+), 165 deletions(-)
>
> < snip >
>
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
>
> If swap is non-ssd, swap.val could be zero. Right?
> If so, could we retry like anonymous page swapout?

This is for shmem, where the THP will be split before goes here.  That
is, "page" here is always normal page.

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
>> +		return entry;
>> +	}
>> +
>
>
> < snip >
>
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
>
> So, with non-SSD swap, THP page *always* get the fail to get swp_entry_t
> and retry after split the page. However, it makes unncessary get_swap_pages
> call which is not trivial. If there is no SSD swap, thp-swap out should
> be void without adding any performance overhead.
> Hmm, but I have no good idea to do it simple. :(

For HDD swap, the device raw throughput is so low (< 100M Bps
typically), that the added overhead here will not be a big issue.  Do
you agree?

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
