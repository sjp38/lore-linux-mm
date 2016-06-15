Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 21C1F6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 23:20:50 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x6so16411781oif.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 20:20:50 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id ho7si27981474pac.241.2016.06.14.20.20.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 20:20:48 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id 62so698874pfd.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 20:20:48 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] Linux VM workaround for Knights Landing A/D leak
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <5760792D.90000@linux.intel.com>
Date: Tue, 14 Jun 2016 20:20:46 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <BB70E657-4C2E-4991-87A1-48B1E41F4252@gmail.com>
References: <1465919919-2093-1-git-send-email-lukasz.anaczkowski@intel.com> <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com> <57603C61.5000408@linux.intel.com> <2471A3E8-FF69-4720-A3BF-BDC6094A6A70@gmail.com> <5760792D.90000@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com, Andy Lutomirski <luto@amacapital.net>

Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 06/14/2016 01:16 PM, Nadav Amit wrote:
>> Dave Hansen <dave.hansen@linux.intel.com> wrote:
>>=20
>>> On 06/14/2016 09:47 AM, Nadav Amit wrote:
>>>> Lukasz Anaczkowski <lukasz.anaczkowski@intel.com> wrote:
>>>>=20
>>>>>> From: Andi Kleen <ak@linux.intel.com>
>>>>>> +void fix_pte_leak(struct mm_struct *mm, unsigned long addr, =
pte_t *ptep)
>>>>>> +{
>>>> Here there should be a call to smp_mb__after_atomic() to =
synchronize with
>>>> switch_mm. I submitted a similar patch, which is still pending =
(hint).
>>>>=20
>>>>>> +	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) =
< nr_cpu_ids) {
>>>>>> +		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, =
TLB_FLUSH_ALL);
>>>>>> +		flush_tlb_others(mm_cpumask(mm), mm, addr,
>>>>>> +				 addr + PAGE_SIZE);
>>>>>> +		mb();
>>>>>> +		set_pte(ptep, __pte(0));
>>>>>> +	}
>>>>>> +}
>>>=20
>>> Shouldn't that barrier be incorporated in the TLB flush code itself =
and
>>> not every single caller (like this code is)?
>>>=20
>>> It is insane to require individual TLB flushers to be concerned with =
the
>>> barriers.
>>=20
>> IMHO it is best to use existing flushing interfaces instead of =
creating
>> new ones.
>=20
> Yeah, or make these things a _little_ harder to get wrong.  That =
little
> snippet above isn't so crazy that we should be depending on open-coded
> barriers to get it right.
>=20
> Should we just add a barrier to mm_cpumask() itself?  That should stop
> the race.  Or maybe we need a new primitive like:
>=20
> /*
> * Call this if a full barrier has been executed since the last
> * pagetable modification operation.
> */
> static int __other_cpus_need_tlb_flush(struct mm_struct *mm)
> {
> 	/* cpumask_any_but() returns >=3D nr_cpu_ids if no cpus set. */
> 	return cpumask_any_but(mm_cpumask(mm), smp_processor_id()) <
> 		nr_cpu_ids;
> }
>=20
>=20
> static int other_cpus_need_tlb_flush(struct mm_struct *mm)
> {
> 	/*
> 	 * Synchronizes with switch_mm.  Makes sure that we do not
> 	 * observe a bit having been cleared in mm_cpumask() before
> 	 * the other processor has seen our pagetable update.  See
> 	 * switch_mm().
> 	 */
> 	smp_mb__after_atomic();
>=20
> 	return __other_cpus_need_tlb_flush(mm)
> }
>=20
> We should be able to deploy other_cpus_need_tlb_flush() in most of the
> cases where we are doing "cpumask_any_but(mm_cpumask(mm),
> smp_processor_id()) < nr_cpu_ids".
>=20
> Right?
This approach may work, but I doubt other_cpus_need_tlb_flush() would
be needed by anyone, excluding this "hacky" workaround. There are =
already
five interfaces for invalidation of: a single page, a userspace range,
a whole task, a kernel range, and full flush including kernel (global)
entries.

>=20
>> In theory, fix_pte_leak could have used flush_tlb_page. But the =
problem
>> is that flush_tlb_page requires the vm_area_struct as an argument, =
which
>> ptep_get_and_clear (and others) do not have.
>=20
> That, and we do not want/need to flush the _current_ processor's TLB.
> flush_tlb_page() would have done that unnecessarily.  That's not the =
end
> of the world here, but it is a downside.

Oops, I missed the fact a local flush is not needed in this case.

Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
