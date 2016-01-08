Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id BFB2F828E9
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:15:56 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id q63so16322964pfb.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:15:56 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id w17si7957791pfi.241.2016.01.08.15.15.55
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 15:15:55 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 13/13] x86/mm: Try to preserve old TLB entries using PCID
Date: Fri,  8 Jan 2016 15:15:31 -0800
Message-Id: <c4125ff6333c97d3ce00e5886b809b7c20594585.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

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

In particular, we use PCIDs 1-7 for recently-used mms and we reserve
PCID 0 for swapper_pg_dir and for PCID-unaware CR3 users (e.g. EFI).
Nothing ever switches to PCID 0 without flushing PCID 0 non-global
pages, so PCID 0 conflicts won't cause problems.

This also leaves the door open for UDEREF-style address space
switching: the kernel will use PCID 0, and exits could simply switch
back.  (As a practical matter, an in-tree implementation of that
feature would probably forego the full syscall fast path and just
invoke some or all of switch_mm in prepare_exit_to_usermode.)

This seems to save about 100ns on context switches between mms.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/mmu.h      |   7 +-
 arch/x86/include/asm/tlbflush.h |  18 ++++
 arch/x86/kernel/cpu/common.c    |   4 +
 arch/x86/kernel/ldt.c           |   2 +
 arch/x86/kernel/process_64.c    |   2 +
 arch/x86/mm/tlb.c               | 195 +++++++++++++++++++++++++++++++++++++---
 6 files changed, 213 insertions(+), 15 deletions(-)

diff --git a/arch/x86/include/asm/mmu.h b/arch/x86/include/asm/mmu.h
index 55234d5e7160..adb958d41bde 100644
--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -5,10 +5,13 @@
 #include <linux/mutex.h>
 
 /*
- * The x86 doesn't have a mmu context, but
- * we put the segment information here.
+ * x86 has an MMU context if PCID is enabled, and x86 also has arch-specific
+ * MMU state beyond what lives in mm_struct.
  */
 typedef struct {
+	/* See arch/x86/mm/tlb.c for details. */
+	struct cpumask pcid_live_cpus;
+
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
 	struct ldt_struct *ldt;
 #endif
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 32e3d8769a22..407c6f5dd4a6 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -56,6 +56,13 @@ static inline void invpcid_flush_all_nonglobals(void)
 #define CR3_PCID_MASK 0ull
 #endif
 
+#ifdef CONFIG_SMP
+extern void zap_old_pcids(void);
+#else
+/* Until PCID is implemented for !SMP, there's nothing to do. */
+static inline void zap_old_pcids(void) {}
+#endif
+
 #ifdef CONFIG_PARAVIRT
 #include <asm/paravirt.h>
 #else
@@ -195,6 +202,8 @@ static inline void __flush_tlb_all(void)
 		__flush_tlb_global();
 	else
 		__flush_tlb();
+
+	zap_old_pcids();
 }
 
 static inline void __flush_tlb_one(unsigned long addr)
@@ -238,6 +247,7 @@ static inline void flush_tlb_all(void)
 {
 	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 	__flush_tlb_all();
+	zap_old_pcids();
 }
 
 static inline void flush_tlb(void)
@@ -254,6 +264,8 @@ static inline void flush_tlb_mm(struct mm_struct *mm)
 {
 	if (mm == current->active_mm)
 		__flush_tlb_up();
+	else
+		zap_old_pcids();
 }
 
 static inline void flush_tlb_page(struct vm_area_struct *vma,
@@ -261,6 +273,8 @@ static inline void flush_tlb_page(struct vm_area_struct *vma,
 {
 	if (vma->vm_mm == current->active_mm)
 		__flush_tlb_one(addr);
+	else
+		zap_old_pcids();
 }
 
 static inline void flush_tlb_range(struct vm_area_struct *vma,
@@ -268,6 +282,8 @@ static inline void flush_tlb_range(struct vm_area_struct *vma,
 {
 	if (vma->vm_mm == current->active_mm)
 		__flush_tlb_up();
+	else
+		zap_old_pcids();
 }
 
 static inline void flush_tlb_mm_range(struct mm_struct *mm,
@@ -275,6 +291,8 @@ static inline void flush_tlb_mm_range(struct mm_struct *mm,
 {
 	if (mm == current->active_mm)
 		__flush_tlb_up();
+	else
+		zap_old_pcids();
 }
 
 static inline void native_flush_tlb_others(const struct cpumask *cpumask,
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 7e1fc53a4ba5..00bdf5806566 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -953,6 +953,10 @@ static void identify_cpu(struct cpuinfo_x86 *c)
 	setup_smep(c);
 	setup_smap(c);
 
+	/* Enable PCID if available. */
+	if (cpu_has(c, X86_FEATURE_PCID))
+		cr4_set_bits(X86_CR4_PCIDE);
+
 	/*
 	 * The vendor-specific functions might have changed features.
 	 * Now we do "generic changes."
diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
index 6acc9dd91f36..3d73c0ddc773 100644
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -109,6 +109,8 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 	struct mm_struct *old_mm;
 	int retval = 0;
 
+	cpumask_clear(&mm->context.pcid_live_cpus);
+
 	mutex_init(&mm->context.lock);
 	old_mm = current->mm;
 	if (!old_mm) {
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index e835d263a33b..2cdb3ba715e6 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -578,6 +578,8 @@ long do_arch_prctl(struct task_struct *task, int code, unsigned long addr)
 		break;
 	}
 
+		__flush_tlb();
+		invpcid_flush_all_nonglobals();
 	default:
 		ret = -EINVAL;
 		break;
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 9790c9338e52..eb84240b8c92 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -28,6 +28,92 @@
  *	Implement flush IPI by CALL_FUNCTION_VECTOR, Alex Shi
  */
 
+/*
+ * An x86 PCID is what everyone else calls an ASID.  TLB entries on each
+ * CPU are tagged with a PCID, and the current CR3 value stores a PCID.
+ * Switching CR3 can change the PCID and can optionally flush all TLB
+ * entries associated with the new PCID.
+ *
+ * The PCID is 12 bits, but we don't use anywhere near that many.
+ *
+ * The guiding principle of this code is that TLB entries that have
+ * survived more than a small number of context switches are mostly
+ * useless, so we don't try very hard not to evict them.
+ *
+ * PCID 0 is used for swapper_pg_dir and for any other special PGDs that
+ * are loaded directly by PCID-naive users of load_cr3.  (This includes
+ * UEFI runtime services, etc.)  Note that we never switch to PCID 0 with
+ * the preserve flag set -- the only TLB entries with PCID == 0 that are
+ * worth preserving have the global flag set.
+ *
+ * PCIDs 1 through NR_PCIDS are used for real user mms.
+ */
+
+#define NR_DYNAMIC_PCIDS 7
+
+struct pcid_cpu_entry {
+	const struct mm_struct *mm;
+};
+
+struct pcid_cpu_state {
+	/* This entire data structure fits in one cache line. */
+	struct pcid_cpu_entry pcids[NR_DYNAMIC_PCIDS];	/* starts with PCID 1 */
+	unsigned long next_pcid_minus_two;
+};
+
+static DEFINE_PER_CPU_ALIGNED(struct pcid_cpu_state, pcid_cpu_state);
+
+/*
+ * Allocate and return a fresh PCID for mm on this CPU.
+ */
+static unsigned long allocate_pcid(const struct mm_struct *mm)
+{
+	unsigned long pcid;
+
+	pcid = this_cpu_add_return(pcid_cpu_state.next_pcid_minus_two, 1) + 1;
+	if (pcid > NR_DYNAMIC_PCIDS) {
+		pcid = 1;
+		this_cpu_write(pcid_cpu_state.next_pcid_minus_two, 0);
+	}
+
+	this_cpu_write(pcid_cpu_state.pcids[pcid-1].mm, mm);
+
+	/*
+	 * We don't bother setting our cpu's bit on pcid_live_cpus.  Any
+	 * remote CPU that needs to shoot down one of our TLB entries will
+	 * do it via IPI because we're all the way live.  We'll take care
+	 * of pcid_live_cpus when we remove ourselves from mm_cpumask.
+	 */
+	return pcid;
+}
+
+/*
+ * Finds the PCID for the given pgd on this cpu.  If that PCID was last
+ * used by this mm, the high bit will be set in the return value.  Otherwise
+ * we claim ownership of the PCID and return the PCID with the high bit
+ * clear.
+ *
+ * This function must not be called if pgd has never been loaded on this
+ * CPU.  Otherwise we might return a PCID allocated to a dead mm whose pgd
+ * page has been reused.
+ */
+static unsigned long choose_pcid(struct mm_struct *mm)
+{
+	unsigned long pcid;
+
+	if (!static_cpu_has(X86_FEATURE_PCID))
+		return 0;
+
+	if (cpumask_test_cpu(smp_processor_id(), &mm->context.pcid_live_cpus)) {
+		for (pcid = 0; pcid < NR_DYNAMIC_PCIDS; pcid++) {
+			if (this_cpu_read(pcid_cpu_state.pcids[pcid].mm) == mm)
+				return (pcid + 1) | (1UL << 63);
+		}
+	}
+
+	return allocate_pcid(mm);
+}
+
 #ifdef CONFIG_SMP
 
 struct flush_tlb_info {
@@ -37,6 +123,55 @@ struct flush_tlb_info {
 };
 
 /*
+ * This effectively invalidates non-global mappings belonging to non-current
+ * PCIDs on the calling CPU.  Rather than doing NR_DYNAMIC_PCIDS-1 INVPCIDs,
+ * it invalidates the mm-to-PCID mappings.
+ */
+void zap_old_pcids(void)
+{
+	struct mm_struct *active_mm;
+	int i;
+
+	if (!static_cpu_has(X86_FEATURE_PCID))
+		return;
+
+	active_mm = this_cpu_read(cpu_tlbstate.active_mm);
+
+	for (i = 0; i < NR_DYNAMIC_PCIDS; i++)
+		if (this_cpu_read(pcid_cpu_state.pcids[i].mm) != active_mm)
+			this_cpu_write(pcid_cpu_state.pcids[i].mm, NULL);
+}
+EXPORT_SYMBOL(zap_old_pcids);
+
+static void zap_local_inactive_mm(struct mm_struct *mm)
+{
+	int i;
+
+	if (!static_cpu_has(X86_FEATURE_PCID))
+		return;
+
+	for (i = 0; i < NR_DYNAMIC_PCIDS; i++) {
+		if (this_cpu_read(pcid_cpu_state.pcids[i].mm) == mm) {
+			this_cpu_write(pcid_cpu_state.pcids[i].mm, NULL);
+			return;
+		}
+	}
+}
+
+static void stop_tlbflush_ipis(int cpu, struct mm_struct *mm)
+{
+	/*
+	 * Stop flush ipis for the previous mm.  First mark us live in
+	 * the PCID cache.  We need our store to pcid_live_cpus to
+	 * happen before remote CPUs stop sending us IPIs; the barrier
+	 * here synchronizes with the barrier in flush_tlb_remote.
+	 */
+	cpumask_set_cpu(cpu, &mm->context.pcid_live_cpus);
+	smp_mb__before_atomic();
+	cpumask_clear_cpu(cpu, mm_cpumask(mm));
+}
+
+/*
  * We cannot call mmdrop() because we are in interrupt context,
  * instead update mm->cpu_vm_mask.
  */
@@ -46,7 +181,7 @@ void leave_mm(int cpu)
 	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
 		BUG();
 	if (cpumask_test_cpu(cpu, mm_cpumask(active_mm))) {
-		cpumask_clear_cpu(cpu, mm_cpumask(active_mm));
+		stop_tlbflush_ipis(cpu, active_mm);
 		load_cr3(swapper_pg_dir);
 		/*
 		 * This gets called in the idle path where RCU
@@ -63,6 +198,7 @@ void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 	       struct task_struct *tsk)
 {
 	unsigned cpu = smp_processor_id();
+	unsigned long pcid;
 
 	if (likely(prev != next)) {
 #ifdef CONFIG_SMP
@@ -76,9 +212,6 @@ void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 		 *
 		 * This logic has an ordering constraint:
 		 *
-		 *  CPU 0: Write to a PTE for 'next'
-		 *  CPU 0: load bit 1 in mm_cpumask.  if nonzero, send IPI.
-		 *  CPU 1: set bit 1 in next's mm_cpumask
 		 *  CPU 1: load from the PTE that CPU 0 writes (implicit)
 		 *
 		 * We need to prevent an outcome in which CPU 1 observes
@@ -97,12 +230,14 @@ void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 		 * serializing and thus acts as a full barrier.
 		 *
 		 */
-		load_cr3(next->pgd);
 
-		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
+		pcid = choose_pcid(next);
+		write_cr3(__pa(next->pgd) | pcid);
 
-		/* Stop flush ipis for the previous mm */
-		cpumask_clear_cpu(cpu, mm_cpumask(prev));
+		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH,
+				(pcid & (1ULL << 63)) ? 0 : TLB_FLUSH_ALL);
+
+		stop_tlbflush_ipis(cpu, prev);
 
 		/* Load per-mm CR4 state */
 		load_mm_cr4(next);
@@ -146,9 +281,18 @@ void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 			 * As above, this is a barrier that forces
 			 * TLB repopulation to be ordered after the
 			 * store to mm_cpumask.
+
+			 *
+			 * XXX: speedup possibility: if we end up preserving
+			 * PCID data, then the write_cr3 is a no-op.
 			 */
-			load_cr3(next->pgd);
-			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
+			pcid = choose_pcid(next);
+			write_cr3(__pa(next->pgd) | pcid);
+
+			trace_tlb_flush(
+				TLB_FLUSH_ON_TASK_SWITCH,
+				(pcid & (1ULL << 63)) ? 0 : TLB_FLUSH_ALL);
+;
 			load_mm_cr4(next);
 			load_mm_ldt(next);
 		}
@@ -203,8 +347,24 @@ static void flush_tlb_func(void *info)
 
 	inc_irq_stat(irq_tlb_count);
 
-	if (f->flush_mm != this_cpu_read(cpu_tlbstate.active_mm))
+	/*
+	 * After all relevant CPUs call flush_tlb_func, pcid_live_cpus
+	 * will be clear.  That's not enough, though: if the mm we're
+	 * targeting isn't active, we won't directly flush the TLB, but
+	 * we need to guarantee that the mm won't be reactivated and
+	 * therefore reinstate stale entries prior to cpumask_clear.
+	 *
+	 * Solve this problem by brute force: if we don't flush the TLB
+	 * directly, zap the PCID mapping.  (We zap it using
+	 * pcid_cpu_state instead of pcid_live_cpus to avoid excessive
+	 * cacheline bounding.)
+	 */
+
+	if (f->flush_mm != this_cpu_read(cpu_tlbstate.active_mm)) {
+		zap_local_inactive_mm(f->flush_mm);
 		return;
+	}
+
 	if (!f->flush_end)
 		f->flush_end = f->flush_start + PAGE_SIZE;
 
@@ -224,9 +384,10 @@ static void flush_tlb_func(void *info)
 			}
 			trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, nr_pages);
 		}
-	} else
+	} else {
 		leave_mm(smp_processor_id());
-
+		zap_local_inactive_mm(f->flush_mm);
+	}
 }
 
 void native_flush_tlb_others(const struct cpumask *cpumask,
@@ -259,6 +420,14 @@ static void propagate_tlb_flush(unsigned int this_cpu,
 {
 	if (cpumask_any_but(mm_cpumask(mm), this_cpu) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
+	/*
+	 * Synchronize with barrier in stop_tlbflush_ipis; cpumask_clear
+	 * must not be overridden by the pcid_live_cpus write in
+	 * stop_tlbflush_ipis unless we sent an IPI.
+	 */
+	smp_wmb();
+
+	cpumask_clear(&mm->context.pcid_live_cpus);
 }
 
 void flush_tlb_current_task(void)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
