Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 333A86B025E
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 13:35:26 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id pp5so220159582pac.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 10:35:26 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id al5si26832847pad.16.2016.08.22.10.35.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 10:35:25 -0700 (PDT)
From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 3/3] writeback: introduce super_operations->write_metadata
Date: Mon, 22 Aug 2016 13:35:02 -0400
Message-ID: <1471887302-12730-4-git-send-email-jbacik@fb.com>
In-Reply-To: <1471887302-12730-1-git-send-email-jbacik@fb.com>
References: <1471887302-12730-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org

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
 fs/super.c                       |  7 +++++
 include/linux/backing-dev-defs.h |  2 ++
 include/linux/fs.h               |  4 +++
 mm/backing-dev.c                 |  1 +
 5 files changed, 69 insertions(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index d329f89..b7d8946 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1615,11 +1615,36 @@ static long writeback_sb_inodes(struct super_block *sb,
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
@@ -1639,11 +1664,38 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
 
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
index c2ff475..c1b1028 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -215,6 +215,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	spin_lock_init(&s->s_inode_list_lock);
 	INIT_LIST_HEAD(&s->s_inodes_wb);
 	spin_lock_init(&s->s_inode_wblist_lock);
+	INIT_LIST_HEAD(&s->s_bdi_list);
 
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
+		list_del_init(&s->s_bdi_list);
+		spin_unlock(&bdi->sb_list_lock);
+
 		put_filesystem(fs);
 		put_super(s);
 	} else {
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 1200aae..ee6f27f 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -167,6 +167,8 @@ struct backing_dev_info {
 
 	struct timer_list laptop_mode_wb_timer;
 
+	spinlock_t sb_list_lock;
+	struct list_head dirty_sb_list;
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *debug_dir;
 	struct dentry *debug_stats;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f3f0b4c8..c063ac6 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1430,6 +1430,8 @@ struct super_block {
 
 	spinlock_t		s_inode_wblist_lock;
 	struct list_head	s_inodes_wb;	/* writeback inodes */
+
+	struct list_head	s_bdi_list;
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
index b48d4e4..80ba94a 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -782,6 +782,7 @@ int bdi_init(struct backing_dev_info *bdi)
 	bdi->max_prop_frac = FPROP_FRAC_BASE;
 	INIT_LIST_HEAD(&bdi->bdi_list);
 	INIT_LIST_HEAD(&bdi->wb_list);
+	INIT_LIST_HEAD(&bdi->dirty_sb_list);
 	init_waitqueue_head(&bdi->wb_waitq);
 
 	ret = cgwb_bdi_init(bdi);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
