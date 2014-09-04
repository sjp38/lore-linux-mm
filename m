Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 39CC16B0035
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 02:25:28 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id ey11so19396510pad.21
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 23:25:26 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id jd1si1389146pbd.206.2014.09.03.23.25.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 03 Sep 2014 23:25:23 -0700 (PDT)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NBD003ZE5U2LX30@mailout4.samsung.com> for linux-mm@kvack.org;
 Thu, 04 Sep 2014 15:25:14 +0900 (KST)
Message-id: <54080606.3050106@samsung.com>
Date: Thu, 04 Sep 2014 15:26:14 +0900
From: Heesub Shin <heesub.shin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC 3/3] zram: add swap_get_free hint
References: <1409794786-10951-1-git-send-email-minchan@kernel.org>
 <1409794786-10951-4-git-send-email-minchan@kernel.org>
In-reply-to: <1409794786-10951-4-git-send-email-minchan@kernel.org>
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>

Hello Minchan,

First of all, I agree with the overall purpose of your patch set.

On 09/04/2014 10:39 AM, Minchan Kim wrote:
> This patch implement SWAP_GET_FREE handler in zram so that VM can
> know how many zram has freeable space.
> VM can use it to stop anonymous reclaiming once zram is full.
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>   drivers/block/zram/zram_drv.c | 18 ++++++++++++++++++
>   1 file changed, 18 insertions(+)
>
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 88661d62e46a..8e22b20aa2db 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -951,6 +951,22 @@ static int zram_slot_free_notify(struct block_device *bdev,
>   	return 0;
>   }
>
> +static int zram_get_free_pages(struct block_device *bdev, long *free)
> +{
> +	struct zram *zram;
> +	struct zram_meta *meta;
> +
> +	zram = bdev->bd_disk->private_data;
> +	meta = zram->meta;
> +
> +	if (!zram->limit_pages)
> +		return 1;
> +
> +	*free = zram->limit_pages - zs_get_total_pages(meta->mem_pool);

Even if 'free' is zero here, there may be free spaces available to store 
more compressed pages into the zs_pool. I mean calculation above is not 
quite accurate and wastes memory, but have no better idea for now.

heesub

> +
> +	return 0;
> +}
> +
>   static int zram_swap_hint(struct block_device *bdev,
>   				unsigned int hint, void *arg)
>   {
> @@ -958,6 +974,8 @@ static int zram_swap_hint(struct block_device *bdev,
>
>   	if (hint == SWAP_SLOT_FREE)
>   		ret = zram_slot_free_notify(bdev, (unsigned long)arg);
> +	else if (hint == SWAP_GET_FREE)
> +		ret = zram_get_free_pages(bdev, arg);
>
>   	return ret;
>   }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
