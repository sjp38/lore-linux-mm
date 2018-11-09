Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E58676B0698
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 01:47:37 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 190-v6so777205pfd.7
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 22:47:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j12-v6sor7852419plk.37.2018.11.08.22.47.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 22:47:36 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC][PATCH v1 03/11] mm: move definition of num_poisoned_pages_inc/dec to include/linux/mm.h
Date: Fri,  9 Nov 2018 15:47:07 +0900
Message-Id: <1541746035-13408-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>

num_poisoned_pages_inc/dec had better be visible to some file like
mm/sparse.c and mm/page_alloc.c (for a subsequent patch). So let's
move it to include/linux/mm.h.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/mm.h      | 13 ++++++++++++-
 include/linux/swapops.h | 16 ----------------
 mm/sparse.c             |  2 +-
 3 files changed, 13 insertions(+), 18 deletions(-)

diff --git v4.19-mmotm-2018-10-30-16-08/include/linux/mm.h v4.19-mmotm-2018-10-30-16-08_patched/include/linux/mm.h
index 59df394..22623ba 100644
--- v4.19-mmotm-2018-10-30-16-08/include/linux/mm.h
+++ v4.19-mmotm-2018-10-30-16-08_patched/include/linux/mm.h
@@ -2741,7 +2741,7 @@ extern void shake_page(struct page *p, int access);
 extern atomic_long_t num_poisoned_pages __read_mostly;
 extern int soft_offline_page(struct page *page, int flags);
 
-
+#ifdef CONFIG_MEMORY_FAILURE
 /*
  * Error handlers for various types of pages.
  */
@@ -2777,6 +2777,17 @@ enum mf_action_page_type {
 	MF_MSG_UNKNOWN,
 };
 
+static inline void num_poisoned_pages_inc(void)
+{
+	atomic_long_inc(&num_poisoned_pages);
+}
+
+static inline void num_poisoned_pages_dec(void)
+{
+	atomic_long_dec(&num_poisoned_pages);
+}
+#endif
+
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
 extern void clear_huge_page(struct page *page,
 			    unsigned long addr_hint,
diff --git v4.19-mmotm-2018-10-30-16-08/include/linux/swapops.h v4.19-mmotm-2018-10-30-16-08_patched/include/linux/swapops.h
index 4d96166..88137e9 100644
--- v4.19-mmotm-2018-10-30-16-08/include/linux/swapops.h
+++ v4.19-mmotm-2018-10-30-16-08_patched/include/linux/swapops.h
@@ -320,8 +320,6 @@ static inline int is_pmd_migration_entry(pmd_t pmd)
 
 #ifdef CONFIG_MEMORY_FAILURE
 
-extern atomic_long_t num_poisoned_pages __read_mostly;
-
 /*
  * Support for hardware poisoned pages
  */
@@ -336,16 +334,6 @@ static inline int is_hwpoison_entry(swp_entry_t entry)
 	return swp_type(entry) == SWP_HWPOISON;
 }
 
-static inline void num_poisoned_pages_inc(void)
-{
-	atomic_long_inc(&num_poisoned_pages);
-}
-
-static inline void num_poisoned_pages_dec(void)
-{
-	atomic_long_dec(&num_poisoned_pages);
-}
-
 #else
 
 static inline swp_entry_t make_hwpoison_entry(struct page *page)
@@ -357,10 +345,6 @@ static inline int is_hwpoison_entry(swp_entry_t swp)
 {
 	return 0;
 }
-
-static inline void num_poisoned_pages_inc(void)
-{
-}
 #endif
 
 #if defined(CONFIG_MEMORY_FAILURE) || defined(CONFIG_MIGRATION)
diff --git v4.19-mmotm-2018-10-30-16-08/mm/sparse.c v4.19-mmotm-2018-10-30-16-08_patched/mm/sparse.c
index 33307fc..7ada2e5 100644
--- v4.19-mmotm-2018-10-30-16-08/mm/sparse.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/mm/sparse.c
@@ -726,7 +726,7 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 
 	for (i = 0; i < nr_pages; i++) {
 		if (PageHWPoison(&memmap[i])) {
-			atomic_long_sub(1, &num_poisoned_pages);
+			num_poisoned_pages_dec();
 			ClearPageHWPoison(&memmap[i]);
 		}
 	}
-- 
2.7.0
