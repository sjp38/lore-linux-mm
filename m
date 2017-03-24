Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13AFA6B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 10:50:47 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b16so776839wmi.14
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 07:50:47 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id h132si3325567wmf.127.2017.03.24.07.50.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 07:50:45 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id u132so1074677wmg.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 07:50:44 -0700 (PDT)
Date: Fri, 24 Mar 2017 17:50:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 06/11] mm: thp: check pmd migration entry in common
 path
Message-ID: <20170324145042.bda52glerop5wydx@node.shutemov.name>
References: <20170313154507.3647-1-zi.yan@sent.com>
 <20170313154507.3647-7-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313154507.3647-7-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

On Mon, Mar 13, 2017 at 11:45:02AM -0400, Zi Yan wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> If one of callers of page migration starts to handle thp,
> memory management code start to see pmd migration entry, so we need
> to prepare for it before enabling. This patch changes various code
> point which checks the status of given pmds in order to prevent race
> between thp migration and the pmd-related works.
> 
> ChangeLog v1 -> v2:
> - introduce pmd_related() (I know the naming is not good, but can't
>   think up no better name. Any suggesntion is welcomed.)
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> ChangeLog v2 -> v3:
> - add is_swap_pmd()
> - a pmd entry should be pmd pointing to pte pages, is_swap_pmd(),
>   pmd_trans_huge(), pmd_devmap(), or pmd_none()
> - use pmdp_huge_clear_flush() instead of pmdp_huge_get_and_clear()
> - flush_cache_range() while set_pmd_migration_entry()
> - pmd_none_or_trans_huge_or_clear_bad() and pmd_trans_unstable() return
>   true on pmd_migration_entry, so that migration entries are not
>   treated as pmd page table entries.
> 
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  arch/x86/mm/gup.c             |  4 +--
>  fs/proc/task_mmu.c            | 22 +++++++++------
>  include/asm-generic/pgtable.h |  3 +-
>  include/linux/huge_mm.h       | 14 +++++++--
>  mm/gup.c                      | 22 +++++++++++++--
>  mm/huge_memory.c              | 66 ++++++++++++++++++++++++++++++++++++++-----
>  mm/madvise.c                  |  2 ++
>  mm/memcontrol.c               |  2 ++
>  mm/memory.c                   |  9 ++++--
>  mm/mprotect.c                 |  6 ++--
>  mm/mremap.c                   |  2 +-
>  11 files changed, 124 insertions(+), 28 deletions(-)
> 
> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> index 1f3b6ef105cd..23bb071f286d 100644
> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -243,9 +243,9 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
>  		pmd_t pmd = *pmdp;
>  
>  		next = pmd_addr_end(addr, end);
> -		if (pmd_none(pmd))
> +		if (!pmd_present(pmd))
>  			return 0;
> -		if (unlikely(pmd_large(pmd) || !pmd_present(pmd))) {
> +		if (unlikely(pmd_large(pmd))) {
>  			/*
>  			 * NUMA hinting faults need to be handled in the GUP
>  			 * slowpath for accounting purposes and so that they
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 5c8359704601..f2b0f3ba25ac 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -600,7 +600,8 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  
>  	ptl = pmd_trans_huge_lock(pmd, vma);
>  	if (ptl) {
> -		smaps_pmd_entry(pmd, addr, walk);
> +		if (pmd_present(*pmd))
> +			smaps_pmd_entry(pmd, addr, walk);
>  		spin_unlock(ptl);
>  		return 0;
>  	}
> @@ -942,6 +943,9 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
>  			goto out;
>  		}
>  
> +		if (!pmd_present(*pmd))
> +			goto out;
> +
>  		page = pmd_page(*pmd);
>  
>  		/* Clear accessed and referenced bits. */
> @@ -1221,19 +1225,19 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
>  	if (ptl) {
>  		u64 flags = 0, frame = 0;
>  		pmd_t pmd = *pmdp;
> +		struct page *page;
>  
>  		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(pmd))
>  			flags |= PM_SOFT_DIRTY;
>  
> -		/*
> -		 * Currently pmd for thp is always present because thp
> -		 * can not be swapped-out, migrated, or HWPOISONed
> -		 * (split in such cases instead.)
> -		 * This if-check is just to prepare for future implementation.
> -		 */
> -		if (pmd_present(pmd)) {
> -			struct page *page = pmd_page(pmd);
> +		if (is_pmd_migration_entry(pmd)) {
> +			swp_entry_t entry = pmd_to_swp_entry(pmd);
>  
> +			frame = swp_type(entry) |
> +				(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
> +			page = migration_entry_to_page(entry);
> +		} else if (pmd_present(pmd)) {
> +			page = pmd_page(pmd);
>  			if (page_mapcount(page) == 1)
>  				flags |= PM_MMAP_EXCLUSIVE;
>  
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index f4ca23b158b3..f98a028100b6 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -790,7 +790,8 @@ static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  	barrier();
>  #endif
> -	if (pmd_none(pmdval) || pmd_trans_huge(pmdval))
> +	if (pmd_none(pmdval) || pmd_trans_huge(pmdval)
> +			|| !pmd_present(pmdval))
>  		return 1;

pmd_none() check is redundant now.

>  	if (unlikely(pmd_bad(pmdval))) {
>  		pmd_clear_bad(pmd);
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 1b81cb57ff0f..6f44a2352597 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -126,7 +126,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  #define split_huge_pmd(__vma, __pmd, __address)				\
>  	do {								\
>  		pmd_t *____pmd = (__pmd);				\
> -		if (pmd_trans_huge(*____pmd)				\
> +		if (is_swap_pmd(*____pmd) || pmd_trans_huge(*____pmd)	\
>  					|| pmd_devmap(*____pmd))	\
>  			__split_huge_pmd(__vma, __pmd, __address,	\
>  						false, NULL);		\
> @@ -157,12 +157,18 @@ extern spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd,
>  		struct vm_area_struct *vma);
>  extern spinlock_t *__pud_trans_huge_lock(pud_t *pud,
>  		struct vm_area_struct *vma);
> +
> +static inline int is_swap_pmd(pmd_t pmd)
> +{
> +	return !pmd_none(pmd) && !pmd_present(pmd);
> +}
> +
>  /* mmap_sem must be held on entry */
>  static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
>  		struct vm_area_struct *vma)
>  {
>  	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
> -	if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
> +	if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
>  		return __pmd_trans_huge_lock(pmd, vma);
>  	else
>  		return NULL;
> @@ -269,6 +275,10 @@ static inline void vma_adjust_trans_huge(struct vm_area_struct *vma,
>  					 long adjust_next)
>  {
>  }
> +static inline int is_swap_pmd(pmd_t pmd)
> +{
> +	return 0;
> +}
>  static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
>  		struct vm_area_struct *vma)
>  {
> diff --git a/mm/gup.c b/mm/gup.c
> index 94fab8fa432b..2b1effb16242 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -272,6 +272,15 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
>  			return page;
>  		return no_page_table(vma, flags);
>  	}
> +	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
> +		return no_page_table(vma, flags);
> +	if (!pmd_present(*pmd)) {
> +retry:
> +		if (likely(!(flags & FOLL_MIGRATION)))
> +			return no_page_table(vma, flags);
> +		pmd_migration_entry_wait(mm, pmd);
> +		goto retry;

This looks a lot like endless loop if flags contain FOLL_MIGRATION. Hm?

I guess retry label should be on previous line.

> +	}
>  	if (pmd_devmap(*pmd)) {
>  		ptl = pmd_lock(mm, pmd);
>  		page = follow_devmap_pmd(vma, address, pmd, flags);
> @@ -286,6 +295,15 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
>  		return no_page_table(vma, flags);
>  
>  	ptl = pmd_lock(mm, pmd);
> +	if (unlikely(!pmd_present(*pmd))) {
> +retry_locked:
> +		if (likely(!(flags & FOLL_MIGRATION))) {
> +			spin_unlock(ptl);
> +			return no_page_table(vma, flags);
> +		}
> +		pmd_migration_entry_wait(mm, pmd);
> +		goto retry_locked;

Again. That's doesn't look right..

> +	}
>  	if (unlikely(!pmd_trans_huge(*pmd))) {
>  		spin_unlock(ptl);
>  		return follow_page_pte(vma, address, pmd, flags);
> @@ -341,7 +359,7 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
>  	pud = pud_offset(pgd, address);
>  	BUG_ON(pud_none(*pud));
>  	pmd = pmd_offset(pud, address);
> -	if (pmd_none(*pmd))
> +	if (!pmd_present(*pmd))
>  		return -EFAULT;
>  	VM_BUG_ON(pmd_trans_huge(*pmd));
>  	pte = pte_offset_map(pmd, address);
> @@ -1369,7 +1387,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
>  		pmd_t pmd = READ_ONCE(*pmdp);
>  
>  		next = pmd_addr_end(addr, end);
> -		if (pmd_none(pmd))
> +		if (!pmd_present(pmd))
>  			return 0;
>  
>  		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index a9c2a0ef5b9b..3f18452f3eb1 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -898,6 +898,21 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  
>  	ret = -EAGAIN;
>  	pmd = *src_pmd;
> +
> +	if (unlikely(is_pmd_migration_entry(pmd))) {

Shouldn't you first check that the pmd is not present?

> +		swp_entry_t entry = pmd_to_swp_entry(pmd);
> +
> +		if (is_write_migration_entry(entry)) {
> +			make_migration_entry_read(&entry);
> +			pmd = swp_entry_to_pmd(entry);
> +			set_pmd_at(src_mm, addr, src_pmd, pmd);
> +		}
> +		set_pmd_at(dst_mm, addr, dst_pmd, pmd);
> +		ret = 0;
> +		goto out_unlock;
> +	}
> +	WARN_ONCE(!pmd_present(pmd), "Uknown non-present format on pmd.\n");

Typo.

> +
>  	if (unlikely(!pmd_trans_huge(pmd))) {
>  		pte_free(dst_mm, pgtable);
>  		goto out_unlock;
> @@ -1204,6 +1219,9 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
>  	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
>  		goto out_unlock;j
>  
> +	if (unlikely(!pmd_present(orig_pmd)))
> +		goto out_unlock;
> +
>  	page = pmd_page(orig_pmd);
>  	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
>  	/*
> @@ -1338,7 +1356,15 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>  	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
>  		goto out;
>  
> -	page = pmd_page(*pmd);
> +	if (is_pmd_migration_entry(*pmd)) {

Again, I don't think it's it's safe to check if pmd is migration entry
before checking if it's present.

> +		swp_entry_t entry;
> +
> +		entry = pmd_to_swp_entry(*pmd);
> +		page = pfn_to_page(swp_offset(entry));
> +		if (!is_migration_entry(entry))
> +			goto out;

I don't understand how it suppose to work.
You take swp_offset() of entry before checking if it's migration entry.
What's going on?

> +	} else
> +		page = pmd_page(*pmd);
>  	VM_BUG_ON_PAGE(!PageHead(page) && !is_zone_device_page(page), page);
>  	if (flags & FOLL_TOUCH)
>  		touch_pmd(vma, addr, pmd);
> @@ -1534,6 +1560,9 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  	if (is_huge_zero_pmd(orig_pmd))
>  		goto out;
>  
> +	if (unlikely(!pmd_present(orig_pmd)))
> +		goto out;
> +
>  	page = pmd_page(orig_pmd);
>  	/*
>  	 * If other processes are mapping this page, we couldn't discard
> @@ -1766,6 +1795,20 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	if (prot_numa && pmd_protnone(*pmd))
>  		goto unlock;
>  
> +	if (is_pmd_migration_entry(*pmd)) {
> +		swp_entry_t entry = pmd_to_swp_entry(*pmd);
> +
> +		if (is_write_migration_entry(entry)) {
> +			pmd_t newpmd;
> +
> +			make_migration_entry_read(&entry);
> +			newpmd = swp_entry_to_pmd(entry);
> +			set_pmd_at(mm, addr, pmd, newpmd);
> +		}
> +		goto unlock;
> +	} else if (!pmd_present(*pmd))
> +		WARN_ONCE(1, "Uknown non-present format on pmd.\n");

Another typo.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
