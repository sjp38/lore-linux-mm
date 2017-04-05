Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B0F8D6B039F
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 02:10:28 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u195so2232447pgb.1
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 23:10:28 -0700 (PDT)
Received: from cmccmta3.chinamobile.com (cmccmta3.chinamobile.com. [221.176.66.81])
        by mx.google.com with ESMTP id e21si16095300pfl.1.2017.04.04.23.10.25
        for <linux-mm@kvack.org>;
        Tue, 04 Apr 2017 23:10:26 -0700 (PDT)
From: lixiubo@cmss.chinamobile.com
Subject: [PATCH v5 1/2] tcmu: Add dynamic growing data area feature support
Date: Wed,  5 Apr 2017 14:06:56 +0800
Message-Id: <1491372417-5994-2-git-send-email-lixiubo@cmss.chinamobile.com>
In-Reply-To: <1491372417-5994-1-git-send-email-lixiubo@cmss.chinamobile.com>
References: <1491372417-5994-1-git-send-email-lixiubo@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nab@linux-iscsi.org
Cc: mchristi@redhat.com, agrover@redhat.com, iliastsi@arrikto.com, namei.unix@gmail.com, sheng@yasker.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Xiubo Li <lixiubo@cmss.chinamobile.com>, Jianfei Hu <hujianfei@cmss.chinamobile.com>

From: Xiubo Li <lixiubo@cmss.chinamobile.com>

Currently for the TCMU, the ring buffer size is fixed to 64K cmd
area + 1M data area, and this will be bottlenecks for high iops.

The struct tcmu_cmd_entry {} size is fixed about 112 bytes with
iovec[N] & N <= 4, and the size of struct iovec is about 16 bytes.

If N == 0, the ratio will be sizeof(cmd entry) : sizeof(datas) ==
112Bytes : (N * 4096)Bytes = 28 : 0, no data area is need.

If 0 < N <=4, the ratio will be sizeof(cmd entry) : sizeof(datas)
== 112Bytes : (N * 4096)Bytes = 28 : (N * 1024), so the max will
be 28 : 1024.

If N > 4, the sizeof(cmd entry) will be [(N - 4) *16 + 112] bytes,
and its corresponding data size will be [N * 4096], so the ratio
of sizeof(cmd entry) : sizeof(datas) == [(N - 4) * 16 + 112)Bytes
: (N * 4096)Bytes == 4/1024 - 12/(N * 1024), so the max is about
4 : 1024.

When N is bigger, the ratio will be smaller.

As the initial patch, we will set the cmd area size to 2M, and
the cmd area size to 32M. The TCMU will dynamically grows the data
area from 0 to max 32M size as needed.

The cmd area memory will be allocated through vmalloc(), and the
data area's blocks will be allocated individually later when needed.

The allocated data area block memory will be managed via radix tree.
For now the bitmap still be the most efficient way to search and
manage the block index, this could be update later.

Signed-off-by: Xiubo Li <lixiubo@cmss.chinamobile.com>
Signed-off-by: Jianfei Hu <hujianfei@cmss.chinamobile.com>
---
 drivers/target/target_core_user.c | 333 ++++++++++++++++++++++++++------------
 1 file changed, 232 insertions(+), 101 deletions(-)

diff --git a/drivers/target/target_core_user.c b/drivers/target/target_core_user.c
index f615c3b..9220e43 100644
--- a/drivers/target/target_core_user.c
+++ b/drivers/target/target_core_user.c
@@ -2,6 +2,7 @@
  * Copyright (C) 2013 Shaohua Li <shli@kernel.org>
  * Copyright (C) 2014 Red Hat, Inc.
  * Copyright (C) 2015 Arrikto, Inc.
+ * Copyright (C) 2017 Chinamobile, Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -25,6 +26,7 @@
 #include <linux/parser.h>
 #include <linux/vmalloc.h>
 #include <linux/uio_driver.h>
+#include <linux/radix-tree.h>
 #include <linux/stringify.h>
 #include <linux/bitops.h>
 #include <linux/highmem.h>
@@ -63,15 +65,17 @@
  * this may have a 'UAM' comment.
  */
 
-
 #define TCMU_TIME_OUT (30 * MSEC_PER_SEC)
 
-#define DATA_BLOCK_BITS 256
-#define DATA_BLOCK_SIZE 4096
+/* For cmd area, the size is fixed 2M */
+#define CMDR_SIZE (2 * 1024 * 1024)
 
-#define CMDR_SIZE (16 * 4096)
+/* For data area, the size is fixed 32M */
+#define DATA_BLOCK_BITS (8 * 1024)
+#define DATA_BLOCK_SIZE 4096
 #define DATA_SIZE (DATA_BLOCK_BITS * DATA_BLOCK_SIZE)
 
+/* The ring buffer size is 34M */
 #define TCMU_RING_SIZE (CMDR_SIZE + DATA_SIZE)
 
 static struct device *tcmu_root_device;
@@ -103,12 +107,14 @@ struct tcmu_dev {
 	size_t data_off;
 	size_t data_size;
 
-	DECLARE_BITMAP(data_bitmap, DATA_BLOCK_BITS);
-
 	wait_queue_head_t wait_cmdr;
 	/* TODO should this be a mutex? */
 	spinlock_t cmdr_lock;
 
+	uint32_t dbi_max;
+	DECLARE_BITMAP(data_bitmap, DATA_BLOCK_BITS);
+	struct radix_tree_root data_blocks;
+
 	struct idr commands;
 	spinlock_t commands_lock;
 
@@ -130,7 +136,9 @@ struct tcmu_cmd {
 
 	/* Can't use se_cmd when cleaning up expired cmds, because if
 	   cmd has been completed then accessing se_cmd is off limits */
-	DECLARE_BITMAP(data_bitmap, DATA_BLOCK_BITS);
+	uint32_t dbi_cnt;
+	uint32_t dbi_cur;
+	uint32_t *dbi;
 
 	unsigned long deadline;
 
@@ -161,6 +169,84 @@ enum tcmu_multicast_groups {
 	.netnsok = true,
 };
 
+#define tcmu_cmd_set_dbi_cur(cmd, index) ((cmd)->dbi_cur = (index))
+#define tcmu_cmd_reset_dbi_cur(cmd) tcmu_cmd_set_dbi_cur(cmd, 0)
+#define tcmu_cmd_set_dbi(cmd, index) ((cmd)->dbi[(cmd)->dbi_cur++] = (index))
+#define tcmu_cmd_get_dbi(cmd) ((cmd)->dbi[(cmd)->dbi_cur++])
+
+static void tcmu_cmd_free_data(struct tcmu_cmd *tcmu_cmd)
+{
+	struct tcmu_dev *udev = tcmu_cmd->tcmu_dev;
+	uint32_t i;
+
+	for (i = 0; i < tcmu_cmd->dbi_cnt; i++)
+		clear_bit(tcmu_cmd->dbi[i], udev->data_bitmap);
+}
+
+static int tcmu_get_empty_block(struct tcmu_dev *udev, void **addr)
+{
+	void *p;
+	uint32_t dbi;
+	int ret;
+
+	dbi = find_first_zero_bit(udev->data_bitmap, DATA_BLOCK_BITS);
+	if (dbi > udev->dbi_max)
+		udev->dbi_max = dbi;
+
+	set_bit(dbi, udev->data_bitmap);
+
+	p = radix_tree_lookup(&udev->data_blocks, dbi);
+	if (!p) {
+		p = kzalloc(DATA_BLOCK_SIZE, GFP_ATOMIC);
+		if (!p) {
+			clear_bit(dbi, udev->data_bitmap);
+			return -ENOMEM;
+		}
+
+		ret = radix_tree_insert(&udev->data_blocks, dbi, p);
+		if (ret) {
+			kfree(p);
+			clear_bit(dbi, udev->data_bitmap);
+			return ret;
+		}
+	}
+
+	*addr = p;
+	return dbi;
+}
+
+static void *tcmu_get_block_addr(struct tcmu_dev *udev, uint32_t dbi)
+{
+	return radix_tree_lookup(&udev->data_blocks, dbi);
+}
+
+static inline void tcmu_free_cmd(struct tcmu_cmd *tcmu_cmd)
+{
+	kfree(tcmu_cmd->dbi);
+	kmem_cache_free(tcmu_cmd_cache, tcmu_cmd);
+}
+
+static inline size_t tcmu_cmd_get_data_length(struct tcmu_cmd *tcmu_cmd)
+{
+	struct se_cmd *se_cmd = tcmu_cmd->se_cmd;
+	size_t data_length = round_up(se_cmd->data_length, DATA_BLOCK_SIZE);
+
+	if (se_cmd->se_cmd_flags & SCF_BIDI) {
+		BUG_ON(!(se_cmd->t_bidi_data_sg && se_cmd->t_bidi_data_nents));
+		data_length += round_up(se_cmd->t_bidi_data_sg->length,
+				DATA_BLOCK_SIZE);
+	}
+
+	return data_length;
+}
+
+static inline uint32_t tcmu_cmd_get_block_cnt(struct tcmu_cmd *tcmu_cmd)
+{
+	size_t data_length = tcmu_cmd_get_data_length(tcmu_cmd);
+
+	return data_length / DATA_BLOCK_SIZE;
+}
+
 static struct tcmu_cmd *tcmu_alloc_cmd(struct se_cmd *se_cmd)
 {
 	struct se_device *se_dev = se_cmd->se_dev;
@@ -178,6 +264,15 @@ static struct tcmu_cmd *tcmu_alloc_cmd(struct se_cmd *se_cmd)
 		tcmu_cmd->deadline = jiffies +
 					msecs_to_jiffies(udev->cmd_time_out);
 
+	tcmu_cmd_reset_dbi_cur(tcmu_cmd);
+	tcmu_cmd->dbi_cnt = tcmu_cmd_get_block_cnt(tcmu_cmd);
+	tcmu_cmd->dbi = kcalloc(tcmu_cmd->dbi_cnt, sizeof(uint32_t),
+				GFP_KERNEL);
+	if (!tcmu_cmd->dbi) {
+		kmem_cache_free(tcmu_cmd_cache, tcmu_cmd);
+		return NULL;
+	}
+
 	idr_preload(GFP_KERNEL);
 	spin_lock_irq(&udev->commands_lock);
 	cmd_id = idr_alloc(&udev->commands, tcmu_cmd, 0,
@@ -186,7 +281,7 @@ static struct tcmu_cmd *tcmu_alloc_cmd(struct se_cmd *se_cmd)
 	idr_preload_end();
 
 	if (cmd_id < 0) {
-		kmem_cache_free(tcmu_cmd_cache, tcmu_cmd);
+		tcmu_free_cmd(tcmu_cmd);
 		return NULL;
 	}
 	tcmu_cmd->cmd_id = cmd_id;
@@ -248,10 +343,10 @@ static inline void new_iov(struct iovec **iov, int *iov_cnt,
 #define UPDATE_HEAD(head, used, size) smp_store_release(&head, ((head % size) + used) % size)
 
 /* offset is relative to mb_addr */
-static inline size_t get_block_offset(struct tcmu_dev *dev,
-		int block, int remaining)
+static inline size_t get_block_offset_user(struct tcmu_dev *dev,
+		int dbi, int remaining)
 {
-	return dev->data_off + block * DATA_BLOCK_SIZE +
+	return dev->data_off + dbi * DATA_BLOCK_SIZE +
 		DATA_BLOCK_SIZE - remaining;
 }
 
@@ -260,14 +355,15 @@ static inline size_t iov_tail(struct tcmu_dev *udev, struct iovec *iov)
 	return (size_t)iov->iov_base + iov->iov_len;
 }
 
-static void alloc_and_scatter_data_area(struct tcmu_dev *udev,
-	struct scatterlist *data_sg, unsigned int data_nents,
-	struct iovec **iov, int *iov_cnt, bool copy_data)
+static int alloc_and_scatter_data_area(struct tcmu_dev *udev,
+	struct tcmu_cmd *tcmu_cmd, struct scatterlist *data_sg,
+	unsigned int data_nents, struct iovec **iov,
+	int *iov_cnt, bool copy_data)
 {
-	int i, block;
+	int i, dbi;
 	int block_remaining = 0;
-	void *from, *to;
-	size_t copy_bytes, to_offset;
+	void *from, *to = NULL;
+	size_t copy_bytes, to_offset, offset;
 	struct scatterlist *sg;
 
 	for_each_sg(data_sg, sg, data_nents, i) {
@@ -275,22 +371,26 @@ static void alloc_and_scatter_data_area(struct tcmu_dev *udev,
 		from = kmap_atomic(sg_page(sg)) + sg->offset;
 		while (sg_remaining > 0) {
 			if (block_remaining == 0) {
-				block = find_first_zero_bit(udev->data_bitmap,
-						DATA_BLOCK_BITS);
 				block_remaining = DATA_BLOCK_SIZE;
-				set_bit(block, udev->data_bitmap);
+				dbi = tcmu_get_empty_block(udev, &to);
+				if (dbi < 0)
+					return dbi;
+				tcmu_cmd_set_dbi(tcmu_cmd, dbi);
 			}
+
 			copy_bytes = min_t(size_t, sg_remaining,
 					block_remaining);
-			to_offset = get_block_offset(udev, block,
+			to_offset = get_block_offset_user(udev, dbi,
 					block_remaining);
-			to = (void *)udev->mb_addr + to_offset;
+			offset = DATA_BLOCK_SIZE - block_remaining;
+			to = (void *)(unsigned long)to + offset;
+
 			if (*iov_cnt != 0 &&
 			    to_offset == iov_tail(udev, *iov)) {
 				(*iov)->iov_len += copy_bytes;
 			} else {
 				new_iov(iov, iov_cnt, udev);
-				(*iov)->iov_base = (void __user *) to_offset;
+				(*iov)->iov_base = (void __user *)to_offset;
 				(*iov)->iov_len = copy_bytes;
 			}
 			if (copy_data) {
@@ -303,33 +403,26 @@ static void alloc_and_scatter_data_area(struct tcmu_dev *udev,
 		}
 		kunmap_atomic(from - sg->offset);
 	}
-}
 
-static void free_data_area(struct tcmu_dev *udev, struct tcmu_cmd *cmd)
-{
-	bitmap_xor(udev->data_bitmap, udev->data_bitmap, cmd->data_bitmap,
-		   DATA_BLOCK_BITS);
+	return 0;
 }
 
 static void gather_data_area(struct tcmu_dev *udev, struct tcmu_cmd *cmd,
 			     bool bidi)
 {
 	struct se_cmd *se_cmd = cmd->se_cmd;
-	int i, block;
+	int i, dbi;
 	int block_remaining = 0;
 	void *from, *to;
-	size_t copy_bytes, from_offset;
+	size_t copy_bytes, offset;
 	struct scatterlist *sg, *data_sg;
 	unsigned int data_nents;
-	DECLARE_BITMAP(bitmap, DATA_BLOCK_BITS);
-
-	bitmap_copy(bitmap, cmd->data_bitmap, DATA_BLOCK_BITS);
+	uint32_t count = 0;
 
 	if (!bidi) {
 		data_sg = se_cmd->t_data_sg;
 		data_nents = se_cmd->t_data_nents;
 	} else {
-		uint32_t count;
 
 		/*
 		 * For bidi case, the first count blocks are for Data-Out
@@ -337,30 +430,26 @@ static void gather_data_area(struct tcmu_dev *udev, struct tcmu_cmd *cmd,
 		 * the Data-Out buffer blocks should be discarded.
 		 */
 		count = DIV_ROUND_UP(se_cmd->data_length, DATA_BLOCK_SIZE);
-		while (count--) {
-			block = find_first_bit(bitmap, DATA_BLOCK_BITS);
-			clear_bit(block, bitmap);
-		}
 
 		data_sg = se_cmd->t_bidi_data_sg;
 		data_nents = se_cmd->t_bidi_data_nents;
 	}
 
+	tcmu_cmd_set_dbi_cur(cmd, count);
+
 	for_each_sg(data_sg, sg, data_nents, i) {
 		int sg_remaining = sg->length;
 		to = kmap_atomic(sg_page(sg)) + sg->offset;
 		while (sg_remaining > 0) {
 			if (block_remaining == 0) {
-				block = find_first_bit(bitmap,
-						DATA_BLOCK_BITS);
 				block_remaining = DATA_BLOCK_SIZE;
-				clear_bit(block, bitmap);
+				dbi = tcmu_cmd_get_dbi(cmd);
+				from = tcmu_get_block_addr(udev, dbi);
 			}
 			copy_bytes = min_t(size_t, sg_remaining,
 					block_remaining);
-			from_offset = get_block_offset(udev, block,
-					block_remaining);
-			from = (void *) udev->mb_addr + from_offset;
+			offset = DATA_BLOCK_SIZE - block_remaining;
+			from = (void *)(unsigned long)from + offset;
 			tcmu_flush_dcache_range(from, copy_bytes);
 			memcpy(to + sg->length - sg_remaining, from,
 					copy_bytes);
@@ -420,27 +509,6 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
 	return true;
 }
 
-static inline size_t tcmu_cmd_get_data_length(struct tcmu_cmd *tcmu_cmd)
-{
-	struct se_cmd *se_cmd = tcmu_cmd->se_cmd;
-	size_t data_length = round_up(se_cmd->data_length, DATA_BLOCK_SIZE);
-
-	if (se_cmd->se_cmd_flags & SCF_BIDI) {
-		BUG_ON(!(se_cmd->t_bidi_data_sg && se_cmd->t_bidi_data_nents));
-		data_length += round_up(se_cmd->t_bidi_data_sg->length,
-				DATA_BLOCK_SIZE);
-	}
-
-	return data_length;
-}
-
-static inline uint32_t tcmu_cmd_get_block_cnt(struct tcmu_cmd *tcmu_cmd)
-{
-	size_t data_length = tcmu_cmd_get_data_length(tcmu_cmd);
-
-	return data_length / DATA_BLOCK_SIZE;
-}
-
 static sense_reason_t
 tcmu_queue_cmd_ring(struct tcmu_cmd *tcmu_cmd)
 {
@@ -450,12 +518,11 @@ static inline uint32_t tcmu_cmd_get_block_cnt(struct tcmu_cmd *tcmu_cmd)
 	struct tcmu_mailbox *mb;
 	struct tcmu_cmd_entry *entry;
 	struct iovec *iov;
-	int iov_cnt;
+	int iov_cnt, ret;
 	uint32_t cmd_head;
 	uint64_t cdb_off;
 	bool copy_to_data_area;
 	size_t data_length = tcmu_cmd_get_data_length(tcmu_cmd);
-	DECLARE_BITMAP(old_bitmap, DATA_BLOCK_BITS);
 
 	if (test_bit(TCMU_DEV_BIT_BROKEN, &udev->flags))
 		return TCM_LOGICAL_UNIT_COMMUNICATION_FAILURE;
@@ -539,15 +606,17 @@ static inline uint32_t tcmu_cmd_get_block_cnt(struct tcmu_cmd *tcmu_cmd)
 	entry->hdr.kflags = 0;
 	entry->hdr.uflags = 0;
 
-	bitmap_copy(old_bitmap, udev->data_bitmap, DATA_BLOCK_BITS);
-
 	/* Handle allocating space from the data area */
 	iov = &entry->req.iov[0];
 	iov_cnt = 0;
 	copy_to_data_area = (se_cmd->data_direction == DMA_TO_DEVICE
 		|| se_cmd->se_cmd_flags & SCF_BIDI);
-	alloc_and_scatter_data_area(udev, se_cmd->t_data_sg,
-		se_cmd->t_data_nents, &iov, &iov_cnt, copy_to_data_area);
+	ret = alloc_and_scatter_data_area(udev, tcmu_cmd, se_cmd->t_data_sg,
+			se_cmd->t_data_nents, &iov, &iov_cnt, copy_to_data_area);
+	if (ret) {
+		pr_err("tcmu: alloc and scatter data failed\n");
+		return TCM_LOGICAL_UNIT_COMMUNICATION_FAILURE;
+	}
 	entry->req.iov_cnt = iov_cnt;
 	entry->req.iov_dif_cnt = 0;
 
@@ -555,14 +624,16 @@ static inline uint32_t tcmu_cmd_get_block_cnt(struct tcmu_cmd *tcmu_cmd)
 	if (se_cmd->se_cmd_flags & SCF_BIDI) {
 		iov_cnt = 0;
 		iov++;
-		alloc_and_scatter_data_area(udev, se_cmd->t_bidi_data_sg,
-				se_cmd->t_bidi_data_nents, &iov, &iov_cnt,
-				false);
+		ret = alloc_and_scatter_data_area(udev, tcmu_cmd,
+					se_cmd->t_bidi_data_sg,
+					se_cmd->t_bidi_data_nents,
+					&iov, &iov_cnt, false);
+		if (ret) {
+			pr_err("tcmu: alloc and scatter bidi data failed\n");
+			return TCM_LOGICAL_UNIT_COMMUNICATION_FAILURE;
+		}
 		entry->req.iov_bidi_cnt = iov_cnt;
 	}
-	/* cmd's data_bitmap is what changed in process */
-	bitmap_xor(tcmu_cmd->data_bitmap, old_bitmap, udev->data_bitmap,
-			DATA_BLOCK_BITS);
 
 	/* All offsets relative to mb_addr, not start of entry! */
 	cdb_off = CMDR_OFF + cmd_head + base_command_size;
@@ -604,7 +675,7 @@ static inline uint32_t tcmu_cmd_get_block_cnt(struct tcmu_cmd *tcmu_cmd)
 		idr_remove(&udev->commands, tcmu_cmd->cmd_id);
 		spin_unlock_irq(&udev->commands_lock);
 
-		kmem_cache_free(tcmu_cmd_cache, tcmu_cmd);
+		tcmu_free_cmd(tcmu_cmd);
 	}
 
 	return ret;
@@ -615,44 +686,40 @@ static void tcmu_handle_completion(struct tcmu_cmd *cmd, struct tcmu_cmd_entry *
 	struct se_cmd *se_cmd = cmd->se_cmd;
 	struct tcmu_dev *udev = cmd->tcmu_dev;
 
-	if (test_bit(TCMU_CMD_BIT_EXPIRED, &cmd->flags)) {
-		/*
-		 * cmd has been completed already from timeout, just reclaim
-		 * data area space and free cmd
-		 */
-		free_data_area(udev, cmd);
+	/*
+	 * cmd has been completed already from timeout, just reclaim
+	 * data area space and free cmd
+	 */
+	if (test_bit(TCMU_CMD_BIT_EXPIRED, &cmd->flags))
+		goto out;
 
-		kmem_cache_free(tcmu_cmd_cache, cmd);
-		return;
-	}
+	tcmu_cmd_reset_dbi_cur(cmd);
 
 	if (entry->hdr.uflags & TCMU_UFLAG_UNKNOWN_OP) {
-		free_data_area(udev, cmd);
 		pr_warn("TCMU: Userspace set UNKNOWN_OP flag on se_cmd %p\n",
 			cmd->se_cmd);
 		entry->rsp.scsi_status = SAM_STAT_CHECK_CONDITION;
 	} else if (entry->rsp.scsi_status == SAM_STAT_CHECK_CONDITION) {
 		memcpy(se_cmd->sense_buffer, entry->rsp.sense_buffer,
 			       se_cmd->scsi_sense_length);
-		free_data_area(udev, cmd);
 	} else if (se_cmd->se_cmd_flags & SCF_BIDI) {
 		/* Get Data-In buffer before clean up */
 		gather_data_area(udev, cmd, true);
-		free_data_area(udev, cmd);
 	} else if (se_cmd->data_direction == DMA_FROM_DEVICE) {
 		gather_data_area(udev, cmd, false);
-		free_data_area(udev, cmd);
 	} else if (se_cmd->data_direction == DMA_TO_DEVICE) {
-		free_data_area(udev, cmd);
+		/* TODO: */
 	} else if (se_cmd->data_direction != DMA_NONE) {
 		pr_warn("TCMU: data direction was %d!\n",
 			se_cmd->data_direction);
 	}
 
 	target_complete_cmd(cmd->se_cmd, entry->rsp.scsi_status);
-	cmd->se_cmd = NULL;
 
-	kmem_cache_free(tcmu_cmd_cache, cmd);
+out:
+	cmd->se_cmd = NULL;
+	tcmu_cmd_free_data(cmd);
+	tcmu_free_cmd(cmd);
 }
 
 static unsigned int tcmu_handle_completions(struct tcmu_dev *udev)
@@ -810,6 +877,54 @@ static int tcmu_irqcontrol(struct uio_info *info, s32 irq_on)
 	return 0;
 }
 
+static void tcmu_blocks_release(struct tcmu_dev *udev, bool release_pending)
+{
+	uint32_t dbi, end;
+	void *addr;
+
+	spin_lock_irq(&udev->cmdr_lock);
+
+	end = udev->dbi_max + 1;
+
+	/* try to release all unused blocks */
+	dbi = find_first_zero_bit(udev->data_bitmap, end);
+	if (dbi >= end) {
+		spin_unlock_irq(&udev->cmdr_lock);
+		return;
+	}
+	do {
+		addr = radix_tree_delete(&udev->data_blocks, dbi);
+		kfree(addr);
+
+		dbi = find_next_zero_bit(udev->data_bitmap, end, dbi + 1);
+	} while (dbi < end);
+
+	if (!release_pending)
+		return;
+
+	/* try to release all pending blocks */
+	dbi = find_first_bit(udev->data_bitmap, end);
+	if (dbi >= end) {
+		spin_unlock_irq(&udev->cmdr_lock);
+		return;
+	}
+	do {
+		addr = radix_tree_delete(&udev->data_blocks, dbi);
+		kfree(addr);
+
+		dbi = find_next_bit(udev->data_bitmap, end, dbi + 1);
+	} while (dbi < end);
+
+	spin_unlock_irq(&udev->cmdr_lock);
+}
+
+static void tcmu_vma_close(struct vm_area_struct *vma)
+{
+	struct tcmu_dev *udev = vma->vm_private_data;
+
+	tcmu_blocks_release(udev, false);
+}
+
 /*
  * mmap code from uio.c. Copied here because we want to hook mmap()
  * and this stuff must come along.
@@ -845,17 +960,28 @@ static int tcmu_vma_fault(struct vm_fault *vmf)
 	 */
 	offset = (vmf->pgoff - mi) << PAGE_SHIFT;
 
-	addr = (void *)(unsigned long)info->mem[mi].addr + offset;
-	if (info->mem[mi].memtype == UIO_MEM_LOGICAL)
-		page = virt_to_page(addr);
-	else
+	if (offset < udev->data_off) {
+		/* For the vmalloc()ed cmd area pages */
+		addr = (void *)(unsigned long)info->mem[mi].addr + offset;
 		page = vmalloc_to_page(addr);
+	} else {
+		/* For the dynamically growing data area pages */
+		uint32_t dbi;
+
+		dbi = (offset - udev->data_off) / DATA_BLOCK_SIZE;
+		addr = tcmu_get_block_addr(udev, dbi);
+		if (!addr)
+			return VM_FAULT_NOPAGE;
+		page = virt_to_page(addr);
+	}
+
 	get_page(page);
 	vmf->page = page;
 	return 0;
 }
 
 static const struct vm_operations_struct tcmu_vm_ops = {
+	.close = tcmu_vma_close,
 	.fault = tcmu_vma_fault,
 };
 
@@ -963,7 +1089,7 @@ static int tcmu_configure_device(struct se_device *dev)
 
 	info->name = str;
 
-	udev->mb_addr = vzalloc(TCMU_RING_SIZE);
+	udev->mb_addr = vzalloc(CMDR_SIZE);
 	if (!udev->mb_addr) {
 		ret = -ENOMEM;
 		goto err_vzalloc;
@@ -972,8 +1098,9 @@ static int tcmu_configure_device(struct se_device *dev)
 	/* mailbox fits in first part of CMDR space */
 	udev->cmdr_size = CMDR_SIZE - CMDR_OFF;
 	udev->data_off = CMDR_SIZE;
-	udev->data_size = TCMU_RING_SIZE - CMDR_SIZE;
+	udev->data_size = DATA_SIZE;
 
+	/* Initialise the mailbox of the ring buffer */
 	mb = udev->mb_addr;
 	mb->version = TCMU_MAILBOX_VERSION;
 	mb->flags = TCMU_MAILBOX_FLAG_CAP_OOOC;
@@ -984,12 +1111,14 @@ static int tcmu_configure_device(struct se_device *dev)
 	WARN_ON(udev->data_size % PAGE_SIZE);
 	WARN_ON(udev->data_size % DATA_BLOCK_SIZE);
 
+	INIT_RADIX_TREE(&udev->data_blocks, GFP_ATOMIC);
+
 	info->version = __stringify(TCMU_MAILBOX_VERSION);
 
 	info->mem[0].name = "tcm-user command & data buffer";
 	info->mem[0].addr = (phys_addr_t)(uintptr_t)udev->mb_addr;
 	info->mem[0].size = TCMU_RING_SIZE;
-	info->mem[0].memtype = UIO_MEM_VIRTUAL;
+	info->mem[0].memtype = UIO_MEM_NONE;
 
 	info->irqcontrol = tcmu_irqcontrol;
 	info->irq = UIO_IRQ_CUSTOM;
@@ -1070,6 +1199,8 @@ static void tcmu_free_device(struct se_device *dev)
 	spin_unlock_irq(&udev->commands_lock);
 	WARN_ON(!all_expired);
 
+	tcmu_blocks_release(udev, true);
+
 	if (tcmu_dev_configured(udev)) {
 		tcmu_netlink_event(TCMU_CMD_REMOVED_DEVICE, udev->uio_info.name,
 				   udev->uio_info.uio_dev->minor);
-- 
1.8.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
