Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40E9D6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 08:52:51 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 205so10832064pfw.4
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 05:52:51 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id h15-v6si2093628plk.480.2018.01.30.05.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 05:52:50 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 5/4] x86/boot/compressed/64: Support switching from 5- to 4-level paging
Date: Tue, 30 Jan 2018 16:52:36 +0300
Message-Id: <20180130135239.72244-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180130135239.72244-1-kirill.shutemov@linux.intel.com>
References: <20180130135239.72244-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If a bootloader enabled 5-level paging before handing off control to
kernel, we may want to switch it to 4-level paging when kernel is
compiled with CONFIG_X86_5LEVEL=n.

Let's modify decompression code to handle the situation.

This will fail if the kernel image is loaded above 64TiB since 4-level
paging would not be able to access the image.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S | 17 +++++++++++++++--
 arch/x86/boot/compressed/pgtable.h |  2 +-
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index f5ac9a6515ef..5942b7d9d6a2 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -520,19 +520,32 @@ ENTRY(trampoline_32bit_src)
 	btrl	$X86_CR0_PG_BIT, %eax
 	movl	%eax, %cr0
 
-	/* For 5-level paging, point CR3 to the trampoline's new top level page table */
+	/* Check what paging mode we want to be in after the trampoline */
 	cmpl	$0, %edx
 	jz	1f
 
 	/* Don't touch CR3 if it already points to 5-level page tables */
 	movl	%cr4, %eax
 	testl	$X86_CR4_LA57, %eax
-	jnz	1f
+	jnz	2f
 
+	/* For 5-level paging, point CR3 to the trampoline's new top level page table */
 	leal	TRAMPOLINE_32BIT_PGTABLE_OFFSET(%ecx), %eax
 	movl	%eax, %cr3
 1:
+	/* Don't touch CR3 if it already points to 4-level page tables */
+	movl	%cr4, %eax
+	testl	$X86_CR4_LA57, %eax
+	jz	2f
 
+	/*
+	 * We are in 5-level paging mode, but we want to switch to 4-level.
+	 * Let's take the first entry in the top-level page table as our new CR3.
+	 */
+	movl	%cr3, %eax
+	movl	(%eax), %eax
+	movl	%eax, %cr3
+2:
 	/* Enable PAE and LA57 (if required) paging modes */
 	movl	%cr4, %eax
 	orl	$X86_CR4_PAE, %eax
diff --git a/arch/x86/boot/compressed/pgtable.h b/arch/x86/boot/compressed/pgtable.h
index 6e0db2260147..cd62c546afd5 100644
--- a/arch/x86/boot/compressed/pgtable.h
+++ b/arch/x86/boot/compressed/pgtable.h
@@ -6,7 +6,7 @@
 #define TRAMPOLINE_32BIT_PGTABLE_OFFSET	0
 
 #define TRAMPOLINE_32BIT_CODE_OFFSET	PAGE_SIZE
-#define TRAMPOLINE_32BIT_CODE_SIZE	0x60
+#define TRAMPOLINE_32BIT_CODE_SIZE	0x70
 
 #define TRAMPOLINE_32BIT_STACK_END	TRAMPOLINE_32BIT_SIZE
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
