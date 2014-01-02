Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id EA5626B0035
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 05:53:04 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id gq1so14225657obb.17
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 02:53:04 -0800 (PST)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id mx9si43875544obc.132.2014.01.02.02.52.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 02:53:03 -0800 (PST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 2 Jan 2014 16:22:49 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id BD83E394004E
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 16:22:45 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s02AqchB5308838
	for <linux-mm@kvack.org>; Thu, 2 Jan 2014 16:22:39 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s02Aqi6x004592
	for <linux-mm@kvack.org>; Thu, 2 Jan 2014 16:22:44 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: RE: [PATCH -V2] powerpc: thp: Fix crash on mremap
In-Reply-To: <20140102094124.04D76E0090@blue.fi.intel.com>
References: <1388654266-5195-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20140102094124.04D76E0090@blue.fi.intel.com>
Date: Thu, 02 Jan 2014 16:22:43 +0530
Message-ID: <87zjneodtw.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, aarcange@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> This patch fix the below crash
>> 
>> NIP [c00000000004cee4] .__hash_page_thp+0x2a4/0x440
>> LR [c0000000000439ac] .hash_page+0x18c/0x5e0
>> ...
>> Call Trace:
>> [c000000736103c40] [00001ffffb000000] 0x1ffffb000000(unreliable)
>> [437908.479693] [c000000736103d50] [c0000000000439ac] .hash_page+0x18c/0x5e0
>> [437908.479699] [c000000736103e30] [c00000000000924c] .do_hash_page+0x4c/0x58
>> 
>> On ppc64 we use the pgtable for storing the hpte slot information and
>> store address to the pgtable at a constant offset (PTRS_PER_PMD) from
>> pmd. On mremap, when we switch the pmd, we need to withdraw and deposit
>> the pgtable again, so that we find the pgtable at PTRS_PER_PMD offset
>> from new pmd.
>> 
>> We also want to move the withdraw and deposit before the set_pmd so
>> that, when page fault find the pmd as trans huge we can be sure that
>> pgtable can be located at the offset.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>> Changes from V1:
>> * limit the withraw/deposit to only ppc64
>> 
>>  arch/Kconfig                           |  3 +++
>>  arch/powerpc/platforms/Kconfig.cputype |  1 +
>>  include/linux/huge_mm.h                |  6 ++++++
>>  mm/huge_memory.c                       | 21 ++++++++++++---------
>>  4 files changed, 22 insertions(+), 9 deletions(-)
>> 
>> diff --git a/arch/Kconfig b/arch/Kconfig
>> index f1cf895c040f..3759e70a649d 100644
>> --- a/arch/Kconfig
>> +++ b/arch/Kconfig
>> @@ -371,6 +371,9 @@ config HAVE_IRQ_TIME_ACCOUNTING
>>  config HAVE_ARCH_TRANSPARENT_HUGEPAGE
>>  	bool
>>  
>> +config ARCH_THP_MOVE_PMD_ALWAYS_WITHDRAW
>
> I don't like name of the option, but can't find any better... :(
>
>> +	bool
>> +
>>  config HAVE_ARCH_SOFT_DIRTY
>>  	bool
>>  
>> diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
>> index bca2465a9c34..5f83b4334e5f 100644
>> --- a/arch/powerpc/platforms/Kconfig.cputype
>> +++ b/arch/powerpc/platforms/Kconfig.cputype
>> @@ -71,6 +71,7 @@ config PPC_BOOK3S_64
>>  	select PPC_FPU
>>  	select PPC_HAVE_PMU_SUPPORT
>>  	select SYS_SUPPORTS_HUGETLBFS
>> +	select ARCH_THP_MOVE_PMD_ALWAYS_WITHDRAW
>>  	select HAVE_ARCH_TRANSPARENT_HUGEPAGE if PPC_64K_PAGES
>>  
>>  config PPC_BOOK3E_64
>> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>> index 91672e2deec3..836242a738a5 100644
>> --- a/include/linux/huge_mm.h
>> +++ b/include/linux/huge_mm.h
>> @@ -230,4 +230,10 @@ static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_str
>>  
>>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>>  
>> +#ifdef CONFIG_ARCH_THP_MOVE_PMD_ALWAYS_WITHDRAW
>> +#define ARCH_THP_MOVE_PMD_ALWAYS_WITHDRAW 1
>> +#else
>> +#define ARCH_THP_MOVE_PMD_ALWAYS_WITHDRAW 0
>> +#endif
>> +
>
> Just use config option directly:
>
> 	if (new_ptl != old_ptl ||
> 		IS_ENABLED(CONFIG_ARCH_THP_MOVE_PMD_ALWAYS_WITHDRAW))


I didn't like that. I found the earlier one easier for reading.
If you and others strongly feel about this, I can redo the patch. Please let me know


> ...
>
>
> Otherwise, looks good:
>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>
>>  #endif /* _LINUX_HUGE_MM_H */
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 7de1bf85f683..32006b51d102 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -1505,19 +1505,22 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
>>  			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
>>  		pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
>>  		VM_BUG_ON(!pmd_none(*new_pmd));
>> -		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
>> -		if (new_ptl != old_ptl) {
>> +		/*
>> +		 * Archs like ppc64 use pgtable to store per pmd
>> +		 * specific information. So when we switch the pmd,
>> +		 * we should also withdraw and deposit the pgtable
>> +		 *
>> +		 * With split pmd lock we also need to move preallocated
>> +		 * PTE page table if new_pmd is on different PMD page table.
>> +		 */
>> +		if (new_ptl != old_ptl || ARCH_THP_MOVE_PMD_ALWAYS_WITHDRAW) {
>>  			pgtable_t pgtable;
>> -
>> -			/*
>> -			 * Move preallocated PTE page table if new_pmd is on
>> -			 * different PMD page table.
>> -			 */
>>  			pgtable = pgtable_trans_huge_withdraw(mm, old_pmd);
>>  			pgtable_trans_huge_deposit(mm, new_pmd, pgtable);
>> -
>> -			spin_unlock(new_ptl);
>>  		}
>> +		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
>> +		if (new_ptl != old_ptl)
>> +			spin_unlock(new_ptl);
>>  		spin_unlock(old_ptl);
>>  	}
>>  out:
>> -- 
>> 1.8.3.2
>
> -- 
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
