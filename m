Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C4BC6B026F
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 09:47:26 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v78so2560698pgb.18
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 06:47:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v196si970356pgb.584.2017.11.01.06.47.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 06:47:25 -0700 (PDT)
Date: Wed, 1 Nov 2017 14:47:22 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 2/3] bdi: add error handle for bdi_debug_register
Message-ID: <20171101134722.GB28572@quack2.suse.cz>
References: <cover.1509415695.git.zhangweiping@didichuxing.com>
 <100ecef9a09dc2a95feb5f6fac21c8bfa26be4eb.1509415695.git.zhangweiping@didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <100ecef9a09dc2a95feb5f6fac21c8bfa26be4eb.1509415695.git.zhangweiping@didichuxing.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: weiping zhang <zhangweiping@didichuxing.com>
Cc: axboe@kernel.dk, jack@suse.cz, linux-block@vger.kernel.org, linux-mm@kvack.org

On Tue 31-10-17 18:38:24, weiping zhang wrote:
> In order to make error handle more cleaner we call bdi_debug_register
> before set state to WB_registered, that we can avoid call bdi_unregister
> in release_bdi().
> 
> Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/backing-dev.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index b5f940ce0143..84b2dc76f140 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -882,10 +882,13 @@ int bdi_register_va(struct backing_dev_info *bdi, const char *fmt, va_list args)
>  	if (IS_ERR(dev))
>  		return PTR_ERR(dev);
>  
> +	if (bdi_debug_register(bdi, dev_name(dev))) {
> +		device_destroy(bdi_class, dev->devt);
> +		return -ENOMEM;
> +	}
>  	cgwb_bdi_register(bdi);
>  	bdi->dev = dev;
>  
> -	bdi_debug_register(bdi, dev_name(dev));
>  	set_bit(WB_registered, &bdi->wb.state);
>  
>  	spin_lock_bh(&bdi_lock);
> -- 
> 2.14.2
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
