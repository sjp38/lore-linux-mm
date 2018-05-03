Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8796B0010
	for <linux-mm@kvack.org>; Thu,  3 May 2018 10:59:31 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id x30-v6so8520204qtm.20
        for <linux-mm@kvack.org>; Thu, 03 May 2018 07:59:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 2si514672qku.200.2018.05.03.07.59.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 07:59:30 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w43EwVZd130514
	for <linux-mm@kvack.org>; Thu, 3 May 2018 10:59:29 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hr49k16eh-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 03 May 2018 10:59:28 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 3 May 2018 15:59:25 +0100
Subject: Re: [PATCH v10 24/25] x86/mm: add speculative pagefault handling
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523975611-15978-25-git-send-email-ldufour@linux.vnet.ibm.com>
 <CAD4BONd5DZiKkGPGaYqEcVb+YubVDy43MNNQ8_yztDHWpf0Y7w@mail.gmail.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 3 May 2018 16:59:14 +0200
MIME-Version: 1.0
In-Reply-To: <CAD4BONd5DZiKkGPGaYqEcVb+YubVDy43MNNQ8_yztDHWpf0Y7w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <fb143123-d54e-b08d-1bd8-07767c86c7d0@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punitagrawal@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 30/04/2018 20:43, Punit Agrawal wrote:
> Hi Laurent,
> 
> I am looking to add support for speculative page fault handling to
> arm64 (effectively porting this patch) and had a few questions.
> Apologies if I've missed an obvious explanation for my queries. I'm
> jumping in bit late to the discussion.

Hi Punit,

Thanks for giving this series a review.
I don't have arm64 hardware to play with, but I'll be happy to add arm64
patches to my series and to try to maintain them.

> 
> On Tue, Apr 17, 2018 at 3:33 PM, Laurent Dufour
> <ldufour@linux.vnet.ibm.com> wrote:
>> From: Peter Zijlstra <peterz@infradead.org>
>>
>> Try a speculative fault before acquiring mmap_sem, if it returns with
>> VM_FAULT_RETRY continue with the mmap_sem acquisition and do the
>> traditional fault.
>>
>> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
>>
>> [Clearing of FAULT_FLAG_ALLOW_RETRY is now done in
>>  handle_speculative_fault()]
>> [Retry with usual fault path in the case VM_ERROR is returned by
>>  handle_speculative_fault(). This allows signal to be delivered]
>> [Don't build SPF call if !CONFIG_SPECULATIVE_PAGE_FAULT]
>> [Try speculative fault path only for multi threaded processes]
>> [Try reuse to the VMA fetch during the speculative path in case of retry]
>> [Call reuse_spf_or_find_vma()]
>> [Handle memory protection key fault]
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  arch/x86/mm/fault.c | 42 ++++++++++++++++++++++++++++++++++++++----
>>  1 file changed, 38 insertions(+), 4 deletions(-)
>>
>> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
>> index 73bd8c95ac71..59f778386df5 100644
>> --- a/arch/x86/mm/fault.c
>> +++ b/arch/x86/mm/fault.c
>> @@ -1220,7 +1220,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>>         struct mm_struct *mm;
>>         int fault, major = 0;
>>         unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
>> -       u32 pkey;
>> +       u32 pkey, *pt_pkey = &pkey;
>>
>>         tsk = current;
>>         mm = tsk->mm;
>> @@ -1310,6 +1310,30 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>>                 flags |= FAULT_FLAG_INSTRUCTION;
>>
>>         /*
>> +        * Do not try speculative page fault for kernel's pages and if
>> +        * the fault was due to protection keys since it can't be resolved.
>> +        */
>> +       if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT) &&
>> +           !(error_code & X86_PF_PK)) {
> 
> You can simplify this condition by dropping the IS_ENABLED() check as
> you already provide an alternate implementation of
> handle_speculative_fault() when CONFIG_SPECULATIVE_PAGE_FAULT is not
> defined.

Yes you're right, I completely forgot about that define of
handle_speculative_fault() when CONFIG_SPECULATIVE_PAGE_FAULT is not set, that
will definitively makes that part of code more readable.

> 
>> +               fault = handle_speculative_fault(mm, address, flags, &vma);
>> +               if (fault != VM_FAULT_RETRY) {
>> +                       perf_sw_event(PERF_COUNT_SW_SPF, 1, regs, address);
>> +                       /*
>> +                        * Do not advertise for the pkey value since we don't
>> +                        * know it.
>> +                        * This is not a matter as we checked for X86_PF_PK
>> +                        * earlier, so we should not handle pkey fault here,
>> +                        * but to be sure that mm_fault_error() callees will
>> +                        * not try to use it, we invalidate the pointer.
>> +                        */
>> +                       pt_pkey = NULL;
>> +                       goto done;
>> +               }
>> +       } else {
>> +               vma = NULL;
>> +       }
> 
> The else part can be dropped if vma is initialised to NULL when it is
> declared at the top of the function.
Sure.

> 
>> +
>> +       /*
>>          * When running in the kernel we expect faults to occur only to
>>          * addresses in user space.  All other faults represent errors in
>>          * the kernel and should generate an OOPS.  Unfortunately, in the
>> @@ -1342,7 +1366,8 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>>                 might_sleep();
>>         }
>>
>> -       vma = find_vma(mm, address);
>> +       if (!vma || !can_reuse_spf_vma(vma, address))
>> +               vma = find_vma(mm, address);
> 
> Is there a measurable benefit from reusing the vma?
> 
> Dropping the vma reference unconditionally after speculative page
> fault handling gets rid of the implicit state when "vma != NULL"
> (increased ref-count). I found it a bit confusing to follow.

I do agree, this is quite confusing. My initial goal was to be able to reuse
the VMA in the case a protection key error was detected, but it's not really
necessary on x86 since we know at the beginning of the fault operation that
protection key are in the loop. This is not the case on ppc64 but I couldn't
find a way to easily rely on the speculatively fetched VMA neither, so for
protection keys, this didn't help.

Regarding the measurable benefit of reusing the fetched vma, I did further
tests using will-it-scale/page_fault2_threads test, and I'm no more really
convince that this worth the added complexity. I think I'll drop the patch "mm:
speculative page fault handler return VMA" of the series, and thus remove the
call to can_reuse_spf_vma().

Thanks,
Laurent.

> 
>>         if (unlikely(!vma)) {
>>                 bad_area(regs, error_code, address);
>>                 return;
>> @@ -1409,8 +1434,15 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>>                 if (flags & FAULT_FLAG_ALLOW_RETRY) {
>>                         flags &= ~FAULT_FLAG_ALLOW_RETRY;
>>                         flags |= FAULT_FLAG_TRIED;
>> -                       if (!fatal_signal_pending(tsk))
>> +                       if (!fatal_signal_pending(tsk)) {
>> +                               /*
>> +                                * Do not try to reuse this vma and fetch it
>> +                                * again since we will release the mmap_sem.
>> +                                */
>> +                               if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT))
>> +                                       vma = NULL;
> 
> Regardless of the above comment, can the vma be reset here unconditionally?
> 
> Thanks,
> Punit
> 
