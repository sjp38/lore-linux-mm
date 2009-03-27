Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 426306B0047
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 10:54:05 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2RFAUHU209372
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 15:10:30 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2RFAD4m1155138
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:10:16 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2RFADCa015321
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:10:13 +0100
Message-Id: <20090327151013.024372165@de.ibm.com>
References: <20090327150905.819861420@de.ibm.com>
Date: Fri, 27 Mar 2009 16:09:11 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 6/6] Guest page hinting: s390 support.
Content-Disposition: inline; filename=006-hva-s390.diff
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org
Cc: frankeh@watson.ibm.com, akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com, riel@redhat.com, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj

s390 uses the milli-coded ESSA instruction to set the page state. The
page state is formed by four guest page states called block usage states
and three host page states called block content states.

The guest states are:
 - stable (S): there is essential content in the page
 - unused (U): there is no useful content and any access to the page will
   cause an addressing exception
 - volatile (V): there is useful content in the page. The host system is
   allowed to discard the content anytime, but has to deliver a discard
   fault with the absolute address of the page if the guest tries to
   access it.
 - potential volatile (P): the page has useful content. The host system
   is allowed to discard the content after it has checked the dirty bit
   of the page. It has to deliver a discard fault with the absolute
   address of the page if the guest tries to access it.

The host states are:
 - resident: the page is present in real memory.
 - preserved: the page is not present in real memory but the content is
   preserved elsewhere by the machine, e.g. on the paging device.
 - zero: the page is not present in real memory. The content of the page
   is logically-zero.

There are 12 combinations of guest and host state, currently only 8 are
valid page states:
 Sr: a stable, resident page.
 Sp: a stable, preserved page.
 Sz: a stable, logically zero page. A page filled with zeroes will be
     allocated on first access.
 Ur: an unused but resident page. The host could make it Uz anytime but
     it doesn't have to.
 Uz: an unused, logically zero page.
 Vr: a volatile, resident page. The guest can access it normally.
 Vz: a volatile, logically zero page. This is a discarded page. The host
     will deliver a discard fault for any access to the page.
 Pr: a potential volatile, resident page. The guest can access it normally.

The remaining 4 combinations can't occur:
 Up: an unused, preserved page. If the host tries to get rid of a Ur page
     it will remove it without writing the page content to disk and set
     the page to Uz.
 Vp: a volatile, preserved page. If the host picks a Vr page for eviction
     it will discard it and set the page state to Vz.
 Pp: a potential volatile, preserved page. There are two cases for page out:
     1) if the page is dirty then the host will preserved the page and set
     it to Sp or 2) if the page is clean then the host will discard it and
     set the page state to Vz.
 Pz: a potential volatile, logically zero page. The host system will always
     use Vz instead of Pz.

The state transitions (a diagram would be nicer but that is too hard
to do in ascii art...):
{Ur,Sr,Vr,Pr}: a resident page will change its block usage state if the
     guest requests it with page_set_{unused,stable,volatile}.
{Uz,Sz,Vz}: a logically zero page will change its block usage state if the
     guest requests it with page_set_{unused,stable,volatile}. The
     guest can't create the Pz state, the state will be Vz instead.
Ur -> Uz: the host system can remove an unused, resident page from memory
Sz -> Sr: on first access a stable, logically zero page will become resident
Sr -> Sp: the host system can swap a stable page to disk
Sp -> Sr: a guest access to a Sp page forces the host to retrieve it
Vr -> Vz: the host can discard a volatile page
Sp -> Uz: a page preserved by the host will be removed if the guest sets 
     the block usage state to unused.
Sp -> Vz: a page preserved by the host will be discarded if the guest sets
     the block usage state to volatile.
Pr -> Sp: the host can move a page from Pr to Sp if it discovers that the
     page is dirty while trying to discard the page. The page content is
     written to the paging device.
Pr -> Vz: the host can discard a Pr page. The Pz state is replaced by the
     Vz state.

The are some hazards the code has to deal with:
1) For potential volatile pages the transfer of the hardware dirty bit to
the software dirty bit needs to make sure that the page gets into the
stable state before the hardware dirty bit is cleared. Between the
page_test_dirty and the page_clear_dirty call a page_make_stable is
required.

2) Since the access of unused pages causes addressing exceptions we need
to take care with /dev/mem. The copy_{from_to}_user functions need to
be able to cope with addressing exceptions for the kernel address space.

3) The discard fault on a s390 machine delivers the absolute address of
the page that caused the fault instead of the virtual address. With the
virtual address we could have used the page table entry of the current
process to safely get a reference to the discarded page. We can get to
the struct page from the absolute page address but it is rather hard to
get to a proper page reference. The page that caused the fault could
already have been freed and reused for a different purpose. None of the
fields in the struct page would be reliable to use. The freeing of
discarded pages therefore has to be postponed until all pending discard
faults for this page have been dealt with. The discard fault handler
is called disabled for interrupts and tries to get a page reference
with get_page_unless_zero. A discarded page is only freed after all
cpus have been enabled for interrupts at least once since the detection
of the discarded page. This is done using the timer interrupts and the
cpu-idle notifier. 

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

---

 arch/s390/Kconfig                   |    6 
 arch/s390/include/asm/page-states.h |  116 ++++++++++++++++++
 arch/s390/include/asm/page.h        |   11 -
 arch/s390/kernel/process.c          |    4 
 arch/s390/kernel/time.c             |    8 +
 arch/s390/kernel/traps.c            |    4 
 arch/s390/lib/uaccess_mvcos.c       |   10 -
 arch/s390/lib/uaccess_std.c         |    7 -
 arch/s390/mm/fault.c                |    1 
 arch/s390/mm/init.c                 |    3 
 arch/s390/mm/page-states.c          |  224 ++++++++++++++++++++++++++++++------
 mm/rmap.c                           |    9 +
 12 files changed, 346 insertions(+), 57 deletions(-)

Index: linux-2.6/arch/s390/Kconfig
===================================================================
--- linux-2.6.orig/arch/s390/Kconfig
+++ linux-2.6/arch/s390/Kconfig
@@ -468,11 +468,7 @@ config CMM_IUCV
 	  the cooperative memory management.
 
 config PAGE_STATES
-	bool "Unused page notification"
-	help
-	  This enables the notification of unused pages to the
-	  hypervisor. The ESSA instruction is used to do the states
-	  changes between a page that has content and the unused state.
+	bool "Enable support for guest page hinting."
 
 config APPLDATA_BASE
 	bool "Linux - VM Monitor Stream, base infrastructure"
Index: linux-2.6/arch/s390/include/asm/page-states.h
===================================================================
--- /dev/null
+++ linux-2.6/arch/s390/include/asm/page-states.h
@@ -0,0 +1,116 @@
+#ifndef _ASM_S390_PAGE_STATES_H
+#define _ASM_S390_PAGE_STATES_H
+
+#define ESSA_GET_STATE			0
+#define ESSA_SET_STABLE			1
+#define ESSA_SET_UNUSED			2
+#define ESSA_SET_VOLATILE		3
+#define ESSA_SET_PVOLATILE		4
+#define ESSA_SET_STABLE_MAKE_RESIDENT	5
+#define ESSA_SET_STABLE_IF_NOT_DISCARDED	6
+
+#define ESSA_USTATE_MASK		0x0c
+#define ESSA_USTATE_STABLE		0x00
+#define ESSA_USTATE_UNUSED		0x04
+#define ESSA_USTATE_PVOLATILE		0x08
+#define ESSA_USTATE_VOLATILE		0x0c
+
+#define ESSA_CSTATE_MASK		0x03
+#define ESSA_CSTATE_RESIDENT		0x00
+#define ESSA_CSTATE_PRESERVED		0x02
+#define ESSA_CSTATE_ZERO		0x03
+
+extern int cmma_flag;
+
+/*
+ * ESSA <rc-reg>,<page-address-reg>,<command-immediate>
+ */
+#define page_essa(_page,_command) ({		       \
+	int _rc; \
+	asm volatile(".insn rrf,0xb9ab0000,%0,%1,%2,0" \
+		     : "=&d" (_rc) : "a" (page_to_phys(_page)), \
+		       "i" (_command)); \
+	_rc; \
+})
+
+static inline int page_host_discards(void)
+{
+	return cmma_flag;
+}
+
+static inline int page_discarded(struct page *page)
+{
+	int state;
+
+	if (!cmma_flag)
+		return 0;
+	state = page_essa(page, ESSA_GET_STATE);
+	return (state & ESSA_USTATE_MASK) == ESSA_USTATE_VOLATILE &&
+		(state & ESSA_CSTATE_MASK) == ESSA_CSTATE_ZERO;
+}
+
+static inline void page_set_unused(struct page *page, int order)
+{
+	int i;
+
+	if (!cmma_flag)
+		return;
+	for (i = 0; i < (1 << order); i++)
+		page_essa(page + i, ESSA_SET_UNUSED);
+}
+
+static inline void page_set_stable(struct page *page, int order)
+{
+	int i;
+
+	if (!cmma_flag)
+		return;
+	for (i = 0; i < (1 << order); i++)
+		page_essa(page + i, ESSA_SET_STABLE);
+}
+
+static inline void page_set_volatile(struct page *page, int writable)
+{
+	if (!cmma_flag)
+		return;
+	if (writable)
+		page_essa(page, ESSA_SET_PVOLATILE);
+	else
+		page_essa(page, ESSA_SET_VOLATILE);
+}
+
+static inline int page_set_stable_if_present(struct page *page)
+{
+	int rc;
+
+	if (!cmma_flag || PageReserved(page))
+		return 1;
+
+	rc = page_essa(page, ESSA_SET_STABLE_IF_NOT_DISCARDED);
+	return (rc & ESSA_USTATE_MASK) != ESSA_USTATE_VOLATILE ||
+		(rc & ESSA_CSTATE_MASK) != ESSA_CSTATE_ZERO;
+}
+
+/*
+ * Page locking is done with the architecture page bit PG_arch_1.
+ */
+static inline int page_test_set_state_change(struct page *page)
+{
+	return test_and_set_bit(PG_arch_1, &page->flags);
+}
+
+static inline void page_clear_state_change(struct page *page)
+{
+	clear_bit(PG_arch_1, &page->flags);
+}
+
+static inline int page_state_change(struct page *page)
+{
+	return test_bit(PG_arch_1, &page->flags);
+}
+
+int page_free_discarded(struct page *page);
+void page_shrink_discard_list(void);
+void page_discard_init(void);
+
+#endif /* _ASM_S390_PAGE_STATES_H */
Index: linux-2.6/arch/s390/include/asm/page.h
===================================================================
--- linux-2.6.orig/arch/s390/include/asm/page.h
+++ linux-2.6/arch/s390/include/asm/page.h
@@ -125,17 +125,6 @@ page_get_storage_key(unsigned long addr)
 	return skey;
 }
 
-#ifdef CONFIG_PAGE_STATES
-
-struct page;
-void arch_free_page(struct page *page, int order);
-void arch_alloc_page(struct page *page, int order);
-
-#define HAVE_ARCH_FREE_PAGE
-#define HAVE_ARCH_ALLOC_PAGE
-
-#endif
-
 #endif /* !__ASSEMBLY__ */
 
 #define __PAGE_OFFSET           0x0UL
Index: linux-2.6/arch/s390/kernel/process.c
===================================================================
--- linux-2.6.orig/arch/s390/kernel/process.c
+++ linux-2.6/arch/s390/kernel/process.c
@@ -29,6 +29,7 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/user.h>
+#include <linux/page-states.h>
 #include <linux/interrupt.h>
 #include <linux/delay.h>
 #include <linux/reboot.h>
@@ -82,6 +83,9 @@ extern void s390_handle_mcck(void);
  */
 static void default_idle(void)
 {
+#ifdef CONFIG_PAGE_STATES
+	page_shrink_discard_list();
+#endif
 	/* CPU is going idle. */
 	local_irq_disable();
 	if (need_resched()) {
Index: linux-2.6/arch/s390/kernel/time.c
===================================================================
--- linux-2.6.orig/arch/s390/kernel/time.c
+++ linux-2.6/arch/s390/kernel/time.c
@@ -37,6 +37,7 @@
 #include <linux/clocksource.h>
 #include <linux/clockchips.h>
 #include <linux/bootmem.h>
+#include <linux/page-states.h>
 #include <asm/uaccess.h>
 #include <asm/delay.h>
 #include <asm/s390_ext.h>
@@ -137,6 +138,9 @@ static int s390_next_event(unsigned long
 static void s390_set_mode(enum clock_event_mode mode,
 			  struct clock_event_device *evt)
 {
+#ifdef CONFIG_PAGE_STATES
+	page_shrink_discard_list();
+#endif
 }
 
 /*
@@ -287,6 +291,10 @@ void __init time_init(void)
 					      &ext_int_etr_cc) != 0)
 		panic("Couldn't request external interrupt 0x1406");
 
+#ifdef CONFIG_PAGE_STATES
+	page_discard_init();
+#endif
+
 	/* Enable TOD clock interrupts on the boot cpu. */
 	init_cpu_timer();
 	/* Enable cpu timer interrupts on the boot cpu. */
Index: linux-2.6/arch/s390/kernel/traps.c
===================================================================
--- linux-2.6.orig/arch/s390/kernel/traps.c
+++ linux-2.6/arch/s390/kernel/traps.c
@@ -57,6 +57,7 @@ int sysctl_userprocess_debug = 0;
 extern pgm_check_handler_t do_protection_exception;
 extern pgm_check_handler_t do_dat_exception;
 extern pgm_check_handler_t do_asce_exception;
+extern pgm_check_handler_t do_discard_fault;
 
 #define stack_pointer ({ void **sp; asm("la %0,0(15)" : "=&d" (sp)); sp; })
 
@@ -761,5 +762,8 @@ void __init trap_init(void)
         pgm_check_table[0x15] = &operand_exception;
         pgm_check_table[0x1C] = &space_switch_exception;
         pgm_check_table[0x1D] = &hfp_sqrt_exception;
+#ifdef CONFIG_PAGE_STATES
+	pgm_check_table[0x1a] = &do_discard_fault;
+#endif
 	pfault_irq_init();
 }
Index: linux-2.6/arch/s390/lib/uaccess_mvcos.c
===================================================================
--- linux-2.6.orig/arch/s390/lib/uaccess_mvcos.c
+++ linux-2.6/arch/s390/lib/uaccess_mvcos.c
@@ -36,7 +36,7 @@ static size_t copy_from_user_mvcos(size_
 	tmp1 = -4096UL;
 	asm volatile(
 		"0: .insn ss,0xc80000000000,0(%0,%2),0(%1),0\n"
-		"   jz    7f\n"
+		"10:jz    7f\n"
 		"1:"ALR"  %0,%3\n"
 		"  "SLR"  %1,%3\n"
 		"  "SLR"  %2,%3\n"
@@ -47,7 +47,7 @@ static size_t copy_from_user_mvcos(size_
 		"  "CLR"  %0,%4\n"	/* copy crosses next page boundary? */
 		"   jnh   4f\n"
 		"3: .insn ss,0xc80000000000,0(%4,%2),0(%1),0\n"
-		"  "SLR"  %0,%4\n"
+		"11:"SLR"  %0,%4\n"
 		"  "ALR"  %2,%4\n"
 		"4:"LHI"  %4,-1\n"
 		"  "ALR"  %4,%0\n"	/* copy remaining size, subtract 1 */
@@ -62,6 +62,7 @@ static size_t copy_from_user_mvcos(size_
 		"7:"SLR"  %0,%0\n"
 		"8: \n"
 		EX_TABLE(0b,2b) EX_TABLE(3b,4b)
+		EX_TABLE(10b,8b) EX_TABLE(11b,8b)
 		: "+a" (size), "+a" (ptr), "+a" (x), "+a" (tmp1), "=a" (tmp2)
 		: "d" (reg0) : "cc", "memory");
 	return size;
@@ -82,7 +83,7 @@ static size_t copy_to_user_mvcos(size_t 
 	tmp1 = -4096UL;
 	asm volatile(
 		"0: .insn ss,0xc80000000000,0(%0,%1),0(%2),0\n"
-		"   jz    4f\n"
+		"6: jz    4f\n"
 		"1:"ALR"  %0,%3\n"
 		"  "SLR"  %1,%3\n"
 		"  "SLR"  %2,%3\n"
@@ -93,11 +94,12 @@ static size_t copy_to_user_mvcos(size_t 
 		"  "CLR"  %0,%4\n"	/* copy crosses next page boundary? */
 		"   jnh   5f\n"
 		"3: .insn ss,0xc80000000000,0(%4,%1),0(%2),0\n"
-		"  "SLR"  %0,%4\n"
+		"7:"SLR"  %0,%4\n"
 		"   j     5f\n"
 		"4:"SLR"  %0,%0\n"
 		"5: \n"
 		EX_TABLE(0b,2b) EX_TABLE(3b,5b)
+		EX_TABLE(6b,5b) EX_TABLE(7b,5b)
 		: "+a" (size), "+a" (ptr), "+a" (x), "+a" (tmp1), "=a" (tmp2)
 		: "d" (reg0) : "cc", "memory");
 	return size;
Index: linux-2.6/arch/s390/lib/uaccess_std.c
===================================================================
--- linux-2.6.orig/arch/s390/lib/uaccess_std.c
+++ linux-2.6/arch/s390/lib/uaccess_std.c
@@ -36,12 +36,12 @@ size_t copy_from_user_std(size_t size, c
 	tmp1 = -256UL;
 	asm volatile(
 		"0: mvcp  0(%0,%2),0(%1),%3\n"
-		"   jz    8f\n"
+		"10:jz    8f\n"
 		"1:"ALR"  %0,%3\n"
 		"   la    %1,256(%1)\n"
 		"   la    %2,256(%2)\n"
 		"2: mvcp  0(%0,%2),0(%1),%3\n"
-		"   jnz   1b\n"
+		"11:jnz   1b\n"
 		"   j     8f\n"
 		"3: la    %4,255(%1)\n"	/* %4 = ptr + 255 */
 		"  "LHI"  %3,-4096\n"
@@ -50,7 +50,7 @@ size_t copy_from_user_std(size_t size, c
 		"  "CLR"  %0,%4\n"	/* copy crosses next page boundary? */
 		"   jnh   5f\n"
 		"4: mvcp  0(%4,%2),0(%1),%3\n"
-		"  "SLR"  %0,%4\n"
+		"12:"SLR"  %0,%4\n"
 		"  "ALR"  %2,%4\n"
 		"5:"LHI"  %4,-1\n"
 		"  "ALR"  %4,%0\n"	/* copy remaining size, subtract 1 */
@@ -65,6 +65,7 @@ size_t copy_from_user_std(size_t size, c
 		"8:"SLR"  %0,%0\n"
 		"9: \n"
 		EX_TABLE(0b,3b) EX_TABLE(2b,3b) EX_TABLE(4b,5b)
+		EX_TABLE(10b,9b) EX_TABLE(11b,9b) EX_TABLE(12b,9b)
 		: "+a" (size), "+a" (ptr), "+a" (x), "+a" (tmp1), "=a" (tmp2)
 		: : "cc", "memory");
 	return size;
Index: linux-2.6/arch/s390/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/s390/mm/fault.c
+++ linux-2.6/arch/s390/mm/fault.c
@@ -611,4 +611,5 @@ void __init pfault_irq_init(void)
 	unregister_early_external_interrupt(0x2603, pfault_interrupt,
 					    &ext_int_pfault);
 }
+
 #endif
Index: linux-2.6/arch/s390/mm/init.c
===================================================================
--- linux-2.6.orig/arch/s390/mm/init.c
+++ linux-2.6/arch/s390/mm/init.c
@@ -94,6 +94,9 @@ void __init mem_init(void)
 	/* Setup guest page hinting */
 	cmma_init();
 
+	/* Setup guest page hinting */
+	cmma_init();
+
 	/* this will put all low memory onto the freelists */
 	totalram_pages += free_all_bootmem();
 
Index: linux-2.6/arch/s390/mm/page-states.c
===================================================================
--- linux-2.6.orig/arch/s390/mm/page-states.c
+++ linux-2.6/arch/s390/mm/page-states.c
@@ -13,67 +13,223 @@
 #include <linux/types.h>
 #include <linux/mm.h>
 #include <linux/init.h>
+#include <linux/cpu.h>
+#include <linux/module.h>
+#include <linux/uaccess.h>
+#include <linux/page-states.h>
+#include <linux/pagemap.h>
+#include <asm/io.h>
+
+extern void die(const char *,struct pt_regs *,long);
+
+#ifndef CONFIG_64BIT
+#define __FAIL_ADDR_MASK 0x7ffff000
+#else /* CONFIG_64BIT */
+#define __FAIL_ADDR_MASK -4096L
+#endif /* CONFIG_64BIT */
 
-#define ESSA_SET_STABLE		1
-#define ESSA_SET_UNUSED		2
+int cmma_flag;
 
-static int cmma_flag;
+void __init cmma_init(void)
+{
+	register unsigned long tmp asm("0") = 0;
+	register int rc asm("1") = -ENOSYS;
+	if (!cmma_flag)
+		return;
+	asm volatile(
+		"       .insn rrf,0xb9ab0000,%1,%1,0,0\n"
+		"0:     la      %0,0\n"
+		"1:\n"
+		EX_TABLE(0b,1b)
+		: "+&d" (rc), "+&d" (tmp));
+	if (rc)
+		cmma_flag = 0;
+}
 
 static int __init cmma(char *str)
 {
 	char *parm;
+
 	parm = strstrip(str);
 	if (strcmp(parm, "yes") == 0 || strcmp(parm, "on") == 0) {
 		cmma_flag = 1;
 		return 1;
 	}
-	cmma_flag = 0;
-	if (strcmp(parm, "no") == 0 || strcmp(parm, "off") == 0)
+	if (strcmp(parm, "no") == 0 || strcmp(parm, "off") == 0) {
+		cmma_flag = 0;
 		return 1;
+	}
 	return 0;
 }
 
 __setup("cmma=", cmma);
 
-void __init cmma_init(void)
+static inline void fixup_user_copy(struct pt_regs *regs,
+				   unsigned long address, unsigned short rx)
 {
-	register unsigned long tmp asm("0") = 0;
-	register int rc asm("1") = -EOPNOTSUPP;
+	const struct exception_table_entry *fixup;
+	unsigned long kaddr;
 
-	if (!cmma_flag)
+	kaddr = (regs->gprs[rx >> 12] + (rx & 0xfff)) & __FAIL_ADDR_MASK;
+	if (virt_to_phys((void *) kaddr) != address)
 		return;
-	asm volatile(
-		"       .insn rrf,0xb9ab0000,%1,%1,0,0\n"
-		"0:     la      %0,0\n"
-		"1:\n"
-		EX_TABLE(0b,1b)
-		: "+&d" (rc), "+&d" (tmp));
-	if (rc)
-		cmma_flag = 0;
+
+	fixup = search_exception_tables(regs->psw.addr & PSW_ADDR_INSN);
+	if (fixup)
+		regs->psw.addr = fixup->fixup | PSW_ADDR_AMODE;
+	else
+		die("discard fault", regs, SIGSEGV);
 }
 
-void arch_free_page(struct page *page, int order)
+/*
+ * Discarded pages with a page_count() of zero are placed on
+ * the page_discarded_list until all cpus have been at
+ * least once in enabled code. That closes the race of page
+ * free vs. discard faults.
+ */
+void do_discard_fault(struct pt_regs *regs, unsigned long error_code)
 {
-	int i, rc;
+	unsigned long address;
+	struct page *page;
 
-	if (!cmma_flag)
-		return;
-	for (i = 0; i < (1 << order); i++)
-		asm volatile(".insn rrf,0xb9ab0000,%0,%1,%2,0"
-			     : "=&d" (rc)
-			     : "a" ((page_to_pfn(page) + i) << PAGE_SHIFT),
-			       "i" (ESSA_SET_UNUSED));
+	/*
+	 * get the real address that caused the block validity
+	 * exception.
+	 */
+	address = S390_lowcore.trans_exc_code & __FAIL_ADDR_MASK;
+	page = pfn_to_page(address >> PAGE_SHIFT);
+
+	/*
+	 * Check for the special case of a discard fault in
+	 * copy_{from,to}_user. User copy is done using one of
+	 * three special instructions: mvcp, mvcs or mvcos.
+	 */
+	if (!(regs->psw.mask & PSW_MASK_PSTATE)) {
+		switch (*(unsigned char *) regs->psw.addr) {
+		case 0xda:	/* mvcp */
+			fixup_user_copy(regs, address,
+					*(__u16 *)(regs->psw.addr + 2));
+			break;
+		case 0xdb:	/* mvcs */
+			fixup_user_copy(regs, address,
+					*(__u16 *)(regs->psw.addr + 4));
+			break;
+		case 0xc8:	/* mvcos */
+			if (regs->gprs[0] == 0x81)
+				fixup_user_copy(regs, address,
+						*(__u16*)(regs->psw.addr + 2));
+			else if (regs->gprs[0] == 0x810000)
+				fixup_user_copy(regs, address,
+						*(__u16*)(regs->psw.addr + 4));
+			break;
+		default:
+			break;
+		}
+	}
+
+	if (likely(get_page_unless_zero(page))) {
+		local_irq_enable();
+		page_discard(page);
+	}
 }
 
-void arch_alloc_page(struct page *page, int order)
+static DEFINE_PER_CPU(struct list_head, page_discard_list);
+static struct list_head page_gather_list = LIST_HEAD_INIT(page_gather_list);
+static struct list_head page_signoff_list = LIST_HEAD_INIT(page_signoff_list);
+static cpumask_var_t page_signoff_cpumask;
+static DEFINE_SPINLOCK(page_discard_lock);
+
+/*
+ * page_free_discarded
+ *
+ * free_hot_cold_page calls this function if it is about to free a
+ * page that has PG_discarded set. Since there might be pending
+ * discard faults on other cpus on s390 we have to postpone the
+ * freeing of the page until each cpu has "signed-off" the page.
+ *
+ * returns 1 to stop free_hot_cold_page from freeing the page.
+ */
+int page_free_discarded(struct page *page)
 {
-	int i, rc;
+	local_irq_disable();
+	list_add_tail(&page->lru, &__get_cpu_var(page_discard_list));
+	local_irq_enable();
+	return 1;
+}
 
-	if (!cmma_flag)
+/*
+ * page_shrink_discard_list
+ *
+ * This function is called from the timer tick for an active cpu or
+ * from the idle notifier. It frees discarded pages in three stages.
+ * In the first stage it moves the pages from the per-cpu discard
+ * list to a global list. From the global list the pages are moved
+ * to the signoff list in a second step. The third step is to free
+ * the pages after all cpus acknoledged the signoff. That prevents
+ * that a page is freed when a cpus still has a pending discard
+ * fault for the page.
+ */
+void page_shrink_discard_list(void)
+{
+	struct list_head *cpu_list = &__get_cpu_var(page_discard_list);
+	struct list_head free_list = LIST_HEAD_INIT(free_list);
+	struct page *page, *next;
+	int cpu = smp_processor_id();
+	if (list_empty(cpu_list) &&
+	    !cpumask_test_cpu(cpu, page_signoff_cpumask))
 		return;
-	for (i = 0; i < (1 << order); i++)
-		asm volatile(".insn rrf,0xb9ab0000,%0,%1,%2,0"
-			     : "=&d" (rc)
-			     : "a" ((page_to_pfn(page) + i) << PAGE_SHIFT),
-			       "i" (ESSA_SET_STABLE));
+	spin_lock(&page_discard_lock);
+	if (!list_empty(cpu_list))
+		list_splice_init(cpu_list, &page_gather_list);
+	cpumask_clear_cpu(cpu, page_signoff_cpumask);
+	if (cpumask_empty(page_signoff_cpumask)) {
+		list_splice_init(&page_signoff_list, &free_list);
+		list_splice_init(&page_gather_list, &page_signoff_list);
+		if (!list_empty(&page_signoff_list)) {
+			/* Take care of the nohz race.. */
+			cpumask_copy(page_signoff_cpumask, &cpu_online_map);
+			smp_wmb();
+			cpumask_andnot(page_signoff_cpumask,
+				       page_signoff_cpumask, nohz_cpu_mask);
+			cpumask_clear_cpu(cpu, page_signoff_cpumask);
+			if (cpumask_empty(page_signoff_cpumask))
+				list_splice_init(&page_signoff_list,
+						 &free_list);
+		}
+	}
+	spin_unlock(&page_discard_lock);
+	list_for_each_entry_safe(page, next, &free_list, lru) {
+		ClearPageDiscarded(page);
+		free_cold_page(page);
+	}
+}
+
+static int page_discard_cpu_notify(struct notifier_block *self,
+				   unsigned long action, void *hcpu)
+{
+	int cpu = (unsigned long) hcpu;
+
+	if (action == CPU_DEAD) {
+		local_irq_disable();
+		list_splice_init(&per_cpu(page_discard_list, cpu),
+				 &__get_cpu_var(page_discard_list));
+		local_irq_enable();
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block page_discard_cpu_notifier = {
+	.notifier_call = page_discard_cpu_notify,
+};
+
+void __init page_discard_init(void)
+{
+	int i;
+
+	if (!alloc_cpumask_var(&page_signoff_cpumask, GFP_KERNEL))
+		panic("Couldn't allocate page_signoff_cpumask\n");
+	for_each_possible_cpu(i)
+		INIT_LIST_HEAD(&per_cpu(page_discard_list, i));
+	if (register_cpu_notifier(&page_discard_cpu_notifier))
+		panic("Couldn't register page discard cpu notifier");
 }
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -744,6 +744,15 @@ void page_remove_rmap(struct page *page)
 		 */
 		if ((!PageAnon(page) || PageSwapCache(page)) &&
 		    page_test_dirty(page)) {
+			int stable = page_make_stable(page);
+			VM_BUG_ON(!stable);
+			/*
+			 * We decremented the mapcount so we now have an
+			 * extra reference for the page. That prevents
+			 * page_make_volatile from making the page
+			 * volatile again while the dirty bit is in
+			 * transit.
+			 */
 			page_clear_dirty(page);
 			set_page_dirty(page);
 		}

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
