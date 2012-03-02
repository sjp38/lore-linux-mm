Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 34D7E6B00E8
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 15:13:23 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 1/2] thp: add HPAGE_PMD_* definitions for !CONFIG_TRANSPARENT_HUGEPAGE
Date: Fri,  2 Mar 2012 15:13:08 -0500
Message-Id: <1330719189-20047-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

These macros will be used in later patch, where all usage are expected
to be optimized away without #ifdef CONFIG_TRANSPARENT_HUGEPAGE.
But to detect unexpected usages, we convert existing BUG() to BUILD_BUG().

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Hillf Danton <dhillf@gmail.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/huge_mm.h |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git linux-next-20120228.orig/include/linux/huge_mm.h linux-next-20120228/include/linux/huge_mm.h
index f56cacb..c8af7a2 100644
--- linux-next-20120228.orig/include/linux/huge_mm.h
+++ linux-next-20120228/include/linux/huge_mm.h
@@ -51,6 +51,9 @@ extern pmd_t *page_check_address_pmd(struct page *page,
 				     unsigned long address,
 				     enum page_check_address_pmd_flag flag);
 
+#define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
+#define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define HPAGE_PMD_SHIFT HPAGE_SHIFT
 #define HPAGE_PMD_MASK HPAGE_MASK
@@ -102,8 +105,6 @@ extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
 		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
 		       pmd_trans_huge(*____pmd));			\
 	} while (0)
-#define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
-#define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
 #if HPAGE_PMD_ORDER > MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
@@ -158,9 +159,9 @@ static inline struct page *compound_trans_head(struct page *page)
 	return page;
 }
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
-#define HPAGE_PMD_SHIFT ({ BUG(); 0; })
-#define HPAGE_PMD_MASK ({ BUG(); 0; })
-#define HPAGE_PMD_SIZE ({ BUG(); 0; })
+#define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
+#define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
+#define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
 
 #define hpage_nr_pages(x) 1
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
