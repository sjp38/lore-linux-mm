Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 04F186B00A2
	for <linux-mm@kvack.org>; Wed,  8 May 2013 05:53:16 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id hm14so1694663wib.17
        for <linux-mm@kvack.org>; Wed, 08 May 2013 02:53:15 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH v2 05/11] mm: thp: Correct the HPAGE_PMD_ORDER check.
Date: Wed,  8 May 2013 10:52:37 +0100
Message-Id: <1368006763-30774-6-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1368006763-30774-1-git-send-email-steve.capper@linaro.org>
References: <1368006763-30774-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, patches@linaro.org, Steve Capper <steve.capper@linaro.org>

All Transparent Huge Pages are allocated by the buddy allocator.

A compile time check is in place that fails when the order of a
transparent huge page is too large to be allocated by the buddy
allocator. Unfortunately that compile time check passes when:
HPAGE_PMD_ORDER == MAX_ORDER
( which is incorrect as the buddy allocator can only allocate
memory of order strictly less than MAX_ORDER. )

This patch updates the compile time check to fail in the above
case.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 include/linux/huge_mm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ee1c244..3d71e5c 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -119,7 +119,7 @@ extern void __split_huge_page_pmd(struct vm_area_struct *vma,
 	} while (0)
 extern void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
 		pmd_t *pmd);
-#if HPAGE_PMD_ORDER > MAX_ORDER
+#if HPAGE_PMD_ORDER >= MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
 extern int hugepage_madvise(struct vm_area_struct *vma,
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
