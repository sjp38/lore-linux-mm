Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 55DD66B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 07:29:23 -0500 (EST)
Received: by mail-la0-f52.google.com with SMTP id y1so7052703lam.39
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 04:29:22 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id dw4si13630234lbc.80.2013.12.03.04.29.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 04:29:21 -0800 (PST)
Message-ID: <529DCE9A.8000802@parallels.com>
Date: Tue, 3 Dec 2013 16:29:14 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v12 10/18] memcg,list_lru: add per-memcg LRU list infrastructure
References: <cover.1385974612.git.vdavydov@parallels.com> <73d7942f31ac80dfa53bbdd0f957ce5e9a301958.1385974612.git.vdavydov@parallels.com> <20131203111808.GE8803@dastard>
In-Reply-To: <20131203111808.GE8803@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 12/03/2013 03:18 PM, Dave Chinner wrote:
> On Mon, Dec 02, 2013 at 03:19:45PM +0400, Vladimir Davydov wrote:
>> FS-shrinkers, which shrink dcaches and icaches, keep dentries and inodes
>> in list_lru structures in order to evict least recently used objects.
>> With per-memcg kmem shrinking infrastructure introduced, we have to make
>> those LRU lists per-memcg in order to allow shrinking FS caches that
>> belong to different memory cgroups independently.
>>
>> This patch addresses the issue by introducing struct memcg_list_lru.
>> This struct aggregates list_lru objects for each kmem-active memcg, and
>> keeps it uptodate whenever a memcg is created or destroyed. Its
>> interface is very simple: it only allows to get the pointer to the
>> appropriate list_lru object from a memcg or a kmem ptr, which should be
>> further operated with conventional list_lru methods.
> Basically The idea was that the memcg LRUs hide entirely behind the
> generic list_lru interface so that any cache that used the list_lru
> insfrastructure got memcg capabilities for free. memcg's to shrink
> were to be passed through the shrinker control shrinkers to the list
> LRU code, and it then did all the "which lru are we using" logic
> internally.
>
> What you've done is driven all the "which LRU are we using" logic
> into every single caller location. i.e. you've just broken the
> underlying design principle that Glauber and I had worked towards
> with this code - that memcg aware LRUs should be completely
> transparent to list_lru users. Just like NUMA awareness came for
> free with the list_lru code, so should memcg awareness....
>
>> +/*
>> + * The following structure can be used to reclaim kmem objects accounted to
>> + * different memory cgroups independently. It aggregates a set of list_lru
>> + * objects, one for each kmem-enabled memcg, and provides the method to get
>> + * the lru corresponding to a memcg.
>> + */
>> +struct memcg_list_lru {
>> +	struct list_lru global_lru;
>> +
>> +#ifdef CONFIG_MEMCG_KMEM
>> +	struct list_lru **memcg_lrus;	/* rcu-protected array of per-memcg
>> +					   lrus, indexed by memcg_cache_id() */
>> +
>> +	struct list_head list;		/* list of all memcg-aware lrus */
>> +
>> +	/*
>> +	 * The memcg_lrus array is rcu protected, so we can only free it after
>> +	 * a call to synchronize_rcu(). To avoid multiple calls to
>> +	 * synchronize_rcu() when many lrus get updated at the same time, which
>> +	 * is a typical scenario, we will store the pointer to the previous
>> +	 * version of the array in the old_lrus variable for each lru, and then
>> +	 * free them all at once after a single call to synchronize_rcu().
>> +	 */
>> +	void *old_lrus;
>> +#endif
>> +};
> Really, this should be embedded in the struct list_lru, not wrapping
> around the outside. I don't see any changelog to tell me why you
> changed the code from what was last in Glauber's tree, so can you
> explain why exposing all this memcg stuff to everyone is a good
> idea?

I preferred to move from list_lru to memcg_list_lru, because the
connection between list_lru and memcgs' turned memcontrol.c and
list_lru.c into a monolithic structure. When I read comments to the last
version of this patchset submitted by Glauber (v10), I found that Andrew
Morton disliked it, that was why I tried to "fix" it the way you observe
in this patch. Besides, I though that the list_lru may be used w/o memcgs.

I didn't participate in the previous discussion so I don't know all your
plans on it :-( If you think it's unacceptable, I'll try to find another
way around.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
