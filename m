Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9GIDvhg023504
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 12:13:57 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9GIEMBe146100
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 12:14:22 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9GIEKGK009765
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 12:14:21 -0600
Subject: [PATCH 3/9] x86 support for checkpoint/restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Thu, 16 Oct 2008 11:14:18 -0700
References: <20081016181414.934C4FCC@kernel>
In-Reply-To: <20081016181414.934C4FCC@kernel>
Message-Id: <20081016181418.4DB75FEB@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, containers <containers@lists.linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Serge E. Hallyn" <serue@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Oren Laadan <orenl@cs.columbia.edu>

(Following Dave Hansen's refactoring of the original post)

Add logic to save and restore architecture specific state, including
thread-specific state, CPU registers and FPU state.

Currently only x86-32 is supported. Compiling on x86-64 will trigger
an explicit error.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/arch/x86/mm/Makefile             |    2 
 linux-2.6.git-dave/arch/x86/mm/checkpoint.c         |  198 ++++++++++++++++++++
 linux-2.6.git-dave/arch/x86/mm/restart.c            |  190 +++++++++++++++++++
 linux-2.6.git-dave/checkpoint/checkpoint.c          |   13 +
 linux-2.6.git-dave/checkpoint/checkpoint_arch.h     |    7 
 linux-2.6.git-dave/checkpoint/restart.c             |   13 +
 linux-2.6.git-dave/include/asm-x86/checkpoint_hdr.h |   72 +++++++
 linux-2.6.git-dave/include/linux/checkpoint_hdr.h   |    1 
 8 files changed, 494 insertions(+), 2 deletions(-)

diff -puN /dev/null arch/x86/mm/checkpoint.c
--- /dev/null	2008-09-02 09:40:19.000000000 -0700
+++ linux-2.6.git-dave/arch/x86/mm/checkpoint.c	2008-10-16 10:53:35.000000000 -0700
@@ -0,0 +1,198 @@
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
+	/* for simplicity dump the entire array, cherry-pick upon restart */
+	ret = cr_kwrite(ctx, thread->tls_array, sizeof(thread->tls_array));
+
+	cr_debug("ntls %d\n", ntls);
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
+void cr_write_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
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
+void cr_write_cpu_debug(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+
+	/* debug regs */
+
+	preempt_disable();
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
+
+	preempt_enable();
+}
+
+void cr_write_cpu_fpu(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct thread_info *thread_info = task_thread_info(t);
+
+	/* i387 + MMU + SSE logic */
+
+	preempt_disable();
+
+	hh->used_math = tsk_used_math(t) ? 1 : 0;
+	if (hh->used_math) {
+		/*
+		 * normally, no need to unlazy_fpu(), since TS_USEDFPU flag
+		 * have been cleared when task was conexted-switched out...
+		 * except if we are in process context, in which case we do
+		 */
+		if (thread_info->status & TS_USEDFPU)
+			unlazy_fpu(current);
+
+		hh->has_fxsr = cpu_has_fxsr;
+		memcpy(&hh->xstate, &thread->xstate, sizeof(thread->xstate));
+	}
+
+	preempt_enable();
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
+	cr_write_cpu_regs(hh, t);
+	cr_write_cpu_debug(hh, t);
+	cr_write_cpu_fpu(hh, t);
+
+	cr_debug("math %d debug %d\n", hh->used_math, hh->uses_debug);
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
diff -puN arch/x86/mm/Makefile~v6_PATCH_3_9_x86_support_for_checkpoint_restart arch/x86/mm/Makefile
--- linux-2.6.git/arch/x86/mm/Makefile~v6_PATCH_3_9_x86_support_for_checkpoint_restart	2008-10-16 10:53:35.000000000 -0700
+++ linux-2.6.git-dave/arch/x86/mm/Makefile	2008-10-16 10:53:35.000000000 -0700
@@ -18,3 +18,5 @@ obj-$(CONFIG_K8_NUMA)		+= k8topology_64.
 obj-$(CONFIG_ACPI_NUMA)		+= srat_$(BITS).o
 
 obj-$(CONFIG_MEMTEST)		+= memtest.o
+
+obj-$(CONFIG_CHECKPOINT_RESTART) += checkpoint.o restart.o
diff -puN /dev/null arch/x86/mm/restart.c
--- /dev/null	2008-09-02 09:40:19.000000000 -0700
+++ linux-2.6.git-dave/arch/x86/mm/restart.c	2008-10-16 10:53:35.000000000 -0700
@@ -0,0 +1,190 @@
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
+int cr_read_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
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
+int cr_read_cpu_debug(struct cr_hdr_cpu *hh, struct task_struct *t)
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
+int cr_read_cpu_fpu(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+
+	/* i387 + MMU + SSE */
+
+	preempt_disable();
+
+	__clear_fpu(t);		/* in case we used FPU in user mode */
+
+	if (!hh->used_math)
+		clear_used_math();
+	else {
+		if (hh->has_fxsr != cpu_has_fxsr) {
+			force_sig(SIGFPE, t);
+			return -EINVAL;
+		}
+		memcpy(&thread->xstate, &hh->xstate, sizeof(thread->xstate));
+		set_used_math();
+	}
+
+	preempt_enable();
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
+	ret = cr_read_cpu_regs(hh, t);
+	if (ret < 0)
+		goto out;
+	ret = cr_read_cpu_debug(hh, t);
+	if (ret < 0)
+		goto out;
+	ret = cr_read_cpu_fpu(hh, t);
+
+	cr_debug("math %d debug %d\n", hh->used_math, hh->uses_debug);
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
diff -puN /dev/null checkpoint/checkpoint_arch.h
--- /dev/null	2008-09-02 09:40:19.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/checkpoint_arch.h	2008-10-16 10:53:35.000000000 -0700
@@ -0,0 +1,7 @@
+#include <linux/checkpoint.h>
+
+extern int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t);
+extern int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t);
+
+extern int cr_read_thread(struct cr_ctx *ctx);
+extern int cr_read_cpu(struct cr_ctx *ctx);
diff -puN checkpoint/checkpoint.c~v6_PATCH_3_9_x86_support_for_checkpoint_restart checkpoint/checkpoint.c
--- linux-2.6.git/checkpoint/checkpoint.c~v6_PATCH_3_9_x86_support_for_checkpoint_restart	2008-10-16 10:53:35.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/checkpoint.c	2008-10-16 10:53:35.000000000 -0700
@@ -20,6 +20,8 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
+#include "checkpoint_arch.h"
+
 /**
  * cr_write_obj - write a record described by a cr_hdr
  * @ctx: checkpoint context
@@ -145,8 +147,17 @@ static int cr_write_task(struct cr_ctx *
 	}
 
 	ret = cr_write_task_struct(ctx, t);
-	cr_debug("ret %d\n", ret);
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
 
diff -puN checkpoint/restart.c~v6_PATCH_3_9_x86_support_for_checkpoint_restart checkpoint/restart.c
--- linux-2.6.git/checkpoint/restart.c~v6_PATCH_3_9_x86_support_for_checkpoint_restart	2008-10-16 10:53:35.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/restart.c	2008-10-16 10:53:35.000000000 -0700
@@ -15,6 +15,8 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
+#include "checkpoint_arch.h"
+
 /**
  * cr_read_obj - read a whole record (cr_hdr followed by payload)
  * @ctx: checkpoint context
@@ -172,8 +174,17 @@ static int cr_read_task(struct cr_ctx *c
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
 
diff -puN /dev/null include/asm-x86/checkpoint_hdr.h
--- /dev/null	2008-09-02 09:40:19.000000000 -0700
+++ linux-2.6.git-dave/include/asm-x86/checkpoint_hdr.h	2008-10-16 10:53:35.000000000 -0700
@@ -0,0 +1,72 @@
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
+#include <asm/processor.h>
+
+struct cr_hdr_thread {
+	/* NEED: restart blocks */
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
+	__u16 uses_debug;
+	__u16 used_math;
+	__u16 has_fxsr;
+	__u16 _padding;
+
+	union thread_xstate xstate;	/* i387 */
+
+} __attribute__((aligned(8)));
+
+#endif /* __ASM_X86_CKPT_HDR__H */
diff -puN include/linux/checkpoint_hdr.h~v6_PATCH_3_9_x86_support_for_checkpoint_restart include/linux/checkpoint_hdr.h
--- linux-2.6.git/include/linux/checkpoint_hdr.h~v6_PATCH_3_9_x86_support_for_checkpoint_restart	2008-10-16 10:53:35.000000000 -0700
+++ linux-2.6.git-dave/include/linux/checkpoint_hdr.h	2008-10-16 10:53:35.000000000 -0700
@@ -12,6 +12,7 @@
 
 #include <linux/types.h>
 #include <linux/utsname.h>
+#include <asm/checkpoint_hdr.h>
 
 /*
  * To maintain compatibility between 32-bit and 64-bit architecture flavors,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
