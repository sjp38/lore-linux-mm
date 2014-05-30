Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8D72A6B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 08:01:59 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so1396875pab.13
        for <linux-mm@kvack.org>; Fri, 30 May 2014 05:01:59 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id cr16si5287917pac.141.2014.05.30.05.01.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 May 2014 05:01:58 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id w10so882497pde.14
        for <linux-mm@kvack.org>; Fri, 30 May 2014 05:01:58 -0700 (PDT)
Date: Fri, 30 May 2014 05:00:40 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] hugetlb: restrict hugepage_migration_support() to
 x86_64
In-Reply-To: <1401423232-25198-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LSU.2.11.1405300459370.1037@eggly.anvils>
References: <1401423232-25198-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, trinity@vger.kernel.org

On Fri, 30 May 2014, Naoya Horiguchi wrote:

> Curretly hugepage migration is available for all archs which support pmd-level
> hugepage, but testing is done only for x86_64 and there're bugs for other archs.
> So to avoid breaking such archs, this patch limits the availability strictly to
> x86_64 until developers of other archs get interested in enabling this feature.
> 
> Simply disabling hugepage migration on non-x86_64 archs is not enough to fix
> the reported problem where sys_move_pages() hits the BUG_ON() in
> follow_page(FOLL_GET), so let's fix this by checking if hugepage migration is
> supported in vma_migratable().
> 
> ChangeLog:
> - add VM_HUGETLB check in vma_migratable()
> - fix dependency in config ARCH_ENABLE_HUGEPAGE_MIGRATION
> - remove comment on hugepage_migration_support()
> 
> Reported-by: Michael Ellerman <mpe@ellerman.id.au>
> Tested-by: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org # 3.12+

Acked-by: Hugh Dickins <hughd@google.com>

> ---
>  arch/arm/mm/hugetlbpage.c     |  5 -----
>  arch/arm64/mm/hugetlbpage.c   |  5 -----
>  arch/ia64/mm/hugetlbpage.c    |  5 -----
>  arch/metag/mm/hugetlbpage.c   |  5 -----
>  arch/mips/mm/hugetlbpage.c    |  5 -----
>  arch/powerpc/mm/hugetlbpage.c | 10 ----------
>  arch/s390/mm/hugetlbpage.c    |  5 -----
>  arch/sh/mm/hugetlbpage.c      |  5 -----
>  arch/sparc/mm/hugetlbpage.c   |  5 -----
>  arch/tile/mm/hugetlbpage.c    |  5 -----
>  arch/x86/Kconfig              |  4 ++++
>  arch/x86/mm/hugetlbpage.c     | 10 ----------
>  include/linux/hugetlb.h       | 13 +++++--------
>  include/linux/mempolicy.h     |  6 ++++++
>  mm/Kconfig                    |  3 +++
>  15 files changed, 18 insertions(+), 73 deletions(-)
> 
> diff --git v3.15-rc5.orig/arch/arm/mm/hugetlbpage.c v3.15-rc5/arch/arm/mm/hugetlbpage.c
> index 54ee6163c181..66781bf34077 100644
> --- v3.15-rc5.orig/arch/arm/mm/hugetlbpage.c
> +++ v3.15-rc5/arch/arm/mm/hugetlbpage.c
> @@ -56,8 +56,3 @@ int pmd_huge(pmd_t pmd)
>  {
>  	return pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT);
>  }
> -
> -int pmd_huge_support(void)
> -{
> -	return 1;
> -}
> diff --git v3.15-rc5.orig/arch/arm64/mm/hugetlbpage.c v3.15-rc5/arch/arm64/mm/hugetlbpage.c
> index 5e9aec358306..2fc8258bab2d 100644
> --- v3.15-rc5.orig/arch/arm64/mm/hugetlbpage.c
> +++ v3.15-rc5/arch/arm64/mm/hugetlbpage.c
> @@ -54,11 +54,6 @@ int pud_huge(pud_t pud)
>  	return !(pud_val(pud) & PUD_TABLE_BIT);
>  }
>  
> -int pmd_huge_support(void)
> -{
> -	return 1;
> -}
> -
>  static __init int setup_hugepagesz(char *opt)
>  {
>  	unsigned long ps = memparse(opt, &opt);
> diff --git v3.15-rc5.orig/arch/ia64/mm/hugetlbpage.c v3.15-rc5/arch/ia64/mm/hugetlbpage.c
> index 68232db98baa..76069c18ee42 100644
> --- v3.15-rc5.orig/arch/ia64/mm/hugetlbpage.c
> +++ v3.15-rc5/arch/ia64/mm/hugetlbpage.c
> @@ -114,11 +114,6 @@ int pud_huge(pud_t pud)
>  	return 0;
>  }
>  
> -int pmd_huge_support(void)
> -{
> -	return 0;
> -}
> -
>  struct page *
>  follow_huge_pmd(struct mm_struct *mm, unsigned long address, pmd_t *pmd, int write)
>  {
> diff --git v3.15-rc5.orig/arch/metag/mm/hugetlbpage.c v3.15-rc5/arch/metag/mm/hugetlbpage.c
> index 042431509b56..3c52fa6d0f8e 100644
> --- v3.15-rc5.orig/arch/metag/mm/hugetlbpage.c
> +++ v3.15-rc5/arch/metag/mm/hugetlbpage.c
> @@ -110,11 +110,6 @@ int pud_huge(pud_t pud)
>  	return 0;
>  }
>  
> -int pmd_huge_support(void)
> -{
> -	return 1;
> -}
> -
>  struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  			     pmd_t *pmd, int write)
>  {
> diff --git v3.15-rc5.orig/arch/mips/mm/hugetlbpage.c v3.15-rc5/arch/mips/mm/hugetlbpage.c
> index 77e0ae036e7c..4ec8ee10d371 100644
> --- v3.15-rc5.orig/arch/mips/mm/hugetlbpage.c
> +++ v3.15-rc5/arch/mips/mm/hugetlbpage.c
> @@ -84,11 +84,6 @@ int pud_huge(pud_t pud)
>  	return (pud_val(pud) & _PAGE_HUGE) != 0;
>  }
>  
> -int pmd_huge_support(void)
> -{
> -	return 1;
> -}
> -
>  struct page *
>  follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  		pmd_t *pmd, int write)
> diff --git v3.15-rc5.orig/arch/powerpc/mm/hugetlbpage.c v3.15-rc5/arch/powerpc/mm/hugetlbpage.c
> index eb923654ba80..7e70ae968e5f 100644
> --- v3.15-rc5.orig/arch/powerpc/mm/hugetlbpage.c
> +++ v3.15-rc5/arch/powerpc/mm/hugetlbpage.c
> @@ -86,11 +86,6 @@ int pgd_huge(pgd_t pgd)
>  	 */
>  	return ((pgd_val(pgd) & 0x3) != 0x0);
>  }
> -
> -int pmd_huge_support(void)
> -{
> -	return 1;
> -}
>  #else
>  int pmd_huge(pmd_t pmd)
>  {
> @@ -106,11 +101,6 @@ int pgd_huge(pgd_t pgd)
>  {
>  	return 0;
>  }
> -
> -int pmd_huge_support(void)
> -{
> -	return 0;
> -}
>  #endif
>  
>  pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
> diff --git v3.15-rc5.orig/arch/s390/mm/hugetlbpage.c v3.15-rc5/arch/s390/mm/hugetlbpage.c
> index 0727a55d87d9..0ff66a7e29bb 100644
> --- v3.15-rc5.orig/arch/s390/mm/hugetlbpage.c
> +++ v3.15-rc5/arch/s390/mm/hugetlbpage.c
> @@ -220,11 +220,6 @@ int pud_huge(pud_t pud)
>  	return 0;
>  }
>  
> -int pmd_huge_support(void)
> -{
> -	return 1;
> -}
> -
>  struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  			     pmd_t *pmdp, int write)
>  {
> diff --git v3.15-rc5.orig/arch/sh/mm/hugetlbpage.c v3.15-rc5/arch/sh/mm/hugetlbpage.c
> index 0d676a41081e..d7762349ea48 100644
> --- v3.15-rc5.orig/arch/sh/mm/hugetlbpage.c
> +++ v3.15-rc5/arch/sh/mm/hugetlbpage.c
> @@ -83,11 +83,6 @@ int pud_huge(pud_t pud)
>  	return 0;
>  }
>  
> -int pmd_huge_support(void)
> -{
> -	return 0;
> -}
> -
>  struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  			     pmd_t *pmd, int write)
>  {
> diff --git v3.15-rc5.orig/arch/sparc/mm/hugetlbpage.c v3.15-rc5/arch/sparc/mm/hugetlbpage.c
> index 9bd9ce80bf77..d329537739c6 100644
> --- v3.15-rc5.orig/arch/sparc/mm/hugetlbpage.c
> +++ v3.15-rc5/arch/sparc/mm/hugetlbpage.c
> @@ -231,11 +231,6 @@ int pud_huge(pud_t pud)
>  	return 0;
>  }
>  
> -int pmd_huge_support(void)
> -{
> -	return 0;
> -}
> -
>  struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  			     pmd_t *pmd, int write)
>  {
> diff --git v3.15-rc5.orig/arch/tile/mm/hugetlbpage.c v3.15-rc5/arch/tile/mm/hugetlbpage.c
> index 0cb3bbaa580c..e514899e1100 100644
> --- v3.15-rc5.orig/arch/tile/mm/hugetlbpage.c
> +++ v3.15-rc5/arch/tile/mm/hugetlbpage.c
> @@ -166,11 +166,6 @@ int pud_huge(pud_t pud)
>  	return !!(pud_val(pud) & _PAGE_HUGE_PAGE);
>  }
>  
> -int pmd_huge_support(void)
> -{
> -	return 1;
> -}
> -
>  struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  			     pmd_t *pmd, int write)
>  {
> diff --git v3.15-rc5.orig/arch/x86/Kconfig v3.15-rc5/arch/x86/Kconfig
> index 25d2c6f7325e..6b8b429c832f 100644
> --- v3.15-rc5.orig/arch/x86/Kconfig
> +++ v3.15-rc5/arch/x86/Kconfig
> @@ -1871,6 +1871,10 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
>  	def_bool y
>  	depends on X86_64 || X86_PAE
>  
> +config ARCH_ENABLE_HUGEPAGE_MIGRATION
> +	def_bool y
> +	depends on X86_64 && HUGETLB_PAGE && MIGRATION
> +
>  menu "Power management and ACPI options"
>  
>  config ARCH_HIBERNATION_HEADER
> diff --git v3.15-rc5.orig/arch/x86/mm/hugetlbpage.c v3.15-rc5/arch/x86/mm/hugetlbpage.c
> index 8c9f647ff9e1..8b977ebf9388 100644
> --- v3.15-rc5.orig/arch/x86/mm/hugetlbpage.c
> +++ v3.15-rc5/arch/x86/mm/hugetlbpage.c
> @@ -58,11 +58,6 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  {
>  	return NULL;
>  }
> -
> -int pmd_huge_support(void)
> -{
> -	return 0;
> -}
>  #else
>  
>  struct page *
> @@ -80,11 +75,6 @@ int pud_huge(pud_t pud)
>  {
>  	return !!(pud_val(pud) & _PAGE_PSE);
>  }
> -
> -int pmd_huge_support(void)
> -{
> -	return 1;
> -}
>  #endif
>  
>  #ifdef CONFIG_HUGETLB_PAGE
> diff --git v3.15-rc5.orig/include/linux/hugetlb.h v3.15-rc5/include/linux/hugetlb.h
> index 63214868c5b2..c9de64cf288d 100644
> --- v3.15-rc5.orig/include/linux/hugetlb.h
> +++ v3.15-rc5/include/linux/hugetlb.h
> @@ -385,15 +385,13 @@ static inline pgoff_t basepage_index(struct page *page)
>  
>  extern void dissolve_free_huge_pages(unsigned long start_pfn,
>  				     unsigned long end_pfn);
> -int pmd_huge_support(void);
> -/*
> - * Currently hugepage migration is enabled only for pmd-based hugepage.
> - * This function will be updated when hugepage migration is more widely
> - * supported.
> - */
>  static inline int hugepage_migration_support(struct hstate *h)
>  {
> -	return pmd_huge_support() && (huge_page_shift(h) == PMD_SHIFT);
> +#ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
> +	return huge_page_shift(h) == PMD_SHIFT;
> +#else
> +	return 0;
> +#endif
>  }
>  
>  static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
> @@ -443,7 +441,6 @@ static inline pgoff_t basepage_index(struct page *page)
>  	return page->index;
>  }
>  #define dissolve_free_huge_pages(s, e)	do {} while (0)
> -#define pmd_huge_support()	0
>  #define hugepage_migration_support(h)	0
>  
>  static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
> diff --git v3.15-rc5.orig/include/linux/mempolicy.h v3.15-rc5/include/linux/mempolicy.h
> index 3c1b968da0ca..f230a978e6ba 100644
> --- v3.15-rc5.orig/include/linux/mempolicy.h
> +++ v3.15-rc5/include/linux/mempolicy.h
> @@ -175,6 +175,12 @@ static inline int vma_migratable(struct vm_area_struct *vma)
>  {
>  	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
>  		return 0;
> +
> +#ifndef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
> +	if (vma->vm_flags & VM_HUGETLB)
> +		return 0;
> +#endif
> +
>  	/*
>  	 * Migration allocates pages in the highest zone. If we cannot
>  	 * do so then migration (at least from node to node) is not
> diff --git v3.15-rc5.orig/mm/Kconfig v3.15-rc5/mm/Kconfig
> index ebe5880c29d6..1e22701c972b 100644
> --- v3.15-rc5.orig/mm/Kconfig
> +++ v3.15-rc5/mm/Kconfig
> @@ -264,6 +264,9 @@ config MIGRATION
>  	  pages as migration can relocate pages to satisfy a huge page
>  	  allocation instead of reclaiming.
>  
> +config ARCH_ENABLE_HUGEPAGE_MIGRATION
> +	boolean
> +
>  config PHYS_ADDR_T_64BIT
>  	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
>  
> -- 
> 1.9.3
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
