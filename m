Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 00A776B0023
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 05:41:26 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w19-v6so15055846plq.2
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 02:41:25 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0102.outbound.protection.outlook.com. [104.47.0.102])
        by mx.google.com with ESMTPS id q2si625651pgc.401.2018.03.27.02.41.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Mar 2018 02:41:24 -0700 (PDT)
Subject: =?UTF-8?Q?Re:_=e7=ad=94=e5=a4=8d:_[PATCH]_mm/list=5flru:_replace_sp?=
 =?UTF-8?Q?inlock_with_RCU_in_=5f=5flist=5flru=5fcount=5fone?=
References: <1522137544-27496-1-git-send-email-lirongqing@baidu.com>
 <20180327081546.GZ5652@dhcp22.suse.cz>
 <20180327090841.ujscbnb54cepencf@esperanza>
 <2AD939572F25A448A3AE3CAEA61328C23750D637@BC-MAIL-M28.internal.baidu.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <f384fb51-22e6-ddd8-b957-4f358fe1e03a@virtuozzo.com>
Date: Tue, 27 Mar 2018 12:41:16 +0300
MIME-Version: 1.0
In-Reply-To: <2AD939572F25A448A3AE3CAEA61328C23750D637@BC-MAIL-M28.internal.baidu.com>
Content-Type: text/plain; charset=gbk
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li,Rongqing" <lirongqing@baidu.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>

On 27.03.2018 12:30, Li,Rongqing wrote:
> 
> 
>> -----OE 1/4 thO- 1/4 th-----
>> .c 1/4 thEE: Vladimir Davydov [mailto:vdavydov.dev@gmail.com]
>> .cEIE+- 1/4 a: 2018Ae3OA27EO 17:09
>> EO 1/4 thEE: Michal Hocko <mhocko@kernel.org>
>> 3-EI: Li,Rongqing <lirongqing@baidu.com>; linux-kernel@vger.kernel.org;
>> linux-mm@kvack.org; Andrew Morton <akpm@linux-foundation.org>;
>> Johannes Weiner <hannes@cmpxchg.org>; Dave Chinner
>> <david@fromorbit.com>; Kirill Tkhai <ktkhai@virtuozzo.com>
>> O/Ia: Re: [PATCH] mm/list_lru: replace spinlock with RCU in
>> __list_lru_count_one
>>
>> [Cc Kirill]
>>
>> AFAIU this has already been fixed in exactly the same fashion by Kirill
>> (mmotm commit 8e7d1201ec71 "mm: make counting of
>> list_lru_one::nr_items lockless"). Kirill is working on further optimizations
>> right now, see
>>
>>
> 
> Ok, thanks

Thanks Vladimir, for CCing me.

Rong, if your are interested I may start to add you to CC on further iterations
of https://marc.info/?i=152163840790.21546.980703278415599202.stgit%40localhost.localdomain
since there are many people which meet such the problem.

Kirill

> 
>> https://lkml.kernel.org/r/152163840790.21546.980703278415599202.stgit
>> @localhost.localdomain
>>
>> On Tue, Mar 27, 2018 at 10:15:46AM +0200, Michal Hocko wrote:
>>> [CC Dave]
>>>
>>> On Tue 27-03-18 15:59:04, Li RongQing wrote:
>>>> when reclaim memory, shink_slab will take lots of time even if no
>>>> memory is reclaimed, since list_lru_count_one called by it needs to
>>>> take a spinlock
>>>>
>>>> try to optimize it by replacing spinlock with RCU in
>>>> __list_lru_count_one
>>>
>>> Isn't the RCU overkill here? Why cannot we simply do an optimistic
>>> lockless check for nr_items? It would be racy but does it actually
>>> matter? We should be able to tolerate occasional 0 to non-zero and
>>> vice versa transitions AFAICS.
>>>
>>>>
>>>>     $dd if=aaa  of=bbb  bs=1k count=3886080
>>>>     $rm -f bbb
>>>>     $time echo
>> 100000000 >/cgroup/memory/test/memory.limit_in_bytes
>>>>
>>>> Before: 0m0.415s ===> after: 0m0.395s
>>>>
>>>> Signed-off-by: Li RongQing <lirongqing@baidu.com>
>>>> ---
>>>>  include/linux/list_lru.h |  2 ++
>>>>  mm/list_lru.c            | 69
>> ++++++++++++++++++++++++++++++++++--------------
>>>>  2 files changed, 51 insertions(+), 20 deletions(-)
>>>>
>>>> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
>>>> index bb8129a3474d..ae472538038e 100644
>>>> --- a/include/linux/list_lru.h
>>>> +++ b/include/linux/list_lru.h
>>>> @@ -29,6 +29,7 @@ struct list_lru_one {
>>>>  	struct list_head	list;
>>>>  	/* may become negative during memcg reparenting */
>>>>  	long			nr_items;
>>>> +	struct rcu_head		rcu;
>>>>  };
>>>>
>>>>  struct list_lru_memcg {
>>>> @@ -46,6 +47,7 @@ struct list_lru_node {
>>>>  	struct list_lru_memcg	*memcg_lrus;
>>>>  #endif
>>>>  	long nr_items;
>>>> +	struct rcu_head		rcu;
>>>>  } ____cacheline_aligned_in_smp;
>>>>
>>>>  struct list_lru {
>>>> diff --git a/mm/list_lru.c b/mm/list_lru.c index
>>>> fd41e969ede5..4c58ed861729 100644
>>>> --- a/mm/list_lru.c
>>>> +++ b/mm/list_lru.c
>>>> @@ -52,13 +52,13 @@ static inline bool list_lru_memcg_aware(struct
>>>> list_lru *lru)  static inline struct list_lru_one *
>>>> list_lru_from_memcg_idx(struct list_lru_node *nlru, int idx)  {
>>>> -	/*
>>>> -	 * The lock protects the array of per cgroup lists from relocation
>>>> -	 * (see memcg_update_list_lru_node).
>>>> -	 */
>>>> -	lockdep_assert_held(&nlru->lock);
>>>> -	if (nlru->memcg_lrus && idx >= 0)
>>>> -		return nlru->memcg_lrus->lru[idx];
>>>> +	struct list_lru_memcg *tmp;
>>>> +
>>>> +	WARN_ON_ONCE(!rcu_read_lock_held());
>>>> +
>>>> +	tmp = rcu_dereference(nlru->memcg_lrus);
>>>> +	if (tmp && idx >= 0)
>>>> +		return rcu_dereference(tmp->lru[idx]);
>>>>
>>>>  	return &nlru->lru;
>>>>  }
>>>> @@ -113,14 +113,17 @@ bool list_lru_add(struct list_lru *lru, struct
>> list_head *item)
>>>>  	struct list_lru_one *l;
>>>>
>>>>  	spin_lock(&nlru->lock);
>>>> +	rcu_read_lock();
>>>>  	if (list_empty(item)) {
>>>>  		l = list_lru_from_kmem(nlru, item);
>>>>  		list_add_tail(item, &l->list);
>>>>  		l->nr_items++;
>>>>  		nlru->nr_items++;
>>>> +		rcu_read_unlock();
>>>>  		spin_unlock(&nlru->lock);
>>>>  		return true;
>>>>  	}
>>>> +	rcu_read_unlock();
>>>>  	spin_unlock(&nlru->lock);
>>>>  	return false;
>>>>  }
>>>> @@ -133,14 +136,17 @@ bool list_lru_del(struct list_lru *lru, struct
>> list_head *item)
>>>>  	struct list_lru_one *l;
>>>>
>>>>  	spin_lock(&nlru->lock);
>>>> +	rcu_read_lock();
>>>>  	if (!list_empty(item)) {
>>>>  		l = list_lru_from_kmem(nlru, item);
>>>>  		list_del_init(item);
>>>>  		l->nr_items--;
>>>>  		nlru->nr_items--;
>>>> +		rcu_read_unlock();
>>>>  		spin_unlock(&nlru->lock);
>>>>  		return true;
>>>>  	}
>>>> +	rcu_read_unlock();
>>>>  	spin_unlock(&nlru->lock);
>>>>  	return false;
>>>>  }
>>>> @@ -166,12 +172,13 @@ static unsigned long
>>>> __list_lru_count_one(struct list_lru *lru,  {
>>>>  	struct list_lru_node *nlru = &lru->node[nid];
>>>>  	struct list_lru_one *l;
>>>> -	unsigned long count;
>>>> +	unsigned long count = 0;
>>>>
>>>> -	spin_lock(&nlru->lock);
>>>> +	rcu_read_lock();
>>>>  	l = list_lru_from_memcg_idx(nlru, memcg_idx);
>>>> -	count = l->nr_items;
>>>> -	spin_unlock(&nlru->lock);
>>>> +	if (l)
>>>> +		count = l->nr_items;
>>>> +	rcu_read_unlock();
>>>>
>>>>  	return count;
>>>>  }
>>>> @@ -204,6 +211,7 @@ __list_lru_walk_one(struct list_lru *lru, int nid,
>> int memcg_idx,
>>>>  	unsigned long isolated = 0;
>>>>
>>>>  	spin_lock(&nlru->lock);
>>>> +	rcu_read_lock();
>>>>  	l = list_lru_from_memcg_idx(nlru, memcg_idx);
>>>>  restart:
>>>>  	list_for_each_safe(item, n, &l->list) { @@ -250,6 +258,7 @@
>>>> __list_lru_walk_one(struct list_lru *lru, int nid, int memcg_idx,
>>>>  		}
>>>>  	}
>>>>
>>>> +	rcu_read_unlock();
>>>>  	spin_unlock(&nlru->lock);
>>>>  	return isolated;
>>>>  }
>>>> @@ -296,9 +305,14 @@ static void
>> __memcg_destroy_list_lru_node(struct list_lru_memcg *memcg_lrus,
>>>>  					  int begin, int end)
>>>>  {
>>>>  	int i;
>>>> +	struct list_lru_one *tmp;
>>>>
>>>> -	for (i = begin; i < end; i++)
>>>> -		kfree(memcg_lrus->lru[i]);
>>>> +	for (i = begin; i < end; i++) {
>>>> +		tmp = memcg_lrus->lru[i];
>>>> +		rcu_assign_pointer(memcg_lrus->lru[i], NULL);
>>>> +		if (tmp)
>>>> +			kfree_rcu(tmp, rcu);
>>>> +	}
>>>>  }
>>>>
>>>>  static int __memcg_init_list_lru_node(struct list_lru_memcg
>>>> *memcg_lrus, @@ -314,7 +328,7 @@ static int
>> __memcg_init_list_lru_node(struct list_lru_memcg *memcg_lrus,
>>>>  			goto fail;
>>>>
>>>>  		init_one_lru(l);
>>>> -		memcg_lrus->lru[i] = l;
>>>> +		rcu_assign_pointer(memcg_lrus->lru[i], l);
>>>>  	}
>>>>  	return 0;
>>>>  fail:
>>>> @@ -325,25 +339,37 @@ static int __memcg_init_list_lru_node(struct
>>>> list_lru_memcg *memcg_lrus,  static int
>>>> memcg_init_list_lru_node(struct list_lru_node *nlru)  {
>>>>  	int size = memcg_nr_cache_ids;
>>>> +	struct list_lru_memcg *tmp;
>>>>
>>>> -	nlru->memcg_lrus = kvmalloc(size * sizeof(void *), GFP_KERNEL);
>>>> -	if (!nlru->memcg_lrus)
>>>> +	tmp = kvmalloc(size * sizeof(void *), GFP_KERNEL);
>>>> +	if (!tmp)
>>>>  		return -ENOMEM;
>>>>
>>>> -	if (__memcg_init_list_lru_node(nlru->memcg_lrus, 0, size)) {
>>>> -		kvfree(nlru->memcg_lrus);
>>>> +	if (__memcg_init_list_lru_node(tmp, 0, size)) {
>>>> +		kvfree(tmp);
>>>>  		return -ENOMEM;
>>>>  	}
>>>>
>>>> +	rcu_assign_pointer(nlru->memcg_lrus, tmp);
>>>> +
>>>>  	return 0;
>>>>  }
>>>>
>>>> -static void memcg_destroy_list_lru_node(struct list_lru_node *nlru)
>>>> +static void memcg_destroy_list_lru_node_rcu(struct rcu_head *rcu)
>>>>  {
>>>> +	struct list_lru_node *nlru;
>>>> +
>>>> +	nlru = container_of(rcu, struct list_lru_node, rcu);
>>>> +
>>>>  	__memcg_destroy_list_lru_node(nlru->memcg_lrus, 0,
>> memcg_nr_cache_ids);
>>>>  	kvfree(nlru->memcg_lrus);
>>>>  }
>>>>
>>>> +static void memcg_destroy_list_lru_node(struct list_lru_node *nlru)
>>>> +{
>>>> +	call_rcu(&nlru->rcu, memcg_destroy_list_lru_node_rcu); }
>>>> +
>>>>  static int memcg_update_list_lru_node(struct list_lru_node *nlru,
>>>>  				      int old_size, int new_size)  { @@ -371,9
>> +397,10 @@
>>>> static int memcg_update_list_lru_node(struct list_lru_node *nlru,
>>>>  	 * we have to use IRQ-safe primitives here to avoid deadlock.
>>>>  	 */
>>>>  	spin_lock_irq(&nlru->lock);
>>>> -	nlru->memcg_lrus = new;
>>>> +	rcu_assign_pointer(nlru->memcg_lrus, new);
>>>>  	spin_unlock_irq(&nlru->lock);
>>>>
>>>> +	synchronize_rcu();
>>>>  	kvfree(old);
>>>>  	return 0;
>>>>  }
>>>> @@ -487,6 +514,7 @@ static void memcg_drain_list_lru_node(struct
>> list_lru_node *nlru,
>>>>  	 * we have to use IRQ-safe primitives here to avoid deadlock.
>>>>  	 */
>>>>  	spin_lock_irq(&nlru->lock);
>>>> +	rcu_read_lock();
>>>>
>>>>  	src = list_lru_from_memcg_idx(nlru, src_idx);
>>>>  	dst = list_lru_from_memcg_idx(nlru, dst_idx); @@ -495,6 +523,7
>> @@
>>>> static void memcg_drain_list_lru_node(struct list_lru_node *nlru,
>>>>  	dst->nr_items += src->nr_items;
>>>>  	src->nr_items = 0;
>>>>
>>>> +	rcu_read_unlock();
>>>>  	spin_unlock_irq(&nlru->lock);
>>>>  }
>>>>
>>>> --
>>>> 2.11.0
>>>
>>> --
>>> Michal Hocko
>>> SUSE Labs
>>>
