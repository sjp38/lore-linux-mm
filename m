Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D08D16B0287
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 07:41:37 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n6so13009511pfg.19
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 04:41:37 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d9si1301848plj.822.2017.12.04.04.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 04:41:36 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 1/5] x86/boot/compressed/64: Detect and handle 5-level paging at boot-time
Date: Mon,  4 Dec 2017 15:40:55 +0300
Message-Id: <20171204124059.63515-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171204124059.63515-1-kirill.shutemov@linux.intel.com>
References: <20171204124059.63515-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org

This patch prepare decompression code to boot-time switching between 4-
and 5-level paging.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: <stable@vger.kernel.org>	[4.14+]
---
 arch/x86/boot/compressed/Makefile     |  1 +
 arch/x86/boot/compressed/head_64.S    | 16 ++++++++++++----
 arch/x86/boot/compressed/pgtable_64.c | 18 ++++++++++++++++++
 3 files changed, 31 insertions(+), 4 deletions(-)
 create mode 100644 arch/x86/boot/compressed/pgtable_64.c

diff --git a/arch/x86/boot/compressed/Makefile b/arch/x86/boot/compressed/Makefile
index 1e9c322e973a..f25e1530e064 100644
--- a/arch/x86/boot/compressed/Makefile
+++ b/arch/x86/boot/compressed/Makefile
@@ -80,6 +80,7 @@ vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/kaslr.o
 ifdef CONFIG_X86_64
 	vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/pagetable.o
 	vmlinux-objs-y += $(obj)/mem_encrypt.o
+	vmlinux-objs-y += $(obj)/pgtable_64.o
 endif
 
 $(obj)/eboot.o: KBUILD_CFLAGS += -fshort-wchar -mno-red-zone
diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index 20919b4f3133..fc313e29fe2c 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -305,10 +305,18 @@ ENTRY(startup_64)
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
diff --git a/arch/x86/boot/compressed/pgtable_64.c b/arch/x86/boot/compressed/pgtable_64.c
new file mode 100644
index 000000000000..eed3a2c3b577
--- /dev/null
+++ b/arch/x86/boot/compressed/pgtable_64.c
@@ -0,0 +1,18 @@
+#include <asm/processor.h>
+
+int l5_paging_required(void)
+{
+	/* Check i leaf 7 is supported. */
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
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
