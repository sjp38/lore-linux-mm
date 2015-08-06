Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0126B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 06:21:13 -0400 (EDT)
Received: by igk11 with SMTP id 11so8284434igk.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 03:21:13 -0700 (PDT)
Received: from mail-io0-x232.google.com (mail-io0-x232.google.com. [2607:f8b0:4001:c06::232])
        by mx.google.com with ESMTPS id f18si1262899igt.58.2015.08.06.03.21.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 03:21:12 -0700 (PDT)
Received: by ioeg141 with SMTP id g141so76351600ioe.3
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 03:21:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150806000843.GA3927@swordfish>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
 <1438782403-29496-4-git-send-email-ddstreet@ieee.org> <20150806000843.GA3927@swordfish>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 6 Aug 2015 06:20:53 -0400
Message-ID: <CALZtONCuj8hh-GS0KFokBEDrs_BH=R+_yChqra4t4TpuWQWKTQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] zswap: change zpool/compressor at runtime
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Aug 5, 2015 at 8:08 PM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> Hi,
>
> On (08/05/15 09:46), Dan Streetman wrote:
>> Update the zpool and compressor parameters to be changeable at runtime.
>> When changed, a new pool is created with the requested zpool/compressor,
>> and added as the current pool at the front of the pool list.  Previous
>> pools remain in the list only to remove existing compressed pages from.
>> The old pool(s) are removed once they become empty.
>>
>
> Sorry, just curious, is this functionality/complication really
> necessary?

Well you could ask the same question about many other module params;
can't people just configure everything using boot params?  ;-)

> How often do you expect people to do that? The way I
> see it -- a static configuration works just fine: boot, test,
> re-configure, boot test; compare the results and done.

Sure a static configuration will work (it has since Seth wrote zswap),
but that doesn't guarantee everyone will want to do it that way.
Certainly for testing/development/benchmarking avoiding a reboot is
helpful.  And for long-running and/or critical systems that need to
change their zpool or compressor, for whatever reason, forcing a
reboot isn't desirable.

Why would someone want to change their compressor or zpool?  A simple
exampe comes to mind - maybe they have 1000's of systems and a bug was
found in the current level of compressor or zpool - they would then
have to either reboot all the systems to change to a different
zpool/compressor, or leave it using the known-buggy one.

In addition, a static boot-time configuration requires adding params
to the bootloader configuration, *and* rebuilding the initramfs to
include both the required zpool and compressor.  So even for static
configurations, it's simpler to be able to set the zpool and
compressor immediately after boot, instead of at boot time.

>
>         -ss
>
>> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
>> ---
>>  mm/zswap.c | 135 +++++++++++++++++++++++++++++++++++++++++++++++++++++++------
>>  1 file changed, 122 insertions(+), 13 deletions(-)
>>
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index f8fcd7e..3eaff21 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -80,23 +80,39 @@ static u64 zswap_duplicate_entry;
>>  static bool zswap_enabled;
>>  module_param_named(enabled, zswap_enabled, bool, 0644);
>>
>> -/* Compressor to be used by zswap (fixed at boot for now) */
>> +/* Crypto compressor to use */
>>  #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
>> -static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
>> -module_param_named(compressor, zswap_compressor, charp, 0444);
>> -
>> -/* The maximum percentage of memory that the compressed pool can occupy */
>> -static unsigned int zswap_max_pool_percent = 20;
>> -module_param_named(max_pool_percent,
>> -                     zswap_max_pool_percent, uint, 0644);
>> +static char zswap_compressor[CRYPTO_MAX_ALG_NAME] = ZSWAP_COMPRESSOR_DEFAULT;
>> +static struct kparam_string zswap_compressor_kparam = {
>> +     .string =       zswap_compressor,
>> +     .maxlen =       sizeof(zswap_compressor),
>> +};
>> +static int zswap_compressor_param_set(const char *,
>> +                                   const struct kernel_param *);
>> +static struct kernel_param_ops zswap_compressor_param_ops = {
>> +     .set =          zswap_compressor_param_set,
>> +     .get =          param_get_string,
>> +};
>> +module_param_cb(compressor, &zswap_compressor_param_ops,
>> +             &zswap_compressor_kparam, 0644);
>>
>> -/* Compressed storage to use */
>> +/* Compressed storage zpool to use */
>>  #define ZSWAP_ZPOOL_DEFAULT "zbud"
>> -static char *zswap_zpool_type = ZSWAP_ZPOOL_DEFAULT;
>> -module_param_named(zpool, zswap_zpool_type, charp, 0444);
>> +static char zswap_zpool_type[32 /* arbitrary */] = ZSWAP_ZPOOL_DEFAULT;
>> +static struct kparam_string zswap_zpool_kparam = {
>> +     .string =       zswap_zpool_type,
>> +     .maxlen =       sizeof(zswap_zpool_type),
>> +};
>> +static int zswap_zpool_param_set(const char *, const struct kernel_param *);
>> +static struct kernel_param_ops zswap_zpool_param_ops = {
>> +     .set =  zswap_zpool_param_set,
>> +     .get =  param_get_string,
>> +};
>> +module_param_cb(zpool, &zswap_zpool_param_ops, &zswap_zpool_kparam, 0644);
>>
>> -/* zpool is shared by all of zswap backend  */
>> -static struct zpool *zswap_pool;
>> +/* The maximum percentage of memory that the compressed pool can occupy */
>> +static unsigned int zswap_max_pool_percent = 20;
>> +module_param_named(max_pool_percent, zswap_max_pool_percent, uint, 0644);
>>
>>  /*********************************
>>  * data structures
>> @@ -161,6 +177,9 @@ static LIST_HEAD(zswap_pools);
>>  /* protects zswap_pools list modification */
>>  static DEFINE_SPINLOCK(zswap_pools_lock);
>>
>> +/* used by param callback function */
>> +static bool zswap_init_started;
>> +
>>  /*********************************
>>  * helpers and fwd declarations
>>  **********************************/
>> @@ -661,6 +680,94 @@ static void zswap_pool_put(struct zswap_pool *pool)
>>       kref_put(&pool->kref, __zswap_pool_empty);
>>  }
>>
>> +/*********************************
>> +* param callbacks
>> +**********************************/
>> +
>> +static int __zswap_param_set(const char *val, const struct kernel_param *kp,
>> +                          char *type, char *compressor)
>> +{
>> +     struct zswap_pool *pool, *put_pool = NULL;
>> +     char str[kp->str->maxlen], *s;
>> +     int ret;
>> +
>> +     strlcpy(str, val, kp->str->maxlen);
>> +     s = strim(str);
>> +
>> +     /* if this is load-time (pre-init) param setting,
>> +      * don't create a pool; that's done during init.
>> +      */
>> +     if (!zswap_init_started)
>> +             return param_set_copystring(s, kp);
>> +
>> +     /* no change required */
>> +     if (!strncmp(kp->str->string, s, kp->str->maxlen))
>> +             return 0;
>> +
>> +     if (!type) {
>> +             type = s;
>> +             if (!zpool_has_pool(type)) {
>> +                     pr_err("zpool %s not available\n", type);
>> +                     return -ENOENT;
>> +             }
>> +     } else if (!compressor) {
>> +             compressor = s;
>> +             if (!crypto_has_comp(compressor, 0, 0)) {
>> +                     pr_err("compressor %s not available\n", compressor);
>> +                     return -ENOENT;
>> +             }
>> +     }
>> +
>> +     spin_lock(&zswap_pools_lock);
>> +
>> +     pool = zswap_pool_find_get(type, compressor);
>> +     if (pool) {
>> +             zswap_pool_debug("using existing", pool);
>> +             list_del_rcu(&pool->list);
>> +     } else {
>> +             spin_unlock(&zswap_pools_lock);
>> +             pool = zswap_pool_create(type, compressor);
>> +             spin_lock(&zswap_pools_lock);
>> +     }
>> +
>> +     if (pool)
>> +             ret = param_set_copystring(s, kp);
>> +     else
>> +             ret = -EINVAL;
>> +
>> +     if (!ret) {
>> +             put_pool = zswap_pool_current();
>> +             list_add_rcu(&pool->list, &zswap_pools);
>> +     } else if (pool) {
>> +             /* add the possibly pre-existing pool to the end of the pools
>> +              * list; if it's new (and empty) then it'll be removed and
>> +              * destroyed by the put after we drop the lock
>> +              */
>> +             list_add_tail_rcu(&pool->list, &zswap_pools);
>> +             put_pool = pool;
>> +     }
>> +
>> +     spin_unlock(&zswap_pools_lock);
>> +
>> +     /* drop the ref from either the old current pool,
>> +      * or the new pool we failed to add
>> +      */
>> +     if (put_pool)
>> +             zswap_pool_put(put_pool);
>> +
>> +     return ret;
>> +}
>> +
>> +static int zswap_compressor_param_set(const char *val,
>> +                                   const struct kernel_param *kp)
>> +{
>> +     return __zswap_param_set(val, kp, zswap_zpool_type, NULL);
>> +}
>> +
>> +static int zswap_zpool_param_set(const char *val,
>> +                              const struct kernel_param *kp)
>> +{
>> +     return __zswap_param_set(val, kp, NULL, zswap_compressor);
>>  }
>>
>>  /*********************************
>> @@ -1116,6 +1223,8 @@ static int __init init_zswap(void)
>>  {
>>       struct zswap_pool *pool;
>>
>> +     zswap_init_started = true;
>> +
>>       if (zswap_entry_cache_create()) {
>>               pr_err("entry cache creation failed\n");
>>               goto cache_fail;
>> --
>> 2.1.0
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
