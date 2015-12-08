Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 11A7B6B027E
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 20:33:26 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so3030999pac.3
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 17:33:25 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id t72si1283148pfa.153.2015.12.07.17.33.24
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 17:33:25 -0800 (PST)
Subject: [PATCH -mm 04/25] dax: fix lifetime of in-kernel dax mappings with
 dax_map_atomic()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 07 Dec 2015 17:32:57 -0800
Message-ID: <20151208013257.25030.67713.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
References: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@fb.com>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

The DAX implementation needs to protect new calls to ->direct_access()
and usage of its return value against the driver for the underlying
block device being disabled.  Use blk_queue_enter()/blk_queue_exit() to
hold off blk_cleanup_queue() from proceeding, or otherwise fail new
mapping requests if the request_queue is being torn down.

This also introduces blk_dax_ctl to simplify the interface from fs/dax.c
through dax_map_atomic() to bdev_direct_access().

Cc: Jan Kara <jack@suse.com>
Cc: Jens Axboe <axboe@fb.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>
[willy: fix read() of a hole]
Reviewed-by: Jeff Moyer <jmoyer@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/block_dev.c         |   13 +--
 fs/dax.c               |  208 ++++++++++++++++++++++++++++++------------------
 include/linux/blkdev.h |   17 +++-
 3 files changed, 150 insertions(+), 88 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 653d14ccc86e..774851b1b201 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -450,10 +450,7 @@ EXPORT_SYMBOL_GPL(bdev_write_page);
 /**
  * bdev_direct_access() - Get the address for directly-accessibly memory
  * @bdev: The device containing the memory
- * @sector: The offset within the device
- * @addr: Where to put the address of the memory
- * @pfn: The Page Frame Number for the memory
- * @size: The number of bytes requested
+ * @dax: control and output parameters for ->direct_access
  *
  * If a block device is made up of directly addressable memory, this function
  * will tell the caller the PFN and the address of the memory.  The address
@@ -464,10 +461,10 @@ EXPORT_SYMBOL_GPL(bdev_write_page);
  * Return: negative errno if an error occurs, otherwise the number of bytes
  * accessible at this address.
  */
-long bdev_direct_access(struct block_device *bdev, sector_t sector,
-			void __pmem **addr, unsigned long *pfn, long size)
+long bdev_direct_access(struct block_device *bdev, struct blk_dax_ctl *dax)
 {
-	long avail;
+	sector_t sector = dax->sector;
+	long avail, size = dax->size;
 	const struct block_device_operations *ops = bdev->bd_disk->fops;
 
 	/*
@@ -486,7 +483,7 @@ long bdev_direct_access(struct block_device *bdev, sector_t sector,
 	sector += get_start_sect(bdev);
 	if (sector % (PAGE_SIZE / 512))
 		return -EINVAL;
-	avail = ops->direct_access(bdev, sector, addr, pfn);
+	avail = ops->direct_access(bdev, sector, &dax->addr, &dax->pfn);
 	if (!avail)
 		return -ERANGE;
 	if (avail > 0 && avail & ~PAGE_MASK)
diff --git a/fs/dax.c b/fs/dax.c
index 6e498c2570bf..68b04de71d19 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -30,45 +30,65 @@
 #include <linux/vmstat.h>
 #include <linux/sizes.h>
 
+static long dax_map_atomic(struct block_device *bdev, struct blk_dax_ctl *dax)
+{
+	struct request_queue *q = bdev->bd_queue;
+	long rc = -EIO;
+
+	dax->addr = (void __pmem *) ERR_PTR(-EIO);
+	if (blk_queue_enter(q, GFP_NOWAIT) != 0)
+		return rc;
+
+	rc = bdev_direct_access(bdev, dax);
+	if (rc < 0) {
+		dax->addr = (void __pmem *) ERR_PTR(rc);
+		blk_queue_exit(q);
+		return rc;
+	}
+	return rc;
+}
+
+static void dax_unmap_atomic(struct block_device *bdev,
+		const struct blk_dax_ctl *dax)
+{
+	if (IS_ERR(dax->addr))
+		return;
+	blk_queue_exit(bdev->bd_queue);
+}
+
 /*
  * dax_clear_blocks() is called from within transaction context from XFS,
  * and hence this means the stack from this point must follow GFP_NOFS
  * semantics for all operations.
  */
-int dax_clear_blocks(struct inode *inode, sector_t block, long size)
+int dax_clear_blocks(struct inode *inode, sector_t block, long _size)
 {
 	struct block_device *bdev = inode->i_sb->s_bdev;
-	sector_t sector = block << (inode->i_blkbits - 9);
+	struct blk_dax_ctl dax = {
+		.sector = block << (inode->i_blkbits - 9),
+		.size = _size,
+	};
 
 	might_sleep();
 	do {
-		void __pmem *addr;
-		unsigned long pfn;
 		long count, sz;
 
-		count = bdev_direct_access(bdev, sector, &addr, &pfn, size);
+		count = dax_map_atomic(bdev, &dax);
 		if (count < 0)
 			return count;
 		sz = min_t(long, count, SZ_1M);
-		clear_pmem(addr, sz);
-		size -= sz;
-		sector += sz / 512;
+		clear_pmem(dax.addr, sz);
+		dax.size -= sz;
+		dax.sector += sz / 512;
+		dax_unmap_atomic(bdev, &dax);
 		cond_resched();
-	} while (size);
+	} while (dax.size);
 
 	wmb_pmem();
 	return 0;
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
@@ -98,19 +118,29 @@ static bool buffer_size_valid(struct buffer_head *bh)
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
-	bool hole = false;
-	bool need_wmb = false;
-
-	if (iov_iter_rw(iter) != WRITE)
+	loff_t pos = start, max = start, bh_max = start;
+	bool hole = false, need_wmb = false;
+	struct block_device *bdev = NULL;
+	int rw = iov_iter_rw(iter), rc;
+	long map_len = 0;
+	struct blk_dax_ctl dax = {
+		.addr = (void __pmem *) ERR_PTR(-EIO),
+	};
+
+	if (rw == READ)
 		end = min(end, i_size_read(inode));
 
 	while (pos < end) {
@@ -125,13 +155,13 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
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
@@ -139,47 +169,53 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 				bh->b_size -= done;
 			}
 
-			hole = iov_iter_rw(iter) != WRITE && !buffer_written(bh);
+			hole = rw == READ && !buffer_written(bh);
 			if (hole) {
-				addr = NULL;
 				size = bh->b_size - first;
 			} else {
-				retval = dax_get_addr(bh, &addr, blkbits);
-				if (retval < 0)
+				dax_unmap_atomic(bdev, &dax);
+				dax.sector = to_sector(bh, inode);
+				dax.size = bh->b_size;
+				map_len = dax_map_atomic(bdev, &dax);
+				if (map_len < 0) {
+					rc = map_len;
 					break;
+				}
 				if (buffer_unwritten(bh) || buffer_new(bh)) {
-					dax_new_buf(addr, retval, first, pos,
-									end);
+					dax_new_buf(dax.addr, map_len, first,
+							pos, end);
 					need_wmb = true;
 				}
-				addr += first;
-				size = retval - first;
+				dax.addr += first;
+				size = map_len - first;
 			}
 			max = min(pos + size, end);
 		}
 
 		if (iov_iter_rw(iter) == WRITE) {
-			len = copy_from_iter_pmem(addr, max - pos, iter);
+			len = copy_from_iter_pmem(dax.addr, max - pos, iter);
 			need_wmb = true;
 		} else if (!hole)
-			len = copy_to_iter((void __force *)addr, max - pos,
+			len = copy_to_iter((void __force *) dax.addr, max - pos,
 					iter);
 		else
 			len = iov_iter_zero(max - pos, iter);
 
 		if (!len) {
-			retval = -EFAULT;
+			rc = -EFAULT;
 			break;
 		}
 
 		pos += len;
-		addr += len;
+		if (!IS_ERR(dax.addr))
+			dax.addr += len;
 	}
 
 	if (need_wmb)
 		wmb_pmem();
+	dax_unmap_atomic(bdev, &dax);
 
-	return (pos == start) ? retval : pos - start;
+	return (pos == start) ? rc : pos - start;
 }
 
 /**
@@ -268,28 +304,35 @@ static int dax_load_hole(struct address_space *mapping, struct page *page,
 	return VM_FAULT_LOCKED;
 }
 
-static int copy_user_bh(struct page *to, struct buffer_head *bh,
-			unsigned blkbits, unsigned long vaddr)
+static int copy_user_bh(struct page *to, struct inode *inode,
+		struct buffer_head *bh, unsigned long vaddr)
 {
-	void __pmem *vfrom;
+	struct blk_dax_ctl dax = {
+		.sector = to_sector(bh, inode),
+		.size = bh->b_size,
+	};
+	struct block_device *bdev = bh->b_bdev;
 	void *vto;
 
-	if (dax_get_addr(bh, &vfrom, blkbits) < 0)
-		return -EIO;
+	if (dax_map_atomic(bdev, &dax) < 0)
+		return PTR_ERR(dax.addr);
 	vto = kmap_atomic(to);
-	copy_user_page(vto, (void __force *)vfrom, vaddr, to);
+	copy_user_page(vto, (void __force *)dax.addr, vaddr, to);
 	kunmap_atomic(vto);
+	dax_unmap_atomic(bdev, &dax);
 	return 0;
 }
 
 static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 			struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct address_space *mapping = inode->i_mapping;
-	sector_t sector = bh->b_blocknr << (inode->i_blkbits - 9);
 	unsigned long vaddr = (unsigned long)vmf->virtual_address;
-	void __pmem *addr;
-	unsigned long pfn;
+	struct address_space *mapping = inode->i_mapping;
+	struct block_device *bdev = bh->b_bdev;
+	struct blk_dax_ctl dax = {
+		.sector = to_sector(bh, inode),
+		.size = bh->b_size,
+	};
 	pgoff_t size;
 	int error;
 
@@ -308,20 +351,18 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 		goto out;
 	}
 
-	error = bdev_direct_access(bh->b_bdev, sector, &addr, &pfn, bh->b_size);
-	if (error < 0)
-		goto out;
-	if (error < PAGE_SIZE) {
-		error = -EIO;
+	if (dax_map_atomic(bdev, &dax) < 0) {
+		error = PTR_ERR(dax.addr);
 		goto out;
 	}
 
 	if (buffer_unwritten(bh) || buffer_new(bh)) {
-		clear_pmem(addr, PAGE_SIZE);
+		clear_pmem(dax.addr, PAGE_SIZE);
 		wmb_pmem();
 	}
+	dax_unmap_atomic(bdev, &dax);
 
-	error = vm_insert_mixed(vma, vaddr, pfn);
+	error = vm_insert_mixed(vma, vaddr, dax.pfn);
 
  out:
 	i_mmap_unlock_read(mapping);
@@ -415,7 +456,7 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	if (vmf->cow_page) {
 		struct page *new_page = vmf->cow_page;
 		if (buffer_written(&bh))
-			error = copy_user_bh(new_page, &bh, blkbits, vaddr);
+			error = copy_user_bh(new_page, inode, &bh, vaddr);
 		else
 			clear_user_highpage(new_page, vaddr);
 		if (error)
@@ -527,11 +568,9 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
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
 
 	/* dax pmd mappings are broken wrt gup and fork */
@@ -559,9 +598,9 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
 
 	bh.b_size = PMD_SIZE;
-	length = get_block(inode, block, &bh, write);
-	if (length)
+	if (get_block(inode, block, &bh, write) != 0)
 		return VM_FAULT_SIGBUS;
+	bdev = bh.b_bdev;
 	i_mmap_lock_read(mapping);
 
 	/*
@@ -616,32 +655,40 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		result = VM_FAULT_NOPAGE;
 		spin_unlock(ptl);
 	} else {
-		sector = bh.b_blocknr << (blkbits - 9);
-		length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
-						bh.b_size);
+		struct blk_dax_ctl dax = {
+			.sector = to_sector(&bh, inode),
+			.size = PMD_SIZE,
+		};
+		long length = dax_map_atomic(bdev, &dax);
+
 		if (length < 0) {
 			result = VM_FAULT_SIGBUS;
 			goto out;
 		}
-		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
+		if ((length < PMD_SIZE) || (dax.pfn & PG_PMD_COLOUR)) {
+			dax_unmap_atomic(bdev, &dax);
 			goto fallback;
+		}
 
 		/*
 		 * TODO: teach vmf_insert_pfn_pmd() to support
 		 * 'pte_special' for pmds
 		 */
-		if (pfn_valid(pfn))
+		if (pfn_valid(dax.pfn)) {
+			dax_unmap_atomic(bdev, &dax);
 			goto fallback;
+		}
 
 		if (buffer_unwritten(&bh) || buffer_new(&bh)) {
-			clear_pmem(kaddr, PMD_SIZE);
+			clear_pmem(dax.addr, PMD_SIZE);
 			wmb_pmem();
 			count_vm_event(PGMAJFAULT);
 			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
 			result |= VM_FAULT_MAJOR;
 		}
+		dax_unmap_atomic(bdev, &dax);
 
-		result |= vmf_insert_pfn_pmd(vma, address, pmd, pfn, write);
+		result |= vmf_insert_pfn_pmd(vma, address, pmd, dax.pfn, write);
 	}
 
  out:
@@ -743,12 +790,17 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 	if (err < 0)
 		return err;
 	if (buffer_written(&bh)) {
-		void __pmem *addr;
-		err = dax_get_addr(&bh, &addr, inode->i_blkbits);
-		if (err < 0)
-			return err;
-		clear_pmem(addr + offset, length);
+		struct block_device *bdev = bh.b_bdev;
+		struct blk_dax_ctl dax = {
+			.sector = to_sector(&bh, inode),
+			.size = PAGE_CACHE_SIZE,
+		};
+
+		if (dax_map_atomic(bdev, &dax) < 0)
+			return PTR_ERR(dax.addr);
+		clear_pmem(dax.addr + offset, length);
 		wmb_pmem();
+		dax_unmap_atomic(bdev, &dax);
 	}
 
 	return 0;
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 12df3da13fb2..ae94b18999ab 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1617,6 +1617,20 @@ static inline bool integrity_req_gap_front_merge(struct request *req,
 
 #endif /* CONFIG_BLK_DEV_INTEGRITY */
 
+/**
+ * struct blk_dax_ctl - control and output parameters for ->direct_access
+ * @sector: (input) offset relative to a block_device
+ * @addr: (output) kernel virtual address for @sector populated by driver
+ * @pfn: (output) page frame number for @addr populated by driver
+ * @size: (input) number of bytes requested
+ */
+struct blk_dax_ctl {
+	sector_t sector;
+	void __pmem *addr;
+	long size;
+	unsigned long pfn;
+};
+
 struct block_device_operations {
 	int (*open) (struct block_device *, fmode_t);
 	void (*release) (struct gendisk *, fmode_t);
@@ -1643,8 +1657,7 @@ extern int __blkdev_driver_ioctl(struct block_device *, fmode_t, unsigned int,
 extern int bdev_read_page(struct block_device *, sector_t, struct page *);
 extern int bdev_write_page(struct block_device *, sector_t, struct page *,
 						struct writeback_control *);
-extern long bdev_direct_access(struct block_device *, sector_t,
-		void __pmem **addr, unsigned long *pfn, long size);
+extern long bdev_direct_access(struct block_device *, struct blk_dax_ctl *);
 #else /* CONFIG_BLOCK */
 
 struct block_device;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
