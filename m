From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH 2.6.32 07/55] x86/mm: Add barriers and document switch_mm()-vs-flush
 synchronization
Date: Fri, 04 Mar 2016 16:30:07 +0100
Message-ID: <20160304153001.014867528@1wt.eu>
References: <148ee355b419e9976ca727513a1405c8@local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <148ee355b419e9976ca727513a1405c8@local>
Sender: stable-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Ben Hutchings <ben@decadent.org.uk>, Willy Tarreau <w@1wt.eu>
List-Id: linux-mm.kvack.org

2.6.32-longterm review patch.  If anyone has any objections, please let me know.

------------------

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
[bwh: Backported to 2.6.32:
 - There's no flush_tlb_mm_range(), only flush_tlb_mm() which does not use
   INVLPG
 - Adjust context]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 arch/x86/include/asm/mmu_context.h | 31 ++++++++++++++++++++++++++++++-
 arch/x86/mm/tlb.c                  | 28 ++++++++++++++++++++++++----
 2 files changed, 54 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 8b5393e..b2c847a 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -42,7 +42,32 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
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
 
 		/* stop flush ipis for the previous mm */
@@ -63,6 +88,10 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 			/* We were in lazy tlb mode and leave_mm disabled
 			 * tlb flush IPI delivery. We must reload CR3
 			 * to make sure to use no freed page tables.
+			 *
+			 * As above, this is a barrier that forces
+			 * TLB repopulation to be ordered after the
+			 * store to mm_cpumask.
 			 */
 			load_cr3(next->pgd);
 			load_LDT_nolock(&next->context);
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 36fe08e..2a655b2 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -234,7 +234,9 @@ void flush_tlb_current_task(void)
 
 	preempt_disable();
 
+	/* This is an implicit full barrier that synchronizes with switch_mm. */
 	local_flush_tlb();
+
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, TLB_FLUSH_ALL);
 	preempt_enable();
@@ -245,10 +247,20 @@ void flush_tlb_mm(struct mm_struct *mm)
 	preempt_disable();
 
 	if (current->active_mm == mm) {
-		if (current->mm)
+		if (current->mm) {
+			/*
+			 * This is an implicit full barrier (MOV to CR) that
+			 * synchronizes with switch_mm.
+			 */
 			local_flush_tlb();
-		else
+		} else {
 			leave_mm(smp_processor_id());
+			/* Synchronize with switch_mm. */
+			smp_mb();
+		}
+	} else {
+		/* Synchronize with switch_mm. */
+		smp_mb();
 	}
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, TLB_FLUSH_ALL);
@@ -263,10 +275,18 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long va)
 	preempt_disable();
 
 	if (current->active_mm == mm) {
-		if (current->mm)
+		if (current->mm) {
+			/*
+			 * Implicit full barrier (INVLPG) that synchronizes
+			 * with switch_mm.
+			 */
 			__flush_tlb_one(va);
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
1.7.12.2.21.g234cd45.dirty
