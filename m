Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EBFDC6B0428
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 10:01:48 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 68so36776469pgj.23
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 07:01:48 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s3si1947892plj.263.2017.04.06.07.01.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 07:01:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/8] x86/boot/64: Rewrite startup_64 in C
Date: Thu,  6 Apr 2017 17:00:59 +0300
Message-Id: <20170406140106.78087-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170406140106.78087-1-kirill.shutemov@linux.intel.com>
References: <20170406140106.78087-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch write most of startup_64 logic in C.

This is preparation for 5-level paging enabling.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/head64.c  | 81 ++++++++++++++++++++++++++++++++++++++++-
 arch/x86/kernel/head_64.S | 93 +----------------------------------------------
 2 files changed, 81 insertions(+), 93 deletions(-)

diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 43b7002f44fb..dbb5b29bf019 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -35,9 +35,88 @@
  */
 extern pgd_t early_level4_pgt[PTRS_PER_PGD];
 extern pmd_t early_dynamic_pgts[EARLY_DYNAMIC_PAGE_TABLES][PTRS_PER_PMD];
-static unsigned int __initdata next_early_pgt = 2;
+static unsigned int __initdata next_early_pgt;
 pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
 
+static void __init *fixup_pointer(void *ptr, unsigned long physaddr)
+{
+	return ptr - (void *)_text + (void *)physaddr;
+}
+
+void __init __startup_64(unsigned long physaddr)
+{
+	unsigned long load_delta, *p;
+	pgdval_t *pgd;
+	pudval_t *pud;
+	pmdval_t *pmd, pmd_entry;
+	int i;
+
+	/* Is the address too large? */
+	if (physaddr >> MAX_PHYSMEM_BITS)
+		for (;;);
+
+	/*
+	 * Compute the delta between the address I am compiled to run at
+	 * and the address I am actually running at.
+	 */
+	load_delta = physaddr - (unsigned long)(_text - __START_KERNEL_map);
+
+	/* Is the address not 2M aligned? */
+	if (load_delta & ~PMD_PAGE_MASK)
+		for (;;);
+
+	/* Fixup the physical addresses in the page table */
+
+	pgd = fixup_pointer(&early_level4_pgt, physaddr);
+	pgd[pgd_index(__START_KERNEL_map)] += load_delta;
+
+	pud = fixup_pointer(&level3_kernel_pgt, physaddr);
+	pud[510] += load_delta;
+	pud[511] += load_delta;
+
+	pmd = fixup_pointer(level2_fixmap_pgt, physaddr);
+	pmd[506] += load_delta;
+
+	/*
+	 * Set up the identity mapping for the switchover.  These
+	 * entries should *NOT* have the global bit set!  This also
+	 * creates a bunch of nonsense entries but that is fine --
+	 * it avoids problems around wraparound.
+	 */
+
+	pud = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
+	pmd = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
+
+	pgd[0] = (pgdval_t)pud + _KERNPG_TABLE;
+	pgd[1] = (pgdval_t)pud + _KERNPG_TABLE;
+
+	pud[0] = (pudval_t)pmd + _KERNPG_TABLE;
+	pud[1] = (pudval_t)pmd + _KERNPG_TABLE;
+
+	pmd_entry = __PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL;
+	pmd_entry +=  physaddr;
+
+	for (i = 0; i < DIV_ROUND_UP(_end - _text, PMD_SIZE); i++)
+		pmd[i + (physaddr >> PMD_SHIFT)] = pmd_entry + i * PMD_SIZE;
+
+	/*
+	 * Fixup the kernel text+data virtual addresses. Note that
+	 * we might write invalid pmds, when the kernel is relocated
+	 * cleanup_highmap() fixes this up along with the mappings
+	 * beyond _end.
+	 */
+
+	pmd = fixup_pointer(level2_kernel_pgt, physaddr);
+	for (i = 0; i < PTRS_PER_PMD; i++) {
+		if (pmd[i] & _PAGE_PRESENT)
+			pmd[i] += load_delta;
+	}
+
+	/* Fixup phys_base */
+	p = fixup_pointer(&phys_base, physaddr);
+	*p += load_delta;
+}
+
 /* Wipe all early page tables except for the kernel symbol map */
 static void __init reset_early_page_tables(void)
 {
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index ac9d327d2e42..9656c5951b98 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -72,100 +72,9 @@ startup_64:
 	/* Sanitize CPU configuration */
 	call verify_cpu
 
-	/*
-	 * Compute the delta between the address I am compiled to run at and the
-	 * address I am actually running at.
-	 */
-	leaq	_text(%rip), %rbp
-	subq	$_text - __START_KERNEL_map, %rbp
-
-	/* Is the address not 2M aligned? */
-	testl	$~PMD_PAGE_MASK, %ebp
-	jnz	bad_address
-
-	/*
-	 * Is the address too large?
-	 */
-	leaq	_text(%rip), %rax
-	shrq	$MAX_PHYSMEM_BITS, %rax
-	jnz	bad_address
-
-	/*
-	 * Fixup the physical addresses in the page table
-	 */
-	addq	%rbp, early_level4_pgt + (L4_START_KERNEL*8)(%rip)
-
-	addq	%rbp, level3_kernel_pgt + (510*8)(%rip)
-	addq	%rbp, level3_kernel_pgt + (511*8)(%rip)
-
-	addq	%rbp, level2_fixmap_pgt + (506*8)(%rip)
-
-	/*
-	 * Set up the identity mapping for the switchover.  These
-	 * entries should *NOT* have the global bit set!  This also
-	 * creates a bunch of nonsense entries but that is fine --
-	 * it avoids problems around wraparound.
-	 */
 	leaq	_text(%rip), %rdi
-	leaq	early_level4_pgt(%rip), %rbx
-
-	movq	%rdi, %rax
-	shrq	$PGDIR_SHIFT, %rax
-
-	leaq	(PAGE_SIZE + _KERNPG_TABLE)(%rbx), %rdx
-	movq	%rdx, 0(%rbx,%rax,8)
-	movq	%rdx, 8(%rbx,%rax,8)
-
-	addq	$PAGE_SIZE, %rdx
-	movq	%rdi, %rax
-	shrq	$PUD_SHIFT, %rax
-	andl	$(PTRS_PER_PUD-1), %eax
-	movq	%rdx, PAGE_SIZE(%rbx,%rax,8)
-	incl	%eax
-	andl	$(PTRS_PER_PUD-1), %eax
-	movq	%rdx, PAGE_SIZE(%rbx,%rax,8)
-
-	addq	$PAGE_SIZE * 2, %rbx
-	movq	%rdi, %rax
-	shrq	$PMD_SHIFT, %rdi
-	addq	$(__PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL), %rax
-	leaq	(_end - 1)(%rip), %rcx
-	shrq	$PMD_SHIFT, %rcx
-	subq	%rdi, %rcx
-	incl	%ecx
+	call	__startup_64
 
-1:
-	andq	$(PTRS_PER_PMD - 1), %rdi
-	movq	%rax, (%rbx,%rdi,8)
-	incq	%rdi
-	addq	$PMD_SIZE, %rax
-	decl	%ecx
-	jnz	1b
-
-	test %rbp, %rbp
-	jz .Lskip_fixup
-
-	/*
-	 * Fixup the kernel text+data virtual addresses. Note that
-	 * we might write invalid pmds, when the kernel is relocated
-	 * cleanup_highmap() fixes this up along with the mappings
-	 * beyond _end.
-	 */
-	leaq	level2_kernel_pgt(%rip), %rdi
-	leaq	PAGE_SIZE(%rdi), %r8
-	/* See if it is a valid page table entry */
-1:	testb	$_PAGE_PRESENT, 0(%rdi)
-	jz	2f
-	addq	%rbp, 0(%rdi)
-	/* Go to the next page */
-2:	addq	$8, %rdi
-	cmp	%r8, %rdi
-	jne	1b
-
-	/* Fixup phys_base */
-	addq	%rbp, phys_base(%rip)
-
-.Lskip_fixup:
 	movq	$(early_level4_pgt - __START_KERNEL_map), %rax
 	jmp 1f
 ENTRY(secondary_startup_64)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
