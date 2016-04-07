Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD8D6B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 05:05:00 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id 184so52205898pff.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 02:05:00 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id rz3si10429786pac.196.2016.04.07.02.04.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 02:04:59 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id zy2so6355795pac.2
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 02:04:59 -0700 (PDT)
Subject: Re: [PATCH 02/10] mm/hugetlb: Add PGD based implementation awareness
References: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1460007464-26726-3-git-send-email-khandual@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <570622B4.5020407@gmail.com>
Date: Thu, 7 Apr 2016 19:04:52 +1000
MIME-Version: 1.0
In-Reply-To: <1460007464-26726-3-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au



On 07/04/16 15:37, Anshuman Khandual wrote:
> Currently the config ARCH_WANT_GENERAL_HUGETLB enabled functions like
> 'huge_pte_alloc' and 'huge_pte_offset' dont take into account HugeTLB
> page implementation at the PGD level. This is also true for functions
> like 'follow_page_mask' which is called from move_pages() system call.
> This lack of PGD level huge page support prohibits some architectures
> to use these generic HugeTLB functions.
> 

>From what I know of move_pages(), it will always call follow_page_mask()
with FOLL_GET (I could be wrong here) and the implementation below
returns NULL for follow_huge_pgd().

> This change adds the required PGD based implementation awareness and
> with that, more architectures like POWER which implements 16GB pages
> at the PGD level along with the 16MB pages at the PMD level can now
> use ARCH_WANT_GENERAL_HUGETLB config option.
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  include/linux/hugetlb.h |  3 +++
>  mm/gup.c                |  6 ++++++
>  mm/hugetlb.c            | 20 ++++++++++++++++++++
>  3 files changed, 29 insertions(+)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 7d953c2..71832e1 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -115,6 +115,8 @@ struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  				pmd_t *pmd, int flags);
>  struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
>  				pud_t *pud, int flags);
> +struct page *follow_huge_pgd(struct mm_struct *mm, unsigned long address,
> +				pgd_t *pgd, int flags);
>  int pmd_huge(pmd_t pmd);
>  int pud_huge(pud_t pmd);
>  unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
> @@ -143,6 +145,7 @@ static inline void hugetlb_show_meminfo(void)
>  }
>  #define follow_huge_pmd(mm, addr, pmd, flags)	NULL
>  #define follow_huge_pud(mm, addr, pud, flags)	NULL
> +#define follow_huge_pgd(mm, addr, pgd, flags)	NULL
>  #define prepare_hugepage_range(file, addr, len)	(-EINVAL)
>  #define pmd_huge(x)	0
>  #define pud_huge(x)	0
> diff --git a/mm/gup.c b/mm/gup.c
> index fb87aea..9bac78c 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -234,6 +234,12 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
>  	pgd = pgd_offset(mm, address);
>  	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
>  		return no_page_table(vma, flags);
> +	if (pgd_huge(*pgd) && vma->vm_flags & VM_HUGETLB) {
> +		page = follow_huge_pgd(mm, address, pgd, flags);
> +		if (page)
> +			return page;
> +		return no_page_table(vma, flags);
This will return NULL as well?
> +	}
>  
>  	pud = pud_offset(pgd, address);
>  	if (pud_none(*pud))
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 19d0d08..5ea3158 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4250,6 +4250,11 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
>  	pte_t *pte = NULL;
>  
>  	pgd = pgd_offset(mm, addr);
> +	if (sz == PGDIR_SIZE) {
> +		pte = (pte_t *)pgd;
> +		goto huge_pgd;
> +	}
> +

No allocation for a pgd slot - right?

>  	pud = pud_alloc(mm, pgd, addr);
>  	if (pud) {
>  		if (sz == PUD_SIZE) {
> @@ -4262,6 +4267,8 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
>  				pte = (pte_t *)pmd_alloc(mm, pud, addr);
>  		}
>  	}
> +
> +huge_pgd:
>  	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
>  
>  	return pte;
> @@ -4275,6 +4282,8 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
>  
>  	pgd = pgd_offset(mm, addr);
>  	if (pgd_present(*pgd)) {
> +		if (pgd_huge(*pgd))
> +			return (pte_t *)pgd;
>  		pud = pud_offset(pgd, addr);
>  		if (pud_present(*pud)) {
>  			if (pud_huge(*pud))
> @@ -4343,6 +4352,17 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
>  	return pte_page(*(pte_t *)pud) + ((address & ~PUD_MASK) >> PAGE_SHIFT);
>  }
>  
> +struct page * __weak
> +follow_huge_pgd(struct mm_struct *mm, unsigned long address,
> +		pgd_t *pgd, int flags)
> +{
> +	if (flags & FOLL_GET)
> +		return NULL;
> +
> +	return pte_page(*(pte_t *)pgd) +
> +				((address & ~PGDIR_MASK) >> PAGE_SHIFT);
> +}
> +
>  #ifdef CONFIG_MEMORY_FAILURE
>  
>  /*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
