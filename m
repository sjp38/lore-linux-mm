Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E51BF6B0397
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 02:18:31 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f13so7971716wrf.3
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 23:18:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 71si1054565wmo.0.2017.04.20.23.18.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 23:18:30 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3L6EFcM081547
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 02:18:29 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29xur5k01t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 02:18:28 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 21 Apr 2017 16:18:07 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3L6Hugi5570918
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 16:18:04 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3L6HU5J024897
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 16:17:31 +1000
Subject: Re: [PATCH v5 06/11] mm: thp: check pmd migration entry in common
 path
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-7-zi.yan@sent.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 21 Apr 2017 11:47:12 +0530
MIME-Version: 1.0
In-Reply-To: <20170420204752.79703-7-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <edb7c113-4c25-4e5b-9182-594c002cbf93@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

On 04/21/2017 02:17 AM, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
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
> - pmd_none_or_trans_huge_or_clear_bad() and pmd_trans_unstable() return
>   true on pmd_migration_entry, so that migration entries are not
>   treated as pmd page table entries.
> 
> ChangeLog v4 -> v5:
> - add explanation in pmd_none_or_trans_huge_or_clear_bad() to state
>   the equivalence of !pmd_present() and is_pmd_migration_entry()
> - fix migration entry wait deadlock code (from v1) in follow_page_mask()
> - remove unnecessary code (from v1) in follow_trans_huge_pmd()
> - use is_swap_pmd() instead of !pmd_present() for pmd migration entry,
>   so it will not be confused with pmd_none()
> - change author information
> 
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  arch/x86/mm/gup.c             |  7 +++--
>  fs/proc/task_mmu.c            | 30 +++++++++++++--------
>  include/asm-generic/pgtable.h | 17 +++++++++++-
>  include/linux/huge_mm.h       | 14 ++++++++--
>  mm/gup.c                      | 22 ++++++++++++++--
>  mm/huge_memory.c              | 61 ++++++++++++++++++++++++++++++++++++++-----
>  mm/memcontrol.c               |  5 ++++
>  mm/memory.c                   | 12 +++++++--
>  mm/mprotect.c                 |  4 +--
>  mm/mremap.c                   |  2 +-
>  10 files changed, 145 insertions(+), 29 deletions(-)
> 
> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> index 456dfdfd2249..096bbcc801e6 100644
> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -9,6 +9,7 @@
>  #include <linux/vmstat.h>
>  #include <linux/highmem.h>
>  #include <linux/swap.h>
> +#include <linux/swapops.h>
>  #include <linux/memremap.h>
>  
>  #include <asm/mmu_context.h>
> @@ -243,9 +244,11 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
>  		pmd_t pmd = *pmdp;
>  
>  		next = pmd_addr_end(addr, end);
> -		if (pmd_none(pmd))
> +		if (!pmd_present(pmd)) {
> +			VM_BUG_ON(is_swap_pmd(pmd) && IS_ENABLED(CONFIG_MIGRATION) &&
> +					  !is_pmd_migration_entry(pmd));
>  			return 0;
> -		if (unlikely(pmd_large(pmd) || !pmd_present(pmd))) {
> +		} else if (unlikely(pmd_large(pmd))) {
>  			/*
>  			 * NUMA hinting faults need to be handled in the GUP
>  			 * slowpath for accounting purposes and so that they
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 5c8359704601..57489dcd71c4 100644
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

These pmd_present() checks should have been done irrespective of the
presence of new PMD migration entries. Please separate them out in a
different clean up patch.
 
>  		page = pmd_page(*pmd);
>  
>  		/* Clear accessed and referenced bits. */
> @@ -1221,28 +1225,32 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
>  	if (ptl) {
>  		u64 flags = 0, frame = 0;
>  		pmd_t pmd = *pmdp;
> +		struct page *page = NULL;
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
>  		if (pmd_present(pmd)) {
> -			struct page *page = pmd_page(pmd);
> -
> -			if (page_mapcount(page) == 1)
> -				flags |= PM_MMAP_EXCLUSIVE;
> +			page = pmd_page(pmd);
>  
>  			flags |= PM_PRESENT;
>  			if (pm->show_pfn)
>  				frame = pmd_pfn(pmd) +
>  					((addr & ~PMD_MASK) >> PAGE_SHIFT);
> +		} else if (is_swap_pmd(pmd)) {
> +			swp_entry_t entry = pmd_to_swp_entry(pmd);
> +
> +			frame = swp_type(entry) |
> +				(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
> +			flags |= PM_SWAP;
> +			VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
> +					  !is_pmd_migration_entry(pmd));
> +			page = migration_entry_to_page(entry);
>  		}
>  
> +		if (page && page_mapcount(page) == 1)
> +			flags |= PM_MMAP_EXCLUSIVE;
> +

Yeah, this makes sense. It discovers the page details in case its
a migration PMD entry which never existed before.

>  		for (; addr != end; addr += PAGE_SIZE) {
>  			pagemap_entry_t pme = make_pme(frame, flags);
>  
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 1fad160f35de..23bf18116df4 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -809,7 +809,22 @@ static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  	barrier();
>  #endif
> -	if (pmd_none(pmdval) || pmd_trans_huge(pmdval))
> +	/*
> +	 * !pmd_present() checks for pmd migration entries
> +	 *
> +	 * The complete check uses is_pmd_migration_entry() in linux/swapops.h
> +	 * But using that requires moving current function and pmd_trans_unstable()
> +	 * to linux/swapops.h to resovle dependency, which is too much code move.
> +	 *
> +	 * !pmd_present() is equivalent to is_pmd_migration_entry() currently,
> +	 * because !pmd_present() pages can only be under migration not swapped
> +	 * out.
> +	 *
> +	 * pmd_none() is preseved for future condition checks on pmd migration
> +	 * entries and not confusing with this function name, although it is
> +	 * redundant with !pmd_present().
> +	 */
> +	if (pmd_none(pmdval) || pmd_trans_huge(pmdval) || !pmd_present(pmdval))
>  		return 1;
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
> index 4039ec2993d3..b24c7d10aced 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -278,6 +278,16 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
>  			return page;
>  		return no_page_table(vma, flags);
>  	}
> +retry:
> +	if (!pmd_present(*pmd)) {
> +		if (likely(!(flags & FOLL_MIGRATION)))
> +			return no_page_table(vma, flags);
> +		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
> +				  !is_pmd_migration_entry(*pmd));
> +		if (is_pmd_migration_entry(*pmd))
> +			pmd_migration_entry_wait(mm, pmd);
> +		goto retry;
> +	}
>  	if (pmd_devmap(*pmd)) {
>  		ptl = pmd_lock(mm, pmd);
>  		page = follow_devmap_pmd(vma, address, pmd, flags);
> @@ -291,7 +301,15 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
>  	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
>  		return no_page_table(vma, flags);
>  
> +retry_locked:
>  	ptl = pmd_lock(mm, pmd);
> +	if (unlikely(!pmd_present(*pmd))) {
> +		spin_unlock(ptl);
> +		if (likely(!(flags & FOLL_MIGRATION)))
> +			return no_page_table(vma, flags);
> +		pmd_migration_entry_wait(mm, pmd);
> +		goto retry_locked;
> +	}
>  	if (unlikely(!pmd_trans_huge(*pmd))) {
>  		spin_unlock(ptl);
>  		return follow_page_pte(vma, address, pmd, flags);
> @@ -350,7 +368,7 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
>  	pud = pud_offset(p4d, address);
>  	BUG_ON(pud_none(*pud));
>  	pmd = pmd_offset(pud, address);
> -	if (pmd_none(*pmd))
> +	if (!pmd_present(*pmd))
>  		return -EFAULT;
>  	VM_BUG_ON(pmd_trans_huge(*pmd));
>  	pte = pte_offset_map(pmd, address);
> @@ -1378,7 +1396,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
>  		pmd_t pmd = READ_ONCE(*pmdp);
>  
>  		next = pmd_addr_end(addr, end);
> -		if (pmd_none(pmd))
> +		if (!pmd_present(pmd))
>  			return 0;
>  
>  		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 7406d88445bf..3479e9caf2fa 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -912,6 +912,22 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  
>  	ret = -EAGAIN;
>  	pmd = *src_pmd;
> +
> +	if (unlikely(is_swap_pmd(pmd))) {
> +		swp_entry_t entry = pmd_to_swp_entry(pmd);
> +
> +		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
> +				  !is_pmd_migration_entry(pmd));
> +		if (is_write_migration_entry(entry)) {
> +			make_migration_entry_read(&entry);

We create a read migration entry after detecting a write ?

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
> @@ -1218,6 +1234,9 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
>  	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
>  		goto out_unlock;
>  
> +	if (unlikely(!pmd_present(orig_pmd)))
> +		goto out_unlock;
> +
>  	page = pmd_page(orig_pmd);
>  	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
>  	/*
> @@ -1548,6 +1567,12 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  	if (is_huge_zero_pmd(orig_pmd))
>  		goto out;
>  
> +	if (unlikely(!pmd_present(orig_pmd))) {
> +		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
> +				  !is_pmd_migration_entry(orig_pmd));
> +		goto out;
> +	}
> +
>  	page = pmd_page(orig_pmd);
>  	/*
>  	 * If other processes are mapping this page, we couldn't discard
> @@ -1758,6 +1783,21 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	preserve_write = prot_numa && pmd_write(*pmd);
>  	ret = 1;
>  
> +	if (is_swap_pmd(*pmd)) {
> +		swp_entry_t entry = pmd_to_swp_entry(*pmd);
> +
> +		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
> +				  !is_pmd_migration_entry(*pmd));
> +		if (is_write_migration_entry(entry)) {
> +			pmd_t newpmd;
> +
> +			make_migration_entry_read(&entry);

Same here or maybe I am missing something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
