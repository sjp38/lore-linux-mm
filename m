Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3DEDF6B0311
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 21:52:44 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p48so61408834qtf.1
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 18:52:44 -0700 (PDT)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id l49si7770811qtl.22.2017.08.14.18.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 18:52:43 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 3/4] mm: soft-offline: retry to split and soft-offline the raw error if the original THP offlining fails.
Date: Mon, 14 Aug 2017 21:52:15 -0400
Message-Id: <20170815015216.31827-4-zi.yan@sent.com>
In-Reply-To: <20170815015216.31827-1-zi.yan@sent.com>
References: <20170815015216.31827-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>

From: Zi Yan <zi.yan@cs.rutgers.edu>

For THP soft-offline support, we first try to migrate a THP without
splitting. If the migration fails, we split the THP and migrate the
raw error page.

migrate_pages() does not split a THP if the migration reason is
MR_MEMORY_FAILURE.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/memory-failure.c | 77 +++++++++++++++++++++++++++++++++++++----------------
 mm/migrate.c        | 16 +++++++++++
 2 files changed, 70 insertions(+), 23 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 8a9ac6f9e1b0..c05107548d72 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1598,10 +1598,11 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	return ret;
 }
 
-static int __soft_offline_page(struct page *page, int flags)
+static int __soft_offline_page(struct page *page, int flags, int *split)
 {
 	int ret;
-	unsigned long pfn = page_to_pfn(page);
+	struct page *hpage = compound_head(page);
+	unsigned long pfn = page_to_pfn(hpage);
 
 	/*
 	 * Check PageHWPoison again inside page lock because PageHWPoison
@@ -1609,11 +1610,11 @@ static int __soft_offline_page(struct page *page, int flags)
 	 * memory_failure() also double-checks PageHWPoison inside page lock,
 	 * so there's no race between soft_offline_page() and memory_failure().
 	 */
-	lock_page(page);
-	wait_on_page_writeback(page);
-	if (PageHWPoison(page)) {
-		unlock_page(page);
-		put_hwpoison_page(page);
+	lock_page(hpage);
+	wait_on_page_writeback(hpage);
+	if (PageHWPoison(hpage)) {
+		unlock_page(hpage);
+		put_hwpoison_page(hpage);
 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
 		return -EBUSY;
 	}
@@ -1621,14 +1622,14 @@ static int __soft_offline_page(struct page *page, int flags)
 	 * Try to invalidate first. This should work for
 	 * non dirty unmapped page cache pages.
 	 */
-	ret = invalidate_inode_page(page);
-	unlock_page(page);
+	ret = invalidate_inode_page(hpage);
+	unlock_page(hpage);
 	/*
 	 * RED-PEN would be better to keep it isolated here, but we
 	 * would need to fix isolation locking first.
 	 */
 	if (ret == 1) {
-		put_hwpoison_page(page);
+		put_hwpoison_page(hpage);
 		pr_info("soft_offline: %#lx: invalidated\n", pfn);
 		SetPageHWPoison(page);
 		num_poisoned_pages_inc();
@@ -1640,15 +1641,15 @@ static int __soft_offline_page(struct page *page, int flags)
 	 * Try to migrate to a new page instead. migrate.c
 	 * handles a large number of cases for us.
 	 */
-	if (PageLRU(page))
-		ret = isolate_lru_page(page);
+	if (PageLRU(hpage))
+		ret = isolate_lru_page(hpage);
 	else
-		ret = isolate_movable_page(page, ISOLATE_UNEVICTABLE);
+		ret = isolate_movable_page(hpage, ISOLATE_UNEVICTABLE);
 	/*
 	 * Drop page reference which is came from get_any_page()
 	 * successful isolate_lru_page() already took another one.
 	 */
-	put_hwpoison_page(page);
+	put_hwpoison_page(hpage);
 	if (!ret) {
 		LIST_HEAD(pagelist);
 		/*
@@ -1657,23 +1658,53 @@ static int __soft_offline_page(struct page *page, int flags)
 		 * cannot have PAGE_MAPPING_MOVABLE.
 		 */
 		if (!__PageMovable(page))
-			inc_node_page_state(page, NR_ISOLATED_ANON +
-						page_is_file_cache(page));
-		list_add(&page->lru, &pagelist);
+			mod_node_page_state(page_pgdat(hpage), NR_ISOLATED_ANON +
+					page_is_file_cache(hpage), hpage_nr_pages(hpage));
+retry_subpage:
+		list_add(&hpage->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
 		if (ret) {
-			if (!list_empty(&pagelist))
-				putback_movable_pages(&pagelist);
-
+			if (!list_empty(&pagelist)) {
+				if (!PageTransHuge(hpage))
+					putback_movable_pages(&pagelist);
+				else {
+					lock_page(hpage);
+					if (split_huge_page_to_list(hpage, &pagelist)) {
+						unlock_page(hpage);
+						goto failed;
+					}
+					unlock_page(hpage);
+
+					if (split)
+						*split = 1;
+					/*
+					 * Pull the raw error page out and put back other subpages.
+					 * Then retry the raw error page.
+					 */
+					list_del(&page->lru);
+					putback_movable_pages(&pagelist);
+					hpage = page;
+					goto retry_subpage;
+				}
+			}
+failed:
 			pr_info("soft offline: %#lx: migration failed %d, type %lx (%pGp)\n",
-				pfn, ret, page->flags, &page->flags);
+				pfn, ret, hpage->flags, &hpage->flags);
 			if (ret > 0)
 				ret = -EIO;
 		}
+		/*
+		 * Set PageHWPoison on the raw error page.
+		 *
+		 * If the page is a THP, PageHWPoison is set then cleared
+		 * in its head page in migrate_pages(). So we need to set the raw error
+		 * page here. Otherwise, setting PageHWPoison again is fine.
+		 */
+		SetPageHWPoison(page);
 	} else {
 		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %lx (%pGp)\n",
-			pfn, ret, page_count(page), page->flags, &page->flags);
+			pfn, ret, page_count(hpage), hpage->flags, &hpage->flags);
 	}
 	return ret;
 }
@@ -1704,7 +1735,7 @@ static int soft_offline_in_use_page(struct page *page, int flags, int *split)
 	if (PageHuge(page))
 		ret = soft_offline_huge_page(page, flags);
 	else
-		ret = __soft_offline_page(page, flags);
+		ret = __soft_offline_page(page, flags, split);
 
 	return ret;
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index f7b69282d216..b44df9cf72fd 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1118,6 +1118,15 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 	}
 
 	if (unlikely(PageTransHuge(page) && !PageTransHuge(newpage))) {
+		/*
+		 * soft-offline wants to retry the raw error subpage, if the THP
+		 * migration fails. So we do not split the THP here and exit directly.
+		 */
+		if (reason == MR_MEMORY_FAILURE) {
+			rc = -ENOMEM;
+			goto put_new;
+		}
+
 		lock_page(page);
 		rc = split_huge_page(page);
 		unlock_page(page);
@@ -1164,6 +1173,13 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 			 */
 			if (!test_set_page_hwpoison(page))
 				num_poisoned_pages_inc();
+
+			/*
+			 * Clear PageHWPoison in the head page. The caller
+			 * is responsible for setting the raw error page.
+			 */
+			if (PageTransHuge(page))
+				ClearPageHWPoison(page);
 		}
 	} else {
 		if (rc != -EAGAIN) {
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
