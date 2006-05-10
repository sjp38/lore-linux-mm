From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 10 May 2006 13:42:22 +1000
Message-Id: <20060510034222.17792.56505.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20060510034206.17792.82504.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
References: <20060510034206.17792.82504.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
Subject: [RFC 3/6] LVHPT - ivt.S long format support
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org, Ian Wienand <ianw@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

LVHPT ivt long format support

Add templates for long format VHPT support, to be merged into ivt.S


Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

---

 Kconfig              |   10 +
 kernel/Makefile      |    9 
 kernel/ivt-lfvhpt.in |  466 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 484 insertions(+), 1 deletion(-)

Index: linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/kernel/Makefile
===================================================================
--- linux-2.6.17-rc3-lvhpt-v2-fresh.orig/arch/ia64/kernel/Makefile	2006-05-05 10:09:38.000000000 +1000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/kernel/Makefile	2006-05-05 10:12:36.000000000 +1000
@@ -62,5 +62,12 @@
 
 # The real ivt.S needs to be built
 AFLAGS_ivt.o += -I$(srctree)/arch/ia64/kernel
-$(obj)/ivt.S: $(src)/ivt.S.in $(src)/ivt-sfvhpt.in
+
+ifeq ($(CONFIG_IA64_LONG_FORMAT_VHPT),)
+fault_handler_in = ivt-sfvhpt.in
+else
+fault_handler_in = ivt-lfvhpt.in
+endif
+
+$(obj)/ivt.S: $(src)/ivt.S.in $(src)/$(fault_handler_in)
 	$(srctree)/arch/ia64/scripts/merge.py $@ $^
Index: linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/kernel/ivt-lfvhpt.in
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/kernel/ivt-lfvhpt.in	2006-05-05 10:12:36.000000000 +1000
@@ -0,0 +1,466 @@
+/*
+ * Long Format VHPT fault handlers
+ *
+ * Copyright (C) 2006; see ivt.S for original authors
+ * These bits by
+ *  Matthew Chapman <matthewc@cse.unsw.edu.au>
+ *  Darren Williams <darren.williams@nicta.com.au>
+ *  Ian Wienand <ianw@gelato.unsw.edu.au>
+ *
+ * This file is to be processed and inserted into the actual ivt.S
+ *
+ * Any variable $name in ivt.S will be replaced with what is between
+ *__begin_name__ and __end_name__ in this file.
+ *
+ */
+
+//vhpt_miss
+__begin_vhpt_miss_handler__
+// This fault can not happen with long format VHPT
+	FAULT(0)
+__end_vhpt_miss_handler__
+
+// itlb_miss
+__begin_itlb_miss_handler__
+        mov r16=cr.ifa                          // get virtual address
+        mov r29=b0                              // save b0
+        mov r31=pr                              // save predicates
+	;;
+.itlb_fault:
+	// walk the page table to satisfy this miss
+	rsm psr.dt                              // switch to using physical data addressing
+        mov r19=IA64_KR(PT_BASE)                // get the page table base address
+        shl r21=r16,3                           // shift bit 60 into sign bit
+        mov r18=cr.itir
+        ;;
+        shr.u r17=r16,61                      // get the region number into ppte
+        extr.u r18=r18,2,6                      // get the faulting page size
+        ;;
+        cmp.eq p6,p7=5,r17                  // is faulting address in region 5?
+        add r22=-PAGE_SHIFT,r18                 // adjustment for hugetlb address
+        add r18=PGDIR_SHIFT-PAGE_SHIFT,r18
+        ;;
+        shr.u r22=r16,r22
+        shr.u r18=r16,r18
+(p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3    // put region number bits in place
+
+        srlz.d
+        LOAD_PHYSICAL(p6, r19, swapper_pg_dir) // region 5 is rooted at swapper_pg_dir
+
+        .pred.rel "mutex", p6, p7
+(p6)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT
+(p7)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3
+	;;
+(p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)      // ppte=pgd_offset for region 5
+(p7)	dep r17=r18,r17,3,(PAGE_SHIFT-3)-3  // ppte=pgd_offset for region[0-4]
+	cmp.eq p7,p6=0,r21                    // unused address bits all zeroes?
+#ifdef CONFIG_PGTABLE_4
+        shr.u r18=r22,PUD_SHIFT                 // shift pud index into position
+#else
+        shr.u r18=r22,PMD_SHIFT                 // shift pmd index into position
+#endif
+        ;;
+        ld8 r17=[r17]                       // get *pgd (may be 0)
+        ;;
+(p7)	cmp.eq p6,p7=r17,r0                 // was pgd_present(*pgd) == NULL?
+        dep r17=r18,r17,3,(PAGE_SHIFT-3)    // ppte=p[u|m]d_offset(pgd,addr)
+        ;;
+#ifdef CONFIG_PGTABLE_4
+(p7)	ld8 r17=[r17]                       // get *pud (may be 0)
+        shr.u r18=r22,PMD_SHIFT                 // shift pmd index into position
+        ;;
+(p7)   cmp.eq.or.andcm p6,p7=r17,r0        // was pud_present(*pud) == NULL?
+        dep r17=r18,r17,3,(PAGE_SHIFT-3)    // ppte=pmd_offset(pud,addr)
+        ;;
+#endif
+(p7)	ld8 r17=[r17]                       // get *pmd (may be 0)
+        shr.u r19=r22,PAGE_SHIFT                // shift pte index into position
+        ;;
+(p7)	cmp.eq.or.andcm p6,p7=r17,r0        // was pmd_present(*pmd) == NULL?
+	dep r17=r19,r17,3,(PAGE_SHIFT-3)    // ppte=pte_offset(pmd,addr)
+	;;
+(p7)    ld8 r18=[r17]
+        ;;
+(p7)    tbit.z p6,p0=r18,_PAGE_P_BIT           /* page present bit cleared? */
+(p6)    br.cond.spnt page_fault
+	// insert vhpt mapping
+        mov r22=cr.iha
+        mov r26=cr.itir
+        ;;
+        tpa r22=r22         /* make hash address physical */
+        ttag r25=r16
+        ;;
+        add r24=16,r22
+        ;;
+        st8 [r22]=r18,8      /* fill out VHPT entry */
+        st8 [r24]=r25,8
+        ;;
+        st8 [r22]=r26,8
+        st8 [r24]=r17
+	//insert actual translation
+	;;
+	itc.i r18
+        ;;
+#ifdef CONFIG_SMP
+        /*
+         * Tell the assemblers dependency-violation checker that the above "itc" instructions
+         * cannot possibly affect the following loads:
+         */
+        dv_serialize_data
+
+        ld8 r19=[r17]                           // read *pte again and see if same
+        mov r20=PAGE_SHIFT<<2                   // setup page size for purge
+        ;;
+        cmp.ne p7,p0=r18,r19
+        ;;
+(p7)	dep r25=-1,r0,63,1      /* set tag-invalid bit */
+	;;
+(p7)	st8 [r22]=r25         /* hpte already points to tag (see above) */
+(p7)    ptc.l r16,r20
+#endif
+        mov pr=r31,-1
+        rfi
+__end_itlb_miss_handler__
+
+// dtlb_miss
+__begin_dtlb_miss_handler__
+        mov r16=cr.ifa                          // get virtual address
+        mov r29=b0                              // save b0
+        mov r31=pr                              // save predicates
+	;;
+.dtlb_fault:
+	// walk the page table to satisfy this miss
+	rsm psr.dt                              // switch to using physical data addressing
+        mov r19=IA64_KR(PT_BASE)                // get the page table base address
+        shl r21=r16,3                           // shift bit 60 into sign bit
+        mov r18=cr.itir
+        ;;
+        shr.u r17=r16,61                      // get the region number into ppte
+        extr.u r18=r18,2,6                      // get the faulting page size
+        ;;
+        cmp.eq p6,p7=5,r17                  // is faulting address in region 5?
+        add r22=-PAGE_SHIFT,r18                 // adjustment for hugetlb address
+        add r18=PGDIR_SHIFT-PAGE_SHIFT,r18
+        ;;
+        shr.u r22=r16,r22
+        shr.u r18=r16,r18
+(p7)   dep r17=r17,r19,(PAGE_SHIFT-3),3    // put region number bits in place
+
+        srlz.d
+        LOAD_PHYSICAL(p6, r19, swapper_pg_dir) // region 5 is rooted at swapper_pg_dir
+
+        .pred.rel "mutex", p6, p7
+(p6)   shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT
+(p7)   shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3
+        ;;
+(p6)   dep r17=r18,r19,3,(PAGE_SHIFT-3)      // ppte=pgd_offset for region 5
+(p7)   dep r17=r18,r17,3,(PAGE_SHIFT-3)-3  // ppte=pgd_offset for region[0-4]
+        cmp.eq p7,p6=0,r21                    // unused address bits all zeroes?
+#ifdef CONFIG_PGTABLE_4
+        shr.u r18=r22,PUD_SHIFT                 // shift pud index into position
+#else
+        shr.u r18=r22,PMD_SHIFT                 // shift pmd index into position
+#endif
+        ;;
+        ld8 r17=[r17]                       // get *pgd (may be 0)
+        ;;
+(p7)   cmp.eq p6,p7=r17,r0                 // was pgd_present(*pgd) == NULL?
+        dep r17=r18,r17,3,(PAGE_SHIFT-3)    // ppte=p[u|m]d_offset(pgd,addr)
+        ;;
+#ifdef CONFIG_PGTABLE_4
+(p7)   ld8 r17=[r17]                       // get *pud (may be 0)
+        shr.u r18=r22,PMD_SHIFT                 // shift pmd index into position
+        ;;
+(p7)   cmp.eq.or.andcm p6,p7=r17,r0        // was pud_present(*pud) == NULL?
+        dep r17=r18,r17,3,(PAGE_SHIFT-3)    // ppte=pmd_offset(pud,addr)
+        ;;
+#endif
+(p7)   ld8 r17=[r17]                       // get *pmd (may be 0)
+        shr.u r19=r22,PAGE_SHIFT                // shift pte index into position
+        ;;
+(p7)   cmp.eq.or.andcm p6,p7=r17,r0        // was pmd_present(*pmd) == NULL?
+       dep r17=r19,r17,3,(PAGE_SHIFT-3)    // ppte=pte_offset(pmd,addr)
+	;;
+(p7)    ld8 r18=[r17]
+        ;;
+(p7)    tbit.z p6,p0=r18,_PAGE_P_BIT           /* page present bit cleared? */
+(p6)    br.cond.spnt page_fault
+// insert vhpt mapping
+        mov r22=cr.iha
+        mov r26=cr.itir
+        ;;
+        tpa r22=r22         /* make hash address physical */
+        ttag r25=r16
+        ;;
+        add r24=16,r22
+        ;;
+        st8 [r22]=r18,8      /* fill out VHPT entry */
+        st8 [r24]=r25,8
+        ;;
+        st8 [r22]=r26,8
+        st8 [r24]=r17
+//insert actual translation
+	;;
+	itc.d r18
+        ;;
+#ifdef CONFIG_SMP
+        /*
+         * Tell the assemblers dependency-violation checker that the above "itc" instructions
+         * cannot possibly affect the following loads:
+         */
+        dv_serialize_data
+
+        ld8 r19=[r17]                           // read *pte again and see if same
+        mov r20=PAGE_SHIFT<<2                   // setup page size for purge
+        ;;
+        cmp.ne p7,p0=r18,r19
+        ;;
+(p7)	dep r25=-1,r0,63,1      /* set tag-invalid bit */
+	;;
+(p7)	st8 [r22]=r25         /* hpte already points to tag (see above) */
+(p7)    ptc.l r16,r20
+#endif
+        mov pr=r31,-1
+        rfi
+__end_dtlb_miss_handler__
+
+// nested_dtlb_miss
+__begin_nested_dtlb_miss_handler__
+// This fault can not happen with long format VHPT
+	FAULT(5)
+__end_nested_dtlb_miss_handler__
+
+// dirty bit
+__begin_dirty_bit_handler__
+	mov r16=cr.ifa				// get the address that caused the fault
+	mov r29=b0				// save b0 for nested fault (XXX)
+	mov r31=pr				// save pr
+	/*
+	 * we try to find the address via the VHPT, if not fall back to
+	 * dtlb_fault.
+	 */
+	;;
+        thash r28=r16
+        rsm psr.dt
+        ;;
+        tpa r22=r28           			// make hash address physical
+        ttag r25=r16
+        ;;
+        srlz.d
+        add r24=16,r22
+        add r17=24,r22
+        ;;
+        ld8 r26=[r24]           		// load tag
+        ld8 r17=[r17]
+        ;;
+        cmp.ne p6,p7=r26, r25   		// verify tag
+        ;;
+(p7)    ld8 r18=[r17]
+        ;;
+(p6)    mov cr.iha=r28          		// set cr.iha only if we are going to take
+(p6)    br.cond.spnt .dtlb_fault 		// the failfn fault - it depends on it.
+#ifdef CONFIG_SMP
+	mov r28=ar.ccv				// save ar.ccv
+	;;
+	mov ar.ccv=r18				// set compare value for cmpxchg
+	or r25=_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
+	tbit.z p7,p6 = r18,_PAGE_P_BIT		// Check present bit
+	;;
+(p6)	cmpxchg8.acq r26=[r17],r25,ar.ccv	// Only update if page is present
+	mov r24=PAGE_SHIFT<<2
+	;;
+(p6)	cmp.eq p6,p7=r26,r18			// Only compare if page is present
+	;;
+(p6)    st8 [r22]=r18,16			// update VHPT
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
+(p7)	dep r25=-1,r0,63,1      		// set tag-invalid bit
+	;;
+(p7)	st8 [r22]=r25         			// hpte already points to tag (see above)
+(p7)	ptc.l r16,r24
+	mov b0=r29				// restore b0
+	mov ar.ccv=r28
+#else
+	;;
+	or r18=_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
+	mov b0=r29				// restore b0
+	;;
+	st8 [r17]=r18				// store back updated PTE
+(p0)	st8 [r22]=r18,16			// update VHPT (p0 set from dtlb_fault)
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
+	mov r29=b0
+	mov r31=pr				// save predicates
+	;;
+	/*
+	 * we try to find the address via the VHPT, if not fall back to
+	 * dtlb_fault.
+	 */
+        thash r28=r16
+        rsm psr.dt
+        ;;
+        tpa r22=r28           			// make hash address physical
+        ttag r25=r16
+        ;;
+        srlz.d
+        add r24=16,r22
+        add r17=24,r22
+        ;;
+        ld8 r26=[r24]           		// load tag
+        ld8 r17=[r17]
+        ;;
+        cmp.ne p6,p7=r26, r25   		// verify tag
+        ;;
+(p7)    ld8 r18=[r17]
+        ;;
+(p6)    mov cr.iha=r28          		// set cr.iha only if we are going to take
+(p6)    br.cond.spnt .itlb_fault 		// the failfn fault - it depends on it.
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
+	mov b0=r29				// restore b0
+#ifdef CONFIG_SMP
+	mov r28=ar.ccv				// save ar.ccv
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
+(p6)	st8 [r22]=r18,16			// update VHPT
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
+(p7)	dep r25=-1,r0,63,1      		// set tag-invalid bit
+	;;
+(p7)	st8 [r22]=r25         			// hpte already points to tag (see above)
+(p7)	ptc.l r16,r24
+	mov b0=r29				// restore b0
+	mov ar.ccv=r28
+#else /* !CONFIG_SMP */
+	;;
+	or r18=_PAGE_A,r18			// set the accessed bit
+	mov b0=r29				// restore b0
+	;;
+	st8 [r17]=r18				// store back updated PTE
+(p0)	st8 [r22]=r18,16			// update VHPT (p0 from itlb_miss)
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
+	mov r29=b0
+	mov r31=pr				// save predicates
+	;;
+	/*
+	 * we try to find the address via the VHPT, if not fall back to
+	 * dtlb_fault.
+	 */
+	;;
+        thash r28=r16
+        rsm psr.dt
+        ;;
+        tpa r22=r28           			// make hash address physical
+        ttag r25=r16
+        ;;
+        srlz.d
+        add r24=16,r22
+        add r17=24,r22
+        ;;
+        ld8 r26=[r24]           		// load tag
+        ld8 r17=[r17]
+        ;;
+        cmp.ne p6,p7=r26, r25   		// verify tag
+        ;;
+(p7)    ld8 r18=[r17]
+        ;;
+(p6)    mov cr.iha=r28          		// set cr.iha only if we are going to take
+(p6)    br.cond.spnt .dtlb_fault 		// the failfn fault - it depends on it.
+#ifdef CONFIG_SMP
+	mov r28=ar.ccv				// save ar.ccv
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
+(p6)	st8 [r22]=r18,16			// update VHPT
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
+(p7)	dep r25=-1,r0,63,1      		// set tag-invalid bit
+	;;
+(p7)	st8 [r22]=r25         			// hpte already points to tag (see above)
+(p7)	ptc.l r16,r24
+	mov b0=r29				// restore b0
+	mov ar.ccv=r28
+#else /* !CONFIG_SMP */
+	;;
+	or r18=_PAGE_A,r18			// set the accessed bit
+	mov b0=r29				// restore b0
+	;;
+	st8 [r17]=r18				// store back updated PTE
+(p0)	st8 [r22]=r18,16			// update VHPT (p0 from itlb_miss)
+	itc.i r18				// install updated PTE
+#endif /* !CONFIG_SMP */
+	mov pr=r31,-1
+	rfi
+__end_daccess_bit_handler__
Index: linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/Kconfig
===================================================================
--- linux-2.6.17-rc3-lvhpt-v2-fresh.orig/arch/ia64/Kconfig	2006-05-05 10:02:39.000000000 +1000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/Kconfig	2006-05-05 10:12:36.000000000 +1000
@@ -374,6 +374,16 @@
 	def_bool y
 	depends on NEED_MULTIPLE_NODES
 
+config IA64_LONG_FORMAT_VHPT
+ 	bool "Long format VHPT"
+ 	depends on !DISABLE_VHPT
+ 	help
+ 	  The long format VHPT is an alternative hashed page table.
+	  It is more TLB friendly, but less cache friendly.  By its
+	  self this may have a negative, neutral, or positive impact
+	  on performance, depending on your workloads.  If you're
+	  unsure, answer N and keep the default short-format VHPT.
+
 config IA32_SUPPORT
 	bool "Support for Linux/x86 binaries"
 	help

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
