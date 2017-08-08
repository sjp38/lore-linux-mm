Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E784C6B03B4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:54:44 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id l2so34117386pgu.2
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:54:44 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id t15si824284pfj.572.2017.08.08.05.54.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 05:54:43 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 06/14] x86/boot/compressed/64: Detect and handle 5-level paging at boot-time
Date: Tue,  8 Aug 2017 15:54:07 +0300
Message-Id: <20170808125415.78842-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
