Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 18DC56B0253
	for <linux-mm@kvack.org>; Mon,  2 May 2016 11:41:56 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y84so145414327lfc.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 08:41:56 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id s128si21566124wmf.99.2016.05.02.08.41.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 08:41:54 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id n129so112505830wmn.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 08:41:54 -0700 (PDT)
Message-ID: <5727753F.6090104@plexistor.com>
Date: Mon, 02 May 2016 18:41:51 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com> <1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
In-Reply-To: <1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org
Cc: Jens Axboe <axboe@fb.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew@wil.cx>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-block@vger.kernel.org, linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On 04/29/2016 12:16 AM, Vishal Verma wrote:
> All IO in a dax filesystem used to go through dax_do_io, which cannot
> handle media errors, and thus cannot provide a recovery path that can
> send a write through the driver to clear errors.
> 
> Add a new iocb flag for DAX, and set it only for DAX mounts. In the IO
> path for DAX filesystems, use the same direct_IO path for both DAX and
> direct_io iocbs, but use the flags to identify when we are in O_DIRECT
> mode vs non O_DIRECT with DAX, and for O_DIRECT, use the conventional
> direct_IO path instead of DAX.
> 

Really? What are your thinking here?

What about all the current users of O_DIRECT, you have just made them
4 times slower and "less concurrent*" then "buffred io" users. Since
direct_IO path will queue an IO request and all.
(And if it is not so slow then why do we need dax_do_io at all? [Rhetorical])

I hate it that you overload the semantics of a known and expected
O_DIRECT flag, for special pmem quirks. This is an incompatible
and unrelated overload of the semantics of O_DIRECT.

> This allows us a recovery path in the form of opening the file with
> O_DIRECT and writing to it with the usual O_DIRECT semantics (sector
> alignment restrictions).
> 

I understand that you want a sector aligned IO, right? for the
clear of errors. But I hate it that you forced all O_DIRECT IO
to be slow for this.
Can you not make dax_do_io handle media errors? At least for the
parts of the IO that are aligned.
(And your recovery path application above can use only aligned
 IO to make sure)

Please look for another solution. Even a special IOCTL_DAX_CLEAR_ERROR

[*"less concurrent" because of the queuing done in bdev. Note how
  pmem is not even multi-queue, and even if it was it will be much
  slower then DAX because of the code depth and all the locks and task
  switches done in the block layer. In DAX the final memcpy is done directly
  on the user-mode thread]

Thanks
Boaz

> Cc: Matthew Wilcox <matthew@wil.cx>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Jeff Moyer <jmoyer@redhat.com>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jens Axboe <axboe@fb.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>
> ---
>  drivers/block/loop.c |  2 +-
>  fs/block_dev.c       | 17 +++++++++++++----
>  fs/ext2/inode.c      | 16 ++++++++++++----
>  fs/ext4/file.c       |  2 +-
>  fs/ext4/inode.c      | 19 +++++++++++++------
>  fs/xfs/xfs_aops.c    | 20 +++++++++++++-------
>  fs/xfs/xfs_file.c    |  4 ++--
>  include/linux/fs.h   | 15 ++++++++++++---
>  mm/filemap.c         |  4 ++--
>  9 files changed, 69 insertions(+), 30 deletions(-)
> 
> diff --git a/drivers/block/loop.c b/drivers/block/loop.c
> index 80cf8ad..c0a24c3 100644
> --- a/drivers/block/loop.c
> +++ b/drivers/block/loop.c
> @@ -568,7 +568,7 @@ struct switch_request {
>  
>  static inline void loop_update_dio(struct loop_device *lo)
>  {
> -	__loop_update_dio(lo, io_is_direct(lo->lo_backing_file) |
> +	__loop_update_dio(lo, (lo->lo_backing_file->f_flags & O_DIRECT) |
>  			lo->use_dio);
>  }
>  
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index 79defba..97a1f5f 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -167,12 +167,21 @@ blkdev_direct_IO(struct kiocb *iocb, struct iov_iter *iter, loff_t offset)
>  	struct file *file = iocb->ki_filp;
>  	struct inode *inode = bdev_file_inode(file);
>  
> -	if (IS_DAX(inode))
> +	if (iocb_is_direct(iocb))
> +		return __blockdev_direct_IO(iocb, inode, I_BDEV(inode), iter,
> +					    offset, blkdev_get_block, NULL,
> +					    NULL, DIO_SKIP_DIO_COUNT);
> +	else if (iocb_is_dax(iocb))
>  		return dax_do_io(iocb, inode, iter, offset, blkdev_get_block,
>  				NULL, DIO_SKIP_DIO_COUNT);
> -	return __blockdev_direct_IO(iocb, inode, I_BDEV(inode), iter, offset,
> -				    blkdev_get_block, NULL, NULL,
> -				    DIO_SKIP_DIO_COUNT);
> +	else {
> +		/*
> +		 * If we're in the direct_IO path, either the IOCB_DIRECT or
> +		 * IOCB_DAX flags must be set.
> +		 */
> +		WARN_ONCE(1, "Kernel Bug with iocb flags\n");
> +		return -ENXIO;
> +	}
>  }
>  
>  int __sync_blockdev(struct block_device *bdev, int wait)
> diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
> index 35f2b0bf..45f2b51 100644
> --- a/fs/ext2/inode.c
> +++ b/fs/ext2/inode.c
> @@ -861,12 +861,20 @@ ext2_direct_IO(struct kiocb *iocb, struct iov_iter *iter, loff_t offset)
>  	size_t count = iov_iter_count(iter);
>  	ssize_t ret;
>  
> -	if (IS_DAX(inode))
> -		ret = dax_do_io(iocb, inode, iter, offset, ext2_get_block, NULL,
> -				DIO_LOCKING);
> -	else
> +	if (iocb_is_direct(iocb))
>  		ret = blockdev_direct_IO(iocb, inode, iter, offset,
>  					 ext2_get_block);
> +	else if (iocb_is_dax(iocb))
> +		ret = dax_do_io(iocb, inode, iter, offset, ext2_get_block, NULL,
> +				DIO_LOCKING);
> +	else {
> +		/*
> +		 * If we're in the direct_IO path, either the IOCB_DIRECT or
> +		 * IOCB_DAX flags must be set.
> +		 */
> +		WARN_ONCE(1, "Kernel Bug with iocb flags\n");
> +		return -ENXIO;
> +	}
>  	if (ret < 0 && iov_iter_rw(iter) == WRITE)
>  		ext2_write_failed(mapping, offset + count);
>  	return ret;
> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index 2e9aa49..165a0b8 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -94,7 +94,7 @@ ext4_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
>  	struct file *file = iocb->ki_filp;
>  	struct inode *inode = file_inode(iocb->ki_filp);
>  	struct blk_plug plug;
> -	int o_direct = iocb->ki_flags & IOCB_DIRECT;
> +	int o_direct = iocb->ki_flags & (IOCB_DIRECT | IOCB_DAX);
>  	int unaligned_aio = 0;
>  	int overwrite = 0;
>  	ssize_t ret;
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 6d5d5c1..0b6d77a 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -3410,15 +3410,22 @@ static ssize_t ext4_direct_IO_write(struct kiocb *iocb, struct iov_iter *iter,
>  #ifdef CONFIG_EXT4_FS_ENCRYPTION
>  	BUG_ON(ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode));
>  #endif
> -	if (IS_DAX(inode)) {
> -		ret = dax_do_io(iocb, inode, iter, offset, get_block_func,
> -				ext4_end_io_dio, dio_flags);
> -	} else
> +	if (iocb_is_direct(iocb))
>  		ret = __blockdev_direct_IO(iocb, inode,
>  					   inode->i_sb->s_bdev, iter, offset,
>  					   get_block_func,
>  					   ext4_end_io_dio, NULL, dio_flags);
> -
> +	else if (iocb_is_dax(iocb))
> +		ret = dax_do_io(iocb, inode, iter, offset, get_block_func,
> +				ext4_end_io_dio, dio_flags);
> +	else {
> +		/*
> +		 * If we're in the direct_IO path, either the IOCB_DIRECT or
> +		 * IOCB_DAX flags must be set.
> +		 */
> +		WARN_ONCE(1, "Kernel Bug with iocb flags\n");
> +		return -ENXIO;
> +	}
>  	if (ret > 0 && !overwrite && ext4_test_inode_state(inode,
>  						EXT4_STATE_DIO_UNWRITTEN)) {
>  		int err;
> @@ -3503,7 +3510,7 @@ static ssize_t ext4_direct_IO_read(struct kiocb *iocb, struct iov_iter *iter,
>  		else
>  			unlocked = 1;
>  	}
> -	if (IS_DAX(inode)) {
> +	if (iocb_is_dax(iocb)) {
>  		ret = dax_do_io(iocb, inode, iter, offset, ext4_dio_get_block,
>  				NULL, unlocked ? 0 : DIO_LOCKING);
>  	} else {
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index e49b240..8134e99 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -1412,21 +1412,27 @@ xfs_vm_direct_IO(
>  	struct inode		*inode = iocb->ki_filp->f_mapping->host;
>  	dio_iodone_t		*endio = NULL;
>  	int			flags = 0;
> -	struct block_device	*bdev;
> +	struct block_device     *bdev = xfs_find_bdev_for_inode(inode);
>  
>  	if (iov_iter_rw(iter) == WRITE) {
>  		endio = xfs_end_io_direct_write;
>  		flags = DIO_ASYNC_EXTEND;
>  	}
>  
> -	if (IS_DAX(inode)) {
> +	if (iocb_is_direct(iocb))
> +		return  __blockdev_direct_IO(iocb, inode, bdev, iter, offset,
> +				xfs_get_blocks_direct, endio, NULL, flags);
> +	else if (iocb_is_dax(iocb))
>  		return dax_do_io(iocb, inode, iter, offset,
> -				 xfs_get_blocks_direct, endio, 0);
> +				xfs_get_blocks_direct, endio, 0);
> +	else {
> +		/*
> +		 * If we're in the direct_IO path, either the IOCB_DIRECT or
> +		 * IOCB_DAX flags must be set.
> +		 */
> +		WARN_ONCE(1, "Kernel Bug with iocb flags\n");
> +		return -ENXIO;
>  	}
> -
> -	bdev = xfs_find_bdev_for_inode(inode);
> -	return  __blockdev_direct_IO(iocb, inode, bdev, iter, offset,
> -			xfs_get_blocks_direct, endio, NULL, flags);
>  }
>  
>  /*
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index c2946f4..3d5d3c2 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -300,7 +300,7 @@ xfs_file_read_iter(
>  
>  	XFS_STATS_INC(mp, xs_read_calls);
>  
> -	if (unlikely(iocb->ki_flags & IOCB_DIRECT))
> +	if (unlikely(iocb->ki_flags & (IOCB_DIRECT | IOCB_DAX)))
>  		ioflags |= XFS_IO_ISDIRECT;
>  	if (file->f_mode & FMODE_NOCMTIME)
>  		ioflags |= XFS_IO_INVIS;
> @@ -898,7 +898,7 @@ xfs_file_write_iter(
>  	if (XFS_FORCED_SHUTDOWN(ip->i_mount))
>  		return -EIO;
>  
> -	if ((iocb->ki_flags & IOCB_DIRECT) || IS_DAX(inode))
> +	if ((iocb->ki_flags & (IOCB_DIRECT | IOCB_DAX)))
>  		ret = xfs_file_dio_aio_write(iocb, from);
>  	else
>  		ret = xfs_file_buffered_aio_write(iocb, from);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 9f28130..adca1d8 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -322,6 +322,7 @@ struct writeback_control;
>  #define IOCB_APPEND		(1 << 1)
>  #define IOCB_DIRECT		(1 << 2)
>  #define IOCB_HIPRI		(1 << 3)
> +#define IOCB_DAX		(1 << 4)
>  
>  struct kiocb {
>  	struct file		*ki_filp;
> @@ -2930,9 +2931,15 @@ extern int generic_show_options(struct seq_file *m, struct dentry *root);
>  extern void save_mount_options(struct super_block *sb, char *options);
>  extern void replace_mount_options(struct super_block *sb, char *options);
>  
> -static inline bool io_is_direct(struct file *filp)
> +static inline bool iocb_is_dax(struct kiocb *iocb)
>  {
> -	return (filp->f_flags & O_DIRECT) || IS_DAX(filp->f_mapping->host);
> +	return IS_DAX(file_inode(iocb->ki_filp)) &&
> +		(iocb->ki_flags & IOCB_DAX);
> +}
> +
> +static inline bool iocb_is_direct(struct kiocb *iocb)
> +{
> +	return iocb->ki_flags & IOCB_DIRECT;
>  }
>  
>  static inline int iocb_flags(struct file *file)
> @@ -2940,8 +2947,10 @@ static inline int iocb_flags(struct file *file)
>  	int res = 0;
>  	if (file->f_flags & O_APPEND)
>  		res |= IOCB_APPEND;
> -	if (io_is_direct(file))
> +	if (file->f_flags & O_DIRECT)
>  		res |= IOCB_DIRECT;
> +	if (IS_DAX(file_inode(file)))
> +		res |= IOCB_DAX;
>  	return res;
>  }
>  
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 3effd5c..b959acf 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1849,7 +1849,7 @@ generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
>  	if (!count)
>  		goto out; /* skip atime */
>  
> -	if (iocb->ki_flags & IOCB_DIRECT) {
> +	if (iocb->ki_flags & (IOCB_DIRECT | IOCB_DAX)) {
>  		struct address_space *mapping = file->f_mapping;
>  		struct inode *inode = mapping->host;
>  		loff_t size;
> @@ -2719,7 +2719,7 @@ ssize_t __generic_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
>  	if (err)
>  		goto out;
>  
> -	if (iocb->ki_flags & IOCB_DIRECT) {
> +	if (iocb->ki_flags & (IOCB_DIRECT | IOCB_DAX)) {
>  		loff_t pos, endbyte;
>  
>  		written = generic_file_direct_write(iocb, from, iocb->ki_pos);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
