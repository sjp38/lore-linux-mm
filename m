Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E920E6B02A4
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:24:06 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id n185so193137049qke.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:24:06 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id q54si14804583qte.113.2016.09.26.08.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:24:06 -0700 (PDT)
From: zi.yan@sent.com
Subject: [PATCH v1 02/12] mm: thp: introduce CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
Date: Mon, 26 Sep 2016 11:22:24 -0400
Message-Id: <20160926152234.14809-3-zi.yan@sent.com>
In-Reply-To: <20160926152234.14809-1-zi.yan@sent.com>
References: <20160926152234.14809-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Introduces CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION to limit thp migration
functionality to x86_64, which should be safer at the first step.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/x86/Kconfig        |  4 ++++
 include/linux/huge_mm.h | 10 ++++++++++
 mm/Kconfig              |  3 +++
 3 files changed, 17 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2a1f0ce..ad99c05 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2234,6 +2234,10 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 	def_bool y
 	depends on X86_64 && HUGETLB_PAGE && MIGRATION
 
+config ARCH_ENABLE_THP_MIGRATION
+	def_bool y
+	depends on X86_64 && TRANSPARENT_HUGEPAGE && MIGRATION
+
 menu "Power management and ACPI options"
 
 config ARCH_HIBERNATION_HEADER
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 6f14de4..4ae156e 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -157,6 +157,11 @@ void put_huge_zero_page(void);
 
 #define mk_huge_pmd(page, prot) pmd_mkhuge(mk_pmd(page, prot))
 
+static inline bool thp_migration_supported(void)
+{
+	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
+}
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -223,6 +228,11 @@ static inline struct page *follow_devmap_pmd(struct vm_area_struct *vma,
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
index be0ee11..1965310 100644
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
