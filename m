Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE0606B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 10:07:50 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id t14so991364ual.11
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 07:07:50 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x20si3662502uah.69.2018.04.30.07.07.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 07:07:49 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3UE4OSO008908
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 10:07:48 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hp1f3h1y4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 10:07:47 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 30 Apr 2018 15:07:42 +0100
Subject: Re: [PATCH v10 06/25] mm: make pte_unmap_same compatible with SPF
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523975611-15978-7-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180423063157.GB114098@rodete-desktop-imager.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 30 Apr 2018 16:07:30 +0200
MIME-Version: 1.0
In-Reply-To: <20180423063157.GB114098@rodete-desktop-imager.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <dd5c4338-3cbb-c65a-f0c1-c71e2a0037ee@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 23/04/2018 08:31, Minchan Kim wrote:
> On Tue, Apr 17, 2018 at 04:33:12PM +0200, Laurent Dufour wrote:
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
> 
> I don't see such logic in this patch.
> Maybe you introduces it later? If so, please comment on it.
> Or just return 0 in case of 2 without introducing VM_FAULT_PTNOTSAME.

Late in the series, pte_spinlock() will check for the VMA's changes and may
return 1. This will be then required to handle the 3 cases presented above.

I can move this handling later in the series, but I wondering if this will make
it more easier to read.

> 
>> If VM_FAULT_RETRY is returned, it is passed up to the callers to retry the
>> page fault while holding the mmap_sem.
>>
>> Acked-by: David Rientjes <rientjes@google.com>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  include/linux/mm.h |  1 +
>>  mm/memory.c        | 39 ++++++++++++++++++++++++++++-----------
>>  2 files changed, 29 insertions(+), 11 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 4d1aff80669c..714da99d77a3 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1208,6 +1208,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
>>  #define VM_FAULT_NEEDDSYNC  0x2000	/* ->fault did not modify page tables
>>  					 * and needs fsync() to complete (for
>>  					 * synchronous page faults in DAX) */
>> +#define VM_FAULT_PTNOTSAME 0x4000	/* Page table entries have changed */
>>  
>>  #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | \
>>  			 VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE | \
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 0b9a51f80e0e..f86efcb8e268 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2309,21 +2309,29 @@ static inline bool pte_map_lock(struct vm_fault *vmf)
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
>> @@ -2912,10 +2920,19 @@ int do_swap_page(struct vm_fault *vmf)
>>  	pte_t pte;
>>  	int locked;
>>  	int exclusive = 0;
>> -	int ret = 0;
>> +	int ret;
>>  
>> -	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
>> +	ret = pte_unmap_same(vmf);
>> +	if (ret) {
>> +		/*
>> +		 * If pte != orig_pte, this means another thread did the
>> +		 * swap operation in our back.
>> +		 * So nothing else to do.
>> +		 */
>> +		if (ret == VM_FAULT_PTNOTSAME)
>> +			ret = 0;
>>  		goto out;
>> +	}
>>  
>>  	entry = pte_to_swp_entry(vmf->orig_pte);
>>  	if (unlikely(non_swap_entry(entry))) {
>> -- 
>> 2.7.4
>>
> 
