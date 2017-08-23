Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A70866B04CE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:03:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s78so12691752pfg.4
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 05:03:56 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o10si371037pgf.334.2017.08.23.05.03.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 05:03:51 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 06/19] x86/boot/compressed/64: Detect and handle 5-level paging at boot-time
Date: Wed, 23 Aug 2017 15:03:19 +0300
Message-Id: <20170823120332.2288-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170823120332.2288-1-kirill.shutemov@linux.intel.com>
References: <20170823120332.2288-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch prepare decompression code to boot-time switching between 4-
and 5-level paging.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index fbf4c32d0b62..2e362aea3319 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -347,6 +347,28 @@ preferred_addr:
 	leaq	boot_stack_end(%rbx), %rsp
 
 #ifdef CONFIG_X86_5LEVEL
+	/* Preserve rbx across cpuid */
+	movq	%rbx, %r8
+
+	/* Check if leaf 7 is supported */
+	movl	$0, %eax
+	cpuid
+	cmpl	$7, %eax
+	jb	lvl5
+
+	/*
+	 * Check if la57 is supported.
+	 * The feature is enumerated with CPUID.(EAX=07H, ECX=0):ECX[bit 16]
+	 */
+	movl	$7, %eax
+	movl	$0, %ecx
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
@@ -386,6 +408,8 @@ preferred_addr:
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
