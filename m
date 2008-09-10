Date: Wed, 10 Sep 2008 20:51:36 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC PATCH] discarding swap
In-Reply-To: <20080910173518.GD20055@kernel.dk>
Message-ID: <Pine.LNX.4.64.0809102015230.16131@blonde.site>
References: <Pine.LNX.4.64.0809092222110.25727@blonde.site>
 <20080910173518.GD20055@kernel.dk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: David Woodhouse <dwmw2@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Sep 2008, Jens Axboe wrote:
> On Tue, Sep 09 2008, Hugh Dickins wrote:
> 
> > It seems odd to me that the data-less blkdev_issue_discard() is limited
> > at all by max_hw_sectors; but I'm guessing there's a good reason, safety
> > perhaps, which has forced you to that.
> 
> The discard request needs to be turned into a hw command at some point,
> and for that we still need to fit the offset and size in there. So we
> are still limited by 32MB commands on sata w/lba48, even though we are
> not moving any data. Suboptimal, but...

... makes good sense, thanks.

> > Here's the proposed patch, or combination of patches: the blkdev and
> > swap parts should certainly be separated.  Advice welcome - thanks!
> 
> I'll snatch up the blk bits and put them in for-2.6.28. OK if I add your
> SOB to that?

That would be great.  Thanks a lot for all your comments, I'd been
expecting a much rougher ride!  If you've not already put it in,
here's that subset of the patch - change it around as you wish.


[PATCH] block: adjust blkdev_issue_discard for swap

Three mods to blkdev_issue_discard(), thinking ahead to its use on swap:

1. Add gfp_mask argument, so swap allocation can use it where GFP_KERNEL
   might deadlock but GFP_NOIO is safe.

2. Enlarge nr_sects argument from unsigned to sector_t: unsigned long is
   enough to cover a whole swap area, but sector_t suits any partition.

3. Add an occasional cond_resched() into the loop, to avoid risking bad
   latencies when discarding a large area in small max_hw_sectors steps.

Change sb_issue_discard()'s nr_blocks to sector_t too; but no need seen
for a gfp_mask there, just pass GFP_KERNEL down to blkdev_issue_discard().

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 block/blk-barrier.c    |   11 ++++++++---
 include/linux/blkdev.h |    9 +++++----
 2 files changed, 13 insertions(+), 7 deletions(-)

--- 2.6.27-rc5-mm1/block/blk-barrier.c	2008-09-05 10:05:33.000000000 +0100
+++ linux/block/blk-barrier.c	2008-09-09 20:00:26.000000000 +0100
@@ -332,15 +332,17 @@ static void blkdev_discard_end_io(struct
  * @bdev:	blockdev to issue discard for
  * @sector:	start sector
  * @nr_sects:	number of sectors to discard
+ * @gfp_mask:	memory allocation flags (for bio_alloc)
  *
  * Description:
  *    Issue a discard request for the sectors in question. Does not wait.
  */
-int blkdev_issue_discard(struct block_device *bdev, sector_t sector,
-			 unsigned nr_sects)
+int blkdev_issue_discard(struct block_device *bdev,
+			 sector_t sector, sector_t nr_sects, gfp_t gfp_mask)
 {
 	struct request_queue *q;
 	struct bio *bio;
+	unsigned int iters = 0;
 	int ret = 0;
 
 	if (bdev->bd_disk == NULL)
@@ -354,7 +356,10 @@ int blkdev_issue_discard(struct block_de
 		return -EOPNOTSUPP;
 
 	while (nr_sects && !ret) {
-		bio = bio_alloc(GFP_KERNEL, 0);
+		if ((++iters & 7) == 0)
+			cond_resched();
+
+		bio = bio_alloc(gfp_mask, 0);
 		if (!bio)
 			return -ENOMEM;
 
--- 2.6.27-rc5-mm1/include/linux/blkdev.h	2008-09-05 10:05:51.000000000 +0100
+++ linux/include/linux/blkdev.h	2008-09-09 20:00:26.000000000 +0100
@@ -16,6 +16,7 @@
 #include <linux/bio.h>
 #include <linux/module.h>
 #include <linux/stringify.h>
+#include <linux/gfp.h>
 #include <linux/bsg.h>
 #include <linux/smp.h>
 
@@ -875,15 +876,15 @@ static inline struct request *blk_map_qu
 }
 
 extern int blkdev_issue_flush(struct block_device *, sector_t *);
-extern int blkdev_issue_discard(struct block_device *, sector_t sector,
-				unsigned nr_sects);
+extern int blkdev_issue_discard(struct block_device *,
+				sector_t sector, sector_t nr_sects, gfp_t);
 
 static inline int sb_issue_discard(struct super_block *sb,
-				   sector_t block, unsigned nr_blocks)
+				   sector_t block, sector_t nr_blocks)
 {
 	block <<= (sb->s_blocksize_bits - 9);
 	nr_blocks <<= (sb->s_blocksize_bits - 9);
-	return blkdev_issue_discard(sb->s_bdev, block, nr_blocks);
+	return blkdev_issue_discard(sb->s_bdev, block, nr_blocks, GFP_KERNEL);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
