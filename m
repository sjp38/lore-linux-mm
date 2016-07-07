Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 095466B0262
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:32:02 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so25030579pfa.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:32:02 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id yk3si3356365pac.233.2016.07.07.02.31.51
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 02:31:52 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [RFC v2 11/13] lockdep: Call lock_acquire(release) when accessing PG_locked manually
Date: Thu,  7 Jul 2016 18:30:01 +0900
Message-Id: <1467883803-29132-12-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
References: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, npiggin@kernel.dk, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The PG_locked bit can be updated through SetPageLocked() or
ClearPageLocked(), not by lock_page() and unlock_page().
SetPageLockded() and ClearPageLocked() also have to be considered to
get balanced between acquring and releasing the PG_locked lock.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 fs/cifs/file.c          | 4 ++++
 include/linux/pagemap.h | 5 ++++-
 mm/filemap.c            | 6 ++++--
 mm/ksm.c                | 1 +
 mm/migrate.c            | 1 +
 mm/shmem.c              | 2 ++
 mm/swap_state.c         | 2 ++
 mm/vmscan.c             | 1 +
 8 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index bcf9ead..7b250c1 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3392,12 +3392,14 @@ readpages_get_pages(struct address_space *mapping, struct list_head *page_list,
 	 * PG_locked without checking it first.
 	 */
 	__SetPageLocked(page);
+	lock_page_acquire(page, 1);
 	rc = add_to_page_cache_locked(page, mapping,
 				      page->index, gfp);
 
 	/* give up if we can't stick it in the cache */
 	if (rc) {
 		__ClearPageLocked(page);
+		lock_page_release(page);
 		return rc;
 	}
 
@@ -3419,8 +3421,10 @@ readpages_get_pages(struct address_space *mapping, struct list_head *page_list,
 			break;
 
 		__SetPageLocked(page);
+		lock_page_acquire(page, 1);
 		if (add_to_page_cache_locked(page, mapping, page->index, gfp)) {
 			__ClearPageLocked(page);
+			lock_page_release(page);
 			break;
 		}
 		list_move_tail(&page->lru, tmplist);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 2fc4af1..f92972c 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -760,9 +760,12 @@ static inline int add_to_page_cache(struct page *page,
 	int error;
 
 	__SetPageLocked(page);
+	lock_page_acquire(page, 1);
 	error = add_to_page_cache_locked(page, mapping, offset, gfp_mask);
-	if (unlikely(error))
+	if (unlikely(error)) {
 		__ClearPageLocked(page);
+		lock_page_release(page);
+	}
 	return error;
 }
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 47fc5c0..7acce5e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -690,11 +690,13 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 	int ret;
 
 	__SetPageLocked(page);
+	lock_page_acquire(page, 1);
 	ret = __add_to_page_cache_locked(page, mapping, offset,
 					 gfp_mask, &shadow);
-	if (unlikely(ret))
+	if (unlikely(ret)) {
 		__ClearPageLocked(page);
-	else {
+		lock_page_release(page);
+	} else {
 		/*
 		 * The page might have been evicted from cache only
 		 * recently, in which case it should be activated like
diff --git a/mm/ksm.c b/mm/ksm.c
index ca6d2a0..c89debd 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1869,6 +1869,7 @@ struct page *ksm_might_need_to_copy(struct page *page,
 		SetPageDirty(new_page);
 		__SetPageUptodate(new_page);
 		__SetPageLocked(new_page);
+		lock_page_acquire(new_page, 1);
 	}
 
 	return new_page;
diff --git a/mm/migrate.c b/mm/migrate.c
index 3ad0fea..9aab7c4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1773,6 +1773,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 	/* Prepare a page as a migration target */
 	__SetPageLocked(new_page);
+	lock_page_acquire(new_page, 1);
 	SetPageSwapBacked(new_page);
 
 	/* anon mapping, we can simply copy page->mapping to the new page: */
diff --git a/mm/shmem.c b/mm/shmem.c
index 440e2a7..da35ca8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1090,6 +1090,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 	flush_dcache_page(newpage);
 
 	__SetPageLocked(newpage);
+	lock_page_acquire(newpage, 1);
 	SetPageUptodate(newpage);
 	SetPageSwapBacked(newpage);
 	set_page_private(newpage, swap_index);
@@ -1283,6 +1284,7 @@ repeat:
 
 		__SetPageSwapBacked(page);
 		__SetPageLocked(page);
+		lock_page_acquire(page, 1);
 		if (sgp == SGP_WRITE)
 			__SetPageReferenced(page);
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 3fb7013..200edbf 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -358,6 +358,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 
 		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
 		__SetPageLocked(new_page);
+		lock_page_acquire(new_page, 1);
 		SetPageSwapBacked(new_page);
 		err = __add_to_swap_cache(new_page, entry);
 		if (likely(!err)) {
@@ -372,6 +373,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		radix_tree_preload_end();
 		ClearPageSwapBacked(new_page);
 		__ClearPageLocked(new_page);
+		lock_page_release(new_page);
 		/*
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
 		 * clear SWAP_HAS_CACHE flag.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 71b1c29..5baff91 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1199,6 +1199,7 @@ lazyfree:
 		 * waiting on the page lock, because there are no references.
 		 */
 		__ClearPageLocked(page);
+		lock_page_release(page);
 free_it:
 		if (ret == SWAP_LZFREE)
 			count_vm_event(PGLAZYFREED);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
