Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4306B0253
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 07:16:27 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id s64so93710168lfs.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 04:16:27 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id h131si14785884wma.47.2016.09.12.04.16.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 04:16:25 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id z194so762898wmd.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 04:16:25 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] fs: use mapping_set_error instead of opencoded set_bit
Date: Mon, 12 Sep 2016 13:16:07 +0200
Message-Id: <20160912111608.2588-2-mhocko@kernel.org>
In-Reply-To: <20160912111608.2588-1-mhocko@kernel.org>
References: <20160901091347.GC12147@dhcp22.suse.cz>
 <20160912111608.2588-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

mapping_set_error helper sets the correct AS_ flag for the mapping so
there is no reason to open code it. Use the helper directly.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/staging/lustre/lustre/llite/vvp_page.c | 5 +----
 fs/afs/write.c                                 | 5 ++---
 fs/buffer.c                                    | 4 ++--
 fs/exofs/inode.c                               | 2 +-
 fs/ext4/page-io.c                              | 2 +-
 fs/f2fs/data.c                                 | 2 +-
 fs/jbd2/commit.c                               | 3 +--
 7 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 6cd2af7a958f..96194b6f118e 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -247,10 +247,7 @@ static void vvp_vmpage_error(struct inode *inode, struct page *vmpage, int ioret
 		obj->vob_discard_page_warned = 0;
 	} else {
 		SetPageError(vmpage);
-		if (ioret == -ENOSPC)
-			set_bit(AS_ENOSPC, &inode->i_mapping->flags);
-		else
-			set_bit(AS_EIO, &inode->i_mapping->flags);
+		mapping_set_error(inode->i_mapping, ioret);
 
 		if ((ioret == -ESHUTDOWN || ioret == -EINTR) &&
 		     obj->vob_discard_page_warned == 0) {
diff --git a/fs/afs/write.c b/fs/afs/write.c
index 14d506efd1aa..20ed04ab833c 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -398,8 +398,7 @@ static int afs_write_back_from_locked_page(struct afs_writeback *wb,
 		switch (ret) {
 		case -EDQUOT:
 		case -ENOSPC:
-			set_bit(AS_ENOSPC,
-				&wb->vnode->vfs_inode.i_mapping->flags);
+			mapping_set_error(wb->vnode->vfs_inode.i_mapping, -ENOSPC);
 			break;
 		case -EROFS:
 		case -EIO:
@@ -409,7 +408,7 @@ static int afs_write_back_from_locked_page(struct afs_writeback *wb,
 		case -ENOMEDIUM:
 		case -ENXIO:
 			afs_kill_pages(wb->vnode, true, first, last);
-			set_bit(AS_EIO, &wb->vnode->vfs_inode.i_mapping->flags);
+			mapping_set_error(wb->vnode->vfs_inode.i_mapping, -ENXIO);
 			break;
 		case -EACCES:
 		case -EPERM:
diff --git a/fs/buffer.c b/fs/buffer.c
index 754813a6962b..467e1ac3fac6 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -350,7 +350,7 @@ void end_buffer_async_write(struct buffer_head *bh, int uptodate)
 		set_buffer_uptodate(bh);
 	} else {
 		buffer_io_error(bh, ", lost async page write");
-		set_bit(AS_EIO, &page->mapping->flags);
+		mapping_set_error(page->mapping, -EIO);
 		set_buffer_write_io_error(bh);
 		clear_buffer_uptodate(bh);
 		SetPageError(page);
@@ -3180,7 +3180,7 @@ drop_buffers(struct page *page, struct buffer_head **buffers_to_free)
 	bh = head;
 	do {
 		if (buffer_write_io_error(bh) && page->mapping)
-			set_bit(AS_EIO, &page->mapping->flags);
+			mapping_set_error(page->mapping, -EIO);
 		if (buffer_busy(bh))
 			goto failed;
 		bh = bh->b_this_page;
diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 9dc4c6dbf3c9..a405db82e060 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -778,7 +778,7 @@ static int writepage_strip(struct page *page,
 fail:
 	EXOFS_DBGMSG("Error: writepage_strip(0x%lx, 0x%lx)=>%d\n",
 		     inode->i_ino, page->index, ret);
-	set_bit(AS_EIO, &page->mapping->flags);
+	mapping_set_error(page->mapping, -EIO);
 	unlock_page(page);
 	return ret;
 }
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index 2a01df9cc1c3..8073d63e37a7 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -89,7 +89,7 @@ static void ext4_finish_bio(struct bio *bio)
 
 		if (bio->bi_error) {
 			SetPageError(page);
-			set_bit(AS_EIO, &page->mapping->flags);
+			mapping_set_error(page->mapping, -EIO);
 		}
 		bh = head = page_buffers(page);
 		/*
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index c80dda4bdff8..b728d284778e 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -67,7 +67,7 @@ static void f2fs_write_end_io(struct bio *bio)
 		fscrypt_pullback_bio_page(&page, true);
 
 		if (unlikely(bio->bi_error)) {
-			set_bit(AS_EIO, &page->mapping->flags);
+			mapping_set_error(page->mapping, -EIO);
 			f2fs_stop_checkpoint(sbi, true);
 		}
 		end_page_writeback(page);
diff --git a/fs/jbd2/commit.c b/fs/jbd2/commit.c
index 70078096117d..f3d5746f2446 100644
--- a/fs/jbd2/commit.c
+++ b/fs/jbd2/commit.c
@@ -269,8 +269,7 @@ static int journal_finish_inode_data_buffers(journal_t *journal,
 			 * filemap_fdatawait_range(), set it again so
 			 * that user process can get -EIO from fsync().
 			 */
-			set_bit(AS_EIO,
-				&jinode->i_vfs_inode->i_mapping->flags);
+			mapping_set_error(jinode->i_vfs_inode->i_mapping, -EIO);
 
 			if (!ret)
 				ret = err;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
