Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3368E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 07:13:58 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id z5-v6so2321463ljb.13
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 04:13:58 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id g83si9822846lfl.30.2018.12.17.04.13.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 04:13:56 -0800 (PST)
Subject: [PATCH] mm: Remove __hugepage_set_anon_rmap()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 17 Dec 2018 15:13:51 +0300
Message-ID: <154504875359.30235.6237926369392564851.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, jglisse@redhat.com, ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This function is identical to __page_set_anon_rmap()
since the time, when it was introduced (8 years ago).
The patch removes the function, and makes its users
to use __page_set_anon_rmap() instead.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/rmap.c |   25 ++++---------------------
 1 file changed, 4 insertions(+), 21 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 896c61dbf16c..f0d3bab2f7ad 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1020,7 +1020,7 @@ void page_move_anon_rmap(struct page *page, struct vm_area_struct *vma)
 
 /**
  * __page_set_anon_rmap - set up new anonymous rmap
- * @page:	Page to add to rmap	
+ * @page:	Page or Hugepage to add to rmap
  * @vma:	VM area to add page to.
  * @address:	User virtual address of the mapping	
  * @exclusive:	the page is exclusively owned by the current process
@@ -1921,27 +1921,10 @@ void rmap_walk_locked(struct page *page, struct rmap_walk_control *rwc)
 
 #ifdef CONFIG_HUGETLB_PAGE
 /*
- * The following three functions are for anonymous (private mapped) hugepages.
+ * The following two functions are for anonymous (private mapped) hugepages.
  * Unlike common anonymous pages, anonymous hugepages have no accounting code
  * and no lru code, because we handle hugepages differently from common pages.
  */
-static void __hugepage_set_anon_rmap(struct page *page,
-	struct vm_area_struct *vma, unsigned long address, int exclusive)
-{
-	struct anon_vma *anon_vma = vma->anon_vma;
-
-	BUG_ON(!anon_vma);
-
-	if (PageAnon(page))
-		return;
-	if (!exclusive)
-		anon_vma = anon_vma->root;
-
-	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
-	page->mapping = (struct address_space *) anon_vma;
-	page->index = linear_page_index(vma, address);
-}
-
 void hugepage_add_anon_rmap(struct page *page,
 			    struct vm_area_struct *vma, unsigned long address)
 {
@@ -1953,7 +1936,7 @@ void hugepage_add_anon_rmap(struct page *page,
 	/* address might be in next vma when migration races vma_adjust */
 	first = atomic_inc_and_test(compound_mapcount_ptr(page));
 	if (first)
-		__hugepage_set_anon_rmap(page, vma, address, 0);
+		__page_set_anon_rmap(page, vma, address, 0);
 }
 
 void hugepage_add_new_anon_rmap(struct page *page,
@@ -1961,6 +1944,6 @@ void hugepage_add_new_anon_rmap(struct page *page,
 {
 	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 	atomic_set(compound_mapcount_ptr(page), 0);
-	__hugepage_set_anon_rmap(page, vma, address, 1);
+	__page_set_anon_rmap(page, vma, address, 1);
 }
 #endif /* CONFIG_HUGETLB_PAGE */
