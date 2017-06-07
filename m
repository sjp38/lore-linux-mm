Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C1CC56B03B5
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 15:19:05 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id j24so6175761ioi.0
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 12:19:05 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0050.outbound.protection.outlook.com. [104.47.32.50])
        by mx.google.com with ESMTPS id 10si696066itl.34.2017.06.07.12.19.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Jun 2017 12:19:04 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v6 32/34] x86/mm: Add support to encrypt the kernel in-place
Date: Wed, 07 Jun 2017 14:18:54 -0500
Message-ID: <20170607191853.28645.85024.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Add the support to encrypt the kernel in-place. This is done by creating
new page mappings for the kernel - a decrypted write-protected mapping
and an encrypted mapping. The kernel is encrypted by copying it through
a temporary buffer.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |    6 +
 arch/x86/mm/Makefile               |    2 
 arch/x86/mm/mem_encrypt.c          |  314 ++++++++++++++++++++++++++++++++++++
 arch/x86/mm/mem_encrypt_boot.S     |  150 +++++++++++++++++
 4 files changed, 472 insertions(+)
 create mode 100644 arch/x86/mm/mem_encrypt_boot.S

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index d86e544..e0a8edc 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -21,6 +21,12 @@
 
 extern unsigned long sme_me_mask;
 
+void sme_encrypt_execute(unsigned long encrypted_kernel_vaddr,
+			 unsigned long decrypted_kernel_vaddr,
+			 unsigned long kernel_len,
+			 unsigned long encryption_wa,
+			 unsigned long encryption_pgd);
+
 void __init sme_early_encrypt(resource_size_t paddr,
 			      unsigned long size);
 void __init sme_early_decrypt(resource_size_t paddr,
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 88ee454..47b26ea 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -38,3 +38,5 @@ obj-$(CONFIG_NUMA_EMU)		+= numa_emulation.o
 obj-$(CONFIG_X86_INTEL_MPX)	+= mpx.o
 obj-$(CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS) += pkeys.o
 obj-$(CONFIG_RANDOMIZE_MEMORY) += kaslr.o
+
+obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 018b58a..6129477 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -24,6 +24,8 @@
 #include <asm/setup.h>
 #include <asm/bootparam.h>
 #include <asm/set_memory.h>
+#include <asm/cacheflush.h>
+#include <asm/sections.h>
 
 /*
  * Since SME related variables are set early in the boot process they must
@@ -246,8 +248,320 @@ void swiotlb_set_mem_attributes(void *vaddr, unsigned long size)
 	set_memory_decrypted((unsigned long)vaddr, size >> PAGE_SHIFT);
 }
 
+static void __init sme_clear_pgd(pgd_t *pgd_base, unsigned long start,
+				 unsigned long end)
+{
+	unsigned long pgd_start, pgd_end, pgd_size;
+	pgd_t *pgd_p;
+
+	pgd_start = start & PGDIR_MASK;
+	pgd_end = end & PGDIR_MASK;
+
+	pgd_size = (((pgd_end - pgd_start) / PGDIR_SIZE) + 1);
+	pgd_size *= sizeof(pgd_t);
+
+	pgd_p = pgd_base + pgd_index(start);
+
+	memset(pgd_p, 0, pgd_size);
+}
+
+#ifndef CONFIG_X86_5LEVEL
+#define native_make_p4d(_x)	(p4d_t) { .pgd = native_make_pgd(_x) }
+#endif
+
+#define PGD_FLAGS	_KERNPG_TABLE_NOENC
+#define P4D_FLAGS	_KERNPG_TABLE_NOENC
+#define PUD_FLAGS	_KERNPG_TABLE_NOENC
+#define PMD_FLAGS	(__PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL)
+
+static void __init *sme_populate_pgd(pgd_t *pgd_base, void *pgtable_area,
+				     unsigned long vaddr, pmdval_t pmd_val)
+{
+	pgd_t *pgd_p;
+	p4d_t *p4d_p;
+	pud_t *pud_p;
+	pmd_t *pmd_p;
+
+	pgd_p = pgd_base + pgd_index(vaddr);
+	if (native_pgd_val(*pgd_p)) {
+		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+			p4d_p = (p4d_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
+		else
+			pud_p = (pud_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
+	} else {
+		pgd_t pgd;
+
+		if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+			p4d_p = pgtable_area;
+			memset(p4d_p, 0, sizeof(*p4d_p) * PTRS_PER_P4D);
+			pgtable_area += sizeof(*p4d_p) * PTRS_PER_P4D;
+
+			pgd = native_make_pgd((pgdval_t)p4d_p + PGD_FLAGS);
+		} else {
+			pud_p = pgtable_area;
+			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
+			pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
+
+			pgd = native_make_pgd((pgdval_t)pud_p + PGD_FLAGS);
+		}
+		native_set_pgd(pgd_p, pgd);
+	}
+
+	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		p4d_p += p4d_index(vaddr);
+		if (native_p4d_val(*p4d_p)) {
+			pud_p = (pud_t *)(native_p4d_val(*p4d_p) & ~PTE_FLAGS_MASK);
+		} else {
+			p4d_t p4d;
+
+			pud_p = pgtable_area;
+			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
+			pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
+
+			p4d = native_make_p4d((p4dval_t)pud_p + P4D_FLAGS);
+			native_set_p4d(p4d_p, p4d);
+		}
+	}
+
+	pud_p += pud_index(vaddr);
+	if (native_pud_val(*pud_p)) {
+		if (native_pud_val(*pud_p) & _PAGE_PSE)
+			goto out;
+
+		pmd_p = (pmd_t *)(native_pud_val(*pud_p) & ~PTE_FLAGS_MASK);
+	} else {
+		pud_t pud;
+
+		pmd_p = pgtable_area;
+		memset(pmd_p, 0, sizeof(*pmd_p) * PTRS_PER_PMD);
+		pgtable_area += sizeof(*pmd_p) * PTRS_PER_PMD;
+
+		pud = native_make_pud((pudval_t)pmd_p + PUD_FLAGS);
+		native_set_pud(pud_p, pud);
+	}
+
+	pmd_p += pmd_index(vaddr);
+	if (!native_pmd_val(*pmd_p) || !(native_pmd_val(*pmd_p) & _PAGE_PSE))
+		native_set_pmd(pmd_p, native_make_pmd(pmd_val));
+
+out:
+	return pgtable_area;
+}
+
+static unsigned long __init sme_pgtable_calc(unsigned long len)
+{
+	unsigned long p4d_size, pud_size, pmd_size;
+	unsigned long total;
+
+	/*
+	 * Perform a relatively simplistic calculation of the pagetable
+	 * entries that are needed. That mappings will be covered by 2MB
+	 * PMD entries so we can conservatively calculate the required
+	 * number of P4D, PUD and PMD structures needed to perform the
+	 * mappings. Incrementing the count for each covers the case where
+	 * the addresses cross entries.
+	 */
+	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		p4d_size = (ALIGN(len, PGDIR_SIZE) / PGDIR_SIZE) + 1;
+		p4d_size *= sizeof(p4d_t) * PTRS_PER_P4D;
+		pud_size = (ALIGN(len, P4D_SIZE) / P4D_SIZE) + 1;
+		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
+	} else {
+		p4d_size = 0;
+		pud_size = (ALIGN(len, PGDIR_SIZE) / PGDIR_SIZE) + 1;
+		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
+	}
+	pmd_size = (ALIGN(len, PUD_SIZE) / PUD_SIZE) + 1;
+	pmd_size *= sizeof(pmd_t) * PTRS_PER_PMD;
+
+	total = p4d_size + pud_size + pmd_size;
+
+	/*
+	 * Now calculate the added pagetable structures needed to populate
+	 * the new pagetables.
+	 */
+	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		p4d_size = ALIGN(total, PGDIR_SIZE) / PGDIR_SIZE;
+		p4d_size *= sizeof(p4d_t) * PTRS_PER_P4D;
+		pud_size = ALIGN(total, P4D_SIZE) / P4D_SIZE;
+		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
+	} else {
+		p4d_size = 0;
+		pud_size = ALIGN(total, PGDIR_SIZE) / PGDIR_SIZE;
+		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
+	}
+	pmd_size = ALIGN(total, PUD_SIZE) / PUD_SIZE;
+	pmd_size *= sizeof(pmd_t) * PTRS_PER_PMD;
+
+	total += p4d_size + pud_size + pmd_size;
+
+	return total;
+}
+
 void __init sme_encrypt_kernel(void)
 {
+	unsigned long workarea_start, workarea_end, workarea_len;
+	unsigned long execute_start, execute_end, execute_len;
+	unsigned long kernel_start, kernel_end, kernel_len;
+	unsigned long pgtable_area_len;
+	unsigned long paddr, pmd_flags;
+	unsigned long decrypted_base;
+	void *pgtable_area;
+	pgd_t *pgd;
+
+	if (!sme_active())
+		return;
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
+	/* Physical addresses gives us the identity mapped virtual addresses */
+	kernel_start = __pa_symbol(_text);
+	kernel_end = ALIGN(__pa_symbol(_end), PMD_PAGE_SIZE);
+	kernel_len = kernel_end - kernel_start;
+
+	/* Set the encryption workarea to be immediately after the kernel */
+	workarea_start = kernel_end;
+
+	/*
+	 * Calculate required number of workarea bytes needed:
+	 *   executable encryption area size:
+	 *     stack page (PAGE_SIZE)
+	 *     encryption routine page (PAGE_SIZE)
+	 *     intermediate copy buffer (PMD_PAGE_SIZE)
+	 *   pagetable structures for the encryption of the kernel
+	 *   pagetable structures for workarea (in case not currently mapped)
+	 */
+	execute_start = workarea_start;
+	execute_end = execute_start + (PAGE_SIZE * 2) + PMD_PAGE_SIZE;
+	execute_len = execute_end - execute_start;
+
+	/*
+	 * One PGD for both encrypted and decrypted mappings and a set of
+	 * PUDs and PMDs for each of the encrypted and decrypted mappings.
+	 */
+	pgtable_area_len = sizeof(pgd_t) * PTRS_PER_PGD;
+	pgtable_area_len += sme_pgtable_calc(execute_end - kernel_start) * 2;
+
+	/* PUDs and PMDs needed in the current pagetables for the workarea */
+	pgtable_area_len += sme_pgtable_calc(execute_len + pgtable_area_len);
+
+	/*
+	 * The total workarea includes the executable encryption area and
+	 * the pagetable area.
+	 */
+	workarea_len = execute_len + pgtable_area_len;
+	workarea_end = workarea_start + workarea_len;
+
+	/*
+	 * Set the address to the start of where newly created pagetable
+	 * structures (PGDs, PUDs and PMDs) will be allocated. New pagetable
+	 * structures are created when the workarea is added to the current
+	 * pagetables and when the new encrypted and decrypted kernel
+	 * mappings are populated.
+	 */
+	pgtable_area = (void *)execute_end;
+
+	/*
+	 * Make sure the current pagetable structure has entries for
+	 * addressing the workarea.
+	 */
+	pgd = (pgd_t *)native_read_cr3_pa();
+	paddr = workarea_start;
+	while (paddr < workarea_end) {
+		pgtable_area = sme_populate_pgd(pgd, pgtable_area,
+						paddr,
+						paddr + PMD_FLAGS);
+
+		paddr += PMD_PAGE_SIZE;
+	}
+
+	/* Flush the TLB - no globals so cr3 is enough */
+	native_write_cr3(native_read_cr3());
+
+	/*
+	 * A new pagetable structure is being built to allow for the kernel
+	 * to be encrypted. It starts with an empty PGD that will then be
+	 * populated with new PUDs and PMDs as the encrypted and decrypted
+	 * kernel mappings are created.
+	 */
+	pgd = pgtable_area;
+	memset(pgd, 0, sizeof(*pgd) * PTRS_PER_PGD);
+	pgtable_area += sizeof(*pgd) * PTRS_PER_PGD;
+
+	/* Add encrypted kernel (identity) mappings */
+	pmd_flags = PMD_FLAGS | _PAGE_ENC;
+	paddr = kernel_start;
+	while (paddr < kernel_end) {
+		pgtable_area = sme_populate_pgd(pgd, pgtable_area,
+						paddr,
+						paddr + pmd_flags);
+
+		paddr += PMD_PAGE_SIZE;
+	}
+
+	/*
+	 * A different PGD index/entry must be used to get different
+	 * pagetable entries for the decrypted mapping. Choose the next
+	 * PGD index and convert it to a virtual address to be used as
+	 * the base of the mapping.
+	 */
+	decrypted_base = (pgd_index(workarea_end) + 1) & (PTRS_PER_PGD - 1);
+	decrypted_base <<= PGDIR_SHIFT;
+
+	/* Add decrypted, write-protected kernel (non-identity) mappings */
+	pmd_flags = (PMD_FLAGS & ~_PAGE_CACHE_MASK) | (_PAGE_PAT | _PAGE_PWT);
+	paddr = kernel_start;
+	while (paddr < kernel_end) {
+		pgtable_area = sme_populate_pgd(pgd, pgtable_area,
+						paddr + decrypted_base,
+						paddr + pmd_flags);
+
+		paddr += PMD_PAGE_SIZE;
+	}
+
+	/* Add decrypted workarea mappings to both kernel mappings */
+	paddr = workarea_start;
+	while (paddr < workarea_end) {
+		pgtable_area = sme_populate_pgd(pgd, pgtable_area,
+						paddr,
+						paddr + PMD_FLAGS);
+
+		pgtable_area = sme_populate_pgd(pgd, pgtable_area,
+						paddr + decrypted_base,
+						paddr + PMD_FLAGS);
+
+		paddr += PMD_PAGE_SIZE;
+	}
+
+	/* Perform the encryption */
+	sme_encrypt_execute(kernel_start, kernel_start + decrypted_base,
+			    kernel_len, workarea_start, (unsigned long)pgd);
+
+	/*
+	 * At this point we are running encrypted.  Remove the mappings for
+	 * the decrypted areas - all that is needed for this is to remove
+	 * the PGD entry/entries.
+	 */
+	sme_clear_pgd(pgd, kernel_start + decrypted_base,
+		      kernel_end + decrypted_base);
+
+	sme_clear_pgd(pgd, workarea_start + decrypted_base,
+		      workarea_end + decrypted_base);
+
+	/* Flush the TLB - no globals so cr3 is enough */
+	native_write_cr3(native_read_cr3());
 }
 
 unsigned long __init sme_enable(void)
diff --git a/arch/x86/mm/mem_encrypt_boot.S b/arch/x86/mm/mem_encrypt_boot.S
new file mode 100644
index 0000000..7720b00
--- /dev/null
+++ b/arch/x86/mm/mem_encrypt_boot.S
@@ -0,0 +1,150 @@
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
+	/*
+	 * Entry parameters:
+	 *   RDI - virtual address for the encrypted kernel mapping
+	 *   RSI - virtual address for the decrypted kernel mapping
+	 *   RDX - length of kernel
+	 *   RCX - virtual address of the encryption workarea, including:
+	 *     - stack page (PAGE_SIZE)
+	 *     - encryption routine page (PAGE_SIZE)
+	 *     - intermediate copy buffer (PMD_PAGE_SIZE)
+	 *    R8 - physcial address of the pagetables to use for encryption
+	 */
+
+	push	%rbp
+	push	%r12
+
+	/* Set up a one page stack in the non-encrypted memory area */
+	movq	%rsp, %rbp		/* Save current stack pointer */
+	movq	%rcx, %rax		/* Workarea stack page */
+	movq	%rax, %rsp		/* Set new stack pointer */
+	addq	$PAGE_SIZE, %rsp	/* Stack grows from the bottom */
+	addq	$PAGE_SIZE, %rax	/* Workarea encryption routine */
+
+	movq	%rdi, %r10		/* Encrypted kernel */
+	movq	%rsi, %r11		/* Decrypted kernel */
+	movq	%rdx, %r12		/* Kernel length */
+
+	/* Copy encryption routine into the workarea */
+	movq	%rax, %rdi				/* Workarea encryption routine */
+	leaq	__enc_copy(%rip), %rsi			/* Encryption routine */
+	movq	$(.L__enc_copy_end - __enc_copy), %rcx	/* Encryption routine length */
+	rep	movsb
+
+	/* Setup registers for call */
+	movq	%r10, %rdi		/* Encrypted kernel */
+	movq	%r11, %rsi		/* Decrypted kernel */
+	movq	%r8, %rdx		/* Pagetables used for encryption */
+	movq	%r12, %rcx		/* Kernel length */
+	movq	%rax, %r8		/* Workarea encryption routine */
+	addq	$PAGE_SIZE, %r8		/* Workarea intermediate copy buffer */
+
+	call	*%rax			/* Call the encryption routine */
+
+	movq	%rbp, %rsp		/* Restore original stack pointer */
+
+	pop	%r12
+	pop	%rbp
+
+	ret
+ENDPROC(sme_encrypt_execute)
+
+ENTRY(__enc_copy)
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
+	movq	%rcx, %r9		/* Save kernel length */
+	movq	%rdi, %r10		/* Save encrypted kernel address */
+	movq	%rsi, %r11		/* Save decrypted kernel address */
+
+	wbinvd				/* Invalidate any cache entries */
+
+	/* Copy/encrypt 2MB at a time */
+1:
+	movq	%r11, %rsi		/* Source - decrypted kernel */
+	movq	%r8, %rdi		/* Dest   - intermediate copy buffer */
+	movq	$PMD_PAGE_SIZE, %rcx	/* 2MB length */
+	rep	movsb
+
+	movq	%r8, %rsi		/* Source - intermediate copy buffer */
+	movq	%r10, %rdi		/* Dest   - encrypted kernel */
+	movq	$PMD_PAGE_SIZE, %rcx	/* 2MB length */
+	rep	movsb
+
+	addq	$PMD_PAGE_SIZE, %r11
+	addq	$PMD_PAGE_SIZE, %r10
+	subq	$PMD_PAGE_SIZE, %r9	/* Kernel length decrement */
+	jnz	1b			/* Kernel length not zero? */
+
+	/* Restore PAT register */
+	push	%rdx			/* Save original PAT value */
+	movl	$MSR_IA32_CR_PAT, %ecx
+	rdmsr
+	pop	%rdx			/* Restore original PAT value */
+	wrmsr
+
+	ret
+.L__enc_copy_end:
+ENDPROC(__enc_copy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
