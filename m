Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFB036B0266
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:31:35 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id xy5so20945540wjc.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:31:35 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id s5si26042288wma.130.2016.11.28.06.31.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 06:31:34 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id g23so19343439wme.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:31:34 -0800 (PST)
Date: Mon, 28 Nov 2016 15:31:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 05/12] mm: thp: add core routines for thp/pmd migration
Message-ID: <20161128143132.GN14788@dhcp22.suse.cz>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-6-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478561517-4317-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue 08-11-16 08:31:50, Naoya Horiguchi wrote:
> This patch prepares thp migration's core code. These code will be open when
> unmap_and_move() stops unconditionally splitting thp and get_new_page() starts
> to allocate destination thps.

this description is underdocumented to say the least. Could you
provide a high level documentation here please?

> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
> ChangeLog v1 -> v2:
> - support pte-mapped thp, doubly-mapped thp
> ---
>  arch/x86/include/asm/pgtable_64.h |   2 +
>  include/linux/swapops.h           |  61 +++++++++++++++
>  mm/huge_memory.c                  | 154 ++++++++++++++++++++++++++++++++++++++
>  mm/migrate.c                      |  44 ++++++++++-
>  mm/pgtable-generic.c              |   3 +-
>  5 files changed, 262 insertions(+), 2 deletions(-)
> 
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/include/asm/pgtable_64.h v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/include/asm/pgtable_64.h
> index 1cc82ec..3a1b48e 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/include/asm/pgtable_64.h
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/include/asm/pgtable_64.h
> @@ -167,7 +167,9 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
>  					 ((type) << (SWP_TYPE_FIRST_BIT)) \
>  					 | ((offset) << SWP_OFFSET_FIRST_BIT) })
>  #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
> +#define __pmd_to_swp_entry(pte)		((swp_entry_t) { pmd_val((pmd)) })
>  #define __swp_entry_to_pte(x)		((pte_t) { .pte = (x).val })
> +#define __swp_entry_to_pmd(x)		((pmd_t) { .pmd = (x).val })
>  
>  extern int kern_addr_valid(unsigned long addr);
>  extern void cleanup_highmap(void);
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/include/linux/swapops.h v4.9-rc2-mmotm-2016-10-27-18-27_patched/include/linux/swapops.h
> index 5c3a5f3..b6b22a2 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/include/linux/swapops.h
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/include/linux/swapops.h
> @@ -163,6 +163,67 @@ static inline int is_write_migration_entry(swp_entry_t entry)
>  
>  #endif
>  
> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> +extern void set_pmd_migration_entry(struct page *page,
> +		struct vm_area_struct *vma, unsigned long address);
> +
> +extern int remove_migration_pmd(struct page *new, pmd_t *pmd,
> +		struct vm_area_struct *vma, unsigned long addr, void *old);
> +
> +extern void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd);
> +
> +static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
> +{
> +	swp_entry_t arch_entry;
> +
> +	arch_entry = __pmd_to_swp_entry(pmd);
> +	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
> +}
> +
> +static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
> +{
> +	swp_entry_t arch_entry;
> +
> +	arch_entry = __swp_entry(swp_type(entry), swp_offset(entry));
> +	return __swp_entry_to_pmd(arch_entry);
> +}
> +
> +static inline int is_pmd_migration_entry(pmd_t pmd)
> +{
> +	return !pmd_present(pmd) && is_migration_entry(pmd_to_swp_entry(pmd));
> +}
> +#else
> +static inline void set_pmd_migration_entry(struct page *page,
> +			struct vm_area_struct *vma, unsigned long address)
> +{
> +}
> +
> +static inline int remove_migration_pmd(struct page *new, pmd_t *pmd,
> +		struct vm_area_struct *vma, unsigned long addr, void *old)
> +{
> +	return 0;
> +}
> +
> +static inline void pmd_migration_entry_wait(struct mm_struct *m, pmd_t *p) { }
> +
> +static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
> +{
> +	return swp_entry(0, 0);
> +}
> +
> +static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
> +{
> +	pmd_t pmd = {};
> +
> +	return pmd;
> +}
> +
> +static inline int is_pmd_migration_entry(pmd_t pmd)
> +{
> +	return 0;
> +}
> +#endif
> +
>  #ifdef CONFIG_MEMORY_FAILURE
>  
>  extern atomic_long_t num_poisoned_pages __read_mostly;
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/huge_memory.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/huge_memory.c
> index 0509d17..b3022b3 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/huge_memory.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/huge_memory.c
> @@ -2310,3 +2310,157 @@ static int __init split_huge_pages_debugfs(void)
>  }
>  late_initcall(split_huge_pages_debugfs);
>  #endif
> +
> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> +void set_pmd_migration_entry(struct page *page, struct vm_area_struct *vma,
> +				unsigned long addr)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pmd_t pmdval;
> +	swp_entry_t entry;
> +	spinlock_t *ptl;
> +
> +	pgd = pgd_offset(mm, addr);
> +	if (!pgd_present(*pgd))
> +		return;
> +	pud = pud_offset(pgd, addr);
> +	if (!pud_present(*pud))
> +		return;
> +	pmd = pmd_offset(pud, addr);
> +	pmdval = *pmd;
> +	barrier();
> +	if (!pmd_present(pmdval))
> +		return;
> +
> +	mmu_notifier_invalidate_range_start(mm, addr, addr + HPAGE_PMD_SIZE);
> +	if (pmd_trans_huge(pmdval)) {
> +		pmd_t pmdswp;
> +
> +		ptl = pmd_lock(mm, pmd);
> +		if (!pmd_present(*pmd))
> +			goto unlock_pmd;
> +		if (unlikely(!pmd_trans_huge(*pmd)))
> +			goto unlock_pmd;
> +		if (pmd_page(*pmd) != page)
> +			goto unlock_pmd;
> +
> +		pmdval = pmdp_huge_get_and_clear(mm, addr, pmd);
> +		if (pmd_dirty(pmdval))
> +			set_page_dirty(page);
> +		entry = make_migration_entry(page, pmd_write(pmdval));
> +		pmdswp = swp_entry_to_pmd(entry);
> +		pmdswp = pmd_mkhuge(pmdswp);
> +		set_pmd_at(mm, addr, pmd, pmdswp);
> +		page_remove_rmap(page, true);
> +		put_page(page);
> +unlock_pmd:
> +		spin_unlock(ptl);
> +	} else { /* pte-mapped thp */
> +		pte_t *pte;
> +		pte_t pteval;
> +		struct page *tmp = compound_head(page);
> +		unsigned long address = addr & HPAGE_PMD_MASK;
> +		pte_t swp_pte;
> +		int i;
> +
> +		pte = pte_offset_map(pmd, address);
> +		ptl = pte_lockptr(mm, pmd);
> +		spin_lock(ptl);
> +		for (i = 0; i < HPAGE_PMD_NR; i++, pte++, tmp++) {
> +			if (!(pte_present(*pte) &&
> +			      page_to_pfn(tmp) == pte_pfn(*pte)))
> +				continue;
> +			pteval = ptep_clear_flush(vma, address, pte);
> +			if (pte_dirty(pteval))
> +				set_page_dirty(tmp);
> +			entry = make_migration_entry(tmp, pte_write(pteval));
> +			swp_pte = swp_entry_to_pte(entry);
> +			set_pte_at(mm, address, pte, swp_pte);
> +			page_remove_rmap(tmp, false);
> +			put_page(tmp);
> +		}
> +		pte_unmap_unlock(pte, ptl);
> +	}
> +	mmu_notifier_invalidate_range_end(mm, addr, addr + HPAGE_PMD_SIZE);
> +	return;
> +}
> +
> +int remove_migration_pmd(struct page *new, pmd_t *pmd,
> +		struct vm_area_struct *vma, unsigned long addr, void *old)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	spinlock_t *ptl;
> +	pmd_t pmde;
> +	swp_entry_t entry;
> +
> +	pmde = *pmd;
> +	barrier();
> +
> +	if (!pmd_present(pmde)) {
> +		if (is_migration_entry(pmd_to_swp_entry(pmde))) {
> +			unsigned long mmun_start = addr & HPAGE_PMD_MASK;
> +			unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
> +
> +			ptl = pmd_lock(mm, pmd);
> +			entry = pmd_to_swp_entry(*pmd);
> +			if (migration_entry_to_page(entry) != old)
> +				goto unlock_ptl;
> +			get_page(new);
> +			pmde = pmd_mkold(mk_huge_pmd(new, vma->vm_page_prot));
> +			if (is_write_migration_entry(entry))
> +				pmde = maybe_pmd_mkwrite(pmde, vma);
> +			flush_cache_range(vma, mmun_start, mmun_end);
> +			page_add_anon_rmap(new, vma, mmun_start, true);
> +			pmdp_huge_clear_flush_notify(vma, mmun_start, pmd);
> +			set_pmd_at(mm, mmun_start, pmd, pmde);
> +			flush_tlb_range(vma, mmun_start, mmun_end);
> +			if (vma->vm_flags & VM_LOCKED)
> +				mlock_vma_page(new);
> +			update_mmu_cache_pmd(vma, addr, pmd);
> +unlock_ptl:
> +			spin_unlock(ptl);
> +		}
> +	} else { /* pte-mapped thp */
> +		pte_t *ptep;
> +		pte_t pte;
> +		int i;
> +		struct page *tmpnew = compound_head(new);
> +		struct page *tmpold = compound_head((struct page *)old);
> +		unsigned long address = addr & HPAGE_PMD_MASK;
> +
> +		ptep = pte_offset_map(pmd, addr);
> +		ptl = pte_lockptr(mm, pmd);
> +		spin_lock(ptl);
> +
> +		for (i = 0; i < HPAGE_PMD_NR;
> +		     i++, ptep++, tmpnew++, tmpold++, address += PAGE_SIZE) {
> +			pte = *ptep;
> +			if (!is_swap_pte(pte))
> +				continue;
> +			entry = pte_to_swp_entry(pte);
> +			if (!is_migration_entry(entry) ||
> +			    migration_entry_to_page(entry) != tmpold)
> +				continue;
> +			get_page(tmpnew);
> +			pte = pte_mkold(mk_pte(tmpnew,
> +					       READ_ONCE(vma->vm_page_prot)));
> +			if (pte_swp_soft_dirty(*ptep))
> +				pte = pte_mksoft_dirty(pte);
> +			if (is_write_migration_entry(entry))
> +				pte = maybe_mkwrite(pte, vma);
> +			flush_dcache_page(tmpnew);
> +			set_pte_at(mm, address, ptep, pte);
> +			if (PageAnon(new))
> +				page_add_anon_rmap(tmpnew, vma, address, false);
> +			else
> +				page_add_file_rmap(tmpnew, false);
> +			update_mmu_cache(vma, address, ptep);
> +		}
> +		pte_unmap_unlock(ptep, ptl);
> +	}
> +	return SWAP_AGAIN;
> +}
> +#endif
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/migrate.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/migrate.c
> index 66ce6b4..54f2eb6 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/migrate.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/migrate.c
> @@ -198,6 +198,8 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	swp_entry_t entry;
> +	pgd_t *pgd;
> +	pud_t *pud;
>   	pmd_t *pmd;
>  	pte_t *ptep, pte;
>   	spinlock_t *ptl;
> @@ -208,10 +210,29 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
>  			goto out;
>  		ptl = huge_pte_lockptr(hstate_vma(vma), mm, ptep);
>  	} else {
> -		pmd = mm_find_pmd(mm, addr);
> +		pmd_t pmde;
> +
> +		pgd = pgd_offset(mm, addr);
> +		if (!pgd_present(*pgd))
> +			goto out;
> +		pud = pud_offset(pgd, addr);
> +		if (!pud_present(*pud))
> +			goto out;
> +		pmd = pmd_offset(pud, addr);
>  		if (!pmd)
>  			goto out;
>  
> +		if (PageTransCompound(new)) {
> +			remove_migration_pmd(new, pmd, vma, addr, old);
> +			goto out;
> +		}
> +
> +		pmde = *pmd;
> +		barrier();
> +
> +		if (!pmd_present(pmde) || pmd_trans_huge(pmde))
> +			goto out;
> +
>  		ptep = pte_offset_map(pmd, addr);
>  
>  		/*
> @@ -344,6 +365,27 @@ void migration_entry_wait_huge(struct vm_area_struct *vma,
>  	__migration_entry_wait(mm, pte, ptl);
>  }
>  
> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> +void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd)
> +{
> +	spinlock_t *ptl;
> +	struct page *page;
> +
> +	ptl = pmd_lock(mm, pmd);
> +	if (!is_pmd_migration_entry(*pmd))
> +		goto unlock;
> +	page = migration_entry_to_page(pmd_to_swp_entry(*pmd));
> +	if (!get_page_unless_zero(page))
> +		goto unlock;
> +	spin_unlock(ptl);
> +	wait_on_page_locked(page);
> +	put_page(page);
> +	return;
> +unlock:
> +	spin_unlock(ptl);
> +}
> +#endif
> +
>  #ifdef CONFIG_BLOCK
>  /* Returns true if all buffers are successfully locked */
>  static bool buffer_migrate_lock_buffers(struct buffer_head *head,
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/pgtable-generic.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/pgtable-generic.c
> index 71c5f91..6012343 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/pgtable-generic.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/pgtable-generic.c
> @@ -118,7 +118,8 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
>  {
>  	pmd_t pmd;
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> -	VM_BUG_ON(!pmd_trans_huge(*pmdp) && !pmd_devmap(*pmdp));
> +	VM_BUG_ON(pmd_present(*pmdp) && !pmd_trans_huge(*pmdp) &&
> +		  !pmd_devmap(*pmdp));
>  	pmd = pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
>  	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
>  	return pmd;
> -- 
> 2.7.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
