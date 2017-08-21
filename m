Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 17A28280405
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 11:29:35 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q3so72844152pgr.3
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 08:29:35 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t76si7342978pgc.539.2017.08.21.08.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 08:29:33 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 13/19] x86/mm: Make early boot code support boot-time switching of paging modes
Date: Mon, 21 Aug 2017 18:29:10 +0300
Message-Id: <20170821152916.40124-14-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
References: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dmitry Safonov <dsafonov@virtuozzo.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Early boot code, that setup page table should be able to initialize page
tables for both 4- and 5-level paging modes.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/head64.c  | 33 +++++++++++++++++++++------------
 arch/x86/kernel/head_64.S | 10 ++++------
 2 files changed, 25 insertions(+), 18 deletions(-)

diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index f013b0732c96..8a44b3d06261 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -74,13 +74,13 @@ static unsigned int __head *fixup_int(void *ptr, unsigned long physaddr)
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
@@ -89,24 +89,28 @@ static void __head check_la57_support(unsigned long physaddr)
 	*fixup_long(&vmalloc_base, physaddr) = __VMALLOC_BASE57;
 	*fixup_long(&vmemmap_base, physaddr) = __VMEMMAP_BASE57;
 
-	return;
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
 
-	check_la57_support(physaddr);
+	la57 = check_la57_support(physaddr);
 
 	/* Is the address too large? */
 	if (physaddr >> MAX_PHYSMEM_BITS)
@@ -131,9 +135,14 @@ unsigned long __head __startup_64(unsigned long physaddr,
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
@@ -156,7 +165,7 @@ unsigned long __head __startup_64(unsigned long physaddr,
 	pmd = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
 	pgtable_flags = _KERNPG_TABLE_NOENC + sme_get_me_mask();
 
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+	if (la57) {
 		p4d = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
 
 		i = (physaddr >> PGDIR_SHIFT) % PTRS_PER_PGD;
@@ -253,7 +262,7 @@ int __init __early_make_pgtable(unsigned long address, pmdval_t pmd)
 	 * critical -- __PAGE_OFFSET would point us back into the dynamic
 	 * range and we might end up looping forever...
 	 */
-	if (!IS_ENABLED(CONFIG_X86_5LEVEL))
+	if (!pgtable_l5_enabled)
 		p4d_p = pgd_p;
 	else if (pgd)
 		p4d_p = (p4dval_t *)((pgd & PTE_PFN_MASK) + __START_KERNEL_map - phys_base);
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index a8409cd23b35..49f8bb43d107 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -121,7 +121,10 @@ ENTRY(secondary_startup_64)
 	/* Enable PAE mode, PGE and LA57 */
 	movl	$(X86_CR4_PAE | X86_CR4_PGE), %ecx
 #ifdef CONFIG_X86_5LEVEL
+	testl	$1, pgtable_l5_enabled(%rip)
+	jz	1f
 	orl	$X86_CR4_LA57, %ecx
+1:
 #endif
 	movq	%rcx, %cr4
 
@@ -350,12 +353,7 @@ GLOBAL(name)
 
 	__INITDATA
 NEXT_PAGE(early_top_pgt)
-	.fill	511,8,0
-#ifdef CONFIG_X86_5LEVEL
-	.quad	level4_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
-#else
-	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
-#endif
+	.fill	512,8,0
 
 NEXT_PAGE(early_dynamic_pgts)
 	.fill	512*EARLY_DYNAMIC_PAGE_TABLES,8,0
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
