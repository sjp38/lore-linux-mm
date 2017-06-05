Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id EA33C6B02F3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 18:37:07 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id r84so73846170oif.0
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:37:07 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c193si2273618oib.24.2017.06.05.15.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 15:37:07 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 03/11] x86/mm: Give each mm TLB flush generation a unique ID
Date: Mon,  5 Jun 2017 15:36:27 -0700
Message-Id: <b7d302dafd28e256b910b0f408bbae3ed971d204.1496701658.git.luto@kernel.org>
In-Reply-To: <cover.1496701658.git.luto@kernel.org>
References: <cover.1496701658.git.luto@kernel.org>
In-Reply-To: <cover.1496701658.git.luto@kernel.org>
References: <cover.1496701658.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>

This adds two new variables to mmu_context_t: ctx_id and tlb_gen.
ctx_id uniquely identifies the mm_struct and will never be reused.
For a given mm_struct (and hence ctx_id), tlb_gen is a monotonic
count of the number of times that a TLB flush has been requested.
The pair (ctx_id, tlb_gen) can be used as an identifier for TLB
flush actions and will be used in subsequent patches to reliably
determine whether all needed TLB flushes have occurred on a given
CPU.

This patch is split out for ease of review.  By itself, it has no
real effect other than creating and updating the new variables.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/mmu.h         | 25 +++++++++++++++++++++++--
 arch/x86/include/asm/mmu_context.h |  5 +++++
 arch/x86/include/asm/tlbflush.h    | 18 ++++++++++++++++++
 arch/x86/mm/tlb.c                  |  6 ++++--
 4 files changed, 50 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/mmu.h b/arch/x86/include/asm/mmu.h
index 79b647a7ebd0..bb8c597c2248 100644
--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -3,12 +3,28 @@
 
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
+#include <linux/atomic.h>
 
 /*
- * The x86 doesn't have a mmu context, but
- * we put the segment information here.
+ * x86 has arch-specific MMU state beyond what lives in mm_struct.
  */
 typedef struct {
+	/*
+	 * ctx_id uniquely identifies this mm_struct.  A ctx_id will never
+	 * be reused, and zero is not a valid ctx_id.
+	 */
+	u64 ctx_id;
+
+	/*
+	 * Any code that needs to do any sort of TLB flushing for this
+	 * mm will first make its changes to the page tables, then
+	 * increment tlb_gen, then flush.  This lets the low-level
+	 * flushing code keep track of what needs flushing.
+	 *
+	 * This is not used on Xen PV.
+	 */
+	atomic64_t tlb_gen;
+
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
 	struct ldt_struct *ldt;
 #endif
@@ -37,6 +53,11 @@ typedef struct {
 #endif
 } mm_context_t;
 
+#define INIT_MM_CONTEXT(mm)						\
+	.context = {							\
+		.ctx_id = 1,						\
+	}
+
 void leave_mm(int cpu);
 
 #endif /* _ASM_X86_MMU_H */
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index d59bbfb4c8b4..e691b4d46b9d 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -126,9 +126,14 @@ static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
 		this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
 }
 
+extern atomic64_t last_mm_ctx_id;
+
 static inline int init_new_context(struct task_struct *tsk,
 				   struct mm_struct *mm)
 {
+	mm->context.ctx_id = atomic64_inc_return(&last_mm_ctx_id);
+	atomic64_set(&mm->context.tlb_gen, 0);
+
 	#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
 	if (cpu_feature_enabled(X86_FEATURE_OSPKE)) {
 		/* pkey 0 is the default and always allocated */
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index ee5a138602e8..5438f7e07fef 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -57,6 +57,23 @@ static inline void invpcid_flush_all_nonglobals(void)
 	__invpcid(0, 0, INVPCID_TYPE_ALL_NON_GLOBAL);
 }
 
+static inline u64 bump_mm_tlb_gen(struct mm_struct *mm)
+{
+	u64 new_tlb_gen;
+
+	/*
+	 * Bump the generation count.  This also serves as a full barrier
+	 * that synchronizes with switch_mm: callers are required to order
+	 * their read of mm_cpumask after their writes to the paging
+	 * structures.
+	 */
+	smp_mb__before_atomic();
+	new_tlb_gen = atomic64_inc_return(&mm->context.tlb_gen);
+	smp_mb__after_atomic();
+
+	return new_tlb_gen;
+}
+
 #ifdef CONFIG_PARAVIRT
 #include <asm/paravirt.h>
 #else
@@ -262,6 +279,7 @@ void native_flush_tlb_others(const struct cpumask *cpumask,
 static inline void arch_tlbbatch_add_mm(struct arch_tlbflush_unmap_batch *batch,
 					struct mm_struct *mm)
 {
+	bump_mm_tlb_gen(mm);
 	cpumask_or(&batch->cpumask, &batch->cpumask, mm_cpumask(mm));
 }
 
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index b2485d69f7c2..7c99c50e8bc9 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -28,6 +28,8 @@
  *	Implement flush IPI by CALL_FUNCTION_VECTOR, Alex Shi
  */
 
+atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
+
 void leave_mm(int cpu)
 {
 	struct mm_struct *loaded_mm = this_cpu_read(cpu_tlbstate.loaded_mm);
@@ -283,8 +285,8 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 
 	cpu = get_cpu();
 
-	/* Synchronize with switch_mm. */
-	smp_mb();
+	/* This is also a barrier that synchronizes with switch_mm(). */
+	bump_mm_tlb_gen(mm);
 
 	/* Should we flush just the requested range? */
 	if ((end != TLB_FLUSH_ALL) &&
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
