Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 308B26B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 11:53:00 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so797160eek.20
        for <linux-mm@kvack.org>; Thu, 15 May 2014 08:52:59 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id u49si4479841eef.172.2014.05.15.08.52.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 15 May 2014 08:52:58 -0700 (PDT)
Date: Thu, 15 May 2014 11:46:58 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v6] mm: support madvise(MADV_FREE)
Message-ID: <20140515154657.GA2720@cmpxchg.org>
References: <1399857988-2880-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399857988-2880-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, John Stultz <john.stultz@linaro.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>

Hi Minchan,

On Mon, May 12, 2014 at 10:26:28AM +0900, Minchan Kim wrote:
> Linux doesn't have an ability to free pages lazy while other OS
> already have been supported that named by madvise(MADV_FREE).
> 
> The gain is clear that kernel can discard freed pages rather than
> swapping out or OOM if memory pressure happens.
> 
> Without memory pressure, freed pages would be reused by userspace
> without another additional overhead(ex, page fault + allocation
> + zeroing).
> 
> How to work is following as.
> 
> When madvise syscall is called, VM clears dirty bit of ptes of
> the range. If memory pressure happens, VM checks dirty bit of
> page table and if it found still "clean", it means it's a
> "lazyfree pages" so VM could discard the page instead of swapping out.
> Once there was store operation for the page before VM peek a page
> to reclaim, dirty bit is set so VM can swap out the page instead of
> discarding.
> 
> Firstly, heavy users would be general allocators(ex, jemalloc,
> tcmalloc and hope glibc supports it) and jemalloc/tcmalloc already
> have supported the feature for other OS(ex, FreeBSD)
> 
> barrios@blaptop:~/benchmark/ebizzy$ lscpu
> Architecture:          x86_64
> CPU op-mode(s):        32-bit, 64-bit
> Byte Order:            Little Endian
> CPU(s):                4
> On-line CPU(s) list:   0-3
> Thread(s) per core:    2
> Core(s) per socket:    2
> Socket(s):             1
> NUMA node(s):          1
> Vendor ID:             GenuineIntel
> CPU family:            6
> Model:                 42
> Stepping:              7
> CPU MHz:               2801.000
> BogoMIPS:              5581.64
> Virtualization:        VT-x
> L1d cache:             32K
> L1i cache:             32K
> L2 cache:              256K
> L3 cache:              4096K
> NUMA node0 CPU(s):     0-3
> 
> ebizzy benchmark(./ebizzy -S 10 -n 512)
> 
>  vanilla-jemalloc		MADV_free-jemalloc
> 
> 1 thread
> records:  10              records:  10
> avg:      7436.70         avg:      15292.70
> std:      48.01(0.65%)    std:      496.40(3.25%)
> max:      7542.00         max:      15944.00
> min:      7366.00         min:      14478.00
> 
> 2 thread
> records:  10              records:  10
> avg:      12190.50        avg:      24975.50
> std:      1011.51(8.30%)  std:      1127.22(4.51%)
> max:      13012.00        max:      26382.00
> min:      10192.00        min:      23265.00
> 
> 4 thread
> records:  10              records:  10
> avg:      16875.30        avg:      36320.90
> std:      562.59(3.33%)   std:      1503.75(4.14%)
> max:      17465.00        max:      38314.00
> min:      15552.00        min:      33863.00
> 
> 8 thread
> records:  10              records:  10
> avg:      16966.80        avg:      35915.20
> std:      229.35(1.35%)   std:      2153.89(6.00%)
> max:      17456.00        max:      37943.00
> min:      16742.00        min:      29891.00
> 
> 16 thread
> records:  10              records:  10
> avg:      20590.90        avg:      37388.40
> std:      362.33(1.76%)   std:      1282.59(3.43%)
> max:      20954.00        max:      38911.00
> min:      19985.00        min:      34928.00
> 
> 32 thread
> records:  10              records:  10
> avg:      22633.40        avg:      37118.00
> std:      413.73(1.83%)   std:      766.36(2.06%)
> max:      23120.00        max:      38328.00
> min:      22071.00        min:      35557.00
> 
> In summary, MADV_FREE is about 2 time faster than MADV_DONTNEED.

This is great!

> Patchset is based on v3.15-rc5
> * From v5
>  * Fix PPC problem which don't flush TLB - Rik
>  * Remove unnecessary lazyfree_range stub function - Rik
>  * Rebased on v3.15-rc5
> 
> * From v4
>  * Add Reviewed-by: Zhang Yanfei
>  * Rebase on v3.15-rc1-mmotm-2014-04-15-16-14
> 
> * From v3
>  * Add "how to work part" in description - Zhang
>  * Add page_discardable utility function - Zhang
>  * Clean up
> 
> * From v2
>  * Remove forceful dirty marking of swap-readed page - Johannes

I don't quite understand how this came to be.  You asked me for my
opinion whether swapin was a problem and I agreed that it was!

If the dirty state denotes volatility, then a swapped-in page that
carries non-volatile data must be marked dirty again at that time,
otherwise it can get wrongfully discarded later on.

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index bf9811e1321a..c69594c141a9 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1082,6 +1082,8 @@ int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
>  		unsigned long size);
>  void zap_page_range(struct vm_area_struct *vma, unsigned long address,
>  		unsigned long size, struct zap_details *);
> +int lazyfree_single_vma(struct vm_area_struct *vma, unsigned long start_addr,
> +		unsigned long end_addr);

madvise_free_single_vma?

> @@ -251,6 +252,14 @@ static long madvise_willneed(struct vm_area_struct *vma,
>  	return 0;
>  }
>  
> +static long madvise_lazyfree(struct vm_area_struct *vma,

madvise_free?

> +			     struct vm_area_struct **prev,
> +			     unsigned long start, unsigned long end)
> +{
> +	*prev = vma;
> +	return lazyfree_single_vma(vma, start, end);
> +}
> +
>  /*
>   * Application no longer needs these pages.  If the pages are dirty,
>   * it's OK to just throw them away.  The app will be more careful about
> @@ -384,6 +393,13 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
>  		return madvise_remove(vma, prev, start, end);
>  	case MADV_WILLNEED:
>  		return madvise_willneed(vma, prev, start, end);
> +	case MADV_FREE:
> +		/*
> +		 * In this implementation, MADV_FREE works like MADV_DONTNEED
> +		 * on swapless system or full swap.
> +		 */
> +		if (get_nr_swap_pages() > 0)
> +			return madvise_lazyfree(vma, prev, start, end);

Please add an /* XXX */, we should fix this at some point.

> diff --git a/mm/memory.c b/mm/memory.c
> index 037b812a9531..0516c94da1a4 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1284,6 +1284,112 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
>  	return addr;
>  }
>  
> +static unsigned long lazyfree_pte_range(struct mmu_gather *tlb,

I'd prefer to have all this code directly where it's used, which is in
madvise.c, and also be named accordingly.  We can always rename and
move it later on should other code want to reuse it.

> +				struct vm_area_struct *vma, pmd_t *pmd,
> +				unsigned long addr, unsigned long end)
> +{
> +	struct mm_struct *mm = tlb->mm;
> +	spinlock_t *ptl;
> +	pte_t *start_pte;
> +	pte_t *pte;
> +
> +	start_pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> +	pte = start_pte;
> +	arch_enter_lazy_mmu_mode();
> +	do {
> +		pte_t ptent = *pte;
> +
> +		if (pte_none(ptent))
> +			continue;
> +
> +		if (!pte_present(ptent))
> +			continue;
> +
> +		/*
> +		 * Some of architecture(ex, PPC) don't update TLB
> +		 * with set_pte_at and tlb_remove_tlb_entry so for
> +		 * the portability, remap the pte with old|clean
> +		 * after pte clearing.
> +		 */
> +		ptent = ptep_get_and_clear_full(mm, addr, pte,
> +						tlb->fullmm);
> +		ptent = pte_mkold(ptent);
> +		ptent = pte_mkclean(ptent);
> +		set_pte_at(mm, addr, pte, ptent);
> +		tlb_remove_tlb_entry(tlb, pte, addr);
> +	} while (pte++, addr += PAGE_SIZE, addr != end);
> +	arch_leave_lazy_mmu_mode();
> +	pte_unmap_unlock(start_pte, ptl);
> +
> +	return addr;
> +}
> +
> +static inline unsigned long lazyfree_pmd_range(struct mmu_gather *tlb,
> +				struct vm_area_struct *vma, pud_t *pud,
> +				unsigned long addr, unsigned long end)
> +{
> +	pmd_t *pmd;
> +	unsigned long next;
> +
> +	pmd = pmd_offset(pud, addr);
> +	do {
> +		next = pmd_addr_end(addr, end);
> +		if (pmd_trans_huge(*pmd))
> +			split_huge_page_pmd(vma, addr, pmd);

/* XXX */ as well? :)

> @@ -754,11 +763,34 @@ static bool invalid_page_referenced_vma(struct vm_area_struct *vma, void *arg)
>  }
>  
>  /**
> + * page_discardable - test if the page could be discardable instead of swap
> + * @page: the page to test
> + * @pte_dirty: ptes which have marked dirty bit
> + *
> + * Should check PageDirty because swap-in page by read fault
> + * would put on swapcache and pte point out the page doesn't have
> + * dirty bit so only pte dirtiness check isn't enough to detect
> + * lazyfree page so we need to check PG_swapcache to filter it out.
> + * But, if the page is removed from swapcache, it must have PG_dirty
> + * so we should check it to prevent purging non-lazyfree page.
> + */
> +bool page_discardable(struct page *page, bool pte_dirty)
> +{
> +	bool ret = false;
> +
> +	if (PageAnon(page) && !pte_dirty && !PageSwapCache(page) &&
> +			!PageDirty(page))
> +		ret = true;
> +	return ret;
> +}
> +
> +/**
>   * page_referenced - test if the page was referenced
>   * @page: the page to test
>   * @is_locked: caller holds lock on the page
>   * @memcg: target memory cgroup
>   * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
> + * @is_pte_dirty: ptes which have marked dirty bit - used for lazyfree page
>   *
>   * Quick test_and_clear_referenced for all mappings to a page,
>   * returns the number of ptes which referenced the page.
> @@ -766,7 +798,8 @@ static bool invalid_page_referenced_vma(struct vm_area_struct *vma, void *arg)
>  int page_referenced(struct page *page,
>  		    int is_locked,
>  		    struct mem_cgroup *memcg,
> -		    unsigned long *vm_flags)
> +		    unsigned long *vm_flags,
> +		    int *is_pte_dirty)
>  {
>  	int ret;
>  	int we_locked = 0;
> @@ -781,6 +814,9 @@ int page_referenced(struct page *page,
>  	};
>  
>  	*vm_flags = 0;
> +	if (is_pte_dirty)
> +		*is_pte_dirty = 0;
> +
>  	if (!page_mapped(page))
>  		return 0;
>  
> @@ -808,6 +844,9 @@ int page_referenced(struct page *page,
>  	if (we_locked)
>  		unlock_page(page);
>  
> +	if (is_pte_dirty)
> +		*is_pte_dirty = pra.dirtied;
> +
>  	return pra.referenced;
>  }
>  
> @@ -1120,7 +1159,9 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	pte_t pteval;
>  	spinlock_t *ptl;
>  	int ret = SWAP_AGAIN;
> -	enum ttu_flags flags = (enum ttu_flags)arg;
> +	struct rmap_private *rp = (struct rmap_private *)arg;
> +	enum ttu_flags flags = rp->flags;
> +	int dirty = 0;
>  
>  	pte = page_check_address(page, mm, address, &ptl, 0);
>  	if (!pte)
> @@ -1150,7 +1191,8 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	pteval = ptep_clear_flush(vma, address, pte);
>  
>  	/* Move the dirty bit to the physical page now the pte is gone. */
> -	if (pte_dirty(pteval))
> +	dirty = pte_dirty(pteval);
> +	if (dirty)
>  		set_page_dirty(page);
>  
>  	/* Update high watermark before we lower rss */
> @@ -1179,6 +1221,15 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  		swp_entry_t entry = { .val = page_private(page) };
>  		pte_t swp_pte;
>  
> +		if ((TTU_ACTION(flags) == TTU_UNMAP) &&
> +				page_discardable(page, dirty)) {
> +			dec_mm_counter(mm, MM_ANONPAGES);
> +			goto discard;
> +		}

This is strange, why would you check page_discardable() again?  We
know it's anon, we already check if it's swapcache, and we have the
pte dirty bit.  The page dirty bit is implied, because we would have
added the page to swapcache had it been dirty (should be stable with
the page lock, right?)

> @@ -1197,6 +1248,10 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			}
>  			dec_mm_counter(mm, MM_ANONPAGES);
>  			inc_mm_counter(mm, MM_SWAPENTS);
> +		} else if (TTU_ACTION(flags) == TTU_UNMAP) {
> +			set_pte_at(mm, address, pte, pteval);
> +			ret = SWAP_FAIL;
> +			goto out_unmap;

...i.e. here you could just check `dirty' for this individual pte,
which can always race with reclaim.  Remap and return SWAP_FAIL if it
is so we try again later, otherwise dec_mm_counter() and goto discard.

> @@ -1517,8 +1579,13 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
>  
>  	ret = rmap_walk(page, &rwc);
>  
> -	if (ret != SWAP_MLOCK && !page_mapped(page))
> +	if (ret != SWAP_MLOCK && !page_mapped(page)) {
>  		ret = SWAP_SUCCESS;
> +		if (TTU_ACTION(flags) == TTU_UNMAP &&
> +			page_discardable(page, rp.pte_dirty))
> +			ret = SWAP_DISCARD;
> +	}

It's discardable if we fully unmapped it at this point, so I don't
think changing this code is necessary.

> @@ -748,6 +752,9 @@ static enum page_references page_check_references(struct page *page,
>  		return PAGEREF_KEEP;
>  	}
>  
> +	if (page_discardable(page, is_pte_dirty))
> +		return PAGEREF_DISCARD;
> +

Just return whether the page or the ptes are dirty here in an extra
argument, int *dirty.  That leaves no callers to page_discardable()
and it can be removed.

> @@ -817,6 +824,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		int may_enter_fs;
>  		enum page_references references = PAGEREF_RECLAIM_CLEAN;
>  		bool dirty, writeback;
> +		bool discard = false;
>  
>  		cond_resched();
>  
> @@ -946,6 +954,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			goto activate_locked;
>  		case PAGEREF_KEEP:
>  			goto keep_locked;
> +		case PAGEREF_DISCARD:
> +			/*
> +			 * skip to add the page into swapcache  then
> +			 * unmap without mapping
> +			 */
> +			discard = true;
>  		case PAGEREF_RECLAIM:
>  		case PAGEREF_RECLAIM_CLEAN:
>  			; /* try to reclaim the page below */
> @@ -955,7 +969,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * Anonymous process memory has backing store?
>  		 * Try to allocate it some swap space here.
>  		 */
> -		if (PageAnon(page) && !PageSwapCache(page)) {
> +		if (PageAnon(page) && !PageSwapCache(page) && !discard) {

... then use !dirty instead of !discard, to make it obvious right here
that we do not swap clean anon pages.

> @@ -970,7 +984,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * The page is mapped into the page tables of one or more
>  		 * processes. Try to unmap it here.
>  		 */
> -		if (page_mapped(page) && mapping) {
> +		if (page_mapped(page) && (mapping || discard)) {
>  			switch (try_to_unmap(page, ttu_flags)) {

The discard check is not necessary, try_to_unmap() will do the right
thing for anon !swapcache: clear clean ptes, or return SWAP_AGAIN when
it encounters dirty ptes that came after page_referenced().  If that
happens, the page will be tried again later, and if the dirty state is
still there, we'll see it in page_check_references() and swap the page
like any other.

> @@ -978,6 +992,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				goto keep_locked;
>  			case SWAP_MLOCK:
>  				goto cull_mlocked;
> +			case SWAP_DISCARD:
> +				VM_BUG_ON_PAGE(PageSwapCache(page), page);
> +				if (!page_freeze_refs(page, 1))
> +					goto keep_locked;
> +				__clear_page_locked(page);
> +				count_vm_event(PGLAZYFREED);
> +				goto free_it;

I'd rather this be merged into __remove_mapping() instead and then
have these pages just follow the regular SWAP_SUCCESS path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
