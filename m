Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 72B0F280286
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:09 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id w186so12210931pgb.10
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b9si5202481pli.725.2018.01.17.12.23.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:08 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 94/99] f2fs: Convert extent_tree_root to XArray
Date: Wed, 17 Jan 2018 12:21:58 -0800
Message-Id: <20180117202203.19756-95-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Rename it to extent_array and use the xa_lock in place of the
extent_tree_lock mutex.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/f2fs/extent_cache.c | 59 +++++++++++++++++++++++++-------------------------
 fs/f2fs/f2fs.h         |  3 +--
 2 files changed, 30 insertions(+), 32 deletions(-)

diff --git a/fs/f2fs/extent_cache.c b/fs/f2fs/extent_cache.c
index ff2352a0ed15..da5f3bd1808d 100644
--- a/fs/f2fs/extent_cache.c
+++ b/fs/f2fs/extent_cache.c
@@ -250,25 +250,25 @@ static struct extent_tree *__grab_extent_tree(struct inode *inode)
 	struct extent_tree *et;
 	nid_t ino = inode->i_ino;
 
-	mutex_lock(&sbi->extent_tree_lock);
-	et = radix_tree_lookup(&sbi->extent_tree_root, ino);
-	if (!et) {
-		et = f2fs_kmem_cache_alloc(extent_tree_slab, GFP_NOFS);
-		f2fs_radix_tree_insert(&sbi->extent_tree_root, ino, et);
-		memset(et, 0, sizeof(struct extent_tree));
-		et->ino = ino;
-		et->root = RB_ROOT;
-		et->cached_en = NULL;
-		rwlock_init(&et->lock);
-		INIT_LIST_HEAD(&et->list);
-		atomic_set(&et->node_cnt, 0);
-		atomic_inc(&sbi->total_ext_tree);
-	} else {
+	et = xa_load(&sbi->extent_array, ino);
+	if (et) {
 		atomic_dec(&sbi->total_zombie_tree);
 		list_del_init(&et->list);
+		goto out;
 	}
-	mutex_unlock(&sbi->extent_tree_lock);
 
+	et = f2fs_kmem_cache_alloc(extent_tree_slab, GFP_NOFS | __GFP_ZERO);
+	et->ino = ino;
+	et->root = RB_ROOT;
+	et->cached_en = NULL;
+	rwlock_init(&et->lock);
+	INIT_LIST_HEAD(&et->list);
+	atomic_set(&et->node_cnt, 0);
+
+	xa_store(&sbi->extent_array, ino, et, GFP_NOFS);
+	atomic_inc(&sbi->total_ext_tree);
+
+out:
 	/* never died until evict_inode */
 	F2FS_I(inode)->extent_tree = et;
 
@@ -622,7 +622,7 @@ unsigned int f2fs_shrink_extent_tree(struct f2fs_sb_info *sbi, int nr_shrink)
 	if (!atomic_read(&sbi->total_zombie_tree))
 		goto free_node;
 
-	if (!mutex_trylock(&sbi->extent_tree_lock))
+	if (!xa_trylock(&sbi->extent_array))
 		goto out;
 
 	/* 1. remove unreferenced extent tree */
@@ -634,7 +634,7 @@ unsigned int f2fs_shrink_extent_tree(struct f2fs_sb_info *sbi, int nr_shrink)
 		}
 		f2fs_bug_on(sbi, atomic_read(&et->node_cnt));
 		list_del_init(&et->list);
-		radix_tree_delete(&sbi->extent_tree_root, et->ino);
+		xa_erase(&sbi->extent_array, et->ino);
 		kmem_cache_free(extent_tree_slab, et);
 		atomic_dec(&sbi->total_ext_tree);
 		atomic_dec(&sbi->total_zombie_tree);
@@ -642,13 +642,13 @@ unsigned int f2fs_shrink_extent_tree(struct f2fs_sb_info *sbi, int nr_shrink)
 
 		if (node_cnt + tree_cnt >= nr_shrink)
 			goto unlock_out;
-		cond_resched();
+		cond_resched_lock(&sbi->extent_array.xa_lock);
 	}
-	mutex_unlock(&sbi->extent_tree_lock);
+	xa_unlock(&sbi->extent_array);
 
 free_node:
 	/* 2. remove LRU extent entries */
-	if (!mutex_trylock(&sbi->extent_tree_lock))
+	if (!xa_trylock(&sbi->extent_array))
 		goto out;
 
 	remained = nr_shrink - (node_cnt + tree_cnt);
@@ -678,7 +678,7 @@ unsigned int f2fs_shrink_extent_tree(struct f2fs_sb_info *sbi, int nr_shrink)
 	spin_unlock(&sbi->extent_lock);
 
 unlock_out:
-	mutex_unlock(&sbi->extent_tree_lock);
+	xa_unlock(&sbi->extent_array);
 out:
 	trace_f2fs_shrink_extent_tree(sbi, node_cnt, tree_cnt);
 
@@ -725,23 +725,23 @@ void f2fs_destroy_extent_tree(struct inode *inode)
 
 	if (inode->i_nlink && !is_bad_inode(inode) &&
 					atomic_read(&et->node_cnt)) {
-		mutex_lock(&sbi->extent_tree_lock);
+		xa_lock(&sbi->extent_array);
 		list_add_tail(&et->list, &sbi->zombie_list);
 		atomic_inc(&sbi->total_zombie_tree);
-		mutex_unlock(&sbi->extent_tree_lock);
+		xa_unlock(&sbi->extent_array);
 		return;
 	}
 
 	/* free all extent info belong to this extent tree */
 	node_cnt = f2fs_destroy_extent_node(inode);
 
-	/* delete extent tree entry in radix tree */
-	mutex_lock(&sbi->extent_tree_lock);
+	/* delete extent from array */
+	xa_lock(&sbi->extent_array);
 	f2fs_bug_on(sbi, atomic_read(&et->node_cnt));
-	radix_tree_delete(&sbi->extent_tree_root, inode->i_ino);
-	kmem_cache_free(extent_tree_slab, et);
+	__xa_erase(&sbi->extent_array, inode->i_ino);
 	atomic_dec(&sbi->total_ext_tree);
-	mutex_unlock(&sbi->extent_tree_lock);
+	xa_unlock(&sbi->extent_array);
+	kmem_cache_free(extent_tree_slab, et);
 
 	F2FS_I(inode)->extent_tree = NULL;
 
@@ -787,8 +787,7 @@ void f2fs_update_extent_cache_range(struct dnode_of_data *dn,
 
 void init_extent_cache_info(struct f2fs_sb_info *sbi)
 {
-	INIT_RADIX_TREE(&sbi->extent_tree_root, GFP_NOIO);
-	mutex_init(&sbi->extent_tree_lock);
+	xa_init(&sbi->extent_array);
 	INIT_LIST_HEAD(&sbi->extent_list);
 	spin_lock_init(&sbi->extent_lock);
 	atomic_set(&sbi->total_ext_tree, 0);
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index b3ee784b49bc..4eacef9c7274 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -1064,8 +1064,7 @@ struct f2fs_sb_info {
 	spinlock_t inode_lock[NR_INODE_TYPE];	/* for dirty inode list lock */
 
 	/* for extent tree cache */
-	struct radix_tree_root extent_tree_root;/* cache extent cache entries */
-	struct mutex extent_tree_lock;	/* locking extent radix tree */
+	struct xarray extent_array;		/* cache extent cache entries */
 	struct list_head extent_list;		/* lru list for shrinker */
 	spinlock_t extent_lock;			/* locking extent lru list */
 	atomic_t total_ext_tree;		/* extent tree count */
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
