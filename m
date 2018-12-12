Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 358438E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 10:28:02 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id v20so10992848ywa.10
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 07:28:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k10sor685786ybh.207.2018.12.12.07.28.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 07:28:00 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH][v6] filemap: drop the mmap_sem for all blocking operations
Date: Wed, 12 Dec 2018 10:27:57 -0500
Message-Id: <20181212152757.10017-1-josef@toxicpanda.com>
In-Reply-To: <20181211173801.29535-4-josef@toxicpanda.com>
References: <20181211173801.29535-4-josef@toxicpanda.com>
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

Even if the readahead does something, it could get throttled because of
io pressure on the system and the process is in a lower priority cgroup.

Holding the mmap_sem while doing IO is problematic because it can cause
system-wide priority inversions.  Consider some large company that does
a lot of web traffic.  This large company has load balancing logic in
it's core web server, cause some engineer thought this was a brilliant
plan.  This load balancing logic gets statistics from /proc about the
system, which trip over processes mmap_sem for various reasons.  Now the
web server application is in a protected cgroup, but these other
processes may not be, and if they are being throttled while their
mmap_sem is held we'll stall, and cause this nice death spiral.

Instead rework filemap fault path to drop the mmap sem at any point that
we may do IO or block for an extended period of time.  This includes
while issuing readahead, locking the page, or needing to call ->readpage
because readahead did not occur.  Then once we have a fully uptodate
page we can return with VM_FAULT_RETRY and come back again to find our
nicely in-cache page that was gotten outside of the mmap_sem.

This patch also adds a new helper for locking the page with the mmap_sem
dropped.  This doesn't make sense currently as generally speaking if the
page is already locked it'll have been read in (unless there was an
error) before it was unlocked.  However a forthcoming patchset will
change this with the ability to abort read-ahead bio's if necessary,
making it more likely that we could contend for a page lock and still
have a not uptodate page.  This allows us to deal with this case by
grabbing the lock and issuing the IO without the mmap_sem held, and then
returning VM_FAULT_RETRY to come back around.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
v5->v6:
- added more comments as per Andrew's suggestion.
- fixed the fpin leaks in the two error paths that were pointed out.

 mm/filemap.c | 135 ++++++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 116 insertions(+), 19 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 8fc45f24b201..42e03decf20f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2304,28 +2304,91 @@ EXPORT_SYMBOL(generic_file_read_iter);
 
 #ifdef CONFIG_MMU
 #define MMAP_LOTSAMISS  (100)
+static struct file *maybe_unlock_mmap_for_io(struct vm_fault *vmf,
+					     struct file *fpin)
+{
+	int flags = vmf->flags;
+	if (fpin)
+		return fpin;
+
+	/*
+	 * FAULT_FLAG_RETRY_NOWAIT means we don't want to wait on page locks or
+	 * anything, so we only pin the file and drop the mmap_sem if only
+	 * FAULT_FLAG_ALLOW_RETRY is set.
+	 */
+	if ((flags & (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT)) ==
+	    FAULT_FLAG_ALLOW_RETRY) {
+		fpin = get_file(vmf->vma->vm_file);
+		up_read(&vmf->vma->vm_mm->mmap_sem);
+	}
+	return fpin;
+}
 
 /*
- * Synchronous readahead happens when we don't even find
- * a page in the page cache at all.
+ * lock_page_maybe_drop_mmap - lock the page, possibly dropping the mmap_sem
+ * @vmf - the vm_fault for this fault.
+ * @page - the page to lock.
+ * @fpin - the pointer to the file we may pin (or is already pinned).
+ *
+ * This works similar to lock_page_or_retry in that it can drop the mmap_sem.
+ * It differs in that it actually returns the page locked if it returns 1 and 0
+ * if it couldn't lock the page.  If we did have to drop the mmap_sem then fpin
+ * will point to the pinned file and needs to be fput()'ed at a later point.
  */
-static void do_sync_mmap_readahead(struct vm_fault *vmf)
+static int lock_page_maybe_drop_mmap(struct vm_fault *vmf, struct page *page,
+				     struct file **fpin)
+{
+	if (trylock_page(page))
+		return 1;
+
+	if (vmf->flags & FAULT_FLAG_RETRY_NOWAIT)
+		return 0;
+
+	*fpin = maybe_unlock_mmap_for_io(vmf, *fpin);
+	if (vmf->flags & FAULT_FLAG_KILLABLE) {
+		if (__lock_page_killable(page)) {
+			/*
+			 * We didn't have the right flags to drop the mmap_sem,
+			 * but all fault_handlers only check for fatal signals
+			 * if we return VM_FAULT_RETRY, so we need to drop the
+			 * mmap_sem here and return 0 if we don't have a fpin.
+			 */
+			if (*fpin == NULL)
+				up_read(&vmf->vma->vm_mm->mmap_sem);
+			return 0;
+		}
+	} else
+		__lock_page(page);
+	return 1;
+}
+
+
+/*
+ * Synchronous readahead happens when we don't even find a page in the page
+ * cache at all.  We don't want to perform IO under the mmap sem, so if we have
+ * to drop the mmap sem we return the file that was pinned in order for us to do
+ * that.  If we didn't pin a file then we return NULL.  The file that is
+ * returned needs to be fput()'ed when we're done with it.
+ */
+static struct file *do_sync_mmap_readahead(struct vm_fault *vmf)
 {
 	struct file *file = vmf->vma->vm_file;
 	struct file_ra_state *ra = &file->f_ra;
 	struct address_space *mapping = file->f_mapping;
+	struct file *fpin = NULL;
 	pgoff_t offset = vmf->pgoff;
 
 	/* If we don't want any read-ahead, don't bother */
 	if (vmf->vma->vm_flags & VM_RAND_READ)
-		return;
+		return fpin;
 	if (!ra->ra_pages)
-		return;
+		return fpin;
 
 	if (vmf->vma->vm_flags & VM_SEQ_READ) {
+		fpin = maybe_unlock_mmap_for_io(vmf, fpin);
 		page_cache_sync_readahead(mapping, ra, file, offset,
 					  ra->ra_pages);
-		return;
+		return fpin;
 	}
 
 	/* Avoid banging the cache line if not needed */
@@ -2337,37 +2400,44 @@ static void do_sync_mmap_readahead(struct vm_fault *vmf)
 	 * stop bothering with read-ahead. It will only hurt.
 	 */
 	if (ra->mmap_miss > MMAP_LOTSAMISS)
-		return;
+		return fpin;
 
 	/*
 	 * mmap read-around
 	 */
+	fpin = maybe_unlock_mmap_for_io(vmf, fpin);
 	ra->start = max_t(long, 0, offset - ra->ra_pages / 2);
 	ra->size = ra->ra_pages;
 	ra->async_size = ra->ra_pages / 4;
 	ra_submit(ra, mapping, file);
+	return fpin;
 }
 
 /*
  * Asynchronous readahead happens when we find the page and PG_readahead,
- * so we want to possibly extend the readahead further..
+ * so we want to possibly extend the readahead further.  We return the file that
+ * was pinned if we have to drop the mmap_sem in order to do IO.
  */
-static void do_async_mmap_readahead(struct vm_fault *vmf,
-				    struct page *page)
+static struct file *do_async_mmap_readahead(struct vm_fault *vmf,
+					    struct page *page)
 {
 	struct file *file = vmf->vma->vm_file;
 	struct file_ra_state *ra = &file->f_ra;
 	struct address_space *mapping = file->f_mapping;
+	struct file *fpin = NULL;
 	pgoff_t offset = vmf->pgoff;
 
 	/* If we don't want any read-ahead, don't bother */
 	if (vmf->vma->vm_flags & VM_RAND_READ)
-		return;
+		return fpin;
 	if (ra->mmap_miss > 0)
 		ra->mmap_miss--;
-	if (PageReadahead(page))
+	if (PageReadahead(page)) {
+		fpin = maybe_unlock_mmap_for_io(vmf, fpin);
 		page_cache_async_readahead(mapping, ra, file,
 					   page, offset, ra->ra_pages);
+	}
+	return fpin;
 }
 
 /**
@@ -2397,6 +2467,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 {
 	int error;
 	struct file *file = vmf->vma->vm_file;
+	struct file *fpin = NULL;
 	struct address_space *mapping = file->f_mapping;
 	struct file_ra_state *ra = &file->f_ra;
 	struct inode *inode = mapping->host;
@@ -2418,10 +2489,10 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		 * We found the page, so try async readahead before
 		 * waiting for the lock.
 		 */
-		do_async_mmap_readahead(vmf, page);
+		fpin = do_async_mmap_readahead(vmf, page);
 	} else if (!page) {
 		/* No page in the page cache at all */
-		do_sync_mmap_readahead(vmf);
+		fpin = do_sync_mmap_readahead(vmf);
 		count_vm_event(PGMAJFAULT);
 		count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
@@ -2429,14 +2500,15 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		page = pagecache_get_page(mapping, offset,
 					  FGP_CREAT|FGP_FOR_MMAP,
 					  vmf->gfp_mask);
-		if (!page)
+		if (!page) {
+			if (fpin)
+				goto out_retry;
 			return vmf_error(-ENOMEM);
+		}
 	}
 
-	if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags)) {
-		put_page(page);
-		return ret | VM_FAULT_RETRY;
-	}
+	if (!lock_page_maybe_drop_mmap(vmf, page, &fpin))
+		goto out_retry;
 
 	/* Did it get truncated? */
 	if (unlikely(page->mapping != mapping)) {
@@ -2453,6 +2525,16 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
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
@@ -2475,12 +2557,15 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	 * and we need to check for errors.
 	 */
 	ClearPageError(page);
+	fpin = maybe_unlock_mmap_for_io(vmf, fpin);
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
@@ -2489,6 +2574,18 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
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
