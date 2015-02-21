Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id AF57E6B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 22:58:40 -0500 (EST)
Received: by padfb1 with SMTP id fb1so12817201pad.8
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 19:58:40 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id bp16si52433pdb.107.2015.02.20.19.58.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 19:58:39 -0800 (PST)
Received: by pablf10 with SMTP id lf10so12745833pab.12
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 19:58:39 -0800 (PST)
Date: Fri, 20 Feb 2015 19:58:36 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 04/24] mm: make page migration's newpage handling more
 robust
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502201956260.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

I don't know of any problem in the current tree, but huge tmpfs wants
to use the custom put_new_page feature of page migration, with a pool
of its own pages: and met some surprises and difficulties in doing so.

An unused newpage is expected to be released with the put_new_page(),
but there was one MIGRATEPAGE_SUCCESS (0) path which released it with
putback_lru_page(), which was wrong for this custom pool.  Fixed more
easily by resetting put_new_page once it won't be needed, than by
adding a further flag to modify the rc test.

Definitely an extension rather than a bugfix: pages of that newpage
pool might in rare cases still be speculatively accessed and locked
by another task, so relax move_to_new_page()'s !trylock_page() BUG
to an -EAGAIN, just like when old page is found locked.  Do its
__ClearPageSwapBacked on failure while still holding page lock;
and don't reset old page->mapping if PageAnon, we often assume
that PageAnon is persistent once set.

Actually, move the trylock_page(newpage) and unlock_page(newpage)
up a level into __unmap_and_move(), to the same level as the trylock
and unlock of old page: though I moved them originally to suit an old
tree (one using mem_cgroup_prepare_migration()), it still seems a
better placement.

Then the remove_migration_ptes() can be done in one place,
instead of at one level on success but another level on failure.

Add some VM_BUG_ONs to enforce the new convention, and adjust
unmap_and_move_huge_page() and balloon_page_migrate() to fit too.

Finally, clean up __unmap_and_move()'s increasingly weird block
"if (anon_vma) nothing; else if (PageSwapCache) nothing; else out;"
while keeping its useful comment on unmapped swapcache.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/balloon_compaction.c |   10 ---
 mm/migrate.c            |  120 +++++++++++++++++++-------------------
 2 files changed, 63 insertions(+), 67 deletions(-)

--- thpfs.orig/mm/balloon_compaction.c	2014-12-07 14:21:05.000000000 -0800
+++ thpfs/mm/balloon_compaction.c	2015-02-20 19:33:40.872062714 -0800
@@ -199,23 +199,17 @@ int balloon_page_migrate(struct page *ne
 	struct balloon_dev_info *balloon = balloon_page_device(page);
 	int rc = -EAGAIN;
 
-	/*
-	 * Block others from accessing the 'newpage' when we get around to
-	 * establishing additional references. We should be the only one
-	 * holding a reference to the 'newpage' at this point.
-	 */
-	BUG_ON(!trylock_page(newpage));
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
 
 	if (WARN_ON(!__is_movable_balloon_page(page))) {
 		dump_page(page, "not movable balloon page");
-		unlock_page(newpage);
 		return rc;
 	}
 
 	if (balloon && balloon->migratepage)
 		rc = balloon->migratepage(balloon, newpage, page, mode);
 
-	unlock_page(newpage);
 	return rc;
 }
 #endif /* CONFIG_BALLOON_COMPACTION */
--- thpfs.orig/mm/migrate.c	2015-02-20 19:33:35.676074594 -0800
+++ thpfs/mm/migrate.c	2015-02-20 19:33:40.876062705 -0800
@@ -746,18 +746,13 @@ static int fallback_migrate_page(struct
  *  MIGRATEPAGE_SUCCESS - success
  */
 static int move_to_new_page(struct page *newpage, struct page *page,
-				int page_was_mapped, enum migrate_mode mode)
+				enum migrate_mode mode)
 {
 	struct address_space *mapping;
 	int rc;
 
-	/*
-	 * Block others from accessing the page when we get around to
-	 * establishing additional references. We are the only one
-	 * holding a reference to the new page at this point.
-	 */
-	if (!trylock_page(newpage))
-		BUG();
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
 
 	/* Prepare mapping for the new page.*/
 	newpage->index = page->index;
@@ -781,16 +776,14 @@ static int move_to_new_page(struct page
 		rc = fallback_migrate_page(mapping, newpage, page, mode);
 
 	if (rc != MIGRATEPAGE_SUCCESS) {
+		__ClearPageSwapBacked(newpage);
 		newpage->mapping = NULL;
 	} else {
 		mem_cgroup_migrate(page, newpage, false);
-		if (page_was_mapped)
-			remove_migration_ptes(page, newpage);
-		page->mapping = NULL;
+		if (!PageAnon(page))
+			page->mapping = NULL;
 	}
 
-	unlock_page(newpage);
-
 	return rc;
 }
 
@@ -839,6 +832,7 @@ static int __unmap_and_move(struct page
 			goto out_unlock;
 		wait_on_page_writeback(page);
 	}
+
 	/*
 	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
 	 * we cannot notice that anon_vma is freed while we migrates a page.
@@ -853,28 +847,29 @@ static int __unmap_and_move(struct page
 		 * getting a hold on an anon_vma from outside one of its mms.
 		 */
 		anon_vma = page_get_anon_vma(page);
-		if (anon_vma) {
-			/*
-			 * Anon page
-			 */
-		} else if (PageSwapCache(page)) {
-			/*
-			 * We cannot be sure that the anon_vma of an unmapped
-			 * swapcache page is safe to use because we don't
-			 * know in advance if the VMA that this page belonged
-			 * to still exists. If the VMA and others sharing the
-			 * data have been freed, then the anon_vma could
-			 * already be invalid.
-			 *
-			 * To avoid this possibility, swapcache pages get
-			 * migrated but are not remapped when migration
-			 * completes
-			 */
-		} else {
+		if (!anon_vma && !PageSwapCache(page))
 			goto out_unlock;
-		}
+		/*
+		 * We cannot be sure that the anon_vma of an unmapped swapcache
+		 * page is safe to use because we don't know in advance if the
+		 * VMA that this page belonged to still exists. If the VMA and
+		 * others sharing it have been freed, then the anon_vma could
+		 * be invalid.  To avoid this possibility, swapcache pages
+		 * are migrated, but not remapped when migration completes.
+		 */
 	}
 
+	/*
+	 * Block others from accessing the new page when we get around to
+	 * establishing additional references. We are usually the only one
+	 * holding a reference to newpage at this point. We used to have a BUG
+	 * here if trylock_page(newpage) fails, but intend to introduce a case
+	 * where there might be a race with the previous use of newpage.  This
+	 * is much like races on the refcount of oldpage: just don't BUG().
+	 */
+	if (unlikely(!trylock_page(newpage)))
+		goto out_unlock;
+
 	if (unlikely(isolated_balloon_page(page))) {
 		/*
 		 * A ballooned page does not need any special attention from
@@ -884,7 +879,7 @@ static int __unmap_and_move(struct page
 		 * the page migration right away (proteced by page lock).
 		 */
 		rc = balloon_page_migrate(newpage, page, mode);
-		goto out_unlock;
+		goto out_unlock_both;
 	}
 
 	/*
@@ -903,30 +898,28 @@ static int __unmap_and_move(struct page
 		VM_BUG_ON_PAGE(PageAnon(page), page);
 		if (page_has_private(page)) {
 			try_to_free_buffers(page);
-			goto out_unlock;
+			goto out_unlock_both;
 		}
-		goto skip_unmap;
-	}
-
-	/* Establish migration ptes or remove ptes */
-	if (page_mapped(page)) {
+	} else if (page_mapped(page)) {
+		/* Establish migration ptes or remove ptes */
 		try_to_unmap(page,
 			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 		page_was_mapped = 1;
 	}
 
-skip_unmap:
 	if (!page_mapped(page))
-		rc = move_to_new_page(newpage, page, page_was_mapped, mode);
+		rc = move_to_new_page(newpage, page, mode);
 
-	if (rc && page_was_mapped)
-		remove_migration_ptes(page, page);
+	if (page_was_mapped)
+		remove_migration_ptes(page,
+			rc == MIGRATEPAGE_SUCCESS ? newpage : page);
 
+out_unlock_both:
+	unlock_page(newpage);
+out_unlock:
 	/* Drop an anon_vma reference if we took one */
 	if (anon_vma)
 		put_anon_vma(anon_vma);
-
-out_unlock:
 	unlock_page(page);
 out:
 	return rc;
@@ -940,10 +933,11 @@ static int unmap_and_move(new_page_t get
 			unsigned long private, struct page *page, int force,
 			enum migrate_mode mode)
 {
-	int rc = 0;
+	int rc = MIGRATEPAGE_SUCCESS;
 	int *result = NULL;
-	struct page *newpage = get_new_page(page, private, &result);
+	struct page *newpage;
 
+	newpage = get_new_page(page, private, &result);
 	if (!newpage)
 		return -ENOMEM;
 
@@ -957,6 +951,8 @@ static int unmap_and_move(new_page_t get
 			goto out;
 
 	rc = __unmap_and_move(page, newpage, force, mode);
+	if (rc == MIGRATEPAGE_SUCCESS)
+		put_new_page = NULL;
 
 out:
 	if (rc != -EAGAIN) {
@@ -977,10 +973,9 @@ out:
 	 * it.  Otherwise, putback_lru_page() will drop the reference grabbed
 	 * during isolation.
 	 */
-	if (rc != MIGRATEPAGE_SUCCESS && put_new_page) {
-		__ClearPageSwapBacked(newpage);
+	if (put_new_page)
 		put_new_page(newpage, private);
-	} else if (unlikely(__is_movable_balloon_page(newpage))) {
+	else if (unlikely(__is_movable_balloon_page(newpage))) {
 		/* drop our reference, page already in the balloon */
 		put_page(newpage);
 	} else
@@ -1018,7 +1013,7 @@ static int unmap_and_move_huge_page(new_
 				struct page *hpage, int force,
 				enum migrate_mode mode)
 {
-	int rc = 0;
+	int rc = -EAGAIN;
 	int *result = NULL;
 	int page_was_mapped = 0;
 	struct page *new_hpage;
@@ -1040,8 +1035,6 @@ static int unmap_and_move_huge_page(new_
 	if (!new_hpage)
 		return -ENOMEM;
 
-	rc = -EAGAIN;
-
 	if (!trylock_page(hpage)) {
 		if (!force || mode != MIGRATE_SYNC)
 			goto out;
@@ -1051,6 +1044,9 @@ static int unmap_and_move_huge_page(new_
 	if (PageAnon(hpage))
 		anon_vma = page_get_anon_vma(hpage);
 
+	if (unlikely(!trylock_page(new_hpage)))
+		goto put_anon;
+
 	if (page_mapped(hpage)) {
 		try_to_unmap(hpage,
 			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
@@ -1058,16 +1054,22 @@ static int unmap_and_move_huge_page(new_
 	}
 
 	if (!page_mapped(hpage))
-		rc = move_to_new_page(new_hpage, hpage, page_was_mapped, mode);
+		rc = move_to_new_page(new_hpage, hpage, mode);
 
-	if (rc != MIGRATEPAGE_SUCCESS && page_was_mapped)
-		remove_migration_ptes(hpage, hpage);
+	if (page_was_mapped)
+		remove_migration_ptes(hpage,
+			rc == MIGRATEPAGE_SUCCESS ? new_hpage : hpage);
 
+	unlock_page(new_hpage);
+
+put_anon:
 	if (anon_vma)
 		put_anon_vma(anon_vma);
 
-	if (rc == MIGRATEPAGE_SUCCESS)
+	if (rc == MIGRATEPAGE_SUCCESS) {
 		hugetlb_cgroup_migrate(hpage, new_hpage);
+		put_new_page = NULL;
+	}
 
 	unlock_page(hpage);
 out:
@@ -1079,7 +1081,7 @@ out:
 	 * it.  Otherwise, put_page() will drop the reference grabbed during
 	 * isolation.
 	 */
-	if (rc != MIGRATEPAGE_SUCCESS && put_new_page)
+	if (put_new_page)
 		put_new_page(new_hpage, private);
 	else
 		put_page(new_hpage);
@@ -1109,7 +1111,7 @@ out:
  *
  * The function returns after 10 attempts or if no pages are movable any more
  * because the list has become empty or no retryable pages exist any more.
- * The caller should call putback_lru_pages() to return pages to the LRU
+ * The caller should call putback_movable_pages() to return pages to the LRU
  * or free list only if ret != 0.
  *
  * Returns the number of pages that were not migrated, or an error code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
