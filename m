Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id AAAC86B006E
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 03:32:45 -0400 (EDT)
Received: by wiar9 with SMTP id r9so59633276wia.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 00:32:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ce7si1853283wjc.102.2015.07.01.00.32.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Jul 2015 00:32:44 -0700 (PDT)
Date: Wed, 1 Jul 2015 09:32:40 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 38/51] writeback: make laptop_mode_timer_fn() handle
 multiple bdi_writeback's
Message-ID: <20150701073240.GY7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-39-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-39-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri 22-05-15 17:13:52, Tejun Heo wrote:
> For cgroup writeback support, all bdi-wide operations should be
> distributed to all its wb's (bdi_writeback's).
> 
> This patch updates laptop_mode_timer_fn() so that it invokes
> wb_start_writeback() on all wb's rather than just the root one.  As
> the intent is writing out all dirty data, there's no reason to split
> the number of pages to write.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza

> ---
>  mm/page-writeback.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 6301af2..682e3a6 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1723,14 +1723,20 @@ void laptop_mode_timer_fn(unsigned long data)
>  	struct request_queue *q = (struct request_queue *)data;
>  	int nr_pages = global_page_state(NR_FILE_DIRTY) +
>  		global_page_state(NR_UNSTABLE_NFS);
> +	struct bdi_writeback *wb;
> +	struct wb_iter iter;
>  
>  	/*
>  	 * We want to write everything out, not just down to the dirty
>  	 * threshold
>  	 */
> -	if (bdi_has_dirty_io(&q->backing_dev_info))
> -		wb_start_writeback(&q->backing_dev_info.wb, nr_pages, true,
> -				   WB_REASON_LAPTOP_TIMER);
> +	if (!bdi_has_dirty_io(&q->backing_dev_info))
> +		return;
> +
> +	bdi_for_each_wb(wb, &q->backing_dev_info, &iter, 0)
> +		if (wb_has_dirty_io(wb))
> +			wb_start_writeback(wb, nr_pages, true,
> +					   WB_REASON_LAPTOP_TIMER);
>  }
>  
>  /*
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
