Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 51EFF6B025F
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 07:20:23 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 123so165036560pga.5
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 04:20:23 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b14si3694806pll.905.2017.08.18.04.20.21
        for <linux-mm@kvack.org>;
        Fri, 18 Aug 2017 04:20:22 -0700 (PDT)
Date: Fri, 18 Aug 2017 12:20:16 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v6 5/9] arm64: hugetlb: Handle swap entries in
 huge_pte_offset() for contiguous hugepages
Message-ID: <20170818112015.2cvkb7y3gkozz5ip@armageddon.cambridge.arm.com>
References: <20170810170906.30772-1-punit.agrawal@arm.com>
 <20170810170906.30772-6-punit.agrawal@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810170906.30772-6-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: will.deacon@arm.com, mark.rutland@arm.com, David Woods <dwoods@mellanox.com>, steve.capper@arm.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

On Thu, Aug 10, 2017 at 06:09:02PM +0100, Punit Agrawal wrote:
> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
> index d3a6713048a2..09e79785c019 100644
> --- a/arch/arm64/mm/hugetlbpage.c
> +++ b/arch/arm64/mm/hugetlbpage.c
> @@ -210,6 +210,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
>  	pgd_t *pgd;
>  	pud_t *pud;
>  	pmd_t *pmd;
> +	pte_t *pte;
>  
>  	pgd = pgd_offset(mm, addr);
>  	pr_debug("%s: addr:0x%lx pgd:%p\n", __func__, addr, pgd);
> @@ -217,19 +218,29 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
>  		return NULL;
>  
>  	pud = pud_offset(pgd, addr);
> -	if (pud_none(*pud))
> +	if (pud_none(*pud) && sz != PUD_SIZE)
>  		return NULL;
>  	/* swap or huge page */
>  	if (!pud_present(*pud) || pud_huge(*pud))
>  		return (pte_t *)pud;
>  	/* table; check the next level */

So if sz == PUD_SIZE and we have pud_none(*pud) == true, it returns the
pud. Isn't this different from what you proposed for the generic
huge_pte_offset()? [1]

>  
> +	if (sz == CONT_PMD_SIZE)
> +		addr &= CONT_PMD_MASK;
> +
>  	pmd = pmd_offset(pud, addr);
> -	if (pmd_none(*pmd))
> +	if (pmd_none(*pmd) &&
> +	    !(sz == PMD_SIZE || sz == CONT_PMD_SIZE))
>  		return NULL;

Again, if sz == PMD_SIZE, you no longer return NULL. The generic
proposal in [1] looks like:

	if (pmd_none(*pmd))
		return NULL;

and that's even when sz == PMD_SIZE.

Anyway, I think we need to push for [1] again to be accepted before we
go ahead with these changes.

[1] http://lkml.kernel.org/r/20170725154114.24131-2-punit.agrawal@arm.com

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
