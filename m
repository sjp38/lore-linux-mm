Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77D45280288
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:08 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id p20so5837322pfh.17
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:08 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p13si4561828pgn.11.2018.01.17.12.23.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:06 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 90/99] btrfs: Convert delayed_nodes_tree to XArray
Date: Wed, 17 Jan 2018 12:21:54 -0800
Message-Id: <20180117202203.19756-91-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Rename it to just 'delayed_nodes' and remove it from the protection of
btrfs_root->inode_lock.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/btrfs/ctree.h         |  8 +++---
 fs/btrfs/delayed-inode.c | 65 ++++++++++++++++--------------------------------
 fs/btrfs/disk-io.c       |  2 +-
 fs/btrfs/inode.c         |  2 +-
 4 files changed, 27 insertions(+), 50 deletions(-)

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index 87984ce3a4c2..9acfdc623d15 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -1219,11 +1219,9 @@ struct btrfs_root {
 	/* red-black tree that keeps track of in-memory inodes */
 	struct rb_root inode_tree;
 
-	/*
-	 * radix tree that keeps track of delayed nodes of every inode,
-	 * protected by inode_lock
-	 */
-	struct radix_tree_root delayed_nodes_tree;
+	/* track delayed nodes of every inode */
+	struct xarray delayed_nodes;
+
 	/*
 	 * right now this just gets used so that a root has its own devid
 	 * for stat.  It may be used for more later
diff --git a/fs/btrfs/delayed-inode.c b/fs/btrfs/delayed-inode.c
index 056276101c63..156a762f3809 100644
--- a/fs/btrfs/delayed-inode.c
+++ b/fs/btrfs/delayed-inode.c
@@ -86,7 +86,7 @@ static struct btrfs_delayed_node *btrfs_get_delayed_node(
 	}
 
 	spin_lock(&root->inode_lock);
-	node = radix_tree_lookup(&root->delayed_nodes_tree, ino);
+	node = xa_load(&root->delayed_nodes, ino);
 
 	if (node) {
 		if (btrfs_inode->delayed_node) {
@@ -131,10 +131,9 @@ static struct btrfs_delayed_node *btrfs_get_delayed_node(
 static struct btrfs_delayed_node *btrfs_get_or_create_delayed_node(
 		struct btrfs_inode *btrfs_inode)
 {
-	struct btrfs_delayed_node *node;
+	struct btrfs_delayed_node *node, *exists;
 	struct btrfs_root *root = btrfs_inode->root;
 	u64 ino = btrfs_ino(btrfs_inode);
-	int ret;
 
 again:
 	node = btrfs_get_delayed_node(btrfs_inode);
@@ -149,23 +148,18 @@ static struct btrfs_delayed_node *btrfs_get_or_create_delayed_node(
 	/* cached in the btrfs inode and can be accessed */
 	refcount_set(&node->refs, 2);
 
-	ret = radix_tree_preload(GFP_NOFS);
-	if (ret) {
+	xa_lock(&root->delayed_nodes);
+	exists = __xa_cmpxchg(&root->delayed_nodes, ino, NULL, node, GFP_NOFS);
+	if (unlikely(exists)) {
+		int ret = xa_err(exists);
+		xa_unlock(&root->delayed_nodes);
 		kmem_cache_free(delayed_node_cache, node);
+		if (ret == -EEXIST)
+			goto again;
 		return ERR_PTR(ret);
 	}
-
-	spin_lock(&root->inode_lock);
-	ret = radix_tree_insert(&root->delayed_nodes_tree, ino, node);
-	if (ret == -EEXIST) {
-		spin_unlock(&root->inode_lock);
-		kmem_cache_free(delayed_node_cache, node);
-		radix_tree_preload_end();
-		goto again;
-	}
 	btrfs_inode->delayed_node = node;
-	spin_unlock(&root->inode_lock);
-	radix_tree_preload_end();
+	xa_unlock(&root->delayed_nodes);
 
 	return node;
 }
@@ -278,15 +272,12 @@ static void __btrfs_release_delayed_node(
 	if (refcount_dec_and_test(&delayed_node->refs)) {
 		struct btrfs_root *root = delayed_node->root;
 
-		spin_lock(&root->inode_lock);
 		/*
 		 * Once our refcount goes to zero, nobody is allowed to bump it
 		 * back up.  We can delete it now.
 		 */
 		ASSERT(refcount_read(&delayed_node->refs) == 0);
-		radix_tree_delete(&root->delayed_nodes_tree,
-				  delayed_node->inode_id);
-		spin_unlock(&root->inode_lock);
+		xa_erase(&root->delayed_nodes, delayed_node->inode_id);
 		kmem_cache_free(delayed_node_cache, delayed_node);
 	}
 }
@@ -1926,31 +1917,19 @@ void btrfs_kill_delayed_inode_items(struct btrfs_inode *inode)
 
 void btrfs_kill_all_delayed_nodes(struct btrfs_root *root)
 {
-	u64 inode_id = 0;
-	struct btrfs_delayed_node *delayed_nodes[8];
-	int i, n;
-
-	while (1) {
-		spin_lock(&root->inode_lock);
-		n = radix_tree_gang_lookup(&root->delayed_nodes_tree,
-					   (void **)delayed_nodes, inode_id,
-					   ARRAY_SIZE(delayed_nodes));
-		if (!n) {
-			spin_unlock(&root->inode_lock);
-			break;
-		}
-
-		inode_id = delayed_nodes[n - 1]->inode_id + 1;
-
-		for (i = 0; i < n; i++)
-			refcount_inc(&delayed_nodes[i]->refs);
-		spin_unlock(&root->inode_lock);
+	struct btrfs_delayed_node *node;
+	unsigned long inode_id = 0;
 
-		for (i = 0; i < n; i++) {
-			__btrfs_kill_delayed_node(delayed_nodes[i]);
-			btrfs_release_delayed_node(delayed_nodes[i]);
-		}
+	xa_lock(&root->delayed_nodes);
+	xa_for_each(&root->delayed_nodes, node, inode_id, ULONG_MAX,
+								XA_PRESENT) {
+		refcount_inc(&node->refs);
+		xa_unlock(&root->delayed_nodes);
+		__btrfs_kill_delayed_node(node);
+		btrfs_release_delayed_node(node);
+		xa_lock(&root->delayed_nodes);
 	}
+	xa_unlock(&root->delayed_nodes);
 }
 
 void btrfs_destroy_delayed_inodes(struct btrfs_fs_info *fs_info)
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 650d1350b64d..593be6c53fae 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -1149,7 +1149,7 @@ static void __setup_root(struct btrfs_root *root, struct btrfs_fs_info *fs_info,
 	root->nr_ordered_extents = 0;
 	root->name = NULL;
 	root->inode_tree = RB_ROOT;
-	INIT_RADIX_TREE(&root->delayed_nodes_tree, GFP_ATOMIC);
+	xa_init(&root->delayed_nodes);
 	root->block_rsv = NULL;
 	root->orphan_block_rsv = NULL;
 
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index d7d2c556d5a2..9b6d08ca6d0c 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -3793,7 +3793,7 @@ static int btrfs_read_locked_inode(struct inode *inode)
 	 * cache.
 	 *
 	 * This is required for both inode re-read from disk and delayed inode
-	 * in delayed_nodes_tree.
+	 * in delayed_nodes.
 	 */
 	if (BTRFS_I(inode)->last_trans == fs_info->generation)
 		set_bit(BTRFS_INODE_NEEDS_FULL_SYNC,
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
