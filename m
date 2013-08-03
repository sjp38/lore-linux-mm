Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 663826B0037
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 13:00:36 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/7] arch: mm: pass userspace fault flag to generic fault handler
Date: Sat,  3 Aug 2013 12:59:56 -0400
Message-Id: <1375549200-19110-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>
References: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Unlike global OOM handling, memory cgroup code will invoke the OOM
killer in any OOM situation because it has no way of telling faults
occuring in kernel context - which could be handled more gracefully -
from user-triggered faults.

Pass a flag that identifies faults originating in user space from the
architecture-specific fault handlers to generic code so that memcg OOM
handling can be improved.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 arch/alpha/mm/fault.c      |  7 ++++---
 arch/arc/mm/fault.c        |  6 ++++--
 arch/arm/mm/fault.c        |  9 ++++++---
 arch/arm64/mm/fault.c      |  9 ++++++---
 arch/avr32/mm/fault.c      |  2 ++
 arch/cris/mm/fault.c       |  6 ++++--
 arch/frv/mm/fault.c        | 10 ++++++----
 arch/hexagon/mm/vm_fault.c |  6 ++++--
 arch/ia64/mm/fault.c       |  6 ++++--
 arch/m32r/mm/fault.c       | 10 ++++++----
 arch/m68k/mm/fault.c       |  2 ++
 arch/metag/mm/fault.c      |  6 ++++--
 arch/microblaze/mm/fault.c |  7 +++++--
 arch/mips/mm/fault.c       |  6 ++++--
 arch/mn10300/mm/fault.c    |  2 ++
 arch/openrisc/mm/fault.c   |  1 +
 arch/parisc/mm/fault.c     |  7 +++++--
 arch/powerpc/mm/fault.c    |  7 ++++---
 arch/s390/mm/fault.c       |  2 ++
 arch/score/mm/fault.c      |  7 ++++++-
 arch/sh/mm/fault.c         |  9 ++++++---
 arch/sparc/mm/fault_32.c   | 12 +++++++++---
 arch/sparc/mm/fault_64.c   |  8 +++++---
 arch/tile/mm/fault.c       |  7 +++++--
 arch/um/kernel/trap.c      | 20 ++++++++++++--------
 arch/unicore32/mm/fault.c  |  8 ++++++--
 arch/x86/mm/fault.c        |  8 +++++---
 arch/xtensa/mm/fault.c     |  2 ++
 include/linux/mm.h         |  1 +
 29 files changed, 132 insertions(+), 61 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index 0c4132d..98838a0 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -89,8 +89,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	const struct exception_table_entry *fixup;
 	int fault, si_code = SEGV_MAPERR;
 	siginfo_t info;
-	unsigned int flags = (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-			      (cause > 0 ? FAULT_FLAG_WRITE : 0));
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	/* As of EV6, a load into $31/$f31 is a prefetch, and never faults
 	   (or is suppressed by the PALcode).  Support that for older CPUs
@@ -115,7 +114,8 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	if (address >= TASK_SIZE)
 		goto vmalloc_fault;
 #endif
-
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
 retry:
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, address);
@@ -142,6 +142,7 @@ retry:
 	} else {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		flags |= FAULT_FLAG_WRITE;
 	}
 
 	/* If for any reason at all we couldn't handle the fault,
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index 6b0bb41..d63f3de 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -60,8 +60,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address)
 	siginfo_t info;
 	int fault, ret;
 	int write = regs->ecr_cause & ECR_C_PROTV_STORE;  /* ST/EX */
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-				(write ? FAULT_FLAG_WRITE : 0);
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	/*
 	 * We fault-in kernel-space virtual memory on-demand. The
@@ -89,6 +88,8 @@ void do_page_fault(struct pt_regs *regs, unsigned long address)
 	if (in_atomic() || !mm)
 		goto no_context;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
 retry:
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, address);
@@ -117,6 +118,7 @@ good_area:
 	if (write) {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		flags |= FAULT_FLAG_WRITE;
 	} else {
 		if (!(vma->vm_flags & (VM_READ | VM_EXEC)))
 			goto bad_area;
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 217bcbf..eb8830a 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -261,9 +261,7 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	int fault, sig, code;
-	int write = fsr & FSR_WRITE;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-				(write ? FAULT_FLAG_WRITE : 0);
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	if (notify_page_fault(regs, fsr))
 		return 0;
@@ -282,6 +280,11 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	if (in_atomic() || !mm)
 		goto no_context;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (fsr & FSR_WRITE)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * As per x86, we may deadlock here.  However, since the kernel only
 	 * validly references user space from well defined areas of the code,
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index dab1cfd..12205b4 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -208,9 +208,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	int fault, sig, code;
-	bool write = (esr & ESR_WRITE) && !(esr & ESR_CM);
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-		(write ? FAULT_FLAG_WRITE : 0);
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	tsk = current;
 	mm  = tsk->mm;
@@ -226,6 +224,11 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 	if (in_atomic() || !mm)
 		goto no_context;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if ((esr & ESR_WRITE) && !(esr & ESR_CM))
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * As per x86, we may deadlock here. However, since the kernel only
 	 * validly references user space from well defined areas of the code,
diff --git a/arch/avr32/mm/fault.c b/arch/avr32/mm/fault.c
index 2ca27b0..0eca933 100644
--- a/arch/avr32/mm/fault.c
+++ b/arch/avr32/mm/fault.c
@@ -86,6 +86,8 @@ asmlinkage void do_page_fault(unsigned long ecr, struct pt_regs *regs)
 
 	local_irq_enable();
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
 retry:
 	down_read(&mm->mmap_sem);
 
diff --git a/arch/cris/mm/fault.c b/arch/cris/mm/fault.c
index 73312ab..1790f22 100644
--- a/arch/cris/mm/fault.c
+++ b/arch/cris/mm/fault.c
@@ -58,8 +58,7 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	struct vm_area_struct * vma;
 	siginfo_t info;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-				((writeaccess & 1) ? FAULT_FLAG_WRITE : 0);
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	D(printk(KERN_DEBUG
 		 "Page fault for %lX on %X at %lX, prot %d write %d\n",
@@ -117,6 +116,8 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	if (in_atomic() || !mm)
 		goto no_context;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
 retry:
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, address);
@@ -155,6 +156,7 @@ retry:
 	} else if (writeaccess == 1) {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		flags |= FAULT_FLAG_WRITE;
 	} else {
 		if (!(vma->vm_flags & (VM_READ | VM_EXEC)))
 			goto bad_area;
diff --git a/arch/frv/mm/fault.c b/arch/frv/mm/fault.c
index 331c1e2..9a66372 100644
--- a/arch/frv/mm/fault.c
+++ b/arch/frv/mm/fault.c
@@ -34,11 +34,11 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
 	struct vm_area_struct *vma;
 	struct mm_struct *mm;
 	unsigned long _pme, lrai, lrad, fixup;
+	unsigned long flags = 0;
 	siginfo_t info;
 	pgd_t *pge;
 	pud_t *pue;
 	pte_t *pte;
-	int write;
 	int fault;
 
 #if 0
@@ -81,6 +81,9 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
 	if (in_atomic() || !mm)
 		goto no_context;
 
+	if (user_mode(__frame))
+		flags |= FAULT_FLAG_USER;
+
 	down_read(&mm->mmap_sem);
 
 	vma = find_vma(mm, ear0);
@@ -129,7 +132,6 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
  */
  good_area:
 	info.si_code = SEGV_ACCERR;
-	write = 0;
 	switch (esr0 & ESR0_ATXC) {
 	default:
 		/* handle write to write protected page */
@@ -140,7 +142,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
 #endif
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
-		write = 1;
+		flags |= FAULT_FLAG_WRITE;
 		break;
 
 		 /* handle read from protected page */
@@ -162,7 +164,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, ear0, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, ear0, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index 1bd276d..8704c93 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -53,8 +53,7 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 	int si_code = SEGV_MAPERR;
 	int fault;
 	const struct exception_table_entry *fixup;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-				 (cause > 0 ? FAULT_FLAG_WRITE : 0);
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	/*
 	 * If we're in an interrupt or have no user context,
@@ -65,6 +64,8 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 
 	local_irq_enable();
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
 retry:
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, address);
@@ -96,6 +97,7 @@ good_area:
 	case FLT_STORE:
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		flags |= FAULT_FLAG_WRITE;
 		break;
 	}
 
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 6cf0341..7225dad 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -90,8 +90,6 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	mask = ((((isr >> IA64_ISR_X_BIT) & 1UL) << VM_EXEC_BIT)
 		| (((isr >> IA64_ISR_W_BIT) & 1UL) << VM_WRITE_BIT));
 
-	flags |= ((mask & VM_WRITE) ? FAULT_FLAG_WRITE : 0);
-
 	/* mmap_sem is performance critical.... */
 	prefetchw(&mm->mmap_sem);
 
@@ -119,6 +117,10 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	if (notify_page_fault(regs, TRAP_BRKPT))
 		return;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (mask & VM_WRITE)
+		flags |= FAULT_FLAG_WRITE;
 retry:
 	down_read(&mm->mmap_sem);
 
diff --git a/arch/m32r/mm/fault.c b/arch/m32r/mm/fault.c
index 3cdfa9c..e9c6a80 100644
--- a/arch/m32r/mm/fault.c
+++ b/arch/m32r/mm/fault.c
@@ -78,7 +78,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
 	unsigned long page, addr;
-	int write;
+	unsigned long flags = 0;
 	int fault;
 	siginfo_t info;
 
@@ -117,6 +117,9 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	if (in_atomic() || !mm)
 		goto bad_area_nosemaphore;
 
+	if (error_code & ACE_USERMODE)
+		flags |= FAULT_FLAG_USER;
+
 	/* When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in the
 	 * kernel and should generate an OOPS.  Unfortunately, in the case of an
@@ -166,14 +169,13 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long error_code,
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
+			flags |= FAULT_FLAG_WRITE;
 			break;
 		case ACE_PROTECTION:	/* read, present */
 		case 0:		/* read, not present */
@@ -194,7 +196,7 @@ good_area:
 	 */
 	addr = (address & PAGE_MASK);
 	set_thread_fault_code(error_code);
-	fault = handle_mm_fault(mm, vma, addr, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, addr, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index a563727..eb1d61f 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -88,6 +88,8 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	if (in_atomic() || !mm)
 		goto no_context;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
 retry:
 	down_read(&mm->mmap_sem);
 
diff --git a/arch/metag/mm/fault.c b/arch/metag/mm/fault.c
index 8fddf46..332680e 100644
--- a/arch/metag/mm/fault.c
+++ b/arch/metag/mm/fault.c
@@ -53,8 +53,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	struct vm_area_struct *vma, *prev_vma;
 	siginfo_t info;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-				(write_access ? FAULT_FLAG_WRITE : 0);
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	tsk = current;
 
@@ -109,6 +108,8 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	if (in_atomic() || !mm)
 		goto no_context;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
 retry:
 	down_read(&mm->mmap_sem);
 
@@ -121,6 +122,7 @@ good_area:
 	if (write_access) {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		flags |= FAULT_FLAG_WRITE;
 	} else {
 		if (!(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)))
 			goto bad_area;
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index 731f739..fa4cf52 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -92,8 +92,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	int code = SEGV_MAPERR;
 	int is_write = error_code & ESR_S;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-					 (is_write ? FAULT_FLAG_WRITE : 0);
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	regs->ear = address;
 	regs->esr = error_code;
@@ -121,6 +120,9 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 		die("Weird page fault", regs, SIGSEGV);
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+
 	/* When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in the
 	 * kernel and should generate an OOPS.  Unfortunately, in the case of an
@@ -199,6 +201,7 @@ good_area:
 	if (unlikely(is_write)) {
 		if (unlikely(!(vma->vm_flags & VM_WRITE)))
 			goto bad_area;
+		flags |= FAULT_FLAG_WRITE;
 	/* a read */
 	} else {
 		/* protection fault */
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 94d3a31..becc42b 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -42,8 +42,7 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	const int field = sizeof(unsigned long) * 2;
 	siginfo_t info;
 	int fault;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-						 (write ? FAULT_FLAG_WRITE : 0);
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 #if 0
 	printk("Cpu%d[%s:%d:%0*lx:%ld:%0*lx]\n", raw_smp_processor_id(),
@@ -93,6 +92,8 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	if (in_atomic() || !mm)
 		goto bad_area_nosemaphore;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
 retry:
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, address);
@@ -114,6 +115,7 @@ good_area:
 	if (write) {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		flags |= FAULT_FLAG_WRITE;
 	} else {
 		if (cpu_has_rixi) {
 			if (address == regs->cp0_epc && !(vma->vm_flags & VM_EXEC)) {
diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
index 8a2e6de..3516cbd 100644
--- a/arch/mn10300/mm/fault.c
+++ b/arch/mn10300/mm/fault.c
@@ -171,6 +171,8 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long fault_code,
 	if (in_atomic() || !mm)
 		goto no_context;
 
+	if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR)
+		flags |= FAULT_FLAG_USER;
 retry:
 	down_read(&mm->mmap_sem);
 
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index 4a41f84..0703acf 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -86,6 +86,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 	if (user_mode(regs)) {
 		/* Exception was in userspace: reenable interrupts */
 		local_irq_enable();
+		flags |= FAULT_FLAG_USER;
 	} else {
 		/* If exception was in a syscall, then IRQ's may have
 		 * been enabled or disabled.  If they were enabled,
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index f247a34..d10d27a 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -180,6 +180,10 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 	if (in_atomic() || !mm)
 		goto no_context;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (acc_type & VM_WRITE)
+		flags |= FAULT_FLAG_WRITE;
 retry:
 	down_read(&mm->mmap_sem);
 	vma = find_vma_prev(mm, address, &prev_vma);
@@ -203,8 +207,7 @@ good_area:
 	 * fault.
 	 */
 
-	fault = handle_mm_fault(mm, vma, address,
-			flags | ((acc_type & VM_WRITE) ? FAULT_FLAG_WRITE : 0));
+	fault = handle_mm_fault(mm, vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 8726779..d9196c9 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -223,9 +223,6 @@ int __kprobes do_page_fault(struct pt_regs *regs, unsigned long address,
 	is_write = error_code & ESR_DST;
 #endif /* CONFIG_4xx || CONFIG_BOOKE */
 
-	if (is_write)
-		flags |= FAULT_FLAG_WRITE;
-
 #ifdef CONFIG_PPC_ICSWX
 	/*
 	 * we need to do this early because this "data storage
@@ -280,6 +277,9 @@ int __kprobes do_page_fault(struct pt_regs *regs, unsigned long address,
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+
 	/* When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in the
 	 * kernel and should generate an OOPS.  Unfortunately, in the case of an
@@ -408,6 +408,7 @@ good_area:
 	} else if (is_write) {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		flags |= FAULT_FLAG_WRITE;
 	/* a read */
 	} else {
 		/* protection fault */
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index f00aefb..35b81d6 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -302,6 +302,8 @@ static inline int do_exception(struct pt_regs *regs, int access)
 	address = trans_exc_code & __FAIL_ADDR_MASK;
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
 	flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
 	if (access == VM_WRITE || (trans_exc_code & store_indication) == 0x400)
 		flags |= FAULT_FLAG_WRITE;
 	down_read(&mm->mmap_sem);
diff --git a/arch/score/mm/fault.c b/arch/score/mm/fault.c
index 4b71a62..52238983 100644
--- a/arch/score/mm/fault.c
+++ b/arch/score/mm/fault.c
@@ -47,6 +47,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long write,
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
 	const int field = sizeof(unsigned long) * 2;
+	unsigned long flags = 0;
 	siginfo_t info;
 	int fault;
 
@@ -75,6 +76,9 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long write,
 	if (in_atomic() || !mm)
 		goto bad_area_nosemaphore;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, address);
 	if (!vma)
@@ -95,6 +99,7 @@ good_area:
 	if (write) {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		flags |= FAULT_FLAG_WRITE;
 	} else {
 		if (!(vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC)))
 			goto bad_area;
@@ -105,7 +110,7 @@ good_area:
 	* make sure we exit gracefully rather than endlessly redo
 	* the fault.
 	*/
-	fault = handle_mm_fault(mm, vma, address, write);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index 1f49c28..541dc61 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -400,9 +400,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
 	int fault;
-	int write = error_code & FAULT_CODE_WRITE;
-	unsigned int flags = (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-			      (write ? FAULT_FLAG_WRITE : 0));
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -476,6 +474,11 @@ good_area:
 
 	set_thread_fault_code(error_code);
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (error_code & FAULT_CODE_WRITE)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index e98bfda..59dbd46 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -177,8 +177,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 	unsigned long g2;
 	int from_user = !(regs->psr & PSR_PS);
 	int fault, code;
-	unsigned int flags = (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-			      (write ? FAULT_FLAG_WRITE : 0));
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	if (text_fault)
 		address = regs->pc;
@@ -235,6 +234,11 @@ good_area:
 			goto bad_area;
 	}
 
+	if (from_user)
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
@@ -383,6 +387,7 @@ static void force_user_fault(unsigned long address, int write)
 	struct vm_area_struct *vma;
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
+	unsigned int flags = FAULT_FLAG_USER;
 	int code;
 
 	code = SEGV_MAPERR;
@@ -402,11 +407,12 @@ good_area:
 	if (write) {
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		flags |= FAULT_FLAG_WRITE;
 	} else {
 		if (!(vma->vm_flags & (VM_READ | VM_EXEC)))
 			goto bad_area;
 	}
-	switch (handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0)) {
+	switch (handle_mm_fault(mm, vma, address, flags)) {
 	case VM_FAULT_SIGBUS:
 	case VM_FAULT_OOM:
 		goto do_sigbus;
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 5062ff3..c08b9bb 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -314,8 +314,9 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 		} else {
 			bad_kernel_pc(regs, address);
 			return;
-		}
-	}
+		}		
+	} else
+		flags |= FAULT_FLAG_USER;
 
 	/*
 	 * If we're in an interrupt or have no user
@@ -418,13 +419,14 @@ good_area:
 		    vma->vm_file != NULL)
 			set_thread_fault_code(fault_code |
 					      FAULT_CODE_BLKCOMMIT);
+
+		flags |= FAULT_FLAG_WRITE;
 	} else {
 		/* Allow reads even for write-only mappings */
 		if (!(vma->vm_flags & (VM_READ | VM_EXEC)))
 			goto bad_area;
 	}
 
-	flags |= ((fault_code & FAULT_CODE_WRITE) ? FAULT_FLAG_WRITE : 0);
 	fault = handle_mm_fault(mm, vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
diff --git a/arch/tile/mm/fault.c b/arch/tile/mm/fault.c
index ac553ee..3ff289f 100644
--- a/arch/tile/mm/fault.c
+++ b/arch/tile/mm/fault.c
@@ -280,8 +280,7 @@ static int handle_page_fault(struct pt_regs *regs,
 	if (!is_page_fault)
 		write = 1;
 
-	flags = (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-		 (write ? FAULT_FLAG_WRITE : 0));
+	flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	is_kernel_mode = (EX1_PL(regs->ex1) != USER_PL);
 
@@ -365,6 +364,9 @@ static int handle_page_fault(struct pt_regs *regs,
 		goto bad_area_nosemaphore;
 	}
 
+	if (!is_kernel_mode)
+		flags |= FAULT_FLAG_USER;
+
 	/*
 	 * When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in the
@@ -425,6 +427,7 @@ good_area:
 #endif
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
+		flags |= FAULT_FLAG_WRITE;
 	} else {
 		if (!is_page_fault || !(vma->vm_flags & VM_READ))
 			goto bad_area;
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index b2f5adf..5c3aef7 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -30,8 +30,7 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 	pmd_t *pmd;
 	pte_t *pte;
 	int err = -EFAULT;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-				 (is_write ? FAULT_FLAG_WRITE : 0);
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	*code_out = SEGV_MAPERR;
 
@@ -42,6 +41,8 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 	if (in_atomic())
 		goto out_nosemaphore;
 
+	if (is_user)
+		flags |= FAULT_FLAG_USER;
 retry:
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, address);
@@ -58,12 +59,15 @@ retry:
 
 good_area:
 	*code_out = SEGV_ACCERR;
-	if (is_write && !(vma->vm_flags & VM_WRITE))
-		goto out;
-
-	/* Don't require VM_READ|VM_EXEC for write faults! */
-	if (!is_write && !(vma->vm_flags & (VM_READ | VM_EXEC)))
-		goto out;
+	if (is_write) {
+		if (!(vma->vm_flags & VM_WRITE))
+			goto out;
+		flags |= FAULT_FLAG_WRITE;
+	} else {
+		/* Don't require VM_READ|VM_EXEC for write faults! */
+		if (!(vma->vm_flags & (VM_READ | VM_EXEC)))
+			goto out;
+	}
 
 	do {
 		int fault;
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 8ed3c45..0dc922d 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -209,8 +209,7 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	int fault, sig, code;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-				 ((!(fsr ^ 0x12)) ? FAULT_FLAG_WRITE : 0);
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -222,6 +221,11 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	if (in_atomic() || !mm)
 		goto no_context;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (!(fsr ^ 0x12))
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * As per x86, we may deadlock here.  However, since the kernel only
 	 * validly references user space from well defined areas of the code,
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 654be4a..6d77c38 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1011,9 +1011,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	unsigned long address;
 	struct mm_struct *mm;
 	int fault;
-	int write = error_code & PF_WRITE;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-					(write ? FAULT_FLAG_WRITE : 0);
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1083,6 +1081,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	if (user_mode_vm(regs)) {
 		local_irq_enable();
 		error_code |= PF_USER;
+		flags |= FAULT_FLAG_USER;
 	} else {
 		if (regs->flags & X86_EFLAGS_IF)
 			local_irq_enable();
@@ -1109,6 +1108,9 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code)
 		return;
 	}
 
+	if (error_code & PF_WRITE)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index 4b7bc8d..70fa7bc 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -72,6 +72,8 @@ void do_page_fault(struct pt_regs *regs)
 	       address, exccause, regs->pc, is_write? "w":"", is_exec? "x":"");
 #endif
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
 retry:
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, address);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d5c82dc..c51fc32 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -170,6 +170,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
 #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
 #define FAULT_FLAG_TRIED	0x40	/* second try */
+#define FAULT_FLAG_USER		0x80	/* The fault originated in userspace */
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
