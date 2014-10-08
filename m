Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9238F6B0072
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 11:21:32 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id gi9so8807052lab.33
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 08:21:31 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.226])
        by mx.google.com with ESMTP id v7si478099laj.78.2014.10.08.08.21.30
        for <linux-mm@kvack.org>;
        Wed, 08 Oct 2014 08:21:30 -0700 (PDT)
Date: Wed, 8 Oct 2014 18:21:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v1 2/7] mm: Prepare for DAX huge pages
Message-ID: <20141008152124.GA7288@node.dhcp.inet.fi>
References: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
 <1412774729-23956-3-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1412774729-23956-3-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.krenel.org, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>

On Wed, Oct 08, 2014 at 09:25:24AM -0400, Matthew Wilcox wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
> 
> DAX wants to use the 'special' bit to mark PMD entries that are not backed
> by struct page, just as for PTEs. 

Hm. I don't see where you use PMD without special set.

> Add pmd_special() and pmd_mkspecial
> for x86 (nb: also need to be added for other architectures).  Prepare
> do_huge_pmd_wp_page(), zap_huge_pmd() and __split_huge_page_pmd() to
> handle pmd_special entries.
> 
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> ---
>  arch/x86/include/asm/pgtable.h | 10 +++++++++
>  mm/huge_memory.c               | 51 ++++++++++++++++++++++++++----------------
>  2 files changed, 42 insertions(+), 19 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index aa97a07..f4f42f2 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -302,6 +302,11 @@ static inline pmd_t pmd_mknotpresent(pmd_t pmd)
>  	return pmd_clear_flags(pmd, _PAGE_PRESENT);
>  }
>  
> +static inline pmd_t pmd_mkspecial(pmd_t pmd)
> +{
> +	return pmd_set_flags(pmd, _PAGE_SPECIAL);
> +}
> +
>  #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
>  static inline int pte_soft_dirty(pte_t pte)
>  {
> @@ -504,6 +509,11 @@ static inline int pmd_none(pmd_t pmd)
>  	return (unsigned long)native_pmd_val(pmd) == 0;
>  }
>  
> +static inline int pmd_special(pmd_t pmd)
> +{
> +	return (pmd_flags(pmd) & _PAGE_SPECIAL) && pmd_present(pmd);
> +}
> +
>  static inline unsigned long pmd_page_vaddr(pmd_t pmd)
>  {
>  	return (unsigned long)__va(pmd_val(pmd) & PTE_PFN_MASK);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 2a56ddd..ad09fc1 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1096,7 +1096,6 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	unsigned long mmun_end;		/* For mmu_notifiers */
>  
>  	ptl = pmd_lockptr(mm, pmd);
> -	VM_BUG_ON(!vma->anon_vma);
>  	haddr = address & HPAGE_PMD_MASK;
>  	if (is_huge_zero_pmd(orig_pmd))
>  		goto alloc;
> @@ -1104,9 +1103,20 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (unlikely(!pmd_same(*pmd, orig_pmd)))
>  		goto out_unlock;
>  
> -	page = pmd_page(orig_pmd);
> -	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
> -	if (page_mapcount(page) == 1) {
> +	if (pmd_special(orig_pmd)) {
> +		/* VM_MIXEDMAP !pfn_valid() case */
> +		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) !=
> +				     (VM_WRITE|VM_SHARED)) {
> +			pmdp_clear_flush(vma, haddr, pmd);
> +			ret = VM_FAULT_FALLBACK;

No private THP pages with THP? Why?
It should be trivial: we already have a code path for !page case for zero
page and it shouldn't be too hard to modify do_dax_pmd_fault() to support
COW.

I remeber I've mentioned that you don't think it's reasonable to allocate
2M page on COW, but that's what we do for anon memory...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
