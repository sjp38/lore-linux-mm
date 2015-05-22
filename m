Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5E21E829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:14:59 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so22206886qkg.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:14:59 -0700 (PDT)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com. [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id v107si3712691qge.44.2015.05.22.14.14.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:14:58 -0700 (PDT)
Received: by qgew3 with SMTP id w3so16202865qge.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:14:57 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 22/51] writeback: add {CONFIG|BDI_CAP|FS}_CGROUP_WRITEBACK
Date: Fri, 22 May 2015 17:13:36 -0400
Message-Id: <1432329245-5844-23-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

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
index f46688f..e0f726f 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -620,7 +620,7 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 
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
index ce100b87..74e0ae0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1897,6 +1897,7 @@ struct file_system_type {
 #define FS_HAS_SUBTYPE		4
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
 #define FS_USERNS_DEV_MOUNT	16 /* A userns mount does not imply MNT_NODEV */
+#define FS_CGROUP_WRITEBACK	32	/* Supports cgroup-aware writeback */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
 	struct dentry *(*mount) (struct file_system_type *, int,
 		       const char *, void *);
diff --git a/init/Kconfig b/init/Kconfig
index dc24dec..d4f7633 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1141,6 +1141,11 @@ config DEBUG_BLK_CGROUP
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
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
