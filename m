Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A12D36B025E
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 15:44:11 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 11so16651376wrb.18
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:44:11 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id i6si20340172wrh.313.2017.11.27.12.44.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 12:44:10 -0800 (PST)
Message-Id: <20171127204257.575052752@linutronix.de>
Date: Mon, 27 Nov 2017 21:34:18 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 2/4] x86/kaiser: Enable PARAVIRT again
References: <20171127203416.236563829@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-kaiser-xen--Runtime-disable-kaiser-on-XEN_PV-guests.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

XEN_PV paravirtualizes read/write_c3. This does not work with KAISER as the
CR3 switch from and to user space PGD would require to map the whole XEN_PV
machinery into both. It's also not clear whether the register space is
sufficient to do so. All other PV guests use the native implementations and
are compatible with KAISER.

Add detection for XEN_PV and disable KAISER in the early boot process when
the kernel is running as a XEN_PV guest.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/asm/hypervisor.h |   25 +++++++++++++++----------
 arch/x86/mm/kaiser.c              |    3 +++
 security/Kconfig                  |    2 +-
 3 files changed, 19 insertions(+), 11 deletions(-)

--- a/arch/x86/include/asm/hypervisor.h
+++ b/arch/x86/include/asm/hypervisor.h
@@ -20,16 +20,7 @@
 #ifndef _ASM_X86_HYPERVISOR_H
 #define _ASM_X86_HYPERVISOR_H
 
-#ifdef CONFIG_HYPERVISOR_GUEST
-
-#include <asm/kvm_para.h>
-#include <asm/x86_init.h>
-#include <asm/xen/hypervisor.h>
-
-/*
- * x86 hypervisor information
- */
-
+/* x86 hypervisor types  */
 enum x86_hypervisor_type {
 	X86_HYPER_NATIVE = 0,
 	X86_HYPER_VMWARE,
@@ -39,6 +30,12 @@ enum x86_hypervisor_type {
 	X86_HYPER_KVM,
 };
 
+#ifdef CONFIG_HYPERVISOR_GUEST
+
+#include <asm/kvm_para.h>
+#include <asm/x86_init.h>
+#include <asm/xen/hypervisor.h>
+
 struct hypervisor_x86 {
 	/* Hypervisor name */
 	const char	*name;
@@ -58,7 +55,15 @@ struct hypervisor_x86 {
 
 extern enum x86_hypervisor_type x86_hyper_type;
 extern void init_hypervisor_platform(void);
+static inline bool hypervisor_is_type(enum x86_hypervisor_type type)
+{
+	return x86_hyper_type == type;
+}
 #else
 static inline void init_hypervisor_platform(void) { }
+static inline bool hypervisor_is_type(enum x86_hypervisor_type type)
+{
+	return type == X86_HYPER_NATIVE;
+}
 #endif /* CONFIG_HYPERVISOR_GUEST */
 #endif /* _ASM_X86_HYPERVISOR_H */
--- a/arch/x86/mm/kaiser.c
+++ b/arch/x86/mm/kaiser.c
@@ -34,6 +34,7 @@
 #include <linux/mm.h>
 #include <linux/uaccess.h>
 
+#include <asm/hypervisor.h>
 #include <asm/cmdline.h>
 #include <asm/kaiser.h>
 #include <asm/pgtable.h>
@@ -53,6 +54,8 @@ void __init kaiser_check_cmdline(void)
 {
 	if (cmdline_find_option_bool(boot_command_line, "nokaiser"))
 		kaiser_enabled = false;
+	if (hypervisor_is_type(X86_HYPER_XEN_PV))
+		kaiser_enabled = false;
 }
 
 /*
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -56,7 +56,7 @@ config SECURITY_NETWORK
 
 config KAISER
 	bool "Remove the kernel mapping in user mode"
-	depends on X86_64 && SMP && !PARAVIRT && JUMP_LABEL
+	depends on X86_64 && SMP && JUMP_LABEL
 	help
 	  This feature reduces the number of hardware side channels by
 	  ensuring that the majority of kernel addresses are not mapped


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
