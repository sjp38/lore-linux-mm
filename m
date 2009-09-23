Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C01436B0055
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:22 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 77/80] powerpc: checkpoint/restart implementation
Date: Wed, 23 Sep 2009 19:51:57 -0400
Message-Id: <1253749920-18673-78-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Nathan Lynch <ntl@pobox.com>
List-ID: <linux-mm.kvack.org>

From: Nathan Lynch <ntl@pobox.com>

Support for checkpointing and restarting GPRs, FPU state, DABR, and
Altivec state.

The portion of the checkpoint image manipulated by this code begins
with a bitmask of features indicating the various contexts saved.
Fields in image that can vary depending on kernel configuration
(e.g. FP regs due to VSX) have their sizes explicitly recorded, except
for GPRS, so migrating between ppc32 and ppc64 won't work yet.

The restart code ensures that the task is not modified until the
checkpoint image is validated against the current kernel configuration
and hardware features (e.g. can't restart a task using Altivec on
non-Altivec systems).

What works:
* self and external checkpoint of simple (single thread, one open
  file) 32- and 64-bit processes on a ppc64 kernel

What doesn't work:
* restarting a 32-bit task from a 64-bit task and vice versa

Untested:
* ppc32 (but it builds)

Signed-off-by: Nathan Lynch <ntl@pobox.com>
[Oren Laadan <orenl@cs.columbia.edu>] Add arch-specific tty support
---
 arch/powerpc/include/asm/Kbuild           |    1 +
 arch/powerpc/include/asm/checkpoint_hdr.h |   37 ++
 arch/powerpc/mm/Makefile                  |    1 +
 arch/powerpc/mm/checkpoint.c              |  531 +++++++++++++++++++++++++++++
 4 files changed, 570 insertions(+), 0 deletions(-)
 create mode 100644 arch/powerpc/include/asm/checkpoint_hdr.h
 create mode 100644 arch/powerpc/mm/checkpoint.c

diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index 5ab7d7f..20379f1 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -12,6 +12,7 @@ header-y += shmbuf.h
 header-y += socket.h
 header-y += termbits.h
 header-y += fcntl.h
+header-y += checkpoint_hdr.h
 header-y += poll.h
 header-y += sockios.h
 header-y += ucontext.h
diff --git a/arch/powerpc/include/asm/checkpoint_hdr.h b/arch/powerpc/include/asm/checkpoint_hdr.h
new file mode 100644
index 0000000..fbb1705
--- /dev/null
+++ b/arch/powerpc/include/asm/checkpoint_hdr.h
@@ -0,0 +1,37 @@
+#ifndef __ASM_POWERPC_CKPT_HDR_H
+#define __ASM_POWERPC_CKPT_HDR_H
+
+#include <linux/types.h>
+
+/* arch dependent constants */
+#define CKPT_ARCH_NSIG 64
+#define CKPT_TTY_NCC  10
+
+#ifdef __KERNEL__
+
+#include <asm/signal.h>
+#if CKPT_ARCH_NSIG != _NSIG
+#error CKPT_ARCH_NSIG size is wrong per asm/signal.h and asm/checkpoint_hdr.h
+#endif
+
+#include <linux/tty.h>
+#if CKPT_TTY_NCC != NCC
+#error CKPT_TTY_NCC size is wrong per asm-generic/termios.h
+#endif
+
+#endif /* __KERNEL__ */
+
+#ifdef __KERNEL__
+#ifdef CONFIG_PPC64
+#define CKPT_ARCH_ID CKPT_ARCH_PPC64
+#else
+#define CKPT_ARCH_ID CKPT_ARCH_PPC32
+#endif
+#endif
+
+struct ckpt_hdr_header_arch {
+	struct ckpt_hdr h;
+	__u32 what;
+} __attribute__((aligned(8)));
+
+#endif /* __ASM_POWERPC_CKPT_HDR_H */
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 3e68363..aa8733c 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -31,3 +31,4 @@ obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
 obj-$(CONFIG_PPC_SUBPAGE_PROT)	+= subpage-prot.o
 obj-$(CONFIG_NOT_COHERENT_CACHE) += dma-noncoherent.o
 obj-$(CONFIG_HIGHMEM)		+= highmem.o
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
diff --git a/arch/powerpc/mm/checkpoint.c b/arch/powerpc/mm/checkpoint.c
new file mode 100644
index 0000000..de18467
--- /dev/null
+++ b/arch/powerpc/mm/checkpoint.c
@@ -0,0 +1,531 @@
+/*
+ * PowerPC architecture support for checkpoint/restart.
+ * Based on x86 implementation.
+ *
+ * Copyright (C) 2008 Oren Laadan
+ * Copyright 2009 IBM Corp.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version
+ * 2 as published by the Free Software Foundation.
+ */
+
+#if 0
+#define DEBUG
+#endif
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/kernel.h>
+#include <asm/processor.h>
+#include <asm/ptrace.h>
+#include <asm/system.h>
+
+enum ckpt_cpu_feature {
+	CKPT_USED_FP,
+	CKPT_USED_DEBUG,
+	CKPT_USED_ALTIVEC,
+	CKPT_USED_SPE,
+	CKPT_USED_VSX,
+	CKPT_FTR_END = 31,
+};
+
+#define x(ftr) (1UL << ftr)
+
+/* features this kernel can handle for restart */
+enum {
+	CKPT_FTRS_POSSIBLE =
+#ifdef CONFIG_PPC_FPU
+	x(CKPT_USED_FP) |
+#endif
+	x(CKPT_USED_DEBUG) |
+#ifdef CONFIG_ALTIVEC
+	x(CKPT_USED_ALTIVEC) |
+#endif
+#ifdef CONFIG_SPE
+	x(CKPT_USED_SPE) |
+#endif
+#ifdef CONFIG_VSX
+	x(CKPT_USED_VSX) |
+#endif
+	0,
+};
+
+#undef x
+
+struct ckpt_hdr_cpu {
+	struct ckpt_hdr h;
+	u32 features_used;
+	u32 pt_regs_size;
+	u32 fpr_size;
+	u64 orig_gpr3;
+	struct pt_regs pt_regs;
+	/* relevant fields from thread_struct */
+	double fpr[32][TS_FPRWIDTH];
+	u32 fpscr;
+	s32 fpexc_mode;
+	u64 dabr;
+	/* Altivec/VMX state */
+	vector128 vr[32];
+	vector128 vscr;
+	u64 vrsave;
+	/* SPE state */
+	u32 evr[32];
+	u64 acc;
+	u32 spefscr;
+};
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+static void ckpt_cpu_feature_set(struct ckpt_hdr_cpu *hdr,
+				 enum ckpt_cpu_feature ftr)
+{
+	hdr->features_used |= 1ULL << ftr;
+}
+
+static bool ckpt_cpu_feature_isset(const struct ckpt_hdr_cpu *hdr,
+				 enum ckpt_cpu_feature ftr)
+{
+	return hdr->features_used & (1ULL << ftr);
+}
+
+/* determine whether an image has feature bits set that this kernel
+ * does not support */
+static bool ckpt_cpu_features_unknown(const struct ckpt_hdr_cpu *hdr)
+{
+	return hdr->features_used & ~CKPT_FTRS_POSSIBLE;
+}
+
+static void checkpoint_gprs(struct ckpt_hdr_cpu *cpu_hdr,
+			    struct task_struct *task)
+{
+	struct pt_regs *pt_regs;
+
+	pr_debug("%s: saving GPRs\n", __func__);
+
+	cpu_hdr->pt_regs_size = sizeof(*pt_regs);
+	pt_regs = task_pt_regs(task);
+	cpu_hdr->pt_regs = *pt_regs;
+
+	if (task == current)
+		cpu_hdr->pt_regs.gpr[3] = 0;
+
+	cpu_hdr->orig_gpr3 = pt_regs->orig_gpr3;
+}
+
+#ifdef CONFIG_PPC_FPU
+static void checkpoint_fpu(struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task)
+{
+	/* easiest to save FP state unconditionally */
+
+	pr_debug("%s: saving FPU state\n", __func__);
+
+	if (task == current)
+		flush_fp_to_thread(task);
+
+	cpu_hdr->fpr_size = sizeof(cpu_hdr->fpr);
+	cpu_hdr->fpscr = task->thread.fpscr.val;
+	cpu_hdr->fpexc_mode = task->thread.fpexc_mode;
+
+	memcpy(cpu_hdr->fpr, task->thread.fpr, sizeof(cpu_hdr->fpr));
+
+	ckpt_cpu_feature_set(cpu_hdr, CKPT_USED_FP);
+}
+#else
+static void checkpoint_fpu(struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task)
+{
+	return;
+}
+#endif
+
+#ifdef CONFIG_ALTIVEC
+static void checkpoint_altivec(struct ckpt_hdr_cpu *cpu_hdr,
+			       struct task_struct *task)
+{
+	if (!cpu_has_feature(CPU_FTR_ALTIVEC))
+		return;
+
+	if (!task->thread.used_vr)
+		return;
+
+	pr_debug("%s: saving Altivec state\n", __func__);
+
+	if (task == current)
+		flush_altivec_to_thread(task);
+
+	cpu_hdr->vrsave = task->thread.vrsave;
+	memcpy(cpu_hdr->vr, task->thread.vr, sizeof(cpu_hdr->vr));
+	ckpt_cpu_feature_set(cpu_hdr, CKPT_USED_ALTIVEC);
+}
+#else
+static void checkpoint_altivec(struct ckpt_hdr_cpu *cpu_hdr,
+			       struct task_struct *task)
+{
+	return;
+}
+#endif
+
+#ifdef CONFIG_SPE
+static void checkpoint_spe(struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task)
+{
+	if (!cpu_has_feature(CPU_FTR_SPE))
+		return;
+
+	if (!task->thread.used_spe)
+		return;
+
+	pr_debug("%s: saving SPE state\n", __func__);
+
+	if (task == current)
+		flush_spe_to_thread(task);
+
+	cpu_hdr->acc = task->thread.acc;
+	cpu_hdr->spefscr = task->thread.spefscr;
+	memcpy(cpu_hdr->evr, task->thread.evr, sizeof(cpu_hdr->evr));
+	ckpt_cpu_feature_set(cpu_hdr, CKPT_USED_SPE);
+}
+#else
+static void checkpoint_spe(struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task)
+{
+	return;
+}
+#endif
+
+static void checkpoint_dabr(struct ckpt_hdr_cpu *cpu_hdr,
+			    const struct task_struct *task)
+{
+	if (!task->thread.dabr)
+		return;
+
+	cpu_hdr->dabr = task->thread.dabr;
+	ckpt_cpu_feature_set(cpu_hdr, CKPT_USED_DEBUG);
+}
+
+/* dump the thread_struct of a given task */
+int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	return 0;
+}
+
+/* dump the cpu state and registers of a given task */
+int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_cpu *cpu_hdr;
+	int rc;
+
+	rc = -ENOMEM;
+	cpu_hdr = ckpt_hdr_get_type(ctx, sizeof(*cpu_hdr), CKPT_HDR_CPU);
+	if (!cpu_hdr)
+		goto err;
+
+	checkpoint_gprs(cpu_hdr, t);
+	checkpoint_fpu(cpu_hdr, t);
+	checkpoint_dabr(cpu_hdr, t);
+	checkpoint_altivec(cpu_hdr, t);
+	checkpoint_spe(cpu_hdr, t);
+
+	rc = ckpt_write_obj(ctx, (struct ckpt_hdr *) cpu_hdr);
+err:
+	ckpt_hdr_put(ctx, cpu_hdr);
+	return rc;
+}
+
+int checkpoint_write_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *arch_hdr;
+	int ret;
+
+	arch_hdr = ckpt_hdr_get_type(ctx, sizeof(*arch_hdr),
+				     CKPT_HDR_HEADER_ARCH);
+	if (!arch_hdr)
+		return -ENOMEM;
+
+	arch_hdr->what = 0xdeadbeef;
+
+	ret = ckpt_write_obj(ctx, &arch_hdr->h);
+	ckpt_hdr_put(ctx, arch_hdr);
+
+	return ret;
+}
+
+/* dump the mm->context state */
+int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	return 0;
+}
+
+/**************************************************************************
+ * Restart
+ */
+
+/* read the thread_struct into the current task */
+int restore_thread(struct ckpt_ctx *ctx)
+{
+	return 0;
+}
+
+/* Based on the MSR value from a checkpoint image, produce an MSR
+ * value that is appropriate for the restored task.  Right now we only
+ * check for MSR_SF (64-bit) for PPC64.
+ */
+static unsigned long sanitize_msr(unsigned long msr_ckpt)
+{
+#ifdef CONFIG_PPC32
+	return MSR_USER;
+#else
+	if (msr_ckpt & MSR_SF)
+		return MSR_USER64;
+	return MSR_USER32;
+#endif
+}
+
+static int restore_gprs(const struct ckpt_hdr_cpu *cpu_hdr,
+			struct task_struct *task, bool update)
+{
+	struct pt_regs *regs;
+	int rc;
+
+	rc = -EINVAL;
+	if (cpu_hdr->pt_regs_size != sizeof(*regs))
+		goto out;
+
+	rc = 0;
+	if (!update)
+		goto out;
+
+	regs = task_pt_regs(task);
+	*regs = cpu_hdr->pt_regs;
+
+	regs->orig_gpr3 = cpu_hdr->orig_gpr3;
+
+	regs->msr = sanitize_msr(regs->msr);
+out:
+	return rc;
+}
+
+#ifdef CONFIG_PPC_FPU
+static int restore_fpu(const struct ckpt_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = -EINVAL;
+	if (cpu_hdr->fpr_size != sizeof(task->thread.fpr))
+		goto out;
+
+	rc = 0;
+	if (!update || !ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_FP))
+		goto out;
+
+	task->thread.fpscr.val = cpu_hdr->fpscr;
+	task->thread.fpexc_mode = cpu_hdr->fpexc_mode;
+
+	memcpy(task->thread.fpr, cpu_hdr->fpr, sizeof(task->thread.fpr));
+out:
+	return rc;
+}
+#else
+static int restore_fpu(const struct ckpt_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	WARN_ON_ONCE(ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_FP));
+	return 0;
+}
+#endif
+
+static int restore_dabr(const struct ckpt_hdr_cpu *cpu_hdr,
+			struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = 0;
+	if (!ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_DEBUG))
+		goto out;
+
+	rc = -EINVAL;
+	if (!debugreg_valid(cpu_hdr->dabr, 0))
+		goto out;
+
+	rc = 0;
+	if (!update)
+		goto out;
+
+	debugreg_update(task, cpu_hdr->dabr, 0);
+out:
+	return rc;
+}
+
+#ifdef CONFIG_ALTIVEC
+static int restore_altivec(const struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = 0;
+	if (!ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_ALTIVEC))
+		goto out;
+
+	rc = -EINVAL;
+	if (!cpu_has_feature(CPU_FTR_ALTIVEC))
+		goto out;
+
+	rc = 0;
+	if (!update)
+		goto out;
+
+	task->thread.vrsave = cpu_hdr->vrsave;
+	task->thread.used_vr = 1;
+
+	memcpy(task->thread.vr, cpu_hdr->vr, sizeof(cpu_hdr->vr));
+out:
+	return rc;
+}
+#else
+static int restore_altivec(const struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task, bool update)
+{
+	WARN_ON_ONCE(ckpt_cpu_feature_isset(CKPT_USED_ALTIVEC));
+	return 0;
+}
+#endif
+
+#ifdef CONFIG_SPE
+static int restore_spe(const struct ckpt_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = 0;
+	if (!ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_SPE))
+		goto out;
+
+	rc = -EINVAL;
+	if (!cpu_has_feature(CPU_FTR_SPE))
+		goto out;
+
+	rc = 0;
+	if (!update)
+		goto out;
+
+	task->thread.acc = cpu_hdr->acc;
+	task->thread.spefscr = cpu_hdr->spefscr;
+	task->thread.used_spe = 1;
+
+	memcpy(task->thread.evr, cpu_hdr->evr, sizeof(cpu_hdr->evr));
+out:
+	return rc;
+}
+#else
+static int restore_spe(const struct ckpt_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	WARN_ON_ONCE(ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_SPE));
+	return 0;
+}
+#endif
+
+struct restore_func_desc {
+	int (*func)(const struct ckpt_hdr_cpu *, struct task_struct *, bool);
+	const char *info;
+};
+
+typedef int (*restore_func_t)(const struct ckpt_hdr_cpu *,
+			      struct task_struct *, bool);
+
+static const restore_func_t restore_funcs[] = {
+	restore_gprs,
+	restore_fpu,
+	restore_dabr,
+	restore_altivec,
+	restore_spe,
+};
+
+static bool bitness_match(const struct ckpt_hdr_cpu *cpu_hdr,
+			  const struct task_struct *task)
+{
+	/* 64-bit image */
+	if (cpu_hdr->pt_regs.msr & MSR_SF) {
+		if (task->thread.regs->msr & MSR_SF)
+			return true;
+		else
+			return false;
+	}
+
+	/* 32-bit image */
+	if (task->thread.regs->msr & MSR_SF)
+		return false;
+
+	return true;
+}
+
+int restore_cpu(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_cpu *cpu_hdr;
+	bool update;
+	int rc;
+	int i;
+
+	cpu_hdr = ckpt_read_obj_type(ctx, sizeof(*cpu_hdr), CKPT_HDR_CPU);
+	if (IS_ERR(cpu_hdr))
+		return PTR_ERR(cpu_hdr);
+
+	rc = -EINVAL;
+	if (ckpt_cpu_features_unknown(cpu_hdr))
+		goto err;
+
+	/* temporary: restoring a 32-bit image from a 64-bit task and
+	 * vice-versa is known not to work (probably not restoring
+	 * thread_info correctly); detect this and fail gracefully.
+	 */
+	if (!bitness_match(cpu_hdr, current))
+		goto err;
+
+	/* We want to determine whether there's anything wrong with
+	 * the checkpoint image before changing the task at all.  Run
+	 * a "check" phase (update = false) first.
+	 */
+	update = false;
+commit:
+	for (i = 0; i < ARRAY_SIZE(restore_funcs); i++) {
+		rc = restore_funcs[i](cpu_hdr, current, update);
+		if (rc == 0)
+			continue;
+		pr_debug("%s: restore_func[%i] failed\n", __func__, i);
+		WARN_ON_ONCE(update);
+		goto err;
+	}
+
+	if (!update) {
+		update = true;
+		goto commit;
+	}
+
+err:
+	ckpt_hdr_put(ctx, cpu_hdr);
+	return rc;
+}
+
+int restore_read_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *arch_hdr;
+
+	arch_hdr = ckpt_read_obj_type(ctx, sizeof(*arch_hdr),
+				      CKPT_HDR_HEADER_ARCH);
+	if (IS_ERR(arch_hdr))
+		return PTR_ERR(arch_hdr);
+
+	ckpt_hdr_put(ctx, arch_hdr);
+
+	return 0;
+}
+
+int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	return 0;
+}
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
