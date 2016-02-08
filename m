Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id A6363828F3
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 05:48:35 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id g62so110228146wme.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 02:48:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3si15660591wmb.104.2016.02.08.02.48.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 02:48:34 -0800 (PST)
Date: Mon, 8 Feb 2016 11:48:50 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] dax: move writeback calls into the filesystems
Message-ID: <20160208104849.GB9451@quack.suse.cz>
References: <1454829553-29499-1-git-send-email-ross.zwisler@linux.intel.com>
 <1454829553-29499-3-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454829553-29499-3-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

On Sun 07-02-16 00:19:13, Ross Zwisler wrote:
> Previously calls to dax_writeback_mapping_range() for all DAX filesystems
> (ext2, ext4 & xfs) were centralized in filemap_write_and_wait_range().
> dax_writeback_mapping_range() needs a struct block_device, and it used to
> get that from inode->i_sb->s_bdev.  This is correct for normal inodes
> mounted on ext2, ext4 and XFS filesystems, but is incorrect for DAX raw
> block devices and for XFS real-time files.
> 
> Instead, call dax_writeback_mapping_range() directly from the filesystem or
> raw block device fsync/msync code so that they can supply us with a valid
> block device.
> 
> It should be noted that this will reduce the number of calls to
> dax_writeback_mapping_range() because filemap_write_and_wait_range() is
> called in the various filesystems for operations other than just
> fsync/msync.  Both ext4 & XFS call filemap_write_and_wait_range() outside
> of ->fsync for hole punch, truncate, and block relocation
> (xfs_shift_file_space() && ext4_collapse_range()/ext4_insert_range()).
> 
> I don't believe that these extra flushes are necessary in the DAX case.  In
> the page cache case when we have dirty data in the page cache, that data
> will be actively lost if we evict a dirty page cache page without flushing
> it to media first.  For DAX, though, the data will remain consistent with
> the physical address to which it was written regardless of whether it's in
> the processor cache or not - really the only reason I see to flush is in
> response to a fsync or msync so that our data is durable on media in case
> of a power loss.  The case where we could throw dirty data out of the page
> cache and essentially lose writes simply doesn't exist.

You should at least note that sync(2) won't make data durable with this
patch in the changelog. Dave and Christoph have told you that Linux users
depend on sync(2) to make data durable and I fully agree with them.  Given
current options, I think we can live with this for 4.5 but long term this
is IMO unacceptable.

								Honza
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/block_dev.c      |  7 +++++++
>  fs/dax.c            |  5 ++---
>  fs/ext2/file.c      | 10 ++++++++++
>  fs/ext4/fsync.c     | 10 +++++++++-
>  fs/xfs/xfs_file.c   | 12 ++++++++++--
>  include/linux/dax.h |  4 ++--
>  mm/filemap.c        |  6 ------
>  7 files changed, 40 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index fa0507a..312ad44 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -356,8 +356,15 @@ int blkdev_fsync(struct file *filp, loff_t start, loff_t end, int datasync)
>  {
>  	struct inode *bd_inode = bdev_file_inode(filp);
>  	struct block_device *bdev = I_BDEV(bd_inode);
> +	struct address_space *mapping = bd_inode->i_mapping;
>  	int error;
>  	
> +	if (dax_mapping(mapping) && mapping->nrexceptional) {
> +		error = dax_writeback_mapping_range(mapping, bdev, start, end);
> +		if (error)
> +			return error;
> +	}
> +
>  	error = filemap_write_and_wait_range(filp->f_mapping, start, end);
>  	if (error)
>  		return error;
> diff --git a/fs/dax.c b/fs/dax.c
> index 4592241..4b5006a 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -484,11 +484,10 @@ static int dax_writeback_one(struct block_device *bdev,
>   * end]. This is required by data integrity operations to ensure file data is
>   * on persistent storage prior to completion of the operation.
>   */
> -int dax_writeback_mapping_range(struct address_space *mapping, loff_t start,
> -		loff_t end)
> +int dax_writeback_mapping_range(struct address_space *mapping,
> +		struct block_device *bdev, loff_t start, loff_t end)
>  {
>  	struct inode *inode = mapping->host;
> -	struct block_device *bdev = inode->i_sb->s_bdev;
>  	pgoff_t start_index, end_index, pmd_index;
>  	pgoff_t indices[PAGEVEC_SIZE];
>  	struct pagevec pvec;
> diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> index 2c88d68..d1abf53 100644
> --- a/fs/ext2/file.c
> +++ b/fs/ext2/file.c
> @@ -162,6 +162,16 @@ int ext2_fsync(struct file *file, loff_t start, loff_t end, int datasync)
>  	int ret;
>  	struct super_block *sb = file->f_mapping->host->i_sb;
>  	struct address_space *mapping = sb->s_bdev->bd_inode->i_mapping;
> +#ifdef CONFIG_FS_DAX
> +	struct address_space *inode_mapping = file->f_inode->i_mapping;
> +
> +	if (dax_mapping(inode_mapping) && inode_mapping->nrexceptional) {
> +		ret = dax_writeback_mapping_range(inode_mapping, sb->s_bdev,
> +				start, end);
> +		if (ret)
> +			return ret;
> +	}
> +#endif
>  
>  	ret = generic_file_fsync(file, start, end, datasync);
>  	if (ret == -EIO || test_and_clear_bit(AS_EIO, &mapping->flags)) {
> diff --git a/fs/ext4/fsync.c b/fs/ext4/fsync.c
> index 8850254..e9cf53b 100644
> --- a/fs/ext4/fsync.c
> +++ b/fs/ext4/fsync.c
> @@ -27,6 +27,7 @@
>  #include <linux/sched.h>
>  #include <linux/writeback.h>
>  #include <linux/blkdev.h>
> +#include <linux/dax.h>
>  
>  #include "ext4.h"
>  #include "ext4_jbd2.h"
> @@ -83,10 +84,10 @@ static int ext4_sync_parent(struct inode *inode)
>   * What we do is just kick off a commit and wait on it.  This will snapshot the
>   * inode to disk.
>   */
> -
>  int ext4_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
>  {
>  	struct inode *inode = file->f_mapping->host;
> +	struct address_space *mapping = inode->i_mapping;
>  	struct ext4_inode_info *ei = EXT4_I(inode);
>  	journal_t *journal = EXT4_SB(inode->i_sb)->s_journal;
>  	int ret = 0, err;
> @@ -97,6 +98,13 @@ int ext4_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
>  
>  	trace_ext4_sync_file_enter(file, datasync);
>  
> +	if (dax_mapping(mapping) && mapping->nrexceptional) {
> +		err = dax_writeback_mapping_range(mapping, inode->i_sb->s_bdev,
> +				start, end);
> +		if (err)
> +			goto out;
> +	}
> +
>  	if (inode->i_sb->s_flags & MS_RDONLY) {
>  		/* Make sure that we read updated s_mount_flags value */
>  		smp_rmb();
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index 52883ac..84e95cc 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -209,7 +209,8 @@ xfs_file_fsync(
>  	loff_t			end,
>  	int			datasync)
>  {
> -	struct inode		*inode = file->f_mapping->host;
> +	struct address_space	*mapping = file->f_mapping;
> +	struct inode		*inode = mapping->host;
>  	struct xfs_inode	*ip = XFS_I(inode);
>  	struct xfs_mount	*mp = ip->i_mount;
>  	int			error = 0;
> @@ -218,7 +219,14 @@ xfs_file_fsync(
>  
>  	trace_xfs_file_fsync(ip);
>  
> -	error = filemap_write_and_wait_range(inode->i_mapping, start, end);
> +	if (dax_mapping(mapping) && mapping->nrexceptional) {
> +		error = dax_writeback_mapping_range(mapping,
> +				xfs_find_bdev_for_inode(inode), start, end);
> +		if (error)
> +			return error;
> +	}
> +
> +	error = filemap_write_and_wait_range(mapping, start, end);
>  	if (error)
>  		return error;
>  
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index bad27b0..8e9f114 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -42,6 +42,6 @@ static inline bool dax_mapping(struct address_space *mapping)
>  {
>  	return mapping->host && IS_DAX(mapping->host);
>  }
> -int dax_writeback_mapping_range(struct address_space *mapping, loff_t start,
> -		loff_t end);
> +int dax_writeback_mapping_range(struct address_space *mapping,
> +		struct block_device *bdev, loff_t start, loff_t end);
>  #endif
> diff --git a/mm/filemap.c b/mm/filemap.c
> index bc94386..c4286eb 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -482,12 +482,6 @@ int filemap_write_and_wait_range(struct address_space *mapping,
>  {
>  	int err = 0;
>  
> -	if (dax_mapping(mapping) && mapping->nrexceptional) {
> -		err = dax_writeback_mapping_range(mapping, lstart, lend);
> -		if (err)
> -			return err;
> -	}
> -
>  	if (mapping->nrpages) {
>  		err = __filemap_fdatawrite_range(mapping, lstart, lend,
>  						 WB_SYNC_ALL);
> -- 
> 2.5.0
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
