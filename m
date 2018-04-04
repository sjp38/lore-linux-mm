Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 108E16B000C
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 05:53:34 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v6so4700128qkd.23
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 02:53:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c6si3610986qtg.258.2018.04.04.02.53.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 02:53:33 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w349qDPP143750
	for <linux-mm@kvack.org>; Wed, 4 Apr 2018 05:53:32 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h4uw1shv4-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Apr 2018 05:53:31 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 4 Apr 2018 10:53:28 +0100
Subject: Re: [PATCH v9 06/24] mm: make pte_unmap_same compatible with SPF
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-7-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180403191005.GC5935@redhat.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 4 Apr 2018 11:53:18 +0200
MIME-Version: 1.0
In-Reply-To: <20180403191005.GC5935@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <04b7be03-b90b-c890-d1bb-6981412a6b10@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org



On 03/04/2018 21:10, Jerome Glisse wrote:
> On Tue, Mar 13, 2018 at 06:59:36PM +0100, Laurent Dufour wrote:
>> pte_unmap_same() is making the assumption that the page table are still
>> around because the mmap_sem is held.
>> This is no more the case when running a speculative page fault and
>> additional check must be made to ensure that the final page table are still
>> there.
>>
>> This is now done by calling pte_spinlock() to check for the VMA's
>> consistency while locking for the page tables.
>>
>> This is requiring passing a vm_fault structure to pte_unmap_same() which is
>> containing all the needed parameters.
>>
>> As pte_spinlock() may fail in the case of a speculative page fault, if the
>> VMA has been touched in our back, pte_unmap_same() should now return 3
>> cases :
>> 	1. pte are the same (0)
>> 	2. pte are different (VM_FAULT_PTNOTSAME)
>> 	3. a VMA's changes has been detected (VM_FAULT_RETRY)
>>
>> The case 2 is handled by the introduction of a new VM_FAULT flag named
>> VM_FAULT_PTNOTSAME which is then trapped in cow_user_page().
>> If VM_FAULT_RETRY is returned, it is passed up to the callers to retry the
>> page fault while holding the mmap_sem.
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  include/linux/mm.h |  1 +
>>  mm/memory.c        | 29 +++++++++++++++++++----------
>>  2 files changed, 20 insertions(+), 10 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 2f3e98edc94a..b6432a261e63 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1199,6 +1199,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
>>  #define VM_FAULT_NEEDDSYNC  0x2000	/* ->fault did not modify page tables
>>  					 * and needs fsync() to complete (for
>>  					 * synchronous page faults in DAX) */
>> +#define VM_FAULT_PTNOTSAME 0x4000	/* Page table entries have changed */
>>  
>>  #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | \
>>  			 VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE | \
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 21b1212a0892..4bc7b0bdcb40 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2309,21 +2309,29 @@ static bool pte_map_lock(struct vm_fault *vmf)
>>   * parts, do_swap_page must check under lock before unmapping the pte and
>>   * proceeding (but do_wp_page is only called after already making such a check;
>>   * and do_anonymous_page can safely check later on).
>> + *
>> + * pte_unmap_same() returns:
>> + *	0			if the PTE are the same
>> + *	VM_FAULT_PTNOTSAME	if the PTE are different
>> + *	VM_FAULT_RETRY		if the VMA has changed in our back during
>> + *				a speculative page fault handling.
>>   */
>> -static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
>> -				pte_t *page_table, pte_t orig_pte)
>> +static inline int pte_unmap_same(struct vm_fault *vmf)
>>  {
>> -	int same = 1;
>> +	int ret = 0;
>> +
>>  #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
>>  	if (sizeof(pte_t) > sizeof(unsigned long)) {
>> -		spinlock_t *ptl = pte_lockptr(mm, pmd);
>> -		spin_lock(ptl);
>> -		same = pte_same(*page_table, orig_pte);
>> -		spin_unlock(ptl);
>> +		if (pte_spinlock(vmf)) {
>> +			if (!pte_same(*vmf->pte, vmf->orig_pte))
>> +				ret = VM_FAULT_PTNOTSAME;
>> +			spin_unlock(vmf->ptl);
>> +		} else
>> +			ret = VM_FAULT_RETRY;
>>  	}
>>  #endif
>> -	pte_unmap(page_table);
>> -	return same;
>> +	pte_unmap(vmf->pte);
>> +	return ret;
>>  }
>>  
>>  static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
>> @@ -2913,7 +2921,8 @@ int do_swap_page(struct vm_fault *vmf)
>>  	int exclusive = 0;
>>  	int ret = 0;
>>  
>> -	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
>> +	ret = pte_unmap_same(vmf);
>> +	if (ret)
>>  		goto out;
>>  
> 
> This change what do_swap_page() returns ie before it was returning 0
> when locked pte lookup was different from orig_pte. After this patch
> it returns VM_FAULT_PTNOTSAME but this is a new return value for
> handle_mm_fault() (the do_swap_page() return value is what ultimately
> get return by handle_mm_fault())
> 
> Do we really want that ? This might confuse some existing user of
> handle_mm_fault() and i am not sure of the value of that information
> to caller.
> 
> Note i do understand that you want to return retry if anything did
> change from underneath and thus need to differentiate from when the
> pte value are not the same.

You're right, do_swap_page() should still return 0 in the case the lookup pte
is different from orig_pte, assuming that the swap operation has been handled
in our back by another concurrent thread.

So in do_swap_page(), VM_FAULT_PTNOTSAME should be translated in ret = 0.

	ret = pte_unmap_same(vmf);
	if (ret) {
		/*
		 * If pte != orig_pte, this means another thread did the
		 * swap operation in our back.
		 * So nothing else to do.
		 */
		if (ret == VM_FAULT_PTNOTSAME)
			ret = 0;
		goto out;
	}

This means that VM_FAULT_PTNOTSAME will never been reported up and limited to
do_swap_page().

Doing this will make easier to understand why when pte_unmap_same() is
returning 0, do_swap_page() is done.

Cheers,
Laurent.
