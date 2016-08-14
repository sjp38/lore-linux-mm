Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 39C5D6B0253
	for <linux-mm@kvack.org>; Sun, 14 Aug 2016 16:08:49 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w128so83447007pfd.3
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 13:08:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ul9si22500410pab.14.2016.08.14.13.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Aug 2016 13:08:47 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 3.14 04/29] x86/mm: Add barriers and document switch_mm()-vs-flush synchronization
Date: Sun, 14 Aug 2016 22:07:32 +0200
Message-Id: <20160814200731.625036088@linuxfoundation.org>
In-Reply-To: <20160814200731.375346059@linuxfoundation.org>
References: <20160814200731.375346059@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Luis Henriques <luis.henriques@canonical.com>, "Charles (Chas) Williams" <ciwillia@brocade.com>

3.14-stable review patch.  If anyone has any objections, please let me know.

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
[ luis: backported to 3.16:
  - dropped N/A comment in flush_tlb_mm_range()
  - adjusted context ]
Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
[ciwillia@brocade.com: backported to 3.14: adjusted context]
Signed-off-by: Charles (Chas) Williams <ciwillia@brocade.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/x86/include/asm/mmu_context.h |   32 +++++++++++++++++++++++++++++++-
 arch/x86/mm/tlb.c                  |   25 ++++++++++++++++++++++---
 2 files changed, 53 insertions(+), 4 deletions(-)

--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -42,7 +42,32 @@ static inline void switch_mm(struct mm_s
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
@@ -65,10 +90,15 @@ static inline void switch_mm(struct mm_s
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
 			load_LDT_nolock(&next->context);
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
@@ -166,11 +169,19 @@ void flush_tlb_mm_range(struct mm_struct
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
 
@@ -222,10 +233,18 @@ void flush_tlb_page(struct vm_area_struc
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
