Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5E88E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 11:30:32 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x144-v6so11298611qkb.4
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 08:30:32 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l8-v6sor820794qvp.41.2018.09.25.08.30.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 08:30:30 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 8/8] btrfs: drop mmap_sem in mkwrite for btrfs
Date: Tue, 25 Sep 2018 11:30:11 -0400
Message-Id: <20180925153011.15311-9-josef@toxicpanda.com>
In-Reply-To: <20180925153011.15311-1-josef@toxicpanda.com>
References: <20180925153011.15311-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, riel@redhat.com, hannes@cmpxchg.org, tj@kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

->page_mkwrite is extremely expensive in btrfs.  We have to reserve
space, which can take 6 lifetimes, and we could possibly have to wait on
writeback on the page, another several lifetimes.  To avoid this simply
drop the mmap_sem if we didn't have the cached page and do all of our
work and return the appropriate retry error.  If we have the cached page
we know we did all the right things to set this page up and we can just
carry on.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 fs/btrfs/inode.c   | 40 ++++++++++++++++++++++++++++++++++++++--
 include/linux/mm.h | 14 ++++++++++++++
 mm/filemap.c       |  3 ++-
 3 files changed, 54 insertions(+), 3 deletions(-)

diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 3ea5339603cf..34c33b96d335 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -8809,7 +8809,9 @@ static void btrfs_invalidatepage(struct page *page, unsigned int offset,
 vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
-	struct inode *inode = file_inode(vmf->vma->vm_file);
+	struct file *file = vmf->vma->vm_file, *fpin;
+	struct mm_struct *mm = vmf->vma->vm_mm;
+	struct inode *inode = file_inode(file);
 	struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
 	struct extent_io_tree *io_tree = &BTRFS_I(inode)->io_tree;
 	struct btrfs_ordered_extent *ordered;
@@ -8828,6 +8830,29 @@ vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
 
 	reserved_space = PAGE_SIZE;
 
+	/*
+	 * We have our cached page from a previous mkwrite, check it to make
+	 * sure it's still dirty and our file size matches when we ran mkwrite
+	 * the last time.  If everything is OK then return VM_FAULT_LOCKED,
+	 * otherwise do the mkwrite again.
+	 */
+	if (vmf->flags & FAULT_FLAG_USED_CACHED) {
+		lock_page(page);
+		if (vmf->cached_size == i_size_read(inode) &&
+		    PageDirty(page))
+			return VM_FAULT_LOCKED;
+		unlock_page(page);
+	}
+
+	/*
+	 * mkwrite is extremely expensive, and we are holding the mmap_sem
+	 * during this, which means we can starve out anybody trying to
+	 * down_write(mmap_sem) for a long while, especially if we throw cgroups
+	 * into the mix.  So just drop the mmap_sem and do all of our work,
+	 * we'll loop back through and verify everything is ok the next time and
+	 * hopefully avoid doing the work twice.
+	 */
+	fpin = maybe_unlock_mmap_for_io(vmf->vma, vmf->flags);
 	sb_start_pagefault(inode->i_sb);
 	page_start = page_offset(page);
 	page_end = page_start + PAGE_SIZE - 1;
@@ -8844,7 +8869,7 @@ vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
 	ret2 = btrfs_delalloc_reserve_space(inode, &data_reserved, page_start,
 					   reserved_space);
 	if (!ret2) {
-		ret2 = file_update_time(vmf->vma->vm_file);
+		ret2 = file_update_time(file);
 		reserved = 1;
 	}
 	if (ret2) {
@@ -8943,6 +8968,13 @@ vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
 		btrfs_delalloc_release_extents(BTRFS_I(inode), PAGE_SIZE, true);
 		sb_end_pagefault(inode->i_sb);
 		extent_changeset_free(data_reserved);
+		if (fpin) {
+			unlock_page(page);
+			fput(fpin);
+			vmf->cached_size = size;
+			down_read(&mm->mmap_sem);
+			return VM_FAULT_RETRY;
+		}
 		return VM_FAULT_LOCKED;
 	}
 
@@ -8955,6 +8987,10 @@ vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
 out_noreserve:
 	sb_end_pagefault(inode->i_sb);
 	extent_changeset_free(data_reserved);
+	if (fpin) {
+		fput(fpin);
+		down_read(&mm->mmap_sem);
+	}
 	return ret;
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 10a0118f5485..b9ad6cb3de84 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -370,6 +370,13 @@ struct vm_fault {
 					 * next time we loop through the fault
 					 * handler for faster lookup.
 					 */
+	loff_t cached_size;		/* ->page_mkwrite handlers may drop
+					 * the mmap_sem to avoid starvation, in
+					 * which case they need to save the
+					 * i_size in order to verify the cached
+					 * page we're using the next loop
+					 * through hasn't changed under us.
+					 */
 	/* These three entries are valid only while holding ptl lock */
 	pte_t *pte;			/* Pointer to pte entry matching
 					 * the 'address'. NULL if the page
@@ -1435,6 +1442,8 @@ extern vm_fault_t handle_mm_fault(struct vm_fault *vmf);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags,
 			    bool *unlocked);
+extern struct file *maybe_unlock_mmap_for_io(struct vm_area_struct *vma,
+					     int flags);
 void unmap_mapping_pages(struct address_space *mapping,
 		pgoff_t start, pgoff_t nr, bool even_cows);
 void unmap_mapping_range(struct address_space *mapping,
@@ -1454,6 +1463,11 @@ static inline int fixup_user_fault(struct task_struct *tsk,
 	BUG();
 	return -EFAULT;
 }
+stiatc inline struct file *maybe_unlock_mmap_for_io(struct vm_area_struct *vma,
+						    int flags)
+{
+	return NULL;
+}
 static inline void unmap_mapping_pages(struct address_space *mapping,
 		pgoff_t start, pgoff_t nr, bool even_cows) { }
 static inline void unmap_mapping_range(struct address_space *mapping,
diff --git a/mm/filemap.c b/mm/filemap.c
index 75a8b252814a..748c696d23af 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2366,7 +2366,7 @@ generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 EXPORT_SYMBOL(generic_file_read_iter);
 
 #ifdef CONFIG_MMU
-static struct file *maybe_unlock_mmap_for_io(struct vm_area_struct *vma, int flags)
+struct file *maybe_unlock_mmap_for_io(struct vm_area_struct *vma, int flags)
 {
 	if ((flags & (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT)) == FAULT_FLAG_ALLOW_RETRY) {
 		struct file *file;
@@ -2377,6 +2377,7 @@ static struct file *maybe_unlock_mmap_for_io(struct vm_area_struct *vma, int fla
 	}
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(maybe_unlock_mmap_for_io);
 
 /**
  * page_cache_read - adds requested page to the page cache if not already there
-- 
2.14.3
