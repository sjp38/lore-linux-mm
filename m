Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id B0F17828E1
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 20:22:53 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l66so48290389wml.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 17:22:53 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id dl6si18801261wjb.82.2016.01.28.17.22.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 17:22:52 -0800 (PST)
From: Kamal Mostafa <kamal@canonical.com>
Subject: [PATCH 3.19.y-ckt 085/210] x86/mm: Add barriers and document switch_mm()-vs-flush synchronization
Date: Thu, 28 Jan 2016 17:17:03 -0800
Message-Id: <1454030348-17736-86-git-send-email-kamal@canonical.com>
In-Reply-To: <1454030348-17736-1-git-send-email-kamal@canonical.com>
References: <1454030348-17736-1-git-send-email-kamal@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org, kernel-team@lists.ubuntu.com
Cc: Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Kamal Mostafa <kamal@canonical.com>

3.19.8-ckt14 -stable review patch.  If anyone has any objections, please let me know.

---8<------------------------------------------------------------

From: Andy Lutomirski <luto@kernel.org>

commit 71b3c126e61177eb693423f2e18a1914205b165e upstream.

When switch_mm() activates a new PGD, it also sets a bit that
tells other CPUs that the PGD is in use so that TLB flush IPIs
will be sent.  In order for that to work correctly, the bit
needs to be visible prior to loading the PGD and therefore
starting to fill the local TLB.

Document all the barriers that make this work correctly and add
a couple that were missing.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Kamal Mostafa <kamal@canonical.com>
---
 arch/x86/include/asm/mmu_context.h | 33 ++++++++++++++++++++++++++++++++-
 arch/x86/mm/tlb.c                  | 29 ++++++++++++++++++++++++++---
 2 files changed, 58 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index acdeb2be..2962f62 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -89,8 +89,34 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
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
@@ -122,10 +148,15 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
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
index 020bcc7..106c4e9 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -163,7 +163,10 @@ void flush_tlb_current_task(void)
 	preempt_disable();
 
 	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
+
+	/* This is an implicit full barrier that synchronizes with switch_mm. */
 	local_flush_tlb();
+
 	trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
@@ -190,17 +193,29 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
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
@@ -230,10 +245,18 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long start)
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
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
