Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id F3D4A6B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 23:30:41 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id bg4so7670538pad.4
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 20:30:41 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so6434890pdj.20
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 20:30:38 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH v2 1/2] mm: thp: cleanup: mv alloc_hugepage to better place
Date: Wed, 18 Sep 2013 11:30:28 +0800
Message-Id: <1379475029-26437-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, davidoff@qedmf.net, isimatu.yasuaki@jp.fujitsu.com, Bob Liu <bob.liu@oracle.com>

Move alloc_hugepage to better place, no need for a seperate #ifndef CONFIG_NUMA

Signed-off-by: Bob Liu <bob.liu@oracle.com>
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a92012a..7448cf9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -753,14 +753,6 @@ static inline struct page *alloc_hugepage_vma(int defrag,
 			       HPAGE_PMD_ORDER, vma, haddr, nd);
 }
 
-#ifndef CONFIG_NUMA
-static inline struct page *alloc_hugepage(int defrag)
-{
-	return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
-			   HPAGE_PMD_ORDER);
-}
-#endif
-
 static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd,
 		struct page *zero_page)
@@ -2204,6 +2196,12 @@ static struct page
 	return *hpage;
 }
 #else
+static inline struct page *alloc_hugepage(int defrag)
+{
+	return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
+			   HPAGE_PMD_ORDER);
+}
+
 static struct page *khugepaged_alloc_hugepage(bool *wait)
 {
 	struct page *hpage;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
