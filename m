Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5FE406B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 07:41:20 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id q59so8506179wes.8
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 04:41:19 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d9si25941128wix.71.2015.01.14.04.41.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 04:41:18 -0800 (PST)
Date: Wed, 14 Jan 2015 13:41:13 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 01/12] fs: deduplicate noop_backing_dev_info
Message-ID: <20150114124113.GD10215@quack.suse.cz>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
 <1421228561-16857-2-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421228561-16857-2-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Wed 14-01-15 10:42:30, Christoph Hellwig wrote:
> hugetlbfs, kernfs and dlmfs can simply use noop_backing_dev_info instead
> of creating a local duplicate.
  Looks good.
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Acked-by: Tejun Heo <tj@kernel.org>
> ---
>  fs/hugetlbfs/inode.c        | 14 +-------------
>  fs/kernfs/inode.c           | 14 +-------------
>  fs/kernfs/kernfs-internal.h |  1 -
>  fs/kernfs/mount.c           |  1 -
>  fs/ocfs2/dlmfs/dlmfs.c      | 16 ++--------------
>  5 files changed, 4 insertions(+), 42 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 5eba47f..de7c95c 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -62,12 +62,6 @@ static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
>  	return container_of(inode, struct hugetlbfs_inode_info, vfs_inode);
>  }
>  
> -static struct backing_dev_info hugetlbfs_backing_dev_info = {
> -	.name		= "hugetlbfs",
> -	.ra_pages	= 0,	/* No readahead */
> -	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
> -};
> -
>  int sysctl_hugetlb_shm_group;
>  
>  enum {
> @@ -498,7 +492,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
>  		lockdep_set_class(&inode->i_mapping->i_mmap_rwsem,
>  				&hugetlbfs_i_mmap_rwsem_key);
>  		inode->i_mapping->a_ops = &hugetlbfs_aops;
> -		inode->i_mapping->backing_dev_info =&hugetlbfs_backing_dev_info;
> +		inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
>  		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>  		inode->i_mapping->private_data = resv_map;
>  		info = HUGETLBFS_I(inode);
> @@ -1032,10 +1026,6 @@ static int __init init_hugetlbfs_fs(void)
>  		return -ENOTSUPP;
>  	}
>  
> -	error = bdi_init(&hugetlbfs_backing_dev_info);
> -	if (error)
> -		return error;
> -
>  	error = -ENOMEM;
>  	hugetlbfs_inode_cachep = kmem_cache_create("hugetlbfs_inode_cache",
>  					sizeof(struct hugetlbfs_inode_info),
> @@ -1071,7 +1061,6 @@ static int __init init_hugetlbfs_fs(void)
>   out:
>  	kmem_cache_destroy(hugetlbfs_inode_cachep);
>   out2:
> -	bdi_destroy(&hugetlbfs_backing_dev_info);
>  	return error;
>  }
>  
> @@ -1091,7 +1080,6 @@ static void __exit exit_hugetlbfs_fs(void)
>  	for_each_hstate(h)
>  		kern_unmount(hugetlbfs_vfsmount[i++]);
>  	unregister_filesystem(&hugetlbfs_fs_type);
> -	bdi_destroy(&hugetlbfs_backing_dev_info);
>  }
>  
>  module_init(init_hugetlbfs_fs)
> diff --git a/fs/kernfs/inode.c b/fs/kernfs/inode.c
> index 9852176..06f0688 100644
> --- a/fs/kernfs/inode.c
> +++ b/fs/kernfs/inode.c
> @@ -24,12 +24,6 @@ static const struct address_space_operations kernfs_aops = {
>  	.write_end	= simple_write_end,
>  };
>  
> -static struct backing_dev_info kernfs_bdi = {
> -	.name		= "kernfs",
> -	.ra_pages	= 0,	/* No readahead */
> -	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
> -};
> -
>  static const struct inode_operations kernfs_iops = {
>  	.permission	= kernfs_iop_permission,
>  	.setattr	= kernfs_iop_setattr,
> @@ -40,12 +34,6 @@ static const struct inode_operations kernfs_iops = {
>  	.listxattr	= kernfs_iop_listxattr,
>  };
>  
> -void __init kernfs_inode_init(void)
> -{
> -	if (bdi_init(&kernfs_bdi))
> -		panic("failed to init kernfs_bdi");
> -}
> -
>  static struct kernfs_iattrs *kernfs_iattrs(struct kernfs_node *kn)
>  {
>  	static DEFINE_MUTEX(iattr_mutex);
> @@ -298,7 +286,7 @@ static void kernfs_init_inode(struct kernfs_node *kn, struct inode *inode)
>  	kernfs_get(kn);
>  	inode->i_private = kn;
>  	inode->i_mapping->a_ops = &kernfs_aops;
> -	inode->i_mapping->backing_dev_info = &kernfs_bdi;
> +	inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
>  	inode->i_op = &kernfs_iops;
>  
>  	set_default_inode_attr(inode, kn->mode);
> diff --git a/fs/kernfs/kernfs-internal.h b/fs/kernfs/kernfs-internal.h
> index dc84a3e..af9fa74 100644
> --- a/fs/kernfs/kernfs-internal.h
> +++ b/fs/kernfs/kernfs-internal.h
> @@ -88,7 +88,6 @@ int kernfs_iop_removexattr(struct dentry *dentry, const char *name);
>  ssize_t kernfs_iop_getxattr(struct dentry *dentry, const char *name, void *buf,
>  			    size_t size);
>  ssize_t kernfs_iop_listxattr(struct dentry *dentry, char *buf, size_t size);
> -void kernfs_inode_init(void);
>  
>  /*
>   * dir.c
> diff --git a/fs/kernfs/mount.c b/fs/kernfs/mount.c
> index f973ae9..8eaf417 100644
> --- a/fs/kernfs/mount.c
> +++ b/fs/kernfs/mount.c
> @@ -246,5 +246,4 @@ void __init kernfs_init(void)
>  	kernfs_node_cache = kmem_cache_create("kernfs_node_cache",
>  					      sizeof(struct kernfs_node),
>  					      0, SLAB_PANIC, NULL);
> -	kernfs_inode_init();
>  }
> diff --git a/fs/ocfs2/dlmfs/dlmfs.c b/fs/ocfs2/dlmfs/dlmfs.c
> index 57c40e3..6000d30 100644
> --- a/fs/ocfs2/dlmfs/dlmfs.c
> +++ b/fs/ocfs2/dlmfs/dlmfs.c
> @@ -390,12 +390,6 @@ clear_fields:
>  	ip->ip_conn = NULL;
>  }
>  
> -static struct backing_dev_info dlmfs_backing_dev_info = {
> -	.name		= "ocfs2-dlmfs",
> -	.ra_pages	= 0,	/* No readahead */
> -	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
> -};
> -
>  static struct inode *dlmfs_get_root_inode(struct super_block *sb)
>  {
>  	struct inode *inode = new_inode(sb);
> @@ -404,7 +398,7 @@ static struct inode *dlmfs_get_root_inode(struct super_block *sb)
>  	if (inode) {
>  		inode->i_ino = get_next_ino();
>  		inode_init_owner(inode, NULL, mode);
> -		inode->i_mapping->backing_dev_info = &dlmfs_backing_dev_info;
> +		inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
>  		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>  		inc_nlink(inode);
>  
> @@ -428,7 +422,7 @@ static struct inode *dlmfs_get_inode(struct inode *parent,
>  
>  	inode->i_ino = get_next_ino();
>  	inode_init_owner(inode, parent, mode);
> -	inode->i_mapping->backing_dev_info = &dlmfs_backing_dev_info;
> +	inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
>  	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>  
>  	ip = DLMFS_I(inode);
> @@ -643,10 +637,6 @@ static int __init init_dlmfs_fs(void)
>  	int status;
>  	int cleanup_inode = 0, cleanup_worker = 0;
>  
> -	status = bdi_init(&dlmfs_backing_dev_info);
> -	if (status)
> -		return status;
> -
>  	dlmfs_inode_cache = kmem_cache_create("dlmfs_inode_cache",
>  				sizeof(struct dlmfs_inode_private),
>  				0, (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
> @@ -673,7 +663,6 @@ bail:
>  			kmem_cache_destroy(dlmfs_inode_cache);
>  		if (cleanup_worker)
>  			destroy_workqueue(user_dlm_worker);
> -		bdi_destroy(&dlmfs_backing_dev_info);
>  	} else
>  		printk("OCFS2 User DLM kernel interface loaded\n");
>  	return status;
> @@ -693,7 +682,6 @@ static void __exit exit_dlmfs_fs(void)
>  	rcu_barrier();
>  	kmem_cache_destroy(dlmfs_inode_cache);
>  
> -	bdi_destroy(&dlmfs_backing_dev_info);
>  }
>  
>  MODULE_AUTHOR("Oracle");
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
