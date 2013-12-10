Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 30E3D6B00B2
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 05:06:23 -0500 (EST)
Received: by mail-la0-f45.google.com with SMTP id eh20so2522805lab.32
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 02:06:22 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id p10si5175145lag.166.2013.12.10.02.06.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 02:06:21 -0800 (PST)
Message-ID: <52A6E77B.3090106@parallels.com>
Date: Tue, 10 Dec 2013 14:05:47 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v13 11/16] mm: list_lru: add per-memcg lists
References: <cover.1386571280.git.vdavydov@parallels.com> <0ca62dbfbf545edb22b86bd11c50e9017a3dc4db.1386571280.git.vdavydov@parallels.com> <20131210050005.GC31386@dastard>
In-Reply-To: <20131210050005.GC31386@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi, David

First of all, let me thank you for such a thorough review. It is really
helpful. As usual, I can't help agreeing with most of your comments, but
there are a couple of things I'd like to clarify. Please, see comments
inline.

On 12/10/2013 09:00 AM, Dave Chinner wrote:
> On Mon, Dec 09, 2013 at 12:05:52PM +0400, Vladimir Davydov wrote:
>> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
>> index 34e57af..e8add3d 100644
>> --- a/include/linux/list_lru.h
>> +++ b/include/linux/list_lru.h
>> @@ -28,11 +28,47 @@ struct list_lru_node {
>>  	long			nr_items;
>>  } ____cacheline_aligned_in_smp;
>>  
>> +struct list_lru_one {
>> +	struct list_lru_node *node;
>> +	nodemask_t active_nodes;
>> +};
>> +
>>  struct list_lru {
>> -	struct list_lru_node	*node;
>> -	nodemask_t		active_nodes;
>> +	struct list_lru_one	global;
>> +#ifdef CONFIG_MEMCG_KMEM
>> +	/*
>> +	 * In order to provide ability of scanning objects from different
>> +	 * memory cgroups independently, we keep a separate LRU list for each
>> +	 * kmem-active memcg in this array. The array is RCU-protected and
>> +	 * indexed by memcg_cache_id().
>> +	 */
>> +	struct list_lru_one	**memcg;
> OK, as far as I can tell, this is introducing a per-node, per-memcg
> LRU lists. Is that correct?

Yes, it is.

> If so, then that is not what Glauber and I originally intended for
> memcg LRUs. per-node LRUs are expensive in terms of memory and cross
> multiplying them by the number of memcgs in a system was not a good
> use of memory.

Unfortunately, I did not spoke to Glauber about this. I only saw the
last version he tried to submit and the code from his tree. There
list_lru is implemented as per-memcg per-node matrix.

> According to Glauber, most memcgs are small and typically confined
> to a single node or two by external means and therefore don't need the
> scalability numa aware LRUs provide. Hence the idea was that the
> memcg LRUs would just be a single LRU list, just like a non-numa
> aware list_lru instantiation. IOWs, this is the structure that we
> had decided on as the best compromise between memory usage,
> complexity and memcg awareness:
>
> 	global list --- node 0 lru
> 			node 1 lru
> 			.....
> 			node nr_nodes lru
> 	memcg lists	memcg 0 lru
> 			memcg 1 lru
> 			.....
> 			memcg nr_memcgs lru
>
> and the LRU code internally would select either a node or memcg LRU
> to iterated based on the scan information coming in from the
> shrinker. i.e.:
>
>
> struct list_lru {
> 	struct list_lru_node	*node;
> 	nodemask_t		active_nodes;
> #ifdef MEMCG
> 	struct list_lru_node	**memcg;
> 	....

I agree that such a setup would not only reduce memory consumption, but
also make the code look much clearer removing these ugly "list_lru_one"
and "olru" I had to introduce. However, it would also make us scan memcg
LRUs more aggressively than usual NUMA-aware LRUs on global pressure (I
mean kswapd's would scan them on each node). I don't think it's much of
concern though, because this is what we had for all shrinkers before
NUMA-awareness was introduced. Besides, prioritizing memcg LRUs reclaim
over global LRUs sounds sane. That said I like this idea. Thanks.

>>  bool list_lru_add(struct list_lru *lru, struct list_head *item)
>>  {
>> -	int nid = page_to_nid(virt_to_page(item));
>> -	struct list_lru_node *nlru = &lru->node[nid];
>> +	struct page *page = virt_to_page(item);
>> +	int nid = page_to_nid(page);
>> +	struct list_lru_one *olru = lru_of_page(lru, page);
>> +	struct list_lru_node *nlru = &olru->node[nid];
> Yeah, that's per-memcg, per-node dereferencing. And, FWIW, olru/nlru
> are bad names - that's the convention typically used for "old <foo>"
> and "new <foo>" pointers....
>
> As it is, it shouldn't be necessary - lru_of_page() should just
> return a struct list_lru_node....
>
>> +int list_lru_init(struct list_lru *lru)
>> +{
>> +	int err;
>> +
>> +	err = list_lru_init_one(&lru->global);
>> +	if (err)
>> +		goto fail;
>> +
>> +	err = memcg_list_lru_init(lru);
>> +	if (err)
>> +		goto fail;
>> +
>> +	return 0;
>> +fail:
>> +	list_lru_destroy_one(&lru->global);
>> +	lru->global.node = NULL; /* see list_lru_destroy() */
>> +	return err;
>> +}
> I suspect we have users of list_lru that don't want memcg bits added
> to them. Hence I think we want to leave list_lru_init() alone and
> add a list_lru_init_memcg() variant that makes the LRU memcg aware.
> i.e. if the shrinker is not going to be memcg aware, then we don't
> want the LRU to be memcg aware, either....

I though that we want to make all LRUs per-memcg automatically, just
like it was with NUMA awareness. After your explanation about some
FS-specific caches (gfs2/xfs dquot), I admit I was wrong, and not all
caches require per-memcg shrinking. I'll add a flag to list_lru_init()
specifying if we want memcg awareness.

>> +int list_lru_grow_memcg(struct list_lru *lru, size_t new_array_size)
>> +{
>> +	int i;
>> +	struct list_lru_one **memcg_lrus;
>> +
>> +	memcg_lrus = kcalloc(new_array_size, sizeof(*memcg_lrus), GFP_KERNEL);
>> +	if (!memcg_lrus)
>> +		return -ENOMEM;
>> +
>> +	if (lru->memcg) {
>> +		for_each_memcg_cache_index(i) {
>> +			if (lru->memcg[i])
>> +				memcg_lrus[i] = lru->memcg[i];
>> +		}
>> +	}
> Um, krealloc()?

Not exactly. We have to keep the old version until we call sync_rcu.

>> +/*
>> + * This function allocates LRUs for a memcg in all list_lru structures. It is
>> + * called under memcg_create_mutex when a new kmem-active memcg is added.
>> + */
>> +static int memcg_init_all_lrus(int new_memcg_id)
>> +{
>> +	int err = 0;
>> +	int num_memcgs = new_memcg_id + 1;
>> +	int grow = (num_memcgs > memcg_limited_groups_array_size);
>> +	size_t new_array_size = memcg_caches_array_size(num_memcgs);
>> +	struct list_lru *lru;
>> +
>> +	if (grow) {
>> +		list_for_each_entry(lru, &all_memcg_lrus, list) {
>> +			err = list_lru_grow_memcg(lru, new_array_size);
>> +			if (err)
>> +				goto out;
>> +		}
>> +	}
>> +
>> +	list_for_each_entry(lru, &all_memcg_lrus, list) {
>> +		err = list_lru_memcg_alloc(lru, new_memcg_id);
>> +		if (err) {
>> +			__memcg_destroy_all_lrus(new_memcg_id);
>> +			break;
>> +		}
>> +	}
>> +out:
>> +	if (grow) {
>> +		synchronize_rcu();
>> +		list_for_each_entry(lru, &all_memcg_lrus, list) {
>> +			kfree(lru->memcg_old);
>> +			lru->memcg_old = NULL;
>> +		}
>> +	}
>> +	return err;
>> +}
> Urk. That won't scale very well.
>
>> +
>> +int memcg_list_lru_init(struct list_lru *lru)
>> +{
>> +	int err = 0;
>> +	int i;
>> +	struct mem_cgroup *memcg;
>> +
>> +	lru->memcg = NULL;
>> +	lru->memcg_old = NULL;
>> +
>> +	mutex_lock(&memcg_create_mutex);
>> +	if (!memcg_kmem_enabled())
>> +		goto out_list_add;
>> +
>> +	lru->memcg = kcalloc(memcg_limited_groups_array_size,
>> +			     sizeof(*lru->memcg), GFP_KERNEL);
>> +	if (!lru->memcg) {
>> +		err = -ENOMEM;
>> +		goto out;
>> +	}
>> +
>> +	for_each_mem_cgroup(memcg) {
>> +		int memcg_id;
>> +
>> +		memcg_id = memcg_cache_id(memcg);
>> +		if (memcg_id < 0)
>> +			continue;
>> +
>> +		err = list_lru_memcg_alloc(lru, memcg_id);
>> +		if (err) {
>> +			mem_cgroup_iter_break(NULL, memcg);
>> +			goto out_free_lru_memcg;
>> +		}
>> +	}
>> +out_list_add:
>> +	list_add(&lru->list, &all_memcg_lrus);
>> +out:
>> +	mutex_unlock(&memcg_create_mutex);
>> +	return err;
>> +
>> +out_free_lru_memcg:
>> +	for (i = 0; i < memcg_limited_groups_array_size; i++)
>> +		list_lru_memcg_free(lru, i);
>> +	kfree(lru->memcg);
>> +	goto out;
>> +}
> That will probably scale even worse. Think about what happens when we
> try to mount a bunch of filesystems in parallel - they will now
> serialise completely on this memcg_create_mutex instantiating memcg
> lists inside list_lru_init().

Yes, the scalability seems to be the main problem here. I have a couple
of thoughts on how it could be improved. Here they go:

1) We can turn memcg_create_mutex to rw-semaphore (or introduce an
rw-semaphore, which we would take for modifying list_lru's) and take it
for reading in memcg_list_lru_init() and for writing when we create a
new memcg (memcg_init_all_lrus()).
This would remove the bottleneck from the mount path, but every memcg
creation would still iterate over all LRUs under a memcg mutex. So I
guess it is not an option, isn't it?

2) We could use cmpxchg() instead of a mutex in list_lru_init_memcg()
and memcg_init_all_lrus() to assure a memcg LRU is initialized only
once. But again, this would not remove iteration over all LRUs from
memcg_init_all_lrus().

3) We can try to initialize per-memcg LRUs lazily only when we actually
need them, similar to how we now handle per-memcg kmem caches creation.
If list_lru_add() cannot find appropriate LRU, it will schedule a
background worker for its initialization.
The benefits of this approach are clear: we do not introduce any
bottlenecks, and we lower memory consumption in case different memcgs
use different mounts exclusively.
However, there is one thing that bothers me. Some objects accounted to a
memcg will go into the global LRU, which will postpone actual memcg
destruction until global reclaim.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
