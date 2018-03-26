Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D613A6B0009
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 11:29:19 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id v4-v6so13239413plp.16
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:29:19 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40110.outbound.protection.outlook.com. [40.107.4.110])
        by mx.google.com with ESMTPS id y4si4050420pfd.257.2018.03.26.08.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 26 Mar 2018 08:29:18 -0700 (PDT)
Subject: Re: [PATCH 03/10] mm: Assign memcg-aware shrinkers bitmap to memcg
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163850081.21546.6969747084834474733.stgit@localhost.localdomain>
 <20180324192521.my7akysvj7wtudan@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <09663190-12dd-4353-668d-f4fc2f27c2d7@virtuozzo.com>
Date: Mon, 26 Mar 2018 18:29:05 +0300
MIME-Version: 1.0
In-Reply-To: <20180324192521.my7akysvj7wtudan@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

On 24.03.2018 22:25, Vladimir Davydov wrote:
> On Wed, Mar 21, 2018 at 04:21:40PM +0300, Kirill Tkhai wrote:
>> Imagine a big node with many cpus, memory cgroups and containers.
>> Let we have 200 containers, every container has 10 mounts,
>> and 10 cgroups. All container tasks don't touch foreign
>> containers mounts. If there is intensive pages write,
>> and global reclaim happens, a writing task has to iterate
>> over all memcgs to shrink slab, before it's able to go
>> to shrink_page_list().
>>
>> Iteration over all the memcg slabs is very expensive:
>> the task has to visit 200 * 10 = 2000 shrinkers
>> for every memcg, and since there are 2000 memcgs,
>> the total calls are 2000 * 2000 = 4000000.
>>
>> So, the shrinker makes 4 million do_shrink_slab() calls
>> just to try to isolate SWAP_CLUSTER_MAX pages in one
>> of the actively writing memcg via shrink_page_list().
>> I've observed a node spending almost 100% in kernel,
>> making useless iteration over already shrinked slab.
>>
>> This patch adds bitmap of memcg-aware shrinkers to memcg.
>> The size of the bitmap depends on bitmap_nr_ids, and during
>> memcg life it's maintained to be enough to fit bitmap_nr_ids
>> shrinkers. Every bit in the map is related to corresponding
>> shrinker id.
>>
>> Next patches will maintain set bit only for really charged
>> memcg. This will allow shrink_slab() to increase its
>> performance in significant way. See the last patch for
>> the numbers.
>>
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> ---
>>  include/linux/memcontrol.h |   20 ++++++++
>>  mm/memcontrol.c            |    5 ++
>>  mm/vmscan.c                |  117 ++++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 142 insertions(+)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 4525b4404a9e..ad88a9697fb9 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -151,6 +151,11 @@ struct mem_cgroup_thresholds {
>>  	struct mem_cgroup_threshold_ary *spare;
>>  };
>>  
>> +struct shrinkers_map {
> 
> IMO better call it mem_cgroup_shrinker_map.
> 
>> +	struct rcu_head rcu;
>> +	unsigned long *map[0];
>> +};
>> +
>>  enum memcg_kmem_state {
>>  	KMEM_NONE,
>>  	KMEM_ALLOCATED,
>> @@ -182,6 +187,9 @@ struct mem_cgroup {
>>  	unsigned long low;
>>  	unsigned long high;
>>  
>> +	/* Bitmap of shrinker ids suitable to call for this memcg */
>> +	struct shrinkers_map __rcu *shrinkers_map;
>> +
> 
> We keep all per-node data in mem_cgroup_per_node struct. I think this
> bitmap should be defined there as well.

But them we'll have to have struct rcu_head for every node to free the map
via rcu. This is the only reason I did that. But if you think it's not a problem,
I'll agree with you.

>>  	/* Range enforcement for interrupt charges */
>>  	struct work_struct high_work;
>>  
> 
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 3801ac1fcfbc..2324577c62dc 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -4476,6 +4476,9 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
>>  {
>>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>>  
>> +	if (alloc_shrinker_maps(memcg))
>> +		return -ENOMEM;
>> +
> 
> This needs a comment explaining why you can't allocate the map in
> css_alloc, which seems to be a better place for it.

I want to use for_each_mem_cgroup_tree() which seem require the memcg
is online. Otherwise map expanding will skip such memcg.
Comment is not a problem ;)

>>  	/* Online state pins memcg ID, memcg ID pins CSS */
>>  	atomic_set(&memcg->id.ref, 1);
>>  	css_get(css);
>> @@ -4487,6 +4490,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>>  	struct mem_cgroup_event *event, *tmp;
>>  
>> +	free_shrinker_maps(memcg);
>> +
> 
> AFAIU this can race with shrink_slab accessing the map, resulting in
> use-after-free. IMO it would be safer to free the bitmap from css_free.

But doesn't shrink_slab() iterate only online memcg?

>>  	/*
>>  	 * Unregister events and notify userspace.
>>  	 * Notify userspace about cgroup removing only after rmdir of cgroup
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 97ce4f342fab..9d1df5d90eca 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -165,6 +165,10 @@ static DECLARE_RWSEM(bitmap_rwsem);
>>  static int bitmap_id_start;
>>  static int bitmap_nr_ids;
>>  static struct shrinker **mcg_shrinkers;
>> +struct shrinkers_map *__rcu root_shrinkers_map;
> 
> Why do you need root_shrinkers_map? AFAIR the root memory cgroup doesn't
> have kernel memory accounting enabled.
But we can charge the corresponding lru and iterate it over global reclaim,
don't we?

struct list_lru_node {
	...
        /* global list, used for the root cgroup in cgroup aware lrus */
        struct list_lru_one     lru;
	...
};


>> +
>> +#define SHRINKERS_MAP(memcg) \
>> +	(memcg == root_mem_cgroup || !memcg ? root_shrinkers_map : memcg->shrinkers_map)
>>  
>>  static int expand_shrinkers_array(int old_nr, int nr)
>>  {
>> @@ -188,6 +192,116 @@ static int expand_shrinkers_array(int old_nr, int nr)
>>  	return 0;
>>  }
>>  
>> +static void kvfree_map_rcu(struct rcu_head *head)
>> +{
> 
>> +static int memcg_expand_maps(struct mem_cgroup *memcg, int size, int old_size)
>> +{
> 
>> +int alloc_shrinker_maps(struct mem_cgroup *memcg)
>> +{
> 
>> +void free_shrinker_maps(struct mem_cgroup *memcg)
>> +{
> 
>> +static int expand_shrinker_maps(int old_id, int id)
>> +{
> 
> All these functions should be defined in memcontrol.c
> 
> The only public function should be mem_cgroup_grow_shrinker_map (I'm not
> insisting on the name), which reallocates shrinker bitmap for each
> cgroups so that it can accommodate the new shrinker id. To do that,
> you'll probably need to keep track of the bitmap capacity in
> memcontrol.c

Ok, I will do, thanks.

Kirill
