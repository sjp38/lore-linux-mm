Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2810E6B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 13:56:05 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id d49so977149eek.13
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 10:56:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5si3814967een.23.2014.04.08.10.56.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 10:56:03 -0700 (PDT)
Date: Tue, 8 Apr 2014 19:56:00 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 06/22] Replace XIP read and write with DAX I/O
Message-ID: <20140408175600.GE2713@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <3ebe329d8713f7db4c105021a845316a47a29797.1395591795.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3ebe329d8713f7db4c105021a845316a47a29797.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Sun 23-03-14 15:08:32, Matthew Wilcox wrote:
> Use the generic AIO infrastructure instead of custom read and write
> methods.  In addition to giving us support for AIO, this adds the missing
> locking between read() and truncate().
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
  In general this looks fine but I have some comments below.

> ---
>  fs/Makefile        |   1 +
>  fs/dax.c           | 216 +++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/ext2/file.c     |   6 +-
>  fs/ext2/inode.c    |   7 +-
>  include/linux/fs.h |  18 ++++-
>  mm/filemap.c       |   6 +-
>  mm/filemap_xip.c   | 234 -----------------------------------------------------
>  7 files changed, 243 insertions(+), 245 deletions(-)
>  create mode 100644 fs/dax.c
> 
> diff --git a/fs/Makefile b/fs/Makefile
> index 47ac07b..2f194cd 100644
> --- a/fs/Makefile
> +++ b/fs/Makefile
> @@ -29,6 +29,7 @@ obj-$(CONFIG_SIGNALFD)		+= signalfd.o
>  obj-$(CONFIG_TIMERFD)		+= timerfd.o
>  obj-$(CONFIG_EVENTFD)		+= eventfd.o
>  obj-$(CONFIG_AIO)               += aio.o
> +obj-$(CONFIG_FS_XIP)		+= dax.o
>  obj-$(CONFIG_FILE_LOCKING)      += locks.o
>  obj-$(CONFIG_COMPAT)		+= compat.o compat_ioctl.o
>  obj-$(CONFIG_BINFMT_AOUT)	+= binfmt_aout.o
> diff --git a/fs/dax.c b/fs/dax.c
> new file mode 100644
> index 0000000..66a6bda
> --- /dev/null
> +++ b/fs/dax.c
> @@ -0,0 +1,216 @@
> +/*
> + * fs/dax.c - Direct Access filesystem code
> + * Copyright (c) 2013-2014 Intel Corporation
> + * Author: Matthew Wilcox <matthew.r.wilcox@intel.com>
> + * Author: Ross Zwisler <ross.zwisler@linux.intel.com>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + */
> +
> +#include <linux/atomic.h>
> +#include <linux/blkdev.h>
> +#include <linux/buffer_head.h>
> +#include <linux/fs.h>
> +#include <linux/genhd.h>
> +#include <linux/mutex.h>
> +#include <linux/uio.h>
> +
> +static long dax_get_addr(struct inode *inode, struct buffer_head *bh,
> +								void **addr)
> +{
> +	struct block_device *bdev = bh->b_bdev;
> +	const struct block_device_operations *ops = bdev->bd_disk->fops;
> +	unsigned long pfn;
> +	sector_t sector = bh->b_blocknr << (inode->i_blkbits - 9);
> +	return ops->direct_access(bdev, sector, addr, &pfn, bh->b_size);
> +}
> +
> +static void dax_new_buf(void *addr, unsigned size, unsigned first,
> +					loff_t offset, loff_t end, int rw)
> +{
> +	loff_t final = end - offset + first; /* The final byte of the buffer */
> +	if (rw != WRITE) {
> +		memset(addr, 0, size);
> +		return;
> +	}
  It seems counterintuitive to zero out "on-disk" blocks (it seems you'd do
this for unwritten blocks) when reading from them. Presumably it could also
have undesired effects on endurance of persistent memory. Instead I'd expect
that you simply zero out user provided buffer the same way as you do it for
holes.

> +
> +	if (first > 0)
> +		memset(addr, 0, first);
> +	if (final < size)
> +		memset(addr + final, 0, size - final);
> +}
> +
> +static bool buffer_written(struct buffer_head *bh)
> +{
> +	return buffer_mapped(bh) && !buffer_unwritten(bh);
> +}
> +
> +/*
> + * When ext4 encounters a hole, it likes to return without modifying the
> + * buffer_head which means that we can't trust b_size.  To cope with this,
> + * we set b_state to 0 before calling get_block and, if any bit is set, we
> + * know we can trust b_size.  Unfortunate, really, since ext4 does know
> + * precisely how long a hole is and would save us time calling get_block
> + * repeatedly.
  Well, this is really a problem of get_blocks() returning the result in
struct buffer_head which is used for input as well. I don't think it is
actually ext4 specific.

> + */
> +static bool buffer_size_valid(struct buffer_head *bh)
> +{
> +	return bh->b_state != 0;
> +}
> +
> +static ssize_t dax_io(int rw, struct inode *inode, const struct iovec *iov,
> +			loff_t start, loff_t end, get_block_t get_block,
> +			struct buffer_head *bh)
> +{
> +	ssize_t retval = 0;
> +	unsigned seg = 0;
> +	unsigned len;
> +	unsigned copied = 0;
> +	loff_t offset = start;
> +	loff_t max = start;
> +	loff_t bh_max = start;
> +	void *addr;
> +	bool hole = false;
> +
> +	if (rw != WRITE)
> +		end = min(end, i_size_read(inode));
> +
> +	while (offset < end) {
> +		void __user *buf = iov[seg].iov_base + copied;
> +
> +		if (offset == max) {
> +			sector_t block = offset >> inode->i_blkbits;
> +			unsigned first = offset - (block << inode->i_blkbits);
> +			long size;
> +
> +			if (offset == bh_max) {
> +				bh->b_size = PAGE_ALIGN(end - offset);
> +				bh->b_state = 0;
> +				retval = get_block(inode, block, bh,
> +								rw == WRITE);
> +				if (retval)
> +					break;
> +				if (!buffer_size_valid(bh))
> +					bh->b_size = 1 << inode->i_blkbits;
> +				bh_max = offset - first + bh->b_size;
> +			} else {
> +				unsigned done = bh->b_size - (bh_max -
> +							(offset - first));
> +				bh->b_blocknr += done >> inode->i_blkbits;
> +				bh->b_size -= done;
  It took me quite some time to figure out what this does and whether it is
correct :). Why isn't this at the place where we advance all other
iterators like offset, addr, etc.?

> +			}
> +			if (rw == WRITE) {
> +				if (!buffer_mapped(bh)) {
> +					retval = -EIO;
> +					break;
  -EIO looks like a wrong error here. Or maybe it is the right one and it
only needs some explanation? The thing is that for direct IO some
filesystems choose not to fill holes for direct IO and fall back to
buffered IO instead (to avoid exposure of uninitialized blocks if the
system crashes after blocks have been added to a file but before they were
written out). For DAX you are pretty much free to define what you ask from
the get_blocks() (and this fallback behavior is somewhat disputed behavior
in direct IO case so you might want to differ here) but you should document
it somewhere.

> +				}
> +				hole = false;
> +			} else {
> +				hole = !buffer_written(bh);
> +			}
> +
> +			if (hole) {
> +				addr = NULL;
> +				size = bh->b_size - first;
> +			} else {
> +				retval = dax_get_addr(inode, bh, &addr);
> +				if (retval < 0)
> +					break;
> +				if (buffer_unwritten(bh) || buffer_new(bh))
> +					dax_new_buf(addr, retval, first,
> +						   offset, end, rw);
> +				addr += first;
> +				size = retval - first;
> +			}
> +			max = min(offset + size, end);
> +		}
> +
> +		len = min_t(unsigned, iov[seg].iov_len - copied, max - offset);
> +
> +		if (rw == WRITE)
> +			len -= __copy_from_user_nocache(addr, buf, len);
> +		else if (!hole)
> +			len -= __copy_to_user(buf, addr, len);
> +		else
> +			len -= __clear_user(buf, len);
> +
> +		if (!len)
> +			break;
> +
> +		offset += len;
> +		copied += len;
> +		addr += len;
> +		if (copied == iov[seg].iov_len) {
> +			seg++;
> +			copied = 0;
> +		}
> +	}
> +
> +	return (offset == start) ? retval : offset - start;
> +}
> +
> +/**
> + * dax_do_io - Perform I/O to a DAX file
> + * @rw: READ to read or WRITE to write
> + * @iocb: The control block for this I/O
> + * @inode: The file which the I/O is directed at
> + * @iov: The user addresses to do I/O from or to
> + * @offset: The file offset where the I/O starts
> + * @nr_segs: The length of the iov array
> + * @get_block: The filesystem method used to translate file offsets to blocks
> + * @end_io: A filesystem callback for I/O completion
> + * @flags: See below
> + *
> + * This function uses the same locking scheme as do_blockdev_direct_IO:
> + * If @flags has DIO_LOCKING set, we assume that the i_mutex is held by the
> + * caller for writes.  For reads, we take and release the i_mutex ourselves.
> + * If DIO_LOCKING is not set, the filesystem takes care of its own locking.
> + * As with do_blockdev_direct_IO(), we increment i_dio_count while the I/O
> + * is in progress.
> + */
> +ssize_t dax_do_io(int rw, struct kiocb *iocb, struct inode *inode,
> +		const struct iovec *iov, loff_t offset, unsigned nr_segs,
> +		get_block_t get_block, dio_iodone_t end_io, int flags)
> +{
> +	struct buffer_head bh;
> +	unsigned seg;
> +	ssize_t retval = -EINVAL;
> +	loff_t end = offset;
> +
> +	memset(&bh, 0, sizeof(bh));
> +	for (seg = 0; seg < nr_segs; seg++)
> +		end += iov[seg].iov_len;
> +
> +	if ((flags & DIO_LOCKING) && (rw == READ)) {
> +		struct address_space *mapping = inode->i_mapping;
> +		mutex_lock(&inode->i_mutex);
> +		retval = filemap_write_and_wait_range(mapping, offset, end - 1);
> +		if (retval) {
> +			mutex_unlock(&inode->i_mutex);
> +			goto out;
> +		}
  Is there a reason for this? I'd assume DAX has no pages in pagecache...

> +	}
> +
> +	/* Protects against truncate */
> +	atomic_inc(&inode->i_dio_count);
> +
> +	retval = dax_io(rw, inode, iov, offset, end, get_block, &bh);
> +
> +	if ((flags & DIO_LOCKING) && (rw == READ))
> +		mutex_unlock(&inode->i_mutex);
> +
> +	inode_dio_done(inode);
> +
> +	if ((retval > 0) && end_io)
> +		end_io(iocb, offset, retval, bh.b_private);
> + out:
> +	return retval;
> +}
> +EXPORT_SYMBOL_GPL(dax_do_io);
> diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> index 44c36e5..ef5cf96 100644
> --- a/fs/ext2/file.c
> +++ b/fs/ext2/file.c
> @@ -81,8 +81,10 @@ const struct file_operations ext2_file_operations = {
>  #ifdef CONFIG_EXT2_FS_XIP
>  const struct file_operations ext2_xip_file_operations = {
>  	.llseek		= generic_file_llseek,
> -	.read		= xip_file_read,
> -	.write		= xip_file_write,
> +	.read		= do_sync_read,
> +	.write		= do_sync_write,
> +	.aio_read	= generic_file_aio_read,
> +	.aio_write	= generic_file_aio_write,
>  	.unlocked_ioctl = ext2_ioctl,
>  #ifdef CONFIG_COMPAT
>  	.compat_ioctl	= ext2_compat_ioctl,
> diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
> index e7d3192..f128ebf 100644
> --- a/fs/ext2/inode.c
> +++ b/fs/ext2/inode.c
> @@ -858,7 +858,11 @@ ext2_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov,
>  	struct inode *inode = mapping->host;
>  	ssize_t ret;
>  
> -	ret = blockdev_direct_IO(rw, iocb, inode, iov, offset, nr_segs,
> +	if (IS_DAX(inode))
> +		ret = dax_do_io(rw, iocb, inode, iov, offset, nr_segs,
> +				ext2_get_block, NULL, DIO_LOCKING);
> +	else
> +		ret = blockdev_direct_IO(rw, iocb, inode, iov, offset, nr_segs,
>  				 ext2_get_block);
  I'd somewhat prefer to have a ext2_direct_IO() as is and have
ext2_dax_IO() call only dax_do_io() (and use that as .direct_io in
ext2_aops_xip). Then there's no need to check IS_DAX() and the code would
look more obvious to me. But I don't feel strongly about it.

>  	if (ret < 0 && (rw & WRITE))
>  		ext2_write_failed(mapping, offset + iov_length(iov, nr_segs));
> @@ -888,6 +892,7 @@ const struct address_space_operations ext2_aops = {
>  const struct address_space_operations ext2_aops_xip = {
>  	.bmap			= ext2_bmap,
>  	.get_xip_mem		= ext2_get_xip_mem,
> +	.direct_IO		= ext2_direct_IO,
>  };
>  
>  const struct address_space_operations ext2_nobh_aops = {
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 47fd219..dabc601 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2521,17 +2521,22 @@ extern int generic_file_open(struct inode * inode, struct file * filp);
>  extern int nonseekable_open(struct inode * inode, struct file * filp);
>  
>  #ifdef CONFIG_FS_XIP
> -extern ssize_t xip_file_read(struct file *filp, char __user *buf, size_t len,
> -			     loff_t *ppos);
>  extern int xip_file_mmap(struct file * file, struct vm_area_struct * vma);
> -extern ssize_t xip_file_write(struct file *filp, const char __user *buf,
> -			      size_t len, loff_t *ppos);
>  extern int xip_truncate_page(struct address_space *mapping, loff_t from);
> +ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, const struct iovec *,
> +		loff_t, unsigned segs, get_block_t, dio_iodone_t, int flags);
>  #else
>  static inline int xip_truncate_page(struct address_space *mapping, loff_t from)
>  {
>  	return 0;
>  }
> +
> +static inline ssize_t dax_do_io(int rw, struct kiocb *iocb, struct inode *inode,
> +		const struct iovec *iov, loff_t offset, unsigned nr_segs,
> +		get_block_t get_block, dio_iodone_t end_io, int flags)
> +{
> +	return -ENOTTY;
  Huh, ENOTTY? I'd expect EOPNOTSUPP or something like that...

> +}
>  #endif
>  
>  #ifdef CONFIG_BLOCK
> @@ -2681,6 +2686,11 @@ extern int generic_show_options(struct seq_file *m, struct dentry *root);
>  extern void save_mount_options(struct super_block *sb, char *options);
>  extern void replace_mount_options(struct super_block *sb, char *options);
>  
> +static inline bool io_is_direct(struct file *filp)
> +{
> +	return (filp->f_flags & O_DIRECT) || IS_DAX(file_inode(filp));
> +}
> +
  BTW: It seems fs/open.c: open_check_o_direct() can be simplified to not
check for get_xip_mem(), cannot it?

>  static inline ino_t parent_ino(struct dentry *dentry)
>  {
>  	ino_t res;
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 7a13f6a..1b7dff6 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1417,8 +1417,7 @@ generic_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
>  	if (retval)
>  		return retval;
>  
> -	/* coalesce the iovecs and go direct-to-BIO for O_DIRECT */
> -	if (filp->f_flags & O_DIRECT) {
> +	if (io_is_direct(filp)) {
>  		loff_t size;
>  		struct address_space *mapping;
>  		struct inode *inode;
> @@ -2468,8 +2467,7 @@ ssize_t __generic_file_aio_write(struct kiocb *iocb, const struct iovec *iov,
>  	if (err)
>  		goto out;
>  
> -	/* coalesce the iovecs and go direct-to-BIO for O_DIRECT */
> -	if (unlikely(file->f_flags & O_DIRECT)) {
> +	if (io_is_direct(file)) {
>  		loff_t endbyte;
>  		ssize_t written_buffered;
>  

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
