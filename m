Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 60C636B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 08:52:04 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id p10so8865907wes.9
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 05:52:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kz5si47789408wjc.167.2015.01.14.05.52.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 05:52:02 -0800 (PST)
Date: Wed, 14 Jan 2015 14:51:58 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 10/12] nfs: don't call bdi_unregister
Message-ID: <20150114135158.GK10215@quack.suse.cz>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
 <1421228561-16857-11-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421228561-16857-11-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Wed 14-01-15 10:42:39, Christoph Hellwig wrote:
> bdi_destroy already does all the work, and if we delay freeing the
> anon bdev we can get away with just that single call.
> 
> Addintionally remove the call during mount failure, as
> deactivate_super_locked will already call ->kill_sb and clean up
> the bdi for us.
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/internal.h  |  1 -
>  fs/nfs/nfs4super.c |  1 -
>  fs/nfs/super.c     | 24 ++++++------------------
>  3 files changed, 6 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index efaa31c..f519d41 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -416,7 +416,6 @@ int  nfs_show_options(struct seq_file *, struct dentry *);
>  int  nfs_show_devname(struct seq_file *, struct dentry *);
>  int  nfs_show_path(struct seq_file *, struct dentry *);
>  int  nfs_show_stats(struct seq_file *, struct dentry *);
> -void nfs_put_super(struct super_block *);
>  int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
>  
>  /* write.c */
> diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
> index 6f340f0..ab30a3a 100644
> --- a/fs/nfs/nfs4super.c
> +++ b/fs/nfs/nfs4super.c
> @@ -53,7 +53,6 @@ static const struct super_operations nfs4_sops = {
>  	.destroy_inode	= nfs_destroy_inode,
>  	.write_inode	= nfs4_write_inode,
>  	.drop_inode	= nfs_drop_inode,
> -	.put_super	= nfs_put_super,
>  	.statfs		= nfs_statfs,
>  	.evict_inode	= nfs4_evict_inode,
>  	.umount_begin	= nfs_umount_begin,
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 31a11b0..6ec4fe2 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -311,7 +311,6 @@ const struct super_operations nfs_sops = {
>  	.destroy_inode	= nfs_destroy_inode,
>  	.write_inode	= nfs_write_inode,
>  	.drop_inode	= nfs_drop_inode,
> -	.put_super	= nfs_put_super,
>  	.statfs		= nfs_statfs,
>  	.evict_inode	= nfs_evict_inode,
>  	.umount_begin	= nfs_umount_begin,
> @@ -2569,7 +2568,7 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
>  		error = nfs_bdi_register(server);
>  		if (error) {
>  			mntroot = ERR_PTR(error);
> -			goto error_splat_bdi;
> +			goto error_splat_super;
>  		}
>  		server->super = s;
>  	}
> @@ -2601,9 +2600,6 @@ error_splat_root:
>  	dput(mntroot);
>  	mntroot = ERR_PTR(error);
>  error_splat_super:
> -	if (server && !s->s_root)
> -		bdi_unregister(&server->backing_dev_info);
> -error_splat_bdi:
>  	deactivate_locked_super(s);
>  	goto out;
>  }
> @@ -2651,27 +2647,19 @@ out:
>  EXPORT_SYMBOL_GPL(nfs_fs_mount);
>  
>  /*
> - * Ensure that we unregister the bdi before kill_anon_super
> - * releases the device name
> - */
> -void nfs_put_super(struct super_block *s)
> -{
> -	struct nfs_server *server = NFS_SB(s);
> -
> -	bdi_unregister(&server->backing_dev_info);
> -}
> -EXPORT_SYMBOL_GPL(nfs_put_super);
> -
> -/*
>   * Destroy an NFS2/3 superblock
>   */
>  void nfs_kill_super(struct super_block *s)
>  {
>  	struct nfs_server *server = NFS_SB(s);
> +	dev_t dev = s->s_dev;
> +
> +	generic_shutdown_super(s);
>  
> -	kill_anon_super(s);
>  	nfs_fscache_release_super_cookie(s);
> +
>  	nfs_free_server(server);
> +	free_anon_bdev(dev);
>  }
>  EXPORT_SYMBOL_GPL(nfs_kill_super);
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
