Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E7ED56B000A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 11:31:22 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 62-v6so13266613ply.4
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:31:22 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10124.outbound.protection.outlook.com. [40.107.1.124])
        by mx.google.com with ESMTPS id 4-v6si15307792plb.205.2018.03.26.08.31.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 26 Mar 2018 08:31:21 -0700 (PDT)
Subject: Re: [PATCH 08/10] mm: Set bit in memcg shrinker bitmap on first
 list_lru item apearance
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163856059.21546.11414341109878480074.stgit@localhost.localdomain>
 <20180324194540.rvejbnjg6knkwwia@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <4cd895c4-73cd-935e-2b67-583d8d849b7e@virtuozzo.com>
Date: Mon, 26 Mar 2018 18:31:12 +0300
MIME-Version: 1.0
In-Reply-To: <20180324194540.rvejbnjg6knkwwia@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

On 24.03.2018 22:45, Vladimir Davydov wrote:
> On Wed, Mar 21, 2018 at 04:22:40PM +0300, Kirill Tkhai wrote:
>> Introduce set_shrinker_bit() function to set shrinker-related
>> bit in memcg shrinker bitmap, and set the bit after the first
>> item is added and in case of reparenting destroyed memcg's items.
>>
>> This will allow next patch to make shrinkers be called only,
>> in case of they have charged objects at the moment, and
>> to improve shrink_slab() performance.
>>
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> ---
>>  include/linux/shrinker.h |    7 +++++++
>>  mm/list_lru.c            |   22 ++++++++++++++++++++--
>>  mm/vmscan.c              |    7 +++++++
>>  3 files changed, 34 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
>> index 738de8ef5246..24aeed1bc332 100644
>> --- a/include/linux/shrinker.h
>> +++ b/include/linux/shrinker.h
>> @@ -78,4 +78,11 @@ struct shrinker {
>>  
>>  extern __must_check int register_shrinker(struct shrinker *);
>>  extern void unregister_shrinker(struct shrinker *);
>> +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
>> +extern void set_shrinker_bit(struct mem_cgroup *, int, int);
>> +#else
>> +static inline void set_shrinker_bit(struct mem_cgroup *memcg, int node, int id)
>> +{
>> +}
>> +#endif
> 
> IMO this function, as well as other shrinker bitmap manipulation
> functions, should be defined in memcontrol.[hc] and have mem_cgroup_
> prefix.
> 
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 9d1df5d90eca..265cf069b470 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -378,6 +378,13 @@ static void del_shrinker(struct shrinker *shrinker)
>>  	list_del(&shrinker->list);
>>  	up_write(&shrinker_rwsem);
>>  }
>> +
>> +void set_shrinker_bit(struct mem_cgroup *memcg, int nid, int nr)
>> +{
>> +	struct shrinkers_map *map = SHRINKERS_MAP(memcg);
>> +
>> +	set_bit(nr, map->map[nid]);
>> +}
> 
> Shouldn't we use rcu_read_lock here? After all, the map can be
> reallocated right from under our feet.

We do have to do that! Thanks for pointing.

Kirill
