Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1C9E6B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 04:35:51 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r74so127950wme.5
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 01:35:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o62si645772eda.6.2017.09.18.01.35.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Sep 2017 01:35:50 -0700 (PDT)
Date: Mon, 18 Sep 2017 10:35:46 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] bdi: fix cleanup when fail to percpu_counter_init
Message-ID: <20170918083546.GC32516@quack2.suse.cz>
References: <20170915182700.GA2489@localhost.didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170915182700.GA2489@localhost.didichuxing.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: weiping zhang <zhangweiping@didichuxing.com>
Cc: axboe@fb.com, jack@suse.cz, tj@kernel.org, linux-mm@kvack.org

On Sat 16-09-17 02:27:05, weiping zhang wrote:
> when percpu_counter_init fail at i, 0 ~ (i-1) should be destoried, not
> 1 ~ i.
> 
> Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>

Good catch. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/backing-dev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index e19606b..d399d3c 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -334,7 +334,7 @@ static int wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi,
>  	return 0;
>  
>  out_destroy_stat:
> -	while (i--)
> +	while (--i >= 0)
>  		percpu_counter_destroy(&wb->stat[i]);
>  	fprop_local_destroy_percpu(&wb->completions);
>  out_put_cong:
> -- 
> 2.9.4
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
