Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CB2A6B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 05:39:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c23so74986924pfj.0
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 02:39:34 -0700 (PDT)
Received: from cmccmta2.chinamobile.com (cmccmta2.chinamobile.com. [221.176.66.80])
        by mx.google.com with ESMTP id g3si4752446pld.88.2017.03.16.02.39.31
        for <linux-mm@kvack.org>;
        Thu, 16 Mar 2017 02:39:32 -0700 (PDT)
Subject: Re: [PATCHv2 2/5] target/user: Add global data block pool support
References: <1488962743-17028-1-git-send-email-lixiubo@cmss.chinamobile.com>
 <1488962743-17028-3-git-send-email-lixiubo@cmss.chinamobile.com>
 <3b1ce412-6072-fda1-3002-220cf8fbf34f@redhat.com>
From: Xiubo Li <lixiubo@cmss.chinamobile.com>
Message-ID: <ddd797ea-43f0-b863-64e4-1e758f41dafe@cmss.chinamobile.com>
Date: Thu, 16 Mar 2017 17:39:33 +0800
MIME-Version: 1.0
In-Reply-To: <3b1ce412-6072-fda1-3002-220cf8fbf34f@redhat.com>
Content-Type: multipart/alternative;
 boundary="------------1193870FEE65F4668BBF3826"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Grover <agrover@redhat.com>, nab@linux-iscsi.org, mchristi@redhat.com
Cc: shli@kernel.org, sheng@yasker.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, namei.unix@gmail.com, linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------1193870FEE65F4668BBF3826
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit


> Hi Xiubo,
>
> I will leave the detailed patch critique to others but this does seem 
> to achieve the goals of 1) larger TCMU data buffers to prevent 
> bottlenecks and 2) Allocating memory in a way that avoids using up all 
> system memory in corner cases.
>
> The one thing I'm still unsure about is what we need to do to maintain 
> the data area's virtual mapping properly. Nobody on linux-mm answered 
> my email a few days ago on the right way to do this, alas. But, 
> userspace accessing the data area is going to cause tcmu_vma_fault() 
> to be called, and it seems to me like we must proactively do something 
> -- some kind of unmap call -- before we can reuse that memory for 
> another, possibly completely unrelated, backstore's data area. This 
> could allow one backstore handler to read or write another's data.
>

Hi Andy, Mike

These days what I have gotten is that the unmap_mapping_range() could be 
used.
At the same time I have deep into the mm code and fixed the double usage of
the data blocks and possible page fault call trace bugs mentioned above.

Following is the V3 patch. I have test this using 4 targets & fio for 
about 2 days, so
far so good.

I'm still testing this using more complex test case.

Thanks

From: Xiubo Li<lixiubo@cmss.chinamobile.com>

For each target there will be one ring, when the target number
grows larger and larger, it could eventually runs out of the
system memories.

In this patch for each target ring, for the cmd area the size
will be limited to 8MB and for the data area the size will be
limited to 256K * PAGE_SIZE.

For all the targets' data areas, they will get empty blocks
from the "global data block pool", which has limited to 512K *
PAGE_SIZE for now.

When the "global data block pool" has been used up, then any
target could trigger the unmapping thread routine to shrink the
targets' rings. And for the idle targets the unmapping routine
will reserve 256 blocks at least.

When user space has touched the data blocks out of the iov[N],
the tcmu_page_fault() will return one zeroed blocks.

Signed-off-by: Xiubo Li<lixiubo@cmss.chinamobile.com>
Signed-off-by: Jianfei Hu<hujianfei@cmss.chinamobile.com>
---
  drivers/target/target_core_user.c | 433 ++++++++++++++++++++++++++++++--------
  1 file changed, 349 insertions(+), 84 deletions(-)

diff --git a/drivers/target/target_core_user.c b/drivers/target/target_core_user.c
index e904bc0..bbc52074 100644
--- a/drivers/target/target_core_user.c
+++ b/drivers/target/target_core_user.c
@@ -30,6 +30,8 @@
  #include <linux/stringify.h>
  #include <linux/bitops.h>
  #include <linux/highmem.h>
+#include <linux/mutex.h>
+#include <linux/kthread.h>
  #include <net/genetlink.h>
  #include <scsi/scsi_common.h>
  #include <scsi/scsi_proto.h>
@@ -66,17 +68,24 @@
  
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
+#define DATA_BLOCK_RES_BITS 256
  
-/* The ring buffer size is 34M */
+/* The total size of the ring is 8M + 256K * PAGE_SIZE */
  #define TCMU_RING_SIZE (CMDR_SIZE + DATA_SIZE)
  
+/* Default maximum of the global data blocks(512K * PAGE_SIZE) */
+#define TCMU_GLOBAL_MAX_BLOCKS (512 * 1024)
+
  static struct device *tcmu_root_device;
  
  struct tcmu_hba {
@@ -86,6 +95,8 @@ struct tcmu_hba {
  #define TCMU_CONFIG_LEN 256
  
  struct tcmu_dev {
+	struct list_head node;
+
  	struct se_device se_dev;
  
  	char *name;
@@ -97,6 +108,15 @@ struct tcmu_dev {
  
  	struct uio_info uio_info;
  
+	struct inode *inode;
+
+	bool unmapping;
+	bool waiting_global;
+	uint32_t dbi_cur;
+	uint32_t dbi_thresh;
+	DECLARE_BITMAP(data_bitmap, DATA_BLOCK_BITS);
+	struct radix_tree_root data_blocks;
+
  	struct tcmu_mailbox *mb_addr;
  	size_t dev_size;
  	u32 cmdr_size;
@@ -110,10 +130,6 @@ struct tcmu_dev {
  	/* TODO should this be a mutex? */
  	spinlock_t cmdr_lock;
  
-	uint32_t dbi_cur;
-	DECLARE_BITMAP(data_bitmap, DATA_BLOCK_BITS);
-	struct radix_tree_root data_blocks;
-
  	struct idr commands;
  	spinlock_t commands_lock;
  
@@ -137,6 +153,11 @@ struct tcmu_cmd {
  	uint32_t *dbi;
  };
  
+static wait_queue_head_t g_wait;
+static DEFINE_MUTEX(g_mutex);
+static LIST_HEAD(root_udev);
+static spinlock_t g_lock;
+static unsigned long global_db_count;
  static struct kmem_cache *tcmu_cmd_cache;
  
  /* multicast group */
@@ -160,54 +181,89 @@ enum tcmu_multicast_groups {
  	.netnsok = true,
  };
  
-static int tcmu_db_get_empty_block(struct tcmu_dev *udev, void **addr)
+#define tcmu_cmd_reset_dbi_cur(cmd) ((cmd)->dbi_cur = 0)
+#define tcmu_cmd_set_dbi(cmd, index) ((cmd)->dbi[(cmd)->dbi_cur++] = (index))
+#define tcmu_cmd_get_dbi(cmd) ((cmd)->dbi[(cmd)->dbi_cur++])
+
+static inline void tcmu_cmd_free_data(struct tcmu_cmd *tcmu_cmd, uint32_t len)
  {
-	void *p;
-	uint32_t dbi;
-	int ret;
+	struct tcmu_dev *udev = tcmu_cmd->tcmu_dev;
+	uint32_t i;
  
-	dbi = find_first_zero_bit(udev->data_bitmap, DATA_BLOCK_BITS);
-	if (dbi > udev->dbi_cur)
-		udev->dbi_cur = dbi;
+	for (i = 0; i < len; i++)
+		clear_bit(tcmu_cmd->dbi[i], udev->data_bitmap);
+}
  
-	set_bit(dbi, udev->data_bitmap);
+static inline bool get_empty_growing_block(struct tcmu_dev *udev,
+					   struct tcmu_cmd *tcmu_cmd)
+{
+	struct page *page;
+	int ret, dbi;
  
-	p = radix_tree_lookup(&udev->data_blocks, dbi);
-	if (!p) {
-		p = kzalloc(DATA_BLOCK_SIZE, GFP_ATOMIC);
-		if (!p) {
-			clear_bit(dbi, udev->data_bitmap);
-			return -ENOMEM;
+	dbi = find_first_zero_bit(udev->data_bitmap, udev->dbi_thresh);
+	if (dbi == udev->dbi_thresh)
+		return false;
+
+	page = radix_tree_lookup(&udev->data_blocks, dbi);
+	if (!page) {
+		/* try to get new page from the mm */
+		spin_lock_irq(&g_lock);
+		if (global_db_count >= TCMU_GLOBAL_MAX_BLOCKS) {
+			spin_unlock_irq(&g_lock);
+			wake_up(&g_wait);
+			return false;
+		}
+		global_db_count++;
+		spin_unlock_irq(&g_lock);
+
+		page = alloc_page(GFP_ATOMIC);
+		if (!page) {
+			return false;
  		}
  
-		ret = radix_tree_insert(&udev->data_blocks, dbi, p);
+		ret = radix_tree_insert(&udev->data_blocks, dbi, page);
  		if (ret) {
-			kfree(p);
-			clear_bit(dbi, udev->data_bitmap);
-			return ret;
+			__free_page(page);
+			return false;
  		}
  	}
  
-	*addr = p;
-	return dbi;
+	if (dbi > udev->dbi_cur)
+		udev->dbi_cur = dbi;
+
+	set_bit(dbi, udev->data_bitmap);
+	tcmu_cmd_set_dbi(tcmu_cmd, dbi);
+
+	return true;
  }
  
-static void *tcmu_db_get_block_addr(struct tcmu_dev *udev, uint32_t dbi)
+static bool tcmu_db_get_empty_blocks(struct tcmu_dev *udev,
+				     struct tcmu_cmd *tcmu_cmd)
  {
-	return radix_tree_lookup(&udev->data_blocks, dbi);
-}
+	int i;
  
-#define tcmu_cmd_reset_dbi_cur(cmd) ((cmd)->dbi_cur = 0)
-#define tcmu_cmd_set_dbi(cmd, index) ((cmd)->dbi[(cmd)->dbi_cur++] = (index))
-#define tcmu_cmd_get_dbi(cmd) ((cmd)->dbi[(cmd)->dbi_cur++])
+	tcmu_cmd_reset_dbi_cur(tcmu_cmd);
+	for (i = 0; i < tcmu_cmd->dbi_len; i++) {
+		if (!get_empty_growing_block(udev, tcmu_cmd))
+			goto err;
+	}
+	return true;
  
-static void tcmu_cmd_free_data(struct tcmu_cmd *tcmu_cmd)
+err:
+	tcmu_cmd_free_data(tcmu_cmd, tcmu_cmd->dbi_cur);
+	udev->waiting_global = true;
+	return false;
+}
+
+static struct page *tcmu_db_get_block_page(struct tcmu_dev *udev, uint32_t dbi)
  {
-	struct tcmu_dev *udev = tcmu_cmd->tcmu_dev;
-	uint32_t bi;
+	struct page *page;
  
-	for (bi = 0; bi < tcmu_cmd->dbi_len; bi++)
-		clear_bit(tcmu_cmd->dbi[bi], udev->data_bitmap);
+	page = radix_tree_lookup(&udev->data_blocks, dbi);
+	if (!page)
+		return NULL;
+
+	return page;
  }
  
  static inline void tcmu_free_cmd(struct tcmu_cmd *tcmu_cmd)
@@ -344,17 +400,20 @@ static int alloc_and_scatter_data_area(struct tcmu_dev *udev,
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
-				dbi = tcmu_db_get_empty_block(udev, &to);
-				if (dbi < 0)
-					return dbi;
-				tcmu_cmd_set_dbi(tcmu_cmd, dbi);
+				dbi = tcmu_cmd_get_dbi(tcmu_cmd);
+				page = tcmu_db_get_block_page(udev, dbi);
+				to = kmap_atomic(page);
  			}
  
  			copy_bytes = min_t(size_t, sg_remaining,
@@ -362,7 +421,7 @@ static int alloc_and_scatter_data_area(struct tcmu_dev *udev,
  			to_offset = get_block_offset_user(udev, dbi,
  					block_remaining);
  			offset = DATA_BLOCK_SIZE - block_remaining;
-			to = (void *)(unsigned long)to + offset;
+			to = (void *)((unsigned long)to + offset);
  
  			if (*iov_cnt != 0 &&
  			    to_offset == iov_tail(udev, *iov)) {
@@ -382,6 +441,8 @@ static int alloc_and_scatter_data_area(struct tcmu_dev *udev,
  		}
  		kunmap_atomic(from - sg->offset);
  	}
+	if (to)
+		kunmap_atomic(to);
  
  	return 0;
  }
@@ -391,23 +452,28 @@ static void gather_data_area(struct tcmu_dev *udev, struct tcmu_cmd *tcmu_cmd,
  {
  	int i, dbi;
  	int block_remaining = 0;
-	void *from, *to;
+	void *from = NULL, *to;
  	size_t copy_bytes, offset;
  	struct scatterlist *sg;
+	struct page *page;
  
  	for_each_sg(data_sg, sg, data_nents, i) {
  		int sg_remaining = sg->length;
  		to = kmap_atomic(sg_page(sg)) + sg->offset;
  		while (sg_remaining > 0) {
  			if (block_remaining == 0) {
+				if (from)
+					kunmap_atomic(from);
+
  				block_remaining = DATA_BLOCK_SIZE;
  				dbi = tcmu_cmd_get_dbi(tcmu_cmd);
-				from = tcmu_db_get_block_addr(udev, dbi);
+				page = tcmu_db_get_block_page(udev, dbi);
+				from = kmap_atomic(page);
  			}
  			copy_bytes = min_t(size_t, sg_remaining,
  					block_remaining);
  			offset = DATA_BLOCK_SIZE - block_remaining;
-			from = (void *)(unsigned long)from + offset;
+			from = (void *)((unsigned long)from + offset);
  			tcmu_flush_dcache_range(from, copy_bytes);
  			memcpy(to + sg->length - sg_remaining, from,
  					copy_bytes);
@@ -417,12 +483,13 @@ static void gather_data_area(struct tcmu_dev *udev, struct tcmu_cmd *tcmu_cmd,
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
@@ -431,12 +498,14 @@ static inline size_t spc_bitmap_free(unsigned long *bitmap)
   *
   * Called with ring lock held.
   */
-static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t data_needed)
+static bool is_ring_space_avail(struct tcmu_dev *udev, struct tcmu_cmd *cmd,
+		size_t cmd_size, size_t data_needed)
  {
  	struct tcmu_mailbox *mb = udev->mb_addr;
  	size_t space, cmd_needed;
  	u32 cmd_head;
  
+	udev->waiting_global = false;
  	tcmu_flush_dcache_range(mb, sizeof(*mb));
  
  	cmd_head = mb->cmd_head % udev->cmdr_size; /* UAM */
@@ -457,10 +526,24 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
  		return false;
  	}
  
-	space = spc_bitmap_free(udev->data_bitmap);
+	/* try to check and get the data blocks as needed */
+	space = spc_bitmap_free(udev->data_bitmap, udev->dbi_thresh);
  	if (space < data_needed) {
-		pr_debug("no data space: only %zu available, but ask for %zu\n",
-				space, data_needed);
+		if (udev->unmapping) {
+			pr_debug("no data space: only %zu available, but ask for %zu\n",
+					space, data_needed);
+			return false;
+		} else {
+			udev->dbi_thresh += udev->dbi_thresh / 2;
+			udev->dbi_thresh = min((int)udev->dbi_thresh, DATA_BLOCK_BITS);
+			space = spc_bitmap_free(udev->data_bitmap, udev->dbi_thresh);
+			if (space < data_needed)
+				return false;
+		}
+	}
+
+	if (!tcmu_db_get_empty_blocks(udev, cmd)) {
+		pr_debug("no data space: ask for %zu\n", data_needed);
  		return false;
  	}
  
@@ -519,7 +602,7 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
  		return TCM_INVALID_CDB_FIELD;
  	}
  
-	while (!is_ring_space_avail(udev, command_size, data_length)) {
+	while (!is_ring_space_avail(udev, tcmu_cmd, command_size, data_length)) {
  		int ret;
  		DEFINE_WAIT(__wait);
  
@@ -567,6 +650,7 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
  	entry->hdr.uflags = 0;
  
  	/* Handle allocating space from the data area */
+	tcmu_cmd_reset_dbi_cur(tcmu_cmd);
  	iov = &entry->req.iov[0];
  	iov_cnt = 0;
  	copy_to_data_area = (se_cmd->data_direction == DMA_TO_DEVICE
@@ -664,7 +748,7 @@ static void tcmu_handle_completion(struct tcmu_cmd *cmd, struct tcmu_cmd_entry *
  	target_complete_cmd(cmd->se_cmd, entry->rsp.scsi_status);
  
  	cmd->se_cmd = NULL;
-	tcmu_cmd_free_data(cmd);
+	tcmu_cmd_free_data(cmd, cmd->dbi_len);
  	tcmu_free_cmd(cmd);
  }
  
@@ -783,41 +867,80 @@ static int tcmu_irqcontrol(struct uio_info *info, s32 irq_on)
  
  static void tcmu_db_release(struct tcmu_dev *udev, bool release_pending)
  {
-	uint32_t dbi, end;
-	void *addr;
+	int dbi = -1, end;
+	struct page *page;
  
  	spin_lock_irq(&udev->cmdr_lock);
-
  	end = udev->dbi_cur + 1;
  
-	/* try to release all unused blocks */
-	dbi = find_first_zero_bit(udev->data_bitmap, end);
-	if (dbi >= end) {
-		spin_unlock_irq(&udev->cmdr_lock);
-		return;
-	}
+	/* try to release all unused but has mapped blocks */
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
+		/*
+		 * When the bit is cleared and p != NULL, meaning that
+		 * this tcmu block had already freed-after-use.
+		 *
+		 * If p->user == 0, meaning that the current ring buffer
+		 * is the last or the only user of the tcmu block, and
+		 * it must already in the free list, so it could be
+		 * remove from the list and then released its memories.
+		 *
+		 * If p->user != 0, meaning that the current tcmu block is
+		 * still referenced by other ring buffers, so just ignore
+		 * it without doing anyting.
+		 */
+		page = radix_tree_delete(&udev->data_blocks, dbi);
+		if (page) {
+				__free_page(page);
+				spin_lock_irq(&g_lock);
+				global_db_count--;
+				spin_unlock_irq(&g_lock);
+		}
+	} while (1);
  
-	/* try to release all pending blocks */
-	dbi = find_first_bit(udev->data_bitmap, end);
-	if (dbi >= end) {
+	if (!release_pending) {
  		spin_unlock_irq(&udev->cmdr_lock);
  		return;
  	}
-	do {
-		addr = radix_tree_delete(&udev->data_blocks, dbi);
-		kfree(addr);
  
+	/* try to release all pending blocks */
+	dbi = -1;
+	do {
  		dbi = find_next_bit(udev->data_bitmap, end, dbi + 1);
-	} while (dbi < end);
+		if (dbi == end)
+			break;
+
+		clear_bit(dbi, udev->data_bitmap);
+
+		/*
+		 * When the bit is set and p != NULL, meaning that this
+		 * tcmu block is still being used here.
+		 *
+		 * If p->user == 0, meaning that the current ring buffer
+		 * is the last or the only user of this tcmu block, and
+		 * it won't in the free list, so could just release its
+		 * memories.
+		 *
+		 * If the p->user != 0, we should insert it to the free
+		 * list.
+		 *
+		 * p == NULL means that the current ring buffer is broken.
+		 */
+		page = radix_tree_delete(&udev->data_blocks, dbi);
+		if (page) {
+				__free_page(page);
+				spin_lock_irq(&g_lock);
+				global_db_count--;
+				spin_unlock_irq(&g_lock);
+		} else {
+			pr_err("block page not found, ring is broken\n");
+			set_bit(TCMU_DEV_BIT_BROKEN, &udev->flags);
+			break;
+		}
+	} while (1);
  
  	spin_unlock_irq(&udev->cmdr_lock);
  }
@@ -846,6 +969,43 @@ static int tcmu_find_mem_index(struct vm_area_struct *vma)
  	return -1;
  }
  
+/*
+ * Normally it shouldn't be here. This is just for avoid
+ * the page fault call trace, and will return zeroed page.
+ */
+static struct page *tcmu_try_to_alloc_new_page(struct tcmu_dev *udev, uint32_t dbi)
+{
+	struct page *page;
+	int ret;
+
+	if (dbi >= udev->dbi_thresh) {
+		udev->dbi_thresh = dbi;
+		udev->dbi_cur = dbi;
+	}
+
+	page = alloc_page(GFP_ATOMIC | __GFP_ZERO);
+	if (!page) {
+		return NULL;
+	}
+
+	ret = radix_tree_insert(&udev->data_blocks, dbi, page);
+	if (ret) {
+		__free_page(page);
+		return NULL;
+	}
+
+	/*
+	 * Since this case is rare in page fault routine, here we
+	 * will allow the global_db_count >= TCMU_GLOBAL_MAX_BLOCKS
+	 * to reduce possible page fault call trace.
+	 */
+	spin_lock_irq(&g_lock);
+	global_db_count++;
+	spin_unlock_irq(&g_lock);
+
+	return page;
+}
+
  static int tcmu_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
  {
  	struct tcmu_dev *udev = vma->vm_private_data;
@@ -869,14 +1029,17 @@ static int tcmu_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
  		addr = (void *)(unsigned long)info->mem[mi].addr + offset;
  		page = vmalloc_to_page(addr);
  	} else {
-		/* For the dynamically growing data area pages */
  		uint32_t dbi;
  
+		/* For the dynamically growing data area pages */
  		dbi = (offset - udev->data_off) / DATA_BLOCK_SIZE;
-		addr = tcmu_db_get_block_addr(udev, dbi);
-		if (!addr)
+		spin_lock_irq(&udev->cmdr_lock);
+		page = tcmu_db_get_block_page(udev, dbi);
+		if (!page)
+			page = tcmu_try_to_alloc_new_page(udev, dbi);
+		spin_unlock_irq(&udev->cmdr_lock);
+		if (!page)
  			return VM_FAULT_NOPAGE;
-		page = virt_to_page(addr);
  	}
  
  	get_page(page);
@@ -913,6 +1076,8 @@ static int tcmu_open(struct uio_info *info, struct inode *inode)
  	if (test_and_set_bit(TCMU_DEV_BIT_OPEN, &udev->flags))
  		return -EBUSY;
  
+	udev->inode = inode;
+
  	pr_debug("open\n");
  
  	return 0;
@@ -1003,6 +1168,8 @@ static int tcmu_configure_device(struct se_device *dev)
  	udev->cmdr_size = CMDR_SIZE - CMDR_OFF;
  	udev->data_off = CMDR_SIZE;
  	udev->data_size = DATA_SIZE;
+	udev->dbi_thresh = DATA_BLOCK_BITS;
+	udev->unmapping = false;
  
  	/* Initialise the mailbox of the ring buffer */
  	mb = udev->mb_addr;
@@ -1048,6 +1215,10 @@ static int tcmu_configure_device(struct se_device *dev)
  	if (ret)
  		goto err_netlink;
  
+	mutex_lock(&g_mutex);
+	list_add(&udev->node, &root_udev);
+	mutex_unlock(&g_mutex);
+
  	return 0;
  
  err_netlink:
@@ -1072,6 +1243,10 @@ static void tcmu_free_device(struct se_device *dev)
  {
  	struct tcmu_dev *udev = TCMU_DEV(dev);
  
+	mutex_lock(&g_mutex);
+	list_del(&udev->node);
+	mutex_unlock(&g_mutex);
+
  	vfree(udev->mb_addr);
  
  	/* Upper layer should drain all requests before calling this */
@@ -1235,12 +1410,90 @@ static sector_t tcmu_get_blocks(struct se_device *dev)
  	.tb_dev_attrib_attrs	= passthrough_attrib_attrs,
  };
  
+static struct task_struct *unmap_thread;
+
+/*
+ * The unmapping thread routine.
+ */
+static int unmap_thread_fn(void *data)
+{
+	struct tcmu_dev *udev;
+	loff_t offset;
+	uint32_t start, end, dbi;
+	struct page *page;
+	bool unmapped;
+	int i;
+
+	while (1) {
+		DEFINE_WAIT(__wait);
+
+		prepare_to_wait(&g_wait, &__wait, TASK_INTERRUPTIBLE);
+		schedule();
+		finish_wait(&g_wait, &__wait);
+
+		unmapped = false;
+		mutex_lock(&g_mutex);
+		list_for_each_entry(udev, &root_udev, node) {
+			spin_lock_irq(&udev->cmdr_lock);
+			end = udev->dbi_cur + 1;
+			dbi = find_last_bit(udev->data_bitmap, end);
+			if (dbi == end) {
+				/*
+				 * Reserved for DATA_BLOCK_RES_BITS
+				 * blocks for idle udev
+				 */
+				dbi = DATA_BLOCK_RES_BITS - 1;
+				udev->dbi_cur = 0;
+			} else {
+				udev->dbi_cur = dbi;
+			}
+
+			udev->dbi_thresh = start = dbi + 1;
+			if (start >= end) {
+				spin_unlock_irq(&udev->cmdr_lock);
+				continue;
+			}
+			udev->unmapping = true;
+			spin_unlock_irq(&udev->cmdr_lock);
+
+			/* Here will truncate the ring from offset */
+			offset = udev->data_off + start * DATA_BLOCK_SIZE;
+			unmap_mapping_range(udev->inode->i_mapping, offset, 0, 1);
+			unmapped = true;
+
+			spin_lock_irq(&udev->cmdr_lock);
+			for (i = start; i < end; i++) {
+				page = radix_tree_delete(&udev->data_blocks, i);
+				if (page) {
+					__free_page(page);
+					spin_lock_irq(&g_lock);
+					global_db_count--;
+					spin_unlock_irq(&g_lock);
+				}
+			}
+			udev->unmapping = false;
+			spin_unlock_irq(&udev->cmdr_lock);
+		}
+
+		if (unmapped) {
+			list_for_each_entry(udev, &root_udev, node)
+				if (udev->waiting_global)
+					wake_up(&udev->wait_cmdr);
+		}
+		mutex_unlock(&g_mutex);
+	}
+
+	return 0;
+}
+
  static int __init tcmu_module_init(void)
  {
  	int ret;
  
  	BUILD_BUG_ON((sizeof(struct tcmu_cmd_entry) % TCMU_OP_ALIGN_SIZE) != 0);
  
+	spin_lock_init(&g_lock);
+
  	tcmu_cmd_cache = kmem_cache_create("tcmu_cmd_cache",
  				sizeof(struct tcmu_cmd),
  				__alignof__(struct tcmu_cmd),
@@ -1263,8 +1516,17 @@ static int __init tcmu_module_init(void)
  	if (ret)
  		goto out_unreg_genl;
  
+	init_waitqueue_head(&g_wait);
+	unmap_thread = kthread_run(unmap_thread_fn, NULL, "tcmu_unmap");
+	if (IS_ERR(unmap_thread)) {
+		unmap_thread = NULL;
+		goto out_unreg_transport;
+	}
+
  	return 0;
  
+out_unreg_transport:
+	target_backend_unregister(&tcmu_ops);
  out_unreg_genl:
  	genl_unregister_family(&tcmu_genl_family);
  out_unreg_device:
@@ -1277,6 +1539,9 @@ static int __init tcmu_module_init(void)
  
  static void __exit tcmu_module_exit(void)
  {
+	if (unmap_thread)
+		kthread_stop(unmap_thread);
+
  	target_backend_unregister(&tcmu_ops);
  	genl_unregister_family(&tcmu_genl_family);
  	root_device_unregister(tcmu_root_device);
-- 1.8.3.1



--------------1193870FEE65F4668BBF3826
Content-Type: text/html; charset=windows-1252
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=windows-1252"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <br>
    <blockquote
      cite="mid:3b1ce412-6072-fda1-3002-220cf8fbf34f@redhat.com"
      type="cite">Hi Xiubo,
      <br>
      <br>
      I will leave the detailed patch critique to others but this does
      seem to achieve the goals of 1) larger TCMU data buffers to
      prevent bottlenecks and 2) Allocating memory in a way that avoids
      using up all system memory in corner cases.
      <br>
      <br>
      The one thing I'm still unsure about is what we need to do to
      maintain the data area's virtual mapping properly. Nobody on
      linux-mm answered my email a few days ago on the right way to do
      this, alas. But, userspace accessing the data area is going to
      cause tcmu_vma_fault() to be called, and it seems to me like we
      must proactively do something -- some kind of unmap call -- before
      we can reuse that memory for another, possibly completely
      unrelated, backstore's data area. This could allow one backstore
      handler to read or write another's data.
      <br>
      <br>
    </blockquote>
    <br>
    Hi Andy, Mike<br>
    <br>
    These days what I have gotten is that the unmap_mapping_range()
    could be used.<br>
    At the same time I have deep into the mm code and fixed the double
    usage of<br>
    the data blocks and possible page fault call trace bugs mentioned
    above.<br>
    <br>
    Following is the V3 patch. I have test this using 4 targets &amp;
    fio for about 2 days, so<br>
    far so good.<br>
    <br>
    I'm still testing this using more complex test case.<br>
    <br>
    Thanks<br>
    <br>
    <pre wrap="">From: Xiubo Li <a class="moz-txt-link-rfc2396E" href="mailto:lixiubo@cmss.chinamobile.com">&lt;lixiubo@cmss.chinamobile.com&gt;</a>

For each target there will be one ring, when the target number
grows larger and larger, it could eventually runs out of the
system memories.

In this patch for each target ring, for the cmd area the size
will be limited to 8MB and for the data area the size will be
limited to 256K * PAGE_SIZE.

For all the targets' data areas, they will get empty blocks
from the "global data block pool", which has limited to 512K *
PAGE_SIZE for now.

When the "global data block pool" has been used up, then any
target could trigger the unmapping thread routine to shrink the
targets' rings. And for the idle targets the unmapping routine
will reserve 256 blocks at least.

When user space has touched the data blocks out of the iov[N],
the tcmu_page_fault() will return one zeroed blocks.

Signed-off-by: Xiubo Li <a class="moz-txt-link-rfc2396E" href="mailto:lixiubo@cmss.chinamobile.com">&lt;lixiubo@cmss.chinamobile.com&gt;</a>
Signed-off-by: Jianfei Hu <a class="moz-txt-link-rfc2396E" href="mailto:hujianfei@cmss.chinamobile.com">&lt;hujianfei@cmss.chinamobile.com&gt;</a>
---
 drivers/target/target_core_user.c | 433 ++++++++++++++++++++++++++++++--------
 1 file changed, 349 insertions(+), 84 deletions(-)

diff --git a/drivers/target/target_core_user.c b/drivers/target/target_core_user.c
index e904bc0..bbc52074 100644
--- a/drivers/target/target_core_user.c
+++ b/drivers/target/target_core_user.c
@@ -30,6 +30,8 @@
 #include &lt;linux/stringify.h&gt;
 #include &lt;linux/bitops.h&gt;
 #include &lt;linux/highmem.h&gt;
+#include &lt;linux/mutex.h&gt;
+#include &lt;linux/kthread.h&gt;
 #include &lt;net/genetlink.h&gt;
 #include &lt;scsi/scsi_common.h&gt;
 #include &lt;scsi/scsi_proto.h&gt;
@@ -66,17 +68,24 @@
 
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
+#define DATA_BLOCK_RES_BITS 256
 
-/* The ring buffer size is 34M */
+/* The total size of the ring is 8M + 256K * PAGE_SIZE */
 #define TCMU_RING_SIZE (CMDR_SIZE + DATA_SIZE)
 
+/* Default maximum of the global data blocks(512K * PAGE_SIZE) */
+#define TCMU_GLOBAL_MAX_BLOCKS (512 * 1024)
+
 static struct device *tcmu_root_device;
 
 struct tcmu_hba {
@@ -86,6 +95,8 @@ struct tcmu_hba {
 #define TCMU_CONFIG_LEN 256
 
 struct tcmu_dev {
+	struct list_head node;
+
 	struct se_device se_dev;
 
 	char *name;
@@ -97,6 +108,15 @@ struct tcmu_dev {
 
 	struct uio_info uio_info;
 
+	struct inode *inode;
+
+	bool unmapping;
+	bool waiting_global;
+	uint32_t dbi_cur;
+	uint32_t dbi_thresh;
+	DECLARE_BITMAP(data_bitmap, DATA_BLOCK_BITS);
+	struct radix_tree_root data_blocks;
+
 	struct tcmu_mailbox *mb_addr;
 	size_t dev_size;
 	u32 cmdr_size;
@@ -110,10 +130,6 @@ struct tcmu_dev {
 	/* TODO should this be a mutex? */
 	spinlock_t cmdr_lock;
 
-	uint32_t dbi_cur;
-	DECLARE_BITMAP(data_bitmap, DATA_BLOCK_BITS);
-	struct radix_tree_root data_blocks;
-
 	struct idr commands;
 	spinlock_t commands_lock;
 
@@ -137,6 +153,11 @@ struct tcmu_cmd {
 	uint32_t *dbi;
 };
 
+static wait_queue_head_t g_wait;
+static DEFINE_MUTEX(g_mutex);
+static LIST_HEAD(root_udev);
+static spinlock_t g_lock;
+static unsigned long global_db_count;
 static struct kmem_cache *tcmu_cmd_cache;
 
 /* multicast group */
@@ -160,54 +181,89 @@ enum tcmu_multicast_groups {
 	.netnsok = true,
 };
 
-static int tcmu_db_get_empty_block(struct tcmu_dev *udev, void **addr)
+#define tcmu_cmd_reset_dbi_cur(cmd) ((cmd)-&gt;dbi_cur = 0)
+#define tcmu_cmd_set_dbi(cmd, index) ((cmd)-&gt;dbi[(cmd)-&gt;dbi_cur++] = (index))
+#define tcmu_cmd_get_dbi(cmd) ((cmd)-&gt;dbi[(cmd)-&gt;dbi_cur++])
+
+static inline void tcmu_cmd_free_data(struct tcmu_cmd *tcmu_cmd, uint32_t len)
 {
-	void *p;
-	uint32_t dbi;
-	int ret;
+	struct tcmu_dev *udev = tcmu_cmd-&gt;tcmu_dev;
+	uint32_t i;
 
-	dbi = find_first_zero_bit(udev-&gt;data_bitmap, DATA_BLOCK_BITS);
-	if (dbi &gt; udev-&gt;dbi_cur)
-		udev-&gt;dbi_cur = dbi;
+	for (i = 0; i &lt; len; i++)
+		clear_bit(tcmu_cmd-&gt;dbi[i], udev-&gt;data_bitmap);
+}
 
-	set_bit(dbi, udev-&gt;data_bitmap);
+static inline bool get_empty_growing_block(struct tcmu_dev *udev,
+					   struct tcmu_cmd *tcmu_cmd)
+{
+	struct page *page;
+	int ret, dbi;
 
-	p = radix_tree_lookup(&amp;udev-&gt;data_blocks, dbi);
-	if (!p) {
-		p = kzalloc(DATA_BLOCK_SIZE, GFP_ATOMIC);
-		if (!p) {
-			clear_bit(dbi, udev-&gt;data_bitmap);
-			return -ENOMEM;
+	dbi = find_first_zero_bit(udev-&gt;data_bitmap, udev-&gt;dbi_thresh);
+	if (dbi == udev-&gt;dbi_thresh)
+		return false;
+
+	page = radix_tree_lookup(&amp;udev-&gt;data_blocks, dbi);
+	if (!page) {
+		/* try to get new page from the mm */
+		spin_lock_irq(&amp;g_lock);
+		if (global_db_count &gt;= TCMU_GLOBAL_MAX_BLOCKS) {
+			spin_unlock_irq(&amp;g_lock);
+			wake_up(&amp;g_wait);
+			return false;
+		}
+		global_db_count++;
+		spin_unlock_irq(&amp;g_lock);
+
+		page = alloc_page(GFP_ATOMIC);
+		if (!page) {
+			return false;
 		}
 
-		ret = radix_tree_insert(&amp;udev-&gt;data_blocks, dbi, p);
+		ret = radix_tree_insert(&amp;udev-&gt;data_blocks, dbi, page);
 		if (ret) {
-			kfree(p);
-			clear_bit(dbi, udev-&gt;data_bitmap);
-			return ret;
+			__free_page(page);
+			return false;
 		}
 	}
 
-	*addr = p;
-	return dbi;
+	if (dbi &gt; udev-&gt;dbi_cur)
+		udev-&gt;dbi_cur = dbi;
+
+	set_bit(dbi, udev-&gt;data_bitmap);
+	tcmu_cmd_set_dbi(tcmu_cmd, dbi);
+
+	return true;
 }
 
-static void *tcmu_db_get_block_addr(struct tcmu_dev *udev, uint32_t dbi)
+static bool tcmu_db_get_empty_blocks(struct tcmu_dev *udev,
+				     struct tcmu_cmd *tcmu_cmd)
 {
-	return radix_tree_lookup(&amp;udev-&gt;data_blocks, dbi);
-}
+	int i;
 
-#define tcmu_cmd_reset_dbi_cur(cmd) ((cmd)-&gt;dbi_cur = 0)
-#define tcmu_cmd_set_dbi(cmd, index) ((cmd)-&gt;dbi[(cmd)-&gt;dbi_cur++] = (index))
-#define tcmu_cmd_get_dbi(cmd) ((cmd)-&gt;dbi[(cmd)-&gt;dbi_cur++])
+	tcmu_cmd_reset_dbi_cur(tcmu_cmd);
+	for (i = 0; i &lt; tcmu_cmd-&gt;dbi_len; i++) {
+		if (!get_empty_growing_block(udev, tcmu_cmd))
+			goto err;
+	}
+	return true;
 
-static void tcmu_cmd_free_data(struct tcmu_cmd *tcmu_cmd)
+err:
+	tcmu_cmd_free_data(tcmu_cmd, tcmu_cmd-&gt;dbi_cur);
+	udev-&gt;waiting_global = true;
+	return false;
+}
+
+static struct page *tcmu_db_get_block_page(struct tcmu_dev *udev, uint32_t dbi)
 {
-	struct tcmu_dev *udev = tcmu_cmd-&gt;tcmu_dev;
-	uint32_t bi;
+	struct page *page;
 
-	for (bi = 0; bi &lt; tcmu_cmd-&gt;dbi_len; bi++)
-		clear_bit(tcmu_cmd-&gt;dbi[bi], udev-&gt;data_bitmap);
+	page = radix_tree_lookup(&amp;udev-&gt;data_blocks, dbi);
+	if (!page)
+		return NULL;
+
+	return page;
 }
 
 static inline void tcmu_free_cmd(struct tcmu_cmd *tcmu_cmd)
@@ -344,17 +400,20 @@ static int alloc_and_scatter_data_area(struct tcmu_dev *udev,
 	void *from, *to = NULL;
 	size_t copy_bytes, to_offset, offset;
 	struct scatterlist *sg;
+	struct page *page;
 
 	for_each_sg(data_sg, sg, data_nents, i) {
 		int sg_remaining = sg-&gt;length;
 		from = kmap_atomic(sg_page(sg)) + sg-&gt;offset;
 		while (sg_remaining &gt; 0) {
 			if (block_remaining == 0) {
+				if (to)
+					kunmap_atomic(to);
+
 				block_remaining = DATA_BLOCK_SIZE;
-				dbi = tcmu_db_get_empty_block(udev, &amp;to);
-				if (dbi &lt; 0)
-					return dbi;
-				tcmu_cmd_set_dbi(tcmu_cmd, dbi);
+				dbi = tcmu_cmd_get_dbi(tcmu_cmd);
+				page = tcmu_db_get_block_page(udev, dbi);
+				to = kmap_atomic(page);
 			}
 
 			copy_bytes = min_t(size_t, sg_remaining,
@@ -362,7 +421,7 @@ static int alloc_and_scatter_data_area(struct tcmu_dev *udev,
 			to_offset = get_block_offset_user(udev, dbi,
 					block_remaining);
 			offset = DATA_BLOCK_SIZE - block_remaining;
-			to = (void *)(unsigned long)to + offset;
+			to = (void *)((unsigned long)to + offset);
 
 			if (*iov_cnt != 0 &amp;&amp;
 			    to_offset == iov_tail(udev, *iov)) {
@@ -382,6 +441,8 @@ static int alloc_and_scatter_data_area(struct tcmu_dev *udev,
 		}
 		kunmap_atomic(from - sg-&gt;offset);
 	}
+	if (to)
+		kunmap_atomic(to);
 
 	return 0;
 }
@@ -391,23 +452,28 @@ static void gather_data_area(struct tcmu_dev *udev, struct tcmu_cmd *tcmu_cmd,
 {
 	int i, dbi;
 	int block_remaining = 0;
-	void *from, *to;
+	void *from = NULL, *to;
 	size_t copy_bytes, offset;
 	struct scatterlist *sg;
+	struct page *page;
 
 	for_each_sg(data_sg, sg, data_nents, i) {
 		int sg_remaining = sg-&gt;length;
 		to = kmap_atomic(sg_page(sg)) + sg-&gt;offset;
 		while (sg_remaining &gt; 0) {
 			if (block_remaining == 0) {
+				if (from)
+					kunmap_atomic(from);
+
 				block_remaining = DATA_BLOCK_SIZE;
 				dbi = tcmu_cmd_get_dbi(tcmu_cmd);
-				from = tcmu_db_get_block_addr(udev, dbi);
+				page = tcmu_db_get_block_page(udev, dbi);
+				from = kmap_atomic(page);
 			}
 			copy_bytes = min_t(size_t, sg_remaining,
 					block_remaining);
 			offset = DATA_BLOCK_SIZE - block_remaining;
-			from = (void *)(unsigned long)from + offset;
+			from = (void *)((unsigned long)from + offset);
 			tcmu_flush_dcache_range(from, copy_bytes);
 			memcpy(to + sg-&gt;length - sg_remaining, from,
 					copy_bytes);
@@ -417,12 +483,13 @@ static void gather_data_area(struct tcmu_dev *udev, struct tcmu_cmd *tcmu_cmd,
 		}
 		kunmap_atomic(to - sg-&gt;offset);
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
@@ -431,12 +498,14 @@ static inline size_t spc_bitmap_free(unsigned long *bitmap)
  *
  * Called with ring lock held.
  */
-static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t data_needed)
+static bool is_ring_space_avail(struct tcmu_dev *udev, struct tcmu_cmd *cmd,
+		size_t cmd_size, size_t data_needed)
 {
 	struct tcmu_mailbox *mb = udev-&gt;mb_addr;
 	size_t space, cmd_needed;
 	u32 cmd_head;
 
+	udev-&gt;waiting_global = false;
 	tcmu_flush_dcache_range(mb, sizeof(*mb));
 
 	cmd_head = mb-&gt;cmd_head % udev-&gt;cmdr_size; /* UAM */
@@ -457,10 +526,24 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
 		return false;
 	}
 
-	space = spc_bitmap_free(udev-&gt;data_bitmap);
+	/* try to check and get the data blocks as needed */
+	space = spc_bitmap_free(udev-&gt;data_bitmap, udev-&gt;dbi_thresh);
 	if (space &lt; data_needed) {
-		pr_debug("no data space: only %zu available, but ask for %zu\n",
-				space, data_needed);
+		if (udev-&gt;unmapping) {
+			pr_debug("no data space: only %zu available, but ask for %zu\n",
+					space, data_needed);
+			return false;
+		} else {
+			udev-&gt;dbi_thresh += udev-&gt;dbi_thresh / 2;
+			udev-&gt;dbi_thresh = min((int)udev-&gt;dbi_thresh, DATA_BLOCK_BITS);
+			space = spc_bitmap_free(udev-&gt;data_bitmap, udev-&gt;dbi_thresh);
+			if (space &lt; data_needed)
+				return false;
+		}
+	}
+
+	if (!tcmu_db_get_empty_blocks(udev, cmd)) {
+		pr_debug("no data space: ask for %zu\n", data_needed);
 		return false;
 	}
 
@@ -519,7 +602,7 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
 		return TCM_INVALID_CDB_FIELD;
 	}
 
-	while (!is_ring_space_avail(udev, command_size, data_length)) {
+	while (!is_ring_space_avail(udev, tcmu_cmd, command_size, data_length)) {
 		int ret;
 		DEFINE_WAIT(__wait);
 
@@ -567,6 +650,7 @@ static bool is_ring_space_avail(struct tcmu_dev *udev, size_t cmd_size, size_t d
 	entry-&gt;hdr.uflags = 0;
 
 	/* Handle allocating space from the data area */
+	tcmu_cmd_reset_dbi_cur(tcmu_cmd);
 	iov = &amp;entry-&gt;req.iov[0];
 	iov_cnt = 0;
 	copy_to_data_area = (se_cmd-&gt;data_direction == DMA_TO_DEVICE
@@ -664,7 +748,7 @@ static void tcmu_handle_completion(struct tcmu_cmd *cmd, struct tcmu_cmd_entry *
 	target_complete_cmd(cmd-&gt;se_cmd, entry-&gt;rsp.scsi_status);
 
 	cmd-&gt;se_cmd = NULL;
-	tcmu_cmd_free_data(cmd);
+	tcmu_cmd_free_data(cmd, cmd-&gt;dbi_len);
 	tcmu_free_cmd(cmd);
 }
 
@@ -783,41 +867,80 @@ static int tcmu_irqcontrol(struct uio_info *info, s32 irq_on)
 
 static void tcmu_db_release(struct tcmu_dev *udev, bool release_pending)
 {
-	uint32_t dbi, end;
-	void *addr;
+	int dbi = -1, end;
+	struct page *page;
 
 	spin_lock_irq(&amp;udev-&gt;cmdr_lock);
-
 	end = udev-&gt;dbi_cur + 1;
 
-	/* try to release all unused blocks */
-	dbi = find_first_zero_bit(udev-&gt;data_bitmap, end);
-	if (dbi &gt;= end) {
-		spin_unlock_irq(&amp;udev-&gt;cmdr_lock);
-		return;
-	}
+	/* try to release all unused but has mapped blocks */
 	do {
-		addr = radix_tree_delete(&amp;udev-&gt;data_blocks, dbi);
-		kfree(addr);
-
 		dbi = find_next_zero_bit(udev-&gt;data_bitmap, end, dbi + 1);
-	} while (dbi &lt; end);
+		if (dbi == end)
+			break;
 
-	if (!release_pending)
-		return;
+		/*
+		 * When the bit is cleared and p != NULL, meaning that
+		 * this tcmu block had already freed-after-use.
+		 *
+		 * If p-&gt;user == 0, meaning that the current ring buffer
+		 * is the last or the only user of the tcmu block, and
+		 * it must already in the free list, so it could be
+		 * remove from the list and then released its memories.
+		 *
+		 * If p-&gt;user != 0, meaning that the current tcmu block is
+		 * still referenced by other ring buffers, so just ignore
+		 * it without doing anyting.
+		 */
+		page = radix_tree_delete(&amp;udev-&gt;data_blocks, dbi);
+		if (page) {
+				__free_page(page);
+				spin_lock_irq(&amp;g_lock);
+				global_db_count--;
+				spin_unlock_irq(&amp;g_lock);
+		}
+	} while (1);
 
-	/* try to release all pending blocks */
-	dbi = find_first_bit(udev-&gt;data_bitmap, end);
-	if (dbi &gt;= end) {
+	if (!release_pending) {
 		spin_unlock_irq(&amp;udev-&gt;cmdr_lock);
 		return;
 	}
-	do {
-		addr = radix_tree_delete(&amp;udev-&gt;data_blocks, dbi);
-		kfree(addr);
 
+	/* try to release all pending blocks */
+	dbi = -1;
+	do {
 		dbi = find_next_bit(udev-&gt;data_bitmap, end, dbi + 1);
-	} while (dbi &lt; end);
+		if (dbi == end)
+			break;
+
+		clear_bit(dbi, udev-&gt;data_bitmap);
+
+		/*
+		 * When the bit is set and p != NULL, meaning that this
+		 * tcmu block is still being used here.
+		 *
+		 * If p-&gt;user == 0, meaning that the current ring buffer
+		 * is the last or the only user of this tcmu block, and
+		 * it won't in the free list, so could just release its
+		 * memories.
+		 *
+		 * If the p-&gt;user != 0, we should insert it to the free
+		 * list.
+		 *
+		 * p == NULL means that the current ring buffer is broken.
+		 */
+		page = radix_tree_delete(&amp;udev-&gt;data_blocks, dbi);
+		if (page) {
+				__free_page(page);
+				spin_lock_irq(&amp;g_lock);
+				global_db_count--;
+				spin_unlock_irq(&amp;g_lock);
+		} else {
+			pr_err("block page not found, ring is broken\n");
+			set_bit(TCMU_DEV_BIT_BROKEN, &amp;udev-&gt;flags);
+			break;
+		}
+	} while (1);
 
 	spin_unlock_irq(&amp;udev-&gt;cmdr_lock);
 }
@@ -846,6 +969,43 @@ static int tcmu_find_mem_index(struct vm_area_struct *vma)
 	return -1;
 }
 
+/*
+ * Normally it shouldn't be here. This is just for avoid
+ * the page fault call trace, and will return zeroed page.
+ */
+static struct page *tcmu_try_to_alloc_new_page(struct tcmu_dev *udev, uint32_t dbi)
+{
+	struct page *page;
+	int ret;
+
+	if (dbi &gt;= udev-&gt;dbi_thresh) {
+		udev-&gt;dbi_thresh = dbi;
+		udev-&gt;dbi_cur = dbi;
+	}
+
+	page = alloc_page(GFP_ATOMIC | __GFP_ZERO);
+	if (!page) {
+		return NULL;
+	}
+
+	ret = radix_tree_insert(&amp;udev-&gt;data_blocks, dbi, page);
+	if (ret) {
+		__free_page(page);
+		return NULL;
+	}
+
+	/*
+	 * Since this case is rare in page fault routine, here we
+	 * will allow the global_db_count &gt;= TCMU_GLOBAL_MAX_BLOCKS
+	 * to reduce possible page fault call trace.
+	 */
+	spin_lock_irq(&amp;g_lock);
+	global_db_count++;
+	spin_unlock_irq(&amp;g_lock);
+
+	return page;
+}
+
 static int tcmu_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct tcmu_dev *udev = vma-&gt;vm_private_data;
@@ -869,14 +1029,17 @@ static int tcmu_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		addr = (void *)(unsigned long)info-&gt;mem[mi].addr + offset;
 		page = vmalloc_to_page(addr);
 	} else {
-		/* For the dynamically growing data area pages */
 		uint32_t dbi;
 
+		/* For the dynamically growing data area pages */
 		dbi = (offset - udev-&gt;data_off) / DATA_BLOCK_SIZE;
-		addr = tcmu_db_get_block_addr(udev, dbi);
-		if (!addr)
+		spin_lock_irq(&amp;udev-&gt;cmdr_lock);
+		page = tcmu_db_get_block_page(udev, dbi);
+		if (!page)
+			page = tcmu_try_to_alloc_new_page(udev, dbi);
+		spin_unlock_irq(&amp;udev-&gt;cmdr_lock);
+		if (!page)
 			return VM_FAULT_NOPAGE;
-		page = virt_to_page(addr);
 	}
 
 	get_page(page);
@@ -913,6 +1076,8 @@ static int tcmu_open(struct uio_info *info, struct inode *inode)
 	if (test_and_set_bit(TCMU_DEV_BIT_OPEN, &amp;udev-&gt;flags))
 		return -EBUSY;
 
+	udev-&gt;inode = inode;
+
 	pr_debug("open\n");
 
 	return 0;
@@ -1003,6 +1168,8 @@ static int tcmu_configure_device(struct se_device *dev)
 	udev-&gt;cmdr_size = CMDR_SIZE - CMDR_OFF;
 	udev-&gt;data_off = CMDR_SIZE;
 	udev-&gt;data_size = DATA_SIZE;
+	udev-&gt;dbi_thresh = DATA_BLOCK_BITS;
+	udev-&gt;unmapping = false;
 
 	/* Initialise the mailbox of the ring buffer */
 	mb = udev-&gt;mb_addr;
@@ -1048,6 +1215,10 @@ static int tcmu_configure_device(struct se_device *dev)
 	if (ret)
 		goto err_netlink;
 
+	mutex_lock(&amp;g_mutex);
+	list_add(&amp;udev-&gt;node, &amp;root_udev);
+	mutex_unlock(&amp;g_mutex);
+
 	return 0;
 
 err_netlink:
@@ -1072,6 +1243,10 @@ static void tcmu_free_device(struct se_device *dev)
 {
 	struct tcmu_dev *udev = TCMU_DEV(dev);
 
+	mutex_lock(&amp;g_mutex);
+	list_del(&amp;udev-&gt;node);
+	mutex_unlock(&amp;g_mutex);
+
 	vfree(udev-&gt;mb_addr);
 
 	/* Upper layer should drain all requests before calling this */
@@ -1235,12 +1410,90 @@ static sector_t tcmu_get_blocks(struct se_device *dev)
 	.tb_dev_attrib_attrs	= passthrough_attrib_attrs,
 };
 
+static struct task_struct *unmap_thread;
+
+/*
+ * The unmapping thread routine.
+ */
+static int unmap_thread_fn(void *data)
+{
+	struct tcmu_dev *udev;
+	loff_t offset;
+	uint32_t start, end, dbi;
+	struct page *page;
+	bool unmapped;
+	int i;
+
+	while (1) {
+		DEFINE_WAIT(__wait);
+
+		prepare_to_wait(&amp;g_wait, &amp;__wait, TASK_INTERRUPTIBLE);
+		schedule();
+		finish_wait(&amp;g_wait, &amp;__wait);
+
+		unmapped = false;
+		mutex_lock(&amp;g_mutex);
+		list_for_each_entry(udev, &amp;root_udev, node) {
+			spin_lock_irq(&amp;udev-&gt;cmdr_lock);
+			end = udev-&gt;dbi_cur + 1;
+			dbi = find_last_bit(udev-&gt;data_bitmap, end);
+			if (dbi == end) {
+				/*
+				 * Reserved for DATA_BLOCK_RES_BITS
+				 * blocks for idle udev
+				 */
+				dbi = DATA_BLOCK_RES_BITS - 1;
+				udev-&gt;dbi_cur = 0;
+			} else {
+				udev-&gt;dbi_cur = dbi;
+			}
+
+			udev-&gt;dbi_thresh = start = dbi + 1;
+			if (start &gt;= end) {
+				spin_unlock_irq(&amp;udev-&gt;cmdr_lock);
+				continue;
+			}
+			udev-&gt;unmapping = true;
+			spin_unlock_irq(&amp;udev-&gt;cmdr_lock);
+
+			/* Here will truncate the ring from offset */
+			offset = udev-&gt;data_off + start * DATA_BLOCK_SIZE;
+			unmap_mapping_range(udev-&gt;inode-&gt;i_mapping, offset, 0, 1);
+			unmapped = true;
+
+			spin_lock_irq(&amp;udev-&gt;cmdr_lock);
+			for (i = start; i &lt; end; i++) {
+				page = radix_tree_delete(&amp;udev-&gt;data_blocks, i);
+				if (page) {
+					__free_page(page);
+					spin_lock_irq(&amp;g_lock);
+					global_db_count--;
+					spin_unlock_irq(&amp;g_lock);
+				}
+			}
+			udev-&gt;unmapping = false;
+			spin_unlock_irq(&amp;udev-&gt;cmdr_lock);
+		}
+
+		if (unmapped) {
+			list_for_each_entry(udev, &amp;root_udev, node)
+				if (udev-&gt;waiting_global)
+					wake_up(&amp;udev-&gt;wait_cmdr);
+		}
+		mutex_unlock(&amp;g_mutex);
+	}
+
+	return 0;
+}
+
 static int __init tcmu_module_init(void)
 {
 	int ret;
 
 	BUILD_BUG_ON((sizeof(struct tcmu_cmd_entry) % TCMU_OP_ALIGN_SIZE) != 0);
 
+	spin_lock_init(&amp;g_lock);
+
 	tcmu_cmd_cache = kmem_cache_create("tcmu_cmd_cache",
 				sizeof(struct tcmu_cmd),
 				__alignof__(struct tcmu_cmd),
@@ -1263,8 +1516,17 @@ static int __init tcmu_module_init(void)
 	if (ret)
 		goto out_unreg_genl;
 
+	init_waitqueue_head(&amp;g_wait);
+	unmap_thread = kthread_run(unmap_thread_fn, NULL, "tcmu_unmap");
+	if (IS_ERR(unmap_thread)) {
+		unmap_thread = NULL;
+		goto out_unreg_transport;
+	}
+
 	return 0;
 
+out_unreg_transport:
+	target_backend_unregister(&amp;tcmu_ops);
 out_unreg_genl:
 	genl_unregister_family(&amp;tcmu_genl_family);
 out_unreg_device:
@@ -1277,6 +1539,9 @@ static int __init tcmu_module_init(void)
 
 static void __exit tcmu_module_exit(void)
 {
+	if (unmap_thread)
+		kthread_stop(unmap_thread);
+
 	target_backend_unregister(&amp;tcmu_ops);
 	genl_unregister_family(&amp;tcmu_genl_family);
 	root_device_unregister(tcmu_root_device);
<div class="moz-txt-sig">-- 
1.8.3.1

</div></pre>
    <br>
  </body>
</html>

--------------1193870FEE65F4668BBF3826--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
