From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:46:11 +1100
Message-Id: <20070113024611.29682.41796.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 6/29] Tweak IA64 arch dependent files to work with PTI
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 06 ia64
 * Defines default page table config option: PT_DEFAULT in Kconfig.debug
 to appear in kernel hacking.
 * Adjusts arch dependent files referring to the pgd in the mm_struct
 to do so via the new generic page table type (no pgd in mm_struct anymore).

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 arch/ia64/Kconfig.debug        |    9 +++++++++
 arch/ia64/kernel/init_task.c   |    2 +-
 arch/ia64/mm/hugetlbpage.c     |    4 ++--
 include/asm-ia64/mmu_context.h |    2 +-
 include/asm-ia64/pgtable.h     |    4 ++--
 5 files changed, 15 insertions(+), 6 deletions(-)
Index: linux-2.6.20-rc4/include/asm-ia64/mmu_context.h
===================================================================
--- linux-2.6.20-rc4.orig/include/asm-ia64/mmu_context.h	2007-01-11 13:15:05.228780000 +1100
+++ linux-2.6.20-rc4/include/asm-ia64/mmu_context.h	2007-01-11 13:15:36.184250000 +1100
@@ -191,7 +191,7 @@
 	 * We may get interrupts here, but that's OK because interrupt
 	 * handlers cannot touch user-space.
 	 */
-	ia64_set_kr(IA64_KR_PT_BASE, __pa(next->pgd));
+	ia64_set_kr(IA64_KR_PT_BASE, __pa(next->page_table.pgd));
 	activate_context(next);
 }
 
Index: linux-2.6.20-rc4/include/asm-ia64/pgtable.h
===================================================================
--- linux-2.6.20-rc4.orig/include/asm-ia64/pgtable.h	2007-01-11 13:15:05.232782000 +1100
+++ linux-2.6.20-rc4/include/asm-ia64/pgtable.h	2007-01-11 13:15:36.184250000 +1100
@@ -346,13 +346,13 @@
 static inline pgd_t*
 pgd_offset (struct mm_struct *mm, unsigned long address)
 {
-	return mm->pgd + pgd_index(address);
+	return mm->page_table.pgd + pgd_index(address);
 }
 
 /* In the kernel's mapped region we completely ignore the region number
    (since we know it's in region number 5). */
 #define pgd_offset_k(addr) \
-	(init_mm.pgd + (((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)))
+	(init_mm.page_table.pgd + (((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)))
 
 /* Look up a pgd entry in the gate area.  On IA-64, the gate-area
    resides in the kernel-mapped segment, hence we use pgd_offset_k()
Index: linux-2.6.20-rc4/arch/ia64/kernel/init_task.c
===================================================================
--- linux-2.6.20-rc4.orig/arch/ia64/kernel/init_task.c	2007-01-11 13:15:05.232782000 +1100
+++ linux-2.6.20-rc4/arch/ia64/kernel/init_task.c	2007-01-11 13:15:36.188252000 +1100
@@ -12,9 +12,9 @@
 #include <linux/sched.h>
 #include <linux/init_task.h>
 #include <linux/mqueue.h>
+#include <linux/pt.h>
 
 #include <asm/uaccess.h>
-#include <asm/pgtable.h>
 
 static struct fs_struct init_fs = INIT_FS;
 static struct files_struct init_files = INIT_FILES;
Index: linux-2.6.20-rc4/arch/ia64/mm/hugetlbpage.c
===================================================================
--- linux-2.6.20-rc4.orig/arch/ia64/mm/hugetlbpage.c	2007-01-11 13:15:05.232782000 +1100
+++ linux-2.6.20-rc4/arch/ia64/mm/hugetlbpage.c	2007-01-11 13:16:53.160812000 +1100
@@ -16,8 +16,8 @@
 #include <linux/smp_lock.h>
 #include <linux/slab.h>
 #include <linux/sysctl.h>
+#include <linux/pt.h>
 #include <asm/mman.h>
-#include <asm/pgalloc.h>
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
@@ -136,7 +136,7 @@
 	if (REGION_NUMBER(ceiling) == RGN_HPAGE)
 		ceiling = htlbpage_to_page(ceiling);
 
-	free_pgd_range(tlb, addr, end, floor, ceiling);
+	free_pt_range(tlb, addr, end, floor, ceiling);
 }
 
 unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
Index: linux-2.6.20-rc4/arch/ia64/Kconfig.debug
===================================================================
--- linux-2.6.20-rc4.orig/arch/ia64/Kconfig.debug	2007-01-11 13:15:05.232782000 +1100
+++ linux-2.6.20-rc4/arch/ia64/Kconfig.debug	2007-01-11 13:15:36.192254000 +1100
@@ -3,6 +3,15 @@
 source "lib/Kconfig.debug"
 
 choice
+	prompt "Page table selection"
+	default DEFAULT-PT
+
+config  PT_DEFAULT
+	bool "PT_DEFAULT"
+
+endchoice
+
+choice
 	prompt "Physical memory granularity"
 	default IA64_GRANULE_64MB
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
