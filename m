Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 693D26B0272
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 06:56:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e199so140788pfh.3
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 03:56:20 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c79si4255963pfd.234.2017.09.18.03.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Sep 2017 03:56:18 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 15/19] x86/mm: Replace compile-time checks for 5-level with runtime-time
Date: Mon, 18 Sep 2017 13:55:49 +0300
Message-Id: <20170918105553.27914-16-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch converts the of CONFIG_X86_5LEVEL check to runtime checks for
p4d folding.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/fault.c            |  2 +-
 arch/x86/mm/ident_map.c        |  2 +-
 arch/x86/mm/init_64.c          | 30 ++++++++++++++++++------------
 arch/x86/mm/kasan_init_64.c    | 12 ++++++------
 arch/x86/mm/kaslr.c            |  6 +++---
 arch/x86/platform/efi/efi_64.c |  2 +-
 arch/x86/power/hibernate_64.c  |  6 +++---
 7 files changed, 33 insertions(+), 27 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index b836a7274e12..305924abdc0f 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -463,7 +463,7 @@ static noinline int vmalloc_fault(unsigned long address)
 	if (pgd_none(*pgd)) {
 		set_pgd(pgd, *pgd_ref);
 		arch_flush_lazy_mmu_mode();
-	} else if (CONFIG_PGTABLE_LEVELS > 4) {
+	} else if (pgtable_l5_enabled) {
 		/*
 		 * With folded p4d, pgd_none() is always false, so the pgd may
 		 * point to an empty page table entry and pgd_page_vaddr()
diff --git a/arch/x86/mm/ident_map.c b/arch/x86/mm/ident_map.c
index 31cea988fa36..b53d527a7749 100644
--- a/arch/x86/mm/ident_map.c
+++ b/arch/x86/mm/ident_map.c
@@ -119,7 +119,7 @@ int kernel_ident_mapping_init(struct x86_mapping_info *info, pgd_t *pgd_page,
 		result = ident_p4d_init(info, p4d, addr, next);
 		if (result)
 			return result;
-		if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		if (pgtable_l5_enabled) {
 			set_pgd(pgd, __pgd(__pa(p4d) | info->kernpg_flag));
 		} else {
 			/*
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 3f3289ba28f4..dcce8497bd79 100644
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
+	if (pgtable_l5_enabled)
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
+	if (!pgtable_l5_enabled)
 		return phys_pud_init((pud_t *) p4d_page, paddr, paddr_end, page_size_mask);
 
 	for (; i < PTRS_PER_P4D; i++, paddr = paddr_next) {
@@ -712,7 +718,7 @@ kernel_physical_mapping_init(unsigned long paddr_start,
 					   page_size_mask);
 
 		spin_lock(&init_mm.page_table_lock);
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+		if (pgtable_l5_enabled)
 			pgd_populate(&init_mm, pgd, p4d);
 		else
 			p4d_populate(&init_mm, p4d_offset(pgd, vaddr), (pud_t *) p4d);
@@ -1086,7 +1092,7 @@ remove_p4d_table(p4d_t *p4d_start, unsigned long addr, unsigned long end,
 		 * 5-level case we should free them. This code will have to change
 		 * to adapt for boot-time switching between 4 and 5 level page tables.
 		 */
-		if (CONFIG_PGTABLE_LEVELS == 5)
+		if (pgtable_l5_enabled)
 			free_pud_table(pud_base, p4d);
 	}
 
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index e1e2cca88567..9173ce1feba0 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -40,10 +40,10 @@ static void __init clear_pgds(unsigned long start,
 		 * With folded p4d, pgd_clear() is nop, use p4d_clear()
 		 * instead.
 		 */
-		if (CONFIG_PGTABLE_LEVELS < 5)
-			p4d_clear(p4d_offset(pgd, start));
-		else
+		if (pgtable_l5_enabled)
 			pgd_clear(pgd);
+		else
+			p4d_clear(p4d_offset(pgd, start));
 	}
 
 	pgd = pgd_offset_k(start);
@@ -55,7 +55,7 @@ static inline p4d_t *early_p4d_offset(pgd_t *pgd, unsigned long addr)
 {
 	unsigned long p4d;
 
-	if (!IS_ENABLED(CONFIG_X86_5LEVEL))
+	if (pgtable_l5_enabled)
 		return (p4d_t *)pgd;
 
 	p4d = __pa_nodebug(pgd_val(*pgd)) & PTE_PFN_MASK;
@@ -135,7 +135,7 @@ void __init kasan_early_init(void)
 	for (i = 0; i < PTRS_PER_PUD; i++)
 		kasan_zero_pud[i] = __pud(pud_val);
 
-	for (i = 0; IS_ENABLED(CONFIG_X86_5LEVEL) && i < PTRS_PER_P4D; i++)
+	for (i = 0; pgtable_l5_enabled && i < PTRS_PER_P4D; i++)
 		kasan_zero_p4d[i] = __p4d(p4d_val);
 
 	kasan_map_early_shadow(early_top_pgt);
@@ -152,7 +152,7 @@ void __init kasan_init(void)
 
 	memcpy(early_top_pgt, init_top_pgt, sizeof(early_top_pgt));
 
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+	if (pgtable_l5_enabled) {
 		void *ptr;
 
 		ptr = (void *)pgd_page_vaddr(*pgd_offset_k(KASAN_SHADOW_END));
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index e29eb50ea2a9..ff922e632bc8 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -139,7 +139,7 @@ void __init kernel_randomize_memory(void)
 		 */
 		entropy = remain_entropy / (ARRAY_SIZE(kaslr_regions) - i);
 		prandom_bytes_state(&rand_state, &rand, sizeof(rand));
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+		if (pgtable_l5_enabled)
 			entropy = (rand % (entropy + 1)) & P4D_MASK;
 		else
 			entropy = (rand % (entropy + 1)) & PUD_MASK;
@@ -151,7 +151,7 @@ void __init kernel_randomize_memory(void)
 		 * randomization alignment.
 		 */
 		vaddr += get_padding(&kaslr_regions[i]);
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+		if (pgtable_l5_enabled)
 			vaddr = round_up(vaddr + 1, P4D_SIZE);
 		else
 			vaddr = round_up(vaddr + 1, PUD_SIZE);
@@ -227,7 +227,7 @@ void __meminit init_trampoline(void)
 		return;
 	}
 
-	if (IS_ENABLED(CONFIG_X86_5LEVEL))
+	if (pgtable_l5_enabled)
 		init_trampoline_p4d();
 	else
 		init_trampoline_pud();
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index 970a0f5f787d..127d00edc117 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -219,7 +219,7 @@ int __init efi_alloc_page_tables(void)
 
 	pud = pud_alloc(&init_mm, p4d, EFI_VA_END);
 	if (!pud) {
-		if (CONFIG_PGTABLE_LEVELS > 4)
+		if (pgtable_l5_enabled)
 			free_page((unsigned long) pgd_page_vaddr(*pgd));
 		free_page((unsigned long)efi_pgd);
 		return -ENOMEM;
diff --git a/arch/x86/power/hibernate_64.c b/arch/x86/power/hibernate_64.c
index f910c514438f..c90b575938cc 100644
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
+	if (pgtable_l5_enabled) {
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
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
