Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 48CE46B02C3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 09:59:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p74so15241292pfd.11
        for <linux-mm@kvack.org>; Wed, 31 May 2017 06:59:11 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h6si17085657pfg.165.2017.05.31.06.59.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 06:59:10 -0700 (PDT)
Received: from mail-vk0-f45.google.com (mail-vk0-f45.google.com [209.85.213.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1C9A123A19
	for <linux-mm@kvack.org>; Wed, 31 May 2017 13:59:10 +0000 (UTC)
Received: by mail-vk0-f45.google.com with SMTP id p85so8729595vkd.3
        for <linux-mm@kvack.org>; Wed, 31 May 2017 06:59:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1496101359.29205.73.camel@redhat.com>
References: <cover.1495990440.git.luto@kernel.org> <bcaf9dbdd1216b7fc03ad4870477e9772edecfc9.1495990440.git.luto@kernel.org>
 <1496101359.29205.73.camel@redhat.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 31 May 2017 06:58:48 -0700
Message-ID: <CALCETrWgR-npO9dgGsiD0DKU5Ovxrf7+8Z88UR5H67mLUAar5g@mail.gmail.com>
Subject: Re: [PATCH v4 3/8] x86/mm: Refactor flush_tlb_mm_range() to merge
 local and remote cases
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Mon, May 29, 2017 at 4:42 PM, Rik van Riel <riel@redhat.com> wrote:
> On Sun, 2017-05-28 at 10:00 -0700, Andy Lutomirski wrote:
>
>> @@ -292,61 +303,33 @@ static unsigned long
>> tlb_single_page_flush_ceiling __read_mostly = 33;
>>  void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
>>                               unsigned long end, unsigned long
>> vmflag)
>>  {
>> -     unsigned long addr;
>> -     struct flush_tlb_info info;
>> -     /* do a global flush by default */
>> -     unsigned long base_pages_to_flush = TLB_FLUSH_ALL;
>> -
>> -     preempt_disable();
>> +     int cpu;
>>
>> -     if ((end != TLB_FLUSH_ALL) && !(vmflag & VM_HUGETLB))
>> -             base_pages_to_flush = (end - start) >> PAGE_SHIFT;
>> -     if (base_pages_to_flush > tlb_single_page_flush_ceiling)
>> -             base_pages_to_flush = TLB_FLUSH_ALL;
>> -
>> -     if (current->active_mm != mm) {
>> -             /* Synchronize with switch_mm. */
>> -             smp_mb();
>> -
>> -             goto out;
>> -     }
>> -
>> -     if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
>> -             leave_mm(smp_processor_id());
>> +     struct flush_tlb_info info = {
>> +             .mm = mm,
>> +     };
>>
>> -             /* Synchronize with switch_mm. */
>> -             smp_mb();
>> +     cpu = get_cpu();
>>
>> -             goto out;
>> -     }
>> +     /* Synchronize with switch_mm. */
>> +     smp_mb();
>>
>> -     /*
>> -      * Both branches below are implicit full barriers (MOV to CR
>> or
>> -      * INVLPG) that synchronize with switch_mm.
>> -      */
>> -     if (base_pages_to_flush == TLB_FLUSH_ALL) {
>> -             count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
>> -             local_flush_tlb();
>> +     /* Should we flush just the requested range? */
>> +     if ((end != TLB_FLUSH_ALL) &&
>> +         !(vmflag & VM_HUGETLB) &&
>> +         ((end - start) >> PAGE_SHIFT) <=
>> tlb_single_page_flush_ceiling) {
>> +             info.start = start;
>> +             info.end = end;
>>       } else {
>> -             /* flush range by one by one 'invlpg' */
>> -             for (addr = start; addr < end;  addr +=
>> PAGE_SIZE) {
>> -                     count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);
>> -                     __flush_tlb_single(addr);
>> -             }
>> -     }
>> -     trace_tlb_flush(TLB_LOCAL_MM_SHOOTDOWN,
>> base_pages_to_flush);
>> -out:
>> -     info.mm = mm;
>> -     if (base_pages_to_flush == TLB_FLUSH_ALL) {
>>               info.start = 0UL;
>>               info.end = TLB_FLUSH_ALL;
>> -     } else {
>> -             info.start = start;
>> -             info.end = end;
>>       }
>> -     if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) <
>> nr_cpu_ids)
>> +
>> +     if (mm == current->active_mm)
>> +             flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
>
> It looks like this could cause flush_tlb_func_local to be
> called over and over again even while cpu_tlbstate.state
> equals TLBSTATE_LAZY, because active_mm is not changed by
> leave_mm.
>
> Do you want to also test cpu_tlbstate.state != TLBSTATE_OK
> here, to ensure flush_tlb_func_local is only called when
> necessary?
>

I don't think that would buy us much.  func_tlb_flush_local will be
called, but it will call flush_tlb_func_common(), which will notice
that we're lazy and call leave_mm() instead of flushing.  leave_mm()
won't do anything if we're already using init_mm.  The overall effect
should be the same as it was before this patch, although it's a bit
more indirect with the patch applied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
