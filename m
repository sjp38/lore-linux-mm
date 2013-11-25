Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6B55F6B00CC
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 11:56:45 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id u15so2105064bkz.33
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 08:56:44 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id kn7si9774068bkb.275.2013.11.25.08.56.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 08:56:44 -0800 (PST)
Date: Mon, 25 Nov 2013 11:56:39 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v11 09/15] memcg,list_lru: add per-memcg LRU list
 infrastructure
Message-ID: <20131125165639.GD22729@cmpxchg.org>
References: <cover.1385377616.git.vdavydov@parallels.com>
 <e7f905d1cb6af578b8e6e872da909cfbf85030ad.1385377616.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e7f905d1cb6af578b8e6e872da909cfbf85030ad.1385377616.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, glommer@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org

On Mon, Nov 25, 2013 at 04:07:42PM +0400, Vladimir Davydov wrote:
> FS-shrinkers, which shrink dcaches and icaches, keep dentries and inodes
> in list_lru structures in order to evict least recently used objects.
> With per-memcg kmem shrinking infrastructure introduced, we have to make
> those LRU lists per-memcg in order to allow shrinking FS caches that
> belong to different memory cgroups independently.
> 
> This patch addresses the issue by introducing struct memcg_list_lru.
> This struct aggregates list_lru objects for each kmem-active memcg, and
> keeps it uptodate whenever a memcg is created or destroyed. Its
> interface is very simple: it only allows to get the pointer to the
> appropriate list_lru object from a memcg or a kmem ptr, which should be
> further operated with conventional list_lru methods.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Glauber Costa <glommer@openvz.org>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/list_lru.h |   56 ++++++++++
>  mm/memcontrol.c          |  256 ++++++++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 306 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> index 3ce5417..b3b3b86 100644
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -10,6 +10,8 @@
>  #include <linux/list.h>
>  #include <linux/nodemask.h>
>  
> +struct mem_cgroup;
> +
>  /* list_lru_walk_cb has to always return one of those */
>  enum lru_status {
>  	LRU_REMOVED,		/* item removed from list */
> @@ -31,6 +33,27 @@ struct list_lru {
>  	nodemask_t		active_nodes;
>  };
>  
> +struct memcg_list_lru {
> +	struct list_lru global_lru;
> +
> +#ifdef CONFIG_MEMCG_KMEM
> +	struct list_lru **memcg_lrus;	/* rcu-protected array of per-memcg
> +					   lrus, indexed by memcg_cache_id() */
> +
> +	struct list_head list;		/* list of all memcg-aware lrus */
> +
> +	/*
> +	 * The memcg_lrus array is rcu protected, so we can only free it after
> +	 * a call to synchronize_rcu(). To avoid multiple calls to
> +	 * synchronize_rcu() when many lrus get updated at the same time, which
> +	 * is a typical scenario, we will store the pointer to the previous
> +	 * version of the array in the old_lrus variable for each lru, and then
> +	 * free them all at once after a single call to synchronize_rcu().
> +	 */
> +	void *old_lrus;
> +#endif
> +};
> +
>  void list_lru_destroy(struct list_lru *lru);
>  int list_lru_init(struct list_lru *lru);
>  
> @@ -128,4 +151,37 @@ list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
>  	}
>  	return isolated;
>  }
> +
> +#ifdef CONFIG_MEMCG_KMEM
> +int memcg_list_lru_init(struct memcg_list_lru *lru);
> +void memcg_list_lru_destroy(struct memcg_list_lru *lru);
> +
> +struct list_lru *
> +mem_cgroup_list_lru(struct memcg_list_lru *lru, struct mem_cgroup *memcg);
> +struct list_lru *
> +mem_cgroup_kmem_list_lru(struct memcg_list_lru *lru, void *ptr);
> +#else
> +static inline int memcg_list_lru_init(struct memcg_list_lru *lru)
> +{
> +	return list_lru_init(&lru->global_lru);
> +}
> +
> +static inline void memcg_list_lru_destroy(struct memcg_list_lru *lru)
> +{
> +	list_lru_destroy(&lru->global_lru);
> +}
> +
> +static inline struct list_lru *
> +mem_cgroup_list_lru(struct memcg_list_lru *lru, struct mem_cgroup *memcg)
> +{
> +	return &lru->global_lru;
> +}
> +
> +static inline struct list_lru *
> +mem_cgroup_kmem_list_lru(struct memcg_list_lru *lru, void *ptr)
> +{
> +	return &lru->global_lru;
> +}
> +#endif /* CONFIG_MEMCG_KMEM */
> +
>  #endif /* _LRU_LIST_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f5d7128..84f1ca3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -55,6 +55,7 @@
>  #include <linux/cpu.h>
>  #include <linux/oom.h>
>  #include <linux/lockdep.h>
> +#include <linux/list_lru.h>
>  #include "internal.h"
>  #include <net/sock.h>
>  #include <net/ip.h>
> @@ -3249,6 +3250,8 @@ void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
>  	mutex_unlock(&memcg->slab_caches_mutex);
>  }
>  
> +static int memcg_update_all_lrus(int num_groups);

This name is a red flag.  It does not say what the function does, and
return value and parameter are unexpected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
