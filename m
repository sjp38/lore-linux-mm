Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E30106B0028
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:14 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id h4so16216464qtj.11
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:14 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b49si4205864qte.189.2018.04.04.12.19.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:13 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 28/79] fs: introduce page_is_truncated() helper
Date: Wed,  4 Apr 2018 15:18:02 -0400
Message-Id: <20180404191831.5378-13-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jeff Layton <jlayton@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Simple helper to unify all truncation test to one logic. This also
unify logic that was bit different in various places.

Convertion done using following coccinelle spatch on fs and mm dir:
---------------------------------------------------------------------
@@
struct page * ppage;
@@
-!ppage->mapping
+page_is_truncated(ppage, mapping)

@@
struct page * ppage;
@@
-ppage->mapping != mapping
+page_is_truncated(ppage, mapping)

@@
struct page * ppage;
@@
-ppage->mapping != inode->i_mapping
+page_is_truncated(ppage, inode->i_mapping)
---------------------------------------------------------------------

Followed by:
git checkout mm/migrate.c mm/huge_memory.c mm/memory-failure.c
git checkout mm/memcontrol.c fs/ext4/page-io.c fs/reiserfs/journal.c

Hand editing:
    mm/memory.c do_page_mkwrite()
    fs/splice.c splice_to_pipe()
    fs/nfs/dir.c cache_page_release()
    fs/xfs/xfs_aops.c xfs_check_page_type()
    fs/xfs/xfs_aops.c xfs_vm_set_page_dirty()
    fs/buffer.c mark_buffer_write_io_error()
    fs/buffer.c page_cache_seek_hole_data()

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jeff Layton <jlayton@redhat.com>

fixup! fs: introduce page_is_truncated() helper
---
 drivers/staging/lustre/lustre/llite/llite_mmap.c |  7 +++++--
 fs/9p/vfs_file.c                                 |  2 +-
 fs/afs/write.c                                   |  2 +-
 fs/btrfs/extent_io.c                             |  4 ++--
 fs/btrfs/file.c                                  |  2 +-
 fs/btrfs/inode.c                                 |  7 ++++---
 fs/btrfs/ioctl.c                                 |  6 +++---
 fs/btrfs/scrub.c                                 |  2 +-
 fs/buffer.c                                      |  8 ++++----
 fs/ceph/addr.c                                   |  6 +++---
 fs/cifs/file.c                                   |  2 +-
 fs/ext4/inode.c                                  | 10 +++++-----
 fs/ext4/mballoc.c                                |  8 ++++----
 fs/f2fs/checkpoint.c                             |  4 ++--
 fs/f2fs/data.c                                   |  8 ++++----
 fs/f2fs/file.c                                   |  2 +-
 fs/f2fs/super.c                                  |  2 +-
 fs/fuse/file.c                                   |  2 +-
 fs/gfs2/aops.c                                   |  2 +-
 fs/gfs2/file.c                                   |  4 ++--
 fs/iomap.c                                       |  2 +-
 fs/nfs/dir.c                                     |  2 +-
 fs/nilfs2/file.c                                 |  2 +-
 fs/ocfs2/aops.c                                  |  2 +-
 fs/ocfs2/mmap.c                                  |  2 +-
 fs/splice.c                                      |  2 +-
 fs/ubifs/file.c                                  |  2 +-
 fs/xfs/xfs_aops.c                                |  8 +++++---
 include/linux/pagemap.h                          | 16 ++++++++++++++++
 mm/filemap.c                                     | 12 ++++++------
 mm/memory.c                                      |  5 ++++-
 mm/page-writeback.c                              |  2 +-
 mm/truncate.c                                    | 12 ++++++------
 33 files changed, 92 insertions(+), 67 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index c0533bd6f352..6a9d310a7bfd 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -191,7 +191,7 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
 		struct ll_inode_info *lli = ll_i2info(inode);
 
 		lock_page(vmpage);
-		if (!vmpage->mapping) {
+		if (page_is_truncated(vmpage, inode->i_mapping)) {
 			unlock_page(vmpage);
 
 			/* page was truncated and lock was cancelled, return
@@ -341,10 +341,13 @@ static int ll_fault(struct vm_fault *vmf)
 	LASSERT(!(result & VM_FAULT_LOCKED));
 	if (result == 0) {
 		struct page *vmpage = vmf->page;
+		struct address_space *mapping;
+
+		mapping = vmf->vma->vm_file ? vmf->vma->vm_file->f_mapping : 0;
 
 		/* check if this page has been truncated */
 		lock_page(vmpage);
-		if (unlikely(!vmpage->mapping)) { /* unlucky */
+		if (unlikely(page_is_truncated(vmpage, mapping))) { /* unlucky */
 			unlock_page(vmpage);
 			put_page(vmpage);
 			vmf->page = NULL;
diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index 03c9e325bfbc..bf71ea1d7ff6 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -553,7 +553,7 @@ v9fs_vm_page_mkwrite(struct vm_fault *vmf)
 	v9fs_fscache_wait_on_page_write(inode, page);
 	BUG_ON(!v9inode->writeback_fid);
 	lock_page(page);
-	if (page->mapping != inode->i_mapping)
+	if (page_is_truncated(page, inode->i_mapping))
 		goto out_unlock;
 	wait_for_stable_page(page);
 
diff --git a/fs/afs/write.c b/fs/afs/write.c
index b0757ca87bfc..9c5bdad0bd72 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -583,7 +583,7 @@ static int afs_writepages_region(struct address_space *mapping,
 			return ret;
 		}
 
-		if (page->mapping != mapping || !PageDirty(page)) {
+		if (page_is_truncated(page, mapping) || !PageDirty(page)) {
 			unlock_page(page);
 			put_page(page);
 			continue;
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 2232a2c224e3..3c145b353873 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -1718,7 +1718,7 @@ static int __process_pages_contig(struct address_space *mapping,
 			if (page_ops & PAGE_LOCK) {
 				lock_page(pages[i]);
 				if (!PageDirty(pages[i]) ||
-				    pages[i]->mapping != mapping) {
+				    page_is_truncated(pages[i], mapping)) {
 					unlock_page(pages[i]);
 					put_page(pages[i]);
 					err = -EAGAIN;
@@ -3970,7 +3970,7 @@ static int extent_write_cache_pages(struct address_space *mapping,
 				lock_page(page);
 			}
 
-			if (unlikely(page->mapping != mapping)) {
+			if (unlikely(page_is_truncated(page, mapping))) {
 				unlock_page(page);
 				continue;
 			}
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 8430df155af6..989735cd751c 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1406,7 +1406,7 @@ static int prepare_uptodate_page(struct inode *inode,
 			unlock_page(page);
 			return -EIO;
 		}
-		if (page->mapping != inode->i_mapping) {
+		if (page_is_truncated(page, inode->i_mapping)) {
 			unlock_page(page);
 			return -EAGAIN;
 		}
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 7d6b22a8791b..968640312537 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -2087,7 +2087,8 @@ static void btrfs_writepage_fixup_worker(struct btrfs_work *work)
 	page = fixup->page;
 again:
 	lock_page(page);
-	if (!page->mapping || !PageDirty(page) || !PageChecked(page)) {
+	if (page_is_truncated(page, page->mapping) ||
+	    !PageDirty(page) || !PageChecked(page)) {
 		ClearPageChecked(page);
 		goto out_page;
 	}
@@ -4815,7 +4816,7 @@ int btrfs_truncate_block(struct inode *inode, loff_t from, loff_t len,
 	if (!PageUptodate(page)) {
 		ret = btrfs_readpage(NULL, mapping, page);
 		lock_page(page);
-		if (page->mapping != mapping) {
+		if (page_is_truncated(page, mapping)) {
 			unlock_page(page);
 			put_page(page);
 			goto again;
@@ -9019,7 +9020,7 @@ int btrfs_page_mkwrite(struct vm_fault *vmf)
 	lock_page(page);
 	size = i_size_read(inode);
 
-	if ((page->mapping != inode->i_mapping) ||
+	if ((page_is_truncated(page, inode->i_mapping)) ||
 	    (page_start >= size)) {
 		/* page got truncated out from underneath us */
 		goto out_unlock;
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index b1186c15f293..c57e9ce8204d 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -1141,7 +1141,7 @@ static int cluster_pages_for_defrag(struct inode *inode,
 			 * we unlocked the page above, so we need check if
 			 * it was released or not.
 			 */
-			if (page->mapping != inode->i_mapping) {
+			if (page_is_truncated(page, inode->i_mapping)) {
 				unlock_page(page);
 				put_page(page);
 				goto again;
@@ -1159,7 +1159,7 @@ static int cluster_pages_for_defrag(struct inode *inode,
 			}
 		}
 
-		if (page->mapping != inode->i_mapping) {
+		if (page_is_truncated(page, inode->i_mapping)) {
 			unlock_page(page);
 			put_page(page);
 			goto again;
@@ -2834,7 +2834,7 @@ static struct page *extent_same_get_page(struct inode *inode, pgoff_t index)
 			put_page(page);
 			return ERR_PTR(-EIO);
 		}
-		if (page->mapping != inode->i_mapping) {
+		if (page_is_truncated(page, inode->i_mapping)) {
 			unlock_page(page);
 			put_page(page);
 			return ERR_PTR(-EAGAIN);
diff --git a/fs/btrfs/scrub.c b/fs/btrfs/scrub.c
index ec56f33feea9..e621b79a90b3 100644
--- a/fs/btrfs/scrub.c
+++ b/fs/btrfs/scrub.c
@@ -4574,7 +4574,7 @@ static int copy_nocow_pages_for_inode(u64 inum, u64 offset, u64 root,
 			 * old one, the new data may be written into the new
 			 * page in the page cache.
 			 */
-			if (page->mapping != inode->i_mapping) {
+			if (page_is_truncated(page, inode->i_mapping)) {
 				unlock_page(page);
 				put_page(page);
 				goto again;
diff --git a/fs/buffer.c b/fs/buffer.c
index 6790bb4ebc07..8b2eb3dfb539 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -602,7 +602,7 @@ static void __set_page_dirty(struct page *page, struct address_space *_mapping,
 	struct address_space *mapping = page_mapping(page);
 
 	spin_lock_irqsave(&mapping->tree_lock, flags);
-	if (page->mapping) {	/* Race with truncate? */
+	if (page_is_truncated(page, mapping)) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
 		account_page_dirtied(page, mapping);
 		radix_tree_tag_set(&mapping->page_tree,
@@ -1138,7 +1138,7 @@ void mark_buffer_write_io_error(struct buffer_head *bh)
 {
 	set_buffer_write_io_error(bh);
 	/* FIXME: do we need to set this in both places? */
-	if (bh->b_page && bh->b_page->mapping)
+	if (bh->b_page && !page_is_truncated(bh->b_page, bh->b_page->mapping))
 		mapping_set_error(bh->b_page->mapping, -EIO);
 	if (bh->b_assoc_map)
 		mapping_set_error(bh->b_assoc_map, -EIO);
@@ -2482,7 +2482,7 @@ int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 	lock_page(page);
 	size = i_size_read(inode);
-	if ((page->mapping != inode->i_mapping) ||
+	if ((page_is_truncated(page, inode->i_mapping)) ||
 	    (page_offset(page) > size)) {
 		/* We overload EFAULT to mean page got truncated */
 		ret = -EFAULT;
@@ -3538,7 +3538,7 @@ page_cache_seek_hole_data(struct inode *inode, loff_t offset, loff_t length,
 				goto check_range;
 
 			lock_page(page);
-			if (likely(page->mapping == inode->i_mapping) &&
+			if (likely(!page_is_truncated(page, inode->i_mapping)) &&
 			    page_has_buffers(page)) {
 				lastoff = page_seek_hole_data(page, lastoff, whence);
 				if (lastoff >= 0) {
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 1ebb146dc890..c274d8a32479 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -126,7 +126,7 @@ static int ceph_set_page_dirty(struct address_space *_mapping,
 
 	ret = __set_page_dirty_nobuffers(page);
 	WARN_ON(!PageLocked(page));
-	WARN_ON(!page->mapping);
+	WARN_ON(page_is_truncated(page, mapping));
 
 	return ret;
 }
@@ -899,7 +899,7 @@ static int ceph_writepages_start(struct address_space *mapping,
 
 			/* only dirty pages, or our accounting breaks */
 			if (unlikely(!PageDirty(page)) ||
-			    unlikely(page->mapping != mapping)) {
+			    unlikely(page_is_truncated(page, mapping))) {
 				dout("!dirty or !mapping %p\n", page);
 				unlock_page(page);
 				continue;
@@ -1586,7 +1586,7 @@ static int ceph_page_mkwrite(struct vm_fault *vmf)
 	do {
 		lock_page(page);
 
-		if ((off > size) || (page->mapping != inode->i_mapping)) {
+		if ((off > size) || (page_is_truncated(page, inode->i_mapping))) {
 			unlock_page(page);
 			ret = VM_FAULT_NOPAGE;
 			break;
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 01f2c3852eea..017fe16ae993 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -1999,7 +1999,7 @@ wdata_prepare_pages(struct cifs_writedata *wdata, unsigned int found_pages,
 		else if (!trylock_page(page))
 			break;
 
-		if (unlikely(page->mapping != mapping)) {
+		if (unlikely(page_is_truncated(page, mapping))) {
 			unlock_page(page);
 			break;
 		}
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 63bf0160c579..394fed206138 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1295,7 +1295,7 @@ static int ext4_write_begin(struct file *file, struct address_space *mapping,
 	}
 
 	lock_page(page);
-	if (page->mapping != mapping) {
+	if (page_is_truncated(page, mapping)) {
 		/* The page got truncated from under us */
 		unlock_page(page);
 		put_page(page);
@@ -2023,7 +2023,7 @@ static int __ext4_journalled_writepage(struct page *page,
 
 	lock_page(page);
 	put_page(page);
-	if (page->mapping != mapping) {
+	if (page_is_truncated(page, mapping)) {
 		/* The page got truncated from under us */
 		ext4_journal_stop(handle);
 		ret = 0;
@@ -2667,7 +2667,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 			if (!PageDirty(page) ||
 			    (PageWriteback(page) &&
 			     (mpd->wbc->sync_mode == WB_SYNC_NONE)) ||
-			    unlikely(page->mapping != mapping)) {
+			    unlikely(page_is_truncated(page, mapping))) {
 				unlock_page(page);
 				continue;
 			}
@@ -3066,7 +3066,7 @@ static int ext4_da_write_begin(struct file *file, struct address_space *mapping,
 	}
 
 	lock_page(page);
-	if (page->mapping != mapping) {
+	if (page_is_truncated(page, mapping)) {
 		/* The page got truncated from under us */
 		unlock_page(page);
 		put_page(page);
@@ -6123,7 +6123,7 @@ int ext4_page_mkwrite(struct vm_fault *vmf)
 	lock_page(page);
 	size = i_size_read(inode);
 	/* Page got truncated from under us? */
-	if (page->mapping != mapping || page_offset(page) > size) {
+	if (page_is_truncated(page, mapping) || page_offset(page) > size) {
 		unlock_page(page);
 		ret = VM_FAULT_NOPAGE;
 		goto out;
diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
index 769a62708b1c..38deb97705c4 100644
--- a/fs/ext4/mballoc.c
+++ b/fs/ext4/mballoc.c
@@ -991,7 +991,7 @@ static int ext4_mb_get_buddy_page_lock(struct super_block *sb,
 	page = find_or_create_page(inode->i_mapping, pnum, gfp);
 	if (!page)
 		return -ENOMEM;
-	BUG_ON(page->mapping != inode->i_mapping);
+	BUG_ON(page_is_truncated(page, inode->i_mapping));
 	e4b->bd_bitmap_page = page;
 	e4b->bd_bitmap = page_address(page) + (poff * sb->s_blocksize);
 
@@ -1005,7 +1005,7 @@ static int ext4_mb_get_buddy_page_lock(struct super_block *sb,
 	page = find_or_create_page(inode->i_mapping, pnum, gfp);
 	if (!page)
 		return -ENOMEM;
-	BUG_ON(page->mapping != inode->i_mapping);
+	BUG_ON(page_is_truncated(page, inode->i_mapping));
 	e4b->bd_buddy_page = page;
 	return 0;
 }
@@ -1156,7 +1156,7 @@ ext4_mb_load_buddy_gfp(struct super_block *sb, ext4_group_t group,
 			put_page(page);
 		page = find_or_create_page(inode->i_mapping, pnum, gfp);
 		if (page) {
-			BUG_ON(page->mapping != inode->i_mapping);
+			BUG_ON(page_is_truncated(page, inode->i_mapping));
 			if (!PageUptodate(page)) {
 				ret = ext4_mb_init_cache(page, NULL, gfp);
 				if (ret) {
@@ -1192,7 +1192,7 @@ ext4_mb_load_buddy_gfp(struct super_block *sb, ext4_group_t group,
 			put_page(page);
 		page = find_or_create_page(inode->i_mapping, pnum, gfp);
 		if (page) {
-			BUG_ON(page->mapping != inode->i_mapping);
+			BUG_ON(page_is_truncated(page, inode->i_mapping));
 			if (!PageUptodate(page)) {
 				ret = ext4_mb_init_cache(page, e4b->bd_bitmap,
 							 gfp);
diff --git a/fs/f2fs/checkpoint.c b/fs/f2fs/checkpoint.c
index c694c504d673..b218fcacd395 100644
--- a/fs/f2fs/checkpoint.c
+++ b/fs/f2fs/checkpoint.c
@@ -89,7 +89,7 @@ static struct page *__get_meta_page(struct f2fs_sb_info *sbi, pgoff_t index,
 	}
 
 	lock_page(page);
-	if (unlikely(page->mapping != mapping)) {
+	if (unlikely(page_is_truncated(page, mapping))) {
 		f2fs_put_page(page, 1);
 		goto repeat;
 	}
@@ -337,7 +337,7 @@ long sync_meta_pages(struct f2fs_sb_info *sbi, enum page_type type,
 
 			lock_page(page);
 
-			if (unlikely(page->mapping != mapping)) {
+			if (unlikely(page_is_truncated(page, mapping))) {
 continue_unlock:
 				unlock_page(page);
 				continue;
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index d15ccbd69bf2..c1a8dd623444 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -725,7 +725,7 @@ struct page *get_lock_data_page(struct inode *inode, pgoff_t index,
 
 	/* wait for read completion */
 	lock_page(page);
-	if (unlikely(page->mapping != mapping)) {
+	if (unlikely(page_is_truncated(page, mapping))) {
 		f2fs_put_page(page, 1);
 		goto repeat;
 	}
@@ -1899,7 +1899,7 @@ static int f2fs_write_cache_pages(struct address_space *mapping,
 retry_write:
 			lock_page(page);
 
-			if (unlikely(page->mapping != mapping)) {
+			if (unlikely(page_is_truncated(page, mapping))) {
 continue_unlock:
 				unlock_page(page);
 				continue;
@@ -2189,7 +2189,7 @@ static int f2fs_write_begin(struct file *file, struct address_space *mapping,
 		unlock_page(page);
 		f2fs_balance_fs(sbi, true);
 		lock_page(page);
-		if (page->mapping != mapping) {
+		if (page_is_truncated(page, mapping)) {
 			/* The page got truncated from under us */
 			f2fs_put_page(page, 1);
 			goto repeat;
@@ -2219,7 +2219,7 @@ static int f2fs_write_begin(struct file *file, struct address_space *mapping,
 			goto fail;
 
 		lock_page(page);
-		if (unlikely(page->mapping != mapping)) {
+		if (unlikely(page_is_truncated(page, mapping))) {
 			f2fs_put_page(page, 1);
 			goto repeat;
 		}
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 672a542e5464..5e9ac31240bb 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -78,7 +78,7 @@ static int f2fs_vm_page_mkwrite(struct vm_fault *vmf)
 	file_update_time(vmf->vma->vm_file);
 	down_read(&F2FS_I(inode)->i_mmap_sem);
 	lock_page(page);
-	if (unlikely(page->mapping != inode->i_mapping ||
+	if (unlikely(page_is_truncated(page, inode->i_mapping) ||
 			page_offset(page) > i_size_read(inode) ||
 			!PageUptodate(page))) {
 		unlock_page(page);
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 8173ae688814..af855b563de0 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -1467,7 +1467,7 @@ static ssize_t f2fs_quota_read(struct super_block *sb, int type, char *data,
 
 		lock_page(page);
 
-		if (unlikely(page->mapping != mapping)) {
+		if (unlikely(page_is_truncated(page, mapping))) {
 			f2fs_put_page(page, 1);
 			goto repeat;
 		}
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index e0562d04d84f..e63be7831f4d 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -2059,7 +2059,7 @@ static int fuse_page_mkwrite(struct vm_fault *vmf)
 
 	file_update_time(vmf->vma->vm_file);
 	lock_page(page);
-	if (page->mapping != inode->i_mapping) {
+	if (page_is_truncated(page, inode->i_mapping)) {
 		unlock_page(page);
 		return VM_FAULT_NOPAGE;
 	}
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index b42775bba6a1..21cb6bc98645 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -290,7 +290,7 @@ static int gfs2_write_jdata_pagevec(struct address_space *mapping,
 
 		lock_page(page);
 
-		if (unlikely(page->mapping != mapping)) {
+		if (unlikely(page_is_truncated(page, mapping))) {
 continue_unlock:
 			unlock_page(page);
 			continue;
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index 4f88e201b3f0..2c4584deb077 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -422,7 +422,7 @@ static int gfs2_page_mkwrite(struct vm_fault *vmf)
 
 	if (!gfs2_write_alloc_required(ip, pos, PAGE_SIZE)) {
 		lock_page(page);
-		if (!PageUptodate(page) || page->mapping != inode->i_mapping) {
+		if (!PageUptodate(page) || page_is_truncated(page, inode->i_mapping)) {
 			ret = -EAGAIN;
 			unlock_page(page);
 		}
@@ -465,7 +465,7 @@ static int gfs2_page_mkwrite(struct vm_fault *vmf)
 	/* If truncated, we must retry the operation, we may have raced
 	 * with the glock demotion code.
 	 */
-	if (!PageUptodate(page) || page->mapping != inode->i_mapping)
+	if (!PageUptodate(page) || page_is_truncated(page, inode->i_mapping))
 		goto out_trans_end;
 
 	/* Unstuff, if required, and allocate backing blocks for page */
diff --git a/fs/iomap.c b/fs/iomap.c
index afd163586aa0..3801abd93e4d 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -453,7 +453,7 @@ int iomap_page_mkwrite(struct vm_fault *vmf, const struct iomap_ops *ops)
 
 	lock_page(page);
 	size = i_size_read(inode);
-	if ((page->mapping != inode->i_mapping) ||
+	if (page_is_truncated(page, inode->i_mapping) ||
 	    (page_offset(page) > size)) {
 		/* We overload EFAULT to mean page got truncated */
 		ret = -EFAULT;
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 1d988a0e91ee..9e23eab3d0df 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -689,7 +689,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc,
 static
 void cache_page_release(nfs_readdir_descriptor_t *desc)
 {
-	if (!desc->page->mapping)
+	if (page_is_truncated(desc->page, desc->file->f_mapping))
 		nfs_readdir_clear_array(desc->page);
 	put_page(desc->page);
 	desc->page = NULL;
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index c5fa3dee72fc..6d061b78a0d8 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -64,7 +64,7 @@ static int nilfs_page_mkwrite(struct vm_fault *vmf)
 
 	sb_start_pagefault(inode->i_sb);
 	lock_page(page);
-	if (page->mapping != inode->i_mapping ||
+	if (page_is_truncated(page, inode->i_mapping) ||
 	    page_offset(page) >= i_size_read(inode) || !PageUptodate(page)) {
 		unlock_page(page);
 		ret = -EFAULT;	/* make the VM retry the fault */
diff --git a/fs/ocfs2/aops.c b/fs/ocfs2/aops.c
index 9942ee775e08..2d1d3afc9664 100644
--- a/fs/ocfs2/aops.c
+++ b/fs/ocfs2/aops.c
@@ -1103,7 +1103,7 @@ static int ocfs2_grab_pages_for_write(struct address_space *mapping,
 			lock_page(mmap_page);
 
 			/* Exit and let the caller retry */
-			if (mmap_page->mapping != mapping) {
+			if (page_is_truncated(mmap_page, mapping)) {
 				WARN_ON(mmap_page->mapping);
 				unlock_page(mmap_page);
 				ret = -EAGAIN;
diff --git a/fs/ocfs2/mmap.c b/fs/ocfs2/mmap.c
index fb9a20e3d608..2144c5343d08 100644
--- a/fs/ocfs2/mmap.c
+++ b/fs/ocfs2/mmap.c
@@ -87,7 +87,7 @@ static int __ocfs2_page_mkwrite(struct file *file, struct buffer_head *di_bh,
 	 *
 	 * Let VM retry with these cases.
 	 */
-	if ((page->mapping != inode->i_mapping) ||
+	if ((page_is_truncated(page, inode->i_mapping)) ||
 	    (!PageUptodate(page)) ||
 	    (page_offset(page) >= size))
 		goto out;
diff --git a/fs/splice.c b/fs/splice.c
index acab52a7fe56..a9b70ab19be3 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -112,7 +112,7 @@ static int page_cache_pipe_buf_confirm(struct pipe_inode_info *pipe,
 		 * Page got truncated/unhashed. This will cause a 0-byte
 		 * splice, if this is the first page.
 		 */
-		if (!page->mapping) {
+		if (page_is_truncated(page, pipe->inode->i_mapping)) {
 			err = -ENODATA;
 			goto error;
 		}
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 4d7d10aadbba..6dcc98351b28 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1570,7 +1570,7 @@ static int ubifs_vm_page_mkwrite(struct vm_fault *vmf)
 	}
 
 	lock_page(page);
-	if (unlikely(page->mapping != inode->i_mapping ||
+	if (unlikely(page_is_truncated(page, inode->i_mapping) ||
 		     page_offset(page) > i_size_read(inode))) {
 		/* Page got truncated out from underneath us */
 		err = -EINVAL;
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index bed27e59720a..1e2b461b8772 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -719,6 +719,7 @@ xfs_map_at_offset(
 STATIC bool
 xfs_check_page_type(
 	struct page		*page,
+	struct inode		*inode,
 	unsigned int		type,
 	bool			check_all_buffers)
 {
@@ -727,7 +728,7 @@ xfs_check_page_type(
 
 	if (PageWriteback(page))
 		return false;
-	if (!page->mapping)
+	if (page_is_truncated(page, inode->i_mapping))
 		return false;
 	if (!page_has_buffers(page))
 		return false;
@@ -798,7 +799,7 @@ xfs_aops_discard_page(
 	struct buffer_head	*bh, *head;
 	loff_t			offset = page_offset(page);
 
-	if (!xfs_check_page_type(page, XFS_IO_DELALLOC, true))
+	if (!xfs_check_page_type(page, inode, XFS_IO_DELALLOC, true))
 		goto out_invalidate;
 
 	if (XFS_FORCED_SHUTDOWN(ip->i_mount))
@@ -1483,7 +1484,8 @@ xfs_vm_set_page_dirty(
 		unsigned long flags;
 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
-		if (page->mapping) {	/* Race with truncate? */
+		/* Race with truncate? */
+		if (!page_is_truncated(page, mapping)) {
 			WARN_ON_ONCE(!PageUptodate(page));
 			account_page_dirtied(page, mapping);
 			radix_tree_tag_set(&mapping->page_tree,
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index c20f00b3321a..e937f493365e 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -229,6 +229,22 @@ static inline struct page *__page_cache_alloc(gfp_t gfp)
 }
 #endif
 
+/*
+ * page_is_truncated() - test if a page have been truncated
+ * @page: page to test
+ * @mapping: address_space the page should belongs to
+ * Returns: true if truncated, false otherwise
+ *
+ * When page is truncated its mapping is set to NULL. Truncation being a multi-
+ * steps process a truncated page can still be under-going activities hence why
+ * page truncation are scatter through fs and mm code.
+ */
+static inline bool page_is_truncated(struct page *page,
+				     struct address_space *mapping)
+{
+	return !page->mapping || page->mapping != mapping;
+}
+
 static inline struct page *page_cache_alloc(struct address_space *x)
 {
 	return __page_cache_alloc(mapping_gfp_mask(x));
diff --git a/mm/filemap.c b/mm/filemap.c
index 3a980e2128ad..876e7e8c8a3e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1554,7 +1554,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 		}
 
 		/* Has the page been truncated? */
-		if (unlikely(page->mapping != mapping)) {
+		if (unlikely(page_is_truncated(page, mapping))) {
 			unlock_page(page);
 			put_page(page);
 			goto repeat;
@@ -2129,7 +2129,7 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
 			if (!trylock_page(page))
 				goto page_not_up_to_date;
 			/* Did it get truncated before we got the lock? */
-			if (!page->mapping)
+			if (page_is_truncated(page, mapping))
 				goto page_not_up_to_date_locked;
 			if (!mapping->a_ops->is_partially_uptodate(page,
 						mapping, offset, iter->count))
@@ -2208,7 +2208,7 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
 
 page_not_up_to_date_locked:
 		/* Did it get truncated before we got the lock? */
-		if (!page->mapping) {
+		if (page_is_truncated(page, mapping)) {
 			unlock_page(page);
 			put_page(page);
 			continue;
@@ -2535,7 +2535,7 @@ int filemap_fault(struct vm_fault *vmf)
 	}
 
 	/* Did it get truncated? */
-	if (unlikely(page->mapping != mapping)) {
+	if (unlikely(page_is_truncated(page, mapping))) {
 		unlock_page(page);
 		put_page(page);
 		goto retry_find;
@@ -2663,7 +2663,7 @@ void filemap_map_pages(struct vm_fault *vmf,
 		if (!trylock_page(page))
 			goto skip;
 
-		if (page->mapping != mapping || !PageUptodate(page))
+		if (page_is_truncated(page, mapping) || !PageUptodate(page))
 			goto unlock;
 
 		max_idx = DIV_ROUND_UP(i_size_read(mapping->host), PAGE_SIZE);
@@ -2854,7 +2854,7 @@ static struct page *do_read_cache_page(struct address_space *mapping,
 	lock_page(page);
 
 	/* Case c or d, restart the operation */
-	if (!page->mapping) {
+	if (page_is_truncated(page, mapping)) {
 		unlock_page(page);
 		put_page(page);
 		goto repeat;
diff --git a/mm/memory.c b/mm/memory.c
index 5fcfc24904d1..1311599a164b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2365,6 +2365,9 @@ static int do_page_mkwrite(struct vm_fault *vmf)
 	int ret;
 	struct page *page = vmf->page;
 	unsigned int old_flags = vmf->flags;
+	struct address_space *mapping;
+
+	mapping = vmf->vma->vm_file ? vmf->vma->vm_file->f_mapping : NULL;
 
 	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 
@@ -2375,7 +2378,7 @@ static int do_page_mkwrite(struct vm_fault *vmf)
 		return ret;
 	if (unlikely(!(ret & VM_FAULT_LOCKED))) {
 		lock_page(page);
-		if (!page->mapping) {
+		if (page_is_truncated(page, mapping)) {
 			unlock_page(page);
 			return 0; /* retry */
 		}
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 67b857ee1a1c..3c14d44639c8 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2213,7 +2213,7 @@ int write_cache_pages(struct address_space *mapping,
 			 * even if there is now a new, dirty page at the same
 			 * pagecache address.
 			 */
-			if (unlikely(page->mapping != mapping)) {
+			if (unlikely(page_is_truncated(page, mapping))) {
 continue_unlock:
 				unlock_page(page);
 				continue;
diff --git a/mm/truncate.c b/mm/truncate.c
index 497a895db341..a9415c96c966 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -209,7 +209,7 @@ invalidate_complete_page(struct address_space *mapping, struct page *page)
 {
 	int ret;
 
-	if (page->mapping != mapping)
+	if (page_is_truncated(page, mapping))
 		return 0;
 
 	if (page_has_private(page) && !try_to_release_page(page, 0))
@@ -224,7 +224,7 @@ int truncate_inode_page(struct address_space *mapping, struct page *page)
 {
 	VM_BUG_ON_PAGE(PageTail(page), page);
 
-	if (page->mapping != mapping)
+	if (page_is_truncated(page, mapping))
 		return -EIO;
 
 	truncate_cleanup_page(mapping, page);
@@ -358,7 +358,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 				unlock_page(page);
 				continue;
 			}
-			if (page->mapping != mapping) {
+			if (page_is_truncated(page, mapping)) {
 				unlock_page(page);
 				continue;
 			}
@@ -622,7 +622,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 {
 	unsigned long flags;
 
-	if (page->mapping != mapping)
+	if (page_is_truncated(page, mapping))
 		return 0;
 
 	if (page_has_private(page) && !try_to_release_page(page, GFP_KERNEL))
@@ -650,7 +650,7 @@ static int do_launder_page(struct address_space *mapping, struct page *page)
 {
 	if (!PageDirty(page))
 		return 0;
-	if (page->mapping != mapping || mapping->a_ops->launder_page == NULL)
+	if (page_is_truncated(page, mapping) || mapping->a_ops->launder_page == NULL)
 		return 0;
 	return mapping->a_ops->launder_page(mapping, page);
 }
@@ -702,7 +702,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 
 			lock_page(page);
 			WARN_ON(page_to_index(page) != index);
-			if (page->mapping != mapping) {
+			if (page_is_truncated(page, mapping)) {
 				unlock_page(page);
 				continue;
 			}
-- 
2.14.3
