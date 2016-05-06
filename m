Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f72.google.com (mail-qg0-f72.google.com [209.85.192.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F94B6B025E
	for <linux-mm@kvack.org>; Fri,  6 May 2016 11:04:07 -0400 (EDT)
Received: by mail-qg0-f72.google.com with SMTP id c103so183641161qge.1
        for <linux-mm@kvack.org>; Fri, 06 May 2016 08:04:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w6si9802590qka.81.2016.05.06.08.04.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 08:04:04 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/3] mm: thp: calculate the mapcount correctly for THP pages during WP faults
Date: Fri,  6 May 2016 17:03:58 +0200
Message-Id: <1462547040-1737-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1462547040-1737-1-git-send-email-aarcange@redhat.com>
References: <1462547040-1737-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Alex Williamson <alex.williamson@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

This will provide fully accuracy to the mapcount calculation in the
write protect faults, so page pinning will not get broken by false
positive copy-on-writes.

total_mapcount() isn't the right calculation needed in
reuse_swap_page(), so this introduces a page_trans_huge_mapcount()
that is effectively the full accurate return value for page_mapcount()
if dealing with Transparent Hugepages, however we only use the
page_trans_huge_mapcount() during COW faults where it strictly needed,
due to its higher runtime cost.

This also provide at practical zero cost the total_mapcount
information which is needed to know if we can still relocate the page
anon_vma to the local vma. If page_trans_huge_mapcount() returns 1 we
can reuse the page no matter if it's a pte or a pmd_trans_huge
triggering the fault, but we can only relocate the page anon_vma to
the local vma->anon_vma if we're sure it's only this "vma" mapping the
whole THP physical range.

Kirill A. Shutemov discovered the problem with moving the page
anon_vma to the local vma->anon_vma in a previous version of this
patch and another problem in the way page_move_anon_rmap() was called.

Reviewed-by: "Kirill A. Shutemov" <kirill@shutemov.name>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm.h   |  9 +++++++
 include/linux/swap.h |  8 ++++---
 mm/huge_memory.c     | 67 +++++++++++++++++++++++++++++++++++++++++++++-------
 mm/memory.c          | 22 ++++++++++-------
 mm/swapfile.c        | 13 +++++-----
 5 files changed, 93 insertions(+), 26 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a55e5be..263f229 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -500,11 +500,20 @@ static inline int page_mapcount(struct page *page)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 int total_mapcount(struct page *page);
+int page_trans_huge_mapcount(struct page *page, int *total_mapcount);
 #else
 static inline int total_mapcount(struct page *page)
 {
 	return page_mapcount(page);
 }
+static inline int page_trans_huge_mapcount(struct page *page,
+					   int *total_mapcount)
+{
+	int mapcount = page_mapcount(page);
+	if (total_mapcount)
+		*total_mapcount = mapcount;
+	return mapcount;
+}
 #endif
 
 static inline struct page *virt_to_head_page(const void *x)
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 2b83359..acef20d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -418,7 +418,7 @@ extern sector_t swapdev_block(int, pgoff_t);
 extern int page_swapcount(struct page *);
 extern int swp_swapcount(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
-extern int reuse_swap_page(struct page *);
+extern bool reuse_swap_page(struct page *, int *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
 
@@ -513,8 +513,10 @@ static inline int swp_swapcount(swp_entry_t entry)
 	return 0;
 }
 
-#define reuse_swap_page(page) \
-	(!PageTransCompound(page) && page_mapcount(page) == 1)
+static inline bool reuse_swap_page(struct page *page, int *total_mapcount)
+{
+	return page_trans_huge_mapcount(page, total_mapcount) == 1;
+}
 
 static inline int try_to_free_swap(struct page *page)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 86f9f8b..9086793 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1298,15 +1298,9 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
 	/*
 	 * We can only reuse the page if nobody else maps the huge page or it's
-	 * part. We can do it by checking page_mapcount() on each sub-page, but
-	 * it's expensive.
-	 * The cheaper way is to check page_count() to be equal 1: every
-	 * mapcount takes page reference reference, so this way we can
-	 * guarantee, that the PMD is the only mapping.
-	 * This can give false negative if somebody pinned the page, but that's
-	 * fine.
+	 * part.
 	 */
-	if (page_mapcount(page) == 1 && page_count(page) == 1) {
+	if (page_trans_huge_mapcount(page, NULL) == 1) {
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
@@ -2080,7 +2074,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		if (pte_write(pteval)) {
 			writable = true;
 		} else {
-			if (PageSwapCache(page) && !reuse_swap_page(page)) {
+			if (PageSwapCache(page) &&
+			    !reuse_swap_page(page, NULL)) {
 				unlock_page(page);
 				result = SCAN_SWAP_CACHE_PAGE;
 				goto out;
@@ -3225,6 +3220,60 @@ int total_mapcount(struct page *page)
 }
 
 /*
+ * This calculates accurately how many mappings a transparent hugepage
+ * has (unlike page_mapcount() which isn't fully accurate). This full
+ * accuracy is primarily needed to know if copy-on-write faults can
+ * reuse the page and change the mapping to read-write instead of
+ * copying them. At the same time this returns the total_mapcount too.
+ *
+ * The function returns the highest mapcount any one of the subpages
+ * has. If the return value is one, even if different processes are
+ * mapping different subpages of the transparent hugepage, they can
+ * all reuse it, because each process is reusing a different subpage.
+ *
+ * The total_mapcount is instead counting all virtual mappings of the
+ * subpages. If the total_mapcount is equal to "one", it tells the
+ * caller all mappings belong to the same "mm" and in turn the
+ * anon_vma of the transparent hugepage can become the vma->anon_vma
+ * local one as no other process may be mapping any of the subpages.
+ *
+ * It would be more accurate to replace page_mapcount() with
+ * page_trans_huge_mapcount(), however we only use
+ * page_trans_huge_mapcount() in the copy-on-write faults where we
+ * need full accuracy to avoid breaking page pinning, because
+ * page_trans_huge_mapcount() is slower than page_mapcount().
+ */
+int page_trans_huge_mapcount(struct page *page, int *total_mapcount)
+{
+	int i, ret, _total_mapcount, mapcount;
+
+	/* hugetlbfs shouldn't call it */
+	VM_BUG_ON_PAGE(PageHuge(page), page);
+
+	if (likely(!PageTransCompound(page)))
+		return atomic_read(&page->_mapcount) + 1;
+
+	page = compound_head(page);
+
+	_total_mapcount = ret = 0;
+	for (i = 0; i < HPAGE_PMD_NR; i++) {
+		mapcount = atomic_read(&page[i]._mapcount) + 1;
+		ret = max(ret, mapcount);
+		_total_mapcount += mapcount;
+	}
+	if (PageDoubleMap(page)) {
+		ret -= 1;
+		_total_mapcount -= HPAGE_PMD_NR;
+	}
+	mapcount = compound_mapcount(page);
+	ret += mapcount;
+	_total_mapcount += mapcount;
+	if (total_mapcount)
+		*total_mapcount = _total_mapcount;
+	return ret;
+}
+
+/*
  * This function splits huge page into normal pages. @page can point to any
  * subpage of huge page to split. Split doesn't change the position of @page.
  *
diff --git a/mm/memory.c b/mm/memory.c
index 93897f2..d7a2af3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2340,6 +2340,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * not dirty accountable.
 	 */
 	if (PageAnon(old_page) && !PageKsm(old_page)) {
+		int total_mapcount;
 		if (!trylock_page(old_page)) {
 			get_page(old_page);
 			pte_unmap_unlock(page_table, ptl);
@@ -2354,13 +2355,18 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			}
 			put_page(old_page);
 		}
-		if (reuse_swap_page(old_page)) {
-			/*
-			 * The page is all ours.  Move it to our anon_vma so
-			 * the rmap code will not search our parent or siblings.
-			 * Protected against the rmap code by the page lock.
-			 */
-			page_move_anon_rmap(old_page, vma, address);
+		if (reuse_swap_page(old_page, &total_mapcount)) {
+			if (total_mapcount == 1) {
+				/*
+				 * The page is all ours. Move it to
+				 * our anon_vma so the rmap code will
+				 * not search our parent or siblings.
+				 * Protected against the rmap code by
+				 * the page lock.
+				 */
+				page_move_anon_rmap(compound_head(old_page),
+						    vma, address);
+			}
 			unlock_page(old_page);
 			return wp_page_reuse(mm, vma, address, page_table, ptl,
 					     orig_pte, old_page, 0, 0);
@@ -2584,7 +2590,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	dec_mm_counter_fast(mm, MM_SWAPENTS);
 	pte = mk_pte(page, vma->vm_page_prot);
-	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
+	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
 		flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 83874ec..031713ab 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -922,18 +922,19 @@ out:
  * to it.  And as a side-effect, free up its swap: because the old content
  * on disk will never be read, and seeking back there to write new content
  * later would only waste time away from clustering.
+ *
+ * NOTE: total_mapcount should not be relied upon by the caller if
+ * reuse_swap_page() returns false, but it may be always overwritten
+ * (see the other implementation for CONFIG_SWAP=n).
  */
-int reuse_swap_page(struct page *page)
+bool reuse_swap_page(struct page *page, int *total_mapcount)
 {
 	int count;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	if (unlikely(PageKsm(page)))
-		return 0;
-	/* The page is part of THP and cannot be reused */
-	if (PageTransCompound(page))
-		return 0;
-	count = page_mapcount(page);
+		return false;
+	count = page_trans_huge_mapcount(page, total_mapcount);
 	if (count <= 1 && PageSwapCache(page)) {
 		count += page_swapcount(page);
 		if (count == 1 && !PageWriteback(page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
