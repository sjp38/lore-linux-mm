Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE30E280284
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:07 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id o11so12182704pgp.14
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n127si459078pga.376.2018.01.17.12.23.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:06 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 89/99] btrfs: Convert buffer_radix to XArray
Date: Wed, 17 Jan 2018 12:21:53 -0800
Message-Id: <20180117202203.19756-90-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Eliminate the buffer_lock as the internal xa_lock provides all the
necessary protection.  We can remove the radix_tree_preload calls, but
I can't find a good way to use the 'exists' result from xa_cmpxchg().
We could resort to the advanced API to improve this, but it's a really
unlikely case (nothing in the xarray when we first look; something there
when we try to add the newly-allocated extent buffer), so I think it's
not worth optimising for.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/btrfs/ctree.h             |  5 ++-
 fs/btrfs/disk-io.c           |  3 +-
 fs/btrfs/extent_io.c         | 82 ++++++++++++++++++--------------------------
 fs/btrfs/tests/btrfs-tests.c | 26 +++-----------
 4 files changed, 40 insertions(+), 76 deletions(-)

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index 272d099bed7e..87984ce3a4c2 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -1058,9 +1058,8 @@ struct btrfs_fs_info {
 	/* readahead works cnt */
 	atomic_t reada_works_cnt;
 
-	/* Extent buffer radix tree */
-	spinlock_t buffer_lock;
-	struct radix_tree_root buffer_radix;
+	/* Extent buffer array */
+	struct xarray buffer_array;
 
 	/* next backup root to be overwritten */
 	int backup_root_index;
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 1eae29045d43..650d1350b64d 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -2429,7 +2429,7 @@ int open_ctree(struct super_block *sb,
 	}
 
 	xa_init(&fs_info->fs_roots);
-	INIT_RADIX_TREE(&fs_info->buffer_radix, GFP_ATOMIC);
+	xa_init(&fs_info->buffer_array);
 	INIT_LIST_HEAD(&fs_info->trans_list);
 	INIT_LIST_HEAD(&fs_info->dead_roots);
 	INIT_LIST_HEAD(&fs_info->delayed_iputs);
@@ -2442,7 +2442,6 @@ int open_ctree(struct super_block *sb,
 	spin_lock_init(&fs_info->tree_mod_seq_lock);
 	spin_lock_init(&fs_info->super_lock);
 	spin_lock_init(&fs_info->qgroup_op_lock);
-	spin_lock_init(&fs_info->buffer_lock);
 	spin_lock_init(&fs_info->unused_bgs_lock);
 	rwlock_init(&fs_info->tree_mod_log_lock);
 	mutex_init(&fs_info->unused_bg_unpin_mutex);
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index fd5e9d887328..2b43fa11c9e2 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -4884,8 +4884,7 @@ struct extent_buffer *find_extent_buffer(struct btrfs_fs_info *fs_info,
 	struct extent_buffer *eb;
 
 	rcu_read_lock();
-	eb = radix_tree_lookup(&fs_info->buffer_radix,
-			       start >> PAGE_SHIFT);
+	eb = xa_load(&fs_info->buffer_array, start >> PAGE_SHIFT);
 	if (eb && atomic_inc_not_zero(&eb->refs)) {
 		rcu_read_unlock();
 		/*
@@ -4919,31 +4918,24 @@ struct extent_buffer *find_extent_buffer(struct btrfs_fs_info *fs_info,
 struct extent_buffer *alloc_test_extent_buffer(struct btrfs_fs_info *fs_info,
 					u64 start)
 {
-	struct extent_buffer *eb, *exists = NULL;
-	int ret;
+	struct extent_buffer *exists, *eb = NULL;
 
-	eb = find_extent_buffer(fs_info, start);
-	if (eb)
-		return eb;
-	eb = alloc_dummy_extent_buffer(fs_info, start);
-	if (!eb)
-		return NULL;
-	eb->fs_info = fs_info;
 again:
-	ret = radix_tree_preload(GFP_NOFS);
-	if (ret)
+	exists = find_extent_buffer(fs_info, start);
+	if (exists)
 		goto free_eb;
-	spin_lock(&fs_info->buffer_lock);
-	ret = radix_tree_insert(&fs_info->buffer_radix,
-				start >> PAGE_SHIFT, eb);
-	spin_unlock(&fs_info->buffer_lock);
-	radix_tree_preload_end();
-	if (ret == -EEXIST) {
-		exists = find_extent_buffer(fs_info, start);
-		if (exists)
+	if (!eb)
+		eb = alloc_dummy_extent_buffer(fs_info, start);
+	if (!eb)
+		return NULL;
+	exists = xa_cmpxchg(&fs_info->buffer_array, start >> PAGE_SHIFT,
+				NULL, eb, GFP_NOFS);
+	if (unlikely(exists)) {
+		if (xa_is_err(exists)) {
+			exists = NULL;
 			goto free_eb;
-		else
-			goto again;
+		}
+		goto again;
 	}
 	check_buffer_tree_ref(eb);
 	set_bit(EXTENT_BUFFER_IN_TREE, &eb->bflags);
@@ -4957,7 +4949,8 @@ struct extent_buffer *alloc_test_extent_buffer(struct btrfs_fs_info *fs_info,
 	atomic_inc(&eb->refs);
 	return eb;
 free_eb:
-	btrfs_release_extent_buffer(eb);
+	if (eb)
+		btrfs_release_extent_buffer(eb);
 	return exists;
 }
 #endif
@@ -4969,22 +4962,24 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 	unsigned long num_pages = num_extent_pages(start, len);
 	unsigned long i;
 	unsigned long index = start >> PAGE_SHIFT;
-	struct extent_buffer *eb;
+	struct extent_buffer *eb = NULL;
 	struct extent_buffer *exists = NULL;
 	struct page *p;
 	struct address_space *mapping = fs_info->btree_inode->i_mapping;
 	int uptodate = 1;
-	int ret;
 
 	if (!IS_ALIGNED(start, fs_info->sectorsize)) {
 		btrfs_err(fs_info, "bad tree block start %llu", start);
 		return ERR_PTR(-EINVAL);
 	}
 
-	eb = find_extent_buffer(fs_info, start);
-	if (eb)
-		return eb;
+again:
+	exists = find_extent_buffer(fs_info, start);
+	if (exists)
+		goto free_eb;
 
+	if (eb)
+		goto add;
 	eb = __alloc_extent_buffer(fs_info, start, len);
 	if (!eb)
 		return ERR_PTR(-ENOMEM);
@@ -5037,24 +5032,15 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 	}
 	if (uptodate)
 		set_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags);
-again:
-	ret = radix_tree_preload(GFP_NOFS);
-	if (ret) {
-		exists = ERR_PTR(ret);
-		goto free_eb;
-	}
-
-	spin_lock(&fs_info->buffer_lock);
-	ret = radix_tree_insert(&fs_info->buffer_radix,
-				start >> PAGE_SHIFT, eb);
-	spin_unlock(&fs_info->buffer_lock);
-	radix_tree_preload_end();
-	if (ret == -EEXIST) {
-		exists = find_extent_buffer(fs_info, start);
-		if (exists)
+add:
+	exists = xa_cmpxchg(&fs_info->buffer_array, start >> PAGE_SHIFT,
+				NULL, eb, GFP_NOFS);
+	if (unlikely(exists)) {
+		if (xa_is_err(exists)) {
+			exists = NULL;
 			goto free_eb;
-		else
-			goto again;
+		}
+		goto again;
 	}
 	/* add one reference for the tree */
 	check_buffer_tree_ref(eb);
@@ -5107,10 +5093,8 @@ static int release_extent_buffer(struct extent_buffer *eb)
 
 			spin_unlock(&eb->refs_lock);
 
-			spin_lock(&fs_info->buffer_lock);
-			radix_tree_delete(&fs_info->buffer_radix,
+			xa_erase(&fs_info->buffer_array,
 					  eb->start >> PAGE_SHIFT);
-			spin_unlock(&fs_info->buffer_lock);
 		} else {
 			spin_unlock(&eb->refs_lock);
 		}
diff --git a/fs/btrfs/tests/btrfs-tests.c b/fs/btrfs/tests/btrfs-tests.c
index 570bce31a301..f80fd54903e9 100644
--- a/fs/btrfs/tests/btrfs-tests.c
+++ b/fs/btrfs/tests/btrfs-tests.c
@@ -110,7 +110,6 @@ struct btrfs_fs_info *btrfs_alloc_dummy_fs_info(u32 nodesize, u32 sectorsize)
 		return NULL;
 	}
 
-	spin_lock_init(&fs_info->buffer_lock);
 	spin_lock_init(&fs_info->qgroup_lock);
 	spin_lock_init(&fs_info->qgroup_op_lock);
 	spin_lock_init(&fs_info->super_lock);
@@ -125,7 +124,7 @@ struct btrfs_fs_info *btrfs_alloc_dummy_fs_info(u32 nodesize, u32 sectorsize)
 	INIT_LIST_HEAD(&fs_info->dirty_qgroups);
 	INIT_LIST_HEAD(&fs_info->dead_roots);
 	INIT_LIST_HEAD(&fs_info->tree_mod_seq_list);
-	INIT_RADIX_TREE(&fs_info->buffer_radix, GFP_ATOMIC);
+	xa_init(&fs_info->buffer_array);
 	xa_init(&fs_info->fs_roots);
 	extent_io_tree_init(&fs_info->freed_extents[0], NULL);
 	extent_io_tree_init(&fs_info->freed_extents[1], NULL);
@@ -139,8 +138,8 @@ struct btrfs_fs_info *btrfs_alloc_dummy_fs_info(u32 nodesize, u32 sectorsize)
 
 void btrfs_free_dummy_fs_info(struct btrfs_fs_info *fs_info)
 {
-	struct radix_tree_iter iter;
-	void **slot;
+	struct extent_buffer *eb;
+	unsigned long index = 0;
 
 	if (!fs_info)
 		return;
@@ -151,25 +150,8 @@ void btrfs_free_dummy_fs_info(struct btrfs_fs_info *fs_info)
 
 	test_mnt->mnt_sb->s_fs_info = NULL;
 
-	spin_lock(&fs_info->buffer_lock);
-	radix_tree_for_each_slot(slot, &fs_info->buffer_radix, &iter, 0) {
-		struct extent_buffer *eb;
-
-		eb = radix_tree_deref_slot_protected(slot, &fs_info->buffer_lock);
-		if (!eb)
-			continue;
-		/* Shouldn't happen but that kind of thinking creates CVE's */
-		if (radix_tree_exception(eb)) {
-			if (radix_tree_deref_retry(eb))
-				slot = radix_tree_iter_retry(&iter);
-			continue;
-		}
-		slot = radix_tree_iter_resume(slot, &iter);
-		spin_unlock(&fs_info->buffer_lock);
+	xa_for_each(&fs_info->buffer_array, eb, index, ULONG_MAX, XA_PRESENT)
 		free_extent_buffer_stale(eb);
-		spin_lock(&fs_info->buffer_lock);
-	}
-	spin_unlock(&fs_info->buffer_lock);
 
 	btrfs_free_qgroup_config(fs_info);
 	btrfs_free_fs_roots(fs_info);
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
