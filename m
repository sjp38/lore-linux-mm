Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7D07E5F0001
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 15:48:26 -0400 (EDT)
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id n3DJn9Re009636
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 12:49:09 -0700
Received: from an-out-0708.google.com (anab6.prod.google.com [10.100.53.6])
	by zps36.corp.google.com with ESMTP id n3DJn7Gn014105
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 12:49:07 -0700
Received: by an-out-0708.google.com with SMTP id b6so1497923ana.7
        for <linux-mm@kvack.org>; Mon, 13 Apr 2009 12:49:07 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 13 Apr 2009 12:49:07 -0700
Message-ID: <604427e00904131249y6db08065s1e4e516aca0ec137@mail.gmail.com>
Subject: [v4][PATCH 4/4]Enable FAULT_FLAG_RETRY into handle_mm_fault() callers
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>, torvalds@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Enable FAULT_FLAG_RETRY into handle_mm_fault() callers

This enables the FAULT_FLAG_RETRY on all arch handle_mm_fault()
callers.

Singed-off-by: Mike Waychison <mikew@google.com>
Signed-off-by: Ying Han <yinghan@google.com>
---

 arch/alpha/mm/fault.c                   |    7 +++++--
 arch/arm/mm/fault.c                     |    9 +++++----
 arch/avr32/mm/fault.c                   |    8 +++-----
 arch/cris/mm/fault.c                    |    5 +++--
 arch/frv/mm/fault.c                     |    7 +++----
 arch/ia64/mm/fault.c                    |    7 +++++--
 arch/m32r/mm/fault.c                    |    7 +++----
 arch/m68k/mm/fault.c                    |    8 ++++----
 arch/mips/mm/fault.c                    |    4 +++-
 arch/mn10300/mm/fault.c                 |    8 ++++----
 arch/parisc/mm/fault.c                  |    7 +++++--
 arch/powerpc/mm/fault.c                 |    9 +++++----
 arch/powerpc/platforms/cell/spu_fault.c |    4 +++-
 arch/s390/lib/uaccess_pt.c              |    5 +++--
 arch/s390/mm/fault.c                    |    4 +++-
 arch/sh/mm/fault_32.c                   |    5 +++--
 arch/sh/mm/tlbflush_64.c                |    5 +++--
 arch/sparc/mm/fault_32.c                |    4 +++-
 arch/sparc/mm/fault_64.c                |    6 ++++--
 arch/um/kernel/trap.c                   |    8 +++++---
 arch/x86/mm/fault.c                     |    8 ++++----
 arch/xtensa/mm/fault.c                  |    5 +++--
 22 files changed, 82 insertions(+), 58 deletions(-)


diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index 9dfa449..d362136 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -90,6 +90,10 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	const struct exception_table_entry *fixup;
 	int fault, si_code = SEGV_MAPERR;
 	siginfo_t info;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;
+
+	if (cause > 0)
+		fault_flags |= FAULT_FLAG_WRITE;

 	/* As of EV6, a load into $31/$f31 is a prefetch, and never faults
 	   (or is suppressed by the PALcode).  Support that for older CPUs
@@ -146,8 +150,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	/* If for any reason at all we couldn't handle the fault,
 	   make sure we exit gracefully rather than endlessly redo
 	   the fault.  */
-	fault = handle_mm_fault(mm, vma, address,
-			cause > 0 ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	up_read(&mm->mmap_sem);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 638335c..4e947d5 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -180,6 +180,7 @@ __do_page_fault(struct mm_struct *mm, unsigned long addr, un
 {
 	struct vm_area_struct *vma;
 	int fault, mask;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 	vma = find_vma(mm, addr);
 	fault = VM_FAULT_BADMAP;
@@ -193,9 +194,10 @@ __do_page_fault(struct mm_struct *mm, unsigned long addr, u
 	 * memory access, so we can handle it.
 	 */
 good_area:
-	if (fsr & (1 << 11)) /* write? */
+	if (fsr & (1 << 11)) { /* write? */
 		mask = VM_WRITE;
-	else
+		fault_flags |= FAULT_FLAG_WRITE;
+	} else
 		mask = VM_READ|VM_EXEC|VM_WRITE;

 	fault = VM_FAULT_BADACCESS;
@@ -208,8 +210,7 @@ good_area:
 	 * than endlessly redo the fault.
 	 */
 survive:
-	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK,
-			(fsr & (1 << 11)) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/avr32/mm/fault.c b/arch/avr32/mm/fault.c
index a53553e..1e1b949 100644
--- a/arch/avr32/mm/fault.c
+++ b/arch/avr32/mm/fault.c
@@ -61,10 +61,10 @@ asmlinkage void do_page_fault(unsigned long ecr, struct pt_r
 	const struct exception_table_entry *fixup;
 	unsigned long address;
 	unsigned long page;
-	int writeaccess;
 	long signr;
 	int code;
 	int fault;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 	if (notify_page_fault(regs, ecr))
 		return;
@@ -104,7 +104,6 @@ asmlinkage void do_page_fault(unsigned long ecr, struct pt_r
 	 */
 good_area:
 	code = SEGV_ACCERR;
-	writeaccess = 0;

 	switch (ecr) {
 	case ECR_PROTECTION_X:
@@ -121,7 +120,7 @@ good_area:
 	case ECR_TLB_MISS_W:
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
-		writeaccess = 1;
+		fault_flags |= FAULT_FLAG_WRITE;
 		break;
 	default:
 		panic("Unhandled case %lu in do_page_fault!", ecr);
@@ -133,8 +132,7 @@ good_area:
 	 * fault.
 	 */
 survive:
-	fault = handle_mm_fault(mm, vma, address,
-			writeaccess ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/cris/mm/fault.c b/arch/cris/mm/fault.c
index 59b01c7..fea30c0 100644
--- a/arch/cris/mm/fault.c
+++ b/arch/cris/mm/fault.c
@@ -58,6 +58,7 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	struct vm_area_struct * vma;
 	siginfo_t info;
 	int fault;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 	D(printk(KERN_DEBUG
 		 "Page fault for %lX on %X at %lX, prot %d write %d\n",
@@ -152,6 +153,7 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	} else if (writeaccess == 1) {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		fault_flags |= FAULT_FLAG_WRITE;
 	} else {
 		if (!(vma->vm_flags & (VM_READ | VM_EXEC)))
 			goto bad_area;
@@ -163,8 +165,7 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	 * the fault.
 	 */

-	fault = handle_mm_fault(mm, vma, address,
-			(writeaccess & 1) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/frv/mm/fault.c b/arch/frv/mm/fault.c
index 30f5d10..795bbe6 100644
--- a/arch/frv/mm/fault.c
+++ b/arch/frv/mm/fault.c
@@ -39,7 +39,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0,
 	pgd_t *pge;
 	pud_t *pue;
 	pte_t *pte;
-	int write;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;
 	int fault;

 #if 0
@@ -130,7 +130,6 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr
  */
  good_area:
 	info.si_code = SEGV_ACCERR;
-	write = 0;
 	switch (esr0 & ESR0_ATXC) {
 	default:
 		/* handle write to write protected page */
@@ -141,7 +140,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr
 #endif
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
-		write = 1;
+		fault_flags |= FAULT_FLAG_WRITE;
 		break;

 		 /* handle read from protected page */
@@ -163,7 +162,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, ear0, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, ear0, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 5add87f..6677cf9 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -80,6 +80,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr,
 	struct mm_struct *mm = current->mm;
 	struct siginfo si;
 	unsigned long mask;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;
 	int fault;

 	/* mmap_sem is performance critical.... */
@@ -148,14 +149,16 @@ ia64_do_page_fault (unsigned long address, unsigned long i
 	if ((vma->vm_flags & mask) != mask)
 		goto bad_area;

+	if (mask & VM_WRITE)
+		fault_flags |= FAULT_FLAG_WRITE;
+
   survive:
 	/*
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address,
-			(mask & VM_WRITE) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		/*
 		 * We ran out of memory, or some other thing happened
diff --git a/arch/m32r/mm/fault.c b/arch/m32r/mm/fault.c
index 7274b47..b066282 100644
--- a/arch/m32r/mm/fault.c
+++ b/arch/m32r/mm/fault.c
@@ -79,7 +79,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned l
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
 	unsigned long page, addr;
-	int write;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;
 	int fault;
 	siginfo_t info;

@@ -167,14 +167,13 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsign
  */
 good_area:
 	info.si_code = SEGV_ACCERR;
-	write = 0;
 	switch (error_code & (ACE_WRITE|ACE_PROTECTION)) {
 		default:	/* 3: write, present */
 			/* fall through */
 		case ACE_WRITE:	/* write, not present */
 			if (!(vma->vm_flags & VM_WRITE))
 				goto bad_area;
-			write++;
+			fault_flags |= FAULT_FLAG_WRITE;
 			break;
 		case ACE_PROTECTION:	/* read, present */
 		case 0:		/* read, not present */
@@ -196,7 +195,7 @@ survive:
 	 */
 	addr = (address & PAGE_MASK);
 	set_thread_fault_code(error_code);
-	fault = handle_mm_fault(mm, vma, addr, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, addr, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index d0e35cf..c694347 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -87,7 +87,8 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct * vma;
-	int write, fault;
+	int fault;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 #ifdef DEBUG
 	printk ("do page fault:\nregs->sr=%#x, regs->pc=%#lx, address=%#lx, %ld, %p\n"
@@ -132,14 +133,13 @@ good_area:
 #ifdef DEBUG
 	printk("do_page_fault: good_area\n");
 #endif
-	write = 0;
 	switch (error_code & 3) {
 		default:	/* 3: write, present */
 			/* fall through */
 		case 2:		/* write, not present */
 			if (!(vma->vm_flags & VM_WRITE))
 				goto acc_err;
-			write++;
+			fault_flags |= FAULT_FLAG_WRITE;
 			break;
 		case 1:		/* read, present */
 			goto acc_err;
@@ -155,7 +155,7 @@ good_area:
 	 */

  survive:
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 #ifdef DEBUG
 	printk("handle_mm_fault returns %d\n",fault);
 #endif
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 6751ce9..b2ff387 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -40,6 +40,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned l
 	const int field = sizeof(unsigned long) * 2;
 	siginfo_t info;
 	int fault;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 #if 0
 	printk("Cpu%d[%s:%d:%0*lx:%ld:%0*lx]\n", raw_smp_processor_id(),
@@ -92,6 +93,7 @@ good_area:
 	if (write) {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		fault_flags |= FAULT_FLAG_WRITE;
 	} else {
 		if (!(vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC)))
 			goto bad_area;
@@ -102,7 +104,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
index a62e1e1..1e22715 100644
--- a/arch/mn10300/mm/fault.c
+++ b/arch/mn10300/mm/fault.c
@@ -130,7 +130,8 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned
 	struct mm_struct *mm;
 	unsigned long page;
 	siginfo_t info;
-	int write, fault;
+	int fault;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 #ifdef CONFIG_GDBSTUB
 	/* handle GDB stub causing a fault */
@@ -227,7 +228,6 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned
  */
 good_area:
 	info.si_code = SEGV_ACCERR;
-	write = 0;
 	switch (fault_code & (MMUFCR_xFC_PGINVAL|MMUFCR_xFC_TYPE)) {
 	default:	/* 3: write, present */
 	case MMUFCR_xFC_TYPE_WRITE:
@@ -239,7 +239,7 @@ good_area:
 	case MMUFCR_xFC_PGINVAL | MMUFCR_xFC_TYPE_WRITE:
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
-		write++;
+		fault_flags |= FAULT_FLAG_WRITE;
 		break;

 		/* read from protected page */
@@ -258,7 +258,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index 987bbfe..04cd921 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -176,6 +176,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 	struct mm_struct *mm = tsk->mm;
 	unsigned long acc_type;
 	int fault;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 	if (in_atomic() || !mm)
 		goto no_context;
@@ -196,14 +197,16 @@ good_area:
 	if ((vma->vm_flags & acc_type) != acc_type)
 		goto bad_area;

+	if (acc_type & VM_WRITE)
+		fault_flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */

-	fault = handle_mm_fault(mm, vma, address,
-			(acc_type & VM_WRITE) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		/*
 		 * We hit a shared mapping outside of the file, or some
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 96a4aaf..4b04579 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -121,9 +121,10 @@ int __kprobes do_page_fault(struct pt_regs *regs, unsigned
 	struct mm_struct *mm = current->mm;
 	siginfo_t info;
 	int code = SEGV_MAPERR;
-	int is_write = 0, ret;
+	int ret;
 	int trap = TRAP(regs);
- 	int is_exec = trap == 0x400;
+	int is_exec = trap == 0x400;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 #if !(defined(CONFIG_4xx) || defined(CONFIG_BOOKE))
 	/*
@@ -296,6 +297,7 @@ good_area:
 	} else if (is_write) {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		fault_flags |= FAULT_FLAG_WRITE;
 	/* a read */
 	} else {
 		/* protection fault */
@@ -311,8 +313,7 @@ good_area:
 	 * the fault.
 	 */
  survive:
-	ret = handle_mm_fault(mm, vma, address,
-			is_write ? FAULT_FLAG_WRITE : 0);
+	ret = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(ret & VM_FAULT_ERROR)) {
 		if (ret & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/powerpc/platforms/cell/spu_fault.c b/arch/powerpc/platforms/ce
index 3b934a0..17a6d2e 100644
--- a/arch/powerpc/platforms/cell/spu_fault.c
+++ b/arch/powerpc/platforms/cell/spu_fault.c
@@ -38,6 +38,7 @@ int spu_handle_mm_fault(struct mm_struct *mm, unsigned long ea
 	struct vm_area_struct *vma;
 	unsigned long is_write;
 	int ret;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 #if 0
 	if (!IS_VALID_EA(ea)) {
@@ -66,6 +67,7 @@ good_area:
 	if (is_write) {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		fault_flags |= FAULT_FLAG_WRITE;
 	} else {
 		if (dsisr & MFC_DSISR_ACCESS_DENIED)
 			goto bad_area;
@@ -73,7 +75,7 @@ good_area:
 			goto bad_area;
 	}
 	ret = 0;
-	*flt = handle_mm_fault(mm, vma, ea, is_write ? FAULT_FLAG_WRITE : 0);
+	*flt = handle_mm_fault(mm, vma, ea, fault_flags);
 	if (unlikely(*flt & VM_FAULT_ERROR)) {
 		if (*flt & VM_FAULT_OOM) {
 			ret = -ENOMEM;
diff --git a/arch/s390/lib/uaccess_pt.c b/arch/s390/lib/uaccess_pt.c
index 4ee9d99..3133246 100644
--- a/arch/s390/lib/uaccess_pt.c
+++ b/arch/s390/lib/uaccess_pt.c
@@ -42,6 +42,7 @@ static int __handle_fault(struct mm_struct *mm, unsigned long
 	struct vm_area_struct *vma;
 	int ret = -EFAULT;
 	int fault;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 	if (in_atomic())
 		return ret;
@@ -63,11 +64,11 @@ static int __handle_fault(struct mm_struct *mm, unsigned lon
 	} else {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto out;
+		fault_flags |= FAULT_FLAG_WRITE;
 	}

 survive:
-	fault = handle_mm_fault(mm, vma, address,
-			write_access ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index f08f3c3..7604458 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -303,6 +303,7 @@ do_exception(struct pt_regs *regs, unsigned long error_code,
 	int space;
 	int si_code;
 	int fault;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 	if (notify_page_fault(regs, error_code))
 		return;
@@ -365,6 +366,7 @@ good_area:
 	} else {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		fault_flags |= FAULT_FLAG_WRITE;
 	}

 survive:
@@ -375,7 +377,7 @@ survive:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM) {
 			if (do_out_of_memory(regs, error_code, address))
diff --git a/arch/sh/mm/fault_32.c b/arch/sh/mm/fault_32.c
index 78d2f8c..3a2dc45 100644
--- a/arch/sh/mm/fault_32.c
+++ b/arch/sh/mm/fault_32.c
@@ -36,6 +36,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	int si_code;
 	int fault;
 	siginfo_t info;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 	/*
 	 * We don't bother with any notifier callbacks here, as they are
@@ -122,6 +123,7 @@ good_area:
 	if (writeaccess) {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		fault_flags |= FAULT_FLAG_WRITE;
 	} else {
 		if (!(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)))
 			goto bad_area;
@@ -133,8 +135,7 @@ good_area:
 	 * the fault.
 	 */
 survive:
-	fault = handle_mm_fault(mm, vma, address,
-			writeaccess ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sh/mm/tlbflush_64.c b/arch/sh/mm/tlbflush_64.c
index 5ee5d95..0bfddca 100644
--- a/arch/sh/mm/tlbflush_64.c
+++ b/arch/sh/mm/tlbflush_64.c
@@ -97,6 +97,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned l
 	const struct exception_table_entry *fixup;
 	pte_t *pte;
 	int fault;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 	/* SIM
 	 * Note this is now called with interrupts still disabled
@@ -175,6 +176,7 @@ good_area:
 		if (writeaccess) {
 			if (!(vma->vm_flags & VM_WRITE))
 				goto bad_area;
+			fault_flags |= FAULT_FLAG_WRITE;
 		} else {
 			if (!(vma->vm_flags & VM_READ))
 				goto bad_area;
@@ -187,8 +189,7 @@ good_area:
 	 * the fault.
 	 */
 survive:
-	fault = handle_mm_fault(mm, vma, address,
-			writeaccess ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index 69ca75e..79a1a1f 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -178,6 +178,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int tex
 	siginfo_t info;
 	int from_user = !(regs->psr & PSR_PS);
 	int fault;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 	if(text_fault)
 		address = regs->pc;
@@ -230,6 +231,7 @@ good_area:
 	if(write) {
 		if(!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		fault_flags |= FAULT_FLAG_WRITE;
 	} else {
 		/* Allow reads even for write-only mappings */
 		if(!(vma->vm_flags & (VM_READ | VM_EXEC)))
@@ -241,7 +243,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 539e829..baf9f54 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -256,6 +256,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *r
 	unsigned int insn = 0;
 	int si_code, fault_code, fault;
 	unsigned long address, mm_rss;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 	fault_code = get_thread_fault_code();

@@ -384,6 +385,8 @@ good_area:
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;

+		fault_flags |= FAULT_FLAG_WRITE;
+
 		/* Spitfire has an icache which does not snoop
 		 * processor stores.  Later processors do...
 		 */
@@ -398,8 +401,7 @@ good_area:
 			goto bad_area;
 	}

-	fault = handle_mm_fault(mm, vma, address,
-			(fault_code & FAULT_CODE_WRITE) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index 87d7a5e..9c79620 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -29,6 +29,7 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;
 	int err = -EFAULT;

 	*code_out = SEGV_MAPERR;
@@ -55,8 +56,10 @@ int handle_page_fault(unsigned long address, unsigned long ip

 good_area:
 	*code_out = SEGV_ACCERR;
-	if (is_write && !(vma->vm_flags & VM_WRITE))
+	if (is_write && !(vma->vm_flags & VM_WRITE)) {
 		goto out;
+		fault_flags |= FAULT_FLAG_WRITE;
+	}

 	/* Don't require VM_READ|VM_EXEC for write faults! */
 	if (!is_write && !(vma->vm_flags & (VM_READ | VM_EXEC)))
@@ -65,8 +68,7 @@ good_area:
 	do {
 		int fault;

-		fault = handle_mm_fault(mm, vma, address,
-				is_write ? FAULT_FLAG_WRITE : 0);
+		fault = handle_mm_fault(mm, vma, address, fault_flags);
 		if (unlikely(fault & VM_FAULT_ERROR)) {
 			if (fault & VM_FAULT_OOM) {
 				goto out_of_memory;
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 63c1427..a7f039e 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -587,12 +587,13 @@ void __kprobes do_page_fault(struct pt_regs *regs, unsigne
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	unsigned long address;
-	int write, si_code;
+	int si_code;
 	int fault;
 #ifdef CONFIG_X86_64
 	unsigned long flags;
 	int sig;
 #endif
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 	tsk = current;
 	mm = tsk->mm;
@@ -719,14 +720,13 @@ void __kprobes do_page_fault(struct pt_regs *regs, unsigne
  */
 good_area:
 	si_code = SEGV_ACCERR;
-	write = 0;
 	switch (error_code & (PF_PROT|PF_WRITE)) {
 	default:	/* 3: write, present */
 		/* fall through */
 	case PF_WRITE:		/* write, not present */
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
-		write++;
+		fault_flags |= FAULT_FLAG_WRITE;
 		break;
 	case PF_PROT:		/* read, present */
 		goto bad_area;
@@ -740,7 +740,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index abea2d7..fee3e00 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -45,6 +45,7 @@ void do_page_fault(struct pt_regs *regs)

 	int is_write, is_exec;
 	int fault;
+	unsigned int fault_flags = FAULT_FLAG_RETRY;

 	info.si_code = SEGV_MAPERR;

@@ -94,6 +95,7 @@ good_area:
 	if (is_write) {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		fault_flags |= FAULT_FLAG_WRITE;
 	} else if (is_exec) {
 		if (!(vma->vm_flags & VM_EXEC))
 			goto bad_area;
@@ -106,8 +108,7 @@ good_area:
 	 * the fault.
 	 */
 survive:
-	fault = handle_mm_fault(mm, vma, address,
-			is_write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
