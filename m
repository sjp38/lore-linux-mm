Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CBC396B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:12:55 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id 194so7619675wmv.9
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 08:12:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u4si8510255wmg.32.2017.12.18.08.12.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 08:12:53 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 037/178] x86/boot/compressed/64: Detect and handle 5-level paging at boot-time
Date: Mon, 18 Dec 2017 16:47:53 +0100
Message-Id: <20171218152922.093379611@linuxfoundation.org>
In-Reply-To: <20171218152920.567991776@linuxfoundation.org>
References: <20171218152920.567991776@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

commit 08529078d8d9adf689bf39cc38d53979a0869970 upstream.

Prerequisite for fixing the current problem of instantaneous reboots when a
5-level paging kernel is booted on 4-level paging hardware.

At the same time this change prepares the decompression code to boot-time
switching between 4- and 5-level paging.

[ tglx: Folded the GCC < 5 fix. ]

Fixes: 77ef56e4f0fb ("x86: Enable 5-level paging support via CONFIG_X86_5LEVEL=y")
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: linux-mm@kvack.org
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Borislav Petkov <bp@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Link: https://lkml.kernel.org/r/20171204124059.63515-2-kirill.shutemov@linux.intel.com
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/boot/compressed/Makefile     |    1 +
 arch/x86/boot/compressed/head_64.S    |   16 ++++++++++++----
 arch/x86/boot/compressed/pgtable_64.c |   28 ++++++++++++++++++++++++++++
 3 files changed, 41 insertions(+), 4 deletions(-)

--- a/arch/x86/boot/compressed/Makefile
+++ b/arch/x86/boot/compressed/Makefile
@@ -78,6 +78,7 @@ vmlinux-objs-$(CONFIG_EARLY_PRINTK) += $
 vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/kaslr.o
 ifdef CONFIG_X86_64
 	vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/pagetable.o
+	vmlinux-objs-y += $(obj)/pgtable_64.o
 endif
 
 $(obj)/eboot.o: KBUILD_CFLAGS += -fshort-wchar -mno-red-zone
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -289,10 +289,18 @@ ENTRY(startup_64)
 	leaq	boot_stack_end(%rbx), %rsp
 
 #ifdef CONFIG_X86_5LEVEL
-	/* Check if 5-level paging has already enabled */
-	movq	%cr4, %rax
-	testl	$X86_CR4_LA57, %eax
-	jnz	lvl5
+	/*
+	 * Check if we need to enable 5-level paging.
+	 * RSI holds real mode data and need to be preserved across
+	 * a function call.
+	 */
+	pushq	%rsi
+	call	l5_paging_required
+	popq	%rsi
+
+	/* If l5_paging_required() returned zero, we're done here. */
+	cmpq	$0, %rax
+	je	lvl5
 
 	/*
 	 * At this point we are in long mode with 4-level paging enabled,
--- /dev/null
+++ b/arch/x86/boot/compressed/pgtable_64.c
@@ -0,0 +1,28 @@
+#include <asm/processor.h>
+
+/*
+ * __force_order is used by special_insns.h asm code to force instruction
+ * serialization.
+ *
+ * It is not referenced from the code, but GCC < 5 with -fPIE would fail
+ * due to an undefined symbol. Define it to make these ancient GCCs work.
+ */
+unsigned long __force_order;
+
+int l5_paging_required(void)
+{
+	/* Check if leaf 7 is supported. */
+
+	if (native_cpuid_eax(0) < 7)
+		return 0;
+
+	/* Check if la57 is supported. */
+	if (!(native_cpuid_ecx(7) & (1 << (X86_FEATURE_LA57 & 31))))
+		return 0;
+
+	/* Check if 5-level paging has already been enabled. */
+	if (native_read_cr4() & X86_CR4_LA57)
+		return 0;
+
+	return 1;
+}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
