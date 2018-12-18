Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4625A8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 03:24:27 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id s12so8942120otc.12
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 00:24:27 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i20si6888514oto.71.2018.12.18.00.24.25
        for <linux-mm@kvack.org>;
        Tue, 18 Dec 2018 00:24:25 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [RESEND PATCH V3 5/5] arm64/mm: Enable HugeTLB migration for contiguous bit HugeTLB pages
Date: Tue, 18 Dec 2018 13:54:10 +0530
Message-Id: <1545121450-1663-6-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1545121450-1663-1-git-send-email-anshuman.khandual@arm.com>
References: <1545121450-1663-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: suzuki.poulose@arm.com, will.deacon@arm.com, Steven.Price@arm.com, steve.capper@arm.com, catalin.marinas@arm.com, mhocko@kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

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

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Steve Capper <steve.capper@arm.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/include/asm/hugetlb.h |  5 +++++
 arch/arm64/mm/hugetlbpage.c      | 20 ++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index fb66098..c6a07a3 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -20,6 +20,11 @@
 
 #include <asm/page.h>
 
+#ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
+#define arch_hugetlb_migration_supported arch_hugetlb_migration_supported
+extern bool arch_hugetlb_migration_supported(struct hstate *h);
+#endif
+
 #define __HAVE_ARCH_HUGE_PTEP_GET
 static inline pte_t huge_ptep_get(pte_t *ptep)
 {
diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index f58ea50..e445500 100644
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
