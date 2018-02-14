Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 14B8A6B0012
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:25:55 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id l1so2195473pga.1
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:25:55 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id b9si1651107pff.42.2018.02.14.10.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 10:25:53 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 8/9] x86/mm: Replace compile-time checks for 5-level with runtime-time
Date: Wed, 14 Feb 2018 21:25:41 +0300
Message-Id: <20180214182542.69302-9-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180214182542.69302-1-kirill.shutemov@linux.intel.com>
References: <20180214182542.69302-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch converts the of CONFIG_X86_5LEVEL check to runtime checks for
p4d folding.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable_64.h | 23 ++++++++++-------------
 arch/x86/mm/dump_pagetables.c     |  4 +---
 arch/x86/mm/fault.c               |  4 ++--
 arch/x86/mm/ident_map.c           |  2 +-
 arch/x86/mm/init_64.c             | 30 ++++++++++++++++++------------
 arch/x86/mm/kasan_init_64.c       | 12 ++++++------
 arch/x86/mm/kaslr.c               |  6 +++---
 arch/x86/mm/tlb.c                 |  2 +-
 arch/x86/platform/efi/efi_64.c    |  2 +-
 arch/x86/power/hibernate_64.c     |  6 +++---
 10 files changed, 46 insertions(+), 45 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 81462e9a34f6..81dda8d1d0bd 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -217,29 +217,26 @@ static inline pgd_t pti_set_user_pgd(pgd_t *pgdp, pgd_t pgd)
 
 static inline void native_set_p4d(p4d_t *p4dp, p4d_t p4d)
 {
-#if defined(CONFIG_PAGE_TABLE_ISOLATION) && !defined(CONFIG_X86_5LEVEL)
-	p4dp->pgd = pti_set_user_pgd(&p4dp->pgd, p4d.pgd);
-#else
-	*p4dp = p4d;
-#endif
+	pgd_t pgd;
+
+	if (pgtable_l5_enabled || !IS_ENABLED(CONFIG_PAGE_TABLE_ISOLATION)) {
+		*p4dp = p4d;
+		return;
+	}
+
+	pgd = native_make_pgd(p4d_val(p4d));
+	pgd = pti_set_user_pgd((pgd_t *)p4dp, pgd);
+	*p4dp = native_make_p4d(pgd_val(pgd));
 }
 
 static inline void native_p4d_clear(p4d_t *p4d)
 {
-#ifdef CONFIG_X86_5LEVEL
 	native_set_p4d(p4d, native_make_p4d(0));
-#else
-	native_set_p4d(p4d, (p4d_t) { .pgd = native_make_pgd(0)});
-#endif
 }
 
 static inline void native_set_pgd(pgd_t *pgdp, pgd_t pgd)
 {
-#ifdef CONFIG_PAGE_TABLE_ISOLATION
 	*pgdp = pti_set_user_pgd(pgdp, pgd);
-#else
-	*pgdp = pgd;
-#endif
 }
 
 static inline void native_pgd_clear(pgd_t *pgd)
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index a32f0621d664..f25f02fcd62d 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -348,9 +348,7 @@ static inline bool kasan_page_table(struct seq_file *m, struct pg_state *st,
 				void *pt)
 {
 	if (__pa(pt) == __pa(kasan_zero_pmd) ||
-#ifdef CONFIG_X86_5LEVEL
-	    __pa(pt) == __pa(kasan_zero_p4d) ||
-#endif
+	    (pgtable_l5_enabled && __pa(pt) == __pa(kasan_zero_p4d)) ||
 	    __pa(pt) == __pa(kasan_zero_pud)) {
 		pgprotval_t prot = pte_flags(kasan_zero_pte[0]);
 		note_page(m, st, __pgprot(prot), 5);
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 800de815519c..321b78060e93 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -439,7 +439,7 @@ static noinline int vmalloc_fault(unsigned long address)
 	if (pgd_none(*pgd_ref))
 		return -1;
 
-	if (CONFIG_PGTABLE_LEVELS > 4) {
+	if (pgtable_l5_enabled) {
 		if (pgd_none(*pgd)) {
 			set_pgd(pgd, *pgd_ref);
 			arch_flush_lazy_mmu_mode();
@@ -454,7 +454,7 @@ static noinline int vmalloc_fault(unsigned long address)
 	if (p4d_none(*p4d_ref))
 		return -1;
 
-	if (p4d_none(*p4d) && CONFIG_PGTABLE_LEVELS == 4) {
+	if (p4d_none(*p4d) && !pgtable_l5_enabled) {
 		set_p4d(p4d, *p4d_ref);
 		arch_flush_lazy_mmu_mode();
 	} else {
diff --git a/arch/x86/mm/ident_map.c b/arch/x86/mm/ident_map.c
index ab33a32df2a8..9aa22be8331e 100644
--- a/arch/x86/mm/ident_map.c
+++ b/arch/x86/mm/ident_map.c
@@ -120,7 +120,7 @@ int kernel_ident_mapping_init(struct x86_mapping_info *info, pgd_t *pgd_page,
 		result = ident_p4d_init(info, p4d, addr, next);
 		if (result)
 			return result;
-		if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		if (pgtable_l5_enabled) {
 			set_pgd(pgd, __pgd(__pa(p4d) | info->kernpg_flag));
 		} else {
 			/*
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index c90cfb18405f..9bbc51ae54a6 100644
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
+static void sync_global_pgds_l5(unsigned long start, unsigned long end)
 {
 	unsigned long addr;
 
@@ -129,8 +124,8 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 		spin_unlock(&pgd_lock);
 	}
 }
-#else
-void sync_global_pgds(unsigned long start, unsigned long end)
+
+static void sync_global_pgds_l4(unsigned long start, unsigned long end)
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
+		sync_global_pgds_l5(start, end);
+	else
+		sync_global_pgds_l4(start, end);
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
@@ -1093,7 +1099,7 @@ remove_p4d_table(p4d_t *p4d_start, unsigned long addr, unsigned long end,
 		 * 5-level case we should free them. This code will have to change
 		 * to adapt for boot-time switching between 4 and 5 level page tables.
 		 */
-		if (CONFIG_PGTABLE_LEVELS == 5)
+		if (pgtable_l5_enabled)
 			free_pud_table(pud_base, p4d, altmap);
 	}
 
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 12ec90f62457..0df0dd13a71d 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -176,10 +176,10 @@ static void __init clear_pgds(unsigned long start,
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
@@ -191,7 +191,7 @@ static inline p4d_t *early_p4d_offset(pgd_t *pgd, unsigned long addr)
 {
 	unsigned long p4d;
 
-	if (!IS_ENABLED(CONFIG_X86_5LEVEL))
+	if (!pgtable_l5_enabled)
 		return (p4d_t *)pgd;
 
 	p4d = __pa_nodebug(pgd_val(*pgd)) & PTE_PFN_MASK;
@@ -272,7 +272,7 @@ void __init kasan_early_init(void)
 	for (i = 0; i < PTRS_PER_PUD; i++)
 		kasan_zero_pud[i] = __pud(pud_val);
 
-	for (i = 0; IS_ENABLED(CONFIG_X86_5LEVEL) && i < PTRS_PER_P4D; i++)
+	for (i = 0; pgtable_l5_enabled && i < PTRS_PER_P4D; i++)
 		kasan_zero_p4d[i] = __p4d(p4d_val);
 
 	kasan_map_early_shadow(early_top_pgt);
@@ -303,7 +303,7 @@ void __init kasan_init(void)
 	 * bunch of things like kernel code, modules, EFI mapping, etc.
 	 * We need to take extra steps to not overwrite them.
 	 */
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+	if (pgtable_l5_enabled) {
 		void *ptr;
 
 		ptr = (void *)pgd_page_vaddr(*pgd_offset_k(KASAN_SHADOW_END));
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index 641169d38184..615cc03ced84 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -124,7 +124,7 @@ void __init kernel_randomize_memory(void)
 		 */
 		entropy = remain_entropy / (ARRAY_SIZE(kaslr_regions) - i);
 		prandom_bytes_state(&rand_state, &rand, sizeof(rand));
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+		if (pgtable_l5_enabled)
 			entropy = (rand % (entropy + 1)) & P4D_MASK;
 		else
 			entropy = (rand % (entropy + 1)) & PUD_MASK;
@@ -136,7 +136,7 @@ void __init kernel_randomize_memory(void)
 		 * randomization alignment.
 		 */
 		vaddr += get_padding(&kaslr_regions[i]);
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+		if (pgtable_l5_enabled)
 			vaddr = round_up(vaddr + 1, P4D_SIZE);
 		else
 			vaddr = round_up(vaddr + 1, PUD_SIZE);
@@ -212,7 +212,7 @@ void __meminit init_trampoline(void)
 		return;
 	}
 
-	if (IS_ENABLED(CONFIG_X86_5LEVEL))
+	if (pgtable_l5_enabled)
 		init_trampoline_p4d();
 	else
 		init_trampoline_pud();
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index c7deb66c2a24..e055d1a06699 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -157,7 +157,7 @@ static void sync_current_stack_to_mm(struct mm_struct *mm)
 	unsigned long sp = current_stack_pointer;
 	pgd_t *pgd = pgd_offset(mm, sp);
 
-	if (CONFIG_PGTABLE_LEVELS > 4) {
+	if (pgtable_l5_enabled) {
 		if (unlikely(pgd_none(*pgd))) {
 			pgd_t *pgd_ref = pgd_offset_k(sp);
 
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index d52aaa7dc088..4845871a2006 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -227,7 +227,7 @@ int __init efi_alloc_page_tables(void)
 
 	pud = pud_alloc(&init_mm, p4d, EFI_VA_END);
 	if (!pud) {
-		if (CONFIG_PGTABLE_LEVELS > 4)
+		if (pgtable_l5_enabled)
 			free_page((unsigned long) pgd_page_vaddr(*pgd));
 		free_page((unsigned long)efi_pgd);
 		return -ENOMEM;
diff --git a/arch/x86/power/hibernate_64.c b/arch/x86/power/hibernate_64.c
index 0ef5e5204968..74a532989308 100644
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
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
