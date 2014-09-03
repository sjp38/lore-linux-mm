Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 138B96B0036
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 05:22:03 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id r10so10748165pdi.29
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 02:22:02 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id ln4si9950454pab.151.2014.09.03.02.21.39
        for <linux-mm@kvack.org>;
        Wed, 03 Sep 2014 02:21:41 -0700 (PDT)
Date: Wed, 3 Sep 2014 19:21:16 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 19/21] xip: Add xip_zero_page_range
Message-ID: <20140903092116.GF20473@dastard>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
 <80c8efc903971eb3a338f262fbd3ef135db63eb0.1409110741.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <80c8efc903971eb3a338f262fbd3ef135db63eb0.1409110741.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Aug 26, 2014 at 11:45:39PM -0400, Matthew Wilcox wrote:
> This new function allows us to support hole-punch for XIP files by zeroing
> a partial page, as opposed to the xip_truncate_page() function which can
> only truncate to the end of the page.  Reimplement xip_truncate_page() as
> a macro that calls xip_zero_page_range().
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> [ported to 3.13-rc2]
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  Documentation/filesystems/dax.txt |  1 +
>  fs/dax.c                          | 20 ++++++++++++++------
>  include/linux/fs.h                |  9 ++++++++-
>  3 files changed, 23 insertions(+), 7 deletions(-)
> 
> diff --git a/Documentation/filesystems/dax.txt b/Documentation/filesystems/dax.txt
> index 635adaa..ebcd97f 100644
> --- a/Documentation/filesystems/dax.txt
> +++ b/Documentation/filesystems/dax.txt
> @@ -62,6 +62,7 @@ Filesystem support consists of
>    for fault and page_mkwrite (which should probably call dax_fault() and
>    dax_mkwrite(), passing the appropriate get_block() callback)
>  - calling dax_truncate_page() instead of block_truncate_page() for DAX files
> +- calling dax_zero_page_range() instead of zero_user() for DAX files
>  - ensuring that there is sufficient locking between reads, writes,
>    truncates and page faults
>  
> diff --git a/fs/dax.c b/fs/dax.c
> index d54f7d3..96c4fed 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -445,13 +445,16 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  EXPORT_SYMBOL_GPL(dax_fault);
>  
>  /**
> - * dax_truncate_page - handle a partial page being truncated in a DAX file
> + * dax_zero_page_range - zero a range within a page of a DAX file
>   * @inode: The file being truncated
>   * @from: The file offset that is being truncated to
> + * @length: The number of bytes to zero
>   * @get_block: The filesystem method used to translate file offsets to blocks
>   *
> - * Similar to block_truncate_page(), this function can be called by a
> - * filesystem when it is truncating an DAX file to handle the partial page.
> + * This function can be called by a filesystem when it is zeroing part of a
> + * page in a DAX file.  This is intended for hole-punch operations.  If
> + * you are truncating a file, the helper function dax_truncate_page() may be
> + * more convenient.
>   *
>   * We work in terms of PAGE_CACHE_SIZE here for commonality with
>   * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
> @@ -459,12 +462,12 @@ EXPORT_SYMBOL_GPL(dax_fault);
>   * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
>   * since the file might be mmaped.
>   */
> -int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
> +int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
> +							get_block_t get_block)
>  {
>  	struct buffer_head bh;
>  	pgoff_t index = from >> PAGE_CACHE_SHIFT;
>  	unsigned offset = from & (PAGE_CACHE_SIZE-1);
> -	unsigned length = PAGE_CACHE_ALIGN(from) - from;
>  	int err;
>  
>  	/* Block boundary? Nothing to do */
> @@ -481,9 +484,14 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
>  		err = dax_get_addr(&bh, &addr, inode->i_blkbits);
>  		if (err < 0)
>  			return err;
> +		/*
> +		 * ext4 sometimes asks to zero past the end of a block.  It
> +		 * really just wants to zero to the end of the block.
> +		 */
> +		length = min_t(unsigned, length, PAGE_CACHE_SIZE - offset);
>  		memset(addr + offset, 0, length);

Sorry, what?

You introduce that bug with the way dax_truncate_page() is redefined
to always pass PAGE_CACHE_SIZE a a length later on in this patch.
into the function. That's hardly an ext4 bug....

>  	}
>  
>  	return 0;
>  }
> -EXPORT_SYMBOL_GPL(dax_truncate_page);
> +EXPORT_SYMBOL_GPL(dax_zero_page_range);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index e6b48cc..b0078df 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2490,6 +2490,7 @@ extern int nonseekable_open(struct inode * inode, struct file * filp);
>  
>  #ifdef CONFIG_FS_DAX
>  int dax_clear_blocks(struct inode *, sector_t block, long size);
> +int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
>  int dax_truncate_page(struct inode *, loff_t from, get_block_t);

It's still defined as a function that doesn't exist now....

>  ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, struct iov_iter *,
>  		loff_t, get_block_t, dio_iodone_t, int flags);
> @@ -2501,7 +2502,8 @@ static inline int dax_clear_blocks(struct inode *i, sector_t blk, long sz)
>  	return 0;
>  }
>  
> -static inline int dax_truncate_page(struct inode *i, loff_t frm, get_block_t gb)
> +static inline int dax_zero_page_range(struct inode *inode, loff_t from,
> +						unsigned len, get_block_t gb)
>  {
>  	return 0;
>  }
> @@ -2514,6 +2516,11 @@ static inline ssize_t dax_do_io(int rw, struct kiocb *iocb,
>  }
>  #endif
>  
> +/* Can't be a function because PAGE_CACHE_SIZE is defined in pagemap.h */
> +#define dax_truncate_page(inode, from, get_block)	\
> +	dax_zero_page_range(inode, from, PAGE_CACHE_SIZE, get_block)

And then redefined as a macro here. This is wrong, IMO,
dax_truncate_page() should remain as a function and it should
correctly calculate how much of the page shoul dbe trimmed, not
leave landmines that other code has to clean up...

(Yup, I'm tracking down a truncate bug in XFS from fsx...)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
