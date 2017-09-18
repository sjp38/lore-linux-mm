Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 45B746B0261
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 06:56:16 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 188so163085pgb.3
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 03:56:16 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f6si4655269plf.94.2017.09.18.03.56.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Sep 2017 03:56:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 06/19] x86/boot/compressed/64: Detect and handle 5-level paging at boot-time
Date: Mon, 18 Sep 2017 13:55:40 +0300
Message-Id: <20170918105553.27914-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch prepare decompression code to boot-time switching between 4-
and 5-level paging.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index b4a5d284391c..09c85e8558eb 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -288,6 +288,28 @@ ENTRY(startup_64)
 	leaq	boot_stack_end(%rbx), %rsp
 
 #ifdef CONFIG_X86_5LEVEL
+	/* Preserve rbx across cpuid */
+	movq	%rbx, %r8
+
+	/* Check if leaf 7 is supported */
+	xorl	%eax, %eax
+	cpuid
+	cmpl	$7, %eax
+	jb	lvl5
+
+	/*
+	 * Check if la57 is supported.
+	 * The feature is enumerated with CPUID.(EAX=07H, ECX=0):ECX[bit 16]
+	 */
+	movl	$7, %eax
+	xorl	%ecx, %ecx
+	cpuid
+	andl	$(1 << 16), %ecx
+	jz	lvl5
+
+	/* Restore rbx */
+	movq	%r8, %rbx
+
 	/* Check if 5-level paging has already enabled */
 	movq	%cr4, %rax
 	testl	$X86_CR4_LA57, %eax
@@ -327,6 +349,8 @@ ENTRY(startup_64)
 	pushq	%rax
 	lretq
 lvl5:
+	/* Restore rbx */
+	movq	%r8, %rbx
 #endif
 
 	/* Zero EFLAGS */
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
