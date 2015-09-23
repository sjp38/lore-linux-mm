Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 57AA96B025C
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:47:55 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so29690022pac.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 21:47:55 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id cy1si7643373pad.200.2015.09.22.21.47.54
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 21:47:54 -0700 (PDT)
Subject: [PATCH 11/15] mm, dax, pmem: introduce __pfn_t
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Sep 2015 00:42:11 -0400
Message-ID: <20150923044211.36490.18084.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Dave Hansen <dave@sr71.net>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

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
 drivers/block/brd.c           |    4 +-
 drivers/nvdimm/pmem.c         |   27 ++++++++-------
 drivers/s390/block/dcssblk.c  |   10 ++----
 fs/block_dev.c                |    2 +
 fs/dax.c                      |   23 +++++++------
 include/linux/blkdev.h        |    4 +-
 include/linux/mm.h            |   72 +++++++++++++++++++++++++++++++++++++++++
 8 files changed, 110 insertions(+), 40 deletions(-)

diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index 24ffab2572e8..35eff52c0a38 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -141,15 +141,13 @@ axon_ram_make_request(struct request_queue *queue, struct bio *bio)
  */
 static long
 axon_ram_direct_access(struct block_device *device, sector_t sector,
-		       void __pmem **kaddr, unsigned long *pfn)
+		       void __pmem **kaddr, __pfn_t *pfn)
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
index f645a71ae827..50e78b1ea26c 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -374,7 +374,7 @@ static int brd_rw_page(struct block_device *bdev, sector_t sector,
 
 #ifdef CONFIG_BLK_DEV_RAM_DAX
 static long brd_direct_access(struct block_device *bdev, sector_t sector,
-			void __pmem **kaddr, unsigned long *pfn)
+			void __pmem **kaddr, __pfn_t *pfn)
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
index 3ee02af73ad0..1c670775129b 100644
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
@@ -108,25 +109,22 @@ static int pmem_rw_page(struct block_device *bdev, sector_t sector,
 }
 
 static long pmem_direct_access(struct block_device *bdev, sector_t sector,
-		      void __pmem **kaddr, unsigned long *pfn)
+		      void __pmem **kaddr, __pfn_t *pfn)
 {
 	struct pmem_device *pmem = bdev->bd_disk->private_data;
 	resource_size_t offset = sector * 512 + pmem->data_offset;
-	resource_size_t size;
+	resource_size_t size = pmem->size - offset;
 
-	if (pmem->data_offset) {
+	*kaddr = pmem->virt_addr + offset;
+	*pfn = phys_to_pfn_t(pmem->phys_addr + offset, pmem->pfn_flags);
+
+	if (__pfn_t_has_page(*pfn)) {
 		/*
 		 * Limit the direct_access() size to what is covered by
 		 * the memmap
 		 */
-		size = (pmem->size - offset) & ~ND_PFN_MASK;
-	} else
-		size = pmem->size - offset;
-
-	/* FIXME convert DAX to comprehend that this mapping has a lifetime */
-	*kaddr = pmem->virt_addr + offset;
-	*pfn = (pmem->phys_addr + offset) >> PAGE_SHIFT;
-
+		size &= ~ND_PFN_MASK;
+	}
 	return size;
 }
 
@@ -158,9 +156,11 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 		return ERR_PTR(-EBUSY);
 	}
 
-	if (pmem_should_map_pages(dev))
+	pmem->pfn_flags = PFN_DEV;
+	if (pmem_should_map_pages(dev)) {
 		pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res);
-	else
+		pmem->pfn_flags |= PFN_MAP;
+	} else
 		pmem->virt_addr = (void __pmem *) devm_memremap(dev,
 				pmem->phys_addr, pmem->size,
 				ARCH_MEMREMAP_PMEM);
@@ -371,6 +371,7 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	pmem = dev_get_drvdata(dev);
 	devm_memunmap(dev, (void __force *) pmem->virt_addr);
 	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res);
+	pmem->pfn_flags |= PFN_MAP;
 	if (IS_ERR(pmem->virt_addr)) {
 		rc = PTR_ERR(pmem->virt_addr);
 		goto err;
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index c212ce925ee6..4dfa8cfbdd9a 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -29,7 +29,7 @@ static int dcssblk_open(struct block_device *bdev, fmode_t mode);
 static void dcssblk_release(struct gendisk *disk, fmode_t mode);
 static void dcssblk_make_request(struct request_queue *q, struct bio *bio);
 static long dcssblk_direct_access(struct block_device *bdev, sector_t secnum,
-			 void __pmem **kaddr, unsigned long *pfn);
+			 void __pmem **kaddr, __pfn_t *pfn);
 
 static char dcssblk_segments[DCSSBLK_PARM_LEN] = "\0";
 
@@ -881,20 +881,18 @@ fail:
 
 static long
 dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
-			void __pmem **kaddr, unsigned long *pfn)
+			void __pmem **kaddr, __pfn_t *pfn)
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
index 073bb57adab1..74c507059f8d 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -442,7 +442,7 @@ EXPORT_SYMBOL_GPL(bdev_write_page);
  * accessible at this address.
  */
 long bdev_direct_access(struct block_device *bdev, sector_t sector,
-			void __pmem **addr, unsigned long *pfn, long size)
+			void __pmem **addr, __pfn_t *pfn, long size)
 {
 	long avail;
 	const struct block_device_operations *ops = bdev->bd_disk->fops;
diff --git a/fs/dax.c b/fs/dax.c
index 358eea39e982..41d4f76e93ef 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -37,7 +37,7 @@ int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 	might_sleep();
 	do {
 		void __pmem *addr;
-		unsigned long pfn;
+		__pfn_t pfn;
 		long count;
 
 		count = bdev_direct_access(bdev, sector, &addr, &pfn, size);
@@ -64,7 +64,7 @@ int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 EXPORT_SYMBOL_GPL(dax_clear_blocks);
 
 static void __pmem *__dax_map_bh(const struct buffer_head *bh, unsigned blkbits,
-		unsigned long *pfn, long *len)
+		__pfn_t *pfn, long *len)
 {
 	long rc;
 	void __pmem *addr;
@@ -87,7 +87,7 @@ static void __pmem *__dax_map_bh(const struct buffer_head *bh, unsigned blkbits,
 
 static void __pmem *dax_map_bh(const struct buffer_head *bh, unsigned blkbits)
 {
-	unsigned long pfn;
+	__pfn_t pfn;
 
 	return __dax_map_bh(bh, blkbits, &pfn, NULL);
 }
@@ -138,7 +138,7 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 	loff_t pos = start, max = start, bh_max = start;
 	int rw = iov_iter_rw(iter), rc;
 	long map_len = 0;
-	unsigned long pfn;
+	__pfn_t pfn;
 	void __pmem *addr = NULL;
 	void __pmem *kmap = (void __pmem *) ERR_PTR(-EIO);
 	bool hole = false;
@@ -324,9 +324,9 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 			struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	unsigned long vaddr = (unsigned long)vmf->virtual_address;
-	unsigned long pfn;
 	void __pmem *addr;
 	pgoff_t size;
+	__pfn_t pfn;
 	int error;
 
 	/*
@@ -354,7 +354,7 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	}
 	dax_unmap_bh(bh, addr);
 
-	error = vm_insert_mixed(vma, vaddr, pfn);
+	error = vm_insert_mixed(vma, vaddr, __pfn_t_to_pfn(pfn));
 
  out:
 	return error;
@@ -604,7 +604,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	if (buffer_unwritten(&bh) || buffer_new(&bh)) {
 		int i;
 		long length;
-		unsigned long pfn;
+		__pfn_t pfn;
 		void __pmem *kaddr = __dax_map_bh(&bh, blkbits, &pfn, &length);
 
 		if (IS_ERR(kaddr)) {
@@ -612,7 +612,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 			goto out;
 		}
 
-		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
+		if ((length < PMD_SIZE) || (__pfn_t_to_pfn(pfn) & PG_PMD_COLOUR))
 			goto fallback;
 
 		for (i = 0; i < PTRS_PER_PMD; i++)
@@ -668,8 +668,8 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		result = VM_FAULT_NOPAGE;
 		spin_unlock(ptl);
 	} else {
+		__pfn_t pfn;
 		long length;
-		unsigned long pfn;
 		void __pmem *kaddr = __dax_map_bh(&bh, blkbits, &pfn, &length);
 
 		if (IS_ERR(kaddr)) {
@@ -677,10 +677,11 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 			goto out;
 		}
 		dax_unmap_bh(&bh, kaddr);
-		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
+		if ((length < PMD_SIZE) || (__pfn_t_to_pfn(pfn) & PG_PMD_COLOUR))
 			goto fallback;
 
-		result |= vmf_insert_pfn_pmd(vma, address, pmd, pfn, write);
+		result |= vmf_insert_pfn_pmd(vma, address, pmd,
+				__pfn_t_to_pfn(pfn), write);
 	}
 
  out:
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 363d7df8d65c..e893f30ad520 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1634,7 +1634,7 @@ struct block_device_operations {
 	int (*ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	int (*compat_ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	long (*direct_access)(struct block_device *, sector_t, void __pmem **,
-			unsigned long *pfn);
+			__pfn_t *);
 	unsigned int (*check_events) (struct gendisk *disk,
 				      unsigned int clearing);
 	/* ->media_changed() is DEPRECATED, use ->check_events() instead */
@@ -1653,7 +1653,7 @@ extern int bdev_read_page(struct block_device *, sector_t, struct page *);
 extern int bdev_write_page(struct block_device *, sector_t, struct page *,
 						struct writeback_control *);
 extern long bdev_direct_access(struct block_device *, sector_t,
-		void __pmem **addr, unsigned long *pfn, long size);
+		void __pmem **addr, __pfn_t *pfn, long size);
 #else /* CONFIG_BLOCK */
 
 struct block_device;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 91c08f6f0dc9..6ea922de6870 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -906,6 +906,78 @@ static inline void set_page_links(struct page *page, enum zone_type zone,
 }
 
 /*
+ * __pfn_t: encapsulates a page-frame number that is optionally backed
+ * by memmap (struct page).  Whether a __pfn_t has a 'struct page'
+ * backing is indicated by flags in the low bits of the value;
+ */
+typedef struct {
+	unsigned long val;
+} __pfn_t;
+
+/*
+ * PFN_SG_CHAIN - pfn is a pointer to the next scatterlist entry
+ * PFN_SG_LAST - pfn references a page and is the last scatterlist entry
+ * PFN_DEV - pfn is not covered by system memmap by default
+ * PFN_MAP - pfn has a dynamic page mapping established by a device driver
+ */
+enum {
+	PFN_SHIFT = 4,
+	PFN_MASK = (1UL << PFN_SHIFT) - 1,
+	PFN_SG_CHAIN = (1UL << 0),
+	PFN_SG_LAST = (1UL << 1),
+	PFN_DEV = (1UL << 2),
+	PFN_MAP = (1UL << 3),
+};
+
+static inline __pfn_t pfn_to_pfn_t(unsigned long pfn, unsigned long flags)
+{
+	__pfn_t pfn_t = { .val = (pfn << PFN_SHIFT) | (flags & PFN_MASK), };
+
+	return pfn_t;
+}
+
+static inline __pfn_t phys_to_pfn_t(dma_addr_t addr, unsigned long flags)
+{
+	return pfn_to_pfn_t(addr >> PAGE_SHIFT, flags);
+}
+
+static inline bool __pfn_t_has_page(__pfn_t pfn)
+{
+	return (pfn.val & PFN_MAP) == PFN_MAP || (pfn.val & PFN_DEV) == 0;
+}
+
+static inline unsigned long __pfn_t_to_pfn(__pfn_t pfn)
+{
+	return pfn.val >> PFN_SHIFT;
+}
+
+static inline struct page *__pfn_t_to_page(__pfn_t pfn)
+{
+	if (__pfn_t_has_page(pfn))
+		return pfn_to_page(__pfn_t_to_pfn(pfn));
+	return NULL;
+}
+
+static inline dma_addr_t __pfn_t_to_phys(__pfn_t pfn)
+{
+	return PFN_PHYS(__pfn_t_to_pfn(pfn));
+}
+
+static inline void *__pfn_t_to_virt(__pfn_t pfn)
+{
+	if (__pfn_t_has_page(pfn))
+		return __va(__pfn_t_to_phys(pfn));
+	return NULL;
+}
+
+static inline __pfn_t page_to_pfn_t(struct page *page)
+{
+	__pfn_t pfn = { .val = page_to_pfn(page) << PFN_SHIFT, };
+
+	return pfn;
+}
+
+/*
  * Some inline functions in vmstat.h depend on page_zone()
  */
 #include <linux/vmstat.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
