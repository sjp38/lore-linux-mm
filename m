Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC906B0089
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:32 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 21/80] c/r: x86_32 support for checkpoint/restart
Date: Wed, 23 Sep 2009 19:51:01 -0400
Message-Id: <1253749920-18673-22-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Add logic to save and restore architecture specific state, including
thread-specific state, CPU registers and FPU state.

In addition, architecture capabilities are saved in an architecure
specific extension of the header (ckpt_hdr_head_arch); Currently this
includes only FPU capabilities.

Currently only x86-32 is supported.

Changelog[v17]:
  - Fix compilation for architectures that don't support checkpoint
  - Validate cpu registers and TLS descriptors on restart
  - Validate debug registers on restart
  - Export asm/checkpoint_hdr.h to userspace
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
 arch/x86/include/asm/Kbuild           |    1 +
 arch/x86/include/asm/checkpoint_hdr.h |  121 ++++++++
 arch/x86/include/asm/ptrace.h         |    5 +
 arch/x86/kernel/ptrace.c              |    8 +-
 arch/x86/mm/Makefile                  |    2 +
 arch/x86/mm/checkpoint.c              |  531 +++++++++++++++++++++++++++++++++
 checkpoint/checkpoint.c               |    7 +-
 checkpoint/process.c                  |   19 ++-
 checkpoint/restart.c                  |    6 +
 include/linux/checkpoint.h            |    9 +
 include/linux/checkpoint_hdr.h        |   16 +-
 11 files changed, 718 insertions(+), 7 deletions(-)
 create mode 100644 arch/x86/include/asm/checkpoint_hdr.h
 create mode 100644 arch/x86/mm/checkpoint.c

diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
index 4a8e80c..f76cb6e 100644
--- a/arch/x86/include/asm/Kbuild
+++ b/arch/x86/include/asm/Kbuild
@@ -2,6 +2,7 @@ include include/asm-generic/Kbuild.asm
 
 header-y += boot.h
 header-y += bootparam.h
+header-y += checkpoint_hdr.h
 header-y += debugreg.h
 header-y += ldt.h
 header-y += msr-index.h
diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
new file mode 100644
index 0000000..f4d1e14
--- /dev/null
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -0,0 +1,121 @@
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
+#ifndef _CHECKPOINT_CKPT_HDR_H_
+#error asm/checkpoint_hdr.h included directly
+#endif
+
+#include <linux/types.h>
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
+#ifdef CONFIG_X86_32
+#define CKPT_ARCH_ID	CKPT_ARCH_X86_32
+#endif
+
+/* arch dependent header types */
+enum {
+	CKPT_HDR_CPU_FPU = 201,
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
+	__u32 thread_info_flags;
+	__u16 gdt_entry_tls_entries;
+	__u16 sizeof_tls_array;
+} __attribute__((aligned(8)));
+
+/* designed to work for both x86_32 and x86_64 */
+struct ckpt_hdr_cpu {
+	struct ckpt_hdr h;
+	/* see struct pt_regs (x86_64) */
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
+	__u64 sp;
+
+	__u64 flags;
+
+	/* segment registers */
+	__u64 fs;
+	__u64 gs;
+
+	__u16 fsindex;
+	__u16 gsindex;
+	__u16 cs;
+	__u16 ss;
+	__u16 ds;
+	__u16 es;
+
+	__u32 used_math;
+
+	/* debug registers */
+	__u64 debugreg0;
+	__u64 debugreg1;
+	__u64 debugreg2;
+	__u64 debugreg3;
+	__u64 debugreg6;
+	__u64 debugreg7;
+
+	/* thread_xstate contents follow (if used_math) */
+} __attribute__((aligned(8)));
+
+#define CKPT_X86_SEG_NULL	0
+#define CKPT_X86_SEG_USER32_CS	1
+#define CKPT_X86_SEG_USER32_DS	2
+#define CKPT_X86_SEG_TLS	0x4000	/* 0100 0000 0000 00xx */
+#define CKPT_X86_SEG_LDT	0x8000	/* 100x xxxx xxxx xxxx */
+
+#endif /* __ASM_X86_CKPT_HDR__H */
diff --git a/arch/x86/include/asm/ptrace.h b/arch/x86/include/asm/ptrace.h
index 0f0d908..66b507b 100644
--- a/arch/x86/include/asm/ptrace.h
+++ b/arch/x86/include/asm/ptrace.h
@@ -242,6 +242,11 @@ extern void ptrace_bts_untrace(struct task_struct *tsk);
 #define arch_ptrace_untrace(tsk)	ptrace_bts_untrace(tsk)
 #endif /* CONFIG_X86_PTRACE_BTS */
 
+extern int ptrace_check_debugreg(int _32bit,
+				 unsigned long dr0, unsigned long dr1,
+				 unsigned long dr2, unsigned long dr3,
+				 unsigned long dr6, unsigned long dr7);
+
 #endif /* __KERNEL__ */
 
 #endif /* !__ASSEMBLY__ */
diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index 9b4cacf..3b434bd 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -466,10 +466,10 @@ static unsigned long ptrace_get_debugreg(struct task_struct *child, int n)
 	return 0;
 }
 
-static int ptrace_check_debugreg(int _32bit,
-				 unsigned long dr0, unsigned long dr1,
-				 unsigned long dr2, unsigned long dr3,
-				 unsigned long dr6, unsigned long dr7)
+int ptrace_check_debugreg(int _32bit,
+			  unsigned long dr0, unsigned long dr1,
+			  unsigned long dr2, unsigned long dr3,
+			  unsigned long dr6, unsigned long dr7)
 {
 	/* Breakpoint type: 00: --x, 01: -w-, 10: undefined, 11: rw- */
 	unsigned int rw[4];
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index eefdeee..ddd5abb 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -21,3 +21,5 @@ obj-$(CONFIG_K8_NUMA)		+= k8topology_64.o
 obj-$(CONFIG_ACPI_NUMA)		+= srat_$(BITS).o
 
 obj-$(CONFIG_MEMTEST)		+= memtest.o
+
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
new file mode 100644
index 0000000..023039f
--- /dev/null
+++ b/arch/x86/mm/checkpoint.c
@@ -0,0 +1,531 @@
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
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/*
+ * helpers to encode/decode/validate registers/segments/eflags
+ */
+
+static int check_eflags(__u32 eflags)
+{
+#define X86_EFLAGS_CKPT_MASK  \
+	(X86_EFLAGS_CF | X86_EFLAGS_PF | X86_EFLAGS_AF | X86_EFLAGS_ZF | \
+	 X86_EFLAGS_SF | X86_EFLAGS_TF | X86_EFLAGS_DF | X86_EFLAGS_OF | \
+	 X86_EFLAGS_NT | X86_EFLAGS_AC | X86_EFLAGS_ID)
+
+	if ((eflags & ~X86_EFLAGS_CKPT_MASK) != (X86_EFLAGS_IF | 0x2))
+		return 0;
+	return 1;
+}
+
+static int check_tls(struct desc_struct *desc)
+{
+	if (!desc->a && !desc->b)
+		return 1;
+	if (desc->l != 0 || desc->s != 1 || desc->dpl != 3)
+		return 0;
+	return 1;
+}
+
+static int check_segment(__u16 seg)
+{
+	int ret = 0;
+
+	switch (seg) {
+	case CKPT_X86_SEG_NULL:
+	case CKPT_X86_SEG_USER32_CS:
+	case CKPT_X86_SEG_USER32_DS:
+		return 1;
+	}
+	if (seg & CKPT_X86_SEG_TLS) {
+		seg &= ~CKPT_X86_SEG_TLS;
+		if (seg <= GDT_ENTRY_TLS_MAX - GDT_ENTRY_TLS_MIN)
+			ret = 1;
+	} else if (seg & CKPT_X86_SEG_LDT) {
+		seg &= ~CKPT_X86_SEG_LDT;
+		if (seg <= 0x1fff)
+			ret = 1;
+	}
+	return ret;
+}
+
+static __u16 encode_segment(unsigned short seg)
+{
+	if (seg == 0)
+		return CKPT_X86_SEG_NULL;
+	BUG_ON((seg & 3) != 3);
+
+	if (seg == __USER_CS)
+		return CKPT_X86_SEG_USER32_CS;
+	if (seg == __USER_DS)
+		return CKPT_X86_SEG_USER32_DS;
+
+	if (seg & 4)
+		return CKPT_X86_SEG_LDT | (seg >> 3);
+
+	seg >>= 3;
+	if (GDT_ENTRY_TLS_MIN <= seg && seg <= GDT_ENTRY_TLS_MAX)
+		return CKPT_X86_SEG_TLS | (seg - GDT_ENTRY_TLS_MIN);
+
+	printk(KERN_ERR "c/r: (decode) bad segment %#hx\n", seg);
+	BUG();
+}
+
+static unsigned short decode_segment(__u16 seg)
+{
+	if (seg == CKPT_X86_SEG_NULL)
+		return 0;
+	if (seg == CKPT_X86_SEG_USER32_CS)
+		return __USER_CS;
+	if (seg == CKPT_X86_SEG_USER32_DS)
+		return __USER_DS;
+
+	if (seg & CKPT_X86_SEG_TLS) {
+		seg &= ~CKPT_X86_SEG_TLS;
+		return ((GDT_ENTRY_TLS_MIN + seg) << 3) | 3;
+	}
+	if (seg & CKPT_X86_SEG_LDT) {
+		seg &= ~CKPT_X86_SEG_LDT;
+		return (seg << 3) | 7;
+	}
+	BUG();
+}
+
+#define CKPT_X86_TIF_UNSUPPORTED   (_TIF_SECCOMP | _TIF_IO_BITMAP)
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+static int may_checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	if (t->thread.vm86_info) {
+		ckpt_write_err(ctx, "TE", "task in VM86 mode", -EBUSY);
+		return -EBUSY;
+	}
+	if (task_thread_info(t)->flags & CKPT_X86_TIF_UNSUPPORTED) {
+		ckpt_write_err(ctx, "TE", "bad thread info flags %#lx", -EBUSY);
+		return -EBUSY;
+	}
+	return 0;
+}
+
+/* dump the thread_struct of a given task */
+int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_thread *h;
+	int tls_size;
+	int ret;
+
+	ret = may_checkpoint_thread(ctx, t);
+	if (ret < 0)
+		return ret;
+
+	tls_size = sizeof(t->thread.tls_array);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h) + tls_size, CKPT_HDR_THREAD);
+	if (!h)
+		return -ENOMEM;
+
+	h->thread_info_flags =
+		task_thread_info(t)->flags & ~CKPT_X86_TIF_UNSUPPORTED;
+	h->gdt_entry_tls_entries = GDT_ENTRY_TLS_ENTRIES;
+	h->sizeof_tls_array = tls_size;
+
+	/* For simplicity dump the entire array */
+	memcpy(h + 1, t->thread.tls_array, tls_size);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+#ifdef CONFIG_X86_32
+
+static void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
+	unsigned long _gs;
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
+
+	h->flags = regs->flags;
+	h->sp = regs->sp;
+
+	h->cs = encode_segment(regs->cs);
+	h->ss = encode_segment(regs->ss);
+	h->ds = encode_segment(regs->ds);
+	h->es = encode_segment(regs->es);
+
+	/*
+	 * for checkpoint in process context (from within a container)
+	 * the GS segment register should be saved from the hardware;
+	 * otherwise it is already saved on the thread structure
+	 */
+	if (t == current)
+		_gs = get_user_gs(regs);
+	else
+		_gs = thread->gs;
+
+	h->fsindex = encode_segment(regs->fs);
+	h->gsindex = encode_segment(_gs);
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
+#endif	/* CONFIG_X86_32 */
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
+	ckpt_debug("math %d debug %d\n", h->used_math, !!h->debugreg7);
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
+	struct thread_struct *thread = &current->thread;
+	struct desc_struct *desc;
+	int tls_size;
+	int i, cpu, ret;
+
+	tls_size = sizeof(thread->tls_array);
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h) + tls_size, CKPT_HDR_THREAD);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->thread_info_flags & CKPT_X86_TIF_UNSUPPORTED)
+		goto out;
+	if (h->gdt_entry_tls_entries != GDT_ENTRY_TLS_ENTRIES)
+		goto out;
+	if (h->sizeof_tls_array != tls_size)
+		goto out;
+
+	/*
+	 * restore TLS by hand: why convert to struct user_desc if
+	 * sys_set_thread_entry() will convert it back ?
+	 */
+	desc = (struct desc_struct *) (h + 1);
+
+	for (i = 0; i < GDT_ENTRY_TLS_ENTRIES; i++) {
+		if (!check_tls(&desc[i]))
+			goto out;
+	}
+
+	cpu = get_cpu();
+	memcpy(thread->tls_array, desc, tls_size);
+	load_TLS(thread, cpu);
+	put_cpu();
+
+	/* TODO: restore TIF flags as necessary (e.g. TIF_NOTSC) */
+
+	ret = 0;
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+#ifdef CONFIG_X86_32
+
+static int load_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
+
+	if (!check_eflags(h->flags))
+		return -EINVAL;
+	if (h->cs == CKPT_X86_SEG_NULL)
+		return -EINVAL;
+	if (!check_segment(h->cs) || !check_segment(h->ds) ||
+	    !check_segment(h->es) || !check_segment(h->ss) ||
+	    !check_segment(h->fsindex) || !check_segment(h->gsindex))
+		return -EINVAL;
+
+	regs->bp = h->bp;
+	regs->bx = h->bx;
+	regs->ax = h->ax;
+	regs->cx = h->cx;
+	regs->dx = h->dx;
+	regs->si = h->si;
+	regs->di = h->di;
+	regs->orig_ax = h->orig_ax;
+	regs->ip = h->ip;
+
+	regs->flags = h->flags;
+	regs->sp = h->sp;
+
+	regs->ds = decode_segment(h->ds);
+	regs->es = decode_segment(h->es);
+	regs->cs = decode_segment(h->cs);
+	regs->ss = decode_segment(h->ss);
+
+	regs->fs = decode_segment(h->fsindex);
+	regs->gs = decode_segment(h->gsindex);
+
+	thread->gs = regs->gs;
+	lazy_load_gs(regs->gs);
+
+	return 0;
+}
+
+static int load_cpu_debug(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	int ret;
+
+	ret = ptrace_check_debugreg(1, h->debugreg0, h->debugreg1, h->debugreg2,
+				    h->debugreg3, h->debugreg6, h->debugreg7);
+	if (ret < 0)
+		return ret;
+
+	set_debugreg(h->debugreg0, 0);
+	set_debugreg(h->debugreg1, 1);
+	/* ignore 4, 5 */
+	set_debugreg(h->debugreg2, 2);
+	set_debugreg(h->debugreg3, 3);
+	set_debugreg(h->debugreg6, 6);
+	set_debugreg(h->debugreg7, 7);
+
+	if (h->debugreg7)
+		set_tsk_thread_flag(t, TIF_DEBUG);
+	else
+		clear_tsk_thread_flag(t, TIF_DEBUG);
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
+#endif	/* CONFIG_X86_32 */
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
+	ckpt_debug("math %d debug %d\n", h->used_math, !!h->debugreg7);
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
index 57eb7d8..e228151 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -300,6 +300,8 @@ static int checkpoint_write_header(struct ckpt_ctx *ctx)
 	do_gettimeofday(&ktv);
 	uts = utsname();
 
+	h->arch_id = cpu_to_le16(CKPT_ARCH_ID);  /* see asm/checkpoitn.h */
+
 	h->magic = CHECKPOINT_MAGIC_HEAD;
 	h->major = (LINUX_VERSION_CODE >> 16) & 0xff;
 	h->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
@@ -327,7 +329,10 @@ static int checkpoint_write_header(struct ckpt_ctx *ctx)
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
index d221c2a..1d1170c 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -57,6 +57,15 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	ret = checkpoint_task_struct(ctx, t);
 	ckpt_debug("task %d\n", ret);
 
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_thread(ctx, t);
+	ckpt_debug("thread %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_cpu(ctx, t);
+	ckpt_debug("cpu %d\n", ret);
+ out:
 	ctx->tsk = NULL;
 	return ret;
 }
@@ -97,6 +106,14 @@ int restore_task(struct ckpt_ctx *ctx)
 
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
index 9f08f4d..afe51c2 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -354,6 +354,8 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 		return PTR_ERR(h);
 
 	ret = -EINVAL;
+	if (le16_to_cpu(h->arch_id) != CKPT_ARCH_ID)
+		goto out;
 	if (h->magic != CHECKPOINT_MAGIC_HEAD ||
 	    h->rev != CHECKPOINT_VERSION ||
 	    h->major != ((LINUX_VERSION_CODE >> 16) & 0xff) ||
@@ -382,6 +384,10 @@ static int restore_read_header(struct ckpt_ctx *ctx)
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
index be0ba4b..aa8ce11 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -61,6 +61,15 @@ extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
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
 static inline int ckpt_validate_errno(int errno)
 {
 	return (errno >= 0) && (errno < MAX_ERRNO);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 22dadbd..92d082e 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -40,19 +40,33 @@ struct ckpt_hdr {
 	__u32 len;
 } __attribute__((aligned(8)));
 
+
+#include <asm/checkpoint_hdr.h>
+
+
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
 /* kernel constants */
 struct ckpt_const {
 	/* task */
@@ -68,7 +82,7 @@ struct ckpt_hdr_header {
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
