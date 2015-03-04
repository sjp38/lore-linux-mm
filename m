Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id D07866B006E
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 10:30:56 -0500 (EST)
Received: by wevk48 with SMTP id k48so509782wev.5
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 07:30:56 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k7si30150919wiv.40.2015.03.04.07.30.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 07:30:55 -0800 (PST)
Date: Wed, 4 Mar 2015 16:30:50 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH block/for-4.0-fixes] writeback: add missing
 INITIAL_JIFFIES init in global_update_bandwidth()
Message-ID: <20150304153050.GA1249@quack.suse.cz>
References: <20150304152243.GG3122@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150304152243.GG3122@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed 04-03-15 10:22:43, Tejun Heo wrote:
> global_update_bandwidth() uses static variable update_time as the
> timestamp for the last update but forgets to initialize it to
> INITIALIZE_JIFFIES.
> 
> This means that global_dirty_limit will be 5 mins into the future on
> 32bit and some large amount jiffies into the past on 64bit.  This
> isn't critical as the only effect is that global_dirty_limit won't be
> updated for the first 5 mins after booting on 32bit machines,
> especially given the auxiliary nature of global_dirty_limit's role -
> protecting against global dirty threshold's sudden dips; however, it
> does lead to unintended suboptimal behavior.  Fix it.
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: stable@vger.kernel.org
> ---
>  mm/page-writeback.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -922,7 +922,7 @@ static void global_update_bandwidth(unsi
>  				    unsigned long now)
>  {
>  	static DEFINE_SPINLOCK(dirty_lock);
> -	static unsigned long update_time;
> +	static unsigned long update_time = INITIAL_JIFFIES;
>  
>  	/*
>  	 * check locklessly first to optimize away locking for the most time
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
