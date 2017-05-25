Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E83A6B02FA
	for <linux-mm@kvack.org>; Thu, 25 May 2017 16:34:28 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a66so242847580pfl.6
        for <linux-mm@kvack.org>; Thu, 25 May 2017 13:34:28 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u195si29435729pgc.315.2017.05.25.13.34.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 13:34:26 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv1, RFC 3/8] x86/mm: Make PGDIR_SHIFT and PTRS_PER_P4D variable
Date: Thu, 25 May 2017 23:33:29 +0300
Message-Id: <20170525203334.867-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For boot-time switching between 4- and 5-level paging we need to be able
to fold p4d page table level at runtime. It requires variable
PGDIR_SHIFT and PTRS_PER_P4D.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable_32.h       |  2 ++
 arch/x86/include/asm/pgtable_64_types.h |  7 +++++--
 arch/x86/kernel/head64.c                |  9 ++++++++-
 arch/x86/mm/dump_pagetables.c           | 11 +++--------
 arch/x86/mm/init_64.c                   |  2 +-
 arch/x86/platform/efi/efi_64.c          |  4 ++--
 6 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_32.h b/arch/x86/include/asm/pgtable_32.h
index bfab55675c16..9c3c811347b0 100644
--- a/arch/x86/include/asm/pgtable_32.h
+++ b/arch/x86/include/asm/pgtable_32.h
@@ -32,6 +32,8 @@ static inline void pgtable_cache_init(void) { }
 static inline void check_pgt_cache(void) { }
 void paging_init(void);
 
+static inline int pgd_large(pgd_t pgd) { return 0; }
+
 /*
  * Define this if things work differently on an i386 and an i486:
  * it will (on an i486) warn about kernel memory accesses that are
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index a9f77ead7088..a09f2fa91e09 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -19,6 +19,9 @@ typedef unsigned long	pgprotval_t;
 
 typedef struct { pteval_t pte; } pte_t;
 
+extern unsigned int pgdir_shift;
+extern unsigned int ptrs_per_p4d;
+
 #endif	/* !__ASSEMBLY__ */
 
 #define SHARED_KERNEL_PMD	0
@@ -28,14 +31,14 @@ typedef struct { pteval_t pte; } pte_t;
 /*
  * PGDIR_SHIFT determines what a top-level page table entry can map
  */
-#define PGDIR_SHIFT	48
+#define PGDIR_SHIFT	pgdir_shift
 #define PTRS_PER_PGD	512
 
 /*
  * 4th level page in 5-level paging case
  */
 #define P4D_SHIFT	39
-#define PTRS_PER_P4D	512
+#define PTRS_PER_P4D	ptrs_per_p4d
 #define P4D_SIZE	(_AC(1, UL) << P4D_SHIFT)
 #define P4D_MASK	(~(P4D_SIZE - 1))
 
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 408ed402db1a..d4e8d4beeb62 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -38,6 +38,13 @@ extern pmd_t early_dynamic_pgts[EARLY_DYNAMIC_PAGE_TABLES][PTRS_PER_PMD];
 static unsigned int __initdata next_early_pgt;
 pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
 
+#ifdef CONFIG_X86_5LEVEL
+unsigned int pgdir_shift = 48;
+EXPORT_SYMBOL(pgdir_shift);
+unsigned int ptrs_per_p4d = 512;
+EXPORT_SYMBOL(ptrs_per_p4d);
+#endif
+
 #if defined(CONFIG_RANDOMIZE_MEMORY) || defined(CONFIG_X86_5LEVEL)
 unsigned long page_offset_base = __PAGE_OFFSET_BASE;
 EXPORT_SYMBOL(page_offset_base);
@@ -273,7 +280,7 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 	BUILD_BUG_ON((__START_KERNEL_map & ~PMD_MASK) != 0);
 	BUILD_BUG_ON((MODULES_VADDR & ~PMD_MASK) != 0);
 	BUILD_BUG_ON(!(MODULES_VADDR > __START_KERNEL));
-	BUILD_BUG_ON(!(((MODULES_END - 1) & PGDIR_MASK) ==
+	MAYBE_BUILD_BUG_ON(!(((MODULES_END - 1) & PGDIR_MASK) ==
 				(__START_KERNEL & PGDIR_MASK)));
 	BUILD_BUG_ON(__fix_to_virt(__end_of_fixed_addresses) <= MODULES_END);
 
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 0470826d2bdc..d7b3cf2320fd 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -380,14 +380,15 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr,
 #define p4d_none(a)  pud_none(__pud(p4d_val(a)))
 #endif
 
-#if PTRS_PER_P4D > 1
-
 static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr, unsigned long P)
 {
 	int i;
 	p4d_t *start;
 	pgprotval_t prot;
 
+	if (PTRS_PER_P4D > 1)
+		return walk_pud_level(m, st, __p4d(pgd_val(addr)), P);
+
 	start = (p4d_t *)pgd_page_vaddr(addr);
 
 	for (i = 0; i < PTRS_PER_P4D; i++) {
@@ -407,12 +408,6 @@ static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
 	}
 }
 
-#else
-#define walk_p4d_level(m,s,a,p) walk_pud_level(m,s,__p4d(pgd_val(a)),p)
-#define pgd_large(a) p4d_large(__p4d(pgd_val(a)))
-#define pgd_none(a)  p4d_none(__p4d(pgd_val(a)))
-#endif
-
 static inline bool is_hypervisor_range(int idx)
 {
 #ifdef CONFIG_X86_64
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 124f1a77c181..d135c613bf7b 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -143,7 +143,7 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 		 * With folded p4d, pgd_none() is always false, we need to
 		 * handle synchonization on p4d level.
 		 */
-		BUILD_BUG_ON(pgd_none(*pgd_ref));
+		MAYBE_BUILD_BUG_ON(pgd_none(*pgd_ref));
 		p4d_ref = p4d_offset(pgd_ref, addr);
 
 		if (p4d_none(*p4d_ref))
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index c488625c9712..d6cfba3e164f 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -186,8 +186,8 @@ void efi_sync_low_kernel_mappings(void)
 	 * only span a single PGD entry and that the entry also maps
 	 * other important kernel regions.
 	 */
-	BUILD_BUG_ON(pgd_index(EFI_VA_END) != pgd_index(MODULES_END));
-	BUILD_BUG_ON((EFI_VA_START & PGDIR_MASK) !=
+	MAYBE_BUILD_BUG_ON(pgd_index(EFI_VA_END) != pgd_index(MODULES_END));
+	MAYBE_BUILD_BUG_ON((EFI_VA_START & PGDIR_MASK) !=
 			(EFI_VA_END & PGDIR_MASK));
 
 	pgd_efi = efi_pgd + pgd_index(PAGE_OFFSET);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
