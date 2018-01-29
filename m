Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DE346B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 06:09:01 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f74so6547276pfa.13
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 03:09:01 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 77si3070034pfs.2.2018.01.29.03.08.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 03:08:59 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] x86/kexec: Make kexec work in 5-level paging mode
Date: Mon, 29 Jan 2018 14:08:45 +0300
Message-Id: <20180129110845.26633-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

I've missed that we need to change relocate_kernel() to set CR4.LA57
flag if the kernel has 5-level paging enabled.

I avoided to use ifdef CONFIG_X86_5LEVEL here and inferred if we need to
enabled 5-level paging from previous CR4 value. This way the code is
ready for boot-time switching between paging modes.

Fixes: 77ef56e4f0fb ("x86: Enable 5-level paging support via CONFIG_X86_5LEVEL=y")
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Baoquan He <bhe@redhat.com>
---
 arch/x86/kernel/relocate_kernel_64.S | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/x86/kernel/relocate_kernel_64.S b/arch/x86/kernel/relocate_kernel_64.S
index 307d3bac5f04..11eda21eb697 100644
--- a/arch/x86/kernel/relocate_kernel_64.S
+++ b/arch/x86/kernel/relocate_kernel_64.S
@@ -68,6 +68,9 @@ relocate_kernel:
 	movq	%cr4, %rax
 	movq	%rax, CR4(%r11)
 
+	/* Save CR4. Required to enable the right paging mode later. */
+	movq	%rax, %r13
+
 	/* zero out flags, and disable interrupts */
 	pushq $0
 	popfq
@@ -126,8 +129,13 @@ identity_mapped:
 	/*
 	 * Set cr4 to a known state:
 	 *  - physical address extension enabled
+	 *  - 5-level paging, if it was enabled before
 	 */
 	movl	$X86_CR4_PAE, %eax
+	testq	$X86_CR4_LA57, %r13
+	jz	1f
+	orl	$X86_CR4_LA57, %eax
+1:
 	movq	%rax, %cr4
 
 	jmp 1f
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
