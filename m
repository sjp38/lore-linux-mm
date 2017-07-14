Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4917F440941
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 19:16:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v26so101956532pfa.0
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 16:16:49 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id k33si7770821pld.481.2017.07.14.16.16.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 16:16:47 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id j186so12017368pge.1
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 16:16:47 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170713060706.o2cuko5y6irxwnww@suse.de>
Date: Fri, 14 Jul 2017 16:16:44 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <A9CB595E-7C6D-438F-9835-A9EB8DA90892@gmail.com>
References: <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de>
 <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de>
 <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <20170713060706.o2cuko5y6irxwnww@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Mel Gorman <mgorman@suse.de> wrote:

> On Wed, Jul 12, 2017 at 04:27:23PM -0700, Nadav Amit wrote:
>>> If reclaim is first, it'll take the PTL, set batched while a racing
>>> mprotect/munmap/etc spins. On release, the racing mprotect/munmmap
>>> immediately calls flush_tlb_batched_pending() before proceeding as =
normal,
>>> finding pte_none with the TLB flushed.
>>=20
>> This is the scenario I regarded in my example. Notice that when the =
first
>> flush_tlb_batched_pending is called, CPU0 and CPU1 hold different =
page-table
>> locks - allowing them to run concurrently. As a result
>> flush_tlb_batched_pending is executed before the PTE was cleared and
>> mm->tlb_flush_batched is cleared. Later, after CPU0 runs =
ptep_get_and_clear
>> mm->tlb_flush_batched remains clear, and CPU1 can use the stale PTE.
>=20
> If they hold different PTL locks, it means that reclaim and and the =
parallel
> munmap/mprotect/madvise/mremap operation are operating on different =
regions
> of an mm or separate mm's and the race should not apply or at the very
> least is equivalent to not batching the flushes. For multiple parallel
> operations, munmap/mprotect/mremap are serialised by mmap_sem so there
> is only one risky operation at a time. For multiple madvise, there is =
a
> small window when a page is accessible after madvise returns but it is =
an
> advisory call so it's primarily a data integrity concern and the TLB =
is
> flushed before the page is either freed or IO starts on the reclaim =
side.

I think there is some miscommunication. Perhaps one detail was missing:

CPU0				CPU1
---- 				----
should_defer_flush
=3D> mm->tlb_flush_batched=3Dtrue	=09
				flush_tlb_batched_pending (another PT)
				=3D> flush TLB
				=3D> mm->tlb_flush_batched=3Dfalse

				Access PTE (and cache in TLB)
ptep_get_and_clear(PTE)
...

				flush_tlb_batched_pending (batched PT)
				[ no flush since tlb_flush_batched=3Dfalse=
 ]
				use the stale PTE
...
try_to_unmap_flush

There are only 2 CPUs and both regard the same address-space. CPU0 =
reclaim a
page from this address-space. Just between setting tlb_flush_batch and =
the
actual clearing of the PTE, the process on CPU1 runs munmap and calls
flush_tlb_batched_pending. This can happen if CPU1 regards a different
page-table.

So CPU1 flushes the TLB and clears the tlb_flush_batched indication. =
Note,
however, that CPU0 still did not clear the PTE so CPU1 can access this =
PTE
and cache it. Then, after CPU0 clears the PTE, the process on CPU1 can =
try
to munmap the region that includes the cleared PTE. However, now it does =
not
flush the TLB.

> +/*
> + * Ensure that any arch_tlbbatch_add_mm calls on this mm are up to =
date when
> + * this returns. Using the current mm tlb_gen means the TLB will be =
up to date
> + * with respect to the tlb_gen set at arch_tlbbatch_add_mm. If a =
flush has
> + * happened since then the IPIs will still be sent but the actual =
flush is
> + * avoided. Unfortunately the IPIs are necessary as the per-cpu =
context
> + * tlb_gens cannot be safely accessed.
> + */
> +void arch_tlbbatch_flush_one_mm(struct mm_struct *mm)
> +{
> +	int cpu;
> +	struct flush_tlb_info info =3D {
> +		.mm =3D mm,
> +		.new_tlb_gen =3D atomic64_read(&mm->context.tlb_gen),
> +		.start =3D 0,
> +		.end =3D TLB_FLUSH_ALL,
> +	};
> +
> +	cpu =3D get_cpu();
> +
> +	if (mm =3D=3D this_cpu_read(cpu_tlbstate.loaded_mm)) {
> +		VM_WARN_ON(irqs_disabled());
> +		local_irq_disable();
> +		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
> +		local_irq_enable();
> +	}
> +
> +	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
> +		flush_tlb_others(mm_cpumask(mm), &info);
> +
> +	put_cpu();
> +}
> +

It is a shame that after Andy collapsed all the different flushing =
flows,
you create a new one. How about squashing this untested one to yours?

-- >8 --

Subject: x86/mm: refactor flush_tlb_mm_range and =
arch_tlbbatch_flush_one_mm

flush_tlb_mm_range() and arch_tlbbatch_flush_one_mm() share a lot of =
mutual
code. After the recent work on combining the x86 TLB userspace entries
flushes, it is a shame to break them into different code-paths again.

Refactor the mutual code into perform_tlb_flush().

Signed-off-by: Nadav Amit <namit@vmware.com>
---
 arch/x86/mm/tlb.c | 48 +++++++++++++++++++-----------------------------
 1 file changed, 19 insertions(+), 29 deletions(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 248063dc5be8..56e00443a6cf 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -404,17 +404,30 @@ void native_flush_tlb_others(const struct cpumask =
*cpumask,
  */
 static unsigned long tlb_single_page_flush_ceiling __read_mostly =3D =
33;
=20
+static void perform_tlb_flush(struct mm_struct *mm, struct =
flush_tlb_info *info)
+{
+	int cpu =3D get_cpu();
+
+	if (info->mm =3D=3D this_cpu_read(cpu_tlbstate.loaded_mm)) {
+		VM_WARN_ON(irqs_disabled());
+		local_irq_disable();
+		flush_tlb_func_local(info, TLB_LOCAL_MM_SHOOTDOWN);
+		local_irq_enable();
+	}
+
+	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
+		flush_tlb_others(mm_cpumask(mm), info);
+
+	put_cpu();
+}
+
 void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 				unsigned long end, unsigned long vmflag)
 {
-	int cpu;
-
 	struct flush_tlb_info info =3D {
 		.mm =3D mm,
 	};
=20
-	cpu =3D get_cpu();
-
 	/* This is also a barrier that synchronizes with switch_mm(). */
 	info.new_tlb_gen =3D inc_mm_tlb_gen(mm);
=20
@@ -429,17 +442,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, =
unsigned long start,
 		info.end =3D TLB_FLUSH_ALL;
 	}
=20
-	if (mm =3D=3D this_cpu_read(cpu_tlbstate.loaded_mm)) {
-		VM_WARN_ON(irqs_disabled());
-		local_irq_disable();
-		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
-		local_irq_enable();
-	}
-
-	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
-		flush_tlb_others(mm_cpumask(mm), &info);
-
-	put_cpu();
+	perform_tlb_flush(mm, &info);
 }
=20
=20
@@ -515,7 +518,6 @@ void arch_tlbbatch_flush(struct =
arch_tlbflush_unmap_batch *batch)
  */
 void arch_tlbbatch_flush_one_mm(struct mm_struct *mm)
 {
-	int cpu;
 	struct flush_tlb_info info =3D {
 		.mm =3D mm,
 		.new_tlb_gen =3D atomic64_read(&mm->context.tlb_gen),
@@ -523,19 +525,7 @@ void arch_tlbbatch_flush_one_mm(struct mm_struct =
*mm)
 		.end =3D TLB_FLUSH_ALL,
 	};
=20
-	cpu =3D get_cpu();
-
-	if (mm =3D=3D this_cpu_read(cpu_tlbstate.loaded_mm)) {
-		VM_WARN_ON(irqs_disabled());
-		local_irq_disable();
-		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
-		local_irq_enable();
-	}
-
-	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
-		flush_tlb_others(mm_cpumask(mm), &info);
-
-	put_cpu();
+	perform_tlb_flush(mm, &info);
 }
=20
 static ssize_t tlbflush_read_file(struct file *file, char __user =
*user_buf,=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
