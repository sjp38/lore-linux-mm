Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id EF1C26B0074
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 12:46:44 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id x12so3942987wgg.11
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 09:46:44 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id s6si5693889wix.57.2015.01.08.09.46.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 09:46:33 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 07/12] fs: export inode_to_bdi and use it in favor of mapping->backing_dev_info
Date: Thu,  8 Jan 2015 18:45:28 +0100
Message-Id: <1420739133-27514-8-git-send-email-hch@lst.de>
In-Reply-To: <1420739133-27514-1-git-send-email-hch@lst.de>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

Now that we got ri of the bdi abuse on character devices we can always use
sb->s_bdi to get at the backing_dev_info for a file, except for the block
device special case.  Export inode_to_bdi and replace uses of
mapping->backing_dev_info with it to prepare for the removal of
mapping->backing_dev_info.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/btrfs/file.c                  |  2 +-
 fs/ceph/file.c                   |  2 +-
 fs/ext2/ialloc.c                 |  2 +-
 fs/ext4/super.c                  |  2 +-
 fs/fs-writeback.c                |  3 ++-
 fs/fuse/file.c                   | 10 +++++-----
 fs/gfs2/aops.c                   |  2 +-
 fs/gfs2/super.c                  |  2 +-
 fs/nfs/filelayout/filelayout.c   |  2 +-
 fs/nfs/write.c                   |  6 +++---
 fs/ntfs/file.c                   |  3 ++-
 fs/ocfs2/file.c                  |  2 +-
 fs/xfs/xfs_file.c                |  2 +-
 include/linux/backing-dev.h      |  6 ++++--
 include/trace/events/writeback.h |  6 +++---
 mm/fadvise.c                     |  4 ++--
 mm/filemap.c                     |  4 ++--
 mm/filemap_xip.c                 |  3 ++-
 mm/page-writeback.c              | 29 +++++++++++++----------------
 mm/readahead.c                   |  4 ++--
 mm/truncate.c                    |  2 +-
 mm/vmscan.c                      |  4 ++--
 22 files changed, 52 insertions(+), 50 deletions(-)

diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index e409025..835c04a 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1746,7 +1746,7 @@ static ssize_t btrfs_file_write_iter(struct kiocb *iocb,
 
 	mutex_lock(&inode->i_mutex);
 
-	current->backing_dev_info = inode->i_mapping->backing_dev_info;
+	current->backing_dev_info = inode_to_bdi(inode);
 	err = generic_write_checks(file, &pos, &count, S_ISBLK(inode->i_mode));
 	if (err) {
 		mutex_unlock(&inode->i_mutex);
diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index ce74b39..905986d 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -945,7 +945,7 @@ static ssize_t ceph_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	mutex_lock(&inode->i_mutex);
 
 	/* We can write back this queue in page reclaim */
-	current->backing_dev_info = file->f_mapping->backing_dev_info;
+	current->backing_dev_info = inode_to_bdi(inode);
 
 	err = generic_write_checks(file, &pos, &count, S_ISBLK(inode->i_mode));
 	if (err)
diff --git a/fs/ext2/ialloc.c b/fs/ext2/ialloc.c
index 7d66fb0..6c14bb8 100644
--- a/fs/ext2/ialloc.c
+++ b/fs/ext2/ialloc.c
@@ -170,7 +170,7 @@ static void ext2_preread_inode(struct inode *inode)
 	struct ext2_group_desc * gdp;
 	struct backing_dev_info *bdi;
 
-	bdi = inode->i_mapping->backing_dev_info;
+	bdi = inode_to_bdi(inode);
 	if (bdi_read_congested(bdi))
 		return;
 	if (bdi_write_congested(bdi))
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 74c5f53..ad88e60 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -334,7 +334,7 @@ static void save_error_info(struct super_block *sb, const char *func,
 static int block_device_ejected(struct super_block *sb)
 {
 	struct inode *bd_inode = sb->s_bdev->bd_inode;
-	struct backing_dev_info *bdi = bd_inode->i_mapping->backing_dev_info;
+	struct backing_dev_info *bdi = inode_to_bdi(bd_inode);
 
 	return bdi->dev == NULL;
 }
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index e8116a4..a20b114 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -66,7 +66,7 @@ int writeback_in_progress(struct backing_dev_info *bdi)
 }
 EXPORT_SYMBOL(writeback_in_progress);
 
-static inline struct backing_dev_info *inode_to_bdi(struct inode *inode)
+struct backing_dev_info *inode_to_bdi(struct inode *inode)
 {
 	struct super_block *sb = inode->i_sb;
 #ifdef CONFIG_BLOCK
@@ -75,6 +75,7 @@ static inline struct backing_dev_info *inode_to_bdi(struct inode *inode)
 #endif
 	return sb->s_bdi;
 }
+EXPORT_SYMBOL_GPL(inode_to_bdi);
 
 static inline struct inode *wb_inode(struct list_head *head)
 {
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 760b2c5..19d80b8 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1159,7 +1159,7 @@ static ssize_t fuse_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	mutex_lock(&inode->i_mutex);
 
 	/* We can write back this queue in page reclaim */
-	current->backing_dev_info = mapping->backing_dev_info;
+	current->backing_dev_info = inode_to_bdi(inode);
 
 	err = generic_write_checks(file, &pos, &count, S_ISBLK(inode->i_mode));
 	if (err)
@@ -1464,7 +1464,7 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
 {
 	struct inode *inode = req->inode;
 	struct fuse_inode *fi = get_fuse_inode(inode);
-	struct backing_dev_info *bdi = inode->i_mapping->backing_dev_info;
+	struct backing_dev_info *bdi = inode_to_bdi(inode);
 	int i;
 
 	list_del(&req->writepages_entry);
@@ -1658,7 +1658,7 @@ static int fuse_writepage_locked(struct page *page)
 	req->end = fuse_writepage_end;
 	req->inode = inode;
 
-	inc_bdi_stat(mapping->backing_dev_info, BDI_WRITEBACK);
+	inc_bdi_stat(inode_to_bdi(inode), BDI_WRITEBACK);
 	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
 
 	spin_lock(&fc->lock);
@@ -1768,7 +1768,7 @@ static bool fuse_writepage_in_flight(struct fuse_req *new_req,
 
 	if (old_req->num_pages == 1 && (old_req->state == FUSE_REQ_INIT ||
 					old_req->state == FUSE_REQ_PENDING)) {
-		struct backing_dev_info *bdi = page->mapping->backing_dev_info;
+		struct backing_dev_info *bdi = inode_to_bdi(page->mapping->host);
 
 		copy_highpage(old_req->pages[0], page);
 		spin_unlock(&fc->lock);
@@ -1872,7 +1872,7 @@ static int fuse_writepages_fill(struct page *page,
 	req->page_descs[req->num_pages].offset = 0;
 	req->page_descs[req->num_pages].length = PAGE_SIZE;
 
-	inc_bdi_stat(page->mapping->backing_dev_info, BDI_WRITEBACK);
+	inc_bdi_stat(inode_to_bdi(inode), BDI_WRITEBACK);
 	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
 
 	err = 0;
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index 805b37f..4ad4f94 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -289,7 +289,7 @@ continue_unlock:
 		if (!clear_page_dirty_for_io(page))
 			goto continue_unlock;
 
-		trace_wbc_writepage(wbc, mapping->backing_dev_info);
+		trace_wbc_writepage(wbc, inode_to_bdi(inode));
 
 		ret = __gfs2_jdata_writepage(page, wbc);
 		if (unlikely(ret)) {
diff --git a/fs/gfs2/super.c b/fs/gfs2/super.c
index 5b327f8..1666382 100644
--- a/fs/gfs2/super.c
+++ b/fs/gfs2/super.c
@@ -743,7 +743,7 @@ static int gfs2_write_inode(struct inode *inode, struct writeback_control *wbc)
 	struct gfs2_inode *ip = GFS2_I(inode);
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
 	struct address_space *metamapping = gfs2_glock2aspace(ip->i_gl);
-	struct backing_dev_info *bdi = metamapping->backing_dev_info;
+	struct backing_dev_info *bdi = inode_to_bdi(metamapping->host);
 	int ret = 0;
 
 	if (wbc->sync_mode == WB_SYNC_ALL)
diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 7afb52f..51aa889 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -1081,7 +1081,7 @@ mds_commit:
 	spin_unlock(cinfo->lock);
 	if (!cinfo->dreq) {
 		inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		inc_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
+		inc_bdi_stat(inode_to_bdi(page_file_mapping(req->wb_page)->host),
 			     BDI_RECLAIMABLE);
 		__mark_inode_dirty(req->wb_context->dentry->d_inode,
 				   I_DIRTY_DATASYNC);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index af3af68..298abcc 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -786,7 +786,7 @@ nfs_request_add_commit_list(struct nfs_page *req, struct list_head *dst,
 	spin_unlock(cinfo->lock);
 	if (!cinfo->dreq) {
 		inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		inc_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
+		inc_bdi_stat(inode_to_bdi(page_file_mapping(req->wb_page)->host),
 			     BDI_RECLAIMABLE);
 		__mark_inode_dirty(req->wb_context->dentry->d_inode,
 				   I_DIRTY_DATASYNC);
@@ -853,7 +853,7 @@ static void
 nfs_clear_page_commit(struct page *page)
 {
 	dec_zone_page_state(page, NR_UNSTABLE_NFS);
-	dec_bdi_stat(page_file_mapping(page)->backing_dev_info, BDI_RECLAIMABLE);
+	dec_bdi_stat(inode_to_bdi(page_file_mapping(page)->host), BDI_RECLAIMABLE);
 }
 
 /* Called holding inode (/cinfo) lock */
@@ -1564,7 +1564,7 @@ void nfs_retry_commit(struct list_head *page_list,
 		nfs_mark_request_commit(req, lseg, cinfo);
 		if (!cinfo->dreq) {
 			dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-			dec_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
+			dec_bdi_stat(inode_to_bdi(page_file_mapping(req->wb_page)->host),
 				     BDI_RECLAIMABLE);
 		}
 		nfs_unlock_and_release_request(req);
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index 643faa4..5aaf11c 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -19,6 +19,7 @@
  * Foundation,Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include <linux/backing-dev.h>
 #include <linux/buffer_head.h>
 #include <linux/gfp.h>
 #include <linux/pagemap.h>
@@ -2091,7 +2092,7 @@ static ssize_t ntfs_file_aio_write_nolock(struct kiocb *iocb,
 	count = iov_length(iov, nr_segs);
 	pos = *ppos;
 	/* We can write back this queue in page reclaim. */
-	current->backing_dev_info = mapping->backing_dev_info;
+	current->backing_dev_info = inode_to_bdi(inode); 
 	written = 0;
 	err = generic_write_checks(file, &pos, &count, S_ISBLK(inode->i_mode));
 	if (err)
diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 3950693..abe7d98 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -2363,7 +2363,7 @@ relock:
 			goto out_dio;
 		}
 	} else {
-		current->backing_dev_info = file->f_mapping->backing_dev_info;
+		current->backing_dev_info = inode_to_bdi(inode);
 		written = generic_perform_write(file, from, *ppos);
 		if (likely(written >= 0))
 			iocb->ki_pos = *ppos + written;
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 13e974e..5684ac3 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -699,7 +699,7 @@ xfs_file_buffered_aio_write(
 
 	iov_iter_truncate(from, count);
 	/* We can write back this queue in page reclaim */
-	current->backing_dev_info = mapping->backing_dev_info;
+	current->backing_dev_info = inode_to_bdi(inode);
 
 write_retry:
 	trace_xfs_file_buffered_write(ip, count, iocb->ki_pos, 0);
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 478f95d..ed59dee 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -106,6 +106,8 @@ struct backing_dev_info {
 #endif
 };
 
+struct backing_dev_info *inode_to_bdi(struct inode *inode);
+
 int __must_check bdi_init(struct backing_dev_info *bdi);
 void bdi_destroy(struct backing_dev_info *bdi);
 
@@ -303,12 +305,12 @@ static inline bool bdi_cap_account_writeback(struct backing_dev_info *bdi)
 
 static inline bool mapping_cap_writeback_dirty(struct address_space *mapping)
 {
-	return bdi_cap_writeback_dirty(mapping->backing_dev_info);
+	return bdi_cap_writeback_dirty(inode_to_bdi(mapping->host));
 }
 
 static inline bool mapping_cap_account_dirty(struct address_space *mapping)
 {
-	return bdi_cap_account_dirty(mapping->backing_dev_info);
+	return bdi_cap_account_dirty(inode_to_bdi(mapping->host));
 }
 
 static inline int bdi_sched_wait(void *word)
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index cee02d6..74f5207 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -47,7 +47,7 @@ TRACE_EVENT(writeback_dirty_page,
 
 	TP_fast_assign(
 		strncpy(__entry->name,
-			mapping ? dev_name(mapping->backing_dev_info->dev) : "(unknown)", 32);
+			mapping ? dev_name(inode_to_bdi(mapping->host)->dev) : "(unknown)", 32);
 		__entry->ino = mapping ? mapping->host->i_ino : 0;
 		__entry->index = page->index;
 	),
@@ -72,7 +72,7 @@ DECLARE_EVENT_CLASS(writeback_dirty_inode_template,
 	),
 
 	TP_fast_assign(
-		struct backing_dev_info *bdi = inode->i_mapping->backing_dev_info;
+		struct backing_dev_info *bdi = inode_to_bdi(inode);
 
 		/* may be called for files on pseudo FSes w/ unregistered bdi */
 		strncpy(__entry->name,
@@ -116,7 +116,7 @@ DECLARE_EVENT_CLASS(writeback_write_inode_template,
 
 	TP_fast_assign(
 		strncpy(__entry->name,
-			dev_name(inode->i_mapping->backing_dev_info->dev), 32);
+			dev_name(inode_to_bdi(inode)->dev), 32);
 		__entry->ino		= inode->i_ino;
 		__entry->sync_mode	= wbc->sync_mode;
 	),
diff --git a/mm/fadvise.c b/mm/fadvise.c
index 2ad7adf..fac23ec 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -73,7 +73,7 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 	else
 		endbyte--;		/* inclusive */
 
-	bdi = mapping->backing_dev_info;
+	bdi = inode_to_bdi(mapping->host);
 
 	switch (advice) {
 	case POSIX_FADV_NORMAL:
@@ -113,7 +113,7 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 	case POSIX_FADV_NOREUSE:
 		break;
 	case POSIX_FADV_DONTNEED:
-		if (!bdi_write_congested(mapping->backing_dev_info))
+		if (!bdi_write_congested(bdi))
 			__filemap_fdatawrite_range(mapping, offset, endbyte,
 						   WB_SYNC_NONE);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 673e458..5d7c23c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -211,7 +211,7 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	 */
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
 		dec_zone_page_state(page, NR_FILE_DIRTY);
-		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+		dec_bdi_stat(inode_to_bdi(mapping->host), BDI_RECLAIMABLE);
 	}
 }
 
@@ -2565,7 +2565,7 @@ ssize_t __generic_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	size_t		count = iov_iter_count(from);
 
 	/* We can write back this queue in page reclaim */
-	current->backing_dev_info = mapping->backing_dev_info;
+	current->backing_dev_info = inode_to_bdi(inode);
 	err = generic_write_checks(file, &pos, &count, S_ISBLK(inode->i_mode));
 	if (err)
 		goto out;
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 0d105ae..26897fb 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/fs.h>
+#include <linux/backing-dev.h>
 #include <linux/pagemap.h>
 #include <linux/export.h>
 #include <linux/uio.h>
@@ -410,7 +411,7 @@ xip_file_write(struct file *filp, const char __user *buf, size_t len,
 	count = len;
 
 	/* We can write back this queue in page reclaim */
-	current->backing_dev_info = mapping->backing_dev_info;
+	current->backing_dev_info = inode_to_bdi(inode);
 
 	ret = generic_write_checks(filp, &pos, &count, S_ISBLK(inode->i_mode));
 	if (ret)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index d5d81f5..562d62e 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1351,7 +1351,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 	unsigned long task_ratelimit;
 	unsigned long dirty_ratelimit;
 	unsigned long pos_ratio;
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
 	bool strictlimit = bdi->capabilities & BDI_CAP_STRICTLIMIT;
 	unsigned long start_time = jiffies;
 
@@ -1584,7 +1584,7 @@ DEFINE_PER_CPU(int, dirty_throttle_leaks) = 0;
  */
 void balance_dirty_pages_ratelimited(struct address_space *mapping)
 {
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
 	int ratelimit;
 	int *p;
 
@@ -1939,7 +1939,7 @@ continue_unlock:
 			if (!clear_page_dirty_for_io(page))
 				goto continue_unlock;
 
-			trace_wbc_writepage(wbc, mapping->backing_dev_info);
+			trace_wbc_writepage(wbc, inode_to_bdi(mapping->host));
 			ret = (*writepage)(page, wbc, data);
 			if (unlikely(ret)) {
 				if (ret == AOP_WRITEPAGE_ACTIVATE) {
@@ -2104,10 +2104,12 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 	trace_writeback_dirty_page(page, mapping);
 
 	if (mapping_cap_account_dirty(mapping)) {
+		struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
+
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_DIRTIED);
-		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
-		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTIED);
+		__inc_bdi_stat(bdi, BDI_RECLAIMABLE);
+		__inc_bdi_stat(bdi, BDI_DIRTIED);
 		task_io_account_write(PAGE_CACHE_SIZE);
 		current->nr_dirtied++;
 		this_cpu_inc(bdp_ratelimits);
@@ -2173,7 +2175,7 @@ void account_page_redirty(struct page *page)
 	if (mapping && mapping_cap_account_dirty(mapping)) {
 		current->nr_dirtied--;
 		dec_zone_page_state(page, NR_DIRTIED);
-		dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTIED);
+		dec_bdi_stat(inode_to_bdi(mapping->host), BDI_DIRTIED);
 	}
 }
 EXPORT_SYMBOL(account_page_redirty);
@@ -2314,7 +2316,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 */
 		if (TestClearPageDirty(page)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
-			dec_bdi_stat(mapping->backing_dev_info,
+			dec_bdi_stat(inode_to_bdi(mapping->host),
 					BDI_RECLAIMABLE);
 			return 1;
 		}
@@ -2334,7 +2336,7 @@ int test_clear_page_writeback(struct page *page)
 
 	memcg = mem_cgroup_begin_page_stat(page, &locked, &memcg_flags);
 	if (mapping) {
-		struct backing_dev_info *bdi = mapping->backing_dev_info;
+		struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
 		unsigned long flags;
 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
@@ -2371,7 +2373,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 
 	memcg = mem_cgroup_begin_page_stat(page, &locked, &memcg_flags);
 	if (mapping) {
-		struct backing_dev_info *bdi = mapping->backing_dev_info;
+		struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
 		unsigned long flags;
 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
@@ -2425,12 +2427,7 @@ EXPORT_SYMBOL(mapping_tagged);
  */
 void wait_for_stable_page(struct page *page)
 {
-	struct address_space *mapping = page_mapping(page);
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
-
-	if (!bdi_cap_stable_pages_required(bdi))
-		return;
-
-	wait_on_page_writeback(page);
+	if (bdi_cap_stable_pages_required(inode_to_bdi(page->mapping->host)))
+		wait_on_page_writeback(page);
 }
 EXPORT_SYMBOL_GPL(wait_for_stable_page);
diff --git a/mm/readahead.c b/mm/readahead.c
index 17b9172..9356758 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -27,7 +27,7 @@
 void
 file_ra_state_init(struct file_ra_state *ra, struct address_space *mapping)
 {
-	ra->ra_pages = mapping->backing_dev_info->ra_pages;
+	ra->ra_pages = inode_to_bdi(mapping->host)->ra_pages;
 	ra->prev_pos = -1;
 }
 EXPORT_SYMBOL_GPL(file_ra_state_init);
@@ -541,7 +541,7 @@ page_cache_async_readahead(struct address_space *mapping,
 	/*
 	 * Defer asynchronous read-ahead on IO congestion.
 	 */
-	if (bdi_read_congested(mapping->backing_dev_info))
+	if (bdi_read_congested(inode_to_bdi(mapping->host)))
 		return;
 
 	/* do read-ahead */
diff --git a/mm/truncate.c b/mm/truncate.c
index f1e4d60..ddec5a5 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -112,7 +112,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 		struct address_space *mapping = page->mapping;
 		if (mapping && mapping_cap_account_dirty(mapping)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
-			dec_bdi_stat(mapping->backing_dev_info,
+			dec_bdi_stat(inode_to_bdi(mapping->host),
 					BDI_RECLAIMABLE);
 			if (account_size)
 				task_io_account_cancelled_write(account_size);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index bd9a72b..94af0a6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -497,7 +497,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	}
 	if (mapping->a_ops->writepage == NULL)
 		return PAGE_ACTIVATE;
-	if (!may_write_to_queue(mapping->backing_dev_info, sc))
+	if (!may_write_to_queue(inode_to_bdi(mapping->host), sc))
 		return PAGE_KEEP;
 
 	if (clear_page_dirty_for_io(page)) {
@@ -876,7 +876,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		mapping = page_mapping(page);
 		if (((dirty || writeback) && mapping &&
-		     bdi_write_congested(mapping->backing_dev_info)) ||
+		     bdi_write_congested(inode_to_bdi(mapping->host))) ||
 		    (writeback && PageReclaim(page)))
 			nr_congested++;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
