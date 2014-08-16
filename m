Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8156B0036
	for <linux-mm@kvack.org>; Sat, 16 Aug 2014 08:56:16 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id f51so3090795qge.32
        for <linux-mm@kvack.org>; Sat, 16 Aug 2014 05:56:16 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2lp0205.outbound.protection.outlook.com. [207.46.163.205])
        by mx.google.com with ESMTPS id e9si9402512qcj.38.2014.08.16.05.56.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 16 Aug 2014 05:56:14 -0700 (PDT)
Message-ID: <53EF54DA.4040406@amd.com>
Date: Sat, 16 Aug 2014 15:55:54 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mmu_notifier: Call mmu_notifier_invalidate_range()
 from VMM
References: <1406650693-23315-1-git-send-email-joro@8bytes.org>
 <1406650693-23315-3-git-send-email-joro@8bytes.org>
In-Reply-To: <1406650693-23315-3-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>, jroedel@suse.de, Jay.Cornwall@amd.com, John.Bridgman@amd.com, Suravee.Suthikulpanit@amd.com, ben.sander@amd.com, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org



On 29/07/14 19:18, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
> 
> Add calls to the new mmu_notifier_invalidate_range()
> function to all places if the VMM that need it.
> 
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  include/linux/mmu_notifier.h | 28 ++++++++++++++++++++++++++++
>  kernel/events/uprobes.c      |  2 +-
>  mm/fremap.c                  |  2 +-
>  mm/huge_memory.c             |  9 +++++----
>  mm/hugetlb.c                 |  7 ++++++-
>  mm/ksm.c                     |  4 ++--
>  mm/memory.c                  |  3 ++-
>  mm/migrate.c                 |  3 ++-
>  mm/rmap.c                    |  2 +-
>  9 files changed, 48 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index 1bac99c..f760e95 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -273,6 +273,32 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
>  	__young;							\
>  })
>  
> +#define	ptep_clear_flush_notify(__vma, __address, __ptep)		\
> +({									\
> +	unsigned long ___addr = __address & PAGE_MASK;			\
> +	struct mm_struct *___mm = (__vma)->vm_mm;			\
> +	pte_t ___pte;							\
> +									\
> +	___pte = ptep_clear_flush(__vma, __address, __ptep);		\
> +	mmu_notifier_invalidate_range(___mm, ___addr,			\
> +					___addr + PAGE_SIZE);		\
> +									\
> +	___pte;								\
> +})
> +
> +#define pmdp_clear_flush_notify(__vma, __haddr, __pmd)			\
> +({									\
> +	unsigned long ___haddr = __haddr & HPAGE_PMD_MASK;		\
> +	struct mm_struct *___mm = (__vma)->vm_mm;			\
> +	pmd_t ___pmd;							\
> +									\
> +	___pmd = pmdp_clear_flush(__vma, __haddr, __pmd);		\
> +	mmu_notifier_invalidate_range(___mm, ___haddr,			\
> +				      ___haddr + HPAGE_PMD_SIZE);	\
> +									\
> +	___pmd;								\
> +})
> +
>  /*
>   * set_pte_at_notify() sets the pte _after_ running the notifier.
>   * This is safe to start by updating the secondary MMUs, because the primary MMU
> @@ -346,6 +372,8 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
>  
>  #define ptep_clear_flush_young_notify ptep_clear_flush_young
>  #define pmdp_clear_flush_young_notify pmdp_clear_flush_young
> +#define	ptep_clear_flush_notify ptep_clear_flush
> +#define pmdp_clear_flush_notify pmdp_clear_flush
>  #define set_pte_at_notify set_pte_at
>  
>  #endif /* CONFIG_MMU_NOTIFIER */
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index 6f3254e..642262d 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -186,7 +186,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  	}
>  
>  	flush_cache_page(vma, addr, pte_pfn(*ptep));
> -	ptep_clear_flush(vma, addr, ptep);
> +	ptep_clear_flush_notify(vma, addr, ptep);
>  	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
>  
>  	page_remove_rmap(page);
> diff --git a/mm/fremap.c b/mm/fremap.c
> index 72b8fa3..9129013 100644
> --- a/mm/fremap.c
> +++ b/mm/fremap.c
> @@ -37,7 +37,7 @@ static void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  	if (pte_present(pte)) {
>  		flush_cache_page(vma, addr, pte_pfn(pte));
> -		pte = ptep_clear_flush(vma, addr, ptep);
> +		pte = ptep_clear_flush_notify(vma, addr, ptep);
>  		page = vm_normal_page(vma, addr, pte);
>  		if (page) {
>  			if (pte_dirty(pte))
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 33514d8..b322c97 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1031,7 +1031,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
>  		goto out_free_pages;
>  	VM_BUG_ON_PAGE(!PageHead(page), page);
>  
> -	pmdp_clear_flush(vma, haddr, pmd);
> +	pmdp_clear_flush_notify(vma, haddr, pmd);
>  	/* leave pmd empty until pte is filled */
>  
>  	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
> @@ -1168,7 +1168,7 @@ alloc:
>  		pmd_t entry;
>  		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
>  		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> -		pmdp_clear_flush(vma, haddr, pmd);
> +		pmdp_clear_flush_notify(vma, haddr, pmd);
>  		page_add_new_anon_rmap(new_page, vma, haddr);
>  		set_pmd_at(mm, haddr, pmd, entry);
>  		update_mmu_cache_pmd(vma, address, pmd);
> @@ -1499,7 +1499,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  		pmd_t entry;
>  		ret = 1;
>  		if (!prot_numa) {
> -			entry = pmdp_get_and_clear(mm, addr, pmd);
> +			entry = pmdp_get_and_clear_notify(mm, addr, pmd);

Where is pmdp_get_and_clear_notify() implemented ?
I didn't find any implementation in this patch nor in linux-next.

	Oded

>  			if (pmd_numa(entry))
>  				entry = pmd_mknonnuma(entry);
>  			entry = pmd_modify(entry, newprot);
> @@ -1631,6 +1631,7 @@ static int __split_huge_page_splitting(struct page *page,
>  		 * serialize against split_huge_page*.
>  		 */
>  		pmdp_splitting_flush(vma, address, pmd);
> +
>  		ret = 1;
>  		spin_unlock(ptl);
>  	}
> @@ -2793,7 +2794,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
>  	pmd_t _pmd;
>  	int i;
>  
> -	pmdp_clear_flush(vma, haddr, pmd);
> +	pmdp_clear_flush_notify(vma, haddr, pmd);
>  	/* leave pmd empty until pte is filled */
>  
>  	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 9221c02..603851d 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2602,8 +2602,11 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  			}
>  			set_huge_pte_at(dst, addr, dst_pte, entry);
>  		} else {
> -			if (cow)
> +			if (cow) {
>  				huge_ptep_set_wrprotect(src, addr, src_pte);
> +				mmu_notifier_invalidate_range(src, mmun_start,
> +								   mmun_end);
> +			}
>  			entry = huge_ptep_get(src_pte);
>  			ptepage = pte_page(entry);
>  			get_page(ptepage);
> @@ -2911,6 +2914,7 @@ retry_avoidcopy:
>  
>  		/* Break COW */
>  		huge_ptep_clear_flush(vma, address, ptep);
> +		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
>  		set_huge_pte_at(mm, address, ptep,
>  				make_huge_pte(vma, new_page, 1));
>  		page_remove_rmap(old_page);
> @@ -3385,6 +3389,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  	 * and that page table be reused and filled with junk.
>  	 */
>  	flush_tlb_range(vma, start, end);
> +	mmu_notifier_invalidate_range(mm, start, end);
>  	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
>  	mmu_notifier_invalidate_range_end(mm, start, end);
>  
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 346ddc9..a73df3b 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -892,7 +892,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
>  		 * this assure us that no O_DIRECT can happen after the check
>  		 * or in the middle of the check.
>  		 */
> -		entry = ptep_clear_flush(vma, addr, ptep);
> +		entry = ptep_clear_flush_notify(vma, addr, ptep);
>  		/*
>  		 * Check that no O_DIRECT or similar I/O is in progress on the
>  		 * page
> @@ -960,7 +960,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
>  	page_add_anon_rmap(kpage, vma, addr);
>  
>  	flush_cache_page(vma, addr, pte_pfn(*ptep));
> -	ptep_clear_flush(vma, addr, ptep);
> +	ptep_clear_flush_notify(vma, addr, ptep);
>  	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
>  
>  	page_remove_rmap(page);
> diff --git a/mm/memory.c b/mm/memory.c
> index 7e8d820..36daa2d 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -236,6 +236,7 @@ static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
>  {
>  	tlb->need_flush = 0;
>  	tlb_flush(tlb);
> +	mmu_notifier_invalidate_range(tlb->mm, tlb->start, tlb->end);
>  #ifdef CONFIG_HAVE_RCU_TABLE_FREE
>  	tlb_table_flush(tlb);
>  #endif
> @@ -2232,7 +2233,7 @@ gotten:
>  		 * seen in the presence of one thread doing SMC and another
>  		 * thread doing COW.
>  		 */
> -		ptep_clear_flush(vma, address, page_table);
> +		ptep_clear_flush_notify(vma, address, page_table);
>  		page_add_new_anon_rmap(new_page, vma, address);
>  		/*
>  		 * We call the notify macro here because, when using secondary
> diff --git a/mm/migrate.c b/mm/migrate.c
> index be6dbf9..d3fb8d0 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1875,7 +1875,7 @@ fail_putback:
>  	 */
>  	flush_cache_range(vma, mmun_start, mmun_end);
>  	page_add_anon_rmap(new_page, vma, mmun_start);
> -	pmdp_clear_flush(vma, mmun_start, pmd);
> +	pmdp_clear_flush_notify(vma, mmun_start, pmd);
>  	set_pmd_at(mm, mmun_start, pmd, entry);
>  	flush_tlb_range(vma, mmun_start, mmun_end);
>  	update_mmu_cache_pmd(vma, address, &entry);
> @@ -1883,6 +1883,7 @@ fail_putback:
>  	if (page_count(page) != 2) {
>  		set_pmd_at(mm, mmun_start, pmd, orig_entry);
>  		flush_tlb_range(vma, mmun_start, mmun_end);
> +		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
>  		update_mmu_cache_pmd(vma, address, &entry);
>  		page_remove_rmap(new_page);
>  		goto fail_putback;
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 22a4a76..8a0d02d 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1380,7 +1380,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
>  
>  		/* Nuke the page table entry. */
>  		flush_cache_page(vma, address, pte_pfn(*pte));
> -		pteval = ptep_clear_flush(vma, address, pte);
> +		pteval = ptep_clear_flush_notify(vma, address, pte);
>  
>  		/* If nonlinear, store the file page offset in the pte. */
>  		if (page->index != linear_page_index(vma, address)) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
