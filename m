Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A16F26B0006
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:02:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f19so10149893pfn.6
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:02:40 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id t131si10741997pgc.664.2018.04.16.19.02.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 19:02:39 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 01/21] mm, THP, swap: Enable PMD swap operations for CONFIG_THP_SWAP
Date: Tue, 17 Apr 2018 10:02:10 +0800
Message-Id: <20180417020230.26412-2-ying.huang@intel.com>
In-Reply-To: <20180417020230.26412-1-ying.huang@intel.com>
References: <20180417020230.26412-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

Previously, the PMD swap operations are only enabled for
CONFIG_ARCH_ENABLE_THP_MIGRATION.  Because they are only used by the
THP migration support.  We will support PMD swap mapping to the huge
swap cluster and swapin the THP as a whole.  That will be enabled via
CONFIG_THP_SWAP and needs these PMD swap operations.  So enable the
PMD swap operations for CONFIG_THP_SWAP too.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
---
 arch/x86/include/asm/pgtable.h |  2 +-
 include/asm-generic/pgtable.h  |  2 +-
 include/linux/swapops.h        | 44 ++++++++++++++++++----------------
 3 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 5f49b4ff0c24..4b4398253528 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1219,7 +1219,7 @@ static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
 	return pte_clear_flags(pte, _PAGE_SWP_SOFT_DIRTY);
 }
 
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+#if defined(CONFIG_ARCH_ENABLE_THP_MIGRATION) || defined(CONFIG_THP_SWAP)
 static inline pmd_t pmd_swp_mksoft_dirty(pmd_t pmd)
 {
 	return pmd_set_flags(pmd, _PAGE_SWP_SOFT_DIRTY);
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index f59639afaa39..bb8354981a36 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -675,7 +675,7 @@ static inline void ptep_modify_prot_commit(struct mm_struct *mm,
 #endif
 
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
-#ifndef CONFIG_ARCH_ENABLE_THP_MIGRATION
+#if !defined(CONFIG_ARCH_ENABLE_THP_MIGRATION) && !defined(CONFIG_THP_SWAP)
 static inline pmd_t pmd_swp_mksoft_dirty(pmd_t pmd)
 {
 	return pmd;
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 1d3877c39a00..f1be5a52f5c8 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -258,17 +258,7 @@ static inline int is_write_migration_entry(swp_entry_t entry)
 
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
+#if defined(CONFIG_ARCH_ENABLE_THP_MIGRATION) || defined(CONFIG_THP_SWAP)
 static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
 {
 	swp_entry_t arch_entry;
@@ -286,6 +276,28 @@ static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
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
@@ -306,16 +318,6 @@ static inline void remove_migration_pmd(struct page_vma_mapped_walk *pvmw,
 
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
-- 
2.17.0
