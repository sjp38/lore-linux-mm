Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id C83E66B0253
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 15:16:52 -0400 (EDT)
Received: by wiar9 with SMTP id r9so79118807wia.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 12:16:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lc5si4951499wjc.120.2015.07.01.12.16.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Jul 2015 12:16:51 -0700 (PDT)
Date: Wed, 1 Jul 2015 21:16:46 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 48/51] writeback: dirty inodes against their matching
 cgroup bdi_writeback's
Message-ID: <20150701191646.GJ7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-49-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-49-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri 22-05-15 17:14:02, Tejun Heo wrote:
> __mark_inode_dirty() always dirtied the inode against the root wb
> (bdi_writeback).  The previous patches added all the infrastructure
> necessary to attribute an inode against the wb of the dirtying cgroup.
> 
> This patch updates __mark_inode_dirty() so that it uses the wb
> associated with the inode instead of unconditionally using the root
> one.
> 
> Currently, none of the filesystems has FS_CGROUP_WRITEBACK and all
> pages will keep being dirtied against the root wb.
> 
> v2: Updated for per-inode wb association.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza

> ---
>  fs/fs-writeback.c | 23 +++++++++++------------
>  1 file changed, 11 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 59d76f6..881ea5d 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -1504,7 +1504,6 @@ static noinline void block_dump___mark_inode_dirty(struct inode *inode)
>  void __mark_inode_dirty(struct inode *inode, int flags)
>  {
>  	struct super_block *sb = inode->i_sb;
> -	struct backing_dev_info *bdi = NULL;
>  	int dirtytime;
>  
>  	trace_writeback_mark_inode_dirty(inode, flags);
> @@ -1574,30 +1573,30 @@ void __mark_inode_dirty(struct inode *inode, int flags)
>  		 * reposition it (that would break b_dirty time-ordering).
>  		 */
>  		if (!was_dirty) {
> +			struct bdi_writeback *wb = inode_to_wb(inode);
>  			struct list_head *dirty_list;
>  			bool wakeup_bdi = false;
> -			bdi = inode_to_bdi(inode);
>  
>  			spin_unlock(&inode->i_lock);
> -			spin_lock(&bdi->wb.list_lock);
> +			spin_lock(&wb->list_lock);
>  
> -			WARN(bdi_cap_writeback_dirty(bdi) &&
> -			     !test_bit(WB_registered, &bdi->wb.state),
> -			     "bdi-%s not registered\n", bdi->name);
> +			WARN(bdi_cap_writeback_dirty(wb->bdi) &&
> +			     !test_bit(WB_registered, &wb->state),
> +			     "bdi-%s not registered\n", wb->bdi->name);
>  
>  			inode->dirtied_when = jiffies;
>  			if (dirtytime)
>  				inode->dirtied_time_when = jiffies;
>  
>  			if (inode->i_state & (I_DIRTY_INODE | I_DIRTY_PAGES))
> -				dirty_list = &bdi->wb.b_dirty;
> +				dirty_list = &wb->b_dirty;
>  			else
> -				dirty_list = &bdi->wb.b_dirty_time;
> +				dirty_list = &wb->b_dirty_time;
>  
> -			wakeup_bdi = inode_wb_list_move_locked(inode, &bdi->wb,
> +			wakeup_bdi = inode_wb_list_move_locked(inode, wb,
>  							       dirty_list);
>  
> -			spin_unlock(&bdi->wb.list_lock);
> +			spin_unlock(&wb->list_lock);
>  			trace_writeback_dirty_inode_enqueue(inode);
>  
>  			/*
> @@ -1606,8 +1605,8 @@ void __mark_inode_dirty(struct inode *inode, int flags)
>  			 * to make sure background write-back happens
>  			 * later.
>  			 */
> -			if (bdi_cap_writeback_dirty(bdi) && wakeup_bdi)
> -				wb_wakeup_delayed(&bdi->wb);
> +			if (bdi_cap_writeback_dirty(wb->bdi) && wakeup_bdi)
> +				wb_wakeup_delayed(wb);
>  			return;
>  		}
>  	}
> -- 
> 2.4.0
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
