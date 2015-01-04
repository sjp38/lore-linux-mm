Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 470D86B0032
	for <linux-mm@kvack.org>; Sun,  4 Jan 2015 03:28:43 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so26597855pab.16
        for <linux-mm@kvack.org>; Sun, 04 Jan 2015 00:28:43 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id gz1si30080853pbd.38.2015.01.04.00.28.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 04 Jan 2015 00:28:41 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so26542506pac.36
        for <linux-mm@kvack.org>; Sun, 04 Jan 2015 00:28:40 -0800 (PST)
Date: Sun, 04 Jan 2015 17:28:35 +0900 (JST)
Message-Id: <20150104.172835.1423403148599715981.konishi.ryusuke@lab.ntt.co.jp>
Subject: Re: [PATCH 8/8] fs: remove mapping->backing_dev_info
From: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
In-Reply-To: <1419929859-24427-9-git-send-email-hch@lst.de>
References: <1419929859-24427-1-git-send-email-hch@lst.de>
	<1419929859-24427-9-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org

On Tue, 30 Dec 2014 09:57:39 +0100, Christoph Hellwig <hch@lst.de> wrote:
> Now that we never use the backing_dev_info pointer in struct address_space
> we can simply remove it and save 4 to 8 bytes in every inode.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks good with regard to nilfs2.

Acked-by: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>

> ---
>  drivers/char/raw.c     |  4 +---
>  fs/aio.c               |  1 -
>  fs/block_dev.c         | 26 +-------------------------
>  fs/btrfs/disk-io.c     |  1 -
>  fs/btrfs/inode.c       |  6 ------
>  fs/ceph/inode.c        |  2 --
>  fs/cifs/inode.c        |  2 --
>  fs/configfs/inode.c    |  1 -
>  fs/ecryptfs/inode.c    |  1 -
>  fs/exofs/inode.c       |  2 --
>  fs/fuse/inode.c        |  1 -
>  fs/gfs2/glock.c        |  1 -
>  fs/gfs2/ops_fstype.c   |  1 -
>  fs/hugetlbfs/inode.c   |  1 -
>  fs/inode.c             | 13 -------------
>  fs/kernfs/inode.c      |  1 -
>  fs/ncpfs/inode.c       |  1 -
>  fs/nfs/inode.c         |  1 -
>  fs/nilfs2/gcinode.c    |  1 -
>  fs/nilfs2/mdt.c        |  6 ++----
>  fs/nilfs2/page.c       |  4 +---
>  fs/nilfs2/page.h       |  3 +--
>  fs/nilfs2/super.c      |  2 +-
>  fs/ocfs2/dlmfs/dlmfs.c |  2 --
>  fs/ramfs/inode.c       |  1 -
>  fs/romfs/super.c       |  3 ---
>  fs/ubifs/dir.c         |  2 --
>  fs/ubifs/super.c       |  3 ---
>  include/linux/fs.h     |  3 +--
>  mm/backing-dev.c       |  1 -
>  mm/shmem.c             |  1 -
>  mm/swap_state.c        |  1 -
>  32 files changed, 8 insertions(+), 91 deletions(-)
> 
> diff --git a/drivers/char/raw.c b/drivers/char/raw.c
> index a24891b..6e29bf2 100644
> --- a/drivers/char/raw.c
> +++ b/drivers/char/raw.c
> @@ -104,11 +104,9 @@ static int raw_release(struct inode *inode, struct file *filp)
>  
>  	mutex_lock(&raw_mutex);
>  	bdev = raw_devices[minor].binding;
> -	if (--raw_devices[minor].inuse == 0) {
> +	if (--raw_devices[minor].inuse == 0)
>  		/* Here  inode->i_mapping == bdev->bd_inode->i_mapping  */
>  		inode->i_mapping = &inode->i_data;
> -		inode->i_mapping->backing_dev_info = &default_backing_dev_info;
> -	}
>  	mutex_unlock(&raw_mutex);
>  
>  	blkdev_put(bdev, filp->f_mode | FMODE_EXCL);
> diff --git a/fs/aio.c b/fs/aio.c
> index 6f13d3f..3bf8b1d 100644
> --- a/fs/aio.c
> +++ b/fs/aio.c
> @@ -176,7 +176,6 @@ static struct file *aio_private_file(struct kioctx *ctx, loff_t nr_pages)
>  
>  	inode->i_mapping->a_ops = &aio_ctx_aops;
>  	inode->i_mapping->private_data = ctx;
> -	inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
>  	inode->i_size = PAGE_SIZE * nr_pages;
>  
>  	path.dentry = d_alloc_pseudo(aio_mnt->mnt_sb, &this);
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index 288ba70..2ec7b3d 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -60,19 +60,6 @@ static void bdev_write_inode(struct inode *inode)
>  	spin_unlock(&inode->i_lock);
>  }
>  
> -/*
> - * Move the inode from its current bdi to a new bdi.  Make sure the inode
> - * is clean before moving so that it doesn't linger on the old bdi.
> - */
> -static void bdev_inode_switch_bdi(struct inode *inode,
> -			struct backing_dev_info *dst)
> -{
> -	spin_lock(&inode->i_lock);
> -	WARN_ON_ONCE(inode->i_state & I_DIRTY);
> -	inode->i_data.backing_dev_info = dst;
> -	spin_unlock(&inode->i_lock);
> -}
> -
>  /* Kill _all_ buffers and pagecache , dirty or not.. */
>  void kill_bdev(struct block_device *bdev)
>  {
> @@ -589,7 +576,6 @@ struct block_device *bdget(dev_t dev)
>  		inode->i_bdev = bdev;
>  		inode->i_data.a_ops = &def_blk_aops;
>  		mapping_set_gfp_mask(&inode->i_data, GFP_USER);
> -		inode->i_data.backing_dev_info = &default_backing_dev_info;
>  		spin_lock(&bdev_lock);
>  		list_add(&bdev->bd_list, &all_bdevs);
>  		spin_unlock(&bdev_lock);
> @@ -1150,8 +1136,6 @@ static int __blkdev_get(struct block_device *bdev, fmode_t mode, int for_part)
>  		bdev->bd_queue = disk->queue;
>  		bdev->bd_contains = bdev;
>  		if (!partno) {
> -			struct backing_dev_info *bdi;
> -
>  			ret = -ENXIO;
>  			bdev->bd_part = disk_get_part(disk, partno);
>  			if (!bdev->bd_part)
> @@ -1177,11 +1161,8 @@ static int __blkdev_get(struct block_device *bdev, fmode_t mode, int for_part)
>  				}
>  			}
>  
> -			if (!ret) {
> +			if (!ret)
>  				bd_set_size(bdev,(loff_t)get_capacity(disk)<<9);
> -				bdi = blk_get_backing_dev_info(bdev);
> -				bdev_inode_switch_bdi(bdev->bd_inode, bdi);
> -			}
>  
>  			/*
>  			 * If the device is invalidated, rescan partition
> @@ -1208,8 +1189,6 @@ static int __blkdev_get(struct block_device *bdev, fmode_t mode, int for_part)
>  			if (ret)
>  				goto out_clear;
>  			bdev->bd_contains = whole;
> -			bdev_inode_switch_bdi(bdev->bd_inode,
> -				whole->bd_inode->i_data.backing_dev_info);
>  			bdev->bd_part = disk_get_part(disk, partno);
>  			if (!(disk->flags & GENHD_FL_UP) ||
>  			    !bdev->bd_part || !bdev->bd_part->nr_sects) {
> @@ -1249,7 +1228,6 @@ static int __blkdev_get(struct block_device *bdev, fmode_t mode, int for_part)
>  	bdev->bd_disk = NULL;
>  	bdev->bd_part = NULL;
>  	bdev->bd_queue = NULL;
> -	bdev_inode_switch_bdi(bdev->bd_inode, &default_backing_dev_info);
>  	if (bdev != bdev->bd_contains)
>  		__blkdev_put(bdev->bd_contains, mode, 1);
>  	bdev->bd_contains = NULL;
> @@ -1474,8 +1452,6 @@ static void __blkdev_put(struct block_device *bdev, fmode_t mode, int for_part)
>  		 * dirty data before.
>  		 */
>  		bdev_write_inode(bdev->bd_inode);
> -		bdev_inode_switch_bdi(bdev->bd_inode,
> -					&default_backing_dev_info);
>  	}
>  	if (bdev->bd_contains == bdev) {
>  		if (disk->fops->release)
> diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
> index afc4092..1ec872e 100644
> --- a/fs/btrfs/disk-io.c
> +++ b/fs/btrfs/disk-io.c
> @@ -2318,7 +2318,6 @@ int open_ctree(struct super_block *sb,
>  	 */
>  	fs_info->btree_inode->i_size = OFFSET_MAX;
>  	fs_info->btree_inode->i_mapping->a_ops = &btree_aops;
> -	fs_info->btree_inode->i_mapping->backing_dev_info = &fs_info->bdi;
>  
>  	RB_CLEAR_NODE(&BTRFS_I(fs_info->btree_inode)->rb_node);
>  	extent_io_tree_init(&BTRFS_I(fs_info->btree_inode)->io_tree,
> diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> index e687bb0..5a4046a 100644
> --- a/fs/btrfs/inode.c
> +++ b/fs/btrfs/inode.c
> @@ -3608,7 +3608,6 @@ cache_acl:
>  	switch (inode->i_mode & S_IFMT) {
>  	case S_IFREG:
>  		inode->i_mapping->a_ops = &btrfs_aops;
> -		inode->i_mapping->backing_dev_info = &root->fs_info->bdi;
>  		BTRFS_I(inode)->io_tree.ops = &btrfs_extent_io_ops;
>  		inode->i_fop = &btrfs_file_operations;
>  		inode->i_op = &btrfs_file_inode_operations;
> @@ -3623,7 +3622,6 @@ cache_acl:
>  	case S_IFLNK:
>  		inode->i_op = &btrfs_symlink_inode_operations;
>  		inode->i_mapping->a_ops = &btrfs_symlink_aops;
> -		inode->i_mapping->backing_dev_info = &root->fs_info->bdi;
>  		break;
>  	default:
>  		inode->i_op = &btrfs_special_inode_operations;
> @@ -6088,7 +6086,6 @@ static int btrfs_create(struct inode *dir, struct dentry *dentry,
>  	inode->i_fop = &btrfs_file_operations;
>  	inode->i_op = &btrfs_file_inode_operations;
>  	inode->i_mapping->a_ops = &btrfs_aops;
> -	inode->i_mapping->backing_dev_info = &root->fs_info->bdi;
>  
>  	err = btrfs_init_inode_security(trans, inode, dir, &dentry->d_name);
>  	if (err)
> @@ -9201,7 +9198,6 @@ static int btrfs_symlink(struct inode *dir, struct dentry *dentry,
>  	inode->i_fop = &btrfs_file_operations;
>  	inode->i_op = &btrfs_file_inode_operations;
>  	inode->i_mapping->a_ops = &btrfs_aops;
> -	inode->i_mapping->backing_dev_info = &root->fs_info->bdi;
>  	BTRFS_I(inode)->io_tree.ops = &btrfs_extent_io_ops;
>  
>  	err = btrfs_init_inode_security(trans, inode, dir, &dentry->d_name);
> @@ -9245,7 +9241,6 @@ static int btrfs_symlink(struct inode *dir, struct dentry *dentry,
>  
>  	inode->i_op = &btrfs_symlink_inode_operations;
>  	inode->i_mapping->a_ops = &btrfs_symlink_aops;
> -	inode->i_mapping->backing_dev_info = &root->fs_info->bdi;
>  	inode_set_bytes(inode, name_len);
>  	btrfs_i_size_write(inode, name_len);
>  	err = btrfs_update_inode(trans, root, inode);
> @@ -9457,7 +9452,6 @@ static int btrfs_tmpfile(struct inode *dir, struct dentry *dentry, umode_t mode)
>  	inode->i_op = &btrfs_file_inode_operations;
>  
>  	inode->i_mapping->a_ops = &btrfs_aops;
> -	inode->i_mapping->backing_dev_info = &root->fs_info->bdi;
>  	BTRFS_I(inode)->io_tree.ops = &btrfs_extent_io_ops;
>  
>  	ret = btrfs_init_inode_security(trans, inode, dir, NULL);
> diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
> index f61a741..6b51736 100644
> --- a/fs/ceph/inode.c
> +++ b/fs/ceph/inode.c
> @@ -783,8 +783,6 @@ static int fill_inode(struct inode *inode, struct page *locked_page,
>  	}
>  
>  	inode->i_mapping->a_ops = &ceph_aops;
> -	inode->i_mapping->backing_dev_info =
> -		&ceph_sb_to_client(inode->i_sb)->backing_dev_info;
>  
>  	switch (inode->i_mode & S_IFMT) {
>  	case S_IFIFO:
> diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
> index 0c3ce464..2d4f372 100644
> --- a/fs/cifs/inode.c
> +++ b/fs/cifs/inode.c
> @@ -937,8 +937,6 @@ retry_iget5_locked:
>  			inode->i_flags |= S_NOATIME | S_NOCMTIME;
>  		if (inode->i_state & I_NEW) {
>  			inode->i_ino = hash;
> -			if (S_ISREG(inode->i_mode))
> -				inode->i_data.backing_dev_info = sb->s_bdi;
>  #ifdef CONFIG_CIFS_FSCACHE
>  			/* initialize per-inode cache cookie pointer */
>  			CIFS_I(inode)->fscache = NULL;
> diff --git a/fs/configfs/inode.c b/fs/configfs/inode.c
> index 0ad6b4d..65af861 100644
> --- a/fs/configfs/inode.c
> +++ b/fs/configfs/inode.c
> @@ -131,7 +131,6 @@ struct inode *configfs_new_inode(umode_t mode, struct configfs_dirent *sd,
>  	if (inode) {
>  		inode->i_ino = get_next_ino();
>  		inode->i_mapping->a_ops = &configfs_aops;
> -		inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
>  		inode->i_op = &configfs_inode_operations;
>  
>  		if (sd->s_iattr) {
> diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
> index 1686dc2..34b36a5 100644
> --- a/fs/ecryptfs/inode.c
> +++ b/fs/ecryptfs/inode.c
> @@ -67,7 +67,6 @@ static int ecryptfs_inode_set(struct inode *inode, void *opaque)
>  	inode->i_ino = lower_inode->i_ino;
>  	inode->i_version++;
>  	inode->i_mapping->a_ops = &ecryptfs_aops;
> -	inode->i_mapping->backing_dev_info = inode->i_sb->s_bdi;
>  
>  	if (S_ISLNK(inode->i_mode))
>  		inode->i_op = &ecryptfs_symlink_iops;
> diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
> index f1d3d4e..6fc91df 100644
> --- a/fs/exofs/inode.c
> +++ b/fs/exofs/inode.c
> @@ -1214,7 +1214,6 @@ struct inode *exofs_iget(struct super_block *sb, unsigned long ino)
>  		memcpy(oi->i_data, fcb.i_data, sizeof(fcb.i_data));
>  	}
>  
> -	inode->i_mapping->backing_dev_info = sb->s_bdi;
>  	if (S_ISREG(inode->i_mode)) {
>  		inode->i_op = &exofs_file_inode_operations;
>  		inode->i_fop = &exofs_file_operations;
> @@ -1314,7 +1313,6 @@ struct inode *exofs_new_inode(struct inode *dir, umode_t mode)
>  
>  	set_obj_2bcreated(oi);
>  
> -	inode->i_mapping->backing_dev_info = sb->s_bdi;
>  	inode_init_owner(inode, dir, mode);
>  	inode->i_ino = sbi->s_nextid++;
>  	inode->i_blkbits = EXOFS_BLKSHIFT;
> diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
> index 6749109..ea0aacd 100644
> --- a/fs/fuse/inode.c
> +++ b/fs/fuse/inode.c
> @@ -308,7 +308,6 @@ struct inode *fuse_iget(struct super_block *sb, u64 nodeid,
>  		if (!fc->writeback_cache || !S_ISREG(attr->mode))
>  			inode->i_flags |= S_NOCMTIME;
>  		inode->i_generation = generation;
> -		inode->i_data.backing_dev_info = &fc->bdi;
>  		fuse_init_inode(inode, attr);
>  		unlock_new_inode(inode);
>  	} else if ((inode->i_mode ^ attr->mode) & S_IFMT) {
> diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
> index a23524a..08ea717 100644
> --- a/fs/gfs2/glock.c
> +++ b/fs/gfs2/glock.c
> @@ -775,7 +775,6 @@ int gfs2_glock_get(struct gfs2_sbd *sdp, u64 number,
>  		mapping->flags = 0;
>  		mapping_set_gfp_mask(mapping, GFP_NOFS);
>  		mapping->private_data = NULL;
> -		mapping->backing_dev_info = s->s_bdi;
>  		mapping->writeback_index = 0;
>  	}
>  
> diff --git a/fs/gfs2/ops_fstype.c b/fs/gfs2/ops_fstype.c
> index 8633ad3..efc8e25 100644
> --- a/fs/gfs2/ops_fstype.c
> +++ b/fs/gfs2/ops_fstype.c
> @@ -112,7 +112,6 @@ static struct gfs2_sbd *init_sbd(struct super_block *sb)
>  	mapping->flags = 0;
>  	mapping_set_gfp_mask(mapping, GFP_NOFS);
>  	mapping->private_data = NULL;
> -	mapping->backing_dev_info = sb->s_bdi;
>  	mapping->writeback_index = 0;
>  
>  	spin_lock_init(&sdp->sd_log_lock);
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index de7c95c..c274aca 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -492,7 +492,6 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
>  		lockdep_set_class(&inode->i_mapping->i_mmap_rwsem,
>  				&hugetlbfs_i_mmap_rwsem_key);
>  		inode->i_mapping->a_ops = &hugetlbfs_aops;
> -		inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
>  		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>  		inode->i_mapping->private_data = resv_map;
>  		info = HUGETLBFS_I(inode);
> diff --git a/fs/inode.c b/fs/inode.c
> index aa149e7..e4e8caa 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -170,20 +170,7 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
>  	atomic_set(&mapping->i_mmap_writable, 0);
>  	mapping_set_gfp_mask(mapping, GFP_HIGHUSER_MOVABLE);
>  	mapping->private_data = NULL;
> -	mapping->backing_dev_info = &default_backing_dev_info;
>  	mapping->writeback_index = 0;
> -
> -	/*
> -	 * If the block_device provides a backing_dev_info for client
> -	 * inodes then use that.  Otherwise the inode share the bdev's
> -	 * backing_dev_info.
> -	 */
> -	if (sb->s_bdev) {
> -		struct backing_dev_info *bdi;
> -
> -		bdi = sb->s_bdev->bd_inode->i_mapping->backing_dev_info;
> -		mapping->backing_dev_info = bdi;
> -	}
>  	inode->i_private = NULL;
>  	inode->i_mapping = mapping;
>  	INIT_HLIST_HEAD(&inode->i_dentry);	/* buggered by rcu freeing */
> diff --git a/fs/kernfs/inode.c b/fs/kernfs/inode.c
> index 06f0688..9000874 100644
> --- a/fs/kernfs/inode.c
> +++ b/fs/kernfs/inode.c
> @@ -286,7 +286,6 @@ static void kernfs_init_inode(struct kernfs_node *kn, struct inode *inode)
>  	kernfs_get(kn);
>  	inode->i_private = kn;
>  	inode->i_mapping->a_ops = &kernfs_aops;
> -	inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
>  	inode->i_op = &kernfs_iops;
>  
>  	set_default_inode_attr(inode, kn->mode);
> diff --git a/fs/ncpfs/inode.c b/fs/ncpfs/inode.c
> index a699a3f..01a9e16 100644
> --- a/fs/ncpfs/inode.c
> +++ b/fs/ncpfs/inode.c
> @@ -267,7 +267,6 @@ ncp_iget(struct super_block *sb, struct ncp_entry_info *info)
>  	if (inode) {
>  		atomic_set(&NCP_FINFO(inode)->opened, info->opened);
>  
> -		inode->i_mapping->backing_dev_info = sb->s_bdi;
>  		inode->i_ino = info->ino;
>  		ncp_set_attr(inode, info);
>  		if (S_ISREG(inode->i_mode)) {
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 4bffe63..24aac72 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -387,7 +387,6 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
>  		if (S_ISREG(inode->i_mode)) {
>  			inode->i_fop = NFS_SB(sb)->nfs_client->rpc_ops->file_ops;
>  			inode->i_data.a_ops = &nfs_file_aops;
> -			inode->i_data.backing_dev_info = &NFS_SB(sb)->backing_dev_info;
>  		} else if (S_ISDIR(inode->i_mode)) {
>  			inode->i_op = NFS_SB(sb)->nfs_client->rpc_ops->dir_inode_ops;
>  			inode->i_fop = &nfs_dir_operations;
> diff --git a/fs/nilfs2/gcinode.c b/fs/nilfs2/gcinode.c
> index 57ceaf3..748ca23 100644
> --- a/fs/nilfs2/gcinode.c
> +++ b/fs/nilfs2/gcinode.c
> @@ -172,7 +172,6 @@ int nilfs_init_gcinode(struct inode *inode)
>  	inode->i_mode = S_IFREG;
>  	mapping_set_gfp_mask(inode->i_mapping, GFP_NOFS);
>  	inode->i_mapping->a_ops = &empty_aops;
> -	inode->i_mapping->backing_dev_info = inode->i_sb->s_bdi;
>  
>  	ii->i_flags = 0;
>  	nilfs_bmap_init_gc(ii->i_bmap);
> diff --git a/fs/nilfs2/mdt.c b/fs/nilfs2/mdt.c
> index c4dcd1d..892cf5f 100644
> --- a/fs/nilfs2/mdt.c
> +++ b/fs/nilfs2/mdt.c
> @@ -429,7 +429,6 @@ int nilfs_mdt_init(struct inode *inode, gfp_t gfp_mask, size_t objsz)
>  
>  	inode->i_mode = S_IFREG;
>  	mapping_set_gfp_mask(inode->i_mapping, gfp_mask);
> -	inode->i_mapping->backing_dev_info = inode->i_sb->s_bdi;
>  
>  	inode->i_op = &def_mdt_iops;
>  	inode->i_fop = &def_mdt_fops;
> @@ -457,13 +456,12 @@ int nilfs_mdt_setup_shadow_map(struct inode *inode,
>  			       struct nilfs_shadow_map *shadow)
>  {
>  	struct nilfs_mdt_info *mi = NILFS_MDT(inode);
> -	struct backing_dev_info *bdi = inode->i_sb->s_bdi;
>  
>  	INIT_LIST_HEAD(&shadow->frozen_buffers);
>  	address_space_init_once(&shadow->frozen_data);
> -	nilfs_mapping_init(&shadow->frozen_data, inode, bdi);
> +	nilfs_mapping_init(&shadow->frozen_data, inode);
>  	address_space_init_once(&shadow->frozen_btnodes);
> -	nilfs_mapping_init(&shadow->frozen_btnodes, inode, bdi);
> +	nilfs_mapping_init(&shadow->frozen_btnodes, inode);
>  	mi->mi_shadow = shadow;
>  	return 0;
>  }
> diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
> index da27664..700ecbc 100644
> --- a/fs/nilfs2/page.c
> +++ b/fs/nilfs2/page.c
> @@ -461,14 +461,12 @@ unsigned nilfs_page_count_clean_buffers(struct page *page,
>  	return nc;
>  }
>  
> -void nilfs_mapping_init(struct address_space *mapping, struct inode *inode,
> -			struct backing_dev_info *bdi)
> +void nilfs_mapping_init(struct address_space *mapping, struct inode *inode)
>  {
>  	mapping->host = inode;
>  	mapping->flags = 0;
>  	mapping_set_gfp_mask(mapping, GFP_NOFS);
>  	mapping->private_data = NULL;
> -	mapping->backing_dev_info = bdi;
>  	mapping->a_ops = &empty_aops;
>  }
>  
> diff --git a/fs/nilfs2/page.h b/fs/nilfs2/page.h
> index ef30c5c..a43b828 100644
> --- a/fs/nilfs2/page.h
> +++ b/fs/nilfs2/page.h
> @@ -57,8 +57,7 @@ int nilfs_copy_dirty_pages(struct address_space *, struct address_space *);
>  void nilfs_copy_back_pages(struct address_space *, struct address_space *);
>  void nilfs_clear_dirty_page(struct page *, bool);
>  void nilfs_clear_dirty_pages(struct address_space *, bool);
> -void nilfs_mapping_init(struct address_space *mapping, struct inode *inode,
> -			struct backing_dev_info *bdi);
> +void nilfs_mapping_init(struct address_space *mapping, struct inode *inode);
>  unsigned nilfs_page_count_clean_buffers(struct page *, unsigned, unsigned);
>  unsigned long nilfs_find_uncommitted_extent(struct inode *inode,
>  					    sector_t start_blk,
> diff --git a/fs/nilfs2/super.c b/fs/nilfs2/super.c
> index 3d4bbac..5bc2a1c 100644
> --- a/fs/nilfs2/super.c
> +++ b/fs/nilfs2/super.c
> @@ -166,7 +166,7 @@ struct inode *nilfs_alloc_inode(struct super_block *sb)
>  	ii->i_state = 0;
>  	ii->i_cno = 0;
>  	ii->vfs_inode.i_version = 1;
> -	nilfs_mapping_init(&ii->i_btnode_cache, &ii->vfs_inode, sb->s_bdi);
> +	nilfs_mapping_init(&ii->i_btnode_cache, &ii->vfs_inode);
>  	return &ii->vfs_inode;
>  }
>  
> diff --git a/fs/ocfs2/dlmfs/dlmfs.c b/fs/ocfs2/dlmfs/dlmfs.c
> index 6000d30..061ba6a 100644
> --- a/fs/ocfs2/dlmfs/dlmfs.c
> +++ b/fs/ocfs2/dlmfs/dlmfs.c
> @@ -398,7 +398,6 @@ static struct inode *dlmfs_get_root_inode(struct super_block *sb)
>  	if (inode) {
>  		inode->i_ino = get_next_ino();
>  		inode_init_owner(inode, NULL, mode);
> -		inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
>  		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>  		inc_nlink(inode);
>  
> @@ -422,7 +421,6 @@ static struct inode *dlmfs_get_inode(struct inode *parent,
>  
>  	inode->i_ino = get_next_ino();
>  	inode_init_owner(inode, parent, mode);
> -	inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
>  	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>  
>  	ip = DLMFS_I(inode);
> diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
> index ad4d712..889d558 100644
> --- a/fs/ramfs/inode.c
> +++ b/fs/ramfs/inode.c
> @@ -59,7 +59,6 @@ struct inode *ramfs_get_inode(struct super_block *sb,
>  		inode->i_ino = get_next_ino();
>  		inode_init_owner(inode, dir, mode);
>  		inode->i_mapping->a_ops = &ramfs_aops;
> -		inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
>  		mapping_set_gfp_mask(inode->i_mapping, GFP_HIGHUSER);
>  		mapping_set_unevictable(inode->i_mapping);
>  		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
> diff --git a/fs/romfs/super.c b/fs/romfs/super.c
> index e98dd88..268733c 100644
> --- a/fs/romfs/super.c
> +++ b/fs/romfs/super.c
> @@ -355,9 +355,6 @@ static struct inode *romfs_iget(struct super_block *sb, unsigned long pos)
>  	case ROMFH_REG:
>  		i->i_fop = &romfs_ro_fops;
>  		i->i_data.a_ops = &romfs_aops;
> -		if (i->i_sb->s_mtd)
> -			i->i_data.backing_dev_info =
> -				i->i_sb->s_mtd->backing_dev_info;
>  		if (nextfh & ROMFH_EXEC)
>  			mode |= S_IXUGO;
>  		break;
> diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
> index ea41649..c49b198 100644
> --- a/fs/ubifs/dir.c
> +++ b/fs/ubifs/dir.c
> @@ -108,8 +108,6 @@ struct inode *ubifs_new_inode(struct ubifs_info *c, const struct inode *dir,
>  	inode->i_mtime = inode->i_atime = inode->i_ctime =
>  			 ubifs_current_time(inode);
>  	inode->i_mapping->nrpages = 0;
> -	/* Disable readahead */
> -	inode->i_mapping->backing_dev_info = &c->bdi;
>  
>  	switch (mode & S_IFMT) {
>  	case S_IFREG:
> diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
> index ed93dc6..6197154 100644
> --- a/fs/ubifs/super.c
> +++ b/fs/ubifs/super.c
> @@ -156,9 +156,6 @@ struct inode *ubifs_iget(struct super_block *sb, unsigned long inum)
>  	if (err)
>  		goto out_invalid;
>  
> -	/* Disable read-ahead */
> -	inode->i_mapping->backing_dev_info = &c->bdi;
> -
>  	switch (inode->i_mode & S_IFMT) {
>  	case S_IFREG:
>  		inode->i_mapping->a_ops = &ubifs_file_address_operations;
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 7939a2e..6484bb4 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -34,6 +34,7 @@
>  #include <asm/byteorder.h>
>  #include <uapi/linux/fs.h>
>  
> +struct backing_dev_info;
>  struct export_operations;
>  struct hd_geometry;
>  struct iovec;
> @@ -394,7 +395,6 @@ int pagecache_write_end(struct file *, struct address_space *mapping,
>  				loff_t pos, unsigned len, unsigned copied,
>  				struct page *page, void *fsdata);
>  
> -struct backing_dev_info;
>  struct address_space {
>  	struct inode		*host;		/* owner: inode, block_device */
>  	struct radix_tree_root	page_tree;	/* radix tree of all pages */
> @@ -409,7 +409,6 @@ struct address_space {
>  	pgoff_t			writeback_index;/* writeback starts here */
>  	const struct address_space_operations *a_ops;	/* methods */
>  	unsigned long		flags;		/* error bits/gfp mask */
> -	struct backing_dev_info *backing_dev_info; /* device readahead, etc */
>  	spinlock_t		private_lock;	/* for use by the address_space */
>  	struct list_head	private_list;	/* ditto */
>  	void			*private_data;	/* ditto */
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 16c6895..52e0c76 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -24,7 +24,6 @@ struct backing_dev_info noop_backing_dev_info = {
>  	.name		= "noop",
>  	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
>  };
> -EXPORT_SYMBOL_GPL(noop_backing_dev_info);
>  
>  static struct class *bdi_class;
>  
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 1b77eaf..4c61d3d 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1410,7 +1410,6 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
>  		inode->i_ino = get_next_ino();
>  		inode_init_owner(inode, dir, mode);
>  		inode->i_blocks = 0;
> -		inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
>  		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>  		inode->i_generation = get_seconds();
>  		info = SHMEM_I(inode);
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 1c137b6..405923f 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -37,7 +37,6 @@ struct address_space swapper_spaces[MAX_SWAPFILES] = {
>  		.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
>  		.i_mmap_writable = ATOMIC_INIT(0),
>  		.a_ops		= &swap_aops,
> -		.backing_dev_info = &noop_backing_dev_info,
>  	}
>  };
>  
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
