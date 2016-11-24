Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 355076B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 04:02:46 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m203so12878004wma.2
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 01:02:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sc5si35759532wjb.155.2016.11.24.01.02.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Nov 2016 01:02:44 -0800 (PST)
Date: Thu, 24 Nov 2016 10:02:39 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/6] dax: fix build breakage with ext4, dax and !iomap
Message-ID: <20161124090239.GA24138@quack2.suse.cz>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-2-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479926662-21718-2-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Wed 23-11-16 11:44:17, Ross Zwisler wrote:
> With the current Kconfig setup it is possible to have the following:
> 
> CONFIG_EXT4_FS=y
> CONFIG_FS_DAX=y
> CONFIG_FS_IOMAP=n	# this is in fs/Kconfig & isn't user accessible
> 
> With this config we get build failures in ext4_dax_fault() because the
> iomap functions in fs/dax.c are missing:
> 
> fs/built-in.o: In function `ext4_dax_fault':
> file.c:(.text+0x7f3ac): undefined reference to `dax_iomap_fault'
> file.c:(.text+0x7f404): undefined reference to `dax_iomap_fault'
> fs/built-in.o: In function `ext4_file_read_iter':
> file.c:(.text+0x7fc54): undefined reference to `dax_iomap_rw'
> fs/built-in.o: In function `ext4_file_write_iter':
> file.c:(.text+0x7fe9a): undefined reference to `dax_iomap_rw'
> file.c:(.text+0x7feed): undefined reference to `dax_iomap_rw'
> fs/built-in.o: In function `ext4_block_zero_page_range':
> inode.c:(.text+0x85c0d): undefined reference to `iomap_zero_range'
> 
> Now that the struct buffer_head based DAX fault paths and I/O path have
> been removed we really depend on iomap support being present for DAX.  Make
> this explicit by selecting FS_IOMAP if we compile in DAX support.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

I've sent the same patch to Ted yesterday and he will probably queue it on
top of ext4 iomap patches. If it doesn't happen for some reason, feel free
to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/Kconfig      | 1 +
>  fs/dax.c        | 2 --
>  fs/ext2/Kconfig | 1 -
>  3 files changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 8e9e5f41..18024bf 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -38,6 +38,7 @@ config FS_DAX
>  	bool "Direct Access (DAX) support"
>  	depends on MMU
>  	depends on !(ARM || MIPS || SPARC)
> +	select FS_IOMAP
>  	help
>  	  Direct Access (DAX) can be used on memory-backed block devices.
>  	  If the block device supports DAX and the filesystem supports DAX,
> diff --git a/fs/dax.c b/fs/dax.c
> index be39633..d8fe3eb 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -968,7 +968,6 @@ int __dax_zero_page_range(struct block_device *bdev, sector_t sector,
>  }
>  EXPORT_SYMBOL_GPL(__dax_zero_page_range);
>  
> -#ifdef CONFIG_FS_IOMAP
>  static sector_t dax_iomap_sector(struct iomap *iomap, loff_t pos)
>  {
>  	return iomap->blkno + (((pos & PAGE_MASK) - iomap->offset) >> 9);
> @@ -1405,4 +1404,3 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>  }
>  EXPORT_SYMBOL_GPL(dax_iomap_pmd_fault);
>  #endif /* CONFIG_FS_DAX_PMD */
> -#endif /* CONFIG_FS_IOMAP */
> diff --git a/fs/ext2/Kconfig b/fs/ext2/Kconfig
> index 36bea5a..c634874e 100644
> --- a/fs/ext2/Kconfig
> +++ b/fs/ext2/Kconfig
> @@ -1,6 +1,5 @@
>  config EXT2_FS
>  	tristate "Second extended fs support"
> -	select FS_IOMAP if FS_DAX
>  	help
>  	  Ext2 is a standard Linux file system for hard disks.
>  
> -- 
> 2.7.4
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
