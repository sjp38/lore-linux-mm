Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id B1F686B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 07:48:01 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id y19so8708824wgg.4
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 04:48:01 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u9si47634273wja.95.2015.01.14.04.48.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 04:48:00 -0800 (PST)
Date: Wed, 14 Jan 2015 13:47:55 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 02/12] fs: kill BDI_CAP_SWAP_BACKED
Message-ID: <20150114124755.GE10215@quack.suse.cz>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
 <1421228561-16857-3-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421228561-16857-3-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Wed 14-01-15 10:42:31, Christoph Hellwig wrote:
> This bdi flag isn't too useful - we can determine that a vma is backed by
> either swap or shmem trivially in the caller.
> 
> This also allows removing the backing_dev_info instaces for swap and shmem
> in favor of noop_backing_dev_info.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Tejun Heo <tj@kernel.org>
  Looks good to me. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/backing-dev.h | 13 -------------
>  mm/madvise.c                | 17 ++++++++++-------
>  mm/shmem.c                  | 25 +++++++------------------
>  mm/swap.c                   |  2 --
>  mm/swap_state.c             |  7 +------
>  5 files changed, 18 insertions(+), 46 deletions(-)
> 
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 5da6012..e936cea 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -238,8 +238,6 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
>   * BDI_CAP_WRITE_MAP:      Can be mapped for writing
>   * BDI_CAP_EXEC_MAP:       Can be mapped for execution
>   *
> - * BDI_CAP_SWAP_BACKED:    Count shmem/tmpfs objects as swap-backed.
> - *
>   * BDI_CAP_STRICTLIMIT:    Keep number of dirty pages below bdi threshold.
>   */
>  #define BDI_CAP_NO_ACCT_DIRTY	0x00000001
> @@ -250,7 +248,6 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
>  #define BDI_CAP_WRITE_MAP	0x00000020
>  #define BDI_CAP_EXEC_MAP	0x00000040
>  #define BDI_CAP_NO_ACCT_WB	0x00000080
> -#define BDI_CAP_SWAP_BACKED	0x00000100
>  #define BDI_CAP_STABLE_WRITES	0x00000200
>  #define BDI_CAP_STRICTLIMIT	0x00000400
>  
> @@ -329,11 +326,6 @@ static inline bool bdi_cap_account_writeback(struct backing_dev_info *bdi)
>  				      BDI_CAP_NO_WRITEBACK));
>  }
>  
> -static inline bool bdi_cap_swap_backed(struct backing_dev_info *bdi)
> -{
> -	return bdi->capabilities & BDI_CAP_SWAP_BACKED;
> -}
> -
>  static inline bool mapping_cap_writeback_dirty(struct address_space *mapping)
>  {
>  	return bdi_cap_writeback_dirty(mapping->backing_dev_info);
> @@ -344,11 +336,6 @@ static inline bool mapping_cap_account_dirty(struct address_space *mapping)
>  	return bdi_cap_account_dirty(mapping->backing_dev_info);
>  }
>  
> -static inline bool mapping_cap_swap_backed(struct address_space *mapping)
> -{
> -	return bdi_cap_swap_backed(mapping->backing_dev_info);
> -}
> -
>  static inline int bdi_sched_wait(void *word)
>  {
>  	schedule();
> diff --git a/mm/madvise.c b/mm/madvise.c
> index a271adc..1383a89 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -222,19 +222,22 @@ static long madvise_willneed(struct vm_area_struct *vma,
>  	struct file *file = vma->vm_file;
>  
>  #ifdef CONFIG_SWAP
> -	if (!file || mapping_cap_swap_backed(file->f_mapping)) {
> +	if (!file) {
>  		*prev = vma;
> -		if (!file)
> -			force_swapin_readahead(vma, start, end);
> -		else
> -			force_shm_swapin_readahead(vma, start, end,
> -						file->f_mapping);
> +		force_swapin_readahead(vma, start, end);
>  		return 0;
>  	}
> -#endif
>  
> +	if (shmem_mapping(file->f_mapping)) {
> +		*prev = vma;
> +		force_shm_swapin_readahead(vma, start, end,
> +					file->f_mapping);
> +		return 0;
> +	}
> +#else
>  	if (!file)
>  		return -EBADF;
> +#endif
>  
>  	if (file->f_mapping->a_ops->get_xip_mem) {
>  		/* no bad return value, but ignore advice */
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 73ba1df..1b77eaf 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -191,11 +191,6 @@ static const struct inode_operations shmem_dir_inode_operations;
>  static const struct inode_operations shmem_special_inode_operations;
>  static const struct vm_operations_struct shmem_vm_ops;
>  
> -static struct backing_dev_info shmem_backing_dev_info  __read_mostly = {
> -	.ra_pages	= 0,	/* No readahead */
> -	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK | BDI_CAP_SWAP_BACKED,
> -};
> -
>  static LIST_HEAD(shmem_swaplist);
>  static DEFINE_MUTEX(shmem_swaplist_mutex);
>  
> @@ -765,11 +760,11 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
>  		goto redirty;
>  
>  	/*
> -	 * shmem_backing_dev_info's capabilities prevent regular writeback or
> -	 * sync from ever calling shmem_writepage; but a stacking filesystem
> -	 * might use ->writepage of its underlying filesystem, in which case
> -	 * tmpfs should write out to swap only in response to memory pressure,
> -	 * and not for the writeback threads or sync.
> +	 * Our capabilities prevent regular writeback or sync from ever calling
> +	 * shmem_writepage; but a stacking filesystem might use ->writepage of
> +	 * its underlying filesystem, in which case tmpfs should write out to
> +	 * swap only in response to memory pressure, and not for the writeback
> +	 * threads or sync.
>  	 */
>  	if (!wbc->for_reclaim) {
>  		WARN_ON_ONCE(1);	/* Still happens? Tell us about it! */
> @@ -1415,7 +1410,7 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
>  		inode->i_ino = get_next_ino();
>  		inode_init_owner(inode, dir, mode);
>  		inode->i_blocks = 0;
> -		inode->i_mapping->backing_dev_info = &shmem_backing_dev_info;
> +		inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
>  		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>  		inode->i_generation = get_seconds();
>  		info = SHMEM_I(inode);
> @@ -1461,7 +1456,7 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
>  
>  bool shmem_mapping(struct address_space *mapping)
>  {
> -	return mapping->backing_dev_info == &shmem_backing_dev_info;
> +	return mapping->host->i_sb->s_op == &shmem_ops;
>  }
>  
>  #ifdef CONFIG_TMPFS
> @@ -3226,10 +3221,6 @@ int __init shmem_init(void)
>  	if (shmem_inode_cachep)
>  		return 0;
>  
> -	error = bdi_init(&shmem_backing_dev_info);
> -	if (error)
> -		goto out4;
> -
>  	error = shmem_init_inodecache();
>  	if (error)
>  		goto out3;
> @@ -3253,8 +3244,6 @@ out1:
>  out2:
>  	shmem_destroy_inodecache();
>  out3:
> -	bdi_destroy(&shmem_backing_dev_info);
> -out4:
>  	shm_mnt = ERR_PTR(error);
>  	return error;
>  }
> diff --git a/mm/swap.c b/mm/swap.c
> index 8a12b33..4e0109a 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -1138,8 +1138,6 @@ void __init swap_setup(void)
>  #ifdef CONFIG_SWAP
>  	int i;
>  
> -	if (bdi_init(swapper_spaces[0].backing_dev_info))
> -		panic("Failed to init swap bdi");
>  	for (i = 0; i < MAX_SWAPFILES; i++) {
>  		spin_lock_init(&swapper_spaces[i].tree_lock);
>  		INIT_LIST_HEAD(&swapper_spaces[i].i_mmap_nonlinear);
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 9711342..1c137b6 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -32,17 +32,12 @@ static const struct address_space_operations swap_aops = {
>  #endif
>  };
>  
> -static struct backing_dev_info swap_backing_dev_info = {
> -	.name		= "swap",
> -	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK | BDI_CAP_SWAP_BACKED,
> -};
> -
>  struct address_space swapper_spaces[MAX_SWAPFILES] = {
>  	[0 ... MAX_SWAPFILES - 1] = {
>  		.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
>  		.i_mmap_writable = ATOMIC_INIT(0),
>  		.a_ops		= &swap_aops,
> -		.backing_dev_info = &swap_backing_dev_info,
> +		.backing_dev_info = &noop_backing_dev_info,
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
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
