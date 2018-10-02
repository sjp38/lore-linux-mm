Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 17FE16B000C
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 08:15:51 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id v188-v6so1112614oie.3
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 05:15:51 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y56si2546102oty.7.2018.10.02.05.15.50
        for <linux-mm@kvack.org>;
        Tue, 02 Oct 2018 05:15:50 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH 2/4] mm/hugetlb: Enable arch specific huge page size support for migration
Date: Tue,  2 Oct 2018 17:45:29 +0530
Message-Id: <1538482531-26883-3-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
References: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mhocko@kernel.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

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

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 include/linux/hugetlb.h | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 9c1b77f..9df1d59 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -479,18 +479,29 @@ static inline pgoff_t basepage_index(struct page *page)
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
 
 static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
-- 
2.7.4
