Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5EBD96B0272
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 21:38:30 -0500 (EST)
Received: by pfu207 with SMTP id 207so39800098pfu.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 18:38:30 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id q19si16780259pfq.8.2015.12.09.18.38.29
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 18:38:29 -0800 (PST)
Subject: [-mm PATCH v2 09/25] mm, dax, pmem: introduce pfn_t
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 09 Dec 2015 18:37:57 -0800
Message-ID: <20151210023757.30368.20786.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave@sr71.net>, Christoph Hellwig <hch@lst.de>, linux-nvdimm@lists.01.org

For the purpose of communicating the optional presence of a 'struct
page' for the pfn returned from ->direct_access(), introduce a type that
encapsulates a page-frame-number plus flags.  These flags contain the
historical "page_link" encoding for a scatterlist entry, but can also
denote "device memory".  Where "device memory" is a set of pfns that are
not part of the kernel's linear mapping by default, but are accessed via
the same memory controller as ram.

The motivation for this new type is large capacity persistent memory
that needs struct page entries in the 'memmap' to support 3rd party DMA
(i.e. O_DIRECT I/O with a persistent memory source/target).  However, we
also need it in support of maintaining a list of mapped inodes which
need to be unmapped at driver teardown or freeze_bdev() time.

Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/powerpc/sysdev/axonram.c |    8 ++---
 drivers/block/brd.c           |    4 +-
 drivers/nvdimm/pmem.c         |   12 +++++--
 drivers/s390/block/dcssblk.c  |   10 ++----
 fs/dax.c                      |   10 ++++--
 include/linux/blkdev.h        |    4 +-
 include/linux/mm.h            |   66 +++++++++++++++++++++++++++++++++++++++++
 include/linux/pfn.h           |    9 ++++++
 8 files changed, 100 insertions(+), 23 deletions(-)

diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index c713b349d967..801e22fa0b02 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -142,15 +142,13 @@ axon_ram_make_request(struct request_queue *queue, struct bio *bio)
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
index a5880f4ab40e..13e5c2fe9f7c 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -378,7 +378,7 @@ static int brd_rw_page(struct block_device *bdev, sector_t sector,
 
 #ifdef CONFIG_BLK_DEV_RAM_DAX
 static long brd_direct_access(struct block_device *bdev, sector_t sector,
-			void __pmem **kaddr, unsigned long *pfn)
+			void __pmem **kaddr, pfn_t *pfn)
 {
 	struct brd_device *brd = bdev->bd_disk->private_data;
 	struct page *page;
@@ -389,7 +389,7 @@ static long brd_direct_access(struct block_device *bdev, sector_t sector,
 	if (!page)
 		return -ENOSPC;
 	*kaddr = (void __pmem *)page_address(page);
-	*pfn = page_to_pfn(page);
+	*pfn = page_to_pfn_t(page);
 
 	return PAGE_SIZE;
 }
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 8ee79893d2f5..157951043b34 100644
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
@@ -101,13 +102,13 @@ static int pmem_rw_page(struct block_device *bdev, sector_t sector,
 }
 
 static long pmem_direct_access(struct block_device *bdev, sector_t sector,
-		      void __pmem **kaddr, unsigned long *pfn)
+		      void __pmem **kaddr, pfn_t *pfn)
 {
 	struct pmem_device *pmem = bdev->bd_disk->private_data;
 	resource_size_t offset = sector * 512 + pmem->data_offset;
 
 	*kaddr = pmem->virt_addr + offset;
-	*pfn = (pmem->phys_addr + offset) >> PAGE_SHIFT;
+	*pfn = phys_to_pfn_t(pmem->phys_addr + offset, pmem->pfn_flags);
 
 	return pmem->size - offset;
 }
@@ -140,9 +141,11 @@ static struct pmem_device *pmem_alloc(struct device *dev,
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
@@ -353,6 +356,7 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	pmem = dev_get_drvdata(dev);
 	devm_memunmap(dev, (void __force *) pmem->virt_addr);
 	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res);
+	pmem->pfn_flags |= PFN_MAP;
 	if (IS_ERR(pmem->virt_addr)) {
 		rc = PTR_ERR(pmem->virt_addr);
 		goto err;
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index 94a8f4ab57bc..b50c5cb5601f 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -30,7 +30,7 @@ static void dcssblk_release(struct gendisk *disk, fmode_t mode);
 static blk_qc_t dcssblk_make_request(struct request_queue *q,
 						struct bio *bio);
 static long dcssblk_direct_access(struct block_device *bdev, sector_t secnum,
-			 void __pmem **kaddr, unsigned long *pfn);
+			 void __pmem **kaddr, pfn_t *pfn);
 
 static char dcssblk_segments[DCSSBLK_PARM_LEN] = "\0";
 
@@ -883,20 +883,18 @@ fail:
 
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
diff --git a/fs/dax.c b/fs/dax.c
index fdd455030bf0..9aadf121a274 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -362,7 +362,7 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	}
 	dax_unmap_atomic(bdev, &dax);
 
-	error = vm_insert_mixed(vma, vaddr, dax.pfn);
+	error = vm_insert_mixed(vma, vaddr, pfn_t_to_pfn(dax.pfn));
 
  out:
 	i_mmap_unlock_read(mapping);
@@ -667,7 +667,8 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 			result = VM_FAULT_SIGBUS;
 			goto out;
 		}
-		if ((length < PMD_SIZE) || (dax.pfn & PG_PMD_COLOUR)) {
+		if (length < PMD_SIZE
+				|| (pfn_t_to_pfn(dax.pfn) & PG_PMD_COLOUR)) {
 			dax_unmap_atomic(bdev, &dax);
 			goto fallback;
 		}
@@ -676,7 +677,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		 * TODO: teach vmf_insert_pfn_pmd() to support
 		 * 'pte_special' for pmds
 		 */
-		if (pfn_valid(dax.pfn)) {
+		if (pfn_t_has_page(dax.pfn)) {
 			dax_unmap_atomic(bdev, &dax);
 			goto fallback;
 		}
@@ -690,7 +691,8 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		}
 		dax_unmap_atomic(bdev, &dax);
 
-		result |= vmf_insert_pfn_pmd(vma, address, pmd, dax.pfn, write);
+		result |= vmf_insert_pfn_pmd(vma, address, pmd,
+				pfn_t_to_pfn(dax.pfn), write);
 	}
 
  out:
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index d52eabc76a12..d82513675de3 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1627,7 +1627,7 @@ struct blk_dax_ctl {
 	sector_t sector;
 	void __pmem *addr;
 	long size;
-	unsigned long pfn;
+	pfn_t pfn;
 };
 
 struct block_device_operations {
@@ -1637,7 +1637,7 @@ struct block_device_operations {
 	int (*ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	int (*compat_ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	long (*direct_access)(struct block_device *, sector_t, void __pmem **,
-			unsigned long *pfn);
+			pfn_t *);
 	unsigned int (*check_events) (struct gendisk *disk,
 				      unsigned int clearing);
 	/* ->media_changed() is DEPRECATED, use ->check_events() instead */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a1e87a3e88c0..dd05e24f904d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -884,6 +884,72 @@ static inline void set_page_memcg(struct page *page, struct mem_cgroup *memcg)
 #endif
 
 /*
+ * PFN_FLAGS_MASK - mask of all the possible valid pfn_t flags
+ * PFN_SG_CHAIN - pfn is a pointer to the next scatterlist entry
+ * PFN_SG_LAST - pfn references a page and is the last scatterlist entry
+ * PFN_DEV - pfn is not covered by system memmap by default
+ * PFN_MAP - pfn has a dynamic page mapping established by a device driver
+ */
+#define PFN_FLAGS_MASK (((unsigned long) ~PAGE_MASK) \
+		<< (BITS_PER_LONG - PAGE_SHIFT))
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
index 97f3e88aead4..2d8e49711b63 100644
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
