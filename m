Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 614946B0003
	for <linux-mm@kvack.org>; Mon, 14 May 2018 05:03:52 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z1-v6so10147879pfh.3
        for <linux-mm@kvack.org>; Mon, 14 May 2018 02:03:52 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0134.outbound.protection.outlook.com. [104.47.2.134])
        by mx.google.com with ESMTPS id j22-v6si3181319pgn.243.2018.05.14.02.03.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 May 2018 02:03:51 -0700 (PDT)
Subject: Re: [PATCH v5 01/13] mm: Assign id to every memcg-aware shrinker
References: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
 <152594593798.22949.6730606876057040426.stgit@localhost.localdomain>
 <20180513051509.df2tcmbhxn3q2fp7@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <e4889603-c337-c389-a819-17f8d4fd03ad@virtuozzo.com>
Date: Mon, 14 May 2018 12:03:38 +0300
MIME-Version: 1.0
In-Reply-To: <20180513051509.df2tcmbhxn3q2fp7@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On 13.05.2018 08:15, Vladimir Davydov wrote:
> On Thu, May 10, 2018 at 12:52:18PM +0300, Kirill Tkhai wrote:
>> The patch introduces shrinker::id number, which is used to enumerate
>> memcg-aware shrinkers. The number start from 0, and the code tries
>> to maintain it as small as possible.
>>
>> This will be used as to represent a memcg-aware shrinkers in memcg
>> shrinkers map.
>>
>> Since all memcg-aware shrinkers are based on list_lru, which is per-memcg
>> in case of !SLOB only, the new functionality will be under MEMCG && !SLOB
>> ifdef (symlinked to CONFIG_MEMCG_SHRINKER).
> 
> Using MEMCG && !SLOB instead of introducing a new config option was done
> deliberately, see:
> 
>   http://lkml.kernel.org/r/20151210202244.GA4809@cmpxchg.org
> 
> I guess, this doesn't work well any more, as there are more and more
> parts depending on kmem accounting, like shrinkers. If you really want
> to introduce a new option, I think you should call it CONFIG_MEMCG_KMEM
> and use it consistently throughout the code instead of MEMCG && !SLOB.
> And this should be done in a separate patch.

What do you mean under "consistently throughout the code"? Should I replace
all MEMCG && !SLOB with CONFIG_MEMCG_KMEM over existing code?

>> diff --git a/fs/super.c b/fs/super.c
>> index 122c402049a2..16c153d2f4f1 100644
>> --- a/fs/super.c
>> +++ b/fs/super.c
>> @@ -248,6 +248,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
>>  	s->s_time_gran = 1000000000;
>>  	s->cleancache_poolid = CLEANCACHE_NO_POOL;
>>  
>> +#ifdef CONFIG_MEMCG_SHRINKER
>> +	s->s_shrink.id = -1;
>> +#endif
> 
> No point doing that - you are going to overwrite the id anyway in
> prealloc_shrinker().

Not so, this is done deliberately. alloc_super() has the only "fail" label,
and it handles all the allocation errors there. The patch just behaves in
the same style. It sets "-1" to make destroy_unused_super() able to differ
the cases, when shrinker is really initialized, and when it's not.
If you don't like this, I can move "s->s_shrink.id = -1;" into
prealloc_memcg_shrinker() instead of this.
 
>>  	s->s_shrink.seeks = DEFAULT_SEEKS;
>>  	s->s_shrink.scan_objects = super_cache_scan;
>>  	s->s_shrink.count_objects = super_cache_count;
> 
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 10c8a38c5eef..d691beac1048 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -169,6 +169,47 @@ unsigned long vm_total_pages;
>>  static LIST_HEAD(shrinker_list);
>>  static DECLARE_RWSEM(shrinker_rwsem);
>>  
>> +#ifdef CONFIG_MEMCG_SHRINKER
>> +static DEFINE_IDR(shrinker_idr);
>> +
>> +static int prealloc_memcg_shrinker(struct shrinker *shrinker)
>> +{
>> +	int id, ret;
>> +
>> +	down_write(&shrinker_rwsem);
>> +	ret = id = idr_alloc(&shrinker_idr, shrinker, 0, 0, GFP_KERNEL);
>> +	if (ret < 0)
>> +		goto unlock;
>> +	shrinker->id = id;
>> +	ret = 0;
>> +unlock:
>> +	up_write(&shrinker_rwsem);
>> +	return ret;
>> +}
>> +
>> +static void del_memcg_shrinker(struct shrinker *shrinker)
> 
> Nit: IMO unregister_memcg_shrinker() would be a better name as it
> matches unregister_shrinker(), just like prealloc_memcg_shrinker()
> matches prealloc_shrinker().
> 
>> +{
>> +	int id = shrinker->id;
>> +
> 
>> +	if (id < 0)
>> +		return;
> 
> Nit: I think this should be BUG_ON(id >= 0) as this function is only
> called for memcg-aware shrinkers AFAICS.

See comment to alloc_super().

>> +
>> +	down_write(&shrinker_rwsem);
>> +	idr_remove(&shrinker_idr, id);
>> +	up_write(&shrinker_rwsem);
>> +	shrinker->id = -1;
>> +}

Kirill
