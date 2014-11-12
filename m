Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E2F586B00E6
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 12:05:11 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so13140891pab.26
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 09:05:11 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id lp1si23400638pab.57.2014.11.12.09.05.09
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 09:05:10 -0800 (PST)
Subject: [PATCH 08/11] x86, mpx: [new code] decode MPX instruction to get bound violation information
From: Dave Hansen <dave@sr71.net>
Date: Wed, 12 Nov 2014 09:05:09 -0800
References: <20141112170443.B4BD0899@viggo.jf.intel.com>
In-Reply-To: <20141112170443.B4BD0899@viggo.jf.intel.com>
Message-Id: <20141112170509.AED2778F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Note: This is substantially different code from the v9 set.

This patch sets bound violation fields of siginfo struct in #BR
exception handler by decoding the user instruction and constructing
the faulting pointer.

We have to be very careful when decoding these instructions.  They
are completely controlled by userspace and may be changed at any
time up to and including the point where we try to copy them in to
the kernel.  They may or may not be MPX instructions and could be
completely invalid for all we know.

Note: This code is based on Qiaowei Ren's specialized MPX
decoder, but uses the generic decoder whenever possible.  It was
tested for robustness by generating a completely random data
stream and trying to decode that stream.  I also unmapped random
pages inside the stream to test the "partial instruction" short
read code.

We kzalloc() the siginfo instead of stack allocating it because
we need to memset() it anyway, and doing this makes it much more
clear when it got initialized by the MPX instruction decoder.

Changes from the old decoder:
 * Use the generic decoder instead of custom functions.  Saved
   ~70 lines of code overall.
 * Remove insn->addr_bytes code (never used??)
 * Make sure never to possibly overflow the regoff[] array, plus
   check the register range correctly in 32 and 64-bit modes.
 * Allow get_reg() to return an error and have mpx_get_addr_ref()
   handle when it sees errors.
 * Only call insn_get_*() near where we actually use the values
   instead if trying to call them all at once.
 * Handle short reads from copy_from_user() and check the actual
   number of read bytes against what we expect from
   insn_get_length().  If a read stops in the middle of an
   instruction, we error out.
 * Actually check the opcodes intead of ignoring them.
 * Dynamically kzalloc() siginfo_t so we don't leak any stack
   data.
 * Detect and handle decoder failures instead of ignoring them.


Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/include/asm/mpx.h |   12 ++
 b/arch/x86/mm/mpx.c          |  237 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 249 insertions(+)

diff -puN arch/x86/include/asm/mpx.h~mpx-new-decoder arch/x86/include/asm/mpx.h
--- a/arch/x86/include/asm/mpx.h~mpx-new-decoder	2014-11-12 08:49:26.095898480 -0800
+++ b/arch/x86/include/asm/mpx.h	2014-11-12 08:49:26.099898661 -0800
@@ -3,6 +3,7 @@
 
 #include <linux/types.h>
 #include <asm/ptrace.h>
+#include <asm/insn.h>
 
 #ifdef CONFIG_X86_64
 
@@ -33,4 +34,15 @@
 
 #define MPX_BNDSTA_ERROR_CODE	0x3
 
+#ifdef CONFIG_X86_INTEL_MPX
+siginfo_t *mpx_generate_siginfo(struct pt_regs *regs,
+				struct xsave_struct *xsave_buf);
+#else
+static inline siginfo_t *mpx_generate_siginfo(struct pt_regs *regs,
+					      struct xsave_struct *xsave_buf)
+{
+	return NULL;
+}
+#endif /* CONFIG_X86_INTEL_MPX */
+
 #endif /* _ASM_X86_MPX_H */
diff -puN arch/x86/mm/mpx.c~mpx-new-decoder arch/x86/mm/mpx.c
--- a/arch/x86/mm/mpx.c~mpx-new-decoder	2014-11-12 08:49:26.096898525 -0800
+++ b/arch/x86/mm/mpx.c	2014-11-12 08:49:26.100898706 -0800
@@ -6,6 +6,7 @@
  * Dave Hansen <dave.hansen@intel.com>
  */
 #include <linux/kernel.h>
+#include <linux/slab.h>
 #include <linux/syscalls.h>
 #include <linux/sched/sysctl.h>
 
@@ -84,3 +85,239 @@ out:
 	up_write(&mm->mmap_sem);
 	return ret;
 }
+
+enum reg_type {
+	REG_TYPE_RM = 0,
+	REG_TYPE_INDEX,
+	REG_TYPE_BASE,
+};
+
+static unsigned long get_reg_offset(struct insn *insn, struct pt_regs *regs,
+				    enum reg_type type)
+{
+	int regno = 0;
+
+	static const int regoff[] = {
+		offsetof(struct pt_regs, ax),
+		offsetof(struct pt_regs, cx),
+		offsetof(struct pt_regs, dx),
+		offsetof(struct pt_regs, bx),
+		offsetof(struct pt_regs, sp),
+		offsetof(struct pt_regs, bp),
+		offsetof(struct pt_regs, si),
+		offsetof(struct pt_regs, di),
+#ifdef CONFIG_X86_64
+		offsetof(struct pt_regs, r8),
+		offsetof(struct pt_regs, r9),
+		offsetof(struct pt_regs, r10),
+		offsetof(struct pt_regs, r11),
+		offsetof(struct pt_regs, r12),
+		offsetof(struct pt_regs, r13),
+		offsetof(struct pt_regs, r14),
+		offsetof(struct pt_regs, r15),
+#endif
+	};
+	int nr_registers = ARRAY_SIZE(regoff);
+	/*
+	 * Don't possibly decode a 32-bit instructions as
+	 * reading a 64-bit-only register.
+	 */
+	if (IS_ENABLED(CONFIG_X86_64) && !insn->x86_64)
+		nr_registers -= 8;
+
+	switch (type) {
+	case REG_TYPE_RM:
+		regno = X86_MODRM_RM(insn->modrm.value);
+		if (X86_REX_B(insn->rex_prefix.value) == 1)
+			regno += 8;
+		break;
+
+	case REG_TYPE_INDEX:
+		regno = X86_SIB_INDEX(insn->sib.value);
+		if (X86_REX_X(insn->rex_prefix.value) == 1)
+			regno += 8;
+		break;
+
+	case REG_TYPE_BASE:
+		regno = X86_SIB_BASE(insn->sib.value);
+		if (X86_REX_B(insn->rex_prefix.value) == 1)
+			regno += 8;
+		break;
+
+	default:
+		pr_err("invalid register type");
+		BUG();
+		break;
+	}
+
+	if (regno > nr_registers) {
+		WARN_ONCE(1, "decoded an instruction with an invalid register");
+		return -EINVAL;
+	}
+	return regoff[regno];
+}
+
+/*
+ * return the address being referenced be instruction
+ * for rm=3 returning the content of the rm reg
+ * for rm!=3 calculates the address using SIB and Disp
+ */
+static void __user *mpx_get_addr_ref(struct insn *insn, struct pt_regs *regs)
+{
+	unsigned long addr, addr_offset;
+	unsigned long base, base_offset;
+	unsigned long indx, indx_offset;
+	insn_byte_t sib;
+
+	insn_get_modrm(insn);
+	insn_get_sib(insn);
+	sib = insn->sib.value;
+
+	if (X86_MODRM_MOD(insn->modrm.value) == 3) {
+		addr_offset = get_reg_offset(insn, regs, REG_TYPE_RM);
+		if (addr_offset < 0)
+			goto out_err;
+		addr = regs_get_register(regs, addr_offset);
+	} else {
+		if (insn->sib.nbytes) {
+			base_offset = get_reg_offset(insn, regs, REG_TYPE_BASE);
+			if (base_offset < 0)
+				goto out_err;
+
+			indx_offset = get_reg_offset(insn, regs, REG_TYPE_INDEX);
+			if (indx_offset < 0)
+				goto out_err;
+
+			base = regs_get_register(regs, base_offset);
+			indx = regs_get_register(regs, indx_offset);
+			addr = base + indx * (1 << X86_SIB_SCALE(sib));
+		} else {
+			addr_offset = get_reg_offset(insn, regs, REG_TYPE_RM);
+			if (addr_offset < 0)
+				goto out_err;
+			addr = regs_get_register(regs, addr_offset);
+		}
+		addr += insn->displacement.value;
+	}
+	return (void __user *)addr;
+out_err:
+	return (void __user *)-1;
+}
+
+static int mpx_insn_decode(struct insn *insn,
+			   struct pt_regs *regs)
+{
+	unsigned char buf[MAX_INSN_SIZE];
+	int x86_64 = !test_thread_flag(TIF_IA32);
+	int not_copied;
+	int nr_copied;
+
+	not_copied = copy_from_user(buf, (void __user *)regs->ip, sizeof(buf));
+	nr_copied = sizeof(buf) - not_copied;
+	/*
+	 * The decoder _should_ fail nicely if we pass it a short buffer.
+	 * But, let's not depend on that implementation detail.  If we
+	 * did not get anything, just error out now.
+	 */
+	if (!nr_copied)
+		return -EFAULT;
+	insn_init(insn, buf, nr_copied, x86_64);
+	insn_get_length(insn);
+	/*
+	 * copy_from_user() tries to get as many bytes as we could see in
+	 * the largest possible instruction.  If the instruction we are
+	 * after is shorter than that _and_ we attempt to copy from
+	 * something unreadable, we might get a short read.  This is OK
+	 * as long as the read did not stop in the middle of the
+	 * instruction.  Check to see if we got a partial instruction.
+	 */
+	if (nr_copied < insn->length)
+		return -EFAULT;
+
+	insn_get_opcode(insn);
+	/*
+	 * We only _really_ need to decode bndcl/bndcn/bndcu
+	 * Error out on anything else.
+	 */
+	if (insn->opcode.bytes[0] != 0x0f)
+		goto bad_opcode;
+	if ((insn->opcode.bytes[1] != 0x1a) &&
+	    (insn->opcode.bytes[1] != 0x1b))
+		goto bad_opcode;
+
+	return 0;
+bad_opcode:
+	return -EINVAL;
+}
+
+/*
+ * If a bounds overflow occurs then a #BR is generated. This
+ * function decodes MPX instructions to get violation address
+ * and set this address into extended struct siginfo.
+ *
+ * Note that this is not a super precise way of doing this.
+ * Userspace could have, by the time we get here, written
+ * anything it wants in to the instructions.  We can not
+ * trust anything about it.  They might not be valid
+ * instructions or might encode invalid registers, etc...
+ *
+ * The caller is expected to kfree() the returned siginfo_t.
+ */
+siginfo_t *mpx_generate_siginfo(struct pt_regs *regs,
+				struct xsave_struct *xsave_buf)
+{
+	struct insn insn;
+	uint8_t bndregno;
+	int err;
+	siginfo_t *info;
+
+	err = mpx_insn_decode(&insn, regs);
+	if (err)
+		goto err_out;
+
+	/*
+	 * We know at this point that we are only dealing with
+	 * MPX instructions.
+	 */
+	insn_get_modrm(&insn);
+	bndregno = X86_MODRM_REG(insn.modrm.value);
+	if (bndregno > 3) {
+		err = -EINVAL;
+		goto err_out;
+	}
+	info = kzalloc(sizeof(*info), GFP_KERNEL);
+	if (!info) {
+		err = -ENOMEM;
+		goto err_out;
+	}
+	/*
+	 * The registers are always 64-bit, but the upper 32
+	 * bits are ignored in 32-bit mode.  Also, note that the
+	 * upper bounds are architecturally represented in 1's
+	 * complement form.
+	 *
+	 * The 'unsigned long' cast is because the compiler
+	 * complains when casting from integers to different-size
+	 * pointers.
+	 */
+	info->si_lower = (void __user *)(unsigned long)
+		(xsave_buf->bndreg[bndregno].lower_bound);
+	info->si_upper = (void __user *)(unsigned long)
+		(~xsave_buf->bndreg[bndregno].upper_bound);
+	info->si_addr_lsb = 0;
+	info->si_signo = SIGSEGV;
+	info->si_errno = 0;
+	info->si_code = SEGV_BNDERR;
+	info->si_addr = mpx_get_addr_ref(&insn, regs);
+	/*
+	 * We were not able to extract an address from the instruction,
+	 * probably because there was something invalid in it.
+	 */
+	if (info->si_addr == (void *)-1) {
+		err = -EINVAL;
+		goto err_out;
+	}
+	return info;
+err_out:
+	return ERR_PTR(err);
+}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
