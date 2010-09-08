Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D28DB6B0083
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 21:29:45 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 08/10] HWPOISON, hugetlb: soft offlining for hugepage
Date: Wed,  8 Sep 2010 10:19:39 +0900
Message-Id: <1283908781-13810-9-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch extends soft offlining framework to support hugepage.
When memory corrected errors occur repeatedly on a hugepage,
we can choose to stop using it by migrating data onto another hugepage
and disabling the original (maybe half-broken) one.

ChangeLog since v4:
- branch soft_offline_page() for hugepage

ChangeLog since v3:
- remove comment about "ToDo: hugepage soft-offline"

ChangeLog since v2:
- move refcount handling into isolate_lru_page()

ChangeLog since v1:
- add double check in isolating hwpoisoned hugepage
- define free/non-free checker for hugepage
- postpone calling put_page() for hugepage in soft_offline_page()

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 mm/memory-failure.c |   59 +++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 55 insertions(+), 4 deletions(-)

diff --git v2.6.36-rc2/mm/memory-failure.c v2.6.36-rc2/mm/memory-failure.c
index dfeb8b8..1d0392d 100644
--- v2.6.36-rc2/mm/memory-failure.c
+++ v2.6.36-rc2/mm/memory-failure.c
@@ -693,8 +693,6 @@ static int me_swapcache_clean(struct page *p, unsigned long pfn)
  * Issues:
  * - Error on hugepage is contained in hugepage unit (not in raw page unit.)
  *   To narrow down kill region to one page, we need to break up pmd.
- * - To support soft-offlining for hugepage, we need to support hugepage
- *   migration.
  */
 static int me_huge_page(struct page *p, unsigned long pfn)
 {
@@ -1220,7 +1218,11 @@ EXPORT_SYMBOL(unpoison_memory);
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
@@ -1248,8 +1250,15 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
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
+			ret = dequeue_hwpoisoned_huge_page(compound_head(p));
+		} else if (is_free_buddy_page(p)) {
 			pr_debug("get_any_page: %#lx free buddy page\n", pfn);
 			/* Set hwpoison bit while page is still isolated */
 			SetPageHWPoison(p);
@@ -1268,6 +1277,45 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
 	return ret;
 }
 
+static int soft_offline_huge_page(struct page *page, int flags)
+{
+	int ret;
+	unsigned long pfn = page_to_pfn(page);
+	struct page *hpage = compound_head(page);
+	LIST_HEAD(pagelist);
+
+	ret = get_any_page(page, pfn, flags);
+	if (ret < 0)
+		return ret;
+	if (ret == 0)
+		goto done;
+
+	if (PageHWPoison(hpage)) {
+		put_page(hpage);
+		pr_debug("soft offline: %#lx hugepage already poisoned\n", pfn);
+		return -EBUSY;
+	}
+
+	/* Keep page count to indicate a given hugepage is isolated. */
+
+	list_add(&hpage->lru, &pagelist);
+	ret = migrate_huge_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, 0);
+	if (ret) {
+		pr_debug("soft offline: %#lx: migration failed %d, type %lx\n",
+			 pfn, ret, page->flags);
+		if (ret > 0)
+			ret = -EIO;
+		return ret;
+	}
+done:
+	if (!PageHWPoison(hpage))
+		atomic_long_add(1 << compound_order(hpage), &mce_bad_pages);
+	set_page_hwpoison_huge_page(hpage);
+	dequeue_hwpoisoned_huge_page(hpage);
+	/* keep elevated page count for bad page */
+	return ret;
+}
+
 /**
  * soft_offline_page - Soft offline a page.
  * @page: page to offline
@@ -1295,6 +1343,9 @@ int soft_offline_page(struct page *page, int flags)
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
 
+	if (PageHuge(page))
+		return soft_offline_huge_page(page, flags);
+
 	ret = get_any_page(page, pfn, flags);
 	if (ret < 0)
 		return ret;
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
