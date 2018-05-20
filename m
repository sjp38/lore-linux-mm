Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9BD726B06E9
	for <linux-mm@kvack.org>; Sun, 20 May 2018 03:27:07 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id v10-v6so4462989lfe.16
        for <linux-mm@kvack.org>; Sun, 20 May 2018 00:27:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j12-v6sor1070112lfb.107.2018.05.20.00.27.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 May 2018 00:27:05 -0700 (PDT)
Date: Sun, 20 May 2018 10:27:02 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v6 05/17] mm: Assign memcg-aware shrinkers bitmap to memcg
Message-ID: <20180520072702.5ivoc5qxdbcus4td@esperanza>
References: <152663268383.5308.8660992135988724014.stgit@localhost.localdomain>
 <152663295709.5308.12103481076537943325.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152663295709.5308.12103481076537943325.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Fri, May 18, 2018 at 11:42:37AM +0300, Kirill Tkhai wrote:
> Imagine a big node with many cpus, memory cgroups and containers.
> Let we have 200 containers, every container has 10 mounts,
> and 10 cgroups. All container tasks don't touch foreign
> containers mounts. If there is intensive pages write,
> and global reclaim happens, a writing task has to iterate
> over all memcgs to shrink slab, before it's able to go
> to shrink_page_list().
> 
> Iteration over all the memcg slabs is very expensive:
> the task has to visit 200 * 10 = 2000 shrinkers
> for every memcg, and since there are 2000 memcgs,
> the total calls are 2000 * 2000 = 4000000.
> 
> So, the shrinker makes 4 million do_shrink_slab() calls
> just to try to isolate SWAP_CLUSTER_MAX pages in one
> of the actively writing memcg via shrink_page_list().
> I've observed a node spending almost 100% in kernel,
> making useless iteration over already shrinked slab.
> 
> This patch adds bitmap of memcg-aware shrinkers to memcg.
> The size of the bitmap depends on bitmap_nr_ids, and during
> memcg life it's maintained to be enough to fit bitmap_nr_ids
> shrinkers. Every bit in the map is related to corresponding
> shrinker id.
> 
> Next patches will maintain set bit only for really charged
> memcg. This will allow shrink_slab() to increase its
> performance in significant way. See the last patch for
> the numbers.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  include/linux/memcontrol.h |   14 +++++
>  mm/memcontrol.c            |  120 ++++++++++++++++++++++++++++++++++++++++++++
>  mm/vmscan.c                |   10 ++++
>  3 files changed, 144 insertions(+)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 996469bc2b82..e51c6e953d7a 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -112,6 +112,15 @@ struct lruvec_stat {
>  	long count[NR_VM_NODE_STAT_ITEMS];
>  };
>  
> +/*
> + * Bitmap of shrinker::id corresponding to memcg-aware shrinkers,
> + * which have elements charged to this memcg.
> + */
> +struct memcg_shrinker_map {
> +	struct rcu_head rcu;
> +	unsigned long map[0];
> +};
> +
>  /*
>   * per-zone information in memory controller.
>   */
> @@ -125,6 +134,9 @@ struct mem_cgroup_per_node {
>  
>  	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
>  
> +#ifdef CONFIG_MEMCG_KMEM
> +	struct memcg_shrinker_map __rcu	*shrinker_map;
> +#endif
>  	struct rb_node		tree_node;	/* RB tree node */
>  	unsigned long		usage_in_excess;/* Set to the value by which */
>  						/* the soft limit is exceeded*/
> @@ -1261,6 +1273,8 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
>  	return memcg ? memcg->kmemcg_id : -1;
>  }
>  
> +extern int memcg_expand_shrinker_maps(int new_id);
> +
>  #else
>  #define for_each_memcg_cache_index(_idx)	\
>  	for (; NULL; )
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 023a1e9c900e..317a72137b95 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -320,6 +320,120 @@ EXPORT_SYMBOL(memcg_kmem_enabled_key);
>  
>  struct workqueue_struct *memcg_kmem_cache_wq;
>  
> +static int memcg_shrinker_map_size;
> +static DEFINE_MUTEX(memcg_shrinker_map_mutex);
> +
> +static void memcg_free_shrinker_map_rcu(struct rcu_head *head)
> +{
> +	kvfree(container_of(head, struct memcg_shrinker_map, rcu));
> +}
> +
> +static int memcg_expand_one_shrinker_map(struct mem_cgroup *memcg,
> +					 int size, int old_size)

Nit: No point in passing old_size here. You can instead use
memcg_shrinker_map_size directly.

> +{
> +	struct memcg_shrinker_map *new, *old;
> +	int nid;
> +
> +	lockdep_assert_held(&memcg_shrinker_map_mutex);
> +
> +	for_each_node(nid) {
> +		old = rcu_dereference_protected(
> +				memcg->nodeinfo[nid]->shrinker_map, true);

Nit: Sometimes you use mem_cgroup_nodeinfo() helper, sometimes you
access mem_cgorup->nodeinfo directly. Please, be consistent.

> +		/* Not yet online memcg */
> +		if (!old)
> +			return 0;
> +
> +		new = kvmalloc(sizeof(*new) + size, GFP_KERNEL);
> +		if (!new)
> +			return -ENOMEM;
> +
> +		/* Set all old bits, clear all new bits */
> +		memset(new->map, (int)0xff, old_size);
> +		memset((void *)new->map + old_size, 0, size - old_size);
> +
> +		rcu_assign_pointer(memcg->nodeinfo[nid]->shrinker_map, new);
> +		if (old)
> +			call_rcu(&old->rcu, memcg_free_shrinker_map_rcu);
> +	}
> +
> +	return 0;
> +}
> +
> +static void memcg_free_shrinker_maps(struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup_per_node *pn;
> +	struct memcg_shrinker_map *map;
> +	int nid;
> +
> +	if (mem_cgroup_is_root(memcg))
> +		return;
> +
> +	for_each_node(nid) {
> +		pn = mem_cgroup_nodeinfo(memcg, nid);
> +		map = rcu_dereference_protected(pn->shrinker_map, true);
> +		if (map)
> +			kvfree(map);
> +		rcu_assign_pointer(pn->shrinker_map, NULL);
> +	}
> +}
> +
> +static int memcg_alloc_shrinker_maps(struct mem_cgroup *memcg)
> +{
> +	struct memcg_shrinker_map *map;
> +	int nid, size, ret = 0;
> +
> +	if (mem_cgroup_is_root(memcg))
> +		return 0;
> +
> +	mutex_lock(&memcg_shrinker_map_mutex);
> +	size = memcg_shrinker_map_size;
> +	for_each_node(nid) {
> +		map = kvzalloc(sizeof(*map) + size, GFP_KERNEL);
> +		if (!map) {

> +			memcg_free_shrinker_maps(memcg);

Nit: Please don't call this function under the mutex as it isn't
necessary. Set 'ret', break the loop, then check 'ret' after releasing
the mutex, and call memcg_free_shrinker_maps() if it's not 0.

> +			ret = -ENOMEM;
> +			break;
> +		}
> +		rcu_assign_pointer(memcg->nodeinfo[nid]->shrinker_map, map);
> +	}
> +	mutex_unlock(&memcg_shrinker_map_mutex);
> +
> +	return ret;
> +}
> +
> +int memcg_expand_shrinker_maps(int nr)

Nit: Please pass the new shrinker id to this function, not the max
number of shrinkers out there - this will look more intuitive. And
please add a comment to this function. Something like:

  Make sure memcg shrinker maps can store the given shrinker id.
  Expand the maps if necessary.

> +{
> +	int size, old_size, ret = 0;
> +	struct mem_cgroup *memcg;
> +
> +	size = DIV_ROUND_UP(nr, BITS_PER_BYTE);

Note, this will turn into DIV_ROUND_UP(id + 1, BITS_PER_BYTE) then.

> +	old_size = memcg_shrinker_map_size;

Nit: old_size won't be needed if you make memcg_expand_one_shrinker_map
use memcg_shrinker_map_size directly.

> +	if (size <= old_size)
> +		return 0;
> +
> +	mutex_lock(&memcg_shrinker_map_mutex);
> +	if (!root_mem_cgroup)
> +		goto unlock;
> +
> +	for_each_mem_cgroup(memcg) {
> +		if (mem_cgroup_is_root(memcg))
> +			continue;
> +		ret = memcg_expand_one_shrinker_map(memcg, size, old_size);
> +		if (ret)
> +			goto unlock;
> +	}
> +unlock:
> +	if (!ret)
> +		memcg_shrinker_map_size = size;
> +	mutex_unlock(&memcg_shrinker_map_mutex);
> +	return ret;
> +}
> +#else /* CONFIG_MEMCG_KMEM */
> +static int memcg_alloc_shrinker_maps(struct mem_cgroup *memcg)
> +{
> +	return 0;
> +}
> +static void memcg_free_shrinker_maps(struct mem_cgroup *memcg) { }
>  #endif /* CONFIG_MEMCG_KMEM */
>  
>  /**
> @@ -4482,6 +4596,11 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  
> +	if (memcg_alloc_shrinker_maps(memcg)) {
> +		mem_cgroup_id_remove(memcg);
> +		return -ENOMEM;
> +	}
> +
>  	/* Online state pins memcg ID, memcg ID pins CSS */
>  	atomic_set(&memcg->id.ref, 1);
>  	css_get(css);
> @@ -4534,6 +4653,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
>  	vmpressure_cleanup(&memcg->vmpressure);
>  	cancel_work_sync(&memcg->high_work);
>  	mem_cgroup_remove_from_trees(memcg);
> +	memcg_free_shrinker_maps(memcg);
>  	memcg_free_kmem(memcg);
>  	mem_cgroup_free(memcg);
>  }
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 3de12a9bdf85..f09ea20d7270 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -171,6 +171,7 @@ static DECLARE_RWSEM(shrinker_rwsem);
>  
>  #ifdef CONFIG_MEMCG_KMEM
>  static DEFINE_IDR(shrinker_idr);

> +static int memcg_shrinker_nr_max;

Nit: Please rename it to shrinker_id_max and make it store max shrinker
id, not the max number shrinkers that have ever been allocated. This
will make it easier to understand IMO.

Also, this variable doesn't belong to this patch as you don't really
need it to expaned mem cgroup maps. Let's please move it to patch 3
(the one that introduces shrinker_idr).

>  
>  static int prealloc_memcg_shrinker(struct shrinker *shrinker)
>  {
> @@ -181,6 +182,15 @@ static int prealloc_memcg_shrinker(struct shrinker *shrinker)
>  	ret = id = idr_alloc(&shrinker_idr, shrinker, 0, 0, GFP_KERNEL);
>  	if (ret < 0)
>  		goto unlock;

> +
> +	if (id >= memcg_shrinker_nr_max) {
> +		if (memcg_expand_shrinker_maps(id + 1)) {
> +			idr_remove(&shrinker_idr, id);
> +			goto unlock;
> +		}
> +		memcg_shrinker_nr_max = id + 1;
> +	}
> +

Then we'll have here:

	if (memcg_expaned_shrinker_maps(id)) {
		idr_remove(shrinker_idr, id);
		goto unlock;
	}

and from patch 3:

	shrinker_id_max = MAX(shrinker_id_max, id);

>  	shrinker->id = id;
>  	ret = 0;
>  unlock:
> 
