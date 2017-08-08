Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C7D286B02C3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 02:50:34 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r133so26089073pgr.6
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 23:50:34 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f35si453761plh.628.2017.08.07.23.50.32
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 23:50:33 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 4/6] mm:swap: use on-stack-bio for BDI_CAP_SYNC devices
Date: Tue,  8 Aug 2017 15:50:22 +0900
Message-Id: <1502175024-28338-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1502175024-28338-1-git-send-email-minchan@kernel.org>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>

There is no need to use dynamic bio allocation for BDI_CAP_SYNC
devices. They can live with on-stack-bio without concern about
waiting bio allocation from mempool under heavy memory pressure.

It would be much better for swap devices because the bio mempool
for swap IO have been used with fs. It means super-fast swap
IO like zram don't need to depends on slow eMMC read/write
completion.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h |   3 +-
 mm/page_io.c         | 123 +++++++++++++++++++++++++++++++++++----------------
 mm/swapfile.c        |   3 ++
 3 files changed, 89 insertions(+), 40 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index ae3da979a7b7..6ed9b6423f7d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -152,8 +152,9 @@ enum {
 	SWP_AREA_DISCARD = (1 << 8),	/* single-time swap area discards */
 	SWP_PAGE_DISCARD = (1 << 9),	/* freed swap page-cluster discards */
 	SWP_STABLE_WRITES = (1 << 10),	/* no overwrite PG_writeback pages */
+	SWP_SYNC_IO	= (1<<11),	/* synchronous IO is efficient */
 					/* add others here before... */
-	SWP_SCANNING	= (1 << 11),	/* refcount in scan_swap_map */
+	SWP_SCANNING	= (1 << 12),	/* refcount in scan_swap_map */
 };
 
 #define SWAP_CLUSTER_MAX 32UL
diff --git a/mm/page_io.c b/mm/page_io.c
index 3502a97f7c48..d794fd810773 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -44,7 +44,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
 	return bio;
 }
 
-void end_swap_bio_write(struct bio *bio)
+void end_swap_bio_write_simple(struct bio *bio)
 {
 	struct page *page = bio->bi_io_vec[0].bv_page;
 
@@ -66,6 +66,11 @@ void end_swap_bio_write(struct bio *bio)
 		ClearPageReclaim(page);
 	}
 	end_page_writeback(page);
+}
+
+void end_swap_bio_write(struct bio *bio)
+{
+	end_swap_bio_write_simple(bio);
 	bio_put(bio);
 }
 
@@ -117,10 +122,9 @@ static void swap_slot_free_notify(struct page *page)
 	}
 }
 
-static void end_swap_bio_read(struct bio *bio)
+static void end_swap_bio_read_simple(struct bio *bio)
 {
 	struct page *page = bio->bi_io_vec[0].bv_page;
-	struct task_struct *waiter = bio->bi_private;
 
 	if (bio->bi_status) {
 		SetPageError(page);
@@ -136,6 +140,13 @@ static void end_swap_bio_read(struct bio *bio)
 	swap_slot_free_notify(page);
 out:
 	unlock_page(page);
+}
+
+static void end_swap_bio_read(struct bio *bio)
+{
+	struct task_struct *waiter = bio->bi_private;
+
+	end_swap_bio_read_simple(bio);
 	WRITE_ONCE(bio->bi_private, NULL);
 	bio_put(bio);
 	wake_up_process(waiter);
@@ -275,7 +286,6 @@ static inline void count_swpout_vm_event(struct page *page)
 
 int __swap_writepage(struct page *page, struct writeback_control *wbc)
 {
-	struct bio *bio;
 	int ret;
 	struct swap_info_struct *sis = page_swap_info(page);
 
@@ -328,25 +338,43 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc)
 	}
 
 	ret = 0;
-	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
-	if (bio == NULL) {
-		set_page_dirty(page);
+	if (!(sis->flags & SWP_SYNC_IO)) {
+		struct bio *bio;
+
+		bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
+		if (bio == NULL) {
+			set_page_dirty(page);
+			unlock_page(page);
+			ret = -ENOMEM;
+			goto out;
+		}
+		bio->bi_opf = REQ_OP_WRITE | wbc_to_write_flags(wbc);
+		set_page_writeback(page);
 		unlock_page(page);
-		ret = -ENOMEM;
-		goto out;
+		submit_bio(bio);
+	} else {
+
+		/* on-stack-bio */
+		struct bio sbio;
+		struct bio_vec bvec;
+
+		bio_init(&sbio, &bvec, 1);
+		sbio.bi_bdev = sis->bdev;
+		sbio.bi_iter.bi_sector = swap_page_sector(page);
+		sbio.bi_end_io = end_swap_bio_write_simple;
+		bio_add_page(&sbio, page, PAGE_SIZE, 0);
+		bio_set_op_attrs(&sbio, REQ_OP_WRITE, wbc_to_write_flags(wbc));
+		set_page_writeback(page);
+		unlock_page(page);
+		submit_bio(&sbio);
 	}
-	bio->bi_opf = REQ_OP_WRITE | wbc_to_write_flags(wbc);
 	count_swpout_vm_event(page);
-	set_page_writeback(page);
-	unlock_page(page);
-	submit_bio(bio);
 out:
 	return ret;
 }
 
 int swap_readpage(struct page *page, bool do_poll)
 {
-	struct bio *bio;
 	int ret = 0;
 	struct swap_info_struct *sis = page_swap_info(page);
 	blk_qc_t qc;
@@ -383,33 +411,50 @@ int swap_readpage(struct page *page, bool do_poll)
 	}
 
 	ret = 0;
-	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
-	if (bio == NULL) {
-		unlock_page(page);
-		ret = -ENOMEM;
-		goto out;
-	}
-	bdev = bio->bi_bdev;
-	/*
-	 * Keep this task valid during swap readpage because the oom killer may
-	 * attempt to access it in the page fault retry time check.
-	 */
-	get_task_struct(current);
-	bio->bi_private = current;
-	bio_set_op_attrs(bio, REQ_OP_READ, 0);
 	count_vm_event(PSWPIN);
-	bio_get(bio);
-	qc = submit_bio(bio);
-	while (do_poll) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		if (!READ_ONCE(bio->bi_private))
-			break;
-
-		if (!blk_mq_poll(bdev_get_queue(bdev), qc))
-			break;
+	if (!(sis->flags & SWP_SYNC_IO)) {
+		struct bio *bio;
+
+		bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
+		if (bio == NULL) {
+			unlock_page(page);
+			ret = -ENOMEM;
+			goto out;
+		}
+		bdev = bio->bi_bdev;
+		/*
+		 * Keep this task valid during swap readpage because
+		 * the oom killer may attempt to access it
+		 * in the page fault retry time check.
+		 */
+		get_task_struct(current);
+		bio->bi_private = current;
+		bio_set_op_attrs(bio, REQ_OP_READ, 0);
+		bio_get(bio);
+		qc = submit_bio(bio);
+		while (do_poll) {
+			set_current_state(TASK_UNINTERRUPTIBLE);
+			if (!READ_ONCE(bio->bi_private))
+				break;
+
+			if (!blk_mq_poll(bdev_get_queue(bdev), qc))
+				break;
+		}
+		__set_current_state(TASK_RUNNING);
+		bio_put(bio);
+	} else {
+		/* on-stack-bio */
+		struct bio sbio;
+		struct bio_vec bvec;
+
+		bio_init(&sbio, &bvec, 1);
+		sbio.bi_bdev = sis->bdev;
+		sbio.bi_iter.bi_sector = swap_page_sector(page);
+		sbio.bi_end_io = end_swap_bio_read_simple;
+		bio_add_page(&sbio, page, PAGE_SIZE, 0);
+		bio_set_op_attrs(&sbio, REQ_OP_READ, 0);
+		submit_bio(&sbio);
 	}
-	__set_current_state(TASK_RUNNING);
-	bio_put(bio);
 
 out:
 	return ret;
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 42eff9e4e972..e916b325b0b7 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3113,6 +3113,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (bdi_cap_stable_pages_required(inode_to_bdi(inode)))
 		p->flags |= SWP_STABLE_WRITES;
 
+	if (bdi_cap_synchronous_io(inode_to_bdi(inode)))
+		p->flags |= SWP_SYNC_IO;
+
 	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
 		int cpu;
 		unsigned long ci, nr_cluster;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
