Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id B83AB6B0260
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:21:48 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id i12so88845353ywa.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:21:48 -0700 (PDT)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id g134si30317887wme.1.2016.07.13.08.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 08:21:47 -0700 (PDT)
Received: by mail-wm0-f44.google.com with SMTP id f126so33688827wma.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:21:47 -0700 (PDT)
Date: Wed, 13 Jul 2016 17:21:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] x86, pagetable: ignore A/D bits in pte/pmd/pud_none()
Message-ID: <20160713152145.GC20693@dhcp22.suse.cz>
References: <20160708001909.FB2443E2@viggo.jf.intel.com>
 <20160708001912.5216F89C@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160708001912.5216F89C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, dave.hansen@intel.com, dave.hansen@linux.intel.com

On Thu 07-07-16 17:19:12, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> The erratum we are fixing here can lead to stray setting of the
> A and D bits.  That means that a pte that we cleared might
> suddenly have A/D set.  So, stop considering those bits when
> determining if a pte is pte_none().  The same goes for the
> other pmd_none() and pud_none().  pgd_none() can be skipped
> because it is not affected; we do not use PGD entries for
> anything other than pagetables on affected configurations.
> 
> This adds a tiny amount of overhead to all pte_none() checks.
> I doubt we'll be able to measure it anywhere.

It would be better to introduce the overhead only for the affected
cpu models but I guess this is also acceptable. Would it be too
complicated to use alternatives for that?

> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Anyway
Acked-by: Michal Hocko <mhocko@suse.com>
> ---
> 
>  b/arch/x86/include/asm/pgtable.h       |   13 ++++++++++---
>  b/arch/x86/include/asm/pgtable_types.h |    6 ++++++
>  2 files changed, 16 insertions(+), 3 deletions(-)
> 
> diff -puN arch/x86/include/asm/pgtable.h~knl-strays-20-mod-pte-none arch/x86/include/asm/pgtable.h
> --- a/arch/x86/include/asm/pgtable.h~knl-strays-20-mod-pte-none	2016-07-07 17:17:43.974764976 -0700
> +++ b/arch/x86/include/asm/pgtable.h	2016-07-07 17:17:43.980765246 -0700
> @@ -480,7 +480,7 @@ pte_t *populate_extra_pte(unsigned long
>  
>  static inline int pte_none(pte_t pte)
>  {
> -	return !pte.pte;
> +	return !(pte.pte & ~(_PAGE_KNL_ERRATUM_MASK));
>  }
>  
>  #define __HAVE_ARCH_PTE_SAME
> @@ -552,7 +552,8 @@ static inline int pmd_none(pmd_t pmd)
>  {
>  	/* Only check low word on 32-bit platforms, since it might be
>  	   out of sync with upper half. */
> -	return (unsigned long)native_pmd_val(pmd) == 0;
> +	unsigned long val = native_pmd_val(pmd);
> +	return (val & ~_PAGE_KNL_ERRATUM_MASK) == 0;
>  }
>  
>  static inline unsigned long pmd_page_vaddr(pmd_t pmd)
> @@ -616,7 +617,7 @@ static inline unsigned long pages_to_mb(
>  #if CONFIG_PGTABLE_LEVELS > 2
>  static inline int pud_none(pud_t pud)
>  {
> -	return native_pud_val(pud) == 0;
> +	return (native_pud_val(pud) & ~(_PAGE_KNL_ERRATUM_MASK)) == 0;
>  }
>  
>  static inline int pud_present(pud_t pud)
> @@ -694,6 +695,12 @@ static inline int pgd_bad(pgd_t pgd)
>  
>  static inline int pgd_none(pgd_t pgd)
>  {
> +	/*
> +	 * There is no need to do a workaround for the KNL stray
> +	 * A/D bit erratum here.  PGDs only point to page tables
> +	 * except on 32-bit non-PAE which is not supported on
> +	 * KNL.
> +	 */
>  	return !native_pgd_val(pgd);
>  }
>  #endif	/* CONFIG_PGTABLE_LEVELS > 3 */
> diff -puN arch/x86/include/asm/pgtable_types.h~knl-strays-20-mod-pte-none arch/x86/include/asm/pgtable_types.h
> --- a/arch/x86/include/asm/pgtable_types.h~knl-strays-20-mod-pte-none	2016-07-07 17:17:43.976765066 -0700
> +++ b/arch/x86/include/asm/pgtable_types.h	2016-07-07 17:17:43.980765246 -0700
> @@ -70,6 +70,12 @@
>  			 _PAGE_PKEY_BIT2 | \
>  			 _PAGE_PKEY_BIT3)
>  
> +#if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
> +#define _PAGE_KNL_ERRATUM_MASK (_PAGE_DIRTY | _PAGE_ACCESSED)
> +#else
> +#define _PAGE_KNL_ERRATUM_MASK 0
> +#endif
> +
>  #ifdef CONFIG_KMEMCHECK
>  #define _PAGE_HIDDEN	(_AT(pteval_t, 1) << _PAGE_BIT_HIDDEN)
>  #else
> _

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
