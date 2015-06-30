Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id D13056B006E
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 12:18:09 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so137735140wiw.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 09:18:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pu2si46991647wjc.109.2015.06.30.09.18.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Jun 2015 09:18:08 -0700 (PDT)
Date: Tue, 30 Jun 2015 18:18:03 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 34/51] writeback: don't issue wb_writeback_work if clean
Message-ID: <20150630161803.GS7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-35-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-35-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri 22-05-15 17:13:48, Tejun Heo wrote:
> There are several places in fs/fs-writeback.c which queues
> wb_writeback_work without checking whether the target wb
> (bdi_writeback) has dirty inodes or not.  The only thing
> wb_writeback_work does is writing back the dirty inodes for the target
> wb and queueing a work item for a clean wb is essentially noop.  There
> are some side effects such as bandwidth stats being updated and
> triggering tracepoints but these don't affect the operation in any
> meaningful way.
> 
> This patch makes all writeback_inodes_sb_nr() and sync_inodes_sb()
> skip wb_queue_work() if the target bdi is clean.  Also, it moves
> dirtiness check from wakeup_flusher_threads() to
> __wb_start_writeback() so that all its callers benefit from the check.
> 
> While the overhead incurred by scheduling a noop work isn't currently
> significant, the overhead may be higher with cgroup writeback support
> as we may end up issuing noop work items to a lot of clean wb's.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza

> ---
>  fs/fs-writeback.c | 18 ++++++++++--------
>  1 file changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index c98d392..921a9e4 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -189,6 +189,9 @@ static void __wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>  {
>  	struct wb_writeback_work *work;
>  
> +	if (!wb_has_dirty_io(wb))
> +		return;
> +
>  	/*
>  	 * This is WB_SYNC_NONE writeback, so if allocation fails just
>  	 * wakeup the thread for old dirty data writeback
> @@ -1215,11 +1218,8 @@ void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
>  		nr_pages = get_nr_dirty_pages();
>  
>  	rcu_read_lock();
> -	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
> -		if (!bdi_has_dirty_io(bdi))
> -			continue;
> +	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list)
>  		__wb_start_writeback(&bdi->wb, nr_pages, false, reason);
> -	}
>  	rcu_read_unlock();
>  }
>  
> @@ -1512,11 +1512,12 @@ void writeback_inodes_sb_nr(struct super_block *sb,
>  		.nr_pages		= nr,
>  		.reason			= reason,
>  	};
> +	struct backing_dev_info *bdi = sb->s_bdi;
>  
> -	if (sb->s_bdi == &noop_backing_dev_info)
> +	if (!bdi_has_dirty_io(bdi) || bdi == &noop_backing_dev_info)
>  		return;
>  	WARN_ON(!rwsem_is_locked(&sb->s_umount));
> -	wb_queue_work(&sb->s_bdi->wb, &work);
> +	wb_queue_work(&bdi->wb, &work);
>  	wait_for_completion(&done);
>  }
>  EXPORT_SYMBOL(writeback_inodes_sb_nr);
> @@ -1594,13 +1595,14 @@ void sync_inodes_sb(struct super_block *sb)
>  		.reason		= WB_REASON_SYNC,
>  		.for_sync	= 1,
>  	};
> +	struct backing_dev_info *bdi = sb->s_bdi;
>  
>  	/* Nothing to do? */
> -	if (sb->s_bdi == &noop_backing_dev_info)
> +	if (!bdi_has_dirty_io(bdi) || bdi == &noop_backing_dev_info)
>  		return;
>  	WARN_ON(!rwsem_is_locked(&sb->s_umount));
>  
> -	wb_queue_work(&sb->s_bdi->wb, &work);
> +	wb_queue_work(&bdi->wb, &work);
>  	wait_for_completion(&done);
>  
>  	wait_sb_inodes(sb);
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
