Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C988680FFB
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:48:22 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id e137so42950787itc.0
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:48:22 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0044.outbound.protection.outlook.com. [104.47.33.44])
        by mx.google.com with ESMTPS id n65si7560162itb.49.2017.02.16.07.48.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 07:48:21 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v4 27/28] x86: Add support to encrypt the kernel in-place
Date: Thu, 16 Feb 2017 09:48:08 -0600
Message-ID: <20170216154808.19244.475.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

This patch adds the support to encrypt the kernel in-place. This is
done by creating new page mappings for the kernel - a decrypted
write-protected mapping and an encrypted mapping. The kernel is encyrpted
by copying the kernel through a temporary buffer.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/Makefile           |    1 
 arch/x86/kernel/mem_encrypt_boot.S |  156 +++++++++++++++++++++++++++++
 arch/x86/kernel/mem_encrypt_init.c |  191 ++++++++++++++++++++++++++++++++++++
 3 files changed, 348 insertions(+)
 create mode 100644 arch/x86/kernel/mem_encrypt_boot.S

diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 33af80a..dc3ed84 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -142,4 +142,5 @@ ifeq ($(CONFIG_X86_64),y)
 	obj-y				+= vsmp_64.o
 
 	obj-y				+= mem_encrypt_init.o
+	obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
 endif
diff --git a/arch/x86/kernel/mem_encrypt_boot.S b/arch/x86/kernel/mem_encrypt_boot.S
new file mode 100644
index 0000000..58e1756
--- /dev/null
+++ b/arch/x86/kernel/mem_encrypt_boot.S
@@ -0,0 +1,156 @@
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
+#include <asm/pgtable.h>
+#include <asm/page.h>
+#include <asm/processor-flags.h>
+#include <asm/msr-index.h>
+
+	.text
+	.code64
+ENTRY(sme_encrypt_execute)
+
+#ifdef CONFIG_AMD_MEM_ENCRYPT
+	/*
+	 * Entry parameters:
+	 *   RDI - virtual address for the encrypted kernel mapping
+	 *   RSI - virtual address for the decrypted kernel mapping
+	 *   RDX - length of kernel
+	 *   RCX - address of the encryption workarea
+	 *     - stack page (PAGE_SIZE)
+	 *     - encryption routine page (PAGE_SIZE)
+	 *     - intermediate copy buffer (PMD_PAGE_SIZE)
+	 *    R8 - address of the pagetables to use for encryption
+	 */
+
+	/* Set up a one page stack in the non-encrypted memory area */
+	movq	%rcx, %rax
+	addq	$PAGE_SIZE, %rax
+	movq	%rsp, %rbp
+	movq	%rax, %rsp
+	push	%rbp
+
+	push	%r12
+	push	%r13
+
+	movq	%rdi, %r10
+	movq	%rsi, %r11
+	movq	%rdx, %r12
+	movq	%rcx, %r13
+
+	/* Copy encryption routine into the workarea */
+	movq	%rax, %rdi
+	leaq	.Lencrypt_start(%rip), %rsi
+	movq	$(.Lencrypt_stop - .Lencrypt_start), %rcx
+	rep	movsb
+
+	/* Setup registers for call */
+	movq	%r10, %rdi
+	movq	%r11, %rsi
+	movq	%r8, %rdx
+	movq	%r12, %rcx
+	movq	%rax, %r8
+	addq	$PAGE_SIZE, %r8
+
+	/* Call the encryption routine */
+	call	*%rax
+
+	pop	%r13
+	pop	%r12
+
+	pop	%rsp			/* Restore original stack pointer */
+.Lencrypt_exit:
+#endif	/* CONFIG_AMD_MEM_ENCRYPT */
+
+	ret
+ENDPROC(sme_encrypt_execute)
+
+#ifdef CONFIG_AMD_MEM_ENCRYPT
+/*
+ * Routine used to encrypt kernel.
+ *   This routine must be run outside of the kernel proper since
+ *   the kernel will be encrypted during the process. So this
+ *   routine is defined here and then copied to an area outside
+ *   of the kernel where it will remain and run decrypted
+ *   during execution.
+ *
+ *   On entry the registers must be:
+ *     RDI - virtual address for the encrypted kernel mapping
+ *     RSI - virtual address for the decrypted kernel mapping
+ *     RDX - address of the pagetables to use for encryption
+ *     RCX - length of kernel
+ *      R8 - intermediate copy buffer
+ *
+ *     RAX - points to this routine
+ *
+ * The kernel will be encrypted by copying from the non-encrypted
+ * kernel space to an intermediate buffer and then copying from the
+ * intermediate buffer back to the encrypted kernel space. The physical
+ * addresses of the two kernel space mappings are the same which
+ * results in the kernel being encrypted "in place".
+ */
+.Lencrypt_start:
+	/* Enable the new page tables */
+	mov	%rdx, %cr3
+
+	/* Flush any global TLBs */
+	mov	%cr4, %rdx
+	andq	$~X86_CR4_PGE, %rdx
+	mov	%rdx, %cr4
+	orq	$X86_CR4_PGE, %rdx
+	mov	%rdx, %cr4
+
+	/* Set the PAT register PA5 entry to write-protect */
+	push	%rcx
+	movl	$MSR_IA32_CR_PAT, %ecx
+	rdmsr
+	push	%rdx			/* Save original PAT value */
+	andl	$0xffff00ff, %edx	/* Clear PA5 */
+	orl	$0x00000500, %edx	/* Set PA5 to WP */
+	wrmsr
+	pop	%rdx			/* RDX contains original PAT value */
+	pop	%rcx
+
+	movq	%rcx, %r9		/* Save length */
+	movq	%rdi, %r10		/* Save destination address */
+	movq	%rsi, %r11		/* Save source address */
+
+	wbinvd				/* Invalidate any cache entries */
+
+	/* Copy/encrypt 2MB at a time */
+1:
+	movq	%r11, %rsi
+	movq	%r8, %rdi
+	movq	$PMD_PAGE_SIZE, %rcx
+	rep	movsb
+
+	movq	%r8, %rsi
+	movq	%r10, %rdi
+	movq	$PMD_PAGE_SIZE, %rcx
+	rep	movsb
+
+	addq	$PMD_PAGE_SIZE, %r11
+	addq	$PMD_PAGE_SIZE, %r10
+	subq	$PMD_PAGE_SIZE, %r9
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
diff --git a/arch/x86/kernel/mem_encrypt_init.c b/arch/x86/kernel/mem_encrypt_init.c
index 25af15d..07cbb90 100644
--- a/arch/x86/kernel/mem_encrypt_init.c
+++ b/arch/x86/kernel/mem_encrypt_init.c
@@ -16,9 +16,200 @@
 #ifdef CONFIG_AMD_MEM_ENCRYPT
 
 #include <linux/mem_encrypt.h>
+#include <linux/mm.h>
+
+#include <asm/sections.h>
+
+extern void sme_encrypt_execute(unsigned long, unsigned long, unsigned long,
+				void *, pgd_t *);
+
+#define PGD_FLAGS	_KERNPG_TABLE_NOENC
+#define PUD_FLAGS	_KERNPG_TABLE_NOENC
+#define PMD_FLAGS	__PAGE_KERNEL_LARGE_EXEC
+
+static void __init *sme_pgtable_entry(pgd_t *pgd, void *next_page,
+				      void *vaddr, pmdval_t pmd_val)
+{
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd += pgd_index((unsigned long)vaddr);
+	if (pgd_none(*pgd)) {
+		pud = next_page;
+		memset(pud, 0, sizeof(*pud) * PTRS_PER_PUD);
+		native_set_pgd(pgd,
+			       native_make_pgd((unsigned long)pud + PGD_FLAGS));
+		next_page += sizeof(*pud) * PTRS_PER_PUD;
+	} else {
+		pud = (pud_t *)(native_pgd_val(*pgd) & ~PTE_FLAGS_MASK);
+	}
+
+	pud += pud_index((unsigned long)vaddr);
+	if (pud_none(*pud)) {
+		pmd = next_page;
+		memset(pmd, 0, sizeof(*pmd) * PTRS_PER_PMD);
+		native_set_pud(pud,
+			       native_make_pud((unsigned long)pmd + PUD_FLAGS));
+		next_page += sizeof(*pmd) * PTRS_PER_PMD;
+	} else {
+		pmd = (pmd_t *)(native_pud_val(*pud) & ~PTE_FLAGS_MASK);
+	}
+
+	pmd += pmd_index((unsigned long)vaddr);
+	if (pmd_none(*pmd) || !pmd_large(*pmd))
+		native_set_pmd(pmd, native_make_pmd(pmd_val));
+
+	return next_page;
+}
+
+static unsigned long __init sme_pgtable_calc(unsigned long start,
+					     unsigned long end)
+{
+	unsigned long addr, total;
+
+	total = 0;
+	addr = start;
+	while (addr < end) {
+		unsigned long pgd_end;
+
+		pgd_end = (addr & PGDIR_MASK) + PGDIR_SIZE;
+		if (pgd_end > end)
+			pgd_end = end;
+
+		total += sizeof(pud_t) * PTRS_PER_PUD * 2;
+
+		while (addr < pgd_end) {
+			unsigned long pud_end;
+
+			pud_end = (addr & PUD_MASK) + PUD_SIZE;
+			if (pud_end > end)
+				pud_end = end;
+
+			total += sizeof(pmd_t) * PTRS_PER_PMD * 2;
+
+			addr = pud_end;
+		}
+
+		addr = pgd_end;
+	}
+	total += sizeof(pgd_t) * PTRS_PER_PGD;
+
+	return total;
+}
 
 void __init sme_encrypt_kernel(void)
 {
+	pgd_t *pgd;
+	void *workarea, *next_page, *vaddr;
+	unsigned long kern_start, kern_end, kern_len;
+	unsigned long index, paddr, pmd_flags;
+	unsigned long exec_size, full_size;
+
+	/* If SME is not active then no need to prepare */
+	if (!sme_active())
+		return;
+
+	/* Set the workarea to be after the kernel */
+	workarea = (void *)ALIGN(__pa_symbol(_end), PMD_PAGE_SIZE);
+
+	/*
+	 * Prepare for encrypting the kernel by building new pagetables with
+	 * the necessary attributes needed to encrypt the kernel in place.
+	 *
+	 *   One range of virtual addresses will map the memory occupied
+	 *   by the kernel as encrypted.
+	 *
+	 *   Another range of virtual addresses will map the memory occupied
+	 *   by the kernel as decrypted and write-protected.
+	 *
+	 *     The use of write-protect attribute will prevent any of the
+	 *     memory from being cached.
+	 */
+
+	/* Physical address gives us the identity mapped virtual address */
+	kern_start = __pa_symbol(_text);
+	kern_end = ALIGN(__pa_symbol(_end), PMD_PAGE_SIZE) - 1;
+	kern_len = kern_end - kern_start + 1;
+
+	/*
+	 * Calculate required number of workarea bytes needed:
+	 *   executable encryption area size:
+	 *     stack page (PAGE_SIZE)
+	 *     encryption routine page (PAGE_SIZE)
+	 *     intermediate copy buffer (PMD_PAGE_SIZE)
+	 *   pagetable structures for workarea (in case not currently mapped)
+	 *   pagetable structures for the encryption of the kernel
+	 */
+	exec_size = (PAGE_SIZE * 2) + PMD_PAGE_SIZE;
+
+	full_size = exec_size;
+	full_size += ALIGN(exec_size, PMD_PAGE_SIZE) / PMD_PAGE_SIZE *
+		     sizeof(pmd_t) * PTRS_PER_PMD;
+	full_size += sme_pgtable_calc(kern_start, kern_end + exec_size);
+
+	next_page = workarea + exec_size;
+
+	/* Make sure the current pagetables have entries for the workarea */
+	pgd = (pgd_t *)native_read_cr3();
+	paddr = (unsigned long)workarea;
+	while (paddr < (unsigned long)workarea + full_size) {
+		vaddr = (void *)paddr;
+		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
+					      paddr + PMD_FLAGS);
+
+		paddr += PMD_PAGE_SIZE;
+	}
+	native_write_cr3(native_read_cr3());
+
+	/* Calculate a PGD index to be used for the decrypted mapping */
+	index = (pgd_index(kern_end + full_size) + 1) & (PTRS_PER_PGD - 1);
+	index <<= PGDIR_SHIFT;
+
+	/* Set and clear the PGD */
+	pgd = next_page;
+	memset(pgd, 0, sizeof(*pgd) * PTRS_PER_PGD);
+	next_page += sizeof(*pgd) * PTRS_PER_PGD;
+
+	/* Add encrypted (identity) mappings for the kernel */
+	pmd_flags = PMD_FLAGS | _PAGE_ENC;
+	paddr = kern_start;
+	while (paddr < kern_end) {
+		vaddr = (void *)paddr;
+		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
+					      paddr + pmd_flags);
+
+		paddr += PMD_PAGE_SIZE;
+	}
+
+	/* Add decrypted (non-identity) mappings for the kernel */
+	pmd_flags = (PMD_FLAGS & ~_PAGE_CACHE_MASK) | (_PAGE_PAT | _PAGE_PWT);
+	paddr = kern_start;
+	while (paddr < kern_end) {
+		vaddr = (void *)(paddr + index);
+		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
+					      paddr + pmd_flags);
+
+		paddr += PMD_PAGE_SIZE;
+	}
+
+	/* Add the workarea to both mappings */
+	paddr = kern_end + 1;
+	while (paddr < (kern_end + exec_size)) {
+		vaddr = (void *)paddr;
+		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
+					      paddr + PMD_FLAGS);
+
+		vaddr = (void *)(paddr + index);
+		next_page = sme_pgtable_entry(pgd, next_page, vaddr,
+					      paddr + PMD_FLAGS);
+
+		paddr += PMD_PAGE_SIZE;
+	}
+
+	/* Perform the encryption */
+	sme_encrypt_execute(kern_start, kern_start + index, kern_len,
+			    workarea, pgd);
+
 }
 
 unsigned long __init sme_get_me_mask(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
