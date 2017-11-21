Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 469FF6B0266
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 13:26:47 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id a63so8254527wrc.1
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 10:26:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2sor5125969wre.47.2017.11.21.10.26.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 10:26:45 -0800 (PST)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v4 07/10] Trampoline emulation
Date: Tue, 21 Nov 2017 19:26:09 +0100
Message-Id: <1511288772-19308-8-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
References: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, James Morris <james.l.morris@oracle.com>, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, Thomas Gleixner <tglx@linutronix.de>, "Serge E. Hallyn" <serge@hallyn.com>

Some programs need to generate part of their code at runtime. Luckily
enough, in some cases they only generate well-known code sequences (the
"trampolines") that can be easily recognized and emulated by the kernel.
This way WX Protection can still be active, so a potential attacker won't
be able to generate arbitrary sequences of code, but just those that are
explicitly allowed. This is not ideal, but it's still better than having WX
Protection completely disabled.
In particular S.A.R.A. is able to recognize trampolines used by GCC for
nested C functions and libffi's trampolines.
This feature is implemented only on x86_32 and x86_64.
Trampoline emulation is modified from Brad Spengler/PaX Team's code in the
last public patch of grsecurity/PaX based on my understanding of the code.
Changes or omissions from the original code are mine and don't reflect the
original grsecurity/PaX code.

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 arch/x86/Kbuild                        |   2 +
 arch/x86/security/Makefile             |   2 +
 arch/x86/security/sara/Makefile        |   1 +
 arch/x86/security/sara/emutramp.c      |  55 ++++++++++++
 arch/x86/security/sara/trampolines32.h | 122 +++++++++++++++++++++++++++
 arch/x86/security/sara/trampolines64.h | 148 +++++++++++++++++++++++++++++++++
 security/sara/Kconfig                  |  18 ++++
 security/sara/include/emutramp.h       |  33 ++++++++
 security/sara/wxprot.c                 |  29 +++++++
 9 files changed, 410 insertions(+)
 create mode 100644 arch/x86/security/Makefile
 create mode 100644 arch/x86/security/sara/Makefile
 create mode 100644 arch/x86/security/sara/emutramp.c
 create mode 100644 arch/x86/security/sara/trampolines32.h
 create mode 100644 arch/x86/security/sara/trampolines64.h
 create mode 100644 security/sara/include/emutramp.h

diff --git a/arch/x86/Kbuild b/arch/x86/Kbuild
index 0038a2d..5509047 100644
--- a/arch/x86/Kbuild
+++ b/arch/x86/Kbuild
@@ -22,3 +22,5 @@ obj-y += platform/
 obj-y += net/
 
 obj-$(CONFIG_KEXEC_FILE) += purgatory/
+
+obj-y += security/
diff --git a/arch/x86/security/Makefile b/arch/x86/security/Makefile
new file mode 100644
index 0000000..ba4be4c
--- /dev/null
+++ b/arch/x86/security/Makefile
@@ -0,0 +1,2 @@
+subdir-$(CONFIG_SECURITY_SARA)		+= sara
+obj-$(CONFIG_SECURITY_SARA)		+= sara/
diff --git a/arch/x86/security/sara/Makefile b/arch/x86/security/sara/Makefile
new file mode 100644
index 0000000..a4a76217
--- /dev/null
+++ b/arch/x86/security/sara/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP) := emutramp.o
diff --git a/arch/x86/security/sara/emutramp.c b/arch/x86/security/sara/emutramp.c
new file mode 100644
index 0000000..6114e87
--- /dev/null
+++ b/arch/x86/security/sara/emutramp.c
@@ -0,0 +1,55 @@
+/*
+ * S.A.R.A. Linux Security Module
+ *
+ * Copyright (C) 2017 Salvatore Mesoraca <s.mesoraca16@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ *
+ * Assembly sequences used here were copied from
+ * PaX patch by PaX Team <pageexec@freemail.hu>
+ * Being just hexadecimal constants, they are not subject to
+ * any copyright.
+ *
+ */
+
+#define PF_PROT		(1 << 0)
+#define PF_USER		(1 << 2)
+#define PF_INSTR	(1 << 4)
+
+#ifdef CONFIG_X86_32
+
+#include "trampolines32.h"
+static inline int trampoline_emulator(struct pt_regs *regs,
+				      unsigned long address)
+{
+	return sara_trampoline_emulator_x86_32(regs);
+}
+
+#else /* CONFIG_X86_32 */
+
+#include "trampolines64.h"
+static inline int trampoline_emulator(struct pt_regs *regs,
+				      unsigned long address)
+{
+	return sara_trampoline_emulator_x86_64(regs, address);
+}
+
+#endif /* CONFIG_X86_32 */
+
+
+int sara_trampoline_emulator(struct pt_regs *regs,
+			     unsigned long error_code,
+			     unsigned long address)
+{
+	if (!(error_code & PF_USER) ||
+	    !(error_code & PF_INSTR) ||
+	    !(error_code & PF_PROT))
+		return 0;
+
+	local_irq_enable();
+	might_sleep();
+	might_fault();
+	return trampoline_emulator(regs, address);
+}
diff --git a/arch/x86/security/sara/trampolines32.h b/arch/x86/security/sara/trampolines32.h
new file mode 100644
index 0000000..9ff4385
--- /dev/null
+++ b/arch/x86/security/sara/trampolines32.h
@@ -0,0 +1,122 @@
+/*
+ * S.A.R.A. Linux Security Module
+ *
+ * Copyright (C) 2017 Salvatore Mesoraca <s.mesoraca16@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ *
+ * Assembly sequences used here were copied from
+ * PaX patch by PaX Team <pageexec@freemail.hu>
+ * Being just hexadecimal constants, they are not subject to
+ * any copyright.
+ *
+ */
+
+#ifndef __TRAMPOLINES32_H
+#define __TRAMPOLINES32_H
+
+#include <linux/printk.h>
+#include <linux/uaccess.h>
+
+struct libffi_trampoline_x86_32 {
+	unsigned char mov;
+	unsigned int addr1;
+	unsigned char jmp;
+	unsigned int addr2;
+} __packed;
+
+struct gcc_trampoline_x86_32_type1 {
+	unsigned char mov1;
+	unsigned int addr1;
+	unsigned char mov2;
+	unsigned int addr2;
+	unsigned short jmp;
+} __packed;
+
+struct gcc_trampoline_x86_32_type2 {
+	unsigned char mov;
+	unsigned int addr1;
+	unsigned char jmp;
+	unsigned int addr2;
+} __packed;
+
+union trampolines_x86_32 {
+	struct libffi_trampoline_x86_32 lf;
+	struct gcc_trampoline_x86_32_type1 g1;
+	struct gcc_trampoline_x86_32_type2 g2;
+};
+
+#define is_valid_libffi_trampoline_x86_32(UNION)	\
+	(UNION.lf.mov == 0xB8 &&			\
+	UNION.lf.jmp == 0xE9)
+
+#define emulate_libffi_trampoline_x86_32(UNION, REGS) do {	\
+	(REGS)->ax = UNION.lf.addr1;				\
+	(REGS)->ip = (unsigned int) ((REGS)->ip +		\
+				     UNION.lf.addr2 +		\
+				     sizeof(UNION.lf));		\
+} while (0)
+
+#define is_valid_gcc_trampoline_x86_32_type1(UNION, REGS)	\
+	(UNION.g1.mov1 == 0xB9 &&				\
+	UNION.g1.mov2 == 0xB8 &&				\
+	UNION.g1.jmp == 0xE0FF &&				\
+	REGS->ip > REGS->sp)
+
+#define emulate_gcc_trampoline_x86_32_type1(UNION, REGS) do {	\
+	(REGS)->cx = UNION.g1.addr1;				\
+	(REGS)->ax = UNION.g1.addr2;				\
+	(REGS)->ip = UNION.g1.addr2;				\
+} while (0)
+
+#define is_valid_gcc_trampoline_x86_32_type2(UNION, REGS)	\
+	(UNION.g2.mov == 0xB9 &&				\
+	UNION.g2.jmp == 0xE9 &&					\
+	REGS->ip > REGS->sp)
+
+#define emulate_gcc_trampoline_x86_32_type2(UNION, REGS) do {	\
+	(REGS)->cx = UNION.g2.addr1;				\
+	(REGS)->ip = (unsigned int) ((REGS)->ip +		\
+				     UNION.g2.addr2 +		\
+				     sizeof(UNION.g2));		\
+} while (0)
+
+static inline int sara_trampoline_emulator_x86_32(struct pt_regs *regs)
+{
+	int ret;
+	void __user *ip = (void __user *) regs->ip;
+	union trampolines_x86_32 t;
+
+	BUILD_BUG_ON(sizeof(t.lf) > sizeof(t.g1));
+	BUILD_BUG_ON(sizeof(t.g2) > sizeof(t.lf));
+
+	ret = copy_from_user(&t, ip, sizeof(t.g1));
+	if (ret)
+		ret = copy_from_user(&t, ip, sizeof(t.lf));
+	if (ret)
+		ret = copy_from_user(&t, ip, sizeof(t.g2));
+	if (ret)
+		return 0;
+
+	if (is_valid_gcc_trampoline_x86_32_type1(t, regs)) {
+		pr_debug("Trampoline: gcc1 x86_32.\n");
+		emulate_gcc_trampoline_x86_32_type1(t, regs);
+		return 1;
+	} else if (is_valid_libffi_trampoline_x86_32(t)) {
+		pr_debug("Trampoline: libffi x86_32.\n");
+		emulate_libffi_trampoline_x86_32(t, regs);
+		return 1;
+	} else if (is_valid_gcc_trampoline_x86_32_type2(t, regs)) {
+		pr_debug("Trampoline: gcc2 x86_32.\n");
+		emulate_gcc_trampoline_x86_32_type2(t, regs);
+		return 1;
+	}
+
+	pr_debug("Not a trampoline (x86_32).\n");
+
+	return 0;
+}
+
+#endif /* __TRAMPOLINES32_H */
diff --git a/arch/x86/security/sara/trampolines64.h b/arch/x86/security/sara/trampolines64.h
new file mode 100644
index 0000000..4be010c
--- /dev/null
+++ b/arch/x86/security/sara/trampolines64.h
@@ -0,0 +1,148 @@
+/*
+ * S.A.R.A. Linux Security Module
+ *
+ * Copyright (C) 2017 Salvatore Mesoraca <s.mesoraca16@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ *
+ * Assembly sequences used here were copied from
+ * PaX patch by PaX Team <pageexec@freemail.hu>
+ * Being just hexadecimal constants, they are not subject to
+ * any copyright.
+ *
+ */
+
+#ifndef __TRAMPOLINES64_H
+#define __TRAMPOLINES64_H
+
+#include <linux/printk.h>
+#include <linux/uaccess.h>
+
+#include "trampolines32.h"
+
+struct libffi_trampoline_x86_64 {
+	unsigned short mov1;
+	unsigned long addr1;
+	unsigned short mov2;
+	unsigned long addr2;
+	unsigned char stcclc;
+	unsigned short jmp1;
+	unsigned char jmp2;
+} __packed;
+
+struct gcc_trampoline_x86_64_type1 {
+	unsigned short mov1;
+	unsigned long addr1;
+	unsigned short mov2;
+	unsigned long addr2;
+	unsigned short jmp1;
+	unsigned char jmp2;
+} __packed;
+
+struct gcc_trampoline_x86_64_type2 {
+	unsigned short mov1;
+	unsigned int addr1;
+	unsigned short mov2;
+	unsigned long addr2;
+	unsigned short jmp1;
+	unsigned char jmp2;
+} __packed;
+
+union trampolines_x86_64 {
+	struct libffi_trampoline_x86_64 lf;
+	struct gcc_trampoline_x86_64_type1 g1;
+	struct gcc_trampoline_x86_64_type2 g2;
+};
+
+#define is_valid_libffi_trampoline_x86_64(UNION)	\
+	(UNION.lf.mov1 == 0xBB49 &&			\
+	UNION.lf.mov2 == 0xBA49 &&			\
+	(UNION.lf.stcclc == 0xF8 ||			\
+	 UNION.lf.stcclc == 0xF9) &&			\
+	UNION.lf.jmp1 == 0xFF49 &&			\
+	UNION.lf.jmp2 == 0xE3)
+
+#define emulate_libffi_trampoline_x86_64(UNION, REGS) do {	\
+	(REGS)->r11 = UNION.lf.addr1;				\
+	(REGS)->r10 = UNION.lf.addr2;				\
+	(REGS)->ip = UNION.lf.addr1;				\
+	if (UNION.lf.stcclc == 0xF8)				\
+		(REGS)->flags &= ~X86_EFLAGS_CF;		\
+	else							\
+		(REGS)->flags |= X86_EFLAGS_CF;			\
+} while (0)
+
+#define is_valid_gcc_trampoline_x86_64_type1(UNION, REGS)	\
+	(UNION.g1.mov1 == 0xBB49 &&				\
+	UNION.g1.mov2 == 0xBA49 &&				\
+	UNION.g1.jmp1 == 0xFF49 &&				\
+	UNION.g1.jmp2 == 0xE3 &&				\
+	REGS->ip > REGS->sp)
+
+#define emulate_gcc_trampoline_x86_64_type1(UNION, REGS) do {	\
+	(REGS)->r11 = UNION.g1.addr1;				\
+	(REGS)->r10 = UNION.g1.addr2;				\
+	(REGS)->ip = UNION.g1.addr1;				\
+} while (0)
+
+#define is_valid_gcc_trampoline_x86_64_type2(UNION, REGS)	\
+	(UNION.g2.mov1 == 0xBB41 &&				\
+	UNION.g2.mov2 == 0xBA49 &&				\
+	UNION.g2.jmp1 == 0xFF49 &&				\
+	UNION.g2.jmp2 == 0xE3 &&				\
+	REGS->ip > REGS->sp)
+
+#define emulate_gcc_trampoline_x86_64_type2(UNION, REGS) do {	\
+	(REGS)->r11 = UNION.g2.addr1;				\
+	(REGS)->r10 = UNION.g2.addr2;				\
+	(REGS)->ip = UNION.g2.addr1;				\
+} while (0)
+
+static inline int sara_trampoline_emulator_x86_64(struct pt_regs *regs,
+						  unsigned long address)
+{
+	int ret;
+	void __user *ip = (void __user *) regs->ip;
+	union trampolines_x86_64 t;
+
+	BUILD_BUG_ON(sizeof(t.g1) > sizeof(t.lf));
+	BUILD_BUG_ON(sizeof(t.g2) > sizeof(t.g1));
+
+	if (regs->cs == __USER32_CS ||
+	    regs->cs & (1<<2)) {
+		if (address >> 32)	/* K8 erratum #100 */
+			return 0;
+		return sara_trampoline_emulator_x86_32(regs);
+	}
+
+	ret = copy_from_user(&t, ip, sizeof(t.lf));
+	if (ret)
+		ret = copy_from_user(&t, ip, sizeof(t.g1));
+	if (ret)
+		ret = copy_from_user(&t, ip, sizeof(t.g2));
+	if (ret)
+		return 0;
+
+	if (is_valid_libffi_trampoline_x86_64(t)) {
+		pr_debug("Trampoline: libffi x86_64.\n");
+		emulate_libffi_trampoline_x86_64(t, regs);
+		return 1;
+	} else if (is_valid_gcc_trampoline_x86_64_type1(t, regs)) {
+		pr_debug("Trampoline: gcc1 x86_64.\n");
+		emulate_gcc_trampoline_x86_64_type1(t, regs);
+		return 1;
+	} else if (is_valid_gcc_trampoline_x86_64_type2(t, regs)) {
+		pr_debug("Trampoline: gcc2 x86_64.\n");
+		emulate_gcc_trampoline_x86_64_type2(t, regs);
+		return 1;
+	}
+
+	pr_debug("Not a trampoline (x86_64).\n");
+
+	return 0;
+
+}
+
+#endif /* __TRAMPOLINES64_H */
diff --git a/security/sara/Kconfig b/security/sara/Kconfig
index 62dfe4f..b68c246 100644
--- a/security/sara/Kconfig
+++ b/security/sara/Kconfig
@@ -95,6 +95,24 @@ choice
 		  Documentation/admin-guide/LSM/SARA.rst.
 endchoice
 
+config SECURITY_SARA_WXPROT_EMUTRAMP
+	bool "Enable emulation for some types of trampolines"
+	depends on SECURITY_SARA_WXPROT
+	depends on ARCH_HAS_LSM_PAGEFAULT
+	depends on X86
+	default y
+	help
+	  Some programs and libraries need to execute special small code
+	  snippets from non-executable memory pages.
+	  Most notable examples are the GCC and libffi trampolines.
+	  This features make it possible to execute those trampolines even
+	  if they reside in non-executable memory pages.
+	  This features need to be enabled on a per-executable basis
+	  via user-space utilities.
+	  See Documentation/admin-guide/LSM/SARA.rst. for further information.
+
+	  If unsure, answer y.
+
 config SECURITY_SARA_WXPROT_DISABLED
 	bool "WX protection will be disabled at boot."
 	depends on SECURITY_SARA_WXPROT
diff --git a/security/sara/include/emutramp.h b/security/sara/include/emutramp.h
new file mode 100644
index 0000000..d5f893c
--- /dev/null
+++ b/security/sara/include/emutramp.h
@@ -0,0 +1,33 @@
+/*
+ * S.A.R.A. Linux Security Module
+ *
+ * Copyright (C) 2017 Salvatore Mesoraca <s.mesoraca16@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ *
+ * Assembly sequences used here were copied from
+ * PaX patch by PaX Team <pageexec@freemail.hu>
+ * Being just hexadecimal constants, they are not subject to
+ * any copyright.
+ *
+ */
+
+#ifndef __EMUTRAMP_H
+#define __EMUTRAMP_H
+
+#ifdef CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP
+int sara_trampoline_emulator(struct pt_regs *regs,
+			     unsigned long error_code,
+			     unsigned long address);
+#else
+inline int sara_trampoline_emulator(struct pt_regs *regs,
+				    unsigned long error_code,
+				    unsigned long address)
+{
+	return 0;
+}
+#endif /* CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP */
+
+#endif /* __EMUTRAMP_H */
diff --git a/security/sara/wxprot.c b/security/sara/wxprot.c
index 46600f0..68203f2 100644
--- a/security/sara/wxprot.c
+++ b/security/sara/wxprot.c
@@ -28,6 +28,7 @@
 #include "include/utils.h"
 #include "include/securityfs.h"
 #include "include/wxprot.h"
+#include "include/emutramp.h"
 
 #define SARA_WXPROT_CONFIG_VERSION 0
 
@@ -38,6 +39,7 @@
 #define SARA_WXP_COMPLAIN	0x0010
 #define SARA_WXP_VERBOSE	0x0020
 #define SARA_WXP_MMAP		0x0040
+#define SARA_WXP_EMUTRAMP	0x0100
 #define SARA_WXP_TRANSFER	0x0200
 #define SARA_WXP_NONE		0x0000
 #define SARA_WXP_MPROTECT	(SARA_WXP_HEAP	| \
@@ -48,7 +50,12 @@
 				SARA_WXP_WXORX		| \
 				SARA_WXP_COMPLAIN	| \
 				SARA_WXP_VERBOSE)
+#ifdef CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP
+#define SARA_WXP_ALL		(__SARA_WXP_ALL		| \
+				SARA_WXP_EMUTRAMP)
+#else /* CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP */
 #define SARA_WXP_ALL		__SARA_WXP_ALL
+#endif /* CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP */
 
 struct wxprot_rule {
 	char *path;
@@ -73,7 +80,11 @@ struct wxprot_config_container {
 static u16 default_flags __ro_after_init =
 				CONFIG_SECURITY_SARA_WXPROT_DEFAULT_FLAGS;
 
+#ifdef CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP
+static const bool wxprot_emutramp = true;
+#else
 static const bool wxprot_emutramp;
+#endif
 
 static void pr_wxp(char *msg)
 {
@@ -116,6 +127,9 @@ static bool are_flags_valid(u16 flags)
 	if (unlikely(flags & SARA_WXP_MMAP &&
 		     !(flags & SARA_WXP_OTHER)))
 		return false;
+	if (unlikely(flags & SARA_WXP_EMUTRAMP &&
+		     ((flags & SARA_WXP_MPROTECT) != SARA_WXP_MPROTECT)))
+		return false;
 	return true;
 }
 
@@ -461,10 +475,25 @@ static int sara_file_mprotect(struct vm_area_struct *vma,
 	return 0;
 }
 
+#ifdef CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP
+static int sara_pagefault_handler(struct pt_regs *regs,
+				  unsigned long error_code,
+				  unsigned long address)
+{
+	if (!sara_enabled || !wxprot_enabled ||
+	    !(get_current_sara_wxp_flags() & SARA_WXP_EMUTRAMP))
+		return 0;
+	return sara_trampoline_emulator(regs, error_code, address);
+}
+#endif
+
 static struct security_hook_list wxprot_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(bprm_set_creds, sara_bprm_set_creds),
 	LSM_HOOK_INIT(check_vmflags, sara_check_vmflags),
 	LSM_HOOK_INIT(file_mprotect, sara_file_mprotect),
+#ifdef CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP
+	LSM_HOOK_INIT(pagefault_handler, sara_pagefault_handler),
+#endif
 };
 
 struct binary_config_header {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
