Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EB9A76B0055
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 07:45:22 -0400 (EDT)
Message-ID: <4A533559.90303@panasas.com>
Date: Tue, 07 Jul 2009 14:45:29 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
Subject: Re: [rfc][patch 3/3] fs: convert ext2,tmpfs to new truncate
References: <20090706165438.GQ2714@wotan.suse.de> <20090706165629.GS2714@wotan.suse.de>
In-Reply-To: <20090706165629.GS2714@wotan.suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/06/2009 07:56 PM, Nick Piggin wrote:
> Convert filemap_xip.c, buffer.c, and some filesystems to the new truncate
> convention. Converting generic helpers is using some ugly code (testing
> for i_op->ftruncate) to distinguish new and old callers... better
> alternative might be just define a new function for these guys.
> ---
>  fs/buffer.c      |   40 +++++++++++++++++--------
>  fs/ext2/ext2.h   |    2 -
>  fs/ext2/file.c   |    2 -
>  fs/ext2/inode.c  |   85 ++++++++++++++++++++++++++++++++++++++++++-------------
>  mm/filemap_xip.c |   15 +++++++--
>  mm/shmem.c       |   40 ++++++++++++++++---------
>  6 files changed, 133 insertions(+), 51 deletions(-)
> 
> Index: linux-2.6/fs/ext2/inode.c
> ===================================================================
> --- linux-2.6.orig/fs/ext2/inode.c
> +++ linux-2.6/fs/ext2/inode.c
> @@ -68,7 +68,7 @@ void ext2_delete_inode (struct inode * i
>  
>  	inode->i_size = 0;
>  	if (inode->i_blocks)
> -		ext2_truncate (inode);
> +		ext2_ftruncate(NULL, 0, inode, 0);
>  	ext2_free_inode (inode);
>  
>  	return;
> @@ -761,8 +761,31 @@ ext2_write_begin(struct file *file, stru
>  		loff_t pos, unsigned len, unsigned flags,
>  		struct page **pagep, void **fsdata)
>  {
> +	int ret;
> +
>  	*pagep = NULL;
> -	return __ext2_write_begin(file, mapping, pos, len, flags, pagep,fsdata);
> +	ret = __ext2_write_begin(file, mapping, pos, len, flags, pagep,fsdata);
> +	if (ret < 0) {
> +		loff_t isize = inode->i_size;
> +		if (pos + len > isize)
> +			ext2_ftruncate(NULL, 0, inode, isize);
> +	}
> +	return ret;
> +}
> +
> +static int ext2_write_end(struct file *file, struct address_space *mapping,
> +			loff_t pos, unsigned len, unsigned copied,
> +			struct page *page, void *fsdata)
> +{
> +	int ret;
> +
> +	ret = generic_write_end(file, mapping, pos, len, copied, page, fsdata);
> +	if (ret < len) {
> +		loff_t isize = inode->i_size;
> +		if (pos + len > isize)
> +			ext2_ftruncate(NULL, 0, inode, isize);
> +	}
> +	return ret;
>  }
>  
>  static int
> @@ -770,13 +793,22 @@ ext2_nobh_write_begin(struct file *file,
>  		loff_t pos, unsigned len, unsigned flags,
>  		struct page **pagep, void **fsdata)
>  {
> +	int ret;
> +
>  	/*
>  	 * Dir-in-pagecache still uses ext2_write_begin. Would have to rework
>  	 * directory handling code to pass around offsets rather than struct
>  	 * pages in order to make this work easily.
>  	 */
> -	return nobh_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
> +	ret = nobh_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
>  							ext2_get_block);
> +	if (ret < 0) {
> +		loff_t isize;
> +		isize = i_size_read(inode);

Unlike the other places you use i_size_read() here, please explain what is the
locking rules for this?

Did your patchset change things in this regard?

> +		if (pos + len > isize)
> +			ext2_ftruncate(NULL, 0, inode, isize);
> +	}
> +	return ret;
>  }
>  
>  static int ext2_nobh_writepage(struct page *page,
> @@ -796,9 +828,15 @@ ext2_direct_IO(int rw, struct kiocb *ioc
>  {
>  	struct file *file = iocb->ki_filp;
>  	struct inode *inode = file->f_mapping->host;
> +	ssize_t ret;
>  
> -	return blockdev_direct_IO(rw, iocb, inode, inode->i_sb->s_bdev, iov,
> +	ret = blockdev_direct_IO(rw, iocb, inode, inode->i_sb->s_bdev, iov,
>  				offset, nr_segs, ext2_get_block, NULL);
> +	if (ret < 0 && (rw & WRITE)) {
> +		loff_t isize = i_size_read(inode);
> +		ext2_ftruncate(NULL, 0, inode, isize);
> +	}
> +	return ret;
>  }
>  
>  static int
> @@ -813,7 +851,7 @@ const struct address_space_operations ex
>  	.writepage		= ext2_writepage,
>  	.sync_page		= block_sync_page,
>  	.write_begin		= ext2_write_begin,
> -	.write_end		= generic_write_end,
> +	.write_end		= ext2_write_end,
>  	.bmap			= ext2_bmap,
>  	.direct_IO		= ext2_direct_IO,
>  	.writepages		= ext2_writepages,
> @@ -1020,7 +1058,8 @@ static void ext2_free_branches(struct in
>  		ext2_free_data(inode, p, q);
>  }
>  
> -void ext2_truncate(struct inode *inode)
> +int ext2_ftruncate(struct file *file, int open,
> +			struct inode *inode, loff_t offset)
>  {
>  	__le32 *i_data = EXT2_I(inode)->i_data;
>  	struct ext2_inode_info *ei = EXT2_I(inode);
> @@ -1032,31 +1071,37 @@ void ext2_truncate(struct inode *inode)
>  	int n;
>  	long iblock;
>  	unsigned blocksize;
> +	int error;
> +
> +	error = inode_truncate_ok(inode, offset);
> +	if (error)
> +		return error;
>  
>  	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode) ||
>  	    S_ISLNK(inode->i_mode)))
> -		return;
> +		return -EINVAL;
>  	if (ext2_inode_is_fast_symlink(inode))
> -		return;
> +		return -EINVAL;
>  	if (IS_APPEND(inode) || IS_IMMUTABLE(inode))
> -		return;
> -
> -	blocksize = inode->i_sb->s_blocksize;
> -	iblock = (inode->i_size + blocksize-1)
> -					>> EXT2_BLOCK_SIZE_BITS(inode->i_sb);
> +		return -EPERM;
>  
>  	if (mapping_is_xip(inode->i_mapping))
> -		xip_truncate_page(inode->i_mapping, inode->i_size);
> +		error = xip_truncate_page(inode->i_mapping, offset);
>  	else if (test_opt(inode->i_sb, NOBH))
> -		nobh_truncate_page(inode->i_mapping,
> -				inode->i_size, ext2_get_block);
> +		error = nobh_truncate_page(inode->i_mapping,
> +				offset, ext2_get_block);
>  	else
> -		block_truncate_page(inode->i_mapping,
> -				inode->i_size, ext2_get_block);
> +		error = block_truncate_page(inode->i_mapping,
> +				offset, ext2_get_block);
> +	if (error)
> +		return error;
> +
> +	blocksize = inode->i_sb->s_blocksize;
> +	iblock = (offset + blocksize-1) >> EXT2_BLOCK_SIZE_BITS(inode->i_sb);
>  
>  	n = ext2_block_to_path(inode, iblock, offsets, NULL);
>  	if (n == 0)
> -		return;
> +		return 0;
>  
>  	/*
>  	 * From here we block out all ext2_get_block() callers who want to
> @@ -1127,6 +1172,8 @@ do_indirects:
>  	} else {
>  		mark_inode_dirty(inode);
>  	}
> +
> +	return 0;
>  }
>  
>  static struct ext2_inode *ext2_get_inode(struct super_block *sb, ino_t ino,
> Index: linux-2.6/mm/shmem.c
> ===================================================================
> --- linux-2.6.orig/mm/shmem.c
> +++ linux-2.6/mm/shmem.c
> @@ -730,10 +730,11 @@ done2:
>  	if (inode->i_mapping->nrpages && (info->flags & SHMEM_PAGEIN)) {
>  		/*
>  		 * Call truncate_inode_pages again: racing shmem_unuse_inode
> -		 * may have swizzled a page in from swap since vmtruncate or
> -		 * generic_delete_inode did it, before we lowered next_index.
> -		 * Also, though shmem_getpage checks i_size before adding to
> -		 * cache, no recheck after: so fix the narrow window there too.
> +		 * may have swizzled a page in from swap since
> +		 * truncate_pagecache or generic_delete_inode did it, before we
> +		 * lowered next_index.  Also, though shmem_getpage checks
> +		 * i_size before adding to cache, no recheck after: so fix the
> +		 * narrow window there too.
>  		 *
>  		 * Recalling truncate_inode_pages_range and unmap_mapping_range
>  		 * every time for punch_hole (which never got a chance to clear
> @@ -763,9 +764,21 @@ done2:
>  	}
>  }
>  
> -static void shmem_truncate(struct inode *inode)
> +static int shmem_ftruncate(struct file *file, int open,
> +			struct inode *inode, loff_t offset)
>  {
> -	shmem_truncate_range(inode, inode->i_size, (loff_t)-1);
> +	loff_t oldsize;
> +	int error;
> +
> +	error = inode_truncate_ok(inode, offset);
> +	if (error)
> +		return error;
> +	oldsize = inode->i_size;
> +	i_size_write(inode, offset);
> +	truncate_pagecache(inode, oldsize, offset);
> +	shmem_truncate_range(inode, offset, (loff_t)-1);
> +
> +	return error;
>  }
>  
>  static int shmem_notify_change(struct dentry *dentry, struct iattr *attr)
> @@ -822,11 +835,10 @@ static void shmem_delete_inode(struct in
>  {
>  	struct shmem_inode_info *info = SHMEM_I(inode);
>  
> -	if (inode->i_op->truncate == shmem_truncate) {
> +	if (inode->i_op->ftruncate == shmem_ftruncate) {
>  		truncate_inode_pages(inode->i_mapping, 0);
>  		shmem_unacct_size(info->flags, inode->i_size);
> -		inode->i_size = 0;
> -		shmem_truncate(inode);
> +		shmem_ftruncate(NULL, 0, inode, 0);
>  		if (!list_empty(&info->swaplist)) {
>  			mutex_lock(&shmem_swaplist_mutex);
>  			list_del_init(&info->swaplist);
> @@ -1627,13 +1639,13 @@ shmem_write_end(struct file *file, struc
>  {
>  	struct inode *inode = mapping->host;
>  
> -	if (pos + copied > inode->i_size)
> -		i_size_write(inode, pos + copied);
> -
>  	unlock_page(page);
>  	set_page_dirty(page);
>  	page_cache_release(page);
>  
> +	if (pos + copied > inode->i_size)
> +		i_size_write(inode, pos + copied);
> +
>  	return copied;
>  }
>  
> @@ -2018,7 +2030,7 @@ static const struct inode_operations shm
>  };
>  
>  static const struct inode_operations shmem_symlink_inode_operations = {
> -	.truncate	= shmem_truncate,
> +	.ftruncate	= shmem_ftruncate,
>  	.readlink	= generic_readlink,
>  	.follow_link	= shmem_follow_link,
>  	.put_link	= shmem_put_link,
> @@ -2438,7 +2450,7 @@ static const struct file_operations shme
>  };
>  
>  static const struct inode_operations shmem_inode_operations = {
> -	.truncate	= shmem_truncate,
> +	.ftruncate	= shmem_ftruncate,
>  	.setattr	= shmem_notify_change,
>  	.truncate_range	= shmem_truncate_range,
>  #ifdef CONFIG_TMPFS_POSIX_ACL
> Index: linux-2.6/fs/buffer.c
> ===================================================================
> --- linux-2.6.orig/fs/buffer.c
> +++ linux-2.6/fs/buffer.c
> @@ -2702,22 +2702,23 @@ int nobh_truncate_page(struct address_sp
>  	struct inode *inode = mapping->host;
>  	struct page *page;
>  	struct buffer_head map_bh;
> -	int err;
> +	int err = 0;
>  
>  	blocksize = 1 << inode->i_blkbits;
>  	length = offset & (blocksize - 1);
>  
>  	/* Block boundary? Nothing to do */
>  	if (!length)
> -		return 0;
> +		goto out;
>  
>  	length = blocksize - length;
>  	iblock = (sector_t)index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
>  
>  	page = grab_cache_page(mapping, index);
> -	err = -ENOMEM;
> -	if (!page)
> +	if (!page) {
> +		err = -ENOMEM;
>  		goto out;
> +	}
>  
>  	if (page_has_buffers(page)) {
>  has_buffers:
> @@ -2759,12 +2760,18 @@ has_buffers:
>  	}
>  	zero_user(page, offset, length);
>  	set_page_dirty(page);
> -	err = 0;
>  
>  unlock:
>  	unlock_page(page);
>  	page_cache_release(page);
>  out:
> +	if (!err && inode->i_op->ftruncate) {
> +		loff_t oldsize = inode->i_size;
> +
> +		i_size_write(inode, from);
> +		truncate_pagecache(inode, oldsize, from);
> +	}
> +
>  	return err;
>  }
>  EXPORT_SYMBOL(nobh_truncate_page);
> @@ -2780,22 +2787,23 @@ int block_truncate_page(struct address_s
>  	struct inode *inode = mapping->host;
>  	struct page *page;
>  	struct buffer_head *bh;
> -	int err;
> +	int err = 0;
>  
>  	blocksize = 1 << inode->i_blkbits;
>  	length = offset & (blocksize - 1);
>  
>  	/* Block boundary? Nothing to do */
>  	if (!length)
> -		return 0;
> +		goto out;
>  
>  	length = blocksize - length;
>  	iblock = (sector_t)index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
>  	
>  	page = grab_cache_page(mapping, index);
> -	err = -ENOMEM;
> -	if (!page)
> +	if (!page) {
> +		err = -ENOMEM;
>  		goto out;
> +	}
>  
>  	if (!page_has_buffers(page))
>  		create_empty_buffers(page, blocksize, 0);
> @@ -2809,7 +2817,6 @@ int block_truncate_page(struct address_s
>  		pos += blocksize;
>  	}
>  
> -	err = 0;
>  	if (!buffer_mapped(bh)) {
>  		WARN_ON(bh->b_size != blocksize);
>  		err = get_block(inode, iblock, bh, 0);
> @@ -2825,22 +2832,29 @@ int block_truncate_page(struct address_s
>  		set_buffer_uptodate(bh);
>  
>  	if (!buffer_uptodate(bh) && !buffer_delay(bh) && !buffer_unwritten(bh)) {
> -		err = -EIO;
>  		ll_rw_block(READ, 1, &bh);
>  		wait_on_buffer(bh);
>  		/* Uhhuh. Read error. Complain and punt. */
> -		if (!buffer_uptodate(bh))
> +		if (!buffer_uptodate(bh)) {
> +			err = -EIO;
>  			goto unlock;
> +		}
>  	}
>  
>  	zero_user(page, offset, length);
>  	mark_buffer_dirty(bh);
> -	err = 0;
>  
>  unlock:
>  	unlock_page(page);
>  	page_cache_release(page);
>  out:
> +	if (!err && inode->i_op->ftruncate) {
> +		loff_t oldsize = inode->i_size;
> +
> +		i_size_write(inode, from);
> +		truncate_pagecache(inode, oldsize, from);
> +	}
> +
>  	return err;
>  }
>  
> Index: linux-2.6/fs/ext2/ext2.h
> ===================================================================
> --- linux-2.6.orig/fs/ext2/ext2.h
> +++ linux-2.6/fs/ext2/ext2.h
> @@ -122,7 +122,7 @@ extern int ext2_write_inode (struct inod
>  extern void ext2_delete_inode (struct inode *);
>  extern int ext2_sync_inode (struct inode *);
>  extern int ext2_get_block(struct inode *, sector_t, struct buffer_head *, int);
> -extern void ext2_truncate (struct inode *);
> +extern int ext2_ftruncate(struct file *, int, struct inode *, loff_t);
>  extern int ext2_setattr (struct dentry *, struct iattr *);
>  extern void ext2_set_inode_flags(struct inode *inode);
>  extern void ext2_get_inode_flags(struct ext2_inode_info *);
> Index: linux-2.6/mm/filemap_xip.c
> ===================================================================
> --- linux-2.6.orig/mm/filemap_xip.c
> +++ linux-2.6/mm/filemap_xip.c
> @@ -440,7 +440,9 @@ EXPORT_SYMBOL_GPL(xip_file_write);
>  int
>  xip_truncate_page(struct address_space *mapping, loff_t from)
>  {
> +	struct inode *inode = mapping->host;
>  	pgoff_t index = from >> PAGE_CACHE_SHIFT;
> +	loff_t oldsize;
>  	unsigned offset = from & (PAGE_CACHE_SIZE-1);
>  	unsigned blocksize;
>  	unsigned length;
> @@ -450,12 +452,12 @@ xip_truncate_page(struct address_space *
>  
>  	BUG_ON(!mapping->a_ops->get_xip_mem);
>  
> -	blocksize = 1 << mapping->host->i_blkbits;
> +	blocksize = 1 << inode->i_blkbits;
>  	length = offset & (blocksize - 1);
>  
>  	/* Block boundary? Nothing to do */
>  	if (!length)
> -		return 0;
> +		goto out;
>  
>  	length = blocksize - length;
>  
> @@ -464,11 +466,18 @@ xip_truncate_page(struct address_space *
>  	if (unlikely(err)) {
>  		if (err == -ENODATA)
>  			/* Hole? No need to truncate */
> -			return 0;
> +			goto out;
>  		else
>  			return err;
>  	}
>  	memset(xip_mem + offset, 0, length);
> +out:
> +	if (inode->i_op->ftruncate) {
> +		oldsize = inode->i_size;
> +		i_size_write(inode, from);
> +		truncate_pagecache(inode, oldsize, from);
> +	}
> +
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(xip_truncate_page);
> Index: linux-2.6/fs/ext2/file.c
> ===================================================================
> --- linux-2.6.orig/fs/ext2/file.c
> +++ linux-2.6/fs/ext2/file.c
> @@ -77,7 +77,7 @@ const struct file_operations ext2_xip_fi
>  #endif
>  
>  const struct inode_operations ext2_file_inode_operations = {
> -	.truncate	= ext2_truncate,
> +	.ftruncate	= ext2_ftruncate,
>  #ifdef CONFIG_EXT2_FS_XATTR
>  	.setxattr	= generic_setxattr,
>  	.getxattr	= generic_getxattr,
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
