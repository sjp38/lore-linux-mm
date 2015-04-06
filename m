Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 276A76B0107
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:18:37 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so31418214qkg.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:18:37 -0700 (PDT)
Received: from mail-qk0-x234.google.com (mail-qk0-x234.google.com. [2607:f8b0:400d:c09::234])
        by mx.google.com with ESMTPS id y137si4333979qky.77.2015.04.06.13.18.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:18:36 -0700 (PDT)
Received: by qku63 with SMTP id 63so31313520qku.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:18:35 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 02/10] writeback: make writeback_control track the inode being written back
Date: Mon,  6 Apr 2015 16:18:20 -0400
Message-Id: <1428351508-8399-3-git-send-email-tj@kernel.org>
In-Reply-To: <1428351508-8399-1-git-send-email-tj@kernel.org>
References: <1428351508-8399-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

Currently, for cgroup writeback, the IO submission paths directly
associate the bio's with the blkcg from inode_to_wb_blkcg_css();
however, it'd be necessary to keep more writeback context to implement
foreign inode writeback detection.  wbc (writeback_control) is the
natural fit for the extra context - it persists throughout the
writeback of each inode and is passed all the way down to IO
submission paths.

This patch adds wbc_attach_and_unlock_inode(), wbc_detach_inode(), and
wbc_attach_fdatawrite_inode() which are used to associate wbc with the
inode being written back.  IO submission paths now use wbc_init_bio()
instead of directly associating bio's with blkcg themselves.  This
leaves inode_to_wb_blkcg_css() w/o any user.  The function is removed.

wbc currently only tracks the associated wb (bdi_writeback).  Future
patches will add more for foreign inode detection.  The association is
established under i_lock which will be depended upon when migrating
foreign inodes to other wb's.

As currently, once established, inode to wb association never changes,
going through wbc when initializing bio's doesn't cause any behavior
changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 fs/buffer.c                 | 24 ++++++++----------
 fs/fs-writeback.c           | 37 +++++++++++++++++++++++++--
 fs/mpage.c                  |  2 +-
 include/linux/backing-dev.h | 12 ---------
 include/linux/writeback.h   | 61 +++++++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c                |  2 ++
 6 files changed, 110 insertions(+), 28 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index f2d594c..cb2c7ec 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -45,9 +45,9 @@
 #include <trace/events/block.h>
 
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
-static int submit_bh_blkcg(int rw, struct buffer_head *bh,
-			   unsigned long bio_flags,
-			   struct cgroup_subsys_state *blkcg_css);
+static int submit_bh_wbc(int rw, struct buffer_head *bh,
+			 unsigned long bio_flags,
+			 struct writeback_control *wbc);
 
 #define BH_ENTRY(list) list_entry((list), struct buffer_head, b_assoc_buffers)
 
@@ -1709,7 +1709,6 @@ static int __block_write_full_page(struct inode *inode, struct page *page,
 	unsigned int blocksize, bbits;
 	int nr_underway = 0;
 	int write_op = (wbc->sync_mode == WB_SYNC_ALL ? WRITE_SYNC : WRITE);
-	struct cgroup_subsys_state *blkcg_css = inode_to_wb_blkcg_css(inode);
 
 	head = create_page_buffers(page, inode,
 					(1 << BH_Dirty)|(1 << BH_Uptodate));
@@ -1798,7 +1797,7 @@ static int __block_write_full_page(struct inode *inode, struct page *page,
 	do {
 		struct buffer_head *next = bh->b_this_page;
 		if (buffer_async_write(bh)) {
-			submit_bh_blkcg(write_op, bh, 0, blkcg_css);
+			submit_bh_wbc(write_op, bh, 0, wbc);
 			nr_underway++;
 		}
 		bh = next;
@@ -1852,7 +1851,7 @@ recover:
 		struct buffer_head *next = bh->b_this_page;
 		if (buffer_async_write(bh)) {
 			clear_buffer_dirty(bh);
-			submit_bh_blkcg(write_op, bh, 0, blkcg_css);
+			submit_bh_wbc(write_op, bh, 0, wbc);
 			nr_underway++;
 		}
 		bh = next;
@@ -3021,9 +3020,8 @@ void guard_bio_eod(int rw, struct bio *bio)
 	}
 }
 
-static int submit_bh_blkcg(int rw, struct buffer_head *bh,
-			   unsigned long bio_flags,
-			   struct cgroup_subsys_state *blkcg_css)
+static int submit_bh_wbc(int rw, struct buffer_head *bh,
+			 unsigned long bio_flags, struct writeback_control *wbc)
 {
 	struct bio *bio;
 	int ret = 0;
@@ -3046,8 +3044,8 @@ static int submit_bh_blkcg(int rw, struct buffer_head *bh,
 	 */
 	bio = bio_alloc(GFP_NOIO, 1);
 
-	if (blkcg_css)
-		bio_associate_blkcg(bio, blkcg_css);
+	if (wbc)
+		wbc_init_bio(wbc, bio);
 
 	bio->bi_iter.bi_sector = bh->b_blocknr * (bh->b_size >> 9);
 	bio->bi_bdev = bh->b_bdev;
@@ -3082,13 +3080,13 @@ static int submit_bh_blkcg(int rw, struct buffer_head *bh,
 
 int _submit_bh(int rw, struct buffer_head *bh, unsigned long bio_flags)
 {
-	return submit_bh_blkcg(rw, bh, bio_flags, NULL);
+	return submit_bh_wbc(rw, bh, bio_flags, NULL);
 }
 EXPORT_SYMBOL_GPL(_submit_bh);
 
 int submit_bh(int rw, struct buffer_head *bh)
 {
-	return submit_bh_blkcg(rw, bh, 0, NULL);
+	return submit_bh_wbc(rw, bh, 0, NULL);
 }
 EXPORT_SYMBOL(submit_bh);
 
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index d4da5e47..a0f7b16 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -232,6 +232,37 @@ void __inode_attach_wb(struct inode *inode, struct page *page)
 }
 
 /**
+ * wbc_attach_and_unlock_inode - associate wbc with target inode and unlock it
+ * @wbc: writeback_control of interest
+ * @inode: target inode
+ *
+ * @inode is locked and about to be written back under the control of @wbc.
+ * Record @inode's writeback context into @wbc and unlock the i_lock.  On
+ * writeback completion, wbc_detach_inode() should be called.  This is used
+ * to track the cgroup writeback context.
+ */
+void wbc_attach_and_unlock_inode(struct writeback_control *wbc,
+				 struct inode *inode)
+{
+	wbc->wb = inode_to_wb(inode);
+	wb_get(wbc->wb);
+	spin_unlock(&inode->i_lock);
+}
+
+/**
+ * wbc_detach_inode - disassociate wbc from its target inode
+ * @wbc: writeback_control of interest
+ *
+ * To be called after a writeback attempt of an inode finishes and undoes
+ * wbc_attach_and_unlock_inode().  Can be called under any context.
+ */
+void wbc_detach_inode(struct writeback_control *wbc)
+{
+	wb_put(wbc->wb);
+	wbc->wb = NULL;
+}
+
+/**
  * inode_congested - test whether an inode is congested
  * @inode: inode to test for congestion
  * @cong_bits: mask of WB_[a]sync_congested bits to test
@@ -858,10 +889,11 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 	     !mapping_tagged(inode->i_mapping, PAGECACHE_TAG_WRITEBACK)))
 		goto out;
 	inode->i_state |= I_SYNC;
-	spin_unlock(&inode->i_lock);
+	wbc_attach_and_unlock_inode(wbc, inode);
 
 	ret = __writeback_single_inode(inode, wbc);
 
+	wbc_detach_inode(wbc);
 	spin_lock(&wb->list_lock);
 	spin_lock(&inode->i_lock);
 	/*
@@ -994,7 +1026,7 @@ static long writeback_sb_inodes(struct super_block *sb,
 			continue;
 		}
 		inode->i_state |= I_SYNC;
-		spin_unlock(&inode->i_lock);
+		wbc_attach_and_unlock_inode(&wbc, inode);
 
 		write_chunk = writeback_chunk_size(wb, work);
 		wbc.nr_to_write = write_chunk;
@@ -1006,6 +1038,7 @@ static long writeback_sb_inodes(struct super_block *sb,
 		 */
 		__writeback_single_inode(inode, &wbc);
 
+		wbc_detach_inode(&wbc);
 		work->nr_pages -= write_chunk - wbc.nr_to_write;
 		wrote += write_chunk - wbc.nr_to_write;
 		spin_lock(&wb->list_lock);
diff --git a/fs/mpage.c b/fs/mpage.c
index a3ccb0b..388fde6 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -606,7 +606,7 @@ alloc_new:
 		if (bio == NULL)
 			goto confused;
 
-		bio_associate_blkcg(bio, inode_to_wb_blkcg_css(inode));
+		wbc_init_bio(wbc, bio);
 	}
 
 	/*
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 5c978a9..b1d2489 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -332,12 +332,6 @@ static inline struct bdi_writeback *inode_to_wb(struct inode *inode)
 	return inode->i_wb;
 }
 
-static inline struct cgroup_subsys_state *
-inode_to_wb_blkcg_css(struct inode *inode)
-{
-	return inode_to_wb(inode)->blkcg_css;
-}
-
 struct wb_iter {
 	int			start_blkcg_id;
 	struct radix_tree_iter	tree_iter;
@@ -434,12 +428,6 @@ static inline void wb_blkcg_offline(struct blkcg *blkcg)
 {
 }
 
-static inline struct cgroup_subsys_state *
-inode_to_wb_blkcg_css(struct inode *inode)
-{
-	return blkcg_root_css;
-}
-
 struct wb_iter {
 	int		next_id;
 };
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index f836e55..3593266 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -86,6 +86,9 @@ struct writeback_control {
 	unsigned for_reclaim:1;		/* Invoked from the page allocator */
 	unsigned range_cyclic:1;	/* range_start is cyclic */
 	unsigned for_sync:1;		/* sync(2) WB_SYNC_ALL writeback */
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct bdi_writeback *wb;	/* wb this writeback is issued under */
+#endif
 };
 
 /*
@@ -176,7 +179,14 @@ static inline void wait_on_inode(struct inode *inode)
 
 #ifdef CONFIG_CGROUP_WRITEBACK
 
+#include <linux/cgroup.h>
+#include <linux/bio.h>
+
 void __inode_attach_wb(struct inode *inode, struct page *page);
+void wbc_attach_and_unlock_inode(struct writeback_control *wbc,
+				 struct inode *inode)
+	__releases(&inode->i_lock);
+void wbc_detach_inode(struct writeback_control *wbc);
 
 /**
  * inode_attach_wb - associate an inode with its wb
@@ -207,6 +217,37 @@ static inline void inode_detach_wb(struct inode *inode)
 	}
 }
 
+/**
+ * wbc_attach_fdatawrite_inode - associate wbc and inode for fdatawrite
+ * @wbc: writeback_control of interest
+ * @inode: target inode
+ *
+ * This function is to be used by __filemap_fdatawrite_range(), which is an
+ * alternative entry point into writeback code, and first ensures @inode is
+ * associated with a bdi_writeback and attaches it to @wbc.
+ */
+static inline void wbc_attach_fdatawrite_inode(struct writeback_control *wbc,
+					       struct inode *inode)
+{
+	spin_lock(&inode->i_lock);
+	inode_attach_wb(inode, NULL);
+	wbc_attach_and_unlock_inode(wbc, inode);
+}
+
+/**
+ * wbc_init_bio - writeback specific initializtion of bio
+ * @wbc: writeback_control for the writeback in progress
+ * @bio: bio to be initialized
+ *
+ * @bio is a part of the writeback in progress controlled by @wbc.  Perform
+ * writeback specific initialization.  This is used to apply the cgroup
+ * writeback context.
+ */
+static inline void wbc_init_bio(struct writeback_control *wbc, struct bio *bio)
+{
+	bio_associate_blkcg(bio, wbc->wb->blkcg_css);
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static inline void inode_attach_wb(struct inode *inode, struct page *page)
@@ -217,6 +258,26 @@ static inline void inode_detach_wb(struct inode *inode)
 {
 }
 
+static inline void wbc_attach_and_unlock_inode(struct writeback_control *wbc,
+					       struct inode *inode)
+	__releases(&inode->i_lock)
+{
+	spin_unlock(&inode->i_lock);
+}
+
+static inline void wbc_attach_fdatawrite_inode(struct writeback_control *wbc,
+					       struct inode *inode)
+{
+}
+
+static inline void wbc_detach_inode(struct writeback_control *wbc)
+{
+}
+
+static inline void wbc_init_bio(struct writeback_control *wbc, struct bio *bio)
+{
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index 64698fa..2b9f142 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -293,7 +293,9 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
 	if (!mapping_cap_writeback_dirty(mapping))
 		return 0;
 
+	wbc_attach_fdatawrite_inode(&wbc, mapping->host);
 	ret = do_writepages(mapping, &wbc);
+	wbc_detach_inode(&wbc);
 	return ret;
 }
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
