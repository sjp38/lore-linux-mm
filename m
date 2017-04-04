Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C37966B039F
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 14:47:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p20so183469150pgd.21
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 11:47:20 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 1si18233633pgr.272.2017.04.04.11.47.19
        for <linux-mm@kvack.org>;
        Tue, 04 Apr 2017 11:47:19 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH 2/4] arm64: hugetlbpages: Correctly handle swap entries in huge_pte_offset()
References: <20170330163849.18402-1-punit.agrawal@arm.com>
	<20170330163849.18402-3-punit.agrawal@arm.com>
	<20170331095155.GA31398@leverpostej>
Date: Tue, 04 Apr 2017 19:47:15 +0100
In-Reply-To: <20170331095155.GA31398@leverpostej> (Mark Rutland's message of
	"Fri, 31 Mar 2017 10:52:06 +0100")
Message-ID: <8760ikypqk.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org, David Woods <dwoods@mellanox.com>, tbaicar@codeaurora.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com

Hi Mark,

Mark Rutland <mark.rutland@arm.com> writes:

> Hi Punit,
>
> On Thu, Mar 30, 2017 at 05:38:47PM +0100, Punit Agrawal wrote:
>> huge_pte_offset() does not correctly handle poisoned or migration page
>> table entries. 
>
> What exactly does it do wrong?
>
> Judging by the patch, we return NULL in some cases we shouldn't, right?

huge_pte_offset() returns NULL when it comes across swap entries for any
of the supported hugepage sizes.

>
> What can result from this? e.g. can we see data corruption?

In the tests I am running, it results in an error in the log -

[  344.165544] mm/pgtable-generic.c:33: bad pmd 000000083af00074.

when unmapping the page tables for the process that owns the poisoned
page.

In some instances, returning NULL instead of swap entries could lead to
data corruption - especially when the page tables contain migration swap
entries. But since hugepage migration is not enabled on arm64 I haven't
seen any corruption.

I've updated the commit log with more details locally.

>
>> Not knowing the size of the hugepage entry being
>> requested only compounded the problem.
>> 
>> The recently added hstate parameter can be used to determine the size of
>> hugepage being accessed. Use the size to find the correct page table
>> entry to return when coming across a swap page table entry.
>> 
>> Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
>> Cc: David Woods <dwoods@mellanox.com>
>
> Given this is a fix for a bug, it sounds like it should have a fixes
> tag, or a Cc stable...

The problem doesn't occur until we enable memory failure handling. So
there shouldn't be a problem on earlier kernels.

Thanks,
Punit

>
> Thanks,
> Mark.
>
>> ---
>>  arch/arm64/mm/hugetlbpage.c | 31 ++++++++++++++++---------------
>>  1 file changed, 16 insertions(+), 15 deletions(-)
>> 
>> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
>> index 9ca742c4c1ab..44014403081f 100644
>> --- a/arch/arm64/mm/hugetlbpage.c
>> +++ b/arch/arm64/mm/hugetlbpage.c
>> @@ -192,38 +192,39 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
>>  pte_t *huge_pte_offset(struct mm_struct *mm,
>>  		       unsigned long addr, struct hstate *h)
>>  {
>> +	unsigned long sz = huge_page_size(h);
>>  	pgd_t *pgd;
>>  	pud_t *pud;
>> -	pmd_t *pmd = NULL;
>> -	pte_t *pte = NULL;
>> +	pmd_t *pmd;
>> +	pte_t *pte;
>>  
>>  	pgd = pgd_offset(mm, addr);
>>  	pr_debug("%s: addr:0x%lx pgd:%p\n", __func__, addr, pgd);
>>  	if (!pgd_present(*pgd))
>>  		return NULL;
>> +
>>  	pud = pud_offset(pgd, addr);
>> -	if (!pud_present(*pud))
>> +	if (pud_none(*pud) && sz != PUD_SIZE)
>>  		return NULL;
>> -
>> -	if (pud_huge(*pud))
>> +	else if (!pud_table(*pud))
>>  		return (pte_t *)pud;
>> +
>> +	if (sz == CONT_PMD_SIZE)
>> +		addr &= CONT_PMD_MASK;
>> +
>>  	pmd = pmd_offset(pud, addr);
>> -	if (!pmd_present(*pmd))
>> +	if (pmd_none(*pmd) &&
>> +	    !(sz == PMD_SIZE || sz == CONT_PMD_SIZE))
>>  		return NULL;
>> -
>> -	if (pte_cont(pmd_pte(*pmd))) {
>> -		pmd = pmd_offset(
>> -			pud, (addr & CONT_PMD_MASK));
>> -		return (pte_t *)pmd;
>> -	}
>> -	if (pmd_huge(*pmd))
>> +	else if (!pmd_table(*pmd))
>>  		return (pte_t *)pmd;
>> -	pte = pte_offset_kernel(pmd, addr);
>> -	if (pte_present(*pte) && pte_cont(*pte)) {
>> +
>> +	if (sz == CONT_PTE_SIZE) {
>>  		pte = pte_offset_kernel(
>>  			pmd, (addr & CONT_PTE_MASK));
>>  		return pte;
>>  	}
>> +
>>  	return NULL;
>>  }
>>  
>> -- 
>> 2.11.0
>> 
>> 
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
