Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0C68F6B0031
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 08:17:23 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id x13so2336185wgg.33
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 05:17:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kx7si348659wjb.100.2014.04.09.05.17.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Apr 2014 05:17:20 -0700 (PDT)
Date: Wed, 9 Apr 2014 14:17:17 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 20/22] ext4: Add DAX functionality
Message-ID: <20140409121717.GN32103@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <490bf3041f0e0633964ca84bf4fb0bb3dd999694.1395591795.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <490bf3041f0e0633964ca84bf4fb0bb3dd999694.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, willy@linux.intel.com

On Sun 23-03-14 15:08:46, Matthew Wilcox wrote:
> From: Ross Zwisler <ross.zwisler@linux.intel.com>
> 
> This is a port of the DAX functionality found in the current version of
> ext2.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> [heavily tweaked]
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> ---
  I have some comments below.

> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index 1a50739..42a8ccd 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -190,7 +190,7 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
>  		}
>  	}
>  
> -	if (unlikely(iocb->ki_filp->f_flags & O_DIRECT))
> +	if (io_is_direct(iocb->ki_filp))
>  		ret = ext4_file_dio_write(iocb, iov, nr_segs, pos);
>  	else
>  		ret = generic_file_aio_write(iocb, iov, nr_segs, pos);
> @@ -198,6 +198,27 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
>  	return ret;
>  }
>  
> +#ifdef CONFIG_FS_DAX
> +static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
> +{
> +	return dax_fault(vma, vmf, ext4_get_block);
> +					/* Is this the right get_block? */
  Yes, it is the right one.

> +}
> +
> +static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
> +{
> +	return dax_mkwrite(vma, vmf, ext4_get_block);
> +}
  Umm, I'm afraid it won't be this easy here. So you rely on
ext4_get_block() to start a transaction for you and do the block
allocation. However if the system crashes after ext4_get_block() has
allocated the block and finished the transaction but before dax_mkwrite()
had a chance to zero out the page, the filesystem will be referencing block
with uninitialized data when the system boots again (this is a security
issue for multiuser systems). What you need to do is to start a transaction
here in ext4_dax_mkwrite(), call dax_mkwrite() (ext4_get_block() will
notice the transaction is already started and don't start it again so you
don't have to care about that), and stop the transaction after
dax_mkwrite() returns. Except it's not so easy because
sb_start_pagefault() locking ranks above transaction start so ext4 will
really need to call into something like do_dax_fault() - I'd suggest we
create dax_mkwrite() and __dax_mkwrite() similarly to how
block_page_mkwrite() and __block_page_mkwrite() from fs/buffer.c do.

> +
> +static const struct vm_operations_struct ext4_dax_vm_ops = {
> +	.fault		= ext4_dax_fault,
> +	.page_mkwrite	= ext4_dax_mkwrite,
> +	.remap_pages	= generic_file_remap_pages,
> +};
> +#else
> +#define ext4_dax_vm_ops	ext4_file_vm_ops
> +#endif
> +
>  static const struct vm_operations_struct ext4_file_vm_ops = {
>  	.fault		= filemap_fault,
>  	.page_mkwrite   = ext4_page_mkwrite,
> @@ -206,12 +227,13 @@ static const struct vm_operations_struct ext4_file_vm_ops = {
>  
>  static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
>  {
> -	struct address_space *mapping = file->f_mapping;
> -
> -	if (!mapping->a_ops->readpage)
> -		return -ENOEXEC;
>  	file_accessed(file);
> -	vma->vm_ops = &ext4_file_vm_ops;
> +	if (IS_DAX(file_inode(file))) {
> +		vma->vm_ops = &ext4_dax_vm_ops;
> +		vma->vm_flags |= VM_MIXEDMAP;
> +	} else {
> +		vma->vm_ops = &ext4_file_vm_ops;
> +	}
>  	return 0;
>  }
>  
> @@ -609,6 +631,25 @@ const struct file_operations ext4_file_operations = {
>  	.fallocate	= ext4_fallocate,
>  };
>  
> +#ifdef CONFIG_FS_DAX
> +const struct file_operations ext4_dax_file_operations = {
> +	.llseek		= ext4_llseek,
> +	.read		= do_sync_read,
> +	.write		= do_sync_write,
> +	.aio_read	= generic_file_aio_read,
> +	.aio_write	= ext4_file_write,
> +	.unlocked_ioctl = ext4_ioctl,
> +#ifdef CONFIG_COMPAT
> +	.compat_ioctl	= ext4_compat_ioctl,
> +#endif
> +	.mmap		= ext4_file_mmap,
> +	.open		= ext4_file_open,
> +	.release	= ext4_release_file,
> +	.fsync		= ext4_sync_file,
> +	.fallocate	= ext4_fallocate,
> +};
> +#endif
> +
>  const struct inode_operations ext4_file_inode_operations = {
>  	.setattr	= ext4_setattr,
>  	.getattr	= ext4_getattr,
> diff --git a/fs/ext4/indirect.c b/fs/ext4/indirect.c
> index 594009f..5fdb414 100644
> --- a/fs/ext4/indirect.c
> +++ b/fs/ext4/indirect.c
> @@ -686,15 +686,22 @@ retry:
>  			inode_dio_done(inode);
>  			goto locked;
>  		}
> -		ret = __blockdev_direct_IO(rw, iocb, inode,
> -				 inode->i_sb->s_bdev, iov,
> -				 offset, nr_segs,
> -				 ext4_get_block, NULL, NULL, 0);
> +		if (IS_DAX(inode))
> +			ret = dax_do_io(rw, iocb, inode, iov, offset, nr_segs,
> +					ext4_get_block, NULL, 0);
> +		else
> +			ret = __blockdev_direct_IO(rw, iocb, inode,
> +					inode->i_sb->s_bdev, iov, offset,
> +					nr_segs, ext4_get_block, NULL, NULL, 0);
>  		inode_dio_done(inode);
>  	} else {
>  locked:
> -		ret = blockdev_direct_IO(rw, iocb, inode, iov,
> -				 offset, nr_segs, ext4_get_block);
> +		if (IS_DAX(inode))
> +			ret = dax_do_io(rw, iocb, inode, iov, offset, nr_segs,
> +					ext4_get_block, NULL, DIO_LOCKING);
> +		else
> +			ret = blockdev_direct_IO(rw, iocb, inode, iov,
> +					offset, nr_segs, ext4_get_block);
>  
>  		if (unlikely((rw & WRITE) && ret < 0)) {
>  			loff_t isize = i_size_read(inode);
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index ce7341c..9462730 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -3140,13 +3140,14 @@ static ssize_t ext4_ext_direct_IO(int rw, struct kiocb *iocb,
>  		get_block_func = ext4_get_block_write;
>  		dio_flags = DIO_LOCKING;
>  	}
> -	ret = __blockdev_direct_IO(rw, iocb, inode,
> -				   inode->i_sb->s_bdev, iov,
> -				   offset, nr_segs,
> -				   get_block_func,
> -				   ext4_end_io_dio,
> -				   NULL,
> -				   dio_flags);
> +	if (IS_DAX(inode))
> +		ret = dax_do_io(rw, iocb, inode, iov, offset, nr_segs,
> +				get_block_func, ext4_end_io_dio, dio_flags);
> +	else
> +		ret = __blockdev_direct_IO(rw, iocb, inode,
> +					   inode->i_sb->s_bdev, iov, offset,
> +					   nr_segs, get_block_func,
> +					   ext4_end_io_dio, NULL, dio_flags);
>  
  Since you don't do real AIO for DAX, you could handle async iocbs for DAX
inodes the same way as normal sync iocbs (i.e., you don't need to allocate
ioend and do completion from a workqueue but handle everything necessary in
ext4_ext_direct_IO()). That will be noticeably faster and with smaller CPU
load as well. I'm not saying you have to do that now (although it shouldn't
be complicated) but at least note that in a comment please.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
