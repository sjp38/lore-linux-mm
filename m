Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F23E56B0317
	for <linux-mm@kvack.org>; Mon, 15 May 2017 21:18:10 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o25so125303866pgc.1
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:18:10 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id h62si12118021pge.75.2017.05.15.18.18.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 18:18:10 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id w69so17864767pfk.1
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:18:10 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v1 09/11] x86/kasan: support on-demand shadow mapping
Date: Tue, 16 May 2017 10:16:47 +0900
Message-Id: <1494897409-14408-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Enable on-demand shadow mapping in x86.

x86 uses separate per-cpu kernel stack for interrupt/exception context.
We need to populate shadow memory for them before they are used.

And, there are two possible problems due to stable TLB entry when using
on-demand shadow mapping since we cannot fully flush the TLB in
some context and we need to handle these situation.

1. write protection fault: original shadow memory for the page is
mapped by black shadow page with write protection in default. When
this page is allocated for a slab or kernel stack, new mapping is
established but stable TLB isn't fully flushed. So, when marking
the shadow value happen in other cpu, write protection fault will happen.
Thanks to x86's spurious fault handling, stale TLB will be invalidated
after one exception fault so there is no actual problem in this case.

2. false-positive in KASAN shadow check: With above situation, if someone
try to check shadow memory, wrong value would be read due to stale
TLB entry. We need to recheck with flushing the stale TLB in this
case. It is implemented in arch_kasan_recheck_prepare() and
generic KASAN check function.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 arch/x86/include/asm/kasan.h     |  2 +
 arch/x86/include/asm/processor.h |  4 ++
 arch/x86/kernel/cpu/common.c     |  4 +-
 arch/x86/kernel/setup_percpu.c   |  2 +
 arch/x86/mm/kasan_init_64.c      | 82 +++++++++++++++++++++++++++++++++++++++-
 5 files changed, 90 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/kasan.h b/arch/x86/include/asm/kasan.h
index cfa63c7..91a29ed 100644
--- a/arch/x86/include/asm/kasan.h
+++ b/arch/x86/include/asm/kasan.h
@@ -29,9 +29,11 @@
 #ifdef CONFIG_KASAN
 void __init kasan_early_init(void);
 void __init kasan_init(void);
+void __init kasan_init_late(void);
 #else
 static inline void kasan_early_init(void) { }
 static inline void kasan_init(void) { }
+static inline void kasan_init_late(void) { }
 #endif
 
 #endif
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 3cada99..516c972 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -377,6 +377,10 @@ DECLARE_INIT_PER_CPU(irq_stack_union);
 
 DECLARE_PER_CPU(char *, irq_stack_ptr);
 DECLARE_PER_CPU(unsigned int, irq_count);
+
+#define EXCEPTION_STKSZ_TOTAL ((N_EXCEPTION_STACKS - 1) * EXCEPTION_STKSZ + DEBUG_STKSZ)
+DECLARE_PER_CPU(char, exception_stacks[EXCEPTION_STKSZ_TOTAL]);
+
 extern asmlinkage void ignore_sysret(void);
 #else	/* X86_64 */
 #ifdef CONFIG_CC_STACKPROTECTOR
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index c8b3987..d16c65a 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -1328,8 +1328,8 @@ static const unsigned int exception_stack_sizes[N_EXCEPTION_STACKS] = {
 	  [DEBUG_STACK - 1]			= DEBUG_STKSZ
 };
 
-static DEFINE_PER_CPU_PAGE_ALIGNED(char, exception_stacks
-	[(N_EXCEPTION_STACKS - 1) * EXCEPTION_STKSZ + DEBUG_STKSZ]);
+DEFINE_PER_CPU_PAGE_ALIGNED(char, exception_stacks
+	[EXCEPTION_STKSZ_TOTAL]);
 
 /* May not be marked __init: used by software suspend */
 void syscall_init(void)
diff --git a/arch/x86/kernel/setup_percpu.c b/arch/x86/kernel/setup_percpu.c
index 10edd1e..cb3aeef 100644
--- a/arch/x86/kernel/setup_percpu.c
+++ b/arch/x86/kernel/setup_percpu.c
@@ -21,6 +21,7 @@
 #include <asm/cpumask.h>
 #include <asm/cpu.h>
 #include <asm/stackprotector.h>
+#include <asm/kasan.h>
 
 DEFINE_PER_CPU_READ_MOSTLY(int, cpu_number);
 EXPORT_PER_CPU_SYMBOL(cpu_number);
@@ -309,4 +310,5 @@ void __init setup_per_cpu_areas(void)
 			swapper_pg_dir     + KERNEL_PGD_BOUNDARY,
 			min(KERNEL_PGD_PTRS, KERNEL_PGD_BOUNDARY));
 #endif
+	kasan_init_late();
 }
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 136b73d..a185668 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -7,6 +7,7 @@
 #include <linux/sched.h>
 #include <linux/sched/task.h>
 #include <linux/vmalloc.h>
+#include <linux/memblock.h>
 
 #include <asm/e820/types.h>
 #include <asm/tlbflush.h>
@@ -15,6 +16,12 @@
 extern pgd_t early_level4_pgt[PTRS_PER_PGD];
 extern struct range pfn_mapped[E820_MAX_ENTRIES];
 
+static __init void *early_alloc(size_t size, int node)
+{
+	return memblock_virt_alloc_try_nid(size, size, __pa(MAX_DMA_ADDRESS),
+					BOOTMEM_ALLOC_ACCESSIBLE, node);
+}
+
 static int __init map_range(struct range *range, bool pshadow)
 {
 	unsigned long start;
@@ -38,7 +45,9 @@ static int __init map_range(struct range *range, bool pshadow)
 	start = (unsigned long)kasan_mem_to_shadow((void *)start);
 	end = (unsigned long)kasan_mem_to_shadow((void *)end);
 
-	return vmemmap_populate(start, end + 1, NUMA_NO_NODE);
+	kasan_populate_shadow((void *)start, (void *)end + 1,
+						false, true);
+	return 0;
 }
 
 static void __init clear_pgds(unsigned long start,
@@ -240,11 +249,80 @@ void __init kasan_init(void)
 	pr_info("KernelAddressSanitizer initialized\n");
 }
 
+static void __init kasan_map_shadow_late(unsigned long start,
+					unsigned long end)
+{
+	unsigned long addr;
+	unsigned char *page;
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep;
+	pte_t pte;
+
+	for (addr = start; addr < end; addr += PAGE_SIZE) {
+		pgd = pgd_offset_k(addr);
+		p4d = p4d_offset(pgd, addr);
+		pud = pud_offset(p4d, addr);
+		pmd = pmd_offset(pud, addr);
+		ptep = pte_offset_kernel(pmd, addr);
+
+		page = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
+		pte = pfn_pte(PFN_DOWN(__pa(page)), PAGE_KERNEL);
+		set_pte_at(&init_mm, addr, ptep, pte);
+	}
+}
+
+static void __init __kasan_init_late(unsigned long start, unsigned long end)
+{
+	unsigned long shadow_start, shadow_end;
+
+	shadow_start = (unsigned long)kasan_mem_to_shadow((void *)start);
+	shadow_start = round_down(shadow_start, PAGE_SIZE);
+	shadow_end = (unsigned long)kasan_mem_to_shadow((void *)end);
+	shadow_end = ALIGN(shadow_end, PAGE_SIZE);
+
+	kasan_map_shadow_late(shadow_start, shadow_end);
+	kasan_poison_pshadow((void *)start, ALIGN(end, PAGE_SIZE) - start);
+}
+
+void __init kasan_init_late(void)
+{
+	int cpu;
+	unsigned long start, end;
+
+	for_each_possible_cpu(cpu) {
+		end   = (unsigned long)per_cpu(irq_stack_ptr, cpu);
+		start = end - IRQ_STACK_SIZE;
+
+		__kasan_init_late(start, end);
+
+		start = (unsigned long)per_cpu(exception_stacks, cpu);
+		end = start + sizeof(exception_stacks);
+
+		__kasan_init_late(start, end);
+	}
+}
+
+/*
+ * We cannot flush the TLBs in other cpus due to deadlock
+ * so just flush the TLB in current cpu. Accessing stale TLB
+ * entry would cause following two problem and we can handle them.
+ *
+ * 1. write protection fault: It will be handled by spurious
+ * fault handler. It will invalidate stale TLB entry.
+ * 2. false-positive in KASAN shadow check: It will be
+ * handled by re-check with flushing local TLB.
+ */
 void arch_kasan_map_shadow(unsigned long s, unsigned long e)
 {
+	__flush_tlb_all();
 }
 
 bool arch_kasan_recheck_prepare(unsigned long addr, size_t size)
 {
-	return false;
+	__flush_tlb_all();
+
+	return true;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
