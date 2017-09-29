Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 28CCC6B0260
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 10:08:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a7so3187110pfj.3
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 07:08:33 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q11si3433813pgc.56.2017.09.29.07.08.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 07:08:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 6/6] x86/boot/compressed/64: Detect and handle 5-level paging at boot-time
Date: Fri, 29 Sep 2017 17:08:21 +0300
Message-Id: <20170929140821.37654-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
References: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch prepare decompression code to boot-time switching between 4-
and 5-level paging.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S | 26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index b4a5d284391c..cefe4958fda9 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -288,7 +288,29 @@ ENTRY(startup_64)
 	leaq	boot_stack_end(%rbx), %rsp
 
 #ifdef CONFIG_X86_5LEVEL
-	/* Check if 5-level paging has already enabled */
+	/* Preserve RBX across CPUID */
+	movq	%rbx, %r8
+
+	/* Check if leaf 7 is supported */
+	xorl	%eax, %eax
+	cpuid
+	cmpl	$7, %eax
+	jb	lvl5
+
+	/*
+	 * Check if LA57 is supported.
+	 * The feature is enumerated with CPUID.(EAX=07H, ECX=0):ECX[bit 16]
+	 */
+	movl	$7, %eax
+	xorl	%ecx, %ecx
+	cpuid
+	andl	$(1 << 16), %ecx
+	jz	lvl5
+
+	/* Restore RBX */
+	movq	%r8, %rbx
+
+	/* Check if 5-level paging has already been enabled */
 	movq	%cr4, %rax
 	testl	$X86_CR4_LA57, %eax
 	jnz	lvl5
@@ -327,6 +349,8 @@ ENTRY(startup_64)
 	pushq	%rax
 	lretq
 lvl5:
+	/* Restore RBX */
+	movq	%r8, %rbx
 #endif
 
 	/* Zero EFLAGS */
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
