Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA956B0314
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 12:44:41 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b15so3801515wrb.1
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 09:44:41 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id t8si582577wrc.143.2017.06.15.09.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 09:44:40 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id d17so792389wme.3
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 09:44:39 -0700 (PDT)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v2 7/9] Trampoline emulation
Date: Thu, 15 Jun 2017 18:42:54 +0200
Message-Id: <1497544976-7856-8-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com>
References: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Casey Schaufler <casey@schaufler-ca.com>, Kees Cook <keescook@chromium.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org, x86@kernel.org, Jann Horn <jannh@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

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
The assembly sequences used here were originally obtained from PaX source
code.

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 security/sara/Kconfig               |  17 ++++
 security/sara/include/trampolines.h | 171 ++++++++++++++++++++++++++++++++++++
 security/sara/wxprot.c              | 140 +++++++++++++++++++++++++++++
 3 files changed, 328 insertions(+)
 create mode 100644 security/sara/include/trampolines.h

diff --git a/security/sara/Kconfig b/security/sara/Kconfig
index 6c74069..f406805 100644
--- a/security/sara/Kconfig
+++ b/security/sara/Kconfig
@@ -96,6 +96,23 @@ choice
 		  Documentation/security/SARA.rst.
 endchoice
 
+config SECURITY_SARA_WXPROT_EMUTRAMP
+	bool "Enable emulation for some types of trampolines"
+	depends on SECURITY_SARA_WXPROT
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
+	  See Documentation/security/SARA.rst. for further information.
+
+	  If unsure, answer y.
+
 config SECURITY_SARA_WXPROT_DISABLED
 	bool "WX protection will be disabled at boot."
 	depends on SECURITY_SARA_WXPROT
diff --git a/security/sara/include/trampolines.h b/security/sara/include/trampolines.h
new file mode 100644
index 0000000..eab0a85
--- /dev/null
+++ b/security/sara/include/trampolines.h
@@ -0,0 +1,171 @@
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
+ *
+ */
+
+#ifndef __SARA_TRAMPOLINES_H
+#define __SARA_TRAMPOLINES_H
+#ifdef CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP
+
+
+/* x86_32 */
+
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
+
+
+#ifdef CONFIG_X86_64
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
+#endif /* CONFIG_X86_64 */
+
+#endif /* CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP */
+#endif /* __SARA_TRAMPOLINES_H */
diff --git a/security/sara/wxprot.c b/security/sara/wxprot.c
index f9233a5..38c86be 100644
--- a/security/sara/wxprot.c
+++ b/security/sara/wxprot.c
@@ -22,6 +22,11 @@
 #include <linux/ratelimit.h>
 #include <linux/spinlock.h>
 
+#ifdef CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP
+#include <linux/uaccess.h>
+#include "include/trampolines.h"
+#endif
+
 #include "include/sara.h"
 #include "include/sara_data.h"
 #include "include/utils.h"
@@ -37,6 +42,7 @@
 #define SARA_WXP_COMPLAIN	0x0010
 #define SARA_WXP_VERBOSE	0x0020
 #define SARA_WXP_MMAP		0x0040
+#define SARA_WXP_EMUTRAMP	0x0100
 #define SARA_WXP_TRANSFER	0x0200
 #define SARA_WXP_NONE		0x0000
 #define SARA_WXP_MPROTECT	(SARA_WXP_HEAP	| \
@@ -47,7 +53,12 @@
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
@@ -72,7 +83,11 @@ struct wxprot_config_container {
 static u16 default_flags __ro_after_init =
 				CONFIG_SECURITY_SARA_WXPROT_DEFAULT_FLAGS;
 
+#ifdef CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP
+static const bool wxprot_emutramp = true;
+#else
 static const bool wxprot_emutramp;
+#endif
 
 static void pr_wxp(char *msg)
 {
@@ -97,6 +112,9 @@ static bool are_flags_valid(u16 flags)
 				SARA_WXP_WXORX |
 				SARA_WXP_MMAP))))
 		return false;
+	if (unlikely(flags & SARA_WXP_EMUTRAMP &&
+		     ((flags & SARA_WXP_MPROTECT) != SARA_WXP_MPROTECT)))
+		return false;
 	return true;
 }
 
@@ -366,10 +384,132 @@ static int sara_file_mprotect(struct vm_area_struct *vma,
 	return 0;
 }
 
+#ifdef CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP
+#define PF_PROT		(1 << 0)
+#define PF_USER		(1 << 2)
+#define PF_INSTR	(1 << 4)
+static int sara_pagefault_handler_x86_32(struct pt_regs *regs);
+static int sara_pagefault_handler_x86_64(struct pt_regs *regs);
+static int sara_pagefault_handler_x86(struct pt_regs *regs,
+					unsigned long error_code,
+					unsigned long address)
+{
+	int ret = 0;
+
+	if (!sara_enabled || !wxprot_enabled ||
+	    !(error_code & PF_USER) ||
+	    !(error_code & PF_INSTR) ||
+	    !(error_code & PF_PROT) ||
+	    !(get_current_sara_wxp_flags() & SARA_WXP_EMUTRAMP))
+		return 0;
+
+	local_irq_enable();
+	might_sleep();
+	might_fault();
+
+#ifdef	CONFIG_X86_32
+	ret = sara_pagefault_handler_x86_32(regs);
+#else
+	if (regs->cs == __USER32_CS ||
+	    regs->cs & (1<<2)) {
+		if (!(address >> 32))	/* K8 erratum #100 */
+			ret = sara_pagefault_handler_x86_32(regs);
+	} else
+		ret = sara_pagefault_handler_x86_64(regs);
+#endif
+
+	return ret;
+}
+
+static int sara_pagefault_handler_x86_32(struct pt_regs *regs)
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
+#ifdef CONFIG_X86_64
+static int sara_pagefault_handler_x86_64(struct pt_regs *regs)
+{
+	int ret;
+	void __user *ip = (void __user *) regs->ip;
+	union trampolines_x86_64 t;
+
+	BUILD_BUG_ON(sizeof(t.g1) > sizeof(t.lf));
+	BUILD_BUG_ON(sizeof(t.g2) > sizeof(t.g1));
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
+#else /* CONFIG_X86_64 */
+static inline int sara_pagefault_handler_x86_64(struct pt_regs *regs)
+{
+	return 0;
+}
+#endif /* CONFIG_X86_64 */
+
+#endif /* CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP */
+
 static struct security_hook_list wxprot_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(bprm_set_creds, sara_bprm_set_creds),
 	LSM_HOOK_INIT(check_vmflags, sara_check_vmflags),
 	LSM_HOOK_INIT(file_mprotect, sara_file_mprotect),
+#ifdef CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP
+	LSM_HOOK_INIT(pagefault_handler_x86, sara_pagefault_handler_x86),
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
