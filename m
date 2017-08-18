Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 377646B025F
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 09:49:46 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r133so170329773pgr.6
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 06:49:46 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g3si4020131plk.281.2017.08.18.06.49.44
        for <linux-mm@kvack.org>;
        Fri, 18 Aug 2017 06:49:45 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v6 5/9] arm64: hugetlb: Handle swap entries in huge_pte_offset() for contiguous hugepages
References: <20170810170906.30772-1-punit.agrawal@arm.com>
	<20170810170906.30772-6-punit.agrawal@arm.com>
	<20170818112015.2cvkb7y3gkozz5ip@armageddon.cambridge.arm.com>
Date: Fri, 18 Aug 2017 14:49:41 +0100
In-Reply-To: <20170818112015.2cvkb7y3gkozz5ip@armageddon.cambridge.arm.com>
	(Catalin Marinas's message of "Fri, 18 Aug 2017 12:20:16 +0100")
Message-ID: <87inhlnfyi.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: will.deacon@arm.com, mark.rutland@arm.com, David Woods <dwoods@mellanox.com>, steve.capper@arm.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

Catalin Marinas <catalin.marinas@arm.com> writes:

> On Thu, Aug 10, 2017 at 06:09:02PM +0100, Punit Agrawal wrote:
>> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
>> index d3a6713048a2..09e79785c019 100644
>> --- a/arch/arm64/mm/hugetlbpage.c
>> +++ b/arch/arm64/mm/hugetlbpage.c
>> @@ -210,6 +210,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
>>  	pgd_t *pgd;
>>  	pud_t *pud;
>>  	pmd_t *pmd;
>> +	pte_t *pte;
>>  
>>  	pgd = pgd_offset(mm, addr);
>>  	pr_debug("%s: addr:0x%lx pgd:%p\n", __func__, addr, pgd);
>> @@ -217,19 +218,29 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
>>  		return NULL;
>>  
>>  	pud = pud_offset(pgd, addr);
>> -	if (pud_none(*pud))
>> +	if (pud_none(*pud) && sz != PUD_SIZE)
>>  		return NULL;
>>  	/* swap or huge page */
>>  	if (!pud_present(*pud) || pud_huge(*pud))
>>  		return (pte_t *)pud;
>>  	/* table; check the next level */
>
> So if sz == PUD_SIZE and we have pud_none(*pud) == true, it returns the
> pud. Isn't this different from what you proposed for the generic
> huge_pte_offset()? [1]

I think I missed this case in the generic version.

As hugetlb_fault() deals with p*d_none() entries by calling
hugetlb_no_page(), the thinking was that returning the p*d saves us an
extra round trip by avoiding the call to huge_pte_alloc().

>
>>  
>> +	if (sz == CONT_PMD_SIZE)
>> +		addr &= CONT_PMD_MASK;
>> +
>>  	pmd = pmd_offset(pud, addr);
>> -	if (pmd_none(*pmd))
>> +	if (pmd_none(*pmd) &&
>> +	    !(sz == PMD_SIZE || sz == CONT_PMD_SIZE))
>>  		return NULL;
>
> Again, if sz == PMD_SIZE, you no longer return NULL. The generic
> proposal in [1] looks like:
>
> 	if (pmd_none(*pmd))
> 		return NULL;
>
> and that's even when sz == PMD_SIZE.
>
> Anyway, I think we need to push for [1] again to be accepted before we
> go ahead with these changes.

[1] is already queued in Andrew's tree. I'll send an update - hopefully
it can be picked up for the next merge.

>
> [1] http://lkml.kernel.org/r/20170725154114.24131-2-punit.agrawal@arm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
