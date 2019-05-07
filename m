Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB7EAC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:42:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D395205ED
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:42:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D395205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F16EE6B0005; Tue,  7 May 2019 12:42:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA18F6B0008; Tue,  7 May 2019 12:42:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D41076B000A; Tue,  7 May 2019 12:42:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 92C726B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 12:42:56 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g11so9616367plt.23
        for <linux-mm@kvack.org>; Tue, 07 May 2019 09:42:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=uafFJG16wfNU7DRVRzmRnKdmMGwkzxPzsRk9+0wLn50=;
        b=XaviubLvb6p1nueycNVlDFDlNhxn2h6Tq+1rkK/G9gacD/4+ulZl1EptCbOVn7sERH
         bWxSMzmv4MN/7cxhdyKAKckn5KHMeocphYQ9AREguXQXe9yHREW6yYlOUavuoABO1TWC
         8Fk5ksvTWKzsIUIR37YFzlyIRlzuIqu7z9qAwEf8O/+4oWJRZmkd/rssAc4LDHFDVajH
         X0RLp2/3oIcmHvHMAflu6Q26KRgjli8JRp83JeFeSXkAD1jPTnUOCFqIVD0cNBlsGc1R
         FGTDJezi33dOi9/zuhBYf7fxZDTgmOFn0Fv4t/mbRW9PkAoJPE5TBlnrbrf1tv5w3cR1
         kxpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAU80avmOBrwdNaqrCTLUVZQ436HZjN4EtJ0/pMxTnE22uXhDeBW
	5nR1vgDzswBI2kyJXg0AELdRvra3b725fuG+62lADruOeA/X7K//9nIetxj181Mb/t0EdfrAmMZ
	X8tjS2KHG7mpjLEkDgXtbFtEWM4yTB1YGoAsb6bLxos/hihsaaQc3V8+exI1oMvK05Q==
X-Received: by 2002:a63:17:: with SMTP id 23mr40176511pga.206.1557247376025;
        Tue, 07 May 2019 09:42:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylXB2w75kRczkO+UeKlODO6eRp3Hp5nyvgQXi3TciZb11E6zEm2lJUL4lqYg2JYmic0Ptw
X-Received: by 2002:a63:17:: with SMTP id 23mr40176391pga.206.1557247374637;
        Tue, 07 May 2019 09:42:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557247374; cv=none;
        d=google.com; s=arc-20160816;
        b=y1R2P2rXO27d//Fy3Z1wvtrvXx+eFU/mCM4rYyDcFxSjo4INpCShsJu5dckax8p2Ms
         lefIds0244D3AxYXdvhBBiPeMS2SRv3V5M64DfY2lUB1u4EYf/pp2zFRrqF0sdUdFd9I
         ZryS904BOmpNQvqdgoUL3yCCVppqo4qHwEZoIWkPzgosv2oTlAntohH415gAgeE/YYAZ
         Kp0msMjCYABDl87VpC2eRV5q0NnmnYUF+gawhFSnQKow1kbhqhiOCpG4uakBU095amMO
         e60AKoCidBQBRNIRaQWb7OsX1rVOXuytKTeahfJl1GHU8EUVKTzmX1yCqToCurIYbMDV
         j7Lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=uafFJG16wfNU7DRVRzmRnKdmMGwkzxPzsRk9+0wLn50=;
        b=HyJYuNfFgueJISoK9Bt6xCl5QOB7HAb7Mz3hckcKTYtYEdFNLzjbKHOjvcgZveIWRI
         9yLojIO90ku/D1de1/AgxHWDfE8vn4sIuWv4a1elAra2ce77H6tFL7qoO+n557qEBoTU
         VtIHVP4eG98CBrBOHgrqv9LGY8BDho8Wn5J2xaa2nxzu9PlmY8t0n5PZOAXQEKQ0KsPC
         vEclKNA+/c52IGc+4nrA3lFiqOOU+89u6uPdQ6eVxDI5gMDb2+rWtZBIQs7YVhhzlMyf
         zHA6yGGj0Oo+Z5ydQleeBR4UuF/ypcP/O5q37sysSfVgpXFKKm34KUiefr0ZRs4oYY3x
         ONSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id cd12si21373205plb.92.2019.05.07.09.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 09:42:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TR7IB32_1557247365;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TR7IB32_1557247365)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 08 May 2019 00:42:49 +0800
Subject: Re: [bug] aarch64: userspace stalls on page fault after dd2283f2605e
 ("mm: mmap: zap pages with read mmap_sem in munmap")
To: Jan Stancek <jstancek@redhat.com>, will deacon <will.deacon@arm.com>,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: kirill@shutemov.name, willy@infradead.org,
 kirill shutemov <kirill.shutemov@linux.intel.com>, vbabka@suse.cz,
 Andrea Arcangeli <aarcange@redhat.com>, akpm@linux-foundation.org,
 Waiman Long <longman@redhat.com>, Mel Gorman <mgorman@techsingularity.net>,
 Rik van Riel <riel@surriel.com>, catalin marinas <catalin.marinas@arm.com>
References: <1817839533.20996552.1557065445233.JavaMail.zimbra@redhat.com>
 <a9d5efea-6088-67c5-8711-f0657a852813@linux.alibaba.com>
 <1928544225.21255545.1557178548494.JavaMail.zimbra@redhat.com>
 <2b2006bf-753b-c4b8-e9a2-fd27ae65fe14@linux.alibaba.com>
 <756571293.21386229.1557229889545.JavaMail.zimbra@redhat.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <3d0843fa-1a34-1d5a-ca4d-abe4032bad8b@linux.alibaba.com>
Date: Tue, 7 May 2019 09:42:43 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <756571293.21386229.1557229889545.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/7/19 4:51 AM, Jan Stancek wrote:
> ----- Original Message -----
>>
>> On 5/6/19 2:35 PM, Jan Stancek wrote:
>>> ----- Original Message -----
>>>> On 5/5/19 7:10 AM, Jan Stancek wrote:
>>>>> Hi,
>>>>>
>>>>> I'm seeing userspace program getting stuck on aarch64, on kernels 4.20
>>>>> and
>>>>> newer.
>>>>> It stalls from seconds to hours.
>>>>>
>>>>> I have simplified it to following scenario (reproducer linked below [1]):
>>>>>      while (1):
>>>>>        spawn Thread 1: mmap, write, munmap
>>>>>        spawn Thread 2: <nothing>
>>>>>
>>>>> Thread 1 is sporadically getting stuck on write to mapped area.
>>>>> User-space
>>>>> is not
>>>>> moving forward - stdout output stops. Observed CPU usage is however 100%.
>>>>>
>>>>> At this time, kernel appears to be busy handling page faults (~700k per
>>>>> second):
>>>>>
>>>>> # perf top -a -g
>>>>> -   98.97%     8.30%  a.out                     [.] map_write_unmap
>>>>>       - 23.52% map_write_unmap
>>>>>          - 24.29% el0_sync
>>>>>             - 10.42% do_mem_abort
>>>>>                - 17.81% do_translation_fault
>>>>>                   - 33.01% do_page_fault
>>>>>                      - 56.18% handle_mm_fault
>>>>>                           40.26% __handle_mm_fault
>>>>>                           2.19% __ll_sc___cmpxchg_case_acq_4
>>>>>                           0.87% mem_cgroup_from_task
>>>>>                      - 6.18% find_vma
>>>>>                           5.38% vmacache_find
>>>>>                        1.35% __ll_sc___cmpxchg_case_acq_8
>>>>>                        1.23% __ll_sc_atomic64_sub_return_release
>>>>>                        0.78% down_read_trylock
>>>>>               0.93% do_translation_fault
>>>>>       + 8.30% thread_start
>>>>>
>>>>> #  perf stat -p 8189 -d
>>>>> ^C
>>>>>     Performance counter stats for process id '8189':
>>>>>
>>>>>            984.311350      task-clock (msec)         #    1.000 CPUs
>>>>>            utilized
>>>>>                     0      context-switches          #    0.000 K/sec
>>>>>                     0      cpu-migrations            #    0.000 K/sec
>>>>>               723,641      page-faults               #    0.735 M/sec
>>>>>         2,559,199,434      cycles                    #    2.600 GHz
>>>>>           711,933,112      instructions              #    0.28  insn per
>>>>>           cycle
>>>>>       <not supported>      branches
>>>>>               757,658      branch-misses
>>>>>           205,840,557      L1-dcache-loads           #  209.121 M/sec
>>>>>            40,561,529      L1-dcache-load-misses     #   19.71% of all
>>>>>            L1-dcache hits
>>>>>       <not supported>      LLC-loads
>>>>>       <not supported>      LLC-load-misses
>>>>>
>>>>>           0.984454892 seconds time elapsed
>>>>>
>>>>> With some extra traces, it appears looping in page fault for same
>>>>> address,
>>>>> over and over:
>>>>>      do_page_fault // mm_flags: 0x55
>>>>>        __do_page_fault
>>>>>          __handle_mm_fault
>>>>>            handle_pte_fault
>>>>>              ptep_set_access_flags
>>>>>                if (pte_same(pte, entry))  // pte: e8000805060f53, entry:
>>>>>                e8000805060f53
>>>>>
>>>>> I had traces in mmap() and munmap() as well, they don't get hit when
>>>>> reproducer
>>>>> hits the bad state.
>>>>>
>>>>> Notes:
>>>>> - I'm not able to reproduce this on x86.
>>>>> - Attaching GDB or strace immediatelly recovers application from stall.
>>>>> - It also seems to recover faster when system is busy with other tasks.
>>>>> - MAP_SHARED vs. MAP_PRIVATE makes no difference.
>>>>> - Turning off THP makes no difference.
>>>>> - Reproducer [1] usually hits it within ~minute on HW described below.
>>>>> - Longman mentioned that "When the rwsem becomes reader-owned, it causes
>>>>>      all the spinning writers to go to sleep adding wakeup latency to
>>>>>      the time required to finish the critical sections", but this looks
>>>>>      like busy loop, so I'm not sure if it's related to rwsem issues
>>>>>      identified
>>>>>      in:
>>>>>      https://lore.kernel.org/lkml/20190428212557.13482-2-longman@redhat.com/
>>>> It sounds possible to me. What the optimization done by the commit ("mm:
>>>> mmap: zap pages with read mmap_sem in munmap") is to downgrade write
>>>> rwsem to read when zapping pages and page table in munmap() after the
>>>> vmas have been detached from the rbtree.
>>>>
>>>> So the mmap(), which is writer, in your test may steal the lock and
>>>> execute with the munmap(), which is the reader after the downgrade, in
>>>> parallel to break the mutual exclusion.
>>>>
>>>> In this case, the parallel mmap() may map to the same area since vmas
>>>> have been detached by munmap(), then mmap() may create the complete same
>>>> vmas, and page fault happens on the same vma at the same address.
>>>>
>>>> I'm not sure why gdb or strace could recover this, but they use ptrace
>>>> which may acquire mmap_sem to break the parallel inadvertently.
>>>>
>>>> May you please try Waiman's patch to see if it makes any difference?
>>> I don't see any difference in behaviour after applying:
>>>     [PATCH-tip v7 01/20] locking/rwsem: Prevent decrement of reader count
>>>     before increment
>>> Issue is still easily reproducible for me.
>>>
>>> I'm including output of mem_abort_decode() / show_pte() for sample PTE,
>>> that
>>> I see in page fault loop. (I went through all bits, but couldn't find
>>> anything invalid about it)
>>>
>>>     mem_abort_decode: Mem abort info:
>>>     mem_abort_decode:   ESR = 0x92000047
>>>     mem_abort_decode:   Exception class = DABT (lower EL), IL = 32 bits
>>>     mem_abort_decode:   SET = 0, FnV = 0
>>>     mem_abort_decode:   EA = 0, S1PTW = 0
>>>     mem_abort_decode: Data abort info:
>>>     mem_abort_decode:   ISV = 0, ISS = 0x00000047
>>>     mem_abort_decode:   CM = 0, WnR = 1
>>>     show_pte: user pgtable: 64k pages, 48-bit VAs, pgdp = 0000000067027567
>>>     show_pte: [0000ffff6dff0000] pgd=000000176bae0003
>>>     show_pte: , pud=000000176bae0003
>>>     show_pte: , pmd=000000174ad60003
>>>     show_pte: , pte=00e80008023a0f53
>>>     show_pte: , pte_pfn: 8023a
>>>
>>>     >>> print bin(0x47)
>>>     0b1000111
>>>
>>>     Per D12-2779 (ARM Architecture Reference Manual),
>>>         ISS encoding for an exception from an Instruction Abort:
>>>       IFSC, bits [5:0], Instruction Fault Status Code
>>>       0b000111 Translation fault, level 3
>>>
>>> ---
>>>
>>> My theory is that TLB is getting broken.
> Theory continued:
>
> unmap_region() is batching updates to TLB (for vmas and page tables).
> And at the same time another thread handles page fault for same mm,
> which increases "tlb_flush_pending".
>
> tlb_finish_mmu() called from unmap_region() will thus set 'force = 1'.
> And arch_tlb_finish_mmu() will in turn reset TLB range, presumably making
> it smaller then it would be if force == 0.
>
> Change below appears to fix it:
>
> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> index f2f03c655807..a4cef21bd62b 100644
> --- a/mm/mmu_gather.c
> +++ b/mm/mmu_gather.c
> @@ -93,7 +93,7 @@ void arch_tlb_finish_mmu(struct mmu_gather *tlb,
>          struct mmu_gather_batch *batch, *next;
>   
>          if (force) {
> -               __tlb_reset_range(tlb);
>                  __tlb_adjust_range(tlb, start, end - start);

I don't get why the change could fix it? __tlb_reset_range() just reset 
start and end to TASK_SIZE and 0, then __tlb_adjust_range() set proper 
start and end. I don't get why "force" flush smaller range?

>          }
>
>>> I made a dummy kernel module that exports debugfs file, which on read
>>> triggers:
>>>     flush_tlb_all();
>>>
>>> Any time reproducer stalls and I read debugfs file, it recovers
>>> immediately and resumes printing to stdout.
>> That commit doesn't change anything about TLB flush, just move zapping
>> pages under read mmap_sem as what MADV_DONTNEED does.
>>
>> I don't have aarch64 board to reproduce and debug it. And, I'm not
>> familiar with aarch64 architecture either. But, some history told me the
>> parallel zapping page may run into stale TLB and defer a flush meaning
>> that this call may observe pte_none and fails to flush the TLB. But,
>> this has been solved by commit 56236a59556c ("mm: refactor TLB gathering
>> API") and 99baac21e458 ("mm: fix MADV_[FREE|DONTNEED] TLB flush miss
>> problem").
>>
>> For more detail, please refer to commit 4647706ebeee ("mm: always flush
>> VMA ranges affected by zap_page_range"). Copied Mel and Rik in this
>> thread. Also added Will Deacon and Catalin Marinas, who are aarch64
>> maintainers, in this loop
> Thanks
>
>> But, your test (triggering TLB flush) does demonstrate TLB flush is
>> *not* done properly at some point as expected for aarch64. Could you
>> please give the below patch a try?
> Your patch also fixes my reproducer.

Thanks for testing it.

>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index ab650c2..ef41ad5 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1336,8 +1336,10 @@ void unmap_vmas(struct mmu_gather *tlb,
>>
>>           mmu_notifier_range_init(&range, vma->vm_mm, start_addr, end_addr);
>>           mmu_notifier_invalidate_range_start(&range);
>> -       for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
>> +       for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
>>                   unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
>> +               flush_tlb_range(vma, start_addr, end_addr);
>> +       }
>>           mmu_notifier_invalidate_range_end(&range);
>>    }
>>
>>>>> - I tried 2 different aarch64 systems so far: APM X-Gene CPU Potenza A3
>>>>> and
>>>>>      Qualcomm 65-LA-115-151.
>>>>>      I can reproduce it on both with v5.1-rc7. It's easier to reproduce
>>>>>      on latter one (for longer periods of time), which has 46 CPUs.
>>>>> - Sample output of reproducer on otherwise idle system:
>>>>>      # ./a.out
>>>>>      [00000314] map_write_unmap took: 26305 ms
>>>>>      [00000867] map_write_unmap took: 13642 ms
>>>>>      [00002200] map_write_unmap took: 44237 ms
>>>>>      [00002851] map_write_unmap took: 992 ms
>>>>>      [00004725] map_write_unmap took: 542 ms
>>>>>      [00006443] map_write_unmap took: 5333 ms
>>>>>      [00006593] map_write_unmap took: 21162 ms
>>>>>      [00007435] map_write_unmap took: 16982 ms
>>>>>      [00007488] map_write unmap took: 13 ms^C
>>>>>
>>>>> I ran a bisect, which identified following commit as first bad one:
>>>>>      dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
>>>>>
>>>>> I can also make the issue go away with following change:
>>>>> diff --git a/mm/mmap.c b/mm/mmap.c
>>>>> index 330f12c17fa1..13ce465740e2 100644
>>>>> --- a/mm/mmap.c
>>>>> +++ b/mm/mmap.c
>>>>> @@ -2844,7 +2844,7 @@ EXPORT_SYMBOL(vm_munmap);
>>>>>     SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
>>>>>     {
>>>>>            profile_munmap(addr);
>>>>> -       return __vm_munmap(addr, len, true);
>>>>> +       return __vm_munmap(addr, len, false);
>>>>>     }
>>>>>
>>>>> # cat /proc/cpuinfo  | head
>>>>> processor       : 0
>>>>> BogoMIPS        : 40.00
>>>>> Features        : fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid
>>>>> asimdrdm
>>>>> CPU implementer : 0x51
>>>>> CPU architecture: 8
>>>>> CPU variant     : 0x0
>>>>> CPU part        : 0xc00
>>>>> CPU revision    : 1
>>>>>
>>>>> # numactl -H
>>>>> available: 1 nodes (0)
>>>>> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22
>>>>> 23
>>>>> 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45
>>>>> node 0 size: 97938 MB
>>>>> node 0 free: 95732 MB
>>>>> node distances:
>>>>> node   0
>>>>>      0:  10
>>>>>
>>>>> Regards,
>>>>> Jan
>>>>>
>>>>> [1]
>>>>> https://github.com/jstancek/reproducers/blob/master/kernel/page_fault_stall/mmap5.c
>>>>> [2]
>>>>> https://github.com/jstancek/reproducers/blob/master/kernel/page_fault_stall/config
>>

