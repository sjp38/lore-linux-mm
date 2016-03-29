Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0636B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 13:05:50 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id w104so11747634qge.3
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 10:05:50 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b67si26401082qgf.86.2016.03.29.10.05.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 10:05:49 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] x86/hugetlb: Attempt PUD_SIZE mapping alignment
 if PMD sharing enabled
References: <1459213970-17957-1-git-send-email-mike.kravetz@oracle.com>
 <1459213970-17957-3-git-send-email-mike.kravetz@oracle.com>
 <20160329083510.GA27941@gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56FAB5DB.8070003@oracle.com>
Date: Tue, 29 Mar 2016 10:05:31 -0700
MIME-Version: 1.0
In-Reply-To: <20160329083510.GA27941@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steve Capper <steve.capper@linaro.org>, Andrew Morton <akpm@linux-foundation.org>

On 03/29/2016 01:35 AM, Ingo Molnar wrote:
> 
> * Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>> When creating a hugetlb mapping, attempt PUD_SIZE alignment if the
>> following conditions are met:
>> - Address passed to mmap or shmat is NULL
>> - The mapping is flaged as shared
>> - The mapping is at least PUD_SIZE in length
>> If a PUD_SIZE aligned mapping can not be created, then fall back to a
>> huge page size mapping.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>  arch/x86/mm/hugetlbpage.c | 64 ++++++++++++++++++++++++++++++++++++++++++++---
>>  1 file changed, 61 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
>> index 42982b2..4f53af5 100644
>> --- a/arch/x86/mm/hugetlbpage.c
>> +++ b/arch/x86/mm/hugetlbpage.c
>> @@ -78,14 +78,39 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
>>  {
>>  	struct hstate *h = hstate_file(file);
>>  	struct vm_unmapped_area_info info;
>> +	bool pud_size_align = false;
>> +	unsigned long ret_addr;
>> +
>> +	/*
>> +	 * If PMD sharing is enabled, align to PUD_SIZE to facilitate
>> +	 * sharing.  Only attempt alignment if no address was passed in,
>> +	 * flags indicate sharing and size is big enough.
>> +	 */
>> +	if (IS_ENABLED(CONFIG_ARCH_WANT_HUGE_PMD_SHARE) &&
>> +	    !addr && flags & MAP_SHARED && len >= PUD_SIZE)
>> +		pud_size_align = true;
>>  
>>  	info.flags = 0;
>>  	info.length = len;
>>  	info.low_limit = current->mm->mmap_legacy_base;
>>  	info.high_limit = TASK_SIZE;
>> -	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
>> +	if (pud_size_align)
>> +		info.align_mask = PAGE_MASK & (PUD_SIZE - 1);
>> +	else
>> +		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
>>  	info.align_offset = 0;
>> -	return vm_unmapped_area(&info);
>> +	ret_addr = vm_unmapped_area(&info);
>> +
>> +	/*
>> +	 * If failed with PUD_SIZE alignment, try again with huge page
>> +	 * size alignment.
>> +	 */
>> +	if ((ret_addr & ~PAGE_MASK) && pud_size_align) {
>> +		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
>> +		ret_addr = vm_unmapped_area(&info);
>> +	}
> 
> So AFAICS 'ret_addr' is either page aligned, or is an error code. Wouldn't it be a 
> lot easier to read to say:
> 
> 	if ((long)ret_addr > 0 && pud_size_align) {
> 		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
> 		ret_addr = vm_unmapped_area(&info);
> 	}
> 
> 	return ret_addr;
> 
> to make it clear that it's about error handling, not some alignment 
> requirement/restriction?

Yes, I agree that is easier to read.  However, it assumes that process
virtual addresses can never evaluate to a negative long value.  This may
be the case for x86_64 today.  But, there are other architectures where
this is not the case.  I know this is x86 specific code, but might it be
possible that x86 virtual addresses could be negative longs in the future?

It appears that all callers of vm_unmapped_area() are using the page aligned
check to determine error.   I would prefer to do the same, and can add
comments to make that more clear.

Thanks,
-- 
Mike Kravetz

> 
>>  	/*
>> +	 * If failed with PUD_SIZE alignment, try again with huge page
>> +	 * size alignment.
>> +	 */
>> +	if ((addr & ~PAGE_MASK) && pud_size_align) {
>> +		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
>> +		addr = vm_unmapped_area(&info);
>> +	}
> 
> Ditto.
> 
>>  		addr = vm_unmapped_area(&info);
>> +
>> +		/*
>> +		 * If failed again with PUD_SIZE alignment, finally try with
>> +		 * huge page size alignment.
>> +		 */
>> +		if (addr & ~PAGE_MASK) {
>> +			info.align_mask = PAGE_MASK & ~huge_page_mask(h);
>> +			addr = vm_unmapped_area(&info);
> 
> Ditto.
> 
> Thanks,
> 
> 	Ingo
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
