Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id EA9B36B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 04:20:20 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so37817907wib.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 01:20:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ga6si2725746wib.68.2015.07.01.01.20.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Jul 2015 01:20:19 -0700 (PDT)
Date: Wed, 1 Jul 2015 10:20:15 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 42/51] writeback: make wakeup_dirtytime_writeback()
 handle multiple bdi_writeback's
Message-ID: <20150701082015.GC7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-43-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-43-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Theodore Ts'o <tytso@mit.edu>

On Fri 22-05-15 17:13:56, Tejun Heo wrote:
> wakeup_dirtytime_writeback() currently only starts writeback on the
> root wb (bdi_writeback).  For cgroup writeback support, update the
> function to check all wbs.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Theodore Ts'o <tytso@mit.edu>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza

> ---
>  fs/fs-writeback.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 508e10c..8ae212e 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -1260,9 +1260,12 @@ static void wakeup_dirtytime_writeback(struct work_struct *w)
>  
>  	rcu_read_lock();
>  	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
> -		if (list_empty(&bdi->wb.b_dirty_time))
> -			continue;
> -		wb_wakeup(&bdi->wb);
> +		struct bdi_writeback *wb;
> +		struct wb_iter iter;
> +
> +		bdi_for_each_wb(wb, bdi, &iter, 0)
> +			if (!list_empty(&bdi->wb.b_dirty_time))
> +				wb_wakeup(&bdi->wb);
>  	}
>  	rcu_read_unlock();
>  	schedule_delayed_work(&dirtytime_work, dirtytime_expire_interval * HZ);
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
