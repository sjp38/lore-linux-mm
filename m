Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 84D226B0055
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:11 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id w19so6564392pgv.4
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u85si4249740pfi.205.2018.02.04.17.28.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 06/64] mm: teach pagefault paths about range locking
Date: Mon,  5 Feb 2018 02:26:56 +0100
Message-Id: <20180205012754.23615-7-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

In handle_mm_fault() we need to remember the range lock specified
when the mmap_sem was first taken as pf paths can drop the lock.
Although this patch may seem far too big at first, it is so due to
bisectability, and later conversion patches become quite easy to
follow. Furthermore, most of what this patch does is pass a pointer
to an 'mmrange' stack allocated parameter that is later used by the
vm_fault structure. The new interfaces are pretty much all in the
following areas:

- vma handling (vma_merge(), vma_adjust(), split_vma(), copy_vma())
- gup family (all except get_user_pages_unlocked(), which internally
  passes the mmrange).
- mm walking (walk_page_vma())
- mmap/unmap (do_mmap(), do_munmap())
- handle_mm_fault(), fixup_user_fault()

Most of the pain of the patch is updating all callers in the kernel
for this. While tedious, it is not that hard to review, I hope.
The idea is to use a local variable (no concurrency) whenever the
mmap_sem is taken and we end up in pf paths that end up retaking
the lock. Ie:

  DEFINE_RANGE_LOCK_FULL(mmrange);

  down_write(&mm->mmap_sem);
  some_fn(a, b, c, &mmrange);
  ....
   ....
    ...
     handle_mm_fault(vma, addr, flags, mmrange);
    ...
  up_write(&mm->mmap_sem);

Semantically nothing changes at all, and the 'mmrange' ends up
being unused for now. Later patches will use the variable when
the mmap_sem wrappers replace straightforward down/up.

Compile tested defconfigs on various non-x86 archs without breaking.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/alpha/mm/fault.c                      |  3 +-
 arch/arc/mm/fault.c                        |  3 +-
 arch/arm/mm/fault.c                        |  8 ++-
 arch/arm/probes/uprobes/core.c             |  5 +-
 arch/arm64/mm/fault.c                      |  7 ++-
 arch/cris/mm/fault.c                       |  3 +-
 arch/frv/mm/fault.c                        |  3 +-
 arch/hexagon/mm/vm_fault.c                 |  3 +-
 arch/ia64/mm/fault.c                       |  3 +-
 arch/m32r/mm/fault.c                       |  3 +-
 arch/m68k/mm/fault.c                       |  3 +-
 arch/metag/mm/fault.c                      |  3 +-
 arch/microblaze/mm/fault.c                 |  3 +-
 arch/mips/kernel/vdso.c                    |  3 +-
 arch/mips/mm/fault.c                       |  3 +-
 arch/mn10300/mm/fault.c                    |  3 +-
 arch/nios2/mm/fault.c                      |  3 +-
 arch/openrisc/mm/fault.c                   |  3 +-
 arch/parisc/mm/fault.c                     |  3 +-
 arch/powerpc/include/asm/mmu_context.h     |  3 +-
 arch/powerpc/include/asm/powernv.h         |  5 +-
 arch/powerpc/mm/copro_fault.c              |  4 +-
 arch/powerpc/mm/fault.c                    |  3 +-
 arch/powerpc/platforms/powernv/npu-dma.c   |  5 +-
 arch/riscv/mm/fault.c                      |  3 +-
 arch/s390/include/asm/gmap.h               | 14 +++--
 arch/s390/kvm/gaccess.c                    | 31 ++++++----
 arch/s390/mm/fault.c                       |  3 +-
 arch/s390/mm/gmap.c                        | 80 +++++++++++++++---------
 arch/score/mm/fault.c                      |  3 +-
 arch/sh/mm/fault.c                         |  3 +-
 arch/sparc/mm/fault_32.c                   |  6 +-
 arch/sparc/mm/fault_64.c                   |  3 +-
 arch/tile/mm/fault.c                       |  3 +-
 arch/um/include/asm/mmu_context.h          |  3 +-
 arch/um/kernel/trap.c                      |  3 +-
 arch/unicore32/mm/fault.c                  |  8 ++-
 arch/x86/entry/vdso/vma.c                  |  3 +-
 arch/x86/include/asm/mmu_context.h         |  5 +-
 arch/x86/include/asm/mpx.h                 |  6 +-
 arch/x86/mm/fault.c                        |  3 +-
 arch/x86/mm/mpx.c                          | 41 ++++++++-----
 arch/xtensa/mm/fault.c                     |  3 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c    |  3 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c    |  4 +-
 drivers/gpu/drm/radeon/radeon_ttm.c        |  4 +-
 drivers/infiniband/core/umem.c             |  3 +-
 drivers/infiniband/core/umem_odp.c         |  3 +-
 drivers/infiniband/hw/qib/qib_user_pages.c |  7 ++-
 drivers/infiniband/hw/usnic/usnic_uiom.c   |  3 +-
 drivers/iommu/amd_iommu_v2.c               |  5 +-
 drivers/iommu/intel-svm.c                  |  5 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c  | 18 ++++--
 drivers/misc/mic/scif/scif_rma.c           |  3 +-
 drivers/misc/sgi-gru/grufault.c            | 43 ++++++++-----
 drivers/vfio/vfio_iommu_type1.c            |  3 +-
 fs/aio.c                                   |  3 +-
 fs/binfmt_elf.c                            |  3 +-
 fs/exec.c                                  | 20 ++++--
 fs/proc/internal.h                         |  3 +
 fs/proc/task_mmu.c                         | 29 ++++++---
 fs/proc/vmcore.c                           | 14 ++++-
 fs/userfaultfd.c                           | 18 +++---
 include/asm-generic/mm_hooks.h             |  3 +-
 include/linux/hmm.h                        |  4 +-
 include/linux/ksm.h                        |  6 +-
 include/linux/migrate.h                    |  4 +-
 include/linux/mm.h                         | 73 +++++++++++++---------
 include/linux/uprobes.h                    | 15 +++--
 ipc/shm.c                                  | 14 +++--
 kernel/events/uprobes.c                    | 49 +++++++++------
 kernel/futex.c                             |  3 +-
 mm/frame_vector.c                          |  4 +-
 mm/gup.c                                   | 60 ++++++++++--------
 mm/hmm.c                                   | 37 ++++++-----
 mm/internal.h                              |  3 +-
 mm/ksm.c                                   | 24 +++++---
 mm/madvise.c                               | 58 ++++++++++-------
 mm/memcontrol.c                            | 13 ++--
 mm/memory.c                                | 10 +--
 mm/mempolicy.c                             | 35 ++++++-----
 mm/migrate.c                               | 20 +++---
 mm/mincore.c                               | 24 +++++---
 mm/mlock.c                                 | 33 ++++++----
 mm/mmap.c                                  | 99 +++++++++++++++++-------------
 mm/mprotect.c                              | 14 +++--
 mm/mremap.c                                | 30 +++++----
 mm/nommu.c                                 | 32 ++++++----
 mm/pagewalk.c                              | 56 +++++++++--------
 mm/process_vm_access.c                     |  4 +-
 mm/util.c                                  |  3 +-
 security/tomoyo/domain.c                   |  3 +-
 virt/kvm/async_pf.c                        |  3 +-
 virt/kvm/kvm_main.c                        | 16 +++--
 94 files changed, 784 insertions(+), 474 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index cd3c572ee912..690d86a00a20 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -90,6 +90,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	int fault, si_code = SEGV_MAPERR;
 	siginfo_t info;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* As of EV6, a load into $31/$f31 is a prefetch, and never faults
 	   (or is suppressed by the PALcode).  Support that for older CPUs
@@ -148,7 +149,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	/* If for any reason at all we couldn't handle the fault,
 	   make sure we exit gracefully rather than endlessly redo
 	   the fault.  */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index a0b7bd6d030d..e423f764f159 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -69,6 +69,7 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 	int fault, ret;
 	int write = regs->ecr_cause & ECR_C_PROTV_STORE;  /* ST/EX */
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * We fault-in kernel-space virtual memory on-demand. The
@@ -137,7 +138,7 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	/* If Pagefault was interrupted by SIGKILL, exit page fault "early" */
 	if (unlikely(fatal_signal_pending(current))) {
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index b75eada23d0a..99ae40b5851a 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -221,7 +221,8 @@ static inline bool access_error(unsigned int fsr, struct vm_area_struct *vma)
 
 static int __kprobes
 __do_page_fault(struct mm_struct *mm, unsigned long addr, unsigned int fsr,
-		unsigned int flags, struct task_struct *tsk)
+		unsigned int flags, struct task_struct *tsk,
+		struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	int fault;
@@ -243,7 +244,7 @@ __do_page_fault(struct mm_struct *mm, unsigned long addr, unsigned int fsr,
 		goto out;
 	}
 
-	return handle_mm_fault(vma, addr & PAGE_MASK, flags);
+	return handle_mm_fault(vma, addr & PAGE_MASK, flags, mmrange);
 
 check_stack:
 	/* Don't allow expansion below FIRST_USER_ADDRESS */
@@ -261,6 +262,7 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	struct mm_struct *mm;
 	int fault, sig, code;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (notify_page_fault(regs, fsr))
 		return 0;
@@ -308,7 +310,7 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 #endif
 	}
 
-	fault = __do_page_fault(mm, addr, fsr, flags, tsk);
+	fault = __do_page_fault(mm, addr, fsr, flags, tsk, &mmrange);
 
 	/* If we need to retry but a fatal signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because
diff --git a/arch/arm/probes/uprobes/core.c b/arch/arm/probes/uprobes/core.c
index d1329f1ba4e4..e8b893eaebcf 100644
--- a/arch/arm/probes/uprobes/core.c
+++ b/arch/arm/probes/uprobes/core.c
@@ -30,10 +30,11 @@ bool is_swbp_insn(uprobe_opcode_t *insn)
 }
 
 int set_swbp(struct arch_uprobe *auprobe, struct mm_struct *mm,
-	     unsigned long vaddr)
+	     unsigned long vaddr, struct range_lock *mmrange)
 {
 	return uprobe_write_opcode(mm, vaddr,
-		   __opcode_to_mem_arm(auprobe->bpinsn));
+				   __opcode_to_mem_arm(auprobe->bpinsn),
+				   mmrange);
 }
 
 bool arch_uprobe_ignore(struct arch_uprobe *auprobe, struct pt_regs *regs)
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index ce441d29e7f6..1f3ad9e4f214 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -342,7 +342,7 @@ static void do_bad_area(unsigned long addr, unsigned int esr, struct pt_regs *re
 
 static int __do_page_fault(struct mm_struct *mm, unsigned long addr,
 			   unsigned int mm_flags, unsigned long vm_flags,
-			   struct task_struct *tsk)
+			   struct task_struct *tsk, struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	int fault;
@@ -368,7 +368,7 @@ static int __do_page_fault(struct mm_struct *mm, unsigned long addr,
 		goto out;
 	}
 
-	return handle_mm_fault(vma, addr & PAGE_MASK, mm_flags);
+	return handle_mm_fault(vma, addr & PAGE_MASK, mm_flags, mmrange);
 
 check_stack:
 	if (vma->vm_flags & VM_GROWSDOWN && !expand_stack(vma, addr))
@@ -390,6 +390,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 	int fault, sig, code, major = 0;
 	unsigned long vm_flags = VM_READ | VM_WRITE;
 	unsigned int mm_flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (notify_page_fault(regs, esr))
 		return 0;
@@ -450,7 +451,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 #endif
 	}
 
-	fault = __do_page_fault(mm, addr, mm_flags, vm_flags, tsk);
+	fault = __do_page_fault(mm, addr, mm_flags, vm_flags, tsk, &mmrange);
 	major |= fault & VM_FAULT_MAJOR;
 
 	if (fault & VM_FAULT_RETRY) {
diff --git a/arch/cris/mm/fault.c b/arch/cris/mm/fault.c
index 29cc58038b98..16af16d77269 100644
--- a/arch/cris/mm/fault.c
+++ b/arch/cris/mm/fault.c
@@ -61,6 +61,7 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	siginfo_t info;
 	int fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	D(printk(KERN_DEBUG
 		 "Page fault for %lX on %X at %lX, prot %d write %d\n",
@@ -170,7 +171,7 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	 * the fault.
 	 */
 
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/frv/mm/fault.c b/arch/frv/mm/fault.c
index cbe7aec863e3..494d33b628fc 100644
--- a/arch/frv/mm/fault.c
+++ b/arch/frv/mm/fault.c
@@ -41,6 +41,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
 	pud_t *pue;
 	pte_t *pte;
 	int fault;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 #if 0
 	const char *atxc[16] = {
@@ -165,7 +166,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, ear0, flags);
+	fault = handle_mm_fault(vma, ear0, flags, &mmrange);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index 3eec33c5cfd7..7d6ada2c2230 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -55,6 +55,7 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 	int fault;
 	const struct exception_table_entry *fixup;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * If we're in an interrupt or have no user context,
@@ -102,7 +103,7 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 		break;
 	}
 
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index dfdc152d6737..44f0ec5f77c2 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -89,6 +89,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	unsigned long mask;
 	int fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	mask = ((((isr >> IA64_ISR_X_BIT) & 1UL) << VM_EXEC_BIT)
 		| (((isr >> IA64_ISR_W_BIT) & 1UL) << VM_WRITE_BIT));
@@ -162,7 +163,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/m32r/mm/fault.c b/arch/m32r/mm/fault.c
index 46d9a5ca0e3a..0129aea46729 100644
--- a/arch/m32r/mm/fault.c
+++ b/arch/m32r/mm/fault.c
@@ -82,6 +82,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	unsigned long flags = 0;
 	int fault;
 	siginfo_t info;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * If BPSW IE bit enable --> set PSW IE bit
@@ -197,7 +198,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 */
 	addr = (address & PAGE_MASK);
 	set_thread_fault_code(error_code);
-	fault = handle_mm_fault(vma, addr, flags);
+	fault = handle_mm_fault(vma, addr, flags, &mmrange);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index 03253c4f8e6a..ec32a193726f 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -75,6 +75,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	struct vm_area_struct * vma;
 	int fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	pr_debug("do page fault:\nregs->sr=%#x, regs->pc=%#lx, address=%#lx, %ld, %p\n",
 		regs->sr, regs->pc, address, error_code, mm ? mm->pgd : NULL);
@@ -138,7 +139,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * the fault.
 	 */
 
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 	pr_debug("handle_mm_fault returns %d\n", fault);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
diff --git a/arch/metag/mm/fault.c b/arch/metag/mm/fault.c
index de54fe686080..e16ba0ea7ea1 100644
--- a/arch/metag/mm/fault.c
+++ b/arch/metag/mm/fault.c
@@ -56,6 +56,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	siginfo_t info;
 	int fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	tsk = current;
 
@@ -135,7 +136,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return 0;
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index f91b30f8aaa8..fd49efbdfbf4 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -93,6 +93,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	int is_write = error_code & ESR_S;
 	int fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	regs->ear = address;
 	regs->esr = error_code;
@@ -216,7 +217,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/mips/kernel/vdso.c b/arch/mips/kernel/vdso.c
index 019035d7225c..56b7c29991db 100644
--- a/arch/mips/kernel/vdso.c
+++ b/arch/mips/kernel/vdso.c
@@ -102,6 +102,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	unsigned long gic_size, vvar_size, size, base, data_addr, vdso_addr, gic_pfn;
 	struct vm_area_struct *vma;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
@@ -110,7 +111,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	base = mmap_region(NULL, STACK_TOP, PAGE_SIZE,
 			   VM_READ|VM_WRITE|VM_EXEC|
 			   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-			   0, NULL);
+			   0, NULL, &mmrange);
 	if (IS_ERR_VALUE(base)) {
 		ret = base;
 		goto out;
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 4f8f5bf46977..1433edd01d09 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -47,6 +47,7 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	static DEFINE_RATELIMIT_STATE(ratelimit_state, 5 * HZ, 10);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 #if 0
 	printk("Cpu%d[%s:%d:%0*lx:%ld:%0*lx]\n", raw_smp_processor_id(),
@@ -152,7 +153,7 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
index f0bfa1448744..71c38f0c8702 100644
--- a/arch/mn10300/mm/fault.c
+++ b/arch/mn10300/mm/fault.c
@@ -125,6 +125,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long fault_code,
 	siginfo_t info;
 	int fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 #ifdef CONFIG_GDBSTUB
 	/* handle GDB stub causing a fault */
@@ -254,7 +255,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long fault_code,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index b804dd06ea1c..768678b685af 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -49,6 +49,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 	int code = SEGV_MAPERR;
 	int fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	cause >>= 2;
 
@@ -132,7 +133,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index d0021dfae20a..75ddb1e8e7e7 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -55,6 +55,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 	siginfo_t info;
 	int fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	tsk = current;
 
@@ -163,7 +164,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * the fault.
 	 */
 
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index e247edbca68e..79db33a0cb0c 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -264,6 +264,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 	unsigned long acc_type;
 	int fault = 0;
 	unsigned int flags;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (faulthandler_disabled())
 		goto no_context;
@@ -301,7 +302,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 	 * fault.
 	 */
 
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 051b3d63afe3..089b3cf948eb 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -176,7 +176,8 @@ extern void arch_exit_mmap(struct mm_struct *mm);
 
 static inline void arch_unmap(struct mm_struct *mm,
 			      struct vm_area_struct *vma,
-			      unsigned long start, unsigned long end)
+			      unsigned long start, unsigned long end,
+			      struct range_lock *mmrange)
 {
 	if (start <= mm->context.vdso_base && mm->context.vdso_base < end)
 		mm->context.vdso_base = 0;
diff --git a/arch/powerpc/include/asm/powernv.h b/arch/powerpc/include/asm/powernv.h
index dc5f6a5d4575..805ff3ba94e1 100644
--- a/arch/powerpc/include/asm/powernv.h
+++ b/arch/powerpc/include/asm/powernv.h
@@ -21,7 +21,7 @@ extern void pnv_npu2_destroy_context(struct npu_context *context,
 				struct pci_dev *gpdev);
 extern int pnv_npu2_handle_fault(struct npu_context *context, uintptr_t *ea,
 				unsigned long *flags, unsigned long *status,
-				int count);
+				int count, struct range_lock *mmrange);
 
 void pnv_tm_init(void);
 #else
@@ -35,7 +35,8 @@ static inline void pnv_npu2_destroy_context(struct npu_context *context,
 
 static inline int pnv_npu2_handle_fault(struct npu_context *context,
 					uintptr_t *ea, unsigned long *flags,
-					unsigned long *status, int count) {
+					unsigned long *status, int count,
+					struct range_lock *mmrange) {
 	return -ENODEV;
 }
 
diff --git a/arch/powerpc/mm/copro_fault.c b/arch/powerpc/mm/copro_fault.c
index 697b70ad1195..8f5e604828a1 100644
--- a/arch/powerpc/mm/copro_fault.c
+++ b/arch/powerpc/mm/copro_fault.c
@@ -39,6 +39,7 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 	struct vm_area_struct *vma;
 	unsigned long is_write;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (mm == NULL)
 		return -EFAULT;
@@ -77,7 +78,8 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 	}
 
 	ret = 0;
-	*flt = handle_mm_fault(vma, ea, is_write ? FAULT_FLAG_WRITE : 0);
+	*flt = handle_mm_fault(vma, ea, is_write ? FAULT_FLAG_WRITE : 0,
+			       &mmrange);
 	if (unlikely(*flt & VM_FAULT_ERROR)) {
 		if (*flt & VM_FAULT_OOM) {
 			ret = -ENOMEM;
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 866446cf2d9a..d562dc88687d 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -399,6 +399,7 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 	int is_write = page_fault_is_write(error_code);
 	int fault, major = 0;
 	bool store_update_sp = false;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (notify_page_fault(regs))
 		return 0;
@@ -514,7 +515,7 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 #ifdef CONFIG_PPC_MEM_KEYS
 	/*
diff --git a/arch/powerpc/platforms/powernv/npu-dma.c b/arch/powerpc/platforms/powernv/npu-dma.c
index 0a253b64ac5f..759e9a4c7479 100644
--- a/arch/powerpc/platforms/powernv/npu-dma.c
+++ b/arch/powerpc/platforms/powernv/npu-dma.c
@@ -789,7 +789,8 @@ EXPORT_SYMBOL(pnv_npu2_destroy_context);
  * Assumes mmap_sem is held for the contexts associated mm.
  */
 int pnv_npu2_handle_fault(struct npu_context *context, uintptr_t *ea,
-			unsigned long *flags, unsigned long *status, int count)
+			  unsigned long *flags, unsigned long *status,
+			  int count, struct range_lock *mmrange)
 {
 	u64 rc = 0, result = 0;
 	int i, is_write;
@@ -807,7 +808,7 @@ int pnv_npu2_handle_fault(struct npu_context *context, uintptr_t *ea,
 		is_write = flags[i] & NPU2_WRITE;
 		rc = get_user_pages_remote(NULL, mm, ea[i], 1,
 					is_write ? FOLL_WRITE : 0,
-					page, NULL, NULL);
+					page, NULL, NULL, mmrange);
 
 		/*
 		 * To support virtualised environments we will have to do an
diff --git a/arch/riscv/mm/fault.c b/arch/riscv/mm/fault.c
index 148c98ca9b45..75d15e73ba39 100644
--- a/arch/riscv/mm/fault.c
+++ b/arch/riscv/mm/fault.c
@@ -42,6 +42,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
 	unsigned long addr, cause;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 	int fault, code = SEGV_MAPERR;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	cause = regs->scause;
 	addr = regs->sbadaddr;
@@ -119,7 +120,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, addr, flags);
+	fault = handle_mm_fault(vma, addr, flags, &mmrange);
 
 	/*
 	 * If we need to retry but a fatal signal is pending, handle the
diff --git a/arch/s390/include/asm/gmap.h b/arch/s390/include/asm/gmap.h
index e07cce88dfb0..117c19a947c9 100644
--- a/arch/s390/include/asm/gmap.h
+++ b/arch/s390/include/asm/gmap.h
@@ -107,22 +107,24 @@ void gmap_discard(struct gmap *, unsigned long from, unsigned long to);
 void __gmap_zap(struct gmap *, unsigned long gaddr);
 void gmap_unlink(struct mm_struct *, unsigned long *table, unsigned long vmaddr);
 
-int gmap_read_table(struct gmap *gmap, unsigned long gaddr, unsigned long *val);
+int gmap_read_table(struct gmap *gmap, unsigned long gaddr, unsigned long *val,
+		    struct range_lock *mmrange);
 
 struct gmap *gmap_shadow(struct gmap *parent, unsigned long asce,
 			 int edat_level);
 int gmap_shadow_valid(struct gmap *sg, unsigned long asce, int edat_level);
 int gmap_shadow_r2t(struct gmap *sg, unsigned long saddr, unsigned long r2t,
-		    int fake);
+		    int fake, struct range_lock *mmrange);
 int gmap_shadow_r3t(struct gmap *sg, unsigned long saddr, unsigned long r3t,
-		    int fake);
+		    int fake, struct range_lock *mmrange);
 int gmap_shadow_sgt(struct gmap *sg, unsigned long saddr, unsigned long sgt,
-		    int fake);
+		    int fake, struct range_lock *mmrange);
 int gmap_shadow_pgt(struct gmap *sg, unsigned long saddr, unsigned long pgt,
-		    int fake);
+		    int fake, struct range_lock *mmrange);
 int gmap_shadow_pgt_lookup(struct gmap *sg, unsigned long saddr,
 			   unsigned long *pgt, int *dat_protection, int *fake);
-int gmap_shadow_page(struct gmap *sg, unsigned long saddr, pte_t pte);
+int gmap_shadow_page(struct gmap *sg, unsigned long saddr, pte_t pte,
+		     struct range_lock *mmrange);
 
 void gmap_register_pte_notifier(struct gmap_notifier *);
 void gmap_unregister_pte_notifier(struct gmap_notifier *);
diff --git a/arch/s390/kvm/gaccess.c b/arch/s390/kvm/gaccess.c
index c24bfa72baf7..ff739b86df36 100644
--- a/arch/s390/kvm/gaccess.c
+++ b/arch/s390/kvm/gaccess.c
@@ -978,10 +978,11 @@ int kvm_s390_check_low_addr_prot_real(struct kvm_vcpu *vcpu, unsigned long gra)
  * @saddr: faulting address in the shadow gmap
  * @pgt: pointer to the page table address result
  * @fake: pgt references contiguous guest memory block, not a pgtable
+ * @mmrange: address space range locking
  */
 static int kvm_s390_shadow_tables(struct gmap *sg, unsigned long saddr,
 				  unsigned long *pgt, int *dat_protection,
-				  int *fake)
+				  int *fake, struct range_lock *mmrange)
 {
 	struct gmap *parent;
 	union asce asce;
@@ -1034,7 +1035,8 @@ static int kvm_s390_shadow_tables(struct gmap *sg, unsigned long saddr,
 			rfte.val = ptr;
 			goto shadow_r2t;
 		}
-		rc = gmap_read_table(parent, ptr + vaddr.rfx * 8, &rfte.val);
+		rc = gmap_read_table(parent, ptr + vaddr.rfx * 8, &rfte.val,
+				     mmrange);
 		if (rc)
 			return rc;
 		if (rfte.i)
@@ -1047,7 +1049,7 @@ static int kvm_s390_shadow_tables(struct gmap *sg, unsigned long saddr,
 			*dat_protection |= rfte.p;
 		ptr = rfte.rto * PAGE_SIZE;
 shadow_r2t:
-		rc = gmap_shadow_r2t(sg, saddr, rfte.val, *fake);
+		rc = gmap_shadow_r2t(sg, saddr, rfte.val, *fake, mmrange);
 		if (rc)
 			return rc;
 		/* fallthrough */
@@ -1060,7 +1062,8 @@ static int kvm_s390_shadow_tables(struct gmap *sg, unsigned long saddr,
 			rste.val = ptr;
 			goto shadow_r3t;
 		}
-		rc = gmap_read_table(parent, ptr + vaddr.rsx * 8, &rste.val);
+		rc = gmap_read_table(parent, ptr + vaddr.rsx * 8, &rste.val,
+				     mmrange);
 		if (rc)
 			return rc;
 		if (rste.i)
@@ -1074,7 +1077,7 @@ static int kvm_s390_shadow_tables(struct gmap *sg, unsigned long saddr,
 		ptr = rste.rto * PAGE_SIZE;
 shadow_r3t:
 		rste.p |= *dat_protection;
-		rc = gmap_shadow_r3t(sg, saddr, rste.val, *fake);
+		rc = gmap_shadow_r3t(sg, saddr, rste.val, *fake, mmrange);
 		if (rc)
 			return rc;
 		/* fallthrough */
@@ -1087,7 +1090,8 @@ static int kvm_s390_shadow_tables(struct gmap *sg, unsigned long saddr,
 			rtte.val = ptr;
 			goto shadow_sgt;
 		}
-		rc = gmap_read_table(parent, ptr + vaddr.rtx * 8, &rtte.val);
+		rc = gmap_read_table(parent, ptr + vaddr.rtx * 8, &rtte.val,
+				     mmrange);
 		if (rc)
 			return rc;
 		if (rtte.i)
@@ -1110,7 +1114,7 @@ static int kvm_s390_shadow_tables(struct gmap *sg, unsigned long saddr,
 		ptr = rtte.fc0.sto * PAGE_SIZE;
 shadow_sgt:
 		rtte.fc0.p |= *dat_protection;
-		rc = gmap_shadow_sgt(sg, saddr, rtte.val, *fake);
+		rc = gmap_shadow_sgt(sg, saddr, rtte.val, *fake, mmrange);
 		if (rc)
 			return rc;
 		/* fallthrough */
@@ -1123,7 +1127,8 @@ static int kvm_s390_shadow_tables(struct gmap *sg, unsigned long saddr,
 			ste.val = ptr;
 			goto shadow_pgt;
 		}
-		rc = gmap_read_table(parent, ptr + vaddr.sx * 8, &ste.val);
+		rc = gmap_read_table(parent, ptr + vaddr.sx * 8, &ste.val,
+				     mmrange);
 		if (rc)
 			return rc;
 		if (ste.i)
@@ -1142,7 +1147,7 @@ static int kvm_s390_shadow_tables(struct gmap *sg, unsigned long saddr,
 		ptr = ste.fc0.pto * (PAGE_SIZE / 2);
 shadow_pgt:
 		ste.fc0.p |= *dat_protection;
-		rc = gmap_shadow_pgt(sg, saddr, ste.val, *fake);
+		rc = gmap_shadow_pgt(sg, saddr, ste.val, *fake, mmrange);
 		if (rc)
 			return rc;
 	}
@@ -1172,6 +1177,7 @@ int kvm_s390_shadow_fault(struct kvm_vcpu *vcpu, struct gmap *sg,
 	unsigned long pgt;
 	int dat_protection, fake;
 	int rc;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	down_read(&sg->mm->mmap_sem);
 	/*
@@ -1184,7 +1190,7 @@ int kvm_s390_shadow_fault(struct kvm_vcpu *vcpu, struct gmap *sg,
 	rc = gmap_shadow_pgt_lookup(sg, saddr, &pgt, &dat_protection, &fake);
 	if (rc)
 		rc = kvm_s390_shadow_tables(sg, saddr, &pgt, &dat_protection,
-					    &fake);
+					    &fake, &mmrange);
 
 	vaddr.addr = saddr;
 	if (fake) {
@@ -1192,7 +1198,8 @@ int kvm_s390_shadow_fault(struct kvm_vcpu *vcpu, struct gmap *sg,
 		goto shadow_page;
 	}
 	if (!rc)
-		rc = gmap_read_table(sg->parent, pgt + vaddr.px * 8, &pte.val);
+		rc = gmap_read_table(sg->parent, pgt + vaddr.px * 8,
+				     &pte.val, &mmrange);
 	if (!rc && pte.i)
 		rc = PGM_PAGE_TRANSLATION;
 	if (!rc && pte.z)
@@ -1200,7 +1207,7 @@ int kvm_s390_shadow_fault(struct kvm_vcpu *vcpu, struct gmap *sg,
 shadow_page:
 	pte.p |= dat_protection;
 	if (!rc)
-		rc = gmap_shadow_page(sg, saddr, __pte(pte.val));
+		rc = gmap_shadow_page(sg, saddr, __pte(pte.val), &mmrange);
 	ipte_unlock(vcpu);
 	up_read(&sg->mm->mmap_sem);
 	return rc;
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 93faeca52284..17ba3c402f9d 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -421,6 +421,7 @@ static inline int do_exception(struct pt_regs *regs, int access)
 	unsigned long address;
 	unsigned int flags;
 	int fault;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	tsk = current;
 	/*
@@ -507,7 +508,7 @@ static inline int do_exception(struct pt_regs *regs, int access)
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 	/* No reason to continue if interrupted by SIGKILL. */
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
 		fault = VM_FAULT_SIGNAL;
diff --git a/arch/s390/mm/gmap.c b/arch/s390/mm/gmap.c
index 2c55a2b9d6c6..b12a44813022 100644
--- a/arch/s390/mm/gmap.c
+++ b/arch/s390/mm/gmap.c
@@ -621,6 +621,7 @@ int gmap_fault(struct gmap *gmap, unsigned long gaddr,
 	unsigned long vmaddr;
 	int rc;
 	bool unlocked;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	down_read(&gmap->mm->mmap_sem);
 
@@ -632,7 +633,7 @@ int gmap_fault(struct gmap *gmap, unsigned long gaddr,
 		goto out_up;
 	}
 	if (fixup_user_fault(current, gmap->mm, vmaddr, fault_flags,
-			     &unlocked)) {
+			     &unlocked, &mmrange)) {
 		rc = -EFAULT;
 		goto out_up;
 	}
@@ -835,13 +836,15 @@ static pte_t *gmap_pte_op_walk(struct gmap *gmap, unsigned long gaddr,
  * @gaddr: virtual address in the guest address space
  * @vmaddr: address in the host process address space
  * @prot: indicates access rights: PROT_NONE, PROT_READ or PROT_WRITE
+ * @mmrange: address space range locking
  *
  * Returns 0 if the caller can retry __gmap_translate (might fail again),
  * -ENOMEM if out of memory and -EFAULT if anything goes wrong while fixing
  * up or connecting the gmap page table.
  */
 static int gmap_pte_op_fixup(struct gmap *gmap, unsigned long gaddr,
-			     unsigned long vmaddr, int prot)
+			     unsigned long vmaddr, int prot,
+			     struct range_lock *mmrange)
 {
 	struct mm_struct *mm = gmap->mm;
 	unsigned int fault_flags;
@@ -849,7 +852,8 @@ static int gmap_pte_op_fixup(struct gmap *gmap, unsigned long gaddr,
 
 	BUG_ON(gmap_is_shadow(gmap));
 	fault_flags = (prot == PROT_WRITE) ? FAULT_FLAG_WRITE : 0;
-	if (fixup_user_fault(current, mm, vmaddr, fault_flags, &unlocked))
+	if (fixup_user_fault(current, mm, vmaddr, fault_flags, &unlocked,
+			     mmrange))
 		return -EFAULT;
 	if (unlocked)
 		/* lost mmap_sem, caller has to retry __gmap_translate */
@@ -874,6 +878,7 @@ static void gmap_pte_op_end(spinlock_t *ptl)
  * @len: size of area
  * @prot: indicates access rights: PROT_NONE, PROT_READ or PROT_WRITE
  * @bits: pgste notification bits to set
+ * @mmrange: address space range locking
  *
  * Returns 0 if successfully protected, -ENOMEM if out of memory and
  * -EFAULT if gaddr is invalid (or mapping for shadows is missing).
@@ -881,7 +886,8 @@ static void gmap_pte_op_end(spinlock_t *ptl)
  * Called with sg->mm->mmap_sem in read.
  */
 static int gmap_protect_range(struct gmap *gmap, unsigned long gaddr,
-			      unsigned long len, int prot, unsigned long bits)
+			      unsigned long len, int prot, unsigned long bits,
+			      struct range_lock *mmrange)
 {
 	unsigned long vmaddr;
 	spinlock_t *ptl;
@@ -900,7 +906,8 @@ static int gmap_protect_range(struct gmap *gmap, unsigned long gaddr,
 			vmaddr = __gmap_translate(gmap, gaddr);
 			if (IS_ERR_VALUE(vmaddr))
 				return vmaddr;
-			rc = gmap_pte_op_fixup(gmap, gaddr, vmaddr, prot);
+			rc = gmap_pte_op_fixup(gmap, gaddr, vmaddr, prot,
+					       mmrange);
 			if (rc)
 				return rc;
 			continue;
@@ -929,13 +936,14 @@ int gmap_mprotect_notify(struct gmap *gmap, unsigned long gaddr,
 			 unsigned long len, int prot)
 {
 	int rc;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if ((gaddr & ~PAGE_MASK) || (len & ~PAGE_MASK) || gmap_is_shadow(gmap))
 		return -EINVAL;
 	if (!MACHINE_HAS_ESOP && prot == PROT_READ)
 		return -EINVAL;
 	down_read(&gmap->mm->mmap_sem);
-	rc = gmap_protect_range(gmap, gaddr, len, prot, PGSTE_IN_BIT);
+	rc = gmap_protect_range(gmap, gaddr, len, prot, PGSTE_IN_BIT, &mmrange);
 	up_read(&gmap->mm->mmap_sem);
 	return rc;
 }
@@ -947,6 +955,7 @@ EXPORT_SYMBOL_GPL(gmap_mprotect_notify);
  * @gmap: pointer to guest mapping meta data structure
  * @gaddr: virtual address in the guest address space
  * @val: pointer to the unsigned long value to return
+ * @mmrange: address space range locking
  *
  * Returns 0 if the value was read, -ENOMEM if out of memory and -EFAULT
  * if reading using the virtual address failed. -EINVAL if called on a gmap
@@ -954,7 +963,8 @@ EXPORT_SYMBOL_GPL(gmap_mprotect_notify);
  *
  * Called with gmap->mm->mmap_sem in read.
  */
-int gmap_read_table(struct gmap *gmap, unsigned long gaddr, unsigned long *val)
+int gmap_read_table(struct gmap *gmap, unsigned long gaddr, unsigned long *val,
+		    struct range_lock *mmrange)
 {
 	unsigned long address, vmaddr;
 	spinlock_t *ptl;
@@ -986,7 +996,7 @@ int gmap_read_table(struct gmap *gmap, unsigned long gaddr, unsigned long *val)
 			rc = vmaddr;
 			break;
 		}
-		rc = gmap_pte_op_fixup(gmap, gaddr, vmaddr, PROT_READ);
+		rc = gmap_pte_op_fixup(gmap, gaddr, vmaddr, PROT_READ, mmrange);
 		if (rc)
 			break;
 	}
@@ -1026,12 +1036,14 @@ static inline void gmap_insert_rmap(struct gmap *sg, unsigned long vmaddr,
  * @raddr: rmap address in the shadow gmap
  * @paddr: address in the parent guest address space
  * @len: length of the memory area to protect
+ * @mmrange: address space range locking
  *
  * Returns 0 if successfully protected and the rmap was created, -ENOMEM
  * if out of memory and -EFAULT if paddr is invalid.
  */
 static int gmap_protect_rmap(struct gmap *sg, unsigned long raddr,
-			     unsigned long paddr, unsigned long len)
+			     unsigned long paddr, unsigned long len,
+			     struct range_lock *mmrange)
 {
 	struct gmap *parent;
 	struct gmap_rmap *rmap;
@@ -1069,7 +1081,7 @@ static int gmap_protect_rmap(struct gmap *sg, unsigned long raddr,
 		radix_tree_preload_end();
 		if (rc) {
 			kfree(rmap);
-			rc = gmap_pte_op_fixup(parent, paddr, vmaddr, PROT_READ);
+			rc = gmap_pte_op_fixup(parent, paddr, vmaddr, PROT_READ, mmrange);
 			if (rc)
 				return rc;
 			continue;
@@ -1473,6 +1485,7 @@ struct gmap *gmap_shadow(struct gmap *parent, unsigned long asce,
 	struct gmap *sg, *new;
 	unsigned long limit;
 	int rc;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	BUG_ON(gmap_is_shadow(parent));
 	spin_lock(&parent->shadow_lock);
@@ -1526,7 +1539,7 @@ struct gmap *gmap_shadow(struct gmap *parent, unsigned long asce,
 	down_read(&parent->mm->mmap_sem);
 	rc = gmap_protect_range(parent, asce & _ASCE_ORIGIN,
 				((asce & _ASCE_TABLE_LENGTH) + 1) * PAGE_SIZE,
-				PROT_READ, PGSTE_VSIE_BIT);
+				PROT_READ, PGSTE_VSIE_BIT, &mmrange);
 	up_read(&parent->mm->mmap_sem);
 	spin_lock(&parent->shadow_lock);
 	new->initialized = true;
@@ -1546,6 +1559,7 @@ EXPORT_SYMBOL_GPL(gmap_shadow);
  * @saddr: faulting address in the shadow gmap
  * @r2t: parent gmap address of the region 2 table to get shadowed
  * @fake: r2t references contiguous guest memory block, not a r2t
+ * @mmrange: address space range locking
  *
  * The r2t parameter specifies the address of the source table. The
  * four pages of the source table are made read-only in the parent gmap
@@ -1559,7 +1573,7 @@ EXPORT_SYMBOL_GPL(gmap_shadow);
  * Called with sg->mm->mmap_sem in read.
  */
 int gmap_shadow_r2t(struct gmap *sg, unsigned long saddr, unsigned long r2t,
-		    int fake)
+		    int fake, struct range_lock *mmrange)
 {
 	unsigned long raddr, origin, offset, len;
 	unsigned long *s_r2t, *table;
@@ -1608,7 +1622,7 @@ int gmap_shadow_r2t(struct gmap *sg, unsigned long saddr, unsigned long r2t,
 	origin = r2t & _REGION_ENTRY_ORIGIN;
 	offset = ((r2t & _REGION_ENTRY_OFFSET) >> 6) * PAGE_SIZE;
 	len = ((r2t & _REGION_ENTRY_LENGTH) + 1) * PAGE_SIZE - offset;
-	rc = gmap_protect_rmap(sg, raddr, origin + offset, len);
+	rc = gmap_protect_rmap(sg, raddr, origin + offset, len, mmrange);
 	spin_lock(&sg->guest_table_lock);
 	if (!rc) {
 		table = gmap_table_walk(sg, saddr, 4);
@@ -1635,6 +1649,7 @@ EXPORT_SYMBOL_GPL(gmap_shadow_r2t);
  * @saddr: faulting address in the shadow gmap
  * @r3t: parent gmap address of the region 3 table to get shadowed
  * @fake: r3t references contiguous guest memory block, not a r3t
+ * @mmrange: address space range locking
  *
  * Returns 0 if successfully shadowed or already shadowed, -EAGAIN if the
  * shadow table structure is incomplete, -ENOMEM if out of memory and
@@ -1643,7 +1658,7 @@ EXPORT_SYMBOL_GPL(gmap_shadow_r2t);
  * Called with sg->mm->mmap_sem in read.
  */
 int gmap_shadow_r3t(struct gmap *sg, unsigned long saddr, unsigned long r3t,
-		    int fake)
+		    int fake, struct range_lock *mmrange)
 {
 	unsigned long raddr, origin, offset, len;
 	unsigned long *s_r3t, *table;
@@ -1691,7 +1706,7 @@ int gmap_shadow_r3t(struct gmap *sg, unsigned long saddr, unsigned long r3t,
 	origin = r3t & _REGION_ENTRY_ORIGIN;
 	offset = ((r3t & _REGION_ENTRY_OFFSET) >> 6) * PAGE_SIZE;
 	len = ((r3t & _REGION_ENTRY_LENGTH) + 1) * PAGE_SIZE - offset;
-	rc = gmap_protect_rmap(sg, raddr, origin + offset, len);
+	rc = gmap_protect_rmap(sg, raddr, origin + offset, len, mmrange);
 	spin_lock(&sg->guest_table_lock);
 	if (!rc) {
 		table = gmap_table_walk(sg, saddr, 3);
@@ -1718,6 +1733,7 @@ EXPORT_SYMBOL_GPL(gmap_shadow_r3t);
  * @saddr: faulting address in the shadow gmap
  * @sgt: parent gmap address of the segment table to get shadowed
  * @fake: sgt references contiguous guest memory block, not a sgt
+ * @mmrange: address space range locking
  *
  * Returns: 0 if successfully shadowed or already shadowed, -EAGAIN if the
  * shadow table structure is incomplete, -ENOMEM if out of memory and
@@ -1726,7 +1742,7 @@ EXPORT_SYMBOL_GPL(gmap_shadow_r3t);
  * Called with sg->mm->mmap_sem in read.
  */
 int gmap_shadow_sgt(struct gmap *sg, unsigned long saddr, unsigned long sgt,
-		    int fake)
+		    int fake, struct range_lock *mmrange)
 {
 	unsigned long raddr, origin, offset, len;
 	unsigned long *s_sgt, *table;
@@ -1775,7 +1791,7 @@ int gmap_shadow_sgt(struct gmap *sg, unsigned long saddr, unsigned long sgt,
 	origin = sgt & _REGION_ENTRY_ORIGIN;
 	offset = ((sgt & _REGION_ENTRY_OFFSET) >> 6) * PAGE_SIZE;
 	len = ((sgt & _REGION_ENTRY_LENGTH) + 1) * PAGE_SIZE - offset;
-	rc = gmap_protect_rmap(sg, raddr, origin + offset, len);
+	rc = gmap_protect_rmap(sg, raddr, origin + offset, len, mmrange);
 	spin_lock(&sg->guest_table_lock);
 	if (!rc) {
 		table = gmap_table_walk(sg, saddr, 2);
@@ -1842,6 +1858,7 @@ EXPORT_SYMBOL_GPL(gmap_shadow_pgt_lookup);
  * @saddr: faulting address in the shadow gmap
  * @pgt: parent gmap address of the page table to get shadowed
  * @fake: pgt references contiguous guest memory block, not a pgtable
+ * @mmrange: address space range locking
  *
  * Returns 0 if successfully shadowed or already shadowed, -EAGAIN if the
  * shadow table structure is incomplete, -ENOMEM if out of memory,
@@ -1850,7 +1867,7 @@ EXPORT_SYMBOL_GPL(gmap_shadow_pgt_lookup);
  * Called with gmap->mm->mmap_sem in read
  */
 int gmap_shadow_pgt(struct gmap *sg, unsigned long saddr, unsigned long pgt,
-		    int fake)
+		    int fake, struct range_lock *mmrange)
 {
 	unsigned long raddr, origin;
 	unsigned long *s_pgt, *table;
@@ -1894,7 +1911,7 @@ int gmap_shadow_pgt(struct gmap *sg, unsigned long saddr, unsigned long pgt,
 	/* Make pgt read-only in parent gmap page table (not the pgste) */
 	raddr = (saddr & _SEGMENT_MASK) | _SHADOW_RMAP_SEGMENT;
 	origin = pgt & _SEGMENT_ENTRY_ORIGIN & PAGE_MASK;
-	rc = gmap_protect_rmap(sg, raddr, origin, PAGE_SIZE);
+	rc = gmap_protect_rmap(sg, raddr, origin, PAGE_SIZE, mmrange);
 	spin_lock(&sg->guest_table_lock);
 	if (!rc) {
 		table = gmap_table_walk(sg, saddr, 1);
@@ -1921,6 +1938,7 @@ EXPORT_SYMBOL_GPL(gmap_shadow_pgt);
  * @sg: pointer to the shadow guest address space structure
  * @saddr: faulting address in the shadow gmap
  * @pte: pte in parent gmap address space to get shadowed
+ * @mmrange: address space range locking
  *
  * Returns 0 if successfully shadowed or already shadowed, -EAGAIN if the
  * shadow table structure is incomplete, -ENOMEM if out of memory and
@@ -1928,7 +1946,8 @@ EXPORT_SYMBOL_GPL(gmap_shadow_pgt);
  *
  * Called with sg->mm->mmap_sem in read.
  */
-int gmap_shadow_page(struct gmap *sg, unsigned long saddr, pte_t pte)
+int gmap_shadow_page(struct gmap *sg, unsigned long saddr, pte_t pte,
+		     struct range_lock *mmrange)
 {
 	struct gmap *parent;
 	struct gmap_rmap *rmap;
@@ -1982,7 +2001,7 @@ int gmap_shadow_page(struct gmap *sg, unsigned long saddr, pte_t pte)
 		radix_tree_preload_end();
 		if (!rc)
 			break;
-		rc = gmap_pte_op_fixup(parent, paddr, vmaddr, prot);
+		rc = gmap_pte_op_fixup(parent, paddr, vmaddr, prot, mmrange);
 		if (rc)
 			break;
 	}
@@ -2117,7 +2136,8 @@ static inline void thp_split_mm(struct mm_struct *mm)
  * - This must be called after THP was enabled
  */
 static int __zap_zero_pages(pmd_t *pmd, unsigned long start,
-			   unsigned long end, struct mm_walk *walk)
+			    unsigned long end, struct mm_walk *walk,
+			    struct range_lock *mmrange)
 {
 	unsigned long addr;
 
@@ -2133,12 +2153,13 @@ static int __zap_zero_pages(pmd_t *pmd, unsigned long start,
 	return 0;
 }
 
-static inline void zap_zero_pages(struct mm_struct *mm)
+static inline void zap_zero_pages(struct mm_struct *mm,
+				  struct range_lock *mmrange)
 {
 	struct mm_walk walk = { .pmd_entry = __zap_zero_pages };
 
 	walk.mm = mm;
-	walk_page_range(0, TASK_SIZE, &walk);
+	walk_page_range(0, TASK_SIZE, &walk, mmrange);
 }
 
 /*
@@ -2147,6 +2168,7 @@ static inline void zap_zero_pages(struct mm_struct *mm)
 int s390_enable_sie(void)
 {
 	struct mm_struct *mm = current->mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* Do we have pgstes? if yes, we are done */
 	if (mm_has_pgste(mm))
@@ -2158,7 +2180,7 @@ int s390_enable_sie(void)
 	mm->context.has_pgste = 1;
 	/* split thp mappings and disable thp for future mappings */
 	thp_split_mm(mm);
-	zap_zero_pages(mm);
+	zap_zero_pages(mm, &mmrange);
 	up_write(&mm->mmap_sem);
 	return 0;
 }
@@ -2182,6 +2204,7 @@ int s390_enable_skey(void)
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	int rc = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	down_write(&mm->mmap_sem);
 	if (mm_use_skey(mm))
@@ -2190,7 +2213,7 @@ int s390_enable_skey(void)
 	mm->context.use_skey = 1;
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (ksm_madvise(vma, vma->vm_start, vma->vm_end,
-				MADV_UNMERGEABLE, &vma->vm_flags)) {
+				MADV_UNMERGEABLE, &vma->vm_flags, &mmrange)) {
 			mm->context.use_skey = 0;
 			rc = -ENOMEM;
 			goto out_up;
@@ -2199,7 +2222,7 @@ int s390_enable_skey(void)
 	mm->def_flags &= ~VM_MERGEABLE;
 
 	walk.mm = mm;
-	walk_page_range(0, TASK_SIZE, &walk);
+	walk_page_range(0, TASK_SIZE, &walk, &mmrange);
 
 out_up:
 	up_write(&mm->mmap_sem);
@@ -2220,10 +2243,11 @@ static int __s390_reset_cmma(pte_t *pte, unsigned long addr,
 void s390_reset_cmma(struct mm_struct *mm)
 {
 	struct mm_walk walk = { .pte_entry = __s390_reset_cmma };
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	down_write(&mm->mmap_sem);
 	walk.mm = mm;
-	walk_page_range(0, TASK_SIZE, &walk);
+	walk_page_range(0, TASK_SIZE, &walk, &mmrange);
 	up_write(&mm->mmap_sem);
 }
 EXPORT_SYMBOL_GPL(s390_reset_cmma);
diff --git a/arch/score/mm/fault.c b/arch/score/mm/fault.c
index b85fad4f0874..07a8637ad142 100644
--- a/arch/score/mm/fault.c
+++ b/arch/score/mm/fault.c
@@ -51,6 +51,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long write,
 	unsigned long flags = 0;
 	siginfo_t info;
 	int fault;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	info.si_code = SEGV_MAPERR;
 
@@ -111,7 +112,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long write,
 	* make sure we exit gracefully rather than endlessly redo
 	* the fault.
 	*/
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, mmrange);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index 6fd1bf7481c7..d36106564728 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -405,6 +405,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	struct vm_area_struct * vma;
 	int fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	tsk = current;
 	mm = tsk->mm;
@@ -488,7 +489,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if (unlikely(fault & (VM_FAULT_RETRY | VM_FAULT_ERROR)))
 		if (mm_fault_error(regs, error_code, address, fault))
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index a8103a84b4ac..ebb2406dbe7c 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -176,6 +176,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 	int from_user = !(regs->psr & PSR_PS);
 	int fault, code;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (text_fault)
 		address = regs->pc;
@@ -242,7 +243,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
@@ -389,6 +390,7 @@ static void force_user_fault(unsigned long address, int write)
 	struct mm_struct *mm = tsk->mm;
 	unsigned int flags = FAULT_FLAG_USER;
 	int code;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	code = SEGV_MAPERR;
 
@@ -412,7 +414,7 @@ static void force_user_fault(unsigned long address, int write)
 		if (!(vma->vm_flags & (VM_READ | VM_EXEC)))
 			goto bad_area;
 	}
-	switch (handle_mm_fault(vma, address, flags)) {
+	switch (handle_mm_fault(vma, address, flags, &mmrange)) {
 	case VM_FAULT_SIGBUS:
 	case VM_FAULT_OOM:
 		goto do_sigbus;
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 41363f46797b..e0a3c36b0fa1 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -287,6 +287,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 	int si_code, fault_code, fault;
 	unsigned long address, mm_rss;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	fault_code = get_thread_fault_code();
 
@@ -438,7 +439,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 			goto bad_area;
 	}
 
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		goto exit_exception;
diff --git a/arch/tile/mm/fault.c b/arch/tile/mm/fault.c
index f58fa06a2214..09f053eb146f 100644
--- a/arch/tile/mm/fault.c
+++ b/arch/tile/mm/fault.c
@@ -275,6 +275,7 @@ static int handle_page_fault(struct pt_regs *regs,
 	int is_kernel_mode;
 	pgd_t *pgd;
 	unsigned int flags;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* on TILE, protection faults are always writes */
 	if (!is_page_fault)
@@ -437,7 +438,7 @@ static int handle_page_fault(struct pt_regs *regs,
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return 0;
diff --git a/arch/um/include/asm/mmu_context.h b/arch/um/include/asm/mmu_context.h
index fca34b2177e2..98cc3e36385a 100644
--- a/arch/um/include/asm/mmu_context.h
+++ b/arch/um/include/asm/mmu_context.h
@@ -23,7 +23,8 @@ static inline int arch_dup_mmap(struct mm_struct *oldmm, struct mm_struct *mm)
 extern void arch_exit_mmap(struct mm_struct *mm);
 static inline void arch_unmap(struct mm_struct *mm,
 			struct vm_area_struct *vma,
-			unsigned long start, unsigned long end)
+			unsigned long start, unsigned long end,
+			struct range_lock *mmrange)
 {
 }
 static inline void arch_bprm_mm_init(struct mm_struct *mm,
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index b2b02df9896e..e632a14e896e 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -33,6 +33,7 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 	pte_t *pte;
 	int err = -EFAULT;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	*code_out = SEGV_MAPERR;
 
@@ -74,7 +75,7 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 	do {
 		int fault;
 
-		fault = handle_mm_fault(vma, address, flags);
+		fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 		if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 			goto out_nosemaphore;
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index bbefcc46a45e..dd35b6191798 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -168,7 +168,8 @@ static inline bool access_error(unsigned int fsr, struct vm_area_struct *vma)
 }
 
 static int __do_pf(struct mm_struct *mm, unsigned long addr, unsigned int fsr,
-		unsigned int flags, struct task_struct *tsk)
+		   unsigned int flags, struct task_struct *tsk,
+		   struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	int fault;
@@ -194,7 +195,7 @@ static int __do_pf(struct mm_struct *mm, unsigned long addr, unsigned int fsr,
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the fault.
 	 */
-	fault = handle_mm_fault(vma, addr & PAGE_MASK, flags);
+	fault = handle_mm_fault(vma, addr & PAGE_MASK, flags, mmrange);
 	return fault;
 
 check_stack:
@@ -210,6 +211,7 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	struct mm_struct *mm;
 	int fault, sig, code;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	tsk = current;
 	mm = tsk->mm;
@@ -251,7 +253,7 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 #endif
 	}
 
-	fault = __do_pf(mm, addr, fsr, flags, tsk);
+	fault = __do_pf(mm, addr, fsr, flags, tsk, &mmrange);
 
 	/* If we need to retry but a fatal signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because
diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 5b8b556dbb12..2e0bdf6a3aaf 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -155,6 +155,7 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
 	struct vm_area_struct *vma;
 	unsigned long text_start;
 	int ret = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
@@ -192,7 +193,7 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
 
 	if (IS_ERR(vma)) {
 		ret = PTR_ERR(vma);
-		do_munmap(mm, text_start, image->size, NULL);
+		do_munmap(mm, text_start, image->size, NULL, &mmrange);
 	} else {
 		current->mm->context.vdso = (void __user *)text_start;
 		current->mm->context.vdso_image = image;
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index c931b88982a0..31fb02ed4770 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -263,7 +263,8 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
 }
 
 static inline void arch_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
-			      unsigned long start, unsigned long end)
+			      unsigned long start, unsigned long end,
+			      struct range_lock *mmrange)
 {
 	/*
 	 * mpx_notify_unmap() goes and reads a rarely-hot
@@ -283,7 +284,7 @@ static inline void arch_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * consistently wrong.
 	 */
 	if (unlikely(cpu_feature_enabled(X86_FEATURE_MPX)))
-		mpx_notify_unmap(mm, vma, start, end);
+		mpx_notify_unmap(mm, vma, start, end, mmrange);
 }
 
 #ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
diff --git a/arch/x86/include/asm/mpx.h b/arch/x86/include/asm/mpx.h
index 61eb4b63c5ec..c26099224a17 100644
--- a/arch/x86/include/asm/mpx.h
+++ b/arch/x86/include/asm/mpx.h
@@ -73,7 +73,8 @@ static inline void mpx_mm_init(struct mm_struct *mm)
 	mm->context.bd_addr = MPX_INVALID_BOUNDS_DIR;
 }
 void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
-		      unsigned long start, unsigned long end);
+		      unsigned long start, unsigned long end,
+		      struct range_lock *mmrange);
 
 unsigned long mpx_unmapped_area_check(unsigned long addr, unsigned long len,
 		unsigned long flags);
@@ -95,7 +96,8 @@ static inline void mpx_mm_init(struct mm_struct *mm)
 }
 static inline void mpx_notify_unmap(struct mm_struct *mm,
 				    struct vm_area_struct *vma,
-				    unsigned long start, unsigned long end)
+				    unsigned long start, unsigned long end,
+				    struct range_lock *mmrange)
 {
 }
 
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 800de815519c..93f1b8d4c88e 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1244,6 +1244,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	int fault, major = 0;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 	u32 pkey;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1423,7 +1424,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 * fault, so we read the pkey beforehand.
 	 */
 	pkey = vma_pkey(vma);
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 	major |= fault & VM_FAULT_MAJOR;
 
 	/*
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index e500949bae24..51c3e1f7e6be 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -47,6 +47,7 @@ static unsigned long mpx_mmap(unsigned long len)
 {
 	struct mm_struct *mm = current->mm;
 	unsigned long addr, populate;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* Only bounds table can be allocated here */
 	if (len != mpx_bt_size_bytes(mm))
@@ -54,7 +55,8 @@ static unsigned long mpx_mmap(unsigned long len)
 
 	down_write(&mm->mmap_sem);
 	addr = do_mmap(NULL, 0, len, PROT_READ | PROT_WRITE,
-		       MAP_ANONYMOUS | MAP_PRIVATE, VM_MPX, 0, &populate, NULL);
+		       MAP_ANONYMOUS | MAP_PRIVATE, VM_MPX, 0, &populate, NULL,
+		       &mmrange);
 	up_write(&mm->mmap_sem);
 	if (populate)
 		mm_populate(addr, populate);
@@ -427,13 +429,15 @@ int mpx_handle_bd_fault(void)
  * A thin wrapper around get_user_pages().  Returns 0 if the
  * fault was resolved or -errno if not.
  */
-static int mpx_resolve_fault(long __user *addr, int write)
+static int mpx_resolve_fault(long __user *addr, int write,
+			     struct range_lock *mmrange)
 {
 	long gup_ret;
 	int nr_pages = 1;
 
 	gup_ret = get_user_pages((unsigned long)addr, nr_pages,
-			write ? FOLL_WRITE : 0,	NULL, NULL);
+		       write ? FOLL_WRITE : 0,	NULL, NULL,
+		       mmrange);
 	/*
 	 * get_user_pages() returns number of pages gotten.
 	 * 0 means we failed to fault in and get anything,
@@ -500,7 +504,8 @@ static int get_user_bd_entry(struct mm_struct *mm, unsigned long *bd_entry_ret,
  */
 static int get_bt_addr(struct mm_struct *mm,
 			long __user *bd_entry_ptr,
-			unsigned long *bt_addr_result)
+		        unsigned long *bt_addr_result,
+		        struct range_lock *mmrange)
 {
 	int ret;
 	int valid_bit;
@@ -519,7 +524,8 @@ static int get_bt_addr(struct mm_struct *mm,
 		if (!ret)
 			break;
 		if (ret == -EFAULT)
-			ret = mpx_resolve_fault(bd_entry_ptr, need_write);
+			ret = mpx_resolve_fault(bd_entry_ptr,
+						need_write, mmrange);
 		/*
 		 * If we could not resolve the fault, consider it
 		 * userspace's fault and error out.
@@ -730,7 +736,8 @@ static unsigned long mpx_get_bd_entry_offset(struct mm_struct *mm,
 }
 
 static int unmap_entire_bt(struct mm_struct *mm,
-		long __user *bd_entry, unsigned long bt_addr)
+		long __user *bd_entry, unsigned long bt_addr,
+		struct range_lock *mmrange)
 {
 	unsigned long expected_old_val = bt_addr | MPX_BD_ENTRY_VALID_FLAG;
 	unsigned long uninitialized_var(actual_old_val);
@@ -747,7 +754,7 @@ static int unmap_entire_bt(struct mm_struct *mm,
 		if (!ret)
 			break;
 		if (ret == -EFAULT)
-			ret = mpx_resolve_fault(bd_entry, need_write);
+			ret = mpx_resolve_fault(bd_entry, need_write, mmrange);
 		/*
 		 * If we could not resolve the fault, consider it
 		 * userspace's fault and error out.
@@ -780,11 +787,12 @@ static int unmap_entire_bt(struct mm_struct *mm,
 	 * avoid recursion, do_munmap() will check whether it comes
 	 * from one bounds table through VM_MPX flag.
 	 */
-	return do_munmap(mm, bt_addr, mpx_bt_size_bytes(mm), NULL);
+	return do_munmap(mm, bt_addr, mpx_bt_size_bytes(mm), NULL, mmrange);
 }
 
 static int try_unmap_single_bt(struct mm_struct *mm,
-	       unsigned long start, unsigned long end)
+	       unsigned long start, unsigned long end,
+	       struct range_lock *mmrange)
 {
 	struct vm_area_struct *next;
 	struct vm_area_struct *prev;
@@ -835,7 +843,7 @@ static int try_unmap_single_bt(struct mm_struct *mm,
 	}
 
 	bde_vaddr = mm->context.bd_addr + mpx_get_bd_entry_offset(mm, start);
-	ret = get_bt_addr(mm, bde_vaddr, &bt_addr);
+	ret = get_bt_addr(mm, bde_vaddr, &bt_addr, mmrange);
 	/*
 	 * No bounds table there, so nothing to unmap.
 	 */
@@ -853,12 +861,13 @@ static int try_unmap_single_bt(struct mm_struct *mm,
 	 */
 	if ((start == bta_start_vaddr) &&
 	    (end == bta_end_vaddr))
-		return unmap_entire_bt(mm, bde_vaddr, bt_addr);
+		return unmap_entire_bt(mm, bde_vaddr, bt_addr, mmrange);
 	return zap_bt_entries_mapping(mm, bt_addr, start, end);
 }
 
 static int mpx_unmap_tables(struct mm_struct *mm,
-		unsigned long start, unsigned long end)
+			    unsigned long start, unsigned long end,
+			    struct range_lock *mmrange)
 {
 	unsigned long one_unmap_start;
 	trace_mpx_unmap_search(start, end);
@@ -876,7 +885,8 @@ static int mpx_unmap_tables(struct mm_struct *mm,
 		 */
 		if (one_unmap_end > next_unmap_start)
 			one_unmap_end = next_unmap_start;
-		ret = try_unmap_single_bt(mm, one_unmap_start, one_unmap_end);
+		ret = try_unmap_single_bt(mm, one_unmap_start, one_unmap_end,
+					  mmrange);
 		if (ret)
 			return ret;
 
@@ -894,7 +904,8 @@ static int mpx_unmap_tables(struct mm_struct *mm,
  * necessary, and the 'vma' is the first vma in this range (start -> end).
  */
 void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long start, unsigned long end)
+		unsigned long start, unsigned long end,
+		struct range_lock *mmrange)
 {
 	int ret;
 
@@ -920,7 +931,7 @@ void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
 		vma = vma->vm_next;
 	} while (vma && vma->vm_start < end);
 
-	ret = mpx_unmap_tables(mm, start, end);
+	ret = mpx_unmap_tables(mm, start, end, mmrange);
 	if (ret)
 		force_sig(SIGSEGV, current);
 }
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index 8b9b6f44bb06..6f8e3e7cccb5 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -44,6 +44,7 @@ void do_page_fault(struct pt_regs *regs)
 	int is_write, is_exec;
 	int fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	info.si_code = SEGV_MAPERR;
 
@@ -108,7 +109,7 @@ void do_page_fault(struct pt_regs *regs)
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index e4bb435e614b..bd464a599341 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -691,6 +691,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 	unsigned int flags = 0;
 	unsigned pinned = 0;
 	int r;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!(gtt->userflags & AMDGPU_GEM_USERPTR_READONLY))
 		flags |= FOLL_WRITE;
@@ -721,7 +722,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 		list_add(&guptask.list, &gtt->guptasks);
 		spin_unlock(&gtt->guptasklock);
 
-		r = get_user_pages(userptr, num_pages, flags, p, NULL);
+		r = get_user_pages(userptr, num_pages, flags, p, NULL, &mmrange);
 
 		spin_lock(&gtt->guptasklock);
 		list_del(&guptask.list);
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 382a77a1097e..881bcc7d663a 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -512,6 +512,8 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 
 		ret = -EFAULT;
 		if (mmget_not_zero(mm)) {
+			DEFINE_RANGE_LOCK_FULL(mmrange);
+
 			down_read(&mm->mmap_sem);
 			while (pinned < npages) {
 				ret = get_user_pages_remote
@@ -519,7 +521,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 					 obj->userptr.ptr + pinned * PAGE_SIZE,
 					 npages - pinned,
 					 flags,
-					 pvec + pinned, NULL, NULL);
+					 pvec + pinned, NULL, NULL, &mmrange);
 				if (ret < 0)
 					break;
 
diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index a0a839bc39bf..9fc3a4f86945 100644
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -545,6 +545,8 @@ static int radeon_ttm_tt_pin_userptr(struct ttm_tt *ttm)
 	struct radeon_ttm_tt *gtt = (void *)ttm;
 	unsigned pinned = 0, nents;
 	int r;
+	// XXX: this is wrong!!
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	int write = !(gtt->userflags & RADEON_GEM_USERPTR_READONLY);
 	enum dma_data_direction direction = write ?
@@ -569,7 +571,7 @@ static int radeon_ttm_tt_pin_userptr(struct ttm_tt *ttm)
 		struct page **pages = ttm->pages + pinned;
 
 		r = get_user_pages(userptr, num_pages, write ? FOLL_WRITE : 0,
-				   pages, NULL);
+				   pages, NULL, &mmrange);
 		if (r < 0)
 			goto release_pages;
 
diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 9a4e899d94b3..fd9601ed5b84 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -96,6 +96,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	struct scatterlist *sg, *sg_list_start;
 	int need_release = 0;
 	unsigned int gup_flags = FOLL_WRITE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (dmasync)
 		dma_attrs |= DMA_ATTR_WRITE_BARRIER;
@@ -194,7 +195,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 		ret = get_user_pages_longterm(cur_base,
 				     min_t(unsigned long, npages,
 					   PAGE_SIZE / sizeof (struct page *)),
-				     gup_flags, page_list, vma_list);
+				      gup_flags, page_list, vma_list, &mmrange);
 
 		if (ret < 0)
 			goto out;
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 2aadf5813a40..0572953260e8 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -632,6 +632,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
 	int j, k, ret = 0, start_idx, npages = 0, page_shift;
 	unsigned int flags = 0;
 	phys_addr_t p = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (access_mask == 0)
 		return -EINVAL;
@@ -683,7 +684,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
 		 */
 		npages = get_user_pages_remote(owning_process, owning_mm,
 				user_virt, gup_num_pages,
-				flags, local_page_list, NULL, NULL);
+				flags, local_page_list, NULL, NULL, &mmrange);
 		up_read(&owning_mm->mmap_sem);
 
 		if (npages < 0)
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index ce83ba9a12ef..6bcb4f9f9b30 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -53,7 +53,7 @@ static void __qib_release_user_pages(struct page **p, size_t num_pages,
  * Call with current->mm->mmap_sem held.
  */
 static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
-				struct page **p)
+				struct page **p, struct range_lock *mmrange)
 {
 	unsigned long lock_limit;
 	size_t got;
@@ -70,7 +70,7 @@ static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
 		ret = get_user_pages(start_page + got * PAGE_SIZE,
 				     num_pages - got,
 				     FOLL_WRITE | FOLL_FORCE,
-				     p + got, NULL);
+				     p + got, NULL, mmrange);
 		if (ret < 0)
 			goto bail_release;
 	}
@@ -134,10 +134,11 @@ int qib_get_user_pages(unsigned long start_page, size_t num_pages,
 		       struct page **p)
 {
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	down_write(&current->mm->mmap_sem);
 
-	ret = __qib_get_user_pages(start_page, num_pages, p);
+	ret = __qib_get_user_pages(start_page, num_pages, p, &mmrange);
 
 	up_write(&current->mm->mmap_sem);
 
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index 4381c0a9a873..5f36c6d2e21b 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -113,6 +113,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	int flags;
 	dma_addr_t pa;
 	unsigned int gup_flags;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!can_do_mlock())
 		return -EPERM;
@@ -146,7 +147,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 		ret = get_user_pages(cur_base,
 					min_t(unsigned long, npages,
 					PAGE_SIZE / sizeof(struct page *)),
-					gup_flags, page_list, NULL);
+					gup_flags, page_list, NULL, &mmrange);
 
 		if (ret < 0)
 			goto out;
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 1d0b53a04a08..15a7103fd84c 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -512,6 +512,7 @@ static void do_fault(struct work_struct *work)
 	unsigned int flags = 0;
 	struct mm_struct *mm;
 	u64 address;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	mm = fault->state->mm;
 	address = fault->address;
@@ -523,7 +524,7 @@ static void do_fault(struct work_struct *work)
 	flags |= FAULT_FLAG_REMOTE;
 
 	down_read(&mm->mmap_sem);
-	vma = find_extend_vma(mm, address);
+	vma = find_extend_vma(mm, address, &mmrange);
 	if (!vma || address < vma->vm_start)
 		/* failed to get a vma in the right range */
 		goto out;
@@ -532,7 +533,7 @@ static void do_fault(struct work_struct *work)
 	if (access_error(vma, fault))
 		goto out;
 
-	ret = handle_mm_fault(vma, address, flags);
+	ret = handle_mm_fault(vma, address, flags, &mmrange);
 out:
 	up_read(&mm->mmap_sem);
 
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index 35a408d0ae4f..6a74386ee83f 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -585,6 +585,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 	struct intel_iommu *iommu = d;
 	struct intel_svm *svm = NULL;
 	int head, tail, handled = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* Clear PPR bit before reading head/tail registers, to
 	 * ensure that we get a new interrupt if needed. */
@@ -643,7 +644,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 			goto bad_req;
 
 		down_read(&svm->mm->mmap_sem);
-		vma = find_extend_vma(svm->mm, address);
+		vma = find_extend_vma(svm->mm, address, &mmrange);
 		if (!vma || address < vma->vm_start)
 			goto invalid;
 
@@ -651,7 +652,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 			goto invalid;
 
 		ret = handle_mm_fault(vma, address,
-				      req->wr_req ? FAULT_FLAG_WRITE : 0);
+				      req->wr_req ? FAULT_FLAG_WRITE : 0, &mmrange);
 		if (ret & VM_FAULT_ERROR)
 			goto invalid;
 
diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index f412429cf5ba..64a4cd62eeb3 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -152,7 +152,8 @@ static void videobuf_dma_init(struct videobuf_dmabuf *dma)
 }
 
 static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
-			int direction, unsigned long data, unsigned long size)
+			int direction, unsigned long data, unsigned long size,
+			struct range_lock *mmrange)
 {
 	unsigned long first, last;
 	int err, rw = 0;
@@ -186,7 +187,7 @@ static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
 		data, size, dma->nr_pages);
 
 	err = get_user_pages_longterm(data & PAGE_MASK, dma->nr_pages,
-			     flags, dma->pages, NULL);
+				      flags, dma->pages, NULL, mmrange);
 
 	if (err != dma->nr_pages) {
 		dma->nr_pages = (err >= 0) ? err : 0;
@@ -201,9 +202,10 @@ static int videobuf_dma_init_user(struct videobuf_dmabuf *dma, int direction,
 			   unsigned long data, unsigned long size)
 {
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	down_read(&current->mm->mmap_sem);
-	ret = videobuf_dma_init_user_locked(dma, direction, data, size);
+	ret = videobuf_dma_init_user_locked(dma, direction, data, size, &mmrange);
 	up_read(&current->mm->mmap_sem);
 
 	return ret;
@@ -539,9 +541,14 @@ static int __videobuf_iolock(struct videobuf_queue *q,
 			we take current->mm->mmap_sem there, to prevent
 			locking inversion, so don't take it here */
 
+			/* XXX: can we use a local mmrange here? */
+			DEFINE_RANGE_LOCK_FULL(mmrange);
+
 			err = videobuf_dma_init_user_locked(&mem->dma,
-						      DMA_FROM_DEVICE,
-						      vb->baddr, vb->bsize);
+							    DMA_FROM_DEVICE,
+							    vb->baddr,
+							    vb->bsize,
+							    &mmrange);
 			if (0 != err)
 				return err;
 		}
@@ -555,6 +562,7 @@ static int __videobuf_iolock(struct videobuf_queue *q,
 		 * building for PAE. Compiler doesn't like direct casting
 		 * of a 32 bit ptr to 64 bit integer.
 		 */
+
 		bus   = (dma_addr_t)(unsigned long)fbuf->base + vb->boff;
 		pages = PAGE_ALIGN(vb->size) >> PAGE_SHIFT;
 		err = videobuf_dma_init_overlay(&mem->dma, DMA_FROM_DEVICE,
diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index c824329f7012..6ecac843e5f3 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -1332,6 +1332,7 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 	int prot = *out_prot;
 	int ulimit = 0;
 	struct mm_struct *mm = NULL;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* Unsupported flags */
 	if (map_flags & ~(SCIF_MAP_KERNEL | SCIF_MAP_ULIMIT))
@@ -1400,7 +1401,7 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 				nr_pages,
 				(prot & SCIF_PROT_WRITE) ? FOLL_WRITE : 0,
 				pinned_pages->pages,
-				NULL);
+				NULL, &mmrange);
 		up_write(&mm->mmap_sem);
 		if (nr_pages != pinned_pages->nr_pages) {
 			if (try_upgrade) {
diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index 93be82fc338a..b35d60bb2197 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -189,7 +189,8 @@ static void get_clear_fault_map(struct gru_state *gru,
  */
 static int non_atomic_pte_lookup(struct vm_area_struct *vma,
 				 unsigned long vaddr, int write,
-				 unsigned long *paddr, int *pageshift)
+				 unsigned long *paddr, int *pageshift,
+				 struct range_lock *mmrange)
 {
 	struct page *page;
 
@@ -198,7 +199,8 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
 #else
 	*pageshift = PAGE_SHIFT;
 #endif
-	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
+	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0,
+			   &page, NULL, mmrange) <= 0)
 		return -EFAULT;
 	*paddr = page_to_phys(page);
 	put_page(page);
@@ -263,7 +265,8 @@ static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long vaddr,
 }
 
 static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
-		    int write, int atomic, unsigned long *gpa, int *pageshift)
+		    int write, int atomic, unsigned long *gpa, int *pageshift,
+		    struct range_lock *mmrange)
 {
 	struct mm_struct *mm = gts->ts_mm;
 	struct vm_area_struct *vma;
@@ -283,7 +286,8 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
 	if (ret) {
 		if (atomic)
 			goto upm;
-		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &ps))
+		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr,
+					  &ps, mmrange))
 			goto inval;
 	}
 	if (is_gru_paddr(paddr))
@@ -324,7 +328,8 @@ static void gru_preload_tlb(struct gru_state *gru,
 			unsigned long fault_vaddr, int asid, int write,
 			unsigned char tlb_preload_count,
 			struct gru_tlb_fault_handle *tfh,
-			struct gru_control_block_extended *cbe)
+			struct gru_control_block_extended *cbe,
+			struct range_lock *mmrange)
 {
 	unsigned long vaddr = 0, gpa;
 	int ret, pageshift;
@@ -342,7 +347,7 @@ static void gru_preload_tlb(struct gru_state *gru,
 	vaddr = min(vaddr, fault_vaddr + tlb_preload_count * PAGE_SIZE);
 
 	while (vaddr > fault_vaddr) {
-		ret = gru_vtop(gts, vaddr, write, atomic, &gpa, &pageshift);
+		ret = gru_vtop(gts, vaddr, write, atomic, &gpa, &pageshift, mmrange);
 		if (ret || tfh_write_only(tfh, gpa, GAA_RAM, vaddr, asid, write,
 					  GRU_PAGESIZE(pageshift)))
 			return;
@@ -368,7 +373,8 @@ static void gru_preload_tlb(struct gru_state *gru,
 static int gru_try_dropin(struct gru_state *gru,
 			  struct gru_thread_state *gts,
 			  struct gru_tlb_fault_handle *tfh,
-			  struct gru_instruction_bits *cbk)
+			  struct gru_instruction_bits *cbk,
+			  struct range_lock *mmrange)
 {
 	struct gru_control_block_extended *cbe = NULL;
 	unsigned char tlb_preload_count = gts->ts_tlb_preload_count;
@@ -423,7 +429,7 @@ static int gru_try_dropin(struct gru_state *gru,
 	if (atomic_read(&gts->ts_gms->ms_range_active))
 		goto failactive;
 
-	ret = gru_vtop(gts, vaddr, write, atomic, &gpa, &pageshift);
+	ret = gru_vtop(gts, vaddr, write, atomic, &gpa, &pageshift, mmrange);
 	if (ret == VTOP_INVALID)
 		goto failinval;
 	if (ret == VTOP_RETRY)
@@ -438,7 +444,8 @@ static int gru_try_dropin(struct gru_state *gru,
 	}
 
 	if (unlikely(cbe) && pageshift == PAGE_SHIFT) {
-		gru_preload_tlb(gru, gts, atomic, vaddr, asid, write, tlb_preload_count, tfh, cbe);
+		gru_preload_tlb(gru, gts, atomic, vaddr, asid, write,
+				tlb_preload_count, tfh, cbe, mmrange);
 		gru_flush_cache_cbe(cbe);
 	}
 
@@ -587,10 +594,13 @@ static irqreturn_t gru_intr(int chiplet, int blade)
 		 * If it fails, retry the fault in user context.
 		 */
 		gts->ustats.fmm_tlbmiss++;
-		if (!gts->ts_force_cch_reload &&
-					down_read_trylock(&gts->ts_mm->mmap_sem)) {
-			gru_try_dropin(gru, gts, tfh, NULL);
-			up_read(&gts->ts_mm->mmap_sem);
+		if (!gts->ts_force_cch_reload) {
+			DEFINE_RANGE_LOCK_FULL(mmrange);
+
+			if (down_read_trylock(&gts->ts_mm->mmap_sem)) {
+				gru_try_dropin(gru, gts, tfh, NULL, &mmrange);
+				up_read(&gts->ts_mm->mmap_sem);
+			}
 		} else {
 			tfh_user_polling_mode(tfh);
 			STAT(intr_mm_lock_failed);
@@ -625,7 +635,7 @@ irqreturn_t gru_intr_mblade(int irq, void *dev_id)
 
 static int gru_user_dropin(struct gru_thread_state *gts,
 			   struct gru_tlb_fault_handle *tfh,
-			   void *cb)
+			   void *cb, struct range_lock *mmrange)
 {
 	struct gru_mm_struct *gms = gts->ts_gms;
 	int ret;
@@ -635,7 +645,7 @@ static int gru_user_dropin(struct gru_thread_state *gts,
 		wait_event(gms->ms_wait_queue,
 			   atomic_read(&gms->ms_range_active) == 0);
 		prefetchw(tfh);	/* Helps on hdw, required for emulator */
-		ret = gru_try_dropin(gts->ts_gru, gts, tfh, cb);
+		ret = gru_try_dropin(gts->ts_gru, gts, tfh, cb, mmrange);
 		if (ret <= 0)
 			return ret;
 		STAT(call_os_wait_queue);
@@ -653,6 +663,7 @@ int gru_handle_user_call_os(unsigned long cb)
 	struct gru_thread_state *gts;
 	void *cbk;
 	int ucbnum, cbrnum, ret = -EINVAL;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	STAT(call_os);
 
@@ -685,7 +696,7 @@ int gru_handle_user_call_os(unsigned long cb)
 		tfh = get_tfh_by_index(gts->ts_gru, cbrnum);
 		cbk = get_gseg_base_address_cb(gts->ts_gru->gs_gru_base_vaddr,
 				gts->ts_ctxnum, ucbnum);
-		ret = gru_user_dropin(gts, tfh, cbk);
+		ret = gru_user_dropin(gts, tfh, cbk, &mmrange);
 	}
 exit:
 	gru_unlock_gts(gts);
diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index e30e29ae4819..1b3b103da637 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -345,13 +345,14 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 					  page);
 	} else {
 		unsigned int flags = 0;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
 		if (prot & IOMMU_WRITE)
 			flags |= FOLL_WRITE;
 
 		down_read(&mm->mmap_sem);
 		ret = get_user_pages_remote(NULL, mm, vaddr, 1, flags, page,
-					    NULL, NULL);
+					    NULL, NULL, &mmrange);
 		up_read(&mm->mmap_sem);
 	}
 
diff --git a/fs/aio.c b/fs/aio.c
index a062d75109cb..31774b75c372 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -457,6 +457,7 @@ static int aio_setup_ring(struct kioctx *ctx, unsigned int nr_events)
 	int nr_pages;
 	int i;
 	struct file *file;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* Compensate for the ring buffer's head/tail overlap entry */
 	nr_events += 2;	/* 1 is required, 2 for good luck */
@@ -519,7 +520,7 @@ static int aio_setup_ring(struct kioctx *ctx, unsigned int nr_events)
 
 	ctx->mmap_base = do_mmap_pgoff(ctx->aio_ring_file, 0, ctx->mmap_size,
 				       PROT_READ | PROT_WRITE,
-				       MAP_SHARED, 0, &unused, NULL);
+				       MAP_SHARED, 0, &unused, NULL, &mmrange);
 	up_write(&mm->mmap_sem);
 	if (IS_ERR((void *)ctx->mmap_base)) {
 		ctx->mmap_size = 0;
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 2f492dfcabde..9aea808d55d7 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -180,6 +180,7 @@ create_elf_tables(struct linux_binprm *bprm, struct elfhdr *exec,
 	int ei_index = 0;
 	const struct cred *cred = current_cred();
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * In some cases (e.g. Hyper-Threading), we want to avoid L1
@@ -300,7 +301,7 @@ create_elf_tables(struct linux_binprm *bprm, struct elfhdr *exec,
 	 * Grow the stack manually; some architectures have a limit on how
 	 * far ahead a user-space access may be in order to grow the stack.
 	 */
-	vma = find_extend_vma(current->mm, bprm->p);
+	vma = find_extend_vma(current->mm, bprm->p, &mmrange);
 	if (!vma)
 		return -EFAULT;
 
diff --git a/fs/exec.c b/fs/exec.c
index e7b69e14649f..e46752874b47 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -197,6 +197,11 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 	struct page *page;
 	int ret;
 	unsigned int gup_flags = FOLL_FORCE;
+	/*
+	 * No concurrency for the bprm->mm yet -- this is exec path;
+	 * but gup needs an mmrange.
+	 */
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 #ifdef CONFIG_STACK_GROWSUP
 	if (write) {
@@ -214,7 +219,7 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 	 * doing the exec and bprm->mm is the new process's mm.
 	 */
 	ret = get_user_pages_remote(current, bprm->mm, pos, 1, gup_flags,
-			&page, NULL, NULL);
+				    &page, NULL, NULL, &mmrange);
 	if (ret <= 0)
 		return NULL;
 
@@ -615,7 +620,8 @@ EXPORT_SYMBOL(copy_strings_kernel);
  * 4) Free up any cleared pgd range.
  * 5) Shrink the vma to cover only the new range.
  */
-static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
+static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift,
+			   struct range_lock *mmrange)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long old_start = vma->vm_start;
@@ -637,7 +643,8 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
 	/*
 	 * cover the whole range: [new_start, old_end)
 	 */
-	if (vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL))
+	if (vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL,
+		    mmrange))
 		return -ENOMEM;
 
 	/*
@@ -671,7 +678,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
 	/*
 	 * Shrink the vma to just the new range.  Always succeeds.
 	 */
-	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
+	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL, mmrange);
 
 	return 0;
 }
@@ -694,6 +701,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	unsigned long stack_size;
 	unsigned long stack_expand;
 	unsigned long rlim_stack;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 #ifdef CONFIG_STACK_GROWSUP
 	/* Limit stack size */
@@ -749,14 +757,14 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	vm_flags |= VM_STACK_INCOMPLETE_SETUP;
 
 	ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end,
-			vm_flags);
+			     vm_flags, &mmrange);
 	if (ret)
 		goto out_unlock;
 	BUG_ON(prev != vma);
 
 	/* Move stack pages down in memory. */
 	if (stack_shift) {
-		ret = shift_arg_pages(vma, stack_shift);
+		ret = shift_arg_pages(vma, stack_shift, &mmrange);
 		if (ret)
 			goto out_unlock;
 	}
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index d697c8ab0a14..791f9f93643c 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -16,6 +16,7 @@
 #include <linux/binfmts.h>
 #include <linux/sched/coredump.h>
 #include <linux/sched/task.h>
+#include <linux/range_lock.h>
 
 struct ctl_table_header;
 struct mempolicy;
@@ -263,6 +264,8 @@ struct proc_maps_private {
 #ifdef CONFIG_NUMA
 	struct mempolicy *task_mempolicy;
 #endif
+	/* mmap_sem is held across all stages of seqfile */
+	struct range_lock mmrange;
 } __randomize_layout;
 
 struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index b66fc8de7d34..7c0a79a937b5 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -174,6 +174,7 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
 	if (!mm || !mmget_not_zero(mm))
 		return NULL;
 
+	range_lock_init_full(&priv->mmrange);
 	down_read(&mm->mmap_sem);
 	hold_task_mempolicy(priv);
 	priv->tail_vma = get_gate_vma(mm);
@@ -514,7 +515,7 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 
 #ifdef CONFIG_SHMEM
 static int smaps_pte_hole(unsigned long addr, unsigned long end,
-		struct mm_walk *walk)
+			  struct mm_walk *walk, struct range_lock *mmrange)
 {
 	struct mem_size_stats *mss = walk->private;
 
@@ -605,7 +606,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
 #endif
 
 static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
-			   struct mm_walk *walk)
+			   struct mm_walk *walk, struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma = walk->vma;
 	pte_t *pte;
@@ -797,7 +798,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 #endif
 
 	/* mmap_sem is held in m_start */
-	walk_page_vma(vma, &smaps_walk);
+	walk_page_vma(vma, &smaps_walk, &priv->mmrange);
 	if (vma->vm_flags & VM_LOCKED)
 		mss->pss_locked += mss->pss;
 
@@ -1012,7 +1013,8 @@ static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 #endif
 
 static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
-				unsigned long end, struct mm_walk *walk)
+				unsigned long end, struct mm_walk *walk,
+				struct range_lock *mmrange)
 {
 	struct clear_refs_private *cp = walk->private;
 	struct vm_area_struct *vma = walk->vma;
@@ -1103,6 +1105,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 	struct mmu_gather tlb;
 	int itype;
 	int rv;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	memset(buffer, 0, sizeof(buffer));
 	if (count > sizeof(buffer) - 1)
@@ -1166,7 +1169,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			}
 			mmu_notifier_invalidate_range_start(mm, 0, -1);
 		}
-		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
+		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk,
+				&mmrange);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_end(mm, 0, -1);
 		tlb_finish_mmu(&tlb, 0, -1);
@@ -1223,7 +1227,7 @@ static int add_to_pagemap(unsigned long addr, pagemap_entry_t *pme,
 }
 
 static int pagemap_pte_hole(unsigned long start, unsigned long end,
-				struct mm_walk *walk)
+			    struct mm_walk *walk, struct range_lock *mmrange)
 {
 	struct pagemapread *pm = walk->private;
 	unsigned long addr = start;
@@ -1301,7 +1305,7 @@ static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
 }
 
 static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
-			     struct mm_walk *walk)
+			     struct mm_walk *walk, struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma = walk->vma;
 	struct pagemapread *pm = walk->private;
@@ -1467,6 +1471,8 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	unsigned long start_vaddr;
 	unsigned long end_vaddr;
 	int ret = 0, copied = 0;
+	DEFINE_RANGE_LOCK_FULL(tmprange);
+	struct range_lock *mmrange = &tmprange;
 
 	if (!mm || !mmget_not_zero(mm))
 		goto out;
@@ -1523,7 +1529,8 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 		if (end < start_vaddr || end > end_vaddr)
 			end = end_vaddr;
 		down_read(&mm->mmap_sem);
-		ret = walk_page_range(start_vaddr, end, &pagemap_walk);
+		ret = walk_page_range(start_vaddr, end, &pagemap_walk,
+				      mmrange);
 		up_read(&mm->mmap_sem);
 		start_vaddr = end;
 
@@ -1671,7 +1678,8 @@ static struct page *can_gather_numa_stats_pmd(pmd_t pmd,
 #endif
 
 static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
-		unsigned long end, struct mm_walk *walk)
+			    unsigned long end, struct mm_walk *walk,
+			    struct range_lock *mmrange)
 {
 	struct numa_maps *md = walk->private;
 	struct vm_area_struct *vma = walk->vma;
@@ -1740,6 +1748,7 @@ static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
  */
 static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 {
+	struct proc_maps_private *priv = m->private;
 	struct numa_maps_private *numa_priv = m->private;
 	struct proc_maps_private *proc_priv = &numa_priv->proc_maps;
 	struct vm_area_struct *vma = v;
@@ -1785,7 +1794,7 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 		seq_puts(m, " huge");
 
 	/* mmap_sem is held by m_start */
-	walk_page_vma(vma, &walk);
+	walk_page_vma(vma, &walk, &priv->mmrange);
 
 	if (!md->pages)
 		goto out;
diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index a45f0af22a60..3768955c10bc 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -350,6 +350,11 @@ static int remap_oldmem_pfn_checked(struct vm_area_struct *vma,
 	unsigned long pos_start, pos_end, pos;
 	unsigned long zeropage_pfn = my_zero_pfn(0);
 	size_t len = 0;
+	/*
+	 * No concurrency for the bprm->mm yet -- this is a vmcore path,
+	 * but do_munmap() needs an mmrange.
+	 */
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	pos_start = pfn;
 	pos_end = pfn + (size >> PAGE_SHIFT);
@@ -388,7 +393,7 @@ static int remap_oldmem_pfn_checked(struct vm_area_struct *vma,
 	}
 	return 0;
 fail:
-	do_munmap(vma->vm_mm, from, len, NULL);
+	do_munmap(vma->vm_mm, from, len, NULL, &mmrange);
 	return -EAGAIN;
 }
 
@@ -411,6 +416,11 @@ static int mmap_vmcore(struct file *file, struct vm_area_struct *vma)
 	size_t size = vma->vm_end - vma->vm_start;
 	u64 start, end, len, tsz;
 	struct vmcore *m;
+	/*
+	 * No concurrency for the bprm->mm yet -- this is a vmcore path,
+	 * but do_munmap() needs an mmrange.
+	 */
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	start = (u64)vma->vm_pgoff << PAGE_SHIFT;
 	end = start + size;
@@ -481,7 +491,7 @@ static int mmap_vmcore(struct file *file, struct vm_area_struct *vma)
 
 	return 0;
 fail:
-	do_munmap(vma->vm_mm, vma->vm_start, len, NULL);
+	do_munmap(vma->vm_mm, vma->vm_start, len, NULL, &mmrange);
 	return -EAGAIN;
 }
 #else
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 87a13a7c8270..e3089865fd52 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -851,6 +851,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	/* len == 0 means wake all */
 	struct userfaultfd_wake_range range = { .len = 0, };
 	unsigned long new_flags;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	WRITE_ONCE(ctx->released, true);
 
@@ -880,7 +881,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 				 new_flags, vma->anon_vma,
 				 vma->vm_file, vma->vm_pgoff,
 				 vma_policy(vma),
-				 NULL_VM_UFFD_CTX);
+				 NULL_VM_UFFD_CTX, &mmrange);
 		if (prev)
 			vma = prev;
 		else
@@ -1276,6 +1277,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	bool found;
 	bool basic_ioctls;
 	unsigned long start, end, vma_end;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	user_uffdio_register = (struct uffdio_register __user *) arg;
 
@@ -1413,18 +1415,19 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		prev = vma_merge(mm, prev, start, vma_end, new_flags,
 				 vma->anon_vma, vma->vm_file, vma->vm_pgoff,
 				 vma_policy(vma),
-				 ((struct vm_userfaultfd_ctx){ ctx }));
+				 ((struct vm_userfaultfd_ctx){ ctx }),
+				 &mmrange);
 		if (prev) {
 			vma = prev;
 			goto next;
 		}
 		if (vma->vm_start < start) {
-			ret = split_vma(mm, vma, start, 1);
+			ret = split_vma(mm, vma, start, 1, &mmrange);
 			if (ret)
 				break;
 		}
 		if (vma->vm_end > end) {
-			ret = split_vma(mm, vma, end, 0);
+			ret = split_vma(mm, vma, end, 0, &mmrange);
 			if (ret)
 				break;
 		}
@@ -1471,6 +1474,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	bool found;
 	unsigned long start, end, vma_end;
 	const void __user *buf = (void __user *)arg;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	ret = -EFAULT;
 	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
@@ -1571,18 +1575,18 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		prev = vma_merge(mm, prev, start, vma_end, new_flags,
 				 vma->anon_vma, vma->vm_file, vma->vm_pgoff,
 				 vma_policy(vma),
-				 NULL_VM_UFFD_CTX);
+				 NULL_VM_UFFD_CTX, &mmrange);
 		if (prev) {
 			vma = prev;
 			goto next;
 		}
 		if (vma->vm_start < start) {
-			ret = split_vma(mm, vma, start, 1);
+			ret = split_vma(mm, vma, start, 1, &mmrange);
 			if (ret)
 				break;
 		}
 		if (vma->vm_end > end) {
-			ret = split_vma(mm, vma, end, 0);
+			ret = split_vma(mm, vma, end, 0, &mmrange);
 			if (ret)
 				break;
 		}
diff --git a/include/asm-generic/mm_hooks.h b/include/asm-generic/mm_hooks.h
index 8ac4e68a12f0..2115deceded1 100644
--- a/include/asm-generic/mm_hooks.h
+++ b/include/asm-generic/mm_hooks.h
@@ -19,7 +19,8 @@ static inline void arch_exit_mmap(struct mm_struct *mm)
 
 static inline void arch_unmap(struct mm_struct *mm,
 			struct vm_area_struct *vma,
-			unsigned long start, unsigned long end)
+			unsigned long start, unsigned long end,
+			struct range_lock *mmrange)
 {
 }
 
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 325017ad9311..da004594d831 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -295,7 +295,7 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
 		     struct hmm_range *range,
 		     unsigned long start,
 		     unsigned long end,
-		     hmm_pfn_t *pfns);
+		     hmm_pfn_t *pfns, struct range_lock *mmrange);
 bool hmm_vma_range_done(struct vm_area_struct *vma, struct hmm_range *range);
 
 
@@ -323,7 +323,7 @@ int hmm_vma_fault(struct vm_area_struct *vma,
 		  unsigned long end,
 		  hmm_pfn_t *pfns,
 		  bool write,
-		  bool block);
+		  bool block, struct range_lock *mmrange);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 
diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 44368b19b27e..19667b75f73c 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -20,7 +20,8 @@ struct mem_cgroup;
 
 #ifdef CONFIG_KSM
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags);
+		unsigned long end, int advice, unsigned long *vm_flags,
+		struct range_lock *mmrange);
 int __ksm_enter(struct mm_struct *mm);
 void __ksm_exit(struct mm_struct *mm);
 
@@ -78,7 +79,8 @@ static inline void ksm_exit(struct mm_struct *mm)
 
 #ifdef CONFIG_MMU
 static inline int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags)
+		      unsigned long end, int advice, unsigned long *vm_flags,
+		      struct range_lock *mmrange)
 {
 	return 0;
 }
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 0c6fe904bc97..fa08e348a295 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -272,7 +272,7 @@ int migrate_vma(const struct migrate_vma_ops *ops,
 		unsigned long end,
 		unsigned long *src,
 		unsigned long *dst,
-		void *private);
+		void *private, struct range_lock *mmrange);
 #else
 static inline int migrate_vma(const struct migrate_vma_ops *ops,
 			      struct vm_area_struct *vma,
@@ -280,7 +280,7 @@ static inline int migrate_vma(const struct migrate_vma_ops *ops,
 			      unsigned long end,
 			      unsigned long *src,
 			      unsigned long *dst,
-			      void *private)
+			      void *private, struct range_lock *mmrange)
 {
 	return -EINVAL;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bcf2509d448d..fc4e7fdc3e76 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1295,11 +1295,12 @@ struct mm_walk {
 	int (*pud_entry)(pud_t *pud, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
 	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
-			 unsigned long next, struct mm_walk *walk);
+			 unsigned long next, struct mm_walk *walk,
+			 struct range_lock *mmrange);
 	int (*pte_entry)(pte_t *pte, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
 	int (*pte_hole)(unsigned long addr, unsigned long next,
-			struct mm_walk *walk);
+			struct mm_walk *walk, struct range_lock *mmrange);
 	int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
 			     unsigned long addr, unsigned long next,
 			     struct mm_walk *walk);
@@ -1311,8 +1312,9 @@ struct mm_walk {
 };
 
 int walk_page_range(unsigned long addr, unsigned long end,
-		struct mm_walk *walk);
-int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
+		    struct mm_walk *walk, struct range_lock *mmrange);
+int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk,
+		  struct range_lock *mmrange);
 void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
@@ -1337,17 +1339,18 @@ int invalidate_inode_page(struct page *page);
 
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags);
+			   unsigned int flags, struct range_lock *mmrange);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags,
-			    bool *unlocked);
+			    bool *unlocked, struct range_lock *mmrange);
 void unmap_mapping_pages(struct address_space *mapping,
 		pgoff_t start, pgoff_t nr, bool even_cows);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
 #else
 static inline int handle_mm_fault(struct vm_area_struct *vma,
-		unsigned long address, unsigned int flags)
+		unsigned long address, unsigned int flags,
+		struct range_lock *mmrange)
 {
 	/* should never happen if there's no MMU */
 	BUG();
@@ -1355,7 +1358,8 @@ static inline int handle_mm_fault(struct vm_area_struct *vma,
 }
 static inline int fixup_user_fault(struct task_struct *tsk,
 		struct mm_struct *mm, unsigned long address,
-		unsigned int fault_flags, bool *unlocked)
+		unsigned int fault_flags, bool *unlocked,
+		struct range_lock *mmrange)
 {
 	/* should never happen if there's no MMU */
 	BUG();
@@ -1383,24 +1387,28 @@ extern int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
-			    struct vm_area_struct **vmas, int *locked);
+			    struct vm_area_struct **vmas, int *locked,
+			    struct range_lock *mmrange);
 long get_user_pages(unsigned long start, unsigned long nr_pages,
-			    unsigned int gup_flags, struct page **pages,
-			    struct vm_area_struct **vmas);
+		    unsigned int gup_flags, struct page **pages,
+		    struct vm_area_struct **vmas, struct range_lock *mmrange);
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
-		    unsigned int gup_flags, struct page **pages, int *locked);
+			   unsigned int gup_flags, struct page **pages,
+			   int *locked, struct range_lock *mmrange);
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 		    struct page **pages, unsigned int gup_flags);
 #ifdef CONFIG_FS_DAX
 long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
-			    unsigned int gup_flags, struct page **pages,
-			    struct vm_area_struct **vmas);
+			     unsigned int gup_flags, struct page **pages,
+			     struct vm_area_struct **vmas,
+			     struct range_lock *mmrange);
 #else
 static inline long get_user_pages_longterm(unsigned long start,
 		unsigned long nr_pages, unsigned int gup_flags,
-		struct page **pages, struct vm_area_struct **vmas)
+		struct page **pages, struct vm_area_struct **vmas,
+		struct range_lock *mmrange)
 {
-	return get_user_pages(start, nr_pages, gup_flags, pages, vmas);
+	return get_user_pages(start, nr_pages, gup_flags, pages, vmas, mmrange);
 }
 #endif /* CONFIG_FS_DAX */
 
@@ -1505,7 +1513,8 @@ extern unsigned long change_protection(struct vm_area_struct *vma, unsigned long
 			      int dirty_accountable, int prot_numa);
 extern int mprotect_fixup(struct vm_area_struct *vma,
 			  struct vm_area_struct **pprev, unsigned long start,
-			  unsigned long end, unsigned long newflags);
+			  unsigned long end, unsigned long newflags,
+			  struct range_lock *mmrange);
 
 /*
  * doesn't attempt to fault and will return short.
@@ -2149,28 +2158,30 @@ void anon_vma_interval_tree_verify(struct anon_vma_chain *node);
 extern int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin);
 extern int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert,
-	struct vm_area_struct *expand);
+	struct vm_area_struct *expand, struct range_lock *mmrange);
 static inline int vma_adjust(struct vm_area_struct *vma, unsigned long start,
-	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert)
+	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert,
+	struct range_lock *mmrange)
 {
-	return __vma_adjust(vma, start, end, pgoff, insert, NULL);
+	return __vma_adjust(vma, start, end, pgoff, insert, NULL, mmrange);
 }
 extern struct vm_area_struct *vma_merge(struct mm_struct *,
 	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
 	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
-	struct mempolicy *, struct vm_userfaultfd_ctx);
+	struct mempolicy *, struct vm_userfaultfd_ctx,
+	struct range_lock *mmrange);
 extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
 extern int __split_vma(struct mm_struct *, struct vm_area_struct *,
-	unsigned long addr, int new_below);
+	unsigned long addr, int new_below, struct range_lock *mmrange);
 extern int split_vma(struct mm_struct *, struct vm_area_struct *,
-	unsigned long addr, int new_below);
+	unsigned long addr, int new_below, struct range_lock *mmrange);
 extern int insert_vm_struct(struct mm_struct *, struct vm_area_struct *);
 extern void __vma_link_rb(struct mm_struct *, struct vm_area_struct *,
 	struct rb_node **, struct rb_node *);
 extern void unlink_file_vma(struct vm_area_struct *);
 extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
 	unsigned long addr, unsigned long len, pgoff_t pgoff,
-	bool *need_rmap_locks);
+	bool *need_rmap_locks, struct range_lock *mmrange);
 extern void exit_mmap(struct mm_struct *);
 
 static inline int check_data_rlimit(unsigned long rlim,
@@ -2212,21 +2223,22 @@ extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned lo
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
-	struct list_head *uf);
+	struct list_head *uf, struct range_lock *mmrange);
 extern unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
 	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate,
-	struct list_head *uf);
+	struct list_head *uf, struct range_lock *mmrange);
 extern int do_munmap(struct mm_struct *, unsigned long, size_t,
-		     struct list_head *uf);
+		     struct list_head *uf, struct range_lock *mmrange);
 
 static inline unsigned long
 do_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
 	unsigned long pgoff, unsigned long *populate,
-	struct list_head *uf)
+	struct list_head *uf, struct range_lock *mmrange)
 {
-	return do_mmap(file, addr, len, prot, flags, 0, pgoff, populate, uf);
+	return do_mmap(file, addr, len, prot, flags, 0, pgoff, populate,
+		       uf, mmrange);
 }
 
 #ifdef CONFIG_MMU
@@ -2405,7 +2417,8 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
 #endif
 
-struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
+struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr,
+				       struct range_lock *);
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 0a294e950df8..79eb735e7c95 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -34,6 +34,7 @@ struct mm_struct;
 struct inode;
 struct notifier_block;
 struct page;
+struct range_lock;
 
 #define UPROBE_HANDLER_REMOVE		1
 #define UPROBE_HANDLER_MASK		1
@@ -115,17 +116,20 @@ struct uprobes_state {
 	struct xol_area		*xol_area;
 };
 
-extern int set_swbp(struct arch_uprobe *aup, struct mm_struct *mm, unsigned long vaddr);
-extern int set_orig_insn(struct arch_uprobe *aup, struct mm_struct *mm, unsigned long vaddr);
+extern int set_swbp(struct arch_uprobe *aup, struct mm_struct *mm,
+		    unsigned long vaddr, struct range_lock *mmrange);
+extern int set_orig_insn(struct arch_uprobe *aup, struct mm_struct *mm,
+			 unsigned long vaddr, struct range_lock *mmrange);
 extern bool is_swbp_insn(uprobe_opcode_t *insn);
 extern bool is_trap_insn(uprobe_opcode_t *insn);
 extern unsigned long uprobe_get_swbp_addr(struct pt_regs *regs);
 extern unsigned long uprobe_get_trap_addr(struct pt_regs *regs);
-extern int uprobe_write_opcode(struct mm_struct *mm, unsigned long vaddr, uprobe_opcode_t);
+extern int uprobe_write_opcode(struct mm_struct *mm, unsigned long vaddr,
+			       uprobe_opcode_t, struct range_lock *mmrange);
 extern int uprobe_register(struct inode *inode, loff_t offset, struct uprobe_consumer *uc);
 extern int uprobe_apply(struct inode *inode, loff_t offset, struct uprobe_consumer *uc, bool);
 extern void uprobe_unregister(struct inode *inode, loff_t offset, struct uprobe_consumer *uc);
-extern int uprobe_mmap(struct vm_area_struct *vma);
+extern int uprobe_mmap(struct vm_area_struct *vma, struct range_lock *mmrange);;
 extern void uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned long end);
 extern void uprobe_start_dup_mmap(void);
 extern void uprobe_end_dup_mmap(void);
@@ -169,7 +173,8 @@ static inline void
 uprobe_unregister(struct inode *inode, loff_t offset, struct uprobe_consumer *uc)
 {
 }
-static inline int uprobe_mmap(struct vm_area_struct *vma)
+static inline int uprobe_mmap(struct vm_area_struct *vma,
+			      struct range_lock *mmrange)
 {
 	return 0;
 }
diff --git a/ipc/shm.c b/ipc/shm.c
index 4643865e9171..6c29c791c7f2 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1293,6 +1293,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 	struct path path;
 	fmode_t f_mode;
 	unsigned long populate = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	err = -EINVAL;
 	if (shmid < 0)
@@ -1411,7 +1412,8 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 			goto invalid;
 	}
 
-	addr = do_mmap_pgoff(file, addr, size, prot, flags, 0, &populate, NULL);
+	addr = do_mmap_pgoff(file, addr, size, prot, flags, 0, &populate, NULL,
+			     &mmrange);
 	*raddr = addr;
 	err = 0;
 	if (IS_ERR_VALUE(addr))
@@ -1487,6 +1489,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 	struct file *file;
 	struct vm_area_struct *next;
 #endif
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (addr & ~PAGE_MASK)
 		return retval;
@@ -1537,7 +1540,8 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 			 */
 			file = vma->vm_file;
 			size = i_size_read(file_inode(vma->vm_file));
-			do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start, NULL);
+			do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start,
+				  NULL, &mmrange);
 			/*
 			 * We discovered the size of the shm segment, so
 			 * break out of here and fall through to the next
@@ -1564,7 +1568,8 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 		if ((vma->vm_ops == &shm_vm_ops) &&
 		    ((vma->vm_start - addr)/PAGE_SIZE == vma->vm_pgoff) &&
 		    (vma->vm_file == file))
-			do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start, NULL);
+			do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start,
+				  NULL, &mmrange);
 		vma = next;
 	}
 
@@ -1573,7 +1578,8 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 	 * given
 	 */
 	if (vma && vma->vm_start == addr && vma->vm_ops == &shm_vm_ops) {
-		do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start, NULL);
+		do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start,
+			  NULL, &mmrange);
 		retval = 0;
 	}
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index ce6848e46e94..60e12b39182c 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -300,7 +300,7 @@ static int verify_opcode(struct page *page, unsigned long vaddr, uprobe_opcode_t
  * Return 0 (success) or a negative errno.
  */
 int uprobe_write_opcode(struct mm_struct *mm, unsigned long vaddr,
-			uprobe_opcode_t opcode)
+			uprobe_opcode_t opcode, struct range_lock *mmrange)
 {
 	struct page *old_page, *new_page;
 	struct vm_area_struct *vma;
@@ -309,7 +309,8 @@ int uprobe_write_opcode(struct mm_struct *mm, unsigned long vaddr,
 retry:
 	/* Read the page with vaddr into memory */
 	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
-			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL);
+			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL,
+			mmrange);
 	if (ret <= 0)
 		return ret;
 
@@ -349,9 +350,10 @@ int uprobe_write_opcode(struct mm_struct *mm, unsigned long vaddr,
  * For mm @mm, store the breakpoint instruction at @vaddr.
  * Return 0 (success) or a negative errno.
  */
-int __weak set_swbp(struct arch_uprobe *auprobe, struct mm_struct *mm, unsigned long vaddr)
+int __weak set_swbp(struct arch_uprobe *auprobe, struct mm_struct *mm,
+		    unsigned long vaddr, struct range_lock *mmrange)
 {
-	return uprobe_write_opcode(mm, vaddr, UPROBE_SWBP_INSN);
+	return uprobe_write_opcode(mm, vaddr, UPROBE_SWBP_INSN, mmrange);
 }
 
 /**
@@ -364,9 +366,12 @@ int __weak set_swbp(struct arch_uprobe *auprobe, struct mm_struct *mm, unsigned
  * Return 0 (success) or a negative errno.
  */
 int __weak
-set_orig_insn(struct arch_uprobe *auprobe, struct mm_struct *mm, unsigned long vaddr)
+set_orig_insn(struct arch_uprobe *auprobe, struct mm_struct *mm,
+	      unsigned long vaddr, struct range_lock *mmrange)
 {
-	return uprobe_write_opcode(mm, vaddr, *(uprobe_opcode_t *)&auprobe->insn);
+	return uprobe_write_opcode(mm, vaddr,
+				   *(uprobe_opcode_t *)&auprobe->insn,
+				   mmrange);
 }
 
 static struct uprobe *get_uprobe(struct uprobe *uprobe)
@@ -650,7 +655,8 @@ static bool filter_chain(struct uprobe *uprobe,
 
 static int
 install_breakpoint(struct uprobe *uprobe, struct mm_struct *mm,
-			struct vm_area_struct *vma, unsigned long vaddr)
+		   struct vm_area_struct *vma, unsigned long vaddr,
+		   struct range_lock *mmrange)
 {
 	bool first_uprobe;
 	int ret;
@@ -667,7 +673,7 @@ install_breakpoint(struct uprobe *uprobe, struct mm_struct *mm,
 	if (first_uprobe)
 		set_bit(MMF_HAS_UPROBES, &mm->flags);
 
-	ret = set_swbp(&uprobe->arch, mm, vaddr);
+	ret = set_swbp(&uprobe->arch, mm, vaddr, mmrange);
 	if (!ret)
 		clear_bit(MMF_RECALC_UPROBES, &mm->flags);
 	else if (first_uprobe)
@@ -677,10 +683,11 @@ install_breakpoint(struct uprobe *uprobe, struct mm_struct *mm,
 }
 
 static int
-remove_breakpoint(struct uprobe *uprobe, struct mm_struct *mm, unsigned long vaddr)
+remove_breakpoint(struct uprobe *uprobe, struct mm_struct *mm,
+		  unsigned long vaddr, struct range_lock *mmrange)
 {
 	set_bit(MMF_RECALC_UPROBES, &mm->flags);
-	return set_orig_insn(&uprobe->arch, mm, vaddr);
+	return set_orig_insn(&uprobe->arch, mm, vaddr, mmrange);
 }
 
 static inline bool uprobe_is_active(struct uprobe *uprobe)
@@ -794,6 +801,7 @@ register_for_each_vma(struct uprobe *uprobe, struct uprobe_consumer *new)
 	bool is_register = !!new;
 	struct map_info *info;
 	int err = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	percpu_down_write(&dup_mmap_sem);
 	info = build_map_info(uprobe->inode->i_mapping,
@@ -824,11 +832,13 @@ register_for_each_vma(struct uprobe *uprobe, struct uprobe_consumer *new)
 			/* consult only the "caller", new consumer. */
 			if (consumer_filter(new,
 					UPROBE_FILTER_REGISTER, mm))
-				err = install_breakpoint(uprobe, mm, vma, info->vaddr);
+				err = install_breakpoint(uprobe, mm, vma,
+							 info->vaddr, &mmrange);
 		} else if (test_bit(MMF_HAS_UPROBES, &mm->flags)) {
 			if (!filter_chain(uprobe,
 					UPROBE_FILTER_UNREGISTER, mm))
-				err |= remove_breakpoint(uprobe, mm, info->vaddr);
+				err |= remove_breakpoint(uprobe, mm,
+							 info->vaddr, &mmrange);
 		}
 
  unlock:
@@ -972,6 +982,7 @@ static int unapply_uprobe(struct uprobe *uprobe, struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 	int err = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	down_read(&mm->mmap_sem);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
@@ -988,7 +999,7 @@ static int unapply_uprobe(struct uprobe *uprobe, struct mm_struct *mm)
 			continue;
 
 		vaddr = offset_to_vaddr(vma, uprobe->offset);
-		err |= remove_breakpoint(uprobe, mm, vaddr);
+		err |= remove_breakpoint(uprobe, mm, vaddr, &mmrange);
 	}
 	up_read(&mm->mmap_sem);
 
@@ -1063,7 +1074,7 @@ static void build_probe_list(struct inode *inode,
  * Currently we ignore all errors and always return 0, the callers
  * can't handle the failure anyway.
  */
-int uprobe_mmap(struct vm_area_struct *vma)
+int uprobe_mmap(struct vm_area_struct *vma, struct range_lock *mmrange)
 {
 	struct list_head tmp_list;
 	struct uprobe *uprobe, *u;
@@ -1087,7 +1098,7 @@ int uprobe_mmap(struct vm_area_struct *vma)
 		if (!fatal_signal_pending(current) &&
 		    filter_chain(uprobe, UPROBE_FILTER_MMAP, vma->vm_mm)) {
 			unsigned long vaddr = offset_to_vaddr(vma, uprobe->offset);
-			install_breakpoint(uprobe, vma->vm_mm, vma, vaddr);
+			install_breakpoint(uprobe, vma->vm_mm, vma, vaddr, mmrange);
 		}
 		put_uprobe(uprobe);
 	}
@@ -1698,7 +1709,8 @@ static void mmf_recalc_uprobes(struct mm_struct *mm)
 	clear_bit(MMF_HAS_UPROBES, &mm->flags);
 }
 
-static int is_trap_at_addr(struct mm_struct *mm, unsigned long vaddr)
+static int is_trap_at_addr(struct mm_struct *mm, unsigned long vaddr,
+			   struct range_lock *mmrange)
 {
 	struct page *page;
 	uprobe_opcode_t opcode;
@@ -1718,7 +1730,7 @@ static int is_trap_at_addr(struct mm_struct *mm, unsigned long vaddr)
 	 * essentially a kernel access to the memory.
 	 */
 	result = get_user_pages_remote(NULL, mm, vaddr, 1, FOLL_FORCE, &page,
-			NULL, NULL);
+				       NULL, NULL, mmrange);
 	if (result < 0)
 		return result;
 
@@ -1734,6 +1746,7 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
 	struct mm_struct *mm = current->mm;
 	struct uprobe *uprobe = NULL;
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, bp_vaddr);
@@ -1746,7 +1759,7 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
 		}
 
 		if (!uprobe)
-			*is_swbp = is_trap_at_addr(mm, bp_vaddr);
+			*is_swbp = is_trap_at_addr(mm, bp_vaddr, &mmrange);
 	} else {
 		*is_swbp = -EFAULT;
 	}
diff --git a/kernel/futex.c b/kernel/futex.c
index 1f450e092c74..09a0d86f80a0 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -725,10 +725,11 @@ static int fault_in_user_writeable(u32 __user *uaddr)
 {
 	struct mm_struct *mm = current->mm;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	down_read(&mm->mmap_sem);
 	ret = fixup_user_fault(current, mm, (unsigned long)uaddr,
-			       FAULT_FLAG_WRITE, NULL);
+			       FAULT_FLAG_WRITE, NULL, &mmrange);
 	up_read(&mm->mmap_sem);
 
 	return ret < 0 ? ret : 0;
diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index c64dca6e27c2..d3dccd80c6ee 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -39,6 +39,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	int ret = 0;
 	int err;
 	int locked;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (nr_frames == 0)
 		return 0;
@@ -71,7 +72,8 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 		vec->got_ref = true;
 		vec->is_pfns = false;
 		ret = get_user_pages_locked(start, nr_frames,
-			gup_flags, (struct page **)(vec->ptrs), &locked);
+			gup_flags, (struct page **)(vec->ptrs), &locked,
+			&mmrange);
 		goto out;
 	}
 
diff --git a/mm/gup.c b/mm/gup.c
index 1b46e6e74881..01983a7b3750 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -478,7 +478,8 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
  * If it is, *@nonblocking will be set to 0 and -EBUSY returned.
  */
 static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
-		unsigned long address, unsigned int *flags, int *nonblocking)
+		unsigned long address, unsigned int *flags, int *nonblocking,
+		struct range_lock *mmrange)
 {
 	unsigned int fault_flags = 0;
 	int ret;
@@ -499,7 +500,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		fault_flags |= FAULT_FLAG_TRIED;
 	}
 
-	ret = handle_mm_fault(vma, address, fault_flags);
+	ret = handle_mm_fault(vma, address, fault_flags, mmrange);
 	if (ret & VM_FAULT_ERROR) {
 		int err = vm_fault_to_errno(ret, *flags);
 
@@ -592,6 +593,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
  * @vmas:	array of pointers to vmas corresponding to each page.
  *		Or NULL if the caller does not require them.
  * @nonblocking: whether waiting for disk IO or mmap_sem contention
+ * @mmrange:	mm address space range locking
  *
  * Returns number of pages pinned. This may be fewer than the number
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
@@ -638,7 +640,8 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
 static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas, int *nonblocking)
+		struct vm_area_struct **vmas, int *nonblocking,
+		struct range_lock *mmrange)
 {
 	long i = 0;
 	unsigned int page_mask;
@@ -664,7 +667,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 
 		/* first iteration or cross vma bound */
 		if (!vma || start >= vma->vm_end) {
-			vma = find_extend_vma(mm, start);
+			vma = find_extend_vma(mm, start, mmrange);
 			if (!vma && in_gate_area(mm, start)) {
 				int ret;
 				ret = get_gate_page(mm, start & PAGE_MASK,
@@ -697,7 +700,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		if (!page) {
 			int ret;
 			ret = faultin_page(tsk, vma, start, &foll_flags,
-					nonblocking);
+					   nonblocking, mmrange);
 			switch (ret) {
 			case 0:
 				goto retry;
@@ -796,7 +799,7 @@ static bool vma_permits_fault(struct vm_area_struct *vma,
  */
 int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long address, unsigned int fault_flags,
-		     bool *unlocked)
+		     bool *unlocked, struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	int ret, major = 0;
@@ -805,14 +808,14 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 
 retry:
-	vma = find_extend_vma(mm, address);
+	vma = find_extend_vma(mm, address, mmrange);
 	if (!vma || address < vma->vm_start)
 		return -EFAULT;
 
 	if (!vma_permits_fault(vma, fault_flags))
 		return -EFAULT;
 
-	ret = handle_mm_fault(vma, address, fault_flags);
+	ret = handle_mm_fault(vma, address, fault_flags, mmrange);
 	major |= ret & VM_FAULT_MAJOR;
 	if (ret & VM_FAULT_ERROR) {
 		int err = vm_fault_to_errno(ret, 0);
@@ -849,7 +852,8 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 						struct page **pages,
 						struct vm_area_struct **vmas,
 						int *locked,
-						unsigned int flags)
+						unsigned int flags,
+						struct range_lock *mmrange)
 {
 	long ret, pages_done;
 	bool lock_dropped;
@@ -868,7 +872,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 	lock_dropped = false;
 	for (;;) {
 		ret = __get_user_pages(tsk, mm, start, nr_pages, flags, pages,
-				       vmas, locked);
+				       vmas, locked, mmrange);
 		if (!locked)
 			/* VM_FAULT_RETRY couldn't trigger, bypass */
 			return ret;
@@ -908,7 +912,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		lock_dropped = true;
 		down_read(&mm->mmap_sem);
 		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
-				       pages, NULL, NULL);
+				       pages, NULL, NULL, mmrange);
 		if (ret != 1) {
 			BUG_ON(ret > 1);
 			if (!pages_done)
@@ -956,11 +960,11 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
  */
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 			   unsigned int gup_flags, struct page **pages,
-			   int *locked)
+			   int *locked, struct range_lock *mmrange)
 {
 	return __get_user_pages_locked(current, current->mm, start, nr_pages,
 				       pages, NULL, locked,
-				       gup_flags | FOLL_TOUCH);
+				       gup_flags | FOLL_TOUCH, mmrange);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
@@ -985,10 +989,11 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 	struct mm_struct *mm = current->mm;
 	int locked = 1;
 	long ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	down_read(&mm->mmap_sem);
 	ret = __get_user_pages_locked(current, mm, start, nr_pages, pages, NULL,
-				      &locked, gup_flags | FOLL_TOUCH);
+				      &locked, gup_flags | FOLL_TOUCH, &mmrange);
 	if (locked)
 		up_read(&mm->mmap_sem);
 	return ret;
@@ -1054,11 +1059,13 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas, int *locked)
+	        struct vm_area_struct **vmas, int *locked,
+		struct range_lock *mmrange)
 {
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
 				       locked,
-				       gup_flags | FOLL_TOUCH | FOLL_REMOTE);
+				       gup_flags | FOLL_TOUCH | FOLL_REMOTE,
+				       mmrange);
 }
 EXPORT_SYMBOL(get_user_pages_remote);
 
@@ -1071,11 +1078,11 @@ EXPORT_SYMBOL(get_user_pages_remote);
  */
 long get_user_pages(unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas)
+		struct vm_area_struct **vmas, struct range_lock *mmrange)
 {
 	return __get_user_pages_locked(current, current->mm, start, nr_pages,
 				       pages, vmas, NULL,
-				       gup_flags | FOLL_TOUCH);
+				       gup_flags | FOLL_TOUCH, mmrange);
 }
 EXPORT_SYMBOL(get_user_pages);
 
@@ -1094,7 +1101,8 @@ EXPORT_SYMBOL(get_user_pages);
  */
 long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas_arg)
+	        struct vm_area_struct **vmas_arg,
+		struct range_lock *mmrange)
 {
 	struct vm_area_struct **vmas = vmas_arg;
 	struct vm_area_struct *vma_prev = NULL;
@@ -1110,7 +1118,7 @@ long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
 			return -ENOMEM;
 	}
 
-	rc = get_user_pages(start, nr_pages, gup_flags, pages, vmas);
+	rc = get_user_pages(start, nr_pages, gup_flags, pages, vmas, mmrange);
 
 	for (i = 0; i < rc; i++) {
 		struct vm_area_struct *vma = vmas[i];
@@ -1149,6 +1157,7 @@ EXPORT_SYMBOL(get_user_pages_longterm);
  * @start: start address
  * @end:   end address
  * @nonblocking:
+ * @mmrange: mm address space range locking
  *
  * This takes care of mlocking the pages too if VM_LOCKED is set.
  *
@@ -1163,7 +1172,8 @@ EXPORT_SYMBOL(get_user_pages_longterm);
  * released.  If it's released, *@nonblocking will be set to 0.
  */
 long populate_vma_page_range(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end, int *nonblocking)
+		unsigned long start, unsigned long end, int *nonblocking,
+		struct range_lock *mmrange)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long nr_pages = (end - start) / PAGE_SIZE;
@@ -1198,7 +1208,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	 * not result in a stack expansion that recurses back here.
 	 */
 	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
-				NULL, NULL, nonblocking);
+				NULL, NULL, nonblocking, mmrange);
 }
 
 /*
@@ -1215,6 +1225,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 	struct vm_area_struct *vma = NULL;
 	int locked = 0;
 	long ret = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(len != PAGE_ALIGN(len));
@@ -1247,7 +1258,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		 * double checks the vma flags, so that it won't mlock pages
 		 * if the vma was already munlocked.
 		 */
-		ret = populate_vma_page_range(vma, nstart, nend, &locked);
+		ret = populate_vma_page_range(vma, nstart, nend, &locked, &mmrange);
 		if (ret < 0) {
 			if (ignore_errors) {
 				ret = 0;
@@ -1282,10 +1293,11 @@ struct page *get_dump_page(unsigned long addr)
 {
 	struct vm_area_struct *vma;
 	struct page *page;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (__get_user_pages(current, current->mm, addr, 1,
 			     FOLL_FORCE | FOLL_DUMP | FOLL_GET, &page, &vma,
-			     NULL) < 1)
+			     NULL, &mmrange) < 1)
 		return NULL;
 	flush_cache_page(vma, addr, page_to_pfn(page));
 	return page;
diff --git a/mm/hmm.c b/mm/hmm.c
index 320545b98ff5..b14e6869689e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -245,7 +245,8 @@ struct hmm_vma_walk {
 
 static int hmm_vma_do_fault(struct mm_walk *walk,
 			    unsigned long addr,
-			    hmm_pfn_t *pfn)
+			    hmm_pfn_t *pfn,
+			    struct range_lock *mmrange)
 {
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_REMOTE;
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
@@ -254,7 +255,7 @@ static int hmm_vma_do_fault(struct mm_walk *walk,
 
 	flags |= hmm_vma_walk->block ? 0 : FAULT_FLAG_ALLOW_RETRY;
 	flags |= hmm_vma_walk->write ? FAULT_FLAG_WRITE : 0;
-	r = handle_mm_fault(vma, addr, flags);
+	r = handle_mm_fault(vma, addr, flags, mmrange);
 	if (r & VM_FAULT_RETRY)
 		return -EBUSY;
 	if (r & VM_FAULT_ERROR) {
@@ -298,7 +299,9 @@ static void hmm_pfns_clear(hmm_pfn_t *pfns,
 
 static int hmm_vma_walk_hole(unsigned long addr,
 			     unsigned long end,
-			     struct mm_walk *walk)
+			     struct mm_walk *walk,
+			     struct range_lock *mmrange)
+
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
@@ -312,7 +315,7 @@ static int hmm_vma_walk_hole(unsigned long addr,
 		if (hmm_vma_walk->fault) {
 			int ret;
 
-			ret = hmm_vma_do_fault(walk, addr, &pfns[i]);
+			ret = hmm_vma_do_fault(walk, addr, &pfns[i], mmrange);
 			if (ret != -EAGAIN)
 				return ret;
 		}
@@ -323,7 +326,8 @@ static int hmm_vma_walk_hole(unsigned long addr,
 
 static int hmm_vma_walk_clear(unsigned long addr,
 			      unsigned long end,
-			      struct mm_walk *walk)
+			      struct mm_walk *walk,
+			      struct range_lock *mmrange)
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
@@ -337,7 +341,7 @@ static int hmm_vma_walk_clear(unsigned long addr,
 		if (hmm_vma_walk->fault) {
 			int ret;
 
-			ret = hmm_vma_do_fault(walk, addr, &pfns[i]);
+			ret = hmm_vma_do_fault(walk, addr, &pfns[i], mmrange);
 			if (ret != -EAGAIN)
 				return ret;
 		}
@@ -349,7 +353,8 @@ static int hmm_vma_walk_clear(unsigned long addr,
 static int hmm_vma_walk_pmd(pmd_t *pmdp,
 			    unsigned long start,
 			    unsigned long end,
-			    struct mm_walk *walk)
+			    struct mm_walk *walk,
+			    struct range_lock *mmrange)
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
@@ -366,7 +371,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 
 again:
 	if (pmd_none(*pmdp))
-		return hmm_vma_walk_hole(start, end, walk);
+		return hmm_vma_walk_hole(start, end, walk, mmrange);
 
 	if (pmd_huge(*pmdp) && vma->vm_flags & VM_HUGETLB)
 		return hmm_pfns_bad(start, end, walk);
@@ -389,10 +394,10 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		if (!pmd_devmap(pmd) && !pmd_trans_huge(pmd))
 			goto again;
 		if (pmd_protnone(pmd))
-			return hmm_vma_walk_clear(start, end, walk);
+			return hmm_vma_walk_clear(start, end, walk, mmrange);
 
 		if (write_fault && !pmd_write(pmd))
-			return hmm_vma_walk_clear(start, end, walk);
+			return hmm_vma_walk_clear(start, end, walk, mmrange);
 
 		pfn = pmd_pfn(pmd) + pte_index(addr);
 		flag |= pmd_write(pmd) ? HMM_PFN_WRITE : 0;
@@ -464,7 +469,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 fault:
 		pte_unmap(ptep);
 		/* Fault all pages in range */
-		return hmm_vma_walk_clear(start, end, walk);
+		return hmm_vma_walk_clear(start, end, walk, mmrange);
 	}
 	pte_unmap(ptep - 1);
 
@@ -495,7 +500,8 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
 		     struct hmm_range *range,
 		     unsigned long start,
 		     unsigned long end,
-		     hmm_pfn_t *pfns)
+		     hmm_pfn_t *pfns,
+		     struct range_lock *mmrange)
 {
 	struct hmm_vma_walk hmm_vma_walk;
 	struct mm_walk mm_walk;
@@ -541,7 +547,7 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
 	mm_walk.pmd_entry = hmm_vma_walk_pmd;
 	mm_walk.pte_hole = hmm_vma_walk_hole;
 
-	walk_page_range(start, end, &mm_walk);
+	walk_page_range(start, end, &mm_walk, mmrange);
 	return 0;
 }
 EXPORT_SYMBOL(hmm_vma_get_pfns);
@@ -664,7 +670,8 @@ int hmm_vma_fault(struct vm_area_struct *vma,
 		  unsigned long end,
 		  hmm_pfn_t *pfns,
 		  bool write,
-		  bool block)
+		  bool block,
+		  struct range_lock *mmrange)
 {
 	struct hmm_vma_walk hmm_vma_walk;
 	struct mm_walk mm_walk;
@@ -717,7 +724,7 @@ int hmm_vma_fault(struct vm_area_struct *vma,
 	mm_walk.pte_hole = hmm_vma_walk_hole;
 
 	do {
-		ret = walk_page_range(start, end, &mm_walk);
+		ret = walk_page_range(start, end, &mm_walk, mmrange);
 		start = hmm_vma_walk.last;
 	} while (ret == -EAGAIN);
 
diff --git a/mm/internal.h b/mm/internal.h
index 62d8c34e63d5..abf1de31e524 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -289,7 +289,8 @@ void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 
 #ifdef CONFIG_MMU
 extern long populate_vma_page_range(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end, int *nonblocking);
+			unsigned long start, unsigned long end, int *nonblocking,
+			struct range_lock *mmrange);
 extern void munlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
 static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
diff --git a/mm/ksm.c b/mm/ksm.c
index 293721f5da70..66c350cd9799 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -448,7 +448,8 @@ static inline bool ksm_test_exit(struct mm_struct *mm)
  * of the process that owns 'vma'.  We also do not want to enforce
  * protection keys here anyway.
  */
-static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
+static int break_ksm(struct vm_area_struct *vma, unsigned long addr,
+		     struct range_lock *mmrange)
 {
 	struct page *page;
 	int ret = 0;
@@ -461,7 +462,8 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 			break;
 		if (PageKsm(page))
 			ret = handle_mm_fault(vma, addr,
-					FAULT_FLAG_WRITE | FAULT_FLAG_REMOTE);
+					FAULT_FLAG_WRITE | FAULT_FLAG_REMOTE,
+					mmrange);
 		else
 			ret = VM_FAULT_WRITE;
 		put_page(page);
@@ -516,6 +518,7 @@ static void break_cow(struct rmap_item *rmap_item)
 	struct mm_struct *mm = rmap_item->mm;
 	unsigned long addr = rmap_item->address;
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * It is not an accident that whenever we want to break COW
@@ -526,7 +529,7 @@ static void break_cow(struct rmap_item *rmap_item)
 	down_read(&mm->mmap_sem);
 	vma = find_mergeable_vma(mm, addr);
 	if (vma)
-		break_ksm(vma, addr);
+		break_ksm(vma, addr, &mmrange);
 	up_read(&mm->mmap_sem);
 }
 
@@ -807,7 +810,8 @@ static void remove_trailing_rmap_items(struct mm_slot *mm_slot,
  * in cmp_and_merge_page on one of the rmap_items we would be removing.
  */
 static int unmerge_ksm_pages(struct vm_area_struct *vma,
-			     unsigned long start, unsigned long end)
+			     unsigned long start, unsigned long end,
+			     struct range_lock *mmrange)
 {
 	unsigned long addr;
 	int err = 0;
@@ -818,7 +822,7 @@ static int unmerge_ksm_pages(struct vm_area_struct *vma,
 		if (signal_pending(current))
 			err = -ERESTARTSYS;
 		else
-			err = break_ksm(vma, addr);
+			err = break_ksm(vma, addr, mmrange);
 	}
 	return err;
 }
@@ -922,6 +926,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int err = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	spin_lock(&ksm_mmlist_lock);
 	ksm_scan.mm_slot = list_entry(ksm_mm_head.mm_list.next,
@@ -937,8 +942,8 @@ static int unmerge_and_remove_all_rmap_items(void)
 				break;
 			if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
 				continue;
-			err = unmerge_ksm_pages(vma,
-						vma->vm_start, vma->vm_end);
+			err = unmerge_ksm_pages(vma, vma->vm_start,
+						vma->vm_end, &mmrange);
 			if (err)
 				goto error;
 		}
@@ -2350,7 +2355,8 @@ static int ksm_scan_thread(void *nothing)
 }
 
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags)
+		unsigned long end, int advice, unsigned long *vm_flags,
+		struct range_lock *mmrange)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int err;
@@ -2384,7 +2390,7 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 			return 0;		/* just ignore the advice */
 
 		if (vma->anon_vma) {
-			err = unmerge_ksm_pages(vma, start, end);
+			err = unmerge_ksm_pages(vma, start, end, mmrange);
 			if (err)
 				return err;
 		}
diff --git a/mm/madvise.c b/mm/madvise.c
index 4d3c922ea1a1..eaec6bfc2b08 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -54,7 +54,8 @@ static int madvise_need_mmap_write(int behavior)
  */
 static long madvise_behavior(struct vm_area_struct *vma,
 		     struct vm_area_struct **prev,
-		     unsigned long start, unsigned long end, int behavior)
+		     unsigned long start, unsigned long end, int behavior,
+		     struct range_lock *mmrange)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int error = 0;
@@ -104,7 +105,8 @@ static long madvise_behavior(struct vm_area_struct *vma,
 		break;
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
-		error = ksm_madvise(vma, start, end, behavior, &new_flags);
+		error = ksm_madvise(vma, start, end, behavior,
+				    &new_flags, mmrange);
 		if (error) {
 			/*
 			 * madvise() returns EAGAIN if kernel resources, such as
@@ -138,7 +140,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, new_flags, vma->anon_vma,
 			  vma->vm_file, pgoff, vma_policy(vma),
-			  vma->vm_userfaultfd_ctx);
+			  vma->vm_userfaultfd_ctx, mmrange);
 	if (*prev) {
 		vma = *prev;
 		goto success;
@@ -151,7 +153,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 			error = -ENOMEM;
 			goto out;
 		}
-		error = __split_vma(mm, vma, start, 1);
+		error = __split_vma(mm, vma, start, 1, mmrange);
 		if (error) {
 			/*
 			 * madvise() returns EAGAIN if kernel resources, such as
@@ -168,7 +170,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 			error = -ENOMEM;
 			goto out;
 		}
-		error = __split_vma(mm, vma, end, 0);
+		error = __split_vma(mm, vma, end, 0, mmrange);
 		if (error) {
 			/*
 			 * madvise() returns EAGAIN if kernel resources, such as
@@ -191,7 +193,8 @@ static long madvise_behavior(struct vm_area_struct *vma,
 
 #ifdef CONFIG_SWAP
 static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
-	unsigned long end, struct mm_walk *walk)
+				 unsigned long end, struct mm_walk *walk,
+				 struct range_lock *mmrange)
 {
 	pte_t *orig_pte;
 	struct vm_area_struct *vma = walk->private;
@@ -226,7 +229,8 @@ static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
 }
 
 static void force_swapin_readahead(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end)
+				   unsigned long start, unsigned long end,
+				   struct range_lock *mmrange)
 {
 	struct mm_walk walk = {
 		.mm = vma->vm_mm,
@@ -234,7 +238,7 @@ static void force_swapin_readahead(struct vm_area_struct *vma,
 		.private = vma,
 	};
 
-	walk_page_range(start, end, &walk);
+	walk_page_range(start, end, &walk, mmrange);
 
 	lru_add_drain();	/* Push any new pages onto the LRU now */
 }
@@ -272,14 +276,15 @@ static void force_shm_swapin_readahead(struct vm_area_struct *vma,
  */
 static long madvise_willneed(struct vm_area_struct *vma,
 			     struct vm_area_struct **prev,
-			     unsigned long start, unsigned long end)
+			     unsigned long start, unsigned long end,
+			     struct range_lock *mmrange)
 {
 	struct file *file = vma->vm_file;
 
 	*prev = vma;
 #ifdef CONFIG_SWAP
 	if (!file) {
-		force_swapin_readahead(vma, start, end);
+		force_swapin_readahead(vma, start, end, mmrange);
 		return 0;
 	}
 
@@ -308,7 +313,8 @@ static long madvise_willneed(struct vm_area_struct *vma,
 }
 
 static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
-				unsigned long end, struct mm_walk *walk)
+				  unsigned long end, struct mm_walk *walk,
+				  struct range_lock *mmrange)
 
 {
 	struct mmu_gather *tlb = walk->private;
@@ -442,7 +448,8 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 
 static void madvise_free_page_range(struct mmu_gather *tlb,
 			     struct vm_area_struct *vma,
-			     unsigned long addr, unsigned long end)
+			     unsigned long addr, unsigned long end,
+			     struct range_lock *mmrange)
 {
 	struct mm_walk free_walk = {
 		.pmd_entry = madvise_free_pte_range,
@@ -451,12 +458,14 @@ static void madvise_free_page_range(struct mmu_gather *tlb,
 	};
 
 	tlb_start_vma(tlb, vma);
-	walk_page_range(addr, end, &free_walk);
+	walk_page_range(addr, end, &free_walk, mmrange);
 	tlb_end_vma(tlb, vma);
 }
 
 static int madvise_free_single_vma(struct vm_area_struct *vma,
-			unsigned long start_addr, unsigned long end_addr)
+				   unsigned long start_addr,
+				   unsigned long end_addr,
+				   struct range_lock *mmrange)
 {
 	unsigned long start, end;
 	struct mm_struct *mm = vma->vm_mm;
@@ -478,7 +487,7 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
 	update_hiwater_rss(mm);
 
 	mmu_notifier_invalidate_range_start(mm, start, end);
-	madvise_free_page_range(&tlb, vma, start, end);
+	madvise_free_page_range(&tlb, vma, start, end, mmrange);
 	mmu_notifier_invalidate_range_end(mm, start, end);
 	tlb_finish_mmu(&tlb, start, end);
 
@@ -514,7 +523,7 @@ static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
 static long madvise_dontneed_free(struct vm_area_struct *vma,
 				  struct vm_area_struct **prev,
 				  unsigned long start, unsigned long end,
-				  int behavior)
+				  int behavior, struct range_lock *mmrange)
 {
 	*prev = vma;
 	if (!can_madv_dontneed_vma(vma))
@@ -562,7 +571,7 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
 	if (behavior == MADV_DONTNEED)
 		return madvise_dontneed_single_vma(vma, start, end);
 	else if (behavior == MADV_FREE)
-		return madvise_free_single_vma(vma, start, end);
+		return madvise_free_single_vma(vma, start, end, mmrange);
 	else
 		return -EINVAL;
 }
@@ -676,18 +685,21 @@ static int madvise_inject_error(int behavior,
 
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
-		unsigned long start, unsigned long end, int behavior)
+	    unsigned long start, unsigned long end, int behavior,
+	    struct range_lock *mmrange)
 {
 	switch (behavior) {
 	case MADV_REMOVE:
 		return madvise_remove(vma, prev, start, end);
 	case MADV_WILLNEED:
-		return madvise_willneed(vma, prev, start, end);
+		return madvise_willneed(vma, prev, start, end, mmrange);
 	case MADV_FREE:
 	case MADV_DONTNEED:
-		return madvise_dontneed_free(vma, prev, start, end, behavior);
+		return madvise_dontneed_free(vma, prev, start, end, behavior,
+					     mmrange);
 	default:
-		return madvise_behavior(vma, prev, start, end, behavior);
+		return madvise_behavior(vma, prev, start, end, behavior,
+					mmrange);
 	}
 }
 
@@ -797,7 +809,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	int write;
 	size_t len;
 	struct blk_plug plug;
-
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	if (!madvise_behavior_valid(behavior))
 		return error;
 
@@ -860,7 +872,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 			tmp = end;
 
 		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
-		error = madvise_vma(vma, &prev, start, tmp, behavior);
+		error = madvise_vma(vma, &prev, start, tmp, behavior, &mmrange);
 		if (error)
 			goto out;
 		start = tmp;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 88c1af32fd67..a7ac5a14b22e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4881,7 +4881,8 @@ static inline enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
 
 static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 					unsigned long addr, unsigned long end,
-					struct mm_walk *walk)
+					struct mm_walk *walk,
+					struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma = walk->vma;
 	pte_t *pte;
@@ -4915,6 +4916,7 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 {
 	unsigned long precharge;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	struct mm_walk mem_cgroup_count_precharge_walk = {
 		.pmd_entry = mem_cgroup_count_precharge_pte_range,
@@ -4922,7 +4924,7 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 	};
 	down_read(&mm->mmap_sem);
 	walk_page_range(0, mm->highest_vm_end,
-			&mem_cgroup_count_precharge_walk);
+			&mem_cgroup_count_precharge_walk, &mmrange);
 	up_read(&mm->mmap_sem);
 
 	precharge = mc.precharge;
@@ -5081,7 +5083,8 @@ static void mem_cgroup_cancel_attach(struct cgroup_taskset *tset)
 
 static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 				unsigned long addr, unsigned long end,
-				struct mm_walk *walk)
+				struct mm_walk *walk,
+				struct range_lock *mmrange)
 {
 	int ret = 0;
 	struct vm_area_struct *vma = walk->vma;
@@ -5197,6 +5200,7 @@ static void mem_cgroup_move_charge(void)
 		.pmd_entry = mem_cgroup_move_charge_pte_range,
 		.mm = mc.mm,
 	};
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	lru_add_drain_all();
 	/*
@@ -5223,7 +5227,8 @@ static void mem_cgroup_move_charge(void)
 	 * When we have consumed all precharges and failed in doing
 	 * additional charge, the page walk just aborts.
 	 */
-	walk_page_range(0, mc.mm->highest_vm_end, &mem_cgroup_move_charge_walk);
+	walk_page_range(0, mc.mm->highest_vm_end, &mem_cgroup_move_charge_walk,
+			&mmrange);
 
 	up_read(&mc.mm->mmap_sem);
 	atomic_dec(&mc.from->moving_account);
diff --git a/mm/memory.c b/mm/memory.c
index 5ec6433d6a5c..b3561a052939 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4021,7 +4021,7 @@ static int handle_pte_fault(struct vm_fault *vmf)
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags)
+			     unsigned int flags, struct range_lock *mmrange)
 {
 	struct vm_fault vmf = {
 		.vma = vma,
@@ -4029,6 +4029,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		.flags = flags,
 		.pgoff = linear_page_index(vma, address),
 		.gfp_mask = __get_fault_gfp_mask(vma),
+		.lockrange = mmrange,
 	};
 	unsigned int dirty = flags & FAULT_FLAG_WRITE;
 	struct mm_struct *mm = vma->vm_mm;
@@ -4110,7 +4111,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags)
+		    unsigned int flags, struct range_lock *mmrange)
 {
 	int ret;
 
@@ -4137,7 +4138,7 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
 	else
-		ret = __handle_mm_fault(vma, address, flags);
+		ret = __handle_mm_fault(vma, address, flags, mmrange);
 
 	if (flags & FAULT_FLAG_USER) {
 		mem_cgroup_oom_disable();
@@ -4425,6 +4426,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	void *old_buf = buf;
 	int write = gup_flags & FOLL_WRITE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	down_read(&mm->mmap_sem);
 	/* ignore errors, just check how much was successfully transferred */
@@ -4434,7 +4436,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		struct page *page = NULL;
 
 		ret = get_user_pages_remote(tsk, mm, addr, 1,
-				gup_flags, &page, &vma, NULL);
+					    gup_flags, &page, &vma, NULL, &mmrange);
 		if (ret <= 0) {
 #ifndef CONFIG_HAVE_IOREMAP_PROT
 			break;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index a8b7d59002e8..001dc176abc1 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -467,7 +467,8 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
  * and move them to the pagelist if they do.
  */
 static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
-			unsigned long end, struct mm_walk *walk)
+				 unsigned long end, struct mm_walk *walk,
+				 struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma = walk->vma;
 	struct page *page;
@@ -618,7 +619,7 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
 static int
 queue_pages_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 		nodemask_t *nodes, unsigned long flags,
-		struct list_head *pagelist)
+		struct list_head *pagelist, struct range_lock *mmrange)
 {
 	struct queue_pages qp = {
 		.pagelist = pagelist,
@@ -634,7 +635,7 @@ queue_pages_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 		.private = &qp,
 	};
 
-	return walk_page_range(start, end, &queue_pages_walk);
+	return walk_page_range(start, end, &queue_pages_walk, mmrange);
 }
 
 /*
@@ -675,7 +676,8 @@ static int vma_replace_policy(struct vm_area_struct *vma,
 
 /* Step 2: apply policy to a range and do splits. */
 static int mbind_range(struct mm_struct *mm, unsigned long start,
-		       unsigned long end, struct mempolicy *new_pol)
+		       unsigned long end, struct mempolicy *new_pol,
+		       struct range_lock *mmrange)
 {
 	struct vm_area_struct *next;
 	struct vm_area_struct *prev;
@@ -705,7 +707,7 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 			((vmstart - vma->vm_start) >> PAGE_SHIFT);
 		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
 				 vma->anon_vma, vma->vm_file, pgoff,
-				 new_pol, vma->vm_userfaultfd_ctx);
+				 new_pol, vma->vm_userfaultfd_ctx, mmrange);
 		if (prev) {
 			vma = prev;
 			next = vma->vm_next;
@@ -715,12 +717,12 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 			goto replace;
 		}
 		if (vma->vm_start != vmstart) {
-			err = split_vma(vma->vm_mm, vma, vmstart, 1);
+			err = split_vma(vma->vm_mm, vma, vmstart, 1, mmrange);
 			if (err)
 				goto out;
 		}
 		if (vma->vm_end != vmend) {
-			err = split_vma(vma->vm_mm, vma, vmend, 0);
+			err = split_vma(vma->vm_mm, vma, vmend, 0, mmrange);
 			if (err)
 				goto out;
 		}
@@ -797,12 +799,12 @@ static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
 	}
 }
 
-static int lookup_node(unsigned long addr)
+static int lookup_node(unsigned long addr, struct range_lock *mmrange)
 {
 	struct page *p;
 	int err;
 
-	err = get_user_pages(addr & PAGE_MASK, 1, 0, &p, NULL);
+	err = get_user_pages(addr & PAGE_MASK, 1, 0, &p, NULL, mmrange);
 	if (err >= 0) {
 		err = page_to_nid(p);
 		put_page(p);
@@ -818,6 +820,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma = NULL;
 	struct mempolicy *pol = current->mempolicy;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (flags &
 		~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
@@ -857,7 +860,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 
 	if (flags & MPOL_F_NODE) {
 		if (flags & MPOL_F_ADDR) {
-			err = lookup_node(addr);
+			err = lookup_node(addr, &mmrange);
 			if (err < 0)
 				goto out;
 			*policy = err;
@@ -943,7 +946,7 @@ struct page *alloc_new_node_page(struct page *page, unsigned long node)
  * Returns error or the number of pages not migrated.
  */
 static int migrate_to_node(struct mm_struct *mm, int source, int dest,
-			   int flags)
+			   int flags, struct range_lock *mmrange)
 {
 	nodemask_t nmask;
 	LIST_HEAD(pagelist);
@@ -959,7 +962,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 	 */
 	VM_BUG_ON(!(flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)));
 	queue_pages_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
-			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
+			  flags | MPOL_MF_DISCONTIG_OK, &pagelist, mmrange);
 
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, alloc_new_node_page, NULL, dest,
@@ -983,6 +986,7 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 	int busy = 0;
 	int err;
 	nodemask_t tmp;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	err = migrate_prep();
 	if (err)
@@ -1063,7 +1067,7 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 			break;
 
 		node_clear(source, tmp);
-		err = migrate_to_node(mm, source, dest, flags);
+		err = migrate_to_node(mm, source, dest, flags, &mmrange);
 		if (err > 0)
 			busy += err;
 		if (err < 0)
@@ -1143,6 +1147,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	unsigned long end;
 	int err;
 	LIST_HEAD(pagelist);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (flags & ~(unsigned long)MPOL_MF_VALID)
 		return -EINVAL;
@@ -1204,9 +1209,9 @@ static long do_mbind(unsigned long start, unsigned long len,
 		goto mpol_out;
 
 	err = queue_pages_range(mm, start, end, nmask,
-			  flags | MPOL_MF_INVERT, &pagelist);
+				flags | MPOL_MF_INVERT, &pagelist, &mmrange);
 	if (!err)
-		err = mbind_range(mm, start, end, new);
+		err = mbind_range(mm, start, end, new, &mmrange);
 
 	if (!err) {
 		int nr_failed = 0;
diff --git a/mm/migrate.c b/mm/migrate.c
index 5d0dc7b85f90..7a6afc34dd54 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2105,7 +2105,8 @@ struct migrate_vma {
 
 static int migrate_vma_collect_hole(unsigned long start,
 				    unsigned long end,
-				    struct mm_walk *walk)
+				    struct mm_walk *walk,
+				    struct range_lock *mmrange)
 {
 	struct migrate_vma *migrate = walk->private;
 	unsigned long addr;
@@ -2138,7 +2139,8 @@ static int migrate_vma_collect_skip(unsigned long start,
 static int migrate_vma_collect_pmd(pmd_t *pmdp,
 				   unsigned long start,
 				   unsigned long end,
-				   struct mm_walk *walk)
+				   struct mm_walk *walk,
+				   struct range_lock *mmrange)
 {
 	struct migrate_vma *migrate = walk->private;
 	struct vm_area_struct *vma = walk->vma;
@@ -2149,7 +2151,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 
 again:
 	if (pmd_none(*pmdp))
-		return migrate_vma_collect_hole(start, end, walk);
+		return migrate_vma_collect_hole(start, end, walk, mmrange);
 
 	if (pmd_trans_huge(*pmdp)) {
 		struct page *page;
@@ -2183,7 +2185,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 								walk);
 			if (pmd_none(*pmdp))
 				return migrate_vma_collect_hole(start, end,
-								walk);
+								walk, mmrange);
 		}
 	}
 
@@ -2309,7 +2311,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
  * valid page, it updates the src array and takes a reference on the page, in
  * order to pin the page until we lock it and unmap it.
  */
-static void migrate_vma_collect(struct migrate_vma *migrate)
+static void migrate_vma_collect(struct migrate_vma *migrate,
+				struct range_lock *mmrange)
 {
 	struct mm_walk mm_walk;
 
@@ -2325,7 +2328,7 @@ static void migrate_vma_collect(struct migrate_vma *migrate)
 	mmu_notifier_invalidate_range_start(mm_walk.mm,
 					    migrate->start,
 					    migrate->end);
-	walk_page_range(migrate->start, migrate->end, &mm_walk);
+	walk_page_range(migrate->start, migrate->end, &mm_walk, mmrange);
 	mmu_notifier_invalidate_range_end(mm_walk.mm,
 					  migrate->start,
 					  migrate->end);
@@ -2891,7 +2894,8 @@ int migrate_vma(const struct migrate_vma_ops *ops,
 		unsigned long end,
 		unsigned long *src,
 		unsigned long *dst,
-		void *private)
+		void *private,
+		struct range_lock *mmrange)
 {
 	struct migrate_vma migrate;
 
@@ -2917,7 +2921,7 @@ int migrate_vma(const struct migrate_vma_ops *ops,
 	migrate.vma = vma;
 
 	/* Collect, and try to unmap source pages */
-	migrate_vma_collect(&migrate);
+	migrate_vma_collect(&migrate, mmrange);
 	if (!migrate.cpages)
 		return 0;
 
diff --git a/mm/mincore.c b/mm/mincore.c
index fc37afe226e6..a6875a34aac0 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -85,7 +85,9 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 }
 
 static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
-				struct vm_area_struct *vma, unsigned char *vec)
+				    struct vm_area_struct *vma,
+				    unsigned char *vec,
+				    struct range_lock *mmrange)
 {
 	unsigned long nr = (end - addr) >> PAGE_SHIFT;
 	int i;
@@ -104,15 +106,17 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
 }
 
 static int mincore_unmapped_range(unsigned long addr, unsigned long end,
-				   struct mm_walk *walk)
+				  struct mm_walk *walk,
+				  struct range_lock *mmrange)
 {
 	walk->private += __mincore_unmapped_range(addr, end,
-						  walk->vma, walk->private);
+						  walk->vma,
+						  walk->private, mmrange);
 	return 0;
 }
 
 static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
-			struct mm_walk *walk)
+			     struct mm_walk *walk, struct range_lock *mmrange)
 {
 	spinlock_t *ptl;
 	struct vm_area_struct *vma = walk->vma;
@@ -128,7 +132,7 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	}
 
 	if (pmd_trans_unstable(pmd)) {
-		__mincore_unmapped_range(addr, end, vma, vec);
+		__mincore_unmapped_range(addr, end, vma, vec, mmrange);
 		goto out;
 	}
 
@@ -138,7 +142,7 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 
 		if (pte_none(pte))
 			__mincore_unmapped_range(addr, addr + PAGE_SIZE,
-						 vma, vec);
+						 vma, vec, mmrange);
 		else if (pte_present(pte))
 			*vec = 1;
 		else { /* pte is a swap entry */
@@ -174,7 +178,8 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
  * all the arguments, we hold the mmap semaphore: we should
  * just return the amount of info we're asked for.
  */
-static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *vec)
+static long do_mincore(unsigned long addr, unsigned long pages,
+		       unsigned char *vec, struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	unsigned long end;
@@ -191,7 +196,7 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 		return -ENOMEM;
 	mincore_walk.mm = vma->vm_mm;
 	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
-	err = walk_page_range(addr, end, &mincore_walk);
+	err = walk_page_range(addr, end, &mincore_walk, mmrange);
 	if (err < 0)
 		return err;
 	return (end - addr) >> PAGE_SHIFT;
@@ -227,6 +232,7 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 	long retval;
 	unsigned long pages;
 	unsigned char *tmp;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* Check the start address: needs to be page-aligned.. */
 	if (start & ~PAGE_MASK)
@@ -254,7 +260,7 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 		 * the temporary buffer size.
 		 */
 		down_read(&current->mm->mmap_sem);
-		retval = do_mincore(start, min(pages, PAGE_SIZE), tmp);
+		retval = do_mincore(start, min(pages, PAGE_SIZE), tmp, &mmrange);
 		up_read(&current->mm->mmap_sem);
 
 		if (retval <= 0)
diff --git a/mm/mlock.c b/mm/mlock.c
index 74e5a6547c3d..3f6bd953e8b0 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -517,7 +517,8 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
  * For vmas that pass the filters, merge/split as appropriate.
  */
 static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
-	unsigned long start, unsigned long end, vm_flags_t newflags)
+	unsigned long start, unsigned long end, vm_flags_t newflags,
+	struct range_lock *mmrange)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgoff_t pgoff;
@@ -534,20 +535,20 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
 			  vma->vm_file, pgoff, vma_policy(vma),
-			  vma->vm_userfaultfd_ctx);
+			  vma->vm_userfaultfd_ctx, mmrange);
 	if (*prev) {
 		vma = *prev;
 		goto success;
 	}
 
 	if (start != vma->vm_start) {
-		ret = split_vma(mm, vma, start, 1);
+		ret = split_vma(mm, vma, start, 1, mmrange);
 		if (ret)
 			goto out;
 	}
 
 	if (end != vma->vm_end) {
-		ret = split_vma(mm, vma, end, 0);
+		ret = split_vma(mm, vma, end, 0, mmrange);
 		if (ret)
 			goto out;
 	}
@@ -580,7 +581,7 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 }
 
 static int apply_vma_lock_flags(unsigned long start, size_t len,
-				vm_flags_t flags)
+				vm_flags_t flags, struct range_lock *mmrange)
 {
 	unsigned long nstart, end, tmp;
 	struct vm_area_struct * vma, * prev;
@@ -610,7 +611,7 @@ static int apply_vma_lock_flags(unsigned long start, size_t len,
 		tmp = vma->vm_end;
 		if (tmp > end)
 			tmp = end;
-		error = mlock_fixup(vma, &prev, nstart, tmp, newflags);
+		error = mlock_fixup(vma, &prev, nstart, tmp, newflags, mmrange);
 		if (error)
 			break;
 		nstart = tmp;
@@ -667,11 +668,13 @@ static int count_mm_mlocked_page_nr(struct mm_struct *mm,
 	return count >> PAGE_SHIFT;
 }
 
-static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t flags)
+static __must_check int do_mlock(unsigned long start, size_t len,
+				 vm_flags_t flags)
 {
 	unsigned long locked;
 	unsigned long lock_limit;
 	int error = -ENOMEM;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!can_do_mlock())
 		return -EPERM;
@@ -700,7 +703,7 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 
 	/* check against resource limits */
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
-		error = apply_vma_lock_flags(start, len, flags);
+		error = apply_vma_lock_flags(start, len, flags, &mmrange);
 
 	up_write(&current->mm->mmap_sem);
 	if (error)
@@ -733,13 +736,14 @@ SYSCALL_DEFINE3(mlock2, unsigned long, start, size_t, len, int, flags)
 SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 {
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	len = PAGE_ALIGN(len + (offset_in_page(start)));
 	start &= PAGE_MASK;
 
 	if (down_write_killable(&current->mm->mmap_sem))
 		return -EINTR;
-	ret = apply_vma_lock_flags(start, len, 0);
+	ret = apply_vma_lock_flags(start, len, 0, &mmrange);
 	up_write(&current->mm->mmap_sem);
 
 	return ret;
@@ -755,7 +759,7 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
  * is called once including the MCL_FUTURE flag and then a second time without
  * it, VM_LOCKED and VM_LOCKONFAULT will be cleared from mm->def_flags.
  */
-static int apply_mlockall_flags(int flags)
+static int apply_mlockall_flags(int flags, struct range_lock *mmrange)
 {
 	struct vm_area_struct * vma, * prev = NULL;
 	vm_flags_t to_add = 0;
@@ -784,7 +788,8 @@ static int apply_mlockall_flags(int flags)
 		newflags |= to_add;
 
 		/* Ignore errors */
-		mlock_fixup(vma, &prev, vma->vm_start, vma->vm_end, newflags);
+		mlock_fixup(vma, &prev, vma->vm_start, vma->vm_end, newflags,
+			mmrange);
 		cond_resched();
 	}
 out:
@@ -795,6 +800,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 {
 	unsigned long lock_limit;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT)))
 		return -EINVAL;
@@ -811,7 +817,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	ret = -ENOMEM;
 	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
 	    capable(CAP_IPC_LOCK))
-		ret = apply_mlockall_flags(flags);
+		ret = apply_mlockall_flags(flags, &mmrange);
 	up_write(&current->mm->mmap_sem);
 	if (!ret && (flags & MCL_CURRENT))
 		mm_populate(0, TASK_SIZE);
@@ -822,10 +828,11 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 SYSCALL_DEFINE0(munlockall)
 {
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (down_write_killable(&current->mm->mmap_sem))
 		return -EINTR;
-	ret = apply_mlockall_flags(0);
+	ret = apply_mlockall_flags(0, &mmrange);
 	up_write(&current->mm->mmap_sem);
 	return ret;
 }
diff --git a/mm/mmap.c b/mm/mmap.c
index 4bb038e7984b..f61d49cb791e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -177,7 +177,8 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	return next;
 }
 
-static int do_brk(unsigned long addr, unsigned long len, struct list_head *uf);
+static int do_brk(unsigned long addr, unsigned long len, struct list_head *uf,
+		  struct range_lock *mmrange);
 
 SYSCALL_DEFINE1(brk, unsigned long, brk)
 {
@@ -188,6 +189,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	unsigned long min_brk;
 	bool populate;
 	LIST_HEAD(uf);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
@@ -225,7 +227,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 
 	/* Always allow shrinking brk. */
 	if (brk <= mm->brk) {
-		if (!do_munmap(mm, newbrk, oldbrk-newbrk, &uf))
+		if (!do_munmap(mm, newbrk, oldbrk-newbrk, &uf, &mmrange))
 			goto set_brk;
 		goto out;
 	}
@@ -236,7 +238,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 		goto out;
 
 	/* Ok, looks good - let it rip. */
-	if (do_brk(oldbrk, newbrk-oldbrk, &uf) < 0)
+	if (do_brk(oldbrk, newbrk-oldbrk, &uf, &mmrange) < 0)
 		goto out;
 
 set_brk:
@@ -680,7 +682,7 @@ static inline void __vma_unlink_prev(struct mm_struct *mm,
  */
 int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert,
-	struct vm_area_struct *expand)
+	struct vm_area_struct *expand, struct range_lock *mmrange)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *next = vma->vm_next, *orig_vma = vma;
@@ -887,10 +889,10 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 		i_mmap_unlock_write(mapping);
 
 	if (root) {
-		uprobe_mmap(vma);
+		uprobe_mmap(vma, mmrange);
 
 		if (adjust_next)
-			uprobe_mmap(next);
+			uprobe_mmap(next, mmrange);
 	}
 
 	if (remove_next) {
@@ -960,7 +962,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 		}
 	}
 	if (insert && file)
-		uprobe_mmap(insert);
+		uprobe_mmap(insert, mmrange);
 
 	validate_mm(mm);
 
@@ -1101,7 +1103,8 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			unsigned long end, unsigned long vm_flags,
 			struct anon_vma *anon_vma, struct file *file,
 			pgoff_t pgoff, struct mempolicy *policy,
-			struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
+			struct vm_userfaultfd_ctx vm_userfaultfd_ctx,
+			struct range_lock *mmrange)
 {
 	pgoff_t pglen = (end - addr) >> PAGE_SHIFT;
 	struct vm_area_struct *area, *next;
@@ -1149,10 +1152,11 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 							/* cases 1, 6 */
 			err = __vma_adjust(prev, prev->vm_start,
 					 next->vm_end, prev->vm_pgoff, NULL,
-					 prev);
+					 prev, mmrange);
 		} else					/* cases 2, 5, 7 */
 			err = __vma_adjust(prev, prev->vm_start,
-					 end, prev->vm_pgoff, NULL, prev);
+					   end, prev->vm_pgoff, NULL,
+					   prev, mmrange);
 		if (err)
 			return NULL;
 		khugepaged_enter_vma_merge(prev, vm_flags);
@@ -1169,10 +1173,12 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 					     vm_userfaultfd_ctx)) {
 		if (prev && addr < prev->vm_end)	/* case 4 */
 			err = __vma_adjust(prev, prev->vm_start,
-					 addr, prev->vm_pgoff, NULL, next);
+					   addr, prev->vm_pgoff, NULL,
+					   next, mmrange);
 		else {					/* cases 3, 8 */
 			err = __vma_adjust(area, addr, next->vm_end,
-					 next->vm_pgoff - pglen, NULL, next);
+					   next->vm_pgoff - pglen, NULL,
+					   next, mmrange);
 			/*
 			 * In case 3 area is already equal to next and
 			 * this is a noop, but in case 8 "area" has
@@ -1322,7 +1328,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			unsigned long len, unsigned long prot,
 			unsigned long flags, vm_flags_t vm_flags,
 			unsigned long pgoff, unsigned long *populate,
-			struct list_head *uf)
+		        struct list_head *uf, struct range_lock *mmrange)
 {
 	struct mm_struct *mm = current->mm;
 	int pkey = 0;
@@ -1491,7 +1497,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			vm_flags |= VM_NORESERVE;
 	}
 
-	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf);
+	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf, mmrange);
 	if (!IS_ERR_VALUE(addr) &&
 	    ((vm_flags & VM_LOCKED) ||
 	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
@@ -1628,7 +1634,7 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 
 unsigned long mmap_region(struct file *file, unsigned long addr,
 		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
-		struct list_head *uf)
+		struct list_head *uf, struct range_lock *mmrange)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -1654,7 +1660,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	/* Clear old maps */
 	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link,
 			      &rb_parent)) {
-		if (do_munmap(mm, addr, len, uf))
+		if (do_munmap(mm, addr, len, uf, mmrange))
 			return -ENOMEM;
 	}
 
@@ -1672,7 +1678,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	 * Can we just expand an old mapping?
 	 */
 	vma = vma_merge(mm, prev, addr, addr + len, vm_flags,
-			NULL, file, pgoff, NULL, NULL_VM_UFFD_CTX);
+			NULL, file, pgoff, NULL, NULL_VM_UFFD_CTX, mmrange);
 	if (vma)
 		goto out;
 
@@ -1756,7 +1762,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	}
 
 	if (file)
-		uprobe_mmap(vma);
+		uprobe_mmap(vma, mmrange);
 
 	/*
 	 * New (or expanded) vma always get soft dirty status.
@@ -2435,7 +2441,8 @@ int expand_stack(struct vm_area_struct *vma, unsigned long address)
 }
 
 struct vm_area_struct *
-find_extend_vma(struct mm_struct *mm, unsigned long addr)
+find_extend_vma(struct mm_struct *mm, unsigned long addr,
+		struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma, *prev;
 
@@ -2446,7 +2453,8 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	if (!prev || expand_stack(prev, addr))
 		return NULL;
 	if (prev->vm_flags & VM_LOCKED)
-		populate_vma_page_range(prev, addr, prev->vm_end, NULL);
+		populate_vma_page_range(prev, addr, prev->vm_end,
+					NULL, mmrange);
 	return prev;
 }
 #else
@@ -2456,7 +2464,8 @@ int expand_stack(struct vm_area_struct *vma, unsigned long address)
 }
 
 struct vm_area_struct *
-find_extend_vma(struct mm_struct *mm, unsigned long addr)
+find_extend_vma(struct mm_struct *mm, unsigned long addr,
+		struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	unsigned long start;
@@ -2473,7 +2482,7 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	if (expand_stack(vma, addr))
 		return NULL;
 	if (vma->vm_flags & VM_LOCKED)
-		populate_vma_page_range(vma, addr, start, NULL);
+		populate_vma_page_range(vma, addr, start, NULL, mmrange);
 	return vma;
 }
 #endif
@@ -2561,7 +2570,7 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
  * has already been checked or doesn't make sense to fail.
  */
 int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long addr, int new_below)
+		unsigned long addr, int new_below, struct range_lock *mmrange)
 {
 	struct vm_area_struct *new;
 	int err;
@@ -2604,9 +2613,11 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (new_below)
 		err = vma_adjust(vma, addr, vma->vm_end, vma->vm_pgoff +
-			((addr - new->vm_start) >> PAGE_SHIFT), new);
+			  ((addr - new->vm_start) >> PAGE_SHIFT), new,
+			   mmrange);
 	else
-		err = vma_adjust(vma, vma->vm_start, addr, vma->vm_pgoff, new);
+		err = vma_adjust(vma, vma->vm_start, addr, vma->vm_pgoff, new,
+				 mmrange);
 
 	/* Success. */
 	if (!err)
@@ -2630,12 +2641,12 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
  * either for the first part or the tail.
  */
 int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
-	      unsigned long addr, int new_below)
+	      unsigned long addr, int new_below, struct range_lock *mmrange)
 {
 	if (mm->map_count >= sysctl_max_map_count)
 		return -ENOMEM;
 
-	return __split_vma(mm, vma, addr, new_below);
+	return __split_vma(mm, vma, addr, new_below, mmrange);
 }
 
 /* Munmap is split into 2 main parts -- this part which finds
@@ -2644,7 +2655,7 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
  * Jeremy Fitzhardinge <jeremy@goop.org>
  */
 int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
-	      struct list_head *uf)
+	      struct list_head *uf, struct range_lock *mmrange)
 {
 	unsigned long end;
 	struct vm_area_struct *vma, *prev, *last;
@@ -2686,7 +2697,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 		if (end < vma->vm_end && mm->map_count >= sysctl_max_map_count)
 			return -ENOMEM;
 
-		error = __split_vma(mm, vma, start, 0);
+		error = __split_vma(mm, vma, start, 0, mmrange);
 		if (error)
 			return error;
 		prev = vma;
@@ -2695,7 +2706,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	/* Does it split the last one? */
 	last = find_vma(mm, end);
 	if (last && end > last->vm_start) {
-		int error = __split_vma(mm, last, end, 1);
+		int error = __split_vma(mm, last, end, 1, mmrange);
 		if (error)
 			return error;
 	}
@@ -2736,7 +2747,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	detach_vmas_to_be_unmapped(mm, vma, prev, end);
 	unmap_region(mm, vma, prev, start, end);
 
-	arch_unmap(mm, vma, start, end);
+	arch_unmap(mm, vma, start, end, mmrange);
 
 	/* Fix up all other VM information */
 	remove_vma_list(mm, vma);
@@ -2749,11 +2760,12 @@ int vm_munmap(unsigned long start, size_t len)
 	int ret;
 	struct mm_struct *mm = current->mm;
 	LIST_HEAD(uf);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
-	ret = do_munmap(mm, start, len, &uf);
+	ret = do_munmap(mm, start, len, &uf, &mmrange);
 	up_write(&mm->mmap_sem);
 	userfaultfd_unmap_complete(mm, &uf);
 	return ret;
@@ -2779,6 +2791,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	unsigned long populate = 0;
 	unsigned long ret = -EINVAL;
 	struct file *file;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	pr_warn_once("%s (%d) uses deprecated remap_file_pages() syscall. See Documentation/vm/remap_file_pages.txt.\n",
 		     current->comm, current->pid);
@@ -2855,7 +2868,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 
 	file = get_file(vma->vm_file);
 	ret = do_mmap_pgoff(vma->vm_file, start, size,
-			prot, flags, pgoff, &populate, NULL);
+			    prot, flags, pgoff, &populate, NULL, &mmrange);
 	fput(file);
 out:
 	up_write(&mm->mmap_sem);
@@ -2881,7 +2894,9 @@ static inline void verify_mm_writelocked(struct mm_struct *mm)
  *  anonymous maps.  eventually we may be able to do some
  *  brk-specific accounting here.
  */
-static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long flags, struct list_head *uf)
+static int do_brk_flags(unsigned long addr, unsigned long request,
+			unsigned long flags, struct list_head *uf,
+			struct range_lock *mmrange)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -2920,7 +2935,7 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 	 */
 	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link,
 			      &rb_parent)) {
-		if (do_munmap(mm, addr, len, uf))
+		if (do_munmap(mm, addr, len, uf, mmrange))
 			return -ENOMEM;
 	}
 
@@ -2936,7 +2951,7 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 
 	/* Can we just expand an old private anonymous mapping? */
 	vma = vma_merge(mm, prev, addr, addr + len, flags,
-			NULL, NULL, pgoff, NULL, NULL_VM_UFFD_CTX);
+			NULL, NULL, pgoff, NULL, NULL_VM_UFFD_CTX, mmrange);
 	if (vma)
 		goto out;
 
@@ -2967,9 +2982,10 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 	return 0;
 }
 
-static int do_brk(unsigned long addr, unsigned long len, struct list_head *uf)
+static int do_brk(unsigned long addr, unsigned long len, struct list_head *uf,
+		  struct range_lock *mmrange)
 {
-	return do_brk_flags(addr, len, 0, uf);
+	return do_brk_flags(addr, len, 0, uf, mmrange);
 }
 
 int vm_brk_flags(unsigned long addr, unsigned long len, unsigned long flags)
@@ -2978,11 +2994,12 @@ int vm_brk_flags(unsigned long addr, unsigned long len, unsigned long flags)
 	int ret;
 	bool populate;
 	LIST_HEAD(uf);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
-	ret = do_brk_flags(addr, len, flags, &uf);
+	ret = do_brk_flags(addr, len, flags, &uf, &mmrange);
 	populate = ((mm->def_flags & VM_LOCKED) != 0);
 	up_write(&mm->mmap_sem);
 	userfaultfd_unmap_complete(mm, &uf);
@@ -3105,7 +3122,7 @@ int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
  */
 struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 	unsigned long addr, unsigned long len, pgoff_t pgoff,
-	bool *need_rmap_locks)
+	bool *need_rmap_locks, struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma = *vmap;
 	unsigned long vma_start = vma->vm_start;
@@ -3127,7 +3144,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		return NULL;	/* should never get here */
 	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
 			    vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
-			    vma->vm_userfaultfd_ctx);
+			    vma->vm_userfaultfd_ctx, mmrange);
 	if (new_vma) {
 		/*
 		 * Source vma may have been merged into new_vma
diff --git a/mm/mprotect.c b/mm/mprotect.c
index e3309fcf586b..b84a70720319 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -299,7 +299,8 @@ unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 
 int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
-	unsigned long start, unsigned long end, unsigned long newflags)
+	       unsigned long start, unsigned long end, unsigned long newflags,
+	       struct range_lock *mmrange)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long oldflags = vma->vm_flags;
@@ -340,7 +341,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*pprev = vma_merge(mm, *pprev, start, end, newflags,
 			   vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
-			   vma->vm_userfaultfd_ctx);
+			   vma->vm_userfaultfd_ctx, mmrange);
 	if (*pprev) {
 		vma = *pprev;
 		VM_WARN_ON((vma->vm_flags ^ newflags) & ~VM_SOFTDIRTY);
@@ -350,13 +351,13 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	*pprev = vma;
 
 	if (start != vma->vm_start) {
-		error = split_vma(mm, vma, start, 1);
+		error = split_vma(mm, vma, start, 1, mmrange);
 		if (error)
 			goto fail;
 	}
 
 	if (end != vma->vm_end) {
-		error = split_vma(mm, vma, end, 0);
+		error = split_vma(mm, vma, end, 0, mmrange);
 		if (error)
 			goto fail;
 	}
@@ -379,7 +380,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 */
 	if ((oldflags & (VM_WRITE | VM_SHARED | VM_LOCKED)) == VM_LOCKED &&
 			(newflags & VM_WRITE)) {
-		populate_vma_page_range(vma, start, end, NULL);
+		populate_vma_page_range(vma, start, end, NULL, mmrange);
 	}
 
 	vm_stat_account(mm, oldflags, -nrpages);
@@ -404,6 +405,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 	const int grows = prot & (PROT_GROWSDOWN|PROT_GROWSUP);
 	const bool rier = (current->personality & READ_IMPLIES_EXEC) &&
 				(prot & PROT_READ);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	prot &= ~(PROT_GROWSDOWN|PROT_GROWSUP);
 	if (grows == (PROT_GROWSDOWN|PROT_GROWSUP)) /* can't be both */
@@ -494,7 +496,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 		tmp = vma->vm_end;
 		if (tmp > end)
 			tmp = end;
-		error = mprotect_fixup(vma, &prev, nstart, tmp, newflags);
+		error = mprotect_fixup(vma, &prev, nstart, tmp, newflags, &mmrange);
 		if (error)
 			goto out;
 		nstart = tmp;
diff --git a/mm/mremap.c b/mm/mremap.c
index 049470aa1e3e..21a9e2a2baa2 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -264,7 +264,8 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		unsigned long old_addr, unsigned long old_len,
 		unsigned long new_len, unsigned long new_addr,
 		bool *locked, struct vm_userfaultfd_ctx *uf,
-		struct list_head *uf_unmap)
+		struct list_head *uf_unmap,
+		struct range_lock *mmrange)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *new_vma;
@@ -292,13 +293,13 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	 * so KSM can come around to merge on vma and new_vma afterwards.
 	 */
 	err = ksm_madvise(vma, old_addr, old_addr + old_len,
-						MADV_UNMERGEABLE, &vm_flags);
+			  MADV_UNMERGEABLE, &vm_flags, mmrange);
 	if (err)
 		return err;
 
 	new_pgoff = vma->vm_pgoff + ((old_addr - vma->vm_start) >> PAGE_SHIFT);
 	new_vma = copy_vma(&vma, new_addr, new_len, new_pgoff,
-			   &need_rmap_locks);
+			   &need_rmap_locks, mmrange);
 	if (!new_vma)
 		return -ENOMEM;
 
@@ -353,7 +354,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	if (unlikely(vma->vm_flags & VM_PFNMAP))
 		untrack_pfn_moved(vma);
 
-	if (do_munmap(mm, old_addr, old_len, uf_unmap) < 0) {
+	if (do_munmap(mm, old_addr, old_len, uf_unmap, mmrange) < 0) {
 		/* OOM: unable to split vma, just get accounts right */
 		vm_unacct_memory(excess >> PAGE_SHIFT);
 		excess = 0;
@@ -444,7 +445,8 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 		unsigned long new_addr, unsigned long new_len, bool *locked,
 		struct vm_userfaultfd_ctx *uf,
 		struct list_head *uf_unmap_early,
-		struct list_head *uf_unmap)
+		struct list_head *uf_unmap,
+		struct range_lock *mmrange)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
@@ -462,12 +464,13 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (addr + old_len > new_addr && new_addr + new_len > addr)
 		goto out;
 
-	ret = do_munmap(mm, new_addr, new_len, uf_unmap_early);
+	ret = do_munmap(mm, new_addr, new_len, uf_unmap_early, mmrange);
 	if (ret)
 		goto out;
 
 	if (old_len >= new_len) {
-		ret = do_munmap(mm, addr+new_len, old_len - new_len, uf_unmap);
+		ret = do_munmap(mm, addr+new_len, old_len - new_len,
+				uf_unmap, mmrange);
 		if (ret && old_len != new_len)
 			goto out;
 		old_len = new_len;
@@ -490,7 +493,7 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 		goto out1;
 
 	ret = move_vma(vma, addr, old_len, new_len, new_addr, locked, uf,
-		       uf_unmap);
+		       uf_unmap, mmrange);
 	if (!(offset_in_page(ret)))
 		goto out;
 out1:
@@ -532,6 +535,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	struct vm_userfaultfd_ctx uf = NULL_VM_UFFD_CTX;
 	LIST_HEAD(uf_unmap_early);
 	LIST_HEAD(uf_unmap);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
 		return ret;
@@ -558,7 +562,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 
 	if (flags & MREMAP_FIXED) {
 		ret = mremap_to(addr, old_len, new_addr, new_len,
-				&locked, &uf, &uf_unmap_early, &uf_unmap);
+				&locked, &uf, &uf_unmap_early,
+				&uf_unmap, &mmrange);
 		goto out;
 	}
 
@@ -568,7 +573,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	 * do_munmap does all the needed commit accounting
 	 */
 	if (old_len >= new_len) {
-		ret = do_munmap(mm, addr+new_len, old_len - new_len, &uf_unmap);
+		ret = do_munmap(mm, addr+new_len, old_len - new_len,
+				&uf_unmap, &mmrange);
 		if (ret && old_len != new_len)
 			goto out;
 		ret = addr;
@@ -592,7 +598,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 			int pages = (new_len - old_len) >> PAGE_SHIFT;
 
 			if (vma_adjust(vma, vma->vm_start, addr + new_len,
-				       vma->vm_pgoff, NULL)) {
+				       vma->vm_pgoff, NULL, &mmrange)) {
 				ret = -ENOMEM;
 				goto out;
 			}
@@ -628,7 +634,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		}
 
 		ret = move_vma(vma, addr, old_len, new_len, new_addr,
-			       &locked, &uf, &uf_unmap);
+			       &locked, &uf, &uf_unmap, &mmrange);
 	}
 out:
 	if (offset_in_page(ret)) {
diff --git a/mm/nommu.c b/mm/nommu.c
index ebb6e618dade..1805f0a788b3 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -113,7 +113,8 @@ unsigned int kobjsize(const void *objp)
 static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		      unsigned long start, unsigned long nr_pages,
 		      unsigned int foll_flags, struct page **pages,
-		      struct vm_area_struct **vmas, int *nonblocking)
+		      struct vm_area_struct **vmas, int *nonblocking,
+		      struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	unsigned long vm_flags;
@@ -162,18 +163,19 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
  */
 long get_user_pages(unsigned long start, unsigned long nr_pages,
 		    unsigned int gup_flags, struct page **pages,
-		    struct vm_area_struct **vmas)
+		    struct vm_area_struct **vmas,
+		    struct range_lock *mmrange)
 {
 	return __get_user_pages(current, current->mm, start, nr_pages,
-				gup_flags, pages, vmas, NULL);
+				gup_flags, pages, vmas, NULL, mmrange);
 }
 EXPORT_SYMBOL(get_user_pages);
 
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
-			    int *locked)
+			    int *locked, struct range_lock *mmrange)
 {
-	return get_user_pages(start, nr_pages, gup_flags, pages, NULL);
+	return get_user_pages(start, nr_pages, gup_flags, pages, NULL, mmrange);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
@@ -183,9 +185,11 @@ static long __get_user_pages_unlocked(struct task_struct *tsk,
 			unsigned int gup_flags)
 {
 	long ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
+
 	down_read(&mm->mmap_sem);
 	ret = __get_user_pages(tsk, mm, start, nr_pages, gup_flags, pages,
-				NULL, NULL);
+			       NULL, NULL, &mmrange);
 	up_read(&mm->mmap_sem);
 	return ret;
 }
@@ -836,7 +840,8 @@ EXPORT_SYMBOL(find_vma);
  * find a VMA
  * - we don't extend stack VMAs under NOMMU conditions
  */
-struct vm_area_struct *find_extend_vma(struct mm_struct *mm, unsigned long addr)
+struct vm_area_struct *find_extend_vma(struct mm_struct *mm, unsigned long addr,
+				       struct range_lock *mmrange)
 {
 	return find_vma(mm, addr);
 }
@@ -1206,7 +1211,8 @@ unsigned long do_mmap(struct file *file,
 			vm_flags_t vm_flags,
 			unsigned long pgoff,
 			unsigned long *populate,
-			struct list_head *uf)
+			struct list_head *uf,
+			struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	struct vm_region *region;
@@ -1476,7 +1482,7 @@ SYSCALL_DEFINE1(old_mmap, struct mmap_arg_struct __user *, arg)
  * for the first part or the tail.
  */
 int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
-	      unsigned long addr, int new_below)
+	      unsigned long addr, int new_below, struct range_lock *mmrange)
 {
 	struct vm_area_struct *new;
 	struct vm_region *region;
@@ -1578,7 +1584,8 @@ static int shrink_vma(struct mm_struct *mm,
  * - under NOMMU conditions the chunk to be unmapped must be backed by a single
  *   VMA, though it need not cover the whole VMA
  */
-int do_munmap(struct mm_struct *mm, unsigned long start, size_t len, struct list_head *uf)
+int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
+	      struct list_head *uf, struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	unsigned long end;
@@ -1624,7 +1631,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len, struct list
 		if (end != vma->vm_end && offset_in_page(end))
 			return -EINVAL;
 		if (start != vma->vm_start && end != vma->vm_end) {
-			ret = split_vma(mm, vma, start, 1);
+			ret = split_vma(mm, vma, start, 1, mmrange);
 			if (ret < 0)
 				return ret;
 		}
@@ -1642,9 +1649,10 @@ int vm_munmap(unsigned long addr, size_t len)
 {
 	struct mm_struct *mm = current->mm;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	down_write(&mm->mmap_sem);
-	ret = do_munmap(mm, addr, len, NULL);
+	ret = do_munmap(mm, addr, len, NULL, &mmrange);
 	up_write(&mm->mmap_sem);
 	return ret;
 }
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 8d2da5dec1e0..44a2507c94fd 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -26,7 +26,7 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 }
 
 static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
-			  struct mm_walk *walk)
+			  struct mm_walk *walk, struct range_lock *mmrange)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -38,7 +38,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 		next = pmd_addr_end(addr, end);
 		if (pmd_none(*pmd) || !walk->vma) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, walk, mmrange);
 			if (err)
 				break;
 			continue;
@@ -48,7 +48,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 		 * needs to know about pmd_trans_huge() pmds
 		 */
 		if (walk->pmd_entry)
-			err = walk->pmd_entry(pmd, addr, next, walk);
+			err = walk->pmd_entry(pmd, addr, next, walk, mmrange);
 		if (err)
 			break;
 
@@ -71,7 +71,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 }
 
 static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
-			  struct mm_walk *walk)
+			  struct mm_walk *walk, struct range_lock *mmrange)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -83,7 +83,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 		next = pud_addr_end(addr, end);
 		if (pud_none(*pud) || !walk->vma) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, walk, mmrange);
 			if (err)
 				break;
 			continue;
@@ -106,7 +106,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 			goto again;
 
 		if (walk->pmd_entry || walk->pte_entry)
-			err = walk_pmd_range(pud, addr, next, walk);
+			err = walk_pmd_range(pud, addr, next, walk, mmrange);
 		if (err)
 			break;
 	} while (pud++, addr = next, addr != end);
@@ -115,7 +115,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 }
 
 static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
-			  struct mm_walk *walk)
+			  struct mm_walk *walk, struct range_lock *mmrange)
 {
 	p4d_t *p4d;
 	unsigned long next;
@@ -126,13 +126,13 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 		next = p4d_addr_end(addr, end);
 		if (p4d_none_or_clear_bad(p4d)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, walk, mmrange);
 			if (err)
 				break;
 			continue;
 		}
 		if (walk->pmd_entry || walk->pte_entry)
-			err = walk_pud_range(p4d, addr, next, walk);
+			err = walk_pud_range(p4d, addr, next, walk, mmrange);
 		if (err)
 			break;
 	} while (p4d++, addr = next, addr != end);
@@ -141,7 +141,7 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 }
 
 static int walk_pgd_range(unsigned long addr, unsigned long end,
-			  struct mm_walk *walk)
+			  struct mm_walk *walk, struct range_lock *mmrange)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -152,13 +152,13 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, walk, mmrange);
 			if (err)
 				break;
 			continue;
 		}
 		if (walk->pmd_entry || walk->pte_entry)
-			err = walk_p4d_range(pgd, addr, next, walk);
+			err = walk_p4d_range(pgd, addr, next, walk, mmrange);
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
@@ -175,7 +175,7 @@ static unsigned long hugetlb_entry_end(struct hstate *h, unsigned long addr,
 }
 
 static int walk_hugetlb_range(unsigned long addr, unsigned long end,
-			      struct mm_walk *walk)
+			      struct mm_walk *walk, struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma = walk->vma;
 	struct hstate *h = hstate_vma(vma);
@@ -192,7 +192,7 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 		if (pte)
 			err = walk->hugetlb_entry(pte, hmask, addr, next, walk);
 		else if (walk->pte_hole)
-			err = walk->pte_hole(addr, next, walk);
+			err = walk->pte_hole(addr, next, walk, mmrange);
 
 		if (err)
 			break;
@@ -203,7 +203,7 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 
 #else /* CONFIG_HUGETLB_PAGE */
 static int walk_hugetlb_range(unsigned long addr, unsigned long end,
-			      struct mm_walk *walk)
+			      struct mm_walk *walk, struct range_lock *mmrange)
 {
 	return 0;
 }
@@ -217,7 +217,7 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
  * error, where we abort the current walk.
  */
 static int walk_page_test(unsigned long start, unsigned long end,
-			struct mm_walk *walk)
+			  struct mm_walk *walk, struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma = walk->vma;
 
@@ -235,23 +235,23 @@ static int walk_page_test(unsigned long start, unsigned long end,
 	if (vma->vm_flags & VM_PFNMAP) {
 		int err = 1;
 		if (walk->pte_hole)
-			err = walk->pte_hole(start, end, walk);
+			err = walk->pte_hole(start, end, walk, mmrange);
 		return err ? err : 1;
 	}
 	return 0;
 }
 
 static int __walk_page_range(unsigned long start, unsigned long end,
-			struct mm_walk *walk)
+			     struct mm_walk *walk, struct range_lock *mmrange)
 {
 	int err = 0;
 	struct vm_area_struct *vma = walk->vma;
 
 	if (vma && is_vm_hugetlb_page(vma)) {
 		if (walk->hugetlb_entry)
-			err = walk_hugetlb_range(start, end, walk);
+			err = walk_hugetlb_range(start, end, walk, mmrange);
 	} else
-		err = walk_pgd_range(start, end, walk);
+		err = walk_pgd_range(start, end, walk, mmrange);
 
 	return err;
 }
@@ -285,10 +285,11 @@ static int __walk_page_range(unsigned long start, unsigned long end,
  * Locking:
  *   Callers of walk_page_range() and walk_page_vma() should hold
  *   @walk->mm->mmap_sem, because these function traverse vma list and/or
- *   access to vma's data.
+ *   access to vma's data. As such, the @mmrange will represent the
+ *   address space range.
  */
 int walk_page_range(unsigned long start, unsigned long end,
-		    struct mm_walk *walk)
+		    struct mm_walk *walk, struct range_lock *mmrange)
 {
 	int err = 0;
 	unsigned long next;
@@ -315,7 +316,7 @@ int walk_page_range(unsigned long start, unsigned long end,
 			next = min(end, vma->vm_end);
 			vma = vma->vm_next;
 
-			err = walk_page_test(start, next, walk);
+			err = walk_page_test(start, next, walk, mmrange);
 			if (err > 0) {
 				/*
 				 * positive return values are purely for
@@ -329,14 +330,15 @@ int walk_page_range(unsigned long start, unsigned long end,
 				break;
 		}
 		if (walk->vma || walk->pte_hole)
-			err = __walk_page_range(start, next, walk);
+			err = __walk_page_range(start, next, walk, mmrange);
 		if (err)
 			break;
 	} while (start = next, start < end);
 	return err;
 }
 
-int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk)
+int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk,
+		  struct range_lock *mmrange)
 {
 	int err;
 
@@ -346,10 +348,10 @@ int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk)
 	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem));
 	VM_BUG_ON(!vma);
 	walk->vma = vma;
-	err = walk_page_test(vma->vm_start, vma->vm_end, walk);
+	err = walk_page_test(vma->vm_start, vma->vm_end, walk, mmrange);
 	if (err > 0)
 		return 0;
 	if (err < 0)
 		return err;
-	return __walk_page_range(vma->vm_start, vma->vm_end, walk);
+	return __walk_page_range(vma->vm_start, vma->vm_end, walk, mmrange);
 }
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index a447092d4635..ff6772b86195 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -90,6 +90,7 @@ static int process_vm_rw_single_vec(unsigned long addr,
 	unsigned long max_pages_per_loop = PVM_MAX_KMALLOC_PAGES
 		/ sizeof(struct pages *);
 	unsigned int flags = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* Work out address and page range required */
 	if (len == 0)
@@ -111,7 +112,8 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		 */
 		down_read(&mm->mmap_sem);
 		pages = get_user_pages_remote(task, mm, pa, pages, flags,
-					      process_pages, NULL, &locked);
+					      process_pages, NULL, &locked,
+					      &mmrange);
 		if (locked)
 			up_read(&mm->mmap_sem);
 		if (pages <= 0)
diff --git a/mm/util.c b/mm/util.c
index c1250501364f..b0ec1d88bb71 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -347,13 +347,14 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	struct mm_struct *mm = current->mm;
 	unsigned long populate;
 	LIST_HEAD(uf);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	ret = security_mmap_file(file, prot, flag);
 	if (!ret) {
 		if (down_write_killable(&mm->mmap_sem))
 			return -EINTR;
 		ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
-				    &populate, &uf);
+				    &populate, &uf, &mmrange);
 		up_write(&mm->mmap_sem);
 		userfaultfd_unmap_complete(mm, &uf);
 		if (populate)
diff --git a/security/tomoyo/domain.c b/security/tomoyo/domain.c
index f6758dad981f..c1e36ea2c6fc 100644
--- a/security/tomoyo/domain.c
+++ b/security/tomoyo/domain.c
@@ -868,6 +868,7 @@ bool tomoyo_dump_page(struct linux_binprm *bprm, unsigned long pos,
 		      struct tomoyo_page_dump *dump)
 {
 	struct page *page;
+	DEFINE_RANGE_LOCK_FULL(mmrange); /* see get_page_arg() in fs/exec.c */
 
 	/* dump->data is released by tomoyo_find_next_domain(). */
 	if (!dump->data) {
@@ -884,7 +885,7 @@ bool tomoyo_dump_page(struct linux_binprm *bprm, unsigned long pos,
 	 * the execve().
 	 */
 	if (get_user_pages_remote(current, bprm->mm, pos, 1,
-				FOLL_FORCE, &page, NULL, NULL) <= 0)
+				  FOLL_FORCE, &page, NULL, NULL, &mmrange) <= 0)
 		return false;
 #else
 	page = bprm->page[pos / PAGE_SIZE];
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index 57bcb27dcf30..4cd2b93bb20c 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -78,6 +78,7 @@ static void async_pf_execute(struct work_struct *work)
 	unsigned long addr = apf->addr;
 	gva_t gva = apf->gva;
 	int locked = 1;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	might_sleep();
 
@@ -88,7 +89,7 @@ static void async_pf_execute(struct work_struct *work)
 	 */
 	down_read(&mm->mmap_sem);
 	get_user_pages_remote(NULL, mm, addr, 1, FOLL_WRITE, NULL, NULL,
-			&locked);
+			      &locked, &mmrange);
 	if (locked)
 		up_read(&mm->mmap_sem);
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 4501e658e8d6..86ec078f4c3b 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1317,11 +1317,12 @@ unsigned long kvm_vcpu_gfn_to_hva_prot(struct kvm_vcpu *vcpu, gfn_t gfn, bool *w
 	return gfn_to_hva_memslot_prot(slot, gfn, writable);
 }
 
-static inline int check_user_page_hwpoison(unsigned long addr)
+static inline int check_user_page_hwpoison(unsigned long addr,
+					   struct range_lock *mmrange)
 {
 	int rc, flags = FOLL_HWPOISON | FOLL_WRITE;
 
-	rc = get_user_pages(addr, 1, flags, NULL, NULL);
+	rc = get_user_pages(addr, 1, flags, NULL, NULL, mmrange);
 	return rc == -EHWPOISON;
 }
 
@@ -1411,7 +1412,8 @@ static bool vma_is_valid(struct vm_area_struct *vma, bool write_fault)
 static int hva_to_pfn_remapped(struct vm_area_struct *vma,
 			       unsigned long addr, bool *async,
 			       bool write_fault, bool *writable,
-			       kvm_pfn_t *p_pfn)
+			       kvm_pfn_t *p_pfn,
+			       struct range_lock *mmrange)
 {
 	unsigned long pfn;
 	int r;
@@ -1425,7 +1427,7 @@ static int hva_to_pfn_remapped(struct vm_area_struct *vma,
 		bool unlocked = false;
 		r = fixup_user_fault(current, current->mm, addr,
 				     (write_fault ? FAULT_FLAG_WRITE : 0),
-				     &unlocked);
+				     &unlocked, mmrange);
 		if (unlocked)
 			return -EAGAIN;
 		if (r)
@@ -1477,6 +1479,7 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 	struct vm_area_struct *vma;
 	kvm_pfn_t pfn = 0;
 	int npages, r;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* we can do it either atomically or asynchronously, not both */
 	BUG_ON(atomic && async);
@@ -1493,7 +1496,7 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 
 	down_read(&current->mm->mmap_sem);
 	if (npages == -EHWPOISON ||
-	      (!async && check_user_page_hwpoison(addr))) {
+	    (!async && check_user_page_hwpoison(addr, &mmrange))) {
 		pfn = KVM_PFN_ERR_HWPOISON;
 		goto exit;
 	}
@@ -1504,7 +1507,8 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 	if (vma == NULL)
 		pfn = KVM_PFN_ERR_FAULT;
 	else if (vma->vm_flags & (VM_IO | VM_PFNMAP)) {
-		r = hva_to_pfn_remapped(vma, addr, async, write_fault, writable, &pfn);
+		r = hva_to_pfn_remapped(vma, addr, async, write_fault, writable,
+					&pfn, &mmrange);
 		if (r == -EAGAIN)
 			goto retry;
 		if (r < 0)
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
