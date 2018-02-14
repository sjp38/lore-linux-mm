Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB83C6B0009
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 06:17:17 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p20so5375023pfh.17
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 03:17:17 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id j75si2238413pgc.156.2018.02.14.03.17.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 03:17:16 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 6/9] x86/mm: Make PGDIR_SHIFT and PTRS_PER_P4D variable
Date: Wed, 14 Feb 2018 14:16:53 +0300
Message-Id: <20180214111656.88514-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
References: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For boot-time switching between 4- and 5-level paging we need to be able
to fold p4d page table level at runtime. It requires variable
PGDIR_SHIFT and PTRS_PER_P4D.

The change doesn't affect the kernel image size much:

   text	   data	    bss	    dec	    hex	filename
8628091	4734304	1368064	14730459	 e0c4db	vmlinux.before
8628393	4734340	1368064	14730797	 e0c62d	vmlinux.after

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/kaslr.c        |  2 ++
 arch/x86/include/asm/pgtable_32.h       |  2 ++
 arch/x86/include/asm/pgtable_64_types.h | 19 ++++++++++++-------
 arch/x86/kernel/cpu/mcheck/mce.c        | 18 ++++++------------
 arch/x86/kernel/head64.c                |  6 +++++-
 arch/x86/mm/dump_pagetables.c           | 12 +++++-------
 arch/x86/mm/init_64.c                   |  2 +-
 arch/x86/mm/kasan_init_64.c             |  2 +-
 arch/x86/platform/efi/efi_64.c          |  4 ++--
 include/asm-generic/5level-fixup.h      |  1 +
 include/asm-generic/pgtable-nop4d.h     |  9 +++++----
 include/linux/kasan.h                   |  2 +-
 mm/kasan/kasan_init.c                   |  2 +-
 13 files changed, 44 insertions(+), 37 deletions(-)

diff --git a/arch/x86/boot/compressed/kaslr.c b/arch/x86/boot/compressed/kaslr.c
index bd69e1830fbe..b18e8f9512de 100644
--- a/arch/x86/boot/compressed/kaslr.c
+++ b/arch/x86/boot/compressed/kaslr.c
@@ -48,6 +48,8 @@
 
 #ifdef CONFIG_X86_5LEVEL
 unsigned int pgtable_l5_enabled __ro_after_init = 1;
+unsigned int pgdir_shift __ro_after_init = 48;
+unsigned int ptrs_per_p4d __ro_after_init = 512;
 #endif
 
 extern unsigned long get_cmd_line_ptr(void);
diff --git a/arch/x86/include/asm/pgtable_32.h b/arch/x86/include/asm/pgtable_32.h
index e55466760ff8..b838c51d8c78 100644
--- a/arch/x86/include/asm/pgtable_32.h
+++ b/arch/x86/include/asm/pgtable_32.h
@@ -33,6 +33,8 @@ static inline void pgtable_cache_init(void) { }
 static inline void check_pgt_cache(void) { }
 void paging_init(void);
 
+static inline int pgd_large(pgd_t pgd) { return 0; }
+
 /*
  * Define this if things work differently on an i386 and an i486:
  * it will (on an i486) warn about kernel memory accesses that are
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 903e4d054bcb..0c48d80e11d4 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -26,6 +26,9 @@ extern unsigned int pgtable_l5_enabled;
 #define pgtable_l5_enabled 0
 #endif
 
+extern unsigned int pgdir_shift;
+extern unsigned int ptrs_per_p4d;
+
 #endif	/* !__ASSEMBLY__ */
 
 #define SHARED_KERNEL_PMD	0
@@ -35,16 +38,17 @@ extern unsigned int pgtable_l5_enabled;
 /*
  * PGDIR_SHIFT determines what a top-level page table entry can map
  */
-#define PGDIR_SHIFT	48
+#define PGDIR_SHIFT	pgdir_shift
 #define PTRS_PER_PGD	512
 
 /*
  * 4th level page in 5-level paging case
  */
-#define P4D_SHIFT	39
-#define PTRS_PER_P4D	512
-#define P4D_SIZE	(_AC(1, UL) << P4D_SHIFT)
-#define P4D_MASK	(~(P4D_SIZE - 1))
+#define P4D_SHIFT		39
+#define MAX_PTRS_PER_P4D	512
+#define PTRS_PER_P4D		ptrs_per_p4d
+#define P4D_SIZE		(_AC(1, UL) << P4D_SHIFT)
+#define P4D_MASK		(~(P4D_SIZE - 1))
 
 #define MAX_POSSIBLE_PHYSMEM_BITS	52
 
@@ -53,8 +57,9 @@ extern unsigned int pgtable_l5_enabled;
 /*
  * PGDIR_SHIFT determines what a top-level page table entry can map
  */
-#define PGDIR_SHIFT	39
-#define PTRS_PER_PGD	512
+#define PGDIR_SHIFT		39
+#define PTRS_PER_PGD		512
+#define MAX_PTRS_PER_P4D	1
 
 #endif /* CONFIG_X86_5LEVEL */
 
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index 8ff94d1e2dce..3d8c573a9a27 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -1088,19 +1088,7 @@ static void mce_unmap_kpfn(unsigned long pfn)
 	 * a legal address.
 	 */
 
-/*
- * Build time check to see if we have a spare virtual bit. Don't want
- * to leave this until run time because most developers don't have a
- * system that can exercise this code path. This will only become a
- * problem if/when we move beyond 5-level page tables.
- *
- * Hard code "9" here because cpp doesn't grok ilog2(PTRS_PER_PGD)
- */
-#if PGDIR_SHIFT + 9 < 63
 	decoy_addr = (pfn << PAGE_SHIFT) + (PAGE_OFFSET ^ BIT(63));
-#else
-#error "no unused virtual bit available"
-#endif
 
 	if (set_memory_np(decoy_addr, 1))
 		pr_warn("Could not invalidate pfn=0x%lx from 1:1 map\n", pfn);
@@ -2333,6 +2321,12 @@ static __init int mcheck_init_device(void)
 {
 	int err;
 
+	/*
+	 * Check if we have a spare virtual bit. This will only become
+	 * a problem if/when we move beyond 5-level page tables.
+	 */
+	MAYBE_BUILD_BUG_ON(__VIRTUAL_MASK_SHIFT >= 63);
+
 	if (!mce_available(&boot_cpu_data)) {
 		err = -EIO;
 		goto err_out;
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 17d00d1886de..98b0ff49b220 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -42,6 +42,10 @@ pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
 #ifdef CONFIG_X86_5LEVEL
 unsigned int pgtable_l5_enabled __ro_after_init = 1;
 EXPORT_SYMBOL(pgtable_l5_enabled);
+unsigned int pgdir_shift __ro_after_init = 48;
+EXPORT_SYMBOL(pgdir_shift);
+unsigned int ptrs_per_p4d __ro_after_init = 512;
+EXPORT_SYMBOL(ptrs_per_p4d);
 #endif
 
 #ifdef CONFIG_DYNAMIC_MEMORY_LAYOUT
@@ -336,7 +340,7 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 	BUILD_BUG_ON((__START_KERNEL_map & ~PMD_MASK) != 0);
 	BUILD_BUG_ON((MODULES_VADDR & ~PMD_MASK) != 0);
 	BUILD_BUG_ON(!(MODULES_VADDR > __START_KERNEL));
-	BUILD_BUG_ON(!(((MODULES_END - 1) & PGDIR_MASK) ==
+	MAYBE_BUILD_BUG_ON(!(((MODULES_END - 1) & PGDIR_MASK) ==
 				(__START_KERNEL & PGDIR_MASK)));
 	BUILD_BUG_ON(__fix_to_virt(__end_of_fixed_addresses) <= MODULES_END);
 
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index a89f2dbc3531..420058b05d39 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -428,14 +428,15 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr,
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
@@ -455,11 +456,8 @@ static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
 	}
 }
 
-#else
-#define walk_p4d_level(m,s,a,p) walk_pud_level(m,s,__p4d(pgd_val(a)),p)
-#define pgd_large(a) p4d_large(__p4d(pgd_val(a)))
-#define pgd_none(a)  p4d_none(__p4d(pgd_val(a)))
-#endif
+#define pgd_large(a) (pgtable_l5_enabled ? pgd_large(a) : p4d_large(__p4d(pgd_val(a))))
+#define pgd_none(a)  (pgtable_l5_enabled ? pgd_none(a) : p4d_none(__p4d(pgd_val(a))))
 
 static inline bool is_hypervisor_range(int idx)
 {
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 8b72923f1d35..c90cfb18405f 100644
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
index af6f2f9c6a26..12ec90f62457 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -19,7 +19,7 @@
 
 extern struct range pfn_mapped[E820_MAX_ENTRIES];
 
-static p4d_t tmp_p4d_table[PTRS_PER_P4D] __initdata __aligned(PAGE_SIZE);
+static p4d_t tmp_p4d_table[MAX_PTRS_PER_P4D] __initdata __aligned(PAGE_SIZE);
 
 static __init void *early_alloc(size_t size, int nid, bool panic)
 {
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index 780460aa5ea5..d52aaa7dc088 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -257,8 +257,8 @@ void efi_sync_low_kernel_mappings(void)
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
index dfbd9d990637..9c2e0708eb82 100644
--- a/include/asm-generic/5level-fixup.h
+++ b/include/asm-generic/5level-fixup.h
@@ -8,6 +8,7 @@
 #define P4D_SHIFT			PGDIR_SHIFT
 #define P4D_SIZE			PGDIR_SIZE
 #define P4D_MASK			PGDIR_MASK
+#define MAX_PTRS_PER_P4D		1
 #define PTRS_PER_P4D			1
 
 #define p4d_t				pgd_t
diff --git a/include/asm-generic/pgtable-nop4d.h b/include/asm-generic/pgtable-nop4d.h
index 8f22f55de17a..1a29b2a0282b 100644
--- a/include/asm-generic/pgtable-nop4d.h
+++ b/include/asm-generic/pgtable-nop4d.h
@@ -8,10 +8,11 @@
 
 typedef struct { pgd_t pgd; } p4d_t;
 
-#define P4D_SHIFT	PGDIR_SHIFT
-#define PTRS_PER_P4D	1
-#define P4D_SIZE	(1UL << P4D_SHIFT)
-#define P4D_MASK	(~(P4D_SIZE-1))
+#define P4D_SHIFT		PGDIR_SHIFT
+#define MAX_PTRS_PER_P4D	1
+#define PTRS_PER_P4D		1
+#define P4D_SIZE		(1UL << P4D_SHIFT)
+#define P4D_MASK		(~(P4D_SIZE-1))
 
 /*
  * The "pgd_xxx()" functions here are trivial for a folded two-level
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index adc13474a53b..d6459bd1376d 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -18,7 +18,7 @@ extern unsigned char kasan_zero_page[PAGE_SIZE];
 extern pte_t kasan_zero_pte[PTRS_PER_PTE];
 extern pmd_t kasan_zero_pmd[PTRS_PER_PMD];
 extern pud_t kasan_zero_pud[PTRS_PER_PUD];
-extern p4d_t kasan_zero_p4d[PTRS_PER_P4D];
+extern p4d_t kasan_zero_p4d[MAX_PTRS_PER_P4D];
 
 void kasan_populate_zero_shadow(const void *shadow_start,
 				const void *shadow_end);
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index 554e4c0f23a2..f436246ccc79 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -31,7 +31,7 @@
 unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
 
 #if CONFIG_PGTABLE_LEVELS > 4
-p4d_t kasan_zero_p4d[PTRS_PER_P4D] __page_aligned_bss;
+p4d_t kasan_zero_p4d[MAX_PTRS_PER_P4D] __page_aligned_bss;
 #endif
 #if CONFIG_PGTABLE_LEVELS > 3
 pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
