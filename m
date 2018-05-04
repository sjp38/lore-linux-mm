Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4586B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 02:31:09 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id s2-v6so11942805ioa.22
        for <linux-mm@kvack.org>; Thu, 03 May 2018 23:31:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r23-v6sor7243237iod.98.2018.05.03.23.31.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 May 2018 23:31:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <871seunmj9.fsf@e105922-lin.cambridge.arm.com>
References: <1525247672-2165-1-git-send-email-opensource.ganesh@gmail.com>
 <1525247672-2165-2-git-send-email-opensource.ganesh@gmail.com> <871seunmj9.fsf@e105922-lin.cambridge.arm.com>
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Date: Fri, 4 May 2018 14:31:07 +0800
Message-ID: <CADAEsF-qdU3Te279sDFEMs0wL1o-N2R3agTuHCh3qZxFDkpwyg@mail.gmail.com>
Subject: Re: [PATCH 2/2] arm64/mm: add speculative page fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

2018-05-02 22:46 GMT+08:00 Punit Agrawal <punit.agrawal@arm.com>:
> Hi Ganesh,
>
> I was looking at evaluating speculative page fault handling on arm64 and
> noticed your patch.
>
> Some comments below -

Thanks for your review.

>
> Ganesh Mahendran <opensource.ganesh@gmail.com> writes:
>
>> This patch enables the speculative page fault on the arm64
>> architecture.
>>
>> I completed spf porting in 4.9. From the test result,
>> we can see app launching time improved by about 10% in average.
>> For the apps which have more than 50 threads, 15% or even more
>> improvement can be got.
>>
>> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>> ---
>> This patch is on top of Laurent's v10 spf
>> ---
>>  arch/arm64/mm/fault.c | 38 +++++++++++++++++++++++++++++++++++---
>>  1 file changed, 35 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
>> index 4165485..e7992a3 100644
>> --- a/arch/arm64/mm/fault.c
>> +++ b/arch/arm64/mm/fault.c
>> @@ -322,11 +322,13 @@ static void do_bad_area(unsigned long addr, unsigned int esr, struct pt_regs *re
>>
>>  static int __do_page_fault(struct mm_struct *mm, unsigned long addr,
>>                          unsigned int mm_flags, unsigned long vm_flags,
>> -                        struct task_struct *tsk)
>> +                        struct task_struct *tsk, struct vm_area_struct *vma)
>>  {
>> -     struct vm_area_struct *vma;
>>       int fault;
>>
>> +     if (!vma || !can_reuse_spf_vma(vma, addr))
>> +             vma = find_vma(mm, addr);
>> +
>
> It would be better to move this hunk to do_page_fault().
>
> It'll help localise the fact that handle_speculative_fault() is a
> stateful call which needs a corresponding can_reuse_spf_vma() to
> properly update the vma reference counting.

Yes, your suggestion is better.

>
>
>>       vma = find_vma(mm, addr);
>
> Remember to drop this call in the next version. As it stands the call
> the find_vma() needlessly gets duplicated.

Will fix

>
>>       fault = VM_FAULT_BADMAP;
>>       if (unlikely(!vma))
>> @@ -371,6 +373,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
>>       int fault, major = 0;
>>       unsigned long vm_flags = VM_READ | VM_WRITE;
>>       unsigned int mm_flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
>> +     struct vm_area_struct *vma;
>>
>>       if (notify_page_fault(regs, esr))
>>               return 0;
>> @@ -409,6 +412,25 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
>>
>>       perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, addr);
>>
>> +     if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT)) {
>
> You don't need the IS_ENABLED() check. The alternate implementation of
> handle_speculative_fault() when CONFIG_SPECULATIVE_PAGE_FAULT is not
> enabled takes care of this.

Will fix

>
>> +             fault = handle_speculative_fault(mm, addr, mm_flags, &vma);
>> +             /*
>> +              * Page fault is done if VM_FAULT_RETRY is not returned.
>> +              * But if the memory protection keys are active, we don't know
>> +              * if the fault is due to key mistmatch or due to a
>> +              * classic protection check.
>> +              * To differentiate that, we will need the VMA we no
>> +              * more have, so let's retry with the mmap_sem held.
>> +              */
>
> As there is no support for memory protection keys on arm64 most of this
> comment can be dropped.

will fix

>
>> +             if (fault != VM_FAULT_RETRY &&
>> +                      fault != VM_FAULT_SIGSEGV) {
>
> Not sure if you need the VM_FAULT_SIGSEGV here.
>
>> +                     perf_sw_event(PERF_COUNT_SW_SPF, 1, regs, addr);
>> +                     goto done;
>> +             }
>> +     } else {
>> +             vma = NULL;
>> +     }
>> +
>
> If vma is initiliased to NULL during declaration, the else part can be
> dropped.

will fix

>
>>       /*
>>        * As per x86, we may deadlock here. However, since the kernel only
>>        * validly references user space from well defined areas of the code,
>> @@ -431,7 +453,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
>>  #endif
>>       }
>>
>> -     fault = __do_page_fault(mm, addr, mm_flags, vm_flags, tsk);
>> +     fault = __do_page_fault(mm, addr, mm_flags, vm_flags, tsk, vma);
>>       major |= fault & VM_FAULT_MAJOR;
>>
>>       if (fault & VM_FAULT_RETRY) {
>> @@ -454,11 +476,21 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
>>               if (mm_flags & FAULT_FLAG_ALLOW_RETRY) {
>>                       mm_flags &= ~FAULT_FLAG_ALLOW_RETRY;
>>                       mm_flags |= FAULT_FLAG_TRIED;
>> +
>> +                     /*
>> +                      * Do not try to reuse this vma and fetch it
>> +                      * again since we will release the mmap_sem.
>> +                      */
>> +                     if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT))
>> +                             vma = NULL;
>
> Please drop the IS_ENABLED() check.

will fix

>
> Thanks,
> Punit
>
>> +
>>                       goto retry;
>>               }
>>       }
>>       up_read(&mm->mmap_sem);
>>
>> +done:
>> +
>>       /*
>>        * Handle the "normal" (no error) case first.
>>        */
