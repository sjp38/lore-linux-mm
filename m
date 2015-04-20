Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id A813A6B006C
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 11:41:36 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so183843150wgy.2
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 08:41:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jy3si16664654wid.81.2015.04.20.08.41.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Apr 2015 08:41:35 -0700 (PDT)
Date: Mon, 20 Apr 2015 17:41:30 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 19/49] writeback: add @gfp to wb_init()
Message-ID: <20150420154130.GI17020@quack.suse.cz>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
 <1428350318-8215-20-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1428350318-8215-20-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

On Mon 06-04-15 15:58:08, Tejun Heo wrote:
> wb_init() currently always uses GFP_KERNEL but the planned cgroup
> writeback support needs using other allocation masks.  Add @gfp to
> wb_init().
> 
> This patch doesn't introduce any behavior changes.
  OK.
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>
> ---
>  mm/backing-dev.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index b0707d1..805b287 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -291,7 +291,8 @@ void wb_wakeup_delayed(struct bdi_writeback *wb)
>   */
>  #define INIT_BW		(100 << (20 - PAGE_SHIFT))
>  
> -static int wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
> +static int wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi,
> +		   gfp_t gfp)
>  {
>  	int i, err;
>  
> @@ -315,12 +316,12 @@ static int wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
>  	INIT_LIST_HEAD(&wb->work_list);
>  	INIT_DELAYED_WORK(&wb->dwork, wb_workfn);
>  
> -	err = fprop_local_init_percpu(&wb->completions, GFP_KERNEL);
> +	err = fprop_local_init_percpu(&wb->completions, gfp);
>  	if (err)
>  		return err;
>  
>  	for (i = 0; i < NR_WB_STAT_ITEMS; i++) {
> -		err = percpu_counter_init(&wb->stat[i], 0, GFP_KERNEL);
> +		err = percpu_counter_init(&wb->stat[i], 0, gfp);
>  		if (err) {
>  			while (--i)
>  				percpu_counter_destroy(&wb->stat[i]);
> @@ -378,7 +379,7 @@ int bdi_init(struct backing_dev_info *bdi)
>  	bdi->max_prop_frac = FPROP_FRAC_BASE;
>  	INIT_LIST_HEAD(&bdi->bdi_list);
>  
> -	err = wb_init(&bdi->wb, bdi);
> +	err = wb_init(&bdi->wb, bdi, GFP_KERNEL);
>  	if (err)
>  		return err;
>  
> -- 
> 2.1.0
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
