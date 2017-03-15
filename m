Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A45F36B038C
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 21:08:50 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q126so6920801pga.0
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 18:08:50 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id k22si359017pli.26.2017.03.14.18.08.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 18:08:49 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v6 4/9] mm, THP, swap: Add get_huge_swap_page()
References: <20170308072613.17634-1-ying.huang@intel.com>
	<20170308072613.17634-5-ying.huang@intel.com>
	<1489534821.2733.47.camel@linux.intel.com>
Date: Wed, 15 Mar 2017 09:08:46 +0800
In-Reply-To: <1489534821.2733.47.camel@linux.intel.com> (Tim Chen's message of
	"Tue, 14 Mar 2017 16:40:21 -0700")
Message-ID: <871stze481.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

Tim Chen <tim.c.chen@linux.intel.com> writes:

> On Wed, 2017-03-08 at 15:26 +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> A variation of get_swap_page(), get_huge_swap_page(), is added to
>> allocate a swap cluster (HPAGE_PMD_NR swap slots) based on the swap
>> cluster allocation function.A A A fair simple algorithm is used, that is,
>> only the first swap device in priority list will be tried to allocate
>> the swap cluster.A A The function will fail if the trying is not
>> successful, and the caller will fallback to allocate a single swap slot
>> instead.A A This works good enough for normal cases.
>> 
>> This will be used for the THP (Transparent Huge Page) swap support.
>> Where get_huge_swap_page() will be used to allocate one swap cluster for
>> each THP swapped out.
>> 
>> Because of the algorithm adopted, if the difference of the number of the
>> free swap clusters among multiple swap devices is significant, it is
>> possible that some THPs are split earlier than necessary.A A For example,
>> this could be caused by big size difference among multiple swap devices.
>> 
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Shaohua Li <shli@kernel.org>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Rik van Riel <riel@redhat.com>
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> ---
>> A include/linux/swap.h | 19 ++++++++++++++++++-
>> A mm/swap_slots.cA A A A A A |A A 5 +++--
>> A mm/swapfile.cA A A A A A A A | 16 ++++++++++++----
>> A 3 files changed, 33 insertions(+), 7 deletions(-)
>> 
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index 278e1349a424..e3a7609a8989 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -388,7 +388,7 @@ static inline long get_nr_swap_pages(void)
>> A extern void si_swapinfo(struct sysinfo *);
>> A extern swp_entry_t get_swap_page(void);
>> A extern swp_entry_t get_swap_page_of_type(int);
>> -extern int get_swap_pages(int n, swp_entry_t swp_entries[]);
>> +extern int get_swap_pages(int n, swp_entry_t swp_entries[], bool huge);
>> A extern int add_swap_count_continuation(swp_entry_t, gfp_t);
>> A extern void swap_shmem_alloc(swp_entry_t);
>> A extern int swap_duplicate(swp_entry_t);
>> @@ -527,6 +527,23 @@ static inline swp_entry_t get_swap_page(void)
>> A 
>> A #endif /* CONFIG_SWAP */
>> A 
>> +#ifdef CONFIG_THP_SWAP_CLUSTER
>> +static inline swp_entry_t get_huge_swap_page(void)
>> +{
>> +	swp_entry_t entry;
>> +
>> +	if (get_swap_pages(1, &entry, true))
>> +		return entry;
>> +	else
>> +		return (swp_entry_t) {0};
>> +}
>> +#else
>> +static inline swp_entry_t get_huge_swap_page(void)
>> +{
>> +	return (swp_entry_t) {0};
>> +}
>> +#endif
>> +
>> A #ifdef CONFIG_MEMCG
>> A static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
>> A {
>> diff --git a/mm/swap_slots.c b/mm/swap_slots.c
>> index 9b5bc86f96ad..075bb39e03c5 100644
>> --- a/mm/swap_slots.c
>> +++ b/mm/swap_slots.c
>> @@ -258,7 +258,8 @@ static int refill_swap_slots_cache(struct swap_slots_cache *cache)
>> A 
>> A 	cache->cur = 0;
>> A 	if (swap_slot_cache_active)
>> -		cache->nr = get_swap_pages(SWAP_SLOTS_CACHE_SIZE, cache->slots);
>> +		cache->nr = get_swap_pages(SWAP_SLOTS_CACHE_SIZE, cache->slots,
>> +					A A A false);
>> A 
>> A 	return cache->nr;
>> A }
>> @@ -334,7 +335,7 @@ swp_entry_t get_swap_page(void)
>> A 			return entry;
>> A 	}
>> A 
>> -	get_swap_pages(1, &entry);
>> +	get_swap_pages(1, &entry, false);
>> A 
>> A 	return entry;
>> A }
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index 91876c33114b..7241c937e52b 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -904,11 +904,12 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
>> A 
>> A }
>> A 
>> -int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
>
>
>> +int get_swap_pages(int n_goal, swp_entry_t swp_entries[], bool huge)
>> A {
>> A 	struct swap_info_struct *si, *next;
>> A 	long avail_pgs;
>> A 	int n_ret = 0;
>> +	int nr_pages = huge_cluster_nr_entries(huge);
>> A 
>> A 	avail_pgs = atomic_long_read(&nr_swap_pages);
>> A 	if (avail_pgs <= 0)
>> @@ -920,6 +921,10 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
>> A 	if (n_goal > avail_pgs)
>> A 		n_goal = avail_pgs;
>> A 
>> +	n_goal *= nr_pages;
>
> I think if (n_goal > 1) when huge is true,A 
> n_goal should be set to huge_cluster_nr_entries(huge) here
> or we could have an invalid check below. We probably
> should add a comment to get_swap_pages on how we treat
> n_goal when huge is true. A Maybe say we will always treat
> n_goal as SWAPFILE_CLUSTER when huge is true.A 

Yes.  The meaning of n_goal and n_ret isn't consistent between huge and
normal swap entry allocation.  I will revise the logic in the function
to make them consistent.

>> +	if (avail_pgs < n_goal)
>> +		goto noswap;
>> +
>> A 	atomic_long_sub(n_goal, &nr_swap_pages);
>> A 
>> A 	spin_lock(&swap_avail_lock);
>> @@ -946,10 +951,13 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
>> A 			spin_unlock(&si->lock);
>> A 			goto nextsi;
>> A 		}
>> -		n_ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
>> -					A A A A n_goal, swp_entries);
>> +		if (likely(nr_pages == 1))
>
> if (likely(!huge)) is probably more readable

Sure.

Best Regards,
Huang, Ying

>> +			n_ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
>> +						A A A A n_goal, swp_entries);
>> +		else
>> +			n_ret = swap_alloc_huge_cluster(si, swp_entries);
>> A 		spin_unlock(&si->lock);
>
> Thanks.
>
> Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
