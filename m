Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 957136B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 08:59:19 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id w62so8876898wes.13
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 05:59:19 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ds1si3712430wib.36.2015.01.14.05.59.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 05:59:18 -0800 (PST)
Date: Wed, 14 Jan 2015 14:59:14 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 11/12] fs: don't reassign dirty inodes to
 default_backing_dev_info
Message-ID: <20150114135914.GL10215@quack.suse.cz>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
 <1421228561-16857-12-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421228561-16857-12-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Wed 14-01-15 10:42:40, Christoph Hellwig wrote:
> If we have dirty inodes we need to call the filesystem for it, even if the
> device has been removed and the filesystem will error out early.  The
> current code does that by reassining all dirty inodes to the default
> backing_dev_info when a bdi is unlinked, but that's pretty pointless given
> that the bdi must always outlive the super block.
> 
> Instead of stopping writeback at unregister time and moving inodes to the
> default bdi just keep the current bdi alive until it is destroyed.  The
> containing objects of the bdi ensure this doesn't happen until all
> writeback has finished by erroring out.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Tejun Heo <tj@kernel.org>
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

One nit below:


> ---
>  mm/backing-dev.c | 91 +++++++++++++++-----------------------------------------
>  1 file changed, 24 insertions(+), 67 deletions(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 52e0c76..3ebba25 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
...
> @@ -471,37 +445,20 @@ void bdi_destroy(struct backing_dev_info *bdi)
>  {
>  	int i;
>  
> -	/*
> -	 * Splice our entries to the default_backing_dev_info.  This
> -	 * condition shouldn't happen.  @wb must be empty at this point and
> -	 * dirty inodes on it might cause other issues.  This workaround is
> -	 * added by ce5f8e779519 ("writeback: splice dirty inode entries to
> -	 * default bdi on bdi_destroy()") without root-causing the issue.
> -	 *
> -	 * http://lkml.kernel.org/g/1253038617-30204-11-git-send-email-jens.axboe@oracle.com
> -	 * http://thread.gmane.org/gmane.linux.file-systems/35341/focus=35350
> -	 *
> -	 * We should probably add WARN_ON() to find out whether it still
> -	 * happens and track it down if so.
> -	 */
> -	if (bdi_has_dirty_io(bdi)) {
> -		struct bdi_writeback *dst = &default_backing_dev_info.wb;
> -
> -		bdi_lock_two(&bdi->wb, dst);
> -		list_splice(&bdi->wb.b_dirty, &dst->b_dirty);
> -		list_splice(&bdi->wb.b_io, &dst->b_io);
> -		list_splice(&bdi->wb.b_more_io, &dst->b_more_io);
> -		spin_unlock(&bdi->wb.list_lock);
> -		spin_unlock(&dst->list_lock);
> -	}
> -
> -	bdi_unregister(bdi);
> +	bdi_wb_shutdown(bdi);
>  
> +	WARN_ON(!list_empty(&bdi->work_list));
> +	WARN_ON(delayed_work_pending(&bdi->wb.dwork));
>  	WARN_ON(delayed_work_pending(&bdi->wb.dwork));
  You have the warning twice here...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
