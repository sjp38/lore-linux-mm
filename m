Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 4E7246B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 00:24:30 -0400 (EDT)
Date: Fri, 19 Jul 2013 00:24:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/5] mm: pass userspace fault flag to generic fault handler
Message-ID: <20130719042424.GE17812@cmpxchg.org>
References: <20130710182506.F25DF461@pobox.sk>
 <20130711072507.GA21667@dhcp22.suse.cz>
 <20130714012641.C2DA4E05@pobox.sk>
 <20130714015112.FFCB7AF7@pobox.sk>
 <20130715154119.GA32435@dhcp22.suse.cz>
 <20130715160006.GB32435@dhcp22.suse.cz>
 <20130716153544.GX17812@cmpxchg.org>
 <20130716160905.GA20018@dhcp22.suse.cz>
 <20130716164830.GZ17812@cmpxchg.org>
 <20130719042124.GC17812@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130719042124.GC17812@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com

The global OOM killer is (XXX: for most architectures) only invoked
for userspace faults, not for faults from kernelspace (uaccess, gup).

Memcg OOM handling is currently invoked for all faults.  Allow it to
behave like the global case by having the architectures pass a flag to
the generic fault handler code that identifies userspace faults.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/alpha/mm/fault.c      |  8 +++++++-
 arch/arm/mm/fault.c        | 12 +++++++++---
 arch/avr32/mm/fault.c      |  8 +++++++-
 arch/cris/mm/fault.c       |  8 +++++++-
 arch/frv/mm/fault.c        |  8 +++++++-
 arch/hexagon/mm/vm_fault.c |  8 +++++++-
 arch/ia64/mm/fault.c       |  8 +++++++-
 arch/m32r/mm/fault.c       |  8 +++++++-
 arch/m68k/mm/fault.c       |  8 +++++++-
 arch/microblaze/mm/fault.c |  8 +++++++-
 arch/mips/mm/fault.c       |  8 +++++++-
 arch/mn10300/mm/fault.c    |  8 +++++++-
 arch/openrisc/mm/fault.c   |  8 +++++++-
 arch/parisc/mm/fault.c     |  8 +++++++-
 arch/powerpc/mm/fault.c    |  8 +++++++-
 arch/s390/mm/fault.c       |  2 ++
 arch/score/mm/fault.c      |  7 ++++++-
 arch/sh/mm/fault_32.c      |  8 +++++++-
 arch/sh/mm/tlbflush_64.c   |  8 +++++++-
 arch/sparc/mm/fault_32.c   |  8 +++++++-
 arch/sparc/mm/fault_64.c   |  8 +++++++-
 arch/tile/mm/fault.c       |  7 ++++++-
 arch/um/kernel/trap.c      |  8 +++++++-
 arch/unicore32/mm/fault.c  | 13 +++++++++----
 arch/x86/mm/fault.c        |  8 ++++++--
 arch/xtensa/mm/fault.c     |  8 +++++++-
 include/linux/mm.h         |  1 +
 27 files changed, 179 insertions(+), 31 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index fadd5f8..fa6b4e4 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -89,6 +89,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	struct mm_struct *mm = current->mm;
 	const struct exception_table_entry *fixup;
 	int fault, si_code = SEGV_MAPERR;
+	unsigned long flags = 0;
 	siginfo_t info;
 
 	/* As of EV6, a load into $31/$f31 is a prefetch, and never faults
@@ -142,10 +143,15 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 			goto bad_area;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (cause > 0)
+		flags |= FAULT_FLAG_WRITE;
+
 	/* If for any reason at all we couldn't handle the fault,
 	   make sure we exit gracefully rather than endlessly redo
 	   the fault.  */
-	fault = handle_mm_fault(mm, vma, address, cause > 0 ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	up_read(&mm->mmap_sem);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index aa33949..31b1e69 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -231,9 +231,10 @@ static inline bool access_error(unsigned int fsr, struct vm_area_struct *vma)
 
 static int __kprobes
 __do_page_fault(struct mm_struct *mm, unsigned long addr, unsigned int fsr,
-		struct task_struct *tsk)
+		struct task_struct *tsk, struct pt_regs *regs)
 {
 	struct vm_area_struct *vma;
+	unsigned long flags = 0;
 	int fault;
 
 	vma = find_vma(mm, addr);
@@ -253,11 +254,16 @@ good_area:
 		goto out;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (fsr & FSR_WRITE)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, (fsr & FSR_WRITE) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, flags);
 	if (unlikely(fault & VM_FAULT_ERROR))
 		return fault;
 	if (fault & VM_FAULT_MAJOR)
@@ -320,7 +326,7 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 #endif
 	}
 
-	fault = __do_page_fault(mm, addr, fsr, tsk);
+	fault = __do_page_fault(mm, addr, fsr, tsk, regs);
 	up_read(&mm->mmap_sem);
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, addr);
diff --git a/arch/avr32/mm/fault.c b/arch/avr32/mm/fault.c
index f7040a1..ada6237 100644
--- a/arch/avr32/mm/fault.c
+++ b/arch/avr32/mm/fault.c
@@ -59,6 +59,7 @@ asmlinkage void do_page_fault(unsigned long ecr, struct pt_regs *regs)
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	const struct exception_table_entry *fixup;
+	unsigned long flags = 0;
 	unsigned long address;
 	unsigned long page;
 	int writeaccess;
@@ -127,12 +128,17 @@ good_area:
 		panic("Unhandled case %lu in do_page_fault!", ecr);
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (writeaccess)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, writeaccess ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/cris/mm/fault.c b/arch/cris/mm/fault.c
index 9dcac8e..35d096a 100644
--- a/arch/cris/mm/fault.c
+++ b/arch/cris/mm/fault.c
@@ -55,6 +55,7 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
+	unsigned long flags = 0;
 	siginfo_t info;
 	int fault;
 
@@ -156,13 +157,18 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 			goto bad_area;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (writeaccess & 1)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
 
-	fault = handle_mm_fault(mm, vma, address, (writeaccess & 1) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/frv/mm/fault.c b/arch/frv/mm/fault.c
index a325d57..2dbf219 100644
--- a/arch/frv/mm/fault.c
+++ b/arch/frv/mm/fault.c
@@ -35,6 +35,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
 	struct vm_area_struct *vma;
 	struct mm_struct *mm;
 	unsigned long _pme, lrai, lrad, fixup;
+	unsigned long flags = 0;
 	siginfo_t info;
 	pgd_t *pge;
 	pud_t *pue;
@@ -158,12 +159,17 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
 		break;
 	}
 
+	if (user_mode(__frame))
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, ear0, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, ear0, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index c10b76f..e56baf3 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -52,6 +52,7 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 	siginfo_t info;
 	int si_code = SEGV_MAPERR;
 	int fault;
+	unsigned long flags = 0;
 	const struct exception_table_entry *fixup;
 
 	/*
@@ -96,7 +97,12 @@ good_area:
 		break;
 	}
 
-	fault = handle_mm_fault(mm, vma, address, (cause > 0));
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (cause > 0)
+		flags |= FAULT_FLAG_WRITE;
+
+	fault = handle_mm_fault(mm, vma, address, flags);
 
 	/* The most common case -- we are done. */
 	if (likely(!(fault & VM_FAULT_ERROR))) {
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 20b3593..ad9ef9d 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -79,6 +79,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	int signal = SIGSEGV, code = SEGV_MAPERR;
 	struct vm_area_struct *vma, *prev_vma;
 	struct mm_struct *mm = current->mm;
+	unsigned long flags = 0;
 	struct siginfo si;
 	unsigned long mask;
 	int fault;
@@ -149,12 +150,17 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	if ((vma->vm_flags & mask) != mask)
 		goto bad_area;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (mask & VM_WRITE)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, (mask & VM_WRITE) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		/*
 		 * We ran out of memory, or some other thing happened
diff --git a/arch/m32r/mm/fault.c b/arch/m32r/mm/fault.c
index 2c9aeb4..e74f6fa 100644
--- a/arch/m32r/mm/fault.c
+++ b/arch/m32r/mm/fault.c
@@ -79,6 +79,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
 	unsigned long page, addr;
+	unsigned long flags = 0;
 	int write;
 	int fault;
 	siginfo_t info;
@@ -188,6 +189,11 @@ good_area:
 	if ((error_code & ACE_INSTRUCTION) && !(vma->vm_flags & VM_EXEC))
 	  goto bad_area;
 
+	if (error_code & ACE_USERMODE)
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
@@ -195,7 +201,7 @@ good_area:
 	 */
 	addr = (address & PAGE_MASK);
 	set_thread_fault_code(error_code);
-	fault = handle_mm_fault(mm, vma, addr, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, addr, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index 2db6099..ab88a91 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -73,6 +73,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct * vma;
+	unsigned long flags = 0;
 	int write, fault;
 
 #ifdef DEBUG
@@ -134,13 +135,18 @@ good_area:
 				goto acc_err;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
 
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 #ifdef DEBUG
 	printk("handle_mm_fault returns %d\n",fault);
 #endif
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index ae97d2c..b002612 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -89,6 +89,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 {
 	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
+	unsigned long flags = 0;
 	siginfo_t info;
 	int code = SEGV_MAPERR;
 	int is_write = error_code & ESR_S;
@@ -206,12 +207,17 @@ good_area:
 			goto bad_area;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (is_write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, is_write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 937cf33..e5b9fed 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -40,6 +40,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs, unsigned long writ
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
 	const int field = sizeof(unsigned long) * 2;
+	unsigned long flags = 0;
 	siginfo_t info;
 	int fault;
 
@@ -139,12 +140,17 @@ good_area:
 		}
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
index 5ac4df5..031be56 100644
--- a/arch/mn10300/mm/fault.c
+++ b/arch/mn10300/mm/fault.c
@@ -121,6 +121,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long fault_code,
 {
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
+	unsigned long flags = 0;
 	struct mm_struct *mm;
 	unsigned long page;
 	siginfo_t info;
@@ -247,12 +248,17 @@ good_area:
 		break;
 	}
 
+	if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR)
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index d78881c..d586119 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -52,6 +52,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
+	unsigned long flags = 0;
 	siginfo_t info;
 	int fault;
 
@@ -153,13 +154,18 @@ good_area:
 	if ((vector == 0x400) && !(vma->vm_page_prot.pgprot & _PAGE_EXEC))
 		goto bad_area;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (write_acc)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
 
-	fault = handle_mm_fault(mm, vma, address, write_acc);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index 18162ce..a151e87 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -173,6 +173,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 	struct vm_area_struct *vma, *prev_vma;
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
+	unsigned long flags = 0;
 	unsigned long acc_type;
 	int fault;
 
@@ -195,13 +196,18 @@ good_area:
 	if ((vma->vm_flags & acc_type) != acc_type)
 		goto bad_area;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (acc_type & VM_WRITE)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
 
-	fault = handle_mm_fault(mm, vma, address, (acc_type & VM_WRITE) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		/*
 		 * We hit a shared mapping outside of the file, or some
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 5efe8c9..2bf339c 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -122,6 +122,7 @@ int __kprobes do_page_fault(struct pt_regs *regs, unsigned long address,
 {
 	struct vm_area_struct * vma;
 	struct mm_struct *mm = current->mm;
+	unsigned long flags = 0;
 	siginfo_t info;
 	int code = SEGV_MAPERR;
 	int is_write = 0, ret;
@@ -305,12 +306,17 @@ good_area:
 			goto bad_area;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (is_write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	ret = handle_mm_fault(mm, vma, address, is_write ? FAULT_FLAG_WRITE : 0);
+	ret = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(ret & VM_FAULT_ERROR)) {
 		if (ret & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index a9a3018..fe6109c 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -301,6 +301,8 @@ static inline int do_exception(struct pt_regs *regs, int access,
 	address = trans_exc_code & __FAIL_ADDR_MASK;
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
 	flags = FAULT_FLAG_ALLOW_RETRY;
+	if (regs->psw.mask & PSW_MASK_PSTATE)
+		flags |= FAULT_FLAG_USER;
 	if (access == VM_WRITE || (trans_exc_code & store_indication) == 0x400)
 		flags |= FAULT_FLAG_WRITE;
 	down_read(&mm->mmap_sem);
diff --git a/arch/score/mm/fault.c b/arch/score/mm/fault.c
index 6b18fb0..2ca5ae5 100644
--- a/arch/score/mm/fault.c
+++ b/arch/score/mm/fault.c
@@ -47,6 +47,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long write,
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
 	const int field = sizeof(unsigned long) * 2;
+	unsigned long flags = 0;
 	siginfo_t info;
 	int fault;
 
@@ -101,12 +102,16 @@ good_area:
 	}
 
 survive:
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
 	/*
 	* If for any reason at all we couldn't handle the fault,
 	* make sure we exit gracefully rather than endlessly redo
 	* the fault.
 	*/
-	fault = handle_mm_fault(mm, vma, address, write);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sh/mm/fault_32.c b/arch/sh/mm/fault_32.c
index 7bebd04..a61b803 100644
--- a/arch/sh/mm/fault_32.c
+++ b/arch/sh/mm/fault_32.c
@@ -126,6 +126,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
+	unsigned long flags = 0;
 	int si_code;
 	int fault;
 	siginfo_t info;
@@ -195,12 +196,17 @@ good_area:
 			goto bad_area;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (writeaccess)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, writeaccess ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sh/mm/tlbflush_64.c b/arch/sh/mm/tlbflush_64.c
index e3430e0..0a9d645 100644
--- a/arch/sh/mm/tlbflush_64.c
+++ b/arch/sh/mm/tlbflush_64.c
@@ -96,6 +96,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long writeaccess,
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
 	const struct exception_table_entry *fixup;
+	unsigned long flags = 0;
 	pte_t *pte;
 	int fault;
 
@@ -184,12 +185,17 @@ good_area:
 		}
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (writeaccess)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, writeaccess ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index 8023fd7..efa3d48 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -222,6 +222,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 	struct vm_area_struct *vma;
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
+	unsigned long flags = 0;
 	unsigned int fixup;
 	unsigned long g2;
 	int from_user = !(regs->psr & PSR_PS);
@@ -285,12 +286,17 @@ good_area:
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
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 504c062..bc536ea 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -276,6 +276,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	unsigned long flags = 0;
 	unsigned int insn = 0;
 	int si_code, fault_code, fault;
 	unsigned long address, mm_rss;
@@ -423,7 +424,12 @@ good_area:
 			goto bad_area;
 	}
 
-	fault = handle_mm_fault(mm, vma, address, (fault_code & FAULT_CODE_WRITE) ? FAULT_FLAG_WRITE : 0);
+	if (!(regs->tstate & TSTATE_PRIV))
+		flags |= FAULT_FLAG_USER;
+	if (fault_code & FAULT_CODE_WRITE)
+		flags |= FAULT_FLAG_WRITE;
+
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/tile/mm/fault.c b/arch/tile/mm/fault.c
index 3312531..b2a7fd5 100644
--- a/arch/tile/mm/fault.c
+++ b/arch/tile/mm/fault.c
@@ -263,6 +263,7 @@ static int handle_page_fault(struct pt_regs *regs,
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	unsigned long stack_offset;
+	unsigned long flags = 0;
 	int fault;
 	int si_code;
 	int is_kernel_mode;
@@ -415,12 +416,16 @@ good_area:
 	}
 
  survive:
+	if (!is_kernel_mode)
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index dafc947..626a85e 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -25,6 +25,7 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	unsigned long flags = 0;
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
@@ -62,10 +63,15 @@ good_area:
 	if (!is_write && !(vma->vm_flags & (VM_READ | VM_EXEC)))
 		goto out;
 
+	if (is_user)
+		flags |= FAULT_FLAG_USER;
+	if (is_write)
+		flags |= FAULT_FLAG_WRITE;
+
 	do {
 		int fault;
 
-		fault = handle_mm_fault(mm, vma, address, is_write ? FAULT_FLAG_WRITE : 0);
+		fault = handle_mm_fault(mm, vma, address, flags);
 		if (unlikely(fault & VM_FAULT_ERROR)) {
 			if (fault & VM_FAULT_OOM) {
 				goto out_of_memory;
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 283aa4b..3026943 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -169,9 +169,10 @@ static inline bool access_error(unsigned int fsr, struct vm_area_struct *vma)
 }
 
 static int __do_pf(struct mm_struct *mm, unsigned long addr, unsigned int fsr,
-		struct task_struct *tsk)
+		   struct task_struct *tsk, struct pt_regs *regs)
 {
 	struct vm_area_struct *vma;
+	unsigned long flags = 0;
 	int fault;
 
 	vma = find_vma(mm, addr);
@@ -191,12 +192,16 @@ good_area:
 		goto out;
 	}
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (!(fsr ^ 0x12))
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK,
-			    (!(fsr ^ 0x12)) ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, flags);
 	if (unlikely(fault & VM_FAULT_ERROR))
 		return fault;
 	if (fault & VM_FAULT_MAJOR)
@@ -252,7 +257,7 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 #endif
 	}
 
-	fault = __do_pf(mm, addr, fsr, tsk);
+	fault = __do_pf(mm, addr, fsr, tsk, regs);
 	up_read(&mm->mmap_sem);
 
 	/*
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 5db0490..1cebabe 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -999,8 +999,7 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	struct mm_struct *mm;
 	int fault;
 	int write = error_code & PF_WRITE;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
-					(write ? FAULT_FLAG_WRITE : 0);
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1160,6 +1159,11 @@ good_area:
 		return;
 	}
 
+	if (error_code & PF_USER)
+		flags |= FAULT_FLAG_USER;
+	if (write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index e367e30..7db9fbe 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -41,6 +41,7 @@ void do_page_fault(struct pt_regs *regs)
 	struct mm_struct *mm = current->mm;
 	unsigned int exccause = regs->exccause;
 	unsigned int address = regs->excvaddr;
+	unsigned long flags = 0;
 	siginfo_t info;
 
 	int is_write, is_exec;
@@ -101,11 +102,16 @@ good_area:
 		if (!(vma->vm_flags & (VM_READ | VM_WRITE)))
 			goto bad_area;
 
+	if (user_mode(regs))
+		flags |= FAULT_FLAG_USER;
+	if (is_write)
+		flags |= FAULT_FLAG_WRITE;
+
 	/* If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, is_write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4baadd1..846b82b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -156,6 +156,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_ALLOW_RETRY	0x08	/* Retry fault if blocking */
 #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
 #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
+#define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
 
 /*
  * This interface is used by x86 PAT code to identify a pfn mapping that is
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
