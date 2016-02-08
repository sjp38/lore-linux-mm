Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 418E8828E2
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 18:55:07 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p63so1696862wmp.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 15:55:07 -0800 (PST)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id g2si45292626wje.67.2016.02.08.15.55.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 15:55:05 -0800 (PST)
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 08 Feb 2016 23:53:51 +0000
Message-ID: <lsq.1454975631.124632264@decadent.org.uk>
Subject: [PATCH 3.2 40/87] x86/mm: Add barriers and document
 switch_mm()-vs-flush synchronization
In-Reply-To: <lsq.1454975630.125133756@decadent.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: akpm@linux-foundation.org, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Linus Torvalds <torvalds@linux-foundation.org>

3.2.77-rc1 review patch.  If anyone has any objections, please let me know.

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
[bwh: Backported to 3.2:
 - There's no flush_tlb_mm_range(), only flush_tlb_mm() which does not use
   INVLPG
 - Adjust context]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -87,7 +87,32 @@ static inline void switch_mm(struct mm_s
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
@@ -108,6 +133,10 @@ static inline void switch_mm(struct mm_s
 			/* We were in lazy tlb mode and leave_mm disabled
 			 * tlb flush IPI delivery. We must reload CR3
 			 * to make sure to use no freed page tables.
+			 *
+			 * As above, this is a barrier that forces
+			 * TLB repopulation to be ordered after the
+			 * store to mm_cpumask.
 			 */
 			load_cr3(next->pgd);
 			load_mm_ldt(next);
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -278,7 +278,9 @@ void flush_tlb_current_task(void)
 
 	preempt_disable();
 
+	/* This is an implicit full barrier that synchronizes with switch_mm. */
 	local_flush_tlb();
+
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, TLB_FLUSH_ALL);
 	preempt_enable();
@@ -289,10 +291,20 @@ void flush_tlb_mm(struct mm_struct *mm)
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
@@ -307,10 +319,18 @@ void flush_tlb_page(struct vm_area_struc
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
