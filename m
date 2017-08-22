Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 06DDD2806D2
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 10:42:01 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id r133so322914128pgr.6
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 07:42:00 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 20si2522354pfm.547.2017.08.22.07.41.59
        for <linux-mm@kvack.org>;
        Tue, 22 Aug 2017 07:41:59 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v7 5/9] arm64: hugetlb: Handle swap entries in huge_pte_offset() for contiguous hugepages
References: <20170822104249.2189-1-punit.agrawal@arm.com>
	<20170822104249.2189-6-punit.agrawal@arm.com>
	<a54aff75-f79b-b40d-c66f-6730aaccbd39@arm.com>
Date: Tue, 22 Aug 2017 15:41:56 +0100
In-Reply-To: <a54aff75-f79b-b40d-c66f-6730aaccbd39@arm.com> (Julien Thierry's
	message of "Tue, 22 Aug 2017 15:14:59 +0100")
Message-ID: <87wp5vmzpn.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julien Thierry <julien.thierry@arm.com>
Cc: will.deacon@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, David Woods <dwoods@mellanox.com>, steve.capper@arm.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

Julien Thierry <julien.thierry@arm.com> writes:

> Hi Punit,
>
> On 22/08/17 11:42, Punit Agrawal wrote:
>> huge_pte_offset() was updated to correctly handle swap entries for
>> hugepages. With the addition of the size parameter, it is now possible
>> to disambiguate whether the request is for a regular hugepage or a
>> contiguous hugepage.
>>
>> Fix huge_pte_offset() for contiguous hugepages by using the size to find
>> the correct page table entry.
>>
>> Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
>> Cc: David Woods <dwoods@mellanox.com>
>> ---
>>   arch/arm64/mm/hugetlbpage.c | 21 ++++++++++++++++-----
>>   1 file changed, 16 insertions(+), 5 deletions(-)
>>
>> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
>> index 594232598cac..b95e24dc3477 100644
>> --- a/arch/arm64/mm/hugetlbpage.c
>> +++ b/arch/arm64/mm/hugetlbpage.c
>> @@ -214,6 +214,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
>>   	pgd_t *pgd;
>>   	pud_t *pud;
>>   	pmd_t *pmd;
>> +	pte_t *pte;
>>     	pgd = pgd_offset(mm, addr);
>>   	pr_debug("%s: addr:0x%lx pgd:%p\n", __func__, addr, pgd);
>> @@ -221,19 +222,29 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
>>   		return NULL;
>>     	pud = pud_offset(pgd, addr);
>> -	if (pud_none(*pud))
>> +	if (sz != PUD_SIZE && pud_none(*pud))
>>   		return NULL;
>> -	/* swap or huge page */
>> -	if (!pud_present(*pud) || pud_huge(*pud))
>> +	/* hugepage or swap? */
>> +	if (pud_huge(*pud) || !pud_present(*pud))
>>   		return (pte_t *)pud;
>>   	/* table; check the next level */
>>   +	if (sz == CONT_PMD_SIZE)
>> +		addr &= CONT_PMD_MASK;
>> +
>>   	pmd = pmd_offset(pud, addr);
>> -	if (pmd_none(*pmd))
>> +	if (!(sz == PMD_SIZE || sz == CONT_PMD_SIZE) &&
>> +	    pmd_none(*pmd))
>>   		return NULL;
>> -	if (!pmd_present(*pmd) || pmd_huge(*pmd))
>> +	if (pmd_huge(*pmd) || !pmd_present(*pmd))
>>   		return (pte_t *)pmd;
>>   +	if (sz == CONT_PTE_SIZE) {
>> +		pte = pte_offset_kernel(
>> +			pmd, (addr & CONT_PTE_MASK));
>> +		return pte;
>
> Nit: Looks like this is the only place the new variable pte is
> used. Since we don't need to test its value, why not just write:
> 	return pte_offset_kernel(pmd, (addr & CONT_PTE_MASK));
>
> and get rid of the pte variable?

There is no benefit to getting rid of "pte" other than conciseness of
the patch. Having an explicit identifier helps highlight the level of
the page tables we are accessing.

And we always want to prioritise readability vs conciseness of the
patch, no?

>
> Cheers,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
