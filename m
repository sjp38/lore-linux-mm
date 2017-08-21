Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 62046280405
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 11:30:30 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y129so288878788pgy.1
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 08:30:30 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d127si3724566pga.4.2017.08.21.08.30.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 08:30:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 06/19] x86/boot/compressed/64: Detect and handle 5-level paging at boot-time
Date: Mon, 21 Aug 2017 18:29:03 +0300
Message-Id: <20170821152916.40124-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
References: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dmitry Safonov <dsafonov@virtuozzo.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
