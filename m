Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6A96B0267
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 19:35:51 -0500 (EST)
Received: by mail-pa0-f71.google.com with SMTP id rf5so83853791pab.3
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:35:51 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0056.outbound.protection.outlook.com. [104.47.40.56])
        by mx.google.com with ESMTPS id tb1si1540588pab.242.2016.11.09.16.35.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 16:35:50 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v3 06/20] x86: Add support to enable SME during early
 boot processing
Date: Wed, 9 Nov 2016 18:35:43 -0600
Message-ID: <20161110003543.3280.99623.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo
 Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas
 Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

This patch adds support to the early boot code to use Secure Memory
Encryption (SME).  Support is added to update the early pagetables with
the memory encryption mask and to encrypt the kernel in place.

The routines to set the encryption mask and perform the encryption are
stub routines for now with full function to be added in a later patch.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/Makefile           |    2 ++
 arch/x86/kernel/head_64.S          |   35 ++++++++++++++++++++++++++++++++++-
 arch/x86/kernel/mem_encrypt_init.c |   29 +++++++++++++++++++++++++++++
 3 files changed, 65 insertions(+), 1 deletion(-)
 create mode 100644 arch/x86/kernel/mem_encrypt_init.c

diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 45257cf..27e22f4 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -141,4 +141,6 @@ ifeq ($(CONFIG_X86_64),y)
 
 	obj-$(CONFIG_PCI_MMCONFIG)	+= mmconf-fam10h_64.o
 	obj-y				+= vsmp_64.o
+
+	obj-y				+= mem_encrypt_init.o
 endif
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index c98a559..9a28aad 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -95,6 +95,17 @@ startup_64:
 	jnz	bad_address
 
 	/*
+	 * Enable Secure Memory Encryption (if available).  Save the mask
+	 * in %r12 for later use and add the memory encryption mask to %rbp
+	 * to include it in the page table fixups.
+	 */
+	push	%rsi
+	call	sme_enable
+	pop	%rsi
+	movq	%rax, %r12
+	addq	%r12, %rbp
+
+	/*
 	 * Fixup the physical addresses in the page table
 	 */
 	addq	%rbp, early_level4_pgt + (L4_START_KERNEL*8)(%rip)
@@ -117,6 +128,7 @@ startup_64:
 	shrq	$PGDIR_SHIFT, %rax
 
 	leaq	(4096 + _KERNPG_TABLE)(%rbx), %rdx
+	addq	%r12, %rdx
 	movq	%rdx, 0(%rbx,%rax,8)
 	movq	%rdx, 8(%rbx,%rax,8)
 
@@ -133,6 +145,7 @@ startup_64:
 	movq	%rdi, %rax
 	shrq	$PMD_SHIFT, %rdi
 	addq	$(__PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL), %rax
+	addq	%r12, %rax
 	leaq	(_end - 1)(%rip), %rcx
 	shrq	$PMD_SHIFT, %rcx
 	subq	%rdi, %rcx
@@ -163,9 +176,21 @@ startup_64:
 	cmp	%r8, %rdi
 	jne	1b
 
-	/* Fixup phys_base */
+	/*
+	 * Fixup phys_base, remove the memory encryption mask from %rbp
+	 * to obtain the true physical address.
+	 */
+	subq	%r12, %rbp
 	addq	%rbp, phys_base(%rip)
 
+	/*
+	 * The page tables have been updated with the memory encryption mask,
+	 * so encrypt the kernel if memory encryption is active
+	 */
+	push	%rsi
+	call	sme_encrypt_kernel
+	pop	%rsi
+
 	movq	$(early_level4_pgt - __START_KERNEL_map), %rax
 	jmp 1f
 ENTRY(secondary_startup_64)
@@ -186,9 +211,17 @@ ENTRY(secondary_startup_64)
 	/* Sanitize CPU configuration */
 	call verify_cpu
 
+	push	%rsi
+	call	sme_get_me_mask
+	pop	%rsi
+	movq	%rax, %r12
+
 	movq	$(init_level4_pgt - __START_KERNEL_map), %rax
 1:
 
+	/* Add the memory encryption mask to RAX */
+	addq	%r12, %rax
+
 	/* Enable PAE mode and PGE */
 	movl	$(X86_CR4_PAE | X86_CR4_PGE), %ecx
 	movq	%rcx, %cr4
diff --git a/arch/x86/kernel/mem_encrypt_init.c b/arch/x86/kernel/mem_encrypt_init.c
new file mode 100644
index 0000000..388d6fb
--- /dev/null
+++ b/arch/x86/kernel/mem_encrypt_init.c
@@ -0,0 +1,29 @@
+/*
+ * AMD Memory Encryption Support
+ *
+ * Copyright (C) 2016 Advanced Micro Devices, Inc.
+ *
+ * Author: Tom Lendacky <thomas.lendacky@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/linkage.h>
+#include <linux/init.h>
+#include <linux/mem_encrypt.h>
+
+void __init sme_encrypt_kernel(void)
+{
+}
+
+unsigned long __init sme_get_me_mask(void)
+{
+	return sme_me_mask;
+}
+
+unsigned long __init sme_enable(void)
+{
+	return sme_me_mask;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
