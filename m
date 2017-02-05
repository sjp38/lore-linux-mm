Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC6186B0266
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 11:14:34 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id w20so70907833qtb.3
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 08:14:34 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id g41si23299832qtb.257.2017.02.05.08.14.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Feb 2017 08:14:34 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v3 07/14] mm: thp: introduce CONFIG_ARCH_ENABLE_THP_MIGRATION
Date: Sun,  5 Feb 2017 11:12:45 -0500
Message-Id: <20170205161252.85004-8-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-1-zi.yan@sent.com>
References: <20170205161252.85004-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Introduces CONFIG_ARCH_ENABLE_THP_MIGRATION to limit thp migration
functionality to x86_64, which should be safer at the first step.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
v1 -> v2:
- fixed config name in subject and patch description
---
 arch/x86/Kconfig        |  4 ++++
 include/linux/huge_mm.h | 10 ++++++++++
 mm/Kconfig              |  3 +++
 3 files changed, 17 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 3d7cd097e827..d9683ca904e0 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2247,6 +2247,10 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 	def_bool y
 	depends on X86_64 && HUGETLB_PAGE && MIGRATION
 
+config ARCH_ENABLE_THP_MIGRATION
+	def_bool y
+	depends on X86_64 && TRANSPARENT_HUGEPAGE && MIGRATION
+
 menu "Power management and ACPI options"
 
 config ARCH_HIBERNATION_HEADER
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 44ee130c7207..83a8d42f9d55 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -217,6 +217,11 @@ void mm_put_huge_zero_page(struct mm_struct *mm);
 
 #define mk_huge_pmd(page, prot) pmd_mkhuge(mk_pmd(page, prot))
 
+static inline bool thp_migration_supported(void)
+{
+	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
+}
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -311,6 +316,11 @@ static inline struct page *follow_devmap_pud(struct vm_area_struct *vma,
 {
 	return NULL;
 }
+
+static inline bool thp_migration_supported(void)
+{
+	return false;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index 85c74e0efc52..165cd7f2e9a4 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -289,6 +289,9 @@ config MIGRATION
 config ARCH_ENABLE_HUGEPAGE_MIGRATION
 	bool
 
+config ARCH_ENABLE_THP_MIGRATION
+	bool
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
