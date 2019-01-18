Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BBB008E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 10:53:56 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so8779205pgi.14
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 07:53:56 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k22si4692259pls.14.2019.01.18.07.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 07:53:55 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0IFrgX1044919
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 10:53:54 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q3ha79hxw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 10:53:49 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 18 Jan 2019 15:51:38 -0000
Subject: Re: [PATCH v11 00/26] Speculative page faults
References: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org>
 <5a24109c-7460-4a8e-a439-d2f2646568e6@codeaurora.org>
 <9ae5496f-7a51-e7b7-0061-5b68354a7945@linux.vnet.ibm.com>
 <e104a6dc-931b-944c-9555-dc1c001a57e0@codeaurora.org>
 <5C40A48F.6070306@huawei.com>
 <38d69e03-df52-394e-514d-bdadc8f640ca@linux.vnet.ibm.com>
 <5C41F3B5.5030700@huawei.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Fri, 18 Jan 2019 16:51:33 +0100
MIME-Version: 1.0
In-Reply-To: <5C41F3B5.5030700@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <8b8ae1b0-39a3-7e83-589d-0bb4263b0a99@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Linux-MM <linux-mm@kvack.org>, charante@codeaurora.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

Le 18/01/2019 à 16:41, zhong jiang a écrit :
> On 2019/1/18 17:29, Laurent Dufour wrote:
>> Le 17/01/2019 à 16:51, zhong jiang a écrit :
>>> On 2019/1/16 19:41, Vinayak Menon wrote:
>>>> On 1/15/2019 1:54 PM, Laurent Dufour wrote:
>>>>> Le 14/01/2019 à 14:19, Vinayak Menon a écrit :
>>>>>> On 1/11/2019 9:13 PM, Vinayak Menon wrote:
>>>>>>> Hi Laurent,
>>>>>>>
>>>>>>> We are observing an issue with speculative page fault with the following test code on ARM64 (4.14 kernel, 8 cores).
>>>>>>
>>>>>> With the patch below, we don't hit the issue.
>>>>>>
>>>>>> From: Vinayak Menon <vinmenon@codeaurora.org>
>>>>>> Date: Mon, 14 Jan 2019 16:06:34 +0530
>>>>>> Subject: [PATCH] mm: flush stale tlb entries on speculative write fault
>>>>>>
>>>>>> It is observed that the following scenario results in
>>>>>> threads A and B of process 1 blocking on pthread_mutex_lock
>>>>>> forever after few iterations.
>>>>>>
>>>>>> CPU 1                   CPU 2                    CPU 3
>>>>>> Process 1,              Process 1,               Process 1,
>>>>>> Thread A                Thread B                 Thread C
>>>>>>
>>>>>> while (1) {             while (1) {              while(1) {
>>>>>> pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
>>>>>> pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
>>>>>> }                       }
>>>>>>
>>>>>> When from thread C, copy_one_pte write-protects the parent pte
>>>>>> (of lock l), stale tlb entries can exist with write permissions
>>>>>> on one of the CPUs at least. This can create a problem if one
>>>>>> of the threads A or B hits the write fault. Though dup_mmap calls
>>>>>> flush_tlb_mm after copy_page_range, since speculative page fault
>>>>>> does not take mmap_sem it can proceed further fixing a fault soon
>>>>>> after CPU 3 does ptep_set_wrprotect. But the CPU with stale tlb
>>>>>> entry can still modify old_page even after it is copied to
>>>>>> new_page by wp_page_copy, thus causing a corruption.
>>>>> Nice catch and thanks for your investigation!
>>>>>
>>>>> There is a real synchronization issue here between copy_page_range() and the speculative page fault handler. I didn't get it on PowerVM since the TLB are flushed when arch_exit_lazy_mode() is called in copy_page_range() but now, I can get it when running on x86_64.
>>>>>
>>>>>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>>>>>> ---
>>>>>>     mm/memory.c | 7 +++++++
>>>>>>     1 file changed, 7 insertions(+)
>>>>>>
>>>>>> diff --git a/mm/memory.c b/mm/memory.c
>>>>>> index 52080e4..1ea168ff 100644
>>>>>> --- a/mm/memory.c
>>>>>> +++ b/mm/memory.c
>>>>>> @@ -4507,6 +4507,13 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>>>>                    return VM_FAULT_RETRY;
>>>>>>            }
>>>>>>
>>>>>> +       /*
>>>>>> +        * Discard tlb entries created before ptep_set_wrprotect
>>>>>> +        * in copy_one_pte
>>>>>> +        */
>>>>>> +       if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
>>>>>> +               flush_tlb_page(vmf.vma, address);
>>>>>> +
>>>>>>            mem_cgroup_oom_enable();
>>>>>>            ret = handle_pte_fault(&vmf);
>>>>>>            mem_cgroup_oom_disable();
>>>>> Your patch is fixing the race but I'm wondering about the cost of these tlb flushes. Here we are flushing on a per page basis (architecture like x86_64 are smarter and flush more pages) but there is a request to flush a range of tlb entries each time a cow page is newly touched. I think there could be some bad impact here.
>>>>>
>>>>> Another option would be to flush the range in copy_pte_range() before unlocking the page table lock. This will flush entries flush_tlb_mm() would later handle in dup_mmap() but that will be called once per fork per cow VMA.
>>>>
>>>> But wouldn't this cause an unnecessary impact if most of the COW pages remain untouched (which I assume would be the usual case) and thus do not create a fault ?
>>>>
>>>>
>>>>> I tried the attached patch which seems to fix the issue on x86_64. Could you please give it a try on arm64 ?
>>>>>
>>>> Your patch works fine on arm64 with a minor change. Thanks Laurent.
>>> Hi, Vinayak and Laurent
>>>
>>> I think the below change will impact the performance significantly. Becuase most of process has many
>>> vmas with cow flags. Flush the tlb in advance is not the better way to avoid the issue and it will
>>> call the flush_tlb_mm  later.
>>>
>>> I think we can try the following way to do.
>>>
>>> vm_write_begin(vma)
>>> copy_pte_range
>>> vm_write_end(vma)
>>>
>>> The speculative page fault will return to grap the mmap_sem to run the nromal path.
>>> Any thought?
>>
>> Hi Zhong,
>>
>> I agree that flushing the TLB could have a bad impact on the performance, but tagging the VMA when copy_pte_range() is not fixing the issue as the VMA must be flagged until the PTE are flushed.
>>
>> Here is what happens:
>>
>> CPU A                CPU B                       CPU C
>> fork()
>> copy_pte_range()
>>    set PTE rdonly
>> got to next VMA...
>>   .                   PTE is seen rdonly             PTE still writable
>>   .                   thread is writing to page
>>   .                   -> page fault
>>   .                     copy the page             Thread writes to page
>>   .                      .                        -> no page fault
>>   .                     update the PTE
>>   .                     flush TLB for that PTE
>> flush TLB                                        PTE are now rdonly
>>
>> So the write done by the CPU C is interfering with the page copy operation done by CPU B, leading to the data corruption.
>>
> I want to know the case if the CPU B has finished in front of the CPU C that the data still is vaild ?

If the CPU B has done the flush TLB then the CPU C will write data to 
the right page. If the CPU B has not yet done the flush of the TLB as 
the time the CPU C is writing data, then this roughly the same issue.

Anyway this is fixed with the patch I'm about to sent for testing on arm64.

Cheers,
Laurent.

> 
> This is to say, the old_page will be changed from other cpu because of the access from other cpu.
> 
> Maybe this is a stupid qestion :-)
> 
> Thanks,
> zhong jiang.
>> Flushing the PTE in copy_pte_range() is fixing the issue as the CPU C is seeing the PTE as rdonly earlier. But this impacts performance.
>>
>> Another option, I'll work on is to flag _all the COW eligible_ VMA before starting copying them and until the PTE are flushed on the CPU A.
>> This way when the CPU B will page fault the speculative handler will abort because the VMA is in the way to be touched.
>>
>> But I need to ensure that all the calls to copy_pte_range() are handling this correctly.
>>
>> Laurent.
>>
>>
>> .
>>
> 
> 
