Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2800D6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 18:06:16 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id p10so203465pdj.7
        for <linux-mm@kvack.org>; Thu, 29 May 2014 15:06:15 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id xj7si2725929pbc.33.2014.05.29.15.06.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 15:06:15 -0700 (PDT)
Received: by mail-pd0-f170.google.com with SMTP id g10so206198pdj.29
        for <linux-mm@kvack.org>; Thu, 29 May 2014 15:06:14 -0700 (PDT)
Date: Thu, 29 May 2014 15:04:57 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] hugetlb: restrict hugepage_migration_support() to x86_64
 (Re: BUG at mm/memory.c:1489!)
In-Reply-To: <53877dd1.0350c20a.2dde.ffff99d7SMTPIN_ADDED_BROKEN@mx.google.com>
Message-ID: <alpine.LSU.2.11.1405291408430.10286@eggly.anvils>
References: <1401265922.3355.4.camel@concordia> <alpine.LSU.2.11.1405281712310.7156@eggly.anvils> <1401353983.4930.15.camel@concordia> <53877dd1.0350c20a.2dde.ffff99d7SMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: mpe@ellerman.id.au, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, benh@kernel.crashing.org, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, trinity@vger.kernel.org

On Thu, 29 May 2014, Naoya Horiguchi wrote:
> 
> Curretly hugepage migration is available for all archs which support pmd-level
> hugepage, but testing is done only for x86_64 and there're bugs for other archs.

And even for x86_64 I think: the follow_huge_pmd() locking issue I
mentioned.  But I agree that's a different kind of bug, and probably
not cause to disable the feature even on x86_64 at this stage - but
cause to fix it in a different patch Cc stable when you have a moment.

> So to avoid breaking such archs, this patch limits the availability strictly to
> x86_64 until developers of other archs get interested in enabling this feature.

Hmm, I don't like the sound of "until developers of other archs get
interested in enabling this feature".  Your choice, I suppose, but I
had been expecting you to give them a little more help than that, by
fixing up the follow_huge_addr() and locking as you expect it to be
(and whatever Michael's subsequent remove_migration_pte() crash comes
from - maybe obvious with a little thought, but I haven't), then
pinging those architectures to give it a try and enable if they wish.

Perhaps I'm expecting too much, and you haven't the time; doubt I have.

I believe your patch below is incomplete, or perhaps you were
expecting to layer it on top of my follow_huge_addr get_page one.
No, I think we should throw mine away if you're going to disable
the feature on most architectures for now (and once the locking is
corrected, my get_page after follow_huge_addr will be wrong anyway).

What I think you're missing is an adjustment to your 71ea2efb1e93
("mm: migrate: remove VM_HUGETLB from vma flag check in vma_migratable()"):
doesn't vma_migratable() need to test VM_HUGETLB when
!CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION?  Then we are saved from
reaching the follow_huge_addr() BUG; and avoid the weird preparation
for migrating HUGETLB pages on architectures which do not support it.

But yes, I think your disablement approach is the right thing for 3.15.

> 
> Reported-by: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org # 3.12+
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
>  include/linux/hugetlb.h       | 10 ++++++----
>  mm/Kconfig                    |  3 +++
>  14 files changed, 13 insertions(+), 69 deletions(-)
> 
> diff --git a/arch/arm/mm/hugetlbpage.c b/arch/arm/mm/hugetlbpage.c
> index 54ee6163c181..66781bf34077 100644
> --- a/arch/arm/mm/hugetlbpage.c
> +++ b/arch/arm/mm/hugetlbpage.c
> @@ -56,8 +56,3 @@ int pmd_huge(pmd_t pmd)
>  {
>  	return pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT);
>  }
> -
> -int pmd_huge_support(void)
> -{
> -	return 1;
> -}
> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
> index 5e9aec358306..2fc8258bab2d 100644
> --- a/arch/arm64/mm/hugetlbpage.c
> +++ b/arch/arm64/mm/hugetlbpage.c
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
> diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
> index 68232db98baa..76069c18ee42 100644
> --- a/arch/ia64/mm/hugetlbpage.c
> +++ b/arch/ia64/mm/hugetlbpage.c
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
> diff --git a/arch/metag/mm/hugetlbpage.c b/arch/metag/mm/hugetlbpage.c
> index 042431509b56..3c52fa6d0f8e 100644
> --- a/arch/metag/mm/hugetlbpage.c
> +++ b/arch/metag/mm/hugetlbpage.c
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
> diff --git a/arch/mips/mm/hugetlbpage.c b/arch/mips/mm/hugetlbpage.c
> index 77e0ae036e7c..4ec8ee10d371 100644
> --- a/arch/mips/mm/hugetlbpage.c
> +++ b/arch/mips/mm/hugetlbpage.c
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
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> index eb923654ba80..7e70ae968e5f 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
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
> diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
> index 0727a55d87d9..0ff66a7e29bb 100644
> --- a/arch/s390/mm/hugetlbpage.c
> +++ b/arch/s390/mm/hugetlbpage.c
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
> diff --git a/arch/sh/mm/hugetlbpage.c b/arch/sh/mm/hugetlbpage.c
> index 0d676a41081e..d7762349ea48 100644
> --- a/arch/sh/mm/hugetlbpage.c
> +++ b/arch/sh/mm/hugetlbpage.c
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
> diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
> index 9bd9ce80bf77..d329537739c6 100644
> --- a/arch/sparc/mm/hugetlbpage.c
> +++ b/arch/sparc/mm/hugetlbpage.c
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
> diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
> index 0cb3bbaa580c..e514899e1100 100644
> --- a/arch/tile/mm/hugetlbpage.c
> +++ b/arch/tile/mm/hugetlbpage.c
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
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 25d2c6f7325e..0cf6a7d0a93e 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1871,6 +1871,10 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
>  	def_bool y
>  	depends on X86_64 || X86_PAE
>  
> +config ARCH_ENABLE_HUGEPAGE_MIGRATION
> +	def_bool y
> +	depends on X86_64 || MIGRATION
> +

Should that be X86_64 && MIGRATION?  X86_64 && HUGETLB_PAGE && MIGRATION?
Maybe it doesn't matter.

Yes, I agree a per-arch config option is better than all those
pmd_huge_support() functions, especially all the ones saying 0.

>  menu "Power management and ACPI options"
>  
>  config ARCH_HIBERNATION_HEADER
> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> index 8c9f647ff9e1..8b977ebf9388 100644
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
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
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 63214868c5b2..61c2e349af64 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -385,15 +385,18 @@ static inline pgoff_t basepage_index(struct page *page)
>  
>  extern void dissolve_free_huge_pages(unsigned long start_pfn,
>  				     unsigned long end_pfn);
> -int pmd_huge_support(void);
>  /*
> - * Currently hugepage migration is enabled only for pmd-based hugepage.
> + * Currently hugepage migration is enabled only for x86_64.

You don't want to have to update that comment every time an architecture
opts in.  No need for any comment here, I think, the name is good enough
(though hugepage_migration_supported() would be better).

>   * This function will be updated when hugepage migration is more widely
>   * supported.
>   */
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
> @@ -443,7 +446,6 @@ static inline pgoff_t basepage_index(struct page *page)
>  	return page->index;
>  }
>  #define dissolve_free_huge_pages(s, e)	do {} while (0)
> -#define pmd_huge_support()	0
>  #define hugepage_migration_support(h)	0
>  
>  static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
> diff --git a/mm/Kconfig b/mm/Kconfig
> index ebe5880c29d6..1e22701c972b 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -264,6 +264,9 @@ config MIGRATION
>  	  pages as migration can relocate pages to satisfy a huge page
>  	  allocation instead of reclaiming.
>  
> +config ARCH_ENABLE_HUGEPAGE_MIGRATION
> +	boolean
> +

I don't remember how duplicated config entries work,
so cannot comment on that.

>  config PHYS_ADDR_T_64BIT
>  	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
>  
> -- 
> 1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
