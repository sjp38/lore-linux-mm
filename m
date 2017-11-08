Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84ADF6B030C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:47:55 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z184so3556629pgd.0
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:47:55 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id x11si4453547plv.4.2017.11.08.11.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 11:47:54 -0800 (PST)
Subject: [PATCH 30/30] x86, kaiser, xen: Dynamically disable KAISER when running under Xen PV
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 08 Nov 2017 11:47:42 -0800
References: <20171108194646.907A1942@viggo.jf.intel.com>
In-Reply-To: <20171108194646.907A1942@viggo.jf.intel.com>
Message-Id: <20171108194742.8CD79E09@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org, jgross@suse.com


From: Dave Hansen <dave.hansen@linux.intel.com>

If you paravirtualize the MMU, you can not use KAISER.  This boils down
to the fact that KAISER needs to do CR3 writes in places that it is not
feasible to do real hypercalls.

If we detect that Xen PV is in use, do not do the KAISER CR3 switches.

I don't think this too bug of a deal for Xen.  I was under the
impression that the Xen guest kernel and Xen guest userspace didn't
share an address space *anyway* so Xen PV is not normally even exposed
to the kinds of things that KAISER protects against.

This allows KAISER=y kernels to deployed in environments that also
require PARAVIRT=y.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
Cc: Juergen Gross <jgross@suse.com>
---

 b/arch/x86/mm/kaiser.c |   24 ++++++++++++++++++++++--
 b/security/Kconfig     |    2 +-
 2 files changed, 23 insertions(+), 3 deletions(-)

diff -puN arch/x86/mm/kaiser.c~kaiser-disable-for-xen-pv arch/x86/mm/kaiser.c
--- a/arch/x86/mm/kaiser.c~kaiser-disable-for-xen-pv	2017-11-08 10:46:16.913681276 -0800
+++ b/arch/x86/mm/kaiser.c	2017-11-08 10:46:16.918681276 -0800
@@ -31,8 +31,20 @@
 #include <asm/tlbflush.h>
 #include <asm/desc.h>
 
+/*
+ * We need a two-stage enable/disable.  One (kaiser_enabled) to stop
+ * the ongoing work that keeps KAISER from being disabled (like PGD
+ * poisoning) and another (kaiser_asm_do_switch) that we set when it
+ * is completely safe to run without doing KAISER switches.
+ */
+int kaiser_enabled;
+
+/*
+ * Sized and aligned so that we can easily map it out to userspace
+ * for use before we have done the assembly CR3 switching.
+ */
 __aligned(PAGE_SIZE)
-unsigned long kaiser_asm_do_switch[PAGE_SIZE/sizeof(unsigned long)] = { 1 };
+unsigned long kaiser_asm_do_switch[PAGE_SIZE/sizeof(unsigned long)];
 
 /*
  * At runtime, the only things we map are some things for CPU
@@ -404,6 +416,15 @@ void __init kaiser_init(void)
 	kaiser_add_user_map_ptrs_early(__irqentry_text_start,
 				       __irqentry_text_end,
 				       __PAGE_KERNEL_RX | _PAGE_GLOBAL);
+
+	if (cpu_feature_enabled(X86_FEATURE_XENPV)) {
+		pr_info("x86/kaiser: Xen PV detected, disabling "
+			"KAISER protection\n");
+	} else {
+		pr_info("x86/kaiser: Unmapping kernel while in userspace\n");
+		kaiser_asm_do_switch[0] = 1;
+		kaiser_enabled = 1;
+	}
 }
 
 int kaiser_add_mapping(unsigned long addr, unsigned long size,
@@ -454,7 +475,6 @@ void kaiser_remove_mapping(unsigned long
 	__native_flush_tlb_global();
 }
 
-int kaiser_enabled = 1;
 static ssize_t kaiser_enabled_read_file(struct file *file, char __user *user_buf,
 			     size_t count, loff_t *ppos)
 {
diff -puN security/Kconfig~kaiser-disable-for-xen-pv security/Kconfig
--- a/security/Kconfig~kaiser-disable-for-xen-pv	2017-11-08 10:46:16.914681276 -0800
+++ b/security/Kconfig	2017-11-08 10:46:16.918681276 -0800
@@ -56,7 +56,7 @@ config SECURITY_NETWORK
 
 config KAISER
 	bool "Remove the kernel mapping in user mode"
-	depends on X86_64 && SMP && !PARAVIRT
+	depends on X86_64 && SMP
 	help
 	  This feature reduces the number of hardware side channels by
 	  ensuring that the majority of kernel addresses are not mapped
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
