Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id ECA006B03A0
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 02:10:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l70so2025603pfi.19
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 23:10:29 -0700 (PDT)
Received: from cmccmta2.chinamobile.com (cmccmta2.chinamobile.com. [221.176.66.80])
        by mx.google.com with ESMTP id c63si19672223pfb.128.2017.04.04.23.10.26
        for <linux-mm@kvack.org>;
        Tue, 04 Apr 2017 23:10:27 -0700 (PDT)
From: lixiubo@cmss.chinamobile.com
Subject: [PATCH v5 2/2] tcmu: Add global data block pool support
Date: Wed,  5 Apr 2017 14:06:57 +0800
Message-Id: <1491372417-5994-3-git-send-email-lixiubo@cmss.chinamobile.com>
In-Reply-To: <1491372417-5994-1-git-send-email-lixiubo@cmss.chinamobile.com>
References: <1491372417-5994-1-git-send-email-lixiubo@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nab@linux-iscsi.org
Cc: mchristi@redhat.com, agrover@redhat.com, iliastsi@arrikto.com, namei.unix@gmail.com, sheng@yasker.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Xiubo Li <lixiubo@cmss.chinamobile.com>, Jianfei Hu <hujianfei@cmss.chinamobile.com>

From: Xiubo Li <lixiubo@cmss.chinamobile.com>

For each target there will be one ring, when the target number
grows larger and larger, it could eventually runs out of the
system memories.

In this patch for each target ring, currently for the cmd area
the size will be fixed to 8MB and for the data area the size
will grow from 0 to max 256K * PAGE_SIZE(1G for 4K page size).

For all the targets' data areas, they will get empty blocks
from the "global data block pool", which has limited to 512K *
PAGE_SIZE(2G for 4K page size) for now.

When the "global data block pool" has been used up, then any
target could wake up the unmap thread routine to shrink other
targets' data area memories. And the unmap thread routine will
always try to truncate the ring vma from the last using block
offset.

When user space has touched the data blocks out of tcmu_cmd
iov[], the tcmu_page_fault() will try to return one zeroed blocks.

Here we move the timeout's tcmu_handle_completions() into unmap
thread routine, that's to say when the timeout fired, it will
only do the tcmu_check_expired_cmd() and then wake up the unmap
thread to do the completions() and then try to shrink its idle
memories. Then the cmdr_lock could be a mutex and could simplify
this patch because the unmap_mapping_range() or zap_* may go to
sleep.

Signed-off-by: Xiubo Li <lixiubo@cmss.chinamobile.com>
Signed-off-by: Jianfei Hu <hujianfei@cmss.chinamobile.com>
---
 drivers/target/target_core_user.c | 427 +++++++++++++++++++++++++++++---------
 1 file changed, 333 insertions(+), 94 deletions(-)

diff --git a/drivers/target/target_core_user.c b/drivers/target/target_core_user.c
index 9220e43..e5b5ae8 100644
--- a/drivers/target/target_core_user.c
+++ b/drivers/target/target_core_user.c
@@ -31,6 +31,8 @@
 #include <linux/bitops.h>
 #include <linux/highmem.h>
 #include <linux/configfs.h>
+#include <linux/mutex.h>
+#include <linux/kthread.h>
 #include <net/genetlink.h>
 #include <scsi/scsi_common.h>
 #include <scsi/scsi_proto.h>
@@ -67,17 +69,24 @@
 
 #define TCMU_TIME_OUT (30 * MSEC_PER_SEC)
 
-/* For cmd area, the size is fixed 2M */
-#define CMDR_SIZE (2 * 1024 * 1024)
+/* For cmd area, the size is fixed 8MB */
+#define CMDR_SIZE (8 * 1024 * 1024)
 
-/* For data area, the size is fixed 32M */
-#define DATA_BLOCK_BITS (8 * 1024)
-#define DATA_BLOCK_SIZE 4096
+/*
+ * For data area, the block size is PAGE_SIZE and
+ * the total size is 256K * PAGE_SIZE.
+ */
+#define DATA_BLOCK_SIZE PAGE_SIZE
+#define DATA_BLOCK_BITS (256 * 1024)
 #define DATA_SIZE (DATA_BLOCK_BITS * DATA_BLOCK_SIZE)
+#define DATA_BLOCK_INIT_BITS 128
 
-/* The ring buffer size is 34M */
+/* The total size of the ring is 8M + 256K * PAGE_SIZE */
 #define TCMU_RING_SIZE (CMDR_SIZE + DATA_SIZE)
 
+/* Default maximum of the global data blocks(512K * PAGE_SIZE) */
+#define TCMU_GLOBAL_MAX_BLOCKS (512 * 1024)
+
 static struct device *tcmu_root_device;
 
 struct tcmu_hba {
@@ -87,6 +96,8 @@ struct tcmu_hba {
 #define TCMU_CONFIG_LEN 256
 
 struct tcmu_dev {
+	struct list_head node;
+
 	struct se_device se_dev;
 
 	char *name;
@@ -98,6 +109,8 @@ struct tcmu_dev {
 
 	struct uio_info uio_info;
 
+	struct inode *inode;
+
 	struct tcmu_mailbox *mb_addr;
 	size_t dev_size;
 	u32 cmdr_size;
@@ -108,10 +121,11 @@ struct tcmu_dev {
 	size_t data_size;
 
 	wait_queue_head_t wait_cmdr;
-	/* TODO should this be a mutex? */
-	spinlock_t cmdr_lock;
+	struct mutex cmdr_lock;
 
+	bool waiting_global;
 	uint32_t dbi_max;
+	uint32_t dbi_thresh;
 	DECLARE_BITMAP(data_bitmap, DATA_BLOCK_BITS);
 	struct radix_tree_root data_blocks;
 
@@ -146,6 +160,13 @@ struct tcmu_cmd {
 	unsigned long flags;
 };
 
+static struct task_struct *unmap_thread;
+static wait_queue_head_t unmap_wait;
+static DEFINE_MUTEX(root_udev_mutex);
+static LIST_HEAD(root_udev);
+
+static atomic_t global_db_count = ATOMIC_INIT(0);
+
 static struct kmem_cache *tcmu_cmd_cache;
 
 /* multicast group */
@@ -174,48 +195,78 @@ enum tcmu_multicast_groups {
 #define tcmu_cmd_set_dbi(cmd, index) ((cmd)->dbi[(cmd)->dbi_cur++] = (index))
 #define tcmu_cmd_get_dbi(cmd) ((cmd)->dbi[(cmd)->dbi_cur++])
 
-static void tcmu_cmd_free_data(struct tcmu_cmd *tcmu_cmd)
+static void tcmu_cmd_free_data(struct tcmu_cmd *tcmu_cmd, uint32_t len)
 {
 	struct tcmu_dev *udev = tcmu_cmd->tcmu_dev;
 	uint32_t i;
 
-	for (i = 0; i < tcmu_cmd->dbi_cnt; i++)
+	for (i = 0; i < len; i++)
 		clear_bit(tcmu_cmd->dbi[i], udev->data_bitmap);
 }
 
-static int tcmu_get_empty_block(struct tcmu_dev *udev, void **addr)
+static inline bool tcmu_get_empty_block(struct tcmu_dev *udev,
+					struct tcmu_cmd *tcmu_cmd)
 {
-	void *p;
-	uint32_t dbi;
-	int ret;
+	struct page *page;
+	int ret, dbi;
 
-	dbi = find_first_zero_bit(udev->data_bitmap, DATA_BLOCK_BITS);
-	if (dbi > udev->dbi_max)
-		udev->dbi_max = dbi;
+	dbi = find_first_zero_bit(udev->data_bitmap, udev->dbi_thresh);
+	if (dbi == udev->dbi_thresh)
+		return false;
 
-	set_bit(dbi, udev->data_bitmap);
+	page = radix_tree_lookup(&udev->data_blocks, dbi);
+	if (!page) {
 
-	p = radix_tree_lookup(&udev->data_blocks, dbi);
-	if (!p) {
-		p = kzalloc(DATA_BLOCK_SIZE, GFP_ATOMIC);
-		if (!p) {
-			clear_bit(dbi, udev->data_bitmap);
-			return -ENOMEM;
+		if (atomic_add_return(1, &global_db_count) >
+					TCMU_GLOBAL_MAX_BLOCKS) {
+			atomic_dec(&global_db_count);
+			return false;
 		}
 
-		ret = radix_tree_insert(&udev->data_blocks, dbi, p);
+		/* try to get new page from the mm */
+		page = alloc_page(GFP_KERNEL);
+		if (!page)
+			return false;
+
+		ret = radix_tree_insert(&udev->data_blocks, dbi, page);
 		if (ret) {
-			kfree(p);
-			clear_bit(dbi, udev->data_bitmap);
-			return ret;
+			__free_page(page);
+			return false;
 		}
+
 	}
 
-	*addr = p;
-	return dbi;
+	if (dbi > udev->dbi_max)
+		udev->dbi_max = dbi;
+
+	set_bit(dbi, udev->data_bitmap);
+	tcmu_cmd_set_dbi(tcmu_cmd, dbi);
+
+	return true;
 }
 
-static void *tcmu_get_block_addr(struct tcmu_dev *udev, uint32_t dbi)
+static bool tcmu_get_empty_blocks(struct tcmu_dev *udev,
+				  struct tcmu_cmd *tcmu_cmd,
+				  uint32_t blocks_needed)
+{
+	int i;
+
+	udev->waiting_global = false;
+
+	for (i = tcmu_cmd->dbi_cur; i < tcmu_cmd->dbi_cnt; i++) {
+		if (!tcmu_get_empty_block(udev, tcmu_cmd))
+			goto err;
+	}
+	return true;
+
+err:
+	udev->waiting_global = true;
+	/* Try to wake up the unmap thread */
+	wake_up(&unmap_wait);
+	return false;
+}
+
+static inline struct page *tcmu_get_block_page(struct tcmu_dev *udev, uint32_t dbi)
 {
 	return radix_tree_lookup(&udev->data_blocks, dbi);
 }
@@ -365,17 +416,20 @@ static int alloc_and_scatter_data_area(struct tcmu_dev *udev,
 	void *from, *to = NULL;
 	size_t copy_bytes, to_offset, offset;
 	struct scatterlist *sg;
+	struct page *page;
 
 	for_each_sg(data_sg, sg, data_nents, i) {
 		int sg_remaining = sg->length;
 		from = kmap_atomic(sg_page(sg)) + sg->offset;
 		while (sg_remaining > 0) {
 			if (block_remaining == 0) {
+				if (to)
+					kunmap_atomic(to);
+
 				block_remaining = DATA_BLOCK_SIZE;
-				dbi = tcmu_get_empty_block(udev, &to);
-				if (dbi < 0)
-					return dbi;
-				tcmu_cmd_set_dbi(tcmu_cmd, dbi);
+				dbi = tcmu_cmd_get_dbi(tcmu_cmd);
+				page = tcmu_get_block_page(udev, dbi);
+				to = kmap_atomic(page);
 			}
 
 			copy_bytes = min_t(size_t, sg_remaining,
@@ -403,6 +457,8 @@ static int alloc_and_scatter_data_area(struct tcmu_dev *udev,
 		}
 		kunmap_atomic(from - sg->offset);
 	}
+	if (to)
+		kunmap_atomic(to);
 
 	return 0;
 }
@@ -413,9 +469,10 @@ static void gather_data_area(struct tcmu_dev *udev, struct tcmu_cmd *cmd,
 	struct se_cmd *se_cmd = cmd->se_cmd;
 	int i, dbi;
 	int block_remaining = 0;
-	void *from, *to;
+	void *from = NULL, *to;
 	size_t copy_bytes, offset;
 	struct scatterlist *sg, *data_sg;
+	struct page *page;
 	unsigned int data_nents;
 	uint32_t count = 0;
 
@@ -442,9 +499,13 @@ static void gather_data_area(struct tcmu_dev *udev, struct tcmu_cmd *cmd,
 		to = kmap_atomic(sg_page(sg)) + sg->offset;
 		while (sg_remaining > 0) {
 			if (block_remaining == 0) {
+				if (from)
+					kunmap_atomic(from);
+
 				block_remaining = DATA_BLOCK_SIZE;
 				dbi = tcmu_cmd_get_dbi(cmd);
-				from = tcmu_get_block_addr(udev, dbi);
+				page = tcmu_get_block_page(udev, dbi);
+				from = kmap_atomic(page);
 			}
 			copy_bytes = min_t(size_t, sg_remaining,
 					block_remaining);
@@ -459,12 +520,13 @@ static void gather_data_area(struct tcmu_dev *udev, struct tcmu_cmd *cmd,
 		}
 		kunmap_atomic(to - sg->offset);
 	}
+	if (from)
+		kunmap_atomic(from);
 }
 
-static inline size_t spc_bitmap_free(unsigned long *bitmap)
+static inline size_t spc_bitmap_free(unsigned long *bitmap, uint32_t thresh)
 {
-	return DATA_BLOCK_SIZE * (DATA_BLOCK_BITS -
-			bitmap_weight(bitmap, DATA_BLOCK_BITS));
+	return DATA_BLOCK_SIZE * (thresh - bitmap_weight(bitmap, thresh));
 }
 
 /*
@@ -473,9 +535,12 @@ static inline size_t spc_bitmap_free(unsigned long *bitmap)
  *
  * Called with ring lock held.
  */
-static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t data_needed)
+static bool is_ring_space_avail(struct tcmu_dev *udev, struct tcmu_cmd *cmd,
+		size_t cmd_size, size_t data_needed)
 {
 	struct tcmu_mailbox *mb = udev->mb_addr;
+	uint32_t blocks_needed = (data_needed + DATA_BLOCK_SIZE - 1)
+				/ DATA_BLOCK_SIZE;
 	size_t space, cmd_needed;
 	u32 cmd_head;
 
@@ -499,13 +564,41 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
 		return false;
 	}
 
-	space = spc_bitmap_free(udev->data_bitmap);
+	/* try to check and get the data blocks as needed */
+	space = spc_bitmap_free(udev->data_bitmap, udev->dbi_thresh);
 	if (space < data_needed) {
-		pr_debug("no data space: only %zu available, but ask for %zu\n",
-				space, data_needed);
-		return false;
+		uint32_t blocks_left = DATA_BLOCK_BITS - udev->dbi_thresh;
+		uint32_t grow;
+
+		if (blocks_left < blocks_needed) {
+			pr_debug("no data space: only %zu available, but ask for %zu\n",
+					blocks_left * DATA_BLOCK_SIZE,
+					data_needed);
+			return false;
+		}
+
+		/* Try to expand the thresh */
+		if (!udev->dbi_thresh) {
+			/* From idle state */
+			uint32_t init_thresh = DATA_BLOCK_INIT_BITS;
+
+			udev->dbi_thresh = max(blocks_needed, init_thresh);
+		} else {
+			/*
+			 * Grow the data area by max(blocks needed,
+			 * dbi_thresh / 2), but limited to the max
+			 * DATA_BLOCK_BITS size.
+			 */
+			grow = max(blocks_needed, udev->dbi_thresh / 2);
+			udev->dbi_thresh += grow;
+			if (udev->dbi_thresh > DATA_BLOCK_BITS)
+				udev->dbi_thresh = DATA_BLOCK_BITS;
+		}
 	}
 
+	if (!tcmu_get_empty_blocks(udev, cmd, blocks_needed))
+		return false;
+
 	return true;
 }
 
@@ -542,7 +635,7 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
 
 	WARN_ON(command_size & (TCMU_OP_ALIGN_SIZE-1));
 
-	spin_lock_irq(&udev->cmdr_lock);
+	mutex_lock(&udev->cmdr_lock);
 
 	mb = udev->mb_addr;
 	cmd_head = mb->cmd_head % udev->cmdr_size; /* UAM */
@@ -551,18 +644,18 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
 		pr_warn("TCMU: Request of size %zu/%zu is too big for %u/%zu "
 			"cmd ring/data area\n", command_size, data_length,
 			udev->cmdr_size, udev->data_size);
-		spin_unlock_irq(&udev->cmdr_lock);
+		mutex_unlock(&udev->cmdr_lock);
 		return TCM_INVALID_CDB_FIELD;
 	}
 
-	while (!is_ring_space_avail(udev, command_size, data_length)) {
+	while (!is_ring_space_avail(udev, tcmu_cmd, command_size, data_length)) {
 		int ret;
 		DEFINE_WAIT(__wait);
 
 		prepare_to_wait(&udev->wait_cmdr, &__wait, TASK_INTERRUPTIBLE);
 
 		pr_debug("sleeping for ring space\n");
-		spin_unlock_irq(&udev->cmdr_lock);
+		mutex_unlock(&udev->cmdr_lock);
 		if (udev->cmd_time_out)
 			ret = schedule_timeout(
 					msecs_to_jiffies(udev->cmd_time_out));
@@ -574,7 +667,7 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
 			return TCM_LOGICAL_UNIT_COMMUNICATION_FAILURE;
 		}
 
-		spin_lock_irq(&udev->cmdr_lock);
+		mutex_lock(&udev->cmdr_lock);
 
 		/* We dropped cmdr_lock, cmd_head is stale */
 		cmd_head = mb->cmd_head % udev->cmdr_size; /* UAM */
@@ -607,6 +700,7 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
 	entry->hdr.uflags = 0;
 
 	/* Handle allocating space from the data area */
+	tcmu_cmd_reset_dbi_cur(tcmu_cmd);
 	iov = &entry->req.iov[0];
 	iov_cnt = 0;
 	copy_to_data_area = (se_cmd->data_direction == DMA_TO_DEVICE
@@ -615,6 +709,7 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
 			se_cmd->t_data_nents, &iov, &iov_cnt, copy_to_data_area);
 	if (ret) {
 		pr_err("tcmu: alloc and scatter data failed\n");
+		mutex_unlock(&udev->cmdr_lock);
 		return TCM_LOGICAL_UNIT_COMMUNICATION_FAILURE;
 	}
 	entry->req.iov_cnt = iov_cnt;
@@ -630,6 +725,7 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
 					&iov, &iov_cnt, false);
 		if (ret) {
 			pr_err("tcmu: alloc and scatter bidi data failed\n");
+			mutex_unlock(&udev->cmdr_lock);
 			return TCM_LOGICAL_UNIT_COMMUNICATION_FAILURE;
 		}
 		entry->req.iov_bidi_cnt = iov_cnt;
@@ -643,8 +739,7 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
 
 	UPDATE_HEAD(mb->cmd_head, command_size, udev->cmdr_size);
 	tcmu_flush_dcache_range(mb, sizeof(*mb));
-
-	spin_unlock_irq(&udev->cmdr_lock);
+	mutex_unlock(&udev->cmdr_lock);
 
 	/* TODO: only if FLUSH and FUA? */
 	uio_event_notify(&udev->uio_info);
@@ -718,14 +813,13 @@ static void tcmu_handle_completion(struct tcmu_cmd *cmd, struct tcmu_cmd_entry *
 
 out:
 	cmd->se_cmd = NULL;
-	tcmu_cmd_free_data(cmd);
+	tcmu_cmd_free_data(cmd, cmd->dbi_cnt);
 	tcmu_free_cmd(cmd);
 }
 
 static unsigned int tcmu_handle_completions(struct tcmu_dev *udev)
 {
 	struct tcmu_mailbox *mb;
-	unsigned long flags;
 	int handled = 0;
 
 	if (test_bit(TCMU_DEV_BIT_BROKEN, &udev->flags)) {
@@ -733,8 +827,6 @@ static unsigned int tcmu_handle_completions(struct tcmu_dev *udev)
 		return 0;
 	}
 
-	spin_lock_irqsave(&udev->cmdr_lock, flags);
-
 	mb = udev->mb_addr;
 	tcmu_flush_dcache_range(mb, sizeof(*mb));
 
@@ -775,8 +867,6 @@ static unsigned int tcmu_handle_completions(struct tcmu_dev *udev)
 	if (mb->cmd_tail == mb->cmd_head)
 		del_timer(&udev->timeout); /* no more pending cmds */
 
-	spin_unlock_irqrestore(&udev->cmdr_lock, flags);
-
 	wake_up(&udev->wait_cmdr);
 
 	return handled;
@@ -803,16 +893,14 @@ static void tcmu_device_timedout(unsigned long data)
 {
 	struct tcmu_dev *udev = (struct tcmu_dev *)data;
 	unsigned long flags;
-	int handled;
-
-	handled = tcmu_handle_completions(udev);
-
-	pr_warn("%d completions handled from timeout\n", handled);
 
 	spin_lock_irqsave(&udev->commands_lock, flags);
 	idr_for_each(&udev->commands, tcmu_check_expired_cmd, NULL);
 	spin_unlock_irqrestore(&udev->commands_lock, flags);
 
+	/* Try to wake up the ummap thread */
+	wake_up(&unmap_wait);
+
 	/*
 	 * We don't need to wakeup threads on wait_cmdr since they have their
 	 * own timeout.
@@ -857,7 +945,7 @@ static struct se_device *tcmu_alloc_device(struct se_hba *hba, const char *name)
 	udev->cmd_time_out = TCMU_TIME_OUT;
 
 	init_waitqueue_head(&udev->wait_cmdr);
-	spin_lock_init(&udev->cmdr_lock);
+	mutex_init(&udev->cmdr_lock);
 
 	idr_init(&udev->commands);
 	spin_lock_init(&udev->commands_lock);
@@ -872,50 +960,60 @@ static int tcmu_irqcontrol(struct uio_info *info, s32 irq_on)
 {
 	struct tcmu_dev *tcmu_dev = container_of(info, struct tcmu_dev, uio_info);
 
+	mutex_lock(&tcmu_dev->cmdr_lock);
 	tcmu_handle_completions(tcmu_dev);
+	mutex_unlock(&tcmu_dev->cmdr_lock);
 
 	return 0;
 }
 
 static void tcmu_blocks_release(struct tcmu_dev *udev, bool release_pending)
 {
-	uint32_t dbi, end;
-	void *addr;
-
-	spin_lock_irq(&udev->cmdr_lock);
+	int dbi = -1, end;
+	struct page *page;
 
+	mutex_lock(&udev->cmdr_lock);
 	end = udev->dbi_max + 1;
 
-	/* try to release all unused blocks */
-	dbi = find_first_zero_bit(udev->data_bitmap, end);
-	if (dbi >= end) {
-		spin_unlock_irq(&udev->cmdr_lock);
-		return;
-	}
+	/* Try to release all empty blocks */
 	do {
-		addr = radix_tree_delete(&udev->data_blocks, dbi);
-		kfree(addr);
-
 		dbi = find_next_zero_bit(udev->data_bitmap, end, dbi + 1);
-	} while (dbi < end);
+		if (dbi == end)
+			break;
 
-	if (!release_pending)
-		return;
+		page = radix_tree_delete(&udev->data_blocks, dbi);
+		if (page) {
+			__free_page(page);
+			atomic_dec(&global_db_count);
+		}
+	} while (1);
 
-	/* try to release all pending blocks */
-	dbi = find_first_bit(udev->data_bitmap, end);
-	if (dbi >= end) {
-		spin_unlock_irq(&udev->cmdr_lock);
+	if (!release_pending) {
+		mutex_unlock(&udev->cmdr_lock);
 		return;
 	}
-	do {
-		addr = radix_tree_delete(&udev->data_blocks, dbi);
-		kfree(addr);
 
+	/* Try to release all pending blocks */
+	dbi = -1;
+	do {
 		dbi = find_next_bit(udev->data_bitmap, end, dbi + 1);
-	} while (dbi < end);
+		if (dbi == end)
+			break;
+
+		clear_bit(dbi, udev->data_bitmap);
 
-	spin_unlock_irq(&udev->cmdr_lock);
+		page = radix_tree_delete(&udev->data_blocks, dbi);
+		if (page) {
+			__free_page(page);
+			atomic_dec(&global_db_count);
+		} else {
+			pr_err("block page not found, ring is broken\n");
+			set_bit(TCMU_DEV_BIT_BROKEN, &udev->flags);
+			break;
+		}
+	} while (1);
+
+	mutex_unlock(&udev->cmdr_lock);
 }
 
 static void tcmu_vma_close(struct vm_area_struct *vma)
@@ -942,6 +1040,56 @@ static int tcmu_find_mem_index(struct vm_area_struct *vma)
 	return -1;
 }
 
+static struct page *tcmu_try_get_block_page(struct tcmu_dev *udev, uint32_t dbi)
+{
+	struct page *page;
+	int ret;
+
+	mutex_lock(&udev->cmdr_lock);
+	page = tcmu_get_block_page(udev, dbi);
+	if (likely(page)) {
+		mutex_unlock(&udev->cmdr_lock);
+		return page;
+	}
+
+	/*
+	 * Normally it shouldn't be here:
+	 * Only when the userspace has touched the blocks which
+	 * are out of the tcmu_cmd's data iov[], and will return
+	 * one zeroed page.
+	 */
+	if (dbi >= udev->dbi_thresh) {
+		/* Extern the udev->dbi_thresh to dbi + 1 */
+		udev->dbi_thresh = dbi + 1;
+		udev->dbi_max = dbi;
+	}
+
+	if (!(page = radix_tree_lookup(&udev->data_blocks, dbi))) {
+		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+		if (!page) {
+			mutex_unlock(&udev->cmdr_lock);
+			return NULL;
+		}
+
+		ret = radix_tree_insert(&udev->data_blocks, dbi, page);
+		if (ret) {
+			mutex_unlock(&udev->cmdr_lock);
+			__free_page(page);
+			return NULL;
+		}
+
+		/*
+		 * Since this case is rare in page fault routine, here we
+		 * will allow the global_db_count >= TCMU_GLOBAL_MAX_BLOCKS
+		 * to reduce possible page fault call trace.
+		 */
+		atomic_inc(&global_db_count);
+	}
+	mutex_unlock(&udev->cmdr_lock);
+
+	return page;
+}
+
 static int tcmu_vma_fault(struct vm_fault *vmf)
 {
 	struct tcmu_dev *udev = vmf->vma->vm_private_data;
@@ -965,14 +1113,13 @@ static int tcmu_vma_fault(struct vm_fault *vmf)
 		addr = (void *)(unsigned long)info->mem[mi].addr + offset;
 		page = vmalloc_to_page(addr);
 	} else {
-		/* For the dynamically growing data area pages */
 		uint32_t dbi;
 
+		/* For the dynamically growing data area pages */
 		dbi = (offset - udev->data_off) / DATA_BLOCK_SIZE;
-		addr = tcmu_get_block_addr(udev, dbi);
-		if (!addr)
+		page = tcmu_try_get_block_page(udev, dbi);
+		if (!page)
 			return VM_FAULT_NOPAGE;
-		page = virt_to_page(addr);
 	}
 
 	get_page(page);
@@ -1009,6 +1156,8 @@ static int tcmu_open(struct uio_info *info, struct inode *inode)
 	if (test_and_set_bit(TCMU_DEV_BIT_OPEN, &udev->flags))
 		return -EBUSY;
 
+	udev->inode = inode;
+
 	pr_debug("open\n");
 
 	return 0;
@@ -1099,6 +1248,8 @@ static int tcmu_configure_device(struct se_device *dev)
 	udev->cmdr_size = CMDR_SIZE - CMDR_OFF;
 	udev->data_off = CMDR_SIZE;
 	udev->data_size = DATA_SIZE;
+	udev->dbi_thresh = 0; /* Default in Idle state */
+	udev->waiting_global = false;
 
 	/* Initialise the mailbox of the ring buffer */
 	mb = udev->mb_addr;
@@ -1111,7 +1262,7 @@ static int tcmu_configure_device(struct se_device *dev)
 	WARN_ON(udev->data_size % PAGE_SIZE);
 	WARN_ON(udev->data_size % DATA_BLOCK_SIZE);
 
-	INIT_RADIX_TREE(&udev->data_blocks, GFP_ATOMIC);
+	INIT_RADIX_TREE(&udev->data_blocks, GFP_KERNEL);
 
 	info->version = __stringify(TCMU_MAILBOX_VERSION);
 
@@ -1144,6 +1295,10 @@ static int tcmu_configure_device(struct se_device *dev)
 	if (ret)
 		goto err_netlink;
 
+	mutex_lock(&root_udev_mutex);
+	list_add(&udev->node, &root_udev);
+	mutex_unlock(&root_udev_mutex);
+
 	return 0;
 
 err_netlink:
@@ -1187,6 +1342,10 @@ static void tcmu_free_device(struct se_device *dev)
 
 	del_timer_sync(&udev->timeout);
 
+	mutex_lock(&root_udev_mutex);
+	list_del(&udev->node);
+	mutex_unlock(&root_udev_mutex);
+
 	vfree(udev->mb_addr);
 
 	/* Upper layer should drain all requests before calling this */
@@ -1387,6 +1546,74 @@ static ssize_t tcmu_cmd_time_out_store(struct config_item *item, const char *pag
 	.tb_dev_attrib_attrs	= NULL,
 };
 
+static int unmap_thread_fn(void *data)
+{
+	struct tcmu_dev *udev;
+	loff_t off;
+	uint32_t start, end, block;
+	struct page *page;
+	int i;
+
+	while (1) {
+		DEFINE_WAIT(__wait);
+
+		prepare_to_wait(&unmap_wait, &__wait, TASK_INTERRUPTIBLE);
+		schedule();
+		finish_wait(&unmap_wait, &__wait);
+
+		mutex_lock(&root_udev_mutex);
+		list_for_each_entry(udev, &root_udev, node) {
+			mutex_lock(&udev->cmdr_lock);
+
+			/* Try to complete the finished commands first */
+			tcmu_handle_completions(udev);
+
+			/* Skip the udevs waiting the global pool or in idle */
+			if (udev->waiting_global || !udev->dbi_thresh) {
+				mutex_unlock(&udev->cmdr_lock);
+				continue;
+			}
+
+			end = udev->dbi_max + 1;
+			block = find_last_bit(udev->data_bitmap, end);
+			if (block == end) {
+				/* The current udev will goto idle state */
+				udev->dbi_thresh = start = 0;
+				udev->dbi_max = 0;
+			} else {
+				udev->dbi_thresh = start = block + 1;
+				udev->dbi_max = block;
+			}
+
+			/* Here will truncate the data area from off */
+			off = udev->data_off + start * DATA_BLOCK_SIZE;
+			unmap_mapping_range(udev->inode->i_mapping, off, 0, 1);
+
+			/* Release the block pages */
+			for (i = start; i < end; i++) {
+				page = radix_tree_delete(&udev->data_blocks, i);
+				if (page) {
+					__free_page(page);
+					atomic_dec(&global_db_count);
+				}
+			}
+			mutex_unlock(&udev->cmdr_lock);
+		}
+
+		/*
+		 * Try to wake up the udevs who are waiting
+		 * for the global data pool.
+		 */
+		list_for_each_entry(udev, &root_udev, node) {
+			if (udev->waiting_global)
+				wake_up(&udev->wait_cmdr);
+		}
+		mutex_unlock(&root_udev_mutex);
+	}
+
+	return 0;
+}
+
 static int __init tcmu_module_init(void)
 {
 	int ret, i, len = 0;
@@ -1432,8 +1659,17 @@ static int __init tcmu_module_init(void)
 	if (ret)
 		goto out_attrs;
 
+	init_waitqueue_head(&unmap_wait);
+	unmap_thread = kthread_run(unmap_thread_fn, NULL, "tcmu_unmap");
+	if (IS_ERR(unmap_thread)) {
+		unmap_thread = NULL;
+		goto out_unreg_transport;
+	}
+
 	return 0;
 
+out_unreg_transport:
+	target_backend_unregister(&tcmu_ops);
 out_attrs:
 	kfree(tcmu_attrs);
 out_unreg_genl:
@@ -1448,6 +1684,9 @@ static int __init tcmu_module_init(void)
 
 static void __exit tcmu_module_exit(void)
 {
+	if (unmap_thread)
+		kthread_stop(unmap_thread);
+
 	target_backend_unregister(&tcmu_ops);
 	kfree(tcmu_attrs);
 	genl_unregister_family(&tcmu_genl_family);
-- 
1.8.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
