Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 54C456B005A
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 05:37:59 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so11739845ied.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 02:37:58 -0700 (PDT)
Message-ID: <507D2AEF.9060509@gmail.com>
Date: Tue, 16 Oct 2012 17:37:51 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: thp: Set the accessed flag for old pages on access
 fault.
References: <1349099505-5581-1-git-send-email-will.deacon@arm.com> <20121001145944.GA18051@redhat.com>
In-Reply-To: <20121001145944.GA18051@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.cz, Steve Capper <steve.capper@arm.com>, Chris Metcalf <cmetcalf@tilera.com>

On 10/01/2012 10:59 PM, Andrea Arcangeli wrote:
> Hi Will,
>
> On Mon, Oct 01, 2012 at 02:51:45PM +0100, Will Deacon wrote:
>> +void huge_pmd_set_accessed(struct mm_struct *mm, struct vm_area_struct *vma,
>> +			   unsigned long address, pmd_t *pmd, pmd_t orig_pmd)
>> +{
>> +	pmd_t entry;
>> +
>> +	spin_lock(&mm->page_table_lock);
>> +	entry = pmd_mkyoung(orig_pmd);
>> +	if (pmdp_set_access_flags(vma, address & HPAGE_PMD_MASK, pmd, entry, 0))
>> +		update_mmu_cache(vma, address, pmd);
> If the pmd is being splitted, this may not be a trasnhuge pmd anymore
> by the time you obtained the lock. (orig_pmd could be stale, and it
> wasn't verified with pmd_same either)

Could you tell me when should call pmd_same in general?

>
> The lock should be obtained through pmd_trans_huge_lock.
>
>    if (pmd_trans_huge_lock(orig_pmd, vma) == 1)
>    {
> 	set young bit
> 	spin_unlock(&mm->page_table_lock);
>    }
>
>
> On x86:
>
> int pmdp_set_access_flags(struct vm_area_struct *vma,
> 			  unsigned long address, pmd_t *pmdp,
> 			  pmd_t entry, int dirty)
> {
> 	int changed = !pmd_same(*pmdp, entry);
>
> 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>
> 	if (changed && dirty) {
> 		*pmdp = entry;
>
> with dirty == 0 it looks like it won't make any difference, but I
> guess your arm pmdp_set_access_flag is different.
>
> However it seems "dirty" means write access and so the invocation
> would better match the pte case:
>
> 	if (pmdp_set_access_flags(vma, address & HPAGE_PMD_MASK, pmd, entry,
> 	    flags & FAULT_FLAG_WRITE))
>
>
> But note, you still have to update it even when "dirty" == 0, or it'll
> still infinite loop for read accesses.
>
>> +	spin_unlock(&mm->page_table_lock);
>> +}
>> +
>>   int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>>   			unsigned long address, pmd_t *pmd, pmd_t orig_pmd)
>>   {
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 5736170..d5c007d 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -3537,7 +3537,11 @@ retry:
>>   				if (unlikely(ret & VM_FAULT_OOM))
>>   					goto retry;
>>   				return ret;
>> +			} else {
>> +				huge_pmd_set_accessed(mm, vma, address, pmd,
>> +						      orig_pmd);
>>   			}
>> +
>>   			return 0;
> Thanks,
> Andrea
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
