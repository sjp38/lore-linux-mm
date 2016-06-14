Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA2C6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 17:37:50 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id b13so4641594pat.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 14:37:50 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id nz7si9877423pab.191.2016.06.14.14.37.49
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 14:37:49 -0700 (PDT)
Subject: Re: [PATCH] Linux VM workaround for Knights Landing A/D leak
References: <1465919919-2093-1-git-send-email-lukasz.anaczkowski@intel.com>
 <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
 <57603C61.5000408@linux.intel.com>
 <2471A3E8-FF69-4720-A3BF-BDC6094A6A70@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <5760792D.90000@linux.intel.com>
Date: Tue, 14 Jun 2016 14:37:49 -0700
MIME-Version: 1.0
In-Reply-To: <2471A3E8-FF69-4720-A3BF-BDC6094A6A70@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com, Andy Lutomirski <luto@amacapital.net>

On 06/14/2016 01:16 PM, Nadav Amit wrote:
> Dave Hansen <dave.hansen@linux.intel.com> wrote:
> 
>> On 06/14/2016 09:47 AM, Nadav Amit wrote:
>>> Lukasz Anaczkowski <lukasz.anaczkowski@intel.com> wrote:
>>>
>>>>> From: Andi Kleen <ak@linux.intel.com>
>>>>> +void fix_pte_leak(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
>>>>> +{
>>> Here there should be a call to smp_mb__after_atomic() to synchronize with
>>> switch_mm. I submitted a similar patch, which is still pending (hint).
>>>
>>>>> +	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids) {
>>>>> +		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
>>>>> +		flush_tlb_others(mm_cpumask(mm), mm, addr,
>>>>> +				 addr + PAGE_SIZE);
>>>>> +		mb();
>>>>> +		set_pte(ptep, __pte(0));
>>>>> +	}
>>>>> +}
>>
>> Shouldn't that barrier be incorporated in the TLB flush code itself and
>> not every single caller (like this code is)?
>>
>> It is insane to require individual TLB flushers to be concerned with the
>> barriers.
> 
> IMHO it is best to use existing flushing interfaces instead of creating
> new ones. 

Yeah, or make these things a _little_ harder to get wrong.  That little
snippet above isn't so crazy that we should be depending on open-coded
barriers to get it right.

Should we just add a barrier to mm_cpumask() itself?  That should stop
the race.  Or maybe we need a new primitive like:

/*
 * Call this if a full barrier has been executed since the last
 * pagetable modification operation.
 */
static int __other_cpus_need_tlb_flush(struct mm_struct *mm)
{
	/* cpumask_any_but() returns >= nr_cpu_ids if no cpus set. */
	return cpumask_any_but(mm_cpumask(mm), smp_processor_id()) <
		nr_cpu_ids;
}


static int other_cpus_need_tlb_flush(struct mm_struct *mm)
{
	/*
	 * Synchronizes with switch_mm.  Makes sure that we do not
	 * observe a bit having been cleared in mm_cpumask() before
 	 * the other processor has seen our pagetable update.  See
	 * switch_mm().
	 */
	smp_mb__after_atomic();

	return __other_cpus_need_tlb_flush(mm)
}

We should be able to deploy other_cpus_need_tlb_flush() in most of the
cases where we are doing "cpumask_any_but(mm_cpumask(mm),
smp_processor_id()) < nr_cpu_ids".

Right?

> In theory, fix_pte_leak could have used flush_tlb_page. But the problem
> is that flush_tlb_page requires the vm_area_struct as an argument, which
> ptep_get_and_clear (and others) do not have.

That, and we do not want/need to flush the _current_ processor's TLB.
flush_tlb_page() would have done that unnecessarily.  That's not the end
of the world here, but it is a downside.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
