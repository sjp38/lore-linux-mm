Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9E83B6B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 09:05:52 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so11107573wiw.4
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:05:52 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ep16si26294223wid.86.2015.01.14.06.05.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 06:05:50 -0800 (PST)
Date: Wed, 14 Jan 2015 15:05:46 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 12/12] fs: remove default_backing_dev_info
Message-ID: <20150114140546.GM10215@quack.suse.cz>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
 <1421228561-16857-13-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421228561-16857-13-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Wed 14-01-15 10:42:41, Christoph Hellwig wrote:
> Now that default_backing_dev_info is not used for writeback purposes we can
> git rid of it easily:
> 
>  - instead of using it's name for tracing unregistered bdi we just use
>    "unknown"
>  - btrfs and ceph can just assign the default read ahead window themselves
>    like several other filesystems already do.
>  - we can assign noop_backing_dev_info as the default one in alloc_super.
>    All filesystems already either assigned their own or
>    noop_backing_dev_info.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Tejun Heo <tj@kernel.org>
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/btrfs/disk-io.c               | 2 +-
>  fs/ceph/super.c                  | 2 +-
>  fs/super.c                       | 8 ++------
>  include/linux/backing-dev.h      | 1 -
>  include/trace/events/writeback.h | 6 ++----
>  mm/backing-dev.c                 | 9 ---------
>  6 files changed, 6 insertions(+), 22 deletions(-)
> 
> diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
> index 1ec872e..1afb182 100644
> --- a/fs/btrfs/disk-io.c
> +++ b/fs/btrfs/disk-io.c
> @@ -1719,7 +1719,7 @@ static int setup_bdi(struct btrfs_fs_info *info, struct backing_dev_info *bdi)
>  	if (err)
>  		return err;
>  
> -	bdi->ra_pages	= default_backing_dev_info.ra_pages;
> +	bdi->ra_pages = VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE;
>  	bdi->congested_fn	= btrfs_congested_fn;
>  	bdi->congested_data	= info;
>  	return 0;
> diff --git a/fs/ceph/super.c b/fs/ceph/super.c
> index e350cc1..5ae6258 100644
> --- a/fs/ceph/super.c
> +++ b/fs/ceph/super.c
> @@ -899,7 +899,7 @@ static int ceph_register_bdi(struct super_block *sb,
>  			>> PAGE_SHIFT;
>  	else
>  		fsc->backing_dev_info.ra_pages =
> -			default_backing_dev_info.ra_pages;
> +			VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE;
>  
>  	err = bdi_register(&fsc->backing_dev_info, NULL, "ceph-%ld",
>  			   atomic_long_inc_return(&bdi_seq));
> diff --git a/fs/super.c b/fs/super.c
> index eae088f..3b4dada 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -185,8 +185,8 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
>  	}
>  	init_waitqueue_head(&s->s_writers.wait);
>  	init_waitqueue_head(&s->s_writers.wait_unfrozen);
> +	s->s_bdi = &noop_backing_dev_info;
>  	s->s_flags = flags;
> -	s->s_bdi = &default_backing_dev_info;
>  	INIT_HLIST_NODE(&s->s_instances);
>  	INIT_HLIST_BL_HEAD(&s->s_anon);
>  	INIT_LIST_HEAD(&s->s_inodes);
> @@ -863,10 +863,7 @@ EXPORT_SYMBOL(free_anon_bdev);
>  
>  int set_anon_super(struct super_block *s, void *data)
>  {
> -	int error = get_anon_bdev(&s->s_dev);
> -	if (!error)
> -		s->s_bdi = &noop_backing_dev_info;
> -	return error;
> +	return get_anon_bdev(&s->s_dev);
>  }
>  
>  EXPORT_SYMBOL(set_anon_super);
> @@ -1111,7 +1108,6 @@ mount_fs(struct file_system_type *type, int flags, const char *name, void *data)
>  	sb = root->d_sb;
>  	BUG_ON(!sb);
>  	WARN_ON(!sb->s_bdi);
> -	WARN_ON(sb->s_bdi == &default_backing_dev_info);
>  	sb->s_flags |= MS_BORN;
>  
>  	error = security_sb_kern_mount(sb, flags, secdata);
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index ed59dee..d94077f 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -241,7 +241,6 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
>  #define BDI_CAP_NO_ACCT_AND_WRITEBACK \
>  	(BDI_CAP_NO_WRITEBACK | BDI_CAP_NO_ACCT_DIRTY | BDI_CAP_NO_ACCT_WB)
>  
> -extern struct backing_dev_info default_backing_dev_info;
>  extern struct backing_dev_info noop_backing_dev_info;
>  
>  int writeback_in_progress(struct backing_dev_info *bdi);
> diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
> index 74f5207..0e93109 100644
> --- a/include/trace/events/writeback.h
> +++ b/include/trace/events/writeback.h
> @@ -156,10 +156,8 @@ DECLARE_EVENT_CLASS(writeback_work_class,
>  		__field(int, reason)
>  	),
>  	TP_fast_assign(
> -		struct device *dev = bdi->dev;
> -		if (!dev)
> -			dev = default_backing_dev_info.dev;
> -		strncpy(__entry->name, dev_name(dev), 32);
> +		strncpy(__entry->name,
> +			bdi->dev ? dev_name(bdi->dev) : "(unknown)", 32);
>  		__entry->nr_pages = work->nr_pages;
>  		__entry->sb_dev = work->sb ? work->sb->s_dev : 0;
>  		__entry->sync_mode = work->sync_mode;
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 3ebba25..c49026d 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -14,12 +14,6 @@
>  
>  static atomic_long_t bdi_seq = ATOMIC_LONG_INIT(0);
>  
> -struct backing_dev_info default_backing_dev_info = {
> -	.name		= "default",
> -	.ra_pages	= VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE,
> -};
> -EXPORT_SYMBOL_GPL(default_backing_dev_info);
> -
>  struct backing_dev_info noop_backing_dev_info = {
>  	.name		= "noop",
>  	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
> @@ -250,9 +244,6 @@ static int __init default_bdi_init(void)
>  	if (!bdi_wq)
>  		return -ENOMEM;
>  
> -	err = bdi_init(&default_backing_dev_info);
> -	if (!err)
> -		bdi_register(&default_backing_dev_info, NULL, "default");
>  	err = bdi_init(&noop_backing_dev_info);
>  
>  	return err;
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
