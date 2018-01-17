Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B76228029C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:24:46 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id g186so4649308pfb.11
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:24:46 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h4si4462795pgq.466.2018.01.17.12.23.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:08 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 84/99] btrfs: Convert fs_roots_radix to XArray
Date: Wed, 17 Jan 2018 12:21:48 -0800
Message-Id: <20180117202203.19756-85-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Most of the gang lookups being done can be expressed just as efficiently
and somewhat more naturally as xa_for_each() loops.  I opted not to
change the one in btrfs_cleanup_fs_roots() as it's using SRCU which is
subtle and quick to anger.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/btrfs/ctree.h             |  3 +-
 fs/btrfs/disk-io.c           | 65 +++++++++++----------------------
 fs/btrfs/tests/btrfs-tests.c |  3 +-
 fs/btrfs/transaction.c       | 87 ++++++++++++++++++--------------------------
 4 files changed, 59 insertions(+), 99 deletions(-)

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index 13c260b525a1..173d72dfaab6 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -741,8 +741,7 @@ struct btrfs_fs_info {
 	/* the log root tree is a directory of all the other log roots */
 	struct btrfs_root *log_root_tree;
 
-	spinlock_t fs_roots_radix_lock;
-	struct radix_tree_root fs_roots_radix;
+	struct xarray fs_roots;
 
 	/* block group cache stuff */
 	spinlock_t block_group_cache_lock;
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index a8ecccfc36de..62995a55d112 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -1519,13 +1519,7 @@ int btrfs_init_fs_root(struct btrfs_root *root)
 struct btrfs_root *btrfs_lookup_fs_root(struct btrfs_fs_info *fs_info,
 					u64 root_id)
 {
-	struct btrfs_root *root;
-
-	spin_lock(&fs_info->fs_roots_radix_lock);
-	root = radix_tree_lookup(&fs_info->fs_roots_radix,
-				 (unsigned long)root_id);
-	spin_unlock(&fs_info->fs_roots_radix_lock);
-	return root;
+	return xa_load(&fs_info->fs_roots, (unsigned long)root_id);
 }
 
 int btrfs_insert_fs_root(struct btrfs_fs_info *fs_info,
@@ -1533,18 +1527,13 @@ int btrfs_insert_fs_root(struct btrfs_fs_info *fs_info,
 {
 	int ret;
 
-	ret = radix_tree_preload(GFP_NOFS);
-	if (ret)
-		return ret;
-
-	spin_lock(&fs_info->fs_roots_radix_lock);
-	ret = radix_tree_insert(&fs_info->fs_roots_radix,
+	xa_lock(&fs_info->fs_roots);
+	ret = __xa_insert(&fs_info->fs_roots,
 				(unsigned long)root->root_key.objectid,
-				root);
+				root, GFP_NOFS);
 	if (ret == 0)
 		set_bit(BTRFS_ROOT_IN_RADIX, &root->state);
-	spin_unlock(&fs_info->fs_roots_radix_lock);
-	radix_tree_preload_end();
+	xa_unlock(&fs_info->fs_roots);
 
 	return ret;
 }
@@ -2079,33 +2068,25 @@ static void free_root_pointers(struct btrfs_fs_info *info, int chunk_root)
 
 void btrfs_free_fs_roots(struct btrfs_fs_info *fs_info)
 {
-	int ret;
-	struct btrfs_root *gang[8];
-	int i;
+	struct btrfs_root *root;
+	unsigned long i = 0;
 
 	while (!list_empty(&fs_info->dead_roots)) {
-		gang[0] = list_entry(fs_info->dead_roots.next,
+		root = list_entry(fs_info->dead_roots.next,
 				     struct btrfs_root, root_list);
-		list_del(&gang[0]->root_list);
+		list_del(&root->root_list);
 
-		if (test_bit(BTRFS_ROOT_IN_RADIX, &gang[0]->state)) {
-			btrfs_drop_and_free_fs_root(fs_info, gang[0]);
+		if (test_bit(BTRFS_ROOT_IN_RADIX, &root->state)) {
+			btrfs_drop_and_free_fs_root(fs_info, root);
 		} else {
-			free_extent_buffer(gang[0]->node);
-			free_extent_buffer(gang[0]->commit_root);
-			btrfs_put_fs_root(gang[0]);
+			free_extent_buffer(root->node);
+			free_extent_buffer(root->commit_root);
+			btrfs_put_fs_root(root);
 		}
 	}
 
-	while (1) {
-		ret = radix_tree_gang_lookup(&fs_info->fs_roots_radix,
-					     (void **)gang, 0,
-					     ARRAY_SIZE(gang));
-		if (!ret)
-			break;
-		for (i = 0; i < ret; i++)
-			btrfs_drop_and_free_fs_root(fs_info, gang[i]);
-	}
+	xa_for_each(&fs_info->fs_roots, root, i, ULONG_MAX, XA_PRESENT)
+		btrfs_drop_and_free_fs_root(fs_info, root);
 
 	if (test_bit(BTRFS_FS_STATE_ERROR, &fs_info->fs_state)) {
 		btrfs_free_log_root_tree(NULL, fs_info);
@@ -2447,7 +2428,7 @@ int open_ctree(struct super_block *sb,
 		goto fail_delalloc_bytes;
 	}
 
-	INIT_RADIX_TREE(&fs_info->fs_roots_radix, GFP_ATOMIC);
+	xa_init(&fs_info->fs_roots);
 	INIT_RADIX_TREE(&fs_info->buffer_radix, GFP_ATOMIC);
 	INIT_LIST_HEAD(&fs_info->trans_list);
 	INIT_LIST_HEAD(&fs_info->dead_roots);
@@ -2456,7 +2437,6 @@ int open_ctree(struct super_block *sb,
 	INIT_LIST_HEAD(&fs_info->caching_block_groups);
 	spin_lock_init(&fs_info->delalloc_root_lock);
 	spin_lock_init(&fs_info->trans_lock);
-	spin_lock_init(&fs_info->fs_roots_radix_lock);
 	spin_lock_init(&fs_info->delayed_iput_lock);
 	spin_lock_init(&fs_info->defrag_inodes_lock);
 	spin_lock_init(&fs_info->tree_mod_seq_lock);
@@ -3573,10 +3553,7 @@ int write_all_supers(struct btrfs_fs_info *fs_info, int max_mirrors)
 void btrfs_drop_and_free_fs_root(struct btrfs_fs_info *fs_info,
 				  struct btrfs_root *root)
 {
-	spin_lock(&fs_info->fs_roots_radix_lock);
-	radix_tree_delete(&fs_info->fs_roots_radix,
-			  (unsigned long)root->root_key.objectid);
-	spin_unlock(&fs_info->fs_roots_radix_lock);
+	xa_erase(&fs_info->fs_roots, (unsigned long)root->root_key.objectid);
 
 	if (btrfs_root_refs(&root->root_item) == 0)
 		synchronize_srcu(&fs_info->subvol_srcu);
@@ -3632,9 +3609,9 @@ int btrfs_cleanup_fs_roots(struct btrfs_fs_info *fs_info)
 
 	while (1) {
 		index = srcu_read_lock(&fs_info->subvol_srcu);
-		ret = radix_tree_gang_lookup(&fs_info->fs_roots_radix,
-					     (void **)gang, root_objectid,
-					     ARRAY_SIZE(gang));
+		ret = xa_extract(&fs_info->fs_roots, (void **)gang,
+				root_objectid, ULONG_MAX, ARRAY_SIZE(gang),
+				XA_PRESENT);
 		if (!ret) {
 			srcu_read_unlock(&fs_info->subvol_srcu, index);
 			break;
diff --git a/fs/btrfs/tests/btrfs-tests.c b/fs/btrfs/tests/btrfs-tests.c
index d3f25376a0f8..570bce31a301 100644
--- a/fs/btrfs/tests/btrfs-tests.c
+++ b/fs/btrfs/tests/btrfs-tests.c
@@ -114,7 +114,6 @@ struct btrfs_fs_info *btrfs_alloc_dummy_fs_info(u32 nodesize, u32 sectorsize)
 	spin_lock_init(&fs_info->qgroup_lock);
 	spin_lock_init(&fs_info->qgroup_op_lock);
 	spin_lock_init(&fs_info->super_lock);
-	spin_lock_init(&fs_info->fs_roots_radix_lock);
 	spin_lock_init(&fs_info->tree_mod_seq_lock);
 	mutex_init(&fs_info->qgroup_ioctl_lock);
 	mutex_init(&fs_info->qgroup_rescan_lock);
@@ -127,7 +126,7 @@ struct btrfs_fs_info *btrfs_alloc_dummy_fs_info(u32 nodesize, u32 sectorsize)
 	INIT_LIST_HEAD(&fs_info->dead_roots);
 	INIT_LIST_HEAD(&fs_info->tree_mod_seq_list);
 	INIT_RADIX_TREE(&fs_info->buffer_radix, GFP_ATOMIC);
-	INIT_RADIX_TREE(&fs_info->fs_roots_radix, GFP_ATOMIC);
+	xa_init(&fs_info->fs_roots);
 	extent_io_tree_init(&fs_info->freed_extents[0], NULL);
 	extent_io_tree_init(&fs_info->freed_extents[1], NULL);
 	fs_info->pinned_extents = &fs_info->freed_extents[0];
diff --git a/fs/btrfs/transaction.c b/fs/btrfs/transaction.c
index 5a8c2649af2f..2d6606df0fa3 100644
--- a/fs/btrfs/transaction.c
+++ b/fs/btrfs/transaction.c
@@ -33,7 +33,7 @@
 #include "dev-replace.h"
 #include "qgroup.h"
 
-#define BTRFS_ROOT_TRANS_TAG 0
+#define BTRFS_ROOT_TRANS_TAG XA_TAG_0
 
 static const unsigned int btrfs_blocked_trans_types[TRANS_STATE_MAX] = {
 	[TRANS_STATE_RUNNING]		= 0U,
@@ -333,15 +333,15 @@ static int record_root_in_trans(struct btrfs_trans_handle *trans,
 		 */
 		smp_wmb();
 
-		spin_lock(&fs_info->fs_roots_radix_lock);
+		xa_lock(&fs_info->fs_roots);
 		if (root->last_trans == trans->transid && !force) {
-			spin_unlock(&fs_info->fs_roots_radix_lock);
+			xa_unlock(&fs_info->fs_roots);
 			return 0;
 		}
-		radix_tree_tag_set(&fs_info->fs_roots_radix,
+		__xa_set_tag(&fs_info->fs_roots,
 				   (unsigned long)root->root_key.objectid,
 				   BTRFS_ROOT_TRANS_TAG);
-		spin_unlock(&fs_info->fs_roots_radix_lock);
+		xa_unlock(&fs_info->fs_roots);
 		root->last_trans = trans->transid;
 
 		/* this is pretty tricky.  We don't want to
@@ -383,11 +383,8 @@ void btrfs_add_dropped_root(struct btrfs_trans_handle *trans,
 	spin_unlock(&cur_trans->dropped_roots_lock);
 
 	/* Make sure we don't try to update the root at commit time */
-	spin_lock(&fs_info->fs_roots_radix_lock);
-	radix_tree_tag_clear(&fs_info->fs_roots_radix,
-			     (unsigned long)root->root_key.objectid,
+	xa_clear_tag(&fs_info->fs_roots, (unsigned long)root->root_key.objectid,
 			     BTRFS_ROOT_TRANS_TAG);
-	spin_unlock(&fs_info->fs_roots_radix_lock);
 }
 
 int btrfs_record_root_in_trans(struct btrfs_trans_handle *trans,
@@ -1255,53 +1252,41 @@ void btrfs_add_dead_root(struct btrfs_root *root)
 static noinline int commit_fs_roots(struct btrfs_trans_handle *trans,
 				    struct btrfs_fs_info *fs_info)
 {
-	struct btrfs_root *gang[8];
-	int i;
-	int ret;
+	struct btrfs_root *root;
+	unsigned long index = 0;
 	int err = 0;
 
-	spin_lock(&fs_info->fs_roots_radix_lock);
-	while (1) {
-		ret = radix_tree_gang_lookup_tag(&fs_info->fs_roots_radix,
-						 (void **)gang, 0,
-						 ARRAY_SIZE(gang),
-						 BTRFS_ROOT_TRANS_TAG);
-		if (ret == 0)
-			break;
-		for (i = 0; i < ret; i++) {
-			struct btrfs_root *root = gang[i];
-			radix_tree_tag_clear(&fs_info->fs_roots_radix,
-					(unsigned long)root->root_key.objectid,
-					BTRFS_ROOT_TRANS_TAG);
-			spin_unlock(&fs_info->fs_roots_radix_lock);
-
-			btrfs_free_log(trans, root);
-			btrfs_update_reloc_root(trans, root);
-			btrfs_orphan_commit_root(trans, root);
-
-			btrfs_save_ino_cache(root, trans);
-
-			/* see comments in should_cow_block() */
-			clear_bit(BTRFS_ROOT_FORCE_COW, &root->state);
-			smp_mb__after_atomic();
-
-			if (root->commit_root != root->node) {
-				list_add_tail(&root->dirty_list,
-					&trans->transaction->switch_commits);
-				btrfs_set_root_node(&root->root_item,
-						    root->node);
-			}
+	xa_lock(&fs_info->fs_roots);
+	xa_for_each(&fs_info->fs_roots, root, index, ULONG_MAX,
+						BTRFS_ROOT_TRANS_TAG) {
+		__xa_clear_tag(&fs_info->fs_roots, index, BTRFS_ROOT_TRANS_TAG);
+		xa_unlock(&fs_info->fs_roots);
 
-			err = btrfs_update_root(trans, fs_info->tree_root,
-						&root->root_key,
-						&root->root_item);
-			spin_lock(&fs_info->fs_roots_radix_lock);
-			if (err)
-				break;
-			btrfs_qgroup_free_meta_all(root);
+		btrfs_free_log(trans, root);
+		btrfs_update_reloc_root(trans, root);
+		btrfs_orphan_commit_root(trans, root);
+
+		btrfs_save_ino_cache(root, trans);
+
+		/* see comments in should_cow_block() */
+		clear_bit(BTRFS_ROOT_FORCE_COW, &root->state);
+		smp_mb__after_atomic();
+
+		if (root->commit_root != root->node) {
+			list_add_tail(&root->dirty_list,
+				&trans->transaction->switch_commits);
+			btrfs_set_root_node(&root->root_item, root->node);
 		}
+
+		err = btrfs_update_root(trans, fs_info->tree_root,
+					&root->root_key, &root->root_item);
+		xa_lock(&fs_info->fs_roots);
+		if (err)
+			break;
+		btrfs_qgroup_free_meta_all(root);
+		index = 0;
 	}
-	spin_unlock(&fs_info->fs_roots_radix_lock);
+	xa_unlock(&fs_info->fs_roots);
 	return err;
 }
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
