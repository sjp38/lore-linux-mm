Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB596B027C
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 18:39:16 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id r91so265324126uar.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 15:39:16 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0041.outbound.protection.outlook.com. [104.47.33.41])
        by mx.google.com with ESMTPS id z24si240393qtb.68.2016.08.22.15.39.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 15:39:15 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v2 20/20] x86: Add support to make use of Secure Memory
 Encryption
Date: Mon, 22 Aug 2016 17:39:08 -0500
Message-ID: <20160822223908.29880.50365.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy
 Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

This patch adds the support to check if SME has been enabled and if the
mem_encrypt=on command line option is set. If both of these conditions
are true, then the encryption mask is set and the kernel is encrypted
"in place."

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 Documentation/kernel-parameters.txt |    3 
 arch/x86/kernel/asm-offsets.c       |    2 
 arch/x86/kernel/mem_encrypt.S       |  302 +++++++++++++++++++++++++++++++++++
 arch/x86/mm/mem_encrypt.c           |    2 
 4 files changed, 309 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 46c030a..a1986c8 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2268,6 +2268,9 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			memory contents and reserves bad memory
 			regions that are detected.
 
+	mem_encrypt=on	[X86_64] Enable memory encryption on processors
+			that support this feature.
+
 	meye.*=		[HW] Set MotionEye Camera parameters
 			See Documentation/video4linux/meye.txt.
 
diff --git a/arch/x86/kernel/asm-offsets.c b/arch/x86/kernel/asm-offsets.c
index 2bd5c6f..e485ada 100644
--- a/arch/x86/kernel/asm-offsets.c
+++ b/arch/x86/kernel/asm-offsets.c
@@ -85,6 +85,8 @@ void common(void) {
 	OFFSET(BP_init_size, boot_params, hdr.init_size);
 	OFFSET(BP_pref_address, boot_params, hdr.pref_address);
 	OFFSET(BP_code32_start, boot_params, hdr.code32_start);
+	OFFSET(BP_cmd_line_ptr, boot_params, hdr.cmd_line_ptr);
+	OFFSET(BP_ext_cmd_line_ptr, boot_params, ext_cmd_line_ptr);
 
 	BLANK();
 	DEFINE(PTREGS_SIZE, sizeof(struct pt_regs));
diff --git a/arch/x86/kernel/mem_encrypt.S b/arch/x86/kernel/mem_encrypt.S
index f2e0536..bf9f6a9 100644
--- a/arch/x86/kernel/mem_encrypt.S
+++ b/arch/x86/kernel/mem_encrypt.S
@@ -12,13 +12,230 @@
 
 #include <linux/linkage.h>
 
+#include <asm/processor-flags.h>
+#include <asm/pgtable.h>
+#include <asm/page.h>
+#include <asm/msr.h>
+#include <asm/asm-offsets.h>
+
 	.text
 	.code64
 ENTRY(sme_enable)
+#ifdef CONFIG_AMD_MEM_ENCRYPT
+	/* Check for AMD processor */
+	xorl	%eax, %eax
+	cpuid
+	cmpl    $0x68747541, %ebx	# AuthenticAMD
+	jne     .Lmem_encrypt_exit
+	cmpl    $0x69746e65, %edx
+	jne     .Lmem_encrypt_exit
+	cmpl    $0x444d4163, %ecx
+	jne     .Lmem_encrypt_exit
+
+	/* Check for memory encryption leaf */
+	movl	$0x80000000, %eax
+	cpuid
+	cmpl	$0x8000001f, %eax
+	jb	.Lmem_encrypt_exit
+
+	/*
+	 * Check for memory encryption feature:
+	 *   CPUID Fn8000_001F[EAX] - Bit 0
+	 *     Secure Memory Encryption support
+	 *   CPUID Fn8000_001F[EBX] - Bits 5:0
+	 *     Pagetable bit position used to indicate encryption
+	 *   CPUID Fn8000_001F[EBX] - Bits 11:6
+	 *     Reduction in physical address space (in bits) when enabled
+	 */
+	movl	$0x8000001f, %eax
+	cpuid
+	bt	$0, %eax
+	jnc	.Lmem_encrypt_exit
+
+	/* Check if BIOS/UEFI has allowed memory encryption */
+	movl	$MSR_K8_SYSCFG, %ecx
+	rdmsr
+	bt	$MSR_K8_SYSCFG_MEM_ENCRYPT_BIT, %eax
+	jnc	.Lmem_encrypt_exit
+
+	/* Check for the mem_encrypt=on command line option */
+	push	%rsi			/* Save RSI (real_mode_data) */
+	push	%rbx			/* Save CPUID information */
+	movl	BP_ext_cmd_line_ptr(%rsi), %ecx
+	shlq	$32, %rcx
+	movl	BP_cmd_line_ptr(%rsi), %edi
+	addq	%rcx, %rdi
+	leaq	mem_encrypt_enable_option(%rip), %rsi
+	call	cmdline_find_option_bool
+	pop	%rbx			/* Restore CPUID information */
+	pop	%rsi			/* Restore RSI (real_mode_data) */
+	testl	%eax, %eax
+	jz	.Lno_mem_encrypt
+
+	/* Set memory encryption mask */
+	movl	%ebx, %ecx
+	andl	$0x3f, %ecx
+	bts	%ecx, sme_me_mask(%rip)
+
+.Lno_mem_encrypt:
+	/*
+	 * BIOS/UEFI has allowed memory encryption so we need to set
+	 * the amount of physical address space reduction even if
+	 * the user decides not to use memory encryption.
+	 */
+	movl	%ebx, %ecx
+	shrl	$6, %ecx
+	andl	$0x3f, %ecx
+	movb	%cl, sme_me_loss(%rip)
+
+.Lmem_encrypt_exit:
+#endif	/* CONFIG_AMD_MEM_ENCRYPT */
+
 	ret
 ENDPROC(sme_enable)
 
 ENTRY(sme_encrypt_kernel)
+#ifdef CONFIG_AMD_MEM_ENCRYPT
+	/* If SME is not active then no need to encrypt the kernel */
+	cmpq	$0, sme_me_mask(%rip)
+	jz	.Lencrypt_exit
+
+	/*
+	 * Encrypt the kernel.
+	 * Pagetables for performing kernel encryption:
+	 *   0x0000000000 - 0x00FFFFFFFF will map just the memory occupied by
+	 *				 the kernel as encrypted memory
+	 *   0x8000000000 - 0x80FFFFFFFF will map all memory as write-protected,
+	 *				 non-encrypted
+	 *
+	 * The use of write-protected memory will prevent any of the
+	 * non-encrypted memory from being cached.
+	 *
+	 * 0x00... and 0x80... represent the first and second PGD entries.
+	 *
+	 * This collection of entries will be created in an area outside
+	 * of the area that is being encrypted (outside the kernel) and
+	 * requires 11 4K pages:
+	 *   1 - PGD
+	 *   2 - PUDs (1 for each mapping)
+	 *   8 - PMDs (4 for each mapping)
+	 */
+	leaq	_end(%rip), %rdi
+	addq	$~PMD_PAGE_MASK, %rdi
+	andq	$PMD_PAGE_MASK, %rdi	/* RDI points to the new PGD */
+
+	/* Clear the pagetable memory */
+	movq	%rdi, %rbx		/* Save pointer to PGD */
+	movl	$(4096 * 11), %ecx
+	xorl	%eax, %eax
+	rep	stosb
+	movq	%rbx, %rdi		/* Restore pointer to PGD */
+
+	/* Set up PGD entries for the two mappings */
+	leaq	(0x1000 + 0x03)(%rdi), %rbx	/* PUD for encrypted kernel */
+	movq	%rbx, (%rdi)
+	leaq	(0x2000 + 0x03)(%rdi), %rbx	/* PUD for unencrypted kernel */
+	movq	%rbx, 8(%rdi)
+
+	/* Set up PUD entries (4 per mapping) for the two mappings */
+	leaq	(0x3000 + 0x03)(%rdi), %rbx	/* PMD for encrypted kernel */
+	leaq	(0x7000 + 0x03)(%rdi), %rdx	/* PMD for unencrypted kernel */
+	xorq	%rcx, %rcx
+1:
+	/* Populate the PUD entries in each mapping */
+	movq	%rbx, 0x1000(%rdi, %rcx, 8)
+	movq	%rdx, 0x2000(%rdi, %rcx, 8)
+	addq	$0x1000, %rbx
+	addq	$0x1000, %rdx
+	incq	%rcx
+	cmpq	$4, %rcx
+	jb	1b
+
+	/*
+	 * Set up PMD entries (4GB worth) for the two mappings.
+	 *   For the encrypted kernel mapping, when R11 is above RDX
+	 *   and below RDI then we know we are in the kernel and we
+	 *   set the encryption mask for that PMD entry.
+	 *
+	 *   The use of _PAGE_PAT and _PAGE_PWT will provide for the
+	 *   write-protected mapping.
+	 */
+	movq	sme_me_mask(%rip), %r10
+	movq	$__PAGE_KERNEL_LARGE_EXEC, %r11
+	andq	$~_PAGE_GLOBAL, %r11
+	movq	%r11, %r12
+	andq	$~_PAGE_CACHE_MASK, %r12
+	orq	$(_PAGE_PAT | _PAGE_PWT), %r12	/* PA5 index */
+	xorq	%rcx, %rcx
+	leaq	_text(%rip), %rdx	/* RDX points to start of kernel */
+1:
+	/* Populate the PMD entries in each mapping */
+	movq	%r11, 0x3000(%rdi, %rcx, 8)
+	movq	%r12, 0x7000(%rdi, %rcx, 8)
+
+	/*
+	 * Check if we are in the kernel range, and if so, set the
+	 * memory encryption mask.
+	 */
+	cmpq	%r11, %rdx
+	jae	2f
+	cmpq	%r11, %rdi
+	jbe	2f
+	orq	%r10, 0x3000(%rdi, %rcx, 8)
+2:
+	addq	$PMD_SIZE, %r11
+	addq	$PMD_SIZE, %r12
+	incq	%rcx
+	cmpq	$2048, %rcx
+	jb	1b
+
+	/*
+	 * Set up a one page stack in the non-encrypted memory area.
+	 *   Set RAX to point to the next page in memory after all the
+	 *   page tables. The stack grows from the bottom so point to
+	 *   the end of the page.
+	 */
+	leaq	(4096 * 11)(%rdi), %rax
+	addq	$PAGE_SIZE, %rax
+	movq	%rsp, %rbp
+	movq	%rax, %rsp
+	push	%rbp			/* Save original stack pointer */
+
+	push	%rsi			/* Save RSI (real mode data) */
+
+	/*
+	 * Copy encryption routine into safe memory
+	 *   - RAX points to the page after all the page tables and stack
+	 *     where the routine will copied
+	 *   - RDI points to the PGD table
+	 *   - Setup registers for call
+	 * and then call it
+	 */
+	movq	%rdi, %rbx
+
+	leaq	.Lencrypt_start(%rip), %rsi
+	movq	%rax, %rdi
+	movq	$(.Lencrypt_stop - .Lencrypt_start), %rcx
+	rep	movsb
+
+	leaq	_text(%rip), %rsi	/* Kernel start */
+	movq	%rbx, %rcx		/* New PGD start */
+	subq	%rsi, %rcx		/* Size of area to encrypt */
+
+	movq	%rsi, %rdi		/* Encrypted kernel space start */
+	movq	$1, %rsi
+	shlq	$PGDIR_SHIFT, %rsi
+	addq	%rdi, %rsi		/* Non-encrypted kernel start */
+
+	/* Call the encryption routine */
+	call	*%rax
+
+	pop	%rsi			/* Restore RSI (real mode data ) */
+
+	pop	%rsp			/* Restore original stack pointer */
+.Lencrypt_exit:
+#endif	/* CONFIG_AMD_MEM_ENCRYPT */
+
 	ret
 ENDPROC(sme_encrypt_kernel)
 
@@ -28,6 +245,87 @@ ENTRY(sme_get_me_loss)
 	ret
 ENDPROC(sme_get_me_loss)
 
+#ifdef CONFIG_AMD_MEM_ENCRYPT
+/*
+ * Routine used to encrypt kernel.
+ *   This routine must be run outside of the kernel proper since
+ *   the kernel will be encrypted during the process. So this
+ *   routine is defined here and then copied to an area outside
+ *   of the kernel where it will remain and run un-encrypted
+ *   during execution.
+ *
+ *   On entry the registers must be:
+ *   - RAX points to this routine
+ *   - RBX points to new PGD to use
+ *   - RCX contains the kernel length
+ *   - RSI points to the non-encrypted kernel space
+ *   - RDI points to the encrypted kernel space
+ *
+ * The kernel will be encrypted by copying from the non-encrypted
+ * kernel space to a temporary buffer and then copying from the
+ * temporary buffer back to the encrypted kernel space. The physical
+ * addresses of the two kernel space mappings are the same which
+ * results in the kernel being encrypted "in place".
+ */
+.Lencrypt_start:
+	/* Enable the new page tables */
+	mov	%rbx, %cr3
+
+	/* Flush any global TLBs */
+	mov	%cr4, %rbx
+	andq	$~X86_CR4_PGE, %rbx
+	mov	%rbx, %cr4
+	orq	$X86_CR4_PGE, %rbx
+	mov	%rbx, %cr4
+
+	/* Set the PAT register PA5 entry to write-protect */
+	push	%rax
+	push	%rcx
+	movl	$MSR_IA32_CR_PAT, %ecx
+	rdmsr
+	push	%rdx			/* Save original PAT value */
+	andl	$0xffff00ff, %edx	/* Clear PA5 */
+	orl	$0x00000500, %edx	/* Set PA5 to WP */
+	wrmsr
+	pop	%rdx			/* RDX contains original PAT value */
+	pop	%rcx
+	pop	%rax
+
+	movq	%rsi, %r10		/* Save source address */
+	movq	%rdi, %r11		/* Save destination address */
+	movq	%rcx, %r12		/* Save length */
+	addq	$PAGE_SIZE, %rax	/* RAX now points to temp copy page */
+
+	wbinvd				/* Invalidate any cache entries */
+
+	/* Copy/encrypt 2MB at a time */
+1:
+	movq	%r10, %rsi
+	movq	%rax, %rdi
+	movq	$PMD_PAGE_SIZE, %rcx
+	rep	movsb
+
+	movq	%rax, %rsi
+	movq	%r11, %rdi
+	movq	$PMD_PAGE_SIZE, %rcx
+	rep	movsb
+
+	addq	$PMD_PAGE_SIZE, %r10
+	addq	$PMD_PAGE_SIZE, %r11
+	subq	$PMD_PAGE_SIZE, %r12
+	jnz	1b
+
+	/* Restore PAT register */
+	push	%rdx
+	movl	$MSR_IA32_CR_PAT, %ecx
+	rdmsr
+	pop	%rdx
+	wrmsr
+
+	ret
+.Lencrypt_stop:
+#endif	/* CONFIG_AMD_MEM_ENCRYPT */
+
 	.data
 	.align 16
 ENTRY(sme_me_mask)
@@ -35,3 +333,7 @@ ENTRY(sme_me_mask)
 sme_me_loss:
 	.byte	0x00
 	.align	8
+
+mem_encrypt_enable_option:
+	.asciz "mem_encrypt=on"
+	.align	8
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 2f28d87..1154353 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -183,6 +183,8 @@ void __init mem_encrypt_init(void)
 
 	/* Make SWIOTLB use an unencrypted DMA area */
 	swiotlb_clear_encryption();
+
+	pr_info("memory encryption active\n");
 }
 
 unsigned long amd_iommu_get_me_mask(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
