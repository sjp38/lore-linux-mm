Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B44076B0253
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 15:59:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 76so11568777pfr.3
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 12:59:41 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id m123si1110313pgm.712.2017.10.20.12.59.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 12:59:40 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/4] x86/boot/compressed/64: Detect and handle 5-level paging at boot-time
Date: Fri, 20 Oct 2017 22:59:32 +0300
Message-Id: <20171020195934.32108-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171020195934.32108-1-kirill.shutemov@linux.intel.com>
References: <20171020195934.32108-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch prepare decompression code to boot-time switching between 4-
and 5-level paging.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S   | 16 ++++++++++++----
 arch/x86/boot/compressed/pagetable.c | 19 +++++++++++++++++++
 2 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index b4a5d284391c..6ac8239af2b6 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -288,10 +288,18 @@ ENTRY(startup_64)
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
+	call	need_to_enabled_l5
+	popq	%rsi
+
+	/* If need_to_enabled_l5() returned zero, we're done here. */
+	cmpq	$0, %rax
+	je	lvl5
 
 	/*
 	 * At this point we are in long mode with 4-level paging enabled,
diff --git a/arch/x86/boot/compressed/pagetable.c b/arch/x86/boot/compressed/pagetable.c
index f1aa43854bed..76d25a82e3ac 100644
--- a/arch/x86/boot/compressed/pagetable.c
+++ b/arch/x86/boot/compressed/pagetable.c
@@ -149,3 +149,22 @@ void finalize_identity_maps(void)
 {
 	write_cr3(top_level_pgt);
 }
+
+#ifdef CONFIG_X86_5LEVEL
+int need_to_enabled_l5(void)
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
+#endif
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
