Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5886B0011
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:05:05 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u188so2341351pfb.6
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 10:05:05 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r9si5229294pfh.311.2018.02.26.10.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 10:05:04 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/5] x86/boot/compressed/64: Set up trampoline memory
Date: Mon, 26 Feb 2018 21:04:50 +0300
Message-Id: <20180226180451.86788-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
References: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch clears up trampoline memory and copies trampoline code in
place. It's not yet used though.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
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
index 57722a2fe2a0..91f75638f6e6 100644
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
 #ifndef __ASSEMBLER__
 
 extern unsigned long *trampoline_32bit;
 
+extern void trampoline_32bit_src(void *return_ptr);
+
 #endif /* __ASSEMBLER__ */
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
