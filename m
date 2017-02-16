Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF589680FF1
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:43:29 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id l26so21934892ota.2
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:43:29 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0066.outbound.protection.outlook.com. [104.47.32.66])
        by mx.google.com with ESMTPS id f9si3449799otb.253.2017.02.16.07.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 07:43:28 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v4 06/28] x86: Add support to enable SME during early
 boot processing
Date: Thu, 16 Feb 2017 09:43:19 -0600
Message-ID: <20170216154319.19244.7863.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

This patch adds support to the early boot code to use Secure Memory
Encryption (SME).  Support is added to update the early pagetables with
the memory encryption mask and to encrypt the kernel in place.

The routines to set the encryption mask and perform the encryption are
stub routines for now with full function to be added in a later patch.

A new file, arch/x86/kernel/mem_encrypt_init.c, is introduced to avoid
adding #ifdefs within arch/x86/kernel/head_64.S and allow
arch/x86/mm/mem_encrypt.c to be removed from the build if SME is not
configured. The mem_encrypt_init.c file will contain the necessary #ifdefs
to allow head_64.S to successfully build and call the SME routines.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/Makefile           |    2 +
 arch/x86/kernel/head_64.S          |   46 ++++++++++++++++++++++++++++++++-
 arch/x86/kernel/mem_encrypt_init.c |   50 ++++++++++++++++++++++++++++++++++++
 3 files changed, 96 insertions(+), 2 deletions(-)
 create mode 100644 arch/x86/kernel/mem_encrypt_init.c

diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index bdcdb3b..33af80a 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -140,4 +140,6 @@ ifeq ($(CONFIG_X86_64),y)
 
 	obj-$(CONFIG_PCI_MMCONFIG)	+= mmconf-fam10h_64.o
 	obj-y				+= vsmp_64.o
+
+	obj-y				+= mem_encrypt_init.o
 endif
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index b467b14..4f8201b 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -91,6 +91,23 @@ startup_64:
 	jnz	bad_address
 
 	/*
+	 * Enable Secure Memory Encryption (SME), if supported and enabled.
+	 * The real_mode_data address is in %rsi and that register can be
+	 * clobbered by the called function so be sure to save it.
+	 * Save the returned mask in %r12 for later use.
+	 */
+	push	%rsi
+	call	sme_enable
+	pop	%rsi
+	movq	%rax, %r12
+
+	/*
+	 * Add the memory encryption mask to %rbp to include it in the page
+	 * table fixups.
+	 */
+	addq	%r12, %rbp
+
+	/*
 	 * Fixup the physical addresses in the page table
 	 */
 	addq	%rbp, early_level4_pgt + (L4_START_KERNEL*8)(%rip)
@@ -113,6 +130,7 @@ startup_64:
 	shrq	$PGDIR_SHIFT, %rax
 
 	leaq	(PAGE_SIZE + _KERNPG_TABLE)(%rbx), %rdx
+	addq	%r12, %rdx
 	movq	%rdx, 0(%rbx,%rax,8)
 	movq	%rdx, 8(%rbx,%rax,8)
 
@@ -129,6 +147,7 @@ startup_64:
 	movq	%rdi, %rax
 	shrq	$PMD_SHIFT, %rdi
 	addq	$(__PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL), %rax
+	addq	%r12, %rax
 	leaq	(_end - 1)(%rip), %rcx
 	shrq	$PMD_SHIFT, %rcx
 	subq	%rdi, %rcx
@@ -162,11 +181,25 @@ startup_64:
 	cmp	%r8, %rdi
 	jne	1b
 
-	/* Fixup phys_base */
+	/*
+	 * Fixup phys_base - remove the memory encryption mask from %rbp
+	 * to obtain the true physical address.
+	 */
+	subq	%r12, %rbp
 	addq	%rbp, phys_base(%rip)
 
+	/*
+	 * Encrypt the kernel if SME is active.
+	 * The real_mode_data address is in %rsi and that register can be
+	 * clobbered by the called function so be sure to save it.
+	 */
+	push	%rsi
+	call	sme_encrypt_kernel
+	pop	%rsi
+
 .Lskip_fixup:
 	movq	$(early_level4_pgt - __START_KERNEL_map), %rax
+	addq	%r12, %rax
 	jmp 1f
 ENTRY(secondary_startup_64)
 	/*
@@ -186,7 +219,16 @@ ENTRY(secondary_startup_64)
 	/* Sanitize CPU configuration */
 	call verify_cpu
 
-	movq	$(init_level4_pgt - __START_KERNEL_map), %rax
+	/*
+	 * Get the SME encryption mask.
+	 * The real_mode_data address is in %rsi and that register can be
+	 * clobbered by the called function so be sure to save it.
+	 */
+	push	%rsi
+	call	sme_get_me_mask
+	pop	%rsi
+
+	addq	$(init_level4_pgt - __START_KERNEL_map), %rax
 1:
 
 	/* Enable PAE mode and PGE */
diff --git a/arch/x86/kernel/mem_encrypt_init.c b/arch/x86/kernel/mem_encrypt_init.c
new file mode 100644
index 0000000..25af15d
--- /dev/null
+++ b/arch/x86/kernel/mem_encrypt_init.c
@@ -0,0 +1,50 @@
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
+
+#ifdef CONFIG_AMD_MEM_ENCRYPT
+
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
+
+#else	/* !CONFIG_AMD_MEM_ENCRYPT */
+
+void __init sme_encrypt_kernel(void)
+{
+}
+
+unsigned long __init sme_get_me_mask(void)
+{
+	return 0;
+}
+
+unsigned long __init sme_enable(void)
+{
+	return 0;
+}
+
+#endif	/* CONFIG_AMD_MEM_ENCRYPT */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
