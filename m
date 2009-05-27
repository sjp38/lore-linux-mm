Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1C36B007E
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:33:10 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 06/43] c/r: x86_32 support for checkpoint/restart
Date: Wed, 27 May 2009 13:32:32 -0400
Message-Id: <1243445589-32388-7-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Add logic to save and restore architecture specific state, including
thread-specific state, CPU registers and FPU state.

In addition, architecture capabilities are saved in an architecure
specific extension of the header (ckpt_hdr_head_arch); Currently this
includes only FPU capabilities.

Currently only x86-32 is supported.

TODO: validate input values for regs, debug regs, and TLS on restart.

Changelog[v16]:
  - All objects are preceded by ckpt_hdr (TLS and xstate_buf)
  - Add architecture identifier to main header

Changelog[v14]:
  - Use new interface ckpt_hdr_get/put()
  - Embed struct ckpt_hdr in struct ckpt_hdr...
  - Remove preempt_disable/enable() around init_fpu() and fix leak
  - Revert change to pr_debug(), back to ckpt_debug()
  - Move code related to task_struct to checkpoint/process.c

Changelog[v12]:
  - A couple of missed calls to ckpt_hbuf_put()
  - Replace obsolete ckpt_debug() with pr_debug()

Changelog[v9]:
  - Add arch-specific header that details architecture capabilities;
    split FPU restore to send capabilities only once.
  - Test for zero TLS entries in ckpt_write_thread()
  - Fix asm/checkpoint_hdr.h so it can be included from user-space

Changelog[v7]:
  - Fix save/restore state of FPU

Changelog[v5]:
  - Remove preempt_disable() when restoring debug registers

Changelog[v4]:
  - Fix header structure alignment

Changelog[v2]:
  - Pad header structures to 64 bits to ensure compatibility
  - Follow Dave Hansen's refactoring of the original post

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 arch/x86/include/asm/checkpoint_hdr.h |  110 +++++++++
 arch/x86/mm/Makefile                  |    2 +
 arch/x86/mm/checkpoint.c              |  431 +++++++++++++++++++++++++++++++++
 checkpoint/checkpoint.c               |    7 +-
 checkpoint/process.c                  |   20 ++-
 checkpoint/restart.c                  |    6 +
 include/linux/checkpoint.h            |   10 +
 include/linux/checkpoint_hdr.h        |   12 +-
 8 files changed, 594 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
new file mode 100644
index 0000000..362b499
--- /dev/null
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -0,0 +1,110 @@
+#ifndef __ASM_X86_CKPT_HDR_H
+#define __ASM_X86_CKPT_HDR_H
+/*
+ *  Checkpoint/restart - architecture specific headers x86
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/types.h>
+#include <linux/checkpoint_hdr.h>
+
+/*
+ * To maintain compatibility between 32-bit and 64-bit architecture flavors,
+ * keep data 64-bit aligned: use padding for structure members, and use
+ * __attribute__((aligned (8))) for the entire structure.
+ *
+ * Quoting Arnd Bergmann:
+ *   "This structure has an odd multiple of 32-bit members, which means
+ *   that if you put it into a larger structure that also contains 64-bit
+ *   members, the larger structure may get different alignment on x86-32
+ *   and x86-64, which you might want to avoid. I can't tell if this is
+ *   an actual problem here. ... In this case, I'm pretty sure that
+ *   sizeof(ckpt_hdr_task) on x86-32 is different from x86-64, since it
+ *   will be 32-bit aligned on x86-32."
+ */
+
+/* i387 structure seen from kernel/userspace */
+#ifdef __KERNEL__
+#include <asm/processor.h>
+#else
+#include <sys/user.h>
+#endif
+
+#ifndef CONFIG_X86_64
+#define CKPT_ARCH_ID	CKPT_ARCH_X86_32
+#endif
+
+/* arch dependent header types */
+enum {
+	CKPT_HDR_THREAD_TLS = 201,
+	CKPT_HDR_CPU_FPU,
+};
+
+struct ckpt_hdr_header_arch {
+	struct ckpt_hdr h;
+	/* FIXME: add HAVE_HWFP */
+	__u16 has_fxsr;
+	__u16 has_xsave;
+	__u16 xstate_size;
+	__u16 _pading;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_thread {
+	struct ckpt_hdr h;
+	/* FIXME: restart blocks */
+	__u16 gdt_entry_tls_entries;
+	__u16 sizeof_tls_array;
+	__u16 ntls;	/* number of TLS entries to follow */
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_cpu {
+	struct ckpt_hdr h;
+	/* see struct pt_regs (x86-64) */
+	__u64 r15;
+	__u64 r14;
+	__u64 r13;
+	__u64 r12;
+	__u64 bp;
+	__u64 bx;
+	__u64 r11;
+	__u64 r10;
+	__u64 r9;
+	__u64 r8;
+	__u64 ax;
+	__u64 cx;
+	__u64 dx;
+	__u64 si;
+	__u64 di;
+	__u64 orig_ax;
+	__u64 ip;
+	__u64 cs;
+	__u64 flags;
+	__u64 sp;
+	__u64 ss;
+
+	/* segment registers */
+	__u64 ds;
+	__u64 es;
+	__u64 fs;
+	__u64 gs;
+
+	/* debug registers */
+	__u64 debugreg0;
+	__u64 debugreg1;
+	__u64 debugreg2;
+	__u64 debugreg3;
+	__u64 debugreg6;
+	__u64 debugreg7;
+
+	__u32 uses_debug;
+	__u32 used_math;
+
+	/* thread_xstate contents follow (if used_math) */
+} __attribute__((aligned(8)));
+
+#endif /* __ASM_X86_CKPT_HDR__H */
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index fdd30d0..7d894a5 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -19,3 +19,5 @@ obj-$(CONFIG_K8_NUMA)		+= k8topology_64.o
 obj-$(CONFIG_ACPI_NUMA)		+= srat_$(BITS).o
 
 obj-$(CONFIG_MEMTEST)		+= memtest.o
+
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
new file mode 100644
index 0000000..f54fe80
--- /dev/null
+++ b/arch/x86/mm/checkpoint.c
@@ -0,0 +1,431 @@
+/*
+ *  Checkpoint/restart - architecture specific support for x86
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
+#include <asm/desc.h>
+#include <asm/i387.h>
+
+#include <asm/checkpoint_hdr.h>
+#include <linux/checkpoint.h>
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+/* dump the thread_struct of a given task */
+int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_thread *h;
+	struct thread_struct *thread;
+	struct desc_struct *desc;
+	int ntls = 0;
+	int n, ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_THREAD);
+	if (!h)
+		return -ENOMEM;
+
+	thread = &t->thread;
+
+	/* calculate no. of TLS entries that follow */
+	desc = thread->tls_array;
+	for (n = GDT_ENTRY_TLS_ENTRIES; n > 0; n--, desc++) {
+		if (desc->a || desc->b)
+			ntls++;
+	}
+
+	h->gdt_entry_tls_entries = GDT_ENTRY_TLS_ENTRIES;
+	h->sizeof_tls_array = sizeof(thread->tls_array);
+	h->ntls = ntls;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	ckpt_debug("ntls %d\n", ntls);
+	if (ntls == 0)
+		return 0;
+
+	/*
+	 * For simplicity dump the entire array, cherry-pick upon restart
+	 * FIXME: the TLS descriptors in the GDT should be called out and
+	 * not tied to the in-kernel representation.
+	 */
+	ret = ckpt_write_obj_type(ctx, thread->tls_array,
+				  sizeof(thread->tls_array),
+				  CKPT_HDR_THREAD_TLS);
+
+	/* IGNORE RESTART BLOCKS FOR NOW ... */
+
+	return ret;
+}
+
+#ifndef CONFIG_X86_64
+
+static void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
+
+	h->bp = regs->bp;
+	h->bx = regs->bx;
+	h->ax = regs->ax;
+	h->cx = regs->cx;
+	h->dx = regs->dx;
+	h->si = regs->si;
+	h->di = regs->di;
+	h->orig_ax = regs->orig_ax;
+	h->ip = regs->ip;
+	h->cs = regs->cs;
+	h->flags = regs->flags;
+	h->sp = regs->sp;
+	h->ss = regs->ss;
+
+	h->ds = regs->ds;
+	h->es = regs->es;
+
+	/*
+	 * for checkpoint in process context (from within a container)
+	 * the GS and FS registers should be saved from the hardware;
+	 * otherwise they are already sabed on the thread structure
+	 */
+	if (t == current) {
+		savesegment(gs, h->gs);
+		savesegment(fs, h->fs);
+	} else {
+		h->gs = thread->gs;
+		h->fs = thread->fs;
+	}
+
+	/*
+	 * for checkpoint in process context (from within a container),
+	 * the actual syscall is taking place at this very moment; so
+	 * we (optimistically) subtitute the future return value (0) of
+	 * this syscall into the orig_eax, so that upon restart it will
+	 * succeed (or it will endlessly retry checkpoint...)
+	 */
+	if (t == current) {
+		BUG_ON(h->orig_ax < 0);
+		h->ax = 0;
+	}
+}
+
+static void save_cpu_debug(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+
+	/* debug regs */
+
+	/*
+	 * for checkpoint in process context (from within a container),
+	 * get the actual registers; otherwise get the saved values.
+	 */
+
+	if (t == current) {
+		get_debugreg(h->debugreg0, 0);
+		get_debugreg(h->debugreg1, 1);
+		get_debugreg(h->debugreg2, 2);
+		get_debugreg(h->debugreg3, 3);
+		get_debugreg(h->debugreg6, 6);
+		get_debugreg(h->debugreg7, 7);
+	} else {
+		h->debugreg0 = thread->debugreg0;
+		h->debugreg1 = thread->debugreg1;
+		h->debugreg2 = thread->debugreg2;
+		h->debugreg3 = thread->debugreg3;
+		h->debugreg6 = thread->debugreg6;
+		h->debugreg7 = thread->debugreg7;
+	}
+
+	h->uses_debug = !!(task_thread_info(t)->flags & TIF_DEBUG);
+}
+
+static void save_cpu_fpu(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	h->used_math = tsk_used_math(t) ? 1 : 0;
+}
+
+static int checkpoint_cpu_fpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, xstate_size + sizeof(*h),
+			      CKPT_HDR_CPU_FPU);
+	if (!h)
+		return -ENOMEM;
+
+	/* i387 + MMU + SSE logic */
+	preempt_disable();	/* needed it (t == current) */
+
+	/*
+	 * normally, no need to unlazy_fpu(), since TS_USEDFPU flag
+	 * was cleared when task was context-switched out...
+	 * except if we are in process context, in which case we do
+	 */
+	if (t == current && (task_thread_info(t)->status & TS_USEDFPU))
+		unlazy_fpu(current);
+
+	/*
+	 * For simplicity dump the entire structure.
+	 * FIX: need to be deliberate about what registers we are
+	 * dumping for traceability and compatibility.
+	 */
+	memcpy(h + 1, t->thread.xstate, xstate_size);
+	preempt_enable();	/* needed if (t == current) */
+
+	ret = ckpt_write_obj(ctx, h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+#endif	/* !CONFIG_X86_64 */
+
+/* dump the cpu state and registers of a given task */
+int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_cpu *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CPU);
+	if (!h)
+		return -ENOMEM;
+
+	save_cpu_regs(h, t);
+	save_cpu_debug(h, t);
+	save_cpu_fpu(h, t);
+
+	ckpt_debug("math %d debug %d\n", h->used_math, h->uses_debug);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	if (h->used_math)
+		ret = checkpoint_cpu_fpu(ctx, t);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int checkpoint_write_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_HEADER_ARCH);
+	if (!h)
+		return -ENOMEM;
+
+	/* FPU capabilities */
+	h->has_fxsr = cpu_has_fxsr;
+	h->has_xsave = cpu_has_xsave;
+	h->xstate_size = xstate_size;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+/**************************************************************************
+ * Restart
+ */
+
+/* read the thread_struct into the current task */
+int restore_thread(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_thread *h;
+	struct task_struct *t = current;
+	struct thread_struct *thread = &t->thread;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_THREAD);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ckpt_debug("ntls %d\n", h->ntls);
+
+	ret = -EINVAL;
+	if (h->gdt_entry_tls_entries != GDT_ENTRY_TLS_ENTRIES ||
+	    h->sizeof_tls_array != sizeof(thread->tls_array) ||
+	    h->ntls > GDT_ENTRY_TLS_ENTRIES)
+		goto out;
+
+	if (h->ntls > 0) {
+		struct ckpt_hdr *hh;
+		int size, cpu;
+
+		/*
+		 * restore TLS by hand: why convert to struct user_desc if
+		 * sys_set_thread_entry() will convert it back ?
+		 */
+
+		size = sizeof(struct desc_struct) * GDT_ENTRY_TLS_ENTRIES;
+		hh = ckpt_read_obj_type(ctx, size + sizeof(*hh),
+					CKPT_HDR_THREAD_TLS);
+		if (IS_ERR(hh)) {
+			ret = PTR_ERR(hh);
+			goto out;
+		}
+
+		/* TODO: ADD SANITY CHECKS TO VERIFY VALIDITY OF VALUES */
+		cpu = get_cpu();
+		memcpy(thread->tls_array, hh + 1, size);
+		load_TLS(thread, cpu);
+		put_cpu();
+
+		ckpt_hdr_put(ctx, hh);
+	}
+
+	ret = 0;
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+#ifndef CONFIG_X86_64
+
+static int load_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
+
+	/* TODO: ADD SANITY CHECKS TO VERIFY VALIDITY OF VALUES */
+	regs->bx = h->bx;
+	regs->cx = h->cx;
+	regs->dx = h->dx;
+	regs->si = h->si;
+	regs->di = h->di;
+	regs->bp = h->bp;
+	regs->ax = h->ax;
+	regs->ds = h->ds;
+	regs->es = h->es;
+	regs->orig_ax = h->orig_ax;
+	regs->ip = h->ip;
+	regs->cs = h->cs;
+	regs->flags = h->flags;
+	regs->sp = h->sp;
+	regs->ss = h->ss;
+
+	thread->gs = h->gs;
+	thread->fs = h->fs;
+	loadsegment(gs, h->gs);
+	loadsegment(fs, h->fs);
+
+	return 0;
+}
+
+static int load_cpu_debug(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	/* TODO: ADD SANITY CHECKS TO VERIFY VALIDITY OF VALUES */
+	if (h->uses_debug) {
+		set_debugreg(h->debugreg0, 0);
+		set_debugreg(h->debugreg1, 1);
+		/* ignore 4, 5 */
+		set_debugreg(h->debugreg2, 2);
+		set_debugreg(h->debugreg3, 3);
+		set_debugreg(h->debugreg6, 6);
+		set_debugreg(h->debugreg7, 7);
+	}
+
+	return 0;
+}
+
+static int load_cpu_fpu(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	preempt_disable();
+
+	__clear_fpu(t);		/* in case we used FPU in user mode */
+
+	if (!h->used_math)
+		clear_used_math();
+
+	preempt_enable();
+	return 0;
+}
+
+static int restore_cpu_fpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr *h;
+	int ret;
+
+	/* init_fpu() eventually also calls set_used_math() */
+	ret = init_fpu(current);
+	if (ret < 0)
+		return ret;
+
+	h = ckpt_read_obj_type(ctx, xstate_size + sizeof(*h),
+			       CKPT_HDR_CPU_FPU);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	memcpy(t->thread.xstate, h + 1, xstate_size);
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+#endif	/* !CONFIG_X86_64 */
+
+/* read the cpu state and registers for the current task */
+int restore_cpu(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_cpu *h;
+	struct task_struct *t = current;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CPU);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ckpt_debug("math %d debug %d\n", h->used_math, h->uses_debug);
+
+	ret = load_cpu_regs(h, t);
+	if (ret < 0)
+		goto out;
+	ret = load_cpu_debug(h, t);
+	if (ret < 0)
+		goto out;
+	ret = load_cpu_fpu(h, t);
+	if (ret < 0)
+		goto out;
+
+	if (h->used_math)
+		ret = restore_cpu_fpu(ctx, t);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int restore_read_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *h;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_HEADER_ARCH);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	/* FIX: verify compatibility of architecture features */
+
+	/* verify FPU capabilities */
+	if (h->has_fxsr != cpu_has_fxsr ||
+	    h->has_xsave != cpu_has_xsave ||
+	    h->xstate_size != xstate_size)
+		ret = -EINVAL;
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 56b690a..409c78b 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -190,6 +190,8 @@ static int checkpoint_write_header(struct ckpt_ctx *ctx)
 	do_gettimeofday(&ktv);
 	uts = utsname();
 
+	h->arch_id = cpu_to_le16(CKPT_ARCH_ID);  /* see asm/checkpoitn.h */
+
 	h->magic = CHECKPOINT_MAGIC_HEAD;
 	h->major = (LINUX_VERSION_CODE >> 16) & 0xff;
 	h->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
@@ -219,7 +221,10 @@ static int checkpoint_write_header(struct ckpt_ctx *ctx)
 	ret = ckpt_write_buffer(ctx, uts->machine, sizeof(uts->machine));
  up:
 	up_read(&uts_sem);
-	return ret;
+	if (ret < 0)
+		return ret;
+
+	return checkpoint_write_header_arch(ctx);
 }
 
 /* write the checkpoint trailer */
diff --git a/checkpoint/process.c b/checkpoint/process.c
index c2b7564..6cab717 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -53,7 +53,15 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	ret = checkpoint_task_struct(ctx, t);
 	ckpt_debug("task %d\n", ret);
-
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_thread(ctx, t);
+	ckpt_debug("thread %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_cpu(ctx, t);
+	ckpt_debug("cpu %d\n", ret);
+ out:
 	return ret;
 }
 
@@ -92,6 +100,14 @@ int restore_task(struct ckpt_ctx *ctx)
 
 	ret = restore_task_struct(ctx);
 	ckpt_debug("task %d\n", ret);
-
+	if (ret < 0)
+		goto out;
+	ret = restore_thread(ctx);
+	ckpt_debug("thread %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_cpu(ctx);
+	ckpt_debug("cpu %d\n", ret);
+ out:
 	return ret;
 }
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index a6f73d3..e839538 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -248,6 +248,8 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 		return PTR_ERR(h);
 
 	ret = -EINVAL;
+	if (le16_to_cpu(h->arch_id) != CKPT_ARCH_ID)
+		goto out;
 	if (h->magic != CHECKPOINT_MAGIC_HEAD ||
 	    h->rev != CHECKPOINT_VERSION ||
 	    h->major != ((LINUX_VERSION_CODE >> 16) & 0xff) ||
@@ -276,6 +278,10 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		goto out;
 	ret = _ckpt_read_buffer(ctx, uts->machine, sizeof(uts->machine));
+	if (ret < 0)
+		goto out;
+
+	ret = restore_read_header_arch(ctx);
  out:
 	kfree(uts);
 	ckpt_hdr_put(ctx, h);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 14da928..6247114 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -12,6 +12,7 @@
 
 #include <linux/checkpoint_types.h>
 #include <linux/checkpoint_hdr.h>
+#include <asm/checkpoint_hdr.h>
 
 extern int ckpt_kwrite(struct ckpt_ctx *ctx, void *buf, int count);
 extern int ckpt_kread(struct ckpt_ctx *ctx, void *buf, int count);
@@ -43,6 +44,15 @@ extern int do_restart(struct ckpt_ctx *ctx, pid_t pid);
 extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_task(struct ckpt_ctx *ctx);
 
+/* arch hooks */
+extern int checkpoint_write_header_arch(struct ckpt_ctx *ctx);
+extern int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t);
+
+extern int restore_read_header_arch(struct ckpt_ctx *ctx);
+extern int restore_thread(struct ckpt_ctx *ctx);
+extern int restore_cpu(struct ckpt_ctx *ctx);
+
 
 /* debugging flags */
 #define CKPT_DBASE	0x1		/* anything */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index c9a1653..a0c576c 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -41,22 +41,32 @@ struct ckpt_hdr {
 /* header types */
 enum {
 	CKPT_HDR_HEADER = 1,
+	CKPT_HDR_HEADER_ARCH,
 	CKPT_HDR_BUFFER,
 	CKPT_HDR_STRING,
 
 	CKPT_HDR_TASK = 101,
+	CKPT_HDR_THREAD,
+	CKPT_HDR_CPU,
+
+	/* 201-299: reserved for arch-dependent */
 
 	CKPT_HDR_TAIL = 9001,
 
 	CKPT_HDR_ERROR = 9999,
 };
 
+/* architecture */
+enum {
+	CKPT_ARCH_X86_32 = 1,
+};
+
 /* checkpoint image header */
 struct ckpt_hdr_header {
 	struct ckpt_hdr h;
 	__u64 magic;
 
-	__u16 _padding;
+	__u16 arch_id;
 
 	__u16 major;
 	__u16 minor;
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
