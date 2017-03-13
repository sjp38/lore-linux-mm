Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D59C16B0429
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 01:51:00 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v190so282426478pfb.5
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 22:51:00 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id l70si10514823pgd.3.2017.03.12.22.50.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Mar 2017 22:50:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 02/26] x86: trivial portion of 5-level paging conversion
Date: Mon, 13 Mar 2017 08:49:56 +0300
Message-Id: <20170313055020.69655-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch covers simple cases only.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/tboot.c        |  6 +++++-
 arch/x86/kernel/vm86_32.c      |  6 +++++-
 arch/x86/mm/fault.c            | 39 +++++++++++++++++++++++++++++++++------
 arch/x86/mm/init_32.c          | 22 ++++++++++++++++------
 arch/x86/mm/ioremap.c          |  3 ++-
 arch/x86/mm/pgtable.c          |  4 +++-
 arch/x86/mm/pgtable_32.c       |  8 +++++++-
 arch/x86/platform/efi/efi_64.c | 13 +++++++++----
 arch/x86/power/hibernate_32.c  |  7 +++++--
 9 files changed, 85 insertions(+), 23 deletions(-)

diff --git a/arch/x86/kernel/tboot.c b/arch/x86/kernel/tboot.c
index b868fa1b812b..5db0f33cbf2c 100644
--- a/arch/x86/kernel/tboot.c
+++ b/arch/x86/kernel/tboot.c
@@ -118,12 +118,16 @@ static int map_tboot_page(unsigned long vaddr, unsigned long pfn,
 			  pgprot_t prot)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 
 	pgd = pgd_offset(&tboot_mm, vaddr);
-	pud = pud_alloc(&tboot_mm, pgd, vaddr);
+	p4d = p4d_alloc(&tboot_mm, pgd, vaddr);
+	if (!p4d)
+		return -1;
+	pud = pud_alloc(&tboot_mm, p4d, vaddr);
 	if (!pud)
 		return -1;
 	pmd = pmd_alloc(&tboot_mm, pud, vaddr);
diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
index 23ee89ce59a9..62597c300d94 100644
--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -164,6 +164,7 @@ static void mark_screen_rdonly(struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	spinlock_t *ptl;
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -173,7 +174,10 @@ static void mark_screen_rdonly(struct mm_struct *mm)
 	pgd = pgd_offset(mm, 0xA0000);
 	if (pgd_none_or_clear_bad(pgd))
 		goto out;
-	pud = pud_offset(pgd, 0xA0000);
+	p4d = p4d_offset(pgd, 0xA0000);
+	if (p4d_none_or_clear_bad(p4d))
+		goto out;
+	pud = pud_offset(p4d, 0xA0000);
 	if (pud_none_or_clear_bad(pud))
 		goto out;
 	pmd = pmd_offset(pud, 0xA0000);
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 428e31763cb9..605fd5e8e048 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -253,6 +253,7 @@ static inline pmd_t *vmalloc_sync_one(pgd_t *pgd, unsigned long address)
 {
 	unsigned index = pgd_index(address);
 	pgd_t *pgd_k;
+	p4d_t *p4d, *p4d_k;
 	pud_t *pud, *pud_k;
 	pmd_t *pmd, *pmd_k;
 
@@ -265,10 +266,15 @@ static inline pmd_t *vmalloc_sync_one(pgd_t *pgd, unsigned long address)
 	/*
 	 * set_pgd(pgd, *pgd_k); here would be useless on PAE
 	 * and redundant with the set_pmd() on non-PAE. As would
-	 * set_pud.
+	 * set_p4d/set_pud.
 	 */
-	pud = pud_offset(pgd, address);
-	pud_k = pud_offset(pgd_k, address);
+	p4d = p4d_offset(pgd, address);
+	p4d_k = p4d_offset(pgd_k, address);
+	if (!p4d_present(*p4d_k))
+		return NULL;
+
+	pud = pud_offset(p4d, address);
+	pud_k = pud_offset(p4d_k, address);
 	if (!pud_present(*pud_k))
 		return NULL;
 
@@ -384,6 +390,8 @@ static void dump_pagetable(unsigned long address)
 {
 	pgd_t *base = __va(read_cr3());
 	pgd_t *pgd = &base[pgd_index(address)];
+	p4d_t *p4d;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 
@@ -392,7 +400,9 @@ static void dump_pagetable(unsigned long address)
 	if (!low_pfn(pgd_val(*pgd) >> PAGE_SHIFT) || !pgd_present(*pgd))
 		goto out;
 #endif
-	pmd = pmd_offset(pud_offset(pgd, address), address);
+	p4d = p4d_offset(pgd, address);
+	pud = pud_offset(p4d, address);
+	pmd = pmd_offset(pud, address);
 	printk(KERN_CONT "*pde = %0*Lx ", sizeof(*pmd) * 2, (u64)pmd_val(*pmd));
 
 	/*
@@ -526,6 +536,7 @@ static void dump_pagetable(unsigned long address)
 {
 	pgd_t *base = __va(read_cr3() & PHYSICAL_PAGE_MASK);
 	pgd_t *pgd = base + pgd_index(address);
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -538,7 +549,15 @@ static void dump_pagetable(unsigned long address)
 	if (!pgd_present(*pgd))
 		goto out;
 
-	pud = pud_offset(pgd, address);
+	p4d = p4d_offset(pgd, address);
+	if (bad_address(p4d))
+		goto bad;
+
+	printk("P4D %lx ", p4d_val(*p4d));
+	if (!p4d_present(*p4d) || p4d_large(*p4d))
+		goto out;
+
+	pud = pud_offset(p4d, address);
 	if (bad_address(pud))
 		goto bad;
 
@@ -1082,6 +1101,7 @@ static noinline int
 spurious_fault(unsigned long error_code, unsigned long address)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -1104,7 +1124,14 @@ spurious_fault(unsigned long error_code, unsigned long address)
 	if (!pgd_present(*pgd))
 		return 0;
 
-	pud = pud_offset(pgd, address);
+	p4d = p4d_offset(pgd, address);
+	if (!p4d_present(*p4d))
+		return 0;
+
+	if (p4d_large(*p4d))
+		return spurious_fault_check(error_code, (pte_t *) p4d);
+
+	pud = pud_offset(p4d, address);
 	if (!pud_present(*pud))
 		return 0;
 
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 2b4b53e6793f..5ed3c141bbd5 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -67,6 +67,7 @@ bool __read_mostly __vmalloc_start_set = false;
  */
 static pmd_t * __init one_md_table_init(pgd_t *pgd)
 {
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd_table;
 
@@ -75,13 +76,15 @@ static pmd_t * __init one_md_table_init(pgd_t *pgd)
 		pmd_table = (pmd_t *)alloc_low_page();
 		paravirt_alloc_pmd(&init_mm, __pa(pmd_table) >> PAGE_SHIFT);
 		set_pgd(pgd, __pgd(__pa(pmd_table) | _PAGE_PRESENT));
-		pud = pud_offset(pgd, 0);
+		p4d = p4d_offset(pgd, 0);
+		pud = pud_offset(p4d, 0);
 		BUG_ON(pmd_table != pmd_offset(pud, 0));
 
 		return pmd_table;
 	}
 #endif
-	pud = pud_offset(pgd, 0);
+	p4d = p4d_offset(pgd, 0);
+	pud = pud_offset(p4d, 0);
 	pmd_table = pmd_offset(pud, 0);
 
 	return pmd_table;
@@ -390,8 +393,11 @@ pte_t *kmap_pte;
 
 static inline pte_t *kmap_get_fixmap_pte(unsigned long vaddr)
 {
-	return pte_offset_kernel(pmd_offset(pud_offset(pgd_offset_k(vaddr),
-			vaddr), vaddr), vaddr);
+	pgd_t *pgd = pgd_offset_k(vaddr);
+	p4d_t *p4d = p4d_offset(pgd, vaddr);
+	pud_t *pud = pud_offset(p4d, vaddr);
+	pmd_t *pmd = pmd_offset(pud, vaddr);
+	return pte_offset_kernel(pmd, vaddr);
 }
 
 static void __init kmap_init(void)
@@ -410,6 +416,7 @@ static void __init permanent_kmaps_init(pgd_t *pgd_base)
 {
 	unsigned long vaddr;
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -418,7 +425,8 @@ static void __init permanent_kmaps_init(pgd_t *pgd_base)
 	page_table_range_init(vaddr, vaddr + PAGE_SIZE*LAST_PKMAP, pgd_base);
 
 	pgd = swapper_pg_dir + pgd_index(vaddr);
-	pud = pud_offset(pgd, vaddr);
+	p4d = p4d_offset(pgd, vaddr);
+	pud = pud_offset(p4d, vaddr);
 	pmd = pmd_offset(pud, vaddr);
 	pte = pte_offset_kernel(pmd, vaddr);
 	pkmap_page_table = pte;
@@ -450,6 +458,7 @@ void __init native_pagetable_init(void)
 {
 	unsigned long pfn, va;
 	pgd_t *pgd, *base = swapper_pg_dir;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -469,7 +478,8 @@ void __init native_pagetable_init(void)
 		if (!pgd_present(*pgd))
 			break;
 
-		pud = pud_offset(pgd, va);
+		p4d = p4d_offset(pgd, va);
+		pud = pud_offset(p4d, va);
 		pmd = pmd_offset(pud, va);
 		if (!pmd_present(*pmd))
 			break;
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 7aaa2635862d..a5e1cda85974 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -425,7 +425,8 @@ static inline pmd_t * __init early_ioremap_pmd(unsigned long addr)
 	/* Don't assume we're using swapper_pg_dir at this point */
 	pgd_t *base = __va(read_cr3());
 	pgd_t *pgd = &base[pgd_index(addr)];
-	pud_t *pud = pud_offset(pgd, addr);
+	p4d_t *p4d = p4d_offset(pgd, addr);
+	pud_t *pud = pud_offset(p4d, addr);
 	pmd_t *pmd = pmd_offset(pud, addr);
 
 	return pmd;
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 6cbdff26bb96..38b6daf72deb 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -261,13 +261,15 @@ static void pgd_mop_up_pmds(struct mm_struct *mm, pgd_t *pgdp)
 
 static void pgd_prepopulate_pmd(struct mm_struct *mm, pgd_t *pgd, pmd_t *pmds[])
 {
+	p4d_t *p4d;
 	pud_t *pud;
 	int i;
 
 	if (PREALLOCATED_PMDS == 0) /* Work around gcc-3.4.x bug */
 		return;
 
-	pud = pud_offset(pgd, 0);
+	p4d = p4d_offset(pgd, 0);
+	pud = pud_offset(p4d, 0);
 
 	for (i = 0; i < PREALLOCATED_PMDS; i++, pud++) {
 		pmd_t *pmd = pmds[i];
diff --git a/arch/x86/mm/pgtable_32.c b/arch/x86/mm/pgtable_32.c
index 9adce776852b..3d275a791c76 100644
--- a/arch/x86/mm/pgtable_32.c
+++ b/arch/x86/mm/pgtable_32.c
@@ -26,6 +26,7 @@ unsigned int __VMALLOC_RESERVE = 128 << 20;
 void set_pte_vaddr(unsigned long vaddr, pte_t pteval)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -35,7 +36,12 @@ void set_pte_vaddr(unsigned long vaddr, pte_t pteval)
 		BUG();
 		return;
 	}
-	pud = pud_offset(pgd, vaddr);
+	p4d = p4d_offset(pgd, vaddr);
+	if (p4d_none(*p4d)) {
+		BUG();
+		return;
+	}
+	pud = pud_offset(p4d, vaddr);
 	if (pud_none(*pud)) {
 		BUG();
 		return;
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index a4695da42d77..8544dae3d1b4 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -166,6 +166,7 @@ void efi_sync_low_kernel_mappings(void)
 {
 	unsigned num_entries;
 	pgd_t *pgd_k, *pgd_efi;
+	p4d_t *p4d_k, *p4d_efi;
 	pud_t *pud_k, *pud_efi;
 
 	if (efi_enabled(EFI_OLD_MEMMAP))
@@ -197,16 +198,20 @@ void efi_sync_low_kernel_mappings(void)
 	BUILD_BUG_ON((EFI_VA_END & ~PUD_MASK) != 0);
 
 	pgd_efi = efi_pgd + pgd_index(EFI_VA_END);
-	pud_efi = pud_offset(pgd_efi, 0);
+	p4d_efi = p4d_offset(pgd_efi, 0);
+	pud_efi = pud_offset(p4d_efi, 0);
 
 	pgd_k = pgd_offset_k(EFI_VA_END);
-	pud_k = pud_offset(pgd_k, 0);
+	p4d_k = p4d_offset(pgd_k, 0);
+	pud_k = pud_offset(p4d_k, 0);
 
 	num_entries = pud_index(EFI_VA_END);
 	memcpy(pud_efi, pud_k, sizeof(pud_t) * num_entries);
 
-	pud_efi = pud_offset(pgd_efi, EFI_VA_START);
-	pud_k = pud_offset(pgd_k, EFI_VA_START);
+	p4d_efi = p4d_offset(pgd_efi, EFI_VA_START);
+	pud_efi = pud_offset(p4d_efi, EFI_VA_START);
+	p4d_k = p4d_offset(pgd_k, EFI_VA_START);
+	pud_k = pud_offset(p4d_k, EFI_VA_START);
 
 	num_entries = PTRS_PER_PUD - pud_index(EFI_VA_START);
 	memcpy(pud_efi, pud_k, sizeof(pud_t) * num_entries);
diff --git a/arch/x86/power/hibernate_32.c b/arch/x86/power/hibernate_32.c
index 9f14bd34581d..c35fdb585c68 100644
--- a/arch/x86/power/hibernate_32.c
+++ b/arch/x86/power/hibernate_32.c
@@ -32,6 +32,7 @@ pgd_t *resume_pg_dir;
  */
 static pmd_t *resume_one_md_table_init(pgd_t *pgd)
 {
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd_table;
 
@@ -41,11 +42,13 @@ static pmd_t *resume_one_md_table_init(pgd_t *pgd)
 		return NULL;
 
 	set_pgd(pgd, __pgd(__pa(pmd_table) | _PAGE_PRESENT));
-	pud = pud_offset(pgd, 0);
+	p4d = p4d_offset(pgd, 0);
+	pud = pud_offset(p4d, 0);
 
 	BUG_ON(pmd_table != pmd_offset(pud, 0));
 #else
-	pud = pud_offset(pgd, 0);
+	p4d = p4d_offset(pgd, 0);
+	pud = pud_offset(p4d, 0);
 	pmd_table = pmd_offset(pud, 0);
 #endif
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
