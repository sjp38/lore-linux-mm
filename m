Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5FCF46B0033
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 19:55:11 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id q6so11634933pff.16
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 16:55:11 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id t192si8470292pgc.23.2017.12.28.16.55.09
        for <linux-mm@kvack.org>;
        Thu, 28 Dec 2017 16:55:10 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm for mmotm: Revert skip swap cache feture for synchronous device
Date: Fri, 29 Dec 2017 09:55:07 +0900
Message-Id: <1514508907-10039-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, James Bottomley <James.Bottomley@hansenpartnership.com>, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ilya Dryomov <idryomov@gmail.com>, Jens Axboe <axboe@kernel.dk>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Huang Ying <ying.huang@intel.com>

James reported a bug of swap paging-in for his testing and found it
at rc5, soon to be -rc5.

Although we can fix the specific problem at the moment, it may
have other lurkig bugs so want to have one more cycle in -next
before merging.

This patchset reverts 23c47d2ada9f, 08fa93021d80, 8e31f339295f completely
but 79b5f08fa34e partially because the swp_swap_info function that
79b5f08fa34e introduced is used by [1].

[1] e9a6effa5005, mm, swap: fix false error message in __swp_swapcount()

Link: http://lkml.kernel.org/r/<1514407817.4169.4.camel@HansenPartnership.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Ilya Dryomov <idryomov@gmail.com>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>
Debugged-by: James Bottomley <James.Bottomley@hansenpartnership.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
This patch is against on v4.15-rc4-mmotm-2017-12-22-17-55. VMA-based
readahead restructuring patchset makes diversion so need to send
separate reverting patch from linus's tree.

Thanks.

 drivers/block/brd.c           |  2 --
 drivers/block/zram/zram_drv.c |  2 +-
 drivers/nvdimm/btt.c          |  3 ---
 drivers/nvdimm/pmem.c         |  2 --
 include/linux/backing-dev.h   |  8 --------
 include/linux/swap.h          | 14 +-------------
 mm/memory.c                   | 45 +++++++++++--------------------------------
 mm/page_io.c                  |  6 +++---
 mm/swapfile.c                 | 12 ++----------
 9 files changed, 18 insertions(+), 76 deletions(-)

diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 8028a3a7e7fd..3d8e29ad0159 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -20,7 +20,6 @@
 #include <linux/radix-tree.h>
 #include <linux/fs.h>
 #include <linux/slab.h>
-#include <linux/backing-dev.h>
 
 #include <linux/uaccess.h>
 
@@ -401,7 +400,6 @@ static struct brd_device *brd_alloc(int i)
 	disk->flags		= GENHD_FL_EXT_DEVT;
 	sprintf(disk->disk_name, "ram%d", i);
 	set_capacity(disk, rd_size * 2);
-	disk->queue->backing_dev_info->capabilities |= BDI_CAP_SYNCHRONOUS_IO;
 
 	return brd;
 
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index d70eba30003a..36117f649e53 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -1558,7 +1558,7 @@ static int zram_add(void)
 		blk_queue_max_write_zeroes_sectors(zram->disk->queue, UINT_MAX);
 
 	zram->disk->queue->backing_dev_info->capabilities |=
-			(BDI_CAP_STABLE_WRITES | BDI_CAP_SYNCHRONOUS_IO);
+					BDI_CAP_STABLE_WRITES;
 	add_disk(zram->disk);
 
 	ret = sysfs_create_group(&disk_to_dev(zram->disk)->kobj,
diff --git a/drivers/nvdimm/btt.c b/drivers/nvdimm/btt.c
index e949e3302af4..d5612bd1cc81 100644
--- a/drivers/nvdimm/btt.c
+++ b/drivers/nvdimm/btt.c
@@ -23,7 +23,6 @@
 #include <linux/ndctl.h>
 #include <linux/fs.h>
 #include <linux/nd.h>
-#include <linux/backing-dev.h>
 #include "btt.h"
 #include "nd.h"
 
@@ -1403,8 +1402,6 @@ static int btt_blk_init(struct btt *btt)
 	btt->btt_disk->private_data = btt;
 	btt->btt_disk->queue = btt->btt_queue;
 	btt->btt_disk->flags = GENHD_FL_EXT_DEVT;
-	btt->btt_disk->queue->backing_dev_info->capabilities |=
-			BDI_CAP_SYNCHRONOUS_IO;
 
 	blk_queue_make_request(btt->btt_queue, btt_make_request);
 	blk_queue_logical_block_size(btt->btt_queue, btt->sector_size);
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 7fbc5c5dc8e1..39dfd7affa31 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -31,7 +31,6 @@
 #include <linux/uio.h>
 #include <linux/dax.h>
 #include <linux/nd.h>
-#include <linux/backing-dev.h>
 #include "pmem.h"
 #include "pfn.h"
 #include "nd.h"
@@ -395,7 +394,6 @@ static int pmem_attach_disk(struct device *dev,
 	disk->fops		= &pmem_fops;
 	disk->queue		= q;
 	disk->flags		= GENHD_FL_EXT_DEVT;
-	disk->queue->backing_dev_info->capabilities |= BDI_CAP_SYNCHRONOUS_IO;
 	nvdimm_namespace_disk_name(ndns, disk->disk_name);
 	set_capacity(disk, (pmem->size - pmem->pfn_pad - pmem->data_offset)
 			/ 512);
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 2c99c5cd5074..0368a6c87e11 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -122,8 +122,6 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
  * BDI_CAP_STRICTLIMIT:    Keep number of dirty pages below bdi threshold.
  *
  * BDI_CAP_CGROUP_WRITEBACK: Supports cgroup-aware writeback.
- * BDI_CAP_SYNCHRONOUS_IO: Device is so fast that asynchronous IO would be
- *			   inefficient.
  */
 #define BDI_CAP_NO_ACCT_DIRTY	0x00000001
 #define BDI_CAP_NO_WRITEBACK	0x00000002
@@ -131,7 +129,6 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
 #define BDI_CAP_STABLE_WRITES	0x00000008
 #define BDI_CAP_STRICTLIMIT	0x00000010
 #define BDI_CAP_CGROUP_WRITEBACK 0x00000020
-#define BDI_CAP_SYNCHRONOUS_IO	0x00000040
 
 #define BDI_CAP_NO_ACCT_AND_WRITEBACK \
 	(BDI_CAP_NO_WRITEBACK | BDI_CAP_NO_ACCT_DIRTY | BDI_CAP_NO_ACCT_WB)
@@ -177,11 +174,6 @@ static inline int wb_congested(struct bdi_writeback *wb, int cong_bits)
 long congestion_wait(int sync, long timeout);
 long wait_iff_congested(struct pglist_data *pgdat, int sync, long timeout);
 
-static inline bool bdi_cap_synchronous_io(struct backing_dev_info *bdi)
-{
-	return bdi->capabilities & BDI_CAP_SYNCHRONOUS_IO;
-}
-
 static inline bool bdi_cap_stable_pages_required(struct backing_dev_info *bdi)
 {
 	return bdi->capabilities & BDI_CAP_STABLE_WRITES;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 2417d288e016..760979f607f4 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -171,9 +171,8 @@ enum {
 	SWP_AREA_DISCARD = (1 << 8),	/* single-time swap area discards */
 	SWP_PAGE_DISCARD = (1 << 9),	/* freed swap page-cluster discards */
 	SWP_STABLE_WRITES = (1 << 10),	/* no overwrite PG_writeback pages */
-	SWP_SYNCHRONOUS_IO = (1 << 11),	/* synchronous IO is efficient */
 					/* add others here before... */
-	SWP_SCANNING	= (1 << 12),	/* refcount in scan_swap_map */
+	SWP_SCANNING	= (1 << 11),	/* refcount in scan_swap_map */
 };
 
 #define SWAP_CLUSTER_MAX 32UL
@@ -460,7 +459,6 @@ extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
 extern int page_swapcount(struct page *);
-extern int __swap_count(struct swap_info_struct *si, swp_entry_t entry);
 extern int __swp_swapcount(swp_entry_t entry);
 extern int swp_swapcount(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
@@ -473,11 +471,6 @@ extern void exit_swap_address_space(unsigned int type);
 
 #else /* CONFIG_SWAP */
 
-static inline int swap_readpage(struct page *page, bool do_poll)
-{
-	return 0;
-}
-
 static inline struct swap_info_struct *swp_swap_info(swp_entry_t entry)
 {
 	return NULL;
@@ -575,11 +568,6 @@ static inline int page_swapcount(struct page *page)
 	return 0;
 }
 
-static inline int __swap_count(struct swap_info_struct *si, swp_entry_t entry)
-{
-	return 0;
-}
-
 static inline int __swp_swapcount(swp_entry_t entry)
 {
 	return 0;
diff --git a/mm/memory.c b/mm/memory.c
index 36dd3a66aa5a..e4cf8ab41eac 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2869,7 +2869,7 @@ EXPORT_SYMBOL(unmap_mapping_range);
 int do_swap_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	struct page *page = NULL, *swapcache = NULL;
+	struct page *page = NULL, *swapcache;
 	struct mem_cgroup *memcg;
 	swp_entry_t entry;
 	pte_t pte;
@@ -2901,31 +2901,10 @@ int do_swap_page(struct vm_fault *vmf)
 		}
 		goto out;
 	}
-
-
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
 	page = lookup_swap_cache(entry, vma, vmf->address);
 	if (!page) {
-		struct swap_info_struct *si = swp_swap_info(entry);
-
-		if (si->flags & SWP_SYNCHRONOUS_IO &&
-				__swap_count(si, entry) == 1) {
-			/* skip swapcache */
-			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
-							vmf->address);
-			if (page) {
-				__SetPageLocked(page);
-				__SetPageSwapBacked(page);
-				set_page_private(page, entry.val);
-				lru_cache_add_anon(page);
-				swap_readpage(page, true);
-			}
-		} else {
-			page = swapin_readahead(entry, GFP_HIGHUSER_MOVABLE,
-						vmf);
-			swapcache = page;
-		}
-
+		page = swapin_readahead(entry, GFP_HIGHUSER_MOVABLE, vmf);
 		if (!page) {
 			/*
 			 * Back out if somebody else faulted in this pte
@@ -2954,6 +2933,7 @@ int do_swap_page(struct vm_fault *vmf)
 		goto out_release;
 	}
 
+	swapcache = page;
 	locked = lock_page_or_retry(page, vma->vm_mm, vmf->flags);
 
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
@@ -2968,8 +2948,7 @@ int do_swap_page(struct vm_fault *vmf)
 	 * test below, are not enough to exclude that.  Even if it is still
 	 * swapcache, we need to check that the page's swap has not changed.
 	 */
-	if (unlikely((!PageSwapCache(page) ||
-			page_private(page) != entry.val)) && swapcache)
+	if (unlikely(!PageSwapCache(page) || page_private(page) != entry.val))
 		goto out_page;
 
 	page = ksm_might_need_to_copy(page, vma, vmf->address);
@@ -3022,16 +3001,14 @@ int do_swap_page(struct vm_fault *vmf)
 		pte = pte_mksoft_dirty(pte);
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
 	vmf->orig_pte = pte;
-
-	/* ksm created a completely new copy */
-	if (unlikely(page != swapcache && swapcache)) {
-		page_add_new_anon_rmap(page, vma, vmf->address, false);
-		mem_cgroup_commit_charge(page, memcg, false, false);
-		lru_cache_add_active_or_unevictable(page, vma);
-	} else {
+	if (page == swapcache) {
 		do_page_add_anon_rmap(page, vma, vmf->address, exclusive);
 		mem_cgroup_commit_charge(page, memcg, true, false);
 		activate_page(page);
+	} else { /* ksm created a completely new copy */
+		page_add_new_anon_rmap(page, vma, vmf->address, false);
+		mem_cgroup_commit_charge(page, memcg, false, false);
+		lru_cache_add_active_or_unevictable(page, vma);
 	}
 
 	swap_free(entry);
@@ -3039,7 +3016,7 @@ int do_swap_page(struct vm_fault *vmf)
 	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
 		try_to_free_swap(page);
 	unlock_page(page);
-	if (page != swapcache && swapcache) {
+	if (page != swapcache) {
 		/*
 		 * Hold the lock to avoid the swap entry to be reused
 		 * until we take the PT lock for the pte_same() check
@@ -3072,7 +3049,7 @@ int do_swap_page(struct vm_fault *vmf)
 	unlock_page(page);
 out_release:
 	put_page(page);
-	if (page != swapcache && swapcache) {
+	if (page != swapcache) {
 		unlock_page(swapcache);
 		put_page(swapcache);
 	}
diff --git a/mm/page_io.c b/mm/page_io.c
index e93f1a4cacd7..cd52b9cc169b 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -347,7 +347,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 	return ret;
 }
 
-int swap_readpage(struct page *page, bool synchronous)
+int swap_readpage(struct page *page, bool do_poll)
 {
 	struct bio *bio;
 	int ret = 0;
@@ -355,7 +355,7 @@ int swap_readpage(struct page *page, bool synchronous)
 	blk_qc_t qc;
 	struct gendisk *disk;
 
-	VM_BUG_ON_PAGE(!PageSwapCache(page) && !synchronous, page);
+	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageUptodate(page), page);
 	if (frontswap_load(page) == 0) {
@@ -403,7 +403,7 @@ int swap_readpage(struct page *page, bool synchronous)
 	count_vm_event(PSWPIN);
 	bio_get(bio);
 	qc = submit_bio(bio);
-	while (synchronous) {
+	while (do_poll) {
 		set_current_state(TASK_UNINTERRUPTIBLE);
 		if (!READ_ONCE(bio->bi_private))
 			break;
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 42fe5653814a..fb065cfca8bf 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1328,13 +1328,6 @@ int page_swapcount(struct page *page)
 	return count;
 }
 
-int __swap_count(struct swap_info_struct *si, swp_entry_t entry)
-{
-	pgoff_t offset = swp_offset(entry);
-
-	return swap_count(si->swap_map[offset]);
-}
-
 static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
 {
 	int count = 0;
@@ -3176,9 +3169,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (bdi_cap_stable_pages_required(inode_to_bdi(inode)))
 		p->flags |= SWP_STABLE_WRITES;
 
-	if (bdi_cap_synchronous_io(inode_to_bdi(inode)))
-		p->flags |= SWP_SYNCHRONOUS_IO;
-
 	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
 		int cpu;
 		unsigned long ci, nr_cluster;
@@ -3478,6 +3468,7 @@ struct swap_info_struct *page_swap_info(struct page *page)
  */
 struct address_space *__page_file_mapping(struct page *page)
 {
+	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
 	return page_swap_info(page)->swap_file->f_mapping;
 }
 EXPORT_SYMBOL_GPL(__page_file_mapping);
@@ -3485,6 +3476,7 @@ EXPORT_SYMBOL_GPL(__page_file_mapping);
 pgoff_t __page_file_index(struct page *page)
 {
 	swp_entry_t swap = { .val = page_private(page) };
+	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
 	return swp_offset(swap);
 }
 EXPORT_SYMBOL_GPL(__page_file_index);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
