Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 216CB6B02B4
	for <linux-mm@kvack.org>; Tue, 23 May 2017 10:53:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l73so166678751pfj.8
        for <linux-mm@kvack.org>; Tue, 23 May 2017 07:53:52 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a76si19168341pfc.145.2017.05.23.07.53.51
        for <linux-mm@kvack.org>;
        Tue, 23 May 2017 07:53:51 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v3.1 4/6] mm/hugetlb: Allow architectures to override huge_pte_clear()
References: <20170522133604.11392-5-punit.agrawal@arm.com>
	<20170522162555.4313-1-punit.agrawal@arm.com>
	<20170523072629.06163fa6@mschwideX1>
Date: Tue, 23 May 2017 15:53:48 +0100
In-Reply-To: <20170523072629.06163fa6@mschwideX1> (Martin Schwidefsky's
	message of "Tue, 23 May 2017 07:26:29 +0200")
Message-ID: <878tlnhber.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, steve.capper@arm.com, mark.rutland@arm.com, linux-arch@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, Heiko Carstens <heiko.carstens@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>

Martin Schwidefsky <schwidefsky@de.ibm.com> writes:

> On Mon, 22 May 2017 17:25:55 +0100
> Punit Agrawal <punit.agrawal@arm.com> wrote:
>
>> When unmapping a hugepage range, huge_pte_clear() is used to clear the
>> page table entries that are marked as not present. huge_pte_clear()
>> internally just ends up calling pte_clear() which does not correctly
>> deal with hugepages consisting of contiguous page table entries.
>> 
>> Add a size argument to address this issue and allow architectures to
>> override huge_pte_clear() by wrapping it in a #ifndef block.
>> 
>> Update s390 implementation with the size parameter as well.
>> 
>> Note that the change only affects huge_pte_clear() - the other generic
>> hugetlb functions don't need any change.
>> 
>> Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>> Cc: Arnd Bergmann <arnd@arndb.de>
>> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> Cc: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>> 
>> Changes since v3
>> 
>> * Drop weak function and use #ifndef block to allow architecture override
>> * Drop unnecessary move of s390 function definition
>> 
>>  arch/s390/include/asm/hugetlb.h | 2 +-
>>  include/asm-generic/hugetlb.h   | 4 +++-
>>  mm/hugetlb.c                    | 2 +-
>>  3 files changed, 5 insertions(+), 3 deletions(-)
>> 
>> diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
>> index cd546a245c68..c0443500baec 100644
>> --- a/arch/s390/include/asm/hugetlb.h
>> +++ b/arch/s390/include/asm/hugetlb.h
>> @@ -39,7 +39,7 @@ static inline int prepare_hugepage_range(struct file *file,
>>  #define arch_clear_hugepage_flags(page)		do { } while (0)
>> 
>>  static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
>> -				  pte_t *ptep)
>> +				  pte_t *ptep, unsigned long sz)
>>  {
>>  	if ((pte_val(*ptep) & _REGION_ENTRY_TYPE_MASK) == _REGION_ENTRY_TYPE_R3)
>>  		pte_val(*ptep) = _REGION3_ENTRY_EMPTY;
>
> For the nop-change for s390:
> Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

Applied the tag locally. Thanks! 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
