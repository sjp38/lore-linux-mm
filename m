Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D27516B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 03:32:31 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p64so2195897wrc.8
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 00:32:31 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id i6si880816wra.141.2017.06.22.00.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 00:32:30 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id k67so2411144wrc.1
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 00:32:30 -0700 (PDT)
Date: Thu, 22 Jun 2017 09:32:27 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 01/11] x86/mm: Don't reenter flush_tlb_func_common()
Message-ID: <20170622073227.lep4fmqypq6habnn@gmail.com>
References: <cover.1498022414.git.luto@kernel.org>
 <b13eee98a0e5322fbdc450f234a01006ec374e2c.1498022414.git.luto@kernel.org>
 <207CCA52-C1A0-4AEF-BABF-FA6552CFB71F@gmail.com>
 <CALCETrWA_-ADiUTqC17WV-GVTJymuGpZOrGnE291nhDMr1McMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWA_-ADiUTqC17WV-GVTJymuGpZOrGnE291nhDMr1McMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>


* Andy Lutomirski <luto@kernel.org> wrote:

> On Wed, Jun 21, 2017 at 4:26 PM, Nadav Amit <nadav.amit@gmail.com> wrote:
> > Andy Lutomirski <luto@kernel.org> wrote:
> >
> >> index 2a5e851f2035..f06239c6919f 100644
> >> --- a/arch/x86/mm/tlb.c
> >> +++ b/arch/x86/mm/tlb.c
> >> @@ -208,6 +208,9 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
> >> static void flush_tlb_func_common(const struct flush_tlb_info *f,
> >>                                 bool local, enum tlb_flush_reason reason)
> >> {
> >> +     /* This code cannot presently handle being reentered. */
> >> +     VM_WARN_ON(!irqs_disabled());
> >> +
> >>       if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
> >>               leave_mm(smp_processor_id());
> >>               return;
> >> @@ -313,8 +316,12 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
> >>               info.end = TLB_FLUSH_ALL;
> >>       }
> >>
> >> -     if (mm == this_cpu_read(cpu_tlbstate.loaded_mm))
> >> +     if (mm == this_cpu_read(cpu_tlbstate.loaded_mm)) {
> >
> > Perhaps you want to add:
> >
> >         VM_WARN_ON(irqs_disabled());
> >
> > here
> >
> >> +             local_irq_disable();
> >>               flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
> >> +             local_irq_enable();
> >> +     }
> >> +
> >>       if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
> >>               flush_tlb_others(mm_cpumask(mm), &info);
> >>       put_cpu();
> >> @@ -370,8 +377,12 @@ void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
> >>
> >>       int cpu = get_cpu();
> >>
> >> -     if (cpumask_test_cpu(cpu, &batch->cpumask))
> >> +     if (cpumask_test_cpu(cpu, &batch->cpumask)) {
> >
> > and here?
> >
> 
> Will do.
> 
> What I really want is lockdep_assert_irqs_disabled() or, even better,
> for this to be implicit when calling local_irq_disable().  Ingo?

I tried that once many years ago and IIRC there were problems - but maybe we could 
try it again and enforce it, as I agree that the following pattern:

	local_irq_disable();
	...
		local_irq_disable();
		...
		local_irq_enable();
	...
	local_irq_enable();

.. is actively dangerous.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
