Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id CCD7D828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 21:33:11 -0500 (EST)
Received: by mail-io0-f171.google.com with SMTP id 77so442149036ioc.2
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 18:33:11 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id e5si1060647igg.38.2016.01.14.18.33.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Jan 2016 18:33:10 -0800 (PST)
Date: Fri, 15 Jan 2016 11:35:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160115023518.GA10843@bbox>
References: <1452818184-2994-1-git-send-email-junil0814.lee@lge.com>
MIME-Version: 1.0
In-Reply-To: <1452818184-2994-1-git-send-email-junil0814.lee@lge.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Junil Lee <junil0814.lee@lge.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Junil,

On Fri, Jan 15, 2016 at 09:36:24AM +0900, Junil Lee wrote:
> To prevent unlock at the not correct situation, tagging the new obj to
> assure lock in migrate_zspage() before right unlock path.
> 
> Two functions are in race condition by tag which set 1 on last bit of
> obj, however unlock succrently when update new obj to handle before call
> unpin_tag() which is right unlock path.
> 
> summarize this problem by call flow as below:
> 
> 		CPU0								CPU1
> migrate_zspage
> find_alloced_obj()
> 	trypin_tag() -- obj |= HANDLE_PIN_BIT
> obj_malloc() -- new obj is not set			zs_free
> record_obj() -- unlock and break sync		pin_tag() -- get lock
> unpin_tag()

It's really good catch!
I think it should be stable material. For that, we should know this
patch fixes what kinds of problem.

What do you see problem? I mean please write down the oops you saw and
verify that the patch fixes your problem. :)

Minor nit below

> 
> Signed-off-by: Junil Lee <junil0814.lee@lge.com>
> ---
>  mm/zsmalloc.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index e7414ce..bb459ef 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1635,6 +1635,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
>  		free_obj = obj_malloc(d_page, class, handle);
>  		zs_object_copy(free_obj, used_obj, class);
>  		index++;
> +		free_obj |= BIT(HANDLE_PIN_BIT);
>  		record_obj(handle, free_obj);

I think record_obj should store free_obj to *handle with masking off least bit.
IOW, how about this?

record_obj(handle, obj)
{
        *(unsigned long)handle = obj & ~(1<<HANDLE_PIN_BIT);
}

Thanks a lot!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
