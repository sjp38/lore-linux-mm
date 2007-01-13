From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:48:35 +1100
Message-Id: <20070113024835.29682.19560.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 4/5] Abstract assembler lookup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH IA64 04
 * Create ivt.h to hold page table assembler lookup function.
 * Abstract implementation dependent assembler.
 NB: Not actually calling the defined lookup .macro for the default
 page table here.  We will probably get rid of this and have just #ifdefed
 it out at the moment.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 arch/ia64/kernel/ivt.S         |    7 +++++
 arch/ia64/mm/init.c            |    2 +
 include/asm-ia64/ivt.h         |   56 +++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/mmu_context.h |    2 +
 4 files changed, 67 insertions(+)
Index: linux-2.6.20-rc1/arch/ia64/kernel/ivt.S
===================================================================
--- linux-2.6.20-rc1.orig/arch/ia64/kernel/ivt.S	2006-12-23 21:02:16.115531000 +1100
+++ linux-2.6.20-rc1/arch/ia64/kernel/ivt.S	2006-12-23 21:05:07.849355000 +1100
@@ -51,6 +51,7 @@
 #include <asm/thread_info.h>
 #include <asm/unistd.h>
 #include <asm/errno.h>
+#include <asm/ivt.h>
 
 #if 1
 # define PSR_DEFAULT_BITS	psr.ac
@@ -102,12 +103,14 @@
 	 *	- the faulting virtual address uses unimplemented address bits
 	 *	- the faulting virtual address has no valid page table mapping
 	 */
+
 	mov r16=cr.ifa				// get address that caused the TLB miss
 #ifdef CONFIG_HUGETLB_PAGE
 	movl r18=PAGE_SHIFT
 	mov r25=cr.itir
 #endif
 	;;
+#ifdef CONFIG_PT_DEFAULT
 	rsm psr.dt				// use physical addressing for data
 	mov r31=pr				// save the predicate registers
 	mov r19=IA64_KR(PT_BASE)		// get page table base address
@@ -166,6 +169,7 @@
 	;;
 (p7)	cmp.eq.or.andcm p6,p7=r20,r0		// was pmd_present(*pmd) == NULL?
 	dep r21=r19,r20,3,(PAGE_SHIFT-3)	// r21=pte_offset(pmd,addr)
+#endif
 	;;
 (p7)	ld8 r18=[r21]				// read *pte
 	mov r19=cr.isr				// cr.isr bit 32 tells us if this is an insn miss
@@ -435,6 +439,7 @@
 	 *
 	 * Clobbered:	b0, r18, r19, r21, r22, psr.dt (cleared)
 	 */
+#ifdef CONFIG_PT_DEFAULT
 	rsm psr.dt				// switch to using physical data addressing
 	mov r19=IA64_KR(PT_BASE)		// get the page table base address
 	shl r21=r16,3				// shift bit 60 into sign bit
@@ -485,6 +490,8 @@
 	;;
 (p7)	cmp.eq.or.andcm p6,p7=r17,r0		// was pmd_present(*pmd) == NULL?
 	dep r17=r19,r17,3,(PAGE_SHIFT-3)	// r17=pte_offset(pmd,addr);
+#endif
+	/* find_pte r16,r17,p6,p7 */
 (p6)	br.cond.spnt page_fault
 	mov b0=r30
 	br.sptk.many b0				// return to continuation point
Index: linux-2.6.20-rc1/include/asm-ia64/ivt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc1/include/asm-ia64/ivt.h	2006-12-23 21:05:07.849355000 +1100
@@ -0,0 +1,56 @@
+#ifdef CONFIG_PT_DEFAULT
+
+.macro find_pte va, ppte, p1, p2
+	rsm psr.dt				// switch to using physical data addressing
+	mov r19=IA64_KR(PT_BASE)		// get the page table base address
+	shl r21=\va,3				// shift bit 60 into sign bit
+	mov r18=cr.itir
+	;;
+	shr.u \ppte=\va,61			// get the region number into ppte
+	extr.u r18=r18,2,6			// get the faulting page size
+	;;
+	cmp.eq \p1,\p2=5,\ppte			// is faulting address in region 5?
+	add r22=-PAGE_SHIFT,r18			// adjustment for hugetlb address
+	add r18=PGDIR_SHIFT-PAGE_SHIFT,r18
+	;;
+	shr.u r22=\va,r22
+	shr.u r18=\va,r18
+(\p2)	dep \ppte=\ppte,r19,(PAGE_SHIFT-3),3	// put region number bits in place
+
+	srlz.d
+	LOAD_PHYSICAL(\p1, r19, swapper_pg_dir)	// region 5 is rooted at swapper_pg_dir
+
+	.pred.rel "mutex", \p1, \p2
+(\p1)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT
+(\p2)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3
+	;;
+(\p1)	dep \ppte=r18,r19,3,(PAGE_SHIFT-3)	// ppte=pgd_offset for region 5
+(\p2)	dep \ppte=r18,\ppte,3,(PAGE_SHIFT-3)-3	// ppte=pgd_offset for region[0-4]
+	cmp.eq \p2,\p1=0,r21			// unused address bits all zeroes?
+#ifdef CONFIG_PGTABLE_4
+	shr.u r18=r22,PUD_SHIFT			// shift pud index into position
+#else
+	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
+#endif
+	;;
+	ld8 \ppte=[\ppte]			// get *pgd (may be 0)
+	;;
+(\p2)	cmp.eq \p1,\p2=\ppte,r0			// was pgd_present(*pgd) == NULL?
+	dep \ppte=r18,\ppte,3,(PAGE_SHIFT-3)	// ppte=p[u|m]d_offset(pgd,addr)
+	;;
+#ifdef CONFIG_PGTABLE_4
+(\p2)	ld8 \ppte=[\ppte]			// get *pud (may be 0)
+	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
+	;;
+(\p2)	cmp.eq.or.andcm \p1,\p2=\ppte,r0	// was pud_present(*pud) == NULL?
+	dep \ppte=r18,\ppte,3,(PAGE_SHIFT-3)	// ppte=pmd_offset(pud,addr)
+	;;
+#endif
+(\p2)	ld8 \ppte=[\ppte]			// get *pmd (may be 0)
+	shr.u r19=r22,PAGE_SHIFT		// shift pte index into position
+	;;
+(\p2)	cmp.eq.or.andcm \p1,\p2=\ppte,r0	// was pmd_present(*pmd) == NULL?
+	dep \ppte=r19,\ppte,3,(PAGE_SHIFT-3)	// ppte=pte_offset(pmd,addr)
+.endm
+
+#endif
Index: linux-2.6.20-rc1/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.20-rc1.orig/arch/ia64/mm/init.c	2006-12-23 21:05:07.437149000 +1100
+++ linux-2.6.20-rc1/arch/ia64/mm/init.c	2006-12-23 21:05:07.853357000 +1100
@@ -597,9 +597,11 @@
 	int i;
 	static struct kcore_list kcore_mem, kcore_vmem, kcore_kernel;
 
+#ifdef CONFIG_PT_DEFAULT
 	BUG_ON(PTRS_PER_PGD * sizeof(pgd_t) != PAGE_SIZE);
 	BUG_ON(PTRS_PER_PMD * sizeof(pmd_t) != PAGE_SIZE);
 	BUG_ON(PTRS_PER_PTE * sizeof(pte_t) != PAGE_SIZE);
+#endif
 
 #ifdef CONFIG_PCI
 	/*
Index: linux-2.6.20-rc1/include/asm-ia64/mmu_context.h
===================================================================
--- linux-2.6.20-rc1.orig/include/asm-ia64/mmu_context.h	2006-12-23 21:04:57.420143000 +1100
+++ linux-2.6.20-rc1/include/asm-ia64/mmu_context.h	2006-12-23 21:05:07.857359000 +1100
@@ -191,7 +191,9 @@
 	 * We may get interrupts here, but that's OK because interrupt
 	 * handlers cannot touch user-space.
 	 */
+#ifdef CONFIG_PT_DEFAULT
 	ia64_set_kr(IA64_KR_PT_BASE, __pa(next->page_table.pgd));
+#endif
 	activate_context(next);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
