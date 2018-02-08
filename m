Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF0046B0007
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 09:36:14 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id a7so4422664ywc.1
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 06:36:14 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n185si43161qkc.479.2018.02.08.06.36.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 06:36:13 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w18ETYQf036047
	for <linux-mm@kvack.org>; Thu, 8 Feb 2018 09:36:12 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2g0r119j5q-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Feb 2018 09:36:11 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 8 Feb 2018 14:36:08 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 04/24] mm: Dont assume page-table invariance during
 faults
References: <1517935810-31177-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1517935810-31177-5-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180206202831.GB16511@bombadil.infradead.org>
Date: Thu, 8 Feb 2018 15:35:58 +0100
MIME-Version: 1.0
In-Reply-To: <20180206202831.GB16511@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <484242d8-e632-9e39-5c99-2e1b4b3b69a5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 06/02/2018 21:28, Matthew Wilcox wrote:
> On Tue, Feb 06, 2018 at 05:49:50PM +0100, Laurent Dufour wrote:
>> From: Peter Zijlstra <peterz@infradead.org>
>>
>> One of the side effects of speculating on faults (without holding
>> mmap_sem) is that we can race with free_pgtables() and therefore we
>> cannot assume the page-tables will stick around.
>>
>> Remove the reliance on the pte pointer.
>>
>> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
>>
>> In most of the case pte_unmap_same() was returning 1, which meaning that
>> do_swap_page() should do its processing. So in most of the case there will
>> be no impact.
>>
>> Now regarding the case where pte_unmap_safe() was returning 0, and thus
>> do_swap_page return 0 too, this happens when the page has already been
>> swapped back. This may happen before do_swap_page() get called or while in
>> the call to do_swap_page(). In that later case, the check done when
>> swapin_readahead() returns will detect that case.
>>
>> The worst case would be that a page fault is occuring on 2 threads at the
>> same time on the same swapped out page. In that case one thread will take
>> much time looping in __read_swap_cache_async(). But in the regular page
>> fault path, this is even worse since the thread would wait for semaphore to
>> be released before starting anything.
>>
>> [Remove only if !CONFIG_SPECULATIVE_PAGE_FAULT]
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> 
> I have a great deal of trouble connecting all of the words above to the
> contents of the patch.

Thanks for pushing forward here, this raised some doubts on my side.

I reviewed that part of code, and I think I could now change the way
pte_unmap_safe() is checking for the pte's value. Since we now have all the
needed details in the vm_fault structure, I will pass it to
pte_unamp_same() and deal with the VMA checks when locking for the pte as
it is done in the other part of the page fault handler by calling
pte_spinlock().

This means that this patch will be dropped, and pte_unmap_same() will become :

static inline int pte_unmap_same(struct vm_fault *vmf, int *same)
{
	int ret = 0;

	*same = 1;
#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
	if (sizeof(pte_t) > sizeof(unsigned long)) {
		if (pte_spinlock(vmf)) {
			*same = pte_same(*vmf->pte, vmf->orig_pte);
			spin_unlock(vmf->ptl);
		}
		else
			ret = VM_FAULT_RETRY;
	}
#endif
	pte_unmap(vmf->pte);
	return ret;
}

Laurent.

> 
>>  
>> +#ifndef CONFIG_SPECULATIVE_PAGE_FAULT
>>  /*
>>   * handle_pte_fault chooses page fault handler according to an entry which was
>>   * read non-atomically.  Before making any commitment, on those architectures
>> @@ -2311,6 +2312,7 @@ static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
>>  	pte_unmap(page_table);
>>  	return same;
>>  }
>> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
>>  
>>  static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
>>  {
>> @@ -2898,11 +2900,13 @@ int do_swap_page(struct vm_fault *vmf)
>>  		swapcache = page;
>>  	}
>>  
>> +#ifndef CONFIG_SPECULATIVE_PAGE_FAULT
>>  	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte)) {
>>  		if (page)
>>  			put_page(page);
>>  		goto out;
>>  	}
>> +#endif
>>  
> 
> This feels to me like we want:
> 
> #ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> [current code]
> #else
> /*
>  * Some words here which explains why we always want to return this
>  * value if we support speculative page faults.
>  */
> static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
> 				pte_t *page_table, pte_t orig_pte)
> {
> 	return 1;
> }
> #endif
> 
> instead of cluttering do_swap_page with an ifdef.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
