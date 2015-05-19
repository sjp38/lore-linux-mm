Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id F22626B009E
	for <linux-mm@kvack.org>; Tue, 19 May 2015 04:25:35 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so108068934wic.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 01:25:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gk6si17039722wib.34.2015.05.19.01.25.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 May 2015 01:25:34 -0700 (PDT)
Message-ID: <555AF37A.2060709@suse.cz>
Date: Tue, 19 May 2015 10:25:30 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 22/28] thp: implement split_huge_pmd()
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-23-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-23-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> Original split_huge_page() combined two operations: splitting PMDs into
> tables of PTEs and splitting underlying compound page. This patch
> implements split_huge_pmd() which split given PMD without splitting
> other PMDs this page mapped with or underlying compound page.
>
> Without tail page refcounting, implementation of split_huge_pmd() is
> pretty straight-forward.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>   include/linux/huge_mm.h |  11 ++++-
>   mm/huge_memory.c        | 108 ++++++++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 118 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 0382230b490f..b7844c73b7db 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -94,7 +94,16 @@ extern unsigned long transparent_hugepage_flags;
>
>   #define split_huge_page_to_list(page, list) BUILD_BUG()
>   #define split_huge_page(page) BUILD_BUG()
> -#define split_huge_pmd(__vma, __pmd, __address) BUILD_BUG()
> +
> +void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> +		unsigned long address);
> +
> +#define split_huge_pmd(__vma, __pmd, __address)				\
> +	do {								\
> +		pmd_t *____pmd = (__pmd);				\
> +		if (unlikely(pmd_trans_huge(*____pmd)))			\

Given that most of calls to split_huge_pmd() appear to be in
if (pmd_trans_huge(...)) branches, this unlikely() seems counter-productive.

> +			__split_huge_pmd(__vma, __pmd, __address);	\
> +	}  while (0)
>
>   #if HPAGE_PMD_ORDER >= MAX_ORDER
>   #error "hugepages can't be allocated by the buddy allocator"
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 06adbe3f2100..5885ef8f0fad 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2522,6 +2522,114 @@ static int khugepaged(void *none)
>   	return 0;
>   }
>
> +static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
> +		unsigned long haddr, pmd_t *pmd)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	pgtable_t pgtable;
> +	pmd_t _pmd;
> +	int i;
> +
> +	/* leave pmd empty until pte is filled */
> +	pmdp_clear_flush_notify(vma, haddr, pmd);
> +
> +	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
> +	pmd_populate(mm, &_pmd, pgtable);
> +
> +	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
> +		pte_t *pte, entry;
> +		entry = pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
> +		entry = pte_mkspecial(entry);
> +		pte = pte_offset_map(&_pmd, haddr);
> +		VM_BUG_ON(!pte_none(*pte));
> +		set_pte_at(mm, haddr, pte, entry);
> +		pte_unmap(pte);
> +	}
> +	smp_wmb(); /* make pte visible before pmd */
> +	pmd_populate(mm, pmd, pgtable);
> +	put_huge_zero_page();
> +}
> +
> +static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
> +		unsigned long haddr)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	struct page *page;
> +	pgtable_t pgtable;
> +	pmd_t _pmd;
> +	bool young, write, last;
> +	int i;
> +
> +	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
> +	VM_BUG_ON_VMA(vma->vm_start > haddr, vma);
> +	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PMD_SIZE, vma);
> +	VM_BUG_ON(!pmd_trans_huge(*pmd));
> +
> +	count_vm_event(THP_SPLIT_PMD);
> +
> +	if (is_huge_zero_pmd(*pmd))
> +		return __split_huge_zero_page_pmd(vma, haddr, pmd);
> +
> +	page = pmd_page(*pmd);
> +	VM_BUG_ON_PAGE(!page_count(page), page);
> +	atomic_add(HPAGE_PMD_NR - 1, &page->_count);
> +	last = atomic_add_negative(-1, compound_mapcount_ptr(page));
> +	if (last)
> +		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
> +
> +	write = pmd_write(*pmd);
> +	young = pmd_young(*pmd);
> +
> +	/* leave pmd empty until pte is filled */
> +	pmdp_clear_flush_notify(vma, haddr, pmd);
> +
> +	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
> +	pmd_populate(mm, &_pmd, pgtable);
> +
> +	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
> +		pte_t entry, *pte;
> +		/*
> +		 * Note that NUMA hinting access restrictions are not
> +		 * transferred to avoid any possibility of altering
> +		 * permissions across VMAs.
> +		 */
> +		entry = mk_pte(page + i, vma->vm_page_prot);
> +		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +		if (!write)
> +			entry = pte_wrprotect(entry);
> +		if (!young)
> +			entry = pte_mkold(entry);
> +		pte = pte_offset_map(&_pmd, haddr);
> +		BUG_ON(!pte_none(*pte));
> +		set_pte_at(mm, haddr, pte, entry);
> +		/*
> +		 * Positive compound_mapcount also offsets ->_mapcount of
> +		 * every subpage by one -- no need to increase mapcount when
> +		 * splitting last PMD.
> +		 */
> +		if (!last)
> +			atomic_inc(&page[i]._mapcount);
> +		pte_unmap(pte);
> +	}
> +	smp_wmb(); /* make pte visible before pmd */
> +	pmd_populate(mm, pmd, pgtable);
> +}
> +
> +void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> +		unsigned long address)
> +{
> +	spinlock_t *ptl;
> +	struct mm_struct *mm = vma->vm_mm;
> +	unsigned long haddr = address & HPAGE_PMD_MASK;
> +
> +	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
> +	ptl = pmd_lock(mm, pmd);
> +	if (likely(pmd_trans_huge(*pmd)))

This likely is likely useless :)

> +		__split_huge_pmd_locked(vma, pmd, haddr);
> +	spin_unlock(ptl);
> +	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
> +}
> +
>   static void split_huge_pmd_address(struct vm_area_struct *vma,
>   				    unsigned long address)
>   {
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
