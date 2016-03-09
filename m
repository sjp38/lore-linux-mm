Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id D8F776B0253
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 14:58:59 -0500 (EST)
Received: by mail-qg0-f54.google.com with SMTP id w104so51614375qge.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 11:58:59 -0800 (PST)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id v18si201790qka.81.2016.03.09.11.58.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 11:58:59 -0800 (PST)
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 9 Mar 2016 12:58:58 -0700
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 6C7ED19D8041
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 12:46:50 -0700 (MST)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u29JwsqR27394180
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 19:58:54 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u29JsNtL030170
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 14:54:24 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC 6/9] powerpc/hugetlb: Enable ARCH_WANT_GENERAL_HUGETLB for BOOK3S 64K
In-Reply-To: <1457525450-4262-6-git-send-email-khandual@linux.vnet.ibm.com>
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com> <1457525450-4262-6-git-send-email-khandual@linux.vnet.ibm.com>
Date: Thu, 10 Mar 2016 01:28:48 +0530
Message-ID: <8760wv1kzr.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mpe@ellerman.id.au

Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:

> [ text/plain ]
> This enables ARCH_WANT_GENERAL_HUGETLB for BOOK3S 64K in Kconfig.
> It also implements a new function 'pte_huge' which is required by
> function 'huge_pte_alloc' from generic VM. Existing BOOK3S 64K
> specific functions 'huge_pte_alloc' and 'huge_pte_offset' (which
> are no longer required) are removed with this change.
>

You want this to be the last patch isn't it ? And you are mixing too
many things in this patch. Why not do this

* book3s specific hash pte routines
* book3s add conditional based on GENERAL_HUGETLB
* Enable GENERAL_HUGETLB for 64k page size config

> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  arch/powerpc/Kconfig                          |  4 ++
>  arch/powerpc/include/asm/book3s/64/hash-64k.h |  8 ++++
>  arch/powerpc/mm/hugetlbpage.c                 | 60 ---------------------------
>  3 files changed, 12 insertions(+), 60 deletions(-)
>
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 9faa18c..c6920bb 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -33,6 +33,10 @@ config HAVE_SETUP_PER_CPU_AREA
>  config NEED_PER_CPU_EMBED_FIRST_CHUNK
>  	def_bool PPC64
>
> +config ARCH_WANT_GENERAL_HUGETLB
> +	depends on PPC_64K_PAGES && PPC_BOOK3S_64
> +	def_bool y
> +
>  config NR_IRQS
>  	int "Number of virtual interrupt numbers"
>  	range 32 32768
> diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
> index 849bbec..5e9b9b9 100644
> --- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
> +++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
> @@ -143,6 +143,14 @@ extern bool __rpte_sub_valid(real_pte_t rpte, unsigned long index);
>   * Defined in such a way that we can optimize away code block at build time
>   * if CONFIG_HUGETLB_PAGE=n.
>   */
> +static inline int pte_huge(pte_t pte)
> +{
> +	/*
> +	 * leaf pte for huge page
> +	 */
> +	return !!(pte_val(pte) & _PAGE_PTE);
> +}
> +
>  static inline int pmd_huge(pmd_t pmd)
>  {
>  	/*
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> index f834a74..f6e4712 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
> @@ -59,42 +59,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
>  	/* Only called for hugetlbfs pages, hence can ignore THP */
>  	return __find_linux_pte_or_hugepte(mm->pgd, addr, NULL, NULL);
>  }
> -#else
> -pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
> -{
> -	pgd_t pgd, *pgdp;
> -	pud_t pud, *pudp;
> -	pmd_t pmd, *pmdp;
> -
> -	pgdp = mm->pgd + pgd_index(addr);
> -	pgd  = READ_ONCE(*pgdp);
> -
> -	if (pgd_none(pgd))
> -		return NULL;
> -
> -	if (pgd_huge(pgd))
> -		return (pte_t *)pgdp;
> -
> -	pudp = pud_offset(&pgd, addr);
> -	pud  = READ_ONCE(*pudp);
> -	if (pud_none(pud))
> -		return NULL;
> -
> -	if (pud_huge(pud))
> -		return (pte_t *)pudp;
>
> -	pmdp = pmd_offset(&pud, addr);
> -	pmd  = READ_ONCE(*pmdp);
> -	if (pmd_none(pmd))
> -		return NULL;
> -
> -	if (pmd_huge(pmd))
> -		return (pte_t *)pmdp;
> -	return NULL;
> -}
> -#endif /* !defined(CONFIG_PPC_64K_PAGES) || !defined(CONFIG_PPC_BOOK3S_64) */
> -
> -#if !defined(CONFIG_PPC_64K_PAGES) || !defined(CONFIG_PPC_BOOK3S_64)
>  static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>  			   unsigned long address, unsigned pdshift, unsigned pshift)
>  {
> @@ -211,31 +176,6 @@ hugepd_search:
>
>  	return hugepte_offset(*hpdp, addr, pdshift);
>  }
> -
> -#else
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
> -{
> -	pgd_t *pg;
> -	pud_t *pu;
> -	pmd_t *pm;
> -	unsigned pshift = __ffs(sz);
> -
> -	addr &= ~(sz-1);
> -	pg = pgd_offset(mm, addr);
> -
> -	if (pshift == PGDIR_SHIFT)	/* 16GB Huge Page */
> -		return (pte_t *)pg;
> -
> -	pu = pud_alloc(mm, pg, addr);	/* NA, skipped */
> -	if (pshift == PUD_SHIFT)
> -		return (pte_t *)pu;
> -
> -	pm = pmd_alloc(mm, pu, addr);	/* 16MB Huge Page */
> -	if (pshift == PMD_SHIFT)
> -		return (pte_t *)pm;
> -
> -	return NULL;
> -}
>  #endif
>  #else
>
> -- 
> 2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
