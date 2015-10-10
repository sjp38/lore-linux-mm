Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C5DE86B0256
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:01:22 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so100482863pad.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:01:22 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id wf3si6420263pab.166.2015.10.09.18.01.21
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:01:22 -0700 (PDT)
Subject: [PATCH v2 03/20] block,
 dax: fix lifetime of in-kernel dax mappings with dax_map_atomic()
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:55:39 -0400
Message-ID: <20151010005539.17221.87794.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jens Axboe <axboe@kernel.dk>, Boaz Harrosh <boaz@plexistor.com>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ross.zwisler@linux.intel.com, hch@lst.de

The DAX implementation needs to protect new calls to ->direct_access()
and usage of its return value against unbind of the underlying block
device.  Use blk_queue_enter()/blk_queue_exit() to either prevent
blk_cleanup_queue() from proceeding, or fail the dax_map_atomic() if the
request_queue is being torn down.

Cc: Jens Axboe <axboe@kernel.dk>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Boaz Harrosh <boaz@plexistor.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 block/blk.h            |    2 -
 fs/dax.c               |  165 ++++++++++++++++++++++++++++++++----------------
 include/linux/blkdev.h |    2 +
 3 files changed, 112 insertions(+), 57 deletions(-)

diff --git a/block/blk.h b/block/blk.h
index 5b2cd393afbe..0f8de0dda768 100644
--- a/block/blk.h
+++ b/block/blk.h
@@ -72,8 +72,6 @@ void blk_dequeue_request(struct request *rq);
 void __blk_queue_free_tags(struct request_queue *q);
 bool __blk_end_bidi_request(struct request *rq, int error,
 			    unsigned int nr_bytes, unsigned int bidi_bytes);
-int blk_queue_enter(struct request_queue *q, gfp_t gfp);
-void blk_queue_exit(struct request_queue *q);
 void blk_freeze_queue(struct request_queue *q);
 
 static inline void blk_queue_enter_live(struct request_queue *q)
diff --git a/fs/dax.c b/fs/dax.c
index 7031b0312596..9549cd523649 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -30,6 +30,40 @@
 #include <linux/vmstat.h>
 #include <linux/sizes.h>
 
+static void __pmem *__dax_map_atomic(struct block_device *bdev, sector_t sector,
+		long size, unsigned long *pfn, long *len)
+{
+	long rc;
+	void __pmem *addr;
+	struct request_queue *q = bdev->bd_queue;
+
+	if (blk_queue_enter(q, GFP_NOWAIT) != 0)
+		return (void __pmem *) ERR_PTR(-EIO);
+	rc = bdev_direct_access(bdev, sector, &addr, pfn, size);
+	if (len)
+		*len = rc;
+	if (rc < 0) {
+		blk_queue_exit(q);
+		return (void __pmem *) ERR_PTR(rc);
+	}
+	return addr;
+}
+
+static void __pmem *dax_map_atomic(struct block_device *bdev, sector_t sector,
+		long size)
+{
+	unsigned long pfn;
+
+	return __dax_map_atomic(bdev, sector, size, &pfn, NULL);
+}
+
+static void dax_unmap_atomic(struct block_device *bdev, void __pmem *addr)
+{
+	if (IS_ERR(addr))
+		return;
+	blk_queue_exit(bdev->bd_queue);
+}
+
 /*
  * dax_clear_blocks() is called from within transaction context from XFS,
  * and hence this means the stack from this point must follow GFP_NOFS
@@ -47,9 +81,9 @@ int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 		long count, sz;
 
 		sz = min_t(long, size, SZ_1M);
-		count = bdev_direct_access(bdev, sector, &addr, &pfn, sz);
-		if (count < 0)
-			return count;
+		addr = __dax_map_atomic(bdev, sector, size, &pfn, &count);
+		if (IS_ERR(addr))
+			return PTR_ERR(addr);
 		if (count < sz)
 			sz = count;
 		clear_pmem(addr, sz);
@@ -57,6 +91,7 @@ int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 		size -= sz;
 		BUG_ON(sz & 511);
 		sector += sz / 512;
+		dax_unmap_atomic(bdev, addr);
 		cond_resched();
 	} while (size);
 
@@ -65,14 +100,6 @@ int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 }
 EXPORT_SYMBOL_GPL(dax_clear_blocks);
 
-static long dax_get_addr(struct buffer_head *bh, void __pmem **addr,
-		unsigned blkbits)
-{
-	unsigned long pfn;
-	sector_t sector = bh->b_blocknr << (blkbits - 9);
-	return bdev_direct_access(bh->b_bdev, sector, addr, &pfn, bh->b_size);
-}
-
 /* the clear_pmem() calls are ordered by a wmb_pmem() in the caller */
 static void dax_new_buf(void __pmem *addr, unsigned size, unsigned first,
 		loff_t pos, loff_t end)
@@ -102,19 +129,30 @@ static bool buffer_size_valid(struct buffer_head *bh)
 	return bh->b_state != 0;
 }
 
+
+static sector_t to_sector(const struct buffer_head *bh,
+		const struct inode *inode)
+{
+	sector_t sector = bh->b_blocknr << (inode->i_blkbits - 9);
+
+	return sector;
+}
+
 static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 		      loff_t start, loff_t end, get_block_t get_block,
 		      struct buffer_head *bh)
 {
-	ssize_t retval = 0;
-	loff_t pos = start;
-	loff_t max = start;
-	loff_t bh_max = start;
-	void __pmem *addr;
+	loff_t pos = start, max = start, bh_max = start;
+	struct block_device *bdev = NULL;
+	int rw = iov_iter_rw(iter), rc;
+	long map_len = 0;
+	unsigned long pfn;
+	void __pmem *addr = NULL;
+	void __pmem *kmap = (void __pmem *) ERR_PTR(-EIO);
 	bool hole = false;
 	bool need_wmb = false;
 
-	if (iov_iter_rw(iter) != WRITE)
+	if (rw == READ)
 		end = min(end, i_size_read(inode));
 
 	while (pos < end) {
@@ -129,13 +167,13 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 			if (pos == bh_max) {
 				bh->b_size = PAGE_ALIGN(end - pos);
 				bh->b_state = 0;
-				retval = get_block(inode, block, bh,
-						   iov_iter_rw(iter) == WRITE);
-				if (retval)
+				rc = get_block(inode, block, bh, rw == WRITE);
+				if (rc)
 					break;
 				if (!buffer_size_valid(bh))
 					bh->b_size = 1 << blkbits;
 				bh_max = pos - first + bh->b_size;
+				bdev = bh->b_bdev;
 			} else {
 				unsigned done = bh->b_size -
 						(bh_max - (pos - first));
@@ -143,21 +181,27 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 				bh->b_size -= done;
 			}
 
-			hole = iov_iter_rw(iter) != WRITE && !buffer_written(bh);
+			hole = rw == READ && !buffer_written(bh);
 			if (hole) {
 				addr = NULL;
 				size = bh->b_size - first;
 			} else {
-				retval = dax_get_addr(bh, &addr, blkbits);
-				if (retval < 0)
+				dax_unmap_atomic(bdev, kmap);
+				kmap = __dax_map_atomic(bdev,
+						to_sector(bh, inode),
+						bh->b_size, &pfn, &map_len);
+				if (IS_ERR(kmap)) {
+					rc = PTR_ERR(kmap);
 					break;
+				}
+				addr = kmap;
 				if (buffer_unwritten(bh) || buffer_new(bh)) {
-					dax_new_buf(addr, retval, first, pos,
-									end);
+					dax_new_buf(addr, map_len, first, pos,
+							end);
 					need_wmb = true;
 				}
 				addr += first;
-				size = retval - first;
+				size = map_len - first;
 			}
 			max = min(pos + size, end);
 		}
@@ -180,8 +224,9 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 
 	if (need_wmb)
 		wmb_pmem();
+	dax_unmap_atomic(bdev, kmap);
 
-	return (pos == start) ? retval : pos - start;
+	return (pos == start) ? rc : pos - start;
 }
 
 /**
@@ -270,28 +315,31 @@ static int dax_load_hole(struct address_space *mapping, struct page *page,
 	return VM_FAULT_LOCKED;
 }
 
-static int copy_user_bh(struct page *to, struct buffer_head *bh,
-			unsigned blkbits, unsigned long vaddr)
+static int copy_user_bh(struct page *to, struct inode *inode,
+		struct buffer_head *bh, unsigned long vaddr)
 {
+	struct block_device *bdev = bh->b_bdev;
 	void __pmem *vfrom;
 	void *vto;
 
-	if (dax_get_addr(bh, &vfrom, blkbits) < 0)
-		return -EIO;
+	vfrom = dax_map_atomic(bdev, to_sector(bh, inode), bh->b_size);
+	if (IS_ERR(vfrom))
+		return PTR_ERR(vfrom);
 	vto = kmap_atomic(to);
 	copy_user_page(vto, (void __force *)vfrom, vaddr, to);
 	kunmap_atomic(vto);
+	dax_unmap_atomic(bdev, vfrom);
 	return 0;
 }
 
 static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 			struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct address_space *mapping = inode->i_mapping;
-	sector_t sector = bh->b_blocknr << (inode->i_blkbits - 9);
 	unsigned long vaddr = (unsigned long)vmf->virtual_address;
-	void __pmem *addr;
+	struct address_space *mapping = inode->i_mapping;
+	struct block_device *bdev = bh->b_bdev;
 	unsigned long pfn;
+	void __pmem *addr;
 	pgoff_t size;
 	int error;
 
@@ -310,11 +358,10 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 		goto out;
 	}
 
-	error = bdev_direct_access(bh->b_bdev, sector, &addr, &pfn, bh->b_size);
-	if (error < 0)
-		goto out;
-	if (error < PAGE_SIZE) {
-		error = -EIO;
+	addr = __dax_map_atomic(bdev, to_sector(bh, inode), bh->b_size,
+			&pfn, NULL);
+	if (IS_ERR(addr)) {
+		error = PTR_ERR(addr);
 		goto out;
 	}
 
@@ -322,6 +369,7 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 		clear_pmem(addr, PAGE_SIZE);
 		wmb_pmem();
 	}
+	dax_unmap_atomic(bdev, addr);
 
 	error = vm_insert_mixed(vma, vaddr, pfn);
 
@@ -417,7 +465,7 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	if (vmf->cow_page) {
 		struct page *new_page = vmf->cow_page;
 		if (buffer_written(&bh))
-			error = copy_user_bh(new_page, &bh, blkbits, vaddr);
+			error = copy_user_bh(new_page, inode, &bh, vaddr);
 		else
 			clear_user_highpage(new_page, vaddr);
 		if (error)
@@ -529,11 +577,9 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	unsigned blkbits = inode->i_blkbits;
 	unsigned long pmd_addr = address & PMD_MASK;
 	bool write = flags & FAULT_FLAG_WRITE;
-	long length;
-	void __pmem *kaddr;
+	struct block_device *bdev;
 	pgoff_t size, pgoff;
-	sector_t block, sector;
-	unsigned long pfn;
+	sector_t block;
 	int result = 0;
 
 	/* Fall back to PTEs if we're going to COW */
@@ -557,9 +603,9 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
 
 	bh.b_size = PMD_SIZE;
-	length = get_block(inode, block, &bh, write);
-	if (length)
+	if (get_block(inode, block, &bh, write) != 0)
 		return VM_FAULT_SIGBUS;
+	bdev = bh.b_bdev;
 	i_mmap_lock_read(mapping);
 
 	/*
@@ -614,15 +660,20 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		result = VM_FAULT_NOPAGE;
 		spin_unlock(ptl);
 	} else {
-		sector = bh.b_blocknr << (blkbits - 9);
-		length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
-						bh.b_size);
-		if (length < 0) {
+		long length;
+		unsigned long pfn;
+		void __pmem *kaddr = __dax_map_atomic(bdev,
+				to_sector(&bh, inode), HPAGE_SIZE, &pfn,
+				&length);
+
+		if (IS_ERR(kaddr)) {
 			result = VM_FAULT_SIGBUS;
 			goto out;
 		}
-		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
+		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR)) {
+			dax_unmap_atomic(bdev, kaddr);
 			goto fallback;
+		}
 
 		if (buffer_unwritten(&bh) || buffer_new(&bh)) {
 			clear_pmem(kaddr, HPAGE_SIZE);
@@ -631,6 +682,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
 			result |= VM_FAULT_MAJOR;
 		}
+		dax_unmap_atomic(bdev, kaddr);
 
 		result |= vmf_insert_pfn_pmd(vma, address, pmd, pfn, write);
 	}
@@ -734,12 +786,15 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 	if (err < 0)
 		return err;
 	if (buffer_written(&bh)) {
-		void __pmem *addr;
-		err = dax_get_addr(&bh, &addr, inode->i_blkbits);
-		if (err < 0)
-			return err;
+		struct block_device *bdev = bh.b_bdev;
+		void __pmem *addr = dax_map_atomic(bdev, to_sector(&bh, inode),
+				PAGE_CACHE_SIZE);
+
+		if (IS_ERR(addr))
+			return PTR_ERR(addr);
 		clear_pmem(addr + offset, length);
 		wmb_pmem();
+		dax_unmap_atomic(bdev, addr);
 	}
 
 	return 0;
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index dd761b663e6a..cd091cb2b96e 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -788,6 +788,8 @@ extern int scsi_cmd_ioctl(struct request_queue *, struct gendisk *, fmode_t,
 extern int sg_scsi_ioctl(struct request_queue *, struct gendisk *, fmode_t,
 			 struct scsi_ioctl_command __user *);
 
+extern int blk_queue_enter(struct request_queue *q, gfp_t gfp);
+extern void blk_queue_exit(struct request_queue *q);
 extern void blk_start_queue(struct request_queue *q);
 extern void blk_stop_queue(struct request_queue *q);
 extern void blk_sync_queue(struct request_queue *q);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
