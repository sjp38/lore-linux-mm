Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BDEF56B039F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:54:35 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a186so33639586pge.7
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:54:35 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 77si846787pfn.385.2017.08.08.05.54.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 05:54:34 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 11/14] x86/mm: Replace compile-time checks for 5-level with runtime-time
Date: Tue,  8 Aug 2017 15:54:12 +0300
Message-Id: <20170808125415.78842-12-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch converts the of CONFIG_X86_5LEVEL check to runtime checks for
p4d folding.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/fault.c            |  2 +-
 arch/x86/mm/ident_map.c        |  2 +-
 arch/x86/mm/init_64.c          | 30 ++++++++++++++++++------------
 arch/x86/mm/kasan_init_64.c    |  8 ++++----
 arch/x86/mm/kaslr.c            |  6 +++---
 arch/x86/platform/efi/efi_64.c |  2 +-
 arch/x86/power/hibernate_64.c  |  6 +++---
 7 files changed, 31 insertions(+), 25 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 2a1fa10c6a98..d3d8f10f0c10 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -459,7 +459,7 @@ static noinline int vmalloc_fault(unsigned long address)
 	if (pgd_none(*pgd)) {
 		set_pgd(pgd, *pgd_ref);
 		arch_flush_lazy_mmu_mode();
-	} else if (CONFIG_PGTABLE_LEVELS > 4) {
+	} else if (!p4d_folded) {
 		/*
 		 * With folded p4d, pgd_none() is always false, so the pgd may
 		 * point to an empty page table entry and pgd_page_vaddr()
diff --git a/arch/x86/mm/ident_map.c b/arch/x86/mm/ident_map.c
index 31cea988fa36..1ab88f1bec15 100644
--- a/arch/x86/mm/ident_map.c
+++ b/arch/x86/mm/ident_map.c
@@ -119,7 +119,7 @@ int kernel_ident_mapping_init(struct x86_mapping_info *info, pgd_t *pgd_page,
 		result = ident_p4d_init(info, p4d, addr, next);
 		if (result)
 			return result;
-		if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		if (!p4d_folded) {
 			set_pgd(pgd, __pgd(__pa(p4d) | info->kernpg_flag));
 		} else {
 			/*
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 649b8df485ad..6b97f6c1bf77 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -88,12 +88,7 @@ static int __init nonx32_setup(char *str)
 }
 __setup("noexec32=", nonx32_setup);
 
-/*
- * When memory was added make sure all the processes MM have
- * suitable PGD entries in the local PGD level page.
- */
-#ifdef CONFIG_X86_5LEVEL
-void sync_global_pgds(unsigned long start, unsigned long end)
+static void sync_global_pgds_57(unsigned long start, unsigned long end)
 {
 	unsigned long addr;
 
@@ -129,8 +124,8 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 		spin_unlock(&pgd_lock);
 	}
 }
-#else
-void sync_global_pgds(unsigned long start, unsigned long end)
+
+static void sync_global_pgds_48(unsigned long start, unsigned long end)
 {
 	unsigned long addr;
 
@@ -173,7 +168,18 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 		spin_unlock(&pgd_lock);
 	}
 }
-#endif
+
+/*
+ * When memory was added make sure all the processes MM have
+ * suitable PGD entries in the local PGD level page.
+ */
+void sync_global_pgds(unsigned long start, unsigned long end)
+{
+	if (!p4d_folded)
+		sync_global_pgds_57(start, end);
+	else
+		sync_global_pgds_48(start, end);
+}
 
 /*
  * NOTE: This function is marked __ref because it calls __init function
@@ -632,7 +638,7 @@ phys_p4d_init(p4d_t *p4d_page, unsigned long paddr, unsigned long paddr_end,
 	unsigned long vaddr = (unsigned long)__va(paddr);
 	int i = p4d_index(vaddr);
 
-	if (!IS_ENABLED(CONFIG_X86_5LEVEL))
+	if (p4d_folded)
 		return phys_pud_init((pud_t *) p4d_page, paddr, paddr_end, page_size_mask);
 
 	for (; i < PTRS_PER_P4D; i++, paddr = paddr_next) {
@@ -712,7 +718,7 @@ kernel_physical_mapping_init(unsigned long paddr_start,
 					   page_size_mask);
 
 		spin_lock(&init_mm.page_table_lock);
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+		if (!p4d_folded)
 			pgd_populate(&init_mm, pgd, p4d);
 		else
 			p4d_populate(&init_mm, p4d_offset(pgd, vaddr), (pud_t *) p4d);
@@ -1078,7 +1084,7 @@ remove_p4d_table(p4d_t *p4d_start, unsigned long addr, unsigned long end,
 		 * 5-level case we should free them. This code will have to change
 		 * to adapt for boot-time switching between 4 and 5 level page tables.
 		 */
-		if (CONFIG_PGTABLE_LEVELS == 5)
+		if (!p4d_folded)
 			free_pud_table(pud_base, p4d);
 	}
 
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index e1e2cca88567..17256253a887 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -40,7 +40,7 @@ static void __init clear_pgds(unsigned long start,
 		 * With folded p4d, pgd_clear() is nop, use p4d_clear()
 		 * instead.
 		 */
-		if (CONFIG_PGTABLE_LEVELS < 5)
+		if (p4d_folded)
 			p4d_clear(p4d_offset(pgd, start));
 		else
 			pgd_clear(pgd);
@@ -55,7 +55,7 @@ static inline p4d_t *early_p4d_offset(pgd_t *pgd, unsigned long addr)
 {
 	unsigned long p4d;
 
-	if (!IS_ENABLED(CONFIG_X86_5LEVEL))
+	if (p4d_folded)
 		return (p4d_t *)pgd;
 
 	p4d = __pa_nodebug(pgd_val(*pgd)) & PTE_PFN_MASK;
@@ -135,7 +135,7 @@ void __init kasan_early_init(void)
 	for (i = 0; i < PTRS_PER_PUD; i++)
 		kasan_zero_pud[i] = __pud(pud_val);
 
-	for (i = 0; IS_ENABLED(CONFIG_X86_5LEVEL) && i < PTRS_PER_P4D; i++)
+	for (i = 0; !p4d_folded && i < PTRS_PER_P4D; i++)
 		kasan_zero_p4d[i] = __p4d(p4d_val);
 
 	kasan_map_early_shadow(early_top_pgt);
@@ -152,7 +152,7 @@ void __init kasan_init(void)
 
 	memcpy(early_top_pgt, init_top_pgt, sizeof(early_top_pgt));
 
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+	if (!p4d_folded) {
 		void *ptr;
 
 		ptr = (void *)pgd_page_vaddr(*pgd_offset_k(KASAN_SHADOW_END));
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index 2f6ba5c72905..b70f86a2ce6a 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -139,7 +139,7 @@ void __init kernel_randomize_memory(void)
 		 */
 		entropy = remain_entropy / (ARRAY_SIZE(kaslr_regions) - i);
 		prandom_bytes_state(&rand_state, &rand, sizeof(rand));
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+		if (!p4d_folded)
 			entropy = (rand % (entropy + 1)) & P4D_MASK;
 		else
 			entropy = (rand % (entropy + 1)) & PUD_MASK;
@@ -151,7 +151,7 @@ void __init kernel_randomize_memory(void)
 		 * randomization alignment.
 		 */
 		vaddr += get_padding(&kaslr_regions[i]);
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+		if (!p4d_folded)
 			vaddr = round_up(vaddr + 1, P4D_SIZE);
 		else
 			vaddr = round_up(vaddr + 1, PUD_SIZE);
@@ -227,7 +227,7 @@ void __meminit init_trampoline(void)
 		return;
 	}
 
-	if (IS_ENABLED(CONFIG_X86_5LEVEL))
+	if (!p4d_folded)
 		init_trampoline_p4d();
 	else
 		init_trampoline_pud();
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index 970a0f5f787d..e8c3fc62ef03 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -219,7 +219,7 @@ int __init efi_alloc_page_tables(void)
 
 	pud = pud_alloc(&init_mm, p4d, EFI_VA_END);
 	if (!pud) {
-		if (CONFIG_PGTABLE_LEVELS > 4)
+		if (!p4d_folded)
 			free_page((unsigned long) pgd_page_vaddr(*pgd));
 		free_page((unsigned long)efi_pgd);
 		return -ENOMEM;
diff --git a/arch/x86/power/hibernate_64.c b/arch/x86/power/hibernate_64.c
index f2598d81cd55..9b9bc2ef4321 100644
--- a/arch/x86/power/hibernate_64.c
+++ b/arch/x86/power/hibernate_64.c
@@ -50,7 +50,7 @@ static int set_up_temporary_text_mapping(pgd_t *pgd)
 {
 	pmd_t *pmd;
 	pud_t *pud;
-	p4d_t *p4d;
+	p4d_t *p4d = NULL;
 
 	/*
 	 * The new mapping only has to cover the page containing the image
@@ -66,7 +66,7 @@ static int set_up_temporary_text_mapping(pgd_t *pgd)
 	 * tables used by the image kernel.
 	 */
 
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+	if (!p4d_folded) {
 		p4d = (p4d_t *)get_safe_page(GFP_ATOMIC);
 		if (!p4d)
 			return -ENOMEM;
@@ -84,7 +84,7 @@ static int set_up_temporary_text_mapping(pgd_t *pgd)
 		__pmd((jump_address_phys & PMD_MASK) | __PAGE_KERNEL_LARGE_EXEC));
 	set_pud(pud + pud_index(restore_jump_address),
 		__pud(__pa(pmd) | _KERNPG_TABLE));
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+	if (p4d) {
 		set_p4d(p4d + p4d_index(restore_jump_address), __p4d(__pa(pud) | _KERNPG_TABLE));
 		set_pgd(pgd + pgd_index(restore_jump_address), __pgd(__pa(p4d) | _KERNPG_TABLE));
 	} else {
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
