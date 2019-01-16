Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1AAD88E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:31:35 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id j5so5535469qtk.11
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 05:31:35 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 52si3497399qvr.211.2019.01.16.05.31.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 05:31:34 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0GDOaqa063978
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:31:33 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2q23br6mrm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:31:33 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 16 Jan 2019 13:31:26 -0000
Subject: Re: [PATCH v11 00/26] Speculative page faults
References: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org>
 <5a24109c-7460-4a8e-a439-d2f2646568e6@codeaurora.org>
 <9ae5496f-7a51-e7b7-0061-5b68354a7945@linux.vnet.ibm.com>
 <47efe258-8953-293b-296b-fe41dd0fbf98@codeaurora.org>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 16 Jan 2019 14:31:21 +0100
MIME-Version: 1.0
In-Reply-To: <47efe258-8953-293b-296b-fe41dd0fbf98@codeaurora.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <7504ec6e-0764-769e-eaca-006fcc8ee38b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Linux-MM <linux-mm@kvack.org>, charante@codeaurora.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

Le 16/01/2019 à 12:41, Vinayak Menon a écrit :
> 
> On 1/15/2019 1:54 PM, Laurent Dufour wrote:
>> Le 14/01/2019 à 14:19, Vinayak Menon a écrit :
>>> On 1/11/2019 9:13 PM, Vinayak Menon wrote:
>>>> Hi Laurent,
>>>>
>>>> We are observing an issue with speculative page fault with the following test code on ARM64 (4.14 kernel, 8 cores).
>>>
>>>
>>> With the patch below, we don't hit the issue.
>>>
>>> From: Vinayak Menon <vinmenon@codeaurora.org>
>>> Date: Mon, 14 Jan 2019 16:06:34 +0530
>>> Subject: [PATCH] mm: flush stale tlb entries on speculative write fault
>>>
>>> It is observed that the following scenario results in
>>> threads A and B of process 1 blocking on pthread_mutex_lock
>>> forever after few iterations.
>>>
>>> CPU 1                   CPU 2                    CPU 3
>>> Process 1,              Process 1,               Process 1,
>>> Thread A                Thread B                 Thread C
>>>
>>> while (1) {             while (1) {              while(1) {
>>> pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
>>> pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
>>> }                       }
>>>
>>> When from thread C, copy_one_pte write-protects the parent pte
>>> (of lock l), stale tlb entries can exist with write permissions
>>> on one of the CPUs at least. This can create a problem if one
>>> of the threads A or B hits the write fault. Though dup_mmap calls
>>> flush_tlb_mm after copy_page_range, since speculative page fault
>>> does not take mmap_sem it can proceed further fixing a fault soon
>>> after CPU 3 does ptep_set_wrprotect. But the CPU with stale tlb
>>> entry can still modify old_page even after it is copied to
>>> new_page by wp_page_copy, thus causing a corruption.
>>
>> Nice catch and thanks for your investigation!
>>
>> There is a real synchronization issue here between copy_page_range() and the speculative page fault handler. I didn't get it on PowerVM since the TLB are flushed when arch_exit_lazy_mode() is called in copy_page_range() but now, I can get it when running on x86_64.
>>
>>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>>> ---
>>>    mm/memory.c | 7 +++++++
>>>    1 file changed, 7 insertions(+)
>>>
>>> diff --git a/mm/memory.c b/mm/memory.c
>>> index 52080e4..1ea168ff 100644
>>> --- a/mm/memory.c
>>> +++ b/mm/memory.c
>>> @@ -4507,6 +4507,13 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>                   return VM_FAULT_RETRY;
>>>           }
>>>
>>> +       /*
>>> +        * Discard tlb entries created before ptep_set_wrprotect
>>> +        * in copy_one_pte
>>> +        */
>>> +       if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
>>> +               flush_tlb_page(vmf.vma, address);
>>> +
>>>           mem_cgroup_oom_enable();
>>>           ret = handle_pte_fault(&vmf);
>>>           mem_cgroup_oom_disable();
>>
>> Your patch is fixing the race but I'm wondering about the cost of these tlb flushes. Here we are flushing on a per page basis (architecture like x86_64 are smarter and flush more pages) but there is a request to flush a range of tlb entries each time a cow page is newly touched. I think there could be some bad impact here.
>>
>> Another option would be to flush the range in copy_pte_range() before unlocking the page table lock. This will flush entries flush_tlb_mm() would later handle in dup_mmap() but that will be called once per fork per cow VMA.
> 
> 
> But wouldn't this cause an unnecessary impact if most of the COW pages remain untouched (which I assume would be the usual case) and thus do not create a fault ?

I think this should be less costly to do it per vma at the time of the 
fork instead of per page hit once the fork has been done, since this 
will happen in both the forked task and the forking one (the COW pages 
are concerning the both sides of the fork).

>>
>> I tried the attached patch which seems to fix the issue on x86_64. Could you please give it a try on arm64 ?
>>
> 
> Your patch works fine on arm64 with a minor change. Thanks Laurent.

Yup my mistake !
I tried to shrink the patch after testing it, sounds that I shrunk it 
far too much...

> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 52080e4..4767095 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1087,6 +1087,7 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>          spinlock_t *src_ptl, *dst_ptl;
>          int progress = 0;
>          int rss[NR_MM_COUNTERS];
> +       unsigned long orig_addr = addr;
>          swp_entry_t entry = (swp_entry_t){0};
> 
>   again:
> @@ -1125,6 +1126,15 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>          } while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
> 
>          arch_leave_lazy_mmu_mode();
> +
> +       /*
> +        * Prevent the page fault handler to copy the page while stale tlb entry
> +        * are still not flushed.
> +        */
> +       if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT) &&
> +               is_cow_mapping(vma->vm_flags))
> +                       flush_tlb_range(vma, orig_addr, end);
> +
>          spin_unlock(src_ptl);
>          pte_unmap(orig_src_pte);
>          add_mm_rss_vec(dst_mm, rss);
> 
> Thanks,
> 
> Vinayak
> 
