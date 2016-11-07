Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE4866B0260
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 18:32:17 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so58171626pfx.1
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:32:17 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id s136si33494699pgc.65.2016.11.07.15.32.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:32:17 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id y68so17347845pfb.1
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:32:17 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 04/12] mm: thp: introduce CONFIG_ARCH_ENABLE_THP_MIGRATION
Date: Tue,  8 Nov 2016 08:31:49 +0900
Message-Id: <1478561517-4317-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Introduces CONFIG_ARCH_ENABLE_THP_MIGRATION to limit thp migration
functionality to x86_64, which should be safer at the first step.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
v1 -> v2:
- fixed config name in subject and patch description
---
 arch/x86/Kconfig        |  4 ++++
 include/linux/huge_mm.h | 14 ++++++++++++++
 mm/Kconfig              |  3 +++
 3 files changed, 21 insertions(+)

diff --git v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/Kconfig v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/Kconfig
index 19d237b..63b2f24 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/Kconfig
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/Kconfig
@@ -2246,6 +2246,10 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 	def_bool y
 	depends on X86_64 && HUGETLB_PAGE && MIGRATION
 
+config ARCH_ENABLE_THP_MIGRATION
+	def_bool y
+	depends on X86_64 && TRANSPARENT_HUGEPAGE && MIGRATION
+
 menu "Power management and ACPI options"
 
 config ARCH_HIBERNATION_HEADER
diff --git v4.9-rc2-mmotm-2016-10-27-18-27/include/linux/huge_mm.h v4.9-rc2-mmotm-2016-10-27-18-27_patched/include/linux/huge_mm.h
index 31f2c32..fcbca51 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/include/linux/huge_mm.h
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/include/linux/huge_mm.h
@@ -161,6 +161,15 @@ void mm_put_huge_zero_page(struct mm_struct *mm);
 
 #define mk_huge_pmd(page, prot) pmd_mkhuge(mk_pmd(page, prot))
 
+static inline bool thp_migration_supported(void)
+{
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+	return true;
+#else
+	return false;
+#endif
+}
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -232,6 +241,11 @@ static inline struct page *follow_devmap_pmd(struct vm_area_struct *vma,
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
diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/Kconfig v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/Kconfig
index be0ee11..1965310 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/mm/Kconfig
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/Kconfig
@@ -289,6 +289,9 @@ config MIGRATION
 config ARCH_ENABLE_HUGEPAGE_MIGRATION
 	bool
 
+config ARCH_ENABLE_THP_MIGRATION
+	bool
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
