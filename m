Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C59E66B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:29:13 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a2so181577325pgn.15
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 05:29:13 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v31si5606152plg.424.2017.07.25.05.29.12
        for <linux-mm@kvack.org>;
        Tue, 25 Jul 2017 05:29:12 -0700 (PDT)
Date: Tue, 25 Jul 2017 13:29:07 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH 1/2] mm/hugetlb: Make huge_pte_offset() consistent
 between PUD and PMD entries
Message-ID: <20170725122907.bvmubwcfmqalp6r3@localhost>
References: <20170724173318.966-1-punit.agrawal@arm.com>
 <20170724173318.966-2-punit.agrawal@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724173318.966-2-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, steve.capper@arm.com, will.deacon@arm.com, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>

Hi Punit,

On Mon, Jul 24, 2017 at 06:33:17PM +0100, Punit Agrawal wrote:
> When walking the page tables to resolve an address that points to
> !present_p*d() entry, huge_pte_offset() returns inconsistent values
> depending on the level of page table (PUD or PMD).
> 
> In the case of a PUD entry, it returns NULL while in the case of a PMD
> entry, it returns a pointer to the page table entry.
> 
> Make huge_pte_offset() consistent by always returning NULL on
> encountering a !present_p*d() entry. Document the behaviour to clarify
> the expected semantics of this function.

Nitpick: "p*d_present" instead of "present_p*d".

> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index bc48ee783dd9..686eb6fa9eb1 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4603,6 +4603,13 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
>  	return pte;
>  }
>  
> +/*
> + * huge_pte_offset() - Walk the page table to resolve the hugepage
> + * entry at address @addr
> + *
> + * Return: Pointer to page table entry (PUD or PMD) for address @addr
> + * or NULL if the entry is not present.
> + */
>  pte_t *huge_pte_offset(struct mm_struct *mm,
>  		       unsigned long addr, unsigned long sz)
>  {
> @@ -4617,13 +4624,20 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
>  	p4d = p4d_offset(pgd, addr);
>  	if (!p4d_present(*p4d))
>  		return NULL;
> +
>  	pud = pud_offset(p4d, addr);
>  	if (!pud_present(*pud))
>  		return NULL;
>  	if (pud_huge(*pud))
>  		return (pte_t *)pud;
> +
>  	pmd = pmd_offset(pud, addr);
> -	return (pte_t *) pmd;
> +	if (!pmd_present(*pmd))
> +		return NULL;

This breaks the current behaviour for swap entries in the pmd (for pud
is already broken but maybe no-one uses them). It is fixed in the
subsequent patch together with the pud but the series is no longer
bisectable. Maybe it's better if you fold the two patches together (or
change the order, though I'm not sure how readable it is).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
