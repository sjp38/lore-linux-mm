Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12E296B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 07:52:35 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l18so5876755wrc.23
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 04:52:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i63si1932774edi.407.2017.11.06.04.52.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 04:52:33 -0800 (PST)
Date: Mon, 6 Nov 2017 13:52:26 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2] writeback: remove the unused function parameter
Message-ID: <20171106125226.GA4359@quack2.suse.cz>
References: <1509685485-15278-1-git-send-email-wanglong19@meituan.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509685485-15278-1-git-send-email-wanglong19@meituan.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Long <wanglong19@meituan.com>
Cc: jack@suse.cz, tj@kernel.org, akpm@linux-foundation.org, gregkh@linuxfoundation.org, axboe@fb.com, nborisov@suse.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 03-11-17 01:04:45, Wang Long wrote:
> The parameter `struct bdi_writeback *wb` is not been used in the function
> body. so we just remove it.
> 
> Signed-off-by: Wang Long <wanglong19@meituan.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/backing-dev.h | 2 +-
>  mm/page-writeback.c         | 4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 1662157..186a2e7 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -95,7 +95,7 @@ static inline s64 wb_stat_sum(struct bdi_writeback *wb, enum wb_stat_item item)
>  /*
>   * maximal error of a stat counter.
>   */
> -static inline unsigned long wb_stat_error(struct bdi_writeback *wb)
> +static inline unsigned long wb_stat_error(void)
>  {
>  #ifdef CONFIG_SMP
>  	return nr_cpu_ids * WB_STAT_BATCH;
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 0b9c5cb..9287466 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1543,7 +1543,7 @@ static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
>  	 * actually dirty; with m+n sitting in the percpu
>  	 * deltas.
>  	 */
> -	if (dtc->wb_thresh < 2 * wb_stat_error(wb)) {
> +	if (dtc->wb_thresh < 2 * wb_stat_error()) {
>  		wb_reclaimable = wb_stat_sum(wb, WB_RECLAIMABLE);
>  		dtc->wb_dirty = wb_reclaimable + wb_stat_sum(wb, WB_WRITEBACK);
>  	} else {
> @@ -1802,7 +1802,7 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		 * more page. However wb_dirty has accounting errors.  So use
>  		 * the larger and more IO friendly wb_stat_error.
>  		 */
> -		if (sdtc->wb_dirty <= wb_stat_error(wb))
> +		if (sdtc->wb_dirty <= wb_stat_error())
>  			break;
>  
>  		if (fatal_signal_pending(current))
> -- 
> 1.8.3.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
