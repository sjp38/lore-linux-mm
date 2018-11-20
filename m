Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D46F06B1F31
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 03:54:59 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id az10so932315plb.11
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 00:54:59 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b15si24149550plm.431.2018.11.20.00.54.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 00:54:58 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V7 RESEND 01/21] swap: Enable PMD swap operations for CONFIG_THP_SWAP
Date: Tue, 20 Nov 2018 16:54:29 +0800
Message-Id: <20181120085449.5542-2-ying.huang@intel.com>
In-Reply-To: <20181120085449.5542-1-ying.huang@intel.com>
References: <20181120085449.5542-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Currently, "the swap entry" in the page tables is used for a number of
things outside of actual swap, like page migration, etc.  We support
the THP/PMD "swap entry" for page migration currently and the
functions behind this are tied to page migration's config
option (CONFIG_ARCH_ENABLE_THP_MIGRATION).

But, we also need them for THP swap optimization.  So a new config
option (CONFIG_HAVE_PMD_SWAP_ENTRY) is added.  It is enabled when
either CONFIG_ARCH_ENABLE_THP_MIGRATION or CONFIG_THP_SWAP is enabled.
And PMD swap entry functions are tied to this new config option
instead.  Some functions enabled by CONFIG_ARCH_ENABLE_THP_MIGRATION
are for page migration only, they are still enabled only for that.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 arch/x86/include/asm/pgtable.h |  2 +-
 include/asm-generic/pgtable.h  |  2 +-
 include/linux/swapops.h        | 44 ++++++++++++++++++----------------
 mm/Kconfig                     |  8 +++++++
 4 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 40616e805292..e830ab345551 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1333,7 +1333,7 @@ static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
 	return pte_clear_flags(pte, _PAGE_SWP_SOFT_DIRTY);
 }
 
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+#ifdef CONFIG_HAVE_PMD_SWAP_ENTRY
 static inline pmd_t pmd_swp_mksoft_dirty(pmd_t pmd)
 {
 	return pmd_set_flags(pmd, _PAGE_SWP_SOFT_DIRTY);
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 359fb935ded6..20aab7bfd487 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -675,7 +675,7 @@ static inline void ptep_modify_prot_commit(struct mm_struct *mm,
 #endif
 
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
-#ifndef CONFIG_ARCH_ENABLE_THP_MIGRATION
+#ifndef CONFIG_HAVE_PMD_SWAP_ENTRY
 static inline pmd_t pmd_swp_mksoft_dirty(pmd_t pmd)
 {
 	return pmd;
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 4d961668e5fc..905ddc65caa3 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -254,17 +254,7 @@ static inline int is_write_migration_entry(swp_entry_t entry)
 
 #endif
 
-struct page_vma_mapped_walk;
-
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
-extern void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
-		struct page *page);
-
-extern void remove_migration_pmd(struct page_vma_mapped_walk *pvmw,
-		struct page *new);
-
-extern void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd);
-
+#ifdef CONFIG_HAVE_PMD_SWAP_ENTRY
 static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
 {
 	swp_entry_t arch_entry;
@@ -282,6 +272,28 @@ static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
 	arch_entry = __swp_entry(swp_type(entry), swp_offset(entry));
 	return __swp_entry_to_pmd(arch_entry);
 }
+#else
+static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
+{
+	return swp_entry(0, 0);
+}
+
+static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
+{
+	return __pmd(0);
+}
+#endif
+
+struct page_vma_mapped_walk;
+
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+extern void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
+		struct page *page);
+
+extern void remove_migration_pmd(struct page_vma_mapped_walk *pvmw,
+		struct page *new);
+
+extern void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd);
 
 static inline int is_pmd_migration_entry(pmd_t pmd)
 {
@@ -302,16 +314,6 @@ static inline void remove_migration_pmd(struct page_vma_mapped_walk *pvmw,
 
 static inline void pmd_migration_entry_wait(struct mm_struct *m, pmd_t *p) { }
 
-static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
-{
-	return swp_entry(0, 0);
-}
-
-static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
-{
-	return __pmd(0);
-}
-
 static inline int is_pmd_migration_entry(pmd_t pmd)
 {
 	return 0;
diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb8a7db..d7c5299c5b7d 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -422,6 +422,14 @@ config THP_SWAP
 
 	  For selection by architectures with reasonable THP sizes.
 
+#
+# "PMD swap entry" in the page table is used both for migration and
+# actual swap.
+#
+config HAVE_PMD_SWAP_ENTRY
+	def_bool y
+	depends on THP_SWAP || ARCH_ENABLE_THP_MIGRATION
+
 config	TRANSPARENT_HUGE_PAGECACHE
 	def_bool y
 	depends on TRANSPARENT_HUGEPAGE
-- 
2.18.1
