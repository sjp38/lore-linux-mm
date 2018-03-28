Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 579A76B0025
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 04:28:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 96so763656wrk.12
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 01:28:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f7si412983edi.509.2018.03.28.01.28.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 01:28:07 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2S8OH2r039972
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 04:28:05 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h04v7qfv1-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 04:28:03 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 28 Mar 2018 09:27:56 +0100
Subject: Re: [PATCH v9 06/24] mm: make pte_unmap_same compatible with SPF
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-7-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803271417510.31115@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 28 Mar 2018 10:27:45 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1803271417510.31115@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <fd9eedf4-b885-d8f5-2daa-4cc450e72427@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org



On 27/03/2018 23:18, David Rientjes wrote:
> On Tue, 13 Mar 2018, Laurent Dufour wrote:
> 
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
> 
> Initialization is now unneeded.

I'm sorry, what "initialization" are you talking about here ?

> 
> Otherwise:
> 
> Acked-by: David Rientjes <rientjes@google.com>

Thanks,
Laurent.
