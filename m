Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 94CC72806F4
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 13:14:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g13so55862341pfm.15
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 10:14:48 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 3si2538971plb.271.2017.08.22.10.14.47
        for <linux-mm@kvack.org>;
        Tue, 22 Aug 2017 10:14:47 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v7 5/9] arm64: hugetlb: Handle swap entries in huge_pte_offset() for contiguous hugepages
References: <20170822104249.2189-1-punit.agrawal@arm.com>
	<20170822104249.2189-6-punit.agrawal@arm.com>
	<20170822163504.pfhbibknppea6wyb@armageddon.cambridge.arm.com>
Date: Tue, 22 Aug 2017 18:14:43 +0100
In-Reply-To: <20170822163504.pfhbibknppea6wyb@armageddon.cambridge.arm.com>
	(Catalin Marinas's message of "Tue, 22 Aug 2017 17:35:05 +0100")
Message-ID: <87efs3msn0.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: will.deacon@arm.com, mark.rutland@arm.com, David Woods <dwoods@mellanox.com>, steve.capper@arm.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

Catalin Marinas <catalin.marinas@arm.com> writes:

> On Tue, Aug 22, 2017 at 11:42:45AM +0100, Punit Agrawal wrote:
>> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
>> index 594232598cac..b95e24dc3477 100644
>> --- a/arch/arm64/mm/hugetlbpage.c
>> +++ b/arch/arm64/mm/hugetlbpage.c
>> @@ -214,6 +214,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
>>  	pgd_t *pgd;
>>  	pud_t *pud;
>>  	pmd_t *pmd;
>> +	pte_t *pte;
>>  
>>  	pgd = pgd_offset(mm, addr);
>>  	pr_debug("%s: addr:0x%lx pgd:%p\n", __func__, addr, pgd);
>> @@ -221,19 +222,29 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
>>  		return NULL;
>>  
>>  	pud = pud_offset(pgd, addr);
>> -	if (pud_none(*pud))
>> +	if (sz != PUD_SIZE && pud_none(*pud))
>>  		return NULL;
>> -	/* swap or huge page */
>> -	if (!pud_present(*pud) || pud_huge(*pud))
>> +	/* hugepage or swap? */
>> +	if (pud_huge(*pud) || !pud_present(*pud))
>>  		return (pte_t *)pud;
>>  	/* table; check the next level */
>>  
>> +	if (sz == CONT_PMD_SIZE)
>> +		addr &= CONT_PMD_MASK;
>> +
>>  	pmd = pmd_offset(pud, addr);
>> -	if (pmd_none(*pmd))
>> +	if (!(sz == PMD_SIZE || sz == CONT_PMD_SIZE) &&
>> +	    pmd_none(*pmd))
>>  		return NULL;
>> -	if (!pmd_present(*pmd) || pmd_huge(*pmd))
>> +	if (pmd_huge(*pmd) || !pmd_present(*pmd))
>>  		return (pte_t *)pmd;
>>  
>> +	if (sz == CONT_PTE_SIZE) {
>> +		pte = pte_offset_kernel(
>> +			pmd, (addr & CONT_PTE_MASK));
>> +		return pte;
>> +	}
>> +
>>  	return NULL;
>>  }
>
> I merged the patch almost as is (with the pte variable but
> pte_offset_kernel() arguments on the same line); the pte variable is a
> minor personal preference, so I'm not going to argue either way ;)).
>
> Anyway, I pulled the whole series for 4.14, though I'll run some tests
> over the next day or so.

Thanks for picking up the patches. Hopefully, there won't be a need for
another revert this time around. :)

>
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
