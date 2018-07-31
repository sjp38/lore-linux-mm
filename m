Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F36016B0003
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 06:06:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q21-v6so4542938pff.21
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 03:06:43 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id l18-v6si13005292pgg.152.2018.07.31.03.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 31 Jul 2018 03:06:38 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v5 09/11] hugetlb: Introduce generic version of huge_ptep_set_wrprotect
In-Reply-To: <20180731060155.16915-10-alex@ghiti.fr>
References: <20180731060155.16915-1-alex@ghiti.fr> <20180731060155.16915-10-alex@ghiti.fr>
Date: Tue, 31 Jul 2018 20:06:35 +1000
Message-ID: <87h8kfhg7o.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandre Ghiti <alex@ghiti.fr>, linux-mm@kvack.org, mike.kravetz@oracle.com, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, aneesh.kumar@linux.ibm.comaneesh.kumar@linux.ibm.com

Alexandre Ghiti <alex@ghiti.fr> writes:

> arm, ia64, mips, sh, x86 architectures use the same version
> of huge_ptep_set_wrprotect, so move this generic implementation into
> asm-generic/hugetlb.h.
> Note: powerpc uses twice for book3s/32 and nohash/32 the same version as
> the above architectures, but the modification was not straightforward
> and hence has not been done.

Do you remember what the problem was there?

It looks like you should just be able to drop them like the others. I
assume there's some header spaghetti that causes problems though?

cheers


> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  arch/arm/include/asm/hugetlb-3level.h        | 6 ------
>  arch/arm64/include/asm/hugetlb.h             | 1 +
>  arch/ia64/include/asm/hugetlb.h              | 6 ------
>  arch/mips/include/asm/hugetlb.h              | 6 ------
>  arch/parisc/include/asm/hugetlb.h            | 1 +
>  arch/powerpc/include/asm/book3s/32/pgtable.h | 2 ++
>  arch/powerpc/include/asm/book3s/64/pgtable.h | 1 +
>  arch/powerpc/include/asm/nohash/32/pgtable.h | 2 ++
>  arch/powerpc/include/asm/nohash/64/pgtable.h | 1 +
>  arch/sh/include/asm/hugetlb.h                | 6 ------
>  arch/sparc/include/asm/hugetlb.h             | 1 +
>  arch/x86/include/asm/hugetlb.h               | 6 ------
>  include/asm-generic/hugetlb.h                | 8 ++++++++
>  13 files changed, 17 insertions(+), 30 deletions(-)
>
> diff --git a/arch/arm/include/asm/hugetlb-3level.h b/arch/arm/include/asm/hugetlb-3level.h
> index b897541520ef..8247cd6a2ac6 100644
> --- a/arch/arm/include/asm/hugetlb-3level.h
> +++ b/arch/arm/include/asm/hugetlb-3level.h
> @@ -37,12 +37,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
>  	return retval;
>  }
>  
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> -					   unsigned long addr, pte_t *ptep)
> -{
> -	ptep_set_wrprotect(mm, addr, ptep);
> -}
> -
>  static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>  					     unsigned long addr, pte_t *ptep,
>  					     pte_t pte, int dirty)
> diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
> index 3e7f6e69b28d..f4f69ae5466e 100644
> --- a/arch/arm64/include/asm/hugetlb.h
> +++ b/arch/arm64/include/asm/hugetlb.h
> @@ -48,6 +48,7 @@ extern int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>  #define __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
>  extern pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
>  				     unsigned long addr, pte_t *ptep);
> +#define __HAVE_ARCH_HUGE_PTEP_SET_WRPROTECT
>  extern void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  				    unsigned long addr, pte_t *ptep);
>  #define __HAVE_ARCH_HUGE_PTEP_CLEAR_FLUSH
> diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
> index cbe296271030..49d1f7949f3a 100644
> --- a/arch/ia64/include/asm/hugetlb.h
> +++ b/arch/ia64/include/asm/hugetlb.h
> @@ -27,12 +27,6 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
>  {
>  }
>  
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> -					   unsigned long addr, pte_t *ptep)
> -{
> -	ptep_set_wrprotect(mm, addr, ptep);
> -}
> -
>  static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>  					     unsigned long addr, pte_t *ptep,
>  					     pte_t pte, int dirty)
> diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
> index 6ff2531cfb1d..3dcf5debf8c4 100644
> --- a/arch/mips/include/asm/hugetlb.h
> +++ b/arch/mips/include/asm/hugetlb.h
> @@ -63,12 +63,6 @@ static inline int huge_pte_none(pte_t pte)
>  	return !val || (val == (unsigned long)invalid_pte_table);
>  }
>  
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> -					   unsigned long addr, pte_t *ptep)
> -{
> -	ptep_set_wrprotect(mm, addr, ptep);
> -}
> -
>  static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>  					     unsigned long addr,
>  					     pte_t *ptep, pte_t pte,
> diff --git a/arch/parisc/include/asm/hugetlb.h b/arch/parisc/include/asm/hugetlb.h
> index fb7e0fd858a3..9c3950ca2974 100644
> --- a/arch/parisc/include/asm/hugetlb.h
> +++ b/arch/parisc/include/asm/hugetlb.h
> @@ -39,6 +39,7 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
>  {
>  }
>  
> +#define __HAVE_ARCH_HUGE_PTEP_SET_WRPROTECT
>  void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  					   unsigned long addr, pte_t *ptep);
>  
> diff --git a/arch/powerpc/include/asm/book3s/32/pgtable.h b/arch/powerpc/include/asm/book3s/32/pgtable.h
> index 02f5acd7ccc4..d2cd1d0226e9 100644
> --- a/arch/powerpc/include/asm/book3s/32/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/32/pgtable.h
> @@ -228,6 +228,8 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
>  {
>  	pte_update(ptep, (_PAGE_RW | _PAGE_HWWRITE), _PAGE_RO);
>  }
> +
> +#define __HAVE_ARCH_HUGE_PTEP_SET_WRPROTECT
>  static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  					   unsigned long addr, pte_t *ptep)
>  {
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index 42aafba7a308..7d957f7c47cd 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -451,6 +451,7 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
>  		pte_update(mm, addr, ptep, 0, _PAGE_PRIVILEGED, 0);
>  }
>  
> +#define __HAVE_ARCH_HUGE_PTEP_SET_WRPROTECT
>  static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  					   unsigned long addr, pte_t *ptep)
>  {
> diff --git a/arch/powerpc/include/asm/nohash/32/pgtable.h b/arch/powerpc/include/asm/nohash/32/pgtable.h
> index 7c46a98cc7f4..f39e200d9591 100644
> --- a/arch/powerpc/include/asm/nohash/32/pgtable.h
> +++ b/arch/powerpc/include/asm/nohash/32/pgtable.h
> @@ -249,6 +249,8 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
>  {
>  	pte_update(ptep, (_PAGE_RW | _PAGE_HWWRITE), _PAGE_RO);
>  }
> +
> +#define __HAVE_ARCH_HUGE_PTEP_SET_WRPROTECT
>  static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  					   unsigned long addr, pte_t *ptep)
>  {
> diff --git a/arch/powerpc/include/asm/nohash/64/pgtable.h b/arch/powerpc/include/asm/nohash/64/pgtable.h
> index dd0c7236208f..69fbf7e9b4db 100644
> --- a/arch/powerpc/include/asm/nohash/64/pgtable.h
> +++ b/arch/powerpc/include/asm/nohash/64/pgtable.h
> @@ -238,6 +238,7 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
>  	pte_update(mm, addr, ptep, _PAGE_RW, 0, 0);
>  }
>  
> +#define __HAVE_ARCH_HUGE_PTEP_SET_WRPROTECT
>  static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  					   unsigned long addr, pte_t *ptep)
>  {
> diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
> index f1bbd255ee43..8df4004977b9 100644
> --- a/arch/sh/include/asm/hugetlb.h
> +++ b/arch/sh/include/asm/hugetlb.h
> @@ -32,12 +32,6 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
>  {
>  }
>  
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> -					   unsigned long addr, pte_t *ptep)
> -{
> -	ptep_set_wrprotect(mm, addr, ptep);
> -}
> -
>  static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>  					     unsigned long addr, pte_t *ptep,
>  					     pte_t pte, int dirty)
> diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
> index 2101ea217f33..c41754a113f3 100644
> --- a/arch/sparc/include/asm/hugetlb.h
> +++ b/arch/sparc/include/asm/hugetlb.h
> @@ -32,6 +32,7 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
>  {
>  }
>  
> +#define __HAVE_ARCH_HUGE_PTEP_SET_WRPROTECT
>  static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  					   unsigned long addr, pte_t *ptep)
>  {
> diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
> index 59c056adb3c9..a3f781f7a264 100644
> --- a/arch/x86/include/asm/hugetlb.h
> +++ b/arch/x86/include/asm/hugetlb.h
> @@ -13,12 +13,6 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
>  	return 0;
>  }
>  
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> -					   unsigned long addr, pte_t *ptep)
> -{
> -	ptep_set_wrprotect(mm, addr, ptep);
> -}
> -
>  static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>  					     unsigned long addr, pte_t *ptep,
>  					     pte_t pte, int dirty)
> diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
> index 6c0c8b0c71e0..9b9039845278 100644
> --- a/include/asm-generic/hugetlb.h
> +++ b/include/asm-generic/hugetlb.h
> @@ -102,4 +102,12 @@ static inline int prepare_hugepage_range(struct file *file,
>  }
>  #endif
>  
> +#ifndef __HAVE_ARCH_HUGE_PTEP_SET_WRPROTECT
> +static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +		unsigned long addr, pte_t *ptep)
> +{
> +	ptep_set_wrprotect(mm, addr, ptep);
> +}
> +#endif
> +
>  #endif /* _ASM_GENERIC_HUGETLB_H */
> -- 
> 2.16.2
