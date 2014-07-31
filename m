Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 748946B003A
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 06:17:00 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id x48so2547247wes.33
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 03:16:59 -0700 (PDT)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id 20si10297790wjr.70.2014.07.31.03.16.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 31 Jul 2014 03:16:58 -0700 (PDT)
Received: by mail-wg0-f45.google.com with SMTP id x12so2551514wgg.16
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 03:16:58 -0700 (PDT)
Message-ID: <53DA1796.4040105@gmail.com>
Date: Thu, 31 Jul 2014 13:16:54 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 04/22] Change direct_access calling convention
References: <cover.1406058387.git.matthew.r.wilcox@intel.com> <b78b33d94b669a5fbd02e06f2493b43dd5d77698.1406058387.git.matthew.r.wilcox@intel.com> <53D9174C.7040906@gmail.com> <53D9197C.2050000@gmail.com> <20140730203435.GR6754@linux.intel.com>
In-Reply-To: <20140730203435.GR6754@linux.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/30/2014 11:34 PM, Matthew Wilcox wrote:
> On Wed, Jul 30, 2014 at 07:12:44PM +0300, Boaz Harrosh wrote:
>> Off course I was wrong here size is in bytes not in sectors. Which points
>> out that maybe this API needs to be in sectors.
>>
>> [Actually it needs to be in pages both size and offset, because of return of
>> pfn, but its your call.]
> 
> I considered a number of options here.  The VM wants things to be in pages.
> The filesystem wants things to be in block size.  The block device wants
> things to be in sectors.  It's all a mess when you try and converge.
> Everybody understands bytes.
> 
> Here's what I've come up with on top of patch 4/22.  Let me know what
> you think.
> 
> 
> diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
> index 3ee1c08..741293f 100644
> --- a/arch/powerpc/sysdev/axonram.c
> +++ b/arch/powerpc/sysdev/axonram.c
> @@ -146,11 +146,6 @@ axon_ram_direct_access(struct block_device *device, sector_t sector,
>  	struct axon_ram_bank *bank = device->bd_disk->private_data;
>  	loff_t offset = (loff_t)sector << AXON_RAM_SECTOR_SHIFT;
>  
> -	if (offset >= bank->size) {
> -		dev_err(&bank->device->dev, "Access outside of address space\n");
> -		return -ERANGE;
> -	}
> -
>  	*kaddr = (void *)(bank->ph_addr + offset);
>  	*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;
>  
> diff --git a/drivers/block/brd.c b/drivers/block/brd.c
> index 33a39e7..3483458 100644
> --- a/drivers/block/brd.c
> +++ b/drivers/block/brd.c
> @@ -378,10 +378,6 @@ static long brd_direct_access(struct block_device *bdev, sector_t sector,
>  
>  	if (!brd)
>  		return -ENODEV;
> -	if (sector & (PAGE_SECTORS-1))
> -		return -EINVAL;
> -	if (sector + PAGE_SECTORS > get_capacity(bdev->bd_disk))
> -		return -ERANGE;
>  	page = brd_insert_page(brd, sector);
>  	if (!page)
>  		return -ENOSPC;
> diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
> index 58958d1..2ee5556 100644
> --- a/drivers/s390/block/dcssblk.c
> +++ b/drivers/s390/block/dcssblk.c
> @@ -877,11 +877,7 @@ dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
>  	if (!dev_info)
>  		return -ENODEV;
>  	dev_sz = dev_info->end - dev_info->start;
> -	if (secnum % (PAGE_SIZE/512))
> -		return -EINVAL;
>  	offset = secnum * 512;
> -	if (offset > dev_sz)
> -		return -ERANGE;
>  	*kaddr = (void *) (dev_info->start + offset);
>  	*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;
>  
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index f1a158e..93ebdd53 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -450,8 +450,14 @@ long bdev_direct_access(struct block_device *bdev, sector_t sector,
>  	const struct block_device_operations *ops = bdev->bd_disk->fops;
>  	if (!ops->direct_access)
>  		return -EOPNOTSUPP;
> -	return ops->direct_access(bdev, sector + get_start_sect(bdev), addr,
> -					pfn, size);
> +	if ((sector + DIV_ROUND_UP(size, 512)) >
> +					part_nr_sects_read(bdev->bd_part))
> +		return -ERANGE;
> +	sector += get_start_sect(bdev);
> +	if (sector % (PAGE_SIZE / 512))
> +		return -EINVAL;
> +	size = ops->direct_access(bdev, sector, addr, pfn, size);
> +	return size ? size : -ERANGE;
>  }
>  EXPORT_SYMBOL_GPL(bdev_direct_access);
>  
> 

Very nice yes.

Only the check at ext2 I think is missing. Once you send the complete patch
I'll review it again. It would be very helpful if you send this patch a head
of Q, even for 3.17. It will help with merging later I think

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
