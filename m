Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 788776B0144
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 06:13:04 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so1685277eek.40
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 03:13:02 -0700 (PDT)
Message-ID: <515FF380.5020406@gmail.com>
Date: Sat, 06 Apr 2013 12:05:52 +0200
From: Marco Stornelli <marco.stornelli@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 3/4] fsfreeze: manage kill signal when sb_start_pagefault
 is called
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Chris Mason <chris.mason@fusionio.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim <jaegeuk.kim@samsung.com>, Steven Whitehouse <swhiteho@redhat.com>, KONISHI Ryusuke <konishi.ryusuke@lab.ntt.co.jp>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, Matthew Wilcox <matthew@wil.cx>, Marco Stornelli <marco.stornelli@gmail.com>, Mike Snitzer <snitzer@redhat.com>, Alasdair G Kergon <agk@redhat.com>, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, cluster-devel@redhat.com, linux-nilfs@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

In every place where sb_start_pagefault was called now we must manage
the error code and return VM_FAULT_RETRY.

Signed-off-by: Marco Stornelli <marco.stornelli@gmail.com>
---
 fs/btrfs/inode.c   |    4 +++-
 fs/buffer.c        |    4 +++-
 fs/ext4/inode.c    |    4 +++-
 fs/f2fs/file.c     |    4 +++-
 fs/gfs2/file.c     |    4 +++-
 fs/nilfs2/file.c   |    4 +++-
 fs/ocfs2/mmap.c    |    4 +++-
 include/linux/fs.h |    6 ++++--
 mm/filemap.c       |    7 +++++--
 9 files changed, 30 insertions(+), 11 deletions(-)

diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 09c58a3..a6166f4 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -7559,7 +7559,9 @@ int btrfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	u64 page_start;
 	u64 page_end;
 
-	sb_start_pagefault(inode->i_sb);
+	ret = sb_start_pagefault(inode->i_sb);
+	if (ret)
+		return VM_FAULT_RETRY;
 	ret  = btrfs_delalloc_reserve_space(inode, PAGE_CACHE_SIZE);
 	if (!ret) {
 		ret = file_update_time(vma->vm_file);
diff --git a/fs/buffer.c b/fs/buffer.c
index b4dcb34..6d3d2cc 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2383,7 +2383,9 @@ int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	int ret;
 	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
 
-	sb_start_pagefault(sb);
+	ret = sb_start_pagefault(sb);
+	if (ret)
+		return VM_FAULT_RETRY;
 
 	/*
 	 * Update file times before taking page lock. We may end up failing the
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index b3a5213..efc47f6 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -5023,7 +5023,9 @@ int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	get_block_t *get_block;
 	int retries = 0;
 
-	sb_start_pagefault(inode->i_sb);
+	ret = sb_start_pagefault(inode->i_sb);
+	if (ret)
+		return VM_FAULT_RETRY;
 	file_update_time(vma->vm_file);
 	/* Delalloc case is easy... */
 	if (test_opt(inode->i_sb, DELALLOC) &&
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 958a46d..cce4147 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -37,7 +37,9 @@ static int f2fs_vm_page_mkwrite(struct vm_area_struct *vma,
 
 	f2fs_balance_fs(sbi);
 
-	sb_start_pagefault(inode->i_sb);
+	err = sb_start_pagefault(inode->i_sb);
+	if (err)
+		return VM_FAULT_RETRY;
 
 	mutex_lock_op(sbi, DATA_NEW);
 
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index d79c2da..071e777 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -396,7 +396,9 @@ static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	loff_t size;
 	int ret;
 
-	sb_start_pagefault(inode->i_sb);
+	ret = sb_start_pagefault(inode->i_sb);
+	if (ret)
+		return VM_FAULT_RETRY;
 
 	/* Update file times before taking page lock */
 	file_update_time(vma->vm_file);
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index 08fdb77..1c7678a 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -74,7 +74,9 @@ static int nilfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (unlikely(nilfs_near_disk_full(inode->i_sb->s_fs_info)))
 		return VM_FAULT_SIGBUS; /* -ENOSPC */
 
-	sb_start_pagefault(inode->i_sb);
+	ret = sb_start_pagefault(inode->i_sb);
+	if (ret)
+		return VM_FAULT_RETRY;
 	lock_page(page);
 	if (page->mapping != inode->i_mapping ||
 	    page_offset(page) >= i_size_read(inode) || !PageUptodate(page)) {
diff --git a/fs/ocfs2/mmap.c b/fs/ocfs2/mmap.c
index 10d66c7..f0973ae 100644
--- a/fs/ocfs2/mmap.c
+++ b/fs/ocfs2/mmap.c
@@ -136,7 +136,9 @@ static int ocfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	sigset_t oldset;
 	int ret;
 
-	sb_start_pagefault(inode->i_sb);
+	ret = sb_start_pagefault(inode->i_sb);
+	if (ret)
+		return VM_FAULT_RETRY;
 	ocfs2_block_signals(&oldset);
 
 	/*
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 03921d6..550574e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1407,6 +1407,8 @@ static inline int sb_start_write_trylock(struct super_block *sb)
  * sb_start_pagefault - get write access to a superblock from a page fault
  * @sb: the super we write to
  *
+ * It returns zero when no error occured, the error code otherwise.
+ *
  * When a process starts handling write page fault, it should embed the
  * operation into sb_start_pagefault() - sb_end_pagefault() pair to get
  * exclusion against file system freezing. This is needed since the page fault
@@ -1422,9 +1424,9 @@ static inline int sb_start_write_trylock(struct super_block *sb)
  * mmap_sem
  *   -> sb_start_pagefault
  */
-static inline void sb_start_pagefault(struct super_block *sb)
+static inline int sb_start_pagefault(struct super_block *sb)
 {
-	__sb_start_write_wait(sb, SB_FREEZE_PAGEFAULT, false);
+	__sb_start_write_wait(sb, SB_FREEZE_PAGEFAULT, true);
 }
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index b238671..acf8d97 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1712,9 +1712,11 @@ int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
 	struct inode *inode = file_inode(vma->vm_file);
-	int ret = VM_FAULT_LOCKED;
+	int ret = 0;
 
-	sb_start_pagefault(inode->i_sb);
+	ret = sb_start_pagefault(inode->i_sb);
+	if (ret)
+		return VM_FAULT_RETRY;
 	file_update_time(vma->vm_file);
 	lock_page(page);
 	if (page->mapping != inode->i_mapping) {
@@ -1727,6 +1729,7 @@ int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	 * progress, we are guaranteed that writeback during freezing will
 	 * see the dirty page and writeprotect it again.
 	 */
+	ret = VM_FAULT_LOCKED;
 	set_page_dirty(page);
 	wait_for_stable_page(page);
 out:
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
