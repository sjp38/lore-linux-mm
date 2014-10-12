Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 39F566B0071
	for <linux-mm@kvack.org>; Sun, 12 Oct 2014 00:51:56 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id fp1so3810485pdb.7
        for <linux-mm@kvack.org>; Sat, 11 Oct 2014 21:51:55 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hn2si7395970pbc.82.2014.10.11.21.51.54
        for <linux-mm@kvack.org>;
        Sat, 11 Oct 2014 21:51:54 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v9 05/12] x86, mpx: on-demand kernel allocation of bounds tables
Date: Sun, 12 Oct 2014 12:41:48 +0800
Message-Id: <1413088915-13428-6-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, Qiaowei Ren <qiaowei.ren@intel.com>

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
---
 arch/x86/include/asm/mpx.h |   20 +++++++++
 arch/x86/kernel/Makefile   |    1 +
 arch/x86/kernel/mpx.c      |  101 ++++++++++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/traps.c    |   52 ++++++++++++++++++++++-
 4 files changed, 173 insertions(+), 1 deletions(-)
 create mode 100644 arch/x86/kernel/mpx.c

diff --git a/arch/x86/include/asm/mpx.h b/arch/x86/include/asm/mpx.h
index 5725ac4..b7598ac 100644
--- a/arch/x86/include/asm/mpx.h
+++ b/arch/x86/include/asm/mpx.h
@@ -18,6 +18,8 @@
 #define MPX_BT_ENTRY_SHIFT	5
 #define MPX_IGN_BITS		3
 
+#define MPX_BD_ENTRY_TAIL	3
+
 #else
 
 #define MPX_BD_ENTRY_OFFSET	20
@@ -26,13 +28,31 @@
 #define MPX_BT_ENTRY_SHIFT	4
 #define MPX_IGN_BITS		2
 
+#define MPX_BD_ENTRY_TAIL	2
+
 #endif
 
+#define MPX_BNDSTA_TAIL		2
+#define MPX_BNDCFG_TAIL		12
+#define MPX_BNDSTA_ADDR_MASK	(~((1UL<<MPX_BNDSTA_TAIL)-1))
+#define MPX_BNDCFG_ADDR_MASK	(~((1UL<<MPX_BNDCFG_TAIL)-1))
+#define MPX_BT_ADDR_MASK	(~((1UL<<MPX_BD_ENTRY_TAIL)-1))
+
 #define MPX_BD_SIZE_BYTES (1UL<<(MPX_BD_ENTRY_OFFSET+MPX_BD_ENTRY_SHIFT))
 #define MPX_BT_SIZE_BYTES (1UL<<(MPX_BT_ENTRY_OFFSET+MPX_BT_ENTRY_SHIFT))
 
 #define MPX_BNDSTA_ERROR_CODE	0x3
+#define MPX_BD_ENTRY_VALID_FLAG	0x1
 
 unsigned long mpx_mmap(unsigned long len);
 
+#ifdef CONFIG_X86_INTEL_MPX
+int do_mpx_bt_fault(struct xsave_struct *xsave_buf);
+#else
+static inline int do_mpx_bt_fault(struct xsave_struct *xsave_buf)
+{
+	return -EINVAL;
+}
+#endif /* CONFIG_X86_INTEL_MPX */
+
 #endif /* _ASM_X86_MPX_H */
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index ada2e2d..9ece662 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -43,6 +43,7 @@ obj-$(CONFIG_PREEMPT)	+= preempt.o
 
 obj-y				+= process.o
 obj-y				+= i387.o xsave.o
+obj-$(CONFIG_X86_INTEL_MPX)	+= mpx.o
 obj-y				+= ptrace.o
 obj-$(CONFIG_X86_32)		+= tls.o
 obj-$(CONFIG_IA32_EMULATION)	+= tls.o
diff --git a/arch/x86/kernel/mpx.c b/arch/x86/kernel/mpx.c
new file mode 100644
index 0000000..2103b5e
--- /dev/null
+++ b/arch/x86/kernel/mpx.c
@@ -0,0 +1,101 @@
+/*
+ * mpx.c - Memory Protection eXtensions
+ *
+ * Copyright (c) 2014, Intel Corporation.
+ * Qiaowei Ren <qiaowei.ren@intel.com>
+ * Dave Hansen <dave.hansen@intel.com>
+ */
+
+#include <linux/kernel.h>
+#include <linux/syscalls.h>
+#include <asm/mpx.h>
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
+	 */
+	ret = user_atomic_cmpxchg_inatomic(&actual_old_val, bd_entry,
+					   expected_old_val, bt_addr);
+	if (ret)
+		goto out;
+
+	/*
+	 * The user_atomic_cmpxchg_inatomic() will only return nonzero
+	 * for faults, *not* if the cmpxchg itself fails.  This verifies
+	 * that the existing value was still empty like we expected.
+	 *
+	 * Note, we might get in here if there is a value in the existing
+	 * bd_entry but it did not have the VALID_FLAG set.  In that case
+	 * we do _not_ replace it.  We only replace completely empty
+	 * entries.
+	 */
+	if (expected_old_val != actual_old_val)
+		goto out;
+
+	return 0;
+
+out:
+	vm_munmap(bt_addr & MPX_BT_ADDR_MASK, MPX_BT_SIZE_BYTES);
+	return ret;
+}
+
+/*
+ * When a BNDSTX instruction attempts to save bounds to a BD entry
+ * with the lack of the valid bit being set, a #BR is generated.
+ * This is an indication that no BT exists for this entry. In this
+ * case the fault handler will allocate a new BT.
+ *
+ * With 32-bit mode, the size of BD is 4MB, and the size of each
+ * bound table is 16KB. With 64-bit mode, the size of BD is 2GB,
+ * and the size of each bound table is 4MB.
+ */
+int do_mpx_bt_fault(struct xsave_struct *xsave_buf)
+{
+	unsigned long status;
+	unsigned long bd_entry, bd_base;
+
+	bd_base = xsave_buf->bndcsr.bndcfgu & MPX_BNDCFG_ADDR_MASK;
+	status = xsave_buf->bndcsr.bndstatus;
+
+	/*
+	 * The hardware provides the address of the missing or invalid
+	 * entry via BNDSTATUS, so we don't have to go look it up.
+	 */
+	bd_entry = status & MPX_BNDSTA_ADDR_MASK;
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
diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
index 0d0e922..611b6ec 100644
--- a/arch/x86/kernel/traps.c
+++ b/arch/x86/kernel/traps.c
@@ -60,6 +60,7 @@
 #include <asm/fixmap.h>
 #include <asm/mach_traps.h>
 #include <asm/alternative.h>
+#include <asm/mpx.h>
 
 #ifdef CONFIG_X86_64
 #include <asm/x86_init.h>
@@ -228,7 +229,6 @@ dotraplinkage void do_##name(struct pt_regs *regs, long error_code)	\
 
 DO_ERROR(X86_TRAP_DE,     SIGFPE,  "divide error",		divide_error)
 DO_ERROR(X86_TRAP_OF,     SIGSEGV, "overflow",			overflow)
-DO_ERROR(X86_TRAP_BR,     SIGSEGV, "bounds",			bounds)
 DO_ERROR(X86_TRAP_UD,     SIGILL,  "invalid opcode",		invalid_op)
 DO_ERROR(X86_TRAP_OLD_MF, SIGFPE,  "coprocessor segment overrun",coprocessor_segment_overrun)
 DO_ERROR(X86_TRAP_TS,     SIGSEGV, "invalid TSS",		invalid_TSS)
@@ -278,6 +278,56 @@ dotraplinkage void do_double_fault(struct pt_regs *regs, long error_code)
 }
 #endif
 
+dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
+{
+	enum ctx_state prev_state;
+	unsigned long status;
+	struct xsave_struct *xsave_buf;
+	struct task_struct *tsk = current;
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
+		do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs, error_code, NULL);
+		goto exit;
+	}
+
+	fpu_xsave(&tsk->thread.fpu);
+	xsave_buf = &(tsk->thread.fpu.state->xsave);
+	status = xsave_buf->bndcsr.bndstatus;
+
+	/*
+	 * The error code field of the BNDSTATUS register communicates status
+	 * information of a bound range exception #BR or operation involving
+	 * bound directory.
+	 */
+	switch (status & MPX_BNDSTA_ERROR_CODE) {
+	case 2: /* Bound directory has invalid entry. */
+		if (do_mpx_bt_fault(xsave_buf))
+			force_sig(SIGSEGV, tsk);
+		break;
+
+	case 1: /* Bound violation. */
+	case 0: /* No exception caused by Intel MPX operations. */
+		do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs, error_code, NULL);
+		break;
+
+	default:
+		die("bounds", regs, error_code);
+	}
+
+exit:
+	exception_exit(prev_state);
+}
+
 dotraplinkage void
 do_general_protection(struct pt_regs *regs, long error_code)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
