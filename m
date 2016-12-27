Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA006B026B
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:54:48 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g1so737184102pgn.3
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 17:54:48 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id r7si44810019ple.282.2016.12.26.17.54.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 17:54:47 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 20/29] x86/mm: basic defines/helpers for CONFIG_X86_5LEVEL
Date: Tue, 27 Dec 2016 04:54:04 +0300
Message-Id: <20161227015413.187403-21-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Extends pagetable headers to support new paging mode.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable_64.h       | 11 +++++++++++
 arch/x86/include/asm/pgtable_64_types.h | 20 +++++++++++++++++++
 arch/x86/include/asm/pgtable_types.h    | 10 +++++++++-
 arch/x86/mm/pgtable.c                   | 34 ++++++++++++++++++++++++++++++++-
 4 files changed, 73 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index dff070a6d27e..2c04ac6f6fe8 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -35,6 +35,13 @@ extern void paging_init(void);
 #define pud_ERROR(e)					\
 	pr_err("%s:%d: bad pud %p(%016lx)\n",		\
 	       __FILE__, __LINE__, &(e), pud_val(e))
+
+#if CONFIG_PGTABLE_LEVELS >= 5
+#define p4d_ERROR(e)					\
+	pr_err("%s:%d: bad p4d %p(%016lx)\n",		\
+	       __FILE__, __LINE__, &(e), p4d_val(e))
+#endif
+
 #define pgd_ERROR(e)					\
 	pr_err("%s:%d: bad pgd %p(%016lx)\n",		\
 	       __FILE__, __LINE__, &(e), pgd_val(e))
@@ -113,7 +120,11 @@ static inline void native_set_p4d(p4d_t *p4dp, p4d_t p4d)
 
 static inline void native_p4d_clear(p4d_t *p4d)
 {
+#ifdef CONFIG_X86_5LEVEL
+	native_set_p4d(p4d, native_make_p4d(0));
+#else
 	native_set_p4d(p4d, (p4d_t) { .pgd = native_make_pgd(0)});
+#endif
 }
 
 static inline void native_set_pgd(pgd_t *pgdp, pgd_t pgd)
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 00dc0c2b456e..7ae641fdbd07 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -23,12 +23,32 @@ typedef struct { pteval_t pte; } pte_t;
 
 #define SHARED_KERNEL_PMD	0
 
+#ifdef CONFIG_X86_5LEVEL
+
+/*
+ * PGDIR_SHIFT determines what a top-level page table entry can map
+ */
+#define PGDIR_SHIFT	48
+#define PTRS_PER_PGD	512
+
+/*
+ * 4rd level page in 5-level paging case
+ */
+#define P4D_SHIFT	39
+#define PTRS_PER_P4D	512
+#define P4D_SIZE	(_AC(1, UL) << P4D_SHIFT)
+#define P4D_MASK	(~(P4D_SIZE - 1))
+
+#else  /* CONFIG_X86_5LEVEL */
+
 /*
  * PGDIR_SHIFT determines what a top-level page table entry can map
  */
 #define PGDIR_SHIFT	39
 #define PTRS_PER_PGD	512
 
+#endif  /* CONFIG_X86_5LEVEL */
+
 /*
  * 3rd level page
  */
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 4930afe9df0a..bf9638e1ee42 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -273,9 +273,17 @@ static inline pgdval_t pgd_flags(pgd_t pgd)
 }
 
 #if CONFIG_PGTABLE_LEVELS > 4
+typedef struct { p4dval_t p4d; } p4d_t;
 
-#error FIXME
+static inline p4d_t native_make_p4d(pudval_t val)
+{
+	return (p4d_t) { val };
+}
 
+static inline p4dval_t native_p4d_val(p4d_t p4d)
+{
+	return p4d.p4d;
+}
 #else
 #include <asm-generic/pgtable-nop4d.h>
 
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index cc6fcd4040e2..ec2dc0625480 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -81,6 +81,14 @@ void ___pud_free_tlb(struct mmu_gather *tlb, pud_t *pud)
 	paravirt_release_pud(__pa(pud) >> PAGE_SHIFT);
 	tlb_remove_page(tlb, virt_to_page(pud));
 }
+
+#if CONFIG_PGTABLE_LEVELS > 4
+void ___p4d_free_tlb(struct mmu_gather *tlb, p4d_t *p4d)
+{
+	paravirt_release_p4d(__pa(p4d) >> PAGE_SHIFT);
+	tlb_remove_page(tlb, virt_to_page(p4d));
+}
+#endif	/* CONFIG_PGTABLE_LEVELS > 4 */
 #endif	/* CONFIG_PGTABLE_LEVELS > 3 */
 #endif	/* CONFIG_PGTABLE_LEVELS > 2 */
 
@@ -120,7 +128,7 @@ static void pgd_ctor(struct mm_struct *mm, pgd_t *pgd)
 	   references from swapper_pg_dir. */
 	if (CONFIG_PGTABLE_LEVELS == 2 ||
 	    (CONFIG_PGTABLE_LEVELS == 3 && SHARED_KERNEL_PMD) ||
-	    CONFIG_PGTABLE_LEVELS == 4) {
+	    CONFIG_PGTABLE_LEVELS >= 4) {
 		clone_pgd_range(pgd + KERNEL_PGD_BOUNDARY,
 				swapper_pg_dir + KERNEL_PGD_BOUNDARY,
 				KERNEL_PGD_PTRS);
@@ -551,6 +559,30 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
 }
 
 #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+#ifdef CONFIG_X86_5LEVEL
+/**
+ * p4d_set_huge - setup kernel P4D mapping
+ *
+ * No 512GB pages yet -- always return 0
+ *
+ * Returns 1 on success and 0 on failure.
+ */
+int p4d_set_huge(p4d_t *p4d, phys_addr_t addr, pgprot_t prot)
+{
+	return 0;
+}
+
+/**
+ * p4d_clear_huge - clear kernel P4D mapping when it is set
+ *
+ * No 512GB pages yet -- always return 0
+ */
+int p4d_clear_huge(p4d_t *p4d)
+{
+	return 0;
+}
+#endif
+
 /**
  * pud_set_huge - setup kernel PUD mapping
  *
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
