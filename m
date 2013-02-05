Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 01A996B0109
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 04:12:26 -0500 (EST)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH v2 01/18] mm: change invalidatepage prototype to accept length
Date: Tue,  5 Feb 2013 10:11:54 +0100
Message-Id: <1360055531-26309-2-git-send-email-lczerner@redhat.com>
In-Reply-To: <1360055531-26309-1-git-send-email-lczerner@redhat.com>
References: <1360055531-26309-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Lukas Czerner <lczerner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>

Currently there is no way to truncate partial page where the end
truncate point is not at the end of the page. This is because it was not
needed and the functionality was enough for file system truncate
operation to work properly. However more file systems now support punch
hole feature and it can benefit from mm supporting truncating page just
up to the certain point.

Specifically, with this functionality truncate_inode_pages_range() can
be changed so it supports truncating partial page at the end of the
range (currently it will BUG_ON() if 'end' is not at the end of the
page).

This commit changes the invalidatepage() address space operation
prototype to accept range to be invalidated and update all the instances
for it.

We also change the block_invalidatepage() in the same way and actually
make a use of the new length argument implementing range invalidation.

Actual file system implementations will follow except the file systems
where the changes are really simple and should not change the behaviour
in any way .Implementation for truncate_page_range() which will be able
to accept page unaligned ranges will follow as well.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
---
 Documentation/filesystems/Locking |    6 +++---
 Documentation/filesystems/vfs.txt |   20 ++++++++++----------
 fs/9p/vfs_addr.c                  |    5 +++--
 fs/afs/file.c                     |   10 ++++++----
 fs/btrfs/disk-io.c                |    3 ++-
 fs/btrfs/extent_io.c              |    2 +-
 fs/btrfs/inode.c                  |    3 ++-
 fs/buffer.c                       |   21 ++++++++++++++++++---
 fs/ceph/addr.c                    |    5 +++--
 fs/cifs/file.c                    |    5 +++--
 fs/exofs/inode.c                  |    6 ++++--
 fs/ext3/inode.c                   |    3 ++-
 fs/ext4/inode.c                   |   18 +++++++++++-------
 fs/f2fs/data.c                    |    3 ++-
 fs/f2fs/node.c                    |    3 ++-
 fs/gfs2/aops.c                    |    8 +++++---
 fs/jfs/jfs_metapage.c             |    5 +++--
 fs/logfs/file.c                   |    3 ++-
 fs/logfs/segment.c                |    3 ++-
 fs/nfs/file.c                     |    8 +++++---
 fs/ntfs/aops.c                    |    2 +-
 fs/ocfs2/aops.c                   |    3 ++-
 fs/reiserfs/inode.c               |    3 ++-
 fs/ubifs/file.c                   |    5 +++--
 fs/xfs/xfs_aops.c                 |    7 ++++---
 include/linux/buffer_head.h       |    3 ++-
 include/linux/fs.h                |    2 +-
 include/linux/mm.h                |    3 ++-
 mm/readahead.c                    |    2 +-
 mm/truncate.c                     |   15 +++++++++------
 30 files changed, 116 insertions(+), 69 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index f48e0c6..8043a87 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -187,7 +187,7 @@ prototypes:
 				loff_t pos, unsigned len, unsigned copied,
 				struct page *page, void *fsdata);
 	sector_t (*bmap)(struct address_space *, sector_t);
-	int (*invalidatepage) (struct page *, unsigned long);
+	void (*invalidatepage) (struct page *, unsigned int, unsigned int);
 	int (*releasepage) (struct page *, int);
 	void (*freepage)(struct page *);
 	int (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
@@ -308,8 +308,8 @@ filesystems and by the swapper. The latter will eventually go away.  Please,
 keep it that way and don't breed new callers.
 
 	->invalidatepage() is called when the filesystem must attempt to drop
-some or all of the buffers from the page when it is being truncated.  It
-returns zero on success.  If ->invalidatepage is zero, the kernel uses
+some or all of the buffers from the page when it is being truncated. It
+returns zero on success. If ->invalidatepage is zero, the kernel uses
 block_invalidatepage() instead.
 
 	->releasepage() is called when the kernel is about to try to drop the
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index e3869098..279fb73 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -549,7 +549,7 @@ struct address_space_operations
 -------------------------------
 
 This describes how the VFS can manipulate mapping of a file to page cache in
-your filesystem. As of kernel 2.6.22, the following members are defined:
+your filesystem. The following members are defined:
 
 struct address_space_operations {
 	int (*writepage)(struct page *page, struct writeback_control *wbc);
@@ -566,7 +566,7 @@ struct address_space_operations {
 				loff_t pos, unsigned len, unsigned copied,
 				struct page *page, void *fsdata);
 	sector_t (*bmap)(struct address_space *, sector_t);
-	int (*invalidatepage) (struct page *, unsigned long);
+	void (*invalidatepage) (struct page *, unsigned int, unsigned int);
 	int (*releasepage) (struct page *, int);
 	void (*freepage)(struct page *);
 	ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
@@ -685,14 +685,14 @@ struct address_space_operations {
   invalidatepage: If a page has PagePrivate set, then invalidatepage
         will be called when part or all of the page is to be removed
 	from the address space.  This generally corresponds to either a
-	truncation or a complete invalidation of the address space
-	(in the latter case 'offset' will always be 0).
-	Any private data associated with the page should be updated
-	to reflect this truncation.  If offset is 0, then
-	the private data should be released, because the page
-	must be able to be completely discarded.  This may be done by
-        calling the ->releasepage function, but in this case the
-        release MUST succeed.
+	truncation, punch hole  or a complete invalidation of the address
+	space (in the latter case 'offset' will always be 0 and 'length'
+	will be PAGE_CACHE_SIZE). Any private data associated with the page
+	should be updated to reflect this truncation.  If offset is 0 and
+	length is PAGE_CACHE_SIZE, then the private data should be released,
+	because the page must be able to be completely discarded.  This may
+	be done by calling the ->releasepage function, but in this case the
+	release MUST succeed.
 
   releasepage: releasepage is called on PagePrivate pages to indicate
         that the page should be freed if possible.  ->releasepage
diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index 0ad61c6..3bf654a 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -147,13 +147,14 @@ static int v9fs_release_page(struct page *page, gfp_t gfp)
  * @offset: offset in the page
  */
 
-static void v9fs_invalidate_page(struct page *page, unsigned long offset)
+static void v9fs_invalidate_page(struct page *page, unsigned int offset,
+				 unsigned int length)
 {
 	/*
 	 * If called with zero offset, we should release
 	 * the private state assocated with the page
 	 */
-	if (offset == 0)
+	if (offset == 0 && length == PAGE_CACHE_SIZE)
 		v9fs_fscache_invalidate_page(page);
 }
 
diff --git a/fs/afs/file.c b/fs/afs/file.c
index 8f6e923..66d50fe 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -19,7 +19,8 @@
 #include "internal.h"
 
 static int afs_readpage(struct file *file, struct page *page);
-static void afs_invalidatepage(struct page *page, unsigned long offset);
+static void afs_invalidatepage(struct page *page, unsigned int offset,
+			       unsigned int length);
 static int afs_releasepage(struct page *page, gfp_t gfp_flags);
 static int afs_launder_page(struct page *page);
 
@@ -310,16 +311,17 @@ static int afs_launder_page(struct page *page)
  * - release a page and clean up its private data if offset is 0 (indicating
  *   the entire page)
  */
-static void afs_invalidatepage(struct page *page, unsigned long offset)
+static void afs_invalidatepage(struct page *page, unsigned int offset,
+			       unsigned int length)
 {
 	struct afs_writeback *wb = (struct afs_writeback *) page_private(page);
 
-	_enter("{%lu},%lu", page->index, offset);
+	_enter("{%lu},%u,%u", page->index, offset, length);
 
 	BUG_ON(!PageLocked(page));
 
 	/* we clean up only if the entire page is being invalidated */
-	if (offset == 0) {
+	if (offset == 0 && length == PAGE_CACHE_SIZE) {
 #ifdef CONFIG_AFS_FSCACHE
 		if (PageFsCache(page)) {
 			struct afs_vnode *vnode = AFS_FS_I(page->mapping->host);
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index a8f652d..9db8632 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -984,7 +984,8 @@ static int btree_releasepage(struct page *page, gfp_t gfp_flags)
 	return try_release_extent_buffer(page, gfp_flags);
 }
 
-static void btree_invalidatepage(struct page *page, unsigned long offset)
+static void btree_invalidatepage(struct page *page, unsigned int offset,
+				 unsigned int length)
 {
 	struct extent_io_tree *tree;
 	tree = &BTRFS_I(page->mapping->host)->io_tree;
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 1b319df..0aaec4a 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2847,7 +2847,7 @@ static int __extent_writepage(struct page *page, struct writeback_control *wbc,
 	pg_offset = i_size & (PAGE_CACHE_SIZE - 1);
 	if (page->index > end_index ||
 	   (page->index == end_index && !pg_offset)) {
-		page->mapping->a_ops->invalidatepage(page, 0);
+		page->mapping->a_ops->invalidatepage(page, 0, PAGE_CACHE_SIZE);
 		unlock_page(page);
 		return 0;
 	}
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index cc93b23..98cdd03 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -6711,7 +6711,8 @@ static int btrfs_releasepage(struct page *page, gfp_t gfp_flags)
 	return __btrfs_releasepage(page, gfp_flags & GFP_NOFS);
 }
 
-static void btrfs_invalidatepage(struct page *page, unsigned long offset)
+static void btrfs_invalidatepage(struct page *page, unsigned int offset,
+				 unsigned int length)
 {
 	struct inode *inode = page->mapping->host;
 	struct extent_io_tree *tree;
diff --git a/fs/buffer.c b/fs/buffer.c
index 7a75c3e..4259151 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1446,7 +1446,8 @@ static void discard_buffer(struct buffer_head * bh)
  * block_invalidatepage - invalidate part or all of a buffer-backed page
  *
  * @page: the page which is affected
- * @offset: the index of the truncation point
+ * @offset: start of the range to invalidate
+ * @length: length of the range to invalidate
  *
  * block_invalidatepage() is called when all or part of the page has become
  * invalidated by a truncate operation.
@@ -1457,15 +1458,22 @@ static void discard_buffer(struct buffer_head * bh)
  * point.  Because the caller is about to free (and possibly reuse) those
  * blocks on-disk.
  */
-void block_invalidatepage(struct page *page, unsigned long offset)
+void block_invalidatepage(struct page *page, unsigned int offset,
+			  unsigned int length)
 {
 	struct buffer_head *head, *bh, *next;
 	unsigned int curr_off = 0;
+	unsigned int stop = length + offset;
 
 	BUG_ON(!PageLocked(page));
 	if (!page_has_buffers(page))
 		goto out;
 
+	/*
+	 * Check for overflow
+	 */
+	BUG_ON(stop > PAGE_CACHE_SIZE || stop < length);
+
 	head = page_buffers(page);
 	bh = head;
 	do {
@@ -1473,6 +1481,12 @@ void block_invalidatepage(struct page *page, unsigned long offset)
 		next = bh->b_this_page;
 
 		/*
+		 * Are we still fully in range ?
+		 */
+		if (next_off > stop)
+			goto out;
+
+		/*
 		 * is this block fully invalidated?
 		 */
 		if (offset <= curr_off)
@@ -1493,6 +1507,7 @@ out:
 }
 EXPORT_SYMBOL(block_invalidatepage);
 
+
 /*
  * We attach and possibly dirty the buffers atomically wrt
  * __set_page_dirty_buffers() via private_lock.  try_to_free_buffers
@@ -2833,7 +2848,7 @@ int block_write_full_page_endio(struct page *page, get_block_t *get_block,
 		 * they may have been added in ext3_writepage().  Make them
 		 * freeable here, so the page does not leak.
 		 */
-		do_invalidatepage(page, 0);
+		do_invalidatepage(page, 0, PAGE_CACHE_SIZE);
 		unlock_page(page);
 		return 0; /* don't care */
 	}
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 064d1a6..8953532 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -143,7 +143,8 @@ static int ceph_set_page_dirty(struct page *page)
  * dirty page counters appropriately.  Only called if there is private
  * data on the page.
  */
-static void ceph_invalidatepage(struct page *page, unsigned long offset)
+static void ceph_invalidatepage(struct page *page, unsigned int offset,
+				unsigned int length)
 {
 	struct inode *inode;
 	struct ceph_inode_info *ci;
@@ -168,7 +169,7 @@ static void ceph_invalidatepage(struct page *page, unsigned long offset)
 
 	ci = ceph_inode(inode);
 	if (offset == 0) {
-		dout("%p invalidatepage %p idx %lu full dirty page %lu\n",
+		dout("%p invalidatepage %p idx %lu full dirty page %u\n",
 		     inode, page, page->index, offset);
 		ceph_put_wrbuffer_cap_refs(ci, 1, snapc);
 		ceph_put_snap_context(snapc);
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 8ea6ca5..8193f84 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3543,11 +3543,12 @@ static int cifs_release_page(struct page *page, gfp_t gfp)
 	return cifs_fscache_release_page(page, gfp);
 }
 
-static void cifs_invalidate_page(struct page *page, unsigned long offset)
+static void cifs_invalidate_page(struct page *page, unsigned int offset,
+				 unsigned int length)
 {
 	struct cifsInodeInfo *cifsi = CIFS_I(page->mapping->host);
 
-	if (offset == 0)
+	if (offset == 0 && length == PAGE_CACHE_SIZE)
 		cifs_fscache_invalidate_page(page, &cifsi->vfs_inode);
 }
 
diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index d1f80ab..2ec8eb1 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -953,9 +953,11 @@ static int exofs_releasepage(struct page *page, gfp_t gfp)
 	return 0;
 }
 
-static void exofs_invalidatepage(struct page *page, unsigned long offset)
+static void exofs_invalidatepage(struct page *page, unsigned int offset,
+				 unsigned int length)
 {
-	EXOFS_DBGMSG("page 0x%lx offset 0x%lx\n", page->index, offset);
+	EXOFS_DBGMSG("page 0x%lx offset 0x%x length 0x%x\n",
+		     page->index, offset, length);
 	WARN_ON(1);
 }
 
diff --git a/fs/ext3/inode.c b/fs/ext3/inode.c
index b176d42..0b8d382 100644
--- a/fs/ext3/inode.c
+++ b/fs/ext3/inode.c
@@ -1819,7 +1819,8 @@ ext3_readpages(struct file *file, struct address_space *mapping,
 	return mpage_readpages(mapping, pages, nr_pages, ext3_get_block);
 }
 
-static void ext3_invalidatepage(struct page *page, unsigned long offset)
+static void ext3_invalidatepage(struct page *page, unsigned int offset,
+				unsigned int length)
 {
 	journal_t *journal = EXT3_JOURNAL(page->mapping->host);
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index cbfe13b..cbf6574 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -131,7 +131,8 @@ static inline int ext4_begin_ordered_truncate(struct inode *inode,
 						   new_size);
 }
 
-static void ext4_invalidatepage(struct page *page, unsigned long offset);
+static void ext4_invalidatepage(struct page *page, unsigned int offset,
+				unsigned int length);
 static int noalloc_get_block_write(struct inode *inode, sector_t iblock,
 				   struct buffer_head *bh_result, int create);
 static int ext4_set_bh_endio(struct buffer_head *bh, struct inode *inode);
@@ -1517,7 +1518,7 @@ static void ext4_da_block_invalidatepages(struct mpage_da_data *mpd)
 				break;
 			BUG_ON(!PageLocked(page));
 			BUG_ON(PageWriteback(page));
-			block_invalidatepage(page, 0);
+			block_invalidatepage(page, 0, PAGE_CACHE_SIZE);
 			ClearPageUptodate(page);
 			unlock_page(page);
 		}
@@ -2698,7 +2699,8 @@ static int ext4_da_write_end(struct file *file,
 	return ret ? ret : copied;
 }
 
-static void ext4_da_invalidatepage(struct page *page, unsigned long offset)
+static void ext4_da_invalidatepage(struct page *page, unsigned int offset,
+				   unsigned int length)
 {
 	/*
 	 * Drop reserved blocks
@@ -2710,7 +2712,7 @@ static void ext4_da_invalidatepage(struct page *page, unsigned long offset)
 	ext4_da_page_release_reservation(page, offset);
 
 out:
-	ext4_invalidatepage(page, offset);
+	ext4_invalidatepage(page, offset, length);
 
 	return;
 }
@@ -2878,7 +2880,8 @@ static void ext4_invalidatepage_free_endio(struct page *page, unsigned long offs
 	} while (bh != head);
 }
 
-static void ext4_invalidatepage(struct page *page, unsigned long offset)
+static void ext4_invalidatepage(struct page *page, unsigned int offset,
+				unsigned int length)
 {
 	trace_ext4_invalidatepage(page, offset);
 
@@ -2891,7 +2894,7 @@ static void ext4_invalidatepage(struct page *page, unsigned long offset)
 	/* No journalling happens on data buffers when this function is used */
 	WARN_ON(page_has_buffers(page) && buffer_jbd(page_buffers(page)));
 
-	block_invalidatepage(page, offset);
+	block_invalidatepage(page, offset, PAGE_CACHE_SIZE - offset);
 }
 
 static int __ext4_journalled_invalidatepage(struct page *page,
@@ -2912,7 +2915,8 @@ static int __ext4_journalled_invalidatepage(struct page *page,
 
 /* Wrapper for aops... */
 static void ext4_journalled_invalidatepage(struct page *page,
-					   unsigned long offset)
+					   unsigned int offset,
+					   unsigned int length)
 {
 	WARN_ON(__ext4_journalled_invalidatepage(page, offset) < 0);
 }
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 7bd22a2..bae8b6c 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -667,7 +667,8 @@ static ssize_t f2fs_direct_IO(int rw, struct kiocb *iocb,
 						  get_data_block_ro);
 }
 
-static void f2fs_invalidate_data_page(struct page *page, unsigned long offset)
+static void f2fs_invalidate_data_page(struct page *page, unsigned int offset,
+				      unsigned int length)
 {
 	struct inode *inode = page->mapping->host;
 	struct f2fs_sb_info *sbi = F2FS_SB(inode->i_sb);
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index 9bda63c..f099a42 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -1170,7 +1170,8 @@ static int f2fs_set_node_page_dirty(struct page *page)
 	return 0;
 }
 
-static void f2fs_invalidate_node_page(struct page *page, unsigned long offset)
+static void f2fs_invalidate_node_page(struct page *page, unsigned int offset,
+				      unsigned int length)
 {
 	struct inode *inode = page->mapping->host;
 	struct f2fs_sb_info *sbi = F2FS_SB(inode->i_sb);
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index 30de4f2..5bd558c 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -109,7 +109,7 @@ static int gfs2_writepage_common(struct page *page,
 	/* Is the page fully outside i_size? (truncate in progress) */
 	offset = i_size & (PAGE_CACHE_SIZE-1);
 	if (page->index > end_index || (page->index == end_index && !offset)) {
-		page->mapping->a_ops->invalidatepage(page, 0);
+		page->mapping->a_ops->invalidatepage(page, 0, PAGE_CACHE_SIZE);
 		goto out;
 	}
 	return 1;
@@ -300,7 +300,8 @@ static int gfs2_write_jdata_pagevec(struct address_space *mapping,
 
 		/* Is the page fully outside i_size? (truncate in progress) */
 		if (page->index > end_index || (page->index == end_index && !offset)) {
-			page->mapping->a_ops->invalidatepage(page, 0);
+			page->mapping->a_ops->invalidatepage(page, 0,
+							     PAGE_CACHE_SIZE);
 			unlock_page(page);
 			continue;
 		}
@@ -944,7 +945,8 @@ static void gfs2_discard(struct gfs2_sbd *sdp, struct buffer_head *bh)
 	unlock_buffer(bh);
 }
 
-static void gfs2_invalidatepage(struct page *page, unsigned long offset)
+static void gfs2_invalidatepage(struct page *page, unsigned int offset,
+				unsigned int length)
 {
 	struct gfs2_sbd *sdp = GFS2_SB(page->mapping->host);
 	struct buffer_head *bh, *head;
diff --git a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
index 6740d34..9e3aaff 100644
--- a/fs/jfs/jfs_metapage.c
+++ b/fs/jfs/jfs_metapage.c
@@ -571,9 +571,10 @@ static int metapage_releasepage(struct page *page, gfp_t gfp_mask)
 	return ret;
 }
 
-static void metapage_invalidatepage(struct page *page, unsigned long offset)
+static void metapage_invalidatepage(struct page *page, unsigned int offset,
+				    unsigned int length)
 {
-	BUG_ON(offset);
+	BUG_ON(offset || length < PAGE_CACHE_SIZE);
 
 	BUG_ON(PageWriteback(page));
 
diff --git a/fs/logfs/file.c b/fs/logfs/file.c
index 3886cde..c2941df 100644
--- a/fs/logfs/file.c
+++ b/fs/logfs/file.c
@@ -159,7 +159,8 @@ static int logfs_writepage(struct page *page, struct writeback_control *wbc)
 	return __logfs_writepage(page);
 }
 
-static void logfs_invalidatepage(struct page *page, unsigned long offset)
+static void logfs_invalidatepage(struct page *page, unsigned int offset,
+				 unsigned int length)
 {
 	struct logfs_block *block = logfs_block(page);
 
diff --git a/fs/logfs/segment.c b/fs/logfs/segment.c
index 038da09..d448a77 100644
--- a/fs/logfs/segment.c
+++ b/fs/logfs/segment.c
@@ -884,7 +884,8 @@ static struct logfs_area *alloc_area(struct super_block *sb)
 	return area;
 }
 
-static void map_invalidatepage(struct page *page, unsigned long l)
+static void map_invalidatepage(struct page *page, unsigned int o,
+			       unsigned int l)
 {
 	return;
 }
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 3c2b893..bbe0b72 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -451,11 +451,13 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
  * - Called if either PG_private or PG_fscache is set on the page
  * - Caller holds page lock
  */
-static void nfs_invalidate_page(struct page *page, unsigned long offset)
+static void nfs_invalidate_page(struct page *page, unsigned int offset,
+				unsigned int length)
 {
-	dfprintk(PAGECACHE, "NFS: invalidate_page(%p, %lu)\n", page, offset);
+	dfprintk(PAGECACHE, "NFS: invalidate_page(%p, %u, %u)\n",
+		 page, offset, length);
 
-	if (offset != 0)
+	if (offset != 0 || length < PAGE_CACHE_SIZE)
 		return;
 	/* Cancel any unstarted writes on this page */
 	nfs_wb_page_cancel(page_file_mapping(page)->host, page);
diff --git a/fs/ntfs/aops.c b/fs/ntfs/aops.c
index fa9c05f..d267ea6 100644
--- a/fs/ntfs/aops.c
+++ b/fs/ntfs/aops.c
@@ -1372,7 +1372,7 @@ retry_writepage:
 		 * The page may have dirty, unmapped buffers.  Make them
 		 * freeable here, so the page does not leak.
 		 */
-		block_invalidatepage(page, 0);
+		block_invalidatepage(page, 0, PAGE_CACHE_SIZE);
 		unlock_page(page);
 		ntfs_debug("Write outside i_size - truncated?");
 		return 0;
diff --git a/fs/ocfs2/aops.c b/fs/ocfs2/aops.c
index 6577432..5d77cf2 100644
--- a/fs/ocfs2/aops.c
+++ b/fs/ocfs2/aops.c
@@ -603,7 +603,8 @@ static void ocfs2_dio_end_io(struct kiocb *iocb,
  * from ext3.  PageChecked() bits have been removed as OCFS2 does not
  * do journalled data.
  */
-static void ocfs2_invalidatepage(struct page *page, unsigned long offset)
+static void ocfs2_invalidatepage(struct page *page, unsigned int offset,
+				 unsigned int length)
 {
 	journal_t *journal = OCFS2_SB(page->mapping->host->i_sb)->journal->j_journal;
 
diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index 95d7680..5ca4fb4 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -2969,7 +2969,8 @@ static int invalidatepage_can_drop(struct inode *inode, struct buffer_head *bh)
 }
 
 /* clm -- taken from fs/buffer.c:block_invalidate_page */
-static void reiserfs_invalidatepage(struct page *page, unsigned long offset)
+static void reiserfs_invalidatepage(struct page *page, unsigned int offset,
+				    unsigned int length)
 {
 	struct buffer_head *head, *bh, *next;
 	struct inode *inode = page->mapping->host;
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 5bc7781..9ec2356 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1276,13 +1276,14 @@ int ubifs_setattr(struct dentry *dentry, struct iattr *attr)
 	return err;
 }
 
-static void ubifs_invalidatepage(struct page *page, unsigned long offset)
+static void ubifs_invalidatepage(struct page *page, unsigned int offset,
+				 unsigned int length)
 {
 	struct inode *inode = page->mapping->host;
 	struct ubifs_info *c = inode->i_sb->s_fs_info;
 
 	ubifs_assert(PagePrivate(page));
-	if (offset)
+	if (offset || length < PAGE_CACHE_SIZE)
 		/* Partial page remains dirty */
 		return;
 
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 5f707e5..e426796 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -823,10 +823,11 @@ xfs_cluster_write(
 STATIC void
 xfs_vm_invalidatepage(
 	struct page		*page,
-	unsigned long		offset)
+	unsigned int		offset,
+	unsigned int		length)
 {
 	trace_xfs_invalidatepage(page->mapping->host, page, offset);
-	block_invalidatepage(page, offset);
+	block_invalidatepage(page, offset, PAGE_CACHE_SIZE - offset);
 }
 
 /*
@@ -890,7 +891,7 @@ next_buffer:
 
 	xfs_iunlock(ip, XFS_ILOCK_EXCL);
 out_invalidate:
-	xfs_vm_invalidatepage(page, 0);
+	xfs_vm_invalidatepage(page, 0, PAGE_CACHE_SIZE);
 	return;
 }
 
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 458f497..e80b4e4 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -193,7 +193,8 @@ extern int buffer_heads_over_limit;
  * Generic address_space_operations implementations for buffer_head-backed
  * address_spaces.
  */
-void block_invalidatepage(struct page *page, unsigned long offset);
+void block_invalidatepage(struct page *page, unsigned int offset,
+			  unsigned int length);
 int block_write_full_page(struct page *page, get_block_t *get_block,
 				struct writeback_control *wbc);
 int block_write_full_page_endio(struct page *page, get_block_t *get_block,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7617ee0..ad432fd 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -364,7 +364,7 @@ struct address_space_operations {
 
 	/* Unfortunately this kludge is needed for FIBMAP. Don't use it */
 	sector_t (*bmap)(struct address_space *, sector_t);
-	void (*invalidatepage) (struct page *, unsigned long);
+	void (*invalidatepage) (struct page *, unsigned int, unsigned int);
 	int (*releasepage) (struct page *, gfp_t);
 	void (*freepage)(struct page *);
 	ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 66e2f7c..9f4fb36 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1056,7 +1056,8 @@ int get_kernel_page(unsigned long start, int write, struct page **pages);
 struct page *get_dump_page(unsigned long addr);
 
 extern int try_to_release_page(struct page * page, gfp_t gfp_mask);
-extern void do_invalidatepage(struct page *page, unsigned long offset);
+extern void do_invalidatepage(struct page *page, unsigned int offset,
+			      unsigned int length);
 
 int __set_page_dirty_nobuffers(struct page *page);
 int __set_page_dirty_no_writeback(struct page *page);
diff --git a/mm/readahead.c b/mm/readahead.c
index 7963f23..3565e53 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -48,7 +48,7 @@ static void read_cache_pages_invalidate_page(struct address_space *mapping,
 		if (!trylock_page(page))
 			BUG();
 		page->mapping = mapping;
-		do_invalidatepage(page, 0);
+		do_invalidatepage(page, 0, PAGE_CACHE_SIZE);
 		page->mapping = NULL;
 		unlock_page(page);
 	}
diff --git a/mm/truncate.c b/mm/truncate.c
index c75b736..fdba083 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -26,7 +26,8 @@
 /**
  * do_invalidatepage - invalidate part or all of a page
  * @page: the page which is affected
- * @offset: the index of the truncation point
+ * @offset: start of the range to invalidate
+ * @length: length of the range to invalidate
  *
  * do_invalidatepage() is called when all or part of the page has become
  * invalidated by a truncate operation.
@@ -37,16 +38,18 @@
  * point.  Because the caller is about to free (and possibly reuse) those
  * blocks on-disk.
  */
-void do_invalidatepage(struct page *page, unsigned long offset)
+void do_invalidatepage(struct page *page, unsigned int offset,
+		       unsigned int length)
 {
-	void (*invalidatepage)(struct page *, unsigned long);
+	void (*invalidatepage)(struct page *, unsigned int, unsigned int);
+
 	invalidatepage = page->mapping->a_ops->invalidatepage;
 #ifdef CONFIG_BLOCK
 	if (!invalidatepage)
 		invalidatepage = block_invalidatepage;
 #endif
 	if (invalidatepage)
-		(*invalidatepage)(page, offset);
+		(*invalidatepage)(page, offset, length);
 }
 
 static inline void truncate_partial_page(struct page *page, unsigned partial)
@@ -54,7 +57,7 @@ static inline void truncate_partial_page(struct page *page, unsigned partial)
 	zero_user_segment(page, partial, PAGE_CACHE_SIZE);
 	cleancache_invalidate_page(page->mapping, page);
 	if (page_has_private(page))
-		do_invalidatepage(page, partial);
+		do_invalidatepage(page, partial, PAGE_CACHE_SIZE - partial);
 }
 
 /*
@@ -103,7 +106,7 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 		return -EIO;
 
 	if (page_has_private(page))
-		do_invalidatepage(page, 0);
+		do_invalidatepage(page, 0, PAGE_CACHE_SIZE);
 
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
