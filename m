Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id A458E8E00B9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:38:09 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id s10-v6so10181491ybj.5
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:38:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g136sor2058820ywb.33.2018.12.11.09.38.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 09:38:07 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 1/3] filemap: kill page_cache_read usage in filemap_fault
Date: Tue, 11 Dec 2018 12:37:59 -0500
Message-Id: <20181211173801.29535-2-josef@toxicpanda.com>
In-Reply-To: <20181211173801.29535-1-josef@toxicpanda.com>
References: <20181211173801.29535-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

If we do not have a page at filemap_fault time we'll do this weird
forced page_cache_read thing to populate the page, and then drop it
again and loop around and find it.  This makes for 2 ways we can read a
page in filemap_fault, and it's not really needed.  Instead add a
FGP_FOR_MMAP flag so that pagecache_get_page() will return a unlocked
page that's in pagecache.  Then use the normal page locking and readpage
logic already in filemap_fault.  This simplifies the no page in page
cache case significantly.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 include/linux/pagemap.h |  1 +
 mm/filemap.c            | 73 ++++++++++---------------------------------------
 2 files changed, 16 insertions(+), 58 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 226f96f0dee0..b13c2442281f 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -252,6 +252,7 @@ pgoff_t page_cache_prev_miss(struct address_space *mapping,
 #define FGP_WRITE		0x00000008
 #define FGP_NOFS		0x00000010
 #define FGP_NOWAIT		0x00000020
+#define FGP_FOR_MMAP		0x00000040
 
 struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 		int fgp_flags, gfp_t cache_gfp_mask);
diff --git a/mm/filemap.c b/mm/filemap.c
index 81adec8ee02c..03bce38d8f2b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1503,6 +1503,9 @@ EXPORT_SYMBOL(find_lock_entry);
  *   @gfp_mask and added to the page cache and the VM's LRU
  *   list. The page is returned locked and with an increased
  *   refcount. Otherwise, NULL is returned.
+ * - FGP_FOR_MMAP: Similar to FGP_CREAT, only we want to allow the caller to do
+ *   its own locking dance if the page is already in cache, or unlock the page
+ *   before returning if we had to add the page to pagecache.
  *
  * If FGP_LOCK or FGP_CREAT are specified then the function may sleep even
  * if the GFP flags specified for FGP_CREAT are atomic.
@@ -1555,7 +1558,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 		if (!page)
 			return NULL;
 
-		if (WARN_ON_ONCE(!(fgp_flags & FGP_LOCK)))
+		if (WARN_ON_ONCE(!(fgp_flags & (FGP_LOCK | FGP_FOR_MMAP))))
 			fgp_flags |= FGP_LOCK;
 
 		/* Init accessed so avoid atomic mark_page_accessed later */
@@ -1569,6 +1572,13 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 			if (err == -EEXIST)
 				goto repeat;
 		}
+
+		/*
+		 * add_to_page_cache_lru lock's the page, and for mmap we expect
+		 * a unlocked page.
+		 */
+		if (fgp_flags & FGP_FOR_MMAP)
+			unlock_page(page);
 	}
 
 	return page;
@@ -2293,39 +2303,6 @@ generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 EXPORT_SYMBOL(generic_file_read_iter);
 
 #ifdef CONFIG_MMU
-/**
- * page_cache_read - adds requested page to the page cache if not already there
- * @file:	file to read
- * @offset:	page index
- * @gfp_mask:	memory allocation flags
- *
- * This adds the requested page to the page cache if it isn't already there,
- * and schedules an I/O to read in its contents from disk.
- */
-static int page_cache_read(struct file *file, pgoff_t offset, gfp_t gfp_mask)
-{
-	struct address_space *mapping = file->f_mapping;
-	struct page *page;
-	int ret;
-
-	do {
-		page = __page_cache_alloc(gfp_mask);
-		if (!page)
-			return -ENOMEM;
-
-		ret = add_to_page_cache_lru(page, mapping, offset, gfp_mask);
-		if (ret == 0)
-			ret = mapping->a_ops->readpage(file, page);
-		else if (ret == -EEXIST)
-			ret = 0; /* losing race to add is OK */
-
-		put_page(page);
-
-	} while (ret == AOP_TRUNCATED_PAGE);
-
-	return ret;
-}
-
 #define MMAP_LOTSAMISS  (100)
 
 /*
@@ -2449,9 +2426,11 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
 retry_find:
-		page = find_get_page(mapping, offset);
+		page = pagecache_get_page(mapping, offset,
+					  FGP_CREAT|FGP_FOR_MMAP,
+					  vmf->gfp_mask);
 		if (!page)
-			goto no_cached_page;
+			return vmf_error(-ENOMEM);
 	}
 
 	if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags)) {
@@ -2488,28 +2467,6 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	vmf->page = page;
 	return ret | VM_FAULT_LOCKED;
 
-no_cached_page:
-	/*
-	 * We're only likely to ever get here if MADV_RANDOM is in
-	 * effect.
-	 */
-	error = page_cache_read(file, offset, vmf->gfp_mask);
-
-	/*
-	 * The page we want has now been added to the page cache.
-	 * In the unlikely event that someone removed it in the
-	 * meantime, we'll just come back here and read it again.
-	 */
-	if (error >= 0)
-		goto retry_find;
-
-	/*
-	 * An error return from page_cache_read can result if the
-	 * system is low on memory, or a problem occurs while trying
-	 * to schedule I/O.
-	 */
-	return vmf_error(error);
-
 page_not_uptodate:
 	/*
 	 * Umm, take care of errors if the page isn't up-to-date.
-- 
2.14.3
