Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A94D280284
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:07 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id j6so12163456pgp.21
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id i186si4951636pfg.116.2018.01.17.12.23.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:05 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 88/99] btrfs: Convert reada_tree to XArray
Date: Wed, 17 Jan 2018 12:21:52 -0800
Message-Id: <20180117202203.19756-89-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Rename reada_tree to reada_array.  Use the xa_lock in reada_array to
replace reada_lock.  This has to use a nested spinlock as we take the
xa_lock of the reada_extents and reada_zones xarrays while holding
the reada_lock.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/btrfs/ctree.h   |  15 +++++--
 fs/btrfs/disk-io.c |   3 +-
 fs/btrfs/reada.c   | 119 +++++++++++++++++++++++++----------------------------
 3 files changed, 70 insertions(+), 67 deletions(-)

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index 173d72dfaab6..272d099bed7e 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -1052,9 +1052,8 @@ struct btrfs_fs_info {
 
 	struct btrfs_delayed_root *delayed_root;
 
-	/* readahead tree */
-	spinlock_t reada_lock;
-	struct radix_tree_root reada_tree;
+	/* readahead extents */
+	struct xarray reada_array;
 
 	/* readahead works cnt */
 	atomic_t reada_works_cnt;
@@ -1102,6 +1101,16 @@ struct btrfs_fs_info {
 #endif
 };
 
+static inline void reada_lock(struct btrfs_fs_info *fs_info)
+{
+	spin_lock_nested(&fs_info->reada_array.xa_lock, SINGLE_DEPTH_NESTING);
+}
+
+static inline void reada_unlock(struct btrfs_fs_info *fs_info)
+{
+	spin_unlock(&fs_info->reada_array.xa_lock);
+}
+
 static inline struct btrfs_fs_info *btrfs_sb(struct super_block *sb)
 {
 	return sb->s_fs_info;
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 62995a55d112..1eae29045d43 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -2478,8 +2478,7 @@ int open_ctree(struct super_block *sb,
 	fs_info->commit_interval = BTRFS_DEFAULT_COMMIT_INTERVAL;
 	fs_info->avg_delayed_ref_runtime = NSEC_PER_SEC >> 6; /* div by 64 */
 	/* readahead state */
-	INIT_RADIX_TREE(&fs_info->reada_tree, GFP_NOFS & ~__GFP_DIRECT_RECLAIM);
-	spin_lock_init(&fs_info->reada_lock);
+	xa_init(&fs_info->reada_array);
 	btrfs_init_ref_verify(fs_info);
 
 	fs_info->thread_pool_size = min_t(unsigned long,
diff --git a/fs/btrfs/reada.c b/fs/btrfs/reada.c
index 8100f1565250..89ba0063903f 100644
--- a/fs/btrfs/reada.c
+++ b/fs/btrfs/reada.c
@@ -215,12 +215,11 @@ int btree_readahead_hook(struct extent_buffer *eb, int err)
 	struct reada_extent *re;
 
 	/* find extent */
-	spin_lock(&fs_info->reada_lock);
-	re = radix_tree_lookup(&fs_info->reada_tree,
-			       eb->start >> PAGE_SHIFT);
+	reada_lock(fs_info);
+	re = xa_load(&fs_info->reada_array, eb->start >> PAGE_SHIFT);
 	if (re)
 		re->refcnt++;
-	spin_unlock(&fs_info->reada_lock);
+	reada_unlock(fs_info);
 	if (!re) {
 		ret = -1;
 		goto start_machine;
@@ -246,15 +245,15 @@ static struct reada_zone *reada_find_zone(struct btrfs_device *dev, u64 logical,
 	unsigned long index = logical >> PAGE_SHIFT;
 	int i;
 
-	spin_lock(&fs_info->reada_lock);
+	reada_lock(fs_info);
 	zone = xa_find(&dev->reada_zones, &index, ULONG_MAX, XA_PRESENT);
 	if (zone && logical >= zone->start && logical <= zone->end) {
 		kref_get(&zone->refcnt);
-		spin_unlock(&fs_info->reada_lock);
+		reada_unlock(fs_info);
 		return zone;
 	}
 
-	spin_unlock(&fs_info->reada_lock);
+	reada_unlock(fs_info);
 
 	cache = btrfs_lookup_block_group(fs_info, logical);
 	if (!cache)
@@ -289,7 +288,7 @@ static struct reada_zone *reada_find_zone(struct btrfs_device *dev, u64 logical,
 	}
 	zone->ndevs = bbio->num_stripes;
 
-	spin_lock(&fs_info->reada_lock);
+	reada_lock(fs_info);
 	curr = xa_cmpxchg(&dev->reada_zones,
 				(unsigned long)(zone->end >> PAGE_SHIFT),
 				NULL, zone, GFP_NOWAIT | __GFP_NOWARN);
@@ -301,7 +300,7 @@ static struct reada_zone *reada_find_zone(struct btrfs_device *dev, u64 logical,
 		else
 			zone = NULL;
 	}
-	spin_unlock(&fs_info->reada_lock);
+	reada_unlock(fs_info);
 
 	return zone;
 }
@@ -323,11 +322,11 @@ static struct reada_extent *reada_find_extent(struct btrfs_fs_info *fs_info,
 	int dev_replace_is_ongoing;
 	int have_zone = 0;
 
-	spin_lock(&fs_info->reada_lock);
-	re = radix_tree_lookup(&fs_info->reada_tree, index);
+	reada_lock(fs_info);
+	re = xa_load(&fs_info->reada_array, index);
 	if (re)
 		re->refcnt++;
-	spin_unlock(&fs_info->reada_lock);
+	reada_unlock(fs_info);
 
 	if (re)
 		return re;
@@ -378,38 +377,32 @@ static struct reada_extent *reada_find_extent(struct btrfs_fs_info *fs_info,
 			kref_get(&zone->refcnt);
 		++zone->elems;
 		spin_unlock(&zone->lock);
-		spin_lock(&fs_info->reada_lock);
+		reada_lock(fs_info);
 		kref_put(&zone->refcnt, reada_zone_release);
-		spin_unlock(&fs_info->reada_lock);
+		reada_unlock(fs_info);
 	}
 	if (re->nzones == 0) {
 		/* not a single zone found, error and out */
 		goto error;
 	}
 
-	ret = radix_tree_preload(GFP_KERNEL);
-	if (ret)
-		goto error;
-
-	/* insert extent in reada_tree + all per-device trees, all or nothing */
+	/*
+	 * Insert extent in reada_array and all per-device arrays,
+	 * all or nothing
+	 */
 	btrfs_dev_replace_lock(&fs_info->dev_replace, 0);
-	spin_lock(&fs_info->reada_lock);
-	ret = radix_tree_insert(&fs_info->reada_tree, index, re);
-	if (ret == -EEXIST) {
-		re_exist = radix_tree_lookup(&fs_info->reada_tree, index);
-		re_exist->refcnt++;
-		spin_unlock(&fs_info->reada_lock);
-		btrfs_dev_replace_unlock(&fs_info->dev_replace, 0);
-		radix_tree_preload_end();
-		goto error;
-	}
-	if (ret) {
-		spin_unlock(&fs_info->reada_lock);
+	reada_lock(fs_info);
+	re_exist = __xa_cmpxchg(&fs_info->reada_array, index, NULL, re,
+								GFP_KERNEL);
+	if (re_exist) {
+		if (xa_is_err(re_exist))
+			re_exist = NULL;
+		else
+			re_exist->refcnt++;
+		reada_unlock(fs_info);
 		btrfs_dev_replace_unlock(&fs_info->dev_replace, 0);
-		radix_tree_preload_end();
 		goto error;
 	}
-	radix_tree_preload_end();
 	prev_dev = NULL;
 	dev_replace_is_ongoing = btrfs_dev_replace_is_ongoing(
 			&fs_info->dev_replace);
@@ -447,14 +440,14 @@ static struct reada_extent *reada_find_extent(struct btrfs_fs_info *fs_info,
 				/* ignore whether the entry was inserted */
 				xa_erase(&dev->reada_extents, index);
 			}
-			radix_tree_delete(&fs_info->reada_tree, index);
-			spin_unlock(&fs_info->reada_lock);
+			__xa_erase(&fs_info->reada_array, index);
+			reada_unlock(fs_info);
 			btrfs_dev_replace_unlock(&fs_info->dev_replace, 0);
 			goto error;
 		}
 		have_zone = 1;
 	}
-	spin_unlock(&fs_info->reada_lock);
+	reada_unlock(fs_info);
 	btrfs_dev_replace_unlock(&fs_info->dev_replace, 0);
 
 	if (!have_zone)
@@ -473,16 +466,16 @@ static struct reada_extent *reada_find_extent(struct btrfs_fs_info *fs_info,
 		--zone->elems;
 		if (zone->elems == 0) {
 			/*
-			 * no fs_info->reada_lock needed, as this can't be
-			 * the last ref
+			 * no fs_info->reada_array lock needed, as this
+			 * can't be the last ref
 			 */
 			kref_put(&zone->refcnt, reada_zone_release);
 		}
 		spin_unlock(&zone->lock);
 
-		spin_lock(&fs_info->reada_lock);
+		reada_lock(fs_info);
 		kref_put(&zone->refcnt, reada_zone_release);
-		spin_unlock(&fs_info->reada_lock);
+		reada_unlock(fs_info);
 	}
 	btrfs_put_bbio(bbio);
 	kfree(re);
@@ -495,20 +488,20 @@ static void reada_extent_put(struct btrfs_fs_info *fs_info,
 	int i;
 	unsigned long index = re->logical >> PAGE_SHIFT;
 
-	spin_lock(&fs_info->reada_lock);
+	reada_lock(fs_info);
 	if (--re->refcnt) {
-		spin_unlock(&fs_info->reada_lock);
+		reada_unlock(fs_info);
 		return;
 	}
 
-	radix_tree_delete(&fs_info->reada_tree, index);
+	__xa_erase(&fs_info->reada_array, index);
 	for (i = 0; i < re->nzones; ++i) {
 		struct reada_zone *zone = re->zones[i];
 
 		xa_erase(&zone->device->reada_extents, index);
 	}
 
-	spin_unlock(&fs_info->reada_lock);
+	reada_unlock(fs_info);
 
 	for (i = 0; i < re->nzones; ++i) {
 		struct reada_zone *zone = re->zones[i];
@@ -517,15 +510,17 @@ static void reada_extent_put(struct btrfs_fs_info *fs_info,
 		spin_lock(&zone->lock);
 		--zone->elems;
 		if (zone->elems == 0) {
-			/* no fs_info->reada_lock needed, as this can't be
-			 * the last ref */
+			/*
+			 * no fs_info->reada_array lock needed, as this
+			 * can't be the last ref
+			 */
 			kref_put(&zone->refcnt, reada_zone_release);
 		}
 		spin_unlock(&zone->lock);
 
-		spin_lock(&fs_info->reada_lock);
+		reada_lock(fs_info);
 		kref_put(&zone->refcnt, reada_zone_release);
-		spin_unlock(&fs_info->reada_lock);
+		reada_unlock(fs_info);
 	}
 
 	kfree(re);
@@ -579,7 +574,7 @@ static int reada_add_block(struct reada_control *rc, u64 logical,
 }
 
 /*
- * called with fs_info->reada_lock held
+ * called with fs_info->reada_array lock held
  */
 static void reada_peer_zones_set_lock(struct reada_zone *zone, int lock)
 {
@@ -595,7 +590,7 @@ static void reada_peer_zones_set_lock(struct reada_zone *zone, int lock)
 }
 
 /*
- * called with fs_info->reada_lock held
+ * called with fs_info->reada_array lock held
  */
 static int reada_pick_zone(struct btrfs_device *dev)
 {
@@ -649,11 +644,11 @@ static int reada_start_machine_dev(struct btrfs_device *dev)
 	int ret;
 	int i;
 
-	spin_lock(&fs_info->reada_lock);
+	reada_lock(fs_info);
 	if (dev->reada_curr_zone == NULL) {
 		ret = reada_pick_zone(dev);
 		if (!ret) {
-			spin_unlock(&fs_info->reada_lock);
+			reada_unlock(fs_info);
 			return 0;
 		}
 	}
@@ -667,7 +662,7 @@ static int reada_start_machine_dev(struct btrfs_device *dev)
 	if (!re || re->logical > dev->reada_curr_zone->end) {
 		ret = reada_pick_zone(dev);
 		if (!ret) {
-			spin_unlock(&fs_info->reada_lock);
+			reada_unlock(fs_info);
 			return 0;
 		}
 		index = dev->reada_next >> PAGE_SHIFT;
@@ -675,13 +670,13 @@ static int reada_start_machine_dev(struct btrfs_device *dev)
 								XA_PRESENT);
 	}
 	if (!re) {
-		spin_unlock(&fs_info->reada_lock);
+		reada_unlock(fs_info);
 		return 0;
 	}
 	dev->reada_next = re->logical + fs_info->nodesize;
 	re->refcnt++;
 
-	spin_unlock(&fs_info->reada_lock);
+	reada_unlock(fs_info);
 
 	spin_lock(&re->lock);
 	if (re->scheduled || list_empty(&re->extctl)) {
@@ -806,7 +801,7 @@ static void dump_devs(struct btrfs_fs_info *fs_info, int all)
 	int j;
 	int cnt;
 
-	spin_lock(&fs_info->reada_lock);
+	reada_lock(fs_info);
 	list_for_each_entry(device, &fs_devices->devices, dev_list) {
 		struct reada_zone *zone;
 
@@ -859,11 +854,11 @@ static void dump_devs(struct btrfs_fs_info *fs_info, int all)
 	index = 0;
 	cnt = 0;
 	while (all) {
-		struct reada_extent *re = NULL;
+		struct reada_extent *re;
 
-		ret = radix_tree_gang_lookup(&fs_info->reada_tree, (void **)&re,
-					     index, 1);
-		if (ret == 0)
+		re = xa_find(&fs_info->reada_tree, &index, ULONG_MAX,
+								XA_PRESENT);
+		if (!re)
 			break;
 		if (!re->scheduled) {
 			index = (re->logical >> PAGE_SHIFT) + 1;
@@ -882,9 +877,9 @@ static void dump_devs(struct btrfs_fs_info *fs_info, int all)
 			}
 		}
 		pr_cont("\n");
-		index = (re->logical >> PAGE_SHIFT) + 1;
+		index++;
 	}
-	spin_unlock(&fs_info->reada_lock);
+	reada_unlock(fs_info);
 }
 #endif
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
