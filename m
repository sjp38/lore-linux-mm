Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 191316B03A1
	for <linux-mm@kvack.org>; Sun,  7 May 2017 08:39:07 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m13so47316406pgd.12
        for <linux-mm@kvack.org>; Sun, 07 May 2017 05:39:07 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id g3si10032141plb.105.2017.05.07.05.39.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 May 2017 05:39:06 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 04/10] x86/mm: Pass flush_tlb_info to flush_tlb_others() etc
Date: Sun,  7 May 2017 05:38:33 -0700
Message-Id: <51ec06f28360a1cc505649acaf0c9db905824115.1494160201.git.luto@kernel.org>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Sasha Levin <sasha.levin@oracle.com>

Rather than passing all the contents of flush_tlb_info to
flush_tlb_others(), pass a pointer to the structure directly. For
consistency, this also removes the unnecessary cpu parameter from
uv_flush_tlb_others() to make its signature match the other
*flush_tlb_others() functions.

This serves two purposes:

 - It will dramatically simplify future patches that change struct
   flush_tlb_info, which I'm planning to do.

 - struct flush_tlb_info is an adequate description of what to do
   for a local flush, too, so by reusing it we can remove duplicated
   code between local and remove flushes in a future patch.

Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/paravirt.h       |  6 ++--
 arch/x86/include/asm/paravirt_types.h |  5 ++-
 arch/x86/include/asm/tlbflush.h       | 19 ++++++-----
 arch/x86/include/asm/uv/uv.h          |  9 ++---
 arch/x86/mm/tlb.c                     | 64 +++++++++++++++++------------------
 arch/x86/platform/uv/tlb_uv.c         |  8 ++---
 arch/x86/xen/mmu.c                    | 10 +++---
 7 files changed, 58 insertions(+), 63 deletions(-)

diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 55fa56fe4e45..9a15739d9f4b 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -312,11 +312,9 @@ static inline void __flush_tlb_single(unsigned long addr)
 }
 
 static inline void flush_tlb_others(const struct cpumask *cpumask,
-				    struct mm_struct *mm,
-				    unsigned long start,
-				    unsigned long end)
+				    const struct flush_tlb_info *info)
 {
-	PVOP_VCALL4(pv_mmu_ops.flush_tlb_others, cpumask, mm, start, end);
+	PVOP_VCALL2(pv_mmu_ops.flush_tlb_others, cpumask, info);
 }
 
 static inline int paravirt_pgd_alloc(struct mm_struct *mm)
diff --git a/arch/x86/include/asm/paravirt_types.h b/arch/x86/include/asm/paravirt_types.h
index 7465d6fe336f..cb976bab6299 100644
--- a/arch/x86/include/asm/paravirt_types.h
+++ b/arch/x86/include/asm/paravirt_types.h
@@ -51,6 +51,7 @@ struct mm_struct;
 struct desc_struct;
 struct task_struct;
 struct cpumask;
+struct flush_tlb_info;
 
 /*
  * Wrapper type for pointers to code which uses the non-standard
@@ -223,9 +224,7 @@ struct pv_mmu_ops {
 	void (*flush_tlb_kernel)(void);
 	void (*flush_tlb_single)(unsigned long addr);
 	void (*flush_tlb_others)(const struct cpumask *cpus,
-				 struct mm_struct *mm,
-				 unsigned long start,
-				 unsigned long end);
+				 const struct flush_tlb_info *info);
 
 	/* Hooks for allocating and freeing a pagetable top-level */
 	int  (*pgd_alloc)(struct mm_struct *mm);
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index df71e3f2fe4d..6d236c1aff89 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -220,12 +220,18 @@ static inline void __flush_tlb_one(unsigned long addr)
  *  - flush_tlb_page(vma, vmaddr) flushes one page
  *  - flush_tlb_range(vma, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
- *  - flush_tlb_others(cpumask, mm, start, end) flushes TLBs on other cpus
+ *  - flush_tlb_others(cpumask, info) flushes TLBs on other cpus
  *
  * ..but the i386 has somewhat limited tlb flushing capabilities,
  * and page-granular flushes are available only on i486 and up.
  */
 
+struct flush_tlb_info {
+	struct mm_struct *mm;
+	unsigned long start;
+	unsigned long end;
+};
+
 #ifndef CONFIG_SMP
 
 /* "_up" is for UniProcessor.
@@ -279,9 +285,7 @@ static inline void flush_tlb_mm_range(struct mm_struct *mm,
 }
 
 static inline void native_flush_tlb_others(const struct cpumask *cpumask,
-					   struct mm_struct *mm,
-					   unsigned long start,
-					   unsigned long end)
+					   const struct flush_tlb_info *info)
 {
 }
 
@@ -317,8 +321,7 @@ static inline void flush_tlb_page(struct vm_area_struct *vma, unsigned long a)
 }
 
 void native_flush_tlb_others(const struct cpumask *cpumask,
-				struct mm_struct *mm,
-				unsigned long start, unsigned long end);
+			     const struct flush_tlb_info *info);
 
 #define TLBSTATE_OK	1
 #define TLBSTATE_LAZY	2
@@ -340,8 +343,8 @@ extern void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch);
 #endif	/* SMP */
 
 #ifndef CONFIG_PARAVIRT
-#define flush_tlb_others(mask, mm, start, end)	\
-	native_flush_tlb_others(mask, mm, start, end)
+#define flush_tlb_others(mask, info)	\
+	native_flush_tlb_others(mask, info)
 #endif
 
 #endif /* _ASM_X86_TLBFLUSH_H */
diff --git a/arch/x86/include/asm/uv/uv.h b/arch/x86/include/asm/uv/uv.h
index 6686820feae9..d2db4517930c 100644
--- a/arch/x86/include/asm/uv/uv.h
+++ b/arch/x86/include/asm/uv/uv.h
@@ -15,10 +15,7 @@ extern void uv_cpu_init(void);
 extern void uv_nmi_init(void);
 extern void uv_system_init(void);
 extern const struct cpumask *uv_flush_tlb_others(const struct cpumask *cpumask,
-						 struct mm_struct *mm,
-						 unsigned long start,
-						 unsigned long end,
-						 unsigned int cpu);
+						 const struct flush_tlb_info *info);
 
 #else	/* X86_UV */
 
@@ -28,8 +25,8 @@ static inline int is_uv_hubless(void)	{ return 0; }
 static inline void uv_cpu_init(void)	{ }
 static inline void uv_system_init(void)	{ }
 static inline const struct cpumask *
-uv_flush_tlb_others(const struct cpumask *cpumask, struct mm_struct *mm,
-		    unsigned long start, unsigned long end, unsigned int cpu)
+uv_flush_tlb_others(const struct cpumask *cpumask,
+		    const struct flush_tlb_info *info)
 { return cpumask; }
 
 #endif	/* X86_UV */
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 743e4c6b4529..776469cc54e0 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -30,12 +30,6 @@
 
 #ifdef CONFIG_SMP
 
-struct flush_tlb_info {
-	struct mm_struct *flush_mm;
-	unsigned long flush_start;
-	unsigned long flush_end;
-};
-
 /*
  * We cannot call mmdrop() because we are in interrupt context,
  * instead update mm->cpu_vm_mask.
@@ -229,11 +223,11 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
  */
 static void flush_tlb_func(void *info)
 {
-	struct flush_tlb_info *f = info;
+	const struct flush_tlb_info *f = info;
 
 	inc_irq_stat(irq_tlb_count);
 
-	if (f->flush_mm && f->flush_mm != this_cpu_read(cpu_tlbstate.active_mm))
+	if (f->mm && f->mm != this_cpu_read(cpu_tlbstate.active_mm))
 		return;
 
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
@@ -243,15 +237,15 @@ static void flush_tlb_func(void *info)
 		return;
 	}
 
-	if (f->flush_end == TLB_FLUSH_ALL) {
+	if (f->end == TLB_FLUSH_ALL) {
 		local_flush_tlb();
 		trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, TLB_FLUSH_ALL);
 	} else {
 		unsigned long addr;
 		unsigned long nr_pages =
-			(f->flush_end - f->flush_start) / PAGE_SIZE;
-		addr = f->flush_start;
-		while (addr < f->flush_end) {
+			(f->end - f->start) / PAGE_SIZE;
+		addr = f->start;
+		while (addr < f->end) {
 			__flush_tlb_single(addr);
 			addr += PAGE_SIZE;
 		}
@@ -260,33 +254,27 @@ static void flush_tlb_func(void *info)
 }
 
 void native_flush_tlb_others(const struct cpumask *cpumask,
-				 struct mm_struct *mm, unsigned long start,
-				 unsigned long end)
+			     const struct flush_tlb_info *info)
 {
-	struct flush_tlb_info info;
-
-	info.flush_mm = mm;
-	info.flush_start = start;
-	info.flush_end = end;
-
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH);
-	if (end == TLB_FLUSH_ALL)
+	if (info->end == TLB_FLUSH_ALL)
 		trace_tlb_flush(TLB_REMOTE_SEND_IPI, TLB_FLUSH_ALL);
 	else
 		trace_tlb_flush(TLB_REMOTE_SEND_IPI,
-				(end - start) >> PAGE_SHIFT);
+				(info->end - info->start) >> PAGE_SHIFT);
 
 	if (is_uv_system()) {
 		unsigned int cpu;
 
 		cpu = smp_processor_id();
-		cpumask = uv_flush_tlb_others(cpumask, mm, start, end, cpu);
+		cpumask = uv_flush_tlb_others(cpumask, info);
 		if (cpumask)
 			smp_call_function_many(cpumask, flush_tlb_func,
-								&info, 1);
+					       (void *)info, 1);
 		return;
 	}
-	smp_call_function_many(cpumask, flush_tlb_func, &info, 1);
+	smp_call_function_many(cpumask, flush_tlb_func,
+			       (void *)info, 1);
 }
 
 /*
@@ -305,6 +293,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 				unsigned long end, unsigned long vmflag)
 {
 	unsigned long addr;
+	struct flush_tlb_info info;
 	/* do a global flush by default */
 	unsigned long base_pages_to_flush = TLB_FLUSH_ALL;
 
@@ -347,15 +336,20 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 	}
 	trace_tlb_flush(TLB_LOCAL_MM_SHOOTDOWN, base_pages_to_flush);
 out:
+	info.mm = mm;
 	if (base_pages_to_flush == TLB_FLUSH_ALL) {
-		start = 0UL;
-		end = TLB_FLUSH_ALL;
+		info.start = 0UL;
+		info.end = TLB_FLUSH_ALL;
+	} else {
+		info.start = start;
+		info.end = end;
 	}
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
-		flush_tlb_others(mm_cpumask(mm), mm, start, end);
+		flush_tlb_others(mm_cpumask(mm), &info);
 	preempt_enable();
 }
 
+
 static void do_flush_tlb_all(void *info)
 {
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
@@ -376,7 +370,7 @@ static void do_kernel_range_flush(void *info)
 	unsigned long addr;
 
 	/* flush range by one by one 'invlpg' */
-	for (addr = f->flush_start; addr < f->flush_end; addr += PAGE_SIZE)
+	for (addr = f->start; addr < f->end; addr += PAGE_SIZE)
 		__flush_tlb_single(addr);
 }
 
@@ -389,14 +383,20 @@ void flush_tlb_kernel_range(unsigned long start, unsigned long end)
 		on_each_cpu(do_flush_tlb_all, NULL, 1);
 	} else {
 		struct flush_tlb_info info;
-		info.flush_start = start;
-		info.flush_end = end;
+		info.start = start;
+		info.end = end;
 		on_each_cpu(do_kernel_range_flush, &info, 1);
 	}
 }
 
 void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
 {
+	struct flush_tlb_info info = {
+		.mm = NULL,
+		.start = 0UL,
+		.end = TLB_FLUSH_ALL,
+	};
+
 	int cpu = get_cpu();
 
 	if (cpumask_test_cpu(cpu, &batch->cpumask)) {
@@ -406,7 +406,7 @@ void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
 	}
 
 	if (cpumask_any_but(&batch->cpumask, cpu) < nr_cpu_ids)
-		flush_tlb_others(&batch->cpumask, NULL, 0, TLB_FLUSH_ALL);
+		flush_tlb_others(&batch->cpumask, &info);
 	cpumask_clear(&batch->cpumask);
 
 	put_cpu();
diff --git a/arch/x86/platform/uv/tlb_uv.c b/arch/x86/platform/uv/tlb_uv.c
index f25982cdff90..018af012e646 100644
--- a/arch/x86/platform/uv/tlb_uv.c
+++ b/arch/x86/platform/uv/tlb_uv.c
@@ -1109,11 +1109,9 @@ static int set_distrib_bits(struct cpumask *flush_mask, struct bau_control *bcp,
  * done.  The returned pointer is valid till preemption is re-enabled.
  */
 const struct cpumask *uv_flush_tlb_others(const struct cpumask *cpumask,
-						struct mm_struct *mm,
-						unsigned long start,
-						unsigned long end,
-						unsigned int cpu)
+					  const struct flush_tlb_info *info)
 {
+	unsigned int cpu = smp_processor_id();
 	int locals = 0;
 	int remotes = 0;
 	int hubs = 0;
@@ -1170,7 +1168,7 @@ const struct cpumask *uv_flush_tlb_others(const struct cpumask *cpumask,
 
 	record_send_statistics(stat, locals, hubs, remotes, bau_desc);
 
-	if (!end || (end - start) <= PAGE_SIZE)
+	if (!info->end || (info->end - info->start) <= PAGE_SIZE)
 		bau_desc->payload.address = start;
 	else
 		bau_desc->payload.address = TLB_FLUSH_ALL;
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index f226038a39ca..894daefd6958 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -1427,8 +1427,7 @@ static void xen_flush_tlb_single(unsigned long addr)
 }
 
 static void xen_flush_tlb_others(const struct cpumask *cpus,
-				 struct mm_struct *mm, unsigned long start,
-				 unsigned long end)
+				 const struct flush_tlb_info *info)
 {
 	struct {
 		struct mmuext_op op;
@@ -1440,7 +1439,7 @@ static void xen_flush_tlb_others(const struct cpumask *cpus,
 	} *args;
 	struct multicall_space mcs;
 
-	trace_xen_mmu_flush_tlb_others(cpus, mm, start, end);
+	trace_xen_mmu_flush_tlb_others(cpus, info->mm, info->start, info->end);
 
 	if (cpumask_empty(cpus))
 		return;		/* nothing to do */
@@ -1454,9 +1453,10 @@ static void xen_flush_tlb_others(const struct cpumask *cpus,
 	cpumask_clear_cpu(smp_processor_id(), to_cpumask(args->mask));
 
 	args->op.cmd = MMUEXT_TLB_FLUSH_MULTI;
-	if (end != TLB_FLUSH_ALL && (end - start) <= PAGE_SIZE) {
+	if (info->end != TLB_FLUSH_ALL &&
+	    (info->end - info->start) <= PAGE_SIZE) {
 		args->op.cmd = MMUEXT_INVLPG_MULTI;
-		args->op.arg1.linear_addr = start;
+		args->op.arg1.linear_addr = info->start;
 	}
 
 	MULTI_mmuext_op(mcs.mc, &args->op, 1, NULL, DOMID_SELF);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
