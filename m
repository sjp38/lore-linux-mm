From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070301100330.29753.56840.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
References: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/12] Add __GFP_MOVABLE for callers to flag allocations from low memory that may be migrated
Date: Thu,  1 Mar 2007 10:03:30 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch flags the allocations from low memory that may be migrated.

A GFP_USER_MOVABLE similar to GFP_HIGH_MOVABLE is not provided in this patch
because it would only be used once.  This patch uses __GFP_MOVABLE twice
for a GFP_USER and a GFP_NOIO allocation. There is little point defining
GFP_*_MOVABLE for one use unless people feel it would help self-documentation.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 block_dev.c |    2 +-
 buffer.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-002_clustering_flags/fs/block_dev.c linux-2.6.20-mm2-003_additional_flags/fs/block_dev.c
--- linux-2.6.20-mm2-002_clustering_flags/fs/block_dev.c	2007-02-19 01:21:36.000000000 +0000
+++ linux-2.6.20-mm2-003_additional_flags/fs/block_dev.c	2007-02-20 18:27:38.000000000 +0000
@@ -576,7 +576,7 @@ struct block_device *bdget(dev_t dev)
 		inode->i_rdev = dev;
 		inode->i_bdev = bdev;
 		inode->i_data.a_ops = &def_blk_aops;
-		mapping_set_gfp_mask(&inode->i_data, GFP_USER);
+		mapping_set_gfp_mask(&inode->i_data, GFP_USER|__GFP_MOVABLE);
 		inode->i_data.backing_dev_info = &default_backing_dev_info;
 		spin_lock(&bdev_lock);
 		list_add(&bdev->bd_list, &all_bdevs);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-002_clustering_flags/fs/buffer.c linux-2.6.20-mm2-003_additional_flags/fs/buffer.c
--- linux-2.6.20-mm2-002_clustering_flags/fs/buffer.c	2007-02-19 01:21:36.000000000 +0000
+++ linux-2.6.20-mm2-003_additional_flags/fs/buffer.c	2007-02-20 18:27:38.000000000 +0000
@@ -2652,7 +2652,7 @@ int submit_bh(int rw, struct buffer_head
 	 * from here on down, it's all bio -- do the initial mapping,
 	 * submit_bio -> generic_make_request may further map this bio around
 	 */
-	bio = bio_alloc(GFP_NOIO, 1);
+	bio = bio_alloc(GFP_NOIO|__GFP_MOVABLE, 1);
 
 	bio->bi_sector = bh->b_blocknr * (bh->b_size >> 9);
 	bio->bi_bdev = bh->b_bdev;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
