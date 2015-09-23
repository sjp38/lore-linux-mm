Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id CA7646B025B
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:47:52 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so29689007pac.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 21:47:52 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id cy1si7643373pad.200.2015.09.22.21.47.51
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 21:47:51 -0700 (PDT)
Subject: [PATCH 08/15] block, dax, pmem: reference counting infrastructure
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Sep 2015 00:41:55 -0400
Message-ID: <20150923044155.36490.2017.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jens Axboe <axboe@kernel.dk>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

Enable DAX to use a reference count for keeping the virtual address
returned by ->direct_access() valid for the duration of its usage in
fs/dax.c, or otherwise hold off blk_cleanup_queue() while
pmem_make_request is active.  The blk-mq code is already in a position
to need low overhead referece counting for races against request_queue
destruction (blk_cleanup_queue()).  Given DAX-enabled block drivers do
not enable blk-mq, share the storage in 'struct request_queue' between
the two implementations.

Cc: Jens Axboe <axboe@kernel.dk>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/powerpc/sysdev/axonram.c |    2 -
 block/blk-core.c              |   84 +++++++++++++++++++++++++++++++++++++++++
 block/blk-mq-sysfs.c          |    2 -
 block/blk-mq.c                |   48 ++++++-----------------
 block/blk-sysfs.c             |    9 ++++
 block/blk.h                   |    3 +
 drivers/block/brd.c           |    2 -
 drivers/nvdimm/pmem.c         |    3 +
 drivers/s390/block/dcssblk.c  |    2 -
 include/linux/blkdev.h        |   20 ++++++++--
 10 files changed, 130 insertions(+), 45 deletions(-)

diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index d2b79bc336c1..24ffab2572e8 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -228,7 +228,7 @@ static int axon_ram_probe(struct platform_device *device)
 	sprintf(bank->disk->disk_name, "%s%d",
 			AXON_RAM_DEVICE_NAME, axon_ram_bank_id);
 
-	bank->disk->queue = blk_alloc_queue(GFP_KERNEL);
+	bank->disk->queue = blk_dax_init_queue(NUMA_NO_NODE);
 	if (bank->disk->queue == NULL) {
 		dev_err(&device->dev, "Cannot register disk queue\n");
 		rc = -EFAULT;
diff --git a/block/blk-core.c b/block/blk-core.c
index 2eb722d48773..13764f8b22e0 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/writeback.h>
+#include <linux/percpu-refcount.h>
 #include <linux/task_io_accounting_ops.h>
 #include <linux/fault-inject.h>
 #include <linux/list_sort.h>
@@ -497,6 +498,84 @@ void blk_queue_bypass_end(struct request_queue *q)
 }
 EXPORT_SYMBOL_GPL(blk_queue_bypass_end);
 
+int blk_qref_enter(struct request_queue_ref *qref, gfp_t gfp)
+{
+	struct request_queue *q = container_of(qref, typeof(*q), mq_ref);
+
+	while (true) {
+		int ret;
+
+		if (percpu_ref_tryget_live(&qref->count))
+			return 0;
+
+		if (!(gfp & __GFP_WAIT))
+			return -EBUSY;
+
+		ret = wait_event_interruptible(qref->freeze_wq,
+				!atomic_read(&qref->freeze_depth) ||
+				blk_queue_dying(q));
+		if (blk_queue_dying(q))
+			return -ENODEV;
+		if (ret)
+			return ret;
+	}
+}
+
+void blk_qref_release(struct percpu_ref *ref)
+{
+	struct request_queue_ref *qref = container_of(ref, typeof(*qref), count);
+
+	wake_up_all(&qref->freeze_wq);
+}
+
+int blk_dax_get(struct request_queue *q)
+{
+	return blk_qref_enter(&q->dax_ref, GFP_NOWAIT);
+}
+
+void blk_dax_put(struct request_queue *q)
+{
+	percpu_ref_put(&q->dax_ref.count);
+}
+
+static void blk_dax_freeze(struct request_queue *q)
+{
+	if (!blk_queue_dax(q))
+		return;
+
+	if (atomic_inc_return(&q->dax_ref.freeze_depth) == 1)
+		percpu_ref_kill(&q->dax_ref.count);
+
+	wait_event(q->dax_ref.freeze_wq, percpu_ref_is_zero(&q->dax_ref.count));
+}
+
+struct request_queue *blk_dax_init_queue(int nid)
+{
+	struct request_queue *q;
+	int rc;
+
+	q = blk_alloc_queue_node(GFP_KERNEL, nid);
+	if (!q)
+		return ERR_PTR(-ENOMEM);
+	queue_flag_set_unlocked(QUEUE_FLAG_DAX, q);
+
+	rc = percpu_ref_init(&q->dax_ref.count, blk_qref_release, 0,
+			GFP_KERNEL);
+	if (rc) {
+		blk_cleanup_queue(q);
+		return ERR_PTR(rc);
+	}
+	return q;
+}
+EXPORT_SYMBOL(blk_dax_init_queue);
+
+static void blk_dax_exit(struct request_queue *q)
+{
+	if (!blk_queue_dax(q))
+		return;
+	percpu_ref_exit(&q->dax_ref.count);
+}
+
 void blk_set_queue_dying(struct request_queue *q)
 {
 	queue_flag_set_unlocked(QUEUE_FLAG_DYING, q);
@@ -558,6 +637,7 @@ void blk_cleanup_queue(struct request_queue *q)
 		blk_mq_freeze_queue(q);
 		spin_lock_irq(lock);
 	} else {
+		blk_dax_freeze(q);
 		spin_lock_irq(lock);
 		__blk_drain_queue(q, true);
 	}
@@ -570,6 +650,7 @@ void blk_cleanup_queue(struct request_queue *q)
 
 	if (q->mq_ops)
 		blk_mq_free_queue(q);
+	blk_dax_exit(q);
 
 	spin_lock_irq(lock);
 	if (q->queue_lock != &q->__queue_lock)
@@ -688,7 +769,8 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 	q->bypass_depth = 1;
 	__set_bit(QUEUE_FLAG_BYPASS, &q->queue_flags);
 
-	init_waitqueue_head(&q->mq_freeze_wq);
+	/* this also inits q->dax_ref.freeze_wq in the union */
+	init_waitqueue_head(&q->mq_ref.freeze_wq);
 
 	if (blkcg_init_queue(q))
 		goto fail_bdi;
diff --git a/block/blk-mq-sysfs.c b/block/blk-mq-sysfs.c
index 279c5d674edf..b0fdffa0d4c6 100644
--- a/block/blk-mq-sysfs.c
+++ b/block/blk-mq-sysfs.c
@@ -415,7 +415,7 @@ static void blk_mq_sysfs_init(struct request_queue *q)
 /* see blk_register_queue() */
 void blk_mq_finish_init(struct request_queue *q)
 {
-	percpu_ref_switch_to_percpu(&q->mq_usage_counter);
+	percpu_ref_switch_to_percpu(&q->mq_ref.count);
 }
 
 int blk_mq_register_disk(struct gendisk *disk)
diff --git a/block/blk-mq.c b/block/blk-mq.c
index f2d67b4047a0..494c6e267c9d 100644
--- a/block/blk-mq.c
+++ b/block/blk-mq.c
@@ -79,45 +79,21 @@ static void blk_mq_hctx_clear_pending(struct blk_mq_hw_ctx *hctx,
 
 static int blk_mq_queue_enter(struct request_queue *q, gfp_t gfp)
 {
-	while (true) {
-		int ret;
-
-		if (percpu_ref_tryget_live(&q->mq_usage_counter))
-			return 0;
-
-		if (!(gfp & __GFP_WAIT))
-			return -EBUSY;
-
-		ret = wait_event_interruptible(q->mq_freeze_wq,
-				!atomic_read(&q->mq_freeze_depth) ||
-				blk_queue_dying(q));
-		if (blk_queue_dying(q))
-			return -ENODEV;
-		if (ret)
-			return ret;
-	}
+	return blk_qref_enter(&q->mq_ref, gfp);
 }
 
 static void blk_mq_queue_exit(struct request_queue *q)
 {
-	percpu_ref_put(&q->mq_usage_counter);
-}
-
-static void blk_mq_usage_counter_release(struct percpu_ref *ref)
-{
-	struct request_queue *q =
-		container_of(ref, struct request_queue, mq_usage_counter);
-
-	wake_up_all(&q->mq_freeze_wq);
+	percpu_ref_put(&q->mq_ref.count);
 }
 
 void blk_mq_freeze_queue_start(struct request_queue *q)
 {
 	int freeze_depth;
 
-	freeze_depth = atomic_inc_return(&q->mq_freeze_depth);
+	freeze_depth = atomic_inc_return(&q->mq_ref.freeze_depth);
 	if (freeze_depth == 1) {
-		percpu_ref_kill(&q->mq_usage_counter);
+		percpu_ref_kill(&q->mq_ref.count);
 		blk_mq_run_hw_queues(q, false);
 	}
 }
@@ -125,7 +101,7 @@ EXPORT_SYMBOL_GPL(blk_mq_freeze_queue_start);
 
 static void blk_mq_freeze_queue_wait(struct request_queue *q)
 {
-	wait_event(q->mq_freeze_wq, percpu_ref_is_zero(&q->mq_usage_counter));
+	wait_event(q->mq_ref.freeze_wq, percpu_ref_is_zero(&q->mq_ref.count));
 }
 
 /*
@@ -143,11 +119,11 @@ void blk_mq_unfreeze_queue(struct request_queue *q)
 {
 	int freeze_depth;
 
-	freeze_depth = atomic_dec_return(&q->mq_freeze_depth);
+	freeze_depth = atomic_dec_return(&q->mq_ref.freeze_depth);
 	WARN_ON_ONCE(freeze_depth < 0);
 	if (!freeze_depth) {
-		percpu_ref_reinit(&q->mq_usage_counter);
-		wake_up_all(&q->mq_freeze_wq);
+		percpu_ref_reinit(&q->mq_ref.count);
+		wake_up_all(&q->mq_ref.freeze_wq);
 	}
 }
 EXPORT_SYMBOL_GPL(blk_mq_unfreeze_queue);
@@ -166,7 +142,7 @@ void blk_mq_wake_waiters(struct request_queue *q)
 	 * dying, we need to ensure that processes currently waiting on
 	 * the queue are notified as well.
 	 */
-	wake_up_all(&q->mq_freeze_wq);
+	wake_up_all(&q->mq_ref.freeze_wq);
 }
 
 bool blk_mq_can_queue(struct blk_mq_hw_ctx *hctx)
@@ -1983,7 +1959,7 @@ struct request_queue *blk_mq_init_allocated_queue(struct blk_mq_tag_set *set,
 	 * Init percpu_ref in atomic mode so that it's faster to shutdown.
 	 * See blk_register_queue() for details.
 	 */
-	if (percpu_ref_init(&q->mq_usage_counter, blk_mq_usage_counter_release,
+	if (percpu_ref_init(&q->mq_ref.count, blk_qref_release,
 			    PERCPU_REF_INIT_ATOMIC, GFP_KERNEL))
 		goto err_hctxs;
 
@@ -2062,7 +2038,7 @@ void blk_mq_free_queue(struct request_queue *q)
 	blk_mq_exit_hw_queues(q, set, set->nr_hw_queues);
 	blk_mq_free_hw_queues(q, set);
 
-	percpu_ref_exit(&q->mq_usage_counter);
+	percpu_ref_exit(&q->mq_ref.count);
 
 	kfree(q->mq_map);
 
@@ -2076,7 +2052,7 @@ void blk_mq_free_queue(struct request_queue *q)
 /* Basically redo blk_mq_init_queue with queue frozen */
 static void blk_mq_queue_reinit(struct request_queue *q)
 {
-	WARN_ON_ONCE(!atomic_read(&q->mq_freeze_depth));
+	WARN_ON_ONCE(!atomic_read(&q->mq_ref.freeze_depth));
 
 	blk_mq_sysfs_unregister(q);
 
diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index 3e44a9da2a13..5126a97825de 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -616,6 +616,15 @@ int blk_register_queue(struct gendisk *disk)
 
 	kobject_uevent(&q->kobj, KOBJ_ADD);
 
+	if (q->mq_ops && blk_queue_dax(q)) {
+		/*
+		 * mq_ref and dax_ref share storage in request_queue, so
+		 * we can't have both enabled.
+		 */
+		WARN_ON_ONCE(1);
+		return -EINVAL;
+	}
+
 	if (q->mq_ops)
 		blk_mq_register_disk(disk);
 
diff --git a/block/blk.h b/block/blk.h
index 98614ad37c81..0b898d89e0dd 100644
--- a/block/blk.h
+++ b/block/blk.h
@@ -54,6 +54,9 @@ static inline void __blk_get_queue(struct request_queue *q)
 	kobject_get(&q->kobj);
 }
 
+int blk_qref_enter(struct request_queue_ref *qref, gfp_t gfp);
+void blk_qref_release(struct percpu_ref *percpu_ref);
+
 struct blk_flush_queue *blk_alloc_flush_queue(struct request_queue *q,
 		int node, int cmd_size);
 void blk_free_flush_queue(struct blk_flush_queue *q);
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index b9794aeeb878..f645a71ae827 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -482,7 +482,7 @@ static struct brd_device *brd_alloc(int i)
 	spin_lock_init(&brd->brd_lock);
 	INIT_RADIX_TREE(&brd->brd_pages, GFP_ATOMIC);
 
-	brd->brd_queue = blk_alloc_queue(GFP_KERNEL);
+	brd->brd_queue = blk_dax_init_queue(NUMA_NO_NODE);
 	if (!brd->brd_queue)
 		goto out_free_dev;
 
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 9805d311b1d1..a01611d8f351 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -176,9 +176,10 @@ static void pmem_detach_disk(struct pmem_device *pmem)
 static int pmem_attach_disk(struct device *dev,
 		struct nd_namespace_common *ndns, struct pmem_device *pmem)
 {
+	int nid = dev_to_node(dev);
 	struct gendisk *disk;
 
-	pmem->pmem_queue = blk_alloc_queue(GFP_KERNEL);
+	pmem->pmem_queue = blk_dax_init_queue(nid);
 	if (!pmem->pmem_queue)
 		return -ENOMEM;
 
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index 5ed44fe21380..c212ce925ee6 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -610,7 +610,7 @@ dcssblk_add_store(struct device *dev, struct device_attribute *attr, const char
 	}
 	dev_info->gd->major = dcssblk_major;
 	dev_info->gd->fops = &dcssblk_devops;
-	dev_info->dcssblk_queue = blk_alloc_queue(GFP_KERNEL);
+	dev_info->dcssblk_queue = blk_dax_init_queue(NUMA_NO_NODE);
 	dev_info->gd->queue = dev_info->dcssblk_queue;
 	dev_info->gd->private_data = dev_info;
 	dev_info->gd->driverfs_dev = &dev_info->dev;
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 99da9ebc7377..363d7df8d65c 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -277,6 +277,13 @@ struct queue_limits {
 	unsigned char		raid_partial_stripes_expensive;
 };
 
+
+struct request_queue_ref {
+	wait_queue_head_t	freeze_wq;
+	struct percpu_ref	count;
+	atomic_t		freeze_depth;
+};
+
 struct request_queue {
 	/*
 	 * Together with queue_head for cacheline sharing
@@ -436,7 +443,6 @@ struct request_queue {
 	struct mutex		sysfs_lock;
 
 	int			bypass_depth;
-	atomic_t		mq_freeze_depth;
 
 #if defined(CONFIG_BLK_DEV_BSG)
 	bsg_job_fn		*bsg_job_fn;
@@ -449,8 +455,10 @@ struct request_queue {
 	struct throtl_data *td;
 #endif
 	struct rcu_head		rcu_head;
-	wait_queue_head_t	mq_freeze_wq;
-	struct percpu_ref	mq_usage_counter;
+	union {
+		struct request_queue_ref mq_ref;
+		struct request_queue_ref dax_ref;
+	};
 	struct list_head	all_q_node;
 
 	struct blk_mq_tag_set	*tag_set;
@@ -480,6 +488,7 @@ struct request_queue {
 #define QUEUE_FLAG_DEAD        19	/* queue tear-down finished */
 #define QUEUE_FLAG_INIT_DONE   20	/* queue is initialized */
 #define QUEUE_FLAG_NO_SG_MERGE 21	/* don't attempt to merge SG segments*/
+#define QUEUE_FLAG_DAX         22	/* capacity may be direct-mapped */
 
 #define QUEUE_FLAG_DEFAULT	((1 << QUEUE_FLAG_IO_STAT) |		\
 				 (1 << QUEUE_FLAG_STACKABLE)	|	\
@@ -568,6 +577,7 @@ static inline void queue_flag_clear(unsigned int flag, struct request_queue *q)
 #define blk_queue_discard(q)	test_bit(QUEUE_FLAG_DISCARD, &(q)->queue_flags)
 #define blk_queue_secdiscard(q)	(blk_queue_discard(q) && \
 	test_bit(QUEUE_FLAG_SECDISCARD, &(q)->queue_flags))
+#define blk_queue_dax(q)	test_bit(QUEUE_FLAG_DAX, &(q)->queue_flags)
 
 #define blk_noretry_request(rq) \
 	((rq)->cmd_flags & (REQ_FAILFAST_DEV|REQ_FAILFAST_TRANSPORT| \
@@ -1003,6 +1013,10 @@ struct request_queue *blk_alloc_queue_node(gfp_t, int);
 extern void blk_put_queue(struct request_queue *);
 extern void blk_set_queue_dying(struct request_queue *);
 
+struct request_queue *blk_dax_init_queue(int nid);
+int blk_dax_get(struct request_queue *q);
+void blk_dax_put(struct request_queue *q);
+
 /*
  * block layer runtime pm functions
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
