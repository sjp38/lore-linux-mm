Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id 11E706B0031
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 06:28:14 -0400 (EDT)
Received: by mail-bk0-f49.google.com with SMTP id my13so1150622bkb.36
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 03:28:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pw4si7339829bkb.13.2014.03.31.03.28.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 03:28:13 -0700 (PDT)
Date: Sat, 29 Mar 2014 17:30:28 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 04/22] Change direct_access calling convention
Message-ID: <20140329163028.GD1211@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <214af2a38d840d0b8e983d39d03711d1292bc2d6.1395591795.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <214af2a38d840d0b8e983d39d03711d1292bc2d6.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Sun 23-03-14 15:08:30, Matthew Wilcox wrote:
> In order to support accesses to larger chunks of memory, pass in a
> 'size' parameter (counted in bytes), and return the amount available at
> that address.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
  Two minor nits below. Other than that you can add:
Reviewed-by: Jan Kara <jack@suse.cz>

> ---
>  Documentation/filesystems/xip.txt | 15 +++++++++------
>  arch/powerpc/sysdev/axonram.c     |  6 +++---
>  drivers/block/brd.c               |  8 +++++---
>  drivers/s390/block/dcssblk.c      | 19 ++++++++++---------
>  fs/ext2/xip.c                     | 30 +++++++++++++-----------------
>  include/linux/blkdev.h            |  4 ++--
>  6 files changed, 42 insertions(+), 40 deletions(-)
> 
...
> diff --git a/drivers/block/brd.c b/drivers/block/brd.c
> index e73b85c..00da60d 100644
> --- a/drivers/block/brd.c
> +++ b/drivers/block/brd.c
> @@ -361,8 +361,8 @@ out:
>  }
>  
>  #ifdef CONFIG_BLK_DEV_XIP
> -static int brd_direct_access(struct block_device *bdev, sector_t sector,
> -			void **kaddr, unsigned long *pfn)
> +static long brd_direct_access(struct block_device *bdev, sector_t sector,
> +			void **kaddr, unsigned long *pfn, long size)
>  {
>  	struct brd_device *brd = bdev->bd_disk->private_data;
>  	struct page *page;
> @@ -379,7 +379,9 @@ static int brd_direct_access(struct block_device *bdev, sector_t sector,
>  	*kaddr = page_address(page);
>  	*pfn = page_to_pfn(page);
>  
> -	return 0;
> +	/* Could optimistically check to see if the next page in the
> +	 * file is mapped to the next page of physical RAM */
> +	return PAGE_SIZE;
  This should be min_t(long, PAGE_SIZE, size), shouldn't it?

>  }
>  #endif
>  
> diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
> index ebf41e2..da914b2 100644
> --- a/drivers/s390/block/dcssblk.c
> +++ b/drivers/s390/block/dcssblk.c
> @@ -28,8 +28,8 @@
>  static int dcssblk_open(struct block_device *bdev, fmode_t mode);
>  static void dcssblk_release(struct gendisk *disk, fmode_t mode);
>  static void dcssblk_make_request(struct request_queue *q, struct bio *bio);
> -static int dcssblk_direct_access(struct block_device *bdev, sector_t secnum,
> -				 void **kaddr, unsigned long *pfn);
> +static long dcssblk_direct_access(struct block_device *bdev, sector_t secnum,
> +				 void **kaddr, unsigned long *pfn, long size);
>  
>  static char dcssblk_segments[DCSSBLK_PARM_LEN] = "\0";
>  
> @@ -866,25 +866,26 @@ fail:
>  	bio_io_error(bio);
>  }
>  
> -static int
> +static long
>  dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
> -			void **kaddr, unsigned long *pfn)
> +			void **kaddr, unsigned long *pfn, long size)
>  {
>  	struct dcssblk_dev_info *dev_info;
> -	unsigned long pgoff;
> +	unsigned long offset, dev_sz;
>  
>  	dev_info = bdev->bd_disk->private_data;
>  	if (!dev_info)
>  		return -ENODEV;
> +	dev_sz = dev_info->end - dev_info->start;
>  	if (secnum % (PAGE_SIZE/512))
>  		return -EINVAL;
> -	pgoff = secnum / (PAGE_SIZE / 512);
> -	if ((pgoff+1)*PAGE_SIZE-1 > dev_info->end - dev_info->start)
> +	offset = secnum * 512;
> +	if (offset > dev_sz)
>  		return -ERANGE;
> -	*kaddr = (void *) (dev_info->start+pgoff*PAGE_SIZE);
> +	*kaddr = (void *) (dev_info->start + offset);
>  	*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;
>  
> -	return 0;
> +	return min_t(unsigned long, size, dev_sz - offset);
                     ^^^ Why unsigned? Everything seems to be long...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
