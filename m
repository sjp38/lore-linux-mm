Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 168466B01F2
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 19:57:08 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 6/8] HWPOISON, hugetlb: soft offlining for hugepage
Date: Wed, 25 Aug 2010 08:55:25 +0900
Message-Id: <1282694127-14609-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1282694127-14609-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1282694127-14609-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch extends soft offlining framework to support hugepage.
When memory corrected errors occur repeatedly on a hugepage,
we can choose to stop using it by migrating data onto another hugepage
and disabling the original (maybe half-broken) one.

ChangeLog since v2:
- move refcount handling into isolate_lru_page()

ChangeLog since v1:
- add double check in isolating hwpoisoned hugepage
- define free/non-free checker for hugepage
- postpone calling put_page() for hugepage in soft_offline_page()

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 include/linux/hugetlb.h |    2 +
 mm/hugetlb.c            |   26 ++++++++++++++++++++++++
 mm/memory-failure.c     |   49 ++++++++++++++++++++++++++++++++--------------
 3 files changed, 62 insertions(+), 15 deletions(-)

diff --git v2.6.36-rc2/include/linux/hugetlb.h v2.6.36-rc2/include/linux/hugetlb.h
index 9e51f77..c8c1891 100644
--- v2.6.36-rc2/include/linux/hugetlb.h
+++ v2.6.36-rc2/include/linux/hugetlb.h
@@ -44,6 +44,7 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to,
 						int acctflags);
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 void __isolate_hwpoisoned_huge_page(struct page *page);
+void isolate_hwpoisoned_huge_page(struct page *page);
 void copy_huge_page(struct page *dst, struct page *src);
 
 extern unsigned long hugepages_treat_as_movable;
@@ -103,6 +104,7 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
 #define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
 #define huge_pte_offset(mm, address)	0
 #define __isolate_hwpoisoned_huge_page(page)	0
+#define isolate_hwpoisoned_huge_page(page)	0
 static inline void copy_huge_page(struct page *dst, struct page *src)
 {
 }
diff --git v2.6.36-rc2/mm/hugetlb.c v2.6.36-rc2/mm/hugetlb.c
index 57bc1ec..dee7972 100644
--- v2.6.36-rc2/mm/hugetlb.c
+++ v2.6.36-rc2/mm/hugetlb.c
@@ -2987,3 +2987,29 @@ void __isolate_hwpoisoned_huge_page(struct page *hpage)
 	h->free_huge_pages_node[nid]--;
 	spin_unlock(&hugetlb_lock);
 }
+
+static int is_hugepage_on_freelist(struct page *hpage)
+{
+	struct page *page;
+	struct page *tmp;
+	struct hstate *h = page_hstate(hpage);
+	int nid = page_to_nid(hpage);
+
+	spin_lock(&hugetlb_lock);
+	list_for_each_entry_safe(page, tmp, &h->hugepage_freelists[nid], lru) {
+		if (page == hpage) {
+			spin_unlock(&hugetlb_lock);
+			return 1;
+		}
+	}
+	spin_unlock(&hugetlb_lock);
+	return 0;
+}
+
+void isolate_hwpoisoned_huge_page(struct page *hpage)
+{
+	lock_page(hpage);
+	if (is_hugepage_on_freelist(hpage))
+		__isolate_hwpoisoned_huge_page(hpage);
+	unlock_page(hpage);
+}
diff --git v2.6.36-rc2/mm/memory-failure.c v2.6.36-rc2/mm/memory-failure.c
index 9c26eec..60178d2 100644
--- v2.6.36-rc2/mm/memory-failure.c
+++ v2.6.36-rc2/mm/memory-failure.c
@@ -1187,7 +1187,11 @@ EXPORT_SYMBOL(unpoison_memory);
 static struct page *new_page(struct page *p, unsigned long private, int **x)
 {
 	int nid = page_to_nid(p);
-	return alloc_pages_exact_node(nid, GFP_HIGHUSER_MOVABLE, 0);
+	if (PageHuge(p))
+		return alloc_huge_page_node(page_hstate(compound_head(p)),
+						   nid);
+	else
+		return alloc_pages_exact_node(nid, GFP_HIGHUSER_MOVABLE, 0);
 }
 
 /*
@@ -1215,8 +1219,16 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
 	 * was free.
 	 */
 	set_migratetype_isolate(p);
+	/*
+	 * When the target page is a free hugepage, just remove it
+	 * from free hugepage list.
+	 */
 	if (!get_page_unless_zero(compound_head(p))) {
-		if (is_free_buddy_page(p)) {
+		if (PageHuge(p)) {
+			pr_debug("get_any_page: %#lx free huge page\n", pfn);
+			ret = 0;
+			SetPageHWPoison(compound_head(p));
+		} else if (is_free_buddy_page(p)) {
 			pr_debug("get_any_page: %#lx free buddy page\n", pfn);
 			/* Set hwpoison bit while page is still isolated */
 			SetPageHWPoison(p);
@@ -1261,6 +1273,7 @@ int soft_offline_page(struct page *page, int flags)
 {
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
+	struct page *hpage = compound_head(page);
 
 	ret = get_any_page(page, pfn, flags);
 	if (ret < 0)
@@ -1271,7 +1284,7 @@ int soft_offline_page(struct page *page, int flags)
 	/*
 	 * Page cache page we can handle?
 	 */
-	if (!PageLRU(page)) {
+	if (!PageLRU(page) && !PageHuge(page)) {
 		/*
 		 * Try to free it.
 		 */
@@ -1287,21 +1300,21 @@ int soft_offline_page(struct page *page, int flags)
 		if (ret == 0)
 			goto done;
 	}
-	if (!PageLRU(page)) {
+	if (!PageLRU(page) && !PageHuge(page)) {
 		pr_debug("soft_offline: %#lx: unknown non LRU page type %lx\n",
 				pfn, page->flags);
 		return -EIO;
 	}
 
-	lock_page(page);
-	wait_on_page_writeback(page);
+	lock_page(hpage);
+	wait_on_page_writeback(hpage);
 
 	/*
 	 * Synchronized using the page lock with memory_failure()
 	 */
-	if (PageHWPoison(page)) {
-		unlock_page(page);
-		put_page(page);
+	if (PageHWPoison(hpage)) {
+		unlock_page(hpage);
+		put_page(hpage);
 		pr_debug("soft offline: %#lx page already poisoned\n", pfn);
 		return -EBUSY;
 	}
@@ -1311,7 +1324,7 @@ int soft_offline_page(struct page *page, int flags)
 	 * non dirty unmapped page cache pages.
 	 */
 	ret = invalidate_inode_page(page);
-	unlock_page(page);
+	unlock_page(hpage);
 
 	/*
 	 * Drop count because page migration doesn't like raised
@@ -1320,7 +1333,7 @@ int soft_offline_page(struct page *page, int flags)
 	 * RED-PEN would be better to keep it isolated here, but we
 	 * would need to fix isolation locking first.
 	 */
-	put_page(page);
+	put_page(hpage);
 	if (ret == 1) {
 		ret = 0;
 		pr_debug("soft_offline: %#lx: invalidated\n", pfn);
@@ -1336,7 +1349,7 @@ int soft_offline_page(struct page *page, int flags)
 	if (!ret) {
 		LIST_HEAD(pagelist);
 
-		list_add(&page->lru, &pagelist);
+		list_add(&hpage->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, 0);
 		if (ret) {
 			pr_debug("soft offline: %#lx: migration failed %d, type %lx\n",
@@ -1352,9 +1365,15 @@ int soft_offline_page(struct page *page, int flags)
 		return ret;
 
 done:
-	atomic_long_add(1, &mce_bad_pages);
-	SetPageHWPoison(page);
-	/* keep elevated page count for bad page */
+	if (!PageHWPoison(hpage))
+		atomic_long_add(1 << compound_order(hpage), &mce_bad_pages);
+	if (PageHuge(hpage)) {
+		set_page_hwpoison_huge_page(hpage);
+		isolate_hwpoisoned_huge_page(hpage);
+	} else {
+		SetPageHWPoison(page);
+		/* keep elevated page count for bad page */
+	}
 	return ret;
 }
 
-- 
1.7.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
