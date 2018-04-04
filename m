Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 40F8C6B0008
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 11:57:02 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q15so11985128qkj.3
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 08:57:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q21si6320005qtg.165.2018.04.04.08.57.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 08:57:01 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w34Fu4aO056649
	for <linux-mm@kvack.org>; Wed, 4 Apr 2018 11:57:00 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h4xq0j41a-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Apr 2018 11:56:59 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 4 Apr 2018 16:56:56 +0100
Subject: Re: [PATCH v9 14/24] mm: Introduce __maybe_mkwrite()
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-15-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1804021611590.102694@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 4 Apr 2018 17:56:46 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1804021611590.102694@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <403a5d84-99f9-d1a5-0c75-38b0d4cc1637@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 03/04/2018 01:12, David Rientjes wrote:
> On Tue, 13 Mar 2018, Laurent Dufour wrote:
> 
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index dfa81a638b7c..a84ddc218bbd 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -684,13 +684,18 @@ void free_compound_page(struct page *page);
>>   * pte_mkwrite.  But get_user_pages can cause write faults for mappings
>>   * that do not have writing enabled, when used by access_process_vm.
>>   */
>> -static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
>> +static inline pte_t __maybe_mkwrite(pte_t pte, unsigned long vma_flags)
>>  {
>> -	if (likely(vma->vm_flags & VM_WRITE))
>> +	if (likely(vma_flags & VM_WRITE))
>>  		pte = pte_mkwrite(pte);
>>  	return pte;
>>  }
>>  
>> +static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
>> +{
>> +	return __maybe_mkwrite(pte, vma->vm_flags);
>> +}
>> +
>>  int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
>>  		struct page *page);
>>  int finish_fault(struct vm_fault *vmf);
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 0a0a483d9a65..af0338fbc34d 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2472,7 +2472,7 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
>>  
>>  	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
>>  	entry = pte_mkyoung(vmf->orig_pte);
>> -	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
>> +	entry = __maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
>>  	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
>>  		update_mmu_cache(vma, vmf->address, vmf->pte);
>>  	pte_unmap_unlock(vmf->pte, vmf->ptl);
>> @@ -2549,8 +2549,8 @@ static int wp_page_copy(struct vm_fault *vmf)
>>  			inc_mm_counter_fast(mm, MM_ANONPAGES);
>>  		}
>>  		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
>> -		entry = mk_pte(new_page, vma->vm_page_prot);
>> -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
>> +		entry = mk_pte(new_page, vmf->vma_page_prot);
>> +		entry = __maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
>>  		/*
>>  		 * Clear the pte entry and flush it first, before updating the
>>  		 * pte with the new entry. This will avoid a race condition
> 
> Don't you also need to do this in do_swap_page()?

Indeed I'll drop this patch as all the changes are now done in the patch 11
"mm: Cache some VMA fields in the vm_fault structure" where, as you suggested,
maybe_mkwrite() is now getting passed the vm_flags value directly.

> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3067,9 +3067,9 @@ int do_swap_page(struct vm_fault *vmf)
> 
>  	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
>  	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
> -	pte = mk_pte(page, vma->vm_page_prot);
> +	pte = mk_pte(page, vmf->vma_page_prot);
>  	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
> -		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
> +		pte = __maybe_mkwrite(pte_mkdirty(pte), vmf->vma_flags);
>  		vmf->flags &= ~FAULT_FLAG_WRITE;
>  		ret |= VM_FAULT_WRITE;
>  		exclusive = RMAP_EXCLUSIVE;
> 
