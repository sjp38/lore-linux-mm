Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 21EDA6B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 09:14:33 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z52so8077413wrc.5
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 06:14:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v62si2950180wme.108.2017.10.30.06.14.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Oct 2017 06:14:31 -0700 (PDT)
Date: Mon, 30 Oct 2017 14:14:30 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/4] block: add WARN_ON if bdi register fail
Message-ID: <20171030131430.GJ23278@quack2.suse.cz>
References: <cover.1509038624.git.zhangweiping@didichuxing.com>
 <413b04ba6a2a0b03b0cb3c578865d71b2ef97921.1509038624.git.zhangweiping@didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <413b04ba6a2a0b03b0cb3c578865d71b2ef97921.1509038624.git.zhangweiping@didichuxing.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: weiping zhang <zhangweiping@didichuxing.com>
Cc: axboe@kernel.dk, jack@suse.cz, linux-block@vger.kernel.org, linux-mm@kvack.org

On Fri 27-10-17 01:36:42, weiping zhang wrote:
> device_add_disk need do more safety error handle, so this patch just
> add WARN_ON.
> 
> Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
> ---
>  block/genhd.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/block/genhd.c b/block/genhd.c
> index dd305c65ffb0..cb55eea821eb 100644
> --- a/block/genhd.c
> +++ b/block/genhd.c
> @@ -660,7 +660,9 @@ void device_add_disk(struct device *parent, struct gendisk *disk)
>  
>  	/* Register BDI before referencing it from bdev */
>  	bdi = disk->queue->backing_dev_info;
> -	bdi_register_owner(bdi, disk_to_dev(disk));
> +	retval = bdi_register_owner(bdi, disk_to_dev(disk));
> +	if (retval)
> +		WARN_ON(1);

Just a nit: You can do

	WARN_ON(retval);

Otherwise you can add:

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
