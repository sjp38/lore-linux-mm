Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4E76B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 20:40:51 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id cc10so2734874wib.11
        for <linux-mm@kvack.org>; Tue, 27 May 2014 17:40:51 -0700 (PDT)
Received: from mail-we0-x233.google.com (mail-we0-x233.google.com [2a00:1450:400c:c03::233])
        by mx.google.com with ESMTPS id un7si28308235wjc.134.2014.05.27.17.40.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 17:40:50 -0700 (PDT)
Received: by mail-we0-f179.google.com with SMTP id q59so10188244wes.24
        for <linux-mm@kvack.org>; Tue, 27 May 2014 17:40:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140527224002.GB25781@cerebellum.variantweb.net>
References: <1399499496-3216-1-git-send-email-ddstreet@ieee.org>
 <1400958369-3588-1-git-send-email-ddstreet@ieee.org> <1400958369-3588-7-git-send-email-ddstreet@ieee.org>
 <20140527224002.GB25781@cerebellum.variantweb.net>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 27 May 2014 20:40:29 -0400
Message-ID: <CALZtONDhkoxXa2o1eDN_7siJ53MEPhNwp5RLg8SOH4pph+t2Og@mail.gmail.com>
Subject: Re: [PATCH 6/6] mm/zpool: prevent zbud/zsmalloc from unloading when used
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, May 27, 2014 at 6:40 PM, Seth Jennings <sjennings@variantweb.net> wrote:
> On Sat, May 24, 2014 at 03:06:09PM -0400, Dan Streetman wrote:
>> Add try_module_get() to pool creation functions for zbud and zsmalloc,
>> and module_put() to pool destruction functions, since they now can be
>> modules used via zpool.  Without usage counting, they could be unloaded
>> while pool(s) were active, resulting in an oops.
>
> I like the idea here, but what about doing this in the zpool layer? For
> me, it is kinda weird for a module to be taking a ref on itself.  Maybe
> this is excepted practice.  Is there precedent for this?

It's done in some places already:
git grep try_module_get\(THIS_MODULE | wc -l
83

but it definitely could be done in zpool, and since other users of
zbud/zsmalloc would be calling directly to their functions, instead of
indirectly by driver registration, I believe the module dependency
there would prevent zbud/zsmalloc unloading while a using module was
still loaded (if I understand module usage counting correctly).

>
> What about having the zbud/zsmalloc drivers pass their module pointers
> to zpool_register_driver() as an additional field in struct zpool_driver
> and have zpool take the reference?  Since zpool is the one in trouble if
> the driver is unloaded.

Yep this seems to be the other common way of doing it, with a ->owner
field in the registered struct.  Either way is fine with me, and zpool
definitely is the one in trouble if its driver is unloaded.  I'll
update for v4 of this patch set.

>
> Seth
>
>>
>> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
>> Cc: Seth Jennings <sjennings@variantweb.net>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Nitin Gupta <ngupta@vflare.org>
>> Cc: Weijie Yang <weijie.yang@samsung.com>
>> ---
>>
>> New for this patch set.
>>
>>  mm/zbud.c     | 5 +++++
>>  mm/zsmalloc.c | 5 +++++
>>  2 files changed, 10 insertions(+)
>>
>> diff --git a/mm/zbud.c b/mm/zbud.c
>> index 8a72cb1..2b3689c 100644
>> --- a/mm/zbud.c
>> +++ b/mm/zbud.c
>> @@ -282,6 +282,10 @@ struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
>>       pool = kmalloc(sizeof(struct zbud_pool), GFP_KERNEL);
>>       if (!pool)
>>               return NULL;
>> +     if (!try_module_get(THIS_MODULE)) {
>> +             kfree(pool);
>> +             return NULL;
>> +     }
>>       spin_lock_init(&pool->lock);
>>       for_each_unbuddied_list(i, 0)
>>               INIT_LIST_HEAD(&pool->unbuddied[i]);
>> @@ -302,6 +306,7 @@ struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
>>  void zbud_destroy_pool(struct zbud_pool *pool)
>>  {
>>       kfree(pool);
>> +     module_put(THIS_MODULE);
>>  }
>>
>>  /**
>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> index 07c3130..2cc2647 100644
>> --- a/mm/zsmalloc.c
>> +++ b/mm/zsmalloc.c
>> @@ -946,6 +946,10 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>>       pool = kzalloc(ovhd_size, GFP_KERNEL);
>>       if (!pool)
>>               return NULL;
>> +     if (!try_module_get(THIS_MODULE)) {
>> +             kfree(pool);
>> +             return NULL;
>> +     }
>>
>>       for (i = 0; i < ZS_SIZE_CLASSES; i++) {
>>               int size;
>> @@ -985,6 +989,7 @@ void zs_destroy_pool(struct zs_pool *pool)
>>               }
>>       }
>>       kfree(pool);
>> +     module_put(THIS_MODULE);
>>  }
>>  EXPORT_SYMBOL_GPL(zs_destroy_pool);
>>
>> --
>> 1.8.3.1
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
