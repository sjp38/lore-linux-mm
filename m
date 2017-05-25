Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A68A6B02F3
	for <linux-mm@kvack.org>; Thu, 25 May 2017 10:19:56 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v195so82456670qka.1
        for <linux-mm@kvack.org>; Thu, 25 May 2017 07:19:56 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id 10si3078902qtf.238.2017.05.25.07.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 07:19:55 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v6 04/10] mm: thp: introduce CONFIG_ARCH_ENABLE_THP_MIGRATION
Date: Thu, 25 May 2017 10:19:39 -0400
Message-Id: <20170525141945.56028-5-zi.yan@sent.com>
In-Reply-To: <20170525141945.56028-1-zi.yan@sent.com>
References: <20170525141945.56028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com, dave.hansen@intel.com

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
index d3b3e8fcc717..93635a6e32b0 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -213,6 +213,11 @@ void mm_put_huge_zero_page(struct mm_struct *mm);
 
 #define mk_huge_pmd(page, prot) pmd_mkhuge(mk_pmd(page, prot))
 
+static inline bool thp_migration_supported(void)
+{
+	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
+}
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -313,6 +318,11 @@ static inline struct page *follow_devmap_pud(struct vm_area_struct *vma,
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
index 0354a4be5a55..1cc90f52ac07 100644
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
