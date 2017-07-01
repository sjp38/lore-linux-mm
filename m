Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id ADE936B02F4
	for <linux-mm@kvack.org>; Sat,  1 Jul 2017 09:40:52 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p45so39207887qtg.11
        for <linux-mm@kvack.org>; Sat, 01 Jul 2017 06:40:52 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id 24si10302327qkv.314.2017.07.01.06.40.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jul 2017 06:40:51 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v8 04/10] mm: thp: introduce CONFIG_ARCH_ENABLE_THP_MIGRATION
Date: Sat,  1 Jul 2017 09:40:02 -0400
Message-Id: <20170701134008.110579-5-zi.yan@sent.com>
In-Reply-To: <20170701134008.110579-1-zi.yan@sent.com>
References: <20170701134008.110579-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Introduces CONFIG_ARCH_ENABLE_THP_MIGRATION to limit thp migration
functionality to x86_64, which should be safer at the first step.

ChangeLog v1 -> v2:
- fixed config name in subject and patch description

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/x86/Kconfig        |  4 ++++
 include/linux/huge_mm.h | 10 ++++++++++
 mm/Kconfig              |  3 +++
 3 files changed, 17 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index b6373817e6f4..631af221ce63 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2276,6 +2276,10 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 	def_bool y
 	depends on X86_64 && HUGETLB_PAGE && MIGRATION
 
+config ARCH_ENABLE_THP_MIGRATION
+	def_bool y
+	depends on X86_64 && TRANSPARENT_HUGEPAGE
+
 menu "Power management and ACPI options"
 
 config ARCH_HIBERNATION_HEADER
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ee696347f928..d8f35a0865dc 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -233,6 +233,11 @@ void mm_put_huge_zero_page(struct mm_struct *mm);
 
 #define mk_huge_pmd(page, prot) pmd_mkhuge(mk_pmd(page, prot))
 
+static inline bool thp_migration_supported(void)
+{
+	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
+}
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -336,6 +341,11 @@ static inline struct page *follow_devmap_pud(struct vm_area_struct *vma,
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
index 9bf2055ed061..6634e0ed5c1b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -262,6 +262,9 @@ config MIGRATION
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
