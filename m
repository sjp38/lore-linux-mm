Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4C99082963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 17:36:54 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id r129so186699006wmr.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:36:54 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id m196si15878142wmg.68.2016.02.03.14.36.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 14:36:52 -0800 (PST)
From: Luis Henriques <luis.henriques@canonical.com>
Subject: [PATCH 3.16.y-ckt 083/180] x86/mm: Add barriers and document switch_mm()-vs-flush synchronization
Date: Wed,  3 Feb 2016 22:31:29 +0000
Message-Id: <1454538786-12215-84-git-send-email-luis.henriques@canonical.com>
In-Reply-To: <1454538786-12215-1-git-send-email-luis.henriques@canonical.com>
References: <1454538786-12215-1-git-send-email-luis.henriques@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org, kernel-team@lists.ubuntu.com
Cc: Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Luis Henriques <luis.henriques@canonical.com>

3.16.7-ckt24 -stable review patch.  If anyone has any objections, please let me know.

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
[ luis: backported to 3.16:
  - dropped N/A comment in flush_tlb_mm_range()
  - adjusted context ]
Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
---
 arch/x86/include/asm/mmu_context.h | 32 +++++++++++++++++++++++++++++++-
 arch/x86/mm/tlb.c                  | 25 ++++++++++++++++++++++---
 2 files changed, 53 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 86fef96f4eca..20cf2c4e1872 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -86,7 +86,32 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
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
 
 		/* Stop flush ipis for the previous mm */
@@ -109,10 +134,15 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
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
 			load_mm_ldt(next);
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index dd8dda167a24..46e82e75192e 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -152,7 +152,10 @@ void flush_tlb_current_task(void)
 	preempt_disable();
 
 	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
+
+	/* This is an implicit full barrier that synchronizes with switch_mm. */
 	local_flush_tlb();
+
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
 	preempt_enable();
@@ -166,11 +169,19 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 	unsigned long nr_base_pages;
 
 	preempt_disable();
-	if (current->active_mm != mm)
+	if (current->active_mm != mm) {
+		/* Synchronize with switch_mm. */
+		smp_mb();
+
 		goto flush_all;
+	}
 
 	if (!current->mm) {
 		leave_mm(smp_processor_id());
+
+		/* Synchronize with switch_mm. */
+		smp_mb();
+
 		goto flush_all;
 	}
 
@@ -222,10 +233,18 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long start)
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
