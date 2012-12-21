Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 8F1DC6B0070
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 16:28:46 -0500 (EST)
Received: by mail-da0-f54.google.com with SMTP id n2so2275195dad.27
        for <linux-mm@kvack.org>; Fri, 21 Dec 2012 13:28:45 -0800 (PST)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH v2 3/3] Remove file_update_time from all mkwrite paths
Date: Fri, 21 Dec 2012 13:28:28 -0800
Message-Id: <71eda8f19427d043be9e0a48c6236df3084e2804.1356124965.git.luto@amacapital.net>
In-Reply-To: <cover.1356124965.git.luto@amacapital.net>
References: <cover.1356124965.git.luto@amacapital.net>
In-Reply-To: <cover.1356124965.git.luto@amacapital.net>
References: <cover.1356124965.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@amacapital.net>

The times are now updated at sync time.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 fs/9p/vfs_file.c | 3 ---
 fs/btrfs/inode.c | 4 +---
 fs/buffer.c      | 6 ------
 fs/ceph/addr.c   | 3 ---
 fs/ext4/inode.c  | 1 -
 fs/gfs2/file.c   | 3 ---
 fs/nilfs2/file.c | 1 -
 fs/sysfs/bin.c   | 2 --
 mm/filemap.c     | 1 -
 mm/memory.c      | 3 ---
 10 files changed, 1 insertion(+), 26 deletions(-)

diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index c2483e9..34b84f0 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -610,9 +610,6 @@ v9fs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	p9_debug(P9_DEBUG_VFS, "page %p fid %lx\n",
 		 page, (unsigned long)filp->private_data);
 
-	/* Update file times before taking page lock */
-	file_update_time(filp);
-
 	v9inode = V9FS_I(inode);
 	/* make sure the cache has finished storing the page */
 	v9fs_fscache_wait_on_page_write(inode, page);
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 95542a1..6fb8558 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -6747,10 +6747,8 @@ int btrfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	sb_start_pagefault(inode->i_sb);
 	ret  = btrfs_delalloc_reserve_space(inode, PAGE_CACHE_SIZE);
 	if (!ret) {
-		ret = file_update_time(vma->vm_file);
 		reserved = 1;
-	}
-	if (ret) {
+	} else if (ret) {
 		if (ret == -ENOMEM)
 			ret = VM_FAULT_OOM;
 		else /* -ENOSPC, -EIO, etc */
diff --git a/fs/buffer.c b/fs/buffer.c
index ec0aca8..a9a8f2a 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2379,12 +2379,6 @@ int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 	sb_start_pagefault(sb);
 
-	/*
-	 * Update file times before taking page lock. We may end up failing the
-	 * fault so this update may be superfluous but who really cares...
-	 */
-	file_update_time(vma->vm_file);
-
 	ret = __block_page_mkwrite(vma, vmf, get_block);
 	sb_end_pagefault(sb);
 	return block_page_mkwrite_return(ret);
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 6690269..19af339 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1183,9 +1183,6 @@ static int ceph_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	loff_t size, len;
 	int ret;
 
-	/* Update time before taking page lock */
-	file_update_time(vma->vm_file);
-
 	size = i_size_read(inode);
 	if (off + PAGE_CACHE_SIZE <= size)
 		len = PAGE_CACHE_SIZE;
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index b3c243b..5ddbc75 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4780,7 +4780,6 @@ int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	int retries = 0;
 
 	sb_start_pagefault(inode->i_sb);
-	file_update_time(vma->vm_file);
 	/* Delalloc case is easy... */
 	if (test_opt(inode->i_sb, DELALLOC) &&
 	    !ext4_should_journal_data(inode) &&
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index e056b4c..999b1ed 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -398,9 +398,6 @@ static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	sb_start_pagefault(inode->i_sb);
 
-	/* Update file times before taking page lock */
-	file_update_time(vma->vm_file);
-
 	ret = gfs2_rs_alloc(ip);
 	if (ret)
 		return ret;
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index 16f35f7..185b8e6 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -116,7 +116,6 @@ static int nilfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (unlikely(ret))
 		goto out;
 
-	file_update_time(vma->vm_file);
 	ret = __block_page_mkwrite(vma, vmf, nilfs_get_block);
 	if (ret) {
 		nilfs_transaction_abort(inode->i_sb);
diff --git a/fs/sysfs/bin.c b/fs/sysfs/bin.c
index 614b2b5..a475983 100644
--- a/fs/sysfs/bin.c
+++ b/fs/sysfs/bin.c
@@ -228,8 +228,6 @@ static int bin_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	ret = 0;
 	if (bb->vm_ops->page_mkwrite)
 		ret = bb->vm_ops->page_mkwrite(vma, vmf);
-	else
-		file_update_time(file);
 
 	sysfs_put_active(attr_sd);
 	return ret;
diff --git a/mm/filemap.c b/mm/filemap.c
index 83efee7..feb0540 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1715,7 +1715,6 @@ int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	int ret = VM_FAULT_LOCKED;
 
 	sb_start_pagefault(inode->i_sb);
-	file_update_time(vma->vm_file);
 	lock_page(page);
 	if (page->mapping != inode->i_mapping) {
 		unlock_page(page);
diff --git a/mm/memory.c b/mm/memory.c
index 086b901..07a0b0d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2658,9 +2658,6 @@ reuse:
 		if (!page_mkwrite) {
 			wait_on_page_locked(dirty_page);
 			set_page_dirty_balance(dirty_page, page_mkwrite);
-			/* file_update_time outside page_lock */
-			if (vma->vm_file)
-				file_update_time(vma->vm_file);
 		}
 		put_page(dirty_page);
 		if (page_mkwrite) {
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
