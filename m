Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B77886B00DE
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 04:36:32 -0500 (EST)
Date: Wed, 25 Feb 2009 10:36:29 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch][rfc] mm: hold page lock over page_mkwrite
Message-ID: <20090225093629.GD22785@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


I want to have the page be protected by page lock between page_mkwrite
notification to the filesystem, and the actual setting of the page
dirty. Do this by holding the page lock over page_mkwrite, and keep it
held until after set_page_dirty.

I need this in fsblock because I am working to ensure filesystem metadata
can be correctly allocated and refcounted. This means that page cleaning
should not require memory allocation (to be really robust).

Without this patch, then for example we could get a concurrent writeout
after the page_mkwrite (which allocates page metadata required to clean
it), but before the set_page_dirty. The writeout will clean the page and
notice that the metadata is now unused and may be deallocated (because
it appears clean as set_page_dirty hasn't been called yet). So at this
point the page may be dirtied via the pte without enough metadata to be
able to write it back.

---
 fs/buffer.c |   11 +++++------
 mm/memory.c |   51 ++++++++++++++++++++++++++++-----------------------
 2 files changed, 33 insertions(+), 29 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -2474,12 +2474,12 @@ block_page_mkwrite(struct vm_area_struct
 	loff_t size;
 	int ret = -EINVAL;
 
-	lock_page(page);
+	BUG_ON(page->mapping != inode->i_mapping);
+
 	size = i_size_read(inode);
-	if ((page->mapping != inode->i_mapping) ||
-	    (page_offset(page) > size)) {
+	if (page_offset(page) > size) {
 		/* page got truncated out from underneath us */
-		goto out_unlock;
+		goto out;
 	}
 
 	/* page is wholly or partially inside EOF */
@@ -2492,8 +2492,7 @@ block_page_mkwrite(struct vm_area_struct
 	if (!ret)
 		ret = block_commit_write(page, 0, end);
 
-out_unlock:
-	unlock_page(page);
+out:
 	return ret;
 }
 
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1948,9 +1948,16 @@ static int do_wp_page(struct mm_struct *
 			 */
 			page_cache_get(old_page);
 			pte_unmap_unlock(page_table, ptl);
+			lock_page(old_page);
+			if (!old_page->mapping) {
+				ret = 0;
+				goto out_error;
+			}
 
-			if (vma->vm_ops->page_mkwrite(vma, old_page) < 0)
-				goto unwritable_page;
+			if (vma->vm_ops->page_mkwrite(vma, old_page) < 0) {
+				ret = VM_FAULT_SIGBUS;
+				goto out_error;
+			}
 
 			/*
 			 * Since we dropped the lock we need to revalidate
@@ -1960,9 +1967,11 @@ static int do_wp_page(struct mm_struct *
 			 */
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
-			page_cache_release(old_page);
-			if (!pte_same(*page_table, orig_pte))
+			if (!pte_same(*page_table, orig_pte)) {
+				unlock_page(old_page);
+				page_cache_release(old_page);
 				goto unlock;
+			}
 
 			page_mkwrite = 1;
 		}
@@ -2085,19 +2094,30 @@ unlock:
 		 *
 		 * do_no_page is protected similarly.
 		 */
-		wait_on_page_locked(dirty_page);
+		if (!page_mkwrite)
+			wait_on_page_locked(dirty_page);
 		set_page_dirty_balance(dirty_page, page_mkwrite);
 		put_page(dirty_page);
+		if (page_mkwrite) {
+			unlock_page(old_page);
+			page_cache_release(old_page);
+		}
 	}
 	return ret;
 oom_free_new:
 	page_cache_release(new_page);
 oom:
-	if (old_page)
+	if (old_page) {
+		if (page_mkwrite) {
+			unlock_page(old_page);
+			page_cache_release(old_page);
+		}
 		page_cache_release(old_page);
+	}
 	return VM_FAULT_OOM;
 
-unwritable_page:
+out_error:
+	unlock_page(old_page);
 	page_cache_release(old_page);
 	return VM_FAULT_SIGBUS;
 }
@@ -2643,23 +2663,9 @@ static int __do_fault(struct mm_struct *
 			 * to become writable
 			 */
 			if (vma->vm_ops->page_mkwrite) {
-				unlock_page(page);
 				if (vma->vm_ops->page_mkwrite(vma, page) < 0) {
 					ret = VM_FAULT_SIGBUS;
 					anon = 1; /* no anon but release vmf.page */
-					goto out_unlocked;
-				}
-				lock_page(page);
-				/*
-				 * XXX: this is not quite right (racy vs
-				 * invalidate) to unlock and relock the page
-				 * like this, however a better fix requires
-				 * reworking page_mkwrite locking API, which
-				 * is better done later.
-				 */
-				if (!page->mapping) {
-					ret = 0;
-					anon = 1; /* no anon but release vmf.page */
 					goto out;
 				}
 				page_mkwrite = 1;
@@ -2713,8 +2719,6 @@ static int __do_fault(struct mm_struct *
 	pte_unmap_unlock(page_table, ptl);
 
 out:
-	unlock_page(vmf.page);
-out_unlocked:
 	if (anon)
 		page_cache_release(vmf.page);
 	else if (dirty_page) {
@@ -2724,6 +2728,7 @@ out_unlocked:
 		set_page_dirty_balance(dirty_page, page_mkwrite);
 		put_page(dirty_page);
 	}
+	unlock_page(vmf.page);
 
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
