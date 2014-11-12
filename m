Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2C88B6B00E7
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 12:05:18 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so13304666pad.15
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 09:05:17 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id lp1si23400638pab.57.2014.11.12.09.05.14
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 09:05:15 -0800 (PST)
Subject: [PATCH 09/11] x86, mpx: on-demand kernel allocation of bounds tables
From: Dave Hansen <dave@sr71.net>
Date: Wed, 12 Nov 2014 09:05:10 -0800
References: <20141112170443.B4BD0899@viggo.jf.intel.com>
In-Reply-To: <20141112170443.B4BD0899@viggo.jf.intel.com>
Message-Id: <20141112170510.3D07BA53@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Thomas, I know you're not a huge fan of using mm->mmap_sem for serializing
this stuff.  But, now that we are not adding an additional lock a la
mm->bd_sem, I can't quite justify adding another lock and trying to
reconcile the interactions and ording with mmap_sem.

We are only adding two spots where we acquire mmap_sem and did not. All of
the other "use" is in places where it is held already.  Those two points
of new use are *tiny* and can easily be replaced in the future.

--

This is really the meat of the MPX patch set.  If there is one patch to
review in the entire series, this is the one.  There is a new ABI here
and this kernel code also interacts with userspace memory in a
relatively unusual manner.  (small FAQ below).

Long Description:

This patch adds two prctl() commands to provide enable or disable the
management of bounds tables in kernel, including on-demand kernel
allocation (See the patch "on-demand kernel allocation of bounds tables")
and cleanup (See the patch "cleanup unused bound tables"). Applications
do not strictly need the kernel to manage bounds tables and we expect
some applications to use MPX without taking advantage of this kernel
support. This means the kernel can not simply infer whether an application
needs bounds table management from the MPX registers.  The prctl() is an
explicit signal from userspace.

PR_MPX_ENABLE_MANAGEMENT is meant to be a signal from userspace to
require kernel's help in managing bounds tables.

PR_MPX_DISABLE_MANAGEMENT is the opposite, meaning that userspace don't
want kernel's help any more. With PR_MPX_DISABLE_MANAGEMENT, the kernel
won't allocate and free bounds tables even if the CPU supports MPX.

PR_MPX_ENABLE_MANAGEMENT will fetch the base address of the bounds
directory out of a userspace register (bndcfgu) and then cache it into
a new field (->bd_addr) in  the 'mm_struct'.  PR_MPX_DISABLE_MANAGEMENT
will set "bd_addr" to an invalid address.  Using this scheme, we can
use "bd_addr" to determine whether the management of bounds tables in
kernel is enabled.

Also, the only way to access that bndcfgu register is via an xsaves,
which can be expensive.  Caching "bd_addr" like this also helps reduce
the cost of those xsaves when doing table cleanup at munmap() time.
Unfortunately, we can not apply this optimization to #BR fault time
because we need an xsave to get the value of BNDSTATUS.

==== Why does the hardware even have these Bounds Tables? ====

MPX only has 4 hardware registers for storing bounds information.
If MPX-enabled code needs more than these 4 registers, it needs to
spill them somewhere. It has two special instructions for this
which allow the bounds to be moved between the bounds registers
and some new "bounds tables".

They are similar conceptually to a page fault and will be raised by
the MPX hardware during both bounds violations or when the tables
are not present. This patch handles those #BR exceptions for
not-present tables by carving the space out of the normal processes
address space (essentially calling the new mmap() interface indroduced
earlier in this patch set.) and then pointing the bounds-directory
over to it.

The tables *need* to be accessed and controlled by userspace because
the instructions for moving bounds in and out of them are extremely
frequent. They potentially happen every time a register pointing to
memory is dereferenced. Any direct kernel involvement (like a syscall)
to access the tables would obviously destroy performance.

==== Why not do this in userspace? ====

This patch is obviously doing this allocation in the kernel.
However, MPX does not strictly *require* anything in the kernel.
It can theoretically be done completely from userspace. Here are
a few ways this *could* be done. I don't think any of them are
practical in the real-world, but here they are.

Q: Can virtual space simply be reserved for the bounds tables so
   that we never have to allocate them?
A: As noted earlier, these tables are *HUGE*. An X-GB virtual
   area needs 4*X GB of virtual space, plus 2GB for the bounds
   directory. If we were to preallocate them for the 128TB of
   user virtual address space, we would need to reserve 512TB+2GB,
   which is larger than the entire virtual address space today.
   This means they can not be reserved ahead of time. Also, a
   single process's pre-popualated bounds directory consumes 2GB
   of virtual *AND* physical memory. IOW, it's completely
   infeasible to prepopulate bounds directories.

Q: Can we preallocate bounds table space at the same time memory
   is allocated which might contain pointers that might eventually
   need bounds tables?
A: This would work if we could hook the site of each and every
   memory allocation syscall. This can be done for small,
   constrained applications. But, it isn't practical at a larger
   scale since a given app has no way of controlling how all the
   parts of the app might allocate memory (think libraries). The
   kernel is really the only place to intercept these calls.

Q: Could a bounds fault be handed to userspace and the tables
   allocated there in a signal handler instead of in the kernel?
A: (thanks to tglx) mmap() is not on the list of safe async
   handler functions and even if mmap() would work it still
   requires locking or nasty tricks to keep track of the
   allocation state there.

Having ruled out all of the userspace-only approaches for managing
bounds tables that we could think of, we create them on demand in
the kernel.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/include/asm/mmu_context.h |    9 +
 b/arch/x86/include/asm/mpx.h         |   30 ++++
 b/arch/x86/include/asm/processor.h   |   18 ++
 b/arch/x86/kernel/mpx.c              |    1 
 b/arch/x86/kernel/setup.c            |    7 +
 b/arch/x86/kernel/traps.c            |   79 ++++++++++++
 b/arch/x86/mm/mpx.c                  |  224 ++++++++++++++++++++++++++++++++++-
 b/fs/exec.c                          |    2 
 b/include/asm-generic/mmu_context.h  |    5 
 b/include/linux/mm_types.h           |    3 
 b/include/uapi/linux/prctl.h         |    6 
 b/kernel/sys.c                       |   12 +
 12 files changed, 392 insertions(+), 4 deletions(-)

diff -puN arch/x86/include/asm/mmu_context.h~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables	2014-11-12 08:49:26.473915530 -0800
+++ b/arch/x86/include/asm/mmu_context.h	2014-11-12 08:49:26.493916432 -0800
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
diff -puN arch/x86/include/asm/mpx.h~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables arch/x86/include/asm/mpx.h
--- a/arch/x86/include/asm/mpx.h~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables	2014-11-12 08:49:26.474915575 -0800
+++ b/arch/x86/include/asm/mpx.h	2014-11-12 08:49:26.493916432 -0800
@@ -5,6 +5,14 @@
 #include <asm/ptrace.h>
 #include <asm/insn.h>
 
+/*
+ * NULL is theoretically a valid place to put the bounds
+ * directory, so point this at an invalid address.
+ */
+#define MPX_INVALID_BOUNDS_DIR ((void __user *)-1)
+#define MPX_BNDCFG_ENABLE_FLAG 0x1
+#define MPX_BD_ENTRY_VALID_FLAG        0x1
+
 #ifdef CONFIG_X86_64
 
 /* upper 28 bits [47:20] of the virtual address in 64-bit used to
@@ -18,6 +26,7 @@
 #define MPX_BT_ENTRY_OFFSET	17
 #define MPX_BT_ENTRY_SHIFT	5
 #define MPX_IGN_BITS		3
+#define MPX_BD_ENTRY_TAIL	3
 
 #else
 
@@ -26,23 +35,44 @@
 #define MPX_BT_ENTRY_OFFSET	10
 #define MPX_BT_ENTRY_SHIFT	4
 #define MPX_IGN_BITS		2
+#define MPX_BD_ENTRY_TAIL	2
 
 #endif
 
 #define MPX_BD_SIZE_BYTES (1UL<<(MPX_BD_ENTRY_OFFSET+MPX_BD_ENTRY_SHIFT))
 #define MPX_BT_SIZE_BYTES (1UL<<(MPX_BT_ENTRY_OFFSET+MPX_BT_ENTRY_SHIFT))
 
+#define MPX_BNDSTA_TAIL                2
+#define MPX_BNDCFG_TAIL                12
+#define MPX_BNDSTA_ADDR_MASK   (~((1UL<<MPX_BNDSTA_TAIL)-1))
+#define MPX_BNDCFG_ADDR_MASK   (~((1UL<<MPX_BNDCFG_TAIL)-1))
+#define MPX_BT_ADDR_MASK       (~((1UL<<MPX_BD_ENTRY_TAIL)-1))
+
+#define MPX_BNDCFG_ADDR_MASK	(~((1UL<<MPX_BNDCFG_TAIL)-1))
 #define MPX_BNDSTA_ERROR_CODE	0x3
 
 #ifdef CONFIG_X86_INTEL_MPX
 siginfo_t *mpx_generate_siginfo(struct pt_regs *regs,
 				struct xsave_struct *xsave_buf);
+int mpx_handle_bd_fault(struct xsave_struct *xsave_buf);
+static inline int kernel_managing_mpx_tables(struct mm_struct *mm)
+{
+	return (mm->bd_addr != MPX_INVALID_BOUNDS_DIR);
+}
 #else
 static inline siginfo_t *mpx_generate_siginfo(struct pt_regs *regs,
 					      struct xsave_struct *xsave_buf)
 {
 	return NULL;
 }
+static inline int mpx_handle_bd_fault(struct xsave_struct *xsave_buf)
+{
+	return -EINVAL;
+}
+static inline int kernel_managing_mpx_tables(struct mm_struct *mm)
+{
+	return 0;
+}
 #endif /* CONFIG_X86_INTEL_MPX */
 
 #endif /* _ASM_X86_MPX_H */
diff -puN arch/x86/include/asm/processor.h~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables arch/x86/include/asm/processor.h
--- a/arch/x86/include/asm/processor.h~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables	2014-11-12 08:49:26.476915665 -0800
+++ b/arch/x86/include/asm/processor.h	2014-11-12 08:49:26.494916477 -0800
@@ -954,6 +954,24 @@ extern void start_thread(struct pt_regs
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
diff -puN /dev/null arch/x86/kernel/mpx.c
--- /dev/null	2014-10-10 16:10:57.316716958 -0700
+++ b/arch/x86/kernel/mpx.c	2014-11-12 08:49:26.494916477 -0800
@@ -0,0 +1 @@
+
diff -puN arch/x86/kernel/setup.c~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables arch/x86/kernel/setup.c
--- a/arch/x86/kernel/setup.c~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables	2014-11-12 08:49:26.478915755 -0800
+++ b/arch/x86/kernel/setup.c	2014-11-12 08:49:26.494916477 -0800
@@ -959,6 +959,13 @@ void __init setup_arch(char **cmdline_p)
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
diff -puN arch/x86/kernel/traps.c~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables arch/x86/kernel/traps.c
--- a/arch/x86/kernel/traps.c~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables	2014-11-12 08:49:26.479915800 -0800
+++ b/arch/x86/kernel/traps.c	2014-11-12 08:49:26.495916522 -0800
@@ -60,6 +60,7 @@
 #include <asm/fixmap.h>
 #include <asm/mach_traps.h>
 #include <asm/alternative.h>
+#include <asm/mpx.h>
 
 #ifdef CONFIG_X86_64
 #include <asm/x86_init.h>
@@ -228,7 +229,6 @@ dotraplinkage void do_##name(struct pt_r
 
 DO_ERROR(X86_TRAP_DE,     SIGFPE,  "divide error",		divide_error)
 DO_ERROR(X86_TRAP_OF,     SIGSEGV, "overflow",			overflow)
-DO_ERROR(X86_TRAP_BR,     SIGSEGV, "bounds",			bounds)
 DO_ERROR(X86_TRAP_UD,     SIGILL,  "invalid opcode",		invalid_op)
 DO_ERROR(X86_TRAP_OLD_MF, SIGFPE,  "coprocessor segment overrun",coprocessor_segment_overrun)
 DO_ERROR(X86_TRAP_TS,     SIGSEGV, "invalid TSS",		invalid_TSS)
@@ -278,6 +278,83 @@ dotraplinkage void do_double_fault(struc
 }
 #endif
 
+dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
+{
+	enum ctx_state prev_state;
+	struct bndcsr *bndcsr;
+	struct xsave_struct *xsave_buf;
+	struct task_struct *tsk = current;
+	siginfo_t *info;
+
+	prev_state = exception_enter();
+	if (notify_die(DIE_TRAP, "bounds", regs, error_code,
+			X86_TRAP_BR, SIGSEGV) == NOTIFY_STOP)
+		goto exit;
+	conditional_sti(regs);
+
+	if (!user_mode(regs))
+		die("bounds", regs, error_code);
+
+	if (!cpu_feature_enabled(X86_FEATURE_MPX)) {
+		/* The exception is not from Intel MPX */
+		goto exit_trap;
+	}
+
+	fpu_save_init(&tsk->thread.fpu);
+	xsave_buf = &(tsk->thread.fpu.state->xsave);
+	bndcsr = get_xsave_addr(xsave_buf, XSTATE_BNDCSR);
+	if (!bndcsr)
+		goto exit_trap;
+
+	/*
+	 * The error code field of the BNDSTATUS register communicates status
+	 * information of a bound range exception #BR or operation involving
+	 * bound directory.
+	 */
+	switch (bndcsr->bndstatus & MPX_BNDSTA_ERROR_CODE) {
+	case 2:	/* Bound directory has invalid entry. */
+		if (mpx_handle_bd_fault(xsave_buf))
+			goto exit_trap;
+		break; /* Success, it was handled */
+	case 1: /* Bound violation. */
+		info = mpx_generate_siginfo(regs, xsave_buf);
+		if (PTR_ERR(info)) {
+			/*
+			 * We failed to decode the MPX instruction.  Act as if
+			 * the exception was not caused by MPX.
+			 */
+			goto exit_trap;
+		}
+		/*
+		 * Success, we decoded the instruction and retrieved
+		 * an 'info' containing the address being accessed
+		 * which caused the exception.  This information
+		 * allows and application to possibly handle the
+		 * #BR exception itself.
+		 */
+		do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs, error_code, info);
+		kfree(info);
+		break;
+	case 0: /* No exception caused by Intel MPX operations. */
+		goto exit_trap;
+	default:
+		die("bounds", regs, error_code);
+	}
+
+exit:
+	exception_exit(prev_state);
+exit_trap:
+	/*
+	 * This path out is for all the cases where we could not
+	 * handle the exception in some way (like allocating a
+	 * table or telling userspace about it.  We will also end
+	 * up here if the kernel has MPX turned off at compile
+	 * time..
+	 */
+	do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs, error_code, NULL);
+	exception_exit(prev_state);
+}
+
 dotraplinkage void
 do_general_protection(struct pt_regs *regs, long error_code)
 {
diff -puN arch/x86/mm/mpx.c~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables arch/x86/mm/mpx.c
--- a/arch/x86/mm/mpx.c~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables	2014-11-12 08:49:26.481915891 -0800
+++ b/arch/x86/mm/mpx.c	2014-11-12 08:49:26.495916522 -0800
@@ -10,8 +10,13 @@
 #include <linux/syscalls.h>
 #include <linux/sched/sysctl.h>
 
+#include <asm/i387.h>
+#include <asm/insn.h>
 #include <asm/mman.h>
 #include <asm/mpx.h>
+#include <asm/processor.h>
+#include <asm/xsave.h>
+#include <asm/fpu-internal.h>
 
 static const char *mpx_mapping_name(struct vm_area_struct *vma)
 {
@@ -268,8 +273,9 @@ siginfo_t *mpx_generate_siginfo(struct p
 {
 	struct insn insn;
 	uint8_t bndregno;
+	struct bndreg *bndregs;
 	int err;
-	siginfo_t *info;
+	siginfo_t *info = NULL;
 
 	err = mpx_insn_decode(&insn, regs);
 	if (err)
@@ -285,6 +291,11 @@ siginfo_t *mpx_generate_siginfo(struct p
 		err = -EINVAL;
 		goto err_out;
 	}
+	bndregs = get_xsave_addr(xsave_buf, XSTATE_BNDREGS);
+	if (!bndregs) {
+		err = -EINVAL;
+		goto err_out;
+	}
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
 	if (!info) {
 		err = -ENOMEM;
@@ -301,9 +312,9 @@ siginfo_t *mpx_generate_siginfo(struct p
 	 * pointers.
 	 */
 	info->si_lower = (void __user *)(unsigned long)
-		(xsave_buf->bndreg[bndregno].lower_bound);
+		(bndregs[bndregno].lower_bound);
 	info->si_upper = (void __user *)(unsigned long)
-		(~xsave_buf->bndreg[bndregno].upper_bound);
+		(~bndregs[bndregno].upper_bound);
 	info->si_addr_lsb = 0;
 	info->si_signo = SIGSEGV;
 	info->si_errno = 0;
@@ -319,5 +330,212 @@ siginfo_t *mpx_generate_siginfo(struct p
 	}
 	return info;
 err_out:
+	/* info might be NULL, but kfree() handles that */
+	kfree(info);
 	return ERR_PTR(err);
 }
+
+static __user void *task_get_bounds_dir(struct task_struct *tsk)
+{
+	struct bndcsr *bndcsr;
+
+	if (!cpu_feature_enabled(X86_FEATURE_MPX))
+		return MPX_INVALID_BOUNDS_DIR;
+
+	/*
+	 * The bounds directory pointer is stored in a register
+	 * only accessible if we first do an xsave.
+	 */
+	fpu_save_init(&tsk->thread.fpu);
+	bndcsr = get_xsave_addr(&tsk->thread.fpu.state->xsave, XSTATE_BNDCSR);
+	if (!bndcsr)
+		return MPX_INVALID_BOUNDS_DIR;
+
+	/*
+	 * Make sure the register looks valid by checking the
+	 * enable bit.
+	 */
+	if (!(bndcsr->bndcfgu & MPX_BNDCFG_ENABLE_FLAG))
+		return MPX_INVALID_BOUNDS_DIR;
+
+	/*
+	 * Lastly, mask off the low bits used for configuration
+	 * flags, and return the address of the bounds table.
+	 */
+	return (void __user *)(unsigned long)
+		(bndcsr->bndcfgu & MPX_BNDCFG_ADDR_MASK);
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
+
+/*
+ * With 32-bit mode, MPX_BT_SIZE_BYTES is 4MB, and the size of each
+ * bounds table is 16KB. With 64-bit mode, MPX_BT_SIZE_BYTES is 2GB,
+ * and the size of each bounds table is 4MB.
+ */
+static int allocate_bt(long __user *bd_entry)
+{
+	unsigned long bt_addr;
+	unsigned long expected_old_val = 0;
+	unsigned long actual_old_val = 0;
+	int ret = 0;
+
+	/*
+	 * Carve the virtual space out of userspace for the new
+	 * bounds table:
+	 */
+	bt_addr = mpx_mmap(MPX_BT_SIZE_BYTES);
+	if (IS_ERR((void *)bt_addr))
+		return PTR_ERR((void *)bt_addr);
+	/*
+	 * Set the valid flag (kinda like _PAGE_PRESENT in a pte)
+	 */
+	bt_addr = bt_addr | MPX_BD_ENTRY_VALID_FLAG;
+
+	/*
+	 * Go poke the address of the new bounds table in to the
+	 * bounds directory entry out in userspace memory.  Note:
+	 * we may race with another CPU instantiating the same table.
+	 * In that case the cmpxchg will see an unexpected
+	 * 'actual_old_val'.
+	 *
+	 * This can fault, but that's OK because we do not hold
+	 * mmap_sem at this point, unlike some of the other part
+	 * of the MPX code that have to pagefault_disable().
+	 */
+	ret = user_atomic_cmpxchg_inatomic(&actual_old_val, bd_entry,
+					   expected_old_val, bt_addr);
+	if (ret)
+		goto out_unmap;
+
+	/*
+	 * The user_atomic_cmpxchg_inatomic() will only return nonzero
+	 * for faults, *not* if the cmpxchg itself fails.  Now we must
+	 * verify that the cmpxchg itself completed successfully.
+	 */
+	/*
+	 * We expected an empty 'expected_old_val', but instead found
+	 * an apparently valid entry.  Assume we raced with another
+	 * thread to instantiate this table and desclare succecss.
+	 */
+	if (actual_old_val & MPX_BD_ENTRY_VALID_FLAG) {
+		ret = 0;
+		goto out_unmap;
+	}
+	/*
+	 * We found a non-empty bd_entry but it did not have the
+	 * VALID_FLAG set.  Return an error which will result in
+	 * a SEGV since this probably means that somebody scribbled
+	 * some invalid data in to a bounds table.
+	 */
+	if (expected_old_val != actual_old_val) {
+		ret = -EINVAL;
+		goto out_unmap;
+	}
+	return 0;
+out_unmap:
+	vm_munmap(bt_addr & MPX_BT_ADDR_MASK, MPX_BT_SIZE_BYTES);
+	return ret;
+}
+
+/*
+ * When a BNDSTX instruction attempts to save bounds to a bounds
+ * table, it will first attempt to look up the table in the
+ * first-level bounds directory.  If it does not find a table in
+ * the directory, a #BR is generated and we get here in order to
+ * allocate a new table.
+ *
+ * With 32-bit mode, the size of BD is 4MB, and the size of each
+ * bound table is 16KB. With 64-bit mode, the size of BD is 2GB,
+ * and the size of each bound table is 4MB.
+ */
+static int do_mpx_bt_fault(struct xsave_struct *xsave_buf)
+{
+	struct bndcsr *bndcsr;
+	unsigned long bd_entry, bd_base;
+
+	bndcsr = get_xsave_addr(xsave_buf, XSTATE_BNDCSR);
+	if (!bndcsr)
+		return -EINVAL;
+	/*
+	 * Mask off the preserve and enable bits
+	 */
+	bd_base = bndcsr->bndcfgu & MPX_BNDCFG_ADDR_MASK;
+	/*
+	 * The hardware provides the address of the missing or invalid
+	 * entry via BNDSTATUS, so we don't have to go look it up.
+	 */
+	bd_entry = bndcsr->bndstatus & MPX_BNDSTA_ADDR_MASK;
+	/*
+	 * Make sure the directory entry is within where we think
+	 * the directory is.
+	 */
+	if ((bd_entry < bd_base) ||
+	    (bd_entry >= bd_base + MPX_BD_SIZE_BYTES))
+		return -EINVAL;
+
+	return allocate_bt((long __user *)bd_entry);
+}
+
+int mpx_handle_bd_fault(struct xsave_struct *xsave_buf)
+{
+	int ret = 0;
+	/*
+	 * Userspace never asked us to manage the bounds tables,
+	 * so refuse to help.
+	 */
+	if (!kernel_managing_mpx_tables(current->mm)) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = do_mpx_bt_fault(xsave_buf);
+	if (ret) {
+		force_sig(SIGSEGV, current);
+		/*
+		 * The force_sig() is essentially "handling" this
+		 * exception.  Return 0 so that the traps.c code
+		 * does not take any further action.
+		 */
+		ret = 0;
+	}
+out:
+	return ret;
+}
diff -puN fs/exec.c~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables fs/exec.c
--- a/fs/exec.c~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables	2014-11-12 08:49:26.483915981 -0800
+++ b/fs/exec.c	2014-11-12 08:49:26.496916567 -0800
@@ -60,6 +60,7 @@
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
 #include <asm/tlb.h>
+#include <asm/mpx.h>
 
 #include <trace/events/task.h>
 #include "internal.h"
@@ -277,6 +278,7 @@ static int __bprm_mm_init(struct linux_b
 		goto err;
 
 	mm->stack_vm = mm->total_vm = 1;
+	arch_bprm_mm_init(mm, vma);
 	up_write(&mm->mmap_sem);
 	bprm->p = vma->vm_end - sizeof(void *);
 	return 0;
diff -puN include/asm-generic/mmu_context.h~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables include/asm-generic/mmu_context.h
--- a/include/asm-generic/mmu_context.h~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables	2014-11-12 08:49:26.485916071 -0800
+++ b/include/asm-generic/mmu_context.h	2014-11-12 08:49:26.496916567 -0800
@@ -42,4 +42,9 @@ static inline void activate_mm(struct mm
 {
 }
 
+static inline void arch_bprm_mm_init(struct mm_struct *mm,
+			struct vm_area_struct *vma)
+{
+}
+
 #endif /* __ASM_GENERIC_MMU_CONTEXT_H */
diff -puN include/linux/mm_types.h~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables include/linux/mm_types.h
--- a/include/linux/mm_types.h~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables	2014-11-12 08:49:26.486916116 -0800
+++ b/include/linux/mm_types.h	2014-11-12 08:49:26.497916612 -0800
@@ -454,6 +454,9 @@ struct mm_struct {
 	bool tlb_flush_pending;
 #endif
 	struct uprobes_state uprobes_state;
+#ifdef CONFIG_X86_INTEL_MPX
+	void __user *bd_addr;		/* address of the bounds directory */
+#endif
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff -puN include/uapi/linux/prctl.h~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables include/uapi/linux/prctl.h
--- a/include/uapi/linux/prctl.h~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables	2014-11-12 08:49:26.488916206 -0800
+++ b/include/uapi/linux/prctl.h	2014-11-12 08:49:26.497916612 -0800
@@ -179,4 +179,10 @@ struct prctl_mm_map {
 #define PR_SET_THP_DISABLE	41
 #define PR_GET_THP_DISABLE	42
 
+/*
+ * Tell the kernel to start/stop helping userspace manage bounds tables.
+ */
+#define PR_MPX_ENABLE_MANAGEMENT  43
+#define PR_MPX_DISABLE_MANAGEMENT 44
+
 #endif /* _LINUX_PRCTL_H */
diff -puN kernel/sys.c~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables kernel/sys.c
--- a/kernel/sys.c~2014-10-14-05_12-x86-mpx-on-demand-kernel-allocation-of-bounds-tables	2014-11-12 08:49:26.490916296 -0800
+++ b/kernel/sys.c	2014-11-12 08:49:26.498916657 -0800
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
@@ -2203,6 +2209,12 @@ SYSCALL_DEFINE5(prctl, int, option, unsi
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
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
