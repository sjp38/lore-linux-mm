Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id DCEE46B025F
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:51:36 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id 184so124667769pff.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 06:51:36 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id y26si3647542pfi.70.2016.04.11.06.51.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 06:51:36 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id ot11so38526018pab.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 06:51:36 -0700 (PDT)
Subject: Re: [PATCH 05/10] powerpc/hugetlb: Split the function
 'huge_pte_alloc'
References: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1460007464-26726-6-git-send-email-khandual@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <570BABD8.5080703@gmail.com>
Date: Mon, 11 Apr 2016 23:51:20 +1000
MIME-Version: 1.0
In-Reply-To: <1460007464-26726-6-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au



On 07/04/16 15:37, Anshuman Khandual wrote:
> Currently the function 'huge_pte_alloc' has got two versions, one for the
> BOOK3S server and the other one for the BOOK3E embedded platforms. This
> change splits only the BOOK3S server version into two parts, one for the
> ARCH_WANT_GENERAL_HUGETLB config implementation and the other one for
> everything else. This change is one of the prerequisites towards enabling
> ARCH_WANT_GENERAL_HUGETLB config option on POWER platform.
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  arch/powerpc/mm/hugetlbpage.c | 67 +++++++++++++++++++++++++++----------------
>  1 file changed, 43 insertions(+), 24 deletions(-)
> 
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> index d991b9e..e453918 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
> @@ -59,6 +59,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
>  	return __find_linux_pte_or_hugepte(mm->pgd, addr, NULL, NULL);
>  }
>  
> +#ifndef CONFIG_ARCH_WANT_GENERAL_HUGETLB
>  static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>  			   unsigned long address, unsigned pdshift, unsigned pshift)
>  {
> @@ -116,6 +117,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>  	spin_unlock(&mm->page_table_lock);
>  	return 0;
>  }
> +#endif /* !CONFIG_ARCH_WANT_GENERAL_HUGETLB */
>  
>  /*
>   * These macros define how to determine which level of the page table holds
> @@ -130,6 +132,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>  #endif
>  
>  #ifdef CONFIG_PPC_BOOK3S_64
> +#ifndef CONFIG_ARCH_WANT_GENERAL_HUGETLB
>  /*
>   * At this point we do the placement change only for BOOK3S 64. This would
>   * possibly work on other subarchs.
> @@ -145,32 +148,23 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz
>  
>  	addr &= ~(sz-1);
>  	pg = pgd_offset(mm, addr);
> -
> -	if (pshift == PGDIR_SHIFT)
> -		/* 16GB huge page */
> -		return (pte_t *) pg;
> -	else if (pshift > PUD_SHIFT)
> -		/*
> -		 * We need to use hugepd table
> -		 */
> +	if (pshift > PUD_SHIFT) {
>  		hpdp = (hugepd_t *)pg;
> -	else {
> -		pdshift = PUD_SHIFT;
> -		pu = pud_alloc(mm, pg, addr);
> -		if (pshift == PUD_SHIFT)
> -			return (pte_t *)pu;
> -		else if (pshift > PMD_SHIFT)
> -			hpdp = (hugepd_t *)pu;
> -		else {
> -			pdshift = PMD_SHIFT;
> -			pm = pmd_alloc(mm, pu, addr);
> -			if (pshift == PMD_SHIFT)
> -				/* 16MB hugepage */
> -				return (pte_t *)pm;
> -			else
> -				hpdp = (hugepd_t *)pm;
> -		}
> +		goto hugepd_search;
>  	}
> +
> +	pdshift = PUD_SHIFT;
> +	pu = pud_alloc(mm, pg, addr);
> +	if (pshift > PMD_SHIFT) {
> +		hpdp = (hugepd_t *)pu;
> +		goto hugepd_search;
> +	}
> +
> +	pdshift = PMD_SHIFT;
> +	pm = pmd_alloc(mm, pu, addr);
> +	hpdp = (hugepd_t *)pm;
> +
> +hugepd_search:
>  	if (!hpdp)
>  		return NULL;
>  
> @@ -182,6 +176,31 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz
>  	return hugepte_offset(*hpdp, addr, pdshift);
>  }
>  
> +#else /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)

This is confusing, aren't we using the one from mm/hugetlb.c?

> +{
> +	pgd_t *pg;
> +	pud_t *pu;
> +	pmd_t *pm;
> +	unsigned pshift = __ffs(sz);
> +
> +	addr &= ~(sz-1);

Am I reading this right? Shouldn't this be addr &= ~(1 << pshift - 1)

> +	pg = pgd_offset(mm, addr);
> +
> +	if (pshift == PGDIR_SHIFT)	/* 16GB Huge Page */
> +		return (pte_t *)pg;
> +
> +	pu = pud_alloc(mm, pg, addr);	/* NA, skipped */
> +	if (pshift == PUD_SHIFT)
> +		return (pte_t *)pu;
> +
> +	pm = pmd_alloc(mm, pu, addr);	/* 16MB Huge Page */
> +	if (pshift == PMD_SHIFT)
> +		return (pte_t *)pm;
> +
> +	return NULL;
> +}
> +#endif /* !CONFIG_ARCH_WANT_GENERAL_HUGETLB */
>  #else
>  
>  pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
