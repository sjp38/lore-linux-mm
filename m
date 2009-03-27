Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5486B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:10:30 -0400 (EDT)
Message-ID: <49CD37B8.4070109@goop.org>
Date: Fri, 27 Mar 2009 13:31:52 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: [PATCH 1/2] x86/mm: maintain a percpu "in get_user_pages_fast" flag
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Avi Kivity <avi@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

get_user_pages_fast() relies on cross-cpu tlb flushes being a barrier
between clearing and setting a pte, and before freeing a pagetable page.
It usually does this by disabling interrupts to hold off IPIs, but
some tlb flush implementations don't use IPIs for tlb flushes, and
must use another mechanism.

In this change, add in_gup_cpumask, which is a cpumask of cpus currently
performing a get_user_pages_fast traversal of a pagetable.  A cross-cpu
tlb flush function can use this to determine whether it should hold-off
on the flush until the gup_fast has finished.

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

diff --git a/arch/x86/include/asm/mmu.h b/arch/x86/include/asm/mmu.h
index 80a1dee..b2e23e2 100644
--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -23,4 +23,6 @@ static inline void leave_mm(int cpu)
 }
 #endif
 
+extern cpumask_var_t in_gup_cpumask;
+
 #endif /* _ASM_X86_MMU_H */
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index be54176..a937b46 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -4,13 +4,17 @@
  * Copyright (C) 2008 Nick Piggin
  * Copyright (C) 2008 Novell Inc.
  */
+#include <linux/init.h>
 #include <linux/sched.h>
+#include <linux/cpumask.h>
 #include <linux/mm.h>
 #include <linux/vmstat.h>
 #include <linux/highmem.h>
 
 #include <asm/pgtable.h>
 
+cpumask_var_t in_gup_cpumask;
+
 static inline pte_t gup_get_pte(pte_t *ptep)
 {
 #ifndef CONFIG_X86_PAE
@@ -227,6 +231,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	unsigned long next;
 	pgd_t *pgdp;
 	int nr = 0;
+	int cpu;
 
 	start &= PAGE_MASK;
 	addr = start;
@@ -255,6 +260,10 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	 * address down to the the page and take a ref on it.
 	 */
 	local_irq_disable();
+
+	cpu = smp_processor_id();
+	cpumask_set_cpu(cpu, in_gup_cpumask);
+
 	pgdp = pgd_offset(mm, addr);
 	do {
 		pgd_t pgd = *pgdp;
@@ -265,6 +274,9 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 		if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
 			goto slow;
 	} while (pgdp++, addr = next, addr != end);
+
+	cpumask_clear_cpu(cpu, in_gup_cpumask);
+
 	local_irq_enable();
 
 	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
@@ -274,6 +286,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 		int ret;
 
 slow:
+		cpumask_clear_cpu(cpu, in_gup_cpumask);
 		local_irq_enable();
 slow_irqon:
 		/* Try to get the remaining pages with get_user_pages */
@@ -296,3 +309,9 @@ slow_irqon:
 		return ret;
 	}
 }
+
+static int __init gup_mask_init(void)
+{
+	return alloc_cpumask_var(&in_gup_cpumask, GFP_KERNEL);
+}
+core_initcall(gup_mask_init);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
