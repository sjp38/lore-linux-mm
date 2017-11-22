Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A13796B02E5
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:16:20 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id l74so9924526qke.10
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:16:20 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n185sor6666288qke.135.2017.11.22.13.16.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 13:16:19 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH v2 07/11] writeback: introduce super_operations->write_metadata
Date: Wed, 22 Nov 2017 16:16:02 -0500
Message-Id: <1511385366-20329-8-git-send-email-josef@toxicpanda.com>
In-Reply-To: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
References: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

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
---
 fs/fs-writeback.c                | 72 ++++++++++++++++++++++++++++++++++++----
 fs/super.c                       |  6 ++++
 include/linux/backing-dev-defs.h |  2 ++
 include/linux/fs.h               |  4 +++
 mm/backing-dev.c                 |  2 ++
 5 files changed, 80 insertions(+), 6 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 987448ed7698..fba703dff678 100644
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
index 166c4ee0d0ed..2290bef486a3 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -214,6 +214,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	spin_lock_init(&s->s_inode_list_lock);
 	INIT_LIST_HEAD(&s->s_inodes_wb);
 	spin_lock_init(&s->s_inode_wblist_lock);
+	INIT_LIST_HEAD(&s->s_bdi_dirty_list);
 
 	if (list_lru_init_memcg(&s->s_dentry_lru))
 		goto fail;
@@ -446,6 +447,11 @@ void generic_shutdown_super(struct super_block *sb)
 	spin_unlock(&sb_lock);
 	up_write(&sb->s_umount);
 	if (sb->s_bdi != &noop_backing_dev_info) {
+		if (!list_empty(&sb->s_bdi_dirty_list)) {
+			spin_lock(&sb->s_bdi->sb_list_lock);
+			list_del_init(&sb->s_bdi_dirty_list);
+			spin_unlock(&sb->s_bdi->sb_list_lock);
+		}
 		bdi_put(sb->s_bdi);
 		sb->s_bdi = &noop_backing_dev_info;
 	}
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
index 339e73742e73..298a28eaed2b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1440,6 +1440,8 @@ struct super_block {
 
 	spinlock_t		s_inode_wblist_lock;
 	struct list_head	s_inodes_wb;	/* writeback inodes */
+
+	struct list_head        s_bdi_dirty_list;
 } __randomize_layout;
 
 /* Helper functions so that in most cases filesystems will
@@ -1830,6 +1832,8 @@ struct super_operations {
 				  struct shrink_control *);
 	long (*free_cached_objects)(struct super_block *,
 				    struct shrink_control *);
+	void (*write_metadata)(struct super_block *sb,
+			       struct writeback_control *wbc);
 };
 
 /*
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 0aad67bc0898..e3aa4e0dd15e 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -839,6 +839,8 @@ static int bdi_init(struct backing_dev_info *bdi)
 	bdi->max_prop_frac = FPROP_FRAC_BASE;
 	INIT_LIST_HEAD(&bdi->bdi_list);
 	INIT_LIST_HEAD(&bdi->wb_list);
+	INIT_LIST_HEAD(&bdi->dirty_sb_list);
+	spin_lock_init(&bdi->sb_list_lock);
 	init_waitqueue_head(&bdi->wb_waitq);
 
 	ret = cgwb_bdi_init(bdi);
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
