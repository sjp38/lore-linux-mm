Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A46E56B0069
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 09:10:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y7so5942379wmd.18
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 06:10:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 38si10520525wry.273.2017.10.30.06.10.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Oct 2017 06:10:16 -0700 (PDT)
Date: Mon, 30 Oct 2017 14:10:16 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/4] bdi: add error handle for bdi_debug_register
Message-ID: <20171030131016.GI23278@quack2.suse.cz>
References: <cover.1509038624.git.zhangweiping@didichuxing.com>
 <b28a35a3af256e2c64b905728b0e9df307e12b0b.1509038624.git.zhangweiping@didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b28a35a3af256e2c64b905728b0e9df307e12b0b.1509038624.git.zhangweiping@didichuxing.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: weiping zhang <zhangweiping@didichuxing.com>
Cc: axboe@kernel.dk, jack@suse.cz, linux-block@vger.kernel.org, linux-mm@kvack.org

On Fri 27-10-17 01:36:14, weiping zhang wrote:
> In order to make error handle more cleaner we call bdi_debug_register
> before set state to WB_registered, that we can avoid call bdi_unregister
> in release_bdi().
> 
> Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
> ---
>  mm/backing-dev.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index e9d6a1ede12b..54396d53f471 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -893,10 +893,13 @@ int bdi_register_va(struct backing_dev_info *bdi, const char *fmt, va_list args)
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
> @@ -916,6 +919,8 @@ int bdi_register(struct backing_dev_info *bdi, const char *fmt, ...)
>  	va_start(args, fmt);
>  	ret = bdi_register_va(bdi, fmt, args);
>  	va_end(args);
> +	if (ret)
> +		bdi_put(bdi);

Why do you drop bdi reference here in case of error? We didn't do it
previously if bdi_register_va() failed for other reasons...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
