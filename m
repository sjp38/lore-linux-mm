Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 595EA6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 05:31:42 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id p126-v6so14627673qkd.1
        for <linux-mm@kvack.org>; Mon, 21 May 2018 02:31:42 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0119.outbound.protection.outlook.com. [104.47.0.119])
        by mx.google.com with ESMTPS id e42-v6si6679607qtk.79.2018.05.21.02.31.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 May 2018 02:31:41 -0700 (PDT)
Subject: Re: [PATCH v6 12/17] mm: Set bit in memcg shrinker bitmap on first
 list_lru item apearance
References: <152663268383.5308.8660992135988724014.stgit@localhost.localdomain>
 <152663302275.5308.7476660277265020067.stgit@localhost.localdomain>
 <20180520075558.6ls4yzrkou63orkb@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <2a0ca70d-12bb-8087-9897-9cb33f676177@virtuozzo.com>
Date: Mon, 21 May 2018 12:31:34 +0300
MIME-Version: 1.0
In-Reply-To: <20180520075558.6ls4yzrkou63orkb@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On 20.05.2018 10:55, Vladimir Davydov wrote:
> On Fri, May 18, 2018 at 11:43:42AM +0300, Kirill Tkhai wrote:
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
>>  include/linux/memcontrol.h |   14 ++++++++++++++
>>  mm/list_lru.c              |   22 ++++++++++++++++++++--
>>  2 files changed, 34 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index e51c6e953d7a..7ae1b94becf3 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -1275,6 +1275,18 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
>>  
>>  extern int memcg_expand_shrinker_maps(int new_id);
>>  
>> +static inline void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
>> +					  int nid, int shrinker_id)
>> +{
> 
>> +	if (shrinker_id >= 0 && memcg && memcg != root_mem_cgroup) {
> 
> Nit: I'd remove these checks from this function and require the caller
> to check that shrinker_id >= 0 and memcg != NULL or root_mem_cgroup.
> See below how the call sites would look then.
> 
>> +		struct memcg_shrinker_map *map;
>> +
>> +		rcu_read_lock();
>> +		map = rcu_dereference(memcg->nodeinfo[nid]->shrinker_map);
>> +		set_bit(shrinker_id, map->map);
>> +		rcu_read_unlock();
>> +	}
>> +}
>>  #else
>>  #define for_each_memcg_cache_index(_idx)	\
>>  	for (; NULL; )
>> @@ -1297,6 +1309,8 @@ static inline void memcg_put_cache_ids(void)
>>  {
>>  }
>>  
>> +static inline void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
>> +					  int nid, int shrinker_id) { }
>>  #endif /* CONFIG_MEMCG_KMEM */
>>  
>>  #endif /* _LINUX_MEMCONTROL_H */
>> diff --git a/mm/list_lru.c b/mm/list_lru.c
>> index cab8fad7f7e2..7df71ab0de1c 100644
>> --- a/mm/list_lru.c
>> +++ b/mm/list_lru.c
>> @@ -31,6 +31,11 @@ static void list_lru_unregister(struct list_lru *lru)
>>  	mutex_unlock(&list_lrus_mutex);
>>  }
>>  
>> +static int lru_shrinker_id(struct list_lru *lru)
>> +{
>> +	return lru->shrinker_id;
>> +}
>> +
>>  static inline bool list_lru_memcg_aware(struct list_lru *lru)
>>  {
>>  	/*
>> @@ -94,6 +99,11 @@ static void list_lru_unregister(struct list_lru *lru)
>>  {
>>  }
>>  
>> +static int lru_shrinker_id(struct list_lru *lru)
>> +{
>> +	return -1;
>> +}
>> +
>>  static inline bool list_lru_memcg_aware(struct list_lru *lru)
>>  {
>>  	return false;
>> @@ -119,13 +129,17 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
>>  {
>>  	int nid = page_to_nid(virt_to_page(item));
>>  	struct list_lru_node *nlru = &lru->node[nid];
>> +	struct mem_cgroup *memcg;
>>  	struct list_lru_one *l;
>>  
>>  	spin_lock(&nlru->lock);
>>  	if (list_empty(item)) {
>> -		l = list_lru_from_kmem(nlru, item, NULL);
>> +		l = list_lru_from_kmem(nlru, item, &memcg);
>>  		list_add_tail(item, &l->list);
>> -		l->nr_items++;
>> +		/* Set shrinker bit if the first element was added */
>> +		if (!l->nr_items++)
>> +			memcg_set_shrinker_bit(memcg, nid,
>> +					       lru_shrinker_id(lru));
> 
> This would turn into
> 
> 	if (!l->nr_items++ && memcg)
> 		memcg_set_shrinker_bit(memcg, nid, lru_shrinker_id(lru));
> 
> Note, you don't need to check that lru_shrinker_id(lru) is >= 0 here as
> the fact that memcg != NULL guarantees that. Also, memcg can't be
> root_mem_cgroup here as kmem objects allocated for the root cgroup go
> unaccounted.
> 
>>  		nlru->nr_items++;
>>  		spin_unlock(&nlru->lock);
>>  		return true;
>> @@ -520,6 +534,7 @@ static void memcg_drain_list_lru_node(struct list_lru *lru, int nid,
>>  	struct list_lru_node *nlru = &lru->node[nid];
>>  	int dst_idx = dst_memcg->kmemcg_id;
>>  	struct list_lru_one *src, *dst;
>> +	bool set;
>>  
>>  	/*
>>  	 * Since list_lru_{add,del} may be called under an IRQ-safe lock,
>> @@ -531,7 +546,10 @@ static void memcg_drain_list_lru_node(struct list_lru *lru, int nid,
>>  	dst = list_lru_from_memcg_idx(nlru, dst_idx);
>>  
>>  	list_splice_init(&src->list, &dst->list);
>> +	set = (!dst->nr_items && src->nr_items);
>>  	dst->nr_items += src->nr_items;
>> +	if (set)
>> +		memcg_set_shrinker_bit(dst_memcg, nid, lru_shrinker_id(lru));
> 
> This would turn into
> 
> 	if (set && dst_idx >= 0)
> 		memcg_set_shrinker_bit(dst_memcg, nid, lru_shrinker_id(lru));
> 
> Again, the shrinker is guaranteed to be memcg aware in this function and
> dst_memcg != NULL.
> 
> IMHO such a change would make the code a bit more straightforward.

IMHO, this makes the code less readable. Using single generic function with
generic check is easier, then using two different checks for different places.
Next a person, who will modify the logic, does not have to think about particulars
of strange checks in list_lru_add() and memcg_drain_list_lru_node(), if he/she
does not involved in the change of maps logic. Memory cgroup is already fell
into many corner cases, let's do not introduce them in new places.

>>  	src->nr_items = 0;
>>  
>>  	spin_unlock_irq(&nlru->lock);

Kirill
