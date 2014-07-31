Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 40E266B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 13:29:39 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id le20so4683569vcb.0
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 10:29:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w10si10926329qag.27.2014.07.31.10.29.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jul 2014 10:29:33 -0700 (PDT)
Date: Thu, 31 Jul 2014 12:35:46 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [PATCH] dm bufio: fully initialize shrinker
In-Reply-To: <1406822839-2423-1-git-send-email-gthelen@google.com>
Message-ID: <alpine.LRH.2.02.1407311235130.1571@file01.intranet.prod.int.rdu2.redhat.com>
References: <1406822839-2423-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: device-mapper development <dm-devel@redhat.com>
Cc: Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org, linux-raid@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>


On Thu, 31 Jul 2014, Greg Thelen wrote:

> 1d3d4437eae1 ("vmscan: per-node deferred work") added a flags field to
> struct shrinker assuming that all shrinkers were zero filled.  The dm
> bufio shrinker is not zero filled, which leaves arbitrary kmalloc() data
> in flags.  So far the only defined flags bit is SHRINKER_NUMA_AWARE.
> But there are proposed patches which add other bits to shrinker.flags
> (e.g. memcg awareness).
> 
> Rather than simply initializing the shrinker, this patch uses kzalloc()
> when allocating the dm_bufio_client to ensure that the embedded shrinker
> and any other similar structures are zeroed.
> 
> This fixes theoretical over aggressive shrinking of dm bufio objects.
> If the uninitialized dm_bufio_client.shrinker.flags contains
> SHRINKER_NUMA_AWARE then shrink_slab() would call the dm shrinker for
> each numa node rather than just once.  This has been broken since 3.12.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Mikulas Patocka <mpatocka@redhat.com>
Cc: stable@vger.kernel.org	#v3.12

> ---
>  drivers/md/dm-bufio.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
> index 4e84095833db..d724459860d9 100644
> --- a/drivers/md/dm-bufio.c
> +++ b/drivers/md/dm-bufio.c
> @@ -1541,7 +1541,7 @@ struct dm_bufio_client *dm_bufio_client_create(struct block_device *bdev, unsign
>  	BUG_ON(block_size < 1 << SECTOR_SHIFT ||
>  	       (block_size & (block_size - 1)));
>  
> -	c = kmalloc(sizeof(*c), GFP_KERNEL);
> +	c = kzalloc(sizeof(*c), GFP_KERNEL);
>  	if (!c) {
>  		r = -ENOMEM;
>  		goto bad_client;
> -- 
> 2.0.0.526.g5318336
> 
> --
> dm-devel mailing list
> dm-devel@redhat.com
> https://www.redhat.com/mailman/listinfo/dm-devel
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
