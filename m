From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 3 May 2006 17:42:29 +1000
Subject: Re: [RFC 1/3] LVHPT - Fault handler modifications
Message-ID: <20060503074229.GA4798@cse.unsw.EDU.AU>
References: <20060502052551.8990.16410.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU> <4t153d$t4guc@azsmga001.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4t153d$t4guc@azsmga001.ch.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 02, 2006 at 10:40:37AM -0700, Chen, Kenneth W wrote:
> I would like to experiment with a few algorithms for lvhpt and best thing
> to do in my opinion is to have parallel ivt.S (or ivt table to be precise).

Ok, I sent an email this morning which I think got dropped for size
(what is the posting limit?).  This is an update.

Below is another approach, dynamically creating ivt.S from a template
and input files with a script.  Below is only a partial patch in the
hope of it getting through the mail server; the full series is at

http://www.gelato.unsw.edu.au/~ianw/lvhpt/patches/v2

The long format handlers are then implemented without macros, etc, as per

http://www.gelato.unsw.edu.au/~ianw/lvhpt/patches/v2/ivt-long-format.patch

Any feedback on this approach is most welcome.

-i

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

---

 kernel/Makefile      |    5
 kernel/ivt-sfvhpt.in |  444 +++++++++++++++++
 kernel/ivt.S.in      | 1324 +++++++++++++++++++++++++++++++++++++++++++++++++++
 scripts/merge.py     |   58 ++
 4 files changed, 1831 insertions(+)

--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/scripts/merge.py	2006-05-03 14:24:54.000000000 +1000
@@ -0,0 +1,58 @@
+#!/usr/bin/env python2.4
+# nb. requires python2.4 for string templating
+#
+# Usage: merge.py output template code
+#
+# merge the code in 'code' into 'template', writing out to 'output'
+#
+# Anything between lines __begin_name__ and __end_name__ in 'code'
+# gets inserted into $name in 'template'.
+#
+# Ian Wienand <ianw@gelato.unsw.edu.au>
+#
+import os
+import sys
+from string import Template
+
+if len(sys.argv) != 4:
+    print "Usage: %s output template code" % sys.argv[0]
+    sys.exit(2)
+
+print "Merging %s and template %s to %s" % (sys.argv[2], sys.argv[3], sys.argv[1])
+
+# bring the code file into a dictionary
+# anything between lines __begin_name__ and __end_name__ goes into
+# a dictionary entry of name
+template_dictionary = {}
+am_processing = False
+current_template = ""
+current_template_name = ""
+for line in open(sys.argv[3], 'r').readlines():
+
+    if am_processing:
+        # if this line is the end, stop
+        # XXX check this end is actually the name we are processing
+        if line[:6] == "__end_":
+            template_dictionary[current_template_name] = current_template
+            am_processing = False
+            print "... done"
+            continue
+        # otherwise, add this line to the current template
+        current_template += line
+        continue
+    # if we got here, we are not processing
+    if line[:8] == "__begin_":
+        am_processing = True
+        current_template_name = line[8:-3] #newline
+        print "Processing %s" % (current_template_name),
+        current_template = ""
+        continue
+    # this is some random line
+    continue
+
+#now open the file where we put these templates
+template = Template(open(sys.argv[2],'r').read())
+
+#finally, substitute them all in
+output = open(sys.argv[1],'w')
+output.write(template.substitute(template_dictionary))
Index: linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/kernel/ivt.S.in
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/kernel/ivt.S.in	2006-05-03 15:52:55.000000000 +1000
@@ -0,0 +1,1324 @@
+/*
+ * arch/ia64/kernel/ivt.S
+ *
+ * Copyright (C) 1998-2001, 2003, 2005 Hewlett-Packard Co
+ *	Stephane Eranian <eranian@hpl.hp.com>
+ *	David Mosberger <davidm@hpl.hp.com>
+ * Copyright (C) 2000, 2002-2003 Intel Co
+ *	Asit Mallick <asit.k.mallick@intel.com>
+ *      Suresh Siddha <suresh.b.siddha@intel.com>
+ *      Kenneth Chen <kenneth.w.chen@intel.com>
+ *      Fenghua Yu <fenghua.yu@intel.com>
+ *
+ * 00/08/23 Asit Mallick <asit.k.mallick@intel.com> TLB handling for SMP
+ * 00/12/20 David Mosberger-Tang <davidm@hpl.hp.com> DTLB/ITLB handler now uses virtual PT.
+ */
+/*
+ * This file defines the interruption vector table used by the CPU.
+ * It does not include one entry per possible cause of interruption.
+ *
+ * The first 20 entries of the table contain 64 bundles each while the
+ * remaining 48 entries contain only 16 bundles each.
+ *
+ * The 64 bundles are used to allow inlining the whole handler for critical
+ * interruptions like TLB misses.
+ *
+ *  For each entry, the comment is as follows:
+ *
+ *		// 0x1c00 Entry 7 (size 64 bundles) Data Key Miss (12,51)
+ *  entry offset ----/     /         /                  /          /
+ *  entry number ---------/         /                  /          /
+ *  size of the entry -------------/                  /          /
+ *  vector name -------------------------------------/          /
+ *  interruptions triggering this vector ----------------------/
+ *
+ * The table is 32KB in size and must be aligned on 32KB boundary.
+ * (The CPU ignores the 15 lower bits of the address)
+ *
+ * Table is based upon EAS2.6 (Oct 1999)
+ */
+
+#include <linux/config.h>
+
+#include <asm/asmmacro.h>
+#include <asm/break.h>
+#include <asm/ia32.h>
+#include <asm/kregs.h>
+#include <asm/asm-offsets.h>
+#include <asm/pgtable.h>
+#include <asm/processor.h>
+#include <asm/ptrace.h>
+#include <asm/system.h>
+#include <asm/thread_info.h>
+#include <asm/unistd.h>
+#include <asm/errno.h>
+
+#if 1
+# define PSR_DEFAULT_BITS	psr.ac
+#else
+# define PSR_DEFAULT_BITS	0
+#endif
+
+#if 0
+  /*
+   * This lets you track the last eight faults that occurred on the CPU.  Make sure ar.k2 isn't
+   * needed for something else before enabling this...
+   */
+# define DBG_FAULT(i)	mov r16=ar.k2;;	shl r16=r16,8;;	add r16=(i),r16;;mov ar.k2=r16
+#else
+# define DBG_FAULT(i)
+#endif
+
+#include "minstate.h"
+
+#define FAULT(n)									\
+	mov r31=pr;									\
+	mov r19=n;;			/* prepare to save predicates */		\
+	br.sptk.many dispatch_to_fault_handler
+
+	.section .text.ivt,"ax"
+
+	.align 32768	// align on 32KB boundary
+	.global ia64_ivt
+ia64_ivt:
+/////////////////////////////////////////////////////////////////////////////////////////
+// 0x0000 Entry 0 (size 64 bundles) VHPT Translation (8,20,47)
+ENTRY(vhpt_miss)
+	DBG_FAULT(0)
+	/*
+	 * The VHPT vector is invoked when the TLB entry for the virtual page table
+	 * is missing.  This happens only as a result of a previous
+	 * (the "original") TLB miss, which may either be caused by an instruction
+	 * fetch or a data access (or non-access).
+	 *
+	 * What we do here is normal TLB miss handing for the _original_ miss,
+	 * followed by inserting the TLB entry for the virtual page table page
+	 * that the VHPT walker was attempting to access.  The latter gets
+	 * inserted as long as page table entry above pte level have valid
+	 * mappings for the faulting address.  The TLB entry for the original
+	 * miss gets inserted only if the pte entry indicates that the page is
+	 * present.
+	 *
+	 * do_page_fault gets invoked in the following cases:
+	 *	- the faulting virtual address uses unimplemented address bits
+	 *	- the faulting virtual address has no valid page table mapping
+	 */
+$vhpt_miss_handler
+END(vhpt_miss)
+
+	.org ia64_ivt+0x400
+/////////////////////////////////////////////////////////////////////////////////////////
+// 0x0400 Entry 1 (size 64 bundles) ITLB (21)
+ENTRY(itlb_miss)
+	DBG_FAULT(1)
+	/*
+	 * The ITLB handler accesses the PTE via the virtually mapped linear
+	 * page table.  If a nested TLB miss occurs, we switch into physical
+	 * mode, walk the page table, and then re-execute the PTE read and
+	 * go on normally after that.
+	 */
+$itlb_miss_handler
+END(itlb_miss)
+
+	.org ia64_ivt+0x0800
+/////////////////////////////////////////////////////////////////////////////////////////
+// 0x0800 Entry 2 (size 64 bundles) DTLB (9,48)
+ENTRY(dtlb_miss)
+	DBG_FAULT(2)
+	/*
+	 * The DTLB handler accesses the PTE via the virtually mapped linear
+	 * page table.  If a nested TLB miss occurs, we switch into physical
+	 * mode, walk the page table, and then re-execute the PTE read and
+	 * go on normally after that.
+	 */
+$dtlb_miss_handler
+END(dtlb_miss)
+
+	.org ia64_ivt+0x0c00
+/////////////////////////////////////////////////////////////////////////////////////////
+// 0x0c00 Entry 3 (size 64 bundles) Alt ITLB (19)
+ENTRY(alt_itlb_miss)
+	DBG_FAULT(3)
+	mov r16=cr.ifa		// get address that caused the TLB miss
+	movl r17=PAGE_KERNEL
+	mov r21=cr.ipsr
+	movl r19=(((1 << IA64_MAX_PHYS_BITS) - 1) & ~0xfff)
+	mov r31=pr
+	;;
+#ifdef CONFIG_DISABLE_VHPT
+	shr.u r22=r16,61			// get the region number into r21
+	;;
+	cmp.gt p8,p0=6,r22			// user mode
+	;;
+(p8)	thash r17=r16
+	;;
+(p8)	mov cr.iha=r17
+(p8)	mov r29=b0				// save b0
+(p8)	br.cond.dptk .itlb_fault
+#endif
+	extr.u r23=r21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl
+	and r19=r19,r16		// clear ed, reserved bits, and PTE control bits
+	shr.u r18=r16,57	// move address bit 61 to bit 4
+	;;
+	andcm r18=0x10,r18	// bit 4=~address-bit(61)
+	cmp.ne p8,p0=r0,r23	// psr.cpl != 0?
+	or r19=r17,r19		// insert PTE control bits into r19
+	;;
+	or r19=r19,r18		// set bit 4 (uncached) if the access was to region 6
+(p8)	br.cond.spnt page_fault
+	;;
+	itc.i r19		// insert the TLB entry
+	mov pr=r31,-1
+	rfi
+END(alt_itlb_miss)
+
+	.org ia64_ivt+0x1000
+/////////////////////////////////////////////////////////////////////////////////////////
+// 0x1000 Entry 4 (size 64 bundles) Alt DTLB (7,46)
+ENTRY(alt_dtlb_miss)
+	DBG_FAULT(4)
+	mov r16=cr.ifa		// get address that caused the TLB miss
+	movl r17=PAGE_KERNEL
+	mov r20=cr.isr
+	movl r19=(((1 << IA64_MAX_PHYS_BITS) - 1) & ~0xfff)
+	mov r21=cr.ipsr
+	mov r31=pr
+	;;
+#ifdef CONFIG_DISABLE_VHPT
+	shr.u r22=r16,61			// get the region number into r21
+	;;
+	cmp.gt p8,p0=6,r22			// access to region 0-5
+	;;
+(p8)	thash r17=r16
+	;;
+(p8)	mov cr.iha=r17
+(p8)	mov r29=b0				// save b0
+(p8)	br.cond.dptk dtlb_fault
+#endif
+	extr.u r23=r21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl
+	and r22=IA64_ISR_CODE_MASK,r20		// get the isr.code field
+	tbit.nz p6,p7=r20,IA64_ISR_SP_BIT	// is speculation bit on?
+	shr.u r18=r16,57			// move address bit 61 to bit 4
+	and r19=r19,r16				// clear ed, reserved bits, and PTE control bits
+	tbit.nz p9,p0=r20,IA64_ISR_NA_BIT	// is non-access bit on?
+	;;
+	andcm r18=0x10,r18	// bit 4=~address-bit(61)
+	cmp.ne p8,p0=r0,r23
+(p9)	cmp.eq.or.andcm p6,p7=IA64_ISR_CODE_LFETCH,r22	// check isr.code field
+(p8)	br.cond.spnt page_fault
+
+	dep r21=-1,r21,IA64_PSR_ED_BIT,1
+	or r19=r19,r17		// insert PTE control bits into r19
+	;;
+	or r19=r19,r18		// set bit 4 (uncached) if the access was to region 6
+(p6)	mov cr.ipsr=r21
+	;;
+(p7)	itc.d r19		// insert the TLB entry
+	mov pr=r31,-1
+	rfi
+END(alt_dtlb_miss)
+
+	.org ia64_ivt+0x1400
+/////////////////////////////////////////////////////////////////////////////////////////
+// 0x1400 Entry 5 (size 64 bundles) Data nested TLB (6,45)
+ENTRY(nested_dtlb_miss)
+	/*
+	 * In the absence of kernel bugs, we get here when the virtually mapped linear
+	 * page table is accessed non-speculatively (e.g., in the Dirty-bit, Instruction
+	 * Access-bit, or Data Access-bit faults).  If the DTLB entry for the virtual page
+	 * table is missing, a nested TLB miss fault is triggered and control is
+	 * transferred to this point.  When this happens, we lookup the pte for the
+	 * faulting address by walking the page table in physical mode and return to the
+	 * continuation point passed in register r30 (or call page_fault if the address is
+	 * not mapped).
+	 *
+	 * Input:	r16:	faulting address
+	 *		r29:	saved b0
+	 *		r30:	continuation address
+	 *		r31:	saved pr
+	 *
+	 * Output:	r17:	physical address of PTE of faulting address
+	 *		r29:	saved b0
+	 *		r30:	continuation address
+	 *		r31:	saved pr
+	 *
+	 * Clobbered:	b0, r18, r19, r21, r22, psr.dt (cleared)
+	 */
+$nested_dtlb_miss_handler
+END(nested_dtlb_miss)
+
+	.org ia64_ivt+0x1800
+/////////////////////////////////////////////////////////////////////////////////////////
+// 0x1800 Entry 6 (size 64 bundles) Instruction Key Miss (24)
+ENTRY(ikey_miss)
+	DBG_FAULT(6)
+	FAULT(6)
+END(ikey_miss)
+
+	//-----------------------------------------------------------------------------------
+	// call do_page_fault (predicates are in r31, psr.dt may be off, r16 is faulting address)
+ENTRY(page_fault)
+	ssm psr.dt
+	;;
+	srlz.i
+	;;
+	SAVE_MIN_WITH_COVER
+	alloc r15=ar.pfs,0,0,3,0
+	mov out0=cr.ifa
+	mov out1=cr.isr
+	adds r3=8,r2				// set up second base pointer
+	;;
+	ssm psr.ic | PSR_DEFAULT_BITS
+	;;
+	srlz.i					// guarantee that interruption collectin is on
+	;;
+(p15)	ssm psr.i				// restore psr.i
+	movl r14=ia64_leave_kernel
+	;;
+	SAVE_REST
+	mov rp=r14
+	;;
+	adds out2=16,r12			// out2 = pointer to pt_regs
+	br.call.sptk.many b6=ia64_do_page_fault	// ignore return address
+END(page_fault)
+
+	.org ia64_ivt+0x1c00
+/////////////////////////////////////////////////////////////////////////////////////////
+// 0x1c00 Entry 7 (size 64 bundles) Data Key Miss (12,51)
+ENTRY(dkey_miss)
+	DBG_FAULT(7)
+	FAULT(7)
+END(dkey_miss)
+
+	.org ia64_ivt+0x2000
+/////////////////////////////////////////////////////////////////////////////////////////
+// 0x2000 Entry 8 (size 64 bundles) Dirty-bit (54)
+ENTRY(dirty_bit)
+	DBG_FAULT(8)
+$dirty_bit_handler
+END(dirty_bit)
+
+	.org ia64_ivt+0x2400
+/////////////////////////////////////////////////////////////////////////////////////////
+// 0x2400 Entry 9 (size 64 bundles) Instruction Access-bit (27)
+ENTRY(iaccess_bit)
+	DBG_FAULT(9)
+$iaccess_bit_handler
+END(iaccess_bit)
+
+	.org ia64_ivt+0x2800
+/////////////////////////////////////////////////////////////////////////////////////////
+// 0x2800 Entry 10 (size 64 bundles) Data Access-bit (15,55)
+ENTRY(daccess_bit)
+	DBG_FAULT(10)
+$daccess_bit_handler
+END(daccess_bit)
+
+	.org ia64_ivt+0x2c00

--- STRIPPED : rest of the file remains the same ----

Index: linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/kernel/ivt.S
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/kernel/ivt-sfvhpt.in	2006-05-03 15:53:11.000000000 +1000
@@ -0,0 +1,444 @@
+/*
+ * This file is to be processed and inserted into the actual ivt.S
+ *
+ * Any variable $name in ivt.S will be replaced with what is between
+ *__begin_name__ and __end_name__ in this file.
+ *
+ */
+
+//vhpt_miss
+__begin_vhpt_miss_handler__
+	mov r16=cr.ifa				// get address that caused the TLB miss
+#ifdef CONFIG_HUGETLB_PAGE
+	movl r18=PAGE_SHIFT
+	mov r25=cr.itir
+#endif
+	;;
+	rsm psr.dt				// use physical addressing for data
+	mov r31=pr				// save the predicate registers
+	mov r19=IA64_KR(PT_BASE)		// get page table base address
+	shl r21=r16,3				// shift bit 60 into sign bit
+	shr.u r17=r16,61			// get the region number into r17
+	;;
+	shr.u r22=r21,3
+#ifdef CONFIG_HUGETLB_PAGE
+	extr.u r26=r25,2,6
+	;;
+	cmp.ne p8,p0=r18,r26
+	sub r27=r26,r18
+	;;
+(p8)	dep r25=r18,r25,2,6
+(p8)	shr r22=r22,r27
+#endif
+	;;
+	cmp.eq p6,p7=5,r17			// is IFA pointing into to region 5?
+	shr.u r18=r22,PGDIR_SHIFT		// get bottom portion of pgd index bit
+	;;
+(p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
+
+	srlz.d
+	LOAD_PHYSICAL(p6, r19, swapper_pg_dir)	// region 5 is rooted at swapper_pg_dir
+
+	.pred.rel "mutex", p6, p7
+(p6)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT
+(p7)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3
+	;;
+(p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=pgd_offset for region 5
+(p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=pgd_offset for region[0-4]
+	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
+#ifdef CONFIG_PGTABLE_4
+	shr.u r28=r22,PUD_SHIFT			// shift pud index into position
+#else
+	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
+#endif
+	;;
+	ld8 r17=[r17]				// get *pgd (may be 0)
+	;;
+(p7)	cmp.eq p6,p7=r17,r0			// was pgd_present(*pgd) == NULL?
+#ifdef CONFIG_PGTABLE_4
+	dep r28=r28,r17,3,(PAGE_SHIFT-3)	// r28=pud_offset(pgd,addr)
+	;;
+	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
+(p7)	ld8 r29=[r28]				// get *pud (may be 0)
+	;;
+(p7)	cmp.eq.or.andcm p6,p7=r29,r0		// was pud_present(*pud) == NULL?
+	dep r17=r18,r29,3,(PAGE_SHIFT-3)	// r17=pmd_offset(pud,addr)
+#else
+	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// r17=pmd_offset(pgd,addr)
+#endif
+	;;
+(p7)	ld8 r20=[r17]				// get *pmd (may be 0)
+	shr.u r19=r22,PAGE_SHIFT		// shift pte index into position
+	;;
+(p7)	cmp.eq.or.andcm p6,p7=r20,r0		// was pmd_present(*pmd) == NULL?
+	dep r21=r19,r20,3,(PAGE_SHIFT-3)	// r21=pte_offset(pmd,addr)
+	;;
+(p7)	ld8 r18=[r21]				// read *pte
+	mov r19=cr.isr				// cr.isr bit 32 tells us if this is an insn miss
+	;;
+(p7)	tbit.z p6,p7=r18,_PAGE_P_BIT		// page present bit cleared?
+	mov r22=cr.iha				// get the VHPT address that caused the TLB miss
+	;;					// avoid RAW on p7
+(p7)	tbit.nz.unc p10,p11=r19,32		// is it an instruction TLB miss?
+	dep r23=0,r20,0,PAGE_SHIFT		// clear low bits to get page address
+	;;
+(p10)	itc.i r18				// insert the instruction TLB entry
+(p11)	itc.d r18				// insert the data TLB entry
+(p6)	br.cond.spnt.many page_fault		// handle bad address/page not present (page fault)
+	mov cr.ifa=r22
+
+#ifdef CONFIG_HUGETLB_PAGE
+(p8)	mov cr.itir=r25				// change to default page-size for VHPT
+#endif
+
+	/*
+	 * Now compute and insert the TLB entry for the virtual page table.  We never
+	 * execute in a page table page so there is no need to set the exception deferral
+	 * bit.
+	 */
+	adds r24=__DIRTY_BITS_NO_ED|_PAGE_PL_0|_PAGE_AR_RW,r23
+	;;
+(p7)	itc.d r24
+	;;
+#ifdef CONFIG_SMP
+	/*
+	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
+	 * cannot possibly affect the following loads:
+	 */
+	dv_serialize_data
+
+	/*
+	 * Re-check pagetable entry.  If they changed, we may have received a ptc.g
+	 * between reading the pagetable and the "itc".  If so, flush the entry we
+	 * inserted and retry.  At this point, we have:
+	 *
+	 * r28 = equivalent of pud_offset(pgd, ifa)
+	 * r17 = equivalent of pmd_offset(pud, ifa)
+	 * r21 = equivalent of pte_offset(pmd, ifa)
+	 *
+	 * r29 = *pud
+	 * r20 = *pmd
+	 * r18 = *pte
+	 */
+	ld8 r25=[r21]				// read *pte again
+	ld8 r26=[r17]				// read *pmd again
+#ifdef CONFIG_PGTABLE_4
+	ld8 r19=[r28]				// read *pud again
+#endif
+	cmp.ne p6,p7=r0,r0
+	;;
+	cmp.ne.or.andcm p6,p7=r26,r20		// did *pmd change
+#ifdef CONFIG_PGTABLE_4
+	cmp.ne.or.andcm p6,p7=r19,r29		// did *pud change
+#endif
+	mov r27=PAGE_SHIFT<<2
+	;;
+(p6)	ptc.l r22,r27				// purge PTE page translation
+(p7)	cmp.ne.or.andcm p6,p7=r25,r18		// did *pte change
+	;;
+(p6)	ptc.l r16,r27				// purge translation
+#endif
+
+	mov pr=r31,-1				// restore predicate registers
+	rfi
+__end_vhpt_miss_handler__
+
+// itlb_miss
+__begin_itlb_miss_handler__
+	mov r16=cr.ifa				// get virtual address
+	mov r29=b0				// save b0
+	mov r31=pr				// save predicates
+.itlb_fault:
+	mov r17=cr.iha				// get virtual address of PTE
+	movl r30=1f				// load nested fault continuation point
+	;;
+1:	ld8 r18=[r17]				// read *pte
+	;;
+	mov b0=r29
+	tbit.z p6,p0=r18,_PAGE_P_BIT		// page present bit cleared?
+(p6)	br.cond.spnt page_fault
+	;;
+	itc.i r18
+	;;
+#ifdef CONFIG_SMP
+	/*
+	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
+	 * cannot possibly affect the following loads:
+	 */
+	dv_serialize_data
+
+	ld8 r19=[r17]				// read *pte again and see if same
+	mov r20=PAGE_SHIFT<<2			// setup page size for purge
+	;;
+	cmp.ne p7,p0=r18,r19
+	;;
+(p7)	ptc.l r16,r20
+#endif
+	mov pr=r31,-1
+	rfi
+__end_itlb_miss_handler__
+
+// dtlb_miss
+__begin_dtlb_miss_handler__
+	mov r16=cr.ifa				// get virtual address
+	mov r29=b0				// save b0
+	mov r31=pr				// save predicates
+dtlb_fault:
+	mov r17=cr.iha				// get virtual address of PTE
+	movl r30=1f				// load nested fault continuation point
+	;;
+1:	ld8 r18=[r17]				// read *pte
+	;;
+	mov b0=r29
+	tbit.z p6,p0=r18,_PAGE_P_BIT		// page present bit cleared?
+(p6)	br.cond.spnt page_fault
+	;;
+	itc.d r18
+	;;
+#ifdef CONFIG_SMP
+	/*
+	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
+	 * cannot possibly affect the following loads:
+	 */
+	dv_serialize_data
+
+	ld8 r19=[r17]				// read *pte again and see if same
+	mov r20=PAGE_SHIFT<<2			// setup page size for purge
+	;;
+	cmp.ne p7,p0=r18,r19
+	;;
+(p7)	ptc.l r16,r20
+#endif
+	mov pr=r31,-1
+	rfi
+__end_dtlb_miss_handler__
+
+// nested_dtlb_miss
+__begin_nested_dtlb_miss_handler__
+	rsm psr.dt				// switch to using physical data addressing
+	mov r19=IA64_KR(PT_BASE)		// get the page table base address
+	shl r21=r16,3				// shift bit 60 into sign bit
+	mov r18=cr.itir
+	;;
+	shr.u r17=r16,61			// get the region number into r17
+	extr.u r18=r18,2,6			// get the faulting page size
+	;;
+	cmp.eq p6,p7=5,r17			// is faulting address in region 5?
+	add r22=-PAGE_SHIFT,r18			// adjustment for hugetlb address
+	add r18=PGDIR_SHIFT-PAGE_SHIFT,r18
+	;;
+	shr.u r22=r16,r22
+	shr.u r18=r16,r18
+(p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
+
+	srlz.d
+	LOAD_PHYSICAL(p6, r19, swapper_pg_dir)	// region 5 is rooted at swapper_pg_dir
+
+	.pred.rel "mutex", p6, p7
+(p6)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT
+(p7)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3
+	;;
+(p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=pgd_offset for region 5
+(p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=pgd_offset for region[0-4]
+	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
+#ifdef CONFIG_PGTABLE_4
+	shr.u r18=r22,PUD_SHIFT			// shift pud index into position
+#else
+	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
+#endif
+	;;
+	ld8 r17=[r17]				// get *pgd (may be 0)
+	;;
+(p7)	cmp.eq p6,p7=r17,r0			// was pgd_present(*pgd) == NULL?
+	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// r17=p[u|m]d_offset(pgd,addr)
+	;;
+#ifdef CONFIG_PGTABLE_4
+(p7)	ld8 r17=[r17]				// get *pud (may be 0)
+	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
+	;;
+(p7)	cmp.eq.or.andcm p6,p7=r17,r0		// was pud_present(*pud) == NULL?
+	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// r17=pmd_offset(pud,addr)
+	;;
+#endif
+(p7)	ld8 r17=[r17]				// get *pmd (may be 0)
+	shr.u r19=r22,PAGE_SHIFT		// shift pte index into position
+	;;
+(p7)	cmp.eq.or.andcm p6,p7=r17,r0		// was pmd_present(*pmd) == NULL?
+	dep r17=r19,r17,3,(PAGE_SHIFT-3)	// r17=pte_offset(pmd,addr);
+(p6)	br.cond.spnt page_fault
+	mov b0=r30
+	br.sptk.many b0				// return to continuation point
+__end_nested_dtlb_miss_handler__
+
+// dirty bit
+__begin_dirty_bit_handler__
+	/*
+	 * What we do here is to simply turn on the dirty bit in the PTE.  We need to
+	 * update both the page-table and the TLB entry.  To efficiently access the PTE,
+	 * we address it through the virtual page table.  Most likely, the TLB entry for
+	 * the relevant virtual page table page is still present in the TLB so we can
+	 * normally do this without additional TLB misses.  In case the necessary virtual
+	 * page table TLB entry isn't present, we take a nested TLB miss hit where we look
+	 * up the physical address of the L3 PTE and then continue at label 1 below.
+	 */
+	mov r16=cr.ifa				// get the address that caused the fault
+	movl r30=1f				// load continuation point in case of nested fault
+	;;
+	thash r17=r16				// compute virtual address of L3 PTE
+	mov r29=b0				// save b0 in case of nested fault
+	mov r31=pr				// save pr
+#ifdef CONFIG_SMP
+	mov r28=ar.ccv				// save ar.ccv
+	;;
+1:	ld8 r18=[r17]
+	;;					// avoid RAW on r18
+	mov ar.ccv=r18				// set compare value for cmpxchg
+	or r25=_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
+	tbit.z p7,p6 = r18,_PAGE_P_BIT		// Check present bit
+	;;
+(p6)	cmpxchg8.acq r26=[r17],r25,ar.ccv	// Only update if page is present
+	mov r24=PAGE_SHIFT<<2
+	;;
+(p6)	cmp.eq p6,p7=r26,r18			// Only compare if page is present
+	;;
+(p6)	itc.d r25				// install updated PTE
+	;;
+	/*
+	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
+	 * cannot possibly affect the following loads:
+	 */
+	dv_serialize_data
+
+	ld8 r18=[r17]				// read PTE again
+	;;
+	cmp.eq p6,p7=r18,r25			// is it same as the newly installed
+	;;
+(p7)	ptc.l r16,r24
+	mov b0=r29				// restore b0
+	mov ar.ccv=r28
+#else
+	;;
+1:	ld8 r18=[r17]
+	;;					// avoid RAW on r18
+	or r18=_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
+	mov b0=r29				// restore b0
+	;;
+	st8 [r17]=r18				// store back updated PTE
+	itc.d r18				// install updated PTE
+#endif
+	mov pr=r31,-1				// restore pr
+	rfi
+__end_dirty_bit_handler__
+
+// iaccess bit
+__begin_iaccess_bit_handler__
+	// Like dirty bit handler, except for instruction access
+	mov r16=cr.ifa				// get the address that caused the fault
+	movl r30=1f				// load continuation point in case of nested fault
+	mov r31=pr				// save predicates
+#ifdef CONFIG_ITANIUM
+	/*
+	 * Erratum 10 (IFA may contain incorrect address) has "NoFix" status.
+	 */
+	mov r17=cr.ipsr
+	;;
+	mov r18=cr.iip
+	tbit.z p6,p0=r17,IA64_PSR_IS_BIT	// IA64 instruction set?
+	;;
+(p6)	mov r16=r18				// if so, use cr.iip instead of cr.ifa
+#endif /* CONFIG_ITANIUM */
+	;;
+	thash r17=r16				// compute virtual address of L3 PTE
+	mov r29=b0				// save b0 in case of nested fault)
+#ifdef CONFIG_SMP
+	mov r28=ar.ccv				// save ar.ccv
+	;;
+1:	ld8 r18=[r17]
+	;;
+	mov ar.ccv=r18				// set compare value for cmpxchg
+	or r25=_PAGE_A,r18			// set the accessed bit
+	tbit.z p7,p6 = r18,_PAGE_P_BIT	 	// Check present bit
+	;;
+(p6)	cmpxchg8.acq r26=[r17],r25,ar.ccv	// Only if page present
+	mov r24=PAGE_SHIFT<<2
+	;;
+(p6)	cmp.eq p6,p7=r26,r18			// Only if page present
+	;;
+(p6)	itc.i r25				// install updated PTE
+	;;
+	/*
+	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
+	 * cannot possibly affect the following loads:
+	 */
+	dv_serialize_data
+
+	ld8 r18=[r17]				// read PTE again
+	;;
+	cmp.eq p6,p7=r18,r25			// is it same as the newly installed
+	;;
+(p7)	ptc.l r16,r24
+	mov b0=r29				// restore b0
+	mov ar.ccv=r28
+#else /* !CONFIG_SMP */
+	;;
+1:	ld8 r18=[r17]
+	;;
+	or r18=_PAGE_A,r18			// set the accessed bit
+	mov b0=r29				// restore b0
+	;;
+	st8 [r17]=r18				// store back updated PTE
+	itc.i r18				// install updated PTE
+#endif /* !CONFIG_SMP */
+	mov pr=r31,-1
+	rfi
+__end_iaccess_bit_handler__
+
+// daccess bit
+__begin_daccess_bit_handler__
+	// Like dirty bit handler, except for data access
+	mov r16=cr.ifa				// get the address that caused the fault
+	movl r30=1f				// load continuation point in case of nested fault
+	;;
+	thash r17=r16				// compute virtual address of L3 PTE
+	mov r31=pr
+	mov r29=b0				// save b0 in case of nested fault)
+#ifdef CONFIG_SMP
+	mov r28=ar.ccv				// save ar.ccv
+	;;
+1:	ld8 r18=[r17]
+	;;					// avoid RAW on r18
+	mov ar.ccv=r18				// set compare value for cmpxchg
+	or r25=_PAGE_A,r18			// set the dirty bit
+	tbit.z p7,p6 = r18,_PAGE_P_BIT		// Check present bit
+	;;
+(p6)	cmpxchg8.acq r26=[r17],r25,ar.ccv	// Only if page is present
+	mov r24=PAGE_SHIFT<<2
+	;;
+(p6)	cmp.eq p6,p7=r26,r18			// Only if page is present
+	;;
+(p6)	itc.d r25				// install updated PTE
+	/*
+	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
+	 * cannot possibly affect the following loads:
+	 */
+	dv_serialize_data
+	;;
+	ld8 r18=[r17]				// read PTE again
+	;;
+	cmp.eq p6,p7=r18,r25			// is it same as the newly installed
+	;;
+(p7)	ptc.l r16,r24
+	mov ar.ccv=r28
+#else
+	;;
+1:	ld8 r18=[r17]
+	;;					// avoid RAW on r18
+	or r18=_PAGE_A,r18			// set the accessed bit
+	;;
+	st8 [r17]=r18				// store back updated PTE
+	itc.d r18				// install updated PTE
+#endif
+	mov b0=r29				// restore b0
+	mov pr=r31,-1
+	rfi
+__end_daccess_bit_handler__
Index: linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/kernel/Makefile
===================================================================
--- linux-2.6.17-rc3-lvhpt-v2-fresh.orig/arch/ia64/kernel/Makefile	2006-05-03 14:24:50.000000000 +1000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/kernel/Makefile	2006-05-03 15:52:39.000000000 +1000
@@ -59,3 +59,8 @@
 # We must build gate.so before we can assemble it.
 # Note: kbuild does not track this dependency due to usage of .incbin
 $(obj)/gate-data.o: $(obj)/gate.so
+
+# The real ivt.S needs to be built
+AFLAGS_ivt.o += -I$(srctree)/arch/ia64/kernel
+$(obj)/ivt.S: $(src)/ivt.S.in $(src)/ivt-sfvhpt.in
+	$(srctree)/arch/ia64/scripts/merge.py $@ $^

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
