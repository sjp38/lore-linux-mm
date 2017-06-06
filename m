Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E94956B0343
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 07:31:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c7so8859647pfd.12
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 04:31:45 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v77si33201685pfa.176.2017.06.06.04.31.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 04:31:44 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 09/14] x86/boot/64: Add support of additional page table level during early boot
Date: Tue,  6 Jun 2017 14:31:28 +0300
Message-Id: <20170606113133.22974-10-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
References: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch adds support for 5-level paging during early boot.
It generalizes boot for 4- and 5-level paging on 64-bit systems with
compile-time switch between them.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable_64.h           |  2 ++
 arch/x86/include/uapi/asm/processor-flags.h |  2 ++
 arch/x86/kernel/head64.c                    | 48 +++++++++++++++++++++++++----
 arch/x86/kernel/head_64.S                   | 26 ++++++++++++----
 4 files changed, 66 insertions(+), 12 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index affcb2a9c563..2160c1fee920 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -14,6 +14,8 @@
 #include <linux/bitops.h>
 #include <linux/threads.h>
 
+extern p4d_t level4_kernel_pgt[512];
+extern p4d_t level4_ident_pgt[512];
 extern pud_t level3_kernel_pgt[512];
 extern pud_t level3_ident_pgt[512];
 extern pmd_t level2_kernel_pgt[512];
diff --git a/arch/x86/include/uapi/asm/processor-flags.h b/arch/x86/include/uapi/asm/processor-flags.h
index 567de50a4c2a..185f3d10c194 100644
--- a/arch/x86/include/uapi/asm/processor-flags.h
+++ b/arch/x86/include/uapi/asm/processor-flags.h
@@ -104,6 +104,8 @@
 #define X86_CR4_OSFXSR		_BITUL(X86_CR4_OSFXSR_BIT)
 #define X86_CR4_OSXMMEXCPT_BIT	10 /* enable unmasked SSE exceptions */
 #define X86_CR4_OSXMMEXCPT	_BITUL(X86_CR4_OSXMMEXCPT_BIT)
+#define X86_CR4_LA57_BIT	12 /* enable 5-level page tables */
+#define X86_CR4_LA57		_BITUL(X86_CR4_LA57_BIT)
 #define X86_CR4_VMXE_BIT	13 /* enable VMX virtualization */
 #define X86_CR4_VMXE		_BITUL(X86_CR4_VMXE_BIT)
 #define X86_CR4_SMXE_BIT	14 /* enable safer mode (TXT) */
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index f8a2f34fa15d..9403633f4c7c 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -47,6 +47,7 @@ void __init __startup_64(unsigned long physaddr)
 {
 	unsigned long load_delta, *p;
 	pgdval_t *pgd;
+	p4dval_t *p4d;
 	pudval_t *pud;
 	pmdval_t *pmd, pmd_entry;
 	int i;
@@ -70,6 +71,11 @@ void __init __startup_64(unsigned long physaddr)
 	pgd = fixup_pointer(&early_top_pgt, physaddr);
 	pgd[pgd_index(__START_KERNEL_map)] += load_delta;
 
+	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		p4d = fixup_pointer(&level4_kernel_pgt, physaddr);
+		p4d[511] += load_delta;
+	}
+
 	pud = fixup_pointer(&level3_kernel_pgt, physaddr);
 	pud[510] += load_delta;
 	pud[511] += load_delta;
@@ -87,9 +93,21 @@ void __init __startup_64(unsigned long physaddr)
 	pud = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
 	pmd = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
 
-	i = (physaddr >> PGDIR_SHIFT) % PTRS_PER_PGD;
-	pgd[i + 0] = (pgdval_t)pud + _KERNPG_TABLE;
-	pgd[i + 1] = (pgdval_t)pud + _KERNPG_TABLE;
+	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		p4d = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
+
+		i = (physaddr >> PGDIR_SHIFT) % PTRS_PER_PGD;
+		pgd[i + 0] = (pgdval_t)p4d + _KERNPG_TABLE;
+		pgd[i + 1] = (pgdval_t)p4d + _KERNPG_TABLE;
+
+		i = (physaddr >> P4D_SHIFT) % PTRS_PER_P4D;
+		p4d[i + 0] = (pgdval_t)pud + _KERNPG_TABLE;
+		p4d[i + 1] = (pgdval_t)pud + _KERNPG_TABLE;
+	} else {
+		i = (physaddr >> PGDIR_SHIFT) % PTRS_PER_PGD;
+		pgd[i + 0] = (pgdval_t)pud + _KERNPG_TABLE;
+		pgd[i + 1] = (pgdval_t)pud + _KERNPG_TABLE;
+	}
 
 	i = (physaddr >> PUD_SHIFT) % PTRS_PER_PUD;
 	pud[i + 0] = (pudval_t)pmd + _KERNPG_TABLE;
@@ -134,6 +152,7 @@ int __init early_make_pgtable(unsigned long address)
 {
 	unsigned long physaddr = address - __PAGE_OFFSET;
 	pgdval_t pgd, *pgd_p;
+	p4dval_t p4d, *p4d_p;
 	pudval_t pud, *pud_p;
 	pmdval_t pmd, *pmd_p;
 
@@ -150,8 +169,25 @@ int __init early_make_pgtable(unsigned long address)
 	 * critical -- __PAGE_OFFSET would point us back into the dynamic
 	 * range and we might end up looping forever...
 	 */
-	if (pgd)
-		pud_p = (pudval_t *)((pgd & PTE_PFN_MASK) + __START_KERNEL_map - phys_base);
+	if (!IS_ENABLED(CONFIG_X86_5LEVEL))
+		p4d_p = pgd_p;
+	else if (pgd)
+		p4d_p = (p4dval_t *)((pgd & PTE_PFN_MASK) + __START_KERNEL_map - phys_base);
+	else {
+		if (next_early_pgt >= EARLY_DYNAMIC_PAGE_TABLES) {
+			reset_early_page_tables();
+			goto again;
+		}
+
+		p4d_p = (p4dval_t *)early_dynamic_pgts[next_early_pgt++];
+		memset(p4d_p, 0, sizeof(*p4d_p) * PTRS_PER_P4D);
+		*pgd_p = (pgdval_t)p4d_p - __START_KERNEL_map + phys_base + _KERNPG_TABLE;
+	}
+	p4d_p += p4d_index(address);
+	p4d = *p4d_p;
+
+	if (p4d)
+		pud_p = (pudval_t *)((p4d & PTE_PFN_MASK) + __START_KERNEL_map - phys_base);
 	else {
 		if (next_early_pgt >= EARLY_DYNAMIC_PAGE_TABLES) {
 			reset_early_page_tables();
@@ -160,7 +196,7 @@ int __init early_make_pgtable(unsigned long address)
 
 		pud_p = (pudval_t *)early_dynamic_pgts[next_early_pgt++];
 		memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
-		*pgd_p = (pgdval_t)pud_p - __START_KERNEL_map + phys_base + _KERNPG_TABLE;
+		*p4d_p = (p4dval_t)pud_p - __START_KERNEL_map + phys_base + _KERNPG_TABLE;
 	}
 	pud_p += pud_index(address);
 	pud = *pud_p;
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 0ae0bad4d4d5..6225550883df 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -37,10 +37,11 @@
  *
  */
 
+#define p4d_index(x)	(((x) >> P4D_SHIFT) & (PTRS_PER_P4D-1))
 #define pud_index(x)	(((x) >> PUD_SHIFT) & (PTRS_PER_PUD-1))
 
-L4_PAGE_OFFSET = pgd_index(__PAGE_OFFSET_BASE)
-L4_START_KERNEL = pgd_index(__START_KERNEL_map)
+PGD_PAGE_OFFSET = pgd_index(__PAGE_OFFSET_BASE)
+PGD_START_KERNEL = pgd_index(__START_KERNEL_map)
 L3_START_KERNEL = pud_index(__START_KERNEL_map)
 
 	.text
@@ -100,11 +101,14 @@ ENTRY(secondary_startup_64)
 	movq	$(init_top_pgt - __START_KERNEL_map), %rax
 1:
 
-	/* Enable PAE mode and PGE */
+	/* Enable PAE mode, PGE and LA57 */
 	movl	$(X86_CR4_PAE | X86_CR4_PGE), %ecx
+#ifdef CONFIG_X86_5LEVEL
+	orl	$X86_CR4_LA57, %ecx
+#endif
 	movq	%rcx, %cr4
 
-	/* Setup early boot stage 4 level pagetables. */
+	/* Setup early boot stage 4-/5-level pagetables. */
 	addq	phys_base(%rip), %rax
 	movq	%rax, %cr3
 
@@ -330,7 +334,11 @@ GLOBAL(name)
 	__INITDATA
 NEXT_PAGE(early_top_pgt)
 	.fill	511,8,0
+#ifdef CONFIG_X86_5LEVEL
+	.quad	level4_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
+#else
 	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
+#endif
 
 NEXT_PAGE(early_dynamic_pgts)
 	.fill	512*EARLY_DYNAMIC_PAGE_TABLES,8,0
@@ -343,9 +351,9 @@ NEXT_PAGE(init_top_pgt)
 #else
 NEXT_PAGE(init_top_pgt)
 	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
-	.org    init_top_pgt + L4_PAGE_OFFSET*8, 0
+	.org    init_top_pgt + PGD_PAGE_OFFSET*8, 0
 	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
-	.org    init_top_pgt + L4_START_KERNEL*8, 0
+	.org    init_top_pgt + PGD_START_KERNEL*8, 0
 	/* (2^48-(2*1024*1024*1024))/(2^39) = 511 */
 	.quad   level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
 
@@ -359,6 +367,12 @@ NEXT_PAGE(level2_ident_pgt)
 	PMDS(0, __PAGE_KERNEL_IDENT_LARGE_EXEC, PTRS_PER_PMD)
 #endif
 
+#ifdef CONFIG_X86_5LEVEL
+NEXT_PAGE(level4_kernel_pgt)
+	.fill	511,8,0
+	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
+#endif
+
 NEXT_PAGE(level3_kernel_pgt)
 	.fill	L3_START_KERNEL,8,0
 	/* (2^48-(2*1024*1024*1024)-((2^39)*511))/(2^30) = 510 */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
