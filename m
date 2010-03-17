Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 509616B0205
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:14:01 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 25/96] c/r: x86-64: checkpoint/restart implementation
Date: Wed, 17 Mar 2010 12:08:13 -0400
Message-Id: <1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Support for checkpoint and restart for X86_32 architecture.
Partly based on Alexey's work.

Support for 32bit on 64bit and fixes from Serge Hallyn.

 Checkpoint          Restart
 (app/arch)         (app/arch/program*)
---------------------------------------
  64/x86-64	->  64/x86-64	  works
  32/x86-64	->  32/x86-64	  works
  32/x86-64	->  32/x86-32	  ?
  32/x86-32	->  32/x86-64	  ?

  32/x86-64	->  32/x86-32	  ?
  32/x86-32	->  32/x86-64	  ?

(*) "program" indicates the bit-ness of 'restart' executable.

Changelog[v19-rc3]:
  - Rebase to kernel 2.6.33
  - [Serge Hallyn] Changes to fs/gs register handling
  - [Serge Hallyn] Allow 32-bit restart of 64-bit and vice versa
  - [Serge Hallyn] Only allow 'restart' with same bit-ness as image.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Signed-off-by: Serge Hallyn <serue@us.ibm.com>
---
 arch/x86/Kconfig                      |    2 +-
 arch/x86/include/asm/checkpoint_hdr.h |    6 +
 arch/x86/include/asm/unistd_64.h      |    4 +
 arch/x86/kernel/Makefile              |    2 +
 arch/x86/kernel/checkpoint.c          |   16 +++
 arch/x86/kernel/checkpoint_64.c       |  241 +++++++++++++++++++++++++++++++++
 arch/x86/kernel/entry_64.S            |    7 +
 include/linux/checkpoint_hdr.h        |    2 +
 8 files changed, 279 insertions(+), 1 deletions(-)
 create mode 100644 arch/x86/kernel/checkpoint_64.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index d5a7284..a6ae38a 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -93,7 +93,7 @@ config HAVE_LATENCYTOP_SUPPORT
 
 config CHECKPOINT_SUPPORT
 	bool
-	default y if X86_32
+	default y
 
 config MMU
 	def_bool y
diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index e6cfc99..6f600dd 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -36,6 +36,10 @@
 #include <asm/processor.h>
 #endif
 
+#ifdef CONFIG_X86_64
+#define CKPT_ARCH_ID	CKPT_ARCH_X86_64
+#endif
+
 #ifdef CONFIG_X86_32
 #define CKPT_ARCH_ID	CKPT_ARCH_X86_32
 #endif
@@ -106,6 +110,8 @@ struct ckpt_hdr_cpu {
 #define CKPT_X86_SEG_NULL	0
 #define CKPT_X86_SEG_USER32_CS	1
 #define CKPT_X86_SEG_USER32_DS	2
+#define CKPT_X86_SEG_USER64_CS	3
+#define CKPT_X86_SEG_USER64_DS	4
 #define CKPT_X86_SEG_TLS	0x4000	/* 0100 0000 0000 00xx */
 #define CKPT_X86_SEG_LDT	0x8000	/* 100x xxxx xxxx xxxx */
 
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index d87318d..17bacfd 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -665,6 +665,10 @@ __SYSCALL(__NR_perf_event_open, sys_perf_event_open)
 __SYSCALL(__NR_recvmmsg, sys_recvmmsg)
 #define __NR_eclone                   		300
 __SYSCALL(__NR_eclone, stub_eclone)
+#define __NR_checkpoint                   	301
+__SYSCALL(__NR_checkpoint, stub_checkpoint)
+#define __NR_restart                   		302
+__SYSCALL(__NR_restart, stub_restart)
 
 #ifndef __NO_STUBS
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 2f45350..2d0ff56 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -137,4 +137,6 @@ ifeq ($(CONFIG_X86_64),y)
 
 	obj-$(CONFIG_PCI_MMCONFIG)	+= mmconf-fam10h_64.o
 	obj-y				+= vsmp_64.o
+
+	obj-$(CONFIG_CHECKPOINT)	+= checkpoint_64.o
 endif
diff --git a/arch/x86/kernel/checkpoint.c b/arch/x86/kernel/checkpoint.c
index 06fe740..53b7e66 100644
--- a/arch/x86/kernel/checkpoint.c
+++ b/arch/x86/kernel/checkpoint.c
@@ -251,6 +251,22 @@ int restore_thread(struct ckpt_ctx *ctx)
 	load_TLS(thread, cpu);
 	put_cpu();
 
+	{
+		int pre, post;
+		/*
+		 * Eventually we'd like to support mixed-bit restart, but for
+		 * now don't pretend to.
+		 */
+		pre = test_thread_flag(TIF_IA32);
+		post = !!(h->thread_info_flags & _TIF_IA32);
+		if (pre != post) {
+			ret = -EINVAL;
+			ckpt_err(ctx, ret, "%d-bit restarting %d-bit\n",
+				64 >> pre, 64 >> post);
+			goto out;
+		}
+	}
+
 	/* TODO: restore TIF flags as necessary (e.g. TIF_NOTSC) */
 
 	ret = 0;
diff --git a/arch/x86/kernel/checkpoint_64.c b/arch/x86/kernel/checkpoint_64.c
new file mode 100644
index 0000000..f8226e2
--- /dev/null
+++ b/arch/x86/kernel/checkpoint_64.c
@@ -0,0 +1,241 @@
+/*
+ *  Checkpoint/restart - architecture specific support for x86_64
+ *
+ *  Copyright (C) 2009 Oren Laadan
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
+#include <asm/elf.h>
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/* helpers to encode/decode/validate segments */
+
+int check_segment(__u16 seg)
+{
+	int ret = 0;
+
+	switch (seg) {
+	case CKPT_X86_SEG_NULL:
+	case CKPT_X86_SEG_USER64_CS:
+	case CKPT_X86_SEG_USER64_DS:
+#ifdef CONFIG_COMPAT
+	case CKPT_X86_SEG_USER32_CS:
+	case CKPT_X86_SEG_USER32_DS:
+#endif
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
+__u16 encode_segment(unsigned short seg)
+{
+	if (seg == 0)
+		return CKPT_X86_SEG_NULL;
+	BUG_ON((seg & 3) != 3);
+
+	if (seg == __USER_CS)
+		return CKPT_X86_SEG_USER64_CS;
+	if (seg == __USER_DS)
+		return CKPT_X86_SEG_USER64_DS;
+#ifdef CONFIG_COMPAT
+	if (seg == __USER32_CS)
+		return CKPT_X86_SEG_USER32_CS;
+	if (seg == __USER32_DS)
+		return CKPT_X86_SEG_USER32_DS;
+#endif
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
+unsigned short decode_segment(__u16 seg)
+{
+	if (seg == CKPT_X86_SEG_NULL)
+		return 0;
+
+	if (seg == CKPT_X86_SEG_USER64_CS)
+		return __USER_CS;
+	if (seg == CKPT_X86_SEG_USER64_DS)
+		return __USER_DS;
+#ifdef CONFIG_COMPAT
+	if (seg == CKPT_X86_SEG_USER32_CS)
+		return __USER32_CS;
+	if (seg == CKPT_X86_SEG_USER32_DS)
+		return __USER32_DS;
+#endif
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
+void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct pt_regs *regs = task_pt_regs(t);
+	unsigned long _ds, _es, _fs, _gs;
+
+	h->r15 = regs->r15;
+	h->r14 = regs->r14;
+	h->r13 = regs->r13;
+	h->r12 = regs->r12;
+	h->r11 = regs->r11;
+	h->r10 = regs->r10;
+	h->r9 = regs->r9;
+	h->r8 = regs->r8;
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
+	/*
+	 * for checkpoint in process context (from within a container)
+	 * DS, ES, FS, GS registers should be saved from the hardware;
+	 * otherwise they are already saved on the thread structure
+	 */
+
+	h->cs = encode_segment(regs->cs);
+	h->ss = encode_segment(regs->ss);
+
+	if (t == current) {
+		savesegment(ds, _ds);
+		savesegment(es, _es);
+		savesegment(fs, _fs);
+		savesegment(gs, _gs);
+		rdmsrl(MSR_FS_BASE, h->fs);
+		rdmsrl(MSR_KERNEL_GS_BASE, h->gs);
+	} else {
+		_ds = t->thread.ds;
+		_es = t->thread.es;
+		_fs = t->thread.fsindex;
+		_gs = t->thread.gsindex;
+		h->fs = t->thread.fs;
+		h->gs = t->thread.gs;
+	}
+	h->ds = encode_segment(_ds);
+	h->es = encode_segment(_es);
+	h->fsindex = encode_segment(_fs);
+	h->gsindex = encode_segment(_gs);
+
+	/* see comment in __switch_to() */
+	if (_fs)
+		h->fs = 0;
+	if (_gs)
+		h->gs = 0;
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
+int load_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
+
+	if (h->cs == CKPT_X86_SEG_NULL)
+		return -EINVAL;
+	if (!check_segment(h->cs) || !check_segment(h->ds) ||
+	    !check_segment(h->es) || !check_segment(h->ss) ||
+	    !check_segment(h->fsindex) || !check_segment(h->gsindex))
+		return -EINVAL;
+
+	regs->r15 = h->r15;
+	regs->r14 = h->r14;
+	regs->r13 = h->r13;
+	regs->r12 = h->r12;
+	regs->r11 = h->r11;
+	regs->r10 = h->r10;
+	regs->r9 = h->r9;
+	regs->r8 = h->r8;
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
+	regs->sp = h->sp;
+	thread->usersp = h->sp;
+
+	preempt_disable();
+
+	regs->cs = decode_segment(h->cs);
+	regs->ss = decode_segment(h->ss);
+	thread->ds = decode_segment(h->ds);
+	thread->es = decode_segment(h->es);
+	thread->fsindex = decode_segment(h->fsindex);
+	thread->gsindex = decode_segment(h->gsindex);
+
+	thread->fs = h->fs;
+	thread->gs = h->gs;
+
+	/* XXX - unsure is this really needed ... */
+	loadsegment(fs, thread->fsindex);
+	if (thread->fs)
+		wrmsrl(MSR_FS_BASE, thread->fs);
+	load_gs_index(thread->gsindex);
+	/*
+	 * when we switch to user-space, the MSR_KERNEL_GS_BASE
+	 * will be moved back to MSR_GS_BASE.
+	 * http://lists.openwall.net/linux-kernel/2008/11/18/340
+	 */
+	if (thread->gs)
+		wrmsrl(MSR_KERNEL_GS_BASE, thread->gs);
+
+	preempt_enable();
+
+	return 0;
+}
diff --git a/arch/x86/kernel/entry_64.S b/arch/x86/kernel/entry_64.S
index 216681e..c2ece28 100644
--- a/arch/x86/kernel/entry_64.S
+++ b/arch/x86/kernel/entry_64.S
@@ -699,6 +699,13 @@ END(\label)
 	PTREGSCALL stub_sigaltstack, sys_sigaltstack, %rdx
 	PTREGSCALL stub_iopl, sys_iopl, %rsi
 	PTREGSCALL stub_eclone, sys_eclone, %r8
+#ifdef CONFIG_CHECKPOINT
+	PTREGSCALL stub_checkpoint, sys_checkpoint, %r8
+	PTREGSCALL stub_restart, sys_restart, %r8
+#else
+	PTREGSCALL stub_checkpoint, sys_ni_syscall, %r8
+	PTREGSCALL stub_restart, sys_ni_syscall, %r8
+#endif
 
 ENTRY(ptregscall_common)
 	DEFAULT_FRAME 1 8	/* offset 8: return address */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 2ab878a..4627564 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -85,6 +85,8 @@ enum {
 enum {
 	CKPT_ARCH_X86_32 = 1,
 #define CKPT_ARCH_X86_32 CKPT_ARCH_X86_32
+	CKPT_ARCH_X86_64,
+#define CKPT_ARCH_X86_64 CKPT_ARCH_X86_64
 };
 
 /* kernel constants */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
