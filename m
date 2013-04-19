Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 454226B0075
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 01:21:53 -0400 (EDT)
Date: Fri, 19 Apr 2013 07:03:11 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 13/18] ext4: use ext4_zero_partial_blocks in
 punch_hole
Message-ID: <20130419050311.GD19244@quack.suse.cz>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
 <1365498867-27782-14-git-send-email-lczerner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365498867-27782-14-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Tue 09-04-13 11:14:22, Lukas Czerner wrote:
> We're doing to get rid of ext4_discard_partial_page_buffers() since it is
> duplicating some code and also partially duplicating work of
> truncate_pagecache_range(), moreover the old implementation was much
> clearer.
> 
> Now when the truncate_inode_pages_range() can handle truncating non page
> aligned regions we can use this to invalidate and zero out block aligned
> region of the punched out range and then use ext4_block_truncate_page()
> to zero the unaligned blocks on the start and end of the range. This
> will greatly simplify the punch hole code. Moreover after this commit we
> can get rid of the ext4_discard_partial_page_buffers() completely.
> 
> We also introduce function ext4_prepare_punch_hole() to do come common
> operations before we attempt to do the actual punch hole on
> indirect or extent file which saves us some code duplication.
> 
> This has been tested on ppc64 with 1k block size with fsx and xfstests
> without any problems.
> 
> Signed-off-by: Lukas Czerner <lczerner@redhat.com>
  Just two nits below, otherwise the patch looks good.

> ---
>  fs/ext4/ext4.h  |    2 +
>  fs/ext4/inode.c |  110 ++++++++++++++++++++-----------------------------------
>  2 files changed, 42 insertions(+), 70 deletions(-)
> 
> diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
> index 3aa5943..2428244 100644
> --- a/fs/ext4/ext4.h
> +++ b/fs/ext4/ext4.h
> @@ -2109,6 +2109,8 @@ extern int ext4_block_truncate_page(handle_t *handle,
>  		struct address_space *mapping, loff_t from);
>  extern int ext4_block_zero_page_range(handle_t *handle,
>  		struct address_space *mapping, loff_t from, loff_t length);
> +extern int ext4_zero_partial_blocks(handle_t *handle, struct inode *inode,
> +			     loff_t lstart, loff_t lend);
>  extern int ext4_discard_partial_page_buffers(handle_t *handle,
>  		struct address_space *mapping, loff_t from,
>  		loff_t length, int flags);
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index d58e13c..6003fd1 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -3675,6 +3675,37 @@ unlock:
>  	return err;
>  }
>  
> +int ext4_zero_partial_blocks(handle_t *handle, struct inode *inode,
> +			     loff_t lstart, loff_t lend)
> +{
  It's a bit confusing that ext4_block_zero_page_range() takes start, len
arguments while this function takes start, end arguments. I think it should
better be unified to avoid stupid mistakes...

> +	struct super_block *sb = inode->i_sb;
> +	struct address_space *mapping = inode->i_mapping;
> +	unsigned partial = lstart & (sb->s_blocksize - 1);
> +	ext4_fsblk_t start = lstart >> sb->s_blocksize_bits;
> +	ext4_fsblk_t end = lend >> sb->s_blocksize_bits;
> +	int err = 0;
> +
> +	/* Handle partial zero within the single block */
> +	if (start == end) {
> +		err = ext4_block_zero_page_range(handle, mapping,
> +						 lstart, lend - lstart + 1);
> +		return err;
> +	}
> +	/* Handle partial zero out on the start of the range */
> +	if (partial) {
> +		err = ext4_block_zero_page_range(handle, mapping,
> +						 lstart, sb->s_blocksize);
> +		if (err)
> +			return err;
> +	}
> +	/* Handle partial zero out on the end of the range */
> +	partial = lend & (sb->s_blocksize - 1);
> +	if (partial != sb->s_blocksize - 1)
> +		err = ext4_block_zero_page_range(handle, mapping,
> +						 lend - partial, partial + 1);
> +	return err;
> +}
> +
>  int ext4_can_truncate(struct inode *inode)
>  {
>  	if (S_ISREG(inode->i_mode))
> @@ -3703,7 +3734,6 @@ int ext4_punch_hole(struct file *file, loff_t offset, loff_t length)
>  	struct super_block *sb = inode->i_sb;
>  	ext4_lblk_t first_block, stop_block;
>  	struct address_space *mapping = inode->i_mapping;
> -	loff_t first_page, last_page, page_len;
>  	loff_t first_page_offset, last_page_offset;
>  	handle_t *handle;
>  	unsigned int credits;
> @@ -3755,17 +3785,13 @@ int ext4_punch_hole(struct file *file, loff_t offset, loff_t length)
>  		   offset;
>  	}
>  
> -	first_page = (offset + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
> -	last_page = (offset + length) >> PAGE_CACHE_SHIFT;
> -
> -	first_page_offset = first_page << PAGE_CACHE_SHIFT;
> -	last_page_offset = last_page << PAGE_CACHE_SHIFT;
> +	first_page_offset = round_up(offset, sb->s_blocksize);
> +	last_page_offset = round_down((offset + length), sb->s_blocksize) - 1;
  Calling these {first,last}_block_offset would be more precise, wouldn't
it?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
