Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id AB9F92806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:17:46 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id c62so3908259oia.13
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:17:46 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0044.outbound.protection.outlook.com. [104.47.34.44])
        by mx.google.com with ESMTPS id i4si130687ota.300.2017.04.18.14.17.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:17:45 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 07/32] x86/mm: Add support to enable SME in early boot
 processing
Date: Tue, 18 Apr 2017 16:17:35 -0500
Message-ID: <20170418211735.10190.29562.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Add support to the early boot code to use Secure Memory Encryption (SME).
Since the kernel has been loaded into memory in a decrypted state, support
is added to encrypt the kernel in place and update the early pagetables
with the memory encryption mask so that new pagetable entries will use
memory encryption.

The routines to set the encryption mask and perform the encryption are
stub routines for now with functionality to be added in a later patch.

Because of the need to have the routines available to head_64.S, the
mem_encrypt.c is always built and #ifdefs in mem_encrypt.c will provide
functionality or stub routines depending on CONFIG_AMD_MEM_ENCRYPT.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/head_64.S |   61 ++++++++++++++++++++++++++++++++++++++++++++-
 arch/x86/mm/Makefile      |    4 +--
 arch/x86/mm/mem_encrypt.c |   26 +++++++++++++++++++
 3 files changed, 86 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index ac9d327..3115e21 100644
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
@@ -142,6 +161,12 @@ startup_64:
 	decl	%ecx
 	jnz	1b
 
+	/*
+	 * Determine if any fixups are required. This includes fixups
+	 * based on where the kernel was loaded and whether SME is
+	 * active. If %rbp is zero, then we can skip both the fixups
+	 * and the call to encrypt the kernel.
+	 */
 	test %rbp, %rbp
 	jz .Lskip_fixup
 
@@ -162,11 +187,30 @@ startup_64:
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
+	/*
+	 * The encryption mask is in %r12. We ADD this to %rax to be sure
+	 * that the encryption mask is part of the value that will be
+	 * stored in %cr3.
+	 */
 	movq	$(early_level4_pgt - __START_KERNEL_map), %rax
+	addq	%r12, %rax
 	jmp 1f
 ENTRY(secondary_startup_64)
 	/*
@@ -186,7 +230,20 @@ ENTRY(secondary_startup_64)
 	/* Sanitize CPU configuration */
 	call verify_cpu
 
-	movq	$(init_level4_pgt - __START_KERNEL_map), %rax
+	/*
+	 * Get the SME encryption mask.
+	 *  The encryption mask will be returned in %rax so we do an ADD
+	 *  below to be sure that the encryption mask is part of the
+	 *  value that will stored in %cr3.
+	 *
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
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index a94a7b6..9e13841 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -2,7 +2,7 @@
 KCOV_INSTRUMENT_tlb.o	:= n
 
 obj-y	:=  init.o init_$(BITS).o fault.o ioremap.o extable.o pageattr.o mmap.o \
-	    pat.o pgtable.o physaddr.o setup_nx.o tlb.o
+	    pat.o pgtable.o physaddr.o setup_nx.o tlb.o mem_encrypt.o
 
 # Make sure __phys_addr has no stackprotector
 nostackp := $(call cc-option, -fno-stack-protector)
@@ -38,5 +38,3 @@ obj-$(CONFIG_NUMA_EMU)		+= numa_emulation.o
 obj-$(CONFIG_X86_INTEL_MPX)	+= mpx.o
 obj-$(CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS) += pkeys.o
 obj-$(CONFIG_RANDOMIZE_MEMORY) += kaslr.o
-
-obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index b99d469..cc00d8b 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -11,6 +11,9 @@
  */
 
 #include <linux/linkage.h>
+#include <linux/init.h>
+
+#ifdef CONFIG_AMD_MEM_ENCRYPT
 
 /*
  * Since SME related variables are set early in the boot process they must
@@ -19,3 +22,26 @@
  */
 unsigned long sme_me_mask __section(.data) = 0;
 EXPORT_SYMBOL_GPL(sme_me_mask);
+
+void __init sme_encrypt_kernel(void)
+{
+}
+
+unsigned long __init sme_enable(void)
+{
+	return sme_me_mask;
+}
+
+unsigned long sme_get_me_mask(void)
+{
+	return sme_me_mask;
+}
+
+#else	/* !CONFIG_AMD_MEM_ENCRYPT */
+
+void __init sme_encrypt_kernel(void)	{ }
+unsigned long __init sme_enable(void)	{ return 0; }
+
+unsigned long sme_get_me_mask(void)	{ return 0; }
+
+#endif	/* CONFIG_AMD_MEM_ENCRYPT */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
