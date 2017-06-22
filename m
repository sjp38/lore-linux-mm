Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D4CC36B0314
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:23:36 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f49so5041321wrf.5
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:23:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 65si1398919wmp.150.2017.06.22.07.23.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Jun 2017 07:23:35 -0700 (PDT)
From: Nikolay Borisov <nborisov@suse.com>
Subject: [PATCH 4/4] writeback: introduce super_operations->write_metadata
Date: Thu, 22 Jun 2017 17:23:24 +0300
Message-Id: <1498141404-18807-5-git-send-email-nborisov@suse.com>
In-Reply-To: <1498141404-18807-1-git-send-email-nborisov@suse.com>
References: <1498141404-18807-1-git-send-email-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: jbacik@fb.com, jack@suse.cz, jeffm@suse.com, chandan@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, axboe@kernel.dk, Nikolay Borisov <nborisov@suse.com>

From: Josef Bacik <jbacik@fb.com>

Now that we have metadata counters in the VM, we need to provide a way to kick
writeback on dirty metadata.  Introduce super_operations->write_metadata.  This
allows file systems to deal with writing back any dirty metadata we need based
on the writeback needs of the system.  Since there is no inode to key off of we
need a list in the bdi for dirty super blocks to be added.  From there we can
find any dirty sb's on the bdi we are currently doing writeback on and call into
their ->write_metadata callback.

Signed-off-by: Josef Bacik <jbacik@fb.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Nikolay Borisov <nborisov@suse.com>
---

Changes since previous posting [1] :

 - Forward ported to 4.12-rc6 kernel

 I've retained the review-by tags since I didn't introduce any changes. 

[1] https://patchwork.kernel.org/patch/9395213/
 fs/fs-writeback.c                | 72 ++++++++++++++++++++++++++++++++++++----
 fs/super.c                       |  7 ++++
 include/linux/backing-dev-defs.h |  2 ++
 include/linux/fs.h               |  4 +++
 mm/backing-dev.c                 |  2 ++
 5 files changed, 81 insertions(+), 6 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index c7b33d124f3d..9fa2b6cfaf5b 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1479,6 +1479,31 @@ static long writeback_chunk_size(struct bdi_writeback *wb,
 	return pages;
 }
 
+static long writeback_sb_metadata(struct super_block *sb,
+				  struct bdi_writeback *wb,
+				  struct wb_writeback_work *work)
+{
+	struct writeback_control wbc = {
+		.sync_mode		= work->sync_mode,
+		.tagged_writepages	= work->tagged_writepages,
+		.for_kupdate		= work->for_kupdate,
+		.for_background		= work->for_background,
+		.for_sync		= work->for_sync,
+		.range_cyclic		= work->range_cyclic,
+		.range_start		= 0,
+		.range_end		= LLONG_MAX,
+	};
+	long write_chunk;
+
+	write_chunk = writeback_chunk_size(wb, work);
+	wbc.nr_to_write = write_chunk;
+	sb->s_op->write_metadata(sb, &wbc);
+	work->nr_pages -= write_chunk - wbc.nr_to_write;
+
+	return write_chunk - wbc.nr_to_write;
+}
+
+
 /*
  * Write a portion of b_io inodes which belong to @sb.
  *
@@ -1505,6 +1530,7 @@ static long writeback_sb_inodes(struct super_block *sb,
 	unsigned long start_time = jiffies;
 	long write_chunk;
 	long wrote = 0;  /* count both pages and inodes */
+	bool done = false;
 
 	while (!list_empty(&wb->b_io)) {
 		struct inode *inode = wb_inode(wb->b_io.prev);
@@ -1621,12 +1647,18 @@ static long writeback_sb_inodes(struct super_block *sb,
 		 * background threshold and other termination conditions.
 		 */
 		if (wrote) {
-			if (time_is_before_jiffies(start_time + HZ / 10UL))
-				break;
-			if (work->nr_pages <= 0)
+			if (time_is_before_jiffies(start_time + HZ / 10UL) ||
+			    work->nr_pages <= 0) {
+				done = true;
 				break;
+			}
 		}
 	}
+	if (!done && sb->s_op->write_metadata) {
+		spin_unlock(&wb->list_lock);
+		wrote += writeback_sb_metadata(sb, wb, work);
+		spin_lock(&wb->list_lock);
+	}
 	return wrote;
 }
 
@@ -1635,6 +1667,7 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
 {
 	unsigned long start_time = jiffies;
 	long wrote = 0;
+	bool done = false;
 
 	while (!list_empty(&wb->b_io)) {
 		struct inode *inode = wb_inode(wb->b_io.prev);
@@ -1654,12 +1687,39 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
 
 		/* refer to the same tests at the end of writeback_sb_inodes */
 		if (wrote) {
-			if (time_is_before_jiffies(start_time + HZ / 10UL))
-				break;
-			if (work->nr_pages <= 0)
+			if (time_is_before_jiffies(start_time + HZ / 10UL) ||
+			    work->nr_pages <= 0) {
+				done = true;
 				break;
+			}
 		}
 	}
+
+	if (!done && wb_stat(wb, WB_METADATA_DIRTY_BYTES)) {
+		LIST_HEAD(list);
+
+		spin_unlock(&wb->list_lock);
+		spin_lock(&wb->bdi->sb_list_lock);
+		list_splice_init(&wb->bdi->dirty_sb_list, &list);
+		while (!list_empty(&list)) {
+			struct super_block *sb;
+
+			sb = list_first_entry(&list, struct super_block,
+					      s_bdi_dirty_list);
+			list_move_tail(&sb->s_bdi_dirty_list,
+				       &wb->bdi->dirty_sb_list);
+			if (!sb->s_op->write_metadata)
+				continue;
+			if (!trylock_super(sb))
+				continue;
+			spin_unlock(&wb->bdi->sb_list_lock);
+			wrote += writeback_sb_metadata(sb, wb, work);
+			spin_lock(&wb->bdi->sb_list_lock);
+			up_read(&sb->s_umount);
+		}
+		spin_unlock(&wb->bdi->sb_list_lock);
+		spin_lock(&wb->list_lock);
+	}
 	/* Leave any unwritten inodes on b_io */
 	return wrote;
 }
diff --git a/fs/super.c b/fs/super.c
index adb0c0de428c..fa5c664bcdfb 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -215,6 +215,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	spin_lock_init(&s->s_inode_list_lock);
 	INIT_LIST_HEAD(&s->s_inodes_wb);
 	spin_lock_init(&s->s_inode_wblist_lock);
+	INIT_LIST_HEAD(&s->s_bdi_dirty_list);
 
 	if (list_lru_init_memcg(&s->s_dentry_lru))
 		goto fail;
@@ -304,6 +305,8 @@ void deactivate_locked_super(struct super_block *s)
 {
 	struct file_system_type *fs = s->s_type;
 	if (atomic_dec_and_test(&s->s_active)) {
+		struct backing_dev_info *bdi = s->s_bdi;
+
 		cleancache_invalidate_fs(s);
 		unregister_shrinker(&s->s_shrink);
 		fs->kill_sb(s);
@@ -316,6 +319,10 @@ void deactivate_locked_super(struct super_block *s)
 		list_lru_destroy(&s->s_dentry_lru);
 		list_lru_destroy(&s->s_inode_lru);
 
+		spin_lock(&bdi->sb_list_lock);
+		list_del_init(&s->s_bdi_dirty_list);
+		spin_unlock(&bdi->sb_list_lock);
+
 		put_filesystem(fs);
 		put_super(s);
 	} else {
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 78c65e2910dc..a961f9a51a38 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -176,6 +176,8 @@ struct backing_dev_info {
 
 	struct timer_list laptop_mode_wb_timer;
 
+	spinlock_t sb_list_lock;
+	struct list_head dirty_sb_list;
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *debug_dir;
 	struct dentry *debug_stats;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 803e5a9b2654..2dda6afdf894 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1404,6 +1404,8 @@ struct super_block {
 
 	spinlock_t		s_inode_wblist_lock;
 	struct list_head	s_inodes_wb;	/* writeback inodes */
+
+	struct list_head	s_bdi_dirty_list;
 };
 
 /* Helper functions so that in most cases filesystems will
@@ -1803,6 +1805,8 @@ struct super_operations {
 				  struct shrink_control *);
 	long (*free_cached_objects)(struct super_block *,
 				    struct shrink_control *);
+	void (*write_metadata)(struct super_block *sb,
+			       struct writeback_control *wbc);
 };
 
 /*
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index b4fbe1c015ae..cc24583141c8 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -833,6 +833,8 @@ static int bdi_init(struct backing_dev_info *bdi)
 	bdi->max_prop_frac = FPROP_FRAC_BASE;
 	INIT_LIST_HEAD(&bdi->bdi_list);
 	INIT_LIST_HEAD(&bdi->wb_list);
+	INIT_LIST_HEAD(&bdi->dirty_sb_list);
+	spin_lock_init(&bdi->sb_list_lock);
 	init_waitqueue_head(&bdi->wb_waitq);
 
 	ret = cgwb_bdi_init(bdi);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
