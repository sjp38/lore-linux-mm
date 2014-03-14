Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B0A876B003D
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 19:10:52 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so3218242pab.8
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 16:10:52 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id ub8si4791829pac.461.2014.03.14.16.10.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 16:10:51 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH] Support map_pages() for DAX
Date: Fri, 14 Mar 2014 17:03:19 -0600
Message-Id: <1394838199-29102-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Toshi Kani <toshi.kani@hp.com>

DAX provides direct access to NVDIMM and bypasses the page caches.
Newly introduced map_pages() callback reduces page faults by adding
mappings around a faulted page, which is not supported for DAX.

This patch implements map_pages() callback for DAX.  It reduces a
number of page faults and increases read performance of DAX as shown
below.  The values in parenthesis are relative to the base DAX results.

iozone results of mmap read/re-read tests [KB/sec]
 64KB:  read: 3,560,777 (x1.6) re-read: 9,086,412 (x1.8) pfault:   121 (-20%)
 128MB: read: 4,374,906 (x1.7) re-read: 6,137,189 (x2.4) pfault: 8,312 (-87%)

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
----
Applies on top of DAX patchset [1] and fault-around patchset [2].

[1] https://lkml.org/lkml/2014/2/25/460
[2] https://lkml.org/lkml/2014/2/27/546
---
 fs/dax.c           |   68 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/ext4/file.c     |    6 +++++
 include/linux/fs.h |    5 ++++
 3 files changed, 79 insertions(+)

diff --git a/fs/dax.c b/fs/dax.c
index c8dfab0..bc54705 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -476,3 +476,71 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 	return 0;
 }
 EXPORT_SYMBOL_GPL(dax_zero_page_range);
+
+static void dax_set_pte(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn, pte_t *pte)
+{
+	pte_t entry;
+
+	if (addr < vma->vm_start || addr >= vma->vm_end)
+		return;
+
+	if (!pte_none(*pte))
+		return;
+
+	entry = pte_mkspecial(pfn_pte(pfn, vma->vm_page_prot));
+	set_pte_at(vma->vm_mm, addr, pte, entry);
+	update_mmu_cache(vma, addr, pte);
+}
+
+void dax_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf,
+		get_block_t get_block)
+{
+	struct file *file = vma->vm_file;
+	struct inode *inode = file_inode(file);
+	struct buffer_head bh;
+	struct address_space *mapping = file->f_mapping;
+	unsigned long vaddr = (unsigned long)vmf->virtual_address;
+	pgoff_t pgoff = vmf->pgoff;
+	sector_t block;
+	pgoff_t size;
+	unsigned long pfn;
+	pte_t *pte = vmf->pte;
+	int error;
+
+	while (pgoff < vmf->max_pgoff) {
+		size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+		if (pgoff >= size)
+			return;
+
+		memset(&bh, 0, sizeof(bh));
+		block = (sector_t)pgoff << (PAGE_SHIFT - inode->i_blkbits);
+		bh.b_size = PAGE_SIZE;
+		error = get_block(inode, block, &bh, 0);
+		if (error || bh.b_size < PAGE_SIZE)
+			goto next;
+
+		if (!buffer_mapped(&bh) || buffer_unwritten(&bh) ||
+		    buffer_new(&bh))
+			goto next;
+
+		/* Recheck i_size under i_mmap_mutex */
+		mutex_lock(&mapping->i_mmap_mutex);
+		size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+		if (unlikely(pgoff >= size)) {
+			mutex_unlock(&mapping->i_mmap_mutex);
+			return;
+		}
+
+		error = dax_get_pfn(inode, &bh, &pfn);
+		if (error > 0)
+			dax_set_pte(vma, vaddr, pfn, pte);
+
+		mutex_unlock(&mapping->i_mmap_mutex);
+next:
+		vaddr += PAGE_SIZE;
+		pgoff++;
+		pte++;
+	}
+}
+EXPORT_SYMBOL_GPL(dax_map_pages);
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index eb19383..15965ea 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -205,6 +205,11 @@ static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 					/* Is this the right get_block? */
 }
 
+static void ext4_dax_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	return dax_map_pages(vma, vmf, ext4_get_block);
+}
+
 static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	return dax_mkwrite(vma, vmf, ext4_get_block);
@@ -212,6 +217,7 @@ static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 static const struct vm_operations_struct ext4_dax_vm_ops = {
 	.fault		= ext4_dax_fault,
+	.map_pages	= ext4_dax_map_pages,
 	.page_mkwrite	= ext4_dax_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/include/linux/fs.h b/include/linux/fs.h
index d0381ab..3bd1042 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2527,6 +2527,7 @@ ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, const struct iovec *,
 		loff_t, unsigned segs, get_block_t, dio_iodone_t, int flags);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
 int dax_mkwrite(struct vm_area_struct *, struct vm_fault *, get_block_t);
+void dax_map_pages(struct vm_area_struct *, struct vm_fault *, get_block_t);
 #else
 static inline int dax_clear_blocks(struct inode *i, sector_t blk, long sz)
 {
@@ -2545,6 +2546,10 @@ static inline ssize_t dax_do_io(int rw, struct kiocb *iocb, struct inode *inode,
 {
 	return -ENOTTY;
 }
+static inline void dax_map_pages(struct vm_area_struct *vma,
+		struct vm_fault *vmf, get_block_t get_block)
+{
+}
 #endif
 
 /* Can't be a function because PAGE_CACHE_SIZE is defined in pagemap.h */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
