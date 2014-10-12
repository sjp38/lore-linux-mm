Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id EDB30900017
	for <linux-mm@kvack.org>; Sun, 12 Oct 2014 00:51:59 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id eu11so4060286pac.35
        for <linux-mm@kvack.org>; Sat, 11 Oct 2014 21:51:59 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ov9si7510017pdb.7.2014.10.11.21.51.55
        for <linux-mm@kvack.org>;
        Sat, 11 Oct 2014 21:51:55 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v9 10/12] x86, mpx: add prctl commands PR_MPX_ENABLE_MANAGEMENT, PR_MPX_DISABLE_MANAGEMENT
Date: Sun, 12 Oct 2014 12:41:53 +0800
Message-Id: <1413088915-13428-11-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, Qiaowei Ren <qiaowei.ren@intel.com>

This patch adds two prctl() commands to provide one explicit interaction
mechanism to enable or disable the management of bounds tables in kernel,
including on-demand kernel allocation (See the patch "on-demand kernel
allocation of bounds tables") and cleanup (See the patch "cleanup unused
bound tables"). Applications do not strictly need the kernel to manage
bounds tables and we expect some applications to use MPX without taking
advantage of the kernel support. This means the kernel can not simply
infer whether an application needs bounds table management from the
MPX registers. prctl() is an explicit signal from userspace.

PR_MPX_ENABLE_MANAGEMENT is meant to be a signal from userspace to
require kernel's help in managing bounds tables. And
PR_MPX_DISABLE_MANAGEMENT is the opposite, meaning that userspace don't
want kernel's help any more. With PR_MPX_DISABLE_MANAGEMENT, kernel
won't allocate and free the bounds table, even if the CPU supports MPX
feature.

PR_MPX_ENABLE_MANAGEMENT will do an xsave and fetch the base address
of bounds directory from the xsave buffer and then cache it into new
filed "bd_addr" of struct mm_struct. PR_MPX_DISABLE_MANAGEMENT will
set "bd_addr" to one invalid address. Then we can check "bd_addr" to
judge whether the management of bounds tables in kernel is enabled.

xsaves are expensive, so "bd_addr" is kept for caching to reduce the
number of we have to do at munmap() time. But we still have to do
xsave to get the value of BNDSTATUS at #BR fault time. In addition,
with this caching, userspace can't just move the bounds directory
around willy-nilly. For sane applications, base address of the bounds
directory won't be changed, otherwise we would be in a world of hurt.
But we will still check whether it is changed by users at #BR fault
time.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
---
 arch/x86/include/asm/mmu_context.h |    9 ++++
 arch/x86/include/asm/mpx.h         |   11 +++++
 arch/x86/include/asm/processor.h   |   18 +++++++
 arch/x86/kernel/mpx.c              |   88 ++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/setup.c            |    8 +++
 arch/x86/kernel/traps.c            |   30 ++++++++++++-
 arch/x86/mm/mpx.c                  |   25 +++-------
 fs/exec.c                          |    2 +
 include/asm-generic/mmu_context.h  |    5 ++
 include/linux/mm_types.h           |    3 +
 include/uapi/linux/prctl.h         |    6 +++
 kernel/sys.c                       |   12 +++++
 12 files changed, 198 insertions(+), 19 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 166af2a..e33ddb7 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -10,6 +10,7 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 #include <asm/paravirt.h>
+#include <asm/mpx.h>
 #ifndef CONFIG_PARAVIRT
 #include <asm-generic/mm_hooks.h>
 
@@ -102,4 +103,12 @@ do {						\
 } while (0)
 #endif
 
+static inline void arch_bprm_mm_init(struct mm_struct *mm,
+		struct vm_area_struct *vma)
+{
+#ifdef CONFIG_X86_INTEL_MPX
+	mm->bd_addr = MPX_INVALID_BOUNDS_DIR;
+#endif
+}
+
 #endif /* _ASM_X86_MMU_CONTEXT_H */
diff --git a/arch/x86/include/asm/mpx.h b/arch/x86/include/asm/mpx.h
index 780af63..32f13f5 100644
--- a/arch/x86/include/asm/mpx.h
+++ b/arch/x86/include/asm/mpx.h
@@ -5,6 +5,12 @@
 #include <asm/ptrace.h>
 #include <asm/insn.h>
 
+/*
+ * NULL is theoretically a valid place to put the bounds
+ * directory, so point this at an invalid address.
+ */
+#define MPX_INVALID_BOUNDS_DIR ((void __user *)-1)
+
 #ifdef CONFIG_X86_64
 
 /* upper 28 bits [47:20] of the virtual address in 64-bit used to
@@ -43,6 +49,7 @@
 #define MPX_BT_SIZE_BYTES (1UL<<(MPX_BT_ENTRY_OFFSET+MPX_BT_ENTRY_SHIFT))
 
 #define MPX_BNDSTA_ERROR_CODE	0x3
+#define MPX_BNDCFG_ENABLE_FLAG	0x1
 #define MPX_BD_ENTRY_VALID_FLAG	0x1
 
 struct mpx_insn {
@@ -61,6 +68,10 @@ struct mpx_insn {
 
 #define MAX_MPX_INSN_SIZE	15
 
+static inline int kernel_managing_mpx_tables(struct mm_struct *mm)
+{
+	return (mm->bd_addr != MPX_INVALID_BOUNDS_DIR);
+}
 unsigned long mpx_mmap(unsigned long len);
 
 #ifdef CONFIG_X86_INTEL_MPX
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 020142f..b35aefa 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -953,6 +953,24 @@ extern void start_thread(struct pt_regs *regs, unsigned long new_ip,
 extern int get_tsc_mode(unsigned long adr);
 extern int set_tsc_mode(unsigned int val);
 
+/* Register/unregister a process' MPX related resource */
+#define MPX_ENABLE_MANAGEMENT(tsk)	mpx_enable_management((tsk))
+#define MPX_DISABLE_MANAGEMENT(tsk)	mpx_disable_management((tsk))
+
+#ifdef CONFIG_X86_INTEL_MPX
+extern int mpx_enable_management(struct task_struct *tsk);
+extern int mpx_disable_management(struct task_struct *tsk);
+#else
+static inline int mpx_enable_management(struct task_struct *tsk)
+{
+	return -EINVAL;
+}
+static inline int mpx_disable_management(struct task_struct *tsk)
+{
+	return -EINVAL;
+}
+#endif /* CONFIG_X86_INTEL_MPX */
+
 extern u16 amd_get_nb_id(int cpu);
 
 static inline uint32_t hypervisor_cpuid_base(const char *sig, uint32_t leaves)
diff --git a/arch/x86/kernel/mpx.c b/arch/x86/kernel/mpx.c
index b7e4c0e..36df3a5 100644
--- a/arch/x86/kernel/mpx.c
+++ b/arch/x86/kernel/mpx.c
@@ -8,7 +8,78 @@
 
 #include <linux/kernel.h>
 #include <linux/syscalls.h>
+#include <linux/prctl.h>
 #include <asm/mpx.h>
+#include <asm/i387.h>
+#include <asm/fpu-internal.h>
+
+static __user void *task_get_bounds_dir(struct task_struct *tsk)
+{
+	struct xsave_struct *xsave_buf;
+
+	if (!cpu_feature_enabled(X86_FEATURE_MPX))
+		return MPX_INVALID_BOUNDS_DIR;
+
+	/*
+	 * The bounds directory pointer is stored in a register
+	 * only accessible if we first do an xsave.
+	 */
+	fpu_xsave(&tsk->thread.fpu);
+	xsave_buf = &(tsk->thread.fpu.state->xsave);
+
+	/*
+	 * Make sure the register looks valid by checking the
+	 * enable bit.
+	 */
+	if (!(xsave_buf->bndcsr.bndcfgu & MPX_BNDCFG_ENABLE_FLAG))
+		return MPX_INVALID_BOUNDS_DIR;
+
+	/*
+	 * Lastly, mask off the low bits used for configuration
+	 * flags, and return the address of the bounds table.
+	 */
+	return (void __user *)(unsigned long)
+		(xsave_buf->bndcsr.bndcfgu & MPX_BNDCFG_ADDR_MASK);
+}
+
+int mpx_enable_management(struct task_struct *tsk)
+{
+	struct mm_struct *mm = tsk->mm;
+	void __user *bd_base = MPX_INVALID_BOUNDS_DIR;
+	int ret = 0;
+
+	/*
+	 * runtime in the userspace will be responsible for allocation of
+	 * the bounds directory. Then, it will save the base of the bounds
+	 * directory into XSAVE/XRSTOR Save Area and enable MPX through
+	 * XRSTOR instruction.
+	 *
+	 * fpu_xsave() is expected to be very expensive. Storing the bounds
+	 * directory here means that we do not have to do xsave in the unmap
+	 * path; we can just use mm->bd_addr instead.
+	 */
+	bd_base = task_get_bounds_dir(tsk);
+	down_write(&mm->mmap_sem);
+	mm->bd_addr = bd_base;
+	if (mm->bd_addr == MPX_INVALID_BOUNDS_DIR)
+		ret = -ENXIO;
+
+	up_write(&mm->mmap_sem);
+	return ret;
+}
+
+int mpx_disable_management(struct task_struct *tsk)
+{
+	struct mm_struct *mm = current->mm;
+
+	if (!cpu_feature_enabled(X86_FEATURE_MPX))
+		return -ENXIO;
+
+	down_write(&mm->mmap_sem);
+	mm->bd_addr = MPX_INVALID_BOUNDS_DIR;
+	up_write(&mm->mmap_sem);
+	return 0;
+}
 
 enum reg_type {
 	REG_TYPE_RM = 0,
@@ -283,6 +354,9 @@ static unsigned long mpx_insn_decode(struct mpx_insn *insn,
  * With 32-bit mode, MPX_BT_SIZE_BYTES is 4MB, and the size of each
  * bounds table is 16KB. With 64-bit mode, MPX_BT_SIZE_BYTES is 2GB,
  * and the size of each bounds table is 4MB.
+ *
+ * This function will be called holding mmap_sem for write. And it
+ * will downgrade this write lock to read lock.
  */
 static int allocate_bt(long __user *bd_entry)
 {
@@ -304,6 +378,11 @@ static int allocate_bt(long __user *bd_entry)
 	bt_addr = bt_addr | MPX_BD_ENTRY_VALID_FLAG;
 
 	/*
+	 * Access to the bounds directory possibly fault, so we
+	 * need to downgrade write lock to read lock.
+	 */
+	downgrade_write(&current->mm->mmap_sem);
+	/*
 	 * Go poke the address of the new bounds table in to the
 	 * bounds directory entry out in userspace memory.  Note:
 	 * we may race with another CPU instantiating the same table.
@@ -351,6 +430,15 @@ int do_mpx_bt_fault(struct xsave_struct *xsave_buf)
 	unsigned long bd_entry, bd_base;
 
 	bd_base = xsave_buf->bndcsr.bndcfgu & MPX_BNDCFG_ADDR_MASK;
+
+	/*
+	 * Make sure the bounds directory being pointed to by the
+	 * configuration register agrees with the place userspace
+	 * told us it was going to be. Otherwise, this -EINVAL return
+	 * will cause a one SIGSEGV.
+	 */
+	if (bd_base != (unsigned long)current->mm->bd_addr)
+		return -EINVAL;
 	status = xsave_buf->bndcsr.bndstatus;
 
 	/*
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 41ead8d..8a58c98 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -110,6 +110,7 @@
 #include <asm/mce.h>
 #include <asm/alternative.h>
 #include <asm/prom.h>
+#include <asm/mpx.h>
 
 /*
  * max_low_pfn_mapped: highest direct mapped pfn under 4GB
@@ -950,6 +951,13 @@ void __init setup_arch(char **cmdline_p)
 	init_mm.end_code = (unsigned long) _etext;
 	init_mm.end_data = (unsigned long) _edata;
 	init_mm.brk = _brk_end;
+#ifdef CONFIG_X86_INTEL_MPX
+	/*
+	 * NULL is theoretically a valid place to put the bounds
+	 * directory, so point this at an invalid address.
+	 */
+	init_mm.bd_addr = MPX_INVALID_BOUNDS_DIR;
+#endif
 
 	code_resource.start = __pa_symbol(_text);
 	code_resource.end = __pa_symbol(_etext)-1;
diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
index b2a916b..5e5b299 100644
--- a/arch/x86/kernel/traps.c
+++ b/arch/x86/kernel/traps.c
@@ -285,6 +285,7 @@ dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
 	struct xsave_struct *xsave_buf;
 	struct task_struct *tsk = current;
 	siginfo_t info;
+	int ret = 0;
 
 	prev_state = exception_enter();
 	if (notify_die(DIE_TRAP, "bounds", regs, error_code,
@@ -312,8 +313,35 @@ dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
 	 */
 	switch (status & MPX_BNDSTA_ERROR_CODE) {
 	case 2: /* Bound directory has invalid entry. */
-		if (do_mpx_bt_fault(xsave_buf))
+		down_write(&current->mm->mmap_sem);
+		/*
+		 * Userspace never asked us to manage the bounds tables,
+		 * so refuse to help.
+		 */
+		if (!kernel_managing_mpx_tables(current->mm)) {
+			do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs,
+					error_code, NULL);
+			up_write(&current->mm->mmap_sem);
+			goto exit;
+		}
+
+		ret = do_mpx_bt_fault(xsave_buf);
+		if (!ret || ret == -EFAULT) {
+			/*
+			 * Successfully handle bounds table fault, or the
+			 * cmpxchg which updates bounds directory entry
+			 * fails.
+			 *
+			 * For this case, write lock has been downgraded
+			 * to read lock in allocate_bt() called by
+			 * do_mpx_bt_fault().
+			 */
+			up_read(&current->mm->mmap_sem);
+			goto exit;
+		}
+		if (ret)
 			force_sig(SIGSEGV, tsk);
+		up_write(&current->mm->mmap_sem);
 		break;
 
 	case 1: /* Bound violation. */
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index e1b28e6..376f2ee 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -33,22 +33,16 @@ unsigned long mpx_mmap(unsigned long len)
 	if (len != MPX_BD_SIZE_BYTES && len != MPX_BT_SIZE_BYTES)
 		return -EINVAL;
 
-	down_write(&mm->mmap_sem);
-
 	/* Too many mappings? */
-	if (mm->map_count > sysctl_max_map_count) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (mm->map_count > sysctl_max_map_count)
+		return -ENOMEM;
 
 	/* Obtain the address to map to. we verify (or select) it and ensure
 	 * that it represents a valid section of the address space.
 	 */
 	addr = get_unmapped_area(NULL, 0, len, 0, MAP_ANONYMOUS | MAP_PRIVATE);
-	if (addr & ~PAGE_MASK) {
-		ret = addr;
-		goto out;
-	}
+	if (addr & ~PAGE_MASK)
+		return addr;
 
 	vm_flags = VM_READ | VM_WRITE | VM_MPX |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
@@ -58,22 +52,17 @@ unsigned long mpx_mmap(unsigned long len)
 
 	ret = mmap_region(NULL, addr, len, vm_flags, pgoff);
 	if (IS_ERR_VALUE(ret))
-		goto out;
+		return ret;
 
 	vma = find_vma(mm, ret);
-	if (!vma) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!vma)
+		return -ENOMEM;
 	vma->vm_ops = &mpx_vma_ops;
 
 	if (vm_flags & VM_LOCKED) {
 		up_write(&mm->mmap_sem);
 		mm_populate(ret, len);
-		return ret;
 	}
 
-out:
-	up_write(&mm->mmap_sem);
 	return ret;
 }
diff --git a/fs/exec.c b/fs/exec.c
index a2b42a9..16d1606 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -60,6 +60,7 @@
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
 #include <asm/tlb.h>
+#include <asm/mpx.h>
 
 #include <trace/events/task.h>
 #include "internal.h"
@@ -277,6 +278,7 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 		goto err;
 
 	mm->stack_vm = mm->total_vm = 1;
+	arch_bprm_mm_init(mm, vma);
 	up_write(&mm->mmap_sem);
 	bprm->p = vma->vm_end - sizeof(void *);
 	return 0;
diff --git a/include/asm-generic/mmu_context.h b/include/asm-generic/mmu_context.h
index a7eec91..1f2a8f9 100644
--- a/include/asm-generic/mmu_context.h
+++ b/include/asm-generic/mmu_context.h
@@ -42,4 +42,9 @@ static inline void activate_mm(struct mm_struct *prev_mm,
 {
 }
 
+static inline void arch_bprm_mm_init(struct mm_struct *mm,
+			struct vm_area_struct *vma)
+{
+}
+
 #endif /* __ASM_GENERIC_MMU_CONTEXT_H */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 6e0b286..760aee3 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -454,6 +454,9 @@ struct mm_struct {
 	bool tlb_flush_pending;
 #endif
 	struct uprobes_state uprobes_state;
+#ifdef CONFIG_X86_INTEL_MPX
+	void __user *bd_addr;		/* address of the bounds directory */
+#endif
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index 58afc04..b7a8cf4 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -152,4 +152,10 @@
 #define PR_SET_THP_DISABLE	41
 #define PR_GET_THP_DISABLE	42
 
+/*
+ * Tell the kernel to start/stop helping userspace manage bounds tables.
+ */
+#define PR_MPX_ENABLE_MANAGEMENT  43
+#define PR_MPX_DISABLE_MANAGEMENT 44
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/sys.c b/kernel/sys.c
index b663664..4713585 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -91,6 +91,12 @@
 #ifndef SET_TSC_CTL
 # define SET_TSC_CTL(a)		(-EINVAL)
 #endif
+#ifndef MPX_ENABLE_MANAGEMENT
+# define MPX_ENABLE_MANAGEMENT(a)	(-EINVAL)
+#endif
+#ifndef MPX_DISABLE_MANAGEMENT
+# define MPX_DISABLE_MANAGEMENT(a)	(-EINVAL)
+#endif
 
 /*
  * this is where the system-wide overflow UID and GID are defined, for
@@ -2009,6 +2015,12 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 			me->mm->def_flags &= ~VM_NOHUGEPAGE;
 		up_write(&me->mm->mmap_sem);
 		break;
+	case PR_MPX_ENABLE_MANAGEMENT:
+		error = MPX_ENABLE_MANAGEMENT(me);
+		break;
+	case PR_MPX_DISABLE_MANAGEMENT:
+		error = MPX_DISABLE_MANAGEMENT(me);
+		break;
 	default:
 		error = -EINVAL;
 		break;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
