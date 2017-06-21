Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 168F06B033C
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 01:22:32 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id 93so112692796oto.10
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 22:22:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 186si4635287oii.341.2017.06.20.22.22.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 22:22:30 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 11/11] x86/mm: Try to preserve old TLB entries using PCID
Date: Tue, 20 Jun 2017 22:22:17 -0700
Message-Id: <a8cdfbbb17785aed10980d24692745f68615a584.1498022414.git.luto@kernel.org>
In-Reply-To: <cover.1498022414.git.luto@kernel.org>
References: <cover.1498022414.git.luto@kernel.org>
In-Reply-To: <cover.1498022414.git.luto@kernel.org>
References: <cover.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>

PCID is a "process context ID" -- it's what other architectures call
an address space ID.  Every non-global TLB entry is tagged with a
PCID, only TLB entries that match the currently selected PCID are
used, and we can switch PGDs without flushing the TLB.  x86's
PCID is 12 bits.

This is an unorthodox approach to using PCID.  x86's PCID is far too
short to uniquely identify a process, and we can't even really
uniquely identify a running process because there are monster
systems with over 4096 CPUs.  To make matters worse, past attempts
to use all 12 PCID bits have resulted in slowdowns instead of
speedups.

This patch uses PCID differently.  We use a PCID to identify a
recently-used mm on a per-cpu basis.  An mm has no fixed PCID
binding at all; instead, we give it a fresh PCID each time it's
loaded except in cases where we want to preserve the TLB, in which
case we reuse a recent value.

This seems to save about 100ns on context switches between mms.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/mmu_context.h     |  3 ++
 arch/x86/include/asm/processor-flags.h |  2 +
 arch/x86/include/asm/tlbflush.h        | 18 +++++++-
 arch/x86/mm/init.c                     |  1 +
 arch/x86/mm/tlb.c                      | 82 ++++++++++++++++++++++++++--------
 5 files changed, 86 insertions(+), 20 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 69a4f1ee86ac..2537ec03c9b7 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -299,6 +299,9 @@ static inline unsigned long __get_current_cr3_fast(void)
 {
 	unsigned long cr3 = __pa(this_cpu_read(cpu_tlbstate.loaded_mm)->pgd);
 
+	if (static_cpu_has(X86_FEATURE_PCID))
+		cr3 |= this_cpu_read(cpu_tlbstate.loaded_mm_asid);
+
 	/* For now, be very restrictive about when this can be called. */
 	VM_WARN_ON(in_nmi() || !in_atomic());
 
diff --git a/arch/x86/include/asm/processor-flags.h b/arch/x86/include/asm/processor-flags.h
index 79aa2f98398d..791b60199aa4 100644
--- a/arch/x86/include/asm/processor-flags.h
+++ b/arch/x86/include/asm/processor-flags.h
@@ -35,6 +35,7 @@
 /* Mask off the address space ID bits. */
 #define CR3_ADDR_MASK 0x7FFFFFFFFFFFF000ull
 #define CR3_PCID_MASK 0xFFFull
+#define CR3_NOFLUSH (1UL << 63)
 #else
 /*
  * CR3_ADDR_MASK needs at least bits 31:5 set on PAE systems, and we save
@@ -42,6 +43,7 @@
  */
 #define CR3_ADDR_MASK 0xFFFFFFFFull
 #define CR3_PCID_MASK 0ull
+#define CR3_NOFLUSH 0
 #endif
 
 #endif /* _ASM_X86_PROCESSOR_FLAGS_H */
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 57b305e13c4c..a9a5aa6f45f7 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -82,6 +82,12 @@ static inline u64 bump_mm_tlb_gen(struct mm_struct *mm)
 #define __flush_tlb_single(addr) __native_flush_tlb_single(addr)
 #endif
 
+/*
+ * 6 because 6 should be plenty and struct tlb_state will fit in
+ * two cache lines.
+ */
+#define NR_DYNAMIC_ASIDS 6
+
 struct tlb_context {
 	u64 ctx_id;
 	u64 tlb_gen;
@@ -95,6 +101,8 @@ struct tlb_state {
 	 * mode even if we've already switched back to swapper_pg_dir.
 	 */
 	struct mm_struct *loaded_mm;
+	u16 loaded_mm_asid;
+	u16 next_asid;
 
 	/*
 	 * Access to this CR4 shadow and to H/W CR4 is protected by
@@ -104,7 +112,8 @@ struct tlb_state {
 
 	/*
 	 * This is a list of all contexts that might exist in the TLB.
-	 * Since we don't yet use PCID, there is only one context.
+	 * There is one per ASID that we use, and the ASID (what the
+	 * CPU calls PCID) is the index into ctxts.
 	 *
 	 * For each context, ctx_id indicates which mm the TLB's user
 	 * entries came from.  As an invariant, the TLB will never
@@ -114,8 +123,13 @@ struct tlb_state {
 	 * To be clear, this means that it's legal for the TLB code to
 	 * flush the TLB without updating tlb_gen.  This can happen
 	 * (for now, at least) due to paravirt remote flushes.
+	 *
+	 * NB: context 0 is a bit special, since it's also used by
+	 * various bits of init code.  This is fine -- code that
+	 * isn't aware of PCID will end up harmlessly flushing
+	 * context 0.
 	 */
-	struct tlb_context ctxs[1];
+	struct tlb_context ctxs[NR_DYNAMIC_ASIDS];
 };
 DECLARE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate);
 
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 7d6fa4676af9..9c9570d300ba 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -812,6 +812,7 @@ void __init zone_sizes_init(void)
 
 DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate) = {
 	.loaded_mm = &init_mm,
+	.next_asid = 1,
 	.cr4 = ~0UL,	/* fail hard if we screw up cr4 shadow initialization */
 };
 EXPORT_SYMBOL_GPL(cpu_tlbstate);
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 5f932fd80881..cd7f604ee818 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -30,6 +30,40 @@
 
 atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
 
+static void choose_new_asid(struct mm_struct *next, u64 next_tlb_gen,
+			    u16 *new_asid, bool *need_flush)
+{
+	u16 asid;
+
+	if (!static_cpu_has(X86_FEATURE_PCID)) {
+		*new_asid = 0;
+		*need_flush = true;
+		return;
+	}
+
+	for (asid = 0; asid < NR_DYNAMIC_ASIDS; asid++) {
+		if (this_cpu_read(cpu_tlbstate.ctxs[asid].ctx_id) !=
+		    next->context.ctx_id)
+			continue;
+
+		*new_asid = asid;
+		*need_flush = (this_cpu_read(cpu_tlbstate.ctxs[asid].tlb_gen) <
+			       next_tlb_gen);
+		return;
+	}
+
+	/*
+	 * We don't currently own an ASID slot on this CPU.
+	 * Allocate a slot.
+	 */
+	*new_asid = this_cpu_add_return(cpu_tlbstate.next_asid, 1) - 1;
+	if (*new_asid >= NR_DYNAMIC_ASIDS) {
+		*new_asid = 0;
+		this_cpu_write(cpu_tlbstate.next_asid, 1);
+	}
+	*need_flush = true;
+}
+
 void leave_mm(int cpu)
 {
 	struct mm_struct *loaded_mm = this_cpu_read(cpu_tlbstate.loaded_mm);
@@ -66,6 +100,7 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 {
 	unsigned cpu = smp_processor_id();
 	struct mm_struct *real_prev = this_cpu_read(cpu_tlbstate.loaded_mm);
+	u16 prev_asid = this_cpu_read(cpu_tlbstate.loaded_mm_asid);
 	u64 next_tlb_gen;
 
 	/*
@@ -81,7 +116,7 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 	if (IS_ENABLED(CONFIG_PROVE_LOCKING))
 		WARN_ON_ONCE(!irqs_disabled());
 
-	VM_BUG_ON(read_cr3_pa() != __pa(real_prev->pgd));
+	VM_BUG_ON(__read_cr3() != (__pa(real_prev->pgd) | prev_asid));
 
 	if (real_prev == next) {
 		if (cpumask_test_cpu(cpu, mm_cpumask(next))) {
@@ -98,10 +133,10 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 		cpumask_set_cpu(cpu, mm_cpumask(next));
 		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
 
-		VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) !=
+		VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[prev_asid].ctx_id) !=
 			  next->context.ctx_id);
 
-		if (this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen) <
+		if (this_cpu_read(cpu_tlbstate.ctxs[prev_asid].tlb_gen) <
 		    next_tlb_gen) {
 			/*
 			 * Ideally, we'd have a flush_tlb() variant that
@@ -109,9 +144,9 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 			 * be faster on Xen PV and on hypothetical CPUs
 			 * on which INVPCID is fast.
 			 */
-			this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
+			this_cpu_write(cpu_tlbstate.ctxs[prev_asid].tlb_gen,
 				       next_tlb_gen);
-			write_cr3(__pa(next->pgd));
+			write_cr3(__pa(next->pgd) | prev_asid);
 			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH,
 					TLB_FLUSH_ALL);
 		}
@@ -122,6 +157,9 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 		 * are not reflected in tlb_gen.)
 		 */
 	} else {
+		u16 new_asid;
+		bool need_flush;
+
 		if (IS_ENABLED(CONFIG_VMAP_STACK)) {
 			/*
 			 * If our current stack is in vmalloc space and isn't
@@ -141,7 +179,7 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 		if (cpumask_test_cpu(cpu, mm_cpumask(real_prev)))
 			cpumask_clear_cpu(cpu, mm_cpumask(real_prev));
 
-		WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
+		VM_WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
 
 		/*
 		 * Start remote flushes and then read tlb_gen.
@@ -149,17 +187,24 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 		cpumask_set_cpu(cpu, mm_cpumask(next));
 		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
 
-		VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) ==
-			  next->context.ctx_id);
+		choose_new_asid(next, next_tlb_gen, &new_asid, &need_flush);
 
-		this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id,
-			       next->context.ctx_id);
-		this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
-			       next_tlb_gen);
-		this_cpu_write(cpu_tlbstate.loaded_mm, next);
-		write_cr3(__pa(next->pgd));
+		if (need_flush) {
+			this_cpu_write(cpu_tlbstate.ctxs[new_asid].ctx_id,
+				       next->context.ctx_id);
+			this_cpu_write(cpu_tlbstate.ctxs[new_asid].tlb_gen,
+				       next_tlb_gen);
+			write_cr3(__pa(next->pgd) | new_asid);
+			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH,
+					TLB_FLUSH_ALL);
+		} else {
+			/* The new ASID is already up to date. */
+			write_cr3(__pa(next->pgd) | new_asid | CR3_NOFLUSH);
+			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, 0);
+		}
 
-		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
+		this_cpu_write(cpu_tlbstate.loaded_mm, next);
+		this_cpu_write(cpu_tlbstate.loaded_mm_asid, new_asid);
 	}
 
 	load_mm_cr4(next);
@@ -170,6 +215,7 @@ static void flush_tlb_func_common(const struct flush_tlb_info *f,
 				  bool local, enum tlb_flush_reason reason)
 {
 	struct mm_struct *loaded_mm = this_cpu_read(cpu_tlbstate.loaded_mm);
+	u32 loaded_mm_asid = this_cpu_read(cpu_tlbstate.loaded_mm_asid);
 
 	/*
 	 * Our memory ordering requirement is that any TLB fills that
@@ -179,12 +225,12 @@ static void flush_tlb_func_common(const struct flush_tlb_info *f,
 	 * atomic64_read operation won't be reordered by the compiler.
 	 */
 	u64 mm_tlb_gen = atomic64_read(&loaded_mm->context.tlb_gen);
-	u64 local_tlb_gen = this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen);
+	u64 local_tlb_gen = this_cpu_read(cpu_tlbstate.ctxs[loaded_mm_asid].tlb_gen);
 
 	/* This code cannot presently handle being reentered. */
 	VM_WARN_ON(!irqs_disabled());
 
-	VM_WARN_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) !=
+	VM_WARN_ON(this_cpu_read(cpu_tlbstate.ctxs[loaded_mm_asid].ctx_id) !=
 		   loaded_mm->context.ctx_id);
 
 	if (!cpumask_test_cpu(smp_processor_id(), mm_cpumask(loaded_mm))) {
@@ -256,7 +302,7 @@ static void flush_tlb_func_common(const struct flush_tlb_info *f,
 	}
 
 	/* Both paths above update our state to mm_tlb_gen. */
-	this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen, mm_tlb_gen);
+	this_cpu_write(cpu_tlbstate.ctxs[loaded_mm_asid].tlb_gen, mm_tlb_gen);
 }
 
 static void flush_tlb_func_local(void *info, enum tlb_flush_reason reason)
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
