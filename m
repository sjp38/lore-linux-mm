Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 874C0440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 14:31:07 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id l69so1173430qkl.6
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 11:31:07 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d15sor4757244qke.27.2017.11.09.11.31.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Nov 2017 11:31:06 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 3/6] writeback: introduce super_operations->write_metadata
Date: Thu,  9 Nov 2017 14:30:58 -0500
Message-Id: <1510255861-8020-3-git-send-email-josef@toxicpanda.com>
In-Reply-To: <1510255861-8020-1-git-send-email-josef@toxicpanda.com>
References: <1510255861-8020-1-git-send-email-josef@toxicpanda.com>
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
---
 fs/fs-writeback.c                | 58 +++++++++++++++++++++++++++++++++++++---
 fs/super.c                       |  6 +++++
 include/linux/backing-dev-defs.h |  2 ++
 include/linux/fs.h               |  4 +++
 mm/backing-dev.c                 |  2 ++
 5 files changed, 69 insertions(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index c5374a4fb982..0a8e225a4757 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1630,11 +1630,36 @@ static long writeback_sb_inodes(struct super_block *sb,
 	return wrote;
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
 static long __writeback_inodes_wb(struct bdi_writeback *wb,
 				  struct wb_writeback_work *work)
 {
 	unsigned long start_time = jiffies;
 	long wrote = 0;
+	bool done = false;
 
 	while (!list_empty(&wb->b_io)) {
 		struct inode *inode = wb_inode(wb->b_io.prev);
@@ -1654,11 +1679,38 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
 
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
+		}
+	}
+
+	if (!done && wb_stat(wb, WB_METADATA_DIRTY)) {
+		LIST_HEAD(list);
+
+		spin_unlock(&wb->list_lock);
+		spin_lock(&wb->bdi->sb_list_lock);
+		list_splice_init(&wb->bdi->dirty_sb_list, &list);
+		while (!list_empty(&list)) {
+			struct super_block *sb;
+
+			sb = list_first_entry(&list, struct super_block,
+					      s_bdi_list);
+			list_move_tail(&sb->s_bdi_list,
+				       &wb->bdi->dirty_sb_list);
+			if (!sb->s_op->write_metadata)
+				continue;
+			if (!trylock_super(sb))
+				continue;
+			spin_unlock(&wb->bdi->sb_list_lock);
+			wrote += writeback_sb_metadata(sb, wb, work);
+			spin_lock(&wb->bdi->sb_list_lock);
+			up_read(&sb->s_umount);
 		}
+		spin_unlock(&wb->bdi->sb_list_lock);
+		spin_lock(&wb->list_lock);
 	}
 	/* Leave any unwritten inodes on b_io */
 	return wrote;
diff --git a/fs/super.c b/fs/super.c
index 166c4ee0d0ed..66b369956c5e 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -214,6 +214,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	spin_lock_init(&s->s_inode_list_lock);
 	INIT_LIST_HEAD(&s->s_inodes_wb);
 	spin_lock_init(&s->s_inode_wblist_lock);
+	INIT_LIST_HEAD(&s->s_bdi_list);
 
 	if (list_lru_init_memcg(&s->s_dentry_lru))
 		goto fail;
@@ -446,6 +447,11 @@ void generic_shutdown_super(struct super_block *sb)
 	spin_unlock(&sb_lock);
 	up_write(&sb->s_umount);
 	if (sb->s_bdi != &noop_backing_dev_info) {
+		if (!list_empty(&sb->s_bdi_list)) {
+			spin_lock(&sb->s_bdi->sb_list_lock);
+			list_del_init(&sb->s_bdi_list);
+			spin_unlock(&sb->s_bdi->sb_list_lock);
+		}
 		bdi_put(sb->s_bdi);
 		sb->s_bdi = &noop_backing_dev_info;
 	}
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 013e764d4b30..e75623ab0278 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -175,6 +175,8 @@ struct backing_dev_info {
 
 	struct timer_list laptop_mode_wb_timer;
 
+	spinlock_t sb_list_lock;
+	struct list_head dirty_sb_list;
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *debug_dir;
 	struct dentry *debug_stats;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 339e73742e73..562c79b3dbe0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1440,6 +1440,8 @@ struct super_block {
 
 	spinlock_t		s_inode_wblist_lock;
 	struct list_head	s_inodes_wb;	/* writeback inodes */
+
+	struct list_head	s_bdi_list;
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
index 57f1dbc41f7e..99a352f943ea 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -834,8 +834,10 @@ static int bdi_init(struct backing_dev_info *bdi)
 	bdi->min_ratio = 0;
 	bdi->max_ratio = 100;
 	bdi->max_prop_frac = FPROP_FRAC_BASE;
+	spin_lock_init(&bdi->sb_list_lock);
 	INIT_LIST_HEAD(&bdi->bdi_list);
 	INIT_LIST_HEAD(&bdi->wb_list);
+	INIT_LIST_HEAD(&bdi->dirty_sb_list);
 	init_waitqueue_head(&bdi->wb_waitq);
 
 	ret = cgwb_bdi_init(bdi);
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
