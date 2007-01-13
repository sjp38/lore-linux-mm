From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:49:07 +1100
Message-Id: <20070113024907.29682.79438.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 5/12] Alternate page table implementation cont...
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH GPT 05
 * Adds IA64 GPT assembler lookup into ivt.h
 * Adds other arch dependent implementation for GPT (parallels how
 its done for default page table).

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 arch/ia64/kernel/ivt.S         |    4 +-
 arch/ia64/kernel/setup.c       |    4 ++
 include/asm-ia64/ivt.h         |   77 +++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/mmu_context.h |    3 +
 include/asm-ia64/pgalloc-gpt.h |   18 +++++++++
 include/asm-ia64/pgalloc.h     |    4 ++
 include/asm-ia64/pt-gpt.h      |   40 +++++++++++++++++++++
 include/asm-ia64/pt.h          |    4 ++
 8 files changed, 153 insertions(+), 1 deletion(-)
Index: linux-2.6.20-rc1/include/asm-ia64/pt-gpt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc1/include/asm-ia64/pt-gpt.h	2007-01-03 12:43:01.693030000 +1100
@@ -0,0 +1,40 @@
+#ifndef _ASM_IA64_GPT_H
+#define _ASM_IA64_GPT_H 1
+
+#include <linux/bootmem.h>
+#include <linux/pt.h>
+
+/* Create kernel page table */
+static inline void create_kernel_page_table(void)
+{
+	init_mm.page_table = gpt_node_invalid_init();
+}
+
+/* Lookup the kernel page table */
+static inline pte_t *lookup_page_table_k(unsigned long address)
+{
+	return lookup_page_table(&init_mm, address, NULL);
+}
+
+/* Lookup the kernel page table */
+static inline pte_t *lookup_page_table_k2(unsigned long *address)
+{
+	panic("Unimplemented");
+	return NULL;
+}
+
+/* Build the kernel page table */
+static inline pte_t *build_page_table_k(unsigned long address)
+{
+	return build_page_table(&init_mm, address, NULL);
+}
+
+/* Builds the kernel page table from bootmem (before kernel memory allocation
+ * comes on line) */
+static inline pte_t *build_page_table_k_bootmem(unsigned long address, int _node)
+{
+	return build_page_table(&init_mm, address, NULL);
+}
+
+
+#endif
Index: linux-2.6.20-rc1/include/asm-ia64/pt.h
===================================================================
--- linux-2.6.20-rc1.orig/include/asm-ia64/pt.h	2007-01-03 12:35:16.310729000 +1100
+++ linux-2.6.20-rc1/include/asm-ia64/pt.h	2007-01-03 12:40:56.437030000 +1100
@@ -5,6 +5,10 @@
 #include <asm/pt-default.h>
 #endif
 
+#ifdef CONFIG_GPT
+#include <asm/pt-gpt.h>
+#endif
+
 void create_kernel_page_table(void);
 
 pte_t *build_page_table_k(unsigned long address);
Index: linux-2.6.20-rc1/include/asm-ia64/pgalloc-gpt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc1/include/asm-ia64/pgalloc-gpt.h	2007-01-03 12:40:56.441030000 +1100
@@ -0,0 +1,18 @@
+/**
+ *  include/asm-ia64/ptalloc-gpt.h
+ *
+ *  Copyright (C) 2005 - 2006 University of New South Wales, Australia
+ *      Adam 'WeirdArms' Wiggins <awiggins@cse.unsw.edu.au>,
+ *      Paul Davies <pauld@cse.unsw.edu.au>.
+ */
+
+#ifndef _ASM_IA64_PGALLOC_GPT_H
+#define _ASM_IA64_PGALLOC_GPT_H
+
+#define GPT_SPECIAL 1
+#define GPT_NORMAL  2
+
+extern int gpt_memsrc;
+
+
+#endif /* !_ASM_IA64_PGALLOC_GPT_H */
Index: linux-2.6.20-rc1/include/asm-ia64/pgalloc.h
===================================================================
--- linux-2.6.20-rc1.orig/include/asm-ia64/pgalloc.h	2007-01-03 12:35:16.310729000 +1100
+++ linux-2.6.20-rc1/include/asm-ia64/pgalloc.h	2007-01-03 12:40:56.441030000 +1100
@@ -81,4 +81,8 @@
 #include <asm/pgalloc-default.h>
 #endif
 
+#ifdef CONFIG_GPT
+#include <asm/pgalloc-gpt.h>
+#endif
+
 #endif				/* _ASM_IA64_PGALLOC_H */
Index: linux-2.6.20-rc1/arch/ia64/kernel/setup.c
===================================================================
--- linux-2.6.20-rc1.orig/arch/ia64/kernel/setup.c	2007-01-03 12:35:16.310729000 +1100
+++ linux-2.6.20-rc1/arch/ia64/kernel/setup.c	2007-01-03 12:40:56.441030000 +1100
@@ -53,6 +53,7 @@
 #include <asm/page.h>
 #include <asm/patch.h>
 #include <asm/pgtable.h>
+#include <asm/pgalloc.h>
 #include <asm/processor.h>
 #include <asm/sal.h>
 #include <asm/sections.h>
@@ -548,6 +549,9 @@
 	platform_setup(cmdline_p);
 	create_kernel_page_table();
 	paging_init();
+#ifdef CONFIG_GPT
+	gpt_memsrc = GPT_NORMAL;
+#endif
 }
 
 /*
Index: linux-2.6.20-rc1/include/asm-ia64/ivt.h
===================================================================
--- linux-2.6.20-rc1.orig/include/asm-ia64/ivt.h	2007-01-03 12:35:16.310729000 +1100
+++ linux-2.6.20-rc1/include/asm-ia64/ivt.h	2007-01-03 12:40:56.441030000 +1100
@@ -54,3 +54,80 @@
 .endm
 
 #endif
+
+#ifdef CONFIG_GPT
+
+/*
+ * FIND_PTE
+ * Walks the page table to find a PTE
+ * @va,		register holding virtual address
+ * @ppte, 	register with pointer to page table entry
+ * @ok,		predicate set if found
+ * @fail,      	predicate set if !found
+ */
+
+#define tmp             r20     /* tmp val to work out key */
+#define pnode           \ppte   /* pointer to node         */
+#define guard           r20     /* lower node word         */
+#define key             r21     /* lookup key              */
+#define size            r22     /* size of node level      */
+#define multiplier      r23
+#define inc             r23     /* inc = multiplier        */
+#define cmp_value       r24     /* cmp val with guard      */
+#define length          r25     /* guard length            */
+#define shift           r26     /* justify guard shift     */
+#define type            r27     /* node type               */
+#define level           r27     /* higher node word.       */
+#define guard2          r18
+#define internal        p8      /* Internal node           */
+#define recurse         p9
+
+.macro find_pte va, ppte, fail, ok
+	;;
+        rsm psr.dt              /* switch to using physical data addressing. */
+        mov pnode = IA64_KR(CURRENT_MM)   /* Load pointer to tasks GPT root. */
+        shr.u tmp = \va, 61                       /* Pull out region number. */
+        ;;
+        cmp.eq \ok, p0=5, tmp  /* Compare if region number is kernel region. */
+        ;;
+        srlz.d                             /* Don't remove, clarify purpose. */
+        LOAD_PHYSICAL(\ok, pnode, init_mm) /* If kernel region, use init_mm. */
+        mov key = \va
+        ;;
+.F1:
+/*0 M */ld8.acq guard = [pnode], 8               /* Load first word of node. */
+        ;;
+/*1 M */xor cmp_value = guard, key          /* Compare guard and key's MSBs. */
+/*1 I0*/extr.u size = guard, 8, 4                      /* Extract level size */
+/*1 M */and length = 63, guard                      /* Extract guard length. */
+/*1 I */tbit.nz internal, p0 = guard, 6           /* Test for internal node. */
+        ;;
+/*2 I */(internal) sub multiplier = 64, size /* Prep key for level indexing. */
+/*2 M */sub shift = 64, length    /* Prep guard/key shift from guard length. */
+/*2 M */(internal) ld8.acq level = [pnode], -8 /* Get pointer to next level. */
+/*2 I */(internal) shl key = key, length             /* Strip guard from key */
+        ;;
+/*3 M */(internal) ld8 guard2 = [pnode]   /* Load guard to check for update. */
+/*3 I */(internal) shr.u inc = key, multiplier     /* Calculate level index. */
+/*3 I */shr.u cmp_value = cmp_value, shift     /* Clear out none guard bits. */
+/*3 M */(internal) cmp.ne.unc recurse, \fail = level, r0   /* Level updated? */
+        ;;
+/*4 M */(internal) cmp.eq.and.orcm recurse, \fail = guard, guard2/* Changed? */
+/*4 I */(internal) shladd pnode = inc, 4, level       /* Point to next node. */
+/*4 M */(internal) cmp.eq.and.orcm recurse, \fail = cmp_value, r0  /* Match? */
+/*4 I */(internal) shl key = key, size               /* strip level from va. */
+/*4 B */(recurse) br.cond.dptk .F1            /* Get next node or exit loop. */
+        ;;
+.F2:
+        extr.u type = guard, 6, 2                       /* Extract node type */
+        cmp.eq \ok, p0 = r0, r0
+        ;;
+        (\fail) cmp.eq p0, \ok = r0, r0
+        ;;
+        (\ok) cmp.eq \ok, \fail = 2, type /* Did we terminated on a leaf node. */
+        ;;
+        (\ok) cmp.eq \ok, \fail = cmp_value, r0 /* FIX! */   /* Check guard. */
+        ;;
+.endm
+
+#endif
Index: linux-2.6.20-rc1/arch/ia64/kernel/ivt.S
===================================================================
--- linux-2.6.20-rc1.orig/arch/ia64/kernel/ivt.S	2007-01-03 12:35:16.310729000 +1100
+++ linux-2.6.20-rc1/arch/ia64/kernel/ivt.S	2007-01-03 12:40:56.445030000 +1100
@@ -490,8 +490,10 @@
 	;;
 (p7)	cmp.eq.or.andcm p6,p7=r17,r0		// was pmd_present(*pmd) == NULL?
 	dep r17=r19,r17,3,(PAGE_SHIFT-3)	// r17=pte_offset(pmd,addr);
+#endif		
+#ifdef CONFIG_GPT
+	find_pte r16,r17,p6,p7
 #endif
-	/* find_pte r16,r17,p6,p7 */
 (p6)	br.cond.spnt page_fault
 	mov b0=r30
 	br.sptk.many b0				// return to continuation point
Index: linux-2.6.20-rc1/include/asm-ia64/mmu_context.h
===================================================================
--- linux-2.6.20-rc1.orig/include/asm-ia64/mmu_context.h	2007-01-03 12:35:16.310729000 +1100
+++ linux-2.6.20-rc1/include/asm-ia64/mmu_context.h	2007-01-03 12:40:56.445030000 +1100
@@ -194,6 +194,9 @@
 #ifdef CONFIG_PT_DEFAULT
 	ia64_set_kr(IA64_KR_PT_BASE, __pa(next->page_table.pgd));
 #endif
+#ifdef CONFIG_GPT
+	ia64_set_kr(IA64_KR_CURRENT_MM, __pa(next));
+#endif
 	activate_context(next);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
