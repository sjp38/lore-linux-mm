Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B73C8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 03:24:18 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id r82so941816oie.14
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 00:24:18 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z88si6727421ota.151.2018.12.18.00.24.17
        for <linux-mm@kvack.org>;
        Tue, 18 Dec 2018 00:24:17 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [RESEND PATCH V3 3/5] mm/hugetlb: Enable arch specific huge page size support for migration
Date: Tue, 18 Dec 2018 13:54:08 +0530
Message-Id: <1545121450-1663-4-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1545121450-1663-1-git-send-email-anshuman.khandual@arm.com>
References: <1545121450-1663-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: suzuki.poulose@arm.com, will.deacon@arm.com, Steven.Price@arm.com, steve.capper@arm.com, catalin.marinas@arm.com, mhocko@kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

Architectures like arm64 have HugeTLB page sizes which are different than
generic sizes at PMD, PUD, PGD level and implemented via contiguous bits.
At present these special size HugeTLB pages cannot be identified through
macros like (PMD|PUD|PGDIR)_SHIFT and hence chosen not be migrated.

Enabling migration support for these special HugeTLB page sizes along with
the generic ones (PMD|PUD|PGD) would require identifying all of them on a
given platform. A platform specific hook can precisely enumerate all huge
page sizes supported for migration. Instead of comparing against standard
huge page orders let hugetlb_migration_support() function call a platform
hook arch_hugetlb_migration_support(). Default definition for the platform
hook maintains existing semantics which checks standard huge page order.
But an architecture can choose to override the default and provide support
for a comprehensive set of huge page sizes.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Steve Capper <steve.capper@arm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 include/linux/hugetlb.h | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 70bcd89..4cc3871 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -493,18 +493,29 @@ static inline pgoff_t basepage_index(struct page *page)
 extern int dissolve_free_huge_page(struct page *page);
 extern int dissolve_free_huge_pages(unsigned long start_pfn,
 				    unsigned long end_pfn);
-static inline bool hugepage_migration_supported(struct hstate *h)
-{
+
 #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
+#ifndef arch_hugetlb_migration_supported
+static inline bool arch_hugetlb_migration_supported(struct hstate *h)
+{
 	if ((huge_page_shift(h) == PMD_SHIFT) ||
 		(huge_page_shift(h) == PUD_SHIFT) ||
 			(huge_page_shift(h) == PGDIR_SHIFT))
 		return true;
 	else
 		return false;
+}
+#endif
 #else
+static inline bool arch_hugetlb_migration_supported(struct hstate *h)
+{
 	return false;
+}
 #endif
+
+static inline bool hugepage_migration_supported(struct hstate *h)
+{
+	return arch_hugetlb_migration_supported(h);
 }
 
 /*
-- 
2.7.4
