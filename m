Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A71BA6B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 10:10:49 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id p62so11013243oih.12
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 07:10:49 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k205si6762429oih.431.2017.07.25.07.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 07:10:48 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v6] x86/mm: Improve TLB flush documentation
Date: Tue, 25 Jul 2017 07:10:44 -0700
Message-Id: <b994bd38fd8dbed15e3bf8a0a23dde207b2297c0.1500991817.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>

Improve comments as requested by PeterZ and also add some
documentation at the top of the file.

This adds and removes some smp_mb__after_atomic() calls to make the
code correct even in the absence of x86's extra-strong atomics.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---

Changes from v5:
 - Fix blatantly wrong docs (PeterZ, Nadav)
 - Remove the smp_mb__...._atomic() I was supposed to remove, not the one
   I did remove (found by turning on brain and re-reading PeterZ's email)

arch/x86/include/asm/tlbflush.h |  2 --
 arch/x86/mm/tlb.c               | 45 ++++++++++++++++++++++++++++++++---------
 2 files changed, 35 insertions(+), 12 deletions(-)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index d23e61dc0640..eb2b44719d57 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -67,9 +67,7 @@ static inline u64 inc_mm_tlb_gen(struct mm_struct *mm)
 	 * their read of mm_cpumask after their writes to the paging
 	 * structures.
 	 */
-	smp_mb__before_atomic();
 	new_tlb_gen = atomic64_inc_return(&mm->context.tlb_gen);
-	smp_mb__after_atomic();
 
 	return new_tlb_gen;
 }
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index ce104b962a17..0a2e9d0b5503 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -15,17 +15,24 @@
 #include <linux/debugfs.h>
 
 /*
- *	TLB flushing, formerly SMP-only
- *		c/o Linus Torvalds.
+ * The code in this file handles mm switches and TLB flushes.
  *
- *	These mean you can really definitely utterly forget about
- *	writing to user space from interrupts. (Its not allowed anyway).
+ * An mm's TLB state is logically represented by a totally ordered sequence
+ * of TLB flushes.  Each flush increments the mm's tlb_gen.
  *
- *	Optimizations Manfred Spraul <manfred@colorfullife.com>
+ * Each CPU that might have an mm in its TLB (and that might ever use
+ * those TLB entries) will have an entry for it in its cpu_tlbstate.ctxs
+ * array.  The kernel maintains the following invariant: for each CPU and
+ * for each mm in its cpu_tlbstate.ctxs array, the CPU has performed all
+ * flushes in that mms history up to the tlb_gen in cpu_tlbstate.ctxs
+ * or the CPU has performed an equivalent set of flushes.
  *
- *	More scalable flush, from Andi Kleen
- *
- *	Implement flush IPI by CALL_FUNCTION_VECTOR, Alex Shi
+ * For this purpose, an equivalent set is a set that is at least as strong.
+ * So, for example, if the flush history is a full flush at time 1,
+ * a full flush after time 1 is sufficient, but a full flush before time 1
+ * is not.  Similarly, any number of flushes can be replaced by a single
+ * full flush so long as that replacement flush is after all the flushes
+ * that it's replacing.
  */
 
 atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
@@ -138,8 +145,18 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 			return;
 		}
 
-		/* Resume remote flushes and then read tlb_gen. */
+		/*
+		 * Resume remote flushes and then read tlb_gen.  The
+		 * barrier synchronizes with inc_mm_tlb_gen() like
+		 * this:
+		 *
+		 * switch_mm_irqs_off():	flush request:
+		 *  cpumask_set_cpu(...);	 inc_mm_tlb_gen();
+		 *  MB				 MB
+		 *  atomic64_read(.tlb_gen);	 flush_tlb_others(mm_cpumask());
+		 */
 		cpumask_set_cpu(cpu, mm_cpumask(next));
+		smp_mb__after_atomic();
 		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
 
 		if (this_cpu_read(cpu_tlbstate.ctxs[prev_asid].tlb_gen) <
@@ -186,9 +203,17 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 		VM_WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
 
 		/*
-		 * Start remote flushes and then read tlb_gen.
+		 * Start remote flushes and then read tlb_gen.  As
+		 * above, the barrier synchronizes with
+		 * inc_mm_tlb_gen() like this:
+		 *
+		 * switch_mm_irqs_off():	flush request:
+		 *  cpumask_set_cpu(...);	 inc_mm_tlb_gen();
+		 *  MB				 MB
+		 *  atomic64_read(.tlb_gen);	 flush_tlb_others(mm_cpumask());
 		 */
 		cpumask_set_cpu(cpu, mm_cpumask(next));
+		smp_mb__after_atomic();
 		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
 
 		choose_new_asid(next, next_tlb_gen, &new_asid, &need_flush);
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
