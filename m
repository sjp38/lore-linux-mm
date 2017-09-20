Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 783CA6B0033
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 10:35:07 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id h16so3291289wrf.0
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 07:35:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i8si1403817edj.450.2017.09.20.07.35.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Sep 2017 07:35:06 -0700 (PDT)
Date: Wed, 20 Sep 2017 16:35:05 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/6] page-writeback: pass in '0' for nr_pages writeback
 in laptop mode
Message-ID: <20170920143505.GD11106@quack2.suse.cz>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-4-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505850787-18311-4-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On Tue 19-09-17 13:53:04, Jens Axboe wrote:
> Laptop mode really wants to writeback the number of dirty
> pages and inodes. Instead of calculating this in the caller,
> just pass in 0 and let wakeup_flusher_threads() handle it.
> 
> Use the new wakeup_flusher_threads_bdi() instead of rolling
> our own.
> 
> Signed-off-by: Jens Axboe <axboe@kernel.dk>
...
> -	rcu_read_lock();
> -	list_for_each_entry_rcu(wb, &q->backing_dev_info->wb_list, bdi_node)
> -		if (wb_has_dirty_io(wb))
> -			wb_start_writeback(wb, nr_pages, true,
> -					   WB_REASON_LAPTOP_TIMER);
> -	rcu_read_unlock();
> +	wakeup_flusher_threads_bdi(q->backing_dev_info, 0,
> +					WB_REASON_LAPTOP_TIMER);
>  }

So this slightly changes the semantics since previously we were doing
range_cyclic writeback and now we don't. I don't think this matters in
practice but please mention that in the changelog. With that you can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
