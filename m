Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A9A886B0255
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 05:40:54 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id p65so28402559wmp.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:40:54 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id d84si9725371wmc.17.2016.03.03.02.40.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 02:40:53 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id p65so28401985wmp.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:40:53 -0800 (PST)
Date: Thu, 3 Mar 2016 13:40:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v1 03/11] mm: thp: add helpers related to thp/pmd
 migration
Message-ID: <20160303104051.GB30948@node.shutemov.name>
References: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1456990918-30906-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456990918-30906-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Mar 03, 2016 at 04:41:50PM +0900, Naoya Horiguchi wrote:
> This patch prepares thp migration's core code. These code will be open when
> unmap_and_move() stops unconditionally splitting thp and get_new_page() starts
> to allocate destination thps.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  arch/x86/include/asm/pgtable.h    | 11 ++++++
>  arch/x86/include/asm/pgtable_64.h |  2 +
>  include/linux/swapops.h           | 62 +++++++++++++++++++++++++++++++
>  mm/huge_memory.c                  | 78 +++++++++++++++++++++++++++++++++++++++
>  mm/migrate.c                      | 23 ++++++++++++
>  5 files changed, 176 insertions(+)
> 
> diff --git v4.5-rc5-mmotm-2016-02-24-16-18/arch/x86/include/asm/pgtable.h v4.5-rc5-mmotm-2016-02-24-16-18_patched/arch/x86/include/asm/pgtable.h
> index 0687c47..0df9afe 100644
> --- v4.5-rc5-mmotm-2016-02-24-16-18/arch/x86/include/asm/pgtable.h
> +++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/arch/x86/include/asm/pgtable.h
> @@ -515,6 +515,17 @@ static inline int pmd_present(pmd_t pmd)
>  	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE);
>  }
>  
> +/*
> + * Unlike pmd_present(), __pmd_present() checks only _PAGE_PRESENT bit.
> + * Combined with is_migration_entry(), this routine is used to detect pmd
> + * migration entries. To make it work fine, callers should make sure that
> + * pmd_trans_huge() returns true beforehand.
> + */

Hm. I don't this this would fly. What pevents false positive for PROT_NONE
pmds?

I guess the problem is _PAGE_PSE, right? I don't really understand why we
need it in pmd_present().

Andrea?

> +static inline int __pmd_present(pmd_t pmd)
> +{
> +	return pmd_flags(pmd) & _PAGE_PRESENT;
> +}
> +
>  #ifdef CONFIG_NUMA_BALANCING
>  /*
>   * These work without NUMA balancing but the kernel does not care. See the
> diff --git v4.5-rc5-mmotm-2016-02-24-16-18/arch/x86/include/asm/pgtable_64.h v4.5-rc5-mmotm-2016-02-24-16-18_patched/arch/x86/include/asm/pgtable_64.h
> index 2ee7811..df869d0 100644
> --- v4.5-rc5-mmotm-2016-02-24-16-18/arch/x86/include/asm/pgtable_64.h
> +++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/arch/x86/include/asm/pgtable_64.h
> @@ -153,7 +153,9 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
>  					 ((type) << (_PAGE_BIT_PRESENT + 1)) \
>  					 | ((offset) << SWP_OFFSET_SHIFT) })
>  #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
> +#define __pmd_to_swp_entry(pte)		((swp_entry_t) { pmd_val((pmd)) })
>  #define __swp_entry_to_pte(x)		((pte_t) { .pte = (x).val })
> +#define __swp_entry_to_pmd(x)		((pmd_t) { .pmd = (x).val })
>  
>  extern int kern_addr_valid(unsigned long addr);
>  extern void cleanup_highmap(void);
> diff --git v4.5-rc5-mmotm-2016-02-24-16-18/include/linux/swapops.h v4.5-rc5-mmotm-2016-02-24-16-18_patched/include/linux/swapops.h
> index 5c3a5f3..b402a2c 100644
> --- v4.5-rc5-mmotm-2016-02-24-16-18/include/linux/swapops.h
> +++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/include/linux/swapops.h
> @@ -163,6 +163,68 @@ static inline int is_write_migration_entry(swp_entry_t entry)
>  
>  #endif
>  
> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> +extern int set_pmd_migration_entry(struct page *page,
> +		struct mm_struct *mm, unsigned long address);
> +
> +extern int remove_migration_pmd(struct page *new,
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
> +	return !__pmd_present(pmd) && is_migration_entry(pmd_to_swp_entry(pmd));
> +}
> +#else
> +static inline int set_pmd_migration_entry(struct page *page,
> +				struct mm_struct *mm, unsigned long address)
> +{
> +	return 0;
> +}
> +
> +static inline int remove_migration_pmd(struct page *new,
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
> diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/huge_memory.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/huge_memory.c
> index 46ad357..c6d5406 100644
> --- v4.5-rc5-mmotm-2016-02-24-16-18/mm/huge_memory.c
> +++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/huge_memory.c
> @@ -3657,3 +3657,81 @@ static int __init split_huge_pages_debugfs(void)
>  }
>  late_initcall(split_huge_pages_debugfs);
>  #endif
> +
> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> +int set_pmd_migration_entry(struct page *page, struct mm_struct *mm,
> +				unsigned long addr)
> +{
> +	pte_t *pte;
> +	pmd_t *pmd;
> +	pmd_t pmdval;
> +	pmd_t pmdswp;
> +	swp_entry_t entry;
> +	spinlock_t *ptl;
> +
> +	mmu_notifier_invalidate_range_start(mm, addr, addr + HPAGE_PMD_SIZE);
> +	if (!page_check_address_transhuge(page, mm, addr, &pmd, &pte, &ptl))
> +		goto out;
> +	if (pte)
> +		goto out;
> +	pmdval = pmdp_huge_get_and_clear(mm, addr, pmd);
> +	entry = make_migration_entry(page, pmd_write(pmdval));
> +	pmdswp = swp_entry_to_pmd(entry);
> +	pmdswp = pmd_mkhuge(pmdswp);
> +	set_pmd_at(mm, addr, pmd, pmdswp);
> +	page_remove_rmap(page, true);
> +	page_cache_release(page);
> +	spin_unlock(ptl);
> +out:
> +	mmu_notifier_invalidate_range_end(mm, addr, addr + HPAGE_PMD_SIZE);
> +	return SWAP_AGAIN;
> +}
> +
> +int remove_migration_pmd(struct page *new, struct vm_area_struct *vma,
> +			unsigned long addr, void *old)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	spinlock_t *ptl;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pmd_t pmde;
> +	swp_entry_t entry;
> +	unsigned long mmun_start = addr & HPAGE_PMD_MASK;
> +	unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
> +
> +	pgd = pgd_offset(mm, addr);
> +	if (!pgd_present(*pgd))
> +		goto out;
> +	pud = pud_offset(pgd, addr);
> +	if (!pud_present(*pud))
> +		goto out;
> +	pmd = pmd_offset(pud, addr);
> +	if (!pmd)
> +		goto out;
> +	ptl = pmd_lock(mm, pmd);
> +	pmde = *pmd;
> +	barrier();

Do we need a barrier under ptl?

> +	if (!is_pmd_migration_entry(pmde))
> +		goto unlock_ptl;
> +	entry = pmd_to_swp_entry(pmde);
> +	if (migration_entry_to_page(entry) != old)
> +		goto unlock_ptl;
> +	get_page(new);
> +	pmde = mk_huge_pmd(new, vma->vm_page_prot);
> +	if (is_write_migration_entry(entry))
> +		pmde = maybe_pmd_mkwrite(pmde, vma);
> +	flush_cache_range(vma, mmun_start, mmun_end);
> +	page_add_anon_rmap(new, vma, mmun_start, true);
> +	pmdp_huge_clear_flush_notify(vma, mmun_start, pmd);
> +	set_pmd_at(mm, mmun_start, pmd, pmde);
> +	flush_tlb_range(vma, mmun_start, mmun_end);
> +	if (vma->vm_flags & VM_LOCKED)
> +		mlock_vma_page(new);
> +	update_mmu_cache_pmd(vma, addr, pmd);
> +unlock_ptl:
> +	spin_unlock(ptl);
> +out:
> +	return SWAP_AGAIN;
> +}
> +#endif
> diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/migrate.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/migrate.c
> index 577c94b..14164f6 100644
> --- v4.5-rc5-mmotm-2016-02-24-16-18/mm/migrate.c
> +++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/migrate.c
> @@ -118,6 +118,8 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
>  		if (!ptep)
>  			goto out;
>  		ptl = huge_pte_lockptr(hstate_vma(vma), mm, ptep);
> +	} else if (PageTransHuge(new)) {
> +		return remove_migration_pmd(new, vma, addr, old);

Hm. THP now can be mapped with PTEs too..

>  	} else {
>  		pmd = mm_find_pmd(mm, addr);
>  		if (!pmd)
> @@ -252,6 +254,27 @@ void migration_entry_wait_huge(struct vm_area_struct *vma,
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
> -- 
> 2.7.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
