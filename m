Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB426B006E
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:04:08 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id pAAJ41HK017730
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 00:34:01 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAJ41wd2465988
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 00:34:01 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAJ40Zj007743
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:04:01 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2011 00:09:06 +0530
Message-Id: <20111110183906.11361.50185.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
References: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v6 3.2-rc1 8/28]   x86: analyze instruction and determine fixups.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


The instruction analysis is based on x86 instruction decoder and
determines if an instruction can be probed and determines the necessary
fixups after singlestep.  Instruction analysis is done at probe
insertion time so that we avoid having to repeat the same analysis every
time a probe is hit.

Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---

Changelog (since v5)
- Include Instruction Decoder if Uprobes gets defined.
- Remove const attributes for instruction prefix arrays.
- Uses mm_context to know if the application is 32 bit.

 arch/x86/Kconfig               |    5 -
 arch/x86/include/asm/uprobes.h |   42 ++++
 arch/x86/kernel/Makefile       |    1 
 arch/x86/kernel/uprobes.c      |  399 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 446 insertions(+), 1 deletions(-)
 create mode 100644 arch/x86/include/asm/uprobes.h
 create mode 100644 arch/x86/kernel/uprobes.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index cb9a104..029b4cc 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -77,7 +77,7 @@ config X86
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 
 config INSTRUCTION_DECODER
-	def_bool (KPROBES || PERF_EVENTS)
+	def_bool (KPROBES || PERF_EVENTS || UPROBES)
 
 config OUTPUT_FORMAT
 	string
@@ -249,6 +249,9 @@ config ARCH_CPU_PROBE_RELEASE
 	def_bool y
 	depends on HOTPLUG_CPU
 
+config ARCH_SUPPORTS_UPROBES
+	def_bool y
+
 source "init/Kconfig"
 source "kernel/Kconfig.freezer"
 
diff --git a/arch/x86/include/asm/uprobes.h b/arch/x86/include/asm/uprobes.h
new file mode 100644
index 0000000..f0b4b2b
--- /dev/null
+++ b/arch/x86/include/asm/uprobes.h
@@ -0,0 +1,42 @@
+#ifndef _ASM_UPROBES_H
+#define _ASM_UPROBES_H
+/*
+ * Userspace Probes (UProbes) for x86
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *
+ * Copyright (C) IBM Corporation, 2008-2011
+ * Authors:
+ *	Srikar Dronamraju
+ *	Jim Keniston
+ */
+
+typedef u8 uprobe_opcode_t;
+#define MAX_UINSN_BYTES 16
+#define UPROBES_XOL_SLOT_BYTES	128	/* to keep it cache aligned */
+
+#define UPROBES_BKPT_INSN 0xcc
+#define UPROBES_BKPT_INSN_SIZE 1
+
+#ifdef CONFIG_X86_64
+struct uprobe_arch_info {
+	unsigned long rip_rela_target_address;
+};
+#else
+struct uprobe_arch_info {};
+#endif
+struct uprobe;
+extern int analyze_insn(struct mm_struct *mm, struct uprobe *uprobe);
+#endif	/* _ASM_UPROBES_H */
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 8baca3c..8f28be8 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -98,6 +98,7 @@ obj-$(CONFIG_X86_CHECK_BIOS_CORRUPTION) += check.o
 
 obj-$(CONFIG_SWIOTLB)			+= pci-swiotlb.o
 obj-$(CONFIG_OF)			+= devicetree.o
+obj-$(CONFIG_UPROBES)			+= uprobes.o
 
 ###
 # 64 bit specific files
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
new file mode 100644
index 0000000..0be7e67
--- /dev/null
+++ b/arch/x86/kernel/uprobes.c
@@ -0,0 +1,399 @@
+/*
+ * Userspace Probes (UProbes) for x86
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *
+ * Copyright (C) IBM Corporation, 2008-2011
+ * Authors:
+ *	Srikar Dronamraju
+ *	Jim Keniston
+ */
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/ptrace.h>
+#include <linux/uprobes.h>
+
+#include <linux/kdebug.h>
+#include <asm/insn.h>
+
+#ifdef CONFIG_X86_32
+#define is_32bit_app(tsk) 1
+#else
+#define is_32bit_app(tsk) (test_tsk_thread_flag(tsk, TIF_IA32))
+#endif
+
+#define UPROBES_FIX_RIP_AX	0x8000
+#define UPROBES_FIX_RIP_CX	0x4000
+
+/* Adaptations for mhiramat x86 decoder v14. */
+#define OPCODE1(insn) ((insn)->opcode.bytes[0])
+#define OPCODE2(insn) ((insn)->opcode.bytes[1])
+#define OPCODE3(insn) ((insn)->opcode.bytes[2])
+#define MODRM_REG(insn) X86_MODRM_REG(insn->modrm.value)
+
+#define W(row, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, ba, bb, bc, bd, be, bf)\
+	(((b0##UL << 0x0)|(b1##UL << 0x1)|(b2##UL << 0x2)|(b3##UL << 0x3) |   \
+	  (b4##UL << 0x4)|(b5##UL << 0x5)|(b6##UL << 0x6)|(b7##UL << 0x7) |   \
+	  (b8##UL << 0x8)|(b9##UL << 0x9)|(ba##UL << 0xa)|(bb##UL << 0xb) |   \
+	  (bc##UL << 0xc)|(bd##UL << 0xd)|(be##UL << 0xe)|(bf##UL << 0xf))    \
+	 << (row % 32))
+
+#ifdef CONFIG_X86_64
+static volatile u32 good_insns_64[256 / 32] = {
+	/*      0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f         */
+	/*      ----------------------------------------------         */
+	W(0x00, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0) | /* 00 */
+	W(0x10, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0) , /* 10 */
+	W(0x20, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0) | /* 20 */
+	W(0x30, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0) , /* 30 */
+	W(0x40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0) | /* 40 */
+	W(0x50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) , /* 50 */
+	W(0x60, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0) | /* 60 */
+	W(0x70, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) , /* 70 */
+	W(0x80, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) | /* 80 */
+	W(0x90, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) , /* 90 */
+	W(0xa0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) | /* a0 */
+	W(0xb0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) , /* b0 */
+	W(0xc0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0) | /* c0 */
+	W(0xd0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1) , /* d0 */
+	W(0xe0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0) | /* e0 */
+	W(0xf0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1)   /* f0 */
+	/*      ----------------------------------------------         */
+	/*      0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f         */
+};
+#endif
+
+/* Good-instruction tables for 32-bit apps */
+
+static volatile u32 good_insns_32[256 / 32] = {
+	/*      0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f         */
+	/*      ----------------------------------------------         */
+	W(0x00, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0) | /* 00 */
+	W(0x10, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0) , /* 10 */
+	W(0x20, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1) | /* 20 */
+	W(0x30, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1) , /* 30 */
+	W(0x40, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) | /* 40 */
+	W(0x50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) , /* 50 */
+	W(0x60, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0) | /* 60 */
+	W(0x70, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) , /* 70 */
+	W(0x80, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) | /* 80 */
+	W(0x90, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) , /* 90 */
+	W(0xa0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) | /* a0 */
+	W(0xb0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) , /* b0 */
+	W(0xc0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0) | /* c0 */
+	W(0xd0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1) , /* d0 */
+	W(0xe0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0) | /* e0 */
+	W(0xf0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1)   /* f0 */
+	/*      ----------------------------------------------         */
+	/*      0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f         */
+};
+
+/* Using this for both 64-bit and 32-bit apps */
+static volatile u32 good_2byte_insns[256 / 32] = {
+	/*      0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f         */
+	/*      ----------------------------------------------         */
+	W(0x00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1) | /* 00 */
+	W(0x10, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1) , /* 10 */
+	W(0x20, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1) | /* 20 */
+	W(0x30, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0) , /* 30 */
+	W(0x40, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) | /* 40 */
+	W(0x50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) , /* 50 */
+	W(0x60, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) | /* 60 */
+	W(0x70, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1) , /* 70 */
+	W(0x80, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) | /* 80 */
+	W(0x90, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) , /* 90 */
+	W(0xa0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1) | /* a0 */
+	W(0xb0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1) , /* b0 */
+	W(0xc0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) | /* c0 */
+	W(0xd0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) , /* d0 */
+	W(0xe0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1) | /* e0 */
+	W(0xf0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0)   /* f0 */
+	/*      ----------------------------------------------         */
+	/*      0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f         */
+};
+
+#undef W
+
+/*
+ * opcodes we'll probably never support:
+ * 6c-6d, e4-e5, ec-ed - in
+ * 6e-6f, e6-e7, ee-ef - out
+ * cc, cd - int3, int
+ * cf - iret
+ * d6 - illegal instruction
+ * f1 - int1/icebp
+ * f4 - hlt
+ * fa, fb - cli, sti
+ * 0f - lar, lsl, syscall, clts, sysret, sysenter, sysexit, invd, wbinvd, ud2
+ *
+ * invalid opcodes in 64-bit mode:
+ * 06, 0e, 16, 1e, 27, 2f, 37, 3f, 60-62, 82, c4-c5, d4-d5
+ *
+ * 63 - we support this opcode in x86_64 but not in i386.
+ *
+ * opcodes we may need to refine support for:
+ * 0f - 2-byte instructions: For many of these instructions, the validity
+ * depends on the prefix and/or the reg field.  On such instructions, we
+ * just consider the opcode combination valid if it corresponds to any
+ * valid instruction.
+ * 8f - Group 1 - only reg = 0 is OK
+ * c6-c7 - Group 11 - only reg = 0 is OK
+ * d9-df - fpu insns with some illegal encodings
+ * f2, f3 - repnz, repz prefixes.  These are also the first byte for
+ * certain floating-point instructions, such as addsd.
+ * fe - Group 4 - only reg = 0 or 1 is OK
+ * ff - Group 5 - only reg = 0-6 is OK
+ *
+ * others -- Do we need to support these?
+ * 0f - (floating-point?) prefetch instructions
+ * 07, 17, 1f - pop es, pop ss, pop ds
+ * 26, 2e, 36, 3e - es:, cs:, ss:, ds: segment prefixes --
+ *	but 64 and 65 (fs: and gs:) seem to be used, so we support them
+ * 67 - addr16 prefix
+ * ce - into
+ * f0 - lock prefix
+ */
+
+/*
+ * TODO:
+ * - Where necessary, examine the modrm byte and allow only valid instructions
+ * in the different Groups and fpu instructions.
+ */
+
+static bool is_prefix_bad(struct insn *insn)
+{
+	int i;
+
+	for (i = 0; i < insn->prefixes.nbytes; i++) {
+		switch (insn->prefixes.bytes[i]) {
+		case 0x26:	/*INAT_PFX_ES   */
+		case 0x2E:	/*INAT_PFX_CS   */
+		case 0x36:	/*INAT_PFX_DS   */
+		case 0x3E:	/*INAT_PFX_SS   */
+		case 0xF0:	/*INAT_PFX_LOCK */
+			return true;
+		}
+	}
+	return false;
+}
+
+static int validate_insn_32bits(struct uprobe *uprobe, struct insn *insn)
+{
+	insn_init(insn, uprobe->insn, false);
+
+	/* Skip good instruction prefixes; reject "bad" ones. */
+	insn_get_opcode(insn);
+	if (is_prefix_bad(insn))
+		return -ENOTSUPP;
+	if (test_bit(OPCODE1(insn), (unsigned long *)good_insns_32))
+		return 0;
+	if (insn->opcode.nbytes == 2) {
+		if (test_bit(OPCODE2(insn), (unsigned long *)good_2byte_insns))
+			return 0;
+	}
+	return -ENOTSUPP;
+}
+
+/*
+ * Figure out which fixups post_xol() will need to perform, and annotate
+ * uprobe->fixups accordingly.  To start with, uprobe->fixups is
+ * either zero or it reflects rip-related fixups.
+ */
+static void prepare_fixups(struct uprobe *uprobe, struct insn *insn)
+{
+	bool fix_ip = true, fix_call = false;	/* defaults */
+	int reg;
+
+	insn_get_opcode(insn);	/* should be a nop */
+
+	switch (OPCODE1(insn)) {
+	case 0xc3:		/* ret/lret */
+	case 0xcb:
+	case 0xc2:
+	case 0xca:
+		/* ip is correct */
+		fix_ip = false;
+		break;
+	case 0xe8:		/* call relative - Fix return addr */
+		fix_call = true;
+		break;
+	case 0x9a:		/* call absolute - Fix return addr, not ip */
+		fix_call = true;
+		fix_ip = false;
+		break;
+	case 0xff:
+		insn_get_modrm(insn);
+		reg = MODRM_REG(insn);
+		if (reg == 2 || reg == 3) {
+			/* call or lcall, indirect */
+			/* Fix return addr; ip is correct. */
+			fix_call = true;
+			fix_ip = false;
+		} else if (reg == 4 || reg == 5) {
+			/* jmp or ljmp, indirect */
+			/* ip is correct. */
+			fix_ip = false;
+		}
+		break;
+	case 0xea:		/* jmp absolute -- ip is correct */
+		fix_ip = false;
+		break;
+	default:
+		break;
+	}
+	if (fix_ip)
+		uprobe->fixups |= UPROBES_FIX_IP;
+	if (fix_call)
+		uprobe->fixups |= UPROBES_FIX_CALL;
+}
+
+#ifdef CONFIG_X86_64
+/*
+ * If uprobe->insn doesn't use rip-relative addressing, return
+ * immediately.  Otherwise, rewrite the instruction so that it accesses
+ * its memory operand indirectly through a scratch register.  Set
+ * uprobe->fixups and uprobe->arch_info.rip_rela_target_address
+ * accordingly.  (The contents of the scratch register will be saved
+ * before we single-step the modified instruction, and restored
+ * afterward.)
+ *
+ * We do this because a rip-relative instruction can access only a
+ * relatively small area (+/- 2 GB from the instruction), and the XOL
+ * area typically lies beyond that area.  At least for instructions
+ * that store to memory, we can't execute the original instruction
+ * and "fix things up" later, because the misdirected store could be
+ * disastrous.
+ *
+ * Some useful facts about rip-relative instructions:
+ * - There's always a modrm byte.
+ * - There's never a SIB byte.
+ * - The displacement is always 4 bytes.
+ */
+static void handle_riprel_insn(struct mm_struct *mm, struct uprobe *uprobe,
+							struct insn *insn)
+{
+	u8 *cursor;
+	u8 reg;
+
+	if (mm->context.ia32_compat)
+		return;
+
+	uprobe->arch_info.rip_rela_target_address = 0x0;
+	if (!insn_rip_relative(insn))
+		return;
+
+	/*
+	 * Point cursor at the modrm byte.  The next 4 bytes are the
+	 * displacement.  Beyond the displacement, for some instructions,
+	 * is the immediate operand.
+	 */
+	cursor = uprobe->insn + insn->prefixes.nbytes
+			+ insn->rex_prefix.nbytes + insn->opcode.nbytes;
+	insn_get_length(insn);
+
+	/*
+	 * Convert from rip-relative addressing to indirect addressing
+	 * via a scratch register.  Change the r/m field from 0x5 (%rip)
+	 * to 0x0 (%rax) or 0x1 (%rcx), and squeeze out the offset field.
+	 */
+	reg = MODRM_REG(insn);
+	if (reg == 0) {
+		/*
+		 * The register operand (if any) is either the A register
+		 * (%rax, %eax, etc.) or (if the 0x4 bit is set in the
+		 * REX prefix) %r8.  In any case, we know the C register
+		 * is NOT the register operand, so we use %rcx (register
+		 * #1) for the scratch register.
+		 */
+		uprobe->fixups = UPROBES_FIX_RIP_CX;
+		/* Change modrm from 00 000 101 to 00 000 001. */
+		*cursor = 0x1;
+	} else {
+		/* Use %rax (register #0) for the scratch register. */
+		uprobe->fixups = UPROBES_FIX_RIP_AX;
+		/* Change modrm from 00 xxx 101 to 00 xxx 000 */
+		*cursor = (reg << 3);
+	}
+
+	/* Target address = address of next instruction + (signed) offset */
+	uprobe->arch_info.rip_rela_target_address = (long)insn->length
+					+ insn->displacement.value;
+	/* Displacement field is gone; slide immediate field (if any) over. */
+	if (insn->immediate.nbytes) {
+		cursor++;
+		memmove(cursor, cursor + insn->displacement.nbytes,
+						insn->immediate.nbytes);
+	}
+	return;
+}
+
+static int validate_insn_64bits(struct uprobe *uprobe, struct insn *insn)
+{
+	insn_init(insn, uprobe->insn, true);
+
+	/* Skip good instruction prefixes; reject "bad" ones. */
+	insn_get_opcode(insn);
+	if (is_prefix_bad(insn))
+		return -ENOTSUPP;
+	if (test_bit(OPCODE1(insn), (unsigned long *)good_insns_64))
+		return 0;
+	if (insn->opcode.nbytes == 2) {
+		if (test_bit(OPCODE2(insn), (unsigned long *)good_2byte_insns))
+			return 0;
+	}
+	return -ENOTSUPP;
+}
+
+static int validate_insn_bits(struct mm_struct *mm, struct uprobe *uprobe,
+				struct insn *insn)
+{
+	if (mm->context.ia32_compat)
+		return validate_insn_32bits(uprobe, insn);
+	return validate_insn_64bits(uprobe, insn);
+}
+#else
+static void handle_riprel_insn(struct mm_struct *mm, struct uprobe *uprobe,
+							struct insn *insn)
+{
+	return;
+}
+
+static int validate_insn_bits(struct mm_struct *mm, struct uprobe *uprobe,
+				struct insn *insn)
+{
+	return validate_insn_32bits(uprobe, insn);
+}
+#endif /* CONFIG_X86_64 */
+
+/**
+ * analyze_insn - instruction analysis including validity and fixups.
+ * @mm: the probed address space.
+ * @uprobe: the probepoint information.
+ * Return 0 on success or a -ve number on error.
+ */
+int analyze_insn(struct mm_struct *mm, struct uprobe *uprobe)
+{
+	int ret;
+	struct insn insn;
+
+	uprobe->fixups = 0;
+	ret = validate_insn_bits(mm, uprobe, &insn);
+	if (ret != 0)
+		return ret;
+	handle_riprel_insn(mm, uprobe, &insn);
+	prepare_fixups(uprobe, &insn);
+	return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
