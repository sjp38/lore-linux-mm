Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18B528E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:45:52 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w1so20697220qta.12
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 07:45:52 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e10si2947743qtg.55.2019.01.28.07.45.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 07:45:50 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0SFbvgZ111175
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:45:50 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qa3r2ud3f-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:45:49 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 28 Jan 2019 15:45:48 -0000
Subject: Re: [PATCH v11 00/26] Speculative page faults
References: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org>
 <5a24109c-7460-4a8e-a439-d2f2646568e6@codeaurora.org>
 <9ae5496f-7a51-e7b7-0061-5b68354a7945@linux.vnet.ibm.com>
 <e104a6dc-931b-944c-9555-dc1c001a57e0@codeaurora.org>
 <5C40A48F.6070306@huawei.com>
 <8bfaf41b-6d88-c0de-35c0-1c41db7a691e@linux.vnet.ibm.com>
 <5C474351.5030603@huawei.com>
 <0ab93858-dcd2-b28a-3445-6ed2f75b844b@linux.vnet.ibm.com>
 <5C4B01F1.5020100@huawei.com>
 <77ff7d2e-38aa-137b-6800-9b328239a321@linux.vnet.ibm.com>
 <5C4F0D13.5070100@huawei.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 28 Jan 2019 16:45:42 +0100
MIME-Version: 1.0
In-Reply-To: <5C4F0D13.5070100@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <c2217ac1-1a16-44f6-2f9e-d294121d3ed0@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Linux-MM <linux-mm@kvack.org>, charante@codeaurora.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

Le 28/01/2019 à 15:09, zhong jiang a écrit :
> On 2019/1/28 16:59, Laurent Dufour wrote:
>> Le 25/01/2019 à 13:32, zhong jiang a écrit :
>>> On 2019/1/24 16:20, Laurent Dufour wrote:
>>>> Le 22/01/2019 à 17:22, zhong jiang a écrit :
>>>>> On 2019/1/19 0:24, Laurent Dufour wrote:
>>>>>> Le 17/01/2019 à 16:51, zhong jiang a écrit :
>>>>>>> On 2019/1/16 19:41, Vinayak Menon wrote:
>>>>>>>> On 1/15/2019 1:54 PM, Laurent Dufour wrote:
>>>>>>>>> Le 14/01/2019 à 14:19, Vinayak Menon a écrit :
>>>>>>>>>> On 1/11/2019 9:13 PM, Vinayak Menon wrote:
>>>>>>>>>>> Hi Laurent,
>>>>>>>>>>>
>>>>>>>>>>> We are observing an issue with speculative page fault with the following test code on ARM64 (4.14 kernel, 8 cores).
>>>>>>>>>>
>>>>>>>>>> With the patch below, we don't hit the issue.
>>>>>>>>>>
>>>>>>>>>> From: Vinayak Menon <vinmenon@codeaurora.org>
>>>>>>>>>> Date: Mon, 14 Jan 2019 16:06:34 +0530
>>>>>>>>>> Subject: [PATCH] mm: flush stale tlb entries on speculative write fault
>>>>>>>>>>
>>>>>>>>>> It is observed that the following scenario results in
>>>>>>>>>> threads A and B of process 1 blocking on pthread_mutex_lock
>>>>>>>>>> forever after few iterations.
>>>>>>>>>>
>>>>>>>>>> CPU 1                   CPU 2                    CPU 3
>>>>>>>>>> Process 1,              Process 1,               Process 1,
>>>>>>>>>> Thread A                Thread B                 Thread C
>>>>>>>>>>
>>>>>>>>>> while (1) {             while (1) {              while(1) {
>>>>>>>>>> pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
>>>>>>>>>> pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
>>>>>>>>>> }                       }
>>>>>>>>>>
>>>>>>>>>> When from thread C, copy_one_pte write-protects the parent pte
>>>>>>>>>> (of lock l), stale tlb entries can exist with write permissions
>>>>>>>>>> on one of the CPUs at least. This can create a problem if one
>>>>>>>>>> of the threads A or B hits the write fault. Though dup_mmap calls
>>>>>>>>>> flush_tlb_mm after copy_page_range, since speculative page fault
>>>>>>>>>> does not take mmap_sem it can proceed further fixing a fault soon
>>>>>>>>>> after CPU 3 does ptep_set_wrprotect. But the CPU with stale tlb
>>>>>>>>>> entry can still modify old_page even after it is copied to
>>>>>>>>>> new_page by wp_page_copy, thus causing a corruption.
>>>>>>>>> Nice catch and thanks for your investigation!
>>>>>>>>>
>>>>>>>>> There is a real synchronization issue here between copy_page_range() and the speculative page fault handler. I didn't get it on PowerVM since the TLB are flushed when arch_exit_lazy_mode() is called in copy_page_range() but now, I can get it when running on x86_64.
>>>>>>>>>
>>>>>>>>>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>>>>>>>>>> ---
>>>>>>>>>>       mm/memory.c | 7 +++++++
>>>>>>>>>>       1 file changed, 7 insertions(+)
>>>>>>>>>>
>>>>>>>>>> diff --git a/mm/memory.c b/mm/memory.c
>>>>>>>>>> index 52080e4..1ea168ff 100644
>>>>>>>>>> --- a/mm/memory.c
>>>>>>>>>> +++ b/mm/memory.c
>>>>>>>>>> @@ -4507,6 +4507,13 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>>>>>>>>                      return VM_FAULT_RETRY;
>>>>>>>>>>              }
>>>>>>>>>>
>>>>>>>>>> +       /*
>>>>>>>>>> +        * Discard tlb entries created before ptep_set_wrprotect
>>>>>>>>>> +        * in copy_one_pte
>>>>>>>>>> +        */
>>>>>>>>>> +       if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
>>>>>>>>>> +               flush_tlb_page(vmf.vma, address);
>>>>>>>>>> +
>>>>>>>>>>              mem_cgroup_oom_enable();
>>>>>>>>>>              ret = handle_pte_fault(&vmf);
>>>>>>>>>>              mem_cgroup_oom_disable();
>>>>>>>>> Your patch is fixing the race but I'm wondering about the cost of these tlb flushes. Here we are flushing on a per page basis (architecture like x86_64 are smarter and flush more pages) but there is a request to flush a range of tlb entries each time a cow page is newly touched. I think there could be some bad impact here.
>>>>>>>>>
>>>>>>>>> Another option would be to flush the range in copy_pte_range() before unlocking the page table lock. This will flush entries flush_tlb_mm() would later handle in dup_mmap() but that will be called once per fork per cow VMA.
>>>>>>>>
>>>>>>>> But wouldn't this cause an unnecessary impact if most of the COW pages remain untouched (which I assume would be the usual case) and thus do not create a fault ?
>>>>>>>>
>>>>>>>>
>>>>>>>>> I tried the attached patch which seems to fix the issue on x86_64. Could you please give it a try on arm64 ?
>>>>>>>>>
>>>>>>>> Your patch works fine on arm64 with a minor change. Thanks Laurent.
>>>>>>> Hi, Vinayak and Laurent
>>>>>>>
>>>>>>> I think the below change will impact the performance significantly. Becuase most of process has many
>>>>>>> vmas with cow flags. Flush the tlb in advance is not the better way to avoid the issue and it will
>>>>>>> call the flush_tlb_mm  later.
>>>>>>>
>>>>>>> I think we can try the following way to do.
>>>>>>>
>>>>>>> vm_write_begin(vma)
>>>>>>> copy_pte_range
>>>>>>> vm_write_end(vma)
>>>>>>>
>>>>>>> The speculative page fault will return to grap the mmap_sem to run the nromal path.
>>>>>>> Any thought?
>>>>>>
>>>>>> Here is a new version of the patch fixing this issue. There is no additional TLB flush, all the fix is belonging on vm_write_{begin,end} calls.
>>>>>>
>>>>>> I did some test on x86_64 and PowerPC but that needs to be double check on arm64.
>>>>>>
>>>>>> Vinayak, Zhong, could you please give it a try ?
>>>>>>
>>>>> Hi Laurent
>>>>>
>>>>> I apply the patch you had attached and none of any abnormal thing came in two days. It is feasible to fix the issue.
>>>>
>>>> Good news !
>>>>
>>>>>
>>>>> but It will better to filter the condition by is_cow_mapping. is it right?
>>>>>
>>>>> for example:
>>>>>
>>>>> if (is_cow_mapping(mnpt->vm_flags)) {
>>>>>               ........
>>>>> }
>>>>
>>>> That's doable for sure but I don't think this has to be introduce in dup_mmap().
>>>> Unless there is a real performance benefit to do so, I don't think dup_mmap() has to mimic underlying checks done in copy_page_range().
>>>>
>>>
>>> Hi, Laurent
>>>
>>> I test the performace with microbench after appling the patch. I find
>>> the page fault latency will increase about 8% than before.  I think we
>>> should use is_cow_mapping to waken the impact and I will try it out.
>>
>> That's interesting,  I would not expect such a higher latency assuming that most of the area not in copied on write are also not managed by the speculative page fault handler (file mapping, etc.). Anyway I'm looking forward to see the result with additional is_cow_mapping() check.
>>
> I test the performance again. It is the protect error access latency in lat_sig.c that it will result in a drop of 8% in that testcase.

What is that "protect error access latency in lat_sig.c" ?

> The page fault latency, In fact, does not impact the performace. It seems to just the fluctuation.
> 
> Thanks,
> zhong jiang
>>> or we can use the following solution to replace as Vinayak has said.
>>>
>>> if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
>>>       return VM_FAULT_RETRY;
>>>
>>> Even though it will influence the performance of SPF, but at least it does
>>> not bring in any negative impact. Any thought?
>>
>> I don't agree, this checks will completely by pass the SPF handler for all the COW areas, even if there is no race situation.
>>
>> Cheers,
>> Laurent.
>>>
>>> Thanks,
>>>
>>>
>>>> Cheers,
>>>> Laurent.
>>>>
>>>>
>>>> .
>>>>
>>>
>>>
>>
>>
>>
> 
> 
