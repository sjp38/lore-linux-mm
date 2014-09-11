Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3876B0062
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 04:54:16 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id fp1so5080169pdb.29
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:54:16 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id v3si274639pds.170.2014.09.11.01.54.15
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 01:54:16 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v8 07/10] x86, mpx: decode MPX instruction to get bound violation information
Date: Thu, 11 Sep 2014 16:46:47 +0800
Message-Id: <1410425210-24789-8-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qiaowei Ren <qiaowei.ren@intel.com>

This patch sets bound violation fields of siginfo struct in #BR
exception handler by decoding the user instruction and constructing
the faulting pointer.

This patch does't use the generic decoder, and implements a limited
special-purpose decoder to decode MPX instructions, simply because the
generic decoder is very heavyweight not just in terms of performance
but in terms of interface -- because it has to.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
---
 arch/x86/include/asm/mpx.h |   23 ++++
 arch/x86/kernel/mpx.c      |  299 ++++++++++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/traps.c    |    6 +
 3 files changed, 328 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/mpx.h b/arch/x86/include/asm/mpx.h
index b7598ac..780af63 100644
--- a/arch/x86/include/asm/mpx.h
+++ b/arch/x86/include/asm/mpx.h
@@ -3,6 +3,7 @@
 
 #include <linux/types.h>
 #include <asm/ptrace.h>
+#include <asm/insn.h>
 
 #ifdef CONFIG_X86_64
 
@@ -44,15 +45,37 @@
 #define MPX_BNDSTA_ERROR_CODE	0x3
 #define MPX_BD_ENTRY_VALID_FLAG	0x1
 
+struct mpx_insn {
+	struct insn_field rex_prefix;	/* REX prefix */
+	struct insn_field modrm;
+	struct insn_field sib;
+	struct insn_field displacement;
+
+	unsigned char addr_bytes;	/* effective address size */
+	unsigned char limit;
+	unsigned char x86_64;
+
+	const unsigned char *kaddr;	/* kernel address of insn to analyze */
+	const unsigned char *next_byte;
+};
+
+#define MAX_MPX_INSN_SIZE	15
+
 unsigned long mpx_mmap(unsigned long len);
 
 #ifdef CONFIG_X86_INTEL_MPX
 int do_mpx_bt_fault(struct xsave_struct *xsave_buf);
+void do_mpx_bounds(struct pt_regs *regs, siginfo_t *info,
+		struct xsave_struct *xsave_buf);
 #else
 static inline int do_mpx_bt_fault(struct xsave_struct *xsave_buf)
 {
 	return -EINVAL;
 }
+static inline void do_mpx_bounds(struct pt_regs *regs, siginfo_t *info,
+		struct xsave_struct *xsave_buf)
+{
+}
 #endif /* CONFIG_X86_INTEL_MPX */
 
 #endif /* _ASM_X86_MPX_H */
diff --git a/arch/x86/kernel/mpx.c b/arch/x86/kernel/mpx.c
index 88d660f..7ef6e39 100644
--- a/arch/x86/kernel/mpx.c
+++ b/arch/x86/kernel/mpx.c
@@ -2,6 +2,275 @@
 #include <linux/syscalls.h>
 #include <asm/mpx.h>
 
+enum reg_type {
+	REG_TYPE_RM = 0,
+	REG_TYPE_INDEX,
+	REG_TYPE_BASE,
+};
+
+static unsigned long get_reg(struct mpx_insn *insn, struct pt_regs *regs,
+			     enum reg_type type)
+{
+	int regno = 0;
+	unsigned char modrm = (unsigned char)insn->modrm.value;
+	unsigned char sib = (unsigned char)insn->sib.value;
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
+
+	switch (type) {
+	case REG_TYPE_RM:
+		regno = X86_MODRM_RM(modrm);
+		if (X86_REX_B(insn->rex_prefix.value) == 1)
+			regno += 8;
+		break;
+
+	case REG_TYPE_INDEX:
+		regno = X86_SIB_INDEX(sib);
+		if (X86_REX_X(insn->rex_prefix.value) == 1)
+			regno += 8;
+		break;
+
+	case REG_TYPE_BASE:
+		regno = X86_SIB_BASE(sib);
+		if (X86_REX_B(insn->rex_prefix.value) == 1)
+			regno += 8;
+		break;
+
+	default:
+		break;
+	}
+
+	return regs_get_register(regs, regoff[regno]);
+}
+
+/*
+ * return the address being referenced be instruction
+ * for rm=3 returning the content of the rm reg
+ * for rm!=3 calculates the address using SIB and Disp
+ */
+static unsigned long get_addr_ref(struct mpx_insn *insn, struct pt_regs *regs)
+{
+	unsigned long addr;
+	unsigned long base;
+	unsigned long indx;
+	unsigned char modrm = (unsigned char)insn->modrm.value;
+	unsigned char sib = (unsigned char)insn->sib.value;
+
+	if (X86_MODRM_MOD(modrm) == 3) {
+		addr = get_reg(insn, regs, REG_TYPE_RM);
+	} else {
+		if (insn->sib.nbytes) {
+			base = get_reg(insn, regs, REG_TYPE_BASE);
+			indx = get_reg(insn, regs, REG_TYPE_INDEX);
+			addr = base + indx * (1 << X86_SIB_SCALE(sib));
+		} else {
+			addr = get_reg(insn, regs, REG_TYPE_RM);
+		}
+		addr += insn->displacement.value;
+	}
+
+	return addr;
+}
+
+/* Verify next sizeof(t) bytes can be on the same instruction */
+#define validate_next(t, insn, n)	\
+	((insn)->next_byte + sizeof(t) + n - (insn)->kaddr <= (insn)->limit)
+
+#define __get_next(t, insn)		\
+({					\
+	t r = *(t *)insn->next_byte;	\
+	insn->next_byte += sizeof(t);	\
+	r;				\
+})
+
+#define __peek_next(t, insn)		\
+({					\
+	t r = *(t *)insn->next_byte;	\
+	r;				\
+})
+
+#define get_next(t, insn)		\
+({					\
+	if (unlikely(!validate_next(t, insn, 0)))	\
+		goto err_out;		\
+	__get_next(t, insn);		\
+})
+
+#define peek_next(t, insn)		\
+({					\
+	if (unlikely(!validate_next(t, insn, 0)))	\
+		goto err_out;		\
+	__peek_next(t, insn);		\
+})
+
+static void mpx_insn_get_prefixes(struct mpx_insn *insn)
+{
+	unsigned char b;
+
+	/* Decode legacy prefix and REX prefix */
+	b = peek_next(unsigned char, insn);
+	while (b != 0x0f) {
+		/*
+		 * look for a rex prefix
+		 * a REX prefix cannot be followed by a legacy prefix.
+		 */
+		if (insn->x86_64 && ((b&0xf0) == 0x40)) {
+			insn->rex_prefix.value = b;
+			insn->rex_prefix.nbytes = 1;
+			insn->next_byte++;
+			break;
+		}
+
+		/* check the other legacy prefixes */
+		switch (b) {
+		case 0xf2:
+		case 0xf3:
+		case 0xf0:
+		case 0x64:
+		case 0x65:
+		case 0x2e:
+		case 0x3e:
+		case 0x26:
+		case 0x36:
+		case 0x66:
+		case 0x67:
+			insn->next_byte++;
+			break;
+		default: /* everything else is garbage */
+			goto err_out;
+		}
+		b = peek_next(unsigned char, insn);
+	}
+
+err_out:
+	return;
+}
+
+static void mpx_insn_get_modrm(struct mpx_insn *insn)
+{
+	insn->modrm.value = get_next(unsigned char, insn);
+	insn->modrm.nbytes = 1;
+
+err_out:
+	return;
+}
+
+static void mpx_insn_get_sib(struct mpx_insn *insn)
+{
+	unsigned char modrm = (unsigned char)insn->modrm.value;
+
+	if (X86_MODRM_MOD(modrm) != 3 && X86_MODRM_RM(modrm) == 4) {
+		insn->sib.value = get_next(unsigned char, insn);
+		insn->sib.nbytes = 1;
+	}
+
+err_out:
+	return;
+}
+
+static void mpx_insn_get_displacement(struct mpx_insn *insn)
+{
+	unsigned char mod, rm, base;
+
+	/*
+	 * Interpreting the modrm byte:
+	 * mod = 00 - no displacement fields (exceptions below)
+	 * mod = 01 - 1-byte displacement field
+	 * mod = 10 - displacement field is 4 bytes
+	 * mod = 11 - no memory operand
+	 *
+	 * mod != 11, r/m = 100 - SIB byte exists
+	 * mod = 00, SIB base = 101 - displacement field is 4 bytes
+	 * mod = 00, r/m = 101 - rip-relative addressing, displacement
+	 *	field is 4 bytes
+	 */
+	mod = X86_MODRM_MOD(insn->modrm.value);
+	rm = X86_MODRM_RM(insn->modrm.value);
+	base = X86_SIB_BASE(insn->sib.value);
+	if (mod == 3)
+		return;
+	if (mod == 1) {
+		insn->displacement.value = get_next(unsigned char, insn);
+		insn->displacement.nbytes = 1;
+	} else if ((mod == 0 && rm == 5) || mod == 2 ||
+			(mod == 0 && base == 5)) {
+		insn->displacement.value = get_next(int, insn);
+		insn->displacement.nbytes = 4;
+	}
+
+err_out:
+	return;
+}
+
+static void mpx_insn_init(struct mpx_insn *insn, struct pt_regs *regs)
+{
+	unsigned char buf[MAX_MPX_INSN_SIZE];
+	int bytes;
+
+	memset(insn, 0, sizeof(*insn));
+
+	bytes = copy_from_user(buf, (void __user *)regs->ip, MAX_MPX_INSN_SIZE);
+	insn->limit = MAX_MPX_INSN_SIZE - bytes;
+	insn->kaddr = buf;
+	insn->next_byte = buf;
+
+	/*
+	 * In 64-bit Mode, all Intel MPX instructions use 64-bit
+	 * operands for bounds and 64 bit addressing, i.e. REX.W &
+	 * 67H have no effect on data or address size.
+	 *
+	 * In compatibility and legacy modes (including 16-bit code
+	 * segments, real and virtual 8086 modes) all Intel MPX
+	 * instructions use 32-bit operands for bounds and 32 bit
+	 * addressing.
+	 */
+#ifdef CONFIG_X86_64
+	insn->x86_64 = 1;
+	insn->addr_bytes = 8;
+#else
+	insn->x86_64 = 0;
+	insn->addr_bytes = 4;
+#endif
+}
+
+static unsigned long mpx_insn_decode(struct mpx_insn *insn,
+				     struct pt_regs *regs)
+{
+	mpx_insn_init(insn, regs);
+
+	/*
+	 * In this case, we only need decode bndcl/bndcn/bndcu,
+	 * so we can use private diassembly interfaces to get
+	 * prefixes, modrm, sib, displacement, etc..
+	 */
+	mpx_insn_get_prefixes(insn);
+	insn->next_byte += 2; /* ignore opcode */
+	mpx_insn_get_modrm(insn);
+	mpx_insn_get_sib(insn);
+	mpx_insn_get_displacement(insn);
+
+	return get_addr_ref(insn, regs);
+}
+
 static int allocate_bt(long __user *bd_entry)
 {
 	unsigned long bt_addr, old_val = 0;
@@ -56,3 +325,33 @@ int do_mpx_bt_fault(struct xsave_struct *xsave_buf)
 
 	return allocate_bt((long __user *)bd_entry);
 }
+
+/*
+ * If a bounds overflow occurs then a #BR is generated. The fault
+ * handler will decode MPX instructions to get violation address
+ * and set this address into extended struct siginfo.
+ */
+void do_mpx_bounds(struct pt_regs *regs, siginfo_t *info,
+		struct xsave_struct *xsave_buf)
+{
+	struct mpx_insn insn;
+	uint8_t bndregno;
+	unsigned long addr_vio;
+
+	addr_vio = mpx_insn_decode(&insn, regs);
+
+	bndregno = X86_MODRM_REG(insn.modrm.value);
+	if (bndregno > 3)
+		return;
+
+	/* Note: the upper 32 bits are ignored in 32-bit mode. */
+	info->si_lower = (void __user *)(unsigned long)
+		(xsave_buf->bndregs.bndregs[2*bndregno]);
+	info->si_upper = (void __user *)(unsigned long)
+		(~xsave_buf->bndregs.bndregs[2*bndregno+1]);
+	info->si_addr_lsb = 0;
+	info->si_signo = SIGSEGV;
+	info->si_errno = 0;
+	info->si_code = SEGV_BNDERR;
+	info->si_addr = (void __user *)addr_vio;
+}
diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
index 396a88b..93ce924 100644
--- a/arch/x86/kernel/traps.c
+++ b/arch/x86/kernel/traps.c
@@ -284,6 +284,7 @@ dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
 	unsigned long status;
 	struct xsave_struct *xsave_buf;
 	struct task_struct *tsk = current;
+	siginfo_t info;
 
 	prev_state = exception_enter();
 	if (notify_die(DIE_TRAP, "bounds", regs, error_code,
@@ -319,6 +320,11 @@ dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
 		break;
 
 	case 1: /* Bound violation. */
+		do_mpx_bounds(regs, &info, xsave_buf);
+		do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs,
+				error_code, &info);
+		break;
+
 	case 0: /* No exception caused by Intel MPX operations. */
 		do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs, error_code, NULL);
 		break;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
