From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: close page_mkwrite races (try 2)
Date: Tue, 14 Apr 2009 09:11:52 +0200
Message-ID: <20090414071152.GC23528__43030.8975316167$1239693221$gmane$org@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5DF5F0002
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 03:11:46 -0400 (EDT)
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Sage Weil <sage@newdream.net>, Trond Myklebust <trond.myklebust@fys.uio.no>, linux-fsdevel@vger.kernel.orgLinux Memory Management List <l>
List-Id: linux-mm.kvack.org

Let's try this again with a better changelog.
--

Change page_mkwrite to allow callers to return with the page locked,
and change it's page fault callers to hold the lock until the page
is marked dirty. This allows the filesystem to have full control of
metadata associated with a dirty page. We'd like to call page_mkwrite
with the page unlocked and return with it locked, so that filesystems
can avoid LOR conditions with page lock.

A filesystem that wants to set some metadata to a page while it
is dirty, will manipulate the metadata in its ->page_mkwrite. At
this point, even if it does a set_page_dirty in its page_mkwrite
handler, it must return with the page unlocked (according to the
page_mkwrite convention).

In this window, the VM could write out the page, clearing page-dirty.
The filesystem has no way to detect that a dirty pte is about to be
attached, so it will happily write out the page, at which point, the
dirty-page metadata might be freed.

It is not always possible to perform the required metadata manipulation
in ->set_page_dirty, because that function cannot block or fail.

The VM cannot mark the pte dirty before page_mkwrite, because
page_mkwrite is allowed to fail (and anyway, it would probably be
hard to avoid races where the pte gets cleaned along the way).

Holding the page locked over the 3 critical operations (page_mkwrite,
setting the pte dirty, and finally setting the page dirty) closes out
races nicely, because the page must be locked to clean it for writeout.
It provides the filesystem with a strong synchronisation against VM.

- Sage needs this race closed for ceph filesystem.
- Trond for NFS (http://bugzilla.kernel.org/show_bug.cgi?id=12913).
- I need it for fsblock.
- I suspect other filesystems may need it too (eg. btrfs).
- I have converted buffer.c to the new locking. Even simple block allocation
  under dirty pages might be susceptible to i_size changing under partial
  page at the end of file (we also have a buffer.c-side problem here, but it
  cannot be fixed properly without this patch).
- Other filesystems (eg. NFS, maybe btrfs) will need to change their
  page_mkwrite functions themselves.

[ This also moves page_mkwrite another step closer to fault, which
should eventually allow page_mkwrite to be moved into ->fault, and
thus avoiding a filesystem calldown and page lock/unlock cycle in
__do_fault. ]

Cc: Sage Weil <sage@newdream.net>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 Documentation/filesystems/Locking |   24 +++++++---
 fs/buffer.c                       |   10 ++--
 mm/memory.c                       |   83 ++++++++++++++++++++++++++------------
 3 files changed, 79 insertions(+), 38 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -2383,7 +2383,8 @@ block_page_mkwrite(struct vm_area_struct
 	if ((page->mapping != inode->i_mapping) ||
 	    (page_offset(page) > size)) {
 		/* page got truncated out from underneath us */
-		goto out_unlock;
+		unlock_page(page);
+		goto out;
 	}
 
 	/* page is wholly or partially inside EOF */
@@ -2397,14 +2398,15 @@ block_page_mkwrite(struct vm_area_struct
 		ret = block_commit_write(page, 0, end);
 
 	if (unlikely(ret)) {
+		unlock_page(page);
 		if (ret == -ENOMEM)
 			ret = VM_FAULT_OOM;
 		else /* -ENOSPC, -EIO, etc */
 			ret = VM_FAULT_SIGBUS;
-	}
+	} else
+		ret = VM_FAULT_LOCKED;
 
-out_unlock:
-	unlock_page(page);
+out:
 	return ret;
 }
 
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1971,6 +1971,15 @@ static int do_wp_page(struct mm_struct *
 				ret = tmp;
 				goto unwritable_page;
 			}
+			if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
+				lock_page(old_page);
+				if (!old_page->mapping) {
+					ret = 0; /* retry the fault */
+					unlock_page(old_page);
+					goto unwritable_page;
+				}
+			} else
+				VM_BUG_ON(!PageLocked(old_page));
 
 			/*
 			 * Since we dropped the lock we need to revalidate
@@ -1980,9 +1989,11 @@ static int do_wp_page(struct mm_struct *
 			 */
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
-			page_cache_release(old_page);
-			if (!pte_same(*page_table, orig_pte))
+			if (!pte_same(*page_table, orig_pte)) {
+				page_cache_release(old_page);
+				unlock_page(old_page);
 				goto unlock;
+			}
 
 			page_mkwrite = 1;
 		}
@@ -2105,16 +2116,30 @@ unlock:
 		 *
 		 * do_no_page is protected similarly.
 		 */
-		wait_on_page_locked(dirty_page);
-		set_page_dirty_balance(dirty_page, page_mkwrite);
+		if (!page_mkwrite) {
+			wait_on_page_locked(dirty_page);
+			set_page_dirty_balance(dirty_page, page_mkwrite);
+		}
 		put_page(dirty_page);
+		if (page_mkwrite) {
+			struct address_space *mapping = old_page->mapping;
+
+			unlock_page(old_page);
+			page_cache_release(old_page);
+			balance_dirty_pages_ratelimited(mapping);
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
 
 unwritable_page:
@@ -2664,27 +2689,22 @@ static int __do_fault(struct mm_struct *
 				int tmp;
 
 				unlock_page(page);
-				vmf.flags |= FAULT_FLAG_MKWRITE;
+				vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 				tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
 				if (unlikely(tmp &
 					  (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
 					ret = tmp;
-					anon = 1; /* no anon but release vmf.page */
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
-					goto out;
+					goto unwritable_page;
 				}
+				if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
+					lock_page(page);
+					if (!page->mapping) {
+						ret = 0; /* retry the fault */
+						unlock_page(page);
+						goto unwritable_page;
+					}
+				} else
+					VM_BUG_ON(!PageLocked(page));
 				page_mkwrite = 1;
 			}
 		}
@@ -2736,19 +2756,30 @@ static int __do_fault(struct mm_struct *
 	pte_unmap_unlock(page_table, ptl);
 
 out:
-	unlock_page(vmf.page);
-out_unlocked:
-	if (anon)
-		page_cache_release(vmf.page);
-	else if (dirty_page) {
+	if (dirty_page) {
+		struct address_space *mapping = page->mapping;
+
 		if (vma->vm_file)
 			file_update_time(vma->vm_file);
 
+		if (set_page_dirty(dirty_page))
+			page_mkwrite = 1;
 		set_page_dirty_balance(dirty_page, page_mkwrite);
+		unlock_page(dirty_page);
 		put_page(dirty_page);
+		if (page_mkwrite)
+			balance_dirty_pages_ratelimited(mapping);
+	} else {
+		unlock_page(vmf.page);
+		if (anon)
+			page_cache_release(vmf.page);
 	}
 
 	return ret;
+
+unwritable_page:
+	page_cache_release(page);
+	return ret;
 }
 
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
Index: linux-2.6/Documentation/filesystems/Locking
===================================================================
--- linux-2.6.orig/Documentation/filesystems/Locking
+++ linux-2.6/Documentation/filesystems/Locking
@@ -512,16 +512,24 @@ locking rules:
 		BKL	mmap_sem	PageLocked(page)
 open:		no	yes
 close:		no	yes
-fault:		no	yes
-page_mkwrite:	no	yes		no
+fault:		no	yes		can return with page locked
+page_mkwrite:	no	yes		can return with page locked
 access:		no	yes
 
-	->page_mkwrite() is called when a previously read-only page is
-about to become writeable. The file system is responsible for
-protecting against truncate races. Once appropriate action has been
-taking to lock out truncate, the page range should be verified to be
-within i_size. The page mapping should also be checked that it is not
-NULL.
+	->fault() is called when a previously not present pte is about
+to be faulted in. The filesystem must find and return the page associated
+with the passed in "pgoff" in the vm_fault structure. If it is possible that
+the page may be truncated and/or invalidated, then the filesystem must lock
+the page, then ensure it is not already truncated (the page lock will block
+subsequent truncate), and then return with VM_FAULT_LOCKED, and the page
+locked. The VM will unlock the page.
+
+	->page_mkwrite() is called when a previously read-only pte is
+about to become writeable. The filesystem again must ensure that there are
+no truncate/invalidate races, and then return with the page locked. If
+the page has been truncated, the filesystem should not look up a new page
+like the ->fault() handler, but simply return with VM_FAULT_NOPAGE, which
+will cause the VM to retry the fault.
 
 	->access() is called when get_user_pages() fails in
 acces_process_vm(), typically used to debug a process through

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
