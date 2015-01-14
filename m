Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id B909D6B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 07:59:01 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ho1so2265795wib.0
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 04:59:01 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cg6si3422675wib.42.2015.01.14.04.59.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 04:59:00 -0800 (PST)
Date: Wed, 14 Jan 2015 13:58:56 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 04/12] block_dev: only write bdev inode on close
Message-ID: <20150114125856.GF10215@quack.suse.cz>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
 <1421228561-16857-5-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421228561-16857-5-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Wed 14-01-15 10:42:33, Christoph Hellwig wrote:
> Since 018a17bdc865 ("bdi: reimplement bdev_inode_switch_bdi()") the
> block device code writes out all dirty data whenever switching the
> backing_dev_info for a block device inode.  But a block device inode can
> only be dirtied when it is in use, which means we only have to write it
> out on the final blkdev_put, but not when doing a blkdev_get.
> 
> Factoring out the write out from the bdi list switch prepares from
> removing the list switch later in the series.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Acked-by: Tejun Heo <tj@kernel.org>
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/block_dev.c | 31 +++++++++++++++++++------------
>  1 file changed, 19 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index b48c41b..026ca7b 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -49,6 +49,17 @@ inline struct block_device *I_BDEV(struct inode *inode)
>  }
>  EXPORT_SYMBOL(I_BDEV);
>  
> +static void bdev_write_inode(struct inode *inode)
> +{
> +	spin_lock(&inode->i_lock);
> +	while (inode->i_state & I_DIRTY) {
> +		spin_unlock(&inode->i_lock);
> +		WARN_ON_ONCE(write_inode_now(inode, true));
> +		spin_lock(&inode->i_lock);
> +	}
> +	spin_unlock(&inode->i_lock);
> +}
> +
>  /*
>   * Move the inode from its current bdi to a new bdi.  Make sure the inode
>   * is clean before moving so that it doesn't linger on the old bdi.
> @@ -56,16 +67,10 @@ EXPORT_SYMBOL(I_BDEV);
>  static void bdev_inode_switch_bdi(struct inode *inode,
>  			struct backing_dev_info *dst)
>  {
> -	while (true) {
> -		spin_lock(&inode->i_lock);
> -		if (!(inode->i_state & I_DIRTY)) {
> -			inode->i_data.backing_dev_info = dst;
> -			spin_unlock(&inode->i_lock);
> -			return;
> -		}
> -		spin_unlock(&inode->i_lock);
> -		WARN_ON_ONCE(write_inode_now(inode, true));
> -	}
> +	spin_lock(&inode->i_lock);
> +	WARN_ON_ONCE(inode->i_state & I_DIRTY);
> +	inode->i_data.backing_dev_info = dst;
> +	spin_unlock(&inode->i_lock);
>  }
>  
>  /* Kill _all_ buffers and pagecache , dirty or not.. */
> @@ -1464,9 +1469,11 @@ static void __blkdev_put(struct block_device *bdev, fmode_t mode, int for_part)
>  		WARN_ON_ONCE(bdev->bd_holders);
>  		sync_blockdev(bdev);
>  		kill_bdev(bdev);
> -		/* ->release can cause the old bdi to disappear,
> -		 * so must switch it out first
> +		/*
> +		 * ->release can cause the queue to disappear, so flush all
> +		 * dirty data before.
>  		 */
> +		bdev_write_inode(bdev->bd_inode);
>  		bdev_inode_switch_bdi(bdev->bd_inode,
>  					&default_backing_dev_info);
>  	}
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
