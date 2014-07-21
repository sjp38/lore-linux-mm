Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 77E3A6B0044
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 01:42:44 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so8513868pdj.36
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 22:42:44 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id j3si1107912pdd.56.2014.07.20.22.42.43
        for <linux-mm@kvack.org>;
        Sun, 20 Jul 2014 22:42:43 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v7 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER, PR_MPX_UNREGISTER
Date: Mon, 21 Jul 2014 13:38:42 +0800
Message-Id: <1405921124-4230-9-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Qiaowei Ren <qiaowei.ren@intel.com>

This patch adds the PR_MPX_REGISTER and PR_MPX_UNREGISTER prctl()
commands. These commands can be used to register and unregister MPX
related resource on the x86 platform.

The base of the bounds directory is set into mm_struct during
PR_MPX_REGISTER command execution. This member can be used to
check whether one application is mpx enabled.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
---
 arch/x86/include/asm/mpx.h       |    1 +
 arch/x86/include/asm/processor.h |   18 ++++++++++++
 arch/x86/kernel/mpx.c            |   56 ++++++++++++++++++++++++++++++++++++++
 include/linux/mm_types.h         |    3 ++
 include/uapi/linux/prctl.h       |    6 ++++
 kernel/sys.c                     |   12 ++++++++
 6 files changed, 96 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/mpx.h b/arch/x86/include/asm/mpx.h
index 780af63..6cb0853 100644
--- a/arch/x86/include/asm/mpx.h
+++ b/arch/x86/include/asm/mpx.h
@@ -43,6 +43,7 @@
 #define MPX_BT_SIZE_BYTES (1UL<<(MPX_BT_ENTRY_OFFSET+MPX_BT_ENTRY_SHIFT))
 
 #define MPX_BNDSTA_ERROR_CODE	0x3
+#define MPX_BNDCFG_ENABLE_FLAG	0x1
 #define MPX_BD_ENTRY_VALID_FLAG	0x1
 
 struct mpx_insn {
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index a4ea023..6e0966e 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -952,6 +952,24 @@ extern void start_thread(struct pt_regs *regs, unsigned long new_ip,
 extern int get_tsc_mode(unsigned long adr);
 extern int set_tsc_mode(unsigned int val);
 
+/* Register/unregister a process' MPX related resource */
+#define MPX_REGISTER(tsk)	mpx_register((tsk))
+#define MPX_UNREGISTER(tsk)	mpx_unregister((tsk))
+
+#ifdef CONFIG_X86_INTEL_MPX
+extern int mpx_register(struct task_struct *tsk);
+extern int mpx_unregister(struct task_struct *tsk);
+#else
+static inline int mpx_register(struct task_struct *tsk)
+{
+	return -EINVAL;
+}
+static inline int mpx_unregister(struct task_struct *tsk)
+{
+	return -EINVAL;
+}
+#endif /* CONFIG_X86_INTEL_MPX */
+
 extern u16 amd_get_nb_id(int cpu);
 
 static inline uint32_t hypervisor_cpuid_base(const char *sig, uint32_t leaves)
diff --git a/arch/x86/kernel/mpx.c b/arch/x86/kernel/mpx.c
index c1957a8..6b7e526 100644
--- a/arch/x86/kernel/mpx.c
+++ b/arch/x86/kernel/mpx.c
@@ -1,6 +1,62 @@
 #include <linux/kernel.h>
 #include <linux/syscalls.h>
+#include <linux/prctl.h>
 #include <asm/mpx.h>
+#include <asm/i387.h>
+#include <asm/fpu-internal.h>
+
+/*
+ * This should only be called when cpuid has been checked
+ * and we are sure that MPX is available.
+ */
+static __user void *task_get_bounds_dir(struct task_struct *tsk)
+{
+	struct xsave_struct *xsave_buf;
+
+	fpu_xsave(&tsk->thread.fpu);
+	xsave_buf = &(tsk->thread.fpu.state->xsave);
+	if (!(xsave_buf->bndcsr.cfg_reg_u & MPX_BNDCFG_ENABLE_FLAG))
+		return NULL;
+
+	return (void __user *)(unsigned long)(xsave_buf->bndcsr.cfg_reg_u &
+			MPX_BNDCFG_ADDR_MASK);
+}
+
+int mpx_register(struct task_struct *tsk)
+{
+	struct mm_struct *mm = tsk->mm;
+
+	if (!cpu_has_mpx)
+		return -EINVAL;
+
+	/*
+	 * runtime in the userspace will be responsible for allocation of
+	 * the bounds directory. Then, it will save the base of the bounds
+	 * directory into XSAVE/XRSTOR Save Area and enable MPX through
+	 * XRSTOR instruction.
+	 *
+	 * fpu_xsave() is expected to be very expensive. In order to do
+	 * performance optimization, here we get the base of the bounds
+	 * directory and then save it into mm_struct to be used in future.
+	 */
+	mm->bd_addr = task_get_bounds_dir(tsk);
+	if (!mm->bd_addr)
+		return -EINVAL;
+
+	pr_debug("MPX BD base address %p\n", mm->bd_addr);
+	return 0;
+}
+
+int mpx_unregister(struct task_struct *tsk)
+{
+	struct mm_struct *mm = current->mm;
+
+	if (!cpu_has_mpx)
+		return -EINVAL;
+
+	mm->bd_addr = NULL;
+	return 0;
+}
 
 enum reg_type {
 	REG_TYPE_RM = 0,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 96c5750..131b5b3 100644
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
index 58afc04..ce86fa9 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -152,4 +152,10 @@
 #define PR_SET_THP_DISABLE	41
 #define PR_GET_THP_DISABLE	42
 
+/*
+ * Register/unregister MPX related resource.
+ */
+#define PR_MPX_REGISTER		43
+#define PR_MPX_UNREGISTER	44
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/sys.c b/kernel/sys.c
index 66a751e..eadff9c 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -91,6 +91,12 @@
 #ifndef SET_TSC_CTL
 # define SET_TSC_CTL(a)		(-EINVAL)
 #endif
+#ifndef MPX_REGISTER
+# define MPX_REGISTER(a)	(-EINVAL)
+#endif
+#ifndef MPX_UNREGISTER
+# define MPX_UNREGISTER(a)	(-EINVAL)
+#endif
 
 /*
  * this is where the system-wide overflow UID and GID are defined, for
@@ -2011,6 +2017,12 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 			me->mm->def_flags &= ~VM_NOHUGEPAGE;
 		up_write(&me->mm->mmap_sem);
 		break;
+	case PR_MPX_REGISTER:
+		error = MPX_REGISTER(me);
+		break;
+	case PR_MPX_UNREGISTER:
+		error = MPX_UNREGISTER(me);
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
