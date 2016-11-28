Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9566B0261
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:35:32 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g23so37581549wme.4
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:35:32 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id wj9si54790279wjb.8.2016.11.28.06.35.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 06:35:31 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id m203so19288365wma.3
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:35:30 -0800 (PST)
Date: Mon, 28 Nov 2016 15:35:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 07/12] mm: thp: check pmd migration entry in common
 path
Message-ID: <20161128143528.GP14788@dhcp22.suse.cz>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-8-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478561517-4317-8-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue 08-11-16 08:31:52, Naoya Horiguchi wrote:
> If one of callers of page migration starts to handle thp, memory management code
> start to see pmd migration entry, so we need to prepare for it before enabling.
> This patch changes various code point which checks the status of given pmds in
> order to prevent race between thp migration and the pmd-related works.

Please be much more verbose about which code paths those are and why do
we care. The above wording didn't really help me to understand both the
problem and the solution until I started to stare into the code. And
even then I am not sure how to know that all places have been handled
properly.

> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
> ChangeLog v1 -> v2:
> - introduce pmd_related() (I know the naming is not good, but can't think up
>   no better name. Any suggesntion is welcomed.)
> ---
>  arch/x86/mm/gup.c       |  4 +--
>  fs/proc/task_mmu.c      | 23 +++++++------
>  include/linux/huge_mm.h |  9 ++++-
>  mm/gup.c                | 10 ++++--
>  mm/huge_memory.c        | 88 ++++++++++++++++++++++++++++++++++++++++---------
>  mm/madvise.c            |  2 +-
>  mm/memcontrol.c         |  2 ++
>  mm/memory.c             |  6 +++-
>  mm/mprotect.c           |  2 ++
>  mm/mremap.c             |  2 +-
>  10 files changed, 114 insertions(+), 34 deletions(-)
> 
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/mm/gup.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/mm/gup.c
> index 0d4fb3e..78a153d 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/mm/gup.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/mm/gup.c
> @@ -222,9 +222,9 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
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
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/fs/proc/task_mmu.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/fs/proc/task_mmu.c
> index 35b92d8..c1f9cf4 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/fs/proc/task_mmu.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/fs/proc/task_mmu.c
> @@ -596,7 +596,8 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  
>  	ptl = pmd_trans_huge_lock(pmd, vma);
>  	if (ptl) {
> -		smaps_pmd_entry(pmd, addr, walk);
> +		if (pmd_present(*pmd))
> +			smaps_pmd_entry(pmd, addr, walk);
>  		spin_unlock(ptl);
>  		return 0;
>  	}
> @@ -929,6 +930,9 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
>  			goto out;
>  		}
>  
> +		if (!pmd_present(*pmd))
> +			goto out;
> +
>  		page = pmd_page(*pmd);
>  
>  		/* Clear accessed and referenced bits. */
> @@ -1208,19 +1212,18 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
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
> -
> +		if (is_pmd_migration_entry(pmd)) {
> +			swp_entry_t entry = pmd_to_swp_entry(pmd);
> +			frame = swp_type(entry) |
> +				(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
> +			page = migration_entry_to_page(entry);
> +		} else if (pmd_present(pmd)) {
> +			page = pmd_page(pmd);
>  			if (page_mapcount(page) == 1)
>  				flags |= PM_MMAP_EXCLUSIVE;
>  
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/include/linux/huge_mm.h v4.9-rc2-mmotm-2016-10-27-18-27_patched/include/linux/huge_mm.h
> index fcbca51..3c252cd 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/include/linux/huge_mm.h
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/include/linux/huge_mm.h
> @@ -125,12 +125,19 @@ extern void vma_adjust_trans_huge(struct vm_area_struct *vma,
>  				    long adjust_next);
>  extern spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd,
>  		struct vm_area_struct *vma);
> +
> +static inline int pmd_related(pmd_t pmd)
> +{
> +	return !pmd_none(pmd) &&
> +		(!pmd_present(pmd) || pmd_trans_huge(pmd) || pmd_devmap(pmd));
> +}
> +
>  /* mmap_sem must be held on entry */
>  static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
>  		struct vm_area_struct *vma)
>  {
>  	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
> -	if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
> +	if (pmd_related(*pmd))
>  		return __pmd_trans_huge_lock(pmd, vma);
>  	else
>  		return NULL;
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/gup.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/gup.c
> index e50178c..2dc4978 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/gup.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/gup.c
> @@ -267,6 +267,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
>  	}
>  	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
>  		return no_page_table(vma, flags);
> +	if (!pmd_present(*pmd))
> +		return no_page_table(vma, flags);
>  	if (pmd_devmap(*pmd)) {
>  		ptl = pmd_lock(mm, pmd);
>  		page = follow_devmap_pmd(vma, address, pmd, flags);
> @@ -278,6 +280,10 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
>  		return follow_page_pte(vma, address, pmd, flags);
>  
>  	ptl = pmd_lock(mm, pmd);
> +	if (unlikely(!pmd_present(*pmd))) {
> +		spin_unlock(ptl);
> +		return no_page_table(vma, flags);
> +	}
>  	if (unlikely(!pmd_trans_huge(*pmd))) {
>  		spin_unlock(ptl);
>  		return follow_page_pte(vma, address, pmd, flags);
> @@ -333,7 +339,7 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
>  	pud = pud_offset(pgd, address);
>  	BUG_ON(pud_none(*pud));
>  	pmd = pmd_offset(pud, address);
> -	if (pmd_none(*pmd))
> +	if (!pmd_present(*pmd))
>  		return -EFAULT;
>  	VM_BUG_ON(pmd_trans_huge(*pmd));
>  	pte = pte_offset_map(pmd, address);
> @@ -1357,7 +1363,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
>  		pmd_t pmd = READ_ONCE(*pmdp);
>  
>  		next = pmd_addr_end(addr, end);
> -		if (pmd_none(pmd))
> +		if (!pmd_present(pmd))
>  			return 0;
>  
>  		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/huge_memory.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/huge_memory.c
> index b3022b3..4e9090c 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/huge_memory.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/huge_memory.c
> @@ -825,6 +825,20 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  
>  	ret = -EAGAIN;
>  	pmd = *src_pmd;
> +
> +	if (unlikely(is_pmd_migration_entry(pmd))) {
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
> +
>  	if (unlikely(!pmd_trans_huge(pmd))) {
>  		pte_free(dst_mm, pgtable);
>  		goto out_unlock;
> @@ -1013,6 +1027,9 @@ int do_huge_pmd_wp_page(struct fault_env *fe, pmd_t orig_pmd)
>  	if (unlikely(!pmd_same(*fe->pmd, orig_pmd)))
>  		goto out_unlock;
>  
> +	if (unlikely(!pmd_present(orig_pmd)))
> +		goto out_unlock;
> +
>  	page = pmd_page(orig_pmd);
>  	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
>  	/*
> @@ -1137,7 +1154,14 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>  	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
>  		goto out;
>  
> -	page = pmd_page(*pmd);
> +	if (is_pmd_migration_entry(*pmd)) {
> +		swp_entry_t entry;
> +		entry = pmd_to_swp_entry(*pmd);
> +		page = pfn_to_page(swp_offset(entry));
> +		if (!is_migration_entry(entry))
> +			goto out;
> +	} else
> +		page = pmd_page(*pmd);
>  	VM_BUG_ON_PAGE(!PageHead(page) && !is_zone_device_page(page), page);
>  	if (flags & FOLL_TOUCH)
>  		touch_pmd(vma, addr, pmd);
> @@ -1332,6 +1356,9 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  	if (is_huge_zero_pmd(orig_pmd))
>  		goto out;
>  
> +	if (unlikely(!pmd_present(orig_pmd)))
> +		goto out;
> +
>  	page = pmd_page(orig_pmd);
>  	/*
>  	 * If other processes are mapping this page, we couldn't discard
> @@ -1410,20 +1437,35 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
>  	} else {
>  		struct page *page = pmd_page(orig_pmd);
> -		page_remove_rmap(page, true);
> -		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
> -		VM_BUG_ON_PAGE(!PageHead(page), page);
> -		if (PageAnon(page)) {
> -			pgtable_t pgtable;
> -			pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
> -			pte_free(tlb->mm, pgtable);
> -			atomic_long_dec(&tlb->mm->nr_ptes);
> -			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
> +		int migration = 0;
> +
> +		if (!is_pmd_migration_entry(orig_pmd)) {
> +			page_remove_rmap(page, true);
> +			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
> +			VM_BUG_ON_PAGE(!PageHead(page), page);
> +			if (PageAnon(page)) {
> +				pgtable_t pgtable;
> +				pgtable = pgtable_trans_huge_withdraw(tlb->mm,
> +								      pmd);
> +				pte_free(tlb->mm, pgtable);
> +				atomic_long_dec(&tlb->mm->nr_ptes);
> +				add_mm_counter(tlb->mm, MM_ANONPAGES,
> +					       -HPAGE_PMD_NR);
> +			} else {
> +				add_mm_counter(tlb->mm, MM_FILEPAGES,
> +					       -HPAGE_PMD_NR);
> +			}
>  		} else {
> -			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
> +			swp_entry_t entry;
> +
> +			entry = pmd_to_swp_entry(orig_pmd);
> +			free_swap_and_cache(entry); /* waring in failure? */
> +			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
> +			migration = 1;
>  		}
>  		spin_unlock(ptl);
> -		tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
> +		if (!migration)
> +			tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
>  	}
>  	return 1;
>  }
> @@ -1496,14 +1538,27 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  		bool preserve_write = prot_numa && pmd_write(*pmd);
>  		ret = 1;
>  
> +		if (!pmd_present(*pmd))
> +			goto unlock;
>  		/*
>  		 * Avoid trapping faults against the zero page. The read-only
>  		 * data is likely to be read-cached on the local CPU and
>  		 * local/remote hits to the zero page are not interesting.
>  		 */
> -		if (prot_numa && is_huge_zero_pmd(*pmd)) {
> -			spin_unlock(ptl);
> -			return ret;
> +		if (prot_numa && is_huge_zero_pmd(*pmd))
> +			goto unlock;
> +
> +		if (is_pmd_migration_entry(*pmd)) {
> +			swp_entry_t entry = pmd_to_swp_entry(*pmd);
> +
> +			if (is_write_migration_entry(entry)) {
> +				pmd_t newpmd;
> +
> +				make_migration_entry_read(&entry);
> +				newpmd = swp_entry_to_pmd(entry);
> +				set_pmd_at(mm, addr, pmd, newpmd);
> +			}
> +			goto unlock;
>  		}
>  
>  		if (!prot_numa || !pmd_protnone(*pmd)) {
> @@ -1516,6 +1571,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  			BUG_ON(vma_is_anonymous(vma) && !preserve_write &&
>  					pmd_write(entry));
>  		}
> +unlock:
>  		spin_unlock(ptl);
>  	}
>  
> @@ -1532,7 +1588,7 @@ spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
>  {
>  	spinlock_t *ptl;
>  	ptl = pmd_lock(vma->vm_mm, pmd);
> -	if (likely(pmd_trans_huge(*pmd) || pmd_devmap(*pmd)))
> +	if (likely(pmd_related(*pmd)))
>  		return ptl;
>  	spin_unlock(ptl);
>  	return NULL;
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/madvise.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/madvise.c
> index 0e3828e..eaa2b02 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/madvise.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/madvise.c
> @@ -274,7 +274,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  	unsigned long next;
>  
>  	next = pmd_addr_end(addr, end);
> -	if (pmd_trans_huge(*pmd))
> +	if (pmd_related(*pmd))
>  		if (madvise_free_huge_pmd(tlb, vma, pmd, addr, next))
>  			goto next;
>  
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/memcontrol.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memcontrol.c
> index 91dfc7c..ebc2c42 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/memcontrol.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memcontrol.c
> @@ -4635,6 +4635,8 @@ static enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
>  	struct page *page = NULL;
>  	enum mc_target_type ret = MC_TARGET_NONE;
>  
> +	if (unlikely(!pmd_present(pmd)))
> +		return ret;
>  	page = pmd_page(pmd);
>  	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
>  	if (!(mc.flags & MOVE_ANON))
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/memory.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memory.c
> index 94b5e2c..33fa439 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/memory.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memory.c
> @@ -999,7 +999,7 @@ static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src
>  	src_pmd = pmd_offset(src_pud, addr);
>  	do {
>  		next = pmd_addr_end(addr, end);
> -		if (pmd_trans_huge(*src_pmd) || pmd_devmap(*src_pmd)) {
> +		if (pmd_related(*src_pmd)) {
>  			int err;
>  			VM_BUG_ON(next-addr != HPAGE_PMD_SIZE);
>  			err = copy_huge_pmd(dst_mm, src_mm,
> @@ -3591,6 +3591,10 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>  		int ret;
>  
>  		barrier();
> +		if (unlikely(is_pmd_migration_entry(orig_pmd))) {
> +			pmd_migration_entry_wait(mm, fe.pmd);
> +			return 0;
> +		}
>  		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
>  			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
>  				return do_huge_pmd_numa_page(&fe, orig_pmd);
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/mprotect.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/mprotect.c
> index c5ba2aa..81186e3 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/mprotect.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/mprotect.c
> @@ -164,6 +164,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  		unsigned long this_pages;
>  
>  		next = pmd_addr_end(addr, end);
> +		if (!pmd_present(*pmd))
> +			continue;
>  		if (!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)
>  				&& pmd_none_or_clear_bad(pmd))
>  			continue;
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/mremap.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/mremap.c
> index da22ad2..a94a698 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/mremap.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/mremap.c
> @@ -194,7 +194,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  		new_pmd = alloc_new_pmd(vma->vm_mm, vma, new_addr);
>  		if (!new_pmd)
>  			break;
> -		if (pmd_trans_huge(*old_pmd)) {
> +		if (pmd_related(*old_pmd)) {
>  			if (extent == HPAGE_PMD_SIZE) {
>  				bool moved;
>  				/* See comment in move_ptes() */
> -- 
> 2.7.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
