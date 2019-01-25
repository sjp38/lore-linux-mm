Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF328E00CD
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 07:33:01 -0500 (EST)
Received: by mail-vk1-f197.google.com with SMTP id d123so2630367vkf.23
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 04:33:01 -0800 (PST)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id y9si18280523uaf.216.2019.01.25.04.32.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 04:33:00 -0800 (PST)
Message-ID: <5C4B01F1.5020100@huawei.com>
Date: Fri, 25 Jan 2019 20:32:49 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v11 00/26] Speculative page faults
References: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org> <5a24109c-7460-4a8e-a439-d2f2646568e6@codeaurora.org> <9ae5496f-7a51-e7b7-0061-5b68354a7945@linux.vnet.ibm.com> <e104a6dc-931b-944c-9555-dc1c001a57e0@codeaurora.org> <5C40A48F.6070306@huawei.com> <8bfaf41b-6d88-c0de-35c0-1c41db7a691e@linux.vnet.ibm.com> <5C474351.5030603@huawei.com> <0ab93858-dcd2-b28a-3445-6ed2f75b844b@linux.vnet.ibm.com>
In-Reply-To: <0ab93858-dcd2-b28a-3445-6ed2f75b844b@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Linux-MM <linux-mm@kvack.org>, charante@codeaurora.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

On 2019/1/24 16:20, Laurent Dufour wrote:
> Le 22/01/2019 à 17:22, zhong jiang a écrit :
>> On 2019/1/19 0:24, Laurent Dufour wrote:
>>> Le 17/01/2019 à 16:51, zhong jiang a écrit :
>>>> On 2019/1/16 19:41, Vinayak Menon wrote:
>>>>> On 1/15/2019 1:54 PM, Laurent Dufour wrote:
>>>>>> Le 14/01/2019 à 14:19, Vinayak Menon a écrit :
>>>>>>> On 1/11/2019 9:13 PM, Vinayak Menon wrote:
>>>>>>>> Hi Laurent,
>>>>>>>>
>>>>>>>> We are observing an issue with speculative page fault with the following test code on ARM64 (4.14 kernel, 8 cores).
>>>>>>>
>>>>>>> With the patch below, we don't hit the issue.
>>>>>>>
>>>>>>> From: Vinayak Menon <vinmenon@codeaurora.org>
>>>>>>> Date: Mon, 14 Jan 2019 16:06:34 +0530
>>>>>>> Subject: [PATCH] mm: flush stale tlb entries on speculative write fault
>>>>>>>
>>>>>>> It is observed that the following scenario results in
>>>>>>> threads A and B of process 1 blocking on pthread_mutex_lock
>>>>>>> forever after few iterations.
>>>>>>>
>>>>>>> CPU 1                   CPU 2                    CPU 3
>>>>>>> Process 1,              Process 1,               Process 1,
>>>>>>> Thread A                Thread B                 Thread C
>>>>>>>
>>>>>>> while (1) {             while (1) {              while(1) {
>>>>>>> pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
>>>>>>> pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
>>>>>>> }                       }
>>>>>>>
>>>>>>> When from thread C, copy_one_pte write-protects the parent pte
>>>>>>> (of lock l), stale tlb entries can exist with write permissions
>>>>>>> on one of the CPUs at least. This can create a problem if one
>>>>>>> of the threads A or B hits the write fault. Though dup_mmap calls
>>>>>>> flush_tlb_mm after copy_page_range, since speculative page fault
>>>>>>> does not take mmap_sem it can proceed further fixing a fault soon
>>>>>>> after CPU 3 does ptep_set_wrprotect. But the CPU with stale tlb
>>>>>>> entry can still modify old_page even after it is copied to
>>>>>>> new_page by wp_page_copy, thus causing a corruption.
>>>>>> Nice catch and thanks for your investigation!
>>>>>>
>>>>>> There is a real synchronization issue here between copy_page_range() and the speculative page fault handler. I didn't get it on PowerVM since the TLB are flushed when arch_exit_lazy_mode() is called in copy_page_range() but now, I can get it when running on x86_64.
>>>>>>
>>>>>>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>>>>>>> ---
>>>>>>>     mm/memory.c | 7 +++++++
>>>>>>>     1 file changed, 7 insertions(+)
>>>>>>>
>>>>>>> diff --git a/mm/memory.c b/mm/memory.c
>>>>>>> index 52080e4..1ea168ff 100644
>>>>>>> --- a/mm/memory.c
>>>>>>> +++ b/mm/memory.c
>>>>>>> @@ -4507,6 +4507,13 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>>>>>                    return VM_FAULT_RETRY;
>>>>>>>            }
>>>>>>>
>>>>>>> +       /*
>>>>>>> +        * Discard tlb entries created before ptep_set_wrprotect
>>>>>>> +        * in copy_one_pte
>>>>>>> +        */
>>>>>>> +       if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
>>>>>>> +               flush_tlb_page(vmf.vma, address);
>>>>>>> +
>>>>>>>            mem_cgroup_oom_enable();
>>>>>>>            ret = handle_pte_fault(&vmf);
>>>>>>>            mem_cgroup_oom_disable();
>>>>>> Your patch is fixing the race but I'm wondering about the cost of these tlb flushes. Here we are flushing on a per page basis (architecture like x86_64 are smarter and flush more pages) but there is a request to flush a range of tlb entries each time a cow page is newly touched. I think there could be some bad impact here.
>>>>>>
>>>>>> Another option would be to flush the range in copy_pte_range() before unlocking the page table lock. This will flush entries flush_tlb_mm() would later handle in dup_mmap() but that will be called once per fork per cow VMA.
>>>>>
>>>>> But wouldn't this cause an unnecessary impact if most of the COW pages remain untouched (which I assume would be the usual case) and thus do not create a fault ?
>>>>>
>>>>>
>>>>>> I tried the attached patch which seems to fix the issue on x86_64. Could you please give it a try on arm64 ?
>>>>>>
>>>>> Your patch works fine on arm64 with a minor change. Thanks Laurent.
>>>> Hi, Vinayak and Laurent
>>>>
>>>> I think the below change will impact the performance significantly. Becuase most of process has many
>>>> vmas with cow flags. Flush the tlb in advance is not the better way to avoid the issue and it will
>>>> call the flush_tlb_mm  later.
>>>>
>>>> I think we can try the following way to do.
>>>>
>>>> vm_write_begin(vma)
>>>> copy_pte_range
>>>> vm_write_end(vma)
>>>>
>>>> The speculative page fault will return to grap the mmap_sem to run the nromal path.
>>>> Any thought?
>>>
>>> Here is a new version of the patch fixing this issue. There is no additional TLB flush, all the fix is belonging on vm_write_{begin,end} calls.
>>>
>>> I did some test on x86_64 and PowerPC but that needs to be double check on arm64.
>>>
>>> Vinayak, Zhong, could you please give it a try ?
>>>
>> Hi Laurent
>>
>> I apply the patch you had attached and none of any abnormal thing came in two days. It is feasible to fix the issue.
>
> Good news !
>
>>
>> but It will better to filter the condition by is_cow_mapping. is it right?
>>
>> for example:
>>
>> if (is_cow_mapping(mnpt->vm_flags)) {
>>             ........
>> }
>
> That's doable for sure but I don't think this has to be introduce in dup_mmap().
> Unless there is a real performance benefit to do so, I don't think dup_mmap() has to mimic underlying checks done in copy_page_range().
>

Hi, Laurent

I test the performace with microbench after appling the patch. I find 
the page fault latency will increase about 8% than before.  I think we
should use is_cow_mapping to waken the impact and I will try it out.

or we can use the following solution to replace as Vinayak has said.
 
if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
    return VM_FAULT_RETRY;

Even though it will influence the performance of SPF, but at least it does
not bring in any negative impact. Any thought?

Thanks,


> Cheers,
> Laurent.
>
>
> .
>
