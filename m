Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 670C76B4941
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:56:04 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id e17so18224358wrw.13
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:56:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i18sor3125296wrw.50.2018.11.27.08.56.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 08:56:02 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v12 07/25] kasan: rename kasan_zero_page to kasan_early_shadow_page
Date: Tue, 27 Nov 2018 17:55:25 +0100
Message-Id: <1aa5a8e562380e0bfb1d58c8ec3130436cff8b47.1543337629.git.andreyknvl@google.com>
In-Reply-To: <cover.1543337629.git.andreyknvl@google.com>
References: <cover.1543337629.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

With tag based KASAN mode the early shadow value is 0xff and not 0x00,
so this patch renames kasan_zero_(page|pte|pmd|pud|p4d) to
kasan_early_shadow_(page|pte|pmd|pud|p4d) to avoid confusion.

Suggested-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/mm/kasan_init.c     | 43 ++++++++++++---------
 arch/s390/mm/dump_pagetables.c | 17 +++++----
 arch/s390/mm/kasan_init.c      | 33 +++++++++-------
 arch/x86/mm/dump_pagetables.c  | 11 +++---
 arch/x86/mm/kasan_init_64.c    | 55 +++++++++++++-------------
 arch/xtensa/mm/kasan_init.c    | 18 +++++----
 include/linux/kasan.h          | 12 +++---
 mm/kasan/init.c                | 70 +++++++++++++++++++---------------
 8 files changed, 145 insertions(+), 114 deletions(-)

diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 63527e585aac..4ebc19422931 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -47,8 +47,9 @@ static pte_t *__init kasan_pte_offset(pmd_t *pmdp, unsigned long addr, int node,
 				      bool early)
 {
 	if (pmd_none(READ_ONCE(*pmdp))) {
-		phys_addr_t pte_phys = early ? __pa_symbol(kasan_zero_pte)
-					     : kasan_alloc_zeroed_page(node);
+		phys_addr_t pte_phys = early ?
+				__pa_symbol(kasan_early_shadow_pte)
+					: kasan_alloc_zeroed_page(node);
 		__pmd_populate(pmdp, pte_phys, PMD_TYPE_TABLE);
 	}
 
@@ -60,8 +61,9 @@ static pmd_t *__init kasan_pmd_offset(pud_t *pudp, unsigned long addr, int node,
 				      bool early)
 {
 	if (pud_none(READ_ONCE(*pudp))) {
-		phys_addr_t pmd_phys = early ? __pa_symbol(kasan_zero_pmd)
-					     : kasan_alloc_zeroed_page(node);
+		phys_addr_t pmd_phys = early ?
+				__pa_symbol(kasan_early_shadow_pmd)
+					: kasan_alloc_zeroed_page(node);
 		__pud_populate(pudp, pmd_phys, PMD_TYPE_TABLE);
 	}
 
@@ -72,8 +74,9 @@ static pud_t *__init kasan_pud_offset(pgd_t *pgdp, unsigned long addr, int node,
 				      bool early)
 {
 	if (pgd_none(READ_ONCE(*pgdp))) {
-		phys_addr_t pud_phys = early ? __pa_symbol(kasan_zero_pud)
-					     : kasan_alloc_zeroed_page(node);
+		phys_addr_t pud_phys = early ?
+				__pa_symbol(kasan_early_shadow_pud)
+					: kasan_alloc_zeroed_page(node);
 		__pgd_populate(pgdp, pud_phys, PMD_TYPE_TABLE);
 	}
 
@@ -87,8 +90,9 @@ static void __init kasan_pte_populate(pmd_t *pmdp, unsigned long addr,
 	pte_t *ptep = kasan_pte_offset(pmdp, addr, node, early);
 
 	do {
-		phys_addr_t page_phys = early ? __pa_symbol(kasan_zero_page)
-					      : kasan_alloc_zeroed_page(node);
+		phys_addr_t page_phys = early ?
+				__pa_symbol(kasan_early_shadow_page)
+					: kasan_alloc_zeroed_page(node);
 		next = addr + PAGE_SIZE;
 		set_pte(ptep, pfn_pte(__phys_to_pfn(page_phys), PAGE_KERNEL));
 	} while (ptep++, addr = next, addr != end && pte_none(READ_ONCE(*ptep)));
@@ -205,14 +209,14 @@ void __init kasan_init(void)
 	kasan_map_populate(kimg_shadow_start, kimg_shadow_end,
 			   early_pfn_to_nid(virt_to_pfn(lm_alias(_text))));
 
-	kasan_populate_zero_shadow((void *)KASAN_SHADOW_START,
-				   (void *)mod_shadow_start);
-	kasan_populate_zero_shadow((void *)kimg_shadow_end,
-				   kasan_mem_to_shadow((void *)PAGE_OFFSET));
+	kasan_populate_early_shadow((void *)KASAN_SHADOW_START,
+				    (void *)mod_shadow_start);
+	kasan_populate_early_shadow((void *)kimg_shadow_end,
+				    kasan_mem_to_shadow((void *)PAGE_OFFSET));
 
 	if (kimg_shadow_start > mod_shadow_end)
-		kasan_populate_zero_shadow((void *)mod_shadow_end,
-					   (void *)kimg_shadow_start);
+		kasan_populate_early_shadow((void *)mod_shadow_end,
+					    (void *)kimg_shadow_start);
 
 	for_each_memblock(memory, reg) {
 		void *start = (void *)__phys_to_virt(reg->base);
@@ -227,14 +231,15 @@ void __init kasan_init(void)
 	}
 
 	/*
-	 * KAsan may reuse the contents of kasan_zero_pte directly, so we
-	 * should make sure that it maps the zero page read-only.
+	 * KAsan may reuse the contents of kasan_early_shadow_pte directly,
+	 * so we should make sure that it maps the zero page read-only.
 	 */
 	for (i = 0; i < PTRS_PER_PTE; i++)
-		set_pte(&kasan_zero_pte[i],
-			pfn_pte(sym_to_pfn(kasan_zero_page), PAGE_KERNEL_RO));
+		set_pte(&kasan_early_shadow_pte[i],
+			pfn_pte(sym_to_pfn(kasan_early_shadow_page),
+				PAGE_KERNEL_RO));
 
-	memset(kasan_zero_page, 0, PAGE_SIZE);
+	memset(kasan_early_shadow_page, 0, PAGE_SIZE);
 	cpu_replace_ttbr1(lm_alias(swapper_pg_dir));
 
 	/* At this point kasan is fully initialized. Enable error messages */
diff --git a/arch/s390/mm/dump_pagetables.c b/arch/s390/mm/dump_pagetables.c
index 363f6470d742..3b93ba0b5d8d 100644
--- a/arch/s390/mm/dump_pagetables.c
+++ b/arch/s390/mm/dump_pagetables.c
@@ -111,11 +111,12 @@ static void note_page(struct seq_file *m, struct pg_state *st,
 }
 
 #ifdef CONFIG_KASAN
-static void note_kasan_zero_page(struct seq_file *m, struct pg_state *st)
+static void note_kasan_early_shadow_page(struct seq_file *m,
+						struct pg_state *st)
 {
 	unsigned int prot;
 
-	prot = pte_val(*kasan_zero_pte) &
+	prot = pte_val(*kasan_early_shadow_pte) &
 		(_PAGE_PROTECT | _PAGE_INVALID | _PAGE_NOEXEC);
 	note_page(m, st, prot, 4);
 }
@@ -154,8 +155,8 @@ static void walk_pmd_level(struct seq_file *m, struct pg_state *st,
 	int i;
 
 #ifdef CONFIG_KASAN
-	if ((pud_val(*pud) & PAGE_MASK) == __pa(kasan_zero_pmd)) {
-		note_kasan_zero_page(m, st);
+	if ((pud_val(*pud) & PAGE_MASK) == __pa(kasan_early_shadow_pmd)) {
+		note_kasan_early_shadow_page(m, st);
 		return;
 	}
 #endif
@@ -185,8 +186,8 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st,
 	int i;
 
 #ifdef CONFIG_KASAN
-	if ((p4d_val(*p4d) & PAGE_MASK) == __pa(kasan_zero_pud)) {
-		note_kasan_zero_page(m, st);
+	if ((p4d_val(*p4d) & PAGE_MASK) == __pa(kasan_early_shadow_pud)) {
+		note_kasan_early_shadow_page(m, st);
 		return;
 	}
 #endif
@@ -215,8 +216,8 @@ static void walk_p4d_level(struct seq_file *m, struct pg_state *st,
 	int i;
 
 #ifdef CONFIG_KASAN
-	if ((pgd_val(*pgd) & PAGE_MASK) == __pa(kasan_zero_p4d)) {
-		note_kasan_zero_page(m, st);
+	if ((pgd_val(*pgd) & PAGE_MASK) == __pa(kasan_early_shadow_p4d)) {
+		note_kasan_early_shadow_page(m, st);
 		return;
 	}
 #endif
diff --git a/arch/s390/mm/kasan_init.c b/arch/s390/mm/kasan_init.c
index acb9645b762b..bac5c27d11fc 100644
--- a/arch/s390/mm/kasan_init.c
+++ b/arch/s390/mm/kasan_init.c
@@ -107,7 +107,8 @@ static void __init kasan_early_vmemmap_populate(unsigned long address,
 			if (mode == POPULATE_ZERO_SHADOW &&
 			    IS_ALIGNED(address, PGDIR_SIZE) &&
 			    end - address >= PGDIR_SIZE) {
-				pgd_populate(&init_mm, pg_dir, kasan_zero_p4d);
+				pgd_populate(&init_mm, pg_dir,
+						kasan_early_shadow_p4d);
 				address = (address + PGDIR_SIZE) & PGDIR_MASK;
 				continue;
 			}
@@ -120,7 +121,8 @@ static void __init kasan_early_vmemmap_populate(unsigned long address,
 			if (mode == POPULATE_ZERO_SHADOW &&
 			    IS_ALIGNED(address, P4D_SIZE) &&
 			    end - address >= P4D_SIZE) {
-				p4d_populate(&init_mm, p4_dir, kasan_zero_pud);
+				p4d_populate(&init_mm, p4_dir,
+						kasan_early_shadow_pud);
 				address = (address + P4D_SIZE) & P4D_MASK;
 				continue;
 			}
@@ -133,7 +135,8 @@ static void __init kasan_early_vmemmap_populate(unsigned long address,
 			if (mode == POPULATE_ZERO_SHADOW &&
 			    IS_ALIGNED(address, PUD_SIZE) &&
 			    end - address >= PUD_SIZE) {
-				pud_populate(&init_mm, pu_dir, kasan_zero_pmd);
+				pud_populate(&init_mm, pu_dir,
+						kasan_early_shadow_pmd);
 				address = (address + PUD_SIZE) & PUD_MASK;
 				continue;
 			}
@@ -146,7 +149,8 @@ static void __init kasan_early_vmemmap_populate(unsigned long address,
 			if (mode == POPULATE_ZERO_SHADOW &&
 			    IS_ALIGNED(address, PMD_SIZE) &&
 			    end - address >= PMD_SIZE) {
-				pmd_populate(&init_mm, pm_dir, kasan_zero_pte);
+				pmd_populate(&init_mm, pm_dir,
+						kasan_early_shadow_pte);
 				address = (address + PMD_SIZE) & PMD_MASK;
 				continue;
 			}
@@ -188,7 +192,7 @@ static void __init kasan_early_vmemmap_populate(unsigned long address,
 				pte_val(*pt_dir) = __pa(page) | pgt_prot;
 				break;
 			case POPULATE_ZERO_SHADOW:
-				page = kasan_zero_page;
+				page = kasan_early_shadow_page;
 				pte_val(*pt_dir) = __pa(page) | pgt_prot_zero;
 				break;
 			}
@@ -256,14 +260,14 @@ void __init kasan_early_init(void)
 	unsigned long vmax;
 	unsigned long pgt_prot = pgprot_val(PAGE_KERNEL_RO);
 	pte_t pte_z;
-	pmd_t pmd_z = __pmd(__pa(kasan_zero_pte) | _SEGMENT_ENTRY);
-	pud_t pud_z = __pud(__pa(kasan_zero_pmd) | _REGION3_ENTRY);
-	p4d_t p4d_z = __p4d(__pa(kasan_zero_pud) | _REGION2_ENTRY);
+	pmd_t pmd_z = __pmd(__pa(kasan_early_shadow_pte) | _SEGMENT_ENTRY);
+	pud_t pud_z = __pud(__pa(kasan_early_shadow_pmd) | _REGION3_ENTRY);
+	p4d_t p4d_z = __p4d(__pa(kasan_early_shadow_pud) | _REGION2_ENTRY);
 
 	kasan_early_detect_facilities();
 	if (!has_nx)
 		pgt_prot &= ~_PAGE_NOEXEC;
-	pte_z = __pte(__pa(kasan_zero_page) | pgt_prot);
+	pte_z = __pte(__pa(kasan_early_shadow_page) | pgt_prot);
 
 	memsize = get_mem_detect_end();
 	if (!memsize)
@@ -292,10 +296,13 @@ void __init kasan_early_init(void)
 	}
 
 	/* init kasan zero shadow */
-	crst_table_init((unsigned long *)kasan_zero_p4d, p4d_val(p4d_z));
-	crst_table_init((unsigned long *)kasan_zero_pud, pud_val(pud_z));
-	crst_table_init((unsigned long *)kasan_zero_pmd, pmd_val(pmd_z));
-	memset64((u64 *)kasan_zero_pte, pte_val(pte_z), PTRS_PER_PTE);
+	crst_table_init((unsigned long *)kasan_early_shadow_p4d,
+				p4d_val(p4d_z));
+	crst_table_init((unsigned long *)kasan_early_shadow_pud,
+				pud_val(pud_z));
+	crst_table_init((unsigned long *)kasan_early_shadow_pmd,
+				pmd_val(pmd_z));
+	memset64((u64 *)kasan_early_shadow_pte, pte_val(pte_z), PTRS_PER_PTE);
 
 	shadow_alloc_size = memsize >> KASAN_SHADOW_SCALE_SHIFT;
 	pgalloc_low = round_up((unsigned long)_end, _SEGMENT_SIZE);
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index fc37bbd23eb8..c4696ab9a72b 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -380,7 +380,7 @@ static void walk_pte_level(struct seq_file *m, struct pg_state *st, pmd_t addr,
 
 /*
  * This is an optimization for KASAN=y case. Since all kasan page tables
- * eventually point to the kasan_zero_page we could call note_page()
+ * eventually point to the kasan_early_shadow_page we could call note_page()
  * right away without walking through lower level page tables. This saves
  * us dozens of seconds (minutes for 5-level config) while checking for
  * W+X mapping or reading kernel_page_tables debugfs file.
@@ -388,10 +388,11 @@ static void walk_pte_level(struct seq_file *m, struct pg_state *st, pmd_t addr,
 static inline bool kasan_page_table(struct seq_file *m, struct pg_state *st,
 				void *pt)
 {
-	if (__pa(pt) == __pa(kasan_zero_pmd) ||
-	    (pgtable_l5_enabled() && __pa(pt) == __pa(kasan_zero_p4d)) ||
-	    __pa(pt) == __pa(kasan_zero_pud)) {
-		pgprotval_t prot = pte_flags(kasan_zero_pte[0]);
+	if (__pa(pt) == __pa(kasan_early_shadow_pmd) ||
+	    (pgtable_l5_enabled() &&
+			__pa(pt) == __pa(kasan_early_shadow_p4d)) ||
+	    __pa(pt) == __pa(kasan_early_shadow_pud)) {
+		pgprotval_t prot = pte_flags(kasan_early_shadow_pte[0]);
 		note_page(m, st, __pgprot(prot), 0, 5);
 		return true;
 	}
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 04a9cf6b034f..462fde83b515 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -211,7 +211,8 @@ static void __init kasan_early_p4d_populate(pgd_t *pgd,
 	unsigned long next;
 
 	if (pgd_none(*pgd)) {
-		pgd_entry = __pgd(_KERNPG_TABLE | __pa_nodebug(kasan_zero_p4d));
+		pgd_entry = __pgd(_KERNPG_TABLE |
+					__pa_nodebug(kasan_early_shadow_p4d));
 		set_pgd(pgd, pgd_entry);
 	}
 
@@ -222,7 +223,8 @@ static void __init kasan_early_p4d_populate(pgd_t *pgd,
 		if (!p4d_none(*p4d))
 			continue;
 
-		p4d_entry = __p4d(_KERNPG_TABLE | __pa_nodebug(kasan_zero_pud));
+		p4d_entry = __p4d(_KERNPG_TABLE |
+					__pa_nodebug(kasan_early_shadow_pud));
 		set_p4d(p4d, p4d_entry);
 	} while (p4d++, addr = next, addr != end && p4d_none(*p4d));
 }
@@ -261,10 +263,11 @@ static struct notifier_block kasan_die_notifier = {
 void __init kasan_early_init(void)
 {
 	int i;
-	pteval_t pte_val = __pa_nodebug(kasan_zero_page) | __PAGE_KERNEL | _PAGE_ENC;
-	pmdval_t pmd_val = __pa_nodebug(kasan_zero_pte) | _KERNPG_TABLE;
-	pudval_t pud_val = __pa_nodebug(kasan_zero_pmd) | _KERNPG_TABLE;
-	p4dval_t p4d_val = __pa_nodebug(kasan_zero_pud) | _KERNPG_TABLE;
+	pteval_t pte_val = __pa_nodebug(kasan_early_shadow_page) |
+				__PAGE_KERNEL | _PAGE_ENC;
+	pmdval_t pmd_val = __pa_nodebug(kasan_early_shadow_pte) | _KERNPG_TABLE;
+	pudval_t pud_val = __pa_nodebug(kasan_early_shadow_pmd) | _KERNPG_TABLE;
+	p4dval_t p4d_val = __pa_nodebug(kasan_early_shadow_pud) | _KERNPG_TABLE;
 
 	/* Mask out unsupported __PAGE_KERNEL bits: */
 	pte_val &= __default_kernel_pte_mask;
@@ -273,16 +276,16 @@ void __init kasan_early_init(void)
 	p4d_val &= __default_kernel_pte_mask;
 
 	for (i = 0; i < PTRS_PER_PTE; i++)
-		kasan_zero_pte[i] = __pte(pte_val);
+		kasan_early_shadow_pte[i] = __pte(pte_val);
 
 	for (i = 0; i < PTRS_PER_PMD; i++)
-		kasan_zero_pmd[i] = __pmd(pmd_val);
+		kasan_early_shadow_pmd[i] = __pmd(pmd_val);
 
 	for (i = 0; i < PTRS_PER_PUD; i++)
-		kasan_zero_pud[i] = __pud(pud_val);
+		kasan_early_shadow_pud[i] = __pud(pud_val);
 
 	for (i = 0; pgtable_l5_enabled() && i < PTRS_PER_P4D; i++)
-		kasan_zero_p4d[i] = __p4d(p4d_val);
+		kasan_early_shadow_p4d[i] = __p4d(p4d_val);
 
 	kasan_map_early_shadow(early_top_pgt);
 	kasan_map_early_shadow(init_top_pgt);
@@ -326,7 +329,7 @@ void __init kasan_init(void)
 
 	clear_pgds(KASAN_SHADOW_START & PGDIR_MASK, KASAN_SHADOW_END);
 
-	kasan_populate_zero_shadow((void *)(KASAN_SHADOW_START & PGDIR_MASK),
+	kasan_populate_early_shadow((void *)(KASAN_SHADOW_START & PGDIR_MASK),
 			kasan_mem_to_shadow((void *)PAGE_OFFSET));
 
 	for (i = 0; i < E820_MAX_ENTRIES; i++) {
@@ -338,41 +341,41 @@ void __init kasan_init(void)
 
 	shadow_cpu_entry_begin = (void *)CPU_ENTRY_AREA_BASE;
 	shadow_cpu_entry_begin = kasan_mem_to_shadow(shadow_cpu_entry_begin);
-	shadow_cpu_entry_begin = (void *)round_down((unsigned long)shadow_cpu_entry_begin,
-						PAGE_SIZE);
+	shadow_cpu_entry_begin = (void *)round_down(
+			(unsigned long)shadow_cpu_entry_begin, PAGE_SIZE);
 
 	shadow_cpu_entry_end = (void *)(CPU_ENTRY_AREA_BASE +
 					CPU_ENTRY_AREA_MAP_SIZE);
 	shadow_cpu_entry_end = kasan_mem_to_shadow(shadow_cpu_entry_end);
-	shadow_cpu_entry_end = (void *)round_up((unsigned long)shadow_cpu_entry_end,
-					PAGE_SIZE);
+	shadow_cpu_entry_end = (void *)round_up(
+			(unsigned long)shadow_cpu_entry_end, PAGE_SIZE);
 
-	kasan_populate_zero_shadow(
+	kasan_populate_early_shadow(
 		kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
 		shadow_cpu_entry_begin);
 
 	kasan_populate_shadow((unsigned long)shadow_cpu_entry_begin,
 			      (unsigned long)shadow_cpu_entry_end, 0);
 
-	kasan_populate_zero_shadow(shadow_cpu_entry_end,
-				kasan_mem_to_shadow((void *)__START_KERNEL_map));
+	kasan_populate_early_shadow(shadow_cpu_entry_end,
+			kasan_mem_to_shadow((void *)__START_KERNEL_map));
 
 	kasan_populate_shadow((unsigned long)kasan_mem_to_shadow(_stext),
 			      (unsigned long)kasan_mem_to_shadow(_end),
 			      early_pfn_to_nid(__pa(_stext)));
 
-	kasan_populate_zero_shadow(kasan_mem_to_shadow((void *)MODULES_END),
-				(void *)KASAN_SHADOW_END);
+	kasan_populate_early_shadow(kasan_mem_to_shadow((void *)MODULES_END),
+					(void *)KASAN_SHADOW_END);
 
 	load_cr3(init_top_pgt);
 	__flush_tlb_all();
 
 	/*
-	 * kasan_zero_page has been used as early shadow memory, thus it may
-	 * contain some garbage. Now we can clear and write protect it, since
-	 * after the TLB flush no one should write to it.
+	 * kasan_early_shadow_page has been used as early shadow memory, thus
+	 * it may contain some garbage. Now we can clear and write protect it,
+	 * since after the TLB flush no one should write to it.
 	 */
-	memset(kasan_zero_page, 0, PAGE_SIZE);
+	memset(kasan_early_shadow_page, 0, PAGE_SIZE);
 	for (i = 0; i < PTRS_PER_PTE; i++) {
 		pte_t pte;
 		pgprot_t prot;
@@ -380,8 +383,8 @@ void __init kasan_init(void)
 		prot = __pgprot(__PAGE_KERNEL_RO | _PAGE_ENC);
 		pgprot_val(prot) &= __default_kernel_pte_mask;
 
-		pte = __pte(__pa(kasan_zero_page) | pgprot_val(prot));
-		set_pte(&kasan_zero_pte[i], pte);
+		pte = __pte(__pa(kasan_early_shadow_page) | pgprot_val(prot));
+		set_pte(&kasan_early_shadow_pte[i], pte);
 	}
 	/* Flush TLBs again to be sure that write protection applied. */
 	__flush_tlb_all();
diff --git a/arch/xtensa/mm/kasan_init.c b/arch/xtensa/mm/kasan_init.c
index 6b95ca43aec0..1734cda6bc4a 100644
--- a/arch/xtensa/mm/kasan_init.c
+++ b/arch/xtensa/mm/kasan_init.c
@@ -24,12 +24,13 @@ void __init kasan_early_init(void)
 	int i;
 
 	for (i = 0; i < PTRS_PER_PTE; ++i)
-		set_pte(kasan_zero_pte + i,
-			mk_pte(virt_to_page(kasan_zero_page), PAGE_KERNEL));
+		set_pte(kasan_early_shadow_pte + i,
+			mk_pte(virt_to_page(kasan_early_shadow_page),
+				PAGE_KERNEL));
 
 	for (vaddr = 0; vaddr < KASAN_SHADOW_SIZE; vaddr += PMD_SIZE, ++pmd) {
 		BUG_ON(!pmd_none(*pmd));
-		set_pmd(pmd, __pmd((unsigned long)kasan_zero_pte));
+		set_pmd(pmd, __pmd((unsigned long)kasan_early_shadow_pte));
 	}
 	early_trap_init();
 }
@@ -80,13 +81,16 @@ void __init kasan_init(void)
 	populate(kasan_mem_to_shadow((void *)VMALLOC_START),
 		 kasan_mem_to_shadow((void *)XCHAL_KSEG_BYPASS_VADDR));
 
-	/* Write protect kasan_zero_page and zero-initialize it again. */
+	/*
+	 * Write protect kasan_early_shadow_page and zero-initialize it again.
+	 */
 	for (i = 0; i < PTRS_PER_PTE; ++i)
-		set_pte(kasan_zero_pte + i,
-			mk_pte(virt_to_page(kasan_zero_page), PAGE_KERNEL_RO));
+		set_pte(kasan_early_shadow_pte + i,
+			mk_pte(virt_to_page(kasan_early_shadow_page),
+				PAGE_KERNEL_RO));
 
 	local_flush_tlb_all();
-	memset(kasan_zero_page, 0, PAGE_SIZE);
+	memset(kasan_early_shadow_page, 0, PAGE_SIZE);
 
 	/* At this point kasan is fully initialized. Enable error messages. */
 	current->kasan_depth = 0;
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index b66fdf5ea7ab..ec22d548d0d7 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -14,13 +14,13 @@ struct task_struct;
 #include <asm/kasan.h>
 #include <asm/pgtable.h>
 
-extern unsigned char kasan_zero_page[PAGE_SIZE];
-extern pte_t kasan_zero_pte[PTRS_PER_PTE];
-extern pmd_t kasan_zero_pmd[PTRS_PER_PMD];
-extern pud_t kasan_zero_pud[PTRS_PER_PUD];
-extern p4d_t kasan_zero_p4d[MAX_PTRS_PER_P4D];
+extern unsigned char kasan_early_shadow_page[PAGE_SIZE];
+extern pte_t kasan_early_shadow_pte[PTRS_PER_PTE];
+extern pmd_t kasan_early_shadow_pmd[PTRS_PER_PMD];
+extern pud_t kasan_early_shadow_pud[PTRS_PER_PUD];
+extern p4d_t kasan_early_shadow_p4d[MAX_PTRS_PER_P4D];
 
-int kasan_populate_zero_shadow(const void *shadow_start,
+int kasan_populate_early_shadow(const void *shadow_start,
 				const void *shadow_end);
 
 static inline void *kasan_mem_to_shadow(const void *addr)
diff --git a/mm/kasan/init.c b/mm/kasan/init.c
index c7550eb65922..2b21d3717d62 100644
--- a/mm/kasan/init.c
+++ b/mm/kasan/init.c
@@ -30,13 +30,13 @@
  *   - Latter it reused it as zero shadow to cover large ranges of memory
  *     that allowed to access, but not handled by kasan (vmalloc/vmemmap ...).
  */
-unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
+unsigned char kasan_early_shadow_page[PAGE_SIZE] __page_aligned_bss;
 
 #if CONFIG_PGTABLE_LEVELS > 4
-p4d_t kasan_zero_p4d[MAX_PTRS_PER_P4D] __page_aligned_bss;
+p4d_t kasan_early_shadow_p4d[MAX_PTRS_PER_P4D] __page_aligned_bss;
 static inline bool kasan_p4d_table(pgd_t pgd)
 {
-	return pgd_page(pgd) == virt_to_page(lm_alias(kasan_zero_p4d));
+	return pgd_page(pgd) == virt_to_page(lm_alias(kasan_early_shadow_p4d));
 }
 #else
 static inline bool kasan_p4d_table(pgd_t pgd)
@@ -45,10 +45,10 @@ static inline bool kasan_p4d_table(pgd_t pgd)
 }
 #endif
 #if CONFIG_PGTABLE_LEVELS > 3
-pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
+pud_t kasan_early_shadow_pud[PTRS_PER_PUD] __page_aligned_bss;
 static inline bool kasan_pud_table(p4d_t p4d)
 {
-	return p4d_page(p4d) == virt_to_page(lm_alias(kasan_zero_pud));
+	return p4d_page(p4d) == virt_to_page(lm_alias(kasan_early_shadow_pud));
 }
 #else
 static inline bool kasan_pud_table(p4d_t p4d)
@@ -57,10 +57,10 @@ static inline bool kasan_pud_table(p4d_t p4d)
 }
 #endif
 #if CONFIG_PGTABLE_LEVELS > 2
-pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
+pmd_t kasan_early_shadow_pmd[PTRS_PER_PMD] __page_aligned_bss;
 static inline bool kasan_pmd_table(pud_t pud)
 {
-	return pud_page(pud) == virt_to_page(lm_alias(kasan_zero_pmd));
+	return pud_page(pud) == virt_to_page(lm_alias(kasan_early_shadow_pmd));
 }
 #else
 static inline bool kasan_pmd_table(pud_t pud)
@@ -68,16 +68,16 @@ static inline bool kasan_pmd_table(pud_t pud)
 	return 0;
 }
 #endif
-pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
+pte_t kasan_early_shadow_pte[PTRS_PER_PTE] __page_aligned_bss;
 
 static inline bool kasan_pte_table(pmd_t pmd)
 {
-	return pmd_page(pmd) == virt_to_page(lm_alias(kasan_zero_pte));
+	return pmd_page(pmd) == virt_to_page(lm_alias(kasan_early_shadow_pte));
 }
 
-static inline bool kasan_zero_page_entry(pte_t pte)
+static inline bool kasan_early_shadow_page_entry(pte_t pte)
 {
-	return pte_page(pte) == virt_to_page(lm_alias(kasan_zero_page));
+	return pte_page(pte) == virt_to_page(lm_alias(kasan_early_shadow_page));
 }
 
 static __init void *early_alloc(size_t size, int node)
@@ -92,7 +92,8 @@ static void __ref zero_pte_populate(pmd_t *pmd, unsigned long addr,
 	pte_t *pte = pte_offset_kernel(pmd, addr);
 	pte_t zero_pte;
 
-	zero_pte = pfn_pte(PFN_DOWN(__pa_symbol(kasan_zero_page)), PAGE_KERNEL);
+	zero_pte = pfn_pte(PFN_DOWN(__pa_symbol(kasan_early_shadow_page)),
+				PAGE_KERNEL);
 	zero_pte = pte_wrprotect(zero_pte);
 
 	while (addr + PAGE_SIZE <= end) {
@@ -112,7 +113,8 @@ static int __ref zero_pmd_populate(pud_t *pud, unsigned long addr,
 		next = pmd_addr_end(addr, end);
 
 		if (IS_ALIGNED(addr, PMD_SIZE) && end - addr >= PMD_SIZE) {
-			pmd_populate_kernel(&init_mm, pmd, lm_alias(kasan_zero_pte));
+			pmd_populate_kernel(&init_mm, pmd,
+					lm_alias(kasan_early_shadow_pte));
 			continue;
 		}
 
@@ -145,9 +147,11 @@ static int __ref zero_pud_populate(p4d_t *p4d, unsigned long addr,
 		if (IS_ALIGNED(addr, PUD_SIZE) && end - addr >= PUD_SIZE) {
 			pmd_t *pmd;
 
-			pud_populate(&init_mm, pud, lm_alias(kasan_zero_pmd));
+			pud_populate(&init_mm, pud,
+					lm_alias(kasan_early_shadow_pmd));
 			pmd = pmd_offset(pud, addr);
-			pmd_populate_kernel(&init_mm, pmd, lm_alias(kasan_zero_pte));
+			pmd_populate_kernel(&init_mm, pmd,
+					lm_alias(kasan_early_shadow_pte));
 			continue;
 		}
 
@@ -181,12 +185,14 @@ static int __ref zero_p4d_populate(pgd_t *pgd, unsigned long addr,
 			pud_t *pud;
 			pmd_t *pmd;
 
-			p4d_populate(&init_mm, p4d, lm_alias(kasan_zero_pud));
+			p4d_populate(&init_mm, p4d,
+					lm_alias(kasan_early_shadow_pud));
 			pud = pud_offset(p4d, addr);
-			pud_populate(&init_mm, pud, lm_alias(kasan_zero_pmd));
+			pud_populate(&init_mm, pud,
+					lm_alias(kasan_early_shadow_pmd));
 			pmd = pmd_offset(pud, addr);
 			pmd_populate_kernel(&init_mm, pmd,
-						lm_alias(kasan_zero_pte));
+					lm_alias(kasan_early_shadow_pte));
 			continue;
 		}
 
@@ -209,13 +215,13 @@ static int __ref zero_p4d_populate(pgd_t *pgd, unsigned long addr,
 }
 
 /**
- * kasan_populate_zero_shadow - populate shadow memory region with
- *                               kasan_zero_page
+ * kasan_populate_early_shadow - populate shadow memory region with
+ *                               kasan_early_shadow_page
  * @shadow_start - start of the memory range to populate
  * @shadow_end   - end of the memory range to populate
  */
-int __ref kasan_populate_zero_shadow(const void *shadow_start,
-				const void *shadow_end)
+int __ref kasan_populate_early_shadow(const void *shadow_start,
+					const void *shadow_end)
 {
 	unsigned long addr = (unsigned long)shadow_start;
 	unsigned long end = (unsigned long)shadow_end;
@@ -231,7 +237,7 @@ int __ref kasan_populate_zero_shadow(const void *shadow_start,
 			pmd_t *pmd;
 
 			/*
-			 * kasan_zero_pud should be populated with pmds
+			 * kasan_early_shadow_pud should be populated with pmds
 			 * at this moment.
 			 * [pud,pmd]_populate*() below needed only for
 			 * 3,2 - level page tables where we don't have
@@ -241,21 +247,25 @@ int __ref kasan_populate_zero_shadow(const void *shadow_start,
 			 * The ifndef is required to avoid build breakage.
 			 *
 			 * With 5level-fixup.h, pgd_populate() is not nop and
-			 * we reference kasan_zero_p4d. It's not defined
+			 * we reference kasan_early_shadow_p4d. It's not defined
 			 * unless 5-level paging enabled.
 			 *
 			 * The ifndef can be dropped once all KASAN-enabled
 			 * architectures will switch to pgtable-nop4d.h.
 			 */
 #ifndef __ARCH_HAS_5LEVEL_HACK
-			pgd_populate(&init_mm, pgd, lm_alias(kasan_zero_p4d));
+			pgd_populate(&init_mm, pgd,
+					lm_alias(kasan_early_shadow_p4d));
 #endif
 			p4d = p4d_offset(pgd, addr);
-			p4d_populate(&init_mm, p4d, lm_alias(kasan_zero_pud));
+			p4d_populate(&init_mm, p4d,
+					lm_alias(kasan_early_shadow_pud));
 			pud = pud_offset(p4d, addr);
-			pud_populate(&init_mm, pud, lm_alias(kasan_zero_pmd));
+			pud_populate(&init_mm, pud,
+					lm_alias(kasan_early_shadow_pmd));
 			pmd = pmd_offset(pud, addr);
-			pmd_populate_kernel(&init_mm, pmd, lm_alias(kasan_zero_pte));
+			pmd_populate_kernel(&init_mm, pmd,
+					lm_alias(kasan_early_shadow_pte));
 			continue;
 		}
 
@@ -350,7 +360,7 @@ static void kasan_remove_pte_table(pte_t *pte, unsigned long addr,
 		if (!pte_present(*pte))
 			continue;
 
-		if (WARN_ON(!kasan_zero_page_entry(*pte)))
+		if (WARN_ON(!kasan_early_shadow_page_entry(*pte)))
 			continue;
 		pte_clear(&init_mm, addr, pte);
 	}
@@ -480,7 +490,7 @@ int kasan_add_zero_shadow(void *start, unsigned long size)
 	    WARN_ON(size % (KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE)))
 		return -EINVAL;
 
-	ret = kasan_populate_zero_shadow(shadow_start, shadow_end);
+	ret = kasan_populate_early_shadow(shadow_start, shadow_end);
 	if (ret)
 		kasan_remove_zero_shadow(shadow_start,
 					size >> KASAN_SHADOW_SCALE_SHIFT);
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
