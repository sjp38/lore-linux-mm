Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5CDA58E0004
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 17:09:04 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x144-v6so473024qkb.4
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 14:09:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v21-v6sor59788qvf.16.2018.09.26.14.09.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Sep 2018 14:09:03 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 2/9] mm: drop mmap_sem for page cache read IO submission
Date: Wed, 26 Sep 2018 17:08:49 -0400
Message-Id: <20180926210856.7895-3-josef@toxicpanda.com>
In-Reply-To: <20180926210856.7895-1-josef@toxicpanda.com>
References: <20180926210856.7895-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-team@fb.com, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, tj@kernel.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, riel@redhat.com, linux-mm@kvack.org, linux-btrfs@vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>

Reads can take a long time, and if anybody needs to take a write lock on
the mmap_sem it'll block any subsequent readers to the mmap_sem while
the read is outstanding, which could cause long delays.  Instead drop
the mmap_sem if we do any reads at all.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 mm/filemap.c | 119 ++++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 90 insertions(+), 29 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 52517f28e6f4..1ed35cd99b2c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2366,6 +2366,18 @@ generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 EXPORT_SYMBOL(generic_file_read_iter);
 
 #ifdef CONFIG_MMU
+static struct file *maybe_unlock_mmap_for_io(struct vm_area_struct *vma, int flags)
+{
+	if ((flags & (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT)) == FAULT_FLAG_ALLOW_RETRY) {
+		struct file *file;
+
+		file = get_file(vma->vm_file);
+		up_read(&vma->vm_mm->mmap_sem);
+		return file;
+	}
+	return NULL;
+}
+
 /**
  * page_cache_read - adds requested page to the page cache if not already there
  * @file:	file to read
@@ -2405,23 +2417,28 @@ static int page_cache_read(struct file *file, pgoff_t offset, gfp_t gfp_mask)
  * Synchronous readahead happens when we don't even find
  * a page in the page cache at all.
  */
-static void do_sync_mmap_readahead(struct vm_area_struct *vma,
-				   struct file_ra_state *ra,
-				   struct file *file,
-				   pgoff_t offset)
+static int do_sync_mmap_readahead(struct vm_area_struct *vma,
+				  struct file_ra_state *ra,
+				  struct file *file,
+				  pgoff_t offset,
+				  int flags)
 {
 	struct address_space *mapping = file->f_mapping;
+	struct file *fpin;
 
 	/* If we don't want any read-ahead, don't bother */
 	if (vma->vm_flags & VM_RAND_READ)
-		return;
+		return 0;
 	if (!ra->ra_pages)
-		return;
+		return 0;
 
 	if (vma->vm_flags & VM_SEQ_READ) {
+		fpin = maybe_unlock_mmap_for_io(vma, flags);
 		page_cache_sync_readahead(mapping, ra, file, offset,
 					  ra->ra_pages);
-		return;
+		if (fpin)
+			fput(fpin);
+		return fpin ? -EAGAIN : 0;
 	}
 
 	/* Avoid banging the cache line if not needed */
@@ -2433,7 +2450,9 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
 	 * stop bothering with read-ahead. It will only hurt.
 	 */
 	if (ra->mmap_miss > MMAP_LOTSAMISS)
-		return;
+		return 0;
+
+	fpin = maybe_unlock_mmap_for_io(vma, flags);
 
 	/*
 	 * mmap read-around
@@ -2442,28 +2461,40 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
 	ra->size = ra->ra_pages;
 	ra->async_size = ra->ra_pages / 4;
 	ra_submit(ra, mapping, file);
+
+	if (fpin)
+		fput(fpin);
+
+	return fpin ? -EAGAIN : 0;
 }
 
 /*
  * Asynchronous readahead happens when we find the page and PG_readahead,
  * so we want to possibly extend the readahead further..
  */
-static void do_async_mmap_readahead(struct vm_area_struct *vma,
-				    struct file_ra_state *ra,
-				    struct file *file,
-				    struct page *page,
-				    pgoff_t offset)
+static int do_async_mmap_readahead(struct vm_area_struct *vma,
+				   struct file_ra_state *ra,
+				   struct file *file,
+				   struct page *page,
+				   pgoff_t offset,
+				   int flags)
 {
 	struct address_space *mapping = file->f_mapping;
+	struct file *fpin;
 
 	/* If we don't want any read-ahead, don't bother */
 	if (vma->vm_flags & VM_RAND_READ)
-		return;
+		return 0;
 	if (ra->mmap_miss > 0)
 		ra->mmap_miss--;
-	if (PageReadahead(page))
-		page_cache_async_readahead(mapping, ra, file,
-					   page, offset, ra->ra_pages);
+	if (!PageReadahead(page))
+		return 0;
+	fpin = maybe_unlock_mmap_for_io(vma, flags);
+	page_cache_async_readahead(mapping, ra, file,
+				   page, offset, ra->ra_pages);
+	if (fpin)
+		fput(fpin);
+	return fpin ? -EAGAIN : 0;
 }
 
 /**
@@ -2479,10 +2510,8 @@ static void do_async_mmap_readahead(struct vm_area_struct *vma,
  *
  * vma->vm_mm->mmap_sem must be held on entry.
  *
- * If our return value has VM_FAULT_RETRY set, it's because
- * lock_page_or_retry() returned 0.
- * The mmap_sem has usually been released in this case.
- * See __lock_page_or_retry() for the exception.
+ * If our return value has VM_FAULT_RETRY set, the mmap_sem has
+ * usually been released.
  *
  * If our return value does not have VM_FAULT_RETRY set, the mmap_sem
  * has not been released.
@@ -2492,11 +2521,13 @@ static void do_async_mmap_readahead(struct vm_area_struct *vma,
 vm_fault_t filemap_fault(struct vm_fault *vmf)
 {
 	int error;
+	struct mm_struct *mm = vmf->vma->vm_mm;
 	struct file *file = vmf->vma->vm_file;
 	struct address_space *mapping = file->f_mapping;
 	struct file_ra_state *ra = &file->f_ra;
 	struct inode *inode = mapping->host;
 	pgoff_t offset = vmf->pgoff;
+	int flags = vmf->flags;
 	pgoff_t max_off;
 	struct page *page;
 	vm_fault_t ret = 0;
@@ -2509,27 +2540,44 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	 * Do we have something in the page cache already?
 	 */
 	page = find_get_page(mapping, offset);
-	if (likely(page) && !(vmf->flags & FAULT_FLAG_TRIED)) {
+	if (likely(page) && !(flags & FAULT_FLAG_TRIED)) {
 		/*
 		 * We found the page, so try async readahead before
 		 * waiting for the lock.
 		 */
-		do_async_mmap_readahead(vmf->vma, ra, file, page, offset);
+		error = do_async_mmap_readahead(vmf->vma, ra, file, page, offset, vmf->flags);
+		if (error == -EAGAIN)
+			goto out_retry_wait;
 	} else if (!page) {
 		/* No page in the page cache at all */
-		do_sync_mmap_readahead(vmf->vma, ra, file, offset);
-		count_vm_event(PGMAJFAULT);
-		count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
+		count_vm_event(PGMAJFAULT);
+		count_memcg_event_mm(mm, PGMAJFAULT);
+		error = do_sync_mmap_readahead(vmf->vma, ra, file, offset, vmf->flags);
+		if (error == -EAGAIN)
+			goto out_retry_wait;
 retry_find:
 		page = find_get_page(mapping, offset);
 		if (!page)
 			goto no_cached_page;
 	}
 
-	if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags)) {
-		put_page(page);
-		return ret | VM_FAULT_RETRY;
+	if (!trylock_page(page)) {
+		if (flags & FAULT_FLAG_ALLOW_RETRY) {
+			if (flags & FAULT_FLAG_RETRY_NOWAIT)
+				goto out_retry;
+			up_read(&mm->mmap_sem);
+			goto out_retry_wait;
+		}
+		if (flags & FAULT_FLAG_KILLABLE) {
+			int ret = __lock_page_killable(page);
+
+			if (ret) {
+				up_read(&mm->mmap_sem);
+				goto out_retry;
+			}
+		} else
+			__lock_page(page);
 	}
 
 	/* Did it get truncated? */
@@ -2607,6 +2655,19 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	/* Things didn't work out. Return zero to tell the mm layer so. */
 	shrink_readahead_size_eio(file, ra);
 	return VM_FAULT_SIGBUS;
+
+out_retry_wait:
+	if (page) {
+		if (flags & FAULT_FLAG_KILLABLE)
+			wait_on_page_locked_killable(page);
+		else
+			wait_on_page_locked(page);
+	}
+
+out_retry:
+	if (page)
+		put_page(page);
+	return ret | VM_FAULT_RETRY;
 }
 EXPORT_SYMBOL(filemap_fault);
 
-- 
2.14.3
