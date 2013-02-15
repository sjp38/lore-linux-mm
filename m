Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 4F4606B0005
	for <linux-mm@kvack.org>; Thu, 14 Feb 2013 20:31:18 -0500 (EST)
Received: by mail-qa0-f73.google.com with SMTP id g10so62568qah.0
        for <linux-mm@kvack.org>; Thu, 14 Feb 2013 17:31:17 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 2/7] memcg,list_lru: duplicate LRUs upon kmemcg creation
References: <1360328857-28070-1-git-send-email-glommer@parallels.com>
	<1360328857-28070-3-git-send-email-glommer@parallels.com>
Date: Thu, 14 Feb 2013 17:31:15 -0800
Message-ID: <xr934nhenz18.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Dave Shrinnker <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Fri, Feb 08 2013, Glauber Costa wrote:

> When a new memcg is created, we need to open up room for its descriptors
> in all of the list_lrus that are marked per-memcg. The process is quite
> similar to the one we are using for the kmem caches: we initialize the
> new structures in an array indexed by kmemcg_id, and grow the array if
> needed. Key data like the size of the array will be shared between the
> kmem cache code and the list_lru code (they basically describe the same
> thing)
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/list_lru.h   |  47 +++++++++++++++++
>  include/linux/memcontrol.h |   6 +++
>  lib/list_lru.c             | 115 +++++++++++++++++++++++++++++++++++++---
>  mm/memcontrol.c            | 128 ++++++++++++++++++++++++++++++++++++++++++---
>  mm/slab_common.c           |   1 -
>  5 files changed, 283 insertions(+), 14 deletions(-)
>
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> index 02796da..370b989 100644
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -16,11 +16,58 @@ struct list_lru_node {
>  	long			nr_items;
>  } ____cacheline_aligned_in_smp;
>  
> +struct list_lru_array {
> +	struct list_lru_node node[1];
> +};
> +
>  struct list_lru {
> +	struct list_head	lrus;
>  	struct list_lru_node	node[MAX_NUMNODES];
>  	nodemask_t		active_nodes;
> +#ifdef CONFIG_MEMCG_KMEM
> +	struct list_lru_array	**memcg_lrus;

Probably need a comment regarding that 0x1 is a magic value and
describing what indexes this lazily constructed array.  Is the primary
index memcg_kmem_id and the secondary index a nid?

> +#endif
>  };
>  
> +struct mem_cgroup;
> +#ifdef CONFIG_MEMCG_KMEM
> +/*
> + * We will reuse the last bit of the pointer to tell the lru subsystem that
> + * this particular lru should be replicated when a memcg comes in.
> + */

>From this patch it seems like 0x1 is a magic value rather than bit 0
being special.  memcg_lrus is either 0x1 or a pointer to an array of
struct list_lru_array.  The array is indexed by memcg_kmem_id.

> +static inline void lru_memcg_enable(struct list_lru *lru)

This function is not called yet.  Hmm.

> +{
> +	lru->memcg_lrus = (void *)0x1ULL;
> +}
> +
> +/*
> + * This will return true if we have already allocated and assignment a memcg
> + * pointer set to the LRU. Therefore, we need to mask the first bit out
> + */
> +static inline bool lru_memcg_is_assigned(struct list_lru *lru)
> +{
> +	return (unsigned long)lru->memcg_lrus & ~0x1ULL;

Is this equivalent to?
	return lru->memcg_lrus != NULL && lru->memcg_lrus != 0x1

> +}
> +

[...]

/* comment the meaning of "num" */
> +int memcg_update_all_lrus(unsigned long num)
> +{
> +	int ret = 0;
> +	struct list_lru *lru;
> +

[...]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
