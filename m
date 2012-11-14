Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id E631A6B0074
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 18:28:17 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so714592pad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 15:28:17 -0800 (PST)
Date: Wed, 14 Nov 2012 15:28:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 07/11] thp: implement splitting pmd for huge zero
 page
In-Reply-To: <1352300463-12627-8-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1211141524010.22537@chino.kir.corp.google.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <1352300463-12627-8-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:

> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 90e651c..f36bc7d 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1611,6 +1611,7 @@ int split_huge_page(struct page *page)
>  	struct anon_vma *anon_vma;
>  	int ret = 1;
>  
> +	BUG_ON(is_huge_zero_pfn(page_to_pfn(page)));
>  	BUG_ON(!PageAnon(page));
>  	anon_vma = page_lock_anon_vma(page);
>  	if (!anon_vma)
> @@ -2509,23 +2510,63 @@ static int khugepaged(void *none)
>  	return 0;
>  }
>  
> +static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
> +		unsigned long haddr, pmd_t *pmd)
> +{

This entire function duplicates other code in mm/huge_memory.c which gives 
even more incentive into breaking do_huge_pmd_wp_zero_page_fallback() into 
logical helper functions and reusing them for both page and !page.  
Duplicating all this code throughout the thp code just becomes a 
maintenance nightmare down the road.

> +	pgtable_t pgtable;
> +	pmd_t _pmd;
> +	int i;
> +
> +	pmdp_clear_flush(vma, haddr, pmd);
> +	/* leave pmd empty until pte is filled */
> +
> +	pgtable = get_pmd_huge_pte(vma->vm_mm);
> +	pmd_populate(vma->vm_mm, &_pmd, pgtable);
> +
> +	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
> +		pte_t *pte, entry;
> +		entry = pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
> +		entry = pte_mkspecial(entry);
> +		pte = pte_offset_map(&_pmd, haddr);
> +		VM_BUG_ON(!pte_none(*pte));
> +		set_pte_at(vma->vm_mm, haddr, pte, entry);
> +		pte_unmap(pte);
> +	}
> +	smp_wmb(); /* make pte visible before pmd */
> +	pmd_populate(vma->vm_mm, pmd, pgtable);
> +}
> +
>  void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
>  		pmd_t *pmd)
>  {
>  	struct page *page;
> +	struct mm_struct *mm = vma->vm_mm;
>  	unsigned long haddr = address & HPAGE_PMD_MASK;
> +	unsigned long mmun_start;	/* For mmu_notifiers */
> +	unsigned long mmun_end;		/* For mmu_notifiers */
>  
>  	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
>  
> -	spin_lock(&vma->vm_mm->page_table_lock);
> +	mmun_start = haddr;
> +	mmun_end   = address + HPAGE_PMD_SIZE;

address or haddr?

> +	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	spin_lock(&mm->page_table_lock);
>  	if (unlikely(!pmd_trans_huge(*pmd))) {
> -		spin_unlock(&vma->vm_mm->page_table_lock);
> +		spin_unlock(&mm->page_table_lock);
> +		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +		return;
> +	}
> +	if (is_huge_zero_pmd(*pmd)) {
> +		__split_huge_zero_page_pmd(vma, haddr, pmd);
> +		spin_unlock(&mm->page_table_lock);
> +		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>  		return;
>  	}
>  	page = pmd_page(*pmd);
>  	VM_BUG_ON(!page_count(page));
>  	get_page(page);
> -	spin_unlock(&vma->vm_mm->page_table_lock);
> +	spin_unlock(&mm->page_table_lock);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>  
>  	split_huge_page(page);
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
