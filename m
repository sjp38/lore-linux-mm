From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v9][PATCH 04/13] x86 support for checkpoint/restart
Date: Mon, 10 Nov 2008 11:37:31 -0500
Message-Id: <1226335060-7061-5-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1226335060-7061-1-git-send-email-orenl@cs.columbia.edu>
References: <1226335060-7061-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Add logic to save and restore architecture specific state, including
thread-specific state, CPU registers and FPU state.

In addition, architecture capabilities are saved in an architecure
specific extension of the header (cr_hdr_head_arch); Currently this
includes only FPU capabilities.

Currently only x86-32 is supported. Compiling on x86-64 will trigger
an explicit error.

Changelog[v9]:
  - Add arch-specific header that details architecture capabilities;
    split FPU restore to send capabilities only once.
  - Test for zero TLS entries in cr_write_thread()
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
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 arch/x86/include/asm/checkpoint_hdr.h |   85 ++++++++++++
 arch/x86/mm/Makefile                  |    2 +
 arch/x86/mm/checkpoint.c              |  223 +++++++++++++++++++++++++++++++
 arch/x86/mm/restart.c                 |  232 +++++++++++++++++++++++++++++++++
 checkpoint/checkpoint.c               |   19 +++-
 checkpoint/checkpoint_arch.h          |    9 ++
 checkpoint/restart.c                  |   17 ++-
 include/linux/checkpoint_hdr.h        |    2 +
 8 files changed, 583 insertions(+), 6 deletions(-)
 create mode 100644 arch/x86/include/asm/checkpoint_hdr.h
 create mode 100644 arch/x86/mm/checkpoint.c
 create mode 100644 arch/x86/mm/restart.c
 create mode 100644 checkpoint/checkpoint_arch.h

diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
new file mode 100644
index 0000000..6325062
--- /dev/null
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -0,0 +1,85 @@
+#ifndef __ASM_X86_CKPT_HDR_H
+#define __ASM_X86_CKPT_HDR_H
+/*
+ *  Checkpoint/restart - architecture specific headers x86
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/types.h>
+
+/* i387 structure seen from kernel/userspace */
+#ifdef __KERNEL__
+#include <asm/processor.h>
+#else
+#include <sys/user.h>
+#endif
+
+struct cr_hdr_head_arch {
+	/* FIXME: add HAVE_HWFP */
+
+	__u16 has_fxsr;
+	__u16 has_xsave;
+	__u16 xstate_size;
+	__u16 _pading;
+} __attribute__((aligned(8)));
+
+struct cr_hdr_thread {
+	/* FIXME: restart blocks */
+
+	__s16 gdt_entry_tls_entries;
+	__s16 sizeof_tls_array;
+	__s16 ntls;	/* number of TLS entries to follow */
+} __attribute__((aligned(8)));
+
+struct cr_hdr_cpu {
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
+	__u64 debugreg4;
+	__u64 debugreg5;
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
index 59f89b4..7d5e2ce 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -18,3 +18,5 @@ obj-$(CONFIG_K8_NUMA)		+= k8topology_64.o
 obj-$(CONFIG_ACPI_NUMA)		+= srat_$(BITS).o
 
 obj-$(CONFIG_MEMTEST)		+= memtest.o
+
+obj-$(CONFIG_CHECKPOINT_RESTART) += checkpoint.o restart.o
diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
new file mode 100644
index 0000000..8dd6d2d
--- /dev/null
+++ b/arch/x86/mm/checkpoint.c
@@ -0,0 +1,223 @@
+/*
+ *  Checkpoint/restart - architecture specific support for x86
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <asm/desc.h>
+#include <asm/i387.h>
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/* dump the thread_struct of a given task */
+int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_thread *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct thread_struct *thread;
+	struct desc_struct *desc;
+	int ntls = 0;
+	int n, ret;
+
+	h.type = CR_HDR_THREAD;
+	h.len = sizeof(*hh);
+	h.parent = task_pid_vnr(t);
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
+	hh->gdt_entry_tls_entries = GDT_ENTRY_TLS_ENTRIES;
+	hh->sizeof_tls_array = sizeof(thread->tls_array);
+	hh->ntls = ntls;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		return ret;
+
+	cr_debug("ntls %d\n", ntls);
+	if (ntls == 0)
+		return 0;
+
+	/* for simplicity dump the entire array, cherry-pick upon restart */
+	ret = cr_kwrite(ctx, thread->tls_array, sizeof(thread->tls_array));
+
+	/* IGNORE RESTART BLOCKS FOR NOW ... */
+
+	return ret;
+}
+
+#ifdef CONFIG_X86_64
+
+#error "CONFIG_X86_64 unsupported yet."
+
+#else	/* !CONFIG_X86_64 */
+
+static void cr_save_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
+
+	hh->bp = regs->bp;
+	hh->bx = regs->bx;
+	hh->ax = regs->ax;
+	hh->cx = regs->cx;
+	hh->dx = regs->dx;
+	hh->si = regs->si;
+	hh->di = regs->di;
+	hh->orig_ax = regs->orig_ax;
+	hh->ip = regs->ip;
+	hh->cs = regs->cs;
+	hh->flags = regs->flags;
+	hh->sp = regs->sp;
+	hh->ss = regs->ss;
+
+	hh->ds = regs->ds;
+	hh->es = regs->es;
+
+	/*
+	 * for checkpoint in process context (from within a container)
+	 * the GS and FS registers should be saved from the hardware;
+	 * otherwise they are already sabed on the thread structure
+	 */
+	if (t == current) {
+		savesegment(gs, hh->gs);
+		savesegment(fs, hh->fs);
+	} else {
+		hh->gs = thread->gs;
+		hh->fs = thread->fs;
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
+		BUG_ON(hh->orig_ax < 0);
+		hh->ax = 0;
+	}
+}
+
+static void cr_save_cpu_debug(struct cr_hdr_cpu *hh, struct task_struct *t)
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
+		get_debugreg(hh->debugreg0, 0);
+		get_debugreg(hh->debugreg1, 1);
+		get_debugreg(hh->debugreg2, 2);
+		get_debugreg(hh->debugreg3, 3);
+		get_debugreg(hh->debugreg6, 6);
+		get_debugreg(hh->debugreg7, 7);
+	} else {
+		hh->debugreg0 = thread->debugreg0;
+		hh->debugreg1 = thread->debugreg1;
+		hh->debugreg2 = thread->debugreg2;
+		hh->debugreg3 = thread->debugreg3;
+		hh->debugreg6 = thread->debugreg6;
+		hh->debugreg7 = thread->debugreg7;
+	}
+
+	hh->debugreg4 = 0;
+	hh->debugreg5 = 0;
+
+	hh->uses_debug = !!(task_thread_info(t)->flags & TIF_DEBUG);
+}
+
+static void cr_save_cpu_fpu(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	hh->used_math = tsk_used_math(t) ? 1 : 0;
+}
+
+static int cr_write_cpu_fpu(struct cr_ctx *ctx, struct task_struct *t)
+{
+	void *xstate_buf = cr_hbuf_get(ctx, xstate_size);
+
+	/* i387 + MMU + SSE logic */
+	preempt_disable();	/* needed it (t == current) */
+
+	/*
+	 * normally, no need to unlazy_fpu(), since TS_USEDFPU flag
+	 * have been cleared when task was context-switched out...
+	 * except if we are in process context, in which case we do
+	 */
+	if (t == current && (task_thread_info(t)->status & TS_USEDFPU))
+		unlazy_fpu(current);
+
+	memcpy(xstate_buf, t->thread.xstate, xstate_size);
+	preempt_enable();	/* needed it (t == current) */
+
+	return cr_kwrite(ctx, xstate_buf, xstate_size);
+}
+
+#endif	/* CONFIG_X86_64 */
+
+/* dump the cpu state and registers of a given task */
+int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_cpu *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int ret;
+
+	h.type = CR_HDR_CPU;
+	h.len = sizeof(*hh);
+	h.parent = task_pid_vnr(t);
+
+	cr_save_cpu_regs(hh, t);
+	cr_save_cpu_debug(hh, t);
+	cr_save_cpu_fpu(hh, t);
+
+	cr_debug("math %d debug %d\n", hh->used_math, hh->uses_debug);
+
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret < 0)
+		goto out;
+
+	if (hh->used_math)
+		ret = cr_write_cpu_fpu(ctx, t);
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+int cr_write_head_arch(struct cr_ctx *ctx)
+{
+	struct cr_hdr h;
+	struct cr_hdr_head_arch *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int ret;
+
+	h.type = CR_HDR_HEAD_ARCH;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	/* FPU capabilities */
+	hh->has_fxsr = cpu_has_fxsr;
+	hh->has_xsave = cpu_has_xsave;
+	hh->xstate_size = xstate_size;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
diff --git a/arch/x86/mm/restart.c b/arch/x86/mm/restart.c
new file mode 100644
index 0000000..45ad790
--- /dev/null
+++ b/arch/x86/mm/restart.c
@@ -0,0 +1,232 @@
+/*
+ *  Checkpoint/restart - architecture specific support for x86
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <asm/desc.h>
+#include <asm/i387.h>
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/* read the thread_struct into the current task */
+int cr_read_thread(struct cr_ctx *ctx)
+{
+	struct cr_hdr_thread *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct task_struct *t = current;
+	struct thread_struct *thread = &t->thread;
+	int parent, ret;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_THREAD);
+	if (parent < 0) {
+		ret = parent;
+		goto out;
+	}
+
+	ret = -EINVAL;
+
+#if 0	/* activate when containers are used */
+	if (parent != task_pid_vnr(t))
+		goto out;
+#endif
+	cr_debug("ntls %d\n", hh->ntls);
+
+	if (hh->gdt_entry_tls_entries != GDT_ENTRY_TLS_ENTRIES ||
+	    hh->sizeof_tls_array != sizeof(thread->tls_array) ||
+	    hh->ntls < 0 || hh->ntls > GDT_ENTRY_TLS_ENTRIES)
+		goto out;
+
+	if (hh->ntls > 0) {
+		struct desc_struct *desc;
+		int size, cpu;
+
+		/*
+		 * restore TLS by hand: why convert to struct user_desc if
+		 * sys_set_thread_entry() will convert it back ?
+		 */
+
+		size = sizeof(*desc) * GDT_ENTRY_TLS_ENTRIES;
+		desc = kmalloc(size, GFP_KERNEL);
+		if (!desc)
+			return -ENOMEM;
+
+		ret = cr_kread(ctx, desc, size);
+		if (ret >= 0) {
+			/*
+			 * FIX: add sanity checks (eg. that values makes
+			 * sense, that we don't overwrite old values, etc
+			 */
+			cpu = get_cpu();
+			memcpy(thread->tls_array, desc, size);
+			load_TLS(thread, cpu);
+			put_cpu();
+		}
+		kfree(desc);
+	}
+
+	ret = 0;
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+#ifdef CONFIG_X86_64
+
+#error "CONFIG_X86_64 unsupported yet."
+
+#else	/* !CONFIG_X86_64 */
+
+static int cr_load_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
+
+	regs->bx = hh->bx;
+	regs->cx = hh->cx;
+	regs->dx = hh->dx;
+	regs->si = hh->si;
+	regs->di = hh->di;
+	regs->bp = hh->bp;
+	regs->ax = hh->ax;
+	regs->ds = hh->ds;
+	regs->es = hh->es;
+	regs->orig_ax = hh->orig_ax;
+	regs->ip = hh->ip;
+	regs->cs = hh->cs;
+	regs->flags = hh->flags;
+	regs->sp = hh->sp;
+	regs->ss = hh->ss;
+
+	thread->gs = hh->gs;
+	thread->fs = hh->fs;
+	loadsegment(gs, hh->gs);
+	loadsegment(fs, hh->fs);
+
+	return 0;
+}
+
+static int cr_load_cpu_debug(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	/* debug regs */
+
+	if (hh->uses_debug) {
+		set_debugreg(hh->debugreg0, 0);
+		set_debugreg(hh->debugreg1, 1);
+		/* ignore 4, 5 */
+		set_debugreg(hh->debugreg2, 2);
+		set_debugreg(hh->debugreg3, 3);
+		set_debugreg(hh->debugreg6, 6);
+		set_debugreg(hh->debugreg7, 7);
+	}
+
+	return 0;
+}
+
+static int cr_load_cpu_fpu(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	preempt_disable();
+
+	__clear_fpu(t);		/* in case we used FPU in user mode */
+
+	if (!hh->used_math)
+		clear_used_math();
+
+	preempt_enable();
+	return 0;
+}
+
+static int cr_read_cpu_fpu(struct cr_ctx *ctx, struct task_struct *t)
+{
+	void *xstate_buf = cr_hbuf_get(ctx, xstate_size);
+	int ret;
+
+	ret = cr_kread(ctx, xstate_buf, xstate_size);
+	if (ret < 0)
+		goto out;
+
+	/* i387 + MMU + SSE */
+	preempt_disable();
+
+	/* init_fpu() also calls set_used_math() */
+	ret = init_fpu(current);
+	if (ret < 0)
+		return ret;
+
+	memcpy(t->thread.xstate, xstate_buf, xstate_size);
+	preempt_enable();
+ out:
+	cr_hbuf_put(ctx, xstate_size);
+	return 0;
+}
+
+#endif	/* CONFIG_X86_64 */
+
+/* read the cpu state and registers for the current task */
+int cr_read_cpu(struct cr_ctx *ctx)
+{
+	struct cr_hdr_cpu *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct task_struct *t = current;
+	int parent, ret;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_CPU);
+	if (parent < 0) {
+		ret = parent;
+		goto out;
+	}
+
+	ret = -EINVAL;
+
+#if 0	/* activate when containers are used */
+	if (parent != task_pid_vnr(t))
+		goto out;
+#endif
+	/* FIX: sanity check for sensitive registers (eg. eflags) */
+
+	cr_debug("math %d debug %d\n", hh->used_math, hh->uses_debug);
+
+	ret = cr_load_cpu_regs(hh, t);
+	if (ret < 0)
+		goto out;
+	ret = cr_load_cpu_debug(hh, t);
+	if (ret < 0)
+		goto out;
+	ret = cr_load_cpu_fpu(hh, t);
+	if (ret < 0)
+		goto out;
+
+	if (hh->used_math)
+		ret = cr_read_cpu_fpu(ctx, t);
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+int cr_read_head_arch(struct cr_ctx *ctx)
+{
+	struct cr_hdr_head_arch *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int parent, ret = 0;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_HEAD_ARCH);
+	if (parent < 0) {
+		ret = parent;
+		goto out;
+	} else if (parent != 0)
+		goto out;
+
+	/* FIX: verify compatibility of architecture features */
+
+	/* verify FPU capabilities */
+	if (hh->has_fxsr != cpu_has_fxsr ||
+	    hh->has_xsave != cpu_has_xsave ||
+	    hh->xstate_size != xstate_size)
+		ret = -EINVAL;
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 71f761e..2948e2e 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -20,6 +20,8 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
+#include "checkpoint_arch.h"
+
 /* unique checkpoint identifier (FIXME: should be per-container ?) */
 static atomic_t cr_ctx_count = ATOMIC_INIT(0);
 
@@ -88,7 +90,10 @@ static int cr_write_head(struct cr_ctx *ctx)
 
 	ret = cr_write_obj(ctx, &h, hh);
 	cr_hbuf_put(ctx, sizeof(*hh));
-	return ret;
+	if (ret < 0)
+		return ret;
+
+	return cr_write_head_arch(ctx);
 }
 
 /* write the checkpoint trailer */
@@ -143,8 +148,16 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 	int ret;
 
 	ret = cr_write_task_struct(ctx, t);
-	cr_debug("ret %d\n", ret);
-
+	cr_debug("task_struct: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = cr_write_thread(ctx, t);
+	cr_debug("thread: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = cr_write_cpu(ctx, t);
+	cr_debug("cpu: ret %d\n", ret);
+ out:
 	return ret;
 }
 
diff --git a/checkpoint/checkpoint_arch.h b/checkpoint/checkpoint_arch.h
new file mode 100644
index 0000000..ada1369
--- /dev/null
+++ b/checkpoint/checkpoint_arch.h
@@ -0,0 +1,9 @@
+#include <linux/checkpoint.h>
+
+extern int cr_write_head_arch(struct cr_ctx *ctx);
+extern int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t);
+extern int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t);
+
+extern int cr_read_head_arch(struct cr_ctx *ctx);
+extern int cr_read_thread(struct cr_ctx *ctx);
+extern int cr_read_cpu(struct cr_ctx *ctx);
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index fbfa52e..56bab40 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -15,6 +15,8 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
+#include "checkpoint_arch.h"
+
 /**
  * cr_read_obj - read a whole record (cr_hdr followed by payload)
  * @ctx: checkpoint context
@@ -100,9 +102,9 @@ static int cr_read_head(struct cr_ctx *ctx)
 
 	ctx->oflags = hh->flags;
 
-	/* FIX: verify compatibility of release, version and machine */
+	/* FIX: verify compatibility of release, version */
 
-	ret = 0;
+	ret = cr_read_head_arch(ctx);
  out:
 	cr_hbuf_put(ctx, sizeof(*hh));
 	return ret;
@@ -172,8 +174,17 @@ static int cr_read_task(struct cr_ctx *ctx)
 	int ret;
 
 	ret = cr_read_task_struct(ctx);
-	cr_debug("ret %d\n", ret);
+	cr_debug("task_struct: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = cr_read_thread(ctx);
+	cr_debug("thread: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = cr_read_cpu(ctx);
+	cr_debug("cpu: ret %d\n", ret);
 
+ out:
 	return ret;
 }
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 79e4df2..a410416 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -12,6 +12,7 @@
 
 #include <linux/types.h>
 #include <linux/utsname.h>
+#include <asm/checkpoint_hdr.h>
 
 /*
  * To maintain compatibility between 32-bit and 64-bit architecture flavors,
@@ -30,6 +31,7 @@ struct cr_hdr {
 /* header types */
 enum {
 	CR_HDR_HEAD = 1,
+	CR_HDR_HEAD_ARCH,
 	CR_HDR_STRING,
 
 	CR_HDR_TASK = 101,
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
