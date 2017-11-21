Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C4A36B0038
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 16:59:45 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id t3so8323468vke.15
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 13:59:45 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id l81si4058478vkd.299.2017.11.21.13.59.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Nov 2017 13:59:44 -0800 (PST)
Message-ID: <1511301494.2466.25.camel@kernel.crashing.org>
Subject: Re: [PATCH v3 2/5] mm: switch to 'define pmd_write' instead of
 __HAVE_ARCH_PMD_WRITE
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 22 Nov 2017 08:58:14 +1100
In-Reply-To: <151129126721.37405.13339850900081557813.stgit@dwillia2-desk3.amr.corp.intel.com>
References: 
	<151129125625.37405.15953656230804875212.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <151129126721.37405.13339850900081557813.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Chris Metcalf <cmetcalf@mellanox.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Oliver OHalloran <oliveroh@au1.ibm.com>

On Tue, 2017-11-21 at 11:07 -0800, Dan Williams wrote:
> In response to compile breakage introduced by a series that added the
> pud_write helper to x86, Stephen notes:

+Aneesh, +Oliver.

>     did you consider using the other paradigm:
> 
>     In arch include files:
>     #define pud_write       pud_write
>     static inline int pud_write(pud_t pud)
>      .....
> 
>     Then in include/asm-generic/pgtable.h:
> 
>     #ifndef pud_write
>     tatic inline int pud_write(pud_t pud)
>     {
>             ....
>     }
>     #endif
> 
>     If you had, then the powerpc code would have worked ... ;-) and many
>     of the other interfaces in include/asm-generic/pgtable.h are
>     protected that way ...
> 
> Given that some architecture already define pmd_write() as a macro,
> it's a net reduction to drop the definition of
> __HAVE_ARCH_PMD_WRITE.
> 
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Chris Metcalf <cmetcalf@mellanox.com>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: <x86@kernel.org>
> Suggested-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/arm/include/asm/pgtable-3level.h        |    1 -
>  arch/arm64/include/asm/pgtable.h             |    1 -
>  arch/mips/include/asm/pgtable.h              |    2 +-
>  arch/powerpc/include/asm/book3s/64/pgtable.h |    1 -
>  arch/s390/include/asm/pgtable.h              |    2 +-
>  arch/sparc/include/asm/pgtable_64.h          |    2 +-
>  arch/tile/include/asm/pgtable.h              |    1 -
>  arch/x86/include/asm/pgtable.h               |    2 +-
>  include/asm-generic/pgtable.h                |    4 ++--
>  9 files changed, 6 insertions(+), 10 deletions(-)
> 
> diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
> index 2a029bceaf2f..1a7a17b2a1ba 100644
> --- a/arch/arm/include/asm/pgtable-3level.h
> +++ b/arch/arm/include/asm/pgtable-3level.h
> @@ -221,7 +221,6 @@ static inline pte_t pte_mkspecial(pte_t pte)
>  }
>  #define	__HAVE_ARCH_PTE_SPECIAL
>  
> -#define __HAVE_ARCH_PMD_WRITE
>  #define pmd_write(pmd)		(pmd_isclear((pmd), L_PMD_SECT_RDONLY))
>  #define pmd_dirty(pmd)		(pmd_isset((pmd), L_PMD_SECT_DIRTY))
>  #define pud_page(pud)		pmd_page(__pmd(pud_val(pud)))
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index c9530b5b5ca8..149d05fb9421 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -345,7 +345,6 @@ static inline int pmd_protnone(pmd_t pmd)
>  
>  #define pmd_thp_or_huge(pmd)	(pmd_huge(pmd) || pmd_trans_huge(pmd))
>  
> -#define __HAVE_ARCH_PMD_WRITE
>  #define pmd_write(pmd)		pte_write(pmd_pte(pmd))
>  
>  #define pmd_mkhuge(pmd)		(__pmd(pmd_val(pmd) & ~PMD_TABLE_BIT))
> diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgtable.h
> index 9e9e94415d08..1a508a74d48d 100644
> --- a/arch/mips/include/asm/pgtable.h
> +++ b/arch/mips/include/asm/pgtable.h
> @@ -552,7 +552,7 @@ static inline pmd_t pmd_mkhuge(pmd_t pmd)
>  extern void set_pmd_at(struct mm_struct *mm, unsigned long addr,
>  		       pmd_t *pmdp, pmd_t pmd);
>  
> -#define __HAVE_ARCH_PMD_WRITE
> +#define pmd_write pmd_write
>  static inline int pmd_write(pmd_t pmd)
>  {
>  	return !!(pmd_val(pmd) & _PAGE_WRITE);
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index 9a677cd5997f..44697817ccc6 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -1005,7 +1005,6 @@ static inline int pmd_protnone(pmd_t pmd)
>  }
>  #endif /* CONFIG_NUMA_BALANCING */
>  
> -#define __HAVE_ARCH_PMD_WRITE
>  #define pmd_write(pmd)		pte_write(pmd_pte(pmd))
>  #define __pmd_write(pmd)	__pte_write(pmd_pte(pmd))
>  #define pmd_savedwrite(pmd)	pte_savedwrite(pmd_pte(pmd))
> diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
> index d7fe9838084d..0a6b0286c32e 100644
> --- a/arch/s390/include/asm/pgtable.h
> +++ b/arch/s390/include/asm/pgtable.h
> @@ -709,7 +709,7 @@ static inline unsigned long pmd_pfn(pmd_t pmd)
>  	return (pmd_val(pmd) & origin_mask) >> PAGE_SHIFT;
>  }
>  
> -#define __HAVE_ARCH_PMD_WRITE
> +#define pmd_write pmd_write
>  static inline int pmd_write(pmd_t pmd)
>  {
>  	return (pmd_val(pmd) & _SEGMENT_ENTRY_WRITE) != 0;
> diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
> index 5a9e96be1665..9937c5ff94a9 100644
> --- a/arch/sparc/include/asm/pgtable_64.h
> +++ b/arch/sparc/include/asm/pgtable_64.h
> @@ -715,7 +715,7 @@ static inline unsigned long pmd_pfn(pmd_t pmd)
>  	return pte_pfn(pte);
>  }
>  
> -#define __HAVE_ARCH_PMD_WRITE
> +#define pmd_write pmd_write
>  static inline unsigned long pmd_write(pmd_t pmd)
>  {
>  	pte_t pte = __pte(pmd_val(pmd));
> diff --git a/arch/tile/include/asm/pgtable.h b/arch/tile/include/asm/pgtable.h
> index 2a26cc4fefc2..adfa21b18488 100644
> --- a/arch/tile/include/asm/pgtable.h
> +++ b/arch/tile/include/asm/pgtable.h
> @@ -475,7 +475,6 @@ static inline void pmd_clear(pmd_t *pmdp)
>  #define pmd_mkdirty(pmd)	pte_pmd(pte_mkdirty(pmd_pte(pmd)))
>  #define pmd_huge_page(pmd)	pte_huge(pmd_pte(pmd))
>  #define pmd_mkhuge(pmd)		pte_pmd(pte_mkhuge(pmd_pte(pmd)))
> -#define __HAVE_ARCH_PMD_WRITE
>  
>  #define pfn_pmd(pfn, pgprot)	pte_pmd(pfn_pte((pfn), (pgprot)))
>  #define pmd_pfn(pmd)		pte_pfn(pmd_pte(pmd))
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index dcce76ee4aa7..95e2dfd75521 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -1061,7 +1061,7 @@ extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
>  				  unsigned long address, pmd_t *pmdp);
>  
>  
> -#define __HAVE_ARCH_PMD_WRITE
> +#define pmd_write pmd_write
>  static inline int pmd_write(pmd_t pmd)
>  {
>  	return pmd_flags(pmd) & _PAGE_RW;
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 1ac457511f4e..b234d54f2cb6 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -805,13 +805,13 @@ static inline int pmd_trans_huge(pmd_t pmd)
>  {
>  	return 0;
>  }
> -#ifndef __HAVE_ARCH_PMD_WRITE
> +#ifndef pmd_write
>  static inline int pmd_write(pmd_t pmd)
>  {
>  	BUG();
>  	return 0;
>  }
> -#endif /* __HAVE_ARCH_PMD_WRITE */
> +#endif /* pmd_write */
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  
>  #ifndef pud_write

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
