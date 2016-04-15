Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F01C6B0253
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 12:11:41 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id f185so61278463vkb.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:11:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c129si19358991qha.114.2016.04.15.09.11.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 09:11:40 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	<1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
Date: Fri, 15 Apr 2016 12:11:36 -0400
In-Reply-To: <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	(Vishal Verma's message of "Tue, 29 Mar 2016 19:59:50 -0600")
Message-ID: <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@ml01.01.org, Jens Axboe <axboe@fb.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-block@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

Vishal Verma <vishal.l.verma@intel.com> writes:

> dax_do_io (called for read() or write() for a dax file system) may fail
> in the presence of bad blocks or media errors. Since we expect that a
> write should clear media errors on nvdimms, make dax_do_io fall back to
> the direct_IO path, which will send down a bio to the driver, which can
> then attempt to clear the error.

[snip]

> +	if (IS_DAX(inode)) {
> +		ret = dax_do_io(iocb, inode, iter, offset, blkdev_get_block,
>  				NULL, DIO_SKIP_DIO_COUNT);
> -	return __blockdev_direct_IO(iocb, inode, I_BDEV(inode), iter, offset,
> +		if (ret == -EIO && (iov_iter_rw(iter) == WRITE))
> +			ret_saved = ret;
> +		else
> +			return ret;
> +	}
> +
> +	ret = __blockdev_direct_IO(iocb, inode, I_BDEV(inode), iter, offset,
>  				    blkdev_get_block, NULL, NULL,
>  				    DIO_SKIP_DIO_COUNT);
> +	if (ret < 0 && ret_saved)
> +		return ret_saved;
> +

Hmm, did you just break async DIO?  I think you did!  :)
__blockdev_direct_IO can return -EIOCBQUEUED, and you've now turned that
into -EIO.  Really, I don't see a reason to save that first -EIO.  The
same applies to all instances in this patch.

Cheers,
Jeff


> +	return ret;
>  }
>  
>  int __sync_blockdev(struct block_device *bdev, int wait)
> diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
> index 824f249..64792c6 100644
> --- a/fs/ext2/inode.c
> +++ b/fs/ext2/inode.c
> @@ -859,14 +859,22 @@ ext2_direct_IO(struct kiocb *iocb, struct iov_iter *iter, loff_t offset)
>  	struct address_space *mapping = file->f_mapping;
>  	struct inode *inode = mapping->host;
>  	size_t count = iov_iter_count(iter);
> -	ssize_t ret;
> +	ssize_t ret, ret_saved = 0;
>  
> -	if (IS_DAX(inode))
> -		ret = dax_do_io(iocb, inode, iter, offset, ext2_get_block, NULL,
> -				DIO_LOCKING);
> -	else
> -		ret = blockdev_direct_IO(iocb, inode, iter, offset,
> -					 ext2_get_block);
> +	if (IS_DAX(inode)) {
> +		ret = dax_do_io(iocb, inode, iter, offset, ext2_get_block,
> +				NULL, DIO_LOCKING | DIO_SKIP_HOLES);
> +		if (ret == -EIO && iov_iter_rw(iter) == WRITE)
> +			ret_saved = ret;
> +		else
> +			goto out;
> +	}
> +
> +	ret = blockdev_direct_IO(iocb, inode, iter, offset, ext2_get_block);
> +	if (ret < 0 && ret_saved)
> +		ret = ret_saved;
> +
> + out:
>  	if (ret < 0 && iov_iter_rw(iter) == WRITE)
>  		ext2_write_failed(mapping, offset + count);
>  	return ret;
> diff --git a/fs/ext4/indirect.c b/fs/ext4/indirect.c
> index 3027fa6..798f341 100644
> --- a/fs/ext4/indirect.c
> +++ b/fs/ext4/indirect.c
> @@ -716,14 +716,22 @@ retry:
>  						   NULL, NULL, 0);
>  		inode_dio_end(inode);
>  	} else {
> +		ssize_t ret_saved = 0;
> +
>  locked:
> -		if (IS_DAX(inode))
> +		if (IS_DAX(inode)) {
>  			ret = dax_do_io(iocb, inode, iter, offset,
>  					ext4_dio_get_block, NULL, DIO_LOCKING);
> -		else
> -			ret = blockdev_direct_IO(iocb, inode, iter, offset,
> -						 ext4_dio_get_block);
> -
> +			if (ret == -EIO && iov_iter_rw(iter) == WRITE)
> +				ret_saved = ret;
> +			else
> +				goto skip_dio;
> +		}
> +		ret = blockdev_direct_IO(iocb, inode, iter, offset,
> +					 ext4_get_block);
> +		if (ret < 0 && ret_saved)
> +			ret = ret_saved;
> +skip_dio:
>  		if (unlikely(iov_iter_rw(iter) == WRITE && ret < 0)) {
>  			loff_t isize = i_size_read(inode);
>  			loff_t end = offset + count;
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index dab84a2..27f07c2 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -3341,7 +3341,7 @@ static ssize_t ext4_ext_direct_IO(struct kiocb *iocb, struct iov_iter *iter,
>  {
>  	struct file *file = iocb->ki_filp;
>  	struct inode *inode = file->f_mapping->host;
> -	ssize_t ret;
> +	ssize_t ret, ret_saved = 0;
>  	size_t count = iov_iter_count(iter);
>  	int overwrite = 0;
>  	get_block_t *get_block_func = NULL;
> @@ -3401,15 +3401,22 @@ static ssize_t ext4_ext_direct_IO(struct kiocb *iocb, struct iov_iter *iter,
>  #ifdef CONFIG_EXT4_FS_ENCRYPTION
>  	BUG_ON(ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode));
>  #endif
> -	if (IS_DAX(inode))
> +	if (IS_DAX(inode)) {
>  		ret = dax_do_io(iocb, inode, iter, offset, get_block_func,
>  				ext4_end_io_dio, dio_flags);
> -	else
> -		ret = __blockdev_direct_IO(iocb, inode,
> -					   inode->i_sb->s_bdev, iter, offset,
> -					   get_block_func,
> -					   ext4_end_io_dio, NULL, dio_flags);
> +		if (ret == -EIO && iov_iter_rw(iter) == WRITE)
> +			ret_saved = ret;
> +		else
> +			goto skip_dio;
> +	}
>  
> +	ret = __blockdev_direct_IO(iocb, inode,
> +				   inode->i_sb->s_bdev, iter, offset,
> +				   get_block_func,
> +				   ext4_end_io_dio, NULL, dio_flags);
> +	if (ret < 0 && ret_saved)
> +		ret = ret_saved;
> + skip_dio:
>  	if (ret > 0 && !overwrite && ext4_test_inode_state(inode,
>  						EXT4_STATE_DIO_UNWRITTEN)) {
>  		int err;
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index d445a64..7cfcf86 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -1413,6 +1413,7 @@ xfs_vm_direct_IO(
>  	dio_iodone_t		*endio = NULL;
>  	int			flags = 0;
>  	struct block_device	*bdev;
> +	ssize_t 		ret, ret_saved = 0;
>  
>  	if (iov_iter_rw(iter) == WRITE) {
>  		endio = xfs_end_io_direct_write;
> @@ -1420,13 +1421,22 @@ xfs_vm_direct_IO(
>  	}
>  
>  	if (IS_DAX(inode)) {
> -		return dax_do_io(iocb, inode, iter, offset,
> +		ret = dax_do_io(iocb, inode, iter, offset,
>  				 xfs_get_blocks_direct, endio, 0);
> +		if (ret == -EIO && iov_iter_rw(iter) == WRITE)
> +			ret_saved = ret;
> +		else
> +			return ret;
>  	}
>  
>  	bdev = xfs_find_bdev_for_inode(inode);
> -	return  __blockdev_direct_IO(iocb, inode, bdev, iter, offset,
> +	ret = __blockdev_direct_IO(iocb, inode, bdev, iter, offset,
>  			xfs_get_blocks_direct, endio, NULL, flags);
> +
> +	if (ret < 0 && ret_saved)
> +		ret = ret_saved;
> +
> +	return ret;
>  }
>  
>  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
