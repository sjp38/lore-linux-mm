Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8476B0266
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 08:15:59 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id b5-v6so1150839otk.21
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 05:15:59 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a62-v6si7632488otc.86.2018.10.02.05.15.58
        for <linux-mm@kvack.org>;
        Tue, 02 Oct 2018 05:15:58 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH 4/4] arm64/mm: Enable HugeTLB migration for contiguous bit HugeTLB pages
Date: Tue,  2 Oct 2018 17:45:31 +0530
Message-Id: <1538482531-26883-5-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
References: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mhocko@kernel.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

Let arm64 subscribe to the previously added framework in which architecture
can inform whether a given huge page size is supported for migration. This
just overrides the default function arch_hugetlb_migration_supported() and
enables migration for all possible HugeTLB page sizes on arm64. With this,
HugeTLB migration support on arm64 now covers all possible HugeTLB options.

        CONT PTE    PMD    CONT PMD    PUD
        --------    ---    --------    ---
4K:        64K      2M        32M      1G
16K:        2M     32M         1G
64K:        2M    512M        16G

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/include/asm/hugetlb.h |  5 +++++
 arch/arm64/mm/hugetlbpage.c      | 20 ++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index e73f685..656f70e 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -20,6 +20,11 @@
 
 #include <asm/page.h>
 
+#ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
+#define arch_hugetlb_migration_supported arch_hugetlb_migration_supported
+extern bool arch_hugetlb_migration_supported(struct hstate *h);
+#endif
+
 static inline pte_t huge_ptep_get(pte_t *ptep)
 {
 	return READ_ONCE(*ptep);
diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 4eafd9f..28f4795 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -27,6 +27,26 @@
 #include <asm/tlbflush.h>
 #include <asm/pgalloc.h>
 
+#ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
+bool arch_hugetlb_migration_supported(struct hstate *h)
+{
+	size_t pagesize = huge_page_size(h);
+
+	switch (pagesize) {
+#ifdef CONFIG_ARM64_4K_PAGES
+	case PUD_SIZE:
+#endif
+	case PMD_SIZE:
+	case CONT_PMD_SIZE:
+	case CONT_PTE_SIZE:
+		return true;
+	}
+	pr_warn("%s: unrecognized huge page size 0x%lx\n",
+			__func__, pagesize);
+	return false;
+}
+#endif
+
 int pmd_huge(pmd_t pmd)
 {
 	return pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT);
-- 
2.7.4
