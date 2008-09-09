Date: Tue, 9 Sep 2008 22:28:41 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [RFC PATCH] discarding swap
Message-ID: <Pine.LNX.4.64.0809092222110.25727@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi David,

I notice 2.6.27-rc5-mm1 and next trees include "discard" support,
so far being used only by fat.  Is that really intended for 2.6.28?

Here's a proposed patch to use discard on swap.  But I know nothing of
the tradeoffs, nor what really goes on in such a device, and have none
to try, so this patch may be wide of the mark.

I started off with the discard_swap() in sys_swapon(): it seemed obvious
to discard all the old swap contents (except the swap header) at that
point (though it would be unfortunate if someone mistakenly does a fresh
boot of a kernel when they mean to resume from swap disk: discarding
would remove the option to back out before swap gets written).

But I've no idea how long that is liable to take on a device which really
supports discard: discarding an entire partition all at once sounds good
for giving the device the greatest freedom to reorganize itself,
but would that happen quickly enough?

To do that (and to avoid duplicating the same loop within swapfile.c),
I'd like to change the nr_sects argument to blkdev_issue_discard() from
unsigned to sector_t - unsigned long would be large enough for swap, but
sector_t makes more general sense.  And if that change is made, it's
probably right to change sb_issue_discard()'s nr_sects to match?

I also got worried that blkdev_issue_discard() might get stuck in its
loop for a very long time, requests getting freed from the queue before
it quite fills up: so inserted an occasional cond_resched().

It seems odd to me that the data-less blkdev_issue_discard() is limited
at all by max_hw_sectors; but I'm guessing there's a good reason, safety
perhaps, which has forced you to that.

Where else should swap be discarded?  I don't want to add anything into
the swap freeing path, and the locking there would be problematic.  And
I take it that doing a discard of each single page just before rewriting
it would just be a totally pointless waste of time.

But the swap allocation algorithm in scan_swap_map() does already try
to locate a free cluster of swap pages (256 of them, not tunable today
but could easily be: 1MB on x86).  So I think it makes sense to discard
the old swap when we find a free cluster (and forget about discarding
when we don't find one).  That's what I've implemented - but then,
does it still make any sense also to discard all of swap at swapon?

I think that discarding when allocating swap cannot safely use GFP_KERNEL
for its bio_alloc()s: swap_writepage() uses GFP_NOIO, so should be good.
That involves an added gfp_t arg to blkdev_issue_discard() - unless I
copy it to make a swap_issue_discard(), which seems a bad idea.

Here's the proposed patch, or combination of patches: the blkdev and
swap parts should certainly be separated.  Advice welcome - thanks!

Not-yet-Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 block/blk-barrier.c    |   11 +-
 include/linux/blkdev.h |    9 +-
 include/linux/swap.h   |   15 ++-
 mm/swapfile.c          |  168 +++++++++++++++++++++++++++++++++++++--
 4 files changed, 183 insertions(+), 20 deletions(-)

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
--- 2.6.27-rc5-mm1/include/linux/swap.h	2008-09-05 10:05:52.000000000 +0100
+++ linux/include/linux/swap.h	2008-09-09 20:00:26.000000000 +0100
@@ -119,8 +119,9 @@ struct swap_extent {
 
 enum {
 	SWP_USED	= (1 << 0),	/* is slot in swap_info[] used? */
-	SWP_WRITEOK	= (1 << 1),	/* ok to write to this swap?	*/
-	SWP_ACTIVE	= (SWP_USED | SWP_WRITEOK),
+	SWP_WRITEOK	= (1 << 1),	/* ok to write to this swap? */
+	SWP_DISCARDABLE = (1 << 2),	/* blkdev supports discard */
+	SWP_DISCARDING	= (1 << 3),	/* now discarding a free cluster */
 					/* add others here before... */
 	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
 };
@@ -134,22 +135,24 @@ enum {
  * The in-memory structure used to track swap areas.
  */
 struct swap_info_struct {
-	unsigned int flags;
+	unsigned long flags;
 	int prio;			/* swap priority */
+	int next;			/* next entry on swap list */
 	struct file *swap_file;
 	struct block_device *bdev;
 	struct list_head extent_list;
 	struct swap_extent *curr_swap_extent;
-	unsigned old_block_size;
-	unsigned short * swap_map;
+	unsigned short *swap_map;
 	unsigned int lowest_bit;
 	unsigned int highest_bit;
+	unsigned int lowest_alloc;
+	unsigned int highest_alloc;
 	unsigned int cluster_next;
 	unsigned int cluster_nr;
 	unsigned int pages;
 	unsigned int max;
 	unsigned int inuse_pages;
-	int next;			/* next entry on swap list */
+	unsigned int old_block_size;
 };
 
 struct swap_list_t {
--- 2.6.27-rc5-mm1/mm/swapfile.c	2008-09-05 10:05:54.000000000 +0100
+++ linux/mm/swapfile.c	2008-09-09 20:00:26.000000000 +0100
@@ -83,13 +83,93 @@ void swap_unplug_io_fn(struct backing_de
 	up_read(&swap_unplug_sem);
 }
 
+/*
+ * swapon tell device that all the old swap contents can be discarded,
+ * to allow the swap device to optimize its wear-levelling.
+ */
+static int discard_swap(struct swap_info_struct *si)
+{
+	struct swap_extent *se;
+	int err = 0;
+
+	list_for_each_entry(se, &si->extent_list, list) {
+		sector_t start_block = se->start_block << (PAGE_SHIFT - 9);
+		pgoff_t nr_blocks = se->nr_pages << (PAGE_SHIFT - 9);
+
+		if (se->start_page == 0) {
+			/* Do not discard the swap header page! */
+			start_block += 1 << (PAGE_SHIFT - 9);
+			nr_blocks -= 1 << (PAGE_SHIFT - 9);
+			if (!nr_blocks)
+				continue;
+		}
+
+		err = blkdev_issue_discard(si->bdev, start_block,
+						nr_blocks, GFP_KERNEL);
+		if (err)
+			break;
+
+		cond_resched();
+	}
+	return err;		/* That will often be -EOPNOTSUPP */
+}
+
+/*
+ * swap allocation tell device that a cluster of swap can now be discarded,
+ * to allow the swap device to optimize its wear-levelling.
+ */
+static void discard_swap_cluster(struct swap_info_struct *si,
+				 pgoff_t start_page, pgoff_t nr_pages)
+{
+	struct swap_extent *se = si->curr_swap_extent;
+	int found_extent = 0;
+
+	while (nr_pages) {
+		struct list_head *lh;
+
+		if (se->start_page <= start_page &&
+		    start_page < se->start_page + se->nr_pages) {
+			pgoff_t offset = start_page - se->start_page;
+			sector_t start_block = se->start_block + offset;
+			pgoff_t nr_blocks = se->nr_pages - offset;
+
+			if (nr_blocks > nr_pages)
+				nr_blocks = nr_pages;
+			start_page += nr_blocks;
+			nr_pages -= nr_blocks;
+
+			if (!found_extent++)
+				si->curr_swap_extent = se;
+
+			start_block <<= PAGE_SHIFT - 9;
+			nr_blocks <<= PAGE_SHIFT - 9;
+			if (blkdev_issue_discard(si->bdev, start_block,
+							nr_blocks, GFP_NOIO))
+				break;
+		}
+
+		lh = se->list.next;
+		if (lh == &si->extent_list)
+			lh = lh->next;
+		se = list_entry(lh, struct swap_extent, list);
+	}
+}
+
+static int wait_for_discard(void *word)
+{
+	schedule();
+	return 0;
+}
+
 #define SWAPFILE_CLUSTER	256
 #define LATENCY_LIMIT		256
 
 static inline unsigned long scan_swap_map(struct swap_info_struct *si)
 {
-	unsigned long offset, last_in_cluster;
+	unsigned long offset;
+	unsigned long last_in_cluster = 0;
 	int latency_ration = LATENCY_LIMIT;
+	int found_free_cluster = 0;
 
 	/* 
 	 * We try to cluster swap pages by allocating them sequentially
@@ -102,10 +182,24 @@ static inline unsigned long scan_swap_ma
 	 */
 
 	si->flags += SWP_SCANNING;
-	if (unlikely(!si->cluster_nr)) {
-		si->cluster_nr = SWAPFILE_CLUSTER - 1;
-		if (si->pages - si->inuse_pages < SWAPFILE_CLUSTER)
+	if (unlikely(!si->cluster_nr--)) {
+		if (si->pages - si->inuse_pages < SWAPFILE_CLUSTER) {
+			si->cluster_nr = SWAPFILE_CLUSTER - 1;
 			goto lowest;
+		}
+		if (si->flags & SWP_DISCARDABLE) {
+			/*
+			 * Start range check on racing allocations, in case
+			 * they overlap the cluster we eventually decide on
+			 * (we scan without swap_lock to allow preemption).
+			 * It's hardly conceivable that cluster_nr could be
+			 * wrapped during our scan, but don't depend on it.
+			 */
+			if (si->lowest_alloc)
+				goto lowest;
+			si->lowest_alloc = si->max;
+			si->highest_alloc = 0;
+		}
 		spin_unlock(&swap_lock);
 
 		offset = si->lowest_bit;
@@ -118,6 +212,8 @@ static inline unsigned long scan_swap_ma
 			else if (offset == last_in_cluster) {
 				spin_lock(&swap_lock);
 				si->cluster_next = offset-SWAPFILE_CLUSTER+1;
+				si->cluster_nr = SWAPFILE_CLUSTER - 1;
+				found_free_cluster = 1;
 				goto cluster;
 			}
 			if (unlikely(--latency_ration < 0)) {
@@ -125,11 +221,13 @@ static inline unsigned long scan_swap_ma
 				latency_ration = LATENCY_LIMIT;
 			}
 		}
+
 		spin_lock(&swap_lock);
+		si->cluster_nr = SWAPFILE_CLUSTER - 1;
+		si->lowest_alloc = 0;
 		goto lowest;
 	}
 
-	si->cluster_nr--;
 cluster:
 	offset = si->cluster_next;
 	if (offset > si->highest_bit)
@@ -151,6 +249,60 @@ checks:	if (!(si->flags & SWP_WRITEOK))
 		si->swap_map[offset] = 1;
 		si->cluster_next = offset + 1;
 		si->flags -= SWP_SCANNING;
+
+		if (si->lowest_alloc) {
+			/*
+			 * Only set when SWP_DISCARDABLE, and there's a scan
+			 * for a free cluster in progress or just completed.
+			 */
+			if (found_free_cluster) {
+				/*
+				 * To optimize wear-levelling, discard the
+				 * old data of the cluster, taking care not to
+				 * discard any of its pages that have already
+				 * been allocated by racing tasks (offset has
+				 * already stepped over any at the beginning).
+				 */
+				if (offset < si->highest_alloc &&
+				    si->lowest_alloc <= last_in_cluster)
+					last_in_cluster = si->lowest_alloc - 1;
+				si->flags |= SWP_DISCARDING;
+				spin_unlock(&swap_lock);
+
+				if (offset < last_in_cluster)
+					discard_swap_cluster(si, offset,
+						last_in_cluster - offset + 1);
+
+				spin_lock(&swap_lock);
+				si->lowest_alloc = 0;
+				si->flags &= ~SWP_DISCARDING;
+
+				smp_mb();	/* wake_up_bit advises this */
+				wake_up_bit(&si->flags, ilog2(SWP_DISCARDING));
+
+			} else if (si->flags & SWP_DISCARDING) {
+				/*
+				 * Delay using pages allocated by racing tasks
+				 * until the whole discard has been issued. We
+				 * could defer that delay until swap_writepage,
+				 * but it's easier to keep this self-contained.
+				 */
+				spin_unlock(&swap_lock);
+				wait_on_bit(&si->flags, ilog2(SWP_DISCARDING),
+					wait_for_discard, TASK_UNINTERRUPTIBLE);
+				spin_lock(&swap_lock);
+			} else {
+				/*
+				 * Note pages allocated by racing tasks while
+				 * scan for a free cluster is in progress, so
+				 * that its final discard can exclude them.
+				 */
+				if (offset < si->lowest_alloc)
+					si->lowest_alloc = offset;
+				if (offset > si->highest_alloc)
+					si->highest_alloc = offset;
+			}
+		}
 		return offset;
 	}
 
@@ -1253,7 +1405,7 @@ asmlinkage long sys_swapoff(const char _
 	spin_lock(&swap_lock);
 	for (type = swap_list.head; type >= 0; type = swap_info[type].next) {
 		p = swap_info + type;
-		if ((p->flags & SWP_ACTIVE) == SWP_ACTIVE) {
+		if (p->flags & SWP_WRITEOK) {
 			if (p->swap_file->f_mapping == mapping)
 				break;
 		}
@@ -1687,6 +1839,8 @@ asmlinkage long sys_swapon(const char __
 		error = -EINVAL;
 		goto bad_swap;
 	}
+	if (discard_swap(p) == 0)
+		p->flags |= SWP_DISCARDABLE;
 
 	mutex_lock(&swapon_mutex);
 	spin_lock(&swap_lock);
@@ -1696,7 +1850,7 @@ asmlinkage long sys_swapon(const char __
 	else
 		p->prio = --least_priority;
 	p->swap_map = swap_map;
-	p->flags = SWP_ACTIVE;
+	p->flags |= SWP_WRITEOK;
 	nr_swap_pages += nr_good_pages;
 	total_swap_pages += nr_good_pages;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
