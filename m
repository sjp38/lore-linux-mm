Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id D6A746B0002
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 02:50:33 -0500 (EST)
Received: by mail-yh0-f74.google.com with SMTP id z12so785321yhz.1
        for <linux-mm@kvack.org>; Wed, 23 Jan 2013 23:50:33 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v2] memcg: reduce the size of struct memcg 244-fold.
References: <1359009996-5350-1-git-send-email-glommer@parallels.com>
Date: Wed, 23 Jan 2013 23:50:31 -0800
In-Reply-To: <1359009996-5350-1-git-send-email-glommer@parallels.com> (Glauber
	Costa's message of "Thu, 24 Jan 2013 10:46:35 +0400")
Message-ID: <xr93r4lbrpdk.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Wed, Jan 23 2013, Glauber Costa wrote:

> In order to maintain all the memcg bookkeeping, we need per-node
> descriptors, which will in turn contain a per-zone descriptor.
>
> Because we want to statically allocate those, this array ends up being
> very big. Part of the reason is that we allocate something large enough
> to hold MAX_NUMNODES, the compile time constant that holds the maximum
> number of nodes we would ever consider.
>
> However, we can do better in some cases if the firmware help us. This is
> true for modern x86 machines; coincidentally one of the architectures in
> which MAX_NUMNODES tends to be very big.
>
> By using the firmware-provided maximum number of nodes instead of
> MAX_NUMNODES, we can reduce the memory footprint of struct memcg
> considerably. In the extreme case in which we have only one node, this
> reduces the size of the structure from ~ 64k to ~2k. This is
> particularly important because it means that we will no longer resort to
> the vmalloc area for the struct memcg on defconfigs. We also have enough
> room for an extra node and still be outside vmalloc.
>
> One also has to keep in mind that with the industry's ability to fit
> more processors in a die as fast as the FED prints money, a nodes = 2
> configuration is already respectably big.
>
> [ v2: use size_t for size calculations ]
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Greg Thelen <gthelen@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Ying Han <yinghan@google.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>

Reviewed-by: Greg Thelen <gthelen@google.com>

> ---
>  mm/memcontrol.c | 40 +++++++++++++++++++++++++---------------
>  1 file changed, 25 insertions(+), 15 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 09255ec..09d8b02 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -172,7 +172,7 @@ struct mem_cgroup_per_node {
>  };
>  
>  struct mem_cgroup_lru_info {
> -	struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
> +	struct mem_cgroup_per_node *nodeinfo[0];

It seems like a VM_BUG_ON() in mem_cgroup_zoneinfo() asserting that the
nid index is less than nr_node_ids would be good at catching illegal
indexes.  I don't see any illegal indexes in your patch, but I fear that
someday a MAX_NUMNODES based for() loop might sneak in.

>  };
>  
>  /*
> @@ -276,17 +276,6 @@ struct mem_cgroup {
>  	 */
>  	struct res_counter kmem;
>  	/*
> -	 * Per cgroup active and inactive list, similar to the
> -	 * per zone LRU lists.
> -	 */
> -	struct mem_cgroup_lru_info info;
> -	int last_scanned_node;
> -#if MAX_NUMNODES > 1
> -	nodemask_t	scan_nodes;
> -	atomic_t	numainfo_events;
> -	atomic_t	numainfo_updating;
> -#endif
> -	/*
>  	 * Should the accounting and control be hierarchical, per subtree?
>  	 */
>  	bool use_hierarchy;
> @@ -349,8 +338,29 @@ struct mem_cgroup {
>          /* Index in the kmem_cache->memcg_params->memcg_caches array */
>  	int kmemcg_id;
>  #endif
> +
> +	int last_scanned_node;
> +#if MAX_NUMNODES > 1
> +	nodemask_t	scan_nodes;
> +	atomic_t	numainfo_events;
> +	atomic_t	numainfo_updating;
> +#endif
> +	/*
> +	 * Per cgroup active and inactive list, similar to the
> +	 * per zone LRU lists.
> +	 *
> +	 * WARNING: This has to be the last element of the struct. Don't
> +	 * add new fields after this point.
> +	 */
> +	struct mem_cgroup_lru_info info;
>  };
>  
> +static inline size_t memcg_size(void)
> +{
> +	return sizeof(struct mem_cgroup) +
> +		nr_node_ids * sizeof(struct mem_cgroup_per_node);
> +}
> +

Tangential question: why use inline here?  I figure that modern
compilers are good at making inlining decisions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
