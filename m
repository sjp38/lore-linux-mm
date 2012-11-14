Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 8D2666B00B3
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 18:22:05 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so432650dad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 15:22:04 -0800 (PST)
Date: Wed, 14 Nov 2012 15:22:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 06/11] thp: change split_huge_page_pmd() interface
In-Reply-To: <1352300463-12627-7-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1211141516570.22537@chino.kir.corp.google.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <1352300463-12627-7-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:

> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> index f734bb2..677a599 100644
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -276,7 +276,7 @@ unaffected. libhugetlbfs will also work fine as usual.
>  == Graceful fallback ==
>  
>  Code walking pagetables but unware about huge pmds can simply call
> -split_huge_page_pmd(mm, pmd) where the pmd is the one returned by
> +split_huge_page_pmd(vma, pmd, addr) where the pmd is the one returned by
>  pmd_offset. It's trivial to make the code transparent hugepage aware
>  by just grepping for "pmd_offset" and adding split_huge_page_pmd where
>  missing after pmd_offset returns the pmd. Thanks to the graceful
> @@ -299,7 +299,7 @@ diff --git a/mm/mremap.c b/mm/mremap.c
>  		return NULL;
>  
>  	pmd = pmd_offset(pud, addr);
> -+	split_huge_page_pmd(mm, pmd);
> ++	split_huge_page_pmd(vma, pmd, addr);
>  	if (pmd_none_or_clear_bad(pmd))
>  		return NULL;
>  
> diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
> index 5c9687b..1dfe69c 100644
> --- a/arch/x86/kernel/vm86_32.c
> +++ b/arch/x86/kernel/vm86_32.c
> @@ -182,7 +182,7 @@ static void mark_screen_rdonly(struct mm_struct *mm)
>  	if (pud_none_or_clear_bad(pud))
>  		goto out;
>  	pmd = pmd_offset(pud, 0xA0000);
> -	split_huge_page_pmd(mm, pmd);
> +	split_huge_page_pmd_mm(mm, 0xA0000, pmd);
>  	if (pmd_none_or_clear_bad(pmd))
>  		goto out;
>  	pte = pte_offset_map_lock(mm, pmd, 0xA0000, &ptl);

Why not be consistent and make this split_huge_page_pmd_mm(mm, pmd, addr)?

> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 90c63f9..291a0d1 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -643,7 +643,7 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
>  	spinlock_t *ptl;
>  	struct page *page;
>  
> -	split_huge_page_pmd(walk->mm, pmd);
> +	split_huge_page_pmd(vma, addr, pmd);

Ah, it's because the change to the documentation is wrong: the format is 
actually split_huge_page_pmd(vma, addr, pmd).

>  	if (pmd_trans_unstable(pmd))
>  		return 0;
>  
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index b31cb7d..856f080 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -91,12 +91,14 @@ extern int handle_pte_fault(struct mm_struct *mm,
>  			    struct vm_area_struct *vma, unsigned long address,
>  			    pte_t *pte, pmd_t *pmd, unsigned int flags);
>  extern int split_huge_page(struct page *page);
> -extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
> -#define split_huge_page_pmd(__mm, __pmd)				\
> +extern void __split_huge_page_pmd(struct vm_area_struct *vma,
> +		unsigned long address, pmd_t *pmd);
> +#define split_huge_page_pmd(__vma, __address, __pmd)			\
>  	do {								\
>  		pmd_t *____pmd = (__pmd);				\
>  		if (unlikely(pmd_trans_huge(*____pmd)))			\
> -			__split_huge_page_pmd(__mm, ____pmd);		\
> +			__split_huge_page_pmd(__vma, __address,		\
> +					____pmd);			\
>  	}  while (0)
>  #define wait_split_huge_page(__anon_vma, __pmd)				\
>  	do {								\
> @@ -106,6 +108,8 @@ extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
>  		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
>  		       pmd_trans_huge(*____pmd));			\
>  	} while (0)
> +extern void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
> +		pmd_t *pmd);
>  #if HPAGE_PMD_ORDER > MAX_ORDER
>  #error "hugepages can't be allocated by the buddy allocator"
>  #endif
> @@ -173,10 +177,12 @@ static inline int split_huge_page(struct page *page)
>  {
>  	return 0;
>  }
> -#define split_huge_page_pmd(__mm, __pmd)	\
> +#define split_huge_page_pmd(__vma, __address, __pmd)	\
>  	do { } while (0)
>  #define wait_split_huge_page(__anon_vma, __pmd)	\
>  	do { } while (0)
> +#define split_huge_page_pmd_mm(__mm, __address, __pmd)	\
> +	do { } while (0)
>  #define compound_trans_head(page) compound_head(page)
>  static inline int hugepage_madvise(struct vm_area_struct *vma,
>  				   unsigned long *vm_flags, int advice)
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 05490b3..90e651c 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2509,19 +2509,23 @@ static int khugepaged(void *none)
>  	return 0;
>  }
>  
> -void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd)
> +void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
> +		pmd_t *pmd)
>  {
>  	struct page *page;
> +	unsigned long haddr = address & HPAGE_PMD_MASK;
> 

Just do

	struct mm_struct *mm = vma->vm_mm;

here and it makes everything else simpler.
 
> -	spin_lock(&mm->page_table_lock);
> +	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
> +
> +	spin_lock(&vma->vm_mm->page_table_lock);
>  	if (unlikely(!pmd_trans_huge(*pmd))) {
> -		spin_unlock(&mm->page_table_lock);
> +		spin_unlock(&vma->vm_mm->page_table_lock);
>  		return;
>  	}
>  	page = pmd_page(*pmd);
>  	VM_BUG_ON(!page_count(page));
>  	get_page(page);
> -	spin_unlock(&mm->page_table_lock);
> +	spin_unlock(&vma->vm_mm->page_table_lock);
>  
>  	split_huge_page(page);
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
