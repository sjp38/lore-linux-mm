From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:48:14 +1100
Message-Id: <20070113024814.29682.37247.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 29/29] Tweak i386 arch dependent files to work with PTI
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 29 i386
 * Defines default page table config option: PT_DEFAULT in Kconfig.debug
 to appear in kernel hacking.
 * Adjusts arch dependent files referring to the pgd in the mm_struct
 to do it via the new generic page table type (no pgd in mm_struct anymore).

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 arch/i386/Kconfig.debug        |    9 +++++++++
 arch/i386/kernel/init_task.c   |    2 +-
 arch/i386/mm/fault.c           |    2 +-
 arch/i386/mm/pageattr.c        |    3 ++-
 include/asm-i386/mmu_context.h |    4 ++--
 include/asm-i386/pgtable.h     |    2 +-
 6 files changed, 16 insertions(+), 6 deletions(-)
 arch/i386/Kconfig.debug        |    9 +++++++++
 arch/i386/kernel/init_task.c   |    2 +-
 arch/i386/mm/fault.c           |    2 +-
 arch/i386/mm/pageattr.c        |    3 ++-
 include/asm-i386/mmu_context.h |    4 ++--
 include/asm-i386/pgtable.h     |    2 +-
 6 files changed, 16 insertions(+), 6 deletions(-)
PATCH 06-i386
 * Defines default page table config option: PT_DEFAULT in Kconfig.debug
 to appear in kernel hacking.
 * Adjusts arch dependent files referring to the pgd in the mm_struct
 to do it via the new generic page table type (no pgd in mm_struct anymore).

 arch/i386/Kconfig.debug        |    9 +++++++++
 arch/i386/kernel/init_task.c   |    2 +-
 arch/i386/mm/fault.c           |    2 +-
 arch/i386/mm/pageattr.c        |    3 ++-
 include/asm-i386/mmu_context.h |    4 ++--
 include/asm-i386/pgtable.h     |    2 +-
 6 files changed, 16 insertions(+), 6 deletions(-)

Index: linux-2.6.20-rc3/include/asm-i386/mmu_context.h
===================================================================
--- linux-2.6.20-rc3.orig/include/asm-i386/mmu_context.h	2007-01-01 11:53:20.000000000 +1100
+++ linux-2.6.20-rc3/include/asm-i386/mmu_context.h	2007-01-06 02:53:38.000000000 +1100
@@ -38,7 +38,7 @@
 		cpu_set(cpu, next->cpu_vm_mask);
 
 		/* Re-load page tables */
-		load_cr3(next->pgd);
+		load_cr3(next->page_table.pgd);
 
 		/*
 		 * load the LDT, if the LDT is different:
@@ -55,7 +55,7 @@
 			/* We were in lazy tlb mode and leave_mm disabled 
 			 * tlb flush IPI delivery. We must reload %cr3.
 			 */
-			load_cr3(next->pgd);
+			load_cr3(next->page_table.pgd);
 			load_LDT_nolock(&next->context);
 		}
 	}
Index: linux-2.6.20-rc3/arch/i386/mm/pageattr.c
===================================================================
--- linux-2.6.20-rc3.orig/arch/i386/mm/pageattr.c	2007-01-01 11:53:20.000000000 +1100
+++ linux-2.6.20-rc3/arch/i386/mm/pageattr.c	2007-01-06 02:53:38.000000000 +1100
@@ -8,10 +8,11 @@
 #include <linux/highmem.h>
 #include <linux/module.h>
 #include <linux/slab.h>
+#include <linux/pt.h>
 #include <asm/uaccess.h>
 #include <asm/processor.h>
 #include <asm/tlbflush.h>
-#include <asm/pgalloc.h>
+//#include <asm/pgalloc.h>
 #include <asm/sections.h>
 
 static DEFINE_SPINLOCK(cpa_lock);
Index: linux-2.6.20-rc3/include/asm-i386/pgtable.h
===================================================================
--- linux-2.6.20-rc3.orig/include/asm-i386/pgtable.h	2007-01-01 11:53:20.000000000 +1100
+++ linux-2.6.20-rc3/include/asm-i386/pgtable.h	2007-01-06 02:53:38.000000000 +1100
@@ -415,7 +415,7 @@
  * pgd_offset() returns a (pgd_t *)
  * pgd_index() is used get the offset into the pgd page's array of pgd_t's;
  */
-#define pgd_offset(mm, address) ((mm)->pgd+pgd_index(address))
+#define pgd_offset(mm, address) ((mm)->page_table.pgd+pgd_index(address))
 
 /*
  * a shortcut which implies the use of the kernel's pgd, instead
Index: linux-2.6.20-rc3/arch/i386/kernel/init_task.c
===================================================================
--- linux-2.6.20-rc3.orig/arch/i386/kernel/init_task.c	2007-01-01 11:53:20.000000000 +1100
+++ linux-2.6.20-rc3/arch/i386/kernel/init_task.c	2007-01-06 02:53:38.000000000 +1100
@@ -5,9 +5,9 @@
 #include <linux/init_task.h>
 #include <linux/fs.h>
 #include <linux/mqueue.h>
+#include <linux/pt.h>
 
 #include <asm/uaccess.h>
-#include <asm/pgtable.h>
 #include <asm/desc.h>
 
 static struct fs_struct init_fs = INIT_FS;
Index: linux-2.6.20-rc3/arch/i386/Kconfig.debug
===================================================================
--- linux-2.6.20-rc3.orig/arch/i386/Kconfig.debug	2007-01-01 11:53:20.000000000 +1100
+++ linux-2.6.20-rc3/arch/i386/Kconfig.debug	2007-01-06 02:53:38.000000000 +1100
@@ -6,6 +6,15 @@
 
 source "lib/Kconfig.debug"
 
+choice
+	prompt "Page table selection"
+	default DEFAULT-PT
+
+config  PT_DEFAULT
+	bool "PT_DEFAULT"
+
+endchoice
+
 config EARLY_PRINTK
 	bool "Early printk" if EMBEDDED && DEBUG_KERNEL
 	default y
Index: linux-2.6.20-rc3/arch/i386/mm/fault.c
===================================================================
--- linux-2.6.20-rc3.orig/arch/i386/mm/fault.c	2007-01-06 05:02:32.000000000 +1100
+++ linux-2.6.20-rc3/arch/i386/mm/fault.c	2007-01-06 05:03:24.000000000 +1100
@@ -254,7 +254,7 @@
 	pmd_t *pmd, *pmd_k;
 
 	pgd += index;
-	pgd_k = init_mm.pgd + index;
+	pgd_k = init_mm.page_table.pgd + index;
 
 	if (!pgd_present(*pgd_k))
 		return NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
