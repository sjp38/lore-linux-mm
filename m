Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9FD828E9
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:15:44 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id e65so15938525pfe.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:15:44 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id h75si3513456pfd.5.2016.01.08.15.15.43
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 15:15:43 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 05/13] x86/mm: Add barriers and document switch_mm-vs-flush synchronization
Date: Fri,  8 Jan 2016 15:15:23 -0800
Message-Id: <95a853538da28c64dfc877c60549ec79ed7a5d69.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, stable@vger.kernel.org

When switch_mm activates a new pgd, it also sets a bit that tells
other CPUs that the pgd is in use so that tlb flush IPIs will be
sent.  In order for that to work correctly, the bit needs to be
visible prior to loading the pgd and therefore starting to fill the
local TLB.

Document all the barriers that make this work correctly and add a
couple that were missing.

Cc: stable@vger.kernel.org
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/mmu_context.h | 33 ++++++++++++++++++++++++++++++++-
 arch/x86/mm/tlb.c                  | 29 ++++++++++++++++++++++++++---
 2 files changed, 58 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 379cd3658799..1edc9cd198b8 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -116,8 +116,34 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 #endif
 		cpumask_set_cpu(cpu, mm_cpumask(next));
 
-		/* Re-load page tables */
+		/*
+		 * Re-load page tables.
+		 *
+		 * This logic has an ordering constraint:
+		 *
+		 *  CPU 0: Write to a PTE for 'next'
+		 *  CPU 0: load bit 1 in mm_cpumask.  if nonzero, send IPI.
+		 *  CPU 1: set bit 1 in next's mm_cpumask
+		 *  CPU 1: load from the PTE that CPU 0 writes (implicit)
+		 *
+		 * We need to prevent an outcome in which CPU 1 observes
+		 * the new PTE value and CPU 0 observes bit 1 clear in
+		 * mm_cpumask.  (If that occurs, then the IPI will never
+		 * be sent, and CPU 0's TLB will contain a stale entry.)
+		 *
+		 * The bad outcome can occur if either CPU's load is
+		 * reordered before that CPU's store, so both CPUs much
+		 * execute full barriers to prevent this from happening.
+		 *
+		 * Thus, switch_mm needs a full barrier between the
+		 * store to mm_cpumask and any operation that could load
+		 * from next->pgd.  This barrier synchronizes with
+		 * remote TLB flushers.  Fortunately, load_cr3 is
+		 * serializing and thus acts as a full barrier.
+		 *
+		 */
 		load_cr3(next->pgd);
+
 		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
 
 		/* Stop flush ipis for the previous mm */
@@ -156,10 +182,15 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 			 * schedule, protecting us from simultaneous changes.
 			 */
 			cpumask_set_cpu(cpu, mm_cpumask(next));
+
 			/*
 			 * We were in lazy tlb mode and leave_mm disabled
 			 * tlb flush IPI delivery. We must reload CR3
 			 * to make sure to use no freed page tables.
+			 *
+			 * As above, this is a barrier that forces
+			 * TLB repopulation to be ordered after the
+			 * store to mm_cpumask.
 			 */
 			load_cr3(next->pgd);
 			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 8ddb5d0d66fb..8f4cc3dfac32 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -161,7 +161,10 @@ void flush_tlb_current_task(void)
 	preempt_disable();
 
 	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
+
+	/* This is an implicit full barrier that synchronizes with switch_mm. */
 	local_flush_tlb();
+
 	trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
@@ -188,17 +191,29 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 	unsigned long base_pages_to_flush = TLB_FLUSH_ALL;
 
 	preempt_disable();
-	if (current->active_mm != mm)
+	if (current->active_mm != mm) {
+		/* Synchronize with switch_mm. */
+		smp_mb();
+
 		goto out;
+	}
 
 	if (!current->mm) {
 		leave_mm(smp_processor_id());
+
+		/* Synchronize with switch_mm. */
+		smp_mb();
+
 		goto out;
 	}
 
 	if ((end != TLB_FLUSH_ALL) && !(vmflag & VM_HUGETLB))
 		base_pages_to_flush = (end - start) >> PAGE_SHIFT;
 
+	/*
+	 * Both branches below are implicit full barriers (MOV to CR or
+	 * INVLPG) that synchronize with switch_mm.
+	 */
 	if (base_pages_to_flush > tlb_single_page_flush_ceiling) {
 		base_pages_to_flush = TLB_FLUSH_ALL;
 		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
@@ -228,10 +243,18 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long start)
 	preempt_disable();
 
 	if (current->active_mm == mm) {
-		if (current->mm)
+		if (current->mm) {
+			/*
+			 * Implicit full barrier (INVLPG) that synchronizes
+			 * with switch_mm.
+			 */
 			__flush_tlb_one(start);
-		else
+		} else {
 			leave_mm(smp_processor_id());
+
+			/* Synchronize with switch_mm. */
+			smp_mb();
+		}
 	}
 
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
