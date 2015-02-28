Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id B628D6B009F
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 18:02:49 -0500 (EST)
Received: by mail-vc0-f176.google.com with SMTP id la4so8636509vcb.7
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 15:02:49 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id bw8si3666830vcb.52.2015.02.28.15.02.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 28 Feb 2015 15:02:48 -0800 (PST)
Message-ID: <1425164559.4645.157.camel@kernel.crashing.org>
Subject: Re: Generic page fault (Was: libsigsegv ....)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 01 Mar 2015 10:02:39 +1100
In-Reply-To: <1425161796.4645.149.camel@kernel.crashing.org>
References: <1422361485.6648.71.camel@opensuse.org>
	 <54C78756.9090605@suse.cz>
	 <alpine.LSU.2.11.1501271347440.30227@nerf60.vanv.qr>
	 <1422364084.6648.82.camel@opensuse.org> <s5h7fw8hvdp.wl-tiwai@suse.de>
	 <CA+55aFyzy_wYHHnr2gDcYr7qcgOKM2557bRdg6RBa=cxrynd+Q@mail.gmail.com>
	 <CA+55aFxRnj97rpSQvvzLJhpo7C8TQ-F=eB1Ry2n53AV1rN8mwA@mail.gmail.com>
	 <CAMo8BfLsKCV_2NfgMH4k9jGOHs_-3=NKjCD3o3KK1uH23-6RRg@mail.gmail.com>
	 <CA+55aFzQ5QEZ1AYauWviq1gp5j=mqByAtt4fpteeK7amuxcyjw@mail.gmail.com>
	 <1422836637.17302.9.camel@au1.ibm.com>
	 <CA+55aFw9sg7pu9-2RbMGyPv5yUtcH54QowoH+5RhWqpPYg4YGQ@mail.gmail.com>
	 <1425107567.4645.108.camel@kernel.crashing.org>
	 <CA+55aFy5UvzSgOMKq09u4psz5twtC4aowuK6tofGKDEu-KFMJQ@mail.gmail.com>
	 <1425158083.4645.139.camel@kernel.crashing.org>
	 <1425161796.4645.149.camel@kernel.crashing.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sun, 2015-03-01 at 09:16 +1100, Benjamin Herrenschmidt wrote:
> So for error handling, I'm trying to simply return the VM_FAULT_* flags
> from generic_page_fault see where that takes us. That's a way to avoid
> passing an arch specific struct around. It also allows my hack to
> account major faults with the hypervisor to be done outside the generic
> code completely (no hook).
>
> .../...

Here's what it looks like for x86 only and without completely sorting
out the fatal signal business. However I might still have to do the
arch pointer you mentioned for sparc and possibly other archs, but so
far it looks better already.

Note that if I add that arch pointer, I might stop messing around
or even returning "fault" and instead just return a simple enum
minor,major,error and let inline arch hooks populate the arch pointer
with the error details in whatever fashion the arch prefers. However
I suspect they'll all end up with sig and si_code in there...

Anyway, here's the current patch:

 arch/x86/include/asm/fault.h |  21 ++++
 arch/x86/mm/fault.c          | 233 ++++---------------------------------------
 include/linux/fault.h        |  24 +++++
 include/linux/mm.h           |   5 +-
 mm/Makefile                  |   2 +-
 mm/fault.c                   | 196 ++++++++++++++++++++++++++++++++++++
 6 files changed, 266 insertions(+), 215 deletions(-)
 create mode 100644 arch/x86/include/asm/fault.h
 create mode 100644 include/linux/fault.h
 create mode 100644 mm/fault.c

diff --git a/arch/x86/include/asm/fault.h b/arch/x86/include/asm/fault.h
new file mode 100644
index 0000000..04263ec
--- /dev/null
+++ b/arch/x86/include/asm/fault.h
@@ -0,0 +1,21 @@
+#ifndef _ASM_X86_FAULT_H
+#define _ASM_X86_FAULT_H
+
+#include <linux/types.h>
+#include <asm/ptrace.h>
+
+/* Check if the stack is allowed to grow during a user page fault */
+static inline bool stack_can_grow(struct pt_regs *regs, unsigned long flags,
+				  unsigned long address,
+				  struct vm_area_struct *vma)
+{
+	/*
+	 * Accessing the stack below %sp is always a bug.
+	 * The large cushion allows instructions like enter
+	 * and pusha to work. ("enter $65535, $31" pushes
+	 * 32 pointers and then decrements %sp by 65535.)
+	 */
+	return address + 65536 + 32 * sizeof(unsigned long) >= regs->sp;
+}
+
+#endif /*  _ASM_X86_FAULT_H */
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index ede025f..19a8a91 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -13,6 +13,7 @@
 #include <linux/hugetlb.h>		/* hstate_index_to_shift	*/
 #include <linux/prefetch.h>		/* prefetchw			*/
 #include <linux/context_tracking.h>	/* exception_enter(), ...	*/
+#include <linux/fault.h>
 
 #include <asm/traps.h>			/* dotraplinkage, ...		*/
 #include <asm/pgalloc.h>		/* pgd_*(), ...			*/
@@ -748,8 +749,7 @@ show_signal_msg(struct pt_regs *regs, unsigned long error_code,
 	printk(KERN_CONT "\n");
 }
 
-static void
-__bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
+static void __bad_area(struct pt_regs *regs, unsigned long error_code,
 		       unsigned long address, int si_code)
 {
 	struct task_struct *tsk = current;
@@ -804,39 +804,10 @@ __bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
 	no_context(regs, error_code, address, SIGSEGV, si_code);
 }
 
-static noinline void
-bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
-		     unsigned long address)
-{
-	__bad_area_nosemaphore(regs, error_code, address, SEGV_MAPERR);
-}
-
-static void
-__bad_area(struct pt_regs *regs, unsigned long error_code,
-	   unsigned long address, int si_code)
-{
-	struct mm_struct *mm = current->mm;
-
-	/*
-	 * Something tried to access memory that isn't in our memory map..
-	 * Fix it, but check if it's kernel or user first..
-	 */
-	up_read(&mm->mmap_sem);
-
-	__bad_area_nosemaphore(regs, error_code, address, si_code);
-}
-
-static noinline void
-bad_area(struct pt_regs *regs, unsigned long error_code, unsigned long address)
-{
-	__bad_area(regs, error_code, address, SEGV_MAPERR);
-}
-
-static noinline void
-bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
-		      unsigned long address)
+static inline void bad_area(struct pt_regs *regs, unsigned long error_code,
+			    unsigned long address, int si_code)
 {
-	__bad_area(regs, error_code, address, SEGV_ACCERR);
+	__bad_area(regs, error_code, address, si_code);
 }
 
 static void
@@ -871,40 +842,6 @@ do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
 	force_sig_info_fault(SIGBUS, code, address, tsk, fault);
 }
 
-static noinline void
-mm_fault_error(struct pt_regs *regs, unsigned long error_code,
-	       unsigned long address, unsigned int fault)
-{
-	if (fatal_signal_pending(current) && !(error_code & PF_USER)) {
-		no_context(regs, error_code, address, 0, 0);
-		return;
-	}
-
-	if (fault & VM_FAULT_OOM) {
-		/* Kernel mode? Handle exceptions or die: */
-		if (!(error_code & PF_USER)) {
-			no_context(regs, error_code, address,
-				   SIGSEGV, SEGV_MAPERR);
-			return;
-		}
-
-		/*
-		 * We ran out of memory, call the OOM killer, and return the
-		 * userspace (which will retry the fault, or kill us if we got
-		 * oom-killed):
-		 */
-		pagefault_out_of_memory();
-	} else {
-		if (fault & (VM_FAULT_SIGBUS|VM_FAULT_HWPOISON|
-			     VM_FAULT_HWPOISON_LARGE))
-			do_sigbus(regs, error_code, address, fault);
-		else if (fault & VM_FAULT_SIGSEGV)
-			bad_area_nosemaphore(regs, error_code, address);
-		else
-			BUG();
-	}
-}
-
 static int spurious_fault_check(unsigned long error_code, pte_t *pte)
 {
 	if ((error_code & PF_WRITE) && !pte_write(*pte))
@@ -998,27 +935,6 @@ NOKPROBE_SYMBOL(spurious_fault);
 
 int show_unhandled_signals = 1;
 
-static inline int
-access_error(unsigned long error_code, struct vm_area_struct *vma)
-{
-	if (error_code & PF_WRITE) {
-		/* write, present and write, not present: */
-		if (unlikely(!(vma->vm_flags & VM_WRITE)))
-			return 1;
-		return 0;
-	}
-
-	/* read, present: */
-	if (unlikely(error_code & PF_PROT))
-		return 1;
-
-	/* read, not present: */
-	if (unlikely(!(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))))
-		return 1;
-
-	return 0;
-}
-
 static int fault_in_kernel_space(unsigned long address)
 {
 	return address >= TASK_SIZE_MAX;
@@ -1054,11 +970,10 @@ static noinline void
 __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		unsigned long address)
 {
-	struct vm_area_struct *vma;
 	struct task_struct *tsk;
 	struct mm_struct *mm;
-	int fault, major = 0;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int fault;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1107,7 +1022,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		 * Don't take the mm semaphore here. If we fixup a prefetch
 		 * fault we could otherwise deadlock:
 		 */
-		bad_area_nosemaphore(regs, error_code, address);
+		bad_area(regs, error_code, address, SEGV_MAPERR);
 
 		return;
 	}
@@ -1120,7 +1035,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		pgtable_bad(regs, error_code, address);
 
 	if (unlikely(smap_violation(error_code, regs))) {
-		bad_area_nosemaphore(regs, error_code, address);
+		bad_area(regs, error_code, address, SEGV_MAPERR);
 		return;
 	}
 
@@ -1129,13 +1044,14 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 * in an atomic region then we must not take the fault:
 	 */
 	if (unlikely(in_atomic() || !mm)) {
-		bad_area_nosemaphore(regs, error_code, address);
+		bad_area(regs, error_code, address, SEGV_MAPERR);
 		return;
 	}
 
 	/*
 	 * It's safe to allow irq's after cr2 has been saved and the
 	 * vmalloc fault has been handled.
+
 	 *
 	 * User-mode registers count as a user access even for any
 	 * potential system fault or CPU buglet:
@@ -1143,138 +1059,29 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	if (user_mode_vm(regs)) {
 		local_irq_enable();
 		error_code |= PF_USER;
-		flags |= FAULT_FLAG_USER;
 	} else {
 		if (regs->flags & X86_EFLAGS_IF)
 			local_irq_enable();
 	}
 
-	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
-
+	if (error_code & PF_USER)
+		flags |= FAULT_FLAG_USER;
 	if (error_code & PF_WRITE)
 		flags |= FAULT_FLAG_WRITE;
+	if (error_code & PF_PROT)
+		flags |= FAULT_FLAG_PROT;
 
-	/*
-	 * When running in the kernel we expect faults to occur only to
-	 * addresses in user space.  All other faults represent errors in
-	 * the kernel and should generate an OOPS.  Unfortunately, in the
-	 * case of an erroneous fault occurring in a code path which already
-	 * holds mmap_sem we will deadlock attempting to validate the fault
-	 * against the address space.  Luckily the kernel only validly
-	 * references user space from well defined areas of code, which are
-	 * listed in the exceptions table.
-	 *
-	 * As the vast majority of faults will be valid we will only perform
-	 * the source reference check when there is a possibility of a
-	 * deadlock. Attempt to lock the address space, if we cannot we then
-	 * validate the source. If this is invalid we can skip the address
-	 * space check, thus avoiding the deadlock:
-	 */
-	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
-		if ((error_code & PF_USER) == 0 &&
-		    !search_exception_tables(regs->ip)) {
-			bad_area_nosemaphore(regs, error_code, address);
-			return;
-		}
-retry:
-		down_read(&mm->mmap_sem);
-	} else {
-		/*
-		 * The above down_read_trylock() might have succeeded in
-		 * which case we'll have missed the might_sleep() from
-		 * down_read():
-		 */
-		might_sleep();
-	}
-
-	vma = find_vma(mm, address);
-	if (unlikely(!vma)) {
-		bad_area(regs, error_code, address);
-		return;
-	}
-	if (likely(vma->vm_start <= address))
-		goto good_area;
-	if (unlikely(!(vma->vm_flags & VM_GROWSDOWN))) {
-		bad_area(regs, error_code, address);
+	fault = generic_page_fault(regs, tsk, flags, address);
+	if (unlikely(fault & VM_FAULT_SIGSEGV)) {
+		bad_area(regs, error_code, address,
+			 (fault & VM_FAULT_ACCESS) ? SEGV_MAPERR : SEGV_ACCERR);
 		return;
 	}
-	if (error_code & PF_USER) {
-		/*
-		 * Accessing the stack below %sp is always a bug.
-		 * The large cushion allows instructions like enter
-		 * and pusha to work. ("enter $65535, $31" pushes
-		 * 32 pointers and then decrements %sp by 65535.)
-		 */
-		if (unlikely(address + 65536 + 32 * sizeof(unsigned long) < regs->sp)) {
-			bad_area(regs, error_code, address);
-			return;
-		}
-	}
-	if (unlikely(expand_stack(vma, address))) {
-		bad_area(regs, error_code, address);
+	if (unlikely(fault & VM_FAULT_SIGBUS)) {
+		do_sigbus(regs, error_code, address, fault);
 		return;
 	}
 
-	/*
-	 * Ok, we have a good vm_area for this memory access, so
-	 * we can handle it..
-	 */
-good_area:
-	if (unlikely(access_error(error_code, vma))) {
-		bad_area_access_error(regs, error_code, address);
-		return;
-	}
-
-	/*
-	 * If for any reason at all we couldn't handle the fault,
-	 * make sure we exit gracefully rather than endlessly redo
-	 * the fault.  Since we never set FAULT_FLAG_RETRY_NOWAIT, if
-	 * we get VM_FAULT_RETRY back, the mmap_sem has been unlocked.
-	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
-	major |= fault & VM_FAULT_MAJOR;
-
-	/*
-	 * If we need to retry the mmap_sem has already been released,
-	 * and if there is a fatal signal pending there is no guarantee
-	 * that we made any progress. Handle this case first.
-	 */
-	if (unlikely(fault & VM_FAULT_RETRY)) {
-		/* Retry at most once */
-		if (flags & FAULT_FLAG_ALLOW_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
-			flags |= FAULT_FLAG_TRIED;
-			if (!fatal_signal_pending(tsk))
-				goto retry;
-		}
-
-		/* User mode? Just return to handle the fatal exception */
-		if (flags & FAULT_FLAG_USER)
-			return;
-
-		/* Not returning to user mode? Handle exceptions or die: */
-		no_context(regs, error_code, address, SIGBUS, BUS_ADRERR);
-		return;
-	}
-
-	up_read(&mm->mmap_sem);
-	if (unlikely(fault & VM_FAULT_ERROR)) {
-		mm_fault_error(regs, error_code, address, fault);
-		return;
-	}
-
-	/*
-	 * Major/minor page fault accounting. If any of the events
-	 * returned VM_FAULT_MAJOR, we account it as a major fault.
-	 */
-	if (major) {
-		tsk->maj_flt++;
-		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ, 1, regs, address);
-	} else {
-		tsk->min_flt++;
-		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MIN, 1, regs, address);
-	}
-
 	check_v8086_mode(regs, address, tsk);
 }
 NOKPROBE_SYMBOL(__do_page_fault);
diff --git a/include/linux/fault.h b/include/linux/fault.h
new file mode 100644
index 0000000..11c567e
--- /dev/null
+++ b/include/linux/fault.h
@@ -0,0 +1,24 @@
+#ifndef __FAULT_H
+#define __FAULT_H
+
+/* Generic page fault stuff */
+
+#include <asm/fault.h>
+
+/* Returns the fault flags from handle_mm_fault() with the addition
+ * that:
+ *
+ * - On an error, either VM_FAULT_SIGSEGV or VM_FAULT_SIGBUS will
+ *   always be set in addition to other flags
+ *
+ * - VM_FAULT_ACCESS will be added to VM_FAULT_SIGSEGV for access
+ *   protection faults
+ *
+ * - VM_FAULT_MAJOR will be set even if there was a retry
+ *
+ * - XXX FIXME: VM_FAULT_SIGBUS will be set on a fatal signal
+ */
+unsigned int generic_page_fault(struct pt_regs *regs, struct task_struct *tsk,
+				unsigned long flags, unsigned long address);
+
+#endif /* __FAULT_H */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 47a9392..5578eba 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -211,6 +211,9 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_KILLABLE	0x10	/* The fault task is in SIGKILL killable region */
 #define FAULT_FLAG_TRIED	0x20	/* Second try */
 #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
+#define FAULT_FLAG_EXEC		0x80	/* The fault was an instruction fetch */
+#define FAULT_FLAG_PROT		0x100	/* HW detected protection fault */
+#define FAULT_FLAG_NO_STK_GROW	0x200	/* Fault is not allowed to grow stack */
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
@@ -1098,7 +1101,7 @@ static inline int page_mapped(struct page *page)
 #define VM_FAULT_HWPOISON 0x0010	/* Hit poisoned small page */
 #define VM_FAULT_HWPOISON_LARGE 0x0020  /* Hit poisoned large page. Index encoded in upper bits */
 #define VM_FAULT_SIGSEGV 0x0040
-
+#define VM_FAULT_ACCESS  0x0080 /* in addition to VM_FAULT_SIGSEGV */
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
diff --git a/mm/Makefile b/mm/Makefile
index 3c1caa2..f647ff1 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -8,7 +8,7 @@ KASAN_SANITIZE_slub.o := n
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= gup.o highmem.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o pagewalk.o pgtable-generic.o
+			   vmalloc.o pagewalk.o pgtable-generic.o fault.o
 
 ifdef CONFIG_CROSS_MEMORY_ATTACH
 mmu-$(CONFIG_MMU)	+= process_vm_access.o
diff --git a/mm/fault.c b/mm/fault.c
new file mode 100644
index 0000000..3bf4583
--- /dev/null
+++ b/mm/fault.c
@@ -0,0 +1,196 @@
+#include <linux/mm.h>
+#include <linux/sched.h>
+#include <linux/perf_event.h>
+#include <linux/module.h>
+
+#include <asm/fault.h>
+
+static noinline unsigned int mm_fault_error(struct pt_regs *regs,
+					    unsigned int flags,
+					    unsigned long address,
+					    unsigned int fault)
+{
+	/* XXX Hack in VM_FAULT_SIGBUS, we need to fix that */
+	if (fatal_signal_pending(current) && !(flags & FAULT_FLAG_USER))
+		return fault | VM_FAULT_SIGBUS;
+
+	if (fault & VM_FAULT_OOM) {
+		/* Kernel mode? Handle exceptions or die: */
+		if (!(flags & FAULT_FLAG_USER))
+			return fault | VM_FAULT_SIGSEGV;
+
+		/*
+		 * We ran out of memory, call the OOM killer, and return the
+		 * userspace (which will retry the fault, or kill us if we got
+		 * oom-killed):
+		 */
+		pagefault_out_of_memory();
+	} else {
+		if (fault & (VM_FAULT_SIGBUS|VM_FAULT_HWPOISON|
+			     VM_FAULT_HWPOISON_LARGE))
+			return fault | VM_FAULT_SIGBUS;
+		else if (fault & VM_FAULT_SIGSEGV)
+			return fault;
+		else
+			BUG();
+	}
+
+	/* Clear error conditions */
+	return fault & ~VM_FAULT_ERROR;
+}
+
+/* Access validity check */
+static inline bool access_error(struct pt_regs *regs, unsigned long flags,
+				struct vm_area_struct *vma)
+{
+	/* Write fault to a non-writeable VMA */
+	if (flags & FAULT_FLAG_WRITE) {
+		if (unlikely(!(vma->vm_flags & VM_WRITE)))
+			return true;
+		return false;
+	}
+
+	/* Exec fault to a non-executable VMA */
+	if (flags & FAULT_FLAG_EXEC) {
+		if (unlikely(!(vma->vm_flags & VM_WRITE)))
+			return true;
+		return false;
+	}
+
+	/* Other HW detected protection fault */
+	if (unlikely(flags & PF_PROT))
+		return true;
+
+	/* No access allowed to that VMA */
+	if (unlikely(!(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))))
+		return true;
+
+	return false;
+}
+
+unsigned int generic_page_fault(struct pt_regs *regs, struct task_struct *tsk,
+				unsigned int flags, unsigned long address)
+{
+	struct vm_area_struct *vma;
+	struct mm_struct *mm;
+	int fault, major = 0;
+
+	mm = tsk->mm;
+
+	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
+
+	/*
+	 * When running in the kernel we expect faults to occur only to
+	 * addresses in user space.  All other faults represent errors in
+	 * the kernel and should generate an OOPS.  Unfortunately, in the
+	 * case of an erroneous fault occurring in a code path which already
+	 * holds mmap_sem we will deadlock attempting to validate the fault
+	 * against the address space.  Luckily the kernel only validly
+	 * references user space from well defined areas of code, which are
+	 * listed in the exceptions table.
+	 *
+	 * As the vast majority of faults will be valid we will only perform
+	 * the source reference check when there is a possibility of a
+	 * deadlock. Attempt to lock the address space, if we cannot we then
+	 * validate the source. If this is invalid we can skip the address
+	 * space check, thus avoiding the deadlock:
+	 */
+	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
+		if (!(flags & FAULT_FLAG_USER) &&
+		    !search_exception_tables(GET_IP(regs))) {
+			return VM_FAULT_SIGSEGV;
+		}
+retry:
+		down_read(&mm->mmap_sem);
+	} else {
+		/*
+		 * The above down_read_trylock() might have succeeded in
+		 * which case we'll have missed the might_sleep() from
+		 * down_read():
+		 */
+		might_sleep();
+	}
+
+	vma = find_vma(mm, address);
+	if (unlikely(!vma))
+		goto bad_area;
+	if (likely(vma->vm_start <= address))
+		goto good_area;
+	if (unlikely(!(vma->vm_flags & VM_GROWSDOWN)))
+		goto bad_area;
+	if (unlikely((flags & FAULT_FLAG_USER) &&
+		     !stack_can_grow(regs, flags, address, vma)))
+		goto bad_area;
+	if (unlikely(expand_stack(vma, address)))
+		goto bad_area;
+
+	/*
+	 * Ok, we have a good vm_area for this memory access, so
+	 * we can handle it..
+	 */
+good_area:
+	if (unlikely(access_error(regs, flags, vma)))
+		goto bad_access;
+
+	/*
+	 * If for any reason at all we couldn't handle the fault,
+	 * make sure we exit gracefully rather than endlessly redo
+	 * the fault.  Since we never set FAULT_FLAG_RETRY_NOWAIT, if
+	 * we get VM_FAULT_RETRY back, the mmap_sem has been unlocked.
+	 */
+	fault = handle_mm_fault(mm, vma, address, flags);
+	major |= fault & VM_FAULT_MAJOR;
+
+	/*
+	 * If we need to retry the mmap_sem has already been released,
+	 * and if there is a fatal signal pending there is no guarantee
+	 * that we made any progress. Handle this case first.
+	 */
+	if (unlikely(fault & VM_FAULT_RETRY)) {
+		/* Retry at most once */
+		if (flags & FAULT_FLAG_ALLOW_RETRY) {
+			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
+			if (!fatal_signal_pending(tsk))
+				goto retry;
+		}
+
+		/* User mode? Just return to handle the fatal exception */
+		if (flags & FAULT_FLAG_USER)
+			return FAULT_NO_ERR;
+
+		/* Not returning to user mode? Handle exceptions or die: */
+		/* XXX mimmic x86, but might not be best */
+		return fault | VM_FAULT_SIGBUS;
+	}
+
+	up_read(&mm->mmap_sem);
+	if (unlikely(fault & VM_FAULT_ERROR))
+		return mm_fault_error(regs, flags, address, fault);
+
+	/*
+	 * Major/minor page fault accounting. If any of the events
+	 * returned VM_FAULT_MAJOR, we account it as a major fault.
+	 */
+	if (major) {
+		tsk->maj_flt++;
+		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ, 1, regs, address);
+
+		/* Restore the major flag, it might have been lost in case of
+		 * retry and the arch might care
+		 */
+		if (major)
+			fault |= VM_FAULT_MAJOR;
+	} else {
+		tsk->min_flt++;
+		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MIN, 1, regs, address);
+	}
+	return fault;
+
+ bad_area:
+	up_read(&mm->mmap_sem);
+	return VM_FAULT_SIGSEGV;
+ bad_access:
+	up_read(&mm->mmap_sem);
+	return VM_FAULT_SIGSEGV | VM_FAULT_ACCESS;
+}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
