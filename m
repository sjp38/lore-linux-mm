Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id B06776B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:55:21 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id d68so216625169ywe.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 07:55:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b5si36766405qhc.44.2016.04.15.07.55.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 07:55:20 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH v2 1/5] block, dax: pass blk_dax_ctl through to drivers
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	<1459303190-20072-2-git-send-email-vishal.l.verma@intel.com>
Date: Fri, 15 Apr 2016 10:55:17 -0400
In-Reply-To: <1459303190-20072-2-git-send-email-vishal.l.verma@intel.com>
	(Vishal Verma's message of "Tue, 29 Mar 2016 19:59:46 -0600")
Message-ID: <x49bn5a7wh6.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@ml01.01.org, Jens Axboe <axboe@fb.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-block@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

Vishal Verma <vishal.l.verma@intel.com> writes:

> From: Dan Williams <dan.j.williams@intel.com>
>
> This is in preparation for doing badblocks checking against the
> requested sector range in the driver.  Currently we opportunistically
> return as much data that can be "dax'd" starting at the given sector.
> When errors are present we want to limit that range to the first
> encountered error, or fail the dax request if the range encompasses an
> error.

I'm not a fan of hiding arguments like this, but it looks fine.

Reviewed-by: Jeff Moyer <jmoyer@redhat.com>


> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/powerpc/sysdev/axonram.c | 10 +++++-----
>  drivers/block/brd.c           |  9 +++++----
>  drivers/nvdimm/pmem.c         |  9 +++++----
>  drivers/s390/block/dcssblk.c  | 12 ++++++------
>  fs/block_dev.c                |  2 +-
>  include/linux/blkdev.h        |  3 +--
>  6 files changed, 23 insertions(+), 22 deletions(-)
>
> diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
> index 0d112b9..d85673f 100644
> --- a/arch/powerpc/sysdev/axonram.c
> +++ b/arch/powerpc/sysdev/axonram.c
> @@ -139,17 +139,17 @@ axon_ram_make_request(struct request_queue *queue, struct bio *bio)
>  
>  /**
>   * axon_ram_direct_access - direct_access() method for block device
> - * @device, @sector, @data: see block_device_operations method
> + * @dax: see block_device_operations method
>   */
>  static long
> -axon_ram_direct_access(struct block_device *device, sector_t sector,
> -		       void __pmem **kaddr, pfn_t *pfn)
> +axon_ram_direct_access(struct block_device *device, struct blk_dax_ctl *dax)
>  {
> +	sector_t sector = get_start_sect(device) + dax->sector;
>  	struct axon_ram_bank *bank = device->bd_disk->private_data;
>  	loff_t offset = (loff_t)sector << AXON_RAM_SECTOR_SHIFT;
>  
> -	*kaddr = (void __pmem __force *) bank->io_addr + offset;
> -	*pfn = phys_to_pfn_t(bank->ph_addr + offset, PFN_DEV);
> +	dax->addr = (void __pmem __force *) bank->io_addr + offset;
> +	dax->pfn = phys_to_pfn_t(bank->ph_addr + offset, PFN_DEV);
>  	return bank->size - offset;
>  }
>  
> diff --git a/drivers/block/brd.c b/drivers/block/brd.c
> index f7ecc28..e3e4780 100644
> --- a/drivers/block/brd.c
> +++ b/drivers/block/brd.c
> @@ -380,9 +380,10 @@ static int brd_rw_page(struct block_device *bdev, sector_t sector,
>  }
>  
>  #ifdef CONFIG_BLK_DEV_RAM_DAX
> -static long brd_direct_access(struct block_device *bdev, sector_t sector,
> -			void __pmem **kaddr, pfn_t *pfn)
> +static long brd_direct_access(struct block_device *bdev,
> +		struct blk_dax_ctl *dax)
>  {
> +	sector_t sector = get_start_sect(bdev) + dax->sector;
>  	struct brd_device *brd = bdev->bd_disk->private_data;
>  	struct page *page;
>  
> @@ -391,8 +392,8 @@ static long brd_direct_access(struct block_device *bdev, sector_t sector,
>  	page = brd_insert_page(brd, sector);
>  	if (!page)
>  		return -ENOSPC;
> -	*kaddr = (void __pmem *)page_address(page);
> -	*pfn = page_to_pfn_t(page);
> +	dax->addr = (void __pmem *)page_address(page);
> +	dax->pfn = page_to_pfn_t(page);
>  
>  	return PAGE_SIZE;
>  }
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index ca5721c..da10554 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -167,14 +167,15 @@ static int pmem_rw_page(struct block_device *bdev, sector_t sector,
>  	return rc;
>  }
>  
> -static long pmem_direct_access(struct block_device *bdev, sector_t sector,
> -		      void __pmem **kaddr, pfn_t *pfn)
> +static long pmem_direct_access(struct block_device *bdev,
> +		struct blk_dax_ctl *dax)
>  {
> +	sector_t sector = get_start_sect(bdev) + dax->sector;
>  	struct pmem_device *pmem = bdev->bd_disk->private_data;
>  	resource_size_t offset = sector * 512 + pmem->data_offset;
>  
> -	*kaddr = pmem->virt_addr + offset;
> -	*pfn = phys_to_pfn_t(pmem->phys_addr + offset, pmem->pfn_flags);
> +	dax->addr = pmem->virt_addr + offset;
> +	dax->pfn = phys_to_pfn_t(pmem->phys_addr + offset, pmem->pfn_flags);
>  
>  	return pmem->size - pmem->pfn_pad - offset;
>  }
> diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
> index 1bce9cf..5719c30 100644
> --- a/drivers/s390/block/dcssblk.c
> +++ b/drivers/s390/block/dcssblk.c
> @@ -30,8 +30,8 @@ static int dcssblk_open(struct block_device *bdev, fmode_t mode);
>  static void dcssblk_release(struct gendisk *disk, fmode_t mode);
>  static blk_qc_t dcssblk_make_request(struct request_queue *q,
>  						struct bio *bio);
> -static long dcssblk_direct_access(struct block_device *bdev, sector_t secnum,
> -			 void __pmem **kaddr, pfn_t *pfn);
> +static long dcssblk_direct_access(struct block_device *bdev,
> +		struct blk_dax_ctl *dax)
>  
>  static char dcssblk_segments[DCSSBLK_PARM_LEN] = "\0";
>  
> @@ -882,9 +882,9 @@ fail:
>  }
>  
>  static long
> -dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
> -			void __pmem **kaddr, pfn_t *pfn)
> +dcssblk_direct_access(struct block_device *bdev, struct blk_dax_ctl *dax)
>  {
> +	sector_t secnum = get_start_sect(bdev) + dax->sector;
>  	struct dcssblk_dev_info *dev_info;
>  	unsigned long offset, dev_sz;
>  
> @@ -893,8 +893,8 @@ dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
>  		return -ENODEV;
>  	dev_sz = dev_info->end - dev_info->start;
>  	offset = secnum * 512;
> -	*kaddr = (void __pmem *) (dev_info->start + offset);
> -	*pfn = __pfn_to_pfn_t(PFN_DOWN(dev_info->start + offset), PFN_DEV);
> +	dax->addr = (void __pmem *) (dev_info->start + offset);
> +	dax->pfn = __pfn_to_pfn_t(PFN_DOWN(dev_info->start + offset), PFN_DEV);
>  
>  	return dev_sz - offset;
>  }
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index 3172c4e..c5837fa 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -488,7 +488,7 @@ long bdev_direct_access(struct block_device *bdev, struct blk_dax_ctl *dax)
>  	sector += get_start_sect(bdev);
>  	if (sector % (PAGE_SIZE / 512))
>  		return -EINVAL;
> -	avail = ops->direct_access(bdev, sector, &dax->addr, &dax->pfn);
> +	avail = ops->direct_access(bdev, dax);
>  	if (!avail)
>  		return -ERANGE;
>  	if (avail > 0 && avail & ~PAGE_MASK)
> diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
> index 7e5d7e0..92f8a1f 100644
> --- a/include/linux/blkdev.h
> +++ b/include/linux/blkdev.h
> @@ -1656,8 +1656,7 @@ struct block_device_operations {
>  	int (*rw_page)(struct block_device *, sector_t, struct page *, int rw);
>  	int (*ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
>  	int (*compat_ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
> -	long (*direct_access)(struct block_device *, sector_t, void __pmem **,
> -			pfn_t *);
> +	long (*direct_access)(struct block_device *, struct blk_dax_ctl *dax);
>  	unsigned int (*check_events) (struct gendisk *disk,
>  				      unsigned int clearing);
>  	/* ->media_changed() is DEPRECATED, use ->check_events() instead */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
