Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 616A16B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 13:07:00 -0400 (EDT)
Date: Tue, 9 Jul 2013 19:06:56 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: cleanup backing_dev_info foo_stamp fields
Message-ID: <20130709170656.GB7256@quack.suse.cz>
References: <20130705155018.3532.45042.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130705155018.3532.45042.stgit@maximpc.sw.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <mpatlasov@parallels.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, jack@suse.cz, dev@parallels.com, miklos@szeredi.hu, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, xemul@parallels.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

On Fri 05-07-13 19:50:41, Maxim Patlasov wrote:
> State clearly that bw_time_stamp is measured in jiffies. Rename other
> foo_stamp fields to reflect that they are in units of number-of-pages.
> 
> Reported-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/backing-dev.h |    7 ++++---
>  mm/backing-dev.c            |    2 +-
>  mm/page-writeback.c         |    8 ++++----
>  3 files changed, 9 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index c388155..ee7eb1a 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -73,9 +73,10 @@ struct backing_dev_info {
>  
>  	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
>  
> -	unsigned long bw_time_stamp;	/* last time write bw is updated */
> -	unsigned long dirtied_stamp;
> -	unsigned long written_stamp;	/* pages written at bw_time_stamp */
> +	unsigned long bw_time_stamp;	/* last time (in jiffies) write bw
> +					 * is updated */
> +	unsigned long dirtied_nr_stamp;
> +	unsigned long written_nr_stamp;	/* pages written at bw_time_stamp */
>  	unsigned long write_bandwidth;	/* the estimated write bandwidth */
>  	unsigned long avg_write_bandwidth; /* further smoothed write bw */
>  
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 5025174..82efe7f 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -454,7 +454,7 @@ int bdi_init(struct backing_dev_info *bdi)
>  	bdi->dirty_exceeded = 0;
>  
>  	bdi->bw_time_stamp = jiffies;
> -	bdi->written_stamp = 0;
> +	bdi->written_nr_stamp = 0;
>  
>  	bdi->balanced_dirty_ratelimit = INIT_BW;
>  	bdi->dirty_ratelimit = INIT_BW;
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 4514ad7..088a8db 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -799,7 +799,7 @@ static void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
>  	 * write_bandwidth = ---------------------------------------------------
>  	 *                                          period
>  	 */
> -	bw = written - bdi->written_stamp;
> +	bw = written - bdi->written_nr_stamp;
>  	bw *= HZ;
>  	if (unlikely(elapsed > period)) {
>  		do_div(bw, elapsed);
> @@ -910,7 +910,7 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
>  	 * The dirty rate will match the writeout rate in long term, except
>  	 * when dirty pages are truncated by userspace or re-dirtied by FS.
>  	 */
> -	dirty_rate = (dirtied - bdi->dirtied_stamp) * HZ / elapsed;
> +	dirty_rate = (dirtied - bdi->dirtied_nr_stamp) * HZ / elapsed;
>  
>  	pos_ratio = bdi_position_ratio(bdi, thresh, bg_thresh, dirty,
>  				       bdi_thresh, bdi_dirty);
> @@ -1066,8 +1066,8 @@ void __bdi_update_bandwidth(struct backing_dev_info *bdi,
>  	bdi_update_write_bandwidth(bdi, elapsed, written);
>  
>  snapshot:
> -	bdi->dirtied_stamp = dirtied;
> -	bdi->written_stamp = written;
> +	bdi->dirtied_nr_stamp = dirtied;
> +	bdi->written_nr_stamp = written;
>  	bdi->bw_time_stamp = now;
>  }
>  
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
