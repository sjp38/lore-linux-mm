Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8868C6B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 14:02:30 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id zy2so180994879pac.1
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 11:02:30 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id sm10si19164509pab.78.2016.04.29.11.02.29
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 11:02:29 -0700 (PDT)
Date: Fri, 29 Apr 2016 12:01:58 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 08/18] ext4: Pre-zero allocated blocks for DAX IO
Message-ID: <20160429180158.GC5888@linux.intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-9-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461015341-20153-9-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Mon, Apr 18, 2016 at 11:35:31PM +0200, Jan Kara wrote:
> Currently ext4 treats DAX IO the same way as direct IO. I.e., it
> allocates unwritten extents before IO is done and converts unwritten
> extents afterwards. However this way DAX IO can race with page fault to
> the same area:
> 
> ext4_ext_direct_IO()				dax_fault()
>   dax_io()
>     get_block() - allocates unwritten extent
>     copy_from_iter_pmem()
> 						  get_block() - converts
> 						    unwritten block to
> 						    written and zeroes it
> 						    out
>   ext4_convert_unwritten_extents()
> 
> So data written with DAX IO gets lost. Similarly dax_new_buf() called
> from dax_io() can overwrite data that has been already written to the
> block via mmap.
> 
> Fix the problem by using pre-zeroed blocks for DAX IO the same way as we
> use them for DAX mmap. The downside of this solution is that every
> allocating write writes each block twice (once zeros, once data). Fixing
> the race with locking is possible as well however we would need to
> lock-out faults for the whole range written to by DAX IO. And that is
> not easy to do without locking-out faults for the whole file which seems
> too aggressive.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Just a couple of simplifications - feel free to ignore them if you don't think
they are worth the effort.

> ---
>  fs/ext4/ext4.h  | 11 +++++++++--
>  fs/ext4/file.c  |  4 ++--
>  fs/ext4/inode.c | 42 +++++++++++++++++++++++++++++++++---------
>  3 files changed, 44 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
> index 35792b430fb6..173da8faff81 100644
> --- a/fs/ext4/ext4.h
> +++ b/fs/ext4/ext4.h
> @@ -2521,8 +2521,8 @@ struct buffer_head *ext4_getblk(handle_t *, struct inode *, ext4_lblk_t, int);
>  struct buffer_head *ext4_bread(handle_t *, struct inode *, ext4_lblk_t, int);
>  int ext4_get_block_unwritten(struct inode *inode, sector_t iblock,
>  			     struct buffer_head *bh_result, int create);
> -int ext4_dax_mmap_get_block(struct inode *inode, sector_t iblock,
> -			    struct buffer_head *bh_result, int create);
> +int ext4_dax_get_block(struct inode *inode, sector_t iblock,
> +		       struct buffer_head *bh_result, int create);
>  int ext4_get_block(struct inode *inode, sector_t iblock,
>  		   struct buffer_head *bh_result, int create);
>  int ext4_dio_get_block(struct inode *inode, sector_t iblock,
> @@ -3328,6 +3328,13 @@ static inline void ext4_clear_io_unwritten_flag(ext4_io_end_t *io_end)
>  	}
>  }
>  
> +static inline bool ext4_aligned_io(struct inode *inode, loff_t off, loff_t len)
> +{
> +	int blksize = 1 << inode->i_blkbits;
> +
> +	return IS_ALIGNED(off, blksize) && IS_ALIGNED(off + len, blksize);

This could be just a tiny bit simpler by doing

	return IS_ALIGNED(off, blksize) && IS_ALIGNED(len, blksize);
						      ^^^

You've already made sure 'off' is aligned, so if 'len' is aligned 'off+len'
will be aligned.

> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 23fd0e0a9223..6d5d5c1db293 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -3215,12 +3215,17 @@ static int ext4_releasepage(struct page *page, gfp_t wait)
>  }
>  
>  #ifdef CONFIG_FS_DAX
> -int ext4_dax_mmap_get_block(struct inode *inode, sector_t iblock,
> -			    struct buffer_head *bh_result, int create)
> +/*
> + * Get block function for DAX IO and mmap faults. It takes care of converting
> + * unwritten extents to written ones and initializes new / converted blocks
> + * to zeros.
> + */
> +int ext4_dax_get_block(struct inode *inode, sector_t iblock,
> +		       struct buffer_head *bh_result, int create)
>  {
>  	int ret;
>  
> -	ext4_debug("ext4_dax_mmap_get_block: inode %lu, create flag %d\n",
> +	ext4_debug("ext4_dax_get_block: inode %lu, create flag %d\n",
>  		   inode->i_ino, create);

This pattern could be improved by using "%s" and __func__ for the function
name.  That way you don't have to hunt through all your debug code and update
strings when you rename a function. More importantly it prevents the strings
from getting out of sync with the function name, resulting in confusing debug
messages.

>  	if (!create)
>  		return _ext4_get_block(inode, iblock, bh_result, 0);
> @@ -3233,9 +3238,9 @@ int ext4_dax_mmap_get_block(struct inode *inode, sector_t iblock,
>  
>  	if (buffer_unwritten(bh_result)) {
>  		/*
> -		 * We are protected by i_mmap_sem so we know block cannot go
> -		 * away from under us even though we dropped i_data_sem.
> -		 * Convert extent to written and write zeros there.
> +		 * We are protected by i_mmap_sem or i_mutex so we know block
> +		 * cannot go away from under us even though we dropped
> +		 * i_data_sem. Convert extent to written and write zeros there.
>  		 */
>  		ret = ext4_get_block_trans(inode, iblock, bh_result,
>  					   EXT4_GET_BLOCKS_CONVERT |
> @@ -3250,6 +3255,14 @@ int ext4_dax_mmap_get_block(struct inode *inode, sector_t iblock,
>  	clear_buffer_new(bh_result);
>  	return 0;
>  }
> +#else
> +/* Just define empty function, it will never get called. */
> +int ext4_dax_get_block(struct inode *inode, sector_t iblock,
> +		       struct buffer_head *bh_result, int create)
> +{
> +	BUG();
> +	return 0;
> +}

You don't need this stub.  All the uses of ext4_dax_get_block() are either
within their own '#ifdef CONFIG_FS_DAX' sections, or they are in an 
"if (IS_DAX)" conditional.  The latter will also be compiled out if
CONFIG_FS_DAX isn't defined.  This is because of the way that S_DAX is
defined:

  #define S_DAX		8192	/* Direct Access, avoiding the page cache */
  #else
  #define S_DAX		0	/* Make all the DAX code disappear */
  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
