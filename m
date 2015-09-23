Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C61026B025E
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:48:03 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so29385129pad.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 21:48:03 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id rq8si734458pbc.226.2015.09.22.21.48.02
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 21:48:03 -0700 (PDT)
Subject: [PATCH 10/15] block, dax: fix lifetime of in-kernel dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Sep 2015 00:42:06 -0400
Message-ID: <20150923044206.36490.79829.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jens Axboe <axboe@kernel.dk>, Boaz Harrosh <boaz@plexistor.com>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

The DAX implementation needs to protect new calls to ->direct_access()
and usage of its return value against unbind of the underlying block
device.  Use blk_dax_{get|put}() to either prevent blk_cleanup_queue()
from proceeding, or fail the dax_map_bh() if the request_queue is being
torn down.

Cc: Jens Axboe <axboe@kernel.dk>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Boaz Harrosh <boaz@plexistor.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c |  131 ++++++++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 84 insertions(+), 47 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index bcfb14bfc1e4..358eea39e982 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -63,12 +63,43 @@ int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 }
 EXPORT_SYMBOL_GPL(dax_clear_blocks);
 
-static long dax_get_addr(struct buffer_head *bh, void __pmem **addr,
-		unsigned blkbits)
+static void __pmem *__dax_map_bh(const struct buffer_head *bh, unsigned blkbits,
+		unsigned long *pfn, long *len)
 {
-	unsigned long pfn;
+	long rc;
+	void __pmem *addr;
+	struct block_device *bdev = bh->b_bdev;
+	struct request_queue *q = bdev->bd_queue;
 	sector_t sector = bh->b_blocknr << (blkbits - 9);
-	return bdev_direct_access(bh->b_bdev, sector, addr, &pfn, bh->b_size);
+
+	rc = blk_dax_get(q);
+	if (rc < 0)
+		return (void __pmem *) ERR_PTR(rc);
+	rc = bdev_direct_access(bdev, sector, &addr, pfn, bh->b_size);
+	if (len)
+		*len = rc;
+	if (rc < 0) {
+		blk_dax_put(q);
+		return (void __pmem *) ERR_PTR(rc);
+	}
+	return addr;
+}
+
+static void __pmem *dax_map_bh(const struct buffer_head *bh, unsigned blkbits)
+{
+	unsigned long pfn;
+
+	return __dax_map_bh(bh, blkbits, &pfn, NULL);
+}
+
+static void dax_unmap_bh(const struct buffer_head *bh, void __pmem *addr)
+{
+	struct block_device *bdev = bh->b_bdev;
+	struct request_queue *q = bdev->bd_queue;
+
+	if (IS_ERR(addr))
+		return;
+	blk_dax_put(q);
 }
 
 /* the clear_pmem() calls are ordered by a wmb_pmem() in the caller */
@@ -104,15 +135,16 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 		      loff_t start, loff_t end, get_block_t get_block,
 		      struct buffer_head *bh)
 {
-	ssize_t retval = 0;
-	loff_t pos = start;
-	loff_t max = start;
-	loff_t bh_max = start;
-	void __pmem *addr;
+	loff_t pos = start, max = start, bh_max = start;
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
@@ -127,9 +159,8 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
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
@@ -141,21 +172,25 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
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
+				dax_unmap_bh(bh, kmap);
+				kmap = __dax_map_bh(bh, blkbits, &pfn, &map_len);
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
@@ -178,8 +213,9 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 
 	if (need_wmb)
 		wmb_pmem();
+	dax_unmap_bh(bh, kmap);
 
-	return (pos == start) ? retval : pos - start;
+	return (pos == start) ? rc : pos - start;
 }
 
 /**
@@ -274,21 +310,22 @@ static int copy_user_bh(struct page *to, struct buffer_head *bh,
 	void __pmem *vfrom;
 	void *vto;
 
-	if (dax_get_addr(bh, &vfrom, blkbits) < 0)
-		return -EIO;
+	vfrom = dax_map_bh(bh, blkbits);
+	if (IS_ERR(vfrom))
+		return PTR_ERR(vfrom);
 	vto = kmap_atomic(to);
 	copy_user_page(vto, (void __force *)vfrom, vaddr, to);
 	kunmap_atomic(vto);
+	dax_unmap_bh(bh, vfrom);
 	return 0;
 }
 
 static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 			struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	sector_t sector = bh->b_blocknr << (inode->i_blkbits - 9);
 	unsigned long vaddr = (unsigned long)vmf->virtual_address;
-	void __pmem *addr;
 	unsigned long pfn;
+	void __pmem *addr;
 	pgoff_t size;
 	int error;
 
@@ -305,11 +342,9 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 		goto out;
 	}
 
-	error = bdev_direct_access(bh->b_bdev, sector, &addr, &pfn, bh->b_size);
-	if (error < 0)
-		goto out;
-	if (error < PAGE_SIZE) {
-		error = -EIO;
+	addr = __dax_map_bh(bh, inode->i_blkbits, &pfn, NULL);
+	if (IS_ERR(addr)) {
+		error = PTR_ERR(addr);
 		goto out;
 	}
 
@@ -317,6 +352,7 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 		clear_pmem(addr, PAGE_SIZE);
 		wmb_pmem();
 	}
+	dax_unmap_bh(bh, addr);
 
 	error = vm_insert_mixed(vma, vaddr, pfn);
 
@@ -528,11 +564,8 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	unsigned blkbits = inode->i_blkbits;
 	unsigned long pmd_addr = address & PMD_MASK;
 	bool write = flags & FAULT_FLAG_WRITE;
-	long length;
-	void __pmem *kaddr;
 	pgoff_t size, pgoff;
-	sector_t block, sector;
-	unsigned long pfn;
+	sector_t block;
 	int result = 0;
 
 	/* Fall back to PTEs if we're going to COW */
@@ -557,8 +590,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 
 	bh.b_size = PMD_SIZE;
 	i_mmap_lock_write(mapping);
-	length = get_block(inode, block, &bh, write);
-	if (length)
+	if (get_block(inode, block, &bh, write) != 0)
 		return VM_FAULT_SIGBUS;
 
 	/*
@@ -569,17 +601,17 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
 		goto fallback;
 
-	sector = bh.b_blocknr << (blkbits - 9);
-
 	if (buffer_unwritten(&bh) || buffer_new(&bh)) {
 		int i;
+		long length;
+		unsigned long pfn;
+		void __pmem *kaddr = __dax_map_bh(&bh, blkbits, &pfn, &length);
 
-		length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
-						bh.b_size);
-		if (length < 0) {
+		if (IS_ERR(kaddr)) {
 			result = VM_FAULT_SIGBUS;
 			goto out;
 		}
+
 		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
 			goto fallback;
 
@@ -589,6 +621,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		count_vm_event(PGMAJFAULT);
 		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
 		result |= VM_FAULT_MAJOR;
+		dax_unmap_bh(&bh, kaddr);
 	}
 
 	/*
@@ -635,12 +668,15 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		result = VM_FAULT_NOPAGE;
 		spin_unlock(ptl);
 	} else {
-		length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
-						bh.b_size);
-		if (length < 0) {
+		long length;
+		unsigned long pfn;
+		void __pmem *kaddr = __dax_map_bh(&bh, blkbits, &pfn, &length);
+
+		if (IS_ERR(kaddr)) {
 			result = VM_FAULT_SIGBUS;
 			goto out;
 		}
+		dax_unmap_bh(&bh, kaddr);
 		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
 			goto fallback;
 
@@ -746,12 +782,13 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 	if (err < 0)
 		return err;
 	if (buffer_written(&bh)) {
-		void __pmem *addr;
-		err = dax_get_addr(&bh, &addr, inode->i_blkbits);
-		if (err < 0)
-			return err;
+		void __pmem *addr = dax_map_bh(&bh, inode->i_blkbits);
+
+		if (IS_ERR(addr))
+			return PTR_ERR(addr);
 		clear_pmem(addr + offset, length);
 		wmb_pmem();
+		dax_unmap_bh(&bh, addr);
 	}
 
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
