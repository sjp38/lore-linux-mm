Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE1286B7D32
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 03:39:41 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id p5-v6so7127447pfh.11
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 00:39:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u8-v6sor1660190plr.15.2018.09.07.00.39.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 00:39:40 -0700 (PDT)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v6 4/6] Btrfs: prevent ioctls from interfering with a swap file
Date: Fri,  7 Sep 2018 00:39:18 -0700
Message-Id: <d6f34563688651fa1638160accdcb693e0913a4a.1536305017.git.osandov@fb.com>
In-Reply-To: <cover.1536305017.git.osandov@fb.com>
References: <cover.1536305017.git.osandov@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org
Cc: kernel-team@fb.com, linux-mm@kvack.org

From: Omar Sandoval <osandov@fb.com>

When a swap file is active, we must make sure that the extents of the
file are not moved and that they don't become shared. That means that
the following are not safe:

- chattr +c (enable compression)
- reflink
- dedupe
- snapshot
- defrag

Don't allow those to happen on an active swap file.

Additionally, balance, resize, device remove, and device replace are
also unsafe if they affect an active swapfile. Add a red-black tree of
block groups and devices which contain an active swapfile. Relocation
checks each block group against this tree and skips it or errors out for
balance or resize, respectively. Device remove and device replace check
the tree for the device they will operate on.

Note that we don't have to worry about chattr -C (disable nocow), which
we ignore for non-empty files, because an active swapfile must be
non-empty and can't be truncated. We also don't have to worry about
autodefrag because it's only done on COW files. Truncate and fallocate
are already taken care of by the generic code. Device add doesn't do
relocation so it's not an issue, either.

Signed-off-by: Omar Sandoval <osandov@fb.com>
---
 fs/btrfs/ctree.h       | 24 +++++++++++++++++++++
 fs/btrfs/dev-replace.c |  8 +++++++
 fs/btrfs/disk-io.c     |  4 ++++
 fs/btrfs/ioctl.c       | 31 +++++++++++++++++++++++---
 fs/btrfs/relocation.c  | 18 ++++++++++++----
 fs/btrfs/volumes.c     | 49 +++++++++++++++++++++++++++++++++++++-----
 6 files changed, 122 insertions(+), 12 deletions(-)

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index 53af9f5253f4..e37ce40db380 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -716,6 +716,23 @@ struct btrfs_fs_devices;
 struct btrfs_balance_control;
 struct btrfs_delayed_root;
 
+/*
+ * Block group or device which contains an active swapfile. Used for preventing
+ * unsafe operations while a swapfile is active.
+ */
+struct btrfs_swapfile_pin {
+	struct rb_node node;
+	void *ptr;
+	struct inode *inode;
+	/*
+	 * If true, ptr points to a struct btrfs_block_group_cache. Otherwise,
+	 * ptr points to a struct btrfs_device.
+	 */
+	bool is_block_group;
+};
+
+bool btrfs_pinned_by_swapfile(struct btrfs_fs_info *fs_info, void *ptr);
+
 #define BTRFS_FS_BARRIER			1
 #define BTRFS_FS_CLOSING_START			2
 #define BTRFS_FS_CLOSING_DONE			3
@@ -1121,6 +1138,10 @@ struct btrfs_fs_info {
 	u32 sectorsize;
 	u32 stripesize;
 
+	/* Block groups and devices containing active swapfiles. */
+	spinlock_t swapfile_pins_lock;
+	struct rb_root swapfile_pins;
+
 #ifdef CONFIG_BTRFS_FS_REF_VERIFY
 	spinlock_t ref_verify_lock;
 	struct rb_root block_tree;
@@ -1285,6 +1306,9 @@ struct btrfs_root {
 	spinlock_t qgroup_meta_rsv_lock;
 	u64 qgroup_meta_rsv_pertrans;
 	u64 qgroup_meta_rsv_prealloc;
+
+	/* Number of active swapfiles */
+	atomic_t nr_swapfiles;
 };
 
 struct btrfs_file_private {
diff --git a/fs/btrfs/dev-replace.c b/fs/btrfs/dev-replace.c
index dec01970d8c5..09d2cee2635b 100644
--- a/fs/btrfs/dev-replace.c
+++ b/fs/btrfs/dev-replace.c
@@ -414,6 +414,14 @@ int btrfs_dev_replace_start(struct btrfs_fs_info *fs_info,
 	if (ret)
 		return ret;
 
+	if (btrfs_pinned_by_swapfile(fs_info, src_device)) {
+		btrfs_info_in_rcu(fs_info,
+				  "cannot replace device %s (devid %llu) due to active swapfile",
+				  btrfs_dev_name(src_device),
+				  src_device->devid);
+		return -ETXTBSY;
+	}
+
 	ret = btrfs_init_dev_replace_tgtdev(fs_info, tgtdev_name,
 					    src_device, &tgt_device);
 	if (ret)
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 5124c15705ce..0ab3527bedd1 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -1187,6 +1187,7 @@ static void __setup_root(struct btrfs_root *root, struct btrfs_fs_info *fs_info,
 	atomic_set(&root->log_batch, 0);
 	refcount_set(&root->refs, 1);
 	atomic_set(&root->will_be_snapshotted, 0);
+	atomic_set(&root->nr_swapfiles, 0);
 	root->log_transid = 0;
 	root->log_transid_committed = -1;
 	root->last_log_commit = 0;
@@ -2781,6 +2782,9 @@ int open_ctree(struct super_block *sb,
 	fs_info->sectorsize = 4096;
 	fs_info->stripesize = 4096;
 
+	spin_lock_init(&fs_info->swapfile_pins_lock);
+	fs_info->swapfile_pins = RB_ROOT;
+
 	ret = btrfs_alloc_stripe_hash_table(fs_info);
 	if (ret) {
 		err = ret;
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 63600dc2ac4c..d083bf21aabe 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -290,6 +290,11 @@ static int btrfs_ioctl_setflags(struct file *file, void __user *arg)
 	} else if (fsflags & FS_COMPR_FL) {
 		const char *comp;
 
+		if (IS_SWAPFILE(inode)) {
+			ret = -ETXTBSY;
+			goto out_unlock;
+		}
+
 		binode->flags |= BTRFS_INODE_COMPRESS;
 		binode->flags &= ~BTRFS_INODE_NOCOMPRESS;
 
@@ -751,6 +756,12 @@ static int create_snapshot(struct btrfs_root *root, struct inode *dir,
 	if (!test_bit(BTRFS_ROOT_REF_COWS, &root->state))
 		return -EINVAL;
 
+	if (atomic_read(&root->nr_swapfiles)) {
+		btrfs_info(fs_info,
+			   "cannot snapshot subvolume with active swapfile");
+		return -ETXTBSY;
+	}
+
 	pending_snapshot = kzalloc(sizeof(*pending_snapshot), GFP_KERNEL);
 	if (!pending_snapshot)
 		return -ENOMEM;
@@ -1487,9 +1498,13 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 		}
 
 		inode_lock(inode);
-		if (do_compress)
-			BTRFS_I(inode)->defrag_compress = compress_type;
-		ret = cluster_pages_for_defrag(inode, pages, i, cluster);
+		if (IS_SWAPFILE(inode)) {
+			ret = -ETXTBSY;
+		} else {
+			if (do_compress)
+				BTRFS_I(inode)->defrag_compress = compress_type;
+			ret = cluster_pages_for_defrag(inode, pages, i, cluster);
+		}
 		if (ret < 0) {
 			inode_unlock(inode);
 			goto out_ra;
@@ -3538,6 +3553,11 @@ static int btrfs_extent_same(struct inode *src, u64 loff, u64 olen,
 		goto out_unlock;
 	}
 
+	if (IS_SWAPFILE(src) || IS_SWAPFILE(dst)) {
+		ret = -ETXTBSY;
+		goto out_unlock;
+	}
+
 	tail_len = olen % BTRFS_MAX_DEDUPE_LEN;
 	chunk_count = div_u64(olen, BTRFS_MAX_DEDUPE_LEN);
 	if (chunk_count == 0)
@@ -4234,6 +4254,11 @@ static noinline int btrfs_clone_files(struct file *file, struct file *file_src,
 		goto out_unlock;
 	}
 
+	if (IS_SWAPFILE(src) || IS_SWAPFILE(inode)) {
+		ret = -ETXTBSY;
+		goto out_unlock;
+	}
+
 	/* determine range to clone */
 	ret = -EINVAL;
 	if (off + len > src->i_size || off + len < off)
diff --git a/fs/btrfs/relocation.c b/fs/btrfs/relocation.c
index 8783a1776540..7468a0f55cd2 100644
--- a/fs/btrfs/relocation.c
+++ b/fs/btrfs/relocation.c
@@ -4226,6 +4226,7 @@ static void describe_relocation(struct btrfs_fs_info *fs_info,
  */
 int btrfs_relocate_block_group(struct btrfs_fs_info *fs_info, u64 group_start)
 {
+	struct btrfs_block_group_cache *bg;
 	struct btrfs_root *extent_root = fs_info->extent_root;
 	struct reloc_control *rc;
 	struct inode *inode;
@@ -4234,14 +4235,23 @@ int btrfs_relocate_block_group(struct btrfs_fs_info *fs_info, u64 group_start)
 	int rw = 0;
 	int err = 0;
 
+	bg = btrfs_lookup_block_group(fs_info, group_start);
+	if (!bg)
+		return -ENOENT;
+
+	if (btrfs_pinned_by_swapfile(fs_info, bg)) {
+		btrfs_put_block_group(bg);
+		return -ETXTBSY;
+	}
+
 	rc = alloc_reloc_control();
-	if (!rc)
+	if (!rc) {
+		btrfs_put_block_group(bg);
 		return -ENOMEM;
+	}
 
 	rc->extent_root = extent_root;
-
-	rc->block_group = btrfs_lookup_block_group(fs_info, group_start);
-	BUG_ON(!rc->block_group);
+	rc->block_group = bg;
 
 	ret = btrfs_inc_block_group_ro(rc->block_group);
 	if (ret) {
diff --git a/fs/btrfs/volumes.c b/fs/btrfs/volumes.c
index da86706123ff..207e36b70d9b 100644
--- a/fs/btrfs/volumes.c
+++ b/fs/btrfs/volumes.c
@@ -1882,6 +1882,14 @@ int btrfs_rm_device(struct btrfs_fs_info *fs_info, const char *device_path,
 	if (ret)
 		goto out;
 
+	if (btrfs_pinned_by_swapfile(fs_info, device)) {
+		btrfs_info_in_rcu(fs_info,
+				  "cannot remove device %s (devid %llu) due to active swapfile",
+				  rcu_str_deref(device->name), device->devid);
+		ret = -ETXTBSY;
+		goto out;
+	}
+
 	if (test_bit(BTRFS_DEV_STATE_REPLACE_TGT, &device->dev_state)) {
 		ret = BTRFS_ERROR_DEV_TGT_REPLACE;
 		goto out;
@@ -3626,10 +3634,15 @@ static int __btrfs_balance(struct btrfs_fs_info *fs_info)
 
 		ret = btrfs_relocate_chunk(fs_info, found_key.offset);
 		mutex_unlock(&fs_info->delete_unused_bgs_mutex);
-		if (ret && ret != -ENOSPC)
-			goto error;
 		if (ret == -ENOSPC) {
 			enospc_errors++;
+		} else if (ret == -ETXTBSY) {
+			btrfs_info(fs_info,
+				   "skipping relocation of block group %llu due to active swapfile",
+				   found_key.offset);
+			ret = 0;
+		} else if (ret) {
+			goto error;
 		} else {
 			spin_lock(&fs_info->balance_lock);
 			bctl->stat.completed++;
@@ -4426,10 +4439,16 @@ int btrfs_shrink_device(struct btrfs_device *device, u64 new_size)
 
 		ret = btrfs_relocate_chunk(fs_info, chunk_offset);
 		mutex_unlock(&fs_info->delete_unused_bgs_mutex);
-		if (ret && ret != -ENOSPC)
-			goto done;
-		if (ret == -ENOSPC)
+		if (ret == -ENOSPC) {
 			failed++;
+		} else {
+			if (ret == -ETXTBSY) {
+				btrfs_info(fs_info,
+					   "could not shrink block group %llu due to active swapfile",
+					   chunk_offset);
+			}
+			goto done;
+		}
 	} while (key.offset-- > 0);
 
 	if (failed && !retried) {
@@ -7525,3 +7544,23 @@ int btrfs_verify_dev_extents(struct btrfs_fs_info *fs_info)
 	btrfs_free_path(path);
 	return ret;
 }
+
+bool btrfs_pinned_by_swapfile(struct btrfs_fs_info *fs_info, void *ptr)
+{
+	struct btrfs_swapfile_pin *sp;
+	struct rb_node *node;
+
+	spin_lock(&fs_info->swapfile_pins_lock);
+	node = fs_info->swapfile_pins.rb_node;
+	while (node) {
+		sp = rb_entry(node, struct btrfs_swapfile_pin, node);
+		if (ptr < sp->ptr)
+			node = node->rb_left;
+		else if (ptr > sp->ptr)
+			node = node->rb_right;
+		else
+			break;
+	}
+	spin_unlock(&fs_info->swapfile_pins_lock);
+	return node != NULL;
+}
-- 
2.18.0
