Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31F91C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 19:56:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D92D0208CB
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 19:56:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D92D0208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 758126B000D; Tue,  7 May 2019 15:56:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 708A06B000E; Tue,  7 May 2019 15:56:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A8346B0010; Tue,  7 May 2019 15:56:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 25DDE6B000D
	for <linux-mm@kvack.org>; Tue,  7 May 2019 15:56:19 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id q82so6271653oif.7
        for <linux-mm@kvack.org>; Tue, 07 May 2019 12:56:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=t1ojwRD9cQPNrBIHASG8I3Oo2o5r6EtfeN1mzGkOdYU=;
        b=mBMC6ncx6fEzTyFMsBPqojsUUKws/syxJ09LsXJEce4TLh6lI+zHjTUbOe/+yKTYYF
         8jhMRtQFxwx7sxSzcn0VvDjiYORXkt5kWRMYCxhBd2XjBTRwe0FxLhJT3FXFtxJK2JIN
         w2gcBhhN3M4L2vXjtU+mTf4MIWpaljxCmsj9t11Yj1u36urd8BU42GD4YMqzeps80opC
         WhutgtR5/1FobAsRr9gjNnfe83UvDaYm7ryvTxqXmJwoSWWQi8zgFaVatIR1cwzyE5Jw
         DYEV/zE96OzsCl8uMYdZveE0cwPylx+veRoh1e2+u+QImZDHpXu/X80iQPWTSC1gayfk
         1fdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXX83kYrrSjf/gtqYjdonAoTKhpobQCQosL1pkJmZRINHdLeUdO
	P/k5G1ZZ+qxoNu7MEvlBTzDajcg5zWAODxqeZgSx651d2IEw94KIVYZYlM7TMgfhgB1LD5r4qQK
	Mx9kUP4XpMZxKRD7LmGCrlICBIpnQvR7D8+mXZC3TGj4hv5M2gXrMNDpZVJZHuppPoQ==
X-Received: by 2002:aca:ba0b:: with SMTP id k11mr108619oif.57.1557258978812;
        Tue, 07 May 2019 12:56:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxafUw8CeNgNMdtrpStzcT/1hA7oBCKn0X2//vO6/2zHA7e9mWcLqA0+qUpTUIPklKbjwK5
X-Received: by 2002:aca:ba0b:: with SMTP id k11mr108560oif.57.1557258977719;
        Tue, 07 May 2019 12:56:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557258977; cv=none;
        d=google.com; s=arc-20160816;
        b=b7OLCfe7nDENPXAVuCPy0ejooAoiDFwPVuulosacD4LBige4Gsjg/JoHRuDTWLZ85W
         DZ5QmGzxfxEawN+LsRHu9f/6++hEH878Rujr9KsevO5urCqKA+h2IayVU6BQtTQJsHYl
         pNpSXvrYApZKOT/zvjTLPx0D/T88KYnEnAPTed0O5SEd8IItorTgyNel8B2tuU570rsr
         2WRaUEt+CerZOgQ0zj2C/UJ3n4GZeQH0zIfZ4SjmxpJm9wLNMnXLTqBIvcpx+w6JooWQ
         4QoJktBEdO3Vo4AJRK3TfNJdfa3VOI7nLSraQadDTREP436Q7qZqK5xkZ5WQdGrOyftq
         TLqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=t1ojwRD9cQPNrBIHASG8I3Oo2o5r6EtfeN1mzGkOdYU=;
        b=Q9ofwb9+zNNDuCDGB1AHoA26qQ30zwDKcsijo2Fg9JFBP1ZyeAasMhX5e+23iwzQLd
         p37zjSB016owcvJOm3tMpCIKUQEEPPIZCC5af76KYB5MM+/akdR+f2933CX7uTYNwbch
         9oHIo9K+Tt1tU3preEVTN+Kfn86vngNutMxty1tVXR2nHFmkfw6W2/atiwGbP/isjCD9
         UgPvuAWfe0zLwy5YZl0vhZrYcDkCLI/sCKKEfy/YVDm09GEOfwrcKEn+cgmAY6ujKxDn
         XaqTQ12MNnEfQnDC71sMyFmWT1cRgB4h2se5Q2hrTQ09fz00B+FNoqrd9oGI6M1XyIv0
         rRqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id e17si9163879otl.79.2019.05.07.12.56.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 12:56:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TR87.TL_1557258953;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TR87.TL_1557258953)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 08 May 2019 03:55:57 +0800
Subject: Re: [bug] aarch64: userspace stalls on page fault after dd2283f2605e
 ("mm: mmap: zap pages with read mmap_sem in munmap")
To: Jan Stancek <jstancek@redhat.com>
Cc: will deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, kirill@shutemov.name, willy@infradead.org,
 kirill shutemov <kirill.shutemov@linux.intel.com>, vbabka@suse.cz,
 Andrea Arcangeli <aarcange@redhat.com>, akpm@linux-foundation.org,
 Waiman Long <longman@redhat.com>, Mel Gorman <mgorman@techsingularity.net>,
 Rik van Riel <riel@surriel.com>, catalin marinas <catalin.marinas@arm.com>
References: <1817839533.20996552.1557065445233.JavaMail.zimbra@redhat.com>
 <a9d5efea-6088-67c5-8711-f0657a852813@linux.alibaba.com>
 <1928544225.21255545.1557178548494.JavaMail.zimbra@redhat.com>
 <2b2006bf-753b-c4b8-e9a2-fd27ae65fe14@linux.alibaba.com>
 <756571293.21386229.1557229889545.JavaMail.zimbra@redhat.com>
 <3d0843fa-1a34-1d5a-ca4d-abe4032bad8b@linux.alibaba.com>
 <2058828796.21479120.1557249568244.JavaMail.zimbra@redhat.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <7bec117d-d8cf-d479-2e11-c286e96ec622@linux.alibaba.com>
Date: Tue, 7 May 2019 12:55:51 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <2058828796.21479120.1557249568244.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/7/19 10:19 AM, Jan Stancek wrote:
> ----- Original Message -----
>>
>> On 5/7/19 4:51 AM, Jan Stancek wrote:
>>> ----- Original Message -----
>>>> On 5/6/19 2:35 PM, Jan Stancek wrote:
>>>>> ----- Original Message -----
>>>>>> On 5/5/19 7:10 AM, Jan Stancek wrote:
>>>>>>> Hi,
>>>>>>>
>>>>>>> I'm seeing userspace program getting stuck on aarch64, on kernels 4.20
>>>>>>> and
>>>>>>> newer.
>>>>>>> It stalls from seconds to hours.
>>>>>>>
>>>>>>> I have simplified it to following scenario (reproducer linked below
>>>>>>> [1]):
>>>>>>>       while (1):
>>>>>>>         spawn Thread 1: mmap, write, munmap
>>>>>>>         spawn Thread 2: <nothing>
>>>>>>>
>>>>>>> Thread 1 is sporadically getting stuck on write to mapped area.
>>>>>>> User-space
>>>>>>> is not
>>>>>>> moving forward - stdout output stops. Observed CPU usage is however
>>>>>>> 100%.
>>>>>>>
>>>>>>> At this time, kernel appears to be busy handling page faults (~700k per
>>>>>>> second):
>>>>>>>
>>>>>>> # perf top -a -g
>>>>>>> -   98.97%     8.30%  a.out                     [.] map_write_unmap
>>>>>>>        - 23.52% map_write_unmap
>>>>>>>           - 24.29% el0_sync
>>>>>>>              - 10.42% do_mem_abort
>>>>>>>                 - 17.81% do_translation_fault
>>>>>>>                    - 33.01% do_page_fault
>>>>>>>                       - 56.18% handle_mm_fault
>>>>>>>                            40.26% __handle_mm_fault
>>>>>>>                            2.19% __ll_sc___cmpxchg_case_acq_4
>>>>>>>                            0.87% mem_cgroup_from_task
>>>>>>>                       - 6.18% find_vma
>>>>>>>                            5.38% vmacache_find
>>>>>>>                         1.35% __ll_sc___cmpxchg_case_acq_8
>>>>>>>                         1.23% __ll_sc_atomic64_sub_return_release
>>>>>>>                         0.78% down_read_trylock
>>>>>>>                0.93% do_translation_fault
>>>>>>>        + 8.30% thread_start
>>>>>>>
>>>>>>> #  perf stat -p 8189 -d
>>>>>>> ^C
>>>>>>>      Performance counter stats for process id '8189':
>>>>>>>
>>>>>>>             984.311350      task-clock (msec)         #    1.000 CPUs
>>>>>>>             utilized
>>>>>>>                      0      context-switches          #    0.000 K/sec
>>>>>>>                      0      cpu-migrations            #    0.000 K/sec
>>>>>>>                723,641      page-faults               #    0.735 M/sec
>>>>>>>          2,559,199,434      cycles                    #    2.600 GHz
>>>>>>>            711,933,112      instructions              #    0.28  insn
>>>>>>>            per
>>>>>>>            cycle
>>>>>>>        <not supported>      branches
>>>>>>>                757,658      branch-misses
>>>>>>>            205,840,557      L1-dcache-loads           #  209.121 M/sec
>>>>>>>             40,561,529      L1-dcache-load-misses     #   19.71% of all
>>>>>>>             L1-dcache hits
>>>>>>>        <not supported>      LLC-loads
>>>>>>>        <not supported>      LLC-load-misses
>>>>>>>
>>>>>>>            0.984454892 seconds time elapsed
>>>>>>>
>>>>>>> With some extra traces, it appears looping in page fault for same
>>>>>>> address,
>>>>>>> over and over:
>>>>>>>       do_page_fault // mm_flags: 0x55
>>>>>>>         __do_page_fault
>>>>>>>           __handle_mm_fault
>>>>>>>             handle_pte_fault
>>>>>>>               ptep_set_access_flags
>>>>>>>                 if (pte_same(pte, entry))  // pte: e8000805060f53,
>>>>>>>                 entry:
>>>>>>>                 e8000805060f53
>>>>>>>
>>>>>>> I had traces in mmap() and munmap() as well, they don't get hit when
>>>>>>> reproducer
>>>>>>> hits the bad state.
>>>>>>>
>>>>>>> Notes:
>>>>>>> - I'm not able to reproduce this on x86.
>>>>>>> - Attaching GDB or strace immediatelly recovers application from stall.
>>>>>>> - It also seems to recover faster when system is busy with other tasks.
>>>>>>> - MAP_SHARED vs. MAP_PRIVATE makes no difference.
>>>>>>> - Turning off THP makes no difference.
>>>>>>> - Reproducer [1] usually hits it within ~minute on HW described below.
>>>>>>> - Longman mentioned that "When the rwsem becomes reader-owned, it
>>>>>>> causes
>>>>>>>       all the spinning writers to go to sleep adding wakeup latency to
>>>>>>>       the time required to finish the critical sections", but this looks
>>>>>>>       like busy loop, so I'm not sure if it's related to rwsem issues
>>>>>>>       identified
>>>>>>>       in:
>>>>>>>       https://lore.kernel.org/lkml/20190428212557.13482-2-longman@redhat.com/
>>>>>> It sounds possible to me. What the optimization done by the commit ("mm:
>>>>>> mmap: zap pages with read mmap_sem in munmap") is to downgrade write
>>>>>> rwsem to read when zapping pages and page table in munmap() after the
>>>>>> vmas have been detached from the rbtree.
>>>>>>
>>>>>> So the mmap(), which is writer, in your test may steal the lock and
>>>>>> execute with the munmap(), which is the reader after the downgrade, in
>>>>>> parallel to break the mutual exclusion.
>>>>>>
>>>>>> In this case, the parallel mmap() may map to the same area since vmas
>>>>>> have been detached by munmap(), then mmap() may create the complete same
>>>>>> vmas, and page fault happens on the same vma at the same address.
>>>>>>
>>>>>> I'm not sure why gdb or strace could recover this, but they use ptrace
>>>>>> which may acquire mmap_sem to break the parallel inadvertently.
>>>>>>
>>>>>> May you please try Waiman's patch to see if it makes any difference?
>>>>> I don't see any difference in behaviour after applying:
>>>>>      [PATCH-tip v7 01/20] locking/rwsem: Prevent decrement of reader count
>>>>>      before increment
>>>>> Issue is still easily reproducible for me.
>>>>>
>>>>> I'm including output of mem_abort_decode() / show_pte() for sample PTE,
>>>>> that
>>>>> I see in page fault loop. (I went through all bits, but couldn't find
>>>>> anything invalid about it)
>>>>>
>>>>>      mem_abort_decode: Mem abort info:
>>>>>      mem_abort_decode:   ESR = 0x92000047
>>>>>      mem_abort_decode:   Exception class = DABT (lower EL), IL = 32 bits
>>>>>      mem_abort_decode:   SET = 0, FnV = 0
>>>>>      mem_abort_decode:   EA = 0, S1PTW = 0
>>>>>      mem_abort_decode: Data abort info:
>>>>>      mem_abort_decode:   ISV = 0, ISS = 0x00000047
>>>>>      mem_abort_decode:   CM = 0, WnR = 1
>>>>>      show_pte: user pgtable: 64k pages, 48-bit VAs, pgdp =
>>>>>      0000000067027567
>>>>>      show_pte: [0000ffff6dff0000] pgd=000000176bae0003
>>>>>      show_pte: , pud=000000176bae0003
>>>>>      show_pte: , pmd=000000174ad60003
>>>>>      show_pte: , pte=00e80008023a0f53
>>>>>      show_pte: , pte_pfn: 8023a
>>>>>
>>>>>      >>> print bin(0x47)
>>>>>      0b1000111
>>>>>
>>>>>      Per D12-2779 (ARM Architecture Reference Manual),
>>>>>          ISS encoding for an exception from an Instruction Abort:
>>>>>        IFSC, bits [5:0], Instruction Fault Status Code
>>>>>        0b000111 Translation fault, level 3
>>>>>
>>>>> ---
>>>>>
>>>>> My theory is that TLB is getting broken.
>>> Theory continued:
>>>
>>> unmap_region() is batching updates to TLB (for vmas and page tables).
>>> And at the same time another thread handles page fault for same mm,
>>> which increases "tlb_flush_pending".
>>>
>>> tlb_finish_mmu() called from unmap_region() will thus set 'force = 1'.
>>> And arch_tlb_finish_mmu() will in turn reset TLB range, presumably making
>>> it smaller then it would be if force == 0.
>>>
>>> Change below appears to fix it:
>>>
>>> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
>>> index f2f03c655807..a4cef21bd62b 100644
>>> --- a/mm/mmu_gather.c
>>> +++ b/mm/mmu_gather.c
>>> @@ -93,7 +93,7 @@ void arch_tlb_finish_mmu(struct mmu_gather *tlb,
>>>           struct mmu_gather_batch *batch, *next;
>>>    
>>>           if (force) {
>>> -               __tlb_reset_range(tlb);
>>>                   __tlb_adjust_range(tlb, start, end - start);
>> I don't get why the change could fix it?
> My guess is that reset clears "tlb->freed_tables", which changes how
> tlb_flush() operates, see "bool last_level = !tlb->freed_tables;" in
> arch/arm64/include/asm/tlb.h. Maybe that doesn't clear some intermediate
> entries? No clue.
>
> If I let it reset the range, but preserve "freed_tables", it also
> seems to solve the problem:

This makes sense. munmap() does free page tables, so "freed_tables" 
should be 1 instead of 0. So, in this case, __tlb_reset_range() should 
not be called.

>
> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> index f2f03c655807..17fb0d7edc03 100644
> --- a/mm/mmu_gather.c
> +++ b/mm/mmu_gather.c
> @@ -93,8 +93,20 @@ void arch_tlb_finish_mmu(struct mmu_gather *tlb,
>          struct mmu_gather_batch *batch, *next;
>   
>          if (force) {
> -               __tlb_reset_range(tlb);
> +               if (tlb->fullmm) {
> +                       tlb->start = tlb->end = ~0;
> +               } else {
> +                       tlb->start = TASK_SIZE;
> +                       tlb->end = 0;
> +               }
>                  __tlb_adjust_range(tlb, start, end - start);
>
>> __tlb_reset_range() just reset
>> start and end to TASK_SIZE and 0, then __tlb_adjust_range() set proper
>> start and end. I don't get why "force" flush smaller range?
> I'm still trying to understand this part. It's actually not smaller, but it changes:
>
> unmap_region()
>    # vm_start: ffff49bd0000 vm_end: ffff49be0000
>    ...
>    # tlb.start, tlb.end: 1000000000000 0
>    free_pgtables()
>    # tlb.start, tlb.end: ffff40000000 ffff40010000
>    tlb_finish_mmu()
>      arch_tlb_finish_mmu()
>        # will see force == 1
>        # resets tlb.start, tlb.end to: ffff49bd0000 ffff49be0000
>
>>>           }
>>>
>>>>> I made a dummy kernel module that exports debugfs file, which on read
>>>>> triggers:
>>>>>      flush_tlb_all();
>>>>>
>>>>> Any time reproducer stalls and I read debugfs file, it recovers
>>>>> immediately and resumes printing to stdout.
>>>> That commit doesn't change anything about TLB flush, just move zapping
>>>> pages under read mmap_sem as what MADV_DONTNEED does.
>>>>
>>>> I don't have aarch64 board to reproduce and debug it. And, I'm not
>>>> familiar with aarch64 architecture either. But, some history told me the
>>>> parallel zapping page may run into stale TLB and defer a flush meaning
>>>> that this call may observe pte_none and fails to flush the TLB. But,
>>>> this has been solved by commit 56236a59556c ("mm: refactor TLB gathering
>>>> API") and 99baac21e458 ("mm: fix MADV_[FREE|DONTNEED] TLB flush miss
>>>> problem").
>>>>
>>>> For more detail, please refer to commit 4647706ebeee ("mm: always flush
>>>> VMA ranges affected by zap_page_range"). Copied Mel and Rik in this
>>>> thread. Also added Will Deacon and Catalin Marinas, who are aarch64
>>>> maintainers, in this loop
>>> Thanks
>>>
>>>> But, your test (triggering TLB flush) does demonstrate TLB flush is
>>>> *not* done properly at some point as expected for aarch64. Could you
>>>> please give the below patch a try?
>>> Your patch also fixes my reproducer.
>> Thanks for testing it.
>>
>>>> diff --git a/mm/memory.c b/mm/memory.c
>>>> index ab650c2..ef41ad5 100644
>>>> --- a/mm/memory.c
>>>> +++ b/mm/memory.c
>>>> @@ -1336,8 +1336,10 @@ void unmap_vmas(struct mmu_gather *tlb,
>>>>
>>>>            mmu_notifier_range_init(&range, vma->vm_mm, start_addr,
>>>>            end_addr);
>>>>            mmu_notifier_invalidate_range_start(&range);
>>>> -       for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
>>>> +       for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
>>>>                    unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
>>>> +               flush_tlb_range(vma, start_addr, end_addr);
>>>> +       }
>>>>            mmu_notifier_invalidate_range_end(&range);
>>>>     }
>>>>
>>>>>>> - I tried 2 different aarch64 systems so far: APM X-Gene CPU Potenza A3
>>>>>>> and
>>>>>>>       Qualcomm 65-LA-115-151.
>>>>>>>       I can reproduce it on both with v5.1-rc7. It's easier to reproduce
>>>>>>>       on latter one (for longer periods of time), which has 46 CPUs.
>>>>>>> - Sample output of reproducer on otherwise idle system:
>>>>>>>       # ./a.out
>>>>>>>       [00000314] map_write_unmap took: 26305 ms
>>>>>>>       [00000867] map_write_unmap took: 13642 ms
>>>>>>>       [00002200] map_write_unmap took: 44237 ms
>>>>>>>       [00002851] map_write_unmap took: 992 ms
>>>>>>>       [00004725] map_write_unmap took: 542 ms
>>>>>>>       [00006443] map_write_unmap took: 5333 ms
>>>>>>>       [00006593] map_write_unmap took: 21162 ms
>>>>>>>       [00007435] map_write_unmap took: 16982 ms
>>>>>>>       [00007488] map_write unmap took: 13 ms^C
>>>>>>>
>>>>>>> I ran a bisect, which identified following commit as first bad one:
>>>>>>>       dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
>>>>>>>
>>>>>>> I can also make the issue go away with following change:
>>>>>>> diff --git a/mm/mmap.c b/mm/mmap.c
>>>>>>> index 330f12c17fa1..13ce465740e2 100644
>>>>>>> --- a/mm/mmap.c
>>>>>>> +++ b/mm/mmap.c
>>>>>>> @@ -2844,7 +2844,7 @@ EXPORT_SYMBOL(vm_munmap);
>>>>>>>      SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
>>>>>>>      {
>>>>>>>             profile_munmap(addr);
>>>>>>> -       return __vm_munmap(addr, len, true);
>>>>>>> +       return __vm_munmap(addr, len, false);
>>>>>>>      }
>>>>>>>
>>>>>>> # cat /proc/cpuinfo  | head
>>>>>>> processor       : 0
>>>>>>> BogoMIPS        : 40.00
>>>>>>> Features        : fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid
>>>>>>> asimdrdm
>>>>>>> CPU implementer : 0x51
>>>>>>> CPU architecture: 8
>>>>>>> CPU variant     : 0x0
>>>>>>> CPU part        : 0xc00
>>>>>>> CPU revision    : 1
>>>>>>>
>>>>>>> # numactl -H
>>>>>>> available: 1 nodes (0)
>>>>>>> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22
>>>>>>> 23
>>>>>>> 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45
>>>>>>> node 0 size: 97938 MB
>>>>>>> node 0 free: 95732 MB
>>>>>>> node distances:
>>>>>>> node   0
>>>>>>>       0:  10
>>>>>>>
>>>>>>> Regards,
>>>>>>> Jan
>>>>>>>
>>>>>>> [1]
>>>>>>> https://github.com/jstancek/reproducers/blob/master/kernel/page_fault_stall/mmap5.c
>>>>>>> [2]
>>>>>>> https://github.com/jstancek/reproducers/blob/master/kernel/page_fault_stall/config
>>

