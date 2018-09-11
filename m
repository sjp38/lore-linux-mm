Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0163D8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 18:35:18 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j15-v6so13409295pff.12
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 15:35:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7-v6sor3209868pgc.197.2018.09.11.15.35.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Sep 2018 15:35:17 -0700 (PDT)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v7 5/6] Btrfs: rename get_chunk_map() and make it non-static
Date: Tue, 11 Sep 2018 15:34:48 -0700
Message-Id: <898dc638c0323a2da9401f03f37db89a4df446a2.1536704650.git.osandov@fb.com>
In-Reply-To: <cover.1536704650.git.osandov@fb.com>
References: <cover.1536704650.git.osandov@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org
Cc: kernel-team@fb.com, linux-mm@kvack.org

From: Omar Sandoval <osandov@fb.com>

The Btrfs swap code is going to need it, so give it a btrfs_ prefix and
make it non-static.

Reviewed-by: Nikolay Borisov <nborisov@suse.com>
Signed-off-by: Omar Sandoval <osandov@fb.com>
---
 fs/btrfs/volumes.c | 29 ++++++++++++++++++-----------
 fs/btrfs/volumes.h |  2 ++
 2 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/fs/btrfs/volumes.c b/fs/btrfs/volumes.c
index a2761395ed22..fe66b635c023 100644
--- a/fs/btrfs/volumes.c
+++ b/fs/btrfs/volumes.c
@@ -2714,8 +2714,15 @@ static int btrfs_del_sys_chunk(struct btrfs_fs_info *fs_info, u64 chunk_offset)
 	return ret;
 }
 
-static struct extent_map *get_chunk_map(struct btrfs_fs_info *fs_info,
-					u64 logical, u64 length)
+/**
+ * btrfs_get_chunk_map() - Find the mapping containing the given logical extent.
+ * @logical: Logical block offset in bytes.
+ * @length: Length of extent in bytes.
+ *
+ * Return: Chunk mapping or ERR_PTR.
+ */
+struct extent_map *btrfs_get_chunk_map(struct btrfs_fs_info *fs_info,
+				       u64 logical, u64 length)
 {
 	struct extent_map_tree *em_tree;
 	struct extent_map *em;
@@ -2752,7 +2759,7 @@ int btrfs_remove_chunk(struct btrfs_trans_handle *trans, u64 chunk_offset)
 	int i, ret = 0;
 	struct btrfs_fs_devices *fs_devices = fs_info->fs_devices;
 
-	em = get_chunk_map(fs_info, chunk_offset, 1);
+	em = btrfs_get_chunk_map(fs_info, chunk_offset, 1);
 	if (IS_ERR(em)) {
 		/*
 		 * This is a logic error, but we don't want to just rely on the
@@ -4902,7 +4909,7 @@ int btrfs_finish_chunk_alloc(struct btrfs_trans_handle *trans,
 	int i = 0;
 	int ret = 0;
 
-	em = get_chunk_map(fs_info, chunk_offset, chunk_size);
+	em = btrfs_get_chunk_map(fs_info, chunk_offset, chunk_size);
 	if (IS_ERR(em))
 		return PTR_ERR(em);
 
@@ -5044,7 +5051,7 @@ int btrfs_chunk_readonly(struct btrfs_fs_info *fs_info, u64 chunk_offset)
 	int miss_ndevs = 0;
 	int i;
 
-	em = get_chunk_map(fs_info, chunk_offset, 1);
+	em = btrfs_get_chunk_map(fs_info, chunk_offset, 1);
 	if (IS_ERR(em))
 		return 1;
 
@@ -5104,7 +5111,7 @@ int btrfs_num_copies(struct btrfs_fs_info *fs_info, u64 logical, u64 len)
 	struct map_lookup *map;
 	int ret;
 
-	em = get_chunk_map(fs_info, logical, len);
+	em = btrfs_get_chunk_map(fs_info, logical, len);
 	if (IS_ERR(em))
 		/*
 		 * We could return errors for these cases, but that could get
@@ -5150,7 +5157,7 @@ unsigned long btrfs_full_stripe_len(struct btrfs_fs_info *fs_info,
 	struct map_lookup *map;
 	unsigned long len = fs_info->sectorsize;
 
-	em = get_chunk_map(fs_info, logical, len);
+	em = btrfs_get_chunk_map(fs_info, logical, len);
 
 	if (!WARN_ON(IS_ERR(em))) {
 		map = em->map_lookup;
@@ -5167,7 +5174,7 @@ int btrfs_is_parity_mirror(struct btrfs_fs_info *fs_info, u64 logical, u64 len)
 	struct map_lookup *map;
 	int ret = 0;
 
-	em = get_chunk_map(fs_info, logical, len);
+	em = btrfs_get_chunk_map(fs_info, logical, len);
 
 	if(!WARN_ON(IS_ERR(em))) {
 		map = em->map_lookup;
@@ -5326,7 +5333,7 @@ static int __btrfs_map_block_for_discard(struct btrfs_fs_info *fs_info,
 	/* discard always return a bbio */
 	ASSERT(bbio_ret);
 
-	em = get_chunk_map(fs_info, logical, length);
+	em = btrfs_get_chunk_map(fs_info, logical, length);
 	if (IS_ERR(em))
 		return PTR_ERR(em);
 
@@ -5652,7 +5659,7 @@ static int __btrfs_map_block(struct btrfs_fs_info *fs_info,
 		return __btrfs_map_block_for_discard(fs_info, logical,
 						     *length, bbio_ret);
 
-	em = get_chunk_map(fs_info, logical, *length);
+	em = btrfs_get_chunk_map(fs_info, logical, *length);
 	if (IS_ERR(em))
 		return PTR_ERR(em);
 
@@ -5951,7 +5958,7 @@ int btrfs_rmap_block(struct btrfs_fs_info *fs_info, u64 chunk_start,
 	u64 rmap_len;
 	int i, j, nr = 0;
 
-	em = get_chunk_map(fs_info, chunk_start, 1);
+	em = btrfs_get_chunk_map(fs_info, chunk_start, 1);
 	if (IS_ERR(em))
 		return -EIO;
 
diff --git a/fs/btrfs/volumes.h b/fs/btrfs/volumes.h
index 23e9285d88de..f4c190c2ab84 100644
--- a/fs/btrfs/volumes.h
+++ b/fs/btrfs/volumes.h
@@ -465,6 +465,8 @@ unsigned long btrfs_full_stripe_len(struct btrfs_fs_info *fs_info,
 int btrfs_finish_chunk_alloc(struct btrfs_trans_handle *trans,
 			     u64 chunk_offset, u64 chunk_size);
 int btrfs_remove_chunk(struct btrfs_trans_handle *trans, u64 chunk_offset);
+struct extent_map *btrfs_get_chunk_map(struct btrfs_fs_info *fs_info,
+				       u64 logical, u64 length);
 
 static inline void btrfs_dev_stat_inc(struct btrfs_device *dev,
 				      int index)
-- 
2.18.0
