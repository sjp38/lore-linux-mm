Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id F0A256B59F1
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 14:58:20 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id l69so4404043ywb.7
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 11:58:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z125sor1061669ywa.67.2018.11.30.11.58.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Nov 2018 11:58:19 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 3/4] filemap: drop the mmap_sem for all blocking operations
Date: Fri, 30 Nov 2018 14:58:11 -0500
Message-Id: <20181130195812.19536-4-josef@toxicpanda.com>
In-Reply-To: <20181130195812.19536-1-josef@toxicpanda.com>
References: <20181130195812.19536-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

Currently we only drop the mmap_sem if there is contention on the page
lock.  The idea is that we issue readahead and then go to lock the page
while it is under IO and we want to not hold the mmap_sem during the IO.

The problem with this is the assumption that the readahead does
anything.  In the case that the box is under extreme memory or IO
pressure we may end up not reading anything at all for readahead, which
means we will end up reading in the page under the mmap_sem.

Instead rework filemap fault path to drop the mmap sem at any point that
we may do IO or block for an extended period of time.  This includes
while issuing readahead, locking the page, or needing to call ->readpage
because readahead did not occur.  Then once we have a fully uptodate
page we can return with VM_FAULT_RETRY and come back again to find our
nicely in-cache page that was gotten outside of the mmap_sem.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 mm/filemap.c | 113 ++++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 93 insertions(+), 20 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index f068712c2525..5e76b24b2a0f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2304,28 +2304,44 @@ EXPORT_SYMBOL(generic_file_read_iter);
 
 #ifdef CONFIG_MMU
 #define MMAP_LOTSAMISS  (100)
+static struct file *maybe_unlock_mmap_for_io(struct file *fpin,
+					     struct vm_area_struct *vma,
+					     int flags)
+{
+	if (fpin)
+		return fpin;
+	if ((flags & (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT)) ==
+	    FAULT_FLAG_ALLOW_RETRY) {
+		fpin = get_file(vma->vm_file);
+		up_read(&vma->vm_mm->mmap_sem);
+	}
+	return fpin;
+}
 
 /*
  * Synchronous readahead happens when we don't even find
  * a page in the page cache at all.
  */
-static void do_sync_mmap_readahead(struct vm_area_struct *vma,
-				   struct file_ra_state *ra,
-				   struct file *file,
-				   pgoff_t offset)
+static struct file *do_sync_mmap_readahead(struct vm_area_struct *vma,
+					   struct file_ra_state *ra,
+					   struct file *file,
+					   pgoff_t offset,
+					   int flags)
 {
 	struct address_space *mapping = file->f_mapping;
+	struct file *fpin = NULL;
 
 	/* If we don't want any read-ahead, don't bother */
 	if (vma->vm_flags & VM_RAND_READ)
-		return;
+		return fpin;
 	if (!ra->ra_pages)
-		return;
+		return fpin;
 
 	if (vma->vm_flags & VM_SEQ_READ) {
+		fpin = maybe_unlock_mmap_for_io(fpin, vma, flags);
 		page_cache_sync_readahead(mapping, ra, file, offset,
 					  ra->ra_pages);
-		return;
+		return fpin;
 	}
 
 	/* Avoid banging the cache line if not needed */
@@ -2337,37 +2353,43 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
 	 * stop bothering with read-ahead. It will only hurt.
 	 */
 	if (ra->mmap_miss > MMAP_LOTSAMISS)
-		return;
+		return fpin;
 
 	/*
 	 * mmap read-around
 	 */
+	fpin = maybe_unlock_mmap_for_io(fpin, vma, flags);
 	ra->start = max_t(long, 0, offset - ra->ra_pages / 2);
 	ra->size = ra->ra_pages;
 	ra->async_size = ra->ra_pages / 4;
 	ra_submit(ra, mapping, file);
+	return fpin;
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
+static struct file *do_async_mmap_readahead(struct vm_area_struct *vma,
+					    struct file_ra_state *ra,
+					    struct file *file,
+					    struct page *page,
+					    pgoff_t offset, int flags)
 {
 	struct address_space *mapping = file->f_mapping;
+	struct file *fpin = NULL;
 
 	/* If we don't want any read-ahead, don't bother */
 	if (vma->vm_flags & VM_RAND_READ)
-		return;
+		return fpin;
 	if (ra->mmap_miss > 0)
 		ra->mmap_miss--;
-	if (PageReadahead(page))
+	if (PageReadahead(page)) {
+		fpin = maybe_unlock_mmap_for_io(fpin, vma, flags);
 		page_cache_async_readahead(mapping, ra, file,
 					   page, offset, ra->ra_pages);
+	}
+	return fpin;
 }
 
 /**
@@ -2397,6 +2419,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 {
 	int error;
 	struct file *file = vmf->vma->vm_file;
+	struct file *fpin = NULL;
 	struct address_space *mapping = file->f_mapping;
 	struct file_ra_state *ra = &file->f_ra;
 	struct inode *inode = mapping->host;
@@ -2418,10 +2441,12 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		 * We found the page, so try async readahead before
 		 * waiting for the lock.
 		 */
-		do_async_mmap_readahead(vmf->vma, ra, file, page, offset);
+		fpin = do_async_mmap_readahead(vmf->vma, ra, file, page, offset,
+					       vmf->flags);
 	} else if (!page) {
 		/* No page in the page cache at all */
-		do_sync_mmap_readahead(vmf->vma, ra, file, offset);
+		fpin = do_sync_mmap_readahead(vmf->vma, ra, file, offset,
+					      vmf->flags);
 		count_vm_event(PGMAJFAULT);
 		count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
@@ -2433,9 +2458,32 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 			return vmf_error(-ENOMEM);
 	}
 
-	if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags)) {
-		put_page(page);
-		return ret | VM_FAULT_RETRY;
+	/*
+	 * We are open-coding lock_page_or_retry here because we want to do the
+	 * readpage if necessary while the mmap_sem is dropped.  If there
+	 * happens to be a lock on the page but it wasn't being faulted in we'd
+	 * come back around without ALLOW_RETRY set and then have to do the IO
+	 * under the mmap_sem, which would be a bummer.
+	 */
+	if (!trylock_page(page)) {
+		fpin = maybe_unlock_mmap_for_io(fpin, vmf->vma, vmf->flags);
+		if (vmf->flags & FAULT_FLAG_RETRY_NOWAIT)
+			goto out_retry;
+		if (vmf->flags & FAULT_FLAG_KILLABLE) {
+			if (__lock_page_killable(page)) {
+				/*
+				 * If we don't have the right flags for
+				 * maybe_unlock_mmap_for_io to do it's thing we
+				 * still need to drop the sem and return
+				 * VM_FAULT_RETRY so the upper layer checks the
+				 * signal and takes the appropriate action.
+				 */
+				if (!fpin)
+					up_read(&vmf->vma->vm_mm->mmap_sem);
+				goto out_retry;
+			}
+		} else
+			__lock_page(page);
 	}
 
 	/* Did it get truncated? */
@@ -2453,6 +2501,16 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	if (unlikely(!PageUptodate(page)))
 		goto page_not_uptodate;
 
+	/*
+	 * We've made it this far and we had to drop our mmap_sem, now is the
+	 * time to return to the upper layer and have it re-find the vma and
+	 * redo the fault.
+	 */
+	if (fpin) {
+		unlock_page(page);
+		goto out_retry;
+	}
+
 	/*
 	 * Found the page and have a reference on it.
 	 * We must recheck i_size under page lock.
@@ -2475,12 +2533,15 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	 * and we need to check for errors.
 	 */
 	ClearPageError(page);
+	fpin = maybe_unlock_mmap_for_io(fpin, vmf->vma, vmf->flags);
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
 		wait_on_page_locked(page);
 		if (!PageUptodate(page))
 			error = -EIO;
 	}
+	if (fpin)
+		goto out_retry;
 	put_page(page);
 
 	if (!error || error == AOP_TRUNCATED_PAGE)
@@ -2489,6 +2550,18 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	/* Things didn't work out. Return zero to tell the mm layer so. */
 	shrink_readahead_size_eio(file, ra);
 	return VM_FAULT_SIGBUS;
+
+out_retry:
+	/*
+	 * We dropped the mmap_sem, we need to return to the fault handler to
+	 * re-find the vma and come back and find our hopefully still populated
+	 * page.
+	 */
+	if (page)
+		put_page(page);
+	if (fpin)
+		fput(fpin);
+	return ret | VM_FAULT_RETRY;
 }
 EXPORT_SYMBOL(filemap_fault);
 
-- 
2.14.3
