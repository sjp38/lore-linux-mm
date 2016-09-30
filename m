Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC526B0038
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 01:18:27 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 188so30876216iti.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 22:18:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a73si3003114wme.1.2016.09.29.22.18.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 22:18:21 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8U5HTUw077408
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 01:18:19 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25sgqstajd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 01:18:19 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 29 Sep 2016 23:18:18 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v1 12/12] mm: ppc64: Add THP migration support for ppc64.
In-Reply-To: <20160926152234.14809-13-zi.yan@sent.com>
References: <20160926152234.14809-1-zi.yan@sent.com> <20160926152234.14809-13-zi.yan@sent.com>
Date: Fri, 30 Sep 2016 10:48:09 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87k2duaru6.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zi.yan@sent.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, Zi Yan <zi.yan@cs.rutgers.edu>

zi.yan@sent.com writes:

> From: Zi Yan <zi.yan@cs.rutgers.edu>
>
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  arch/powerpc/Kconfig                         |  4 ++++
>  arch/powerpc/include/asm/book3s/64/pgtable.h | 23 +++++++++++++++++++++++
>  2 files changed, 27 insertions(+)
>
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 927d2ab..84ffd4c 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -553,6 +553,10 @@ config ARCH_SPARSEMEM_DEFAULT
>  config SYS_SUPPORTS_HUGETLBFS
>  	bool
>  
> +config ARCH_ENABLE_THP_MIGRATION
> +	def_bool y
> +	depends on PPC64 && TRANSPARENT_HUGEPAGE && MIGRATION
> +
>  source "mm/Kconfig"
>  
>  config ARCH_MEMORY_PROBE
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index 263bf39..9dee0467 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -521,7 +521,9 @@ static inline bool pte_user(pte_t pte)
>   * Clear bits not found in swap entries here.
>   */
>  #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val((pte)) & ~_PAGE_PTE })
> +#define __pmd_to_swp_entry(pte)	((swp_entry_t) { pmd_val((pte)) & ~_PAGE_PTE })
>  #define __swp_entry_to_pte(x)	__pte((x).val | _PAGE_PTE)
> +#define __swp_entry_to_pmd(x)	__pmd((x).val | _PAGE_PTE)


We definitely need a comment around that. This will work only for 64K
linux page size, on 4k we may consider it a hugepd directory entry. But
This should be ok because we support THP only with 64K linux page size.
Hence my suggestion to add proper comments or move it to right headers.


>  
>  #ifdef CONFIG_MEM_SOFT_DIRTY
>  #define _PAGE_SWP_SOFT_DIRTY   (1UL << (SWP_TYPE_BITS + _PAGE_BIT_SWAP_TYPE))
> @@ -662,6 +664,10 @@ static inline int pmd_bad(pmd_t pmd)
>  		return radix__pmd_bad(pmd);
>  	return hash__pmd_bad(pmd);
>  }
> +static inline int __pmd_present(pmd_t pte)
> +{
> +	return !!(pmd_val(pte) & _PAGE_PRESENT);
> +}
>  
>  static inline void pud_set(pud_t *pudp, unsigned long val)
>  {
> @@ -850,6 +856,23 @@ static inline pte_t *pmdp_ptep(pmd_t *pmd)
>  #define pmd_soft_dirty(pmd)    pte_soft_dirty(pmd_pte(pmd))
>  #define pmd_mksoft_dirty(pmd)  pte_pmd(pte_mksoft_dirty(pmd_pte(pmd)))
>  #define pmd_clear_soft_dirty(pmd) pte_pmd(pte_clear_soft_dirty(pmd_pte(pmd)))
> +
> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> +static inline pmd_t pmd_swp_mksoft_dirty(pmd_t pmd)
> +{
> +	return pte_pmd(pte_swp_mksoft_dirty(pmd_pte(pmd)));
> +}
> +
> +static inline int pmd_swp_soft_dirty(pmd_t pmd)
> +{
> +	return pte_swp_soft_dirty(pmd_pte(pmd));
> +}
> +
> +static inline pmd_t pmd_swp_clear_soft_dirty(pmd_t pmd)
> +{
> +	return pte_pmd(pte_swp_clear_soft_dirty(pmd_pte(pmd)));
> +}
> +#endif
>  #endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
>  
>  #ifdef CONFIG_NUMA_BALANCING

Did we test this with Radix config ? If not I will suggest we hold off
the ppc64 patch and you can merge rest of the changes.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
