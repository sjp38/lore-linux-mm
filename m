Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2C066B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:19:43 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x7so132228813qkd.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:19:43 -0700 (PDT)
Received: from mail-vk0-x241.google.com (mail-vk0-x241.google.com. [2607:f8b0:400c:c05::241])
        by mx.google.com with ESMTPS id 19si2702945uad.43.2016.04.27.10.19.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 10:19:43 -0700 (PDT)
Received: by mail-vk0-x241.google.com with SMTP id u23so253587vkb.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:19:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160427005853.GD4782@swordfish>
References: <1461619210-10057-1-git-send-email-ddstreet@ieee.org>
 <1461704891-15272-1-git-send-email-ddstreet@ieee.org> <20160427005853.GD4782@swordfish>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 27 Apr 2016 13:19:03 -0400
Message-ID: <CALZtONArGwmaWNcHJODmY1uXm306NiqeZtRekfCFgZsMz_cngw@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: use workqueue to destroy pool
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Yu Zhao <yuzhao@google.com>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@redhat.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On Tue, Apr 26, 2016 at 8:58 PM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> Hello,
>
> On (04/26/16 17:08), Dan Streetman wrote:
> [..]
>> -static void __zswap_pool_release(struct rcu_head *head)
>> +static void __zswap_pool_release(struct work_struct *work)
>>  {
>> -     struct zswap_pool *pool = container_of(head, typeof(*pool), rcu_head);
>> +     struct zswap_pool *pool = container_of(work, typeof(*pool), work);
>> +
>> +     synchronize_rcu();
>>
>>       /* nobody should have been able to get a kref... */
>>       WARN_ON(kref_get_unless_zero(&pool->kref));
>> @@ -674,7 +676,9 @@ static void __zswap_pool_empty(struct kref *kref)
>>       WARN_ON(pool == zswap_pool_current());
>>
>>       list_del_rcu(&pool->list);
>> -     call_rcu(&pool->rcu_head, __zswap_pool_release);
>> +
>> +     INIT_WORK(&pool->work, __zswap_pool_release);
>> +     schedule_work(&pool->work);
>
> so in general the patch look good to me.
>
> it's either I didn't have enough coffee yet (which is true) or
> _IN THEORY_ it creates a tiny race condition; which is hard (and
> unlikely) to hit, but still. and the problem being is
> CONFIG_ZSMALLOC_STAT.

Aha, thanks, I hadn't tested with that param enabled.  However, the
patch doesn't create the race condition, that existed already.

>
> zsmalloc stats are exported via debugfs which is getting init
> during pool set up in zs_pool_stat_create() -> debugfs_create_dir() zsmalloc<ID>.
>
> so, once again, in theory, since zswap has the same <ID>, debugfs
> dir will have the same for different pool, so a series of zpool
> changes via user space knob
>
>         zsmalloc > zpool
>         zbud > zpool
>         zsmalloc > zpool
>
> can result in
>
> release zsmalloc0        switch to zbud         switch to zsmalloc
> __zswap_pool_release()
>         schedule_work()
>                                 ...
>                                                 zs_create_pool()
>                                                         zs_pool_stat_create()
>                                                         <<  zsmalloc0 still exists >>
>
>         work is finally scheduled
>                 zs_destroy_pool()
>                         zs_pool_stat_destroy()

zsmalloc uses the pool 'name' provided, without any checking, and in
this case it will always be 'zswap'.  So this is easy to reproduce:

1. make sure kernel is compiled with CONFIG_ZSMALLOC_STAT=y
2. enable zswap, change zpool to zsmalloc
3. put some pages into zswap
4. try to change the compressor -> failure

It fails because the new zswap pool creates a new zpool using
zsmalloc, but it can't create the zsmalloc pool because there is
already one named 'zswap' so the stat dir can't be created.

So...either zswap needs to provide a unique 'name' to each of its
zpools, or zsmalloc needs to modify its provided pool name in some way
(add a unique suffix maybe).  Or both.

It seems like zsmalloc should do the checking/modification - or, at
the very least, it should have consistent behavior regardless of the
CONFIG_ZSMALLOC_STAT setting.  However, it's easy to change zswap to
provide a unique name for each zpool creation, and zsmalloc's primary
user (zram) guarantees to provide a unique name for each pool created.
So updating zswap is probably best.


>
>         -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
