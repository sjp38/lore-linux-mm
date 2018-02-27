Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 40F3C6B000A
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 10:42:30 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id x6so9448326plr.7
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 07:42:30 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id h19si4271872pgn.310.2018.02.27.07.42.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 07:42:28 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 4/5] x86/boot/compressed/64: Set up trampoline memory
Date: Tue, 27 Feb 2018 18:42:16 +0300
Message-Id: <20180227154217.69347-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180227154217.69347-1-kirill.shutemov@linux.intel.com>
References: <20180227154217.69347-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch clears up trampoline memory and copies trampoline code in
place. It's not yet used though.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Borislav Petkov <bp@suse.de>
---
 arch/x86/boot/compressed/head_64.S    | 3 ++-
 arch/x86/boot/compressed/pgtable.h    | 9 +++++++++
 arch/x86/boot/compressed/pgtable_64.c | 7 +++++++
 3 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index 8ba0582c65d5..c813cb004056 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -501,8 +501,9 @@ relocated:
 	jmp	*%rax
 
 	.code32
+ENTRY(trampoline_32bit_src)
 compatible_mode:
-	/* Setup data and stack segments */
+	/* Set up data and stack segments */
 	movl	$__KERNEL_DS, %eax
 	movl	%eax, %ds
 	movl	%eax, %ss
diff --git a/arch/x86/boot/compressed/pgtable.h b/arch/x86/boot/compressed/pgtable.h
index 1895f345eb73..cfcb8beeac8f 100644
--- a/arch/x86/boot/compressed/pgtable.h
+++ b/arch/x86/boot/compressed/pgtable.h
@@ -3,9 +3,18 @@
 
 #define TRAMPOLINE_32BIT_SIZE		(2 * PAGE_SIZE)
 
+#define TRAMPOLINE_32BIT_PGTABLE_OFFSET	0
+
+#define TRAMPOLINE_32BIT_CODE_OFFSET	PAGE_SIZE
+#define TRAMPOLINE_32BIT_CODE_SIZE	0x60
+
+#define TRAMPOLINE_32BIT_STACK_END	TRAMPOLINE_32BIT_SIZE
+
 #ifndef __ASSEMBLY__
 
 extern unsigned long *trampoline_32bit;
 
+extern void trampoline_32bit_src(void *return_ptr);
+
 #endif /* __ASSEMBLY__ */
 #endif /* BOOT_COMPRESSED_PAGETABLE_H */
diff --git a/arch/x86/boot/compressed/pgtable_64.c b/arch/x86/boot/compressed/pgtable_64.c
index 01d08d3e3e43..810c2c32d98e 100644
--- a/arch/x86/boot/compressed/pgtable_64.c
+++ b/arch/x86/boot/compressed/pgtable_64.c
@@ -76,6 +76,13 @@ struct paging_config paging_prepare(void)
 	/* Preserve trampoline memory */
 	memcpy(trampoline_save, trampoline_32bit, TRAMPOLINE_32BIT_SIZE);
 
+	/* Clear trampoline memory first */
+	memset(trampoline_32bit, 0, TRAMPOLINE_32BIT_SIZE);
+
+	/* Copy trampoline code in place */
+	memcpy(trampoline_32bit + TRAMPOLINE_32BIT_CODE_OFFSET / sizeof(unsigned long),
+			&trampoline_32bit_src, TRAMPOLINE_32BIT_CODE_SIZE);
+
 	return paging_config;
 }
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
