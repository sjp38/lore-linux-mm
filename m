Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 6FB3D6B0027
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 19:09:01 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 55FDA3EE0B6
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:08:59 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CD6245DE50
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:08:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BC9245DE4D
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:08:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C2351DB803E
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:08:59 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A9BDC1DB802F
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:08:58 +0900 (JST)
Message-ID: <51071306.1020107@jp.fujitsu.com>
Date: Tue, 29 Jan 2013 09:08:38 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memcg: reduce the size of struct memcg 244-fold.
References: <1359009996-5350-1-git-send-email-glommer@parallels.com>
In-Reply-To: <1359009996-5350-1-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

(2013/01/24 15:46), Glauber Costa wrote:
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
> ---
>   mm/memcontrol.c | 40 +++++++++++++++++++++++++---------------
>   1 file changed, 25 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 09255ec..09d8b02 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -172,7 +172,7 @@ struct mem_cgroup_per_node {
>   };
>   
>   struct mem_cgroup_lru_info {
> -	struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
> +	struct mem_cgroup_per_node *nodeinfo[0];
>   };
>   
>   /*
> @@ -276,17 +276,6 @@ struct mem_cgroup {
>   	 */
>   	struct res_counter kmem;
>   	/*
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
>   	 * Should the accounting and control be hierarchical, per subtree?
>   	 */
>   	bool use_hierarchy;
> @@ -349,8 +338,29 @@ struct mem_cgroup {
>           /* Index in the kmem_cache->memcg_params->memcg_caches array */
>   	int kmemcg_id;
>   #endif
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
>   };
>   
> +static inline size_t memcg_size(void)
> +{
> +	return sizeof(struct mem_cgroup) +
> +		nr_node_ids * sizeof(struct mem_cgroup_per_node);
> +}
> 
ok, nr_node_ids is made from possible_node_map.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
