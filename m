Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id C263E6B0038
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 09:00:41 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id gm9so2841291lab.13
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 06:00:41 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id e3si11811963lam.28.2014.10.16.06.00.39
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 06:00:39 -0700 (PDT)
Date: Thu, 16 Oct 2014 15:00:16 +0200
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v11 21/21] brd: Rename XIP to DAX
Message-ID: <20141016130016.GS19075@thinkos.etherlink>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-22-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411677218-29146-22-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>

On 25-Sep-2014 04:33:38 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
> 
> Since this is relating to FS_XIP, not KERNEL_XIP, it should be called
> DAX instead of XIP.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> ---
>  drivers/block/Kconfig | 13 +++++++------
>  drivers/block/brd.c   | 14 +++++++-------
>  fs/Kconfig            |  4 ++--
>  3 files changed, 16 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
> index 014a1cf..1b8094d 100644
> --- a/drivers/block/Kconfig
> +++ b/drivers/block/Kconfig
> @@ -393,14 +393,15 @@ config BLK_DEV_RAM_SIZE
>  	  The default value is 4096 kilobytes. Only change this if you know
>  	  what you are doing.
>  
> -config BLK_DEV_XIP
> -	bool "Support XIP filesystems on RAM block device"
> -	depends on BLK_DEV_RAM
> +config BLK_DEV_RAM_DAX
> +	bool "Support Direct Access (DAX) to RAM block devices"
> +	depends on BLK_DEV_RAM && FS_DAX
>  	default n
>  	help
> -	  Support XIP filesystems (such as ext2 with XIP support on) on
> -	  top of block ram device. This will slightly enlarge the kernel, and
> -	  will prevent RAM block device backing store memory from being
> +	  Support filesystems using DAX to access RAM block devices.  This
> +	  avoids double-buffering data in the page cache before copying it
> +	  to the block device.  Answering Y will slightly enlarge the kernel,
> +	  and will prevent RAM block device backing store memory from being
>  	  allocated from highmem (only a problem for highmem systems).
>  
>  config CDROM_PKTCDVD
> diff --git a/drivers/block/brd.c b/drivers/block/brd.c
> index 78fe510..97c55db 100644
> --- a/drivers/block/brd.c
> +++ b/drivers/block/brd.c
> @@ -97,13 +97,13 @@ static struct page *brd_insert_page(struct brd_device *brd, sector_t sector)
>  	 * Must use NOIO because we don't want to recurse back into the
>  	 * block or filesystem layers from page reclaim.
>  	 *
> -	 * Cannot support XIP and highmem, because our ->direct_access
> -	 * routine for XIP must return memory that is always addressable.
> -	 * If XIP was reworked to use pfns and kmap throughout, this
> +	 * Cannot support DAX and highmem, because our ->direct_access
> +	 * routine for DAX must return memory that is always addressable.
> +	 * If DAX was reworked to use pfns and kmap throughout, this

So this might be an important limitation on x86-32 with PAE, am I
correct ? It should be eventually investigated if anyone still care, but
it does not appear to be a roadblocking limitation.

Thanks,

Mathieu

>  	 * restriction might be able to be lifted.
>  	 */
>  	gfp_flags = GFP_NOIO | __GFP_ZERO;
> -#ifndef CONFIG_BLK_DEV_XIP
> +#ifndef CONFIG_BLK_DEV_RAM_DAX
>  	gfp_flags |= __GFP_HIGHMEM;
>  #endif
>  	page = alloc_page(gfp_flags);
> @@ -369,7 +369,7 @@ static int brd_rw_page(struct block_device *bdev, sector_t sector,
>  	return err;
>  }
>  
> -#ifdef CONFIG_BLK_DEV_XIP
> +#ifdef CONFIG_BLK_DEV_RAM_DAX
>  static long brd_direct_access(struct block_device *bdev, sector_t sector,
>  			void **kaddr, unsigned long *pfn, long size)
>  {
> @@ -388,6 +388,8 @@ static long brd_direct_access(struct block_device *bdev, sector_t sector,
>  	 * file happens to be mapped to the next page of physical RAM */
>  	return PAGE_SIZE;
>  }
> +#else
> +#define brd_direct_access NULL
>  #endif
>  
>  static int brd_ioctl(struct block_device *bdev, fmode_t mode,
> @@ -428,9 +430,7 @@ static const struct block_device_operations brd_fops = {
>  	.owner =		THIS_MODULE,
>  	.rw_page =		brd_rw_page,
>  	.ioctl =		brd_ioctl,
> -#ifdef CONFIG_BLK_DEV_XIP
>  	.direct_access =	brd_direct_access,
> -#endif
>  };
>  
>  /*
> diff --git a/fs/Kconfig b/fs/Kconfig
> index a9eb53d..117900f 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -34,7 +34,7 @@ source "fs/btrfs/Kconfig"
>  source "fs/nilfs2/Kconfig"
>  
>  config FS_DAX
> -	bool "Direct Access support"
> +	bool "Direct Access (DAX) support"
>  	depends on MMU
>  	help
>  	  Direct Access (DAX) can be used on memory-backed block devices.
> @@ -45,7 +45,7 @@ config FS_DAX
>  
>  	  If you do not have a block device that is capable of using this,
>  	  or if unsure, say N.  Saying Y will increase the size of the kernel
> -	  by about 2kB.
> +	  by about 5kB.
>  
>  endif # BLOCK
>  
> -- 
> 2.1.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com
Key fingerprint: 2A0B 4ED9 15F2 D3FA 45F5  B162 1728 0A97 8118 6ACF

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
