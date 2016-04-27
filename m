Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 598F26B025E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 20:57:22 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id xm6so39709242pab.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 17:57:22 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id da6si1860599pad.156.2016.04.26.17.57.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 17:57:21 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id c189so13490028pfb.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 17:57:21 -0700 (PDT)
Date: Wed, 27 Apr 2016 09:58:53 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zswap: use workqueue to destroy pool
Message-ID: <20160427005853.GD4782@swordfish>
References: <1461619210-10057-1-git-send-email-ddstreet@ieee.org>
 <1461704891-15272-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461704891-15272-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Yu Zhao <yuzhao@google.com>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

Hello,

On (04/26/16 17:08), Dan Streetman wrote:
[..]
> -static void __zswap_pool_release(struct rcu_head *head)
> +static void __zswap_pool_release(struct work_struct *work)
>  {
> -	struct zswap_pool *pool = container_of(head, typeof(*pool), rcu_head);
> +	struct zswap_pool *pool = container_of(work, typeof(*pool), work);
> +
> +	synchronize_rcu();
>  
>  	/* nobody should have been able to get a kref... */
>  	WARN_ON(kref_get_unless_zero(&pool->kref));
> @@ -674,7 +676,9 @@ static void __zswap_pool_empty(struct kref *kref)
>  	WARN_ON(pool == zswap_pool_current());
>  
>  	list_del_rcu(&pool->list);
> -	call_rcu(&pool->rcu_head, __zswap_pool_release);
> +
> +	INIT_WORK(&pool->work, __zswap_pool_release);
> +	schedule_work(&pool->work);

so in general the patch look good to me.

it's either I didn't have enough coffee yet (which is true) or
_IN THEORY_ it creates a tiny race condition; which is hard (and
unlikely) to hit, but still. and the problem being is
CONFIG_ZSMALLOC_STAT.

zsmalloc stats are exported via debugfs which is getting init
during pool set up in zs_pool_stat_create() -> debugfs_create_dir() zsmalloc<ID>.

so, once again, in theory, since zswap has the same <ID>, debugfs
dir will have the same for different pool, so a series of zpool
changes via user space knob

	zsmalloc > zpool
	zbud > zpool
	zsmalloc > zpool

can result in

release zsmalloc0	 switch to zbud		switch to zsmalloc
__zswap_pool_release()
	schedule_work()
				...
						zs_create_pool()
							zs_pool_stat_create()
							<<  zsmalloc0 still exists >>

	work is finally scheduled
		zs_destroy_pool()
			zs_pool_stat_destroy()

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
