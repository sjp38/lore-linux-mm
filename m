Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E9DF06B0253
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 16:58:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c84so59046203pfj.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 13:58:19 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q68si71710636pfq.104.2016.09.20.13.58.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 13:58:19 -0700 (PDT)
From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 4/4] writeback: introduce super_operations->write_metadata
Date: Tue, 20 Sep 2016 16:57:48 -0400
Message-ID: <1474405068-27841-5-git-send-email-jbacik@fb.com>
In-Reply-To: <1474405068-27841-1-git-send-email-jbacik@fb.com>
References: <1474405068-27841-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org, hannes@cmpxchg.org

Now that we have metadata counters in the VM, we need to provide a way to kick
writeback on dirty metadata.  Introduce super_operations->write_metadata.  This
allows file systems to deal with writing back any dirty metadata we need based
on the writeback needs of the system.  Since there is no inode to key off of we
need a list in the bdi for dirty super blocks to be added.  From there we can
find any dirty sb's on the bdi we are currently doing writeback on and call into
their ->write_metadata callback.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 fs/fs-writeback.c                | 72 ++++++++++++++++++++++++++++++++++++----
 fs/super.c                       |  7 ++++
 include/linux/backing-dev-defs.h |  2 ++
 include/linux/fs.h               |  4 +++
 mm/backing-dev.c                 |  2 ++
 5 files changed, 81 insertions(+), 6 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index aafdb11..8cd072e 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1464,6 +1464,31 @@ static long writeback_chunk_size(struct bdi_writeback *wb,
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
@@ -1490,6 +1515,7 @@ static long writeback_sb_inodes(struct super_block *sb,
 	unsigned long start_time = jiffies;
 	long write_chunk;
 	long wrote = 0;  /* count both pages and inodes */
+	bool done = false;
 
 	while (!list_empty(&wb->b_io)) {
 		struct inode *inode = wb_inode(wb->b_io.prev);
@@ -1606,12 +1632,18 @@ static long writeback_sb_inodes(struct super_block *sb,
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
+		spin_unlock(&wb->list_lock);
+	}
 	return wrote;
 }
 
@@ -1620,6 +1652,7 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
 {
 	unsigned long start_time = jiffies;
 	long wrote = 0;
+	bool done = false;
 
 	while (!list_empty(&wb->b_io)) {
 		struct inode *inode = wb_inode(wb->b_io.prev);
@@ -1639,12 +1672,39 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
 
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
index c2ff475..eb32913 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -215,6 +215,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	spin_lock_init(&s->s_inode_list_lock);
 	INIT_LIST_HEAD(&s->s_inodes_wb);
 	spin_lock_init(&s->s_inode_wblist_lock);
+	INIT_LIST_HEAD(&s->s_bdi_dirty_list);
 
 	if (list_lru_init_memcg(&s->s_dentry_lru))
 		goto fail;
@@ -305,6 +306,8 @@ void deactivate_locked_super(struct super_block *s)
 {
 	struct file_system_type *fs = s->s_type;
 	if (atomic_dec_and_test(&s->s_active)) {
+		struct backing_dev_info *bdi = s->s_bdi;
+
 		cleancache_invalidate_fs(s);
 		unregister_shrinker(&s->s_shrink);
 		fs->kill_sb(s);
@@ -317,6 +320,10 @@ void deactivate_locked_super(struct super_block *s)
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
index cef0f24..11cea63 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -168,6 +168,8 @@ struct backing_dev_info {
 
 	struct timer_list laptop_mode_wb_timer;
 
+	spinlock_t sb_list_lock;
+	struct list_head dirty_sb_list;
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *debug_dir;
 	struct dentry *debug_stats;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f3f0b4c8..f521187 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1430,6 +1430,8 @@ struct super_block {
 
 	spinlock_t		s_inode_wblist_lock;
 	struct list_head	s_inodes_wb;	/* writeback inodes */
+
+	struct list_head	s_bdi_dirty_list;
 };
 
 /* Helper functions so that in most cases filesystems will
@@ -1805,6 +1807,8 @@ struct super_operations {
 				  struct shrink_control *);
 	long (*free_cached_objects)(struct super_block *,
 				    struct shrink_control *);
+	void (*write_metadata)(struct super_block *sb,
+			       struct writeback_control *wbc);
 };
 
 /*
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index f0695b0..541f532 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -785,6 +785,8 @@ int bdi_init(struct backing_dev_info *bdi)
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
