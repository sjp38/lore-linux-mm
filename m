Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5D726B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 08:01:12 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 17so1363195wrm.10
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 05:01:12 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r141si16965906wmb.155.2018.02.21.05.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 05:01:11 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 037/167] x86/kexec: Make kexec (mostly) work in 5-level paging mode
Date: Wed, 21 Feb 2018 13:47:28 +0100
Message-Id: <20180221124526.630792321@linuxfoundation.org>
In-Reply-To: <20180221124524.639039577@linuxfoundation.org>
References: <20180221124524.639039577@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Baoquan He <bhe@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Borislav Petkov <bp@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

commit 5bf30316991d5bcda046343ee77d823cf16fdd03 upstream.

Currently kexec() will crash when switching into a 5-level paging
enabled kernel.

I missed that we need to change relocate_kernel() to set CR4.LA57
flag if the kernel has 5-level paging enabled.

I avoided using #ifdef CONFIG_X86_5LEVEL here and inferred if we need to
enable 5-level paging from previous CR4 value. This way the code is
ready for boot-time switching between paging modes.

With this patch applied, in addition to kexec 4-to-4 which always worked,
we can kexec 4-to-5 and 5-to-5 - while 5-to-4 will need more work.

Reported-by: Baoquan He <bhe@redhat.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Baoquan He <bhe@redhat.com>
Cc: <stable@vger.kernel.org> # v4.14+
Cc: Borislav Petkov <bp@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Fixes: 77ef56e4f0fb ("x86: Enable 5-level paging support via CONFIG_X86_5LEVEL=y")
Link: http://lkml.kernel.org/r/20180129110845.26633-1-kirill.shutemov@linux.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/kernel/relocate_kernel_64.S |    8 ++++++++
 1 file changed, 8 insertions(+)

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
