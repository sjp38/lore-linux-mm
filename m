Message-Id: <20070504103202.950175722@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:23 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 32/40] block: add a swapdev callback to the request_queue
Content-Disposition: inline; filename=blk_queue_swapdev.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

Networked storage devices need a swap-on/off callback in order to setup
some state and reserve memory. Place the block device callback in the
request_queue as suggested by James Bottomley.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jens Axboe <jens.axboe@oracle.com>
Cc: James Bottomley <James.Bottomley@SteelEye.com>
---
 include/linux/blkdev.h |   19 +++++++++++++++++++
 mm/swapfile.c          |    4 ++++
 2 files changed, 23 insertions(+)

Index: linux-2.6-git/include/linux/blkdev.h
===================================================================
--- linux-2.6-git.orig/include/linux/blkdev.h	2007-01-08 11:53:13.000000000 +0100
+++ linux-2.6-git/include/linux/blkdev.h	2007-01-16 14:14:50.000000000 +0100
@@ -341,6 +341,7 @@ typedef int (merge_bvec_fn) (request_que
 typedef int (issue_flush_fn) (request_queue_t *, struct gendisk *, sector_t *);
 typedef void (prepare_flush_fn) (request_queue_t *, struct request *);
 typedef void (softirq_done_fn)(struct request *);
+typedef int (swapdev_fn)(void*, int);
 
 enum blk_queue_state {
 	Queue_down,
@@ -379,6 +380,8 @@ struct request_queue
 	issue_flush_fn		*issue_flush_fn;
 	prepare_flush_fn	*prepare_flush_fn;
 	softirq_done_fn		*softirq_done_fn;
+	swapdev_fn		*swapdev_fn;
+	void			*swapdev_obj;
 
 	/*
 	 * Dispatch queue sorting
@@ -766,6 +769,22 @@ request_queue_t *blk_alloc_queue(gfp_t);
 request_queue_t *blk_alloc_queue_node(gfp_t, int);
 extern void blk_put_queue(request_queue_t *);
 
+static inline
+void blk_queue_swapdev(struct request_queue *rq,
+		       swapdev_fn *swapdev_fn, void *swapdev_obj)
+{
+	rq->swapdev_fn = swapdev_fn;
+	rq->swapdev_obj = swapdev_obj;
+}
+
+static inline
+int blk_queue_swapdev_fn(struct request_queue *rq, int enable)
+{
+	if (rq->swapdev_fn)
+		return rq->swapdev_fn(rq->swapdev_obj, enable);
+	return 0;
+}
+
 /*
  * tag stuff
  */
Index: linux-2.6-git/mm/swapfile.c
===================================================================
--- linux-2.6-git.orig/mm/swapfile.c	2007-01-15 09:59:02.000000000 +0100
+++ linux-2.6-git/mm/swapfile.c	2007-01-16 14:14:50.000000000 +0100
@@ -1305,6 +1305,7 @@ asmlinkage long sys_swapoff(const char _
 	inode = mapping->host;
 	if (S_ISBLK(inode->i_mode)) {
 		struct block_device *bdev = I_BDEV(inode);
+		blk_queue_swapdev_fn(bdev->bd_disk->queue, 0);
 		set_blocksize(bdev, p->old_block_size);
 		bd_release(bdev);
 	} else {
@@ -1524,6 +1525,9 @@ asmlinkage long sys_swapon(const char __
 		error = set_blocksize(bdev, PAGE_SIZE);
 		if (error < 0)
 			goto bad_swap;
+		error = blk_queue_swapdev_fn(bdev->bd_disk->queue, 1);
+		if (error < 0)
+			goto bad_swap;
 		p->bdev = bdev;
 	} else if (S_ISREG(inode->i_mode)) {
 		p->bdev = inode->i_sb->s_bdev;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
