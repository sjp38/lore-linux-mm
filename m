Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0F46B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 04:15:35 -0400 (EDT)
Received: by wgqq4 with SMTP id q4so29702019wgq.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 01:15:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pj2si2076642wjb.37.2015.07.01.01.15.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Jul 2015 01:15:34 -0700 (PDT)
Date: Wed, 1 Jul 2015 10:15:28 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 41/51] writeback: make wakeup_flusher_threads() handle
 multiple bdi_writeback's
Message-ID: <20150701081528.GB7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-42-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-42-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri 22-05-15 17:13:55, Tejun Heo wrote:
> wakeup_flusher_threads() currently only starts writeback on the root
> wb (bdi_writeback).  For cgroup writeback support, update the function
> to wake up all wbs and distribute the number of pages to write
> according to the proportion of each wb's write bandwidth, which is
> implemented in wb_split_bdi_pages().
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>

I was looking at who uses wakeup_flusher_threads(). There are two usecases:

1) sync() - we want to writeback everything
2) We want to relieve memory pressure by cleaning and subsequently
   reclaiming pages.

Neither of these cares about number of pages too much if you write enough.
So similarly as we don't split the passed nr_pages argument among bdis, I
wouldn't split the nr_pages among wbs. Just pass the nr_pages to each wb
and be done with that...

								Honza

> ---
>  fs/fs-writeback.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 46 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 92aaf64..508e10c 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -198,6 +198,41 @@ int inode_congested(struct inode *inode, int cong_bits)
>  }
>  EXPORT_SYMBOL_GPL(inode_congested);
>  
> +/**
> + * wb_split_bdi_pages - split nr_pages to write according to bandwidth
> + * @wb: target bdi_writeback to split @nr_pages to
> + * @nr_pages: number of pages to write for the whole bdi
> + *
> + * Split @wb's portion of @nr_pages according to @wb's write bandwidth in
> + * relation to the total write bandwidth of all wb's w/ dirty inodes on
> + * @wb->bdi.
> + */
> +static long wb_split_bdi_pages(struct bdi_writeback *wb, long nr_pages)
> +{
> +	unsigned long this_bw = wb->avg_write_bandwidth;
> +	unsigned long tot_bw = atomic_long_read(&wb->bdi->tot_write_bandwidth);
> +
> +	if (nr_pages == LONG_MAX)
> +		return LONG_MAX;
> +
> +	/*
> +	 * This may be called on clean wb's and proportional distribution
> +	 * may not make sense, just use the original @nr_pages in those
> +	 * cases.  In general, we wanna err on the side of writing more.
> +	 */
> +	if (!tot_bw || this_bw >= tot_bw)
> +		return nr_pages;
> +	else
> +		return DIV_ROUND_UP_ULL((u64)nr_pages * this_bw, tot_bw);
> +}
> +
> +#else	/* CONFIG_CGROUP_WRITEBACK */
> +
> +static long wb_split_bdi_pages(struct bdi_writeback *wb, long nr_pages)
> +{
> +	return nr_pages;
> +}
> +
>  #endif	/* CONFIG_CGROUP_WRITEBACK */
>  
>  void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
> @@ -1187,8 +1222,17 @@ void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
>  		nr_pages = get_nr_dirty_pages();
>  
>  	rcu_read_lock();
> -	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list)
> -		wb_start_writeback(&bdi->wb, nr_pages, false, reason);
> +	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
> +		struct bdi_writeback *wb;
> +		struct wb_iter iter;
> +
> +		if (!bdi_has_dirty_io(bdi))
> +			continue;
> +
> +		bdi_for_each_wb(wb, bdi, &iter, 0)
> +			wb_start_writeback(wb, wb_split_bdi_pages(wb, nr_pages),
> +					   false, reason);
> +	}
>  	rcu_read_unlock();
>  }
>  
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
