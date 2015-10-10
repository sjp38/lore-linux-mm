Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0104682F64
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:02:33 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so100503339pad.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:02:32 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id w5si6500797pbt.36.2015.10.09.18.02.31
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:02:32 -0700 (PDT)
Subject: [PATCH v2 13/20] mm, dax, pmem: introduce pfn_t
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:56:33 -0400
Message-ID: <20151010005633.17221.70857.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ross.zwisler@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, hch@lst.de

In preparation for enabling get_user_pages() operations on dax mappings,
introduce a type that encapsulates a page-frame-number that can also be
used to encode other information.  This other information is the
historical "page_link" encoding in a scatterlist, but can also denote
"device memory".  Where "device memory" is a set of pfns that are not
part of the kernel's linear mapping by default, but are accessed via the
same memory controller as ram.  The motivation for this new type is
large capacity persistent memory that optionally has struct page entries
in the 'memmap'.

When a driver, like pmem, has established a devm_memremap_pages()
mapping it needs to communicate to upper layers that the pfn has a page
backing.  This property will be leveraged in a later patch to enable
dax-gup.  For now, update all the ->direct_access() implementations to
communicate whether the returned pfn range is mapped.

Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/powerpc/sysdev/axonram.c |    8 ++---
 drivers/block/brd.c           |    4 +--
 drivers/nvdimm/pmem.c         |   25 ++++++----------
 drivers/s390/block/dcssblk.c  |   10 +++---
 fs/block_dev.c                |    2 +
 fs/dax.c                      |   19 ++++++------
 include/linux/blkdev.h        |    4 +--
 include/linux/mm.h            |   65 +++++++++++++++++++++++++++++++++++++++++
 include/linux/pfn.h           |    9 ++++++
 9 files changed, 105 insertions(+), 41 deletions(-)

diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index d2b79bc336c1..59ca4c0ab529 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -141,15 +141,13 @@ axon_ram_make_request(struct request_queue *queue, struct bio *bio)
  */
 static long
 axon_ram_direct_access(struct block_device *device, sector_t sector,
-		       void __pmem **kaddr, unsigned long *pfn)
+		       void __pmem **kaddr, pfn_t *pfn)
 {
 	struct axon_ram_bank *bank = device->bd_disk->private_data;
 	loff_t offset = (loff_t)sector << AXON_RAM_SECTOR_SHIFT;
-	void *addr = (void *)(bank->ph_addr + offset);
-
-	*kaddr = (void __pmem *)addr;
-	*pfn = virt_to_phys(addr) >> PAGE_SHIFT;
 
+	*kaddr = (void __pmem __force *) bank->io_addr + offset;
+	*pfn = phys_to_pfn_t(bank->ph_addr + offset, PFN_DEV);
 	return bank->size - offset;
 }
 
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index b9794aeeb878..0bbc60463779 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -374,7 +374,7 @@ static int brd_rw_page(struct block_device *bdev, sector_t sector,
 
 #ifdef CONFIG_BLK_DEV_RAM_DAX
 static long brd_direct_access(struct block_device *bdev, sector_t sector,
-			void __pmem **kaddr, unsigned long *pfn)
+			void __pmem **kaddr, pfn_t *pfn)
 {
 	struct brd_device *brd = bdev->bd_disk->private_data;
 	struct page *page;
@@ -385,7 +385,7 @@ static long brd_direct_access(struct block_device *bdev, sector_t sector,
 	if (!page)
 		return -ENOSPC;
 	*kaddr = (void __pmem *)page_address(page);
-	*pfn = page_to_pfn(page);
+	*pfn = page_to_pfn_t(page);
 
 	return PAGE_SIZE;
 }
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index bb66158c0505..c950602bbf0b 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -39,6 +39,7 @@ struct pmem_device {
 	phys_addr_t		phys_addr;
 	/* when non-zero this device is hosting a 'pfn' instance */
 	phys_addr_t		data_offset;
+	unsigned long		pfn_flags;
 	void __pmem		*virt_addr;
 	size_t			size;
 };
@@ -100,26 +101,15 @@ static int pmem_rw_page(struct block_device *bdev, sector_t sector,
 }
 
 static long pmem_direct_access(struct block_device *bdev, sector_t sector,
-		      void __pmem **kaddr, unsigned long *pfn)
+		      void __pmem **kaddr, pfn_t *pfn)
 {
 	struct pmem_device *pmem = bdev->bd_disk->private_data;
 	resource_size_t offset = sector * 512 + pmem->data_offset;
-	resource_size_t size;
-
-	if (pmem->data_offset) {
-		/*
-		 * Limit the direct_access() size to what is covered by
-		 * the memmap
-		 */
-		size = (pmem->size - offset) & ~ND_PFN_MASK;
-	} else
-		size = pmem->size - offset;
 
-	/* FIXME convert DAX to comprehend that this mapping has a lifetime */
 	*kaddr = pmem->virt_addr + offset;
-	*pfn = (pmem->phys_addr + offset) >> PAGE_SHIFT;
+	*pfn = phys_to_pfn_t(pmem->phys_addr + offset, pmem->pfn_flags);
 
-	return size;
+	return pmem->size - offset;
 }
 
 static const struct block_device_operations pmem_fops = {
@@ -150,10 +140,12 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 		return ERR_PTR(-EBUSY);
 	}
 
-	if (pmem_should_map_pages(dev))
+	pmem->pfn_flags = PFN_DEV;
+	if (pmem_should_map_pages(dev)) {
 		pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res,
 				NULL);
-	else
+		pmem->pfn_flags |= PFN_MAP;
+	} else
 		pmem->virt_addr = (void __pmem *) devm_memremap(dev,
 				pmem->phys_addr, pmem->size,
 				ARCH_MEMREMAP_PMEM);
@@ -380,6 +372,7 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	devm_memunmap(dev, (void __force *) pmem->virt_addr);
 	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res,
 			altmap);
+	pmem->pfn_flags |= PFN_MAP;
 	if (IS_ERR(pmem->virt_addr)) {
 		rc = PTR_ERR(pmem->virt_addr);
 		goto err;
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index 5ed44fe21380..e2b2839e4de5 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -29,7 +29,7 @@ static int dcssblk_open(struct block_device *bdev, fmode_t mode);
 static void dcssblk_release(struct gendisk *disk, fmode_t mode);
 static void dcssblk_make_request(struct request_queue *q, struct bio *bio);
 static long dcssblk_direct_access(struct block_device *bdev, sector_t secnum,
-			 void __pmem **kaddr, unsigned long *pfn);
+			 void __pmem **kaddr, pfn_t *pfn);
 
 static char dcssblk_segments[DCSSBLK_PARM_LEN] = "\0";
 
@@ -881,20 +881,18 @@ fail:
 
 static long
 dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
-			void __pmem **kaddr, unsigned long *pfn)
+			void __pmem **kaddr, pfn_t *pfn)
 {
 	struct dcssblk_dev_info *dev_info;
 	unsigned long offset, dev_sz;
-	void *addr;
 
 	dev_info = bdev->bd_disk->private_data;
 	if (!dev_info)
 		return -ENODEV;
 	dev_sz = dev_info->end - dev_info->start;
 	offset = secnum * 512;
-	addr = (void *) (dev_info->start + offset);
-	*pfn = virt_to_phys(addr) >> PAGE_SHIFT;
-	*kaddr = (void __pmem *) addr;
+	*kaddr = (void __pmem *) (dev_info->start + offset);
+	*pfn = phys_to_pfn_t(dev_info->start + offset, PFN_DEV);
 
 	return dev_sz - offset;
 }
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 073bb57adab1..c37a193695d4 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -442,7 +442,7 @@ EXPORT_SYMBOL_GPL(bdev_write_page);
  * accessible at this address.
  */
 long bdev_direct_access(struct block_device *bdev, sector_t sector,
-			void __pmem **addr, unsigned long *pfn, long size)
+			void __pmem **addr, pfn_t *pfn, long size)
 {
 	long avail;
 	const struct block_device_operations *ops = bdev->bd_disk->fops;
diff --git a/fs/dax.c b/fs/dax.c
index 9549cd523649..7496a776e1a6 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -31,7 +31,7 @@
 #include <linux/sizes.h>
 
 static void __pmem *__dax_map_atomic(struct block_device *bdev, sector_t sector,
-		long size, unsigned long *pfn, long *len)
+		long size, pfn_t *pfn, long *len)
 {
 	long rc;
 	void __pmem *addr;
@@ -52,7 +52,7 @@ static void __pmem *__dax_map_atomic(struct block_device *bdev, sector_t sector,
 static void __pmem *dax_map_atomic(struct block_device *bdev, sector_t sector,
 		long size)
 {
-	unsigned long pfn;
+	pfn_t pfn;
 
 	return __dax_map_atomic(bdev, sector, size, &pfn, NULL);
 }
@@ -77,8 +77,8 @@ int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 	might_sleep();
 	do {
 		void __pmem *addr;
-		unsigned long pfn;
 		long count, sz;
+		pfn_t pfn;
 
 		sz = min_t(long, size, SZ_1M);
 		addr = __dax_map_atomic(bdev, sector, size, &pfn, &count);
@@ -146,7 +146,7 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 	struct block_device *bdev = NULL;
 	int rw = iov_iter_rw(iter), rc;
 	long map_len = 0;
-	unsigned long pfn;
+	pfn_t pfn;
 	void __pmem *addr = NULL;
 	void __pmem *kmap = (void __pmem *) ERR_PTR(-EIO);
 	bool hole = false;
@@ -338,9 +338,9 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	unsigned long vaddr = (unsigned long)vmf->virtual_address;
 	struct address_space *mapping = inode->i_mapping;
 	struct block_device *bdev = bh->b_bdev;
-	unsigned long pfn;
 	void __pmem *addr;
 	pgoff_t size;
+	pfn_t pfn;
 	int error;
 
 	i_mmap_lock_read(mapping);
@@ -371,7 +371,7 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	}
 	dax_unmap_atomic(bdev, addr);
 
-	error = vm_insert_mixed(vma, vaddr, pfn);
+	error = vm_insert_mixed(vma, vaddr, pfn_t_to_pfn(pfn));
 
  out:
 	i_mmap_unlock_read(mapping);
@@ -660,8 +660,8 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		result = VM_FAULT_NOPAGE;
 		spin_unlock(ptl);
 	} else {
+		pfn_t pfn;
 		long length;
-		unsigned long pfn;
 		void __pmem *kaddr = __dax_map_atomic(bdev,
 				to_sector(&bh, inode), HPAGE_SIZE, &pfn,
 				&length);
@@ -670,7 +670,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 			result = VM_FAULT_SIGBUS;
 			goto out;
 		}
-		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR)) {
+		if ((length < PMD_SIZE) || (pfn_t_to_pfn(pfn) & PG_PMD_COLOUR)) {
 			dax_unmap_atomic(bdev, kaddr);
 			goto fallback;
 		}
@@ -684,7 +684,8 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		}
 		dax_unmap_atomic(bdev, kaddr);
 
-		result |= vmf_insert_pfn_pmd(vma, address, pmd, pfn, write);
+		result |= vmf_insert_pfn_pmd(vma, address, pmd,
+				pfn_t_to_pfn(pfn), write);
 	}
 
  out:
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index cd091cb2b96e..fb3e6886c479 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1624,7 +1624,7 @@ struct block_device_operations {
 	int (*ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	int (*compat_ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	long (*direct_access)(struct block_device *, sector_t, void __pmem **,
-			unsigned long *pfn);
+			pfn_t *);
 	unsigned int (*check_events) (struct gendisk *disk,
 				      unsigned int clearing);
 	/* ->media_changed() is DEPRECATED, use ->check_events() instead */
@@ -1643,7 +1643,7 @@ extern int bdev_read_page(struct block_device *, sector_t, struct page *);
 extern int bdev_write_page(struct block_device *, sector_t, struct page *,
 						struct writeback_control *);
 extern long bdev_direct_access(struct block_device *, sector_t,
-		void __pmem **addr, unsigned long *pfn, long size);
+		void __pmem **addr, pfn_t *pfn, long size);
 #else /* CONFIG_BLOCK */
 
 struct block_device;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b5628cfbf649..7045099f1654 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1033,6 +1033,71 @@ static inline void set_page_memcg(struct page *page, struct mem_cgroup *memcg)
 #endif
 
 /*
+ * PFN_FLAGS_MASK - mask of all the possible valid pfn_t flags
+ * PFN_SG_CHAIN - pfn is a pointer to the next scatterlist entry
+ * PFN_SG_LAST - pfn references a page and is the last scatterlist entry
+ * PFN_DEV - pfn is not covered by system memmap by default
+ * PFN_MAP - pfn has a dynamic page mapping established by a device driver
+ */
+#define PFN_FLAGS_MASK (~PAGE_MASK << (BITS_PER_LONG - PAGE_SHIFT))
+#define PFN_SG_CHAIN (1UL << (BITS_PER_LONG - 1))
+#define PFN_SG_LAST (1UL << (BITS_PER_LONG - 2))
+#define PFN_DEV (1UL << (BITS_PER_LONG - 3))
+#define PFN_MAP (1UL << (BITS_PER_LONG - 4))
+
+static inline pfn_t __pfn_to_pfn_t(unsigned long pfn, unsigned long flags)
+{
+	pfn_t pfn_t = { .val = pfn | (flags & PFN_FLAGS_MASK), };
+
+	return pfn_t;
+}
+
+/* a default pfn to pfn_t conversion assumes that @pfn is pfn_valid() */
+static inline pfn_t pfn_to_pfn_t(unsigned long pfn)
+{
+	return __pfn_to_pfn_t(pfn, 0);
+}
+
+static inline pfn_t phys_to_pfn_t(dma_addr_t addr, unsigned long flags)
+{
+	return __pfn_to_pfn_t(addr >> PAGE_SHIFT, flags);
+}
+
+static inline bool pfn_t_has_page(pfn_t pfn)
+{
+	return (pfn.val & PFN_MAP) == PFN_MAP || (pfn.val & PFN_DEV) == 0;
+}
+
+static inline unsigned long pfn_t_to_pfn(pfn_t pfn)
+{
+	return pfn.val & ~PFN_FLAGS_MASK;
+}
+
+static inline struct page *pfn_t_to_page(pfn_t pfn)
+{
+	if (pfn_t_has_page(pfn))
+		return pfn_to_page(pfn_t_to_pfn(pfn));
+	return NULL;
+}
+
+static inline dma_addr_t pfn_t_to_phys(pfn_t pfn)
+{
+	return PFN_PHYS(pfn_t_to_pfn(pfn));
+}
+
+static inline void *pfn_t_to_virt(pfn_t pfn)
+{
+	if (pfn_t_has_page(pfn))
+		return __va(pfn_t_to_phys(pfn));
+	return NULL;
+}
+
+static inline pfn_t page_to_pfn_t(struct page *page)
+{
+	return pfn_to_pfn_t(page_to_pfn(page));
+}
+
+/*
  * Some inline functions in vmstat.h depend on page_zone()
  */
 #include <linux/vmstat.h>
diff --git a/include/linux/pfn.h b/include/linux/pfn.h
index 7646637221f3..96df85985f16 100644
--- a/include/linux/pfn.h
+++ b/include/linux/pfn.h
@@ -3,6 +3,15 @@
 
 #ifndef __ASSEMBLY__
 #include <linux/types.h>
+
+/*
+ * pfn_t: encapsulates a page-frame number that is optionally backed
+ * by memmap (struct page).  Whether a pfn_t has a 'struct page'
+ * backing is indicated by flags in the high bits of the value.
+ */
+typedef struct {
+	unsigned long val;
+} pfn_t;
 #endif
 
 #define PFN_ALIGN(x)	(((unsigned long)(x) + (PAGE_SIZE - 1)) & PAGE_MASK)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
