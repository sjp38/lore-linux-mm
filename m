Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 33B006B0311
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:54:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b83so31767015pfl.6
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:54:32 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 77si846787pfn.385.2017.08.08.05.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 05:54:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 08/14] x86/mm: Make PGDIR_SHIFT and PTRS_PER_P4D variable
Date: Tue,  8 Aug 2017 15:54:09 +0300
Message-Id: <20170808125415.78842-9-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For boot-time switching between 4- and 5-level paging we need to be able
to fold p4d page table level at runtime. It requires variable
PGDIR_SHIFT and PTRS_PER_P4D.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/kaslr.c        |  5 +++++
 arch/x86/include/asm/pgtable_32.h       |  2 ++
 arch/x86/include/asm/pgtable_32_types.h |  2 ++
 arch/x86/include/asm/pgtable_64_types.h | 15 +++++++++++++--
 arch/x86/kernel/head64.c                |  9 ++++++++-
 arch/x86/mm/dump_pagetables.c           | 12 +++++-------
 arch/x86/mm/init_64.c                   |  2 +-
 arch/x86/mm/kasan_init_64.c             |  2 +-
 arch/x86/platform/efi/efi_64.c          |  4 ++--
 include/asm-generic/5level-fixup.h      |  1 +
 include/asm-generic/pgtable-nop4d.h     |  1 +
 include/linux/kasan.h                   |  2 +-
 mm/kasan/kasan_init.c                   |  2 +-
 13 files changed, 43 insertions(+), 16 deletions(-)

diff --git a/arch/x86/boot/compressed/kaslr.c b/arch/x86/boot/compressed/kaslr.c
index 99c7194f7ea6..f0f53817a8d2 100644
--- a/arch/x86/boot/compressed/kaslr.c
+++ b/arch/x86/boot/compressed/kaslr.c
@@ -43,6 +43,11 @@
 #define STATIC
 #include <linux/decompress/mm.h>
 
+#ifdef CONFIG_X86_5LEVEL
+unsigned int pgdir_shift __read_mostly = 48;
+unsigned int ptrs_per_p4d __read_mostly = 512;
+#endif
+
 extern unsigned long get_cmd_line_ptr(void);
 
 /* Simplified build-specific string for starting entropy. */
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
diff --git a/arch/x86/include/asm/pgtable_32_types.h b/arch/x86/include/asm/pgtable_32_types.h
index 9fb2f2bc8245..8928eac4ef08 100644
--- a/arch/x86/include/asm/pgtable_32_types.h
+++ b/arch/x86/include/asm/pgtable_32_types.h
@@ -14,6 +14,8 @@
 # include <asm/pgtable-2level_types.h>
 #endif
 
+#define p4d_folded 1
+
 #define PGDIR_SIZE	(1UL << PGDIR_SHIFT)
 #define PGDIR_MASK	(~(PGDIR_SIZE - 1))
 
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index a9f77ead7088..a5338b0936ad 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -19,6 +19,15 @@ typedef unsigned long	pgprotval_t;
 
 typedef struct { pteval_t pte; } pte_t;
 
+#ifdef CONFIG_X86_5LEVEL
+#define p4d_folded 0
+#else
+#define p4d_folded 1
+#endif
+
+extern unsigned int pgdir_shift;
+extern unsigned int ptrs_per_p4d;
+
 #endif	/* !__ASSEMBLY__ */
 
 #define SHARED_KERNEL_PMD	0
@@ -28,14 +37,15 @@ typedef struct { pteval_t pte; } pte_t;
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
+#define __PTRS_PER_P4D	512
+#define PTRS_PER_P4D	ptrs_per_p4d
 #define P4D_SIZE	(_AC(1, UL) << P4D_SHIFT)
 #define P4D_MASK	(~(P4D_SIZE - 1))
 
@@ -46,6 +56,7 @@ typedef struct { pteval_t pte; } pte_t;
  */
 #define PGDIR_SHIFT	39
 #define PTRS_PER_PGD	512
+#define __PTRS_PER_P4D	1
 
 #endif /* CONFIG_X86_5LEVEL */
 
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index aa163bda4a29..f05ea8d6b0fa 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -38,6 +38,13 @@ extern pmd_t early_dynamic_pgts[EARLY_DYNAMIC_PAGE_TABLES][PTRS_PER_PMD];
 static unsigned int __initdata next_early_pgt;
 pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
 
+#ifdef CONFIG_X86_5LEVEL
+unsigned int pgdir_shift __read_mostly = 48;
+EXPORT_SYMBOL(pgdir_shift);
+unsigned int ptrs_per_p4d __read_mostly = 512;
+EXPORT_SYMBOL(ptrs_per_p4d);
+#endif
+
 #if defined(CONFIG_RANDOMIZE_MEMORY) || defined(CONFIG_X86_5LEVEL)
 unsigned long page_offset_base __read_mostly = __PAGE_OFFSET_BASE;
 EXPORT_SYMBOL(page_offset_base);
@@ -329,7 +336,7 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 	BUILD_BUG_ON((__START_KERNEL_map & ~PMD_MASK) != 0);
 	BUILD_BUG_ON((MODULES_VADDR & ~PMD_MASK) != 0);
 	BUILD_BUG_ON(!(MODULES_VADDR > __START_KERNEL));
-	BUILD_BUG_ON(!(((MODULES_END - 1) & PGDIR_MASK) ==
+	MAYBE_BUILD_BUG_ON(!(((MODULES_END - 1) & PGDIR_MASK) ==
 				(__START_KERNEL & PGDIR_MASK)));
 	BUILD_BUG_ON(__fix_to_virt(__end_of_fixed_addresses) <= MODULES_END);
 
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 5e3ac6fe6c9e..bad178deffba 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -399,14 +399,15 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr,
 #define p4d_none(a)  pud_none(__pud(p4d_val(a)))
 #endif
 
-#if PTRS_PER_P4D > 1
-
 static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr, unsigned long P)
 {
 	int i;
 	p4d_t *start, *p4d_start;
 	pgprotval_t prot;
 
+	if (PTRS_PER_P4D == 1)
+		return walk_pud_level(m, st, __p4d(pgd_val(addr)), P);
+
 	p4d_start = start = (p4d_t *)pgd_page_vaddr(addr);
 
 	for (i = 0; i < PTRS_PER_P4D; i++) {
@@ -426,11 +427,8 @@ static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
 	}
 }
 
-#else
-#define walk_p4d_level(m,s,a,p) walk_pud_level(m,s,__p4d(pgd_val(a)),p)
-#define pgd_large(a) p4d_large(__p4d(pgd_val(a)))
-#define pgd_none(a)  p4d_none(__p4d(pgd_val(a)))
-#endif
+#define pgd_large(a) (p4d_folded ? p4d_large(__p4d(pgd_val(a))) : pgd_large(a))
+#define pgd_none(a)  (p4d_folded ? p4d_none(__p4d(pgd_val(a))) : pgd_none(a))
 
 static inline bool is_hypervisor_range(int idx)
 {
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 136422d7d539..649b8df485ad 100644
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
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index f6b4db2647b5..e1e2cca88567 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -15,7 +15,7 @@
 
 extern struct range pfn_mapped[E820_MAX_ENTRIES];
 
-static p4d_t tmp_p4d_table[PTRS_PER_P4D] __initdata __aligned(PAGE_SIZE);
+static p4d_t tmp_p4d_table[__PTRS_PER_P4D] __initdata __aligned(PAGE_SIZE);
 
 static int __init map_range(struct range *range)
 {
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index 12e83888e5b9..970a0f5f787d 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -249,8 +249,8 @@ void efi_sync_low_kernel_mappings(void)
 	 * only span a single PGD entry and that the entry also maps
 	 * other important kernel regions.
 	 */
-	BUILD_BUG_ON(pgd_index(EFI_VA_END) != pgd_index(MODULES_END));
-	BUILD_BUG_ON((EFI_VA_START & PGDIR_MASK) !=
+	MAYBE_BUILD_BUG_ON(pgd_index(EFI_VA_END) != pgd_index(MODULES_END));
+	MAYBE_BUILD_BUG_ON((EFI_VA_START & PGDIR_MASK) !=
 			(EFI_VA_END & PGDIR_MASK));
 
 	pgd_efi = efi_pgd + pgd_index(PAGE_OFFSET);
diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/5level-fixup.h
index b5ca82dc4175..e9fcfc6b2518 100644
--- a/include/asm-generic/5level-fixup.h
+++ b/include/asm-generic/5level-fixup.h
@@ -7,6 +7,7 @@
 #define P4D_SHIFT			PGDIR_SHIFT
 #define P4D_SIZE			PGDIR_SIZE
 #define P4D_MASK			PGDIR_MASK
+#define __PTRS_PER_P4D			1
 #define PTRS_PER_P4D			1
 
 #define p4d_t				pgd_t
diff --git a/include/asm-generic/pgtable-nop4d.h b/include/asm-generic/pgtable-nop4d.h
index de364ecb8df6..99cb2fa61cef 100644
--- a/include/asm-generic/pgtable-nop4d.h
+++ b/include/asm-generic/pgtable-nop4d.h
@@ -8,6 +8,7 @@
 typedef struct { pgd_t pgd; } p4d_t;
 
 #define P4D_SHIFT	PGDIR_SHIFT
+#define __PTRS_PER_P4D	1
 #define PTRS_PER_P4D	1
 #define P4D_SIZE	(1UL << P4D_SHIFT)
 #define P4D_MASK	(~(P4D_SIZE-1))
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index a5c7046f26b4..d27787ab2b84 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -19,7 +19,7 @@ extern unsigned char kasan_zero_page[PAGE_SIZE];
 extern pte_t kasan_zero_pte[PTRS_PER_PTE];
 extern pmd_t kasan_zero_pmd[PTRS_PER_PMD];
 extern pud_t kasan_zero_pud[PTRS_PER_PUD];
-extern p4d_t kasan_zero_p4d[PTRS_PER_P4D];
+extern p4d_t kasan_zero_p4d[__PTRS_PER_P4D];
 
 void kasan_populate_zero_shadow(const void *shadow_start,
 				const void *shadow_end);
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index 554e4c0f23a2..419e0d33f9be 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -31,7 +31,7 @@
 unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
 
 #if CONFIG_PGTABLE_LEVELS > 4
-p4d_t kasan_zero_p4d[PTRS_PER_P4D] __page_aligned_bss;
+p4d_t kasan_zero_p4d[__PTRS_PER_P4D] __page_aligned_bss;
 #endif
 #if CONFIG_PGTABLE_LEVELS > 3
 pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
