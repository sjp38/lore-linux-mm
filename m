Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 676806B00A3
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:43:00 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 43/43] c/r: define s390-specific checkpoint-restart code
Date: Wed, 27 May 2009 13:33:09 -0400
Message-Id: <1243445589-32388-44-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Dan Smith <danms@us.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Dan Smith <danms@us.ibm.com>

Implement the s390 arch-specific checkpoint/restart helpers.  This
is on top of Oren Laadan's c/r code.

With these, I am able to checkpoint and restart simple programs as per
Oren's patch intro.  While on x86 I never had to freeze a single task
to checkpoint it, on s390 I do need to.  That is a prereq for consistent
snapshots (esp with multiple processes) anyway so I don't see that as
a problem.

Changelog:
    Apr 11:
            . Introduce ckpt_arch_vdso()
    Feb 27:
            . Add checkpoint_s390.h
            . Fixed up save and restore of PSW, with the non-address bits
              properly masked out
    Feb 25:
            . Make checkpoint_hdr.h safe for inclusion in userspace
            . Replace comment about vsdo code
            . Add comment about restoring access registers
            . Write and read an empty ckpt_hdr_head_arch record to appease
              code (mktree) that expects it to be there
            . Utilize NUM_CKPT_WORDS in checkpoint_hdr.h
    Feb 24:
            . Use CKPT_COPY() to unify the un/loading of cpu and mm state
            . Fix fprs definition in ckpt_hdr_cpu
            . Remove debug WARN_ON() from checkpoint.c
    Feb 23:
            . Macro-ize the un/packing of trace flags
            . Fix the crash when externally-linked
            . Break out the restart functions into restart.c
            . Remove unneeded s390_enable_sie() call
    Jan 30:
            . Switched types in ckpt_hdr_cpu to __u64 etc.
              (Per Oren suggestion)
            . Replaced direct inclusion of structs in
              ckpt_hdr_cpu with the struct members.
              (Per Oren suggestion)
            . Also ended up adding a bunch of new things
              into restart (mm_segment, ksp, etc) in vain
              attempt to get code using fpu to not segfault
              after restart.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 arch/s390/include/asm/checkpoint_hdr.h |   81 ++++++++++++++
 arch/s390/include/asm/unistd.h         |    4 +-
 arch/s390/kernel/compat_wrapper.S      |   12 ++
 arch/s390/kernel/syscalls.S            |    2 +
 arch/s390/mm/Makefile                  |    1 +
 arch/s390/mm/checkpoint.c              |  183 ++++++++++++++++++++++++++++++++
 arch/s390/mm/checkpoint_s390.h         |   23 ++++
 7 files changed, 305 insertions(+), 1 deletions(-)

diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
new file mode 100644
index 0000000..185194b
--- /dev/null
+++ b/arch/s390/include/asm/checkpoint_hdr.h
@@ -0,0 +1,81 @@
+#ifndef __ASM_S390_CKPT_HDR_H
+#define __ASM_S390_CKPT_HDR_H
+/*
+ *  Checkpoint/restart - architecture specific headers s/390
+ *
+ *  Copyright IBM Corp. 2009
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/types.h>
+#include <linux/checkpoint_hdr.h>
+#include <asm/ptrace.h>
+
+#ifdef __KERNEL__
+#include <asm/processor.h>
+#else
+#include <sys/user.h>
+#endif
+
+/*
+ * Notes
+ * NUM_GPRS defined in <asm/ptrace.h> to be 16
+ * NUM_FPRS defined in <asm/ptrace.h> to be 16
+ * NUM_APRS defined in <asm/ptrace.h> to be 16
+ * NUM_CR_WORDS defined in <asm/ptrace.h> to be 3
+ */
+struct ckpt_hdr_cpu {
+	struct ckpt_hdr h;
+	__u64 args[1];
+	__u64 gprs[NUM_GPRS];
+	__u64 orig_gpr2;
+	__u16 svcnr;
+	__u16 ilc;
+	__u32 acrs[NUM_ACRS];
+	__u64 ieee_instruction_pointer;
+
+	/* psw_t */
+	__u64 psw_t_mask;
+	__u64 psw_t_addr;
+
+	/* s390_fp_regs_t */
+	__u32 fpc;
+	union {
+		float f;
+		double d;
+		__u64 ui;
+		struct {
+			__u32 fp_hi;
+			__u32 fp_lo;
+		} fp;
+	} fprs[NUM_FPRS];
+
+	/* per_struct */
+	__u64 per_control_regs[NUM_CR_WORDS];
+	__u64 starting_addr;
+	__u64 ending_addr;
+	__u64 address;
+	__u16 perc_atmid;
+	__u8 access_id;
+	__u8 single_step;
+	__u8 instruction_fetch;
+};
+
+struct ckpt_hdr_mm_context {
+	struct ckpt_hdr h;
+	unsigned long vdso_base;
+	int noexec;
+	int has_pgste;
+	int alloc_pgste;
+	unsigned long asce_bits;
+	unsigned long asce_limit;
+};
+
+struct ckpt_hdr_header_arch {
+	struct ckpt_hdr h;
+};
+
+#endif /* __ASM_S390_CKPT_HDR__H */
diff --git a/arch/s390/include/asm/unistd.h b/arch/s390/include/asm/unistd.h
index f0f19e6..3d22f17 100644
--- a/arch/s390/include/asm/unistd.h
+++ b/arch/s390/include/asm/unistd.h
@@ -267,7 +267,9 @@
 #define __NR_epoll_create1	327
 #define	__NR_preadv		328
 #define	__NR_pwritev		329
-#define NR_syscalls 330
+#define __NR_checkpoint		330
+#define __NR_restart		331
+#define NR_syscalls 332
 
 /* 
  * There are some system calls that are not present on 64 bit, some
diff --git a/arch/s390/kernel/compat_wrapper.S b/arch/s390/kernel/compat_wrapper.S
index fb38af6..ece87c8 100644
--- a/arch/s390/kernel/compat_wrapper.S
+++ b/arch/s390/kernel/compat_wrapper.S
@@ -1823,3 +1823,15 @@ compat_sys_pwritev_wrapper:
 	llgfr	%r5,%r5			# u32
 	llgfr	%r6,%r6			# u32
 	jg	compat_sys_pwritev	# branch to system call
+
+	.globl sys_checkpoint_wrapper
+sys_checkpoint_wrapper:
+	lgfr	%r2,%r2			# pid_t
+	lgfr	%r3,%r3			# int
+	llgfr	%r4,%r4			# unsigned long
+
+	.globl sys_restore_wrapper
+sys_restore_wrapper:
+	lgfr	%r2,%r2			# int
+	lgfr	%r3,%r3			# int
+	llgfr	%r4,%r4			# unsigned long
diff --git a/arch/s390/kernel/syscalls.S b/arch/s390/kernel/syscalls.S
index 2c7739f..e755e93 100644
--- a/arch/s390/kernel/syscalls.S
+++ b/arch/s390/kernel/syscalls.S
@@ -338,3 +338,5 @@ SYSCALL(sys_dup3,sys_dup3,sys_dup3_wrapper)
 SYSCALL(sys_epoll_create1,sys_epoll_create1,sys_epoll_create1_wrapper)
 SYSCALL(sys_preadv,sys_preadv,compat_sys_preadv_wrapper)
 SYSCALL(sys_pwritev,sys_pwritev,compat_sys_pwritev_wrapper)
+SYSCALL(sys_checkpoint,sys_checkpoint,sys_checkpoint_wrapper) /* 330 */
+SYSCALL(sys_restart,sys_restart,sys_restore_wrapper)
diff --git a/arch/s390/mm/Makefile b/arch/s390/mm/Makefile
index 2a74581..d1c3fbf 100644
--- a/arch/s390/mm/Makefile
+++ b/arch/s390/mm/Makefile
@@ -6,3 +6,4 @@ obj-y	 := init.o fault.o extmem.o mmap.o vmem.o pgtable.o
 obj-$(CONFIG_CMM) += cmm.o
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
 obj-$(CONFIG_PAGE_STATES) += page-states.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint.o
diff --git a/arch/s390/mm/checkpoint.c b/arch/s390/mm/checkpoint.c
new file mode 100644
index 0000000..f97f619
--- /dev/null
+++ b/arch/s390/mm/checkpoint.c
@@ -0,0 +1,183 @@
+/*
+ *  Checkpoint/restart - architecture specific support for s390
+ *
+ *  Copyright IBM Corp. 2009
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/kernel.h>
+#include <asm/system.h>
+#include <asm/pgtable.h>
+#include <asm/elf.h>
+
+#include <linux/checkpoint.h>
+#include <asm/checkpoint_hdr.h>
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+static void s390_copy_regs(int op, struct ckpt_hdr_cpu *h,
+			   struct task_struct *t)
+{
+	struct pt_regs *regs = task_pt_regs(t);
+	struct thread_struct *thr = &t->thread;
+
+	/* Save the whole PSW to facilitate forensic debugging, but only
+	 * restore the address portion to avoid letting userspace do
+	 * bad things by manipulating its value.
+	 */
+	if (op == CKPT_CPT) {
+		CKPT_COPY(op, h->psw_t_addr, regs->psw.addr);
+	} else {
+		regs->psw.addr &= ~PSW_ADDR_INSN;
+		regs->psw.addr |= h->psw_t_addr;
+	}
+
+	CKPT_COPY(op, h->args[0], regs->args[0]);
+	CKPT_COPY(op, h->orig_gpr2, regs->orig_gpr2);
+	CKPT_COPY(op, h->svcnr, regs->svcnr);
+	CKPT_COPY(op, h->ilc, regs->ilc);
+	CKPT_COPY(op, h->ieee_instruction_pointer,
+		thr->ieee_instruction_pointer);
+	CKPT_COPY(op, h->psw_t_mask, regs->psw.mask);
+	CKPT_COPY(op, h->fpc, thr->fp_regs.fpc);
+	CKPT_COPY(op, h->starting_addr, thr->per_info.starting_addr);
+	CKPT_COPY(op, h->ending_addr, thr->per_info.ending_addr);
+	CKPT_COPY(op, h->address, thr->per_info.lowcore.words.address);
+	CKPT_COPY(op, h->perc_atmid, thr->per_info.lowcore.words.perc_atmid);
+	CKPT_COPY(op, h->access_id, thr->per_info.lowcore.words.access_id);
+	CKPT_COPY(op, h->single_step, thr->per_info.single_step);
+	CKPT_COPY(op, h->instruction_fetch, thr->per_info.instruction_fetch);
+
+	CKPT_COPY_ARRAY(op, h->gprs, regs->gprs, NUM_GPRS);
+	CKPT_COPY_ARRAY(op, h->fprs, thr->fp_regs.fprs, NUM_FPRS);
+	CKPT_COPY_ARRAY(op, h->acrs, thr->acrs, NUM_ACRS);
+	CKPT_COPY_ARRAY(op, h->per_control_regs,
+		      thr->per_info.control_regs.words.cr, NUM_CR_WORDS);
+}
+
+static void s390_mm(int op, struct ckpt_hdr_mm_context *h,
+		    struct mm_struct *mm)
+{
+	CKPT_COPY(op, h->noexec, mm->context.noexec);
+	CKPT_COPY(op, h->has_pgste, mm->context.has_pgste);
+	CKPT_COPY(op, h->alloc_pgste, mm->context.alloc_pgste);
+	CKPT_COPY(op, h->asce_bits, mm->context.asce_bits);
+	CKPT_COPY(op, h->asce_limit, mm->context.asce_limit);
+}
+
+int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	return 0;
+}
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
+	s390_copy_regs(CKPT_CPT, h, t);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+/* Write an empty header since it is assumed to be there */
+int checkpoint_write_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_HEADER_ARCH);
+	if (!h)
+		return -ENOMEM;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct ckpt_hdr_mm_context *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_MM_CONTEXT);
+	if (!h)
+		return -ENOMEM;
+
+	s390_mm(CKPT_CPT, h, mm);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+/**************************************************************************
+ * Restart
+ */
+
+int restore_thread(struct ckpt_ctx *ctx)
+{
+	return 0;
+}
+
+int restore_cpu(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_cpu *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CPU);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	s390_copy_regs(CKPT_RST, h, current);
+
+	/* s390 does not restore the access registers after a syscall,
+	 * but does on a task switch.  Since we're switching tasks (in
+	 * a way), we need to replicate that behavior here.
+	 */
+	restore_access_regs(h->acrs);
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
+
+int restore_read_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_HEADER_ARCH);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
+
+
+int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct ckpt_hdr_mm_context *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_MM_CONTEXT);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	s390_mm(CKPT_RST, h, mm);
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
diff --git a/arch/s390/mm/checkpoint_s390.h b/arch/s390/mm/checkpoint_s390.h
new file mode 100644
index 0000000..c3bf24d
--- /dev/null
+++ b/arch/s390/mm/checkpoint_s390.h
@@ -0,0 +1,23 @@
+/*
+ *  Checkpoint/restart - architecture specific support for s390
+ *
+ *  Copyright IBM Corp. 2009
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#ifndef _S390_CHECKPOINT_H
+#define _S390_CHECKPOINT_H
+
+#include <linux/checkpoint_hdr.h>
+#include <linux/sched.h>
+#include <linux/mm_types.h>
+
+extern void checkpoint_s390_regs(int op, struct ckpt_hdr_cpu *h,
+				 struct task_struct *t);
+extern void checkpoint_s390_mm(int op, struct ckpt_hdr_mm_context *h,
+			       struct mm_struct *mm);
+
+#endif /* _S390_CHECKPOINT_H */
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
