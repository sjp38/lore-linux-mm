Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0D606B05FE
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 11:55:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t3so13507990wme.9
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 08:55:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b7si5373776wma.134.2017.07.15.08.55.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 15 Jul 2017 08:55:20 -0700 (PDT)
Date: Sat, 15 Jul 2017 16:55:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170715155518.ok2q62efc2vurqk5@suse.de>
References: <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de>
 <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de>
 <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <20170713060706.o2cuko5y6irxwnww@suse.de>
 <A9CB595E-7C6D-438F-9835-A9EB8DA90892@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <A9CB595E-7C6D-438F-9835-A9EB8DA90892@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Fri, Jul 14, 2017 at 04:16:44PM -0700, Nadav Amit wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Wed, Jul 12, 2017 at 04:27:23PM -0700, Nadav Amit wrote:
> >>> If reclaim is first, it'll take the PTL, set batched while a racing
> >>> mprotect/munmap/etc spins. On release, the racing mprotect/munmmap
> >>> immediately calls flush_tlb_batched_pending() before proceeding as normal,
> >>> finding pte_none with the TLB flushed.
> >> 
> >> This is the scenario I regarded in my example. Notice that when the first
> >> flush_tlb_batched_pending is called, CPU0 and CPU1 hold different page-table
> >> locks - allowing them to run concurrently. As a result
> >> flush_tlb_batched_pending is executed before the PTE was cleared and
> >> mm->tlb_flush_batched is cleared. Later, after CPU0 runs ptep_get_and_clear
> >> mm->tlb_flush_batched remains clear, and CPU1 can use the stale PTE.
> > 
> > If they hold different PTL locks, it means that reclaim and and the parallel
> > munmap/mprotect/madvise/mremap operation are operating on different regions
> > of an mm or separate mm's and the race should not apply or at the very
> > least is equivalent to not batching the flushes. For multiple parallel
> > operations, munmap/mprotect/mremap are serialised by mmap_sem so there
> > is only one risky operation at a time. For multiple madvise, there is a
> > small window when a page is accessible after madvise returns but it is an
> > advisory call so it's primarily a data integrity concern and the TLB is
> > flushed before the page is either freed or IO starts on the reclaim side.
> 
> I think there is some miscommunication. Perhaps one detail was missing:
> 
> CPU0				CPU1
> ---- 				----
> should_defer_flush
> => mm->tlb_flush_batched=true		
> 				flush_tlb_batched_pending (another PT)
> 				=> flush TLB
> 				=> mm->tlb_flush_batched=false
> 
> 				Access PTE (and cache in TLB)
> ptep_get_and_clear(PTE)
> ...
> 
> 				flush_tlb_batched_pending (batched PT)
> 				[ no flush since tlb_flush_batched=false ]
> 				use the stale PTE
> ...
> try_to_unmap_flush
> 
> There are only 2 CPUs and both regard the same address-space. CPU0 reclaim a
> page from this address-space. Just between setting tlb_flush_batch and the
> actual clearing of the PTE, the process on CPU1 runs munmap and calls
> flush_tlb_batched_pending. This can happen if CPU1 regards a different
> page-table.
> 

If both regard the same address-space then they have the same page table so
there is a disconnect between the first and last sentence in your paragraph
above. On CPU 0, the setting of tlb_flush_batched and ptep_get_and_clear
is also reversed as the sequence is

                        pteval = ptep_get_and_clear(mm, address, pvmw.pte);
                        set_tlb_ubc_flush_pending(mm, pte_dirty(pteval));

Additional barriers should not be needed as within the critical section
that can race, it's protected by the lock and with Andy's code, there is
a full barrier before the setting of tlb_flush_batched. With Andy's code,
there may be a need for a compiler barrier but I can rethink about that
and add it during the backport to -stable if necessary.

So the setting happens after the clear and if they share the same address
space and collide then they both share the same PTL so are protected from
each other.

If there are separate address spaces using a shared mapping then the
same race does not occur.

> > +/*
> > + * Ensure that any arch_tlbbatch_add_mm calls on this mm are up to date when
> > + * this returns. Using the current mm tlb_gen means the TLB will be up to date
> > + * with respect to the tlb_gen set at arch_tlbbatch_add_mm. If a flush has
> > + * happened since then the IPIs will still be sent but the actual flush is
> > + * avoided. Unfortunately the IPIs are necessary as the per-cpu context
> > + * tlb_gens cannot be safely accessed.
> > + */
> > +void arch_tlbbatch_flush_one_mm(struct mm_struct *mm)
> > +{
> > +	int cpu;
> > +	struct flush_tlb_info info = {
> > +		.mm = mm,
> > +		.new_tlb_gen = atomic64_read(&mm->context.tlb_gen),
> > +		.start = 0,
> > +		.end = TLB_FLUSH_ALL,
> > +	};
> > +
> > +	cpu = get_cpu();
> > +
> > +	if (mm == this_cpu_read(cpu_tlbstate.loaded_mm)) {
> > +		VM_WARN_ON(irqs_disabled());
> > +		local_irq_disable();
> > +		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
> > +		local_irq_enable();
> > +	}
> > +
> > +	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
> > +		flush_tlb_others(mm_cpumask(mm), &info);
> > +
> > +	put_cpu();
> > +}
> > +
> 
> It is a shame that after Andy collapsed all the different flushing flows,
> you create a new one. How about squashing this untested one to yours?
> 

The patch looks fine to be but when writing the patch, I wondered why the
original code disabled preemption before inc_mm_tlb_gen. I didn't spot
the reason for it but given the importance of properly synchronising with
switch_mm, I played it safe. However, this should be ok on top and
maintain the existing sequences

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 248063dc5be8..cbd8621a0bee 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -404,6 +404,21 @@ void native_flush_tlb_others(const struct cpumask *cpumask,
  */
 static unsigned long tlb_single_page_flush_ceiling __read_mostly = 33;
 
+static void flush_tlb_mm_common(struct flush_tlb_info *info, int cpu)
+{
+	struct mm_struct *mm = info->mm;
+
+	if (mm == this_cpu_read(cpu_tlbstate.loaded_mm)) {
+		VM_WARN_ON(irqs_disabled());
+		local_irq_disable();
+		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
+		local_irq_enable();
+	}
+
+	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
+		flush_tlb_others(mm_cpumask(mm), info);
+}
+
 void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 				unsigned long end, unsigned long vmflag)
 {
@@ -429,15 +444,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 		info.end = TLB_FLUSH_ALL;
 	}
 
-	if (mm == this_cpu_read(cpu_tlbstate.loaded_mm)) {
-		VM_WARN_ON(irqs_disabled());
-		local_irq_disable();
-		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
-		local_irq_enable();
-	}
-
-	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
-		flush_tlb_others(mm_cpumask(mm), &info);
+	flush_tlb_mm_common(&info, cpu);
 
 	put_cpu();
 }
@@ -515,7 +522,6 @@ void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
  */
 void arch_tlbbatch_flush_one_mm(struct mm_struct *mm)
 {
-	int cpu;
 	struct flush_tlb_info info = {
 		.mm = mm,
 		.new_tlb_gen = atomic64_read(&mm->context.tlb_gen),
@@ -523,17 +529,7 @@ void arch_tlbbatch_flush_one_mm(struct mm_struct *mm)
 		.end = TLB_FLUSH_ALL,
 	};
 
-	cpu = get_cpu();
-
-	if (mm == this_cpu_read(cpu_tlbstate.loaded_mm)) {
-		VM_WARN_ON(irqs_disabled());
-		local_irq_disable();
-		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
-		local_irq_enable();
-	}
-
-	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
-		flush_tlb_others(mm_cpumask(mm), &info);
+	flush_tlb_mm_common(&info, get_cpu());
 
 	put_cpu();
 }

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
