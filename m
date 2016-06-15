Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 489836B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 22:36:57 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id a64so15078620oii.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 19:36:57 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id n55si16256253otd.231.2016.06.14.19.36.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 19:36:56 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id d132so13721297oig.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 19:36:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <3878B27E-756E-4086-93BE-B4799A70570F@gmail.com>
References: <1465919919-2093-1-git-send-email-lukasz.anaczkowski@intel.com>
 <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com> <57603C61.5000408@linux.intel.com>
 <2471A3E8-FF69-4720-A3BF-BDC6094A6A70@gmail.com> <5760792D.90000@linux.intel.com>
 <CALCETrWwFQ-NHfUw56QRDWFikD-v29OSwOqVdGLst6APGc4+bw@mail.gmail.com> <3878B27E-756E-4086-93BE-B4799A70570F@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 14 Jun 2016 19:36:36 -0700
Message-ID: <CALCETrXcmAF566O2oy8XdoH+SNRWSKqmtgxybTA0YGW6OtEVCg@mail.gmail.com>
Subject: Re: [PATCH] Linux VM workaround for Knights Landing A/D leak
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com

On Tue, Jun 14, 2016 at 7:35 PM, Nadav Amit <nadav.amit@gmail.com> wrote:
> Andy Lutomirski <luto@amacapital.net> wrote:
>
>> On Tue, Jun 14, 2016 at 2:37 PM, Dave Hansen
>> <dave.hansen@linux.intel.com> wrote:
>>> On 06/14/2016 01:16 PM, Nadav Amit wrote:
>>>> Dave Hansen <dave.hansen@linux.intel.com> wrote:
>>>>
>>>>> On 06/14/2016 09:47 AM, Nadav Amit wrote:
>>>>>> Lukasz Anaczkowski <lukasz.anaczkowski@intel.com> wrote:
>>>>>>
>>>>>>>> From: Andi Kleen <ak@linux.intel.com>
>>>>>>>> +void fix_pte_leak(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
>>>>>>>> +{
>>>>>> Here there should be a call to smp_mb__after_atomic() to synchronize with
>>>>>> switch_mm. I submitted a similar patch, which is still pending (hint).
>>>>>>
>>>>>>>> + if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids) {
>>>>>>>> +         trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
>>>>>>>> +         flush_tlb_others(mm_cpumask(mm), mm, addr,
>>>>>>>> +                          addr + PAGE_SIZE);
>>>>>>>> +         mb();
>>>>>>>> +         set_pte(ptep, __pte(0));
>>>>>>>> + }
>>>>>>>> +}
>>>>>
>>>>> Shouldn't that barrier be incorporated in the TLB flush code itself and
>>>>> not every single caller (like this code is)?
>>>>>
>>>>> It is insane to require individual TLB flushers to be concerned with the
>>>>> barriers.
>>>>
>>>> IMHO it is best to use existing flushing interfaces instead of creating
>>>> new ones.
>>>
>>> Yeah, or make these things a _little_ harder to get wrong.  That little
>>> snippet above isn't so crazy that we should be depending on open-coded
>>> barriers to get it right.
>>>
>>> Should we just add a barrier to mm_cpumask() itself?  That should stop
>>> the race.  Or maybe we need a new primitive like:
>>>
>>> /*
>>> * Call this if a full barrier has been executed since the last
>>> * pagetable modification operation.
>>> */
>>> static int __other_cpus_need_tlb_flush(struct mm_struct *mm)
>>> {
>>>        /* cpumask_any_but() returns >= nr_cpu_ids if no cpus set. */
>>>        return cpumask_any_but(mm_cpumask(mm), smp_processor_id()) <
>>>                nr_cpu_ids;
>>> }
>>>
>>>
>>> static int other_cpus_need_tlb_flush(struct mm_struct *mm)
>>> {
>>>        /*
>>>         * Synchronizes with switch_mm.  Makes sure that we do not
>>>         * observe a bit having been cleared in mm_cpumask() before
>>>         * the other processor has seen our pagetable update.  See
>>>         * switch_mm().
>>>         */
>>>        smp_mb__after_atomic();
>>>
>>>        return __other_cpus_need_tlb_flush(mm)
>>> }
>>>
>>> We should be able to deploy other_cpus_need_tlb_flush() in most of the
>>> cases where we are doing "cpumask_any_but(mm_cpumask(mm),
>>> smp_processor_id()) < nr_cpu_ids".
>>
>> IMO this is a bit nuts.  smp_mb__after_atomic() doesn't do anything on
>> x86.  And, even if it did, why should the flush code assume that the
>> previous store was atomic?
>>
>> What's the issue being fixed / worked around here?
>
> It does a compiler barrier, which prevents the decision whether a
> remote TLB shootdown is required to be made before the PTE is set.
>
> I agree that PTEs may not be written atomically in certain cases
> (although I am unaware of such cases, except on full-mm flush).

How about plain set_pte?  It's atomic (aligned word-sized write), but
it's not atomic in the _after_atomic sense.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
