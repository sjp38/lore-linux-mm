Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2F91F6B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 02:42:10 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id fi3so8278153pac.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:10 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id bx9si63870441pab.185.2016.03.02.23.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 23:42:09 -0800 (PST)
Received: by mail-pf0-x230.google.com with SMTP id w128so10373313pfb.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:09 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 02/11] mm: thp: introduce CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
Date: Thu,  3 Mar 2016 16:41:49 +0900
Message-Id: <1456990918-30906-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Introduces CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION to limit thp migration
functionality to x86_64, which should be safer at the first step.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/x86/Kconfig        |  4 ++++
 include/linux/huge_mm.h | 14 ++++++++++++++
 mm/Kconfig              |  3 +++
 3 files changed, 21 insertions(+)

diff --git v4.5-rc5-mmotm-2016-02-24-16-18/arch/x86/Kconfig v4.5-rc5-mmotm-2016-02-24-16-18_patched/arch/x86/Kconfig
index 993aca4..7a563cf 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/arch/x86/Kconfig
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/arch/x86/Kconfig
@@ -2198,6 +2198,10 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 	def_bool y
 	depends on X86_64 && HUGETLB_PAGE && MIGRATION
 
+config ARCH_ENABLE_THP_MIGRATION
+	def_bool y
+	depends on X86_64 && TRANSPARENT_HUGEPAGE && MIGRATION
+
 menu "Power management and ACPI options"
 
 config ARCH_HIBERNATION_HEADER
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/include/linux/huge_mm.h v4.5-rc5-mmotm-2016-02-24-16-18_patched/include/linux/huge_mm.h
index 459fd25..09b215d 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/include/linux/huge_mm.h
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/include/linux/huge_mm.h
@@ -156,6 +156,15 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 
 struct page *get_huge_zero_page(void);
 
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
@@ -213,6 +222,11 @@ static inline struct page *follow_devmap_pmd(struct vm_area_struct *vma,
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
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/Kconfig v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/Kconfig
index f2c1a07..64e7ab6 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/mm/Kconfig
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/Kconfig
@@ -265,6 +265,9 @@ config MIGRATION
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
