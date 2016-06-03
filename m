Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE896B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 13:42:13 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id di3so102929316pab.0
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 10:42:13 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id do10si6871150pac.124.2016.06.03.10.42.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 10:42:12 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id x1so6429090pav.1
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 10:42:12 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC 05/13] x86/mm: Add barriers and document switch_mm-vs-flush synchronization
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <95a853538da28c64dfc877c60549ec79ed7a5d69.1452294700.git.luto@kernel.org>
Date: Fri, 3 Jun 2016 10:42:10 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <8D80C93B-3DD6-469B-90D6-FBC71B917EAD@gmail.com>
References: <cover.1452294700.git.luto@kernel.org> <cover.1452294700.git.luto@kernel.org> <95a853538da28c64dfc877c60549ec79ed7a5d69.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, LKML <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Following this patch, if (current->active_mm !=3D mm), flush_tlb_page() =
still
doesn=E2=80=99t call smp_mb() before checking mm_cpumask(mm).

In contrast, flush_tlb_mm_range() does call smp_mb().

Is there a reason for this discrepancy?

Thanks,
Nadav

Andy Lutomirski <luto@kernel.org> wrote:

> When switch_mm activates a new pgd, it also sets a bit that tells
> other CPUs that the pgd is in use so that tlb flush IPIs will be
> sent.  In order for that to work correctly, the bit needs to be
> visible prior to loading the pgd and therefore starting to fill the
> local TLB.
>=20
> Document all the barriers that make this work correctly and add a
> couple that were missing.
>=20
> Cc: stable@vger.kernel.org
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
> arch/x86/include/asm/mmu_context.h | 33 =
++++++++++++++++++++++++++++++++-
> arch/x86/mm/tlb.c                  | 29 ++++++++++++++++++++++++++---
> 2 files changed, 58 insertions(+), 4 deletions(-)
>=20
> diff --git a/arch/x86/include/asm/mmu_context.h =
b/arch/x86/include/asm/mmu_context.h
> index 379cd3658799..1edc9cd198b8 100644
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -116,8 +116,34 @@ static inline void switch_mm(struct mm_struct =
*prev, struct mm_struct *next,
> #endif
> 		cpumask_set_cpu(cpu, mm_cpumask(next));
>=20
> -		/* Re-load page tables */
> +		/*
> +		 * Re-load page tables.
> +		 *
> +		 * This logic has an ordering constraint:
> +		 *
> +		 *  CPU 0: Write to a PTE for 'next'
> +		 *  CPU 0: load bit 1 in mm_cpumask.  if nonzero, send =
IPI.
> +		 *  CPU 1: set bit 1 in next's mm_cpumask
> +		 *  CPU 1: load from the PTE that CPU 0 writes =
(implicit)
> +		 *
> +		 * We need to prevent an outcome in which CPU 1 observes
> +		 * the new PTE value and CPU 0 observes bit 1 clear in
> +		 * mm_cpumask.  (If that occurs, then the IPI will never
> +		 * be sent, and CPU 0's TLB will contain a stale entry.)
> +		 *
> +		 * The bad outcome can occur if either CPU's load is
> +		 * reordered before that CPU's store, so both CPUs much
> +		 * execute full barriers to prevent this from happening.
> +		 *
> +		 * Thus, switch_mm needs a full barrier between the
> +		 * store to mm_cpumask and any operation that could load
> +		 * from next->pgd.  This barrier synchronizes with
> +		 * remote TLB flushers.  Fortunately, load_cr3 is
> +		 * serializing and thus acts as a full barrier.
> +		 *
> +		 */
> 		load_cr3(next->pgd);
> +
> 		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, =
TLB_FLUSH_ALL);
>=20
> 		/* Stop flush ipis for the previous mm */
> @@ -156,10 +182,15 @@ static inline void switch_mm(struct mm_struct =
*prev, struct mm_struct *next,
> 			 * schedule, protecting us from simultaneous =
changes.
> 			 */
> 			cpumask_set_cpu(cpu, mm_cpumask(next));
> +
> 			/*
> 			 * We were in lazy tlb mode and leave_mm =
disabled
> 			 * tlb flush IPI delivery. We must reload CR3
> 			 * to make sure to use no freed page tables.
> +			 *
> +			 * As above, this is a barrier that forces
> +			 * TLB repopulation to be ordered after the
> +			 * store to mm_cpumask.
> 			 */
> 			load_cr3(next->pgd);
> 			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, =
TLB_FLUSH_ALL);
> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index 8ddb5d0d66fb..8f4cc3dfac32 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -161,7 +161,10 @@ void flush_tlb_current_task(void)
> 	preempt_disable();
>=20
> 	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
> +
> +	/* This is an implicit full barrier that synchronizes with =
switch_mm. */
> 	local_flush_tlb();
> +
> 	trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
> 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < =
nr_cpu_ids)
> 		flush_tlb_others(mm_cpumask(mm), mm, 0UL, =
TLB_FLUSH_ALL);
> @@ -188,17 +191,29 @@ void flush_tlb_mm_range(struct mm_struct *mm, =
unsigned long start,
> 	unsigned long base_pages_to_flush =3D TLB_FLUSH_ALL;
>=20
> 	preempt_disable();
> -	if (current->active_mm !=3D mm)
> +	if (current->active_mm !=3D mm) {
> +		/* Synchronize with switch_mm. */
> +		smp_mb();
> +
> 		goto out;
> +	}
>=20
> 	if (!current->mm) {
> 		leave_mm(smp_processor_id());
> +
> +		/* Synchronize with switch_mm. */
> +		smp_mb();
> +
> 		goto out;
> 	}
>=20
> 	if ((end !=3D TLB_FLUSH_ALL) && !(vmflag & VM_HUGETLB))
> 		base_pages_to_flush =3D (end - start) >> PAGE_SHIFT;
>=20
> +	/*
> +	 * Both branches below are implicit full barriers (MOV to CR or
> +	 * INVLPG) that synchronize with switch_mm.
> +	 */
> 	if (base_pages_to_flush > tlb_single_page_flush_ceiling) {
> 		base_pages_to_flush =3D TLB_FLUSH_ALL;
> 		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
> @@ -228,10 +243,18 @@ void flush_tlb_page(struct vm_area_struct *vma, =
unsigned long start)
> 	preempt_disable();
>=20
> 	if (current->active_mm =3D=3D mm) {
> -		if (current->mm)
> +		if (current->mm) {
> +			/*
> +			 * Implicit full barrier (INVLPG) that =
synchronizes
> +			 * with switch_mm.
> +			 */
> 			__flush_tlb_one(start);
> -		else
> +		} else {
> 			leave_mm(smp_processor_id());
> +
> +			/* Synchronize with switch_mm. */
> +			smp_mb();
> +		}
> 	}
>=20
> 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < =
nr_cpu_ids)
> --=20
> 2.5.0
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
