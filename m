Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id CF3DB6B0128
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:26:34 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id w8so218044qac.5
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:34 -0800 (PST)
Received: from mail-qc0-x235.google.com (mail-qc0-x235.google.com. [2607:f8b0:400d:c01::235])
        by mx.google.com with ESMTPS id n13si56736243qab.15.2015.01.06.13.26.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:26:33 -0800 (PST)
Received: by mail-qc0-f181.google.com with SMTP id m20so55078qcx.40
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:33 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 02/45] writeback: add {CONFIG|BDI_CAP|FS}_CGROUP_WRITEBACK
Date: Tue,  6 Jan 2015 16:25:39 -0500
Message-Id: <1420579582-8516-3-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

cgroup writeback requires support from both bdi and filesystem sides.
Add BDI_CAP_CGROUP_WRITEBACK and FS_CGROUP_WRITEBACK to indicate
support and enable BDI_CAP_CGROUP_WRITEBACK on block based bdi's by
default.  Also, define CONFIG_CGROUP_WRITEBACK which is enabled if
both MEMCG and BLK_CGROUP are enabled.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 block/blk-core.c            |  3 ++-
 include/linux/backing-dev.h | 31 +++++++++++++++++++++++++++++++
 include/linux/fs.h          |  1 +
 init/Kconfig                |  5 +++++
 4 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 723e4a3..ff4d2f8 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -606,7 +606,8 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 
 	q->backing_dev_info.ra_pages =
 			(VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
-	q->backing_dev_info.capabilities = BDI_CAP_MAP_COPY;
+	q->backing_dev_info.capabilities = BDI_CAP_MAP_COPY |
+					   BDI_CAP_CGROUP_WRITEBACK;
 	q->backing_dev_info.name = "block";
 	q->node = node_id;
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 34fe620..68c2fd7 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -146,6 +146,8 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
  * BDI_CAP_SWAP_BACKED:    Count shmem/tmpfs objects as swap-backed.
  *
  * BDI_CAP_STRICTLIMIT:    Keep number of dirty pages below bdi threshold.
+ *
+ * BDI_CAP_CGROUP_WRITEBACK: Supports cgroup-aware writeback.
  */
 #define BDI_CAP_NO_ACCT_DIRTY	0x00000001
 #define BDI_CAP_NO_WRITEBACK	0x00000002
@@ -158,6 +160,7 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
 #define BDI_CAP_SWAP_BACKED	0x00000100
 #define BDI_CAP_STABLE_WRITES	0x00000200
 #define BDI_CAP_STRICTLIMIT	0x00000400
+#define BDI_CAP_CGROUP_WRITEBACK 0x00000800
 
 #define BDI_CAP_VMFLAGS \
 	(BDI_CAP_READ_MAP | BDI_CAP_WRITE_MAP | BDI_CAP_EXEC_MAP)
@@ -267,4 +270,32 @@ void init_dirty_page_context(struct dirty_context *dctx, struct page *page,
 			     struct address_space *mapping);
 void init_dirty_inode_context(struct dirty_context *dctx, struct inode *inode);
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+
+/**
+ * mapping_cgwb_enabled - test whether cgroup writeback is enabled on a mapping
+ * @mapping: address_space of interest
+ *
+ * cgroup writeback requires support from both the bdi and filesystem.
+ * Test whether @mapping has both.
+ */
+static inline bool mapping_cgwb_enabled(struct address_space *mapping)
+{
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	struct inode *inode = mapping->host;
+
+	return bdi_cap_account_dirty(bdi) &&
+		(bdi->capabilities & BDI_CAP_CGROUP_WRITEBACK) &&
+		inode && (inode->i_sb->s_type->fs_flags & FS_CGROUP_WRITEBACK);
+}
+
+#else	/* CONFIG_CGROUP_WRITEBACK */
+
+static inline bool mapping_cgwb_enabled(struct address_space *mapping)
+{
+	return false;
+}
+
+#endif	/* CONFIG_CGROUP_WRITEBACK */
+
 #endif		/* _LINUX_BACKING_DEV_H */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9b63758..2f3df6a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1818,6 +1818,7 @@ struct file_system_type {
 #define FS_HAS_SUBTYPE		4
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
 #define FS_USERNS_DEV_MOUNT	16 /* A userns mount does not imply MNT_NODEV */
+#define FS_CGROUP_WRITEBACK	32	/* Supports cgroup-aware writeback */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
 	struct dentry *(*mount) (struct file_system_type *, int,
 		       const char *, void *);
diff --git a/init/Kconfig b/init/Kconfig
index 005d239..3fb9a53 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1122,6 +1122,11 @@ config DEBUG_BLK_CGROUP
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
