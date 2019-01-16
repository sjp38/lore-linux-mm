Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 44AE98E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 06:42:03 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id s22so3705306pgv.8
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 03:42:03 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id f22si5808996pgm.81.2019.01.16.03.42.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 03:42:01 -0800 (PST)
Subject: Re: [PATCH v11 00/26] Speculative page faults
References: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org>
 <5a24109c-7460-4a8e-a439-d2f2646568e6@codeaurora.org>
 <9ae5496f-7a51-e7b7-0061-5b68354a7945@linux.vnet.ibm.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <e104a6dc-931b-944c-9555-dc1c001a57e0@codeaurora.org>
Date: Wed, 16 Jan 2019 17:11:56 +0530
MIME-Version: 1.0
In-Reply-To: <9ae5496f-7a51-e7b7-0061-5b68354a7945@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Linux-MM <linux-mm@kvack.org>, charante@codeaurora.org, Ganesh Mahendran <opensource.ganesh@gmail.com>


On 1/15/2019 1:54 PM, Laurent Dufour wrote:
> Le 14/01/2019 à 14:19, Vinayak Menon a écrit :
>> On 1/11/2019 9:13 PM, Vinayak Menon wrote:
>>> Hi Laurent,
>>>
>>> We are observing an issue with speculative page fault with the following test code on ARM64 (4.14 kernel, 8 cores).
>>
>>
>> With the patch below, we don't hit the issue.
>>
>> From: Vinayak Menon <vinmenon@codeaurora.org>
>> Date: Mon, 14 Jan 2019 16:06:34 +0530
>> Subject: [PATCH] mm: flush stale tlb entries on speculative write fault
>>
>> It is observed that the following scenario results in
>> threads A and B of process 1 blocking on pthread_mutex_lock
>> forever after few iterations.
>>
>> CPU 1                   CPU 2                    CPU 3
>> Process 1,              Process 1,               Process 1,
>> Thread A                Thread B                 Thread C
>>
>> while (1) {             while (1) {              while(1) {
>> pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
>> pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
>> }                       }
>>
>> When from thread C, copy_one_pte write-protects the parent pte
>> (of lock l), stale tlb entries can exist with write permissions
>> on one of the CPUs at least. This can create a problem if one
>> of the threads A or B hits the write fault. Though dup_mmap calls
>> flush_tlb_mm after copy_page_range, since speculative page fault
>> does not take mmap_sem it can proceed further fixing a fault soon
>> after CPU 3 does ptep_set_wrprotect. But the CPU with stale tlb
>> entry can still modify old_page even after it is copied to
>> new_page by wp_page_copy, thus causing a corruption.
>
> Nice catch and thanks for your investigation!
>
> There is a real synchronization issue here between copy_page_range() and the speculative page fault handler. I didn't get it on PowerVM since the TLB are flushed when arch_exit_lazy_mode() is called in copy_page_range() but now, I can get it when running on x86_64.
>
>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>> ---
>>   mm/memory.c | 7 +++++++
>>   1 file changed, 7 insertions(+)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 52080e4..1ea168ff 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -4507,6 +4507,13 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>                  return VM_FAULT_RETRY;
>>          }
>>
>> +       /*
>> +        * Discard tlb entries created before ptep_set_wrprotect
>> +        * in copy_one_pte
>> +        */
>> +       if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
>> +               flush_tlb_page(vmf.vma, address);
>> +
>>          mem_cgroup_oom_enable();
>>          ret = handle_pte_fault(&vmf);
>>          mem_cgroup_oom_disable();
>
> Your patch is fixing the race but I'm wondering about the cost of these tlb flushes. Here we are flushing on a per page basis (architecture like x86_64 are smarter and flush more pages) but there is a request to flush a range of tlb entries each time a cow page is newly touched. I think there could be some bad impact here.
>
> Another option would be to flush the range in copy_pte_range() before unlocking the page table lock. This will flush entries flush_tlb_mm() would later handle in dup_mmap() but that will be called once per fork per cow VMA.


But wouldn't this cause an unnecessary impact if most of the COW pages remain untouched (which I assume would be the usual case) and thus do not create a fault ?


>
> I tried the attached patch which seems to fix the issue on x86_64. Could you please give it a try on arm64 ?
>

Your patch works fine on arm64 with a minor change. Thanks Laurent.

diff --git a/mm/memory.c b/mm/memory.c
index 52080e4..4767095 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1087,6 +1087,7 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
        spinlock_t *src_ptl, *dst_ptl;
        int progress = 0;
        int rss[NR_MM_COUNTERS];
+       unsigned long orig_addr = addr;
        swp_entry_t entry = (swp_entry_t){0};

 again:
@@ -1125,6 +1126,15 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
        } while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);

        arch_leave_lazy_mmu_mode();
+
+       /*
+        * Prevent the page fault handler to copy the page while stale tlb entry
+        * are still not flushed.
+        */
+       if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT) &&
+               is_cow_mapping(vma->vm_flags))
+                       flush_tlb_range(vma, orig_addr, end);
+
        spin_unlock(src_ptl);
        pte_unmap(orig_src_pte);
        add_mm_rss_vec(dst_mm, rss);

Thanks,

Vinayak
