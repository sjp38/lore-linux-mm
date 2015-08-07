Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 98F386B0254
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 10:25:05 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so32620586igb.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 07:25:05 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id x21si6105157iod.71.2015.08.07.07.25.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 07:25:05 -0700 (PDT)
Received: by igk11 with SMTP id 11so32597740igk.1
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 07:25:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150807063056.GG1891@swordfish>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
 <1438782403-29496-3-git-send-email-ddstreet@ieee.org> <20150807063056.GG1891@swordfish>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 7 Aug 2015 10:24:45 -0400
Message-ID: <CALZtONATwf7EbWo1RhoNzeYnacCk6A__9Jrtr4UZvV9W-seX7g@mail.gmail.com>
Subject: Re: [PATCH 2/3] zswap: dynamic pool creation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Aug 7, 2015 at 2:30 AM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> Hello,
>
> On (08/05/15 09:46), Dan Streetman wrote:
> [..]
>> -enum comp_op {
>> -     ZSWAP_COMPOP_COMPRESS,
>> -     ZSWAP_COMPOP_DECOMPRESS
>> +struct zswap_pool {
>> +     struct zpool *zpool;
>> +     struct kref kref;
>> +     struct list_head list;
>> +     struct rcu_head rcu_head;
>> +     struct notifier_block notifier;
>> +     char tfm_name[CRYPTO_MAX_ALG_NAME];
>
> do you need to keep a second CRYPTO_MAX_ALG_NAME copy? shouldn't it
> be `tfm->__crt_alg->cra_name`, which is what
>         crypto_tfm_alg_name(struct crypto_tfm *tfm)
> does?

well, we don't absolutely have to keep a copy of tfm_name.  However,
->tfm is a __percpu variable, so each time we want to check the pool's
tfm name, we would need to do:
crypto_comp_name(this_cpu_ptr(pool->tfm))

nothing wrong with that really, just adds a bit more code each time we
want to check the tfm name.  I'll send a patch to change it.

>
>> +     struct crypto_comp * __percpu *tfm;
>>  };
>
> ->tfm will be access pretty often, right? did you intentionally put it
> at the bottom offset of `struct zswap_pool'?

no it wasn't intentional; does moving it up provide a benefit?

>
> [..]
>> +static struct zswap_pool *__zswap_pool_current(void)
>>  {
>> -     return totalram_pages * zswap_max_pool_percent / 100 <
>> -             DIV_ROUND_UP(zswap_pool_total_size, PAGE_SIZE);
>> +     struct zswap_pool *pool;
>> +
>> +     pool = list_first_or_null_rcu(&zswap_pools, typeof(*pool), list);
>> +     WARN_ON(!pool);
>> +
>> +     return pool;
>> +}
>> +
>> +static struct zswap_pool *zswap_pool_current(void)
>> +{
>> +     assert_spin_locked(&zswap_pools_lock);
>> +
>> +     return __zswap_pool_current();
>> +}
>
> this one seems to be used only once. do you want to replace
> that single usage (well, if it's really needed)

it's actually used twice, in __zswap_pool_empty() and
__zswap_param_set().  The next patch adds __zswap_param_set().

>
>         WARN_ON(pool == zswap_pool_current());
> with
>         WARN_ON(pool == __zswap_pool_current);
>
> ?
>
> you can then drop zswap_pool_current()... and probably rename
> __zswap_pool_current() to zswap_pool_current().
>
>         -ss
>
>> +static struct zswap_pool *zswap_pool_current_get(void)
>> +{
>> +     struct zswap_pool *pool;
>> +
>> +     rcu_read_lock();
>> +
>> +     pool = __zswap_pool_current();
>> +     if (!pool || !zswap_pool_get(pool))
>> +             pool = NULL;
>> +
>> +     rcu_read_unlock();
>> +
>> +     return pool;
>> +}
>> +
>> +static struct zswap_pool *zswap_pool_last_get(void)
>> +{
>> +     struct zswap_pool *pool, *last = NULL;
>> +
>> +     rcu_read_lock();
>> +
>> +     list_for_each_entry_rcu(pool, &zswap_pools, list)
>> +             last = pool;
>> +     if (!WARN_ON(!last) && !zswap_pool_get(last))
>> +             last = NULL;
>> +
>> +     rcu_read_unlock();
>> +
>> +     return last;
>> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
