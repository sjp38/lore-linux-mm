Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0506B000A
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:25:54 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id n11so11334265plp.13
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:25:54 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id l1si140806pgc.548.2018.02.14.10.25.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 10:25:52 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 6/9] x86/mm: Make early boot code support boot-time switching of paging modes
Date: Wed, 14 Feb 2018 21:25:39 +0300
Message-Id: <20180214182542.69302-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180214182542.69302-1-kirill.shutemov@linux.intel.com>
References: <20180214182542.69302-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Early boot code should be able to initialize page tables for both 4- and
5-level paging modes.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/head64.c  | 33 ++++++++++++++++++++++-----------
 arch/x86/kernel/head_64.S | 10 ++++------
 2 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 795e762f3c66..8161e719a20f 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -75,13 +75,13 @@ static unsigned int __head *fixup_int(void *ptr, unsigned long physaddr)
 	return fixup_pointer(ptr, physaddr);
 }
 
-static void __head check_la57_support(unsigned long physaddr)
+static bool __head check_la57_support(unsigned long physaddr)
 {
 	if (native_cpuid_eax(0) < 7)
-		return;
+		return false;
 
 	if (!(native_cpuid_ecx(7) & (1 << (X86_FEATURE_LA57 & 31))))
-		return;
+		return false;
 
 	*fixup_int(&pgtable_l5_enabled, physaddr) = 1;
 	*fixup_int(&pgdir_shift, physaddr) = 48;
@@ -89,24 +89,30 @@ static void __head check_la57_support(unsigned long physaddr)
 	*fixup_long(&page_offset_base, physaddr) = __PAGE_OFFSET_BASE_L5;
 	*fixup_long(&vmalloc_base, physaddr) = __VMALLOC_BASE_L5;
 	*fixup_long(&vmemmap_base, physaddr) = __VMEMMAP_BASE_L5;
+
+	return true;
 }
 #else
-static void __head check_la57_support(unsigned long physaddr) {}
+static bool __head check_la57_support(unsigned long physaddr)
+{
+	return false;
+}
 #endif
 
 unsigned long __head __startup_64(unsigned long physaddr,
 				  struct boot_params *bp)
 {
-	unsigned long load_delta;
+	unsigned long load_delta, *p;
 	unsigned long pgtable_flags;
 	pgdval_t *pgd;
 	p4dval_t *p4d;
 	pudval_t *pud;
 	pmdval_t *pmd, pmd_entry;
+	bool la57;
 	int i;
 	unsigned int *next_pgt_ptr;
 
-	check_la57_support(physaddr);
+	la57 = check_la57_support(physaddr);
 
 	/* Is the address too large? */
 	if (physaddr >> MAX_PHYSMEM_BITS)
@@ -131,9 +137,14 @@ unsigned long __head __startup_64(unsigned long physaddr,
 	/* Fixup the physical addresses in the page table */
 
 	pgd = fixup_pointer(&early_top_pgt, physaddr);
-	pgd[pgd_index(__START_KERNEL_map)] += load_delta;
-
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+	p = pgd + pgd_index(__START_KERNEL_map);
+	if (la57)
+		*p = (unsigned long)level4_kernel_pgt;
+	else
+		*p = (unsigned long)level3_kernel_pgt;
+	*p += _PAGE_TABLE_NOENC - __START_KERNEL_map + load_delta;
+
+	if (la57) {
 		p4d = fixup_pointer(&level4_kernel_pgt, physaddr);
 		p4d[511] += load_delta;
 	}
@@ -158,7 +169,7 @@ unsigned long __head __startup_64(unsigned long physaddr,
 
 	pgtable_flags = _KERNPG_TABLE_NOENC + sme_get_me_mask();
 
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+	if (la57) {
 		p4d = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
 
 		i = (physaddr >> PGDIR_SHIFT) % PTRS_PER_PGD;
@@ -255,7 +266,7 @@ int __init __early_make_pgtable(unsigned long address, pmdval_t pmd)
 	 * critical -- __PAGE_OFFSET would point us back into the dynamic
 	 * range and we might end up looping forever...
 	 */
-	if (!IS_ENABLED(CONFIG_X86_5LEVEL))
+	if (!pgtable_l5_enabled)
 		p4d_p = pgd_p;
 	else if (pgd)
 		p4d_p = (p4dval_t *)((pgd & PTE_PFN_MASK) + __START_KERNEL_map - phys_base);
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index d3f8b43d541a..145d7b95ae29 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -124,7 +124,10 @@ ENTRY(secondary_startup_64)
 	/* Enable PAE mode, PGE and LA57 */
 	movl	$(X86_CR4_PAE | X86_CR4_PGE), %ecx
 #ifdef CONFIG_X86_5LEVEL
+	testl	$1, pgtable_l5_enabled(%rip)
+	jz	1f
 	orl	$X86_CR4_LA57, %ecx
+1:
 #endif
 	movq	%rcx, %cr4
 
@@ -372,12 +375,7 @@ GLOBAL(name)
 
 	__INITDATA
 NEXT_PGD_PAGE(early_top_pgt)
-	.fill	511,8,0
-#ifdef CONFIG_X86_5LEVEL
-	.quad	level4_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
-#else
-	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
-#endif
+	.fill	512,8,0
 	.fill	PTI_USER_PGD_FILL,8,0
 
 NEXT_PAGE(early_dynamic_pgts)
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
