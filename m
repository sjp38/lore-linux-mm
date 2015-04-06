Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id BCC7A6B00A3
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 15:59:42 -0400 (EDT)
Received: by qkhg7 with SMTP id g7so31018287qkh.2
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 12:59:42 -0700 (PDT)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id x2si1474845qcs.26.2015.04.06.12.59.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 12:59:29 -0700 (PDT)
Received: by qgfi89 with SMTP id i89so14936734qgf.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 12:59:28 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 21/49] writeback: add {CONFIG|BDI_CAP|FS}_CGROUP_WRITEBACK
Date: Mon,  6 Apr 2015 15:58:10 -0400
Message-Id: <1428350318-8215-22-git-send-email-tj@kernel.org>
In-Reply-To: <1428350318-8215-1-git-send-email-tj@kernel.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

cgroup writeback requires support from both bdi and filesystem sides.
Add BDI_CAP_CGROUP_WRITEBACK and FS_CGROUP_WRITEBACK to indicate
support and enable BDI_CAP_CGROUP_WRITEBACK on block based bdi's by
default.  Also, define CONFIG_CGROUP_WRITEBACK which is enabled if
both MEMCG and BLK_CGROUP are enabled.

inode_cgwb_enabled() which determines whether a given inode's both bdi
and fs support cgroup writeback is added.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 block/blk-core.c            |  2 +-
 include/linux/backing-dev.h | 32 +++++++++++++++++++++++++++++++-
 include/linux/fs.h          |  1 +
 init/Kconfig                |  5 +++++
 4 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index fa1314e..c44018a 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -606,7 +606,7 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 
 	q->backing_dev_info.ra_pages =
 			(VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
-	q->backing_dev_info.capabilities = 0;
+	q->backing_dev_info.capabilities = BDI_CAP_CGROUP_WRITEBACK;
 	q->backing_dev_info.name = "block";
 	q->node = node_id;
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index bfdaa18..6bb3123 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -134,12 +134,15 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
  * BDI_CAP_NO_WRITEBACK:   Don't write pages back
  * BDI_CAP_NO_ACCT_WB:     Don't automatically account writeback pages
  * BDI_CAP_STRICTLIMIT:    Keep number of dirty pages below bdi threshold.
+ *
+ * BDI_CAP_CGROUP_WRITEBACK: Supports cgroup-aware writeback.
  */
 #define BDI_CAP_NO_ACCT_DIRTY	0x00000001
 #define BDI_CAP_NO_WRITEBACK	0x00000002
 #define BDI_CAP_NO_ACCT_WB	0x00000004
 #define BDI_CAP_STABLE_WRITES	0x00000008
 #define BDI_CAP_STRICTLIMIT	0x00000010
+#define BDI_CAP_CGROUP_WRITEBACK 0x00000020
 
 #define BDI_CAP_NO_ACCT_AND_WRITEBACK \
 	(BDI_CAP_NO_WRITEBACK | BDI_CAP_NO_ACCT_DIRTY | BDI_CAP_NO_ACCT_WB)
@@ -229,4 +232,31 @@ static inline int bdi_sched_wait(void *word)
 	return 0;
 }
 
-#endif		/* _LINUX_BACKING_DEV_H */
+#ifdef CONFIG_CGROUP_WRITEBACK
+
+/**
+ * inode_cgwb_enabled - test whether cgroup writeback is enabled on an inode
+ * @inode: inode of interest
+ *
+ * cgroup writeback requires support from both the bdi and filesystem.
+ * Test whether @inode has both.
+ */
+static inline bool inode_cgwb_enabled(struct inode *inode)
+{
+	struct backing_dev_info *bdi = inode_to_bdi(inode);
+
+	return bdi_cap_account_dirty(bdi) &&
+		(bdi->capabilities & BDI_CAP_CGROUP_WRITEBACK) &&
+		(inode->i_sb->s_type->fs_flags & FS_CGROUP_WRITEBACK);
+}
+
+#else	/* CONFIG_CGROUP_WRITEBACK */
+
+static inline bool inode_cgwb_enabled(struct inode *inode)
+{
+	return false;
+}
+
+#endif	/* CONFIG_CGROUP_WRITEBACK */
+
+#endif	/* _LINUX_BACKING_DEV_H */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ccf4b64..bc72737 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1862,6 +1862,7 @@ struct file_system_type {
 #define FS_HAS_SUBTYPE		4
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
 #define FS_USERNS_DEV_MOUNT	16 /* A userns mount does not imply MNT_NODEV */
+#define FS_CGROUP_WRITEBACK	32	/* Supports cgroup-aware writeback */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
 	struct dentry *(*mount) (struct file_system_type *, int,
 		       const char *, void *);
diff --git a/init/Kconfig b/init/Kconfig
index f5dbc6d..9f17798 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1132,6 +1132,11 @@ config DEBUG_BLK_CGROUP
 	Enable some debugging help. Currently it exports additional stat
 	files in a cgroup which can be useful for debugging.
 
+config CGROUP_WRITEBACK
+	bool
+	depends on MEMCG && BLK_CGROUP
+	default y
+
 endif # CGROUPS
 
 config CHECKPOINT_RESTORE
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
