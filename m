Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 30FC16B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 02:27:01 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so245601614wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:27:00 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id az9si2166629wib.30.2015.08.12.23.26.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 23:26:58 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so55789154wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:26:58 -0700 (PDT)
Message-ID: <55CC38B0.70502@plexistor.com>
Date: Thu, 13 Aug 2015 09:26:56 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 4/5] dax: fix mapping lifetime handling, convert to
 __pfn_t + kmap_atomic_pfn_t()
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com> <20150813030119.36703.48416.stgit@otcpl-skl-sds-2.jf.intel.com>
In-Reply-To: <20150813030119.36703.48416.stgit@otcpl-skl-sds-2.jf.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org
Cc: axboe@kernel.dk, riel@redhat.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, mgorman@suse.de, torvalds@linux-foundation.org, hch@lst.de

On 08/13/2015 06:01 AM, Dan Williams wrote:
> The primary source for non-page-backed page-frames to enter the system
> is via the pmem driver's ->direct_access() method.  The pfns returned by
> the top-level bdev_direct_access() may be passed to any other subsystem
> in the kernel and those sub-systems either need to assume that the pfn
> is page backed (CONFIG_DEV_PFN=n) or be prepared to handle non-page
> backed case (CONFIG_DEV_PFN=y).  Currently the pfns returned by
> ->direct_access() are only ever used by vm_insert_mixed() which does not
> care if the pfn is mapped.  As we go to add more usages of these pfns
> add the type-safety of __pfn_t.
> 
> This also simplifies the calling convention of ->direct_access() by not
> returning the virtual address in the same call.  This annotates cases
> where the kernel is directly accessing pmem outside the driver, and
> makes the valid lifetime of the reference explicit.  This property may
> be useful in the future for invalidating mappings to pmem, but for now
> it provides some protection against the "pmem disable vs still-in-use"
> race.
> 
> Note that axon_ram_direct_access and dcssblk_direct_access were
> previously making potentially incorrect assumptions about the addresses
> they passed to virt_to_phys().
> 
> [hch: various minor updates]
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/powerpc/platforms/Kconfig |    1 +
>  arch/powerpc/sysdev/axonram.c  |   24 ++++++++----
>  drivers/block/brd.c            |    5 +--
>  drivers/nvdimm/Kconfig         |    1 +
>  drivers/nvdimm/pmem.c          |   24 +++++++-----
>  drivers/s390/block/Kconfig     |    1 +
>  drivers/s390/block/dcssblk.c   |   23 ++++++++++--
>  fs/Kconfig                     |    1 +
>  fs/block_dev.c                 |    4 +-
>  fs/dax.c                       |   79 +++++++++++++++++++++++++++++-----------
>  include/linux/blkdev.h         |    7 ++--
>  include/linux/mm.h             |   12 ++++++
>  12 files changed, 129 insertions(+), 53 deletions(-)
> 
> diff --git a/arch/powerpc/platforms/Kconfig b/arch/powerpc/platforms/Kconfig
> index b7f9c408bf24..6b1c2f2e5fb4 100644
> --- a/arch/powerpc/platforms/Kconfig
> +++ b/arch/powerpc/platforms/Kconfig
> @@ -307,6 +307,7 @@ config CPM2
>  config AXON_RAM
>  	tristate "Axon DDR2 memory device driver"
>  	depends on PPC_IBM_CELL_BLADE && BLOCK
> +	select KMAP_PFN
>  	default m
>  	help
>  	  It registers one block device per Axon's DDR2 memory bank found
> diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
> index e8657d3bc588..7c5a1563c0fd 100644
> --- a/arch/powerpc/sysdev/axonram.c
> +++ b/arch/powerpc/sysdev/axonram.c
> @@ -43,6 +43,7 @@
>  #include <linux/types.h>
>  #include <linux/of_device.h>
>  #include <linux/of_platform.h>
> +#include <linux/kmap_pfn.h>
>  
>  #include <asm/page.h>
>  #include <asm/prom.h>
> @@ -141,14 +142,12 @@ axon_ram_make_request(struct request_queue *queue, struct bio *bio)
>   */
>  static long
>  axon_ram_direct_access(struct block_device *device, sector_t sector,
> -		       void **kaddr, unsigned long *pfn)
> +		       __pfn_t *pfn)
>  {
>  	struct axon_ram_bank *bank = device->bd_disk->private_data;
>  	loff_t offset = (loff_t)sector << AXON_RAM_SECTOR_SHIFT;
>  
> -	*kaddr = (void *)(bank->ph_addr + offset);
> -	*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;
> -
> +	*pfn = phys_to_pfn_t(bank->ph_addr + offset, PFN_DEV);
>  	return bank->size - offset;
>  }
>  
> @@ -165,9 +164,13 @@ static int axon_ram_probe(struct platform_device *device)
>  {
>  	static int axon_ram_bank_id = -1;
>  	struct axon_ram_bank *bank;
> -	struct resource resource;
> +	struct resource *resource;
>  	int rc = 0;
>  
> +	resource = devm_kzalloc(&device->dev, sizeof(*resource), GFP_KERNEL);
> +	if (!resource)
> +		return -ENOMEM;
> +
>  	axon_ram_bank_id++;
>  
>  	dev_info(&device->dev, "Found memory controller on %s\n",
> @@ -184,13 +187,13 @@ static int axon_ram_probe(struct platform_device *device)
>  
>  	bank->device = device;
>  
> -	if (of_address_to_resource(device->dev.of_node, 0, &resource) != 0) {
> +	if (of_address_to_resource(device->dev.of_node, 0, resource) != 0) {
>  		dev_err(&device->dev, "Cannot access device tree\n");
>  		rc = -EFAULT;
>  		goto failed;
>  	}
>  
> -	bank->size = resource_size(&resource);
> +	bank->size = resource_size(resource);
>  
>  	if (bank->size == 0) {
>  		dev_err(&device->dev, "No DDR2 memory found for %s%d\n",
> @@ -202,7 +205,7 @@ static int axon_ram_probe(struct platform_device *device)
>  	dev_info(&device->dev, "Register DDR2 memory device %s%d with %luMB\n",
>  			AXON_RAM_DEVICE_NAME, axon_ram_bank_id, bank->size >> 20);
>  
> -	bank->ph_addr = resource.start;
> +	bank->ph_addr = resource->start;
>  	bank->io_addr = (unsigned long) ioremap_prot(
>  			bank->ph_addr, bank->size, _PAGE_NO_CACHE);
>  	if (bank->io_addr == 0) {
> @@ -211,6 +214,11 @@ static int axon_ram_probe(struct platform_device *device)
>  		goto failed;
>  	}
>  
> +	rc = devm_register_kmap_pfn_range(&device->dev, resource,
> +			(void *) bank->io_addr);
> +	if (rc)
> +		goto failed;
> +
>  	bank->disk = alloc_disk(AXON_RAM_MINORS_PER_DISK);
>  	if (bank->disk == NULL) {
>  		dev_err(&device->dev, "Cannot register disk\n");
> diff --git a/drivers/block/brd.c b/drivers/block/brd.c
> index 41528857c70d..6c4b21a4e915 100644
> --- a/drivers/block/brd.c
> +++ b/drivers/block/brd.c
> @@ -371,7 +371,7 @@ static int brd_rw_page(struct block_device *bdev, sector_t sector,
>  
>  #ifdef CONFIG_BLK_DEV_RAM_DAX
>  static long brd_direct_access(struct block_device *bdev, sector_t sector,
> -			void **kaddr, unsigned long *pfn)
> +		__pfn_t *pfn)
>  {
>  	struct brd_device *brd = bdev->bd_disk->private_data;
>  	struct page *page;
> @@ -381,8 +381,7 @@ static long brd_direct_access(struct block_device *bdev, sector_t sector,
>  	page = brd_insert_page(brd, sector);
>  	if (!page)
>  		return -ENOSPC;
> -	*kaddr = page_address(page);
> -	*pfn = page_to_pfn(page);
> +	*pfn = page_to_pfn_t(page);
>  
>  	return PAGE_SIZE;
>  }
> diff --git a/drivers/nvdimm/Kconfig b/drivers/nvdimm/Kconfig
> index 72226acb5c0f..0d8c6bda7a41 100644
> --- a/drivers/nvdimm/Kconfig
> +++ b/drivers/nvdimm/Kconfig
> @@ -20,6 +20,7 @@ config BLK_DEV_PMEM
>  	tristate "PMEM: Persistent memory block device support"
>  	default LIBNVDIMM
>  	depends on HAS_IOMEM
> +	select KMAP_PFN
>  	select ND_BTT if BTT
>  	help
>  	  Memory ranges for PMEM are described by either an NFIT
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index 5e019a6942ce..85d4101bb821 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -25,6 +25,8 @@
>  #include <linux/slab.h>
>  #include <linux/pmem.h>
>  #include <linux/nd.h>
> +#include <linux/mm.h>
> +#include <linux/kmap_pfn.h>
>  #include "nd.h"
>  
>  struct pmem_device {
> @@ -92,18 +94,12 @@ static int pmem_rw_page(struct block_device *bdev, sector_t sector,
>  }
>  
>  static long pmem_direct_access(struct block_device *bdev, sector_t sector,
> -			      void **kaddr, unsigned long *pfn)
> +		__pfn_t *pfn)
>  {
>  	struct pmem_device *pmem = bdev->bd_disk->private_data;
>  	size_t offset = sector << 9;
>  
> -	if (!pmem)
> -		return -ENODEV;
> -
> -	/* FIXME convert DAX to comprehend that this mapping has a lifetime */
> -	*kaddr = (void __force *) pmem->virt_addr + offset;
> -	*pfn = (pmem->phys_addr + offset) >> PAGE_SHIFT;
> -
> +	*pfn = phys_to_pfn_t(pmem->phys_addr + offset, PFN_DEV);
>  	return pmem->size - offset;
>  }
>  
> @@ -149,10 +145,17 @@ static void pmem_detach_disk(struct pmem_device *pmem)
>  	blk_cleanup_queue(pmem->pmem_queue);
>  }
>  
> -static int pmem_attach_disk(struct nd_namespace_common *ndns,
> +static int pmem_attach_disk(struct device *dev,
> +		struct nd_namespace_common *ndns,
>  		struct pmem_device *pmem)
>  {
>  	struct gendisk *disk;
> +	struct resource *res = &(to_nd_namespace_io(&ndns->dev)->res);
> +	int err;
> +
> +	err = devm_register_kmap_pfn_range(dev, res, pmem->virt_addr);
> +	if (err)
> +		return err;
>  
>  	pmem->pmem_queue = blk_alloc_queue(GFP_KERNEL);
>  	if (!pmem->pmem_queue)
> @@ -232,7 +235,8 @@ static int nd_pmem_probe(struct device *dev)
>  	if (nd_btt_probe(ndns, pmem) == 0)
>  		/* we'll come back as btt-pmem */
>  		return -ENXIO;
> -	return pmem_attach_disk(ndns, pmem);
> +
> +	return pmem_attach_disk(dev, ndns, pmem);
>  }
>  
>  static int nd_pmem_remove(struct device *dev)
> diff --git a/drivers/s390/block/Kconfig b/drivers/s390/block/Kconfig
> index 4a3b62326183..06c7a1c90d88 100644
> --- a/drivers/s390/block/Kconfig
> +++ b/drivers/s390/block/Kconfig
> @@ -14,6 +14,7 @@ config BLK_DEV_XPRAM
>  
>  config DCSSBLK
>  	def_tristate m
> +	select KMAP_PFN
>  	prompt "DCSSBLK support"
>  	depends on S390 && BLOCK
>  	help
> diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
> index 2f1734ba0e22..42f1546d7b03 100644
> --- a/drivers/s390/block/dcssblk.c
> +++ b/drivers/s390/block/dcssblk.c
> @@ -16,6 +16,7 @@
>  #include <linux/blkdev.h>
>  #include <linux/completion.h>
>  #include <linux/interrupt.h>
> +#include <linux/kmap_pfn.h>
>  #include <linux/platform_device.h>
>  #include <asm/extmem.h>
>  #include <asm/io.h>
> @@ -29,7 +30,7 @@ static int dcssblk_open(struct block_device *bdev, fmode_t mode);
>  static void dcssblk_release(struct gendisk *disk, fmode_t mode);
>  static void dcssblk_make_request(struct request_queue *q, struct bio *bio);
>  static long dcssblk_direct_access(struct block_device *bdev, sector_t secnum,
> -				 void **kaddr, unsigned long *pfn);
> +		__pfn_t *pfn);
>  
>  static char dcssblk_segments[DCSSBLK_PARM_LEN] = "\0";
>  
> @@ -520,12 +521,18 @@ static const struct attribute_group *dcssblk_dev_attr_groups[] = {
>  static ssize_t
>  dcssblk_add_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
>  {
> +	struct resource *res = devm_kzalloc(dev, sizeof(*res), GFP_KERNEL);
>  	int rc, i, j, num_of_segments;
>  	struct dcssblk_dev_info *dev_info;
>  	struct segment_info *seg_info, *temp;
>  	char *local_buf;
>  	unsigned long seg_byte_size;
>  
> +	if (!res) {
> +		rc = -ENOMEM;
> +		goto out_nobuf;
> +	}
> +
>  	dev_info = NULL;
>  	seg_info = NULL;
>  	if (dev != dcssblk_root_dev) {
> @@ -652,6 +659,13 @@ dcssblk_add_store(struct device *dev, struct device_attribute *attr, const char
>  	if (rc)
>  		goto put_dev;
>  
> +	res->start = dev_info->start;
> +	res->end = dev_info->end - 1;
> +	rc = devm_register_kmap_pfn_range(&dev_info->dev, res,
> +			(void *) dev_info->start);
> +	if (rc)
> +		goto put_dev;
> +
>  	get_device(&dev_info->dev);
>  	add_disk(dev_info->gd);
>  
> @@ -699,6 +713,8 @@ seg_list_del:
>  out:
>  	kfree(local_buf);
>  out_nobuf:
> +	if (res)
> +		devm_kfree(dev, res);
>  	return rc;
>  }
>  
> @@ -879,7 +895,7 @@ fail:
>  
>  static long
>  dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
> -			void **kaddr, unsigned long *pfn)
> +		__pfn_t *pfn)
>  {
>  	struct dcssblk_dev_info *dev_info;
>  	unsigned long offset, dev_sz;
> @@ -889,8 +905,7 @@ dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
>  		return -ENODEV;
>  	dev_sz = dev_info->end - dev_info->start;
>  	offset = secnum * 512;
> -	*kaddr = (void *) (dev_info->start + offset);
> -	*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;
> +	*pfn = phys_to_pfn_t(dev_info->start + offset, PFN_DEV);
>  
>  	return dev_sz - offset;
>  }
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 011f43365d7b..bd37234e71a8 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -38,6 +38,7 @@ config FS_DAX
>  	bool "Direct Access (DAX) support"
>  	depends on MMU
>  	depends on !(ARM || MIPS || SPARC)
> +	depends on KMAP_PFN
>  	help
>  	  Direct Access (DAX) can be used on memory-backed block devices.
>  	  If the block device supports DAX and the filesystem supports DAX,
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index 3a8ac7edfbf4..73fbc57b6e6d 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -441,7 +441,7 @@ EXPORT_SYMBOL_GPL(bdev_write_page);
>   * accessible at this address.
>   */
>  long bdev_direct_access(struct block_device *bdev, sector_t sector,
> -			void **addr, unsigned long *pfn, long size)
> +			__pfn_t *pfn, long size)
>  {
>  	long avail;
>  	const struct block_device_operations *ops = bdev->bd_disk->fops;
> @@ -462,7 +462,7 @@ long bdev_direct_access(struct block_device *bdev, sector_t sector,
>  	sector += get_start_sect(bdev);
>  	if (sector % (PAGE_SIZE / 512))
>  		return -EINVAL;
> -	avail = ops->direct_access(bdev, sector, addr, pfn);
> +	avail = ops->direct_access(bdev, sector, pfn);
>  	if (!avail)
>  		return -ERANGE;
>  	return min(avail, size);
> diff --git a/fs/dax.c b/fs/dax.c
> index c3e21ccfc358..94611f480091 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -26,6 +26,7 @@
>  #include <linux/sched.h>
>  #include <linux/uio.h>
>  #include <linux/vmstat.h>
> +#include <linux/kmap_pfn.h>
>  
>  int dax_clear_blocks(struct inode *inode, sector_t block, long size)
>  {
> @@ -35,13 +36,16 @@ int dax_clear_blocks(struct inode *inode, sector_t block, long size)
>  	might_sleep();
>  	do {
>  		void *addr;
> -		unsigned long pfn;
> +		__pfn_t pfn;
>  		long count;
>  
> -		count = bdev_direct_access(bdev, sector, &addr, &pfn, size);
> +		count = bdev_direct_access(bdev, sector, &pfn, size);
>  		if (count < 0)
>  			return count;
>  		BUG_ON(size < count);
> +		addr = kmap_atomic_pfn_t(pfn);
> +		if (!addr)
> +			return -EIO;
>  		while (count > 0) {
>  			unsigned pgsz = PAGE_SIZE - offset_in_page(addr);
>  			if (pgsz > count)
> @@ -57,17 +61,39 @@ int dax_clear_blocks(struct inode *inode, sector_t block, long size)
>  			sector += pgsz / 512;
>  			cond_resched();
>  		}
> +		kunmap_atomic_pfn_t(addr);
>  	} while (size);
>  
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(dax_clear_blocks);
>  
> -static long dax_get_addr(struct buffer_head *bh, void **addr, unsigned blkbits)
> +static void *__dax_map_bh(struct buffer_head *bh, unsigned blkbits, __pfn_t *pfn)
>  {
> -	unsigned long pfn;
>  	sector_t sector = bh->b_blocknr << (blkbits - 9);
> -	return bdev_direct_access(bh->b_bdev, sector, addr, &pfn, bh->b_size);
> +	void *addr;
> +	long rc;
> +
> +	rc = bdev_direct_access(bh->b_bdev, sector, pfn, bh->b_size);
> +	if (rc)
> +		return ERR_PTR(rc);
> +	addr = kmap_atomic_pfn_t(*pfn);
> +	if (!addr)
> +		return ERR_PTR(-EIO);
> +	return addr;
> +}
> +
> +static void *dax_map_bh(struct buffer_head *bh, unsigned blkbits)
> +{
> +	__pfn_t pfn;
> +
> +	return __dax_map_bh(bh, blkbits, &pfn);
> +}
> +
> +static void dax_unmap_bh(void *addr)
> +{
> +	if (!IS_ERR(addr))
> +		kunmap_atomic_pfn_t(addr);
>  }
>  
>  static void dax_new_buf(void *addr, unsigned size, unsigned first, loff_t pos,
> @@ -106,7 +132,7 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
>  	loff_t pos = start;
>  	loff_t max = start;
>  	loff_t bh_max = start;
> -	void *addr;
> +	void *addr = NULL, *kmap = ERR_PTR(-EIO);
>  	bool hole = false;
>  
>  	if (iov_iter_rw(iter) != WRITE)
> @@ -142,9 +168,13 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
>  				addr = NULL;
>  				size = bh->b_size - first;
>  			} else {
> -				retval = dax_get_addr(bh, &addr, blkbits);
> -				if (retval < 0)
> +				dax_unmap_bh(kmap);
> +				kmap = dax_map_bh(bh, blkbits);
> +				if (IS_ERR(kmap)) {
> +					retval = PTR_ERR(kmap);
>  					break;
> +				}
> +				addr = kmap;
>  				if (buffer_unwritten(bh) || buffer_new(bh))
>  					dax_new_buf(addr, retval, first, pos,
>  									end);
> @@ -168,6 +198,8 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
>  		addr += len;
>  	}
>  
> +	dax_unmap_bh(kmap);
> +
>  	return (pos == start) ? retval : pos - start;
>  }
>  
> @@ -261,11 +293,14 @@ static int copy_user_bh(struct page *to, struct buffer_head *bh,
>  			unsigned blkbits, unsigned long vaddr)
>  {
>  	void *vfrom, *vto;
> -	if (dax_get_addr(bh, &vfrom, blkbits) < 0)
> -		return -EIO;
> +
> +	vfrom = dax_map_bh(bh, blkbits);
> +	if (IS_ERR(vfrom))
> +		return PTR_ERR(vfrom);
>  	vto = kmap_atomic(to);
>  	copy_user_page(vto, vfrom, vaddr, to);
>  	kunmap_atomic(vto);
> +	dax_unmap_bh(vfrom);
>  	return 0;
>  }
>  
> @@ -273,11 +308,10 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
>  			struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
>  	struct address_space *mapping = inode->i_mapping;
> -	sector_t sector = bh->b_blocknr << (inode->i_blkbits - 9);
>  	unsigned long vaddr = (unsigned long)vmf->virtual_address;
> -	void *addr;
> -	unsigned long pfn;
>  	pgoff_t size;
> +	__pfn_t pfn;
> +	void *addr;
>  	int error;
>  
>  	i_mmap_lock_read(mapping);
> @@ -295,18 +329,17 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
>  		goto out;
>  	}
>  
> -	error = bdev_direct_access(bh->b_bdev, sector, &addr, &pfn, bh->b_size);
> -	if (error < 0)
> -		goto out;
> -	if (error < PAGE_SIZE) {
> -		error = -EIO;
> +	addr = __dax_map_bh(bh, inode->i_blkbits, &pfn);
> +	if (IS_ERR(addr)) {
> +		error = PTR_ERR(addr);
>  		goto out;
>  	}
>  
>  	if (buffer_unwritten(bh) || buffer_new(bh))
>  		clear_page(addr);
> +	dax_unmap_bh(addr);
>  

Boooo. Here this all set is a joke. The all "pmem disable vs still-in-use" argument is mute
here below you have inserted a live, used for ever, pfn into a process vm without holding
a map.

The all "pmem disable vs still-in-use" is a joke. The FS loaded has a reference on the bdev
and the filehadle has a reference on the FS. So what is exactly this "pmem disable" you are
talking about?

And for god sake. I have a bdev I call bdev_direct_access(sector), the bdev calculated the
exact address for me (base + sector). Now I get back this __pfn_t and I need to call
kmap_atomic_pfn_t() which does a loop to search for my range and again base+offset ?

This all model is broken, sorry?

> -	error = vm_insert_mixed(vma, vaddr, pfn);
> +	error = vm_insert_mixed(vma, vaddr, __pfn_t_to_pfn(pfn));
>  
>   out:
>  	i_mmap_unlock_read(mapping);
> @@ -539,10 +572,12 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
>  		return err;
>  	if (buffer_written(&bh)) {
>  		void *addr;
> -		err = dax_get_addr(&bh, &addr, inode->i_blkbits);
> -		if (err < 0)
> -			return err;
> +
> +		addr = dax_map_bh(&bh, inode->i_blkbits);
> +		if (IS_ERR(addr))
> +			return PTR_ERR(addr);
>  		memset(addr + offset, 0, length);
> +		dax_unmap_bh(addr);
>  	}
>  
>  	return 0;
> diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
> index ff47d5498133..ae59778d8076 100644
> --- a/include/linux/blkdev.h
> +++ b/include/linux/blkdev.h
> @@ -1555,8 +1555,7 @@ struct block_device_operations {
>  	int (*rw_page)(struct block_device *, sector_t, struct page *, int rw);
>  	int (*ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
>  	int (*compat_ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
> -	long (*direct_access)(struct block_device *, sector_t,
> -					void **, unsigned long *pfn);
> +	long (*direct_access)(struct block_device *, sector_t, __pfn_t *pfn);
>  	unsigned int (*check_events) (struct gendisk *disk,
>  				      unsigned int clearing);
>  	/* ->media_changed() is DEPRECATED, use ->check_events() instead */
> @@ -1574,8 +1573,8 @@ extern int __blkdev_driver_ioctl(struct block_device *, fmode_t, unsigned int,
>  extern int bdev_read_page(struct block_device *, sector_t, struct page *);
>  extern int bdev_write_page(struct block_device *, sector_t, struct page *,
>  						struct writeback_control *);
> -extern long bdev_direct_access(struct block_device *, sector_t, void **addr,
> -						unsigned long *pfn, long size);
> +extern long bdev_direct_access(struct block_device *, sector_t,
> +		__pfn_t *pfn, long size);
>  #else /* CONFIG_BLOCK */
>  
>  struct block_device;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 57ba5ca6be72..c4683ea2fcab 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -951,6 +951,18 @@ enum {
>  #endif
>  };
>  
> +static inline __pfn_t pfn_to_pfn_t(unsigned long pfn, unsigned long flags)
> +{
> +	__pfn_t pfn_t = { .val = (pfn << PAGE_SHIFT) | (flags & PFN_MASK), };
> +
> +	return pfn_t;
> +}
> +
> +static inline __pfn_t phys_to_pfn_t(dma_addr_t addr, unsigned long flags)
> +{
> +	return pfn_to_pfn_t(addr >> PAGE_SHIFT, flags);
> +}
> +
>  static inline bool __pfn_t_has_page(__pfn_t pfn)
>  {
>  	return (pfn.val & PFN_DEV) == 0;
> 
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
