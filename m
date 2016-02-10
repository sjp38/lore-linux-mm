Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 39E786B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 00:15:42 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id x65so6001959pfb.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 21:15:42 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id pz5si2478248pac.133.2016.02.09.21.15.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 21:15:41 -0800 (PST)
Subject: Re: [PATCH] mm,thp: khugepaged: call pte flush at the time of
 collapse
References: <1455080175-10987-1-git-send-email-vgupta@synopsys.com>
 <87fux1xifd.fsf@linux.vnet.ibm.com>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <56BAC76A.60000@synopsys.com>
Date: Wed, 10 Feb 2016 10:45:22 +0530
MIME-Version: 1.0
In-Reply-To: <87fux1xifd.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wednesday 10 February 2016 10:37 AM, Aneesh Kumar K.V wrote:
> Vineet Gupta <Vineet.Gupta1@synopsys.com> writes:
> 
>> This showed up on ARC when running LMBench bw_mem tests as
>> Overlapping TLB Machine Check Exception triggered due to STLB entry
>> (2M pages) overlapping some NTLB entry (regular 8K page).
>>
>> bw_mem 2m touches a large chunk of vaddr creating NTLB entries.
>> In the interim khugepaged kicks in, collapsing the contiguous ptes into
>> a single pmd. pmdp_collapse_flush()->flush_pmd_tlb_range() is called to
>> flush out NTLB entries for the ptes. This for ARC (by design) can only
>> shootdown STLB entries (for pmd). The stray NTLB entries cause the overlap
>> with the subsequent STLB entry for collapsed page.
>> So make pmdp_collapse_flush() call pte flush interface not pmd flush.
>>
>> Note that originally all thp flush call sites in generic code called
>> flush_tlb_range() leaving it to architecture to implement the flush for
>> pte and/or pmd. Commit 12ebc1581ad11454 changed this by calling a new
>> opt-in API flush_pmd_tlb_range() which made the semantics more explicit
>> but failed to distinguish the pte vs pmd flush in generic code, which is
>> what this patch fixes.
>>
>> Note that ARC can fixed w/o touching the generic pmdp_collapse_flush()
>> by defining a ARC version, but that defeats the purpose of generic
>> version, plus sementically this is the right thing to do.
>>
>> Fixes STAR 9000961194: LMBench on AXS103 triggering duplicate TLB
>> exceptions with super pages
>>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: <stable@vger.kernel.org> #4.4
>> Cc: <linux-snps-arc@lists.infradead.org>
>> Cc: linux-kernel@vger.kernel.org
>> Cc: linux-mm@kvack.org
>> Fixes: 12ebc1581ad11454 ("mm,thp: introduce flush_pmd_tlb_range")
>> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

I hope that there is no other site which needs similar fixup.


> We do have reverse usage in migration code path, which I have as a patch
> here.
> 
> https://github.com/kvaneesh/linux/commit/b8a78933fea93cb0b2978868e59a0a4b12eb92eb

Great ! So you must also be defining __HAVE_ARCH_FLUSH_PMD_TLB_RANGE for powerpc.
What branch is that patch off of ?

> 
>> ---
>>  mm/pgtable-generic.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
>> index 7d3db0247983..1ba58213ad65 100644
>> --- a/mm/pgtable-generic.c
>> +++ b/mm/pgtable-generic.c
>> @@ -210,7 +210,9 @@ pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
>>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>>  	VM_BUG_ON(pmd_trans_huge(*pmdp));
>>  	pmd = pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
>> -	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
>> +
>> +	/* collapse entails shooting down ptes not pmd */
>> +	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
>>  	return pmd;
>>  }
>>  #endif
>> -- 
>> 2.5.0
> 
> -aneesh
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
