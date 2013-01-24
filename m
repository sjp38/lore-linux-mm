Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 5ADDC6B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 19:18:12 -0500 (EST)
Date: Wed, 23 Jan 2013 16:18:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: reduce the size of struct memcg 244-fold.
Message-Id: <20130123161810.73e4ca58.akpm@linux-foundation.org>
In-Reply-To: <1358962426-8738-1-git-send-email-glommer@parallels.com>
References: <1358962426-8738-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Wed, 23 Jan 2013 21:33:46 +0400
Glauber Costa <glommer@parallels.com> wrote:

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

Seems sensible.

> +static inline int memcg_size(void)
> +{
> +	return sizeof(struct mem_cgroup) +
> +		nr_node_ids * sizeof(struct mem_cgroup_per_node);
> +}
> +
>  /* internal only representation about the status of kmem accounting. */
>  enum {
>  	KMEM_ACCOUNTED_ACTIVE = 0, /* accounted by this cgroup itself */
> @@ -5894,9 +5904,9 @@ static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
>  static struct mem_cgroup *mem_cgroup_alloc(void)
>  {
>  	struct mem_cgroup *memcg;
> -	int size = sizeof(struct mem_cgroup);
> +	int size = memcg_size();
>  
> -	/* Can be very big if MAX_NUMNODES is very big */
> +	/* Can be very big if nr_node_ids is very big */
>  	if (size < PAGE_SIZE)
>  		memcg = kzalloc(size, GFP_KERNEL);
>  	else
> @@ -5933,7 +5943,7 @@ out_free:
>  static void __mem_cgroup_free(struct mem_cgroup *memcg)
>  {
>  	int node;
> -	int size = sizeof(struct mem_cgroup);
> +	int size = memcg_size();
>  
>  	mem_cgroup_remove_from_trees(memcg);
>  	free_css_id(&mem_cgroup_subsys, &memcg->css);

Really everything here should be using size_t - a minor
cosmetic/readability thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
