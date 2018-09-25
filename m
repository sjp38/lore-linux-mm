Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67A6F8E009E
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 11:30:20 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s1-v6so9105942qte.19
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 08:30:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t65-v6sor694389qkl.14.2018.09.25.08.30.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 08:30:17 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 1/8] mm: push vm_fault into the page fault handlers
Date: Tue, 25 Sep 2018 11:30:04 -0400
Message-Id: <20180925153011.15311-2-josef@toxicpanda.com>
In-Reply-To: <20180925153011.15311-1-josef@toxicpanda.com>
References: <20180925153011.15311-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, riel@redhat.com, hannes@cmpxchg.org, tj@kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

In preparation for caching pages during filemap faults we need to push
the struct vm_fault up a level into the arch page fault handlers, since
they are the ones responsible for retrying if we unlock the mmap_sem.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 arch/alpha/mm/fault.c         |  4 ++-
 arch/arc/mm/fault.c           |  2 ++
 arch/arm/mm/fault.c           | 18 ++++++++-----
 arch/arm64/mm/fault.c         | 18 +++++++------
 arch/hexagon/mm/vm_fault.c    |  4 ++-
 arch/ia64/mm/fault.c          |  4 ++-
 arch/m68k/mm/fault.c          |  5 ++--
 arch/microblaze/mm/fault.c    |  4 ++-
 arch/mips/mm/fault.c          |  4 ++-
 arch/nds32/mm/fault.c         |  5 ++--
 arch/nios2/mm/fault.c         |  4 ++-
 arch/openrisc/mm/fault.c      |  5 ++--
 arch/parisc/mm/fault.c        |  5 ++--
 arch/powerpc/mm/copro_fault.c |  4 ++-
 arch/powerpc/mm/fault.c       |  4 ++-
 arch/riscv/mm/fault.c         |  2 ++
 arch/s390/mm/fault.c          |  4 ++-
 arch/sh/mm/fault.c            |  4 ++-
 arch/sparc/mm/fault_32.c      |  6 ++++-
 arch/sparc/mm/fault_64.c      |  2 ++
 arch/um/kernel/trap.c         |  4 ++-
 arch/unicore32/mm/fault.c     | 17 +++++++-----
 arch/x86/mm/fault.c           |  4 ++-
 arch/xtensa/mm/fault.c        |  4 ++-
 drivers/iommu/amd_iommu_v2.c  |  4 ++-
 drivers/iommu/intel-svm.c     |  6 +++--
 include/linux/mm.h            | 16 +++++++++---
 mm/gup.c                      |  8 ++++--
 mm/hmm.c                      |  4 ++-
 mm/ksm.c                      | 10 ++++---
 mm/memory.c                   | 61 +++++++++++++++++++++----------------------
 31 files changed, 157 insertions(+), 89 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index d73dc473fbb9..3c98dfef03a9 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -84,6 +84,7 @@ asmlinkage void
 do_page_fault(unsigned long address, unsigned long mmcsr,
 	      long cause, struct pt_regs *regs)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct * vma;
 	struct mm_struct *mm = current->mm;
 	const struct exception_table_entry *fixup;
@@ -148,7 +149,8 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	/* If for any reason at all we couldn't handle the fault,
 	   make sure we exit gracefully rather than endlessly redo
 	   the fault.  */
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmfs, vma, flags, address);
+	fault = handle_mm_fault(&vmf);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index db6913094be3..7aeb81ff5070 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -63,6 +63,7 @@ noinline static int handle_kernel_vaddr_fault(unsigned long address)
 
 void do_page_fault(unsigned long address, struct pt_regs *regs)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct *vma = NULL;
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
@@ -141,6 +142,7 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
+	vm_fault_init(&vmf, vma, address, flags);
 	fault = handle_mm_fault(vma, address, flags);
 
 	/* If Pagefault was interrupted by SIGKILL, exit page fault "early" */
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 3232afb6fdc0..885a24385a0a 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -225,17 +225,17 @@ static inline bool access_error(unsigned int fsr, struct vm_area_struct *vma)
 }
 
 static vm_fault_t __kprobes
-__do_page_fault(struct mm_struct *mm, unsigned long addr, unsigned int fsr,
-		unsigned int flags, struct task_struct *tsk)
+__do_page_fault(struct mm_struct *mm, struct vm_fault *vm, unsigned int fsr,
+		struct task_struct *tsk)
 {
 	struct vm_area_struct *vma;
 	vm_fault_t fault;
 
-	vma = find_vma(mm, addr);
+	vma = find_vma(mm, vmf->address);
 	fault = VM_FAULT_BADMAP;
 	if (unlikely(!vma))
 		goto out;
-	if (unlikely(vma->vm_start > addr))
+	if (unlikely(vma->vm_start > vmf->address))
 		goto check_stack;
 
 	/*
@@ -248,12 +248,14 @@ __do_page_fault(struct mm_struct *mm, unsigned long addr, unsigned int fsr,
 		goto out;
 	}
 
-	return handle_mm_fault(vma, addr & PAGE_MASK, flags);
+	vmf->vma = vma;
+	return handle_mm_fault(vmf);
 
 check_stack:
 	/* Don't allow expansion below FIRST_USER_ADDRESS */
 	if (vma->vm_flags & VM_GROWSDOWN &&
-	    addr >= FIRST_USER_ADDRESS && !expand_stack(vma, addr))
+	    vmf->address >= FIRST_USER_ADDRESS &&
+	    !expand_stack(vma, vmf->address))
 		goto good_area;
 out:
 	return fault;
@@ -262,6 +264,7 @@ __do_page_fault(struct mm_struct *mm, unsigned long addr, unsigned int fsr,
 static int __kprobes
 do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 {
+	struct vm_fault = {};
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	int sig, code;
@@ -314,7 +317,8 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 #endif
 	}
 
-	fault = __do_page_fault(mm, addr, fsr, flags, tsk);
+	vm_fault_init(&vmf, NULL, addr, flags);
+	fault = __do_page_fault(mm, &vmf, fsr, tsk);
 
 	/* If we need to retry but a fatal signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 50b30ff30de4..31e86a74cbe0 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -379,18 +379,17 @@ static void do_bad_area(unsigned long addr, unsigned int esr, struct pt_regs *re
 #define VM_FAULT_BADMAP		0x010000
 #define VM_FAULT_BADACCESS	0x020000
 
-static vm_fault_t __do_page_fault(struct mm_struct *mm, unsigned long addr,
-			   unsigned int mm_flags, unsigned long vm_flags,
-			   struct task_struct *tsk)
+static vm_fault_t __do_page_fault(struct mm_struct *mm, struct vm_fault *vmf,
+				  unsigned long vm_flags, struct task_struct *tsk)
 {
 	struct vm_area_struct *vma;
 	vm_fault_t fault;
 
-	vma = find_vma(mm, addr);
+	vma = find_vma(mm, vmf->address);
 	fault = VM_FAULT_BADMAP;
 	if (unlikely(!vma))
 		goto out;
-	if (unlikely(vma->vm_start > addr))
+	if (unlikely(vma->vm_start > vmf->address))
 		goto check_stack;
 
 	/*
@@ -407,10 +406,11 @@ static vm_fault_t __do_page_fault(struct mm_struct *mm, unsigned long addr,
 		goto out;
 	}
 
-	return handle_mm_fault(vma, addr & PAGE_MASK, mm_flags);
+	vmf->vma = vma;
+	return handle_mm_fault(vmf);
 
 check_stack:
-	if (vma->vm_flags & VM_GROWSDOWN && !expand_stack(vma, addr))
+	if (vma->vm_flags & VM_GROWSDOWN && !expand_stack(vma, vmf->address))
 		goto good_area;
 out:
 	return fault;
@@ -424,6 +424,7 @@ static bool is_el0_instruction_abort(unsigned int esr)
 static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 				   struct pt_regs *regs)
 {
+	struct vm_fault vmf = {};
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	struct siginfo si;
@@ -493,7 +494,8 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 #endif
 	}
 
-	fault = __do_page_fault(mm, addr, mm_flags, vm_flags, tsk);
+	vm_fault_init(&vmf, NULL, addr, mm_flags);
+	fault = __do_page_fault(mm, vmf, vm_flags, tsk);
 	major |= fault & VM_FAULT_MAJOR;
 
 	if (fault & VM_FAULT_RETRY) {
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index eb263e61daf4..1ee1042bb2b5 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -48,6 +48,7 @@
  */
 void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
 	int si_signo;
@@ -102,7 +103,8 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 		break;
 	}
 
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault(&vmf);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index a9d55ad8d67b..827b898adb5e 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -82,6 +82,7 @@ mapped_kernel_page_is_present (unsigned long address)
 void __kprobes
 ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *regs)
 {
+	struct vm_fault vmf = {};
 	int signal = SIGSEGV, code = SEGV_MAPERR;
 	struct vm_area_struct *vma, *prev_vma;
 	struct mm_struct *mm = current->mm;
@@ -161,7 +162,8 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault(&vmf);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index 9b6163c05a75..e42eddc9c7ca 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -68,6 +68,7 @@ int send_fault_sig(struct pt_regs *regs)
 int do_page_fault(struct pt_regs *regs, unsigned long address,
 			      unsigned long error_code)
 {
+	struct vm_fault vmf = {};
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct * vma;
 	vm_fault_t fault;
@@ -134,8 +135,8 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault(&vmf);
 	pr_debug("handle_mm_fault returns %x\n", fault);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index 202ad6a494f5..ade980266f65 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -86,6 +86,7 @@ void bad_page_fault(struct pt_regs *regs, unsigned long address, int sig)
 void do_page_fault(struct pt_regs *regs, unsigned long address,
 		   unsigned long error_code)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
 	int code = SEGV_MAPERR;
@@ -215,7 +216,8 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault(&vmf);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 73d8a0f0b810..bf212bb70f24 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -38,6 +38,7 @@ int show_unhandled_signals = 1;
 static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	unsigned long address)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct * vma = NULL;
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
@@ -152,7 +153,8 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault(&vmf);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/nds32/mm/fault.c b/arch/nds32/mm/fault.c
index b740534b152c..27ac4caa5102 100644
--- a/arch/nds32/mm/fault.c
+++ b/arch/nds32/mm/fault.c
@@ -69,6 +69,7 @@ void show_pte(struct mm_struct *mm, unsigned long addr)
 void do_page_fault(unsigned long entry, unsigned long addr,
 		   unsigned int error_code, struct pt_regs *regs)
 {
+	struct vm_fault vmf = {};
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
@@ -203,8 +204,8 @@ void do_page_fault(unsigned long entry, unsigned long addr,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-
-	fault = handle_mm_fault(vma, addr, flags);
+	vm_fault_init(&vmf, vma, addr, flags);
+	fault = handle_mm_fault(&vmf);
 
 	/*
 	 * If we need to retry but a fatal signal is pending, handle the
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index 24fd84cf6006..693472f05065 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -43,6 +43,7 @@
 asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 				unsigned long address)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct *vma = NULL;
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
@@ -132,7 +133,8 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault(&vmf);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index dc4dbafc1d83..70eef1d9f7ed 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -49,6 +49,7 @@ extern void die(char *, struct pt_regs *, long);
 asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 			      unsigned long vector, int write_acc)
 {
+	struct vm_fault vmf = {};
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
@@ -162,8 +163,8 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault(&vmf);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index c8e8b7c05558..83c89cada3c0 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -258,6 +258,7 @@ show_signal_msg(struct pt_regs *regs, unsigned long code,
 void do_page_fault(struct pt_regs *regs, unsigned long code,
 			      unsigned long address)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct *vma, *prev_vma;
 	struct task_struct *tsk;
 	struct mm_struct *mm;
@@ -300,8 +301,8 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault(&vmf);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/powerpc/mm/copro_fault.c b/arch/powerpc/mm/copro_fault.c
index c8da352e8686..02dd21a54479 100644
--- a/arch/powerpc/mm/copro_fault.c
+++ b/arch/powerpc/mm/copro_fault.c
@@ -36,6 +36,7 @@
 int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 		unsigned long dsisr, vm_fault_t *flt)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct *vma;
 	unsigned long is_write;
 	int ret;
@@ -77,7 +78,8 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 	}
 
 	ret = 0;
-	*flt = handle_mm_fault(vma, ea, is_write ? FAULT_FLAG_WRITE : 0);
+	vm_fault_init(&vmf, vma, ea, is_write ? FAULT_FLAG_WRITE : 0);
+	*flt = handle_mm_fault(&vmf);
 	if (unlikely(*flt & VM_FAULT_ERROR)) {
 		if (*flt & VM_FAULT_OOM) {
 			ret = -ENOMEM;
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index d51cf5f4e45e..cc00bba104fb 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -409,6 +409,7 @@ static void sanity_check_fault(bool is_write, unsigned long error_code) { }
 static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 			   unsigned long error_code)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct * vma;
 	struct mm_struct *mm = current->mm;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
@@ -538,7 +539,8 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault(&vmf);
 
 #ifdef CONFIG_PPC_MEM_KEYS
 	/*
diff --git a/arch/riscv/mm/fault.c b/arch/riscv/mm/fault.c
index 88401d5125bc..aa3db34c9eb8 100644
--- a/arch/riscv/mm/fault.c
+++ b/arch/riscv/mm/fault.c
@@ -36,6 +36,7 @@
  */
 asmlinkage void do_page_fault(struct pt_regs *regs)
 {
+	struct vm_fault vmf = {};
 	struct task_struct *tsk;
 	struct vm_area_struct *vma;
 	struct mm_struct *mm;
@@ -120,6 +121,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
+	vm_fault_init(&vmf, vma, addr, flags);
 	fault = handle_mm_fault(vma, addr, flags);
 
 	/*
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 72af23bacbb5..14cfd6de43ed 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -404,6 +404,7 @@ static noinline void do_fault_error(struct pt_regs *regs, int access,
  */
 static inline vm_fault_t do_exception(struct pt_regs *regs, int access)
 {
+	struct vm_fault vmf = {};
 	struct gmap *gmap;
 	struct task_struct *tsk;
 	struct mm_struct *mm;
@@ -499,7 +500,8 @@ static inline vm_fault_t do_exception(struct pt_regs *regs, int access)
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault(&vmf);
 	/* No reason to continue if interrupted by SIGKILL. */
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
 		fault = VM_FAULT_SIGNAL;
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index 6defd2c6d9b1..31202706125c 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -392,6 +392,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 					unsigned long error_code,
 					unsigned long address)
 {
+	stuct vm_fault vmf = {};
 	unsigned long vec;
 	struct task_struct *tsk;
 	struct mm_struct *mm;
@@ -481,7 +482,8 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault(&vmf);
 
 	if (unlikely(fault & (VM_FAULT_RETRY | VM_FAULT_ERROR)))
 		if (mm_fault_error(regs, error_code, address, fault))
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index b0440b0edd97..a9dd62393934 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -160,6 +160,7 @@ static noinline void do_fault_siginfo(int code, int sig, struct pt_regs *regs,
 asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 			       unsigned long address)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct *vma;
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
@@ -235,6 +236,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
+	vm_fault_init(&vmf, vma, address, flags);
 	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
@@ -377,6 +379,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 /* This always deals with user addresses. */
 static void force_user_fault(unsigned long address, int write)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct *vma;
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
@@ -405,7 +408,8 @@ static void force_user_fault(unsigned long address, int write)
 		if (!(vma->vm_flags & (VM_READ | VM_EXEC)))
 			goto bad_area;
 	}
-	switch (handle_mm_fault(vma, address, flags)) {
+	vm_fault_init(&vmf, vma, address, flags);
+	switch (handle_mm_fault(&vmf)) {
 	case VM_FAULT_SIGBUS:
 	case VM_FAULT_OOM:
 		goto do_sigbus;
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 8f8a604c1300..381ab905eb2c 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -274,6 +274,7 @@ static void noinline __kprobes bogus_32bit_fault_tpc(struct pt_regs *regs)
 
 asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 {
+	struct vm_fault vmf = {};
 	enum ctx_state prev_state = exception_enter();
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
@@ -433,6 +434,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 			goto bad_area;
 	}
 
+	vm_fault_init(&vmf, vma, address, flags);
 	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index cced82946042..c6d9e176c5c5 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -25,6 +25,7 @@
 int handle_page_fault(unsigned long address, unsigned long ip,
 		      int is_write, int is_user, int *code_out)
 {
+	struct vm_fault vmf = {};
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	pgd_t *pgd;
@@ -74,7 +75,8 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 	do {
 		vm_fault_t fault;
 
-		fault = handle_mm_fault(vma, address, flags);
+		vm_fault_init(&vmf, vma, address, flags);
+		fault = handle_mm_fault(&vmf);
 
 		if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 			goto out_nosemaphore;
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 8f12a5b50a42..68c2b0a65348 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -168,17 +168,17 @@ static inline bool access_error(unsigned int fsr, struct vm_area_struct *vma)
 	return vma->vm_flags & mask ? false : true;
 }
 
-static vm_fault_t __do_pf(struct mm_struct *mm, unsigned long addr,
-		unsigned int fsr, unsigned int flags, struct task_struct *tsk)
+static vm_fault_t __do_pf(struct mm_struct *mm, struct vm_fault *vmf,
+		unsigned int fsr, struct task_struct *tsk)
 {
 	struct vm_area_struct *vma;
 	vm_fault_t fault;
 
-	vma = find_vma(mm, addr);
+	vma = find_vma(mm, vmf->address);
 	fault = VM_FAULT_BADMAP;
 	if (unlikely(!vma))
 		goto out;
-	if (unlikely(vma->vm_start > addr))
+	if (unlikely(vma->vm_start > vmf->address))
 		goto check_stack;
 
 	/*
@@ -195,11 +195,12 @@ static vm_fault_t __do_pf(struct mm_struct *mm, unsigned long addr,
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the fault.
 	 */
-	fault = handle_mm_fault(vma, addr & PAGE_MASK, flags);
+	vmf->vma = vma;
+	fault = handle_mm_fault(vmf);
 	return fault;
 
 check_stack:
-	if (vma->vm_flags & VM_GROWSDOWN && !expand_stack(vma, addr))
+	if (vma->vm_flags & VM_GROWSDOWN && !expand_stack(vma, vmf->address))
 		goto good_area;
 out:
 	return fault;
@@ -207,6 +208,7 @@ static vm_fault_t __do_pf(struct mm_struct *mm, unsigned long addr,
 
 static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 {
+	struct vm_fault vmf = {};
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	int sig, code;
@@ -253,7 +255,8 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 #endif
 	}
 
-	fault = __do_pf(mm, addr, fsr, flags, tsk);
+	vm_fault_init(&vmf, NULL, addr, flags);
+	fault = __do_pf(mm, &vmf, fsr, tsk);
 
 	/* If we need to retry but a fatal signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 47bebfe6efa7..9919a25b15e6 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1211,6 +1211,7 @@ static noinline void
 __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		unsigned long address)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
 	struct mm_struct *mm;
@@ -1392,7 +1393,8 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 * fault, so we read the pkey beforehand.
 	 */
 	pkey = vma_pkey(vma);
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault(&vmf);
 	major |= fault & VM_FAULT_MAJOR;
 
 	/*
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index 2ab0e0dcd166..f1b0f4f858ff 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -35,6 +35,7 @@ void bad_page_fault(struct pt_regs*, unsigned long, int);
 
 void do_page_fault(struct pt_regs *regs)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct * vma;
 	struct mm_struct *mm = current->mm;
 	unsigned int exccause = regs->exccause;
@@ -108,7 +109,8 @@ void do_page_fault(struct pt_regs *regs)
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault(&vmf);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 58da65df03f5..129e0ef68827 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -506,6 +506,7 @@ static bool access_error(struct vm_area_struct *vma, struct fault *fault)
 
 static void do_fault(struct work_struct *work)
 {
+	struct vm_fault vmf = {};
 	struct fault *fault = container_of(work, struct fault, work);
 	struct vm_area_struct *vma;
 	vm_fault_t ret = VM_FAULT_ERROR;
@@ -532,7 +533,8 @@ static void do_fault(struct work_struct *work)
 	if (access_error(vma, fault))
 		goto out;
 
-	ret = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	ret = handle_mm_fault(&vmf);
 out:
 	up_read(&mm->mmap_sem);
 
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index 4a03e5090952..03aa02723242 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -567,6 +567,7 @@ static bool is_canonical_address(u64 addr)
 
 static irqreturn_t prq_event_thread(int irq, void *d)
 {
+	struct vm_fault vmf = {};
 	struct intel_iommu *iommu = d;
 	struct intel_svm *svm = NULL;
 	int head, tail, handled = 0;
@@ -636,8 +637,9 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 		if (access_error(vma, req))
 			goto invalid;
 
-		ret = handle_mm_fault(vma, address,
-				      req->wr_req ? FAULT_FLAG_WRITE : 0);
+		vm_fault_init(&vmf, vma, address,
+			      req->wr_req ? FAULT_FLAG_WRITE : 0);
+		ret = handle_mm_fault(&vmf);
 		if (ret & VM_FAULT_ERROR)
 			goto invalid;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a61ebe8ad4ca..e271c60af01a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -378,6 +378,16 @@ struct vm_fault {
 					 */
 };
 
+static inline void vm_fault_init(struct vm_fault *vmf,
+				 struct vm_area_struct *vma,
+				 unsigned long address,
+				 unsigned int flags)
+{
+	vmf->vma = vma;
+	vmf->address = address;
+	vmf->flags = flags;
+}
+
 /* page entry size for vm->huge_fault() */
 enum page_entry_size {
 	PE_SIZE_PTE = 0,
@@ -1403,8 +1413,7 @@ int generic_error_remove_page(struct address_space *mapping, struct page *page);
 int invalidate_inode_page(struct page *page);
 
 #ifdef CONFIG_MMU
-extern vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
-			unsigned long address, unsigned int flags);
+extern vm_fault_t handle_mm_fault(struct vm_fault *vmf);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags,
 			    bool *unlocked);
@@ -1413,8 +1422,7 @@ void unmap_mapping_pages(struct address_space *mapping,
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
 #else
-static inline vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
-		unsigned long address, unsigned int flags)
+static inline vm_fault_t handle_mm_fault(struct vm_fault *vmf)
 {
 	/* should never happen if there's no MMU */
 	BUG();
diff --git a/mm/gup.c b/mm/gup.c
index 1abc8b4afff6..c12d1e98614b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -496,6 +496,7 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
 static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		unsigned long address, unsigned int *flags, int *nonblocking)
 {
+	struct vm_fault vmf = {};
 	unsigned int fault_flags = 0;
 	vm_fault_t ret;
 
@@ -515,7 +516,8 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		fault_flags |= FAULT_FLAG_TRIED;
 	}
 
-	ret = handle_mm_fault(vma, address, fault_flags);
+	vm_fault_init(&vmf, vma, address, fault_flags);
+	ret = handle_mm_fault(&vmf);
 	if (ret & VM_FAULT_ERROR) {
 		int err = vm_fault_to_errno(ret, *flags);
 
@@ -817,6 +819,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long address, unsigned int fault_flags,
 		     bool *unlocked)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct *vma;
 	vm_fault_t ret, major = 0;
 
@@ -831,7 +834,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	if (!vma_permits_fault(vma, fault_flags))
 		return -EFAULT;
 
-	ret = handle_mm_fault(vma, address, fault_flags);
+	vm_fault_init(&vmf, vma, address, fault_flags);
+	ret = handle_mm_fault(&vmf);
 	major |= ret & VM_FAULT_MAJOR;
 	if (ret & VM_FAULT_ERROR) {
 		int err = vm_fault_to_errno(ret, 0);
diff --git a/mm/hmm.c b/mm/hmm.c
index c968e49f7a0c..695ef184a7d0 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -298,6 +298,7 @@ struct hmm_vma_walk {
 static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
 			    bool write_fault, uint64_t *pfn)
 {
+	struct vm_fault vmf = {};
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_REMOTE;
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
@@ -306,7 +307,8 @@ static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
 
 	flags |= hmm_vma_walk->block ? 0 : FAULT_FLAG_ALLOW_RETRY;
 	flags |= write_fault ? FAULT_FLAG_WRITE : 0;
-	ret = handle_mm_fault(vma, addr, flags);
+	vm_fault_init(&vmf, vma, addr, flags);
+	ret = handle_mm_fault(&vmf);
 	if (ret & VM_FAULT_RETRY)
 		return -EBUSY;
 	if (ret & VM_FAULT_ERROR) {
diff --git a/mm/ksm.c b/mm/ksm.c
index 5b0894b45ee5..4b6d90357ee2 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -478,10 +478,12 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 				FOLL_GET | FOLL_MIGRATION | FOLL_REMOTE);
 		if (IS_ERR_OR_NULL(page))
 			break;
-		if (PageKsm(page))
-			ret = handle_mm_fault(vma, addr,
-					FAULT_FLAG_WRITE | FAULT_FLAG_REMOTE);
-		else
+		if (PageKsm(page)) {
+			struct vm_fault vmf = {};
+			vm_fault_init(&vmf, vma, addr,
+				      FAULT_FLAG_WRITE | FAULT_FLAG_REMOTE);
+			ret = handle_mm_fault(&vmf);
+		} else
 			ret = VM_FAULT_WRITE;
 		put_page(page);
 	} while (!(ret & (VM_FAULT_WRITE | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | VM_FAULT_OOM)));
diff --git a/mm/memory.c b/mm/memory.c
index c467102a5cbc..9152c2a2c9f6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4024,36 +4024,34 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
-		unsigned long address, unsigned int flags)
+static vm_fault_t __handle_mm_fault(struct vm_fault *vmf)
 {
-	struct vm_fault vmf = {
-		.vma = vma,
-		.address = address & PAGE_MASK,
-		.flags = flags,
-		.pgoff = linear_page_index(vma, address),
-		.gfp_mask = __get_fault_gfp_mask(vma),
-	};
-	unsigned int dirty = flags & FAULT_FLAG_WRITE;
+	struct vm_area_struct *vma = vmf->vma;
+	unsigned long address = vmf->address;
+	unsigned int dirty = vmf->flags & FAULT_FLAG_WRITE;
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
 	p4d_t *p4d;
 	vm_fault_t ret;
 
+	vmf->address = address & PAGE_MASK;
+	vmf->pgoff = linear_page_index(vma, address);
+	vmf->gfp_mask = __get_fault_gfp_mask(vma);
+
 	pgd = pgd_offset(mm, address);
 	p4d = p4d_alloc(mm, pgd, address);
 	if (!p4d)
 		return VM_FAULT_OOM;
 
-	vmf.pud = pud_alloc(mm, p4d, address);
-	if (!vmf.pud)
+	vmf->pud = pud_alloc(mm, p4d, address);
+	if (!vmf->pud)
 		return VM_FAULT_OOM;
-	if (pud_none(*vmf.pud) && transparent_hugepage_enabled(vma)) {
-		ret = create_huge_pud(&vmf);
+	if (pud_none(*vmf->pud) && transparent_hugepage_enabled(vma)) {
+		ret = create_huge_pud(vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
 	} else {
-		pud_t orig_pud = *vmf.pud;
+		pud_t orig_pud = *vmf->pud;
 
 		barrier();
 		if (pud_trans_huge(orig_pud) || pud_devmap(orig_pud)) {
@@ -4061,50 +4059,50 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
 			/* NUMA case for anonymous PUDs would go here */
 
 			if (dirty && !pud_write(orig_pud)) {
-				ret = wp_huge_pud(&vmf, orig_pud);
+				ret = wp_huge_pud(vmf, orig_pud);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;
 			} else {
-				huge_pud_set_accessed(&vmf, orig_pud);
+				huge_pud_set_accessed(vmf, orig_pud);
 				return 0;
 			}
 		}
 	}
 
-	vmf.pmd = pmd_alloc(mm, vmf.pud, address);
-	if (!vmf.pmd)
+	vmf->pmd = pmd_alloc(mm, vmf->pud, address);
+	if (!vmf->pmd)
 		return VM_FAULT_OOM;
-	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)) {
-		ret = create_huge_pmd(&vmf);
+	if (pmd_none(*vmf->pmd) && transparent_hugepage_enabled(vma)) {
+		ret = create_huge_pmd(vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
 	} else {
-		pmd_t orig_pmd = *vmf.pmd;
+		pmd_t orig_pmd = *vmf->pmd;
 
 		barrier();
 		if (unlikely(is_swap_pmd(orig_pmd))) {
 			VM_BUG_ON(thp_migration_supported() &&
 					  !is_pmd_migration_entry(orig_pmd));
 			if (is_pmd_migration_entry(orig_pmd))
-				pmd_migration_entry_wait(mm, vmf.pmd);
+				pmd_migration_entry_wait(mm, vmf->pmd);
 			return 0;
 		}
 		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
 			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
-				return do_huge_pmd_numa_page(&vmf, orig_pmd);
+				return do_huge_pmd_numa_page(vmf, orig_pmd);
 
 			if (dirty && !pmd_write(orig_pmd)) {
-				ret = wp_huge_pmd(&vmf, orig_pmd);
+				ret = wp_huge_pmd(vmf, orig_pmd);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;
 			} else {
-				huge_pmd_set_accessed(&vmf, orig_pmd);
+				huge_pmd_set_accessed(vmf, orig_pmd);
 				return 0;
 			}
 		}
 	}
 
-	return handle_pte_fault(&vmf);
+	return handle_pte_fault(vmf);
 }
 
 /*
@@ -4113,9 +4111,10 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags)
+vm_fault_t handle_mm_fault(struct vm_fault *vmf)
 {
+	struct vm_area_struct *vma = vmf->vma;
+	unsigned int flags = vmf->flags;
 	vm_fault_t ret;
 
 	__set_current_state(TASK_RUNNING);
@@ -4139,9 +4138,9 @@ vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		mem_cgroup_enter_user_fault();
 
 	if (unlikely(is_vm_hugetlb_page(vma)))
-		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
+		ret = hugetlb_fault(vma->vm_mm, vma, vmf->address, flags);
 	else
-		ret = __handle_mm_fault(vma, address, flags);
+		ret = __handle_mm_fault(vmf);
 
 	if (flags & FAULT_FLAG_USER) {
 		mem_cgroup_exit_user_fault();
-- 
2.14.3
