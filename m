Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id B93FF6B0266
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 20:57:44 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id i13-v6so9030134oth.4
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 17:57:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1-v6sor6024034oil.172.2018.07.01.17.57.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Jul 2018 17:57:42 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH v2 4/6] mm/fs: add a sync_mode param for clear_page_dirty_for_io()
Date: Sun,  1 Jul 2018 17:56:52 -0700
Message-Id: <20180702005654.20369-5-jhubbard@nvidia.com>
In-Reply-To: <20180702005654.20369-1-jhubbard@nvidia.com>
References: <20180702005654.20369-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

Add a sync_mode parameter to clear_page_dirty_for_io(), to specify the
writeback sync mode, and also pass in the appropriate value
(WB_SYNC_NONE or WB_SYNC_ALL), from each filesystem location that calls
it. This will be used in subsequent patches, to allow page_mkclean() to
decide how to handle pinned pages.

How to decide which value to pass to clear_page_dirty_for_io?
Jan Kara's write-up explains that:

    What needs to happen in page_mkclean() depends on the caller. Most of
    the callers really need to be sure the page is write-protected once
    page_mkclean() returns. Those are:

      pagecache_isize_extended()
      fb_deferred_io_work()
      clear_page_dirty_for_io() if called for data-integrity
      writeback--which is currently known only in its caller
      (e.g. write_cache_pages()), where it can be determined as
      wbc->sync_mode == WB_SYNC_ALL. Getting this information into
      page_mkclean() will require some plumbing and
      clear_page_dirty_for_io() has some 50 callers but it's doable.

    clear_page_dirty_for_io() for cleaning writeback
    (wbc->sync_mode != WB_SYNC_ALL) can just skip pinned pages and we
    probably need to do that as otherwise memory cleaning would get
    stuck on pinned pages until RDMA drivers release its pins.

An enum (writeback_sync_modes) is used instead of a bool,
for the usual readability reasons, but it is declared as
an int, because mm.h neads it, and unless a new header file
is used, an actual enum would further complicate header
file dependencies.

The enum writeback_sync_modes was chosen because these changes are being
made to the filesystems, in order to pass down a hint to the memory
management system. Therefore, it's best to use naming that is
filesystem-centric. The name will be interpreted into more mm-specific
terms, in page_mkclean, in a subsequent patch.

CC: Jan Kara <jack@suse.cz>
CC: linux-fsdevel@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 fs/9p/vfs_addr.c            |  2 +-
 fs/afs/write.c              |  6 +++---
 fs/btrfs/extent_io.c        | 14 +++++++-------
 fs/btrfs/file.c             |  2 +-
 fs/btrfs/free-space-cache.c |  2 +-
 fs/btrfs/ioctl.c            |  2 +-
 fs/ceph/addr.c              |  4 ++--
 fs/cifs/cifssmb.c           |  3 ++-
 fs/cifs/file.c              |  5 +++--
 fs/ext4/inode.c             |  5 +++--
 fs/f2fs/checkpoint.c        |  4 ++--
 fs/f2fs/data.c              |  2 +-
 fs/f2fs/dir.c               |  2 +-
 fs/f2fs/gc.c                |  4 ++--
 fs/f2fs/inline.c            |  2 +-
 fs/f2fs/node.c              | 10 +++++-----
 fs/f2fs/segment.c           |  3 ++-
 fs/fuse/file.c              |  2 +-
 fs/gfs2/aops.c              |  2 +-
 fs/nfs/write.c              |  2 +-
 fs/nilfs2/page.c            |  2 +-
 fs/nilfs2/segment.c         | 10 ++++++----
 fs/ubifs/file.c             |  2 +-
 fs/xfs/xfs_aops.c           |  2 +-
 include/linux/mm.h          |  7 ++++++-
 mm/migrate.c                |  2 +-
 mm/page-writeback.c         | 11 ++++++++---
 mm/vmscan.c                 |  2 +-
 28 files changed, 66 insertions(+), 50 deletions(-)

diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index e1cbdfdb7c68..35572f150b31 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -221,7 +221,7 @@ static int v9fs_launder_page(struct page *page)
 	struct inode *inode = page->mapping->host;
 
 	v9fs_fscache_wait_on_page_write(inode, page);
-	if (clear_page_dirty_for_io(page)) {
+	if (clear_page_dirty_for_io(page, WB_SYNC_NONE)) {
 		retval = v9fs_vfs_writepage_locked(page);
 		if (retval)
 			return retval;
diff --git a/fs/afs/write.c b/fs/afs/write.c
index 8b39e6ebb40b..a0c7a364ffb7 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -472,7 +472,7 @@ static int afs_write_back_from_locked_page(struct address_space *mapping,
 			trace_afs_page_dirty(vnode, tracepoint_string("store+"),
 					     page->index, priv);
 
-			if (!clear_page_dirty_for_io(page))
+			if (!clear_page_dirty_for_io(page, wbc->sync_mode))
 				BUG();
 			if (test_set_page_writeback(page))
 				BUG();
@@ -612,7 +612,7 @@ static int afs_writepages_region(struct address_space *mapping,
 			continue;
 		}
 
-		if (!clear_page_dirty_for_io(page))
+		if (!clear_page_dirty_for_io(page, wbc->sync_mode))
 			BUG();
 		ret = afs_write_back_from_locked_page(mapping, wbc, page, end);
 		put_page(page);
@@ -838,7 +838,7 @@ int afs_launder_page(struct page *page)
 	_enter("{%lx}", page->index);
 
 	priv = page_private(page);
-	if (clear_page_dirty_for_io(page)) {
+	if (clear_page_dirty_for_io(page, WB_SYNC_NONE)) {
 		f = 0;
 		t = PAGE_SIZE;
 		if (PagePrivate(page)) {
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index e55843f536bc..78fafec3b607 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -1364,7 +1364,7 @@ void extent_range_clear_dirty_for_io(struct inode *inode, u64 start, u64 end)
 	while (index <= end_index) {
 		page = find_get_page(inode->i_mapping, index);
 		BUG_ON(!page); /* Pages should be in the extent_io_tree */
-		clear_page_dirty_for_io(page);
+		clear_page_dirty_for_io(page, WB_SYNC_ALL);
 		put_page(page);
 		index++;
 	}
@@ -1707,7 +1707,7 @@ static int __process_pages_contig(struct address_space *mapping,
 				continue;
 			}
 			if (page_ops & PAGE_CLEAR_DIRTY)
-				clear_page_dirty_for_io(pages[i]);
+				clear_page_dirty_for_io(pages[i], WB_SYNC_ALL);
 			if (page_ops & PAGE_SET_WRITEBACK)
 				set_page_writeback(pages[i]);
 			if (page_ops & PAGE_SET_ERROR)
@@ -3740,7 +3740,7 @@ static noinline_for_stack int write_one_eb(struct extent_buffer *eb,
 	for (i = 0; i < num_pages; i++) {
 		struct page *p = eb->pages[i];
 
-		clear_page_dirty_for_io(p);
+		clear_page_dirty_for_io(p, wbc->sync_mode);
 		set_page_writeback(p);
 		ret = submit_extent_page(REQ_OP_WRITE | write_flags, tree, wbc,
 					 p, offset, PAGE_SIZE, 0, bdev,
@@ -3764,7 +3764,7 @@ static noinline_for_stack int write_one_eb(struct extent_buffer *eb,
 	if (unlikely(ret)) {
 		for (; i < num_pages; i++) {
 			struct page *p = eb->pages[i];
-			clear_page_dirty_for_io(p);
+			clear_page_dirty_for_io(p, wbc->sync_mode);
 			unlock_page(p);
 		}
 	}
@@ -3984,7 +3984,7 @@ static int extent_write_cache_pages(struct address_space *mapping,
 			}
 
 			if (PageWriteback(page) ||
-			    !clear_page_dirty_for_io(page)) {
+			    !clear_page_dirty_for_io(page, wbc->sync_mode)) {
 				unlock_page(page);
 				continue;
 			}
@@ -4089,7 +4089,7 @@ int extent_write_locked_range(struct inode *inode, u64 start, u64 end,
 
 	while (start <= end) {
 		page = find_get_page(mapping, start >> PAGE_SHIFT);
-		if (clear_page_dirty_for_io(page))
+		if (clear_page_dirty_for_io(page, wbc_writepages.sync_mode))
 			ret = __extent_writepage(page, &wbc_writepages, &epd);
 		else {
 			if (tree->ops && tree->ops->writepage_end_io_hook)
@@ -5170,7 +5170,7 @@ void clear_extent_buffer_dirty(struct extent_buffer *eb)
 		lock_page(page);
 		WARN_ON(!PagePrivate(page));
 
-		clear_page_dirty_for_io(page);
+		clear_page_dirty_for_io(page, WB_SYNC_ALL);
 		xa_lock_irq(&page->mapping->i_pages);
 		if (!PageDirty(page)) {
 			radix_tree_tag_clear(&page->mapping->i_pages,
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 51e77d72068a..dace1375f366 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1514,7 +1514,7 @@ lock_and_cleanup_extent_if_need(struct btrfs_inode *inode, struct page **pages,
 	}
 
 	for (i = 0; i < num_pages; i++) {
-		if (clear_page_dirty_for_io(pages[i]))
+		if (clear_page_dirty_for_io(pages[i]), WB_SYNC_NONE)
 			account_page_redirty(pages[i]);
 		set_page_extent_mapped(pages[i]);
 		WARN_ON(!PageLocked(pages[i]));
diff --git a/fs/btrfs/free-space-cache.c b/fs/btrfs/free-space-cache.c
index d5f80cb300be..2014e9a2b659 100644
--- a/fs/btrfs/free-space-cache.c
+++ b/fs/btrfs/free-space-cache.c
@@ -387,7 +387,7 @@ static int io_ctl_prepare_pages(struct btrfs_io_ctl *io_ctl, struct inode *inode
 	}
 
 	for (i = 0; i < io_ctl->num_pages; i++) {
-		clear_page_dirty_for_io(io_ctl->pages[i]);
+		clear_page_dirty_for_io(io_ctl->pages[i], WB_SYNC_ALL);
 		set_page_extent_mapped(io_ctl->pages[i]);
 	}
 
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 43ecbe620dea..e7291284b4c8 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -1337,7 +1337,7 @@ static int cluster_pages_for_defrag(struct inode *inode,
 			     page_start, page_end - 1, &cached_state);
 
 	for (i = 0; i < i_done; i++) {
-		clear_page_dirty_for_io(pages[i]);
+		clear_page_dirty_for_io(pages[i], WB_SYNC_ALL);
 		ClearPageChecked(pages[i]);
 		set_page_extent_mapped(pages[i]);
 		set_page_dirty(pages[i]);
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 292b3d72d725..29948c0464c0 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -937,7 +937,7 @@ static int ceph_writepages_start(struct address_space *mapping,
 				wait_on_page_writeback(page);
 			}
 
-			if (!clear_page_dirty_for_io(page)) {
+			if (!clear_page_dirty_for_io(page, wbc->sync_mode)) {
 				dout("%p !clear_page_dirty_for_io\n", page);
 				unlock_page(page);
 				continue;
@@ -1277,7 +1277,7 @@ static int ceph_update_writeable_page(struct file *file,
 		/* yay, writeable, do it now (without dropping page lock) */
 		dout(" page %p snapc %p not current, but oldest\n",
 		     page, snapc);
-		if (!clear_page_dirty_for_io(page))
+		if (!clear_page_dirty_for_io(page, WB_SYNC_ALL))
 			goto retry_locked;
 		r = writepage_nounlock(page, NULL);
 		if (r < 0)
diff --git a/fs/cifs/cifssmb.c b/fs/cifs/cifssmb.c
index d352da325de3..0f8ddc80a4db 100644
--- a/fs/cifs/cifssmb.c
+++ b/fs/cifs/cifssmb.c
@@ -1999,7 +1999,8 @@ cifs_writev_requeue(struct cifs_writedata *wdata)
 		for (j = 0; j < nr_pages; j++) {
 			wdata2->pages[j] = wdata->pages[i + j];
 			lock_page(wdata2->pages[j]);
-			clear_page_dirty_for_io(wdata2->pages[j]);
+			clear_page_dirty_for_io(wdata2->pages[j],
+						wdata->sync_mode);
 		}
 
 		wdata2->sync_mode = wdata->sync_mode;
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 8d41ca7bfcf1..488061185b95 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -2019,7 +2019,8 @@ wdata_prepare_pages(struct cifs_writedata *wdata, unsigned int found_pages,
 			wait_on_page_writeback(page);
 
 		if (PageWriteback(page) ||
-				!clear_page_dirty_for_io(page)) {
+				!clear_page_dirty_for_io(page,
+							 wbc->sync_mode)) {
 			unlock_page(page);
 			break;
 		}
@@ -4089,7 +4090,7 @@ static int cifs_launder_page(struct page *page)
 
 	cifs_dbg(FYI, "Launder page: %p\n", page);
 
-	if (clear_page_dirty_for_io(page))
+	if (clear_page_dirty_for_io(page, wbc.sync_mode))
 		rc = cifs_writepage_locked(page, &wbc);
 
 	cifs_fscache_invalidate_page(page, page->mapping->host);
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 2ea07efbe016..78f77d31c8ad 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1741,7 +1741,8 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 			BUG_ON(PageWriteback(page));
 			if (invalidate) {
 				if (page_mapped(page))
-					clear_page_dirty_for_io(page);
+					clear_page_dirty_for_io(page,
+								WB_SYNC_ALL);
 				block_invalidatepage(page, 0, PAGE_SIZE);
 				ClearPageUptodate(page);
 			}
@@ -2187,7 +2188,7 @@ static int mpage_submit_page(struct mpage_da_data *mpd, struct page *page)
 	int err;
 
 	BUG_ON(page->index != mpd->first_page);
-	clear_page_dirty_for_io(page);
+	clear_page_dirty_for_io(page, WB_SYNC_ALL);
 	/*
 	 * We have to be very careful here!  Nothing protects writeback path
 	 * against i_size changes and the page can be writeably mapped into
diff --git a/fs/f2fs/checkpoint.c b/fs/f2fs/checkpoint.c
index 9f1c96caebda..e1dcc848207b 100644
--- a/fs/f2fs/checkpoint.c
+++ b/fs/f2fs/checkpoint.c
@@ -354,7 +354,7 @@ long f2fs_sync_meta_pages(struct f2fs_sb_info *sbi, enum page_type type,
 			f2fs_wait_on_page_writeback(page, META, true);
 
 			BUG_ON(PageWriteback(page));
-			if (!clear_page_dirty_for_io(page))
+			if (!clear_page_dirty_for_io(page, wbc.sync_mode))
 				goto continue_unlock;
 
 			if (__f2fs_write_meta_page(page, &wbc, io_type)) {
@@ -1197,7 +1197,7 @@ static void commit_checkpoint(struct f2fs_sb_info *sbi,
 
 	f2fs_wait_on_page_writeback(page, META, true);
 	f2fs_bug_on(sbi, PageWriteback(page));
-	if (unlikely(!clear_page_dirty_for_io(page)))
+	if (unlikely(!clear_page_dirty_for_io(page, wbc->sync_mode)))
 		f2fs_bug_on(sbi, 1);
 
 	/* writeout cp pack 2 page */
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 8f931d699287..a03eac98cfe3 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -2018,7 +2018,7 @@ static int f2fs_write_cache_pages(struct address_space *mapping,
 			}
 
 			BUG_ON(PageWriteback(page));
-			if (!clear_page_dirty_for_io(page))
+			if (!clear_page_dirty_for_io(page), wbc->sync_mode)
 				goto continue_unlock;
 
 			ret = __write_data_page(page, &submitted, wbc, io_type);
diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
index 7f955c4e86a4..258f9dc117f4 100644
--- a/fs/f2fs/dir.c
+++ b/fs/f2fs/dir.c
@@ -731,7 +731,7 @@ void f2fs_delete_entry(struct f2fs_dir_entry *dentry, struct page *page,
 	if (bit_pos == NR_DENTRY_IN_BLOCK &&
 		!f2fs_truncate_hole(dir, page->index, page->index + 1)) {
 		f2fs_clear_radix_tree_dirty_tag(page);
-		clear_page_dirty_for_io(page);
+		clear_page_dirty_for_io(page, WB_SYNC_ALL);
 		ClearPagePrivate(page);
 		ClearPageUptodate(page);
 		inode_dec_dirty_pages(dir);
diff --git a/fs/f2fs/gc.c b/fs/f2fs/gc.c
index 9093be6e7a7d..a6eb7ecf6f0b 100644
--- a/fs/f2fs/gc.c
+++ b/fs/f2fs/gc.c
@@ -693,7 +693,7 @@ static void move_data_block(struct inode *inode, block_t bidx,
 
 	set_page_dirty(fio.encrypted_page);
 	f2fs_wait_on_page_writeback(fio.encrypted_page, DATA, true);
-	if (clear_page_dirty_for_io(fio.encrypted_page))
+	if (clear_page_dirty_for_io(fio.encrypted_page, fio.io_wbc->sync_mode))
 		dec_page_count(fio.sbi, F2FS_DIRTY_META);
 
 	set_page_writeback(fio.encrypted_page);
@@ -780,7 +780,7 @@ static void move_data_page(struct inode *inode, block_t bidx, int gc_type,
 retry:
 		set_page_dirty(page);
 		f2fs_wait_on_page_writeback(page, DATA, true);
-		if (clear_page_dirty_for_io(page)) {
+		if (clear_page_dirty_for_io(page, fio.io_wbc->sync_mode)) {
 			inode_dec_dirty_pages(inode);
 			f2fs_remove_dirty_inode(inode);
 		}
diff --git a/fs/f2fs/inline.c b/fs/f2fs/inline.c
index 043830be5662..97dbc721e985 100644
--- a/fs/f2fs/inline.c
+++ b/fs/f2fs/inline.c
@@ -136,7 +136,7 @@ int f2fs_convert_inline_page(struct dnode_of_data *dn, struct page *page)
 	set_page_dirty(page);
 
 	/* clear dirty state */
-	dirty = clear_page_dirty_for_io(page);
+	dirty = clear_page_dirty_for_io(page, fio.io_wbc->sync_mode);
 
 	/* write data page to try to make data consistent */
 	set_page_writeback(page);
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index 10643b11bd59..9401f70d3f9f 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -104,7 +104,7 @@ static void clear_node_page_dirty(struct page *page)
 {
 	if (PageDirty(page)) {
 		f2fs_clear_radix_tree_dirty_tag(page);
-		clear_page_dirty_for_io(page);
+		clear_page_dirty_for_io(page, WB_SYNC_ALL);
 		dec_page_count(F2FS_P_SB(page), F2FS_DIRTY_NODES);
 	}
 	ClearPageUptodate(page);
@@ -1276,7 +1276,7 @@ static void flush_inline_data(struct f2fs_sb_info *sbi, nid_t ino)
 	if (!PageDirty(page))
 		goto page_out;
 
-	if (!clear_page_dirty_for_io(page))
+	if (!clear_page_dirty_for_io(page, WB_SYNC_ALL))
 		goto page_out;
 
 	ret = f2fs_write_inline_data(inode, page);
@@ -1444,7 +1444,7 @@ void f2fs_move_node_page(struct page *node_page, int gc_type)
 		f2fs_wait_on_page_writeback(node_page, NODE, true);
 
 		f2fs_bug_on(F2FS_P_SB(node_page), PageWriteback(node_page));
-		if (!clear_page_dirty_for_io(node_page))
+		if (!clear_page_dirty_for_io(node_page, wbc.sync_mode))
 			goto out_page;
 
 		if (__write_node_page(node_page, false, NULL,
@@ -1544,7 +1544,7 @@ int f2fs_fsync_node_pages(struct f2fs_sb_info *sbi, struct inode *inode,
 					set_page_dirty(page);
 			}
 
-			if (!clear_page_dirty_for_io(page))
+			if (!clear_page_dirty_for_io(page, WB_SYNC_ALL))
 				goto continue_unlock;
 
 			ret = __write_node_page(page, atomic &&
@@ -1658,7 +1658,7 @@ int f2fs_sync_node_pages(struct f2fs_sb_info *sbi,
 			f2fs_wait_on_page_writeback(page, NODE, true);
 
 			BUG_ON(PageWriteback(page));
-			if (!clear_page_dirty_for_io(page))
+			if (!clear_page_dirty_for_io(page, wbc->sync_mode))
 				goto continue_unlock;
 
 			set_fsync_mark(page, 0);
diff --git a/fs/f2fs/segment.c b/fs/f2fs/segment.c
index 9efce174c51a..947a16c1836f 100644
--- a/fs/f2fs/segment.c
+++ b/fs/f2fs/segment.c
@@ -382,7 +382,8 @@ static int __f2fs_commit_inmem_pages(struct inode *inode)
 
 			set_page_dirty(page);
 			f2fs_wait_on_page_writeback(page, DATA, true);
-			if (clear_page_dirty_for_io(page)) {
+			if (clear_page_dirty_for_io(page,
+						    fio.io_wbc->sync_mode)) {
 				inode_dec_dirty_pages(inode);
 				f2fs_remove_dirty_inode(inode);
 			}
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index a201fb0ac64f..a7837d909894 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -2015,7 +2015,7 @@ static int fuse_write_end(struct file *file, struct address_space *mapping,
 static int fuse_launder_page(struct page *page)
 {
 	int err = 0;
-	if (clear_page_dirty_for_io(page)) {
+	if (clear_page_dirty_for_io(page, WB_SYNC_NONE)) {
 		struct inode *inode = page->mapping->host;
 		err = fuse_writepage_locked(page);
 		if (!err)
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index 35f5ee23566d..43d8baabaa13 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -304,7 +304,7 @@ static int gfs2_write_jdata_pagevec(struct address_space *mapping,
 		}
 
 		BUG_ON(PageWriteback(page));
-		if (!clear_page_dirty_for_io(page))
+		if (!clear_page_dirty_for_io(page, wbc->sync_mode))
 			goto continue_unlock;
 
 		trace_wbc_writepage(wbc, inode_to_bdi(inode));
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index a057b4f45a46..0535ee5c1b88 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -2037,7 +2037,7 @@ int nfs_wb_page(struct inode *inode, struct page *page)
 
 	for (;;) {
 		wait_on_page_writeback(page);
-		if (clear_page_dirty_for_io(page)) {
+		if (clear_page_dirty_for_io(page, wbc.sync_mode)) {
 			ret = nfs_writepage_locked(page, &wbc);
 			if (ret < 0)
 				goto out_error;
diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
index 4cb850a6f1c2..f38805177248 100644
--- a/fs/nilfs2/page.c
+++ b/fs/nilfs2/page.c
@@ -480,7 +480,7 @@ int __nilfs_clear_page_dirty(struct page *page)
 					     page_index(page),
 					     PAGECACHE_TAG_DIRTY);
 			xa_unlock_irq(&mapping->i_pages);
-			return clear_page_dirty_for_io(page);
+			return clear_page_dirty_for_io(page, WB_SYNC_ALL);
 		}
 		xa_unlock_irq(&mapping->i_pages);
 		return 0;
diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
index 0953635e7d48..b237378cbc81 100644
--- a/fs/nilfs2/segment.c
+++ b/fs/nilfs2/segment.c
@@ -1644,7 +1644,7 @@ static void nilfs_begin_page_io(struct page *page)
 		return;
 
 	lock_page(page);
-	clear_page_dirty_for_io(page);
+	clear_page_dirty_for_io(page, WB_SYNC_ALL);
 	set_page_writeback(page);
 	unlock_page(page);
 }
@@ -1662,7 +1662,8 @@ static void nilfs_segctor_prepare_write(struct nilfs_sc_info *sci)
 			if (bh->b_page != bd_page) {
 				if (bd_page) {
 					lock_page(bd_page);
-					clear_page_dirty_for_io(bd_page);
+					clear_page_dirty_for_io(bd_page,
+								WB_SYNC_ALL);
 					set_page_writeback(bd_page);
 					unlock_page(bd_page);
 				}
@@ -1676,7 +1677,8 @@ static void nilfs_segctor_prepare_write(struct nilfs_sc_info *sci)
 			if (bh == segbuf->sb_super_root) {
 				if (bh->b_page != bd_page) {
 					lock_page(bd_page);
-					clear_page_dirty_for_io(bd_page);
+					clear_page_dirty_for_io(bd_page,
+								WB_SYNC_ALL);
 					set_page_writeback(bd_page);
 					unlock_page(bd_page);
 					bd_page = bh->b_page;
@@ -1691,7 +1693,7 @@ static void nilfs_segctor_prepare_write(struct nilfs_sc_info *sci)
 	}
 	if (bd_page) {
 		lock_page(bd_page);
-		clear_page_dirty_for_io(bd_page);
+		clear_page_dirty_for_io(bd_page, WB_SYNC_ALL);
 		set_page_writeback(bd_page);
 		unlock_page(bd_page);
 	}
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index fd7eb6fe9090..80804e13a05f 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1169,7 +1169,7 @@ static int do_truncation(struct ubifs_info *c, struct inode *inode,
 				 */
 				ubifs_assert(PagePrivate(page));
 
-				clear_page_dirty_for_io(page);
+				clear_page_dirty_for_io(page, WB_SYNC_ALL);
 				if (UBIFS_BLOCKS_PER_PAGE_SHIFT)
 					offset = new_size &
 						 (PAGE_SIZE - 1);
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 8eb3ba3d4d00..2d61e7c92287 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -496,7 +496,7 @@ xfs_start_page_writeback(
 	 * write this page in this writeback sweep will be made.
 	 */
 	if (clear_dirty) {
-		clear_page_dirty_for_io(page);
+		clear_page_dirty_for_io(page, WB_SYNC_ALL);
 		set_page_writeback(page);
 	} else
 		set_page_writeback_keepwrite(page);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a0fbb9ffe380..3094500f5cff 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1532,7 +1532,12 @@ static inline void cancel_dirty_page(struct page *page)
 	if (PageDirty(page))
 		__cancel_dirty_page(page);
 }
-int clear_page_dirty_for_io(struct page *page);
+
+/* The sync_mode argument expects enum writeback_sync_modes (see
+ * include/linux/writeback.h), but is declared as an int here, to avoid
+ * even more header file dependencies in mm.h.
+ */
+int clear_page_dirty_for_io(struct page *page, int sync_mode);
 
 int get_cmdline(struct task_struct *task, char *buffer, int buflen);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 8c0af0f7cab1..703c9ee86309 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -849,7 +849,7 @@ static int writeout(struct address_space *mapping, struct page *page)
 		/* No write method for the address space */
 		return -EINVAL;
 
-	if (!clear_page_dirty_for_io(page))
+	if (!clear_page_dirty_for_io(page, wbc.sync_mode))
 		/* Someone else already triggered a write */
 		return -EAGAIN;
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 337c6afb3345..e526b3cbf900 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2233,7 +2233,7 @@ int write_cache_pages(struct address_space *mapping,
 			}
 
 			BUG_ON(PageWriteback(page));
-			if (!clear_page_dirty_for_io(page))
+			if (!clear_page_dirty_for_io(page, wbc->sync_mode))
 				goto continue_unlock;
 
 			trace_wbc_writepage(wbc, inode_to_bdi(mapping->host));
@@ -2371,7 +2371,7 @@ int write_one_page(struct page *page)
 
 	wait_on_page_writeback(page);
 
-	if (clear_page_dirty_for_io(page)) {
+	if (clear_page_dirty_for_io(page, wbc.sync_mode)) {
 		get_page(page);
 		ret = mapping->a_ops->writepage(page, &wbc);
 		if (ret == 0)
@@ -2643,8 +2643,13 @@ EXPORT_SYMBOL(__cancel_dirty_page);
  *
  * This incoherency between the page's dirty flag and radix-tree tag is
  * unfortunate, but it only exists while the page is locked.
+ *
+ * The sync_mode argument expects enum writeback_sync_modes (see
+ * include/linux/writeback.h), but is declared as an int here, to avoid
+ * even more header file dependencies in mm.h.
  */
-int clear_page_dirty_for_io(struct page *page)
+
+int clear_page_dirty_for_io(struct page *page, int sync_mode)
 {
 	struct address_space *mapping = page_mapping(page);
 	int ret = 0;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 03822f86f288..16c305a8d476 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -668,7 +668,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	if (!may_write_to_inode(mapping->host, sc))
 		return PAGE_KEEP;
 
-	if (clear_page_dirty_for_io(page)) {
+	if (clear_page_dirty_for_io(page, WB_SYNC_ALL)) {
 		int res;
 		struct writeback_control wbc = {
 			.sync_mode = WB_SYNC_NONE,
-- 
2.18.0
