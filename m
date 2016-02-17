Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id A12E16B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 21:25:13 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id fl4so2307065pad.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 18:25:13 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id l80si55068950pfj.31.2016.02.16.18.25.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 18:25:12 -0800 (PST)
Received: by mail-pa0-x234.google.com with SMTP id ho8so2312237pac.2
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 18:25:12 -0800 (PST)
Date: Wed, 17 Feb 2016 11:26:29 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: drop unused member 'mapping_area->huge'
Message-ID: <20160217022552.GB535@swordfish>
References: <1455674199-6227-1-git-send-email-xuyiping@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455674199-6227-1-git-send-email-xuyiping@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YiPing Xu <xuyiping@huawei.com>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, suzhuangluan@hisilicon.com, puck.chen@hisilicon.com, dan.zhao@hisilicon.com

Hello,

On (02/17/16 09:56), YiPing Xu wrote:
>  static int create_handle_cache(struct zs_pool *pool)
> @@ -1127,11 +1126,9 @@ static void __zs_unmap_object(struct mapping_area *area,
>  		goto out;
>  
>  	buf = area->vm_buf;
> -	if (!area->huge) {
> -		buf = buf + ZS_HANDLE_SIZE;
> -		size -= ZS_HANDLE_SIZE;
> -		off += ZS_HANDLE_SIZE;
> -	}
> +	buf = buf + ZS_HANDLE_SIZE;
> +	size -= ZS_HANDLE_SIZE;
> +	off += ZS_HANDLE_SIZE;
>  
>  	sizes[0] = PAGE_SIZE - off;
>  	sizes[1] = size - sizes[0];


hm, indeed.

shouldn't it depend on class->huge?

void *zs_map_object()
{
	void *ret = __zs_map_object(area, pages, off, class->size);

	if (!class->huge)
		ret += ZS_HANDLE_SIZE;  /* area->vm_buf + ZS_HANDLE_SIZE */

	return ret;
}

static void __zs_unmap_object(struct mapping_area *area...)
{
	char *buf = area->vm_buf;

	/* handle is in page->private for class->huge */

	buf = buf + ZS_HANDLE_SIZE;
	size -= ZS_HANDLE_SIZE;
	off += ZS_HANDLE_SIZE;

	memcpy(..);
}

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
