Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 0D9E06B0033
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 07:39:10 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2] truncate: drop 'oldsize' truncate_pagecache() parameter
Date: Tue, 30 Jul 2013 14:42:10 +0300
Message-Id: <1375184530-24490-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <20130729215141.GE32145@lenny.home.zabbo.net>
References: <20130729215141.GE32145@lenny.home.zabbo.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Lukas Czerner <lczerner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Zach Brown <zab@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

truncate_pagecache() doesn't care about old size since commit cedabed.
Let's drop it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
[v2: drop unused variables]
---
 fs/adfs/inode.c             | 2 +-
 fs/affs/file.c              | 2 +-
 fs/bfs/file.c               | 2 +-
 fs/btrfs/free-space-cache.c | 4 +---
 fs/btrfs/inode.c            | 2 +-
 fs/cifs/inode.c             | 5 +----
 fs/exofs/inode.c            | 2 +-
 fs/ext2/inode.c             | 2 +-
 fs/ext4/inode.c             | 4 +---
 fs/fat/inode.c              | 2 +-
 fs/fuse/dir.c               | 2 +-
 fs/fuse/inode.c             | 2 +-
 fs/gfs2/bmap.c              | 4 ++--
 fs/hfs/inode.c              | 2 +-
 fs/hfsplus/inode.c          | 2 +-
 fs/hpfs/file.c              | 2 +-
 fs/jfs/inode.c              | 2 +-
 fs/minix/inode.c            | 2 +-
 fs/nfs/inode.c              | 4 +---
 fs/nilfs2/inode.c           | 2 +-
 fs/ntfs/file.c              | 2 +-
 fs/omfs/file.c              | 2 +-
 fs/sysv/itree.c             | 2 +-
 fs/udf/inode.c              | 2 +-
 fs/ufs/inode.c              | 2 +-
 fs/xfs/xfs_aops.c           | 4 ++--
 include/linux/mm.h          | 2 +-
 mm/truncate.c               | 9 ++-------
 28 files changed, 31 insertions(+), 45 deletions(-)

diff --git a/fs/adfs/inode.c b/fs/adfs/inode.c
index 5f95d1e..b9acada 100644
--- a/fs/adfs/inode.c
+++ b/fs/adfs/inode.c
@@ -50,7 +50,7 @@ static void adfs_write_failed(struct address_space *mapping, loff_t to)
 	struct inode *inode = mapping->host;
 
 	if (to > inode->i_size)
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 }
 
 static int adfs_write_begin(struct file *file, struct address_space *mapping,
diff --git a/fs/affs/file.c b/fs/affs/file.c
index af3261b..1d5e51d 100644
--- a/fs/affs/file.c
+++ b/fs/affs/file.c
@@ -406,7 +406,7 @@ static void affs_write_failed(struct address_space *mapping, loff_t to)
 	struct inode *inode = mapping->host;
 
 	if (to > inode->i_size) {
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 		affs_truncate(inode);
 	}
 }
diff --git a/fs/bfs/file.c b/fs/bfs/file.c
index ad3ea14..ae28922 100644
--- a/fs/bfs/file.c
+++ b/fs/bfs/file.c
@@ -166,7 +166,7 @@ static void bfs_write_failed(struct address_space *mapping, loff_t to)
 	struct inode *inode = mapping->host;
 
 	if (to > inode->i_size)
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 }
 
 static int bfs_write_begin(struct file *file, struct address_space *mapping,
diff --git a/fs/btrfs/free-space-cache.c b/fs/btrfs/free-space-cache.c
index b21a3cd..256d959 100644
--- a/fs/btrfs/free-space-cache.c
+++ b/fs/btrfs/free-space-cache.c
@@ -221,12 +221,10 @@ int btrfs_truncate_free_space_cache(struct btrfs_root *root,
 				    struct btrfs_path *path,
 				    struct inode *inode)
 {
-	loff_t oldsize;
 	int ret = 0;
 
-	oldsize = i_size_read(inode);
 	btrfs_i_size_write(inode, 0);
-	truncate_pagecache(inode, oldsize, 0);
+	truncate_pagecache(inode, 0);
 
 	/*
 	 * We don't need an orphan item because truncating the free space cache
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 6d1b93c..3bdadc1 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -4404,7 +4404,7 @@ static int btrfs_setsize(struct inode *inode, struct iattr *attr)
 		inode->i_ctime = inode->i_mtime = current_fs_time(inode->i_sb);
 
 	if (newsize > oldsize) {
-		truncate_pagecache(inode, oldsize, newsize);
+		truncate_pagecache(inode, newsize);
 		ret = btrfs_cont_expand(inode, oldsize, newsize);
 		if (ret)
 			return ret;
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index 449b6cf..2a92c5c 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -1852,14 +1852,11 @@ static int cifs_truncate_page(struct address_space *mapping, loff_t from)
 
 static void cifs_setsize(struct inode *inode, loff_t offset)
 {
-	loff_t oldsize;
-
 	spin_lock(&inode->i_lock);
-	oldsize = inode->i_size;
 	i_size_write(inode, offset);
 	spin_unlock(&inode->i_lock);
 
-	truncate_pagecache(inode, oldsize, offset);
+	truncate_pagecache(inode, offset);
 }
 
 static int
diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 2ec8eb1..a52a5d2 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -861,7 +861,7 @@ static int exofs_writepage(struct page *page, struct writeback_control *wbc)
 static void _write_failed(struct inode *inode, loff_t to)
 {
 	if (to > inode->i_size)
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 }
 
 int exofs_write_begin(struct file *file, struct address_space *mapping,
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 0a87bb1..c260de6 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -58,7 +58,7 @@ static void ext2_write_failed(struct address_space *mapping, loff_t to)
 	struct inode *inode = mapping->host;
 
 	if (to > inode->i_size) {
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 		ext2_truncate_blocks(inode, inode->i_size);
 	}
 }
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index ba33c67..5dac315 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4577,8 +4577,6 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 
 	if (attr->ia_valid & ATTR_SIZE) {
 		if (attr->ia_size != inode->i_size) {
-			loff_t oldsize = inode->i_size;
-
 			i_size_write(inode, attr->ia_size);
 			/*
 			 * Blocks are going to be removed from the inode. Wait
@@ -4597,7 +4595,7 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 			 * Truncate pagecache after we've waited for commit
 			 * in data=journal mode to make pages freeable.
 			 */
-			truncate_pagecache(inode, oldsize, inode->i_size);
+			truncate_pagecache(inode, inode->i_size);
 		}
 		ext4_truncate(inode);
 	}
diff --git a/fs/fat/inode.c b/fs/fat/inode.c
index 11b51bb..0062da2 100644
--- a/fs/fat/inode.c
+++ b/fs/fat/inode.c
@@ -147,7 +147,7 @@ static void fat_write_failed(struct address_space *mapping, loff_t to)
 	struct inode *inode = mapping->host;
 
 	if (to > inode->i_size) {
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 		fat_truncate_blocks(inode, inode->i_size);
 	}
 }
diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index 72a5d5b..5cb9730 100644
--- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -1676,7 +1676,7 @@ int fuse_do_setattr(struct inode *inode, struct iattr *attr,
 	 * FUSE_NOWRITE, otherwise fuse_launder_page() would deadlock.
 	 */
 	if (S_ISREG(inode->i_mode) && oldsize != outarg.attr.size) {
-		truncate_pagecache(inode, oldsize, outarg.attr.size);
+		truncate_pagecache(inode, outarg.attr.size);
 		invalidate_inode_pages2(inode->i_mapping);
 	}
 
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 0b57859..a24e2a7 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -217,7 +217,7 @@ void fuse_change_attributes(struct inode *inode, struct fuse_attr *attr,
 		bool inval = false;
 
 		if (oldsize != attr->size) {
-			truncate_pagecache(inode, oldsize, attr->size);
+			truncate_pagecache(inode, attr->size);
 			inval = true;
 		} else if (fc->auto_inval_data) {
 			struct timespec new_mtime = {
diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
index 5e2f56f..62a65fc 100644
--- a/fs/gfs2/bmap.c
+++ b/fs/gfs2/bmap.c
@@ -1016,7 +1016,7 @@ static int gfs2_journaled_truncate(struct inode *inode, u64 oldsize, u64 newsize
 		chunk = oldsize - newsize;
 		if (chunk > max_chunk)
 			chunk = max_chunk;
-		truncate_pagecache(inode, oldsize, oldsize - chunk);
+		truncate_pagecache(inode, oldsize - chunk);
 		oldsize -= chunk;
 		gfs2_trans_end(sdp);
 		error = gfs2_trans_begin(sdp, RES_DINODE, GFS2_JTRUNC_REVOKES);
@@ -1067,7 +1067,7 @@ static int trunc_start(struct inode *inode, u64 oldsize, u64 newsize)
 	if (journaled)
 		error = gfs2_journaled_truncate(inode, oldsize, newsize);
 	else
-		truncate_pagecache(inode, oldsize, newsize);
+		truncate_pagecache(inode, newsize);
 
 	if (error) {
 		brelse(dibh);
diff --git a/fs/hfs/inode.c b/fs/hfs/inode.c
index f9299d8..380ab31 100644
--- a/fs/hfs/inode.c
+++ b/fs/hfs/inode.c
@@ -41,7 +41,7 @@ static void hfs_write_failed(struct address_space *mapping, loff_t to)
 	struct inode *inode = mapping->host;
 
 	if (to > inode->i_size) {
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 		hfs_file_truncate(inode);
 	}
 }
diff --git a/fs/hfsplus/inode.c b/fs/hfsplus/inode.c
index f833d35..4b4ae8c 100644
--- a/fs/hfsplus/inode.c
+++ b/fs/hfsplus/inode.c
@@ -35,7 +35,7 @@ static void hfsplus_write_failed(struct address_space *mapping, loff_t to)
 	struct inode *inode = mapping->host;
 
 	if (to > inode->i_size) {
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 		hfsplus_file_truncate(inode);
 	}
 }
diff --git a/fs/hpfs/file.c b/fs/hpfs/file.c
index 4e9dabc..67c1a61 100644
--- a/fs/hpfs/file.c
+++ b/fs/hpfs/file.c
@@ -138,7 +138,7 @@ static void hpfs_write_failed(struct address_space *mapping, loff_t to)
 	hpfs_lock(inode->i_sb);
 
 	if (to > inode->i_size) {
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 		hpfs_truncate(inode);
 	}
 
diff --git a/fs/jfs/inode.c b/fs/jfs/inode.c
index 730f24e..f4aab71 100644
--- a/fs/jfs/inode.c
+++ b/fs/jfs/inode.c
@@ -306,7 +306,7 @@ static void jfs_write_failed(struct address_space *mapping, loff_t to)
 	struct inode *inode = mapping->host;
 
 	if (to > inode->i_size) {
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 		jfs_truncate(inode);
 	}
 }
diff --git a/fs/minix/inode.c b/fs/minix/inode.c
index df12249..0332109 100644
--- a/fs/minix/inode.c
+++ b/fs/minix/inode.c
@@ -400,7 +400,7 @@ static void minix_write_failed(struct address_space *mapping, loff_t to)
 	struct inode *inode = mapping->host;
 
 	if (to > inode->i_size) {
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 		minix_truncate(inode);
 	}
 }
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index af6e806..40c4ba7 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -538,7 +538,6 @@ EXPORT_SYMBOL_GPL(nfs_setattr);
  */
 static int nfs_vmtruncate(struct inode * inode, loff_t offset)
 {
-	loff_t oldsize;
 	int err;
 
 	err = inode_newsize_ok(inode, offset);
@@ -546,11 +545,10 @@ static int nfs_vmtruncate(struct inode * inode, loff_t offset)
 		goto out;
 
 	spin_lock(&inode->i_lock);
-	oldsize = inode->i_size;
 	i_size_write(inode, offset);
 	spin_unlock(&inode->i_lock);
 
-	truncate_pagecache(inode, oldsize, offset);
+	truncate_pagecache(inode, offset);
 out:
 	return err;
 }
diff --git a/fs/nilfs2/inode.c b/fs/nilfs2/inode.c
index b1a5277..7e350c5 100644
--- a/fs/nilfs2/inode.c
+++ b/fs/nilfs2/inode.c
@@ -254,7 +254,7 @@ void nilfs_write_failed(struct address_space *mapping, loff_t to)
 	struct inode *inode = mapping->host;
 
 	if (to > inode->i_size) {
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 		nilfs_truncate(inode);
 	}
 }
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index c5670b8..ea4ba9d 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -1768,7 +1768,7 @@ static void ntfs_write_failed(struct address_space *mapping, loff_t to)
 	struct inode *inode = mapping->host;
 
 	if (to > inode->i_size) {
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 		ntfs_truncate_vfs(inode);
 	}
 }
diff --git a/fs/omfs/file.c b/fs/omfs/file.c
index e0d9b3e..54d57d6 100644
--- a/fs/omfs/file.c
+++ b/fs/omfs/file.c
@@ -311,7 +311,7 @@ static void omfs_write_failed(struct address_space *mapping, loff_t to)
 	struct inode *inode = mapping->host;
 
 	if (to > inode->i_size) {
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 		omfs_truncate(inode);
 	}
 }
diff --git a/fs/sysv/itree.c b/fs/sysv/itree.c
index c1a591a..66bc316 100644
--- a/fs/sysv/itree.c
+++ b/fs/sysv/itree.c
@@ -469,7 +469,7 @@ static void sysv_write_failed(struct address_space *mapping, loff_t to)
 	struct inode *inode = mapping->host;
 
 	if (to > inode->i_size) {
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 		sysv_truncate(inode);
 	}
 }
diff --git a/fs/udf/inode.c b/fs/udf/inode.c
index b6d15d3..062b792 100644
--- a/fs/udf/inode.c
+++ b/fs/udf/inode.c
@@ -172,7 +172,7 @@ static void udf_write_failed(struct address_space *mapping, loff_t to)
 	loff_t isize = inode->i_size;
 
 	if (to > isize) {
-		truncate_pagecache(inode, to, isize);
+		truncate_pagecache(inode, isize);
 		if (iinfo->i_alloc_type != ICBTAG_FLAG_AD_IN_ICB) {
 			down_write(&iinfo->i_data_sem);
 			udf_clear_extent_cache(inode);
diff --git a/fs/ufs/inode.c b/fs/ufs/inode.c
index ff24e44..c8ca960 100644
--- a/fs/ufs/inode.c
+++ b/fs/ufs/inode.c
@@ -531,7 +531,7 @@ static void ufs_write_failed(struct address_space *mapping, loff_t to)
 	struct inode *inode = mapping->host;
 
 	if (to > inode->i_size)
-		truncate_pagecache(inode, to, inode->i_size);
+		truncate_pagecache(inode, inode->i_size);
 }
 
 static int ufs_write_begin(struct file *file, struct address_space *mapping,
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 596ec71..03d70a9 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1587,7 +1587,7 @@ xfs_vm_write_begin(
 		unlock_page(page);
 
 		if (pos + len > i_size_read(inode))
-			truncate_pagecache(inode, pos + len, i_size_read(inode));
+			truncate_pagecache(inode, i_size_read(inode));
 
 		page_cache_release(page);
 		page = NULL;
@@ -1623,7 +1623,7 @@ xfs_vm_write_end(
 		loff_t		to = pos + len;
 
 		if (to > isize) {
-			truncate_pagecache(inode, to, isize);
+			truncate_pagecache(inode, isize);
 			xfs_vm_kill_delalloc_range(inode, isize, to);
 		}
 	}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f022460..8293bf1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -992,7 +992,7 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
 	unmap_mapping_range(mapping, holebegin, holelen, 0);
 }
 
-extern void truncate_pagecache(struct inode *inode, loff_t old, loff_t new);
+extern void truncate_pagecache(struct inode *inode, loff_t new);
 extern void truncate_setsize(struct inode *inode, loff_t newsize);
 void truncate_pagecache_range(struct inode *inode, loff_t offset, loff_t end);
 int truncate_inode_page(struct address_space *mapping, struct page *page);
diff --git a/mm/truncate.c b/mm/truncate.c
index e2e8a8a..353b683 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -567,7 +567,6 @@ EXPORT_SYMBOL_GPL(invalidate_inode_pages2);
 /**
  * truncate_pagecache - unmap and remove pagecache that has been truncated
  * @inode: inode
- * @oldsize: old file size
  * @newsize: new file size
  *
  * inode's new i_size must already be written before truncate_pagecache
@@ -580,7 +579,7 @@ EXPORT_SYMBOL_GPL(invalidate_inode_pages2);
  * situations such as writepage being called for a page that has already
  * had its underlying blocks deallocated.
  */
-void truncate_pagecache(struct inode *inode, loff_t oldsize, loff_t newsize)
+void truncate_pagecache(struct inode *inode, loff_t newsize)
 {
 	struct address_space *mapping = inode->i_mapping;
 	loff_t holebegin = round_up(newsize, PAGE_SIZE);
@@ -614,12 +613,8 @@ EXPORT_SYMBOL(truncate_pagecache);
  */
 void truncate_setsize(struct inode *inode, loff_t newsize)
 {
-	loff_t oldsize;
-
-	oldsize = inode->i_size;
 	i_size_write(inode, newsize);
-
-	truncate_pagecache(inode, oldsize, newsize);
+	truncate_pagecache(inode, newsize);
 }
 EXPORT_SYMBOL(truncate_setsize);
 
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
