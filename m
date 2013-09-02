Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 6B7446B0031
	for <linux-mm@kvack.org>; Sun,  1 Sep 2013 23:45:51 -0400 (EDT)
Received: by mail-oa0-f47.google.com with SMTP id g12so4697157oah.6
        for <linux-mm@kvack.org>; Sun, 01 Sep 2013 20:45:50 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 1/2] mm: thp: cleanup: mv alloc_hugepage to better place
Date: Mon,  2 Sep 2013 11:45:41 +0800
Message-Id: <1378093542-31971-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, konrad.wilk@oracle.com, davidoff@qedmf.net, Bob Liu <bob.liu@oracle.com>

Move alloc_hugepage to better place, no need for a seperate #ifndef CONFIG_NUMA

Signed-off-by: Bob Liu <bob.liu@oracle.com>
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
